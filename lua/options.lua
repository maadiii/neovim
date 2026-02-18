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
vim.opt.colorcolumn = "79"
vim.opt.title = true
vim.opt.titlestring = " %{fnamemodify(getcwd(), ':~')} "
vim.cmd("colorscheme kanagawa")

local treesitter = require("nvim-treesitter")
treesitter.setup({
  ensure_installed = { "go", "lua", "javascript", "typescript", "js", "ts", "tsx", "jsx", "html", "css", "json", "javascriptreact", "typescriptreact" }, 
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
	auto_install = true
})

vim.diagnostic.config({
  virtual_text = {
      prefix = '●', -- علامت قبل از متن خطا در انتهای خط
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
  signs = true, -- نمایش آیکن در گوتر لاین
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
      -- "node_modules",
      "%.git/",
			-- "/usr/local/go",
      ".cache",
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

require'colorizer'.setup(
  {'*'},  -- تمام فایل‌ها
  {
    RGB      = true; -- #RGB hex codes
    RRGGBB   = true; -- #RRGGBB hex codes
    names    = true; -- نام‌های رنگ مثل "red"
    RRGGBBAA = true; -- #RRGGBBAA hex codes
    rgb_fn   = true; -- rgb() و rgba()
    hsl_fn   = true; -- hsl() و hsla()
    css      = true; -- enable all CSS features
    tailwind = true; -- enable tailwind colors
  }
)

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.golangci_lint.with({
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    }),

    null_ls.builtins.formatting.prettier.with({
			extra_args = { "--config", vim.fn.getcwd() .. "/.prettierrc" },
      filetypes = {
        "js", "ts", "jsx", "tsx", "javascript", "typescript", "javascriptreact", "typescriptreact",
        "html", "css", "scss", "json", "markdown",
      },
    }),
  },
})

require("flutter-tools").setup{}
