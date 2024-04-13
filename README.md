<div align="center">
    <h1>printf.nvim</h1>
    <h5>printf generator tool for Neovim powered by tree-sitter and LSP</h5>
</div>

## Disclaimer

This project is a work-in-progress - please expect breaking changes!

## Features

- Full qualified variable name parsing using tree-sitter
- Format specifier detection for standard C types using LSP

## Requirements

- A tree-sitter parser for C
- The clangd language server

## Installation

### lazy.nvim

```lua
{
    'declancm/printf.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'neovim/lsp-config',
    }
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

## Roadmap

- Support more languages
- Support more language servers

