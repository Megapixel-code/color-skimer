PLUGIN_NAME = "color-skimer"
INTERFACE = {
   buf_id = nil,
   win_id = nil,
}

-- [[ SETUP ]]

--- function that returns the default options
--- @return table
local function get_default_options()
   return {
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

      name_override = nil,

      pre_function = function() end,
      post_function = function() end,

      pre_callback = function() end,
      post_callback = function() end,
   }
end

--- function that setup the tables to be read by the rest of the program
--- tables will be set like so:
--- result = {
---    {
---      name = "...",
---      colorscheme = "...",
---      pre_function = function() ... end
---      post_function = function() ... end
---      pre_callback = function() ... end
---      post_callback = function() ... end
---    }
---    ... for every colorscheme
--- }
--- @param options_table table
--- @return table
local function get_init_tables( options_table )
   local default = get_default_options()

   local result = {}

   local name
   local pre_function
   local post_function
   local pre_callback
   local post_callback

   if options_table.colorscheme == nil then
      options_table.colorscheme = default.colorscheme
   end

   for _, colorscheme in ipairs( options_table.colorscheme ) do
      if options_table.name_override[colorscheme] ~= nil then
         name = options_table.name_override[colorscheme]
      else
         name = colorscheme
      end

      if options_table.pre_function[colorscheme] ~= nil then
         pre_function = options_table.pre_function[colorscheme]
      elseif options_table.pre_function["*"] ~= nil then
         pre_function = options_table.pre_function["*"]
      else
         pre_function = default.pre_function
      end


      if options_table.post_function[colorscheme] ~= nil then
         post_function = options_table.post_function[colorscheme]
      elseif options_table.post_function["*"] ~= nil then
         post_function = options_table.post_function["*"]
      else
         post_function = default.post_function
      end

      if options_table.pre_callback[colorscheme] ~= nil then
         pre_callback = options_table.pre_callback[colorscheme]
      elseif options_table.pre_callback["*"] ~= nil then
         pre_callback = options_table.pre_callback["*"]
      else
         pre_callback = default.pre_callback
      end

      if options_table.post_callback[colorscheme] ~= nil then
         post_callback = options_table.post_callback[colorscheme]
      elseif options_table.post_callback["*"] ~= nil then
         post_callback = options_table.post_callback["*"]
      else
         post_callback = default.post_callback
      end

      vim.list_extend( result, {
         {
            colorscheme = colorscheme,
            name = name,
            pre_function = pre_function,
            post_function = post_function,
            pre_callback = pre_callback,
            post_callback = post_callback,
         },
      } )
   end
   return result
end

-- [[ UTILS ]]

--- this will preview the colorscheme, we execute pre and post functions to
--- make sure the colorscheme is displayed correcly.
local function display_colorscheme( colorscheme_params )
   colorscheme_params.pre_function()

   vim.cmd( "colorscheme " .. colorscheme_params.colorscheme )

   colorscheme_params.post_function()
end

--- when we have selected the colorscheme we call pre and post callbacks, we
--- also display the colorscheme and save to file
local function save_colorscheme( colorscheme_params )
   colorscheme_params.pre_callback()

   display_colorscheme( colorscheme_params )

   -- TODO: add save to file

   colorscheme_params.post_callback()
end

-- [[ Windows ]]
-- NOTE: this section is inspired by the themery plugin :
--       https://github.com/zaldih/themery.nvim/

local function get_coords()
   local editor_columns = vim.api.nvim_get_option_value( "columns", {} )
   local editor_rows = vim.api.nvim_get_option_value( "lines", {} )
   local width = 40
   local height = 10

   local result = {
      width = width - 2,
      height = height - 2,
      col = (editor_columns / 2) - (width / 2),
      row = (editor_rows / 2) - (height / 2),
   }

   return result
end

local function close_win()
   if INTERFACE.win_id == nil then
      return
   end

   vim.api.nvim_win_close( INTERFACE.win_id, true )
   INTERFACE = {
      buf_id = nil,
      win_id = nil,
   }
end

local function setup_win_closing()
   vim.api.nvim_set_option_value( "bufhidden", "wipe", { buf = INTERFACE.buf_id } )

   vim.api.nvim_create_autocmd( { "WinLeave", "BufLeave" }, {
      group = vim.api.nvim_create_augroup( PLUGIN_NAME .. "-augroup", { clear = true } ),
      buffer = INTERFACE.buf_id,
      callback = function()
         close_win()
      end,
      once = true,
   } )

   vim.api.nvim_buf_set_keymap( INTERFACE.buf_id, "n", "<ESC>", "", {
      ft = PLUGIN_NAME,
      callback = function()
         vim.api.nvim_buf_del_keymap( INTERFACE.buf_id, "n", "<ESC>" )
         close_win()
      end,
   } )
end

local function toggle_win()
   if INTERFACE.win_id ~= nil then
      close_win()
      return
   end

   local coords = get_coords()

   -- TODO: feature to override thoses args
   local opts = {
      style = "minimal",
      relative = "editor",
      border = "single",
      width = coords.width,
      height = coords.height,
      row = coords.row,
      col = coords.col,
      title = " Color-Skimer ",
      title_pos = "center",
   }

   local buf_id = vim.api.nvim_create_buf( false, true )
   local win_id = vim.api.nvim_open_win( buf_id, true, opts )

   INTERFACE = {
      buf_id = buf_id,
      win_id = win_id,
   }

   setup_win_closing()

   vim.api.nvim_set_option_value( "filetype",   PLUGIN_NAME, { buf = INTERFACE.buf_id } )
   vim.api.nvim_set_option_value( "modifiable", false,       { buf = INTERFACE.buf_id } )
end


-- [[ USER INPUT ]]


local function setup( opts )
   local init_tables = get_init_tables( opts )

   -- display_colorscheme( init_tables[1] )
   -- save_colorscheme( init_tables[1] )

   vim.keymap.set( "n", "<leader>h", toggle_win )
end

return {
   setup = setup,
   color_skimer = toggle_win,
}
