local M = {}

--- Get the variable type information from the LSP hover method.
--- @param hover_value string
--- @return string
local get_type_from_hover = function(hover_value)
    local type = hover_value:match('Type: `(.-)`') or ''
    return type:match(' %(aka (.*)%)') or type
end

--- Gets the type of the variable under the cursor.
--- @return string|nil
M.get_var_type = function()
    -- Get the client ID for clangd.
    local clangd_id = nil
    for _, client in pairs(vim.lsp.get_clients()) do
        if client.name == 'clangd' then
            clangd_id = client.id
            break
        end
    end
    if clangd_id == nil then
        return nil
    end

    -- Get the LSP hover method since that has type data.
    local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win())
    local response = vim.lsp.buf_request_sync(vim.api.nvim_get_current_buf(), 'textDocument/hover', params)
    if not response or not response[clangd_id] then
        return nil
    end
    local value = response[clangd_id].result.contents.value

    return get_type_from_hover(value)
end

return M
