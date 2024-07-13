local utils = require('printf.utils')

local health = vim.health or require('health')
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error
local info = health.info or health.report_info

local treesitter_parsers = {
	'c',
	'cpp',
}

local M = {}

M.check = function()
	start('Checking for clangd')
	if vim.fn.executable('clangd') == 1 then
		local version = vim.split(vim.fn.system('clangd --version'), ' ')[3]
		ok('clangd is installed `' .. version .. '`')
	else
		error('clangd is not installed')
	end

	start('Checking for tree-sitter parsers')
	for _, lang in ipairs(treesitter_parsers) do
		if utils.treesitter_parser_exists(lang) then
			ok('The tree-sitter parser for ' .. lang .. ' is installed')
		else
			warn('The tree-sitter parser for ' .. lang .. ' is not installed')
		end
	end
end

return M
