<div align="center">
    <h1>printf.nvim</h1>
    <h5>A smarter print debugging statement generator for C/C++</h5>
</div>

![printf.nvim](assets/printf_demo.gif "print_var demo")

*Note: This project is a work-in-progress - please expect breaking changes!*

## Features

- Generates print statements for printing line numbers, function names and variable values
- Can instantly remove all generated print statements
- Syntax and context aware - doesn't just use the word under the cursor to print a variable
- Automatically inserts format specifiers for all standard C types
- Customizable function call (see the Examples section for inspiration)

## Requirements

- Neovim >= 0.8.0
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

## Configuration

```lua
require('printf').setup({
    keymaps = {
        defaults = true,                -- Enable the default keymaps (see the Usage section for more details)
    },
    called_function = {
        name = 'printf',                -- Name of the called function
        additional_args = {
            left = {},                  -- Add additional arguments to the left of the format string
            right = {},                 -- Add additional arguments to the right of the format string
        },
    },
    print_var = {
        dereference_pointers = false,   -- Automatically dereference supported pointer types (excludes arrays, char * and void *)
        char_ptr_strings = true,        -- Format char * variables as strings
    },
})
```

## Usage

### Default Keymaps

#### Normal Mode

- **\<leader\>dv** - Print the variable under the cursor
- **\<leader\>dl** - Print the line number
- **\<leader\>df** - Print the enclosed function name
- **\<leader\>dc** - Remove all the generated statements

### Lua API

```lua
require('printf').print_var()   -- Print the variable under the cursor
require('printf').print_line()  -- Print the line number
require('printf').print_func()  -- Print the enclosed function name
require('printf').clean()       -- Remove all the generated statements
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

-- Make sure the tree-sitter parser for c is installed
require('nvim-treesitter.configs').setup({ ensure_installed = { 'c', 'cpp' } })

-- Setup the clangd language server
require('lspconfig').clangd.setup({})

-- Setup printf.
require('printf').setup()
```

### Standard Error Stream

**Config:**

```lua
require('printf').setup({
    called_function = {
        name = 'fprintf',
        additional_args = {
            left = { 'stderr' }
        }
    }
})
```

**Output:**

```c
fprintf(stderr, "example: %d\n", example); // auto-generated printf
```
