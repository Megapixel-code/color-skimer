local constants = require( "color-skimer.constants" )
local utils = require( "color-skimer.utils" )

-- NOTE: this file is partly inspired by the themery plugin :
--       https://github.com/zaldih/themery.nvim/


--- Function to close the window, does nothing if no window is open
local function close_win()
   if constants.INTERFACE.win_id == nil then
      return
   end

   vim.api.nvim_win_close( constants.INTERFACE.win_id, true )
   constants.INTERFACE = {
      buf_id = nil,
      win_id = nil,
   }
end



--- Function that setup the options and autocmds of the menu window
local function setup_win_config()
   -- buf options
   vim.api.nvim_set_option_value( "filetype",   constants.PLUGIN_NAME, { buf = constants.INTERFACE.buf_id } )
   vim.api.nvim_set_option_value( "modifiable", false,                 { buf = constants.INTERFACE.buf_id } )

   -- win options
   vim.api.nvim_set_option_value( "cursorline", true, { win = constants.INTERFACE.win_id } )
   vim.api.nvim_set_option_value( "scrolloff",  4,    { win = constants.INTERFACE.win_id } )

   -- autocmds
   vim.api.nvim_create_autocmd( "CursorMoved", {
      group = vim.api.nvim_create_augroup( constants.PLUGIN_NAME .. "-WINCONFIG", { clear = true } ),
      buffer = constants.INTERFACE.buf_id,
      callback = function()
         utils.cursor_moved()
      end,
   } )

   if constants.COLORSCHEME_PARAMS.keys.save ~= "" then
      vim.api.nvim_buf_set_keymap( constants.INTERFACE.buf_id, "n", constants.COLORSCHEME_PARAMS.keys.save, "", {
         callback = function()
            local line = vim.api.nvim_win_get_cursor( constants.INTERFACE.win_id )[1]
            close_win()
            utils.save_colorscheme( line )
         end,
      } )
   end
   if constants.COLORSCHEME_PARAMS.keys.random ~= "" then
      vim.api.nvim_buf_set_keymap( constants.INTERFACE.buf_id, "n", constants.COLORSCHEME_PARAMS.keys.random, "", {
         callback = function()
            utils.random_move_cursor()
         end,
      } )
   end
end



--- Function that setup the future closing of the window and the buffer with autocmds/keymaps
local function setup_win_closing()
   vim.api.nvim_set_option_value( "bufhidden", "wipe", { buf = constants.INTERFACE.buf_id } )

   vim.api.nvim_create_autocmd( { "WinLeave", "BufLeave" }, {
      group = vim.api.nvim_create_augroup( constants.PLUGIN_NAME .. "-WINCLOSING", { clear = true } ),
      buffer = constants.INTERFACE.buf_id,
      callback = function()
         close_win()
         vim.schedule(
            utils.retrieve_last_colorscheme
         )
      end,
      once = true,
   } )

   if constants.COLORSCHEME_PARAMS.keys.escape ~= "" then
      vim.api.nvim_buf_set_keymap( constants.INTERFACE.buf_id, "n", constants.COLORSCHEME_PARAMS.keys.escape, "", {
         callback = function()
            vim.api.nvim_buf_del_keymap( constants.INTERFACE.buf_id, "n", constants.COLORSCHEME_PARAMS.keys.escape )
            close_win()
         end,
      } )
   end
end



--- Function that will open/close the menu window
local function toggle_win()
   if constants.INTERFACE.win_id ~= nil then
      close_win()
      return
   end
   if constants.COLORSCHEME_PARAMS[1] == nil then
      -- no params, shouldn't happen ?
      print( "ERROR: no options are available, setup() function has not been run" )
      print( "       if you are using lazy, please make sure you are using either 'config' OR 'opts' but not both" )
      return
   end

   local size = constants.COLORSCHEME_PARAMS.window_config.shape()
   local win_conf = constants.COLORSCHEME_PARAMS.window_config.config
   win_conf.width = size.width
   win_conf.height = size.height
   win_conf.row = size.row
   win_conf.col = size.col

   local buf_id = vim.api.nvim_create_buf( false, true )
   --- @diagnostic disable-next-line
   local win_id = vim.api.nvim_open_win( buf_id, true, win_conf )

   constants.INTERFACE = {
      buf_id = buf_id,
      win_id = win_id,
   }

   setup_win_closing()
   setup_win_config()

   utils.write_to_buf()

   -- place the cursor in the right starting position
   local row = utils.get_colorscheme_id_from_memory()
   vim.api.nvim_win_set_cursor( constants.INTERFACE.win_id,
                                {
                                   row,
                                   (constants.COLORSCHEME_PARAMS.window_config.shape().width / 2) - 1,
                                } )
end



return {
   toggle_win = toggle_win,
}
