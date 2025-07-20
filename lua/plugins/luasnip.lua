return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
	},
	opts = {
		enable_autosnippets = true,
		update_events = { "TextChanged", "TextChangedI" }, -- Para qué servía esto?
	},
	config = function(plugin, opts)
		-- include the default config that calls the setup call
		require("luasnip").setup(opts)
		-- load snippets paths
		require("luasnip.loaders.from_lua").lazy_load({
			-- paths = { vim.fn.stdpath("config") .. "/snippets" },
			paths = { "~/snippets" },
		})
        require("luasnip.loaders.from_vscode").lazy_load()
	end,
	build = "make install_jsregexp",
}
