return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            defaults = {
                mappings = {
                    n = {
                        ["<Leader>ff"] =  {
                              function()
                                  require("telescope.builtin").find_files { hidden = true, no_ignore = true }
                              end,
                              desc = "Find all files",
                        }
                    }
                }
            },
        }
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require "telescope".setup {
                extensions = {
                    ["ui-select"] = {
                        require "telescope.themes"
                    }
                }
            }
            require("telescope").load_extension("ui-select")
        end,
    }
}
