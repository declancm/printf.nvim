local M = {}

--- Check if a table contains a given value.
--- @param table table
--- @param value integer|string
--- @return boolean
M.contains = function(table, value)
	for i = 1, #table do
		if table[i] == value then
			return true
		end
	end
	return false
end

--- Insert the text in a new line with the current line indent.
--- @param text string
--- @param below boolean
M.insert_line = function(text, below)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	if not below then
		row = row - 1
	end

	-- TODO: Use treesitter to get the correct indentation.
	local indent = string.match(vim.api.nvim_get_current_line(), '^(%s*)')
	vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. text })
end

return M
