<div align="center">
    <h1>printf.nvim</h1>
    <h5>A smarter print debugging statement generator for C/C++</h5>
</div>

![printf.nvim](assets/printf_demo.gif "print_var demo")

## Features

- Generates print statements for:
  - line numbers
  - function names
  - variable values
- Syntax and context aware
- Automatic format specifier detection
- Customizable (see the Examples section for inspiration)

## Requirements

- Neovim >= 0.8.0
- A tree-sitter parser for C/C++
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

### Lua API

```lua
require('printf').print_var()   -- Print the variable under the cursor
require('printf').print_line()  -- Print the current line number
require('printf').print_func()  -- Print the name of the enclosed function
require('printf').clean()       -- Cleanup generated statements
```

### Vim Commands

The `Printf` command can be used to access the Lua API as Vim commands

```viml
:Printf print_var      " equivalent to `:lua require('printf').print_var()`
:Printf print_line     " equivalent to `:lua require('printf').print_line()`
:Printf print_func     " equivalent to `:lua require('printf').print_func()`
:Printf clean          " equivalent to `:lua require('printf').clean()`
```

### Example Keymaps

#### Lua

```lua
vim.keymap.set('n', '<leader>dv', require('printf').print_var, {})
vim.keymap.set('n', '<leader>dl', require('printf').print_line, {})
vim.keymap.set('n', '<leader>df', require('printf').print_func, {})
vim.keymap.set('n', '<leader>dc', require('printf').clean, {})
```

#### VimL

```viml
nnoremap <leader>dv <cmd>Printf print_var<cr>
nnoremap <leader>dl <cmd>Printf print_line<cr>
nnoremap <leader>df <cmd>Printf print_func<cr>
nnoremap <leader>dc <cmd>Printf clean<cr>
```

<!-- panvimdoc-ignore-start -->

### Help

Help docs can be accessed with `:help printf.nvim`

<!-- panvimdoc-ignore-end -->

## Configuration

```lua
require('printf').setup({
    -- Generated function call options
    called_function = {
        -- Name of the called function
        name = 'printf',
        -- Add additional arguments before the format string
        additional_args = {},
    },
    -- 'print_var' specific options
    print_var = {
        -- Automatically dereference supported pointer types
        dereference_pointers = false,
        -- Format char * variables as strings
        char_ptr_strings = true,
    },
    -- 'print_line' specific options
    print_line = {
        -- The variable/identifier/macro with the line number integer value
        variable = '__LINE__',
    },
    -- 'print_func' specific options
    print_func = {
        -- The variable/identifier/macro with the function name string
        variable = '__func__',
    },
})
```

## Examples

### Minimal Neovim Config

```lua
-- Install plugins
require('lazy').setup({
    'neovim/nvim-lspconfig',
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    'declancm/printf.nvim'
})

-- Setup nvim-treesitter
require('nvim-treesitter.configs').setup()

-- Setup the clangd language server
require('lspconfig').clangd.setup({})

-- Setup printf
require('printf').setup()
```

### Standard Error Stream

**Config:**

```lua
require('printf').setup({
    called_function = {
        name = 'fprintf',
        additional_args = { 'stderr' }
    }
})
```

**Output:**

```c
fprintf(stderr, "example: %d\n", example); // auto-generated printf
```

### Pretty Function

**Config:**

```lua
require('printf').setup({
    print_func = { variable = '__PRETTY_FUNCTION__' }
})
```

**Output:**

```c
printf("function: %s\n", __PRETTY_FUNCTION__); // auto-generated printf
```
