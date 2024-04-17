local M = {}

-- TODO: Add telescope picker to search for variable names in current file and generate the print line under the cursor?

local utils = require('printf.utils')
local config = require('printf.config')

local autogen_signature = 'auto-generated printf'

--- Setup the plugin.
M.setup = function(user_config)
	config.setup(user_config)

	if config.options.keymaps.defaults then
		vim.api.nvim_set_keymap('n', '<leader>dv', '', { callback = M.print_var })
		vim.api.nvim_set_keymap('n', '<leader>dl', '', { callback = M.print_line })
		vim.api.nvim_set_keymap('n', '<leader>df', '', { callback = M.print_func })
		vim.api.nvim_set_keymap('n', '<leader>dc', '', { callback = M.clean })
	end
end

--- Generate the print statement.
--- @param format string
--- @param value string
local function generate_print(format, value)
	-- Construct the argument list.
	local args = {}
	for _, v in ipairs(config.options.called_function.additional_args.left) do
		table.insert(args, v)
	end
	table.insert(args, format)
	table.insert(args, value)
	for _, v in ipairs(config.options.called_function.additional_args.right) do
		table.insert(args, v)
	end

	-- Generate the function call and arguments.
	local name = config.options.called_function.name
	local line = name .. '(' .. table.concat(args, ', ') .. ');'

	-- Append the signature comment.
	line = line .. ' // ' .. autogen_signature

	utils.insert_line(line)
end

--- Generate a printf() function call which prints the line number.
M.print_line = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"line: %d\\n"', '__LINE__')
	else
		vim.notify('This file type is not supported', vim.log.levels.WARN)
	end
end

--- Generate a printf() function call which prints the function name.
M.print_func = function()
	local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })

	if ft == 'c' or ft == 'cpp' then
		generate_print('"function: %d\\n"', '__func__')
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

		local format, cast = require('printf.format').get_format_specifier(type)
		if not format then
			-- TODO: Move the cursor to manually type in the format when not available or not supported.
			vim.notify('The variable type is not supported', vim.log.levels.WARN)
			return
		end

		local format_string = '"' .. name .. ': %' .. format .. '\\n"'
		local value = (cast or '') .. name
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
