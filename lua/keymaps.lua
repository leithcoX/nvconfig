mappings = {
    n = {
        ["<leader>s"] = { name = "Snippets" },
        ["<leader>f"] = { name = "Find" },
        ["<leader>w"] = { name = "Save" },
    }
}

vim.keymap.set('n', '<leader>q', ":q<CR>", {desc = 'Quit'})
vim.keymap.set('n', '<leader>w', ":w<CR>", {desc = 'Save'})


local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', ":q", {desc = 'Telescope find files'})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = 'Telescope live grep'})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = 'Telescope help tags'})

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {desc = 'Go to definition'})
vim.keymap.set({'n','v'}, '<leader>ca', vim.lsp.buf.code_action, {})

do
    local ls = require "luasnip";
    vim.keymap.set('n','<Leader>se', require("luasnip.loaders").edit_snippet_files,{desc = "Edit snippets"})
    vim.keymap.set({"i", "s"}, "<C-j>", function() ls.jump(-1) end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-k>", ls.expand , {silent = true})
    vim.keymap.set({"i", "s"}, "<C-l>", function() ls.jump( 1) end, {silent = true})
end
