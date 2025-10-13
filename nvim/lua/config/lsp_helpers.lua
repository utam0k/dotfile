local M = {}

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  return vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
end

function M.on_attach(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    local ok, navic = pcall(require, "nvim-navic")
    if ok then
      navic.attach(client, bufnr)
    end
  end

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
  map("n", "<leader>k", vim.lsp.buf.signature_help, "LSP: Signature help")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")

  map("n", "\\rn", vim.lsp.buf.rename, "LSP: Rename symbol")
  map({ "n", "x" }, "\\ca", vim.lsp.buf.code_action, "LSP: Code action")

  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: Remove workspace folder")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "LSP: List workspace folders")

  if client.name == "rust_analyzer" then
    client.server_capabilities.semanticTokensProvider = nil
  end

  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

return M
