-- local zsh_path = vim.fn.exepath("zsh")
-- if zsh_path ~= "" then
--     vim.opt.shell = zsh_path
--     vim.env.SHELL = zsh_path
-- end
require("plugins")
require("options")
require("keymaps")
require("neotree")
require("lsp")
require("dap_config")
