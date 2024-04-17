local M = {}

local defaults = {
	keymaps = {
		defaults = true,
	},
	called_function = {
		name = 'printf',
		additional_args = {},
	},
	print_var = {
		dereference_pointers = false,
	},
	print_line = {
		variable = '__LINE__',
	},
	print_func = {
		variable = '__func__',
	},
}

M.options = {}

M.setup = function(user_config)
	M.options = vim.tbl_deep_extend('force', {}, defaults, user_config or {})
end

return M
