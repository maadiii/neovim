local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ 
		"mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
	},
	{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    lazy = false,
  },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lua/plenary.nvim" },
  { "MunifTanjim/nui.nvim" },
	{ 'stevearc/dressing.nvim' },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "plenary.nvim", "nui.nvim", "nvim-web-devicons" },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  { 
		"neovim/nvim-lspconfig",
		ft = {"yaml", "yml"}
	},
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  },
  { 
		"mfussenegger/nvim-dap",
	},
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
	{
	  "nvim-telescope/telescope.nvim",
	  dependencies = { "nvim-lua/plenary.nvim" },
	},
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
  },
	{
	  "nvimtools/none-ls.nvim",
	  dependencies = { 
			"nvim-lua/plenary.nvim", 
			"nvimtools/none-ls-extras.nvim"
		}
	},
	{ "mfussenegger/nvim-lint" },
	{ "github/copilot.vim" },
	{
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
		lazy = false,
    opts = {
      debug = false,
    },
  },
	{
	  'nvim-lualine/lualine.nvim',
	  dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  { "lewis6991/gitsigns.nvim" },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
	{
		"preservim/tagbar",
		lazy=false
	},
  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup()
      vim.keymap.set("n", "<F8>", "<cmd>Outline<CR>")
    end,
  },
	{ "norcalli/nvim-colorizer.lua", name="colorizer" },
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig"
  },
	{
	  "sphamba/smear-cursor.nvim",
	  opts = {
	    smear_between_buffers = true,
	    smear_between_neighbor_lines = true,
	    scroll_buffer_space = true,
	    legacy_computing_symbols_support = false,
	    smear_insert_mode = true,
	  },
	},
	{
    "stevearc/conform.nvim",
		lazy = false,
    opts = {
			formatters_by_ft = {
				python = {"ruff_format"},
			},
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
	{"rebelot/kanagawa.nvim"},
	{"ellisonleao/gruvbox.nvim"},
	{ 'tpope/vim-dotenv' },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
  		scope = {
  		  enabled = false
  		},
		}
  },
	{
	  "andythigpen/nvim-coverage",
	  requires = {"nvim-lua/plenary.nvim"},
	},
	{
	  "folke/noice.nvim",
	  dependencies = { "MunifTanjim/nui.nvim" },
	  config = function()
	    require("noice").setup({
	      presets = { lsp_doc_border = true },
	    })
	  end
	},
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      {
        "nvim-treesitter/nvim-treesitter", -- Optional, but recommended
        branch = "main",  -- NOTE; not the master branch!
      },
      {
        "fredrikaverpil/neotest-golang",
        version = "*",  -- Optional, but recommended; track releases
        build = function()
          vim.system({"go", "install", "gotest.tools/gotestsum@latest"}):wait() -- Optional, but recommended
        end,
      },
			{
				"nvim-neotest/neotest-python",
  			"nvim-neotest/neotest-plenary",
			},
    },
    config = function(_, opts)
      local goconfig = {
				go_test_args = {
          "-race",
					"-count=1",
          "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
        },
				warn_test_name_dupes = false,
      }
  		local pythonconfig = {
  		  dap = { justMyCode = false },
  		  python = function()
  		    -- اتوماتیک virtualenv را پیدا می‌کند
  		    local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
  		    if vim.fn.filereadable(venv_python) == 1 then
  		      return venv_python
  		    end
  		    return "python" -- fallback
  		  end,
  		}
      require("neotest").setup({
        adapters = {
          require("neotest-golang")(goconfig),
          require("neotest-python")(pythonconfig),
        },
      })
    end,
    keys = {
      { "gtc", function() require("neotest").run.run() end, desc = "[t]est [n]earest" },
      { "gtf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "[t]est run [f]ile" },
      { "gtF", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "[t]est [A]ll files" },
      { "gta", function() require("neotest").run.attach() end, desc = "[t]est [a]ttach" },
      { "gts", function() require("neotest").run.run({ suite = true }) end, desc = "[t]est [S]uite" },
      { "gtl", function() require("neotest").run.run_last() end, desc = "[t]est [l]ast" },
      { "gtS", function() require("neotest").summary.toggle() end, desc = "[t]est [s]ummary" },
      { "gto", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "[t]est [o]utput" },
      { "gtO", function() require("neotest").output_panel.toggle() end, desc = "[t]est [O]utput panel" },
      { "gtt", function() require("neotest").run.stop() end, desc = "[t]est [t]erminate" },
      { "gtd", function() require("neotest").run.run({ suite = false, strategy = "dap" }) end, desc = "Debug nearest test" },
      { "gtD", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Debug current file" },
    },
  },
	{
		'yioneko/nvim-vtsls'
	},
	{
  	"mfussenegger/nvim-dap",
  	dependencies = {
  	  "williamboman/mason.nvim",
  	  "jay-babu/mason-nvim-dap.nvim", -- این پل بین mason و dap رو می‌سازه
  	},
  	config = function()
  	  require("mason-nvim-dap").setup({
  	    ensure_installed = { "codelldb" },
  	    automatic_installation = true,
  	  })
  	  -- بقیه‌ی کانفیگ dap اینجا
  	end,
	},
 	{
    "mrcjkb/rustaceanvim",
    lazy = false,   -- این پلاگین نباید lazy-load بشه
    ft = { "rust" },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
	{
	  "saecki/crates.nvim",
	  event = { "BufRead Cargo.toml" },
	  config = function()
	    require("crates").setup()
	  end,
	},
	{
	  "mfussenegger/nvim-dap",
	  dependencies = {
	    "rcarriga/nvim-dap-ui",
	    "nvim-neotest/nvim-nio",
	    "williamboman/mason.nvim",
	  },
	},
})
