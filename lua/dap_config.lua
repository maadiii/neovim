local dap = require("dap")
local dapui = require("dapui")
dapui.setup({
  layouts = {
    {
      size = 30,
      position = "left",
      elements = {
        { id = "scopes", size = 0.35 },
        { id = "breakpoints", size = 0.15 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
    },
    {
      elements = {
        { id = "repl", size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size = 8,
      position = "bottom",
    },
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end


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

require("dap-go").setup({})

dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    console = "integratedTerminal";
  },
  {
    type = "python",
    request = "launch",
    name = "Launch file with Args",
    program = "${file}",
    console = "integratedTerminal";
    pythonPath = function()
      local venv = vim.fn.getcwd() .. "/.venv/bin/python3"
      if vim.fn.filereadable(venv) == 1 then
        return venv
      end
      return "python3"
    end,
    args = function()
      local input = vim.fn.input("Program args: ")
      return vim.split(input, " ")
    end,
  },
	{
	  type = "python",
	  request = "launch",
	  name = "Django Run Server",
	  program = vim.fn.getcwd() .. "/manage.py",
	  args = { "runserver", "3000", "--noreload" },
	  django = true,
	  console = "integratedTerminal",
	  justMyCode = false,
	  pythonPath = function()
	    local venv = vim.fn.getcwd() .. "/.venv/bin/python3"
	    if vim.fn.filereadable(venv) == 1 then
	      return venv
	    end
	    return "python3"
	  end,
	},
	{
	  type = "python",
	  request = "launch",
	  name = "Django Make Migration",
	  program = vim.fn.getcwd() .. "/manage.py",
	  args = { "makemigrations" },
	  django = true,
	  console = "integratedTerminal",
	  justMyCode = false,
	  pythonPath = function()
	    local venv = vim.fn.getcwd() .. "/.venv/bin/python3"
	    if vim.fn.filereadable(venv) == 1 then
	      return venv
	    end
	    return "python3"
	  end,
	},
	{
	  type = "python",
	  request = "launch",
	  name = "Django Migrate",
	  program = vim.fn.getcwd() .. "/manage.py",
	  args = function()
	    local input = vim.fn.input("Args: ", "migrate")
	    return vim.split(input, "%s+")
	  end,
	  django = true,
	  console = "integratedTerminal",
	  justMyCode = false,
	  pythonPath = function()
	    local venv = vim.fn.getcwd() .. "/.venv/bin/python3"
	    if vim.fn.filereadable(venv) == 1 then
	      return venv
	    end
	    return "python3"
	  end,
	},
}

local mason_registry = require("mason-registry")
local codelldb_path = mason_registry.get_package("codelldb"):get_install_path() .. "/codelldb"

dap.adapters.codelldb = {
  type = 'server',
	host = '127.0.0.1',
  port = "${port}",
  executable = {
    -- Change this to your exact path if you don't use Mason
    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
    args = {"--port", "${port}"},
  }
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      -- کامپایل با cargo build و مسیر باینری رو بگیر
      vim.fn.system("cargo build")
      local cwd = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(cwd, ":t") -- اسم فولدر پروژه = اسم باینری (پیش‌فرض cargo)
      return cwd .. "/target/debug/" .. project_name
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
		console="integratedTerminal"
  },
  {
    name = "Launch with Args",
    type = "codelldb",
    request = "launch",
    program = function()
      vim.fn.system("cargo build")
      local cwd = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(cwd, ":t")
      return cwd .. "/target/debug/" .. project_name
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = function()
      local input = vim.fn.input("Program args: ")
      return vim.split(input, " ")
    end,
  },
  {
    name = "Attach to Process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
      "127.0.0.1",
    },
  },
}

for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug NestJS (main.ts via ts-node)",
      runtimeExecutable = "node",
      runtimeArgs = { "--require", "ts-node/register" },
      args = { "${workspaceFolder}/src/main.ts" },
      cwd = "${workspaceFolder}",
      protocol = "inspector",
      console = "integratedTerminal",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug NestJS (nest start --debug)",
      runtimeExecutable = "npm",
      runtimeArgs = { "run", "start:debug" },
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      attachSimplePort = 9229,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to NestJS process (port 9229)",
      port = 9229,
      address = "localhost",
      restart = true,
      sourceMaps = true,
      cwd = "${workspaceFolder}",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug npm script (dev)",
      runtimeExecutable = "npm",
      runtimeArgs = { "run", "dev" },
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    },
  }
end
