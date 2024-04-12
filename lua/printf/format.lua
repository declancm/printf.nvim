local M = {}

--- Get the C language format specifier for the provided type.
--- @param type string
--- @return string|nil
M.get_type_format_specifier = function(type)
	if not type then
		return nil
	end

	-- Remove keywords that don't have an effect on the type format specifier.
	type = type:gsub('volatile ', '')
	type = type:gsub('extern ', '')
	type = type:gsub('static ', '')
	type = type:gsub('const ', '')

	-- Return the format specifier.
	if type == '_Bool' or type == 'bool' then
		return '"%d"'
	elseif type:match('^char[%d+]$') or type == 'char *' then
		return '"%s"'
	elseif type:match('.* %*$') then
		return '"%u"'
	elseif type:match('^u?int%d+_t$') then
		local size = type:match('^u?int(%d+)_t$')
		return '"%" PRI' .. type:sub(1, 1) .. size
	else
		-- Check if signed or unsigned.
		local count
		type, count = type:gsub('unsigned ', '', 1)
		local unsigned = count > 0
		type, count = type:gsub('signed ', '', 1)
		local signed = count > 0

		if type == 'char' then
			if unsigned then
				return '"%hhu"'
			elseif signed then
				return '"%hhd"'
			else
				return '"%c"'
			end
		elseif type == 'short' then
			return unsigned and '"%hu"' or '"%hd"'
		elseif type == 'int' then
			return unsigned and '"%u"' or '"%d"'
		elseif type == 'long' then
			return unsigned and '"%lu"' or '"%ld"'
		elseif type == 'long long' then
			return unsigned and '"%llu"' or '"%lld"'
		elseif type == 'float' then
			return '"%f"'
		elseif type == 'double' then
			return '"%f"'
		elseif type == 'long double' then
			return '"%Lf"'
		else
			-- Unknown type.
			return nil
		end
	end
end

return M
