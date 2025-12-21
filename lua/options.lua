vim.o.foldmethod = "indent"
vim.o.foldnestmax = 1000
vim.o.foldlevel = 1000
vim.o.foldenable = false
vim.o.clipboard = "unnamedplus"
vim.o.showmode = false
vim.o.showcmd = false
vim.o.shortmess = vim.o.shortmess .. "F"
vim.o.arabicshape = false
vim.o.scrolloff = 10
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.undofile = true
vim.opt.termguicolors = true
-- vim.o.guicursor = "n-v-c-sm:block"

local treesitter = require("nvim-treesitter")
treesitter.setup({
  ensure_installed = { "go", "lua", "javascript", "typescript", "vim", "html", "css" }, 
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
})


local gruvbox = require("gruvbox")
gruvbox.setup({
	contrast = "soft", 
	transparent_mode = false,
  overrides = {
		Type = { link = "GruvboxOrange" },
		["@operator"] = { link = "GruvboxRed" },
		["@type.definition.go"] = { link = "GruvboxOrange"},
    ["@variable.parameter"] = { link = "GruvboxFg2" },
		["@variable.member"] = { link = "GruvboxFg2" },
		["@function"] = { link = "GruvboxAqua" },
		["@function.method"] = { link = "GruvboxAqua" },
		["@function.call"] = { link = "GruvboxAqua" },
  }
})
vim.cmd("colorscheme gruvbox")

vim.diagnostic.config({
  virtual_text = {
      prefix = '●', -- علامت قبل از متن خطا در انتهای خط
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
  }
})

vim.defer_fn(function()
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "⛔",
        [vim.diagnostic.severity.WARN]  = "⚠️",
        [vim.diagnostic.severity.HINT]  = "💡",
        [vim.diagnostic.severity.INFO]  = "ℹ️",
      },
    },
  })
end, 100)

local autopairs = require("nvim-autopairs")
autopairs.setup({
  check_ts = true,
  ts_config = {
    lua = { "string" },
    javascript = { "template_string", "string" },
  },
  enable_check_bracket_pairs = true,
})

local golangci_config = [[
version: 2

linters:
  enable-all: true
  enable:
    - forbidigo
    - gocritic
    - bodyclose
    - exhaustive
    - goconst
    - gocognit
    - gochecknoinits
    - godot
    - godox
    - wsl
  disable:
    - lll
    - mnd
    - exhaustruct
    - wrapcheck
    - forcetypeassert
    - tagliatelle
    - dupl
    - varnamelen
    - depguard
    - nonamedreturns
    - gochecknoglobals
    - paralleltest
    - errorlint
    - cyclop
    - ireturn
    - nakedret
    - revive
    - tagalign
    - recvcheck
    - err113
run:
  timeout: 5m
  issues-exit-code: 1
]]

-- -----------------------------------------
-- Find Go project root (via go.mod)
-- -----------------------------------------
local function go_project_root(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local gomod = vim.fs.find("go.mod", {
    upward = true,
    path = bufname,
  })[1]

  if gomod then
    return vim.fs.dirname(gomod)
  end

  return nil
end

-- -----------------------------------------
-- Ensure .golangci.yml exists
-- -----------------------------------------
local function ensure_golangci_config(bufnr)
  local root = go_project_root(bufnr)
  if not root then
    return
  end

  local config_path = root .. "/.golangci.yml"

  if vim.fn.filereadable(config_path) == 1 then
    return
  end

  local file = io.open(config_path, "w")
  if not file then
    return
  end

  file:write(golangci_config)
  file:close()

  vim.notify(".golangci.yml created in project root", vim.log.levels.INFO)
end


local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.golangci_lint.with({
      command = "golangci-lint", 
    }),
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    ensure_golangci_config(args.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.keymap.set("n", "gb", function()
            vim.cmd("write") -- ذخیره فایل
            print("Linting...")
            local cmd = "golangci-lint run"
            local output = vim.fn.systemlist(cmd)
            if vim.v.shell_error ~= 0 and #output > 0 then
                vim.fn.setqflist({}, 'r', {title = "GolangCI-Lint", lines = output})
                vim.cmd("copen")
            elseif vim.v.shell_error == 0 then
                vim.cmd("cclose")
                print("Clean! No issues found.")
            else
                print("Error running linter: " .. table.concat(output, " "))
            end
        end, { buffer = true, silent = true })
    end
})


vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("Copilot enable")
  end,
})

