local M = {}

---@param message string
---@param level "debug" | "error" | "info" | "trace" | "warn" | "off"
---@param options? table={once: boolean?}
M.notify = function(message, level, options)
	options = options or {}
	local notify_level = vim.log.levels[level:upper()]
	assert(notify_level, 'Invalid log level: ' .. level)
	local notify_fn = options.once and vim.notify_once or vim.notify
	notify_fn('[printf.nvim] ' .. message, notify_level)
end

return M
