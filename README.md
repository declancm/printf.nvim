<div align="center">
    <h1>printf.nvim</h1>
    <h5>A syntax-aware print debugging statement generator for C/C++</h5>
</div>

![printf.nvim](assets/printf_demo.gif "print_var demo")

*Note: This project is a work-in-progress - please expect breaking changes!*

## Features

- Generates print statements for printing line numbers, function names and variable values
- Can instantly remove all generated print statements
- Syntax and context aware - doesn't just use the word under the cursor to print a variable
- Automatically inserts format specifiers for all standard C types

## Requirements

- A tree-sitter parser for C
- The clangd language server

## Installation

### lazy.nvim

```lua
{
    'declancm/printf.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }
}
```

## Usage

```lua
local printf = require('printf')
vim.keymap.set('n', '<leader>dv', printf.print_var, {})  -- Print the variable under the cursor.
vim.keymap.set('n', '<leader>dl', printf.print_line, {}) -- Print the line number.
vim.keymap.set('n', '<leader>df', printf.print_fun, {})  -- Print the enclosed function name.
vim.keymap.set('n', '<leader>dc', printf.clean, {})      -- Remove all the generated statements.
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

