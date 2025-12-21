require("neo-tree").setup({
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    container = { enable_character_fade = true },
    indent = { padding = 1, with_markers = true },
    icon = { folder_closed = "", folder_open = "", folder_empty = "", default = "" },
    modified = { symbol = "[+]" },
    name = { trailing_slash = false },
    git_status = {
      symbols = {
        added = "+", modified = "~", deleted = "x", renamed = "»",
        untracked = "?", ignored = "•", unstaged = "!", staged = "✓", conflict = "",
      },
    },
  },
  window = {
    position = "float",
    popup = { size = { width = 50, height = 30 }, position = "50%", border = "rounded" },
    mapping_options = { noremap = true, nowait = true },
  },
  filesystem = {
		follow_current_file = {
      enabled = true,           -- این باید داخل یک آبجکت باشد
      leave_dirs_open = true,  -- اگر true باشد، فولدرهای قبلی باز می‌مانند
    },
    use_libuv_file_watcher = true,
    filtered_items = { hide_dotfiles = false, hide_gitignored = false },
    window = {
      mappings = {
        ["l"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and not node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          end
        end,
			  ["h"] = function(state)
			    local node = state.tree:get_node()
			    
			    -- ۱. اگر روی دایرکتوری باز بودیم (چه روت چه غیر روت)
			    if node.type == "directory" and node:is_expanded() then
			      -- استفاده از دستور ویژه برای بستن بازگشتی
			      require("neo-tree.sources.filesystem.commands").close_node(state)
			    
			    -- ۲. اگر روی فایل بودیم یا دایرکتوری بسته بود
			    else
			      local parent_id = node:get_parent_id()
			      if parent_id then
			        -- انتقال فوکوس به والد و بستن آن
			        require("neo-tree.ui.renderer").focus_node(state, parent_id)
			        require("neo-tree.sources.filesystem.commands").close_node(state)
			      else
			        -- ۳. اگر والد نداشت (یعنی روی روت بودیم) و دایرکتوری باز بود
			        if node.type == "directory" then
			          require("neo-tree.sources.filesystem.commands").close_node(state)
			        end
			      end
			    end
			  end,
      },
    },
	},
})

