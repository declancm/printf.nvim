local M = {}

-- TODO: Add telescope picker to search for variable names in current file and generate the print line under the cursor?

local utils = require('printf.utils')

local autogen_signature = 'auto-generated printf'

--- printf function options.
--- @class PrintfOptions
--- @field below boolean

--- @type PrintfOptions
local default_options = {
	below = true
}

--- @param options PrintfOptions|nil
--- @return PrintfOptions
local extend_options = function(options)
	if options then
		return vim.tbl_deep_extend('keep', options, default_options)
	end
	return default_options
end

--- Generate a printf() function call which prints the line number.
--- @param opts PrintfOptions|nil
M.print_line = function(opts)
	opts = extend_options(opts)
	local file_type = vim.api.nvim_get_option_value('filetype', { buf = 0 })
	local text

	if file_type == 'c' then
		text = 'printf("line: %d\\n", __LINE__); // ' .. autogen_signature
	else
		print('This file type is not supported')
		return
	end

	utils.insert_line(text, opts.below)
end

--- Generate a printf() function call which prints the function name.
--- @param opts PrintfOptions|nil
M.print_func = function(opts)
	opts = extend_options(opts)
	local file_type = vim.api.nvim_get_option_value('filetype', { buf = 0 })
	local text

	if file_type == 'c' then
		text = 'printf("func: %s\\n", __func__); // ' .. autogen_signature
	else
		print('This file type is not supported')
		return
	end

	utils.insert_line(text, opts.below)
end

--- Generate a printf() function call which prints the value of the variable under the cursor.
--- @param opts PrintfOptions|nil
M.print_var = function(opts)
	opts = extend_options(opts)
	local file_type = vim.api.nvim_get_option_value('filetype', { buf = 0 })
	local text

	local name = require('printf.name').get_var_qualified_name()
	if not name then
		print('A valid variable name was not found')
		return
	end

	if file_type == 'c' then
		local type = require('printf.type').get_var_type()
		if not type then
			print('Failed to retrieve the variable type')
			return
		end
		local format = require('printf.format').get_type_format_specifier(type)
		if not format then
			-- TODO: Move the cursor to manually type in the format when not available or not supported.
			print('A format specifier was not found')
			return
		end
		text = 'printf("' .. name .. ': " ' .. format .. ' "\\n", ' .. name .. '); // ' .. autogen_signature
	else
		print('This file type is not supported')
		return
	end

	utils.insert_line(text, opts.below)
end

--- Delete all generated lines in the current file by searching for the signature.
M.clean = function()
	local line_count = vim.api.nvim_buf_line_count(0)
	local escaped_signature = string.gsub(autogen_signature, '%-', '%%-')
	for i = line_count, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		if string.find(line, escaped_signature) then
			vim.api.nvim_buf_set_lines(0, i - 1, i, false, {})
		end
	end
end

return M
