local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<Space>l", function()
  require("neo-tree.command").execute({
    action = "focus",
    source = "filesystem",
    reveal = true,
    toggle = true,
  })
end, { desc = "NeoTree Float Reveal" })

vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', opts)
vim.api.nvim_set_keymap('n', 'oo', 'o<Esc>', opts)
vim.api.nvim_set_keymap('', '<Space><Space>', 'za', opts)
vim.api.nvim_set_keymap('n', '"', ":vertical resize -5<CR>", opts)
vim.api.nvim_set_keymap('n', "'", ":vertical resize +5<CR>", opts)
vim.api.nvim_set_keymap('n', '>', ":resize -1<CR>", opts)
vim.api.nvim_set_keymap('n', '<', ":resize +1<CR>", opts)

vim.keymap.set("n", "<leader><Space>", function()
  vim.cmd("nohlsearch")
  vim.cmd("echo")
end, opts)

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require('telescope.themes')

vim.keymap.set("n", "<leader><leader>", function()
  builtin.find_files(themes.get_ivy())
end, { desc = "Telescope find files" })

vim.keymap.set("n", "<leader>g", function()
  builtin.live_grep(themes.get_ivy())
end, { desc = "Telescope live grep" })

vim.keymap.set("n", "<leader>fb", function()
  builtin.buffers(themes.get_ivy())
end, { desc = "Telescope buffers" })

vim.keymap.set('n', 'gd', function()
	builtin.lsp_definitions(themes.get_ivy())
end, { desc = "Goto Definition" })

vim.keymap.set('n', 'gf', function() 
	builtin.lsp_references(themes.get_ivy())
end, { desc = "Goto References" })

vim.keymap.set('n', 'gi', function()
	builtin.lsp_implementations(themes.get_ivy())
end, { desc = "Goto Implementation" })

vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })
vim.keymap.set('n', 'gx', vim.lsp.buf.rename, { desc = "LSP: Rename" })

vim.keymap.set('n', 'gv', function()
  require('telescope.builtin').lsp_definitions({ jump_type = "vsplit", theme = "ivy" })
end, { desc = "Telescope: Definition (Vertical Split)" })

vim.keymap.set('n', 'gs', function()
  require('telescope.builtin').lsp_definitions({ jump_type = "split", theme = "ivy"})
end, { desc = "Telescope: Definition (Horizontal Split)" })

vim.keymap.set('n', 'gD', function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/declaration', params, function(err, result, ctx, config)
        if err or not result or vim.tbl_isempty(result) then
            builtin.lsp_definitions({theme = "ivy"})
        else
            builtin.lsp_declarations({theme = "ivy"})
        end
    end)
end, { desc = "Telescope: Declaration (Fallback to Definition)" })

vim.keymap.set('n', '<C-n>', function()
    vim.diagnostic.goto_next({ float = { border = "rounded" } })
end, { desc = "Go to next diagnostic" })

vim.keymap.set('n', '<C-p>', function()
    vim.diagnostic.goto_prev({ float = { border = "rounded" } })
end, { desc = "Go to previous diagnostic" })

vim.keymap.set('n', '<space>d', '<cmd>Telescope diagnostics theme=ivy<CR>', opts)
vim.keymap.set('n', '<space>c', '<cmd>Telescope commands theme=ivy<CR>', opts)
vim.keymap.set('n', '<space>o', '<cmd>Telescope lsp_document_symbols theme=ivy<CR>', opts)
vim.keymap.set('n', '<space>s', '<cmd>Telescope lsp_dynamic_workspace_symbols theme=ivy<CR>', opts)
vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action, { desc = "LSP Quick Fix" })
vim.keymap.set('n', '<space>g', ':LazyGit<CR>', {desc = 'Open LazyGit'})
vim.keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', {desc = 'Open DBUI'})

vim.keymap.set('n', '<leader>cc', '<cmd>CopilotChatToggle<CR>', {desc = 'CopilotChat toggle'})
vim.keymap.set('n', '<leader>ce', '<cmd>CopilotChatExplain<CR>', {desc = 'CopilotChat explain code'})
vim.keymap.set({ 'n', 'v' }, '<leader>cc', function()
  require("CopilotChat").toggle()
end, { desc = 'CopilotChat: Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>cv', function()
  local input = vim.fn.input("Copilot Question: ")
  if input ~= "" then
    require("CopilotChat").ask(input)
  end
end, { desc = 'CopilotChat: Ask prompt' })

