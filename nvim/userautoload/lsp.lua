-- built-in LSP + nvim-cmp (coc parity)
local lspconfig, mason, mason_lsp = require('lspconfig'), require('mason'), require('mason-lspconfig')
local cmp, cmp_lsp = require('cmp'), require('cmp_nvim_lsp')
local luasnip, lspkind = require('luasnip'), require('lspkind')

mason.setup()
mason_lsp.setup({ ensure_installed = { 'gopls','rust_analyzer','terraformls','yamlls' } })

vim.diagnostic.config({ virtual_text = false, severity_sort = true })

local function on_attach(c, b)
  if c.name == 'gopls' or c.name == 'rust_analyzer' then
    vim.api.nvim_create_autocmd('BufWritePre', { buffer = b,
      callback = function() vim.lsp.buf.format({ async = false }) end })
  end
end
local cap = cmp_lsp.default_capabilities()

lspconfig.gopls.setup{ on_attach = on_attach, capabilities = cap,
  settings = { gopls = { completeUnimported = true } } }
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = cap,
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true, features = 'all' },
      check = {
        command = 'clippy',
        overrideCommand = {
          'cargo','clippy','--message-format=json',
          '--all-targets','--all-features','--','-Dwarnings',
        },
      },
    },
  },
})
lspconfig.terraformls.setup{ cmd = { 'terraform-ls','serve' },
  on_attach = on_attach, capabilities = cap }
lspconfig.yamlls.setup{ on_attach = on_attach, capabilities = cap,
  settings = { yaml = { schemas = { kubernetes = '/*.yaml' } } } }
for _, s in ipairs({ 'lua_ls','clangd','pyright','ts_ls','hls' }) do
  lspconfig[s].setup{ on_attach = on_attach, capabilities = cap }
end

cmp.setup{
  snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>']=cmp.mapping.select_next_item(),
    ['<C-p>']=cmp.mapping.select_prev_item(),
    ['<CR>'] =cmp.mapping.confirm({ select = true }),
  }),
  sources = { {name='nvim_lsp'}, {name='luasnip'}, {name='buffer'}, {name='path'} },
  formatting = { format = lspkind.cmp_format({ mode = 'symbol_text' }) },
}
