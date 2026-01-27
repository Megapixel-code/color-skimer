local constants = require( "color-skimer.constants" )

--- Returns the directory path of the plugin
--- @return string file_path directory path of the plugin
local function get_data_dir()
   local data_home = vim.fn.stdpath( "data" )
   if data_home == nil then
      data_home = os.getenv( "HOME" ) .. "/.local/share/nvim"
   end

   local file_dir = data_home .. "/" .. constants.PLUGIN_NAME

   return file_dir
end

--- Returns the colorscheme id from the file in memory or 1 if file is empty
--- @return integer colorscheme_id last colorscheme set or 1 if file is empty
local function get_colorscheme_id_from_memory()
   local file_path = get_data_dir() .. "/data"
   local file, err = io.open( file_path, "r" )

   if not file then
      print( "ERROR: Could not open file \"" .. file_path .. "\", err : " .. err )
      return 1
   end

   -- only read the first line
   local colorscheme_id = file:read( "*l" )
   file:close()

   return tonumber( colorscheme_id ) or 1
end

--- This function will preview the colorscheme, we execute pre and post functions to
--- make sure the colorscheme is displayed correcly.
--- @param colorscheme_param colorscheme_param table with the params of the colorscheme to display
local function display_colorscheme( colorscheme_param )
   colorscheme_param.pre_preview()

   vim.cmd( "colorscheme " .. colorscheme_param.colorscheme )

   colorscheme_param.post_preview()
end

--- When we have selected the colorscheme we call pre and post callbacks, we
--- also display the colorscheme and save to file
--- @param colorscheme_id integer id of the colorscheme to save and display
local function save_colorscheme( colorscheme_id )
   --- @type colorscheme_param
   local colorscheme_param = constants.COLORSCHEME_PARAMS[colorscheme_id]

   colorscheme_param.pre_save()

   display_colorscheme( colorscheme_param )

   -- saving the file
   local file_dir = get_data_dir()
   os.execute( "mkdir -p " .. file_dir )
   local file, err = io.open( file_dir .. "/data", "w" )

   if file then
      file:write( tostring( colorscheme_id ) )
      file:close()
   else
      print( "ERROR: Could not save colorscheme to memory, err : ", err )
   end

   colorscheme_param.post_save()
end

--- Reads the last colorscheme set from memory and displays it
local function retrieve_last_colorscheme()
   local id = get_colorscheme_id_from_memory()

   local params_len = 0
   for _ in pairs( constants.COLORSCHEME_PARAMS ) do params_len = params_len + 1 end
   if (id > params_len) then
      id = 1
   end

   display_colorscheme( constants.COLORSCHEME_PARAMS[id] )
end

--- Write the content inside the menu buffer and setup the buffer
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

--- This function is called every time the cursor moved, we update the displayed colorscheme.
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
