local golangci_config = [[
version: 2

linters:
  enable-all: true
  enable:
    - forbidigo
    - gocritic
    - bodyclose
    - exhaustive
    - goconst
    - gocognit
    - gochecknoinits
    - godot

  disable:
    - lll
    - mnd
    - exhaustruct
    - wrapcheck
    - forcetypeassert
    - tagliatelle
    - dupl
    - varnamelen
    - depguard
    - nonamedreturns
    - gochecknoglobals
    - paralleltest
    - errorlint
    - cyclop
    - ireturn
    - nakedret
    - revive
    - tagalign
    - recvcheck
    - err113
run:
  timeout: 5m
  issues-exit-code: 1
]]

-- -----------------------------------------
-- Find Go project root (via go.mod)
-- -----------------------------------------
local function go_project_root(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local gomod = vim.fs.find("go.mod", {
    upward = true,
    path = bufname,
  })[1]

  if gomod then
    return vim.fs.dirname(gomod)
  end

  return nil
end

-- -----------------------------------------
-- Ensure .golangci.yml exists
-- -----------------------------------------
local function ensure_golangci_config(bufnr)
  local root = go_project_root(bufnr)
  if not root then
    return
  end

  local config_path = root .. "/.golangci.yml"

  if vim.fn.filereadable(config_path) == 1 then
    return
  end

  local file = io.open(config_path, "w")
  if not file then
    return
  end

  file:write(golangci_config)
  file:close()

  vim.notify(".golangci.yml created in project root", vim.log.levels.INFO)
end


local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.golangci_lint.with({
      command = "golangci-lint", 
    }),
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    ensure_golangci_config(args.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.keymap.set("n", "gb", function()
            vim.cmd("write") -- ذخیره فایل
            print("Linting...")
            local cmd = "golangci-lint run"
            local output = vim.fn.systemlist(cmd)
            if vim.v.shell_error ~= 0 and #output > 0 then
                vim.fn.setqflist({}, 'r', {title = "GolangCI-Lint", lines = output})
                vim.cmd("copen")
            elseif vim.v.shell_error == 0 then
                vim.cmd("cclose")
                print("Clean! No issues found.")
            else
                print("Error running linter: " .. table.concat(output, " "))
            end
        end, { buffer = true, silent = true })
    end
})
