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
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "ellisonleao/gruvbox.nvim",
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
	  dependencies = { "nvim-lua/plenary.nvim" }
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
	  config = function()
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
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
	    })
	  end
	},
  {
      'barrett-ruth/live-server.nvim',
      build = 'npm add -g live-server',
      cmd = { 'LiveServerStart', 'LiveServerStop' },
      config = true
  },
	{
    "stevearc/conform.nvim",
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
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },
  {
  "lewis6991/gitsigns.nvim",
  config = function()
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
  end
 },
 {
   "kdheepak/lazygit.nvim",
   dependencies = { "nvim-lua/plenary.nvim" },
   keys = {
     { "<space>g", ":LazyGit<CR>", desc = "Open LazyGit" },
   },
	 config = function() 
		 vim.g.lazygit_use_neovim_remote = 1
	 end
 }
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

vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fb4934" }) -- قرمز روشن
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#fabd2f", bg = "#3c3836" }) -- زرد با پس‌زمینه تیره برای خطی که دیباگر روی آن ایستاده
vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
  fg = "#7aa2f7",
  bg = "#1f2335",
  italic = true,
})
