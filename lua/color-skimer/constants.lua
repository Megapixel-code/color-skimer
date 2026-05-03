--- @type string
PLUGIN_NAME = "color-skimer"

--- @class name_override
--- @field [string] string new name to display in the menu instead of the colorscheme name

--- @class function_field
--- @field [string] function function that will be executed at a specific time

--- @class window_config
--- @field config? vim.api.keyset.win_config
--- @field shape? fun(): color_skimer_win_shape

--- @class color_skimer_win_shape
--- @field width integer
--- @field height integer
--- @field row integer
--- @field col integer

--- @class keys
--- @field toggle_plugin? string
--- @field escape? string
--- @field save? string
--- @field random? string

--- @class color_skimer_config
--- @field colorscheme string[] array of all of your colorschemes
--- @field name_override? name_override this will override the name displayed in the preview menu
--- @field window_config? window_config override window config of the plugin
--- @field keys? keys The key that you will use to close the plugin menu window
--- @field pre_preview? function_field this will be called before each preview of the colorscheme
--- @field post_preview? function_field this will be called after each preview of the colorscheme
--- @field pre_save? function_field this will be called before we save the colorscheme to memory
--- @field post_save? function_field this will be called after we save the colorscheme to memory

--- @module "color-skimer"
--- @type color_skimer_config
DEFAULT_CONFIG = {
   colorscheme = { -- < list of your colorschemes names
      -- The default options are the default vim colorschemes :
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

   name_override = { -- < this will override the name displayed in the preview menu
      -- [Example]
      -- The name displayed for the "default" colorscheme will be displayed as "tluafed" in the preview menu
      -- ["default"] = "tluafed",
   },

   window_config = {
      -- Very similar options as the {config} parameter of `:h nvim_open_win()`
      -- NOTE: width, height, row and col fields will be overwritten by the plugin
      --       if you want to set theses yourself, look at the "shape" option bellow
      config = {
         style = "minimal",
         relative = "editor",
         border = "single",
         title = " Color-Skimer ",
         title_pos = "center",
      },
      -- You can also have a function give the width, height, row and col of the menu window
      shape = function()
         local editor_columns = vim.api.nvim_get_option_value( "columns", {} )
         local editor_rows = vim.api.nvim_get_option_value( "lines", {} )
         local width = 40
         local height = 15

         --- @type color_skimer_win_shape
         return {
            width = width - 2,
            height = height - 2,
            col = (editor_columns / 2) - (width / 2),
            row = (editor_rows / 2) - (height / 2),
         }
      end,
   },

   -- Same options as the {lhs} parameter of ':h vim.keymap.set()'
   -- NOTE: If the variable is an empty string it won't set the keymap
   --       That means you might not have a way to interact with the plugin
   keys = {               -- < Redefine some keymaps
      toggle_plugin = "", -- < Open/Close the plugin menu window, Example: I personally use "<leader>sc" (for Search Colorscheme)
      escape = "<ESC>",   -- < Close the plugin menu window.
      save = "<CR>",      -- < Select and save a colorscheme in the menu window.
      random = "r",       -- < Preview a random colorscheme when in the plugin menu window
   },

   -- For more information about the pre_preview, post_preview, pre_save and post_save configurations,
   -- look at the README on the [CUSTOM HOOKS] section
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

--- @diagnostic disable-next-line: unused-local
local hooks_config_example = {
   pre_preview = {
      -- Here it would set nvim in dark mode for every colorscheme
      -- except vscode where we set it to light mode
      ["*"] = function()
         vim.o.background = "dark"
      end,
      ["vscode"] = function()
         vim.o.background = "light"
      end,
   },
   post_preview = {
      ["*"] = function()
         print( "we are previewing a colorscheme" )
      end,
      ["vague"] = function()
         print( "we are previewing the vague colorscheme" )
      end,
   },

   pre_save = {
      ["*"] = function() end,
   },
   post_save = {
      ["*"] = function()
         -- message after saving, right before closing the menu window
         print( "colorscheme set and saved !" )
      end,
   },
}

--- @class INTERFACE
--- @field buf_id number?
--- @field win_id number?

--- @type INTERFACE
INTERFACE = {
   buf_id = nil,
   win_id = nil,
}

--- @class colorscheme_param
--- @field colorscheme string
--- @field name string
--- @field pre_preview function
--- @field post_preview function
--- @field pre_save function
--- @field post_save function

--- @class COLORSCHEME_PARAMS
--- @field [integer] colorscheme_param
--- @field keys? keys
--- @field window_config? window_config

--- @type COLORSCHEME_PARAMS
COLORSCHEME_PARAMS = {}

return {
   PLUGIN_NAME = PLUGIN_NAME,
   DEFAULT_CONFIG = DEFAULT_CONFIG,
   INTERFACE = INTERFACE,
   COLORSCHEME_PARAMS = COLORSCHEME_PARAMS,
}
