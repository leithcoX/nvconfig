return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		main = "mason-lspconfig",
		opts = {
			ensure_installed = {
				"lua_ls",
			},
			automatic_enable = true,
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
				},
				automatic_enable = true,
			})
			--vim.lsp.config['luals'] = {
			--    cmd = { 'lua-language-server', "--force-accept-workspace" },

			--    filetypes = { 'lua' },

			--    root_markers = { {'.luarc.json', '.luarc.jsonc'} },--, '.git' },

			--    settings = {
			--        Lua = {
			--            runtime = {
			--                version = 'LuaJIT',
			--            }
			--        }
			--    }
			--}
			-- vim.lsp.enable("luals")
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })
		end,
	},
}
