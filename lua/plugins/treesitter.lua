return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    main = "nvim-treesitter.configs",
    opts = {
        ensure_installed = {'c', 'cpp', 'lua', 'make', 'cmake', 'python', 'html', 'css', 'javascript'},
        auto_install = vim.fn.executable('tree-sitter') == 1,
        -- ignore_install = {'latex'},
        highlight = {
            enable = true,
            disable = {'latex'},
            -- additional_vim_regex_highlighting = { "latex", "markdown" },
        },
        indent = {enable = true}
    }
}
