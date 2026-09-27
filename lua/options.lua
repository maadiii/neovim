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
--vim.opt.colorcolumn = "79"
vim.opt.title = true
vim.opt.titlestring = " %{fnamemodify(getcwd(), ':~')} "
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

require('kanagawa').setup({
  overrides = function(colors)
    return {
     ["@lsp.typemod.function.readonly"] = { bold = false },
    }
  end,
})
vim.cmd("colorscheme kanagawa")

local treesitter = require("nvim-treesitter")
treesitter.setup({
  ensure_installed = { 
		"go", "pyright", "ruff_lsp", "lua", "javascript", "typescript", "js", "ts", "tsx", "jsx", 
		"html", "css", "json", "javascriptreact", "typescriptreact", "prisma" }, 
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
	auto_install = true
})

vim.diagnostic.config({
  virtual_text = {
      prefix = '●',
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
      focusable = true,
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
  },
  enable_check_bracket_pairs = true,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("Copilot enable")
  end,
})

require("todo-comments").setup {
  signs = true,
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "warning", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  highlight = {
    before = "", -- رنگ قبل از کامنت
    keyword = "wide", -- رنگ خود کلمه
    after = "", -- رنگ بعد از کامنت
    pattern = [[.*<(KEYWORDS)>:]], -- regex سفارشی
  },
}

require('gitsigns').setup({
  current_line_blame = true,
	current_line_blame_opts ={
		virt_text = true,
		virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
		delay = 400,
		ignore_whitespace = true,
		virt_text_priority = 10000,
		use_focus = true,
	}
})

require('nvim-ts-autotag').setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
})

require('lualine').setup({
  options = {
    component_separators = { left = ')', right = '(' },
    section_separators = { left = '', right = '' },
  },
	sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    },
		lualine_x = { 
			function()
				return require("nvim-navic").get_location()
			end,
			venv_status,
			'filetype',
		},
    lualine_y = { 'progress' },
    lualine_z = { 'location', '%L' },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()
    local highlighters = vim.treesitter.highlighter.active
    if not highlighters[buffer] then
      pcall(vim.treesitter.start)
    end
  end,
})

require('telescope').setup{
  defaults = {
    file_ignore_patterns = {
      "%.git/",
			"/usr/local/go",
			-- "vendor",
      ".cache",
			"node_modules"
    },
  },
}

require("coverage").setup({
	commands = true,
	highlights = {
		covered = { fg = "#C3E88D", bg = "#C3E88D", sp = "#C3E88D" },   -- supports style, fg, bg, sp (see :h highlight-gui)
		uncovered = { fg = "#F07178", bg = "#F07178", sp = "#F07178" },
	},
})

local coverage_visible = false
toggle_coverage = function()
  local coverage = require("coverage")
  if _G.coverage_visible then
    coverage.load(false)
    _G.coverage_visible = false
  else
    coverage.load(true)
    _G.coverage_visible = true
  end
end

vim.api.nvim_set_keymap(
  "n",
  "<leader>co",
  ":lua toggle_coverage()<CR>",
  { noremap = true, silent = true }
)

local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local null_utils = require("null-ls.utils")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = {
        "javascript",
        "typescript",
        "json",
        "markdown",
      },
    }),
  },
})

null_ls.register({
  name = "golangci-lint-v2",
  method = null_ls.methods.FORMATTING,
  filetypes = { "go" },
  generator = null_ls.formatter({
    command = "golangci-lint-v2",
    args = { "fmt", "--stdin" },
    to_stdin = true,
    cwd = function(params)
      return null_utils.root_pattern("go.mod")(params.bufname)
    end,
  }),
})

local golangci_lint_v2 = helpers.make_builtin({
  name = "golangci-lint-v2",
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  filetypes = { "go" },
  generator_opts = {
    command = "golangci-lint-v2",
    args = {
      "run",
      "--fast-only",
      "--output.json.path=stdout",
      "--output.text.path=NUL",
      "--show-stats=false",
      "$DIRNAME",
      "--path-prefix", "$ROOT",
    },
    to_stdout = true,
    from_stderr = false,
    ignore_stderr = true,
    format = "json",
    check_exit_code = function(code)
      return code == 0 or code == 1
    end,
    on_output = function(params)
      local diags = {}
      if not params.output or not params.output.Issues then
        return diags
      end
      local bufname = params.bufname:gsub("\\", "/")
      for _, issue in ipairs(params.output.Issues) do
        local filename = (issue.Pos.Filename or ""):gsub("\\", "/")
        if filename ~= "" and bufname:sub(-#filename) == filename then
          table.insert(diags, {
            row = issue.Pos.Line,
            col = issue.Pos.Column,
            source = issue.FromLinter or "golangci-lint-v2",
            message = issue.Text,
            severity = vim.diagnostic.severity.WARN,
          })
        end
      end
      return diags
    end,
  },
  factory = helpers.generator_factory,
})

null_ls.register(golangci_lint_v2)
