return {
        "mfussenegger/nvim-dap",
        dependencies = {
                "rcarriga/nvim-dap-ui",
                "nvim-neotest/nvim-nio",
        },
        config = function()
                require("dapui").setup()
                local dap = require("dap")
                dap.adapters.lldb = {
                        type = "executable",
                        command = "/usr/bin/lldb-vscode", -- adjust as needed, must be absolute path
                        name = "lldb",
                }
                dap.adapters.gdb = {
                        type = "executable",
                        command = "gdb",
                        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
                }
                dap.configurations.c = {
                        {
                                name = "Launch",
                                type = "gdb",
                                request = "launch",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                cwd = "${workspaceFolder}",
                                stopAtBeginningOfMainSubprogram = false,
                        },
                        {
                                name = "Select and attach to process",
                                type = "gdb",
                                request = "attach",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                pid = function()
                                        local name = vim.fn.input("Executable name (filter): ")
                                        return require("dap.utils").pick_process({ filter = name })
                                end,
                                cwd = "${workspaceFolder}",
                        },
                        {
                                name = "Attach to gdbserver :1234",
                                type = "gdb",
                                request = "attach",
                                target = "localhost:1234",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                cwd = "${workspaceFolder}",
                        },
                }

                dap.configurations.cpp = {
                        {
                                name = "Launch",
                                type = "gdb",
                                request = "launch",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                cwd = "${workspaceFolder}",
                                stopAtBeginningOfMainSubprogram = false,
                        },
                        {
                                name = "Select and attach to process",
                                type = "gdb",
                                request = "attach",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                pid = function()
                                        local name = vim.fn.input("Executable name (filter): ")
                                        return require("dap.utils").pick_process({ filter = name })
                                end,
                                cwd = "${workspaceFolder}",
                        },
                        {
                                name = "Attach to gdbserver :1234",
                                type = "gdb",
                                request = "attach",
                                target = "localhost:1234",
                                program = function()
                                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                                end,
                                cwd = "${workspaceFolder}",
                        },
                }
                dap.adapters.python = function(cb, config)
                        if config.request == "attach" then
                                ---@diagnostic disable-next-line: undefined-field
                                local port = (config.connect or config).port
                                ---@diagnostic disable-next-line: undefined-field
                                local host = (config.connect or config).host or "127.0.0.1"
                                cb({
                                        type = "server",
                                        port = assert(port,
                                                "`connect.port` is required for a python `attach` configuration"),
                                        host = host,
                                        options = {
                                                source_filetype = "python",
                                        },
                                })
                        else
                                cb({
                                        type = "executable",
                                        command = "/root/.virtualenvs/debugpy",
                                        args = { "-m", "debugpy.adapter" },
                                        options = {
                                                source_filetype = "python",
                                        },
                                })
                        end
                end
                dap.configurations.python = {
                        {
                                -- The first three options are required by nvim-dap
                                type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                                request = "launch",
                                name = "Launch file",

                                -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                                program = "${file}", -- This configuration will launch the current file if used.
                                pythonPath = function()
                                        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                                        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                                        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                                        local cwd = vim.fn.getcwd()
                                        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                                                return cwd .. "/venv/bin/python"
                                        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                                                return cwd .. "/.venv/bin/python"
                                        else
                                                return "/usr/bin/python"
                                        end
                                end,
                        },
                }
                vim.keymap.set("n", "<F10>", function()
                        require("dap").toggle_breakpoint()
                end)
                vim.keymap.set("n", "<F5>", function()
                        require("dap").continue()
                end)
                vim.keymap.set("n", "<F9>", function()
                        require("dap").step_over()
                end)
                vim.keymap.set("n", "<F11>", function()
                        require("dap").step_into()
                end)
                vim.keymap.set("n", "<F12>", function()
                        require("dap").step_out()
                end)
                vim.keymap.set("n", "<Leader>b", function()
                        require("dap").toggle_breakpoint()
                end)
                vim.keymap.set("n", "<Leader>B", function()
                        require("dap").set_breakpoint()
                end)
                vim.keymap.set("n", "<Leader>lp", function()
                        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                end)
                vim.keymap.set("n", "<Leader>dr", function()
                        require("dap").repl.open()
                end)
                vim.keymap.set("n", "<Leader>dl", function()
                        require("dap").run_last()
                end)
                local dap, dapui = require("dap"), require("dapui")
                dap.listeners.before.attach.dapui_config = function()
                        dapui.open()
                end
                dap.listeners.before.launch.dapui_config = function()
                        dapui.open()
                end
                dap.listeners.before.event_terminated.dapui_config = function()
                        dapui.close()
                end
                dap.listeners.before.event_exited.dapui_config = function()
                        dapui.close()
                end
        end,
}
