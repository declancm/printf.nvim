local M = {}

local config = require('printf.config')

--- Get the C language format specifier for the provided type.
--- @param type string
--- @return string|nil
--- @return table
M.get_format_specifier = function(type)
	-- Initialize the return values
	local format = nil
	local operators = {
		left = '',
		right = ''
	}

	-- Counter to keep track of how many dereferences occur to prevent infinite loops.
	local dereference_count = 0

	-- Remove keywords that don't have an effect on the type format specifier.
	type = type:gsub('volatile ', '')
	type = type:gsub('extern ', '')
	type = type:gsub('static ', '')
	type = type:gsub('const ', '')

	-- Check if signed or unsigned.
	local count
	type, count = type:gsub('unsigned ', '')
	local unsigned = count > 0
	type, count = type:gsub('signed ', '')
	local signed = count > 0

	while not format do
		-- Strip outer whitespace.
		type = type:match('^%s*(.-)%s*$')

		-- Look for a type match and get the format.
		if type:match('^char%[%d+%]$') then
			format = 's'
		elseif type == 'char *' and config.options.print_var.char_ptr_strings then
			format = 's'
		elseif type:match('%[%d+%]$') then
			format = 'p'
			operators.left = '(void *)'
		elseif type == '_Bool' or type == 'bool' then
			format = 'd'
		elseif type == 'size_t' then
			format = 'zu'
		elseif type == 'ssize_t' then
			format = 'zd'
		elseif type:match('^u?int%d+_t$') then
			format = '" PRI' .. type:sub(1, 1) .. type:match('^u?int(%d+)_t$') .. ' "'
		elseif type == 'inptr_t' then
			format = '" PRIdPTR "'
		elseif type == 'uinptr_t' then
			format = '" PRIuPTR "'
		elseif type:match(' %*$') and not config.options.print_var.dereference_pointers then
			format = 'p'
			operators.left = '(void *)' .. operators.left
		elseif type == 'char' then
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
		else
			-- The type didn't match a supported type. If the variable is a pointer,
			-- dereference it and check for a match. Maximum supported depth is 256 (to
			-- prevent infinite loops) which is the minimum recommended for a C++ compiler.
			if config.options.print_var.dereference_pointers and type:match('%*$') and dereference_count < 256 then
				type = type:match('(.*)%*$')
				operators.left = '*' .. operators.left
				dereference_count = dereference_count + 1
			else
				break
			end
		end
	end

	return format, operators
end

return M
