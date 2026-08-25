/**
 * Disable selected tools from the pi-web-access extension at session start.
 *
 * pi-web-access only offers `webSearch.enabled: false` (unregisters web_search
 * and source_check). There is no config switch for get_search_content, so we
 * filter it out of the active tool set via pi.setActiveTools(), following the
 * same pattern as the official examples/extensions/tools.ts extension.
 *
 * To disable additional tools, add their names to DISABLED_TOOLS.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// 禁用的工具, get_search_content 是 pi-web-access 的工具,
// 用 web-search-fast mcp 替代掉了
const DISABLED_TOOLS = ["get_search_content"];

export default function disableWebToolsExtension(pi: ExtensionAPI) {
	function applyDisabledTools() {
		const active = pi.getActiveTools();
		const filtered = active.filter((name) => !DISABLED_TOOLS.includes(name));
		if (filtered.length !== active.length) {
			pi.setActiveTools(filtered);
		}
	}

	pi.on("session_start", applyDisabledTools);
	pi.on("session_tree", applyDisabledTools);
}
