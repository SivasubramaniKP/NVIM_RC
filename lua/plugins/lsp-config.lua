return {
        {
                "williamboman/mason.nvim",
                config = function()
                        require("mason").setup()
                end,
        },
        {
                "williamboman/mason-lspconfig.nvim",
                config = function()
                        require("mason-lspconfig").setup({
                                ensure_installed = {
                                        "lua_ls", -- Lua Language Server
                                        "clangd", -- C/C++ Language Server,
                                        "ast_grep",
                                        "pyright",
                                },
                        })
                end,
        },
        {
                "neovim/nvim-lspconfig",
                config = function()
                        require("java").setup()
                        local capabilities = require("cmp_nvim_lsp").default_capabilities()
                        local lspconfig = require("lspconfig")

                        -- Lua Language Server setup
                        lspconfig.lua_ls.setup({
                                capabilities = capabilities,
                        })

                        -- Clangd setup for C/C++
                        lspconfig.clangd.setup({
                                capabilities = capabilities,
                        })
                        lspconfig.ast_grep.setup({
                                capabilities = capabilities,
                        })
                        lspconfig.pyright.setup({
                                capabilities = capabilities,
                        })
                        local htmlcapabilities = vim.lsp.protocol.make_client_capabilities()
                        capabilities.textDocument.completion.completionItem.snippetSupport = true
                        local configs = require'lspconfig.configs'
                        if not configs.ls_emmet then
                                configs.ls_emmet = {
                                        default_config = {
                                                cmd = { "ls_emmet", "--stdio" },
                                                filetypes = {
                                                        "html",
                                                        "css",
                                                        "scss",
                                                        "javascriptreact",
                                                        "typescriptreact",
                                                        "haml",
                                                        "xml",
                                                        "xsl",
                                                        "pug",
                                                        "slim",
                                                        "sass",
                                                        "stylus",
                                                        "less",
                                                        "sss",
                                                        "hbs",
                                                        "handlebars",
                                                },
                                                root_dir = function(fname)
                                                        return vim.loop.cwd()
                                                end,
                                                settings = {},
                                        },
                                }
                        end

                        lspconfig.ls_emmet.setup({ capabilities = htmlcapabilities })
                        lspconfig.jdtls.setup({})
                        --        lspconfig.ast_grep.setup()
                        require("code_runner").setup({
                                filetype = {
                                        java = {
                                                "cd $dir &&",
                                                "javac $fileName &&",
                                                "java $fileNameWithoutExt",
                                        },
                                        cpp = {
                                                "cd $dir &&",
                                                "g++ $fileName",
                                                "-o /tmp/$fileNameWithoutExt &&",
                                                "/tmp/$fileNameWithoutExt",
                                        },
                                        python = {
                                                "cd $dir &&", -- Navigate to the directory of the file
                                                "python3 -u $fileName", -- Corrected the missing quote
                                        },
                                        --python = "python3",
                                        sh = "bash",
                                        typescript = "deno run",
                                        typescriptreact = "yarn dev$end",
                                        dart = "dart",
                                        rust = {
                                                "cd $dir &&",
                                                "rustc $fileName &&",
                                                "$dir/$fileNameWithoutExt",
                                        },
                                        c = function(...)
                                                c_base = {
                                                        "cd $dir &&",
                                                        "gcc $fileName -o",
                                                        "/tmp/$fileNameWithoutExt",
                                                }
                                                local c_exec = {
                                                        "&& /tmp/$fileNameWithoutExt &&",
                                                        "rm /tmp/$fileNameWithoutExt",
                                                }
                                                vim.ui.input({ prompt = "Add more args:" }, function(input)
                                                        c_base[4] = input
                                                        vim.print(vim.tbl_extend("force", c_base, c_exec))
                                                        require("code_runner.commands").run_from_fn(vim.list_extend(
                                                        c_base, c_exec))
                                                end)
                                        end,
                                },
                        })
                        lspconfig.ast_grep.setup({})
                        -- Keymaps for general LSP functionality (if not buffer-specific)
                        vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
                        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
                end,
        },
}
