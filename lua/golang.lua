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

    local function run_cmd(tag)
        local target
        if struct_name then
            target = "-struct " .. struct_name
        else
            target = "-line " .. line_num
        end

        local cmd
        if mode == "add" then
            cmd = string.format("gomodifytags -file %s %s -add-tags %s -transform snakecase -w", 
                                 vim.fn.shellescape(file), target, vim.fn.shellescape(tag))
        elseif mode == "remove" then
            cmd = string.format("gomodifytags -file %s %s -remove-tags %s -w", 
                                 vim.fn.shellescape(file), target, vim.fn.shellescape(tag))
        end

        vim.cmd("write")
        local output = vim.fn.system(cmd)
        
        if vim.v.shell_error ~= 0 then
            print("Error: " .. output)
        else
            vim.cmd("edit!")
            local target_desc = struct_name and "Struct '" .. struct_name .. "'" or "Field"
            print(string.format("%s %s tags from %s", (mode == "add" and "Added" or "Removed"), tag, target_desc))
        end
    end

    local prompt_msg = mode == "add" and "Add Tag (e.g. json): " or "Remove Tag (e.g. json): "
    
    vim.ui.input({ prompt = prompt_msg }, function(tag)
        if tag and tag ~= "" then
            run_cmd(tag)
        end
    end)
end
vim.keymap.set("n", "<leader>at", function() go_tag_modify("add") end, { desc = "Add Go Tag (Smart)" })
vim.keymap.set("n", "<leader>ct", function() go_tag_modify("remove") end, { desc = "Remove Specific Go Tag (Smart)" })
