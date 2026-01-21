# Color-skimer

Color-skimer is a lightweight colorscheme/theme switcher. It allow you to change your colorschemes quickly and easily.

## TABLE OF CONTENTS

- [FEATURES](#features)
- [USAGE](#usage)
   - [how to interact with the plugin](#1-how-to-interact-with-the-plugin-)
   - [base binds](#2-base-binds)
- [INSTALLATION](#installation)
   - [lazy](#lazy)
   - [others (untested)](#others-untested)
- [CONFIGURATION](#configuration)
   - [example config](#example-config-)
   - [default config](#default-config-)
- [CUSTOM HOOKS](#custom-hooks)
- [WHY COLOR-SKIMER ?](why-color-skimer-)
- [LICENCE](#licence)

## FEATURES

- **Quick Colorscheme Switching**: Ability to cycle through your colorschemes fast
- **Persistent**: Colorscheme stays set across your sessions
- **Live Preview**: Preview your colorschemes as you move through your list
- **Custom Lua Hooks**: you can define Lua functions to be executed at specific times (see [CUSTOM HOOKS](#custom-hooks))
- **No dependencies**

## USAGE

### 1: how to interact with the plugin ?
with the plugin api :
```lua
color_skimer_toggle_function = require( "color-skimer" ).toggle
vim.api.nvim_set_keymap( "n", "<leader>st", "", { callback = color_skimer_toggle_function, desc = "Search themes" } )
```

or just use the command ```:ColorSkimerToggle```:
```lua
vim.api.nvim_set_keymap( "n", "<leader>st", "<cmd>ColorSkimerToggle<CR>", { desc = "Search themes" } )
```

### 2: base binds
- movement:
   same way as you would for any other buffer (```j```, ```k```, ```C-U```, ```C-D```, etc...)
- select and save to memory colorscheme : ```<CR>```
- exit without saving : ```<ESC>```

## INSTALLATION

### lazy
```lua
return {
   "Megapixel-code/color-skimer.nvim",
   config = function()
      require( "color-skimer" ).setup( {
         -- TODO: config goes here
      } )

      vim.api.nvim_set_keymap( "n", "<leader>st", "<cmd>ColorSkimerToggle<CR>", { desc = "Search themes" } )
   end,
}
```

### others (untested)
Packer :
```lua
use 'Megapixel-code/color-skimer.nvim'
require( "color-skimer" ).setup( {
   -- config goes here
} )
```

Vim-plug
```lua
Plug 'Megapixel-code/color-skimer.nvim'
require( "color-skimer" ).setup( {
   -- config goes here
} )
```

## CONFIGURATION

### Example config :
```lua
{
   colorscheme = { -- < your colorschemes names
      "github_dark_default",
      "vscode",
      "lackluster",
      "vague",
      "kanso-ink",
      "kanagawa-paper-ink",
      "rosebones",
      "tokyobones",
      "neobones",
      "spaceduck",
      "slightlyclownish",
      "base16-ashes",
      "base16-kanagawa-dragon",
      "base16-vulcan",
      "base16-tarot",
   },

   name_override = { -- < this will override the name displayed in the preview menu
      ["github_dark_default"] = "github",
   },

   pre_function = { -- < this will be called before each preview of the colorscheme
      ["*"] = function()
         -- you can use the star to execute before each
         -- will execute before displaying colorscheme
         -- [Example]
         -- Here it would print "aww" for every colorscheme
         -- exept github_dark_default where it would only print "eww"
         print( "aww" )
      end,
      ["github_dark_default"] = function()
         print( "eww" )
      end,
   },
   post_function = { -- < this will be called after each preview of the colorscheme
      -- same options as pre_function
   },

   pre_callback = { -- < this will be called before we save the colorscheme to memory
      -- same options as pre_function
   },
   post_callback = { -- < this will be called after we save the colorscheme to memory
      -- same options as pre_function
   },
}
```

### Default config :
If you give a empty table or no table in setup() the plugin will act as this is your config:

```lua
{
   colorscheme = {
      -- default vim themes
      "blue",
      "darkblue",
      "default",
      "delek",
      "desert",
      "elflord",
      "evening",
      "habamax",
      "industry",
      "koehler",
      "lunaperche",
      "morning",
      "murphy",
      "pablo",
      "peachpuff",
      "quiet",
      "retrobox",
      "ron",
      "shine",
      "slate",
      "sorbet",
      "torte",
      "unokai",
      "wildcharm",
      "zaibatsu",
      "zellner",
   },

   name_override = {},

   pre_function = {
      ["*"] = function() end,
   },
   post_function = {
      ["*"] = function() end,
   },

   pre_callback = {
      ["*"] = function() end,
   },
   post_callback = {
      ["*"] = function() end,
   },
}
```

## CUSTOM HOOKS
color-skimer has great hooks that can be set for all or specific colorschemes. This is the main reason I created this plugin (see [WHY COLOR-SKIMER ?](why-color-skimer-)).

```lua
pre_function  > this will be called everytime before the colorscheme is displayed on the screen
post_function > this will be called everytime after the colorscheme is displayed on the screen
pre_callback  > this will be called before saving the colorscheme to memory
post_callback > this will be called after saving the colorscheme to memory
```

Examples :
```lua
{
   pre_function = {
      -- Here it would set nvim in dark mode for every colorscheme
      -- exept vscode where set it to light mode
      ["*"] = function()
         vim.o.background = "dark"
      end,
      ["vscode"] = function()
         vim.o.background = "light"
      end,
   },
   post_function = {
      ["*"] = function()
         print("we are previewing a colorscheme")
      end,
      ["vague"] = function()
         print("we are previewing the vague colorscheme")
      end,
   },

   pre_callback = {
      ["*"] = function() end,
   },
   post_callback = {
      ["*"] = function()
         -- message after saving, right before closing the plugin
         print("colorscheme set and saved !")
      end,
   },
}
```

## WHY COLOR-SKIMER ?
Other plugins options :
- themery: https://github.com/zaldih/themery.nvim

I used themery for a long time. Whilst this plugin is great there are few reasons I wanted to create this and move away from themery:

- 1: I **need** the post_save_callback hook to update my terminal colors after every colorscheme save
- 2: I want to be able to have Lua function instead of text blocks that get executed
- 3: Themery seems to go in the direction of a complete theme manager with a community repertoire. I do not have the need for this and I would rather have a lighter plugin than have that bloat built in (my opinion).
- 4: To have a bit of fun, this is my first plugin

## LICENCE
GPL-3
