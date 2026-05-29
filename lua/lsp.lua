local navic = require("nvim-navic")
local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end

vim.lsp.enable("gopls")
vim.lsp.config("gopls", {
	on_attach = on_attach,
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = false,
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
				shadow = true
      },
			hints = {
        -- parameterNames = true,
        -- assignVariableTypes = true,
        -- compositeLiteralFields = true,
        -- compositeLiteralTypes = true,
			}
    },
  },
})

vim.lsp.enable("dockerls")
vim.lsp.config("dockerls", {
	on_attach = on_attach,
})

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
  sources = {
    { name = "nvim_lsp"},
    { name = "path"},
    { name = "buffer"},
		{ name = "luasnip"},
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_selected_entry() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
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

vim.lsp.inlay_hint.enable(true)
