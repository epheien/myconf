#!/usr/bin/env bash
# Route marked EasyTier IPv4 sockets through a dedicated gateway.
set -euo pipefail
export LC_ALL=C

usage() {
    cat <<'EOF'
Usage:
  easytier-route.sh apply  --gateway IPv4 [options]
  easytier-route.sh remove --gateway IPv4 [options]
  easytier-route.sh status [options]

Options:
  --gateway IPv4    Directly reachable gateway; never inferred from the default route
  --dev IFACE       Outgoing interface; auto-detected from the gateway if omitted
  --mark NUMBER     EasyTier socket_mark, decimal or hexadecimal (default: 109)
  --table NUMBER    Dedicated routing table (default: 109)
  --priority N      Two consecutive rule priorities, N and N+1 (default: 9000)
  --dry-run         Validate and print changes without applying them
  -h, --help        Show this help

Linux only. Requires Bash, iproute2 and awk; mutations require root.
Existing specific routes in main remain preferred over the dedicated default.
Run in the same network namespace as easytier-core. IPv6 is not configured.
Reserve the table, mark and priorities for this script. Run one invocation at a time.
Runtime routes do not survive reboot; call apply from your network startup hook.
Add socket_mark = 109 (or your --mark value) to EasyTier's existing [flags].
This script does not edit EasyTier configuration or restart its service.
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
run() { printf '+'; printf ' %q' "$@"; printf '\n'; if (( ! dry_run )); then "$@"; fi; }
compact() { awk '{$1=$1; if (NF) print}'; }
field() { awk -v key="$1" '{for (i=1; i<NF; i++) if ($i==key) {print $(i+1); exit}}'; }

number() {
    local value=$1
    if [[ $value =~ ^0[xX][0-9a-fA-F]{1,8}$ ]]; then
        printf '%s' "$((16#${value:2}))"
    elif [[ $value =~ ^[0-9]{1,10}$ ]]; then
        printf '%s' "$((10#$value))"
    else
        die "Invalid number: $value"
    fi
}

action=${1:-help}
if (( $# )); then shift; fi
gateway= dev= mark=109 table=109 priority=9000 dry_run=0
while (( $# )); do
    case $1 in
        --gateway|--dev|--mark|--table|--priority)
            (( $# >= 2 )) && [[ -n $2 ]] || die "Missing value for $1"
            case $1 in
                --gateway) gateway=$2 ;; --dev) dev=$2 ;;
                --mark) mark=$2 ;; --table) table=$2 ;; --priority) priority=$2 ;;
            esac
            shift 2 ;;
        --dry-run) dry_run=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
done
case $action in
    help|-h|--help) usage; exit 0 ;;
    apply|remove|status) ;;
    *) die "Unknown action: $action" ;;
esac

[[ $(uname -s) == Linux ]] || die 'This script requires Linux policy routing.'
for cmd in ip awk; do command -v "$cmd" >/dev/null || die "Missing dependency: $cmd"; done
mark=$(number "$mark"); table=$(number "$table"); priority=$(number "$priority")
(( mark > 0 && mark <= 4294967295 )) || die 'Mark must be 1..4294967295.'
(( table > 0 && table <= 4294967295 && (table < 253 || table > 255) )) || die 'Reserved or invalid table ID.'
(( priority > 0 && priority < 32765 )) || die 'Priority must be 1..32764.'
next_priority=$((priority + 1))
printf -v mark_hex '0x%x' "$mark"

# Do not mistake permission errors for an empty table.
if ! routes=$(ip -4 -o route show table "$table" 2>&1); then
    [[ $routes == *'FIB table does not exist'* ]] || die "$routes"
    routes=
fi
routes=$(printf '%s\n' "$routes" | compact)
rules=$(ip -4 -N -o rule show | compact)
if [[ $action == status ]]; then
    printf 'IPv4 rules (numeric table IDs):\n%s\n\nTable %s:\n%s\n' "$rules" "$table" "${routes:-(empty)}"
    printf '\nEasyTier [flags]: socket_mark = %s\n' "$mark"
    exit 0
fi

