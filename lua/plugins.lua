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
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    lazy = false,
  },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lua/plenary.nvim" },
  { "MunifTanjim/nui.nvim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "plenary.nvim", "nui.nvim", "nvim-web-devicons" },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  { "neovim/nvim-lspconfig" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  },
  { "mfussenegger/nvim-dap" },
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
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
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
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
      {
        "<leader>ce",
        ":CopilotChatExplain<cr>",
        mode = "v",
        desc = "CopilotChat - Explain code",
      },
    },
  },
	{
	  'nvim-lualine/lualine.nvim',
	  dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
  {
    'barrett-ruth/live-server.nvim',
		lazy = false,
    build = 'npm add -g live-server',
    cmd = { 'LiveServerStart', 'LiveServerStop' },
    config = true
  },
	{
    "stevearc/conform.nvim",
		lazy = false,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
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
	    -- Smear cursor when switching buffers or windows.
	    smear_between_buffers = true,
	
	    -- Smear cursor when moving within line or to neighbor lines.
	    -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
	    smear_between_neighbor_lines = true,
	
	    -- Draw the smear in buffer space instead of screen space when scrolling
	    scroll_buffer_space = true,
	
	    -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
	    -- Smears and particles will look a lot less blocky.
	    legacy_computing_symbols_support = false,
	
	    -- Smear cursor in insert mode.
	    -- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
	    smear_insert_mode = true,
	  },
	},
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { 
				"kristijanhusak/vim-dadbod-completion", 
				ft = { "psql", "sql", "mysql", "plsql" }, 
				lazy = true,
			},
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
		init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "psql", "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })
    end,
  },
  { 
		"catppuccin/nvim", 
		name = "catppuccin"
	},
  {"ellisonleao/gruvbox.nvim"},
	{"rebelot/kanagawa.nvim"},
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
})

