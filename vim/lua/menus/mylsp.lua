return {
  {
    name = "Goto Definition",
    cmd = vim.lsp.buf.definition,
    rtxt = "gd",
  },

  {
    name = "Goto Declaration",
    cmd = vim.lsp.buf.declaration,
    rtxt = "gD",
  },

  {
    name = "Goto Implementation",
    cmd = vim.lsp.buf.implementation,
    rtxt = "gi",
  },

  { name = "separator" },

  {
    name = "Show signature help",
    cmd = vim.lsp.buf.signature_help,
    rtxt = "<leader>sh",
  },

  {
    name = "Add workspace folder",
    cmd = vim.lsp.buf.add_workspace_folder,
    rtxt = "<leader>wa",
  },

  {
    name = "Remove workspace folder",
    cmd = vim.lsp.buf.remove_workspace_folder,
    rtxt = "<leader>wr",
  },

  {
    name = "Show References",
    cmd = vim.lsp.buf.references,
    rtxt = "gr",
  },

  { name = "separator" },

  {
    name = "Format Buffer",
    hl = 'ExRed',
    cmd = function()
      local ok, conform = pcall(require, "conform")

      if ok then
        conform.format { lsp_fallback = true }
      else
        vim.lsp.buf.format()
      end
    end,
    rtxt = "<leader>fm",
  },

  {
    name = "Code Actions",
    cmd = vim.lsp.buf.code_action,
    rtxt = "<leader>ca",
  },

  {
    name = 'Rename',
    cmd = vim.lsp.buf.rename,
    rtxt = 'r',
  },

  { name = "separator" },

  {
    name = 'Diagnostic Toggle',
    cmd = function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end,
  },
  {
    name = 'Diagnostic Open in QuickFix List',
    cmd = vim.diagnostic.setqflist,
  },
  {
    name = 'Diagnostic Open in Location List',
    cmd = vim.diagnostic.setloclist,
  },
  {
    name = 'Diagnostic Open in Float',
    cmd = vim.diagnostic.open_float,
  },
  {
    name = 'Diagnostic Goto Prev',
    cmd = vim.diagnostic.goto_prev,
  },
  {
    name = 'Diagnostic Goto Next',
    cmd = vim.diagnostic.goto_next,
  },
}
