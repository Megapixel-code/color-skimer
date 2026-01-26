--- @type string
PLUGIN_NAME = "color-skimer"

--- @class name_override
--- @field [string] string new name to display in the menu instead of the colorscheme name

--- @class function_field
--- @field [string] function function that will be executed at a specific time

--- @class color_skimer_config
--- @field colorscheme string[] array of all of your colorschemes
--- @field name_override name_override? this will override the name displayed in the preview menu
--- @field pre_function function_field? this will be called before each preview of the colorscheme
--- @field post_function function_field? this will be called after each preview of the colorscheme
--- @field pre_callback function_field? this will be called before we save the colorscheme to memory
--- @field post_callback function_field? this will be called after we save the colorscheme to memory

--- @type color_skimer_config
DEFAULT_CONFIG = {
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
--- @field pre_function function
--- @field post_function function
--- @field pre_callback function
--- @field post_callback function

--- @class COLORSCHEME_PARAMS
--- @field [integer] colorscheme_param

--- @type COLORSCHEME_PARAMS
COLORSCHEME_PARAMS = {}

return {
   PLUGIN_NAME = PLUGIN_NAME,
   DEFAULT_CONFIG = DEFAULT_CONFIG,
   INTERFACE = INTERFACE,
   COLORSCHEME_PARAMS = COLORSCHEME_PARAMS,
}
