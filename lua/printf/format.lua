local M = {}

local config = require('printf.config')

--- Get the C language format specifier for the provided type.
--- @param type string
--- @return string|nil
--- @return table
M.get_format_specifier = function(type)
	-- Initialize the return values
	local format = nil
	local operators = {}

	-- Remove keywords that don't have an effect on the type format specifier.
	type = type:gsub('volatile ', '')
	type = type:gsub('extern ', '')
	type = type:gsub('static ', '')
	type = type:gsub('const ', '')

	-- Return the format specifier.
	if type == '_Bool' or type == 'bool' then
		format = 'd'
	elseif type:match('^char%[%d+%]$') then
		format = 's'
	elseif type == 'char *' and config.options.print_var.char_ptr_strings then
		format = 's'
	elseif type == 'size_t' then
		format = 'zu'
	elseif type == 'ssize_t' then
		format = 'zd'
	elseif type:match('^u?int%d+_t$') then
		local size = type:match('^u?int(%d+)_t$')
		format = '" PRI' .. type:sub(1, 1) .. size .. ' "'
	elseif type == 'inptr_t' then
		format = '" PRIdPTR "'
	elseif type == 'uinptr_t' then
		format = '" PRIuPTR "'
	elseif type:match(' %*$') then
		format = 'p'
		operators.left = '(void *)'
	elseif type:match('%[%d+%]$') then
		format = 'p'
		operators.left = '(void *)'
	else
		-- Check if signed or unsigned.
		local count
		type, count = type:gsub('unsigned ', '', 1)
		local unsigned = count > 0
		type, count = type:gsub('signed ', '', 1)
		local signed = count > 0

		if type == 'char' then
			if unsigned then
				format = 'hhu'
			elseif signed then
				format = 'hhd'
			else
				format = 'c'
			end
		elseif type == 'short' or type == 'short int' then
			format = unsigned and 'hu' or 'hd'
		elseif type == 'int' then
			format = unsigned and 'u' or 'd'
		elseif type == 'long' or type == 'long int' then
			format = unsigned and 'lu' or 'ld'
		elseif type == 'long long' or type == 'long long int' then
			format = unsigned and 'llu' or 'lld'
		elseif type == 'float' then
			format = 'f'
		elseif type == 'double' then
			format = 'f'
		elseif type == 'long double' then
			format = 'Lf'
		end
	end

	return format, operators
end

return M