[[ $gateway =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || die '--gateway requires an IPv4 address.'
IFS=. read -r -a octets <<< "$gateway"
for octet in "${octets[@]}"; do
    (( 10#$octet <= 255 )) || die 'Invalid IPv4 gateway.'
done
printf -v gateway '%d.%d.%d.%d' "$((10#${octets[0]}))" "$((10#${octets[1]}))" "$((10#${octets[2]}))" "$((10#${octets[3]}))"
first_octet=$((10#${octets[0]}))
(( first_octet > 0 && first_octet < 224 && first_octet != 127 )) || die 'Gateway must be a unicast IPv4 address.'
if [[ $action == apply ]]; then
    get_args=()
    if [[ -n $dev ]]; then get_args=(oif "$dev"); fi
    gateway_route=$(ip -4 -o route get "$gateway" "${get_args[@]}")
    [[ -z $(printf '%s\n' "$gateway_route" | field via) ]] ||
        die 'Gateway is not on-link here. Check --gateway/--dev and use the host network namespace, not ns-alt.'
    [[ $gateway_route != local\ * ]] || die 'Gateway is a local address, not a router.'
    if [[ -z $dev ]]; then dev=$(printf '%s\n' "$gateway_route" | field dev); fi
    [[ -n $dev && $dev != lo ]] || die 'Cannot determine the outgoing interface.'
elif [[ -z $dev ]]; then
    # Removal still works when the interface or its address has disappeared.
    dev=$(printf '%s\n' "$routes" | field dev)
fi

main_rule="$priority: from all fwmark $mark_hex lookup 254 suppress_prefixlength 0"
exit_rule="$next_priority: from all fwmark $mark_hex lookup $table"
main_count=0 exit_count=0
while IFS= read -r rule; do
    [[ -n $rule ]] || continue
    pref=${rule%%:*}
    if [[ $pref == "$priority" ]]; then
        [[ $rule == "$main_rule" ]] || die "Priority $priority is occupied: $rule"
        main_count=$((main_count + 1))
    elif [[ $pref == "$next_priority" ]]; then
        [[ $rule == "$exit_rule" ]] || die "Priority $next_priority is occupied: $rule"
        exit_count=$((exit_count + 1))
    elif [[ $(printf '%s\n' "$rule" | field lookup) == "$table" ]]; then
        die "Table $table is referenced by another rule: $rule"
    fi
done <<< "$rules"

# Match only our two exact routes; never flush a table or delete unrelated entries.
gateway_line="$gateway dev $dev proto static scope link"
default_line="default via $gateway dev $dev proto static"
has_gateway=0 has_default=0
while IFS= read -r route; do
    [[ -n $route ]] || continue
    route=${route% linkdown}
    case $route in
        "$gateway_line") has_gateway=1 ;;
        "$default_line") has_default=1 ;;
        *) die "Table $table contains a different route: $route. Choose another table or remove the old setup first." ;;
    esac
done <<< "$routes"

if (( ! dry_run )) && [[ $(id -u) != 0 ]]; then die 'Run apply/remove with sudo, or use --dry-run.'; fi
main_args=(pref "$priority" from all fwmark "$mark_hex" lookup main suppress_prefixlength 0)
exit_args=(pref "$next_priority" from all fwmark "$mark_hex" lookup "$table")
gateway_args=(table "$table" "$gateway/32" dev "$dev" proto static scope link)
default_args=(table "$table" default via "$gateway" dev "$dev" proto static)

if [[ $action == apply ]]; then
    # Install routes before making the table reachable through a policy rule.
    if (( ! has_gateway )); then run ip -4 route add "${gateway_args[@]}"; fi
    if (( ! has_default )); then run ip -4 route add "${default_args[@]}"; fi
    if (( ! main_count )); then run ip -4 rule add "${main_args[@]}"; main_count=1; fi
    if (( ! exit_count )); then run ip -4 rule add "${exit_args[@]}"; exit_count=1; fi
    # Repair duplicate copies left by earlier manual invocations.
    while (( main_count > 1 )); do run ip -4 rule del "${main_args[@]}"; main_count=$((main_count - 1)); done
    while (( exit_count > 1 )); do run ip -4 rule del "${exit_args[@]}"; exit_count=$((exit_count - 1)); done
    printf 'Route setup%s: mark=%s table=%s gateway=%s dev=%s\n' "$(if (( dry_run )); then printf ' preview'; fi)" "$mark" "$table" "$gateway" "$dev"
    printf 'Required EasyTier setting in existing [flags]: socket_mark = %s\n' "$mark"
else
    # Stop selecting the table before removing its routes.
    while (( exit_count > 0 )); do run ip -4 rule del "${exit_args[@]}"; exit_count=$((exit_count - 1)); done
    while (( main_count > 0 )); do run ip -4 rule del "${main_args[@]}"; main_count=$((main_count - 1)); done
    if (( has_default )); then run ip -4 route del "${default_args[@]}"; fi
    if (( has_gateway )); then run ip -4 route del "${gateway_args[@]}"; fi
    printf 'Route removal%s complete.\n' "$(if (( dry_run )); then printf ' preview'; fi)"
fi
