local M = {}

local utils = require('printf.utils')

--- Get the qualified name of the variable under the cursor.
--- @return string|nil
M.get_var_qualified_name = function()
	local types = { 'identifier', 'field_identifier', 'field_expression', 'property' }

	-- Check if the cursor is starting on a variable.
	local node = vim.treesitter.get_node()
	if not node or not utils.contains(types, node:type()) then
		return nil
	end

	-- Traverse the parent nodes until the parent is no longer part of the variable.
	local parent = node:parent()
	while parent do
		if not utils.contains(types, parent:type()) then
			break
		end

		node = parent
		parent = node:parent()
	end

	return vim.treesitter.get_node_text(node, 0)
end

return M
