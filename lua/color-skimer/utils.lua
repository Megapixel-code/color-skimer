local constants = require( "color-skimer.constants" )

local function get_data_dir()
   local data_home = os.getenv( "XDG_DATA_HOME" )
   if data_home == nil then
      data_home = os.getenv( "HOME" ) .. "/.local/share"
   end

   local file_dir = data_home .. "/nvim/" .. constants.PLUGIN_NAME

   return file_dir
end

--- this gets the colorscheme id with the colorscheme name
local function get_colorscheme_id_from_colorscheme( colorscheme )
   for id, colorscheme_param in ipairs( constants.COLORSCHEME_PARAMS ) do
      if colorscheme == colorscheme_param.colorscheme then
         return id
      end
   end

   return 0
end

local function get_colorscheme_id_from_memory()
   local file_path = get_data_dir() .. "/data"
   local file, err = io.open( file_path, "r" )

   if not file then
      print( "Could not retrieve the last colorscheme set, err :", err )
      return 1
   end

   -- only read the first line
   local colorscheme_id = file:read( "*l" )
   file:close()

   return tonumber( colorscheme_id )
end

--- this will preview the colorscheme, we execute pre and post functions to
--- make sure the colorscheme is displayed correcly.
local function display_colorscheme( colorscheme_param )
   -- TODO: add verify if we have not aleready displayed this theme
   --       by looking at the current theme
   colorscheme_param.pre_function()

   vim.cmd( "colorscheme " .. colorscheme_param.colorscheme )

   colorscheme_param.post_function()
end

--- when we have selected the colorscheme we call pre and post callbacks, we
--- also display the colorscheme and save to file
local function save_colorscheme( line )
   local colorscheme_param = constants.COLORSCHEME_PARAMS[line]

   colorscheme_param.pre_callback()

   display_colorscheme( colorscheme_param )

   -- saving the file
   local file_dir = get_data_dir()
   os.execute( "mkdir -p " .. file_dir )
   local file, err = io.open( file_dir .. "/data", "w" )

   if file then
      file:write( tostring( line ) )
      file:close()
   else
      print( "Could not save colorscheme to memory, err :", err )
   end

   colorscheme_param.post_callback()
end

local function retrieve_last_colorscheme()
   local id = get_colorscheme_id_from_memory()
   display_colorscheme( constants.COLORSCHEME_PARAMS[id] )
end

local function write_to_buf()
   local lines = {}

   for _, colorscheme_param in ipairs( constants.COLORSCHEME_PARAMS ) do
      vim.list_extend( lines, {
         colorscheme_param.name,
      } )
   end

   vim.api.nvim_win_set_cursor( constants.INTERFACE.win_id, { 1, 0 } )

   -- get sandwiched
   vim.api.nvim_set_option_value( "modifiable", true, { buf = constants.INTERFACE.buf_id } )
   vim.api.nvim_buf_set_lines( 0, 0, 1, false, lines )
   vim.api.nvim_set_option_value( "modifiable", false, { buf = constants.INTERFACE.buf_id } )
end

local function cursor_moved()
   local line = vim.api.nvim_win_get_cursor( constants.INTERFACE.win_id )[1]
   display_colorscheme( constants.COLORSCHEME_PARAMS[line] )
end

return {
   get_colorscheme_id_from_memory = get_colorscheme_id_from_memory,
   save_colorscheme = save_colorscheme,
   retrieve_last_colorscheme = retrieve_last_colorscheme,
   write_to_buf = write_to_buf,
   cursor_moved = cursor_moved,
   get_data_dir = get_data_dir,
}
