local M = {}

--- Get the C language format specifier for the provided type.
--- @param type string
--- @return string
M.get_type_format_specifier = function(type)
	-- Check if unsigned.
	local unsigned = string.match(type, 'unsigned (.*)') and true or false
	if unsigned then
		type = string.sub(type, #'unsigned ' + 1)
	end

	-- Return format specifier.
	if not type or type == '' then
		return ''
	elseif type == '_Bool' or type == 'bool' then
		return '"%d"'
	elseif type == 'char' then
		return '"%c"'
	elseif type == 'short' then
		return unsigned and '"%u"' or '"%d"'
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
	elseif string.match(type, '^(char[%d+])$') or type == 'char *' then
		return '"%s"'
	elseif string.match(type, '^(u?int%d+_t)$') then
		local size = string.match(type, '^u?int(%d+)_t$')
		if type[1] == 'u' then
			return '"%" PRIu' .. size
		else
			return '"%" PRIi' .. size
		end
	elseif string.match(type, '^(.* %*)$') then
		return '"%u"'
	else
		return ''
	end
end

return M
