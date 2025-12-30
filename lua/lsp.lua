local navic = require("nvim-navic")
local on_attach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end
end

vim.lsp.enable("gopls")
vim.lsp.config("gopls", {
	on_attach = on_attach,
	on_init = on_init,
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = false,
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
      },
    },
  },
})

vim.lsp.enable("ts_ls")
vim.lsp.config("ts_ls", {
	on_attach = on_attach,
  settings = {
    javascript = {
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayVariableTypeHints = true,
      },
    },
    typescript = {
      suggest = {
        completeFunctionCalls = true,
      },
    },
  },
})

vim.lsp.enable("dockerls")
vim.lsp.config("dockerls", {
	on_attach = on_attach,
})

vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("emmet_ls")
vim.lsp.config("emmet_ls", { filetypes = { "html", "css", "sass", "scss", "less", "javascriptreact", "typescriptreact" }})
vim.lsp.config("html", { settings = { html = { format = { indentInnerHtml = true }}}})

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = true,
  underline = true,
})

local cmp = require("cmp")
cmp.setup({
preselect = cmp.PreselectMode.None,
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.go", "*.js", "*.jsx", "*.ts", "*.tsx" },
--   callback = function()
--     vim.lsp.buf.format({ async = true })
--   end,
-- })
-- 
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client == nil or client.name ~= "gopls" then
--       return
--     end
-- 
--     vim.api.nvim_create_autocmd("BufWritePre", {
--       buffer = args.buf,
--       callback = function()
--         vim.lsp.buf.code_action({
--           context = { only = { "source.organizeImports" } },
--           apply = true,
--         })
--         
--         vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
--       end,
--     })
--   end,
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    for _, client in ipairs(clients) do
      if client.name == "gopls" then
        -- gopls: organize imports + format
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" } },
          apply = true,
        })
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
      elseif client.name == "tsserver" then
        -- TS/JS: organize imports + format
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" } },
          apply = true,
        })
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
      end
    end

    -- conform fallback for other filetypes
    if vim.fn.exists(":ConformFormat") == 2 then
      vim.cmd("ConformFormat")
    end
  end,
})

local lsp_signature = require("lsp_signature")
lsp_signature.setup({
  bind = true,
  handler_opts = {
    border = "rounded"
  },
  floating_window = true,
  floating_window_above_cur = false,
  hint_enable = false,
  hint_prefix = "",
  padding = '',
  always_trigger = false,
})

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width = 50
  opts.wrap = true
  opts.border = "rounded"

  local raw_text = ""
  if type(contents) == "table" then
    raw_text = table.concat(contents, "\n")
  else
    raw_text = contents
  end

  local processed_text = raw_text:gsub("([^%s])%s*@", "%1\n@")

  local final_contents = vim.split(processed_text, "\n")

  local bufnr, winnr = orig_util_open_floating_preview(final_contents, syntax, opts, ...)

  if winnr then
    vim.api.nvim_win_set_option(winnr, "wrap", true)
    vim.api.nvim_win_set_option(winnr, "linebreak", true)
    vim.api.nvim_win_set_option(winnr, "breakindent", true)
    vim.api.nvim_win_set_width(winnr, 120)
  end

  return bufnr, winnr
end
