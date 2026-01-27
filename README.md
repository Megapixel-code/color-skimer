# Color-skimer

Color-skimer is a lightweight colorscheme/theme switcher. It allow you to change your colorschemes quickly and easily. Inspired by [themery.nvim](https://github.com/zaldih/themery.nvim).

## TABLE OF CONTENTS

- [FEATURES](#features)
- [USAGE](#usage)
   - [How to interact with the plugin](#how-to-interact-with-the-plugin-)
   - [Base binds](#base-binds)
- [INSTALLATION](#installation)
   - [lazy](#lazy)
   - [others (untested)](#others-untested)
- [CONFIGURATION](#configuration)
   - [example config](#example-config-)
   - [default config](#default-config-)
- [CUSTOM HOOKS](#custom-hooks)
- [WHY COLOR-SKIMER ?](why-color-skimer-)
- [CONTRIBUTING](#contributing)
- [LICENCE](#licence)

## FEATURES

- **Quick Colorscheme Switching**: Ability to cycle through your colorschemes fast.
- **Persistent**: Colorscheme stays set across your sessions.
- **Live Preview**: Preview your colorschemes as you move through your list.
- **Higly Configurable**: Large amount of specific configurations options available
- **Custom Lua Hooks**: You can define Lua functions to be executed at specific instants. (see [CUSTOM HOOKS](#custom-hooks))
- **No dependencies**.

## USAGE

### How to interact with the plugin ?
With the plugin api :
```lua
local color_skimer_toggle_function = require( "color-skimer" ).toggle
vim.api.nvim_set_keymap( "n", "<leader>st", "", { callback = color_skimer_toggle_function, desc = "Search themes" } )
```

Or just use the command ```:ColorSkimerToggle```:
```lua
vim.api.nvim_set_keymap( "n", "<leader>st", "<cmd>ColorSkimerToggle<CR>", { desc = "Search themes" } )
```

### Base binds
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
vim.api.nvim_set_keymap( "n", "<leader>st", "<cmd>ColorSkimerToggle<CR>", { desc = "Search themes" } )
```

Vim-plug :
```lua
Plug 'Megapixel-code/color-skimer.nvim'
require( "color-skimer" ).setup( {
   -- config goes here
} )
vim.api.nvim_set_keymap( "n", "<leader>st", "<cmd>ColorSkimerToggle<CR>", { desc = "Search themes" } )
```

## CONFIGURATION

### Example config :
```lua
--- @type color_skimer_config
local options = {
   colorscheme = { -- < your colorschemes names
      "github_dark_default",
      "vscode",
      "lackluster",
      "no-clown-fiesta-dark",
      "vague",
      "kanso-ink",
      "kanagawa-paper-ink",
      "zenbones",
      "rosebones",
      "tokyobones",
      "neobones",
      "spaceduck",
      "terafox",
      "base16-ashes",
      "base16-kanagawa-dragon",
      "base16-vulcan",
      "base16-tarot",
   },

   name_override = { -- < this will override the name displayed in the preview menu
      ["github_dark_default"] = "github",
   },

   pre_preview = { -- < this will be called before each preview of the colorscheme
      ["*"] = function()
         -- you can use the star to execute before each
         -- [Example]
         -- Here it would set every colorscheme to dark mode
         -- exept vscode where it would set it to light mode
         vim.o.background = "dark"
      end,
      ["vscode"] = function()
         vim.o.background = "light"
      end,
   },
   post_preview = { -- < this will be called after each preview of the colorscheme
      -- same options as pre_preview
   },

   pre_save = { -- < this will be called before we save the colorscheme to memory
      -- same options as pre_preview
   },
   post_save = { -- < this will be called after we save the colorscheme to memory
      -- same options as pre_preview
      ["*"] = function()
         -- [Example]
         -- Here it would print "aww" for every colorscheme
         -- exept github_dark_default where it would only print "eww"
         print( "aww" )
      end,
      ["github_dark_default"] = function()
         print( "eww" )
      end,
   },
}

require( "color-skimer" ).setup( options )
```

### Default config :
If you give a empty table or no table in setup() the plugin will act as this is your config:

```lua
--- @type color_skimer_config
local options = {
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

   pre_preview = {
      ["*"] = function() end,
   },
   post_preview = {
      ["*"] = function() end,
   },

   pre_save = {
      ["*"] = function() end,
   },
   post_save = {
      ["*"] = function() end,
   },
}

require( "color-skimer" ).setup( options )
```

## CUSTOM HOOKS
Color-skimer has great hooks that can be set for all or specific colorschemes. This is the main reason I created this plugin (see [WHY COLOR-SKIMER ?](why-color-skimer-)).

```lua
pre_preview  > this will be called everytime before the colorscheme is displayed on the screen
post_preview > this will be called everytime after the colorscheme is displayed on the screen
pre_save     > this will be called everytime before saving the colorscheme to memory
post_save    > this will be called everytime after saving the colorscheme to memory
```

Examples :
```lua
{
   pre_preview = {
      -- Here it would set nvim in dark mode for every colorscheme
      -- except vscode where set it to light mode
      ["*"] = function()
         vim.o.background = "dark"
      end,
      ["vscode"] = function()
         vim.o.background = "light"
      end,
   },
   post_preview = {
      ["*"] = function()
         print("we are previewing a colorscheme")
      end,
      ["vague"] = function()
         print("we are previewing the vague colorscheme")
      end,
   },

   pre_save = {
      ["*"] = function() end,
   },
   post_save = {
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

I used themery for a long time. Whilst this plugin is great there are few reasons I wanted to create this and move away from themery :

- 1: I **need** the post_save hook to update my terminal colors after every colorscheme save.
- 2: I want to be able to have Lua function instead of text blocks that get executed.
- 3: Themery seems to go in the direction of a complete theme manager with a community repertoire. I do not have the need for this and I would rather have a lighter plugin than have that bloat built in (my opinion).
- 4: Color-skimer has (in my opinion) better/nicer configuration settings.
- 5: To have a bit of fun, this is my first plugin.

## CONTRIBUTING
- No AI slop.
- Only submit a pull request after having a prior issue or discussion.
- Keep PRs small and focused.

## LICENSE
GPL-3
