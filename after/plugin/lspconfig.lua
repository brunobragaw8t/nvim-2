-- Config diagnostics
vim.diagnostic.config({
  severity_sort = true,
  signs = false,
  float = {
    border = "rounded",
  },
})

-- Set general keymaps
vim.keymap.set('n', "<F8>", vim.diagnostic.goto_next)
vim.keymap.set('n', "<S-F8>", vim.diagnostic.goto_prev)

-- Set buffer-specific keymaps
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set({"n", "i"}, "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "<Leader>fm", vim.lsp.buf.format, bufopts)
  vim.keymap.set("n", "<Leader>fa", "<Cmd>EslintFixAll<CR>", bufopts)
end

-- Set LSP handler settings
local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"}),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = "rounded"}),
}

-- Define servers to install
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  -- volar = {
  --   filetypes = { "typescript", "javascript", "vue", "json" },
  -- },
  -- tailwindcss = {},
  tsserver = {},
  eslint = {},
}

-- Setup Neovim Lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Setup Mason so it can manage external tooling
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "",
      package_uninstalled = "",
    },
  },
})

-- Ensure the servers above are installed
local mason_lspconfig = require "mason-lspconfig"

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    if rawget(servers, server_name) == nil then
      return
    end

    local server_to_setup = {}

    server_to_setup.capabilities = capabilities
    server_to_setup.on_attach = on_attach
    server_to_setup.handlers = handlers

    if rawget(servers[server_name], "settings") ~= nil then
      server_to_setup.settings = servers[server_name].settings
    end

    if rawget(servers[server_name], "filetypes") ~= nil then
      server_to_setup.filetypes = servers[server_name].filetypes
    end

    require("lspconfig")[server_name].setup(server_to_setup)
  end,
}

-- Turn on lsp status information
require("fidget").setup()

-- Setup completion
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
  window = {
    completion = cmp.config.window.bordered({
      border = "rounded",
    }),
    documentation = cmp.config.window.bordered({
      border = "rounded",
    })
  },
})
