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
			-- hints = {
        -- parameterNames = true,
        -- assignVariableTypes = true,
        -- compositeLiteralFields = true,
        -- compositeLiteralTypes = true,
			-- }
    },
  },
})

-- vim.lsp.enable("rust_analyzer")
-- vim.lsp.config("rust_analyzer", {
--   on_attach = on_attach,
--   settings = {
--     ["rust-analyzer"] = {
--       cargo = {
--         allFeatures = true,
--         loadOutDirsFromCheck = true,
--         buildScripts = { enable = true },
--       },
--       checkOnSave = true,
--       check = {
--         command = "clippy", -- به‌جای check ساده، از clippy استفاده کن (لینتر قوی‌تر)
--       },
--       procMacro = {
--         enable = true,
--       },
--       hints = {
--       	bindingModeHints = { enable = false },
--       	closureReturnTypeHints = { enable = "always" },
--       	parameterHints = { enable = true },
--       	typeHints = { enable = true },
--       }
--     },
--   },
-- })

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
-- local compare = require("cmp.config.compare")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  sources = {
    { name = "nvim_lsp"},
    { name = "path"},
    { name = "buffer"},
		{ name = "luasnip"},
  },

  -- sorting = {
  --   comparators = {
  --     compare.offset,
  --     compare.exact,
  --     compare.sort_text,
  --     compare.order,
  --   },
  -- },

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

-- vim.lsp.enable("ts_ls")
-- vim.lsp.config("ts_ls", {
-- 	on_attach = on_attach,
--   settings = {
--     javascript = {
--       suggest = {
--         completeFunctionCalls = true,
--       },
--       inlayHints = {
--         includeInlayParameterNameHints = "all",
--         includeInlayVariableTypeHints = true,
--       },
--     },
--     typescript = {
--       suggest = {
--         completeFunctionCalls = true,
--       },
--     },
--   },
-- })
--
require('vtsls').config({
  -- customize handlers for commands
  handlers = {
    source_definition = function(err, locations) end,
    file_references = function(err, locations) end,
    code_action = function(err, actions) end,
  },
  -- automatically trigger renaming of extracted symbol
  refactor_auto_rename = true,
  refactor_move_to_file = {
    -- If dressing.nvim is installed, telescope will be used for selection prompt. Use this to customize
    -- the opts for telescope picker.
    telescope_opts = function(items, default) end,
  }
})
vim.lsp.enable("vtsls")



vim.lsp.enable("templ")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("emmet_ls")
-- vim.lsp.enable("tailwindcss")
vim.lsp.config("emmet_ls", { filetypes = { "html", "css", "templ", "sass", "scss", "less", "javascript", "javascriptreact", "typescript", "typescriptreact" }})
vim.lsp.config("html", { settings = { html = { format = { indentInnerHtml = true }}}})
vim.lsp.config("tailwindcss", {
	filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "jsx",
    "tsx",
		"js",
		"ts",
		"templ",
  },
})

vim.api.nvim_create_user_command("PrismaValidate", function()
  local fname = vim.fn.expand("%:p")
  vim.cmd("!prisma validate --schema " .. fname)
end, { desc = "Validate current prisma schema with prisma CLI" })

vim.lsp.enable("pyright")
vim.lsp.config("pyright", {
	settings = {
	  python = {
      typeCheckingMode = "basic",   -- strict=false برای جلوگیری از false positive
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
      diagnosticMode = "workspace",
	  },
	},
})
vim.lsp.enable("ruff")

vim.lsp.inlay_hint.enable(true)
