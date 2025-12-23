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
vim.g.python3_host_prog = "/home/maadi/.venvs/nvim/bin/python"
-- vim.o.guicursor = "n-v-c-sm:block"

local treesitter = require("nvim-treesitter")
treesitter.setup({
  ensure_installed = { "python", "go", "lua", "tsx", "jsx", "javascript", "javascriptreact", "typescript", "typescriptreactt", "vim", "html", "css" }, 
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
	auto_install = true
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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("Copilot enable")
  end,
})

vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fb4934" }) -- قرمز روشن
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#fabd2f", bg = "#3c3836" }) -- زرد با پس‌زمینه تیره برای خطی که دیباگر روی آن ایستاده
vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
  fg = "#7aa2f7",
  bg = "#1f2335",
  italic = true,
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

local function venv_status()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    local venv_name = string.match(venv, "[^/]+$")
    return venv_name -- آیکون پایتون + نام venv
  end
  return ""
end

require('lualine').setup({
  options = {
    theme = 'catppuccin',
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

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()
    local highlighters = vim.treesitter.highlighter.active
    if not highlighters[buffer] then
      pcall(vim.treesitter.start)
    end
  end,
})

local function auto_theme_switch()
    local is_go_project = vim.fn.glob("go.mod") ~= ""
    
    if is_go_project then
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
    else
      vim.cmd("colorscheme kanagawa")
    end
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
      auto_theme_switch()
  end,
})
require('lualine').setup({ options = { theme = 'catppuccin' } })
