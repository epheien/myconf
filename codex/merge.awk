# 将 myconf 的默认 codex 配置合并进现有的 config.toml
#
# 用法:
#   awk -v tpl=config.toml -v dep="personality" -f merge.awk target.toml
#
# 规则:
#   - 模板中的键: 目标中存在则原位替换, 不存在则插入
#     (根层键插在第一个表头之前; 表内键插在该表块末尾)
#   - 目标文件中其余内容(注释、projects、hooks.state 等自动状态)原样保留
#   - dep 中逗号分隔的根层键会被删除(用于清理废弃项)
#   - 模板只支持单行标量键值和 [table] 表头; 不支持 [[array of tables]]
#   - 替换键行时保留原行首缩进, 但不保留行内注释

function trim(s) {
    gsub(/^[[:space:]]+/, "", s)
    gsub(/[[:space:]]+$/, "", s)
    return s
}

function header_name(line,   h) {
    h = line
    if (h ~ /^[[:space:]]*\[\[/) {
        sub(/^[[:space:]]*\[\[/, "", h)
        sub(/\]\][[:space:]]*(#.*)?$/, "", h)
        return h
    }
    sub(/^[[:space:]]*\[/, "", h)
    sub(/\][[:space:]]*(#.*)?$/, "", h)
    return h
}

function key_name(line,   k) {
    k = line
    sub(/=.*/, "", k)
    return trim(k)
}

function keep_indent(oldline, newline,   indent) {
    match(oldline, /^[[:space:]]*/)
    indent = substr(oldline, 1, RLENGTH)
    return indent newline
}

# 输出当前缓冲块, 同时完成该块的键合并
function flush(   i, j, k, found, pat, nins, ins, last) {
    nins = 0
    if (cur_table == "") {
        for (i = 1; i <= nroot; i++) {
            k = root_order[i]
            found = 0
            pat = "^[[:space:]]*" k "[[:space:]]*="
            for (j = 1; j <= nb; j++)
                if (buffer[j] ~ pat) {
                    buffer[j] = keep_indent(buffer[j], root_val[k])
                    found = 1
                    break
                }
            if (!found)
                ins[++nins] = root_val[k]
        }
    } else if (!is_array && (cur_table in t_seen)) {
        for (i = 1; i <= tcnt[cur_table]; i++) {
            k = tkey[cur_table, i]
            found = 0
            pat = "^[[:space:]]*" k "[[:space:]]*="
            for (j = 1; j <= nb; j++)
                if (buffer[j] ~ pat) {
                    buffer[j] = keep_indent(buffer[j], tval[cur_table, k])
                    found = 1
                    break
                }
            if (!found)
                ins[++nins] = tval[cur_table, k]
        }
    }

    if (nins == 0) {
        for (j = 1; j <= nb; j++)
            print buffer[j]
        nb = 0
        return
    }

    # 新键插在块末尾空行之前, 保持表头前留白
    last = nb
    while (last >= 1 && buffer[last] ~ /^[[:space:]]*$/)
        last--
    for (j = 1; j <= last; j++)
        print buffer[j]
    for (i = 1; i <= nins; i++)
        print ins[i]
    for (j = last + 1; j <= nb; j++)
        print buffer[j]
    nb = 0
}

BEGIN {
    while ((getline line < tpl) > 0) {
        if (line ~ /^[[:space:]]*#/ || line ~ /^[[:space:]]*$/)
            continue
        if (line ~ /^[[:space:]]*\[\[/) {
            print "ERROR: template must not use [[array of tables]]: " line > "/dev/stderr"
            exit 1
        }
        if (line ~ /^[[:space:]]*\[/) {
            cur = header_name(line)
            if (!(cur in t_seen)) {
                t_seen[cur] = 1
                t_order[++nt] = cur
            }
            tpl_hdr[cur] = line
            continue
        }
        if (line ~ /=/) {
            k = key_name(line)
            if (cur == "") {
                root_val[k] = line
                if (!(k in root_seen)) {
                    root_seen[k] = 1
                    root_order[++nroot] = k
                }
            } else {
                tval[cur, k] = line
                if (!((cur, k) in tk_seen)) {
                    tk_seen[cur, k] = 1
                    tkey[cur, ++tcnt[cur]] = k
                }
            }
            continue
        }
        print "ERROR: unsupported template line: " line > "/dev/stderr"
        exit 1
    }
    close(tpl)
}

{
    if ($0 ~ /^[[:space:]]*\[/) {
        flush()
        cur_table = header_name($0)
        is_array = ($0 ~ /^[[:space:]]*\[\[/)
        nb = 0
        buffer[++nb] = $0
        if (!is_array && (cur_table in t_seen))
            seen_t[cur_table] = 1
        next
    }

    # 删除根层的废弃键
    if (cur_table == "" && dep != "") {
        k = key_name($0)
        n = split(dep, parts, ",")
        for (i = 1; i <= n; i++) {
            d = trim(parts[i])
            if (d != "" && k == d)
                next
        }
    }

    buffer[++nb] = $0
}

END {
    flush()
    # 模板中定义了而目标文件里不存在的表, 追加到末尾
    for (i = 1; i <= nt; i++) {
        if (t_order[i] in seen_t)
            continue
        print ""
        print tpl_hdr[t_order[i]]
        for (j = 1; j <= tcnt[t_order[i]]; j++)
            print tval[t_order[i], tkey[t_order[i], j]]
    }
}
