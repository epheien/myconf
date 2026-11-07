/**
 * 给内置 bash 工具加默认超时。
 *
 * 背景:pi 内置 bash 工具的 timeout 参数是可选的,省略即"永不超时",
 * 一条挂住的命令会把 agent 卡死。本扩展让模型省略 timeout 时默认取
 * 300 秒(5 分钟);模型显式指定时一律以显式值为准。
 *
 * 实现参考 @cad0p/pi-bash-timeout:用 createBashToolDefinition() 拿到内置
 * bash 工具的完整定义,注册同名工具覆盖注册表里的它,只替换 execute 并
 * 改写 timeout 字段的描述 —— promptSnippet、renderCall/renderResult 等
 * 其余部分全部继承内置行为,所以 TUI 显示与原生 bash 工具一致。
 *
 * 想改默认值:改下面的 DEFAULT_TIMEOUT_SECONDS,然后在 pi 里 /reload。
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createBashToolDefinition } from "@earendil-works/pi-coding-agent";

const DEFAULT_TIMEOUT_SECONDS = 300;

export default function bashTimeoutExtension(pi: ExtensionAPI) {
	// 注册时先取一份内置定义,用于继承 description / 渲染器等静态字段
	const builtinBash = createBashToolDefinition(process.cwd());

	// 内置 schema 里 timeout 的描述写着 "no default timeout",与本扩展的
	// 语义矛盾。浅拷贝一份参数 schema 只改写这个字段,不动内置对象本身。
	const parameters = {
		...builtinBash.parameters,
		properties: {
			...builtinBash.parameters.properties,
			timeout: {
				...builtinBash.parameters.properties.timeout,
				description: `Timeout in seconds. Defaults to ${DEFAULT_TIMEOUT_SECONDS} seconds when omitted; an explicit value overrides it.`,
			},
		},
	} as typeof builtinBash.parameters;

	pi.registerTool({
		...builtinBash,
		name: "bash", // 同名 → 覆盖内置 bash 工具
		// 在描述末尾补一句默认值,让模型知道有兜底;其余文案保持内置原样
		description: `${builtinBash.description} (default timeout: ${DEFAULT_TIMEOUT_SECONDS}s when omitted)`,
		parameters,

		async execute(toolCallId, params, signal, onUpdate, ctx) {
			// 只在模型没给 timeout 时补默认值,显式值永远优先
			const effectiveParams = {
				...params,
				timeout: params.timeout ?? DEFAULT_TIMEOUT_SECONDS,
			};

			// 用 ctx.cwd 重新构造,保证命令在会话当前目录执行
			const bashTool = createBashToolDefinition(ctx.cwd);
			return bashTool.execute(toolCallId, effectiveParams, signal, onUpdate, ctx);
		},
	});
}
