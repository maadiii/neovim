require("dap-go").setup()
local dap = require("dap")

dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
        args = { "dap", "-l", "127.0.0.1:" .. port },
        stdio = { stdin, stdout },
        detached = true
    }
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
        stdout:close()
        handle:close()
    end)

    stdout:read_start(function(err, data)
        if data then
            vim.schedule(function()
                require('dap.repl').append(data)
            end)
        end
    end)

    vim.defer_fn(function()
        callback({ type = "server", host = "127.0.0.1", port = port })
    end, 100)
end


dap.adapters.python = {
  type = 'executable',
  command = 'python3',
  args = { '-m', 'debugpy.adapter' },
}

local function setup_launch_json()
  local ft = vim.bo.filetype
  local path = vim.fn.getcwd() .. "/.vscode/launch.json"

  -- فقط اگر پایتون بود و فایل وجود نداشت، بسازش
  if ft == "python" and vim.fn.filereadable(path) <= 0 then
    vim.fn.mkdir(vim.fn.getcwd() .. "/.vscode", "p")
    local content = [[
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Auto Python: main.py",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal"
    }
  ]
}]]
    local file = io.open(path, "w")
    if file then
      file:write(content)
      file:close()
      print("Created default launch.json for Python")
    end
  end
  
  -- در هر صورت (چه فایل ساخته بشه، چه از قبل باشه، چه کلاً گو باشه) دیباگر رو استارت بزن
  require('dap').continue()
end

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
    { elements = { "repl" }, size = 0.01, position = "bottom" },
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
--dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end


vim.keymap.set("n", "<leader>dr", dap.repl.open)
vim.keymap.set("n", "<leader>du", dapui.toggle)
vim.keymap.set("n", "<F5>", setup_launch_json)
vim.keymap.set("n", "<F9>", function() dap.clear_breakpoints() end, { desc = "Dap Clear All Breakpoints" })
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>B", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end)

local dap_signs = {
    Breakpoint          = { text = "🔴", texthl = "DapBreakpoint", numhl = "DapBreakpoint" },
    BreakpointCondition = { text = "🟥", texthl = "DapBreakpointCondition", numhl = "DapBreakpointCondition" },
    BreakpointRejected  = { text = "⭕", texthl = "DapBreakpointRejected", numhl = "DapBreakpointRejected" },
    LogPoint            = { text = "󰇧 ", texthl = "DapLogPoint", numhl = "DapLogPoint" },
    Stopped             = { text = "󰁕 ", texthl = "DapStopped", numhl = "DapStopped" },
}

-- اعمال تنظیمات در نئوویم
for type, config in pairs(dap_signs) do
    local hl = "Dap" .. type
    vim.fn.sign_define(hl, { 
        text = config.text, 
        texthl = config.texthl, 
        numhl = config.numhl
    })
end

dap.defaults.fallback.terminal_win_cmd = 'botright new | resize 10 | setlocal winfixheight'
