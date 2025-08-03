local all_mappings = {
    n = {
        ["<leader>s"] = { name = "Snippets" },
        ["<leader>f"] = { name = "Find" },
        ["<leader>w"] = { name = "Save" },
    },
}

-- for mode, mappings in pairs(all_mappings) do
--     for key, map in pairs(mappings) do
--         vim.keymap.set(
--             mode,
--             key,
--             table.remove(map, 1), map)
--     end
-- end

vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

vim.keymap.set("n", "H", "<C-w>h")
vim.keymap.set("n", "J", "<C-w>j")
vim.keymap.set("n", "K", "<C-w>k")
vim.keymap.set("n", "L", "<C-w>l")

vim.keymap.set("n", "<leader>pu", ":Lazy update<CR>", { desc = "Update" })
vim.keymap.set("n", "<leader>ps", ":Lazy sync<CR>", { desc = "Sync" })

do
    local wk = require("which-key")
    wk.add({
        {"<leader>f", group = "Find"},
        {"<leader>p", group = "Plugins"},
        {"<leader>s", group = "Plugins"},
        {"<leader>c", group = "Code Actions"},
    })
end

local builtin = require("telescope.builtin")
-- vim.keymap.set('n', '<leader>f', "" , {group = 'Find'})
vim.keymap.set("n", "<leader>ff", ":q", { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "View code actions" })

do
    local ls = require("luasnip")
    vim.keymap.set("n", "<Leader>se", require("luasnip.loaders").edit_snippet_files, { desc = "Edit snippets" })
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
        ls.jump(-1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-k>", ls.expand, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-l>", function()
        ls.jump(1)
    end, { silent = true })
end
