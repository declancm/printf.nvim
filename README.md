<div align="center">
    <h1>printf.nvim</h1>
    <h5>printf generator tool for Neovim powered by tree-sitter and LSP</h5>
</div>

![printf.nvim](assets/printf_demo.gif "print_var demo")

Print debugging is a valuable debugging technique, especially for situations where a debugger might be too timing intrusive.
This plugin automatically generates print statements which understand the code syntax and know what format specifiers to use.

*Note: This project is a work-in-progress - please expect breaking changes!*

## Features

- Full qualified variable name parsing
- Format specifier detection for standard types

## Requirements

- A tree-sitter parser for C
- The clangd language server

## Installation

### lazy.nvim

```lua
{
    'declancm/printf.nvim'
}
```

## Usage

```lua
local printf = require('printf')
vim.keymap.set('n', '<leader>dv', printf.print_var, {})
vim.keymap.set('n', '<leader>dl', printf.print_line, {})
vim.keymap.set('n', '<leader>df', printf.print_fun, {})
vim.keymap.set('n', '<leader>dc', printf.clean, {})
```

## Examples

### Minimal C Setup

```lua
-- Install plugins.
require('lazy').setup({
    'neovim/nvim-lspconfig',
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    'declancm/printf.nvim'
})

-- Install the tree-sitter parser for c.
require('nvim-treesitter.configs').setup({ ensure_installed = { 'c' } })

-- Setup the clangd language server.
require('lspconfig').clangd.setup({})

-- Setup printf keymaps.
local printf = require('printf')
vim.keymap.set('n', '<leader>dv', printf.print_var, {})
vim.keymap.set('n', '<leader>dl', printf.print_line, {})
vim.keymap.set('n', '<leader>df', printf.print_fun, {})
vim.keymap.set('n', '<leader>dc', printf.clean, {})
```

## Roadmap

- Support more languages
- Support more language servers

