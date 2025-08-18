return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enabled = false,
    opts = {
        options = {
            disable_filetypes = { "neo-tree" },
            -- always_show_tabline = false,
        },
        tabline = {
            -- lualine_a = { "buffers" },
            lualine_b = { "buffers" },
            -- lualine_c = {'buffers'},
            -- lualine_x = {},
            -- lualine_y = {},
            -- lualine_z = {},
        },
    },
}
