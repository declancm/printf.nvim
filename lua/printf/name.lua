local M = {}

local utils = require('printf.utils')

--- Get the qualified name of the variable under the cursor.
--- @return string
M.get_var_qualified_name = function()
	local node = vim.treesitter.get_node()
	local types = { 'identifier', 'field_identifier', 'field_expression', 'property' }

	if not node or not utils.contains(types, node:type()) then
		return ''
	end

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
