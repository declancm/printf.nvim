local M = {}

--- Get the variable type information from the LSP hover method.
--- @param ls_name string
--- @param hover_value string
--- @return string
local get_type_from_hover = function(ls_name, hover_value)
	local type

	if ls_name == 'clangd' then
		type = string.match(hover_value, 'Type: `(.-)`') or ''

		-- Some types like uint8_t have descriptions in braces so cut it off.
		type = string.match(type, '^(.-) %(.*%)') or type
	end

	return type
end

--- Gets the type of the variable under the cursor.
--- @return string|nil
M.get_var_type = function()
	-- Get the attached language server name.
	local lsp_clients = vim.lsp.get_clients()
	if not lsp_clients or not next(lsp_clients) then
		return nil
	end
	local ls_name = lsp_clients[1].name

	-- Get the LSP hover method since that has type data.
	local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win())
	local response = vim.lsp.buf_request_sync(vim.api.nvim_get_current_buf(), 'textDocument/hover', params)
	if not response or not next(response) then
		return nil
	end
	local value = response[1].result.contents.value

	return get_type_from_hover(ls_name, value)
end

return M
