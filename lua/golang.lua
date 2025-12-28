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
local function go_tag_modify(mode)
    local file = vim.fn.expand("%:p")
    local line_num = vim.fn.line(".")
    local line_text = vim.api.nvim_get_current_line()
    
    local struct_name = line_text:match("type%s+([%w_]+)%s+struct")

    local function run_cmd(user_input)
        local target = struct_name and ("-struct " .. struct_name) or ("-line " .. line_num)
        local cmd = ""

        if mode == "add" then
            if user_input:match(":") then
                local tag_name, tag_value = user_input:match("([^:]+):([^:]+)")
                cmd = string.format("gomodifytags -file %s %s -add-tags %s -override-tags %s=%s -w",
                    vim.fn.shellescape(file), target, vim.fn.shellescape(tag_name), 
                    vim.fn.shellescape(tag_name), vim.fn.shellescape(tag_value))
            else
                cmd = string.format("gomodifytags -file %s %s -add-tags %s -transform snakecase -w",
                    vim.fn.shellescape(file), target, vim.fn.shellescape(user_input))
            end
        elseif mode == "remove" then
            local tag_to_remove = user_input:match("([^:]+)") or user_input
            cmd = string.format("gomodifytags -file %s %s -remove-tags %s -w",
                vim.fn.shellescape(file), target, vim.fn.shellescape(tag_to_remove))
        end

        vim.cmd("write")
        local output = vim.fn.system(cmd)
        
        if vim.v.shell_error ~= 0 then
            print("Error: " .. output)
        else
            vim.cmd("edit!")
            print("Done!")
        end
    end

    local prompt_msg = mode == "add" and "Add Tag: " or "Remove Tag: "
    vim.ui.input({ prompt = prompt_msg }, function(input)
        if input and input ~= "" then run_cmd(input) end
    end)
end
