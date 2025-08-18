return {
	"rebelot/heirline.nvim",
	-- lazy = false,
	-- priority = 49,
	config = function()
		local conditions = require("heirline.conditions")
		local utils = require("heirline.utils")
		local colors = {
			bright_bg = utils.get_highlight("Folded").bg,
			bright_fg = utils.get_highlight("Folded").fg,
			red = utils.get_highlight("DiagnosticError").fg,
			dark_red = utils.get_highlight("DiffDelete").bg,
			green = utils.get_highlight("String").fg,
			blue = utils.get_highlight("Function").fg,
			gray = utils.get_highlight("NonText").fg,
			orange = utils.get_highlight("Constant").fg,
			purple = utils.get_highlight("Statement").fg,
			cyan = utils.get_highlight("Special").fg,
			diag_warn = utils.get_highlight("DiagnosticWarn").fg,
			diag_error = utils.get_highlight("DiagnosticError").fg,
			diag_hint = utils.get_highlight("DiagnosticHint").fg,
			diag_info = utils.get_highlight("DiagnosticInfo").fg,
			git_del = utils.get_highlight("DiffDeleted").fg,
			git_add = utils.get_highlight("DiffAdded").fg,
			git_change = utils.get_highlight("DiffChanged").fg,
		}
		local Align = { provider = "%=" }
		local Sep = { provider = "   " }
		local Space = { provider = " " }

		local ViMode = {
			-- get vim current mode, this information will be required by the provider
			-- and the highlight functions, so we compute it only once per component
			-- evaluation and store it as a component attribute
			init = function(self)
				self.mode = vim.fn.mode(1) -- :h mode()
			end,
			-- Now we define some dictionaries to map the output of mode() to the
			-- corresponding string and color. We can put these into `static` to compute
			-- them at initialisation time.
			static = {
				mode_names = { -- change the strings if you like it vvvvverbose!
					n = "N",
					no = "N?",
					nov = "N?",
					noV = "N?",
					["no\22"] = "N?",
					niI = "Ni",
					niR = "Nr",
					niV = "Nv",
					nt = "Nt",
					v = "V",
					vs = "Vs",
					V = "V_",
					Vs = "Vs",
					["\22"] = "^V",
					["\22s"] = "^V",
					s = "S",
					S = "S_",
					["\19"] = "^S",
					i = "I",
					ic = "Ic",
					ix = "Ix",
					R = "R",
					Rc = "Rc",
					Rx = "Rx",
					Rv = "Rv",
					Rvc = "Rv",
					Rvx = "Rv",
					c = "C",
					cv = "Ex",
					r = "...",
					rm = "M",
					["r?"] = "?",
					["!"] = "!",
					t = "T",
				},
				mode_colors = {
					n = "red",
					i = "green",
					v = "cyan",
					V = "cyan",
					["\22"] = "cyan",
					c = "orange",
					s = "purple",
					S = "purple",
					["\19"] = "purple",
					R = "orange",
					r = "orange",
					["!"] = "red",
					t = "red",
				},
			},
			-- We can now access the value of mode() that, by now, would have been
			-- computed by `init()` and use it to index our strings dictionary.
			-- note how `static` fields become just regular attributes once the
			-- component is instantiated.
			-- To be extra meticulous, we can also add some vim statusline syntax to
			-- control the padding and make sure our string is always at least 2
			-- characters long. Plus a nice Icon.
			provider = function(self)
				return " %2(" .. self.mode_names[self.mode] .. "%)"
			end,
			-- Same goes for the highlight. Now the foreground will change according to the current mode.
			hl = function(self)
				local mode = self.mode:sub(1, 1) -- get only the first mode character
				return { fg = self.mode_colors[mode], bold = true }
			end,
			-- Re-evaluate the component only on ModeChanged event!
			-- Also allows the statusline to be re-evaluated when entering operator-pending mode
			update = {
				"ModeChanged",
				pattern = "*:*",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
			},
		}

		ViMode = utils.surround({ "", "" }, "bright_bg", { ViMode })
		ViMode = { ViMode, Sep }

		local FileNameBlock = {
			-- let's first set up some attributes needed by this component and its children
			init = function(self)
				self.filename = vim.api.nvim_buf_get_name(0)
			end,
		}
		-- We can now define some children separately and add them later

		local FileIcon = {
			init = function(self)
				local filename = self.filename
				local extension = vim.fn.fnamemodify(filename, ":e")
				self.icon, self.icon_color =
					require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
				if not self.is_active then
					self.icon_color = "gray"
				end
			end,
			provider = function(self)
				return self.icon and (self.icon .. " ")
			end,
			hl = function(self)
				return { fg = self.icon_color }
			end,
		}

		local FileName = {
			provider = function(self)
				-- first, trim the pattern relative to the current directory. For other
				-- options, see :h filename-modifers
				local filename = vim.fn.fnamemodify(self.filename, ":.")
				if filename == "" then
					return "[No Name]"
				end
				-- now, if the filename would occupy more than 1/4th of the available
				-- space, we trim the file path to its initials
				-- See Flexible Components section below for dynamic truncation
				if not conditions.width_percent_below(#filename, 0.25) then
					filename = vim.fn.pathshorten(filename)
				end
				return filename
			end,
			hl = { fg = utils.get_highlight("Directory").fg },
		}

		local FileFlags = {
			{
				condition = function()
					return vim.bo.modified
				end,
				provider = "[+]",
				hl = { fg = "green" },
			},
			{
				condition = function()
					return not vim.bo.modifiable or vim.bo.readonly
				end,
				provider = "",
				hl = { fg = "orange" },
			},
		}

		-- Now, let's say that we want the filename color to change if the buffer is
		-- modified. Of course, we could do that directly using the FileName.hl field,
		-- but we'll see how easy it is to alter existing components using a "modifier"
		-- component

		local FileNameModifer = {
			hl = function()
				if vim.bo.modified then
					-- use `force` because we need to override the child's hl foreground
					return { fg = "cyan", bold = true, force = true }
				end
			end,
		}

		-- let's add the children to our FileNameBlock component
		FileNameBlock = utils.insert(
			FileNameBlock,
			FileIcon,
			utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
			FileFlags,
			{ provider = "%<" } -- this means that the statusline is cut here when there's not enough space
		)

		local FileType = {
			provider = function()
				return string.upper(vim.bo.filetype)
			end,
			hl = { fg = utils.get_highlight("Type").fg, bold = true },
		}

		local FileEncoding = {
			provider = function()
				local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
				return enc ~= "utf-8" and enc:upper()
			end,
		}

		local FileFormat = {
			provider = function()
				local fmt = vim.bo.fileformat
				return fmt ~= "unix" and fmt:upper()
			end,
		}

		local Ruler = {
			-- %l = current line number
			-- %L = number of lines in the buffer
			-- %c = column number
			-- %P = percentage through file of displayed window
			provider = "%7(%l/%3L%):%2c %P",
		}

		local ScrollBar = {
			static = {
				sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
				-- Another variant, because the more choice the better.
				-- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
			},
			provider = function(self)
				local curr_line = vim.api.nvim_win_get_cursor(0)[1]
				local lines = vim.api.nvim_buf_line_count(0)
				local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
				return string.rep(self.sbar[i], 2)
			end,
			hl = { fg = "blue", bg = "bright_bg" },
		}

		local LSPActive = {
			condition = conditions.lsp_attached,
			update = { "LspAttach", "LspDetach" },

			-- You can keep it simple,
			-- provider = " [LSP]",

			-- Or complicate things a bit and get the servers names
			provider = function()
				local names = {}
				for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
					table.insert(names, server.name)
				end
				return " [" .. table.concat(names, " ") .. "]"
			end,
			hl = { fg = "green", bold = true },
		}

		local GitBranch = {
			condition = conditions.is_git_repo,

			init = function(self)
				self.status_dict = vim.b.gitsigns_status_dict
			end,

			hl = { fg = "purple" },

			{ -- git branch name
				provider = function(self)
					return " " .. self.status_dict.head
				end,
				hl = { bold = true },
			},
			Sep,
		}

		local GitDiff = {
			condition = conditions.is_git_repo,

			init = function(self)
				self.status_dict = vim.b.gitsigns_status_dict
				self.has_changes = self.status_dict.added ~= 0
					or self.status_dict.removed ~= 0
					or self.status_dict.changed ~= 0
			end,

			hl = { fg = "orange" },

			Sep,

			-- You could handle delimiters, icons and counts similar to Diagnostics
			{
				provider = function(self)
					local count = self.status_dict.added or 0
					return count > 0 and ("+" .. count .. " ")
				end,
				hl = { fg = "git_add" },
			},
			{
				provider = function(self)
					local count = self.status_dict.removed or 0
					return count > 0 and ("-" .. count .. " ")
				end,
				hl = { fg = "git_del" },
			},
			{
				provider = function(self)
					local count = self.status_dict.changed or 0
					return count > 0 and ("~" .. count)
				end,
				hl = { fg = "git_change" },
			},
		}

		local Diagnostics = {

			condition = conditions.has_diagnostics,
			static = {
				error_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.ERROR],
				warn_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.WARN],
				info_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.INFO],
				hint_icon = vim.diagnostic.config()["signs"]["text"][vim.diagnostic.severity.HINT],
			},

			init = function(self)
				self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
				self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
				self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
			end,

			update = { "DiagnosticChanged", "BufEnter" },
			Sep,
			{
				provider = "![",
			},
			{
				provider = function(self)
					-- 0 is just another output, we can decide to print it or not!
					return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ")
				end,
				hl = { fg = "diag_error" },
			},
			{
				provider = function(self)
					return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ")
				end,
				hl = { fg = "diag_warn" },
			},
			{
				provider = function(self)
					return self.info > 0 and (self.info_icon .. " " .. self.info .. " ")
				end,
				hl = { fg = "diag_info" },
			},
			{
				provider = function(self)
					return self.hints > 0 and (self.hint_icon .. self.hints)
				end,
				hl = { fg = "diag_hint" },
			},
			{
				provider = "]",
			},
		}

		local CloseButton = {
			condition = function(self)
				return not vim.bo.modified
			end,
			-- a small performance improvement:
			-- re register the component callback only on layout/buffer changes.
			update = { "WinNew", "WinClosed", "BufEnter" },
			{ provider = " " },
			{
				provider = "",
				hl = { fg = "gray" },
				on_click = {
					minwid = function()
						return vim.api.nvim_get_current_win()
					end,
					callback = function(_, minwid)
						vim.api.nvim_win_close(minwid, true)
					end,
					name = "heirline_winbar_close_button",
				},
			},
		}

		-- Use it anywhere!
		local WinBarFileName = utils.surround({ "", "" }, "bright_bg", {
			hl = function()
				if not conditions.is_active() then
					return { fg = "gray", force = true }
				end
			end,
			FileNameBlock,
			Space,
			CloseButton,
		})

		local TablineBufnr = {
			provider = function(self)
				return tostring(self.bufnr) .. ". "
			end,
			hl = "Comment",
		}

		-- we redefine the filename component, as we probably only want the tail and not the relative path
		local TablineFileName = {
			provider = function(self)
				-- self.filename will be defined later, just keep looking at the example!
				local filename = self.filename
				filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
				return filename
			end,
			hl = function(self)
				return { bold = self.is_active or self.is_visible, italic = true }
			end,
		}

		-- this looks exactly like the FileFlags component that we saw in
		-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
		-- also, we are adding a nice icon for terminal buffers.
		local TablineFileFlags = {
			{
				condition = function(self)
					return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
				end,
				provider = "[+]",
				hl = { fg = "green" },
			},
			{
				condition = function(self)
					return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
						or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
				end,
				provider = function(self)
					if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
						return "  "
					else
						return ""
					end
				end,
				hl = { fg = "orange" },
			},
		}

		-- Here the filename block finally comes together
		local TablineFileNameBlock = {
			init = function(self)
				self.filename = vim.api.nvim_buf_get_name(self.bufnr)
			end,
			hl = function(self)
				if self.is_active then
					return "TabLineSel"
					-- why not?
					-- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
					--     return { fg = "gray" }
				else
					return "TabLine"
				end
			end,
			on_click = {
				callback = function(_, minwid, _, button)
					if button == "m" then -- close on mouse middle click
						vim.schedule(function()
							vim.api.nvim_buf_delete(minwid, { force = false })
						end)
					else
						vim.api.nvim_win_set_buf(0, minwid)
					end
				end,
				minwid = function(self)
					return self.bufnr
				end,
				name = "heirline_tabline_buffer_callback",
			},
			TablineBufnr,
			FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
			TablineFileName,
			TablineFileFlags,
		}

		-- a nice "x" button to close the buffer
		local TablineCloseButton = {
			condition = function(self)
				return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
			end,
			{ provider = " " },
			{
				provider = "",
				hl = { fg = "red" },
				on_click = {
					callback = function(_, minwid)
						vim.schedule(function()
							vim.api.nvim_buf_delete(minwid, { force = false })
							vim.cmd.redrawtabline()
						end)
					end,
					minwid = function(self)
						return self.bufnr
					end,
					name = "heirline_tabline_close_buffer_callback",
				},
			},
		}

		-- The final touch!
		local TablineBufferBlock = utils.surround({ "", "" }, function(self)
			if not self.is_active then
				return utils.get_highlight("TabLineSel").bg
			else
				return utils.get_highlight("TabLine").bg
			end
		end, { TablineFileNameBlock, TablineCloseButton })

		-- and here we go
		local BufferLine = utils.make_buflist(
			TablineBufferBlock,
			{ provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
			{ provider = "", hl = { fg = "gray" } } -- right trunctation, also optional (defaults to ...... yep, ">")
			-- by the way, open a lot of buffers and try clicking them ;)
		)
		require("heirline").setup({
			opts = {
				colors = colors,
				-- if the callback returns true, the winbar will be disabled for that window
				-- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
				disable_winbar_cb = function(args)
					return conditions.buffer_matches({
						buftype = { "nofile", "prompt", "help", "quickfix" },
						filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
					}, args.buf)
				end,
			},
			tabline = { BufferLine },
			statusline = {
				{ ViMode, GitBranch, FileNameBlock, GitDiff, Diagnostics, Align },
				{ LSPActive, Sep, Ruler, Space, ScrollBar, Space },
			},
			{},
		})
	end,
}
