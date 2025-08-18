return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		indent = { enabled = true },
		quickfile = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = {
			left = { "fold", "mark" },
			right = { "git", "sign" },
			folds = { open = true, git_hl = true },
			git = { patterns = { "GitSign", "MiniDiffSign" } },
			refresh = 50,
		},
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		words = { enabled = true },
		-- profiler = {}
		-- rename = {}
	},
}
