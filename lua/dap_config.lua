require("dap-go").setup()
local dap = require("dap")
local dapui = require("dapui")
dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.35 },
        { id = "breakpoints", size = 0.15 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 30,
      position = "left",
    },
    { elements = { "repl" }, size = 0.25, position = "bottom" },
  },
})


dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
--dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end


vim.keymap.set("n", "<leader>dr", dap.repl.toggle)
vim.keymap.set("n", "<leader>dt", dapui.toggle)
vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F6>", dap.disconnect)
vim.keymap.set("n", "<F9>", function() dap.clear_breakpoints() end, { desc = "Dap Clear All Breakpoints" })
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)

local dap_signs = {
    Breakpoint          = { text = "🔴", texthl = "DapBreakpoint", numhl = "DapBreakpoint" },
    BreakpointCondition = { text = "🟥", texthl = "DapBreakpointCondition", numhl = "DapBreakpointCondition" },
    BreakpointRejected  = { text = "⭕", texthl = "DapBreakpointRejected", numhl = "DapBreakpointRejected" },
    LogPoint            = { text = "󰇧 ", texthl = "DapLogPoint", numhl = "DapLogPoint" },
    Stopped             = { text = "󰁕 ", texthl = "DapStopped", numhl = "DapStopped" },
}

for type, config in pairs(dap_signs) do
    local hl = "Dap" .. type
    vim.fn.sign_define(hl, { 
        text = config.text, 
        texthl = config.texthl, 
        numhl = config.numhl
    })
end

dap.adapters.dart = {
  type = "executable",
  command = "dart",
  -- This command was introduced upstream in https://github.com/dart-lang/sdk/commit/b68ccc9a
  args = {"debug_adapter"}
}
dap.configurations.dart = {
  {
    type = "dart",
    request = "launch",
    name = "Launch Dart Program",
    -- The nvim-dap plugin populates this variable with the filename of the current buffer
    program = "${file}",
    -- The nvim-dap plugin populates this variable with the editor's current working directory
    cwd = "${workspaceFolder}",
    -- args = {"--help"}, -- Note for Dart apps this is args, for Flutter apps toolArgs
  }
}
