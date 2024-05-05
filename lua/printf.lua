local M = {}

-- TODO: Add telescope picker to search for variable names in current file and generate the print line under the cursor?

local config = require('printf.config')

local autogen_signature = 'auto-generated printf'

--- Setup the plugin.
M.setup = function(user_config)
	config.setup(user_config)

	if config.options.keymaps.defaults then
		vim.api.nvim_set_keymap('n', '<leader>dv', '', { callback = M.print_var, desc = 'Debug print variable.' })
		vim.api.nvim_set_keymap('n', '<leader>dl', '', { callback = M.print_line, desc = 'Debug print line number.' })
		vim.api.nvim_set_keymap('n', '<leader>df', '', { callback = M.print_func, desc = 'Debug print function name.' })
		vim.api.nvim_set_keymap('n', '<leader>dc', '', { callback = M.clean, desc = 'Debug print cleanup.' })
	end
end

--- Generate the print statement.
--- @param format string
--- @param value string
local function generate_print(format, value)
	-- Construct the argument list.
	local args = vim.deepcopy(config.options.called_function.additional_args)
	table.insert(args, format)
	table.insert(args, value)

	-- Generate the function call and arguments.
	local name = config.options.called_function.name
	local line = name .. '(' .. table.concat(args, ', ') .. ');'

	-- Append the signature comment.
	line = line .. ' // ' .. autogen_signature

	-- Prepend the indent.
	local indent = vim.api.nvim_get_current_line():match('^(%s*)')
	line = indent .. line

	-- Insert the new line.
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, { line })
end

--- Generate a printf() function call which prints the line number.
M.print_line = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"line: %d\\n"', config.options.print_line.variable)
	else
		vim.notify('This file type is not supported', vim.log.levels.WARN)
	end
end

--- Generate a printf() function call which prints the function name.
M.print_func = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"function: %s\\n"', config.options.print_func.variable)
	else
		vim.notify('This file type is not supported', vim.log.levels.WARN)
	end
end

--- Generate a printf() function call which prints the value of the variable under the cursor.
M.print_var = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
	if not ok then
		vim.notify('The nvim-treesitter plugin is required', vim.log.levels.ERROR)
		return
	elseif not parsers.has_parser() then
		vim.notify('This file type is missing a tree-sitter parser', vim.log.levels.ERROR)
		return
	end

	if ft == 'c' or ft == 'cpp' then
		local name = require('printf.name').get_var_qualified_name()
		if not name then
			vim.notify('A valid variable name was not found', vim.log.levels.WARN)
			return
		end

		local type = require('printf.type').get_var_type()
		if not type then
			vim.notify('Failed to get the variable type', vim.log.levels.ERROR)
			return
		end

		local format, operators = require('printf.format').get_format_specifier(type)
		if not format then
			-- TODO: Move the cursor to manually type in the format when not available or not supported.
			vim.notify('The variable type is not supported', vim.log.levels.WARN)
			return
		end

		local format_string = '"' .. name .. ': %' .. format .. '\\n"'
		local value = (operators.left or '') .. name .. (operators.right or '')
		generate_print(format_string, value)
	else
		vim.notify('This file type is not supported', vim.log.levels.WARN)
	end
end

--- Delete all generated lines in the current file by searching for the signature.
M.clean = function()
	local line_count = vim.api.nvim_buf_line_count(0)
	local escaped_signature = autogen_signature:gsub('%-', '%%-')
	for i = line_count, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		if line:find(escaped_signature) then
			vim.api.nvim_buf_set_lines(0, i - 1, i, false, {})
		end
	end
end

return M
