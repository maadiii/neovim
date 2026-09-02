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
      enabled = true,
      leave_dirs_open = true,
    },
    use_libuv_file_watcher = true,
    filtered_items = { 
			hide_dotfiles = true, 
			hide_gitignored = true, 
			hide_by_name = { "vendor", "node_modules", "__pycache__" } ,
		},
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
			    
			    if node.type == "directory" and node:is_expanded() then
			      require("neo-tree.sources.filesystem.commands").close_node(state)
			    
			    else
			      local parent_id = node:get_parent_id()
			      if parent_id then
			        require("neo-tree.ui.renderer").focus_node(state, parent_id)
			        require("neo-tree.sources.filesystem.commands").close_node(state)
			      else
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

