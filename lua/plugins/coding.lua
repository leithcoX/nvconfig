return {
	{
		"numToStr/Comment.nvim",
		main = "Comment",
		opts = {
			toggler = { line = "<leader>/" },
			opleader = { line = "<leader>/" },
		},
	},
	{
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			opts = {}
		},
	},
}
