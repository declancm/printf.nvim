local config = require('printf.config')
local utils = require('printf.utils')
local M = {}

-- TODO: Add telescope picker to search for variable names in current file and generate the print line under the cursor?

local autogen_signature = 'auto-generated printf'

--- Setup the plugin.
M.setup = function(user_config)
	config.setup(user_config)

	vim.api.nvim_create_user_command('Printf', function(arg)
		local function_name = arg.args
		if type(M[function_name]) == 'function' then
			M[function_name]()
		else
			utils.notify('Not a valid command', 'warn')
		end
	end, { nargs = 1 })
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

--- Generate a print statement which prints the line number.
M.print_line = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"line: %d\\n"', config.options.print_line.variable)
	else
		utils.notify('This file type is not supported', 'warn')
	end
end

--- Generate a print statement which prints the name of the enclosed function.
M.print_func = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"function: %s\\n"', config.options.print_func.variable)
	else
		utils.notify('This file type is not supported', 'warn')
	end
end

--- Generate a print statement which prints the value of the variable under the cursor.
M.print_var = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		if not utils.treesitter_parser_exists(ft) then
			utils.notify('The tree-sitter parser for ' .. ft .. ' is not installed', 'warn')
			return
		end

		local name = require('printf.name').get_var_qualified_name()
		if not name then
			utils.notify('A valid variable name was not found', 'warn')
			return
		end

		local type = require('printf.type').get_var_type()
		if not type then
			utils.notify('Failed to get the variable type', 'error')
			return
		end

		local format, operators = require('printf.format').get_format_specifier(type)
		if not format then
			-- TODO: Move the cursor to manually type in the format when not available or not supported.
			utils.notify('The variable type is not supported', 'warn')
			return
		end

		local format_string = '"' .. name .. ': %' .. format .. '\\n"'
		local value = (operators.left or '') .. name .. (operators.right or '')
		generate_print(format_string, value)
	else
		utils.notify('This file type is not supported', 'warn')
	end
end

--- Delete all generated print statements in the current file by searching for the signature.
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
