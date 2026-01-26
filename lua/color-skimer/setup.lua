local constants = require( "color-skimer.constants" )
local utils = require( "color-skimer.utils" )

--- Function that setup the tables to be read by the rest of the program
--- @param config color_skimer_config user config
--- @return COLORSCHEME_PARAMS return table that can be read by the program
local function get_colorscheme_params( config )
   local default = constants.DEFAULT_CONFIG

   local result = {}

   local name
   local pre_function
   local post_function
   local pre_callback
   local post_callback

   for key, _ in ipairs( default ) do
      if config[key] == nil then
         config[key] = default[key]
      end
   end

   for _, colorscheme in ipairs( config.colorscheme ) do
      if config.name_override[colorscheme] ~= nil then
         name = config.name_override[colorscheme]
      else
         name = colorscheme
      end

      if config.pre_function[colorscheme] ~= nil then
         pre_function = config.pre_function[colorscheme]
      elseif config.pre_function["*"] ~= nil then
         pre_function = config.pre_function["*"]
      else
         pre_function = default.pre_function["*"]
      end

      if config.post_function[colorscheme] ~= nil then
         post_function = config.post_function[colorscheme]
      elseif config.post_function["*"] ~= nil then
         post_function = config.post_function["*"]
      else
         post_function = default.post_function["*"]
      end

      if config.pre_callback[colorscheme] ~= nil then
         pre_callback = config.pre_callback[colorscheme]
      elseif config.pre_callback["*"] ~= nil then
         pre_callback = config.pre_callback["*"]
      else
         pre_callback = default.pre_callback["*"]
      end

      if config.post_callback[colorscheme] ~= nil then
         post_callback = config.post_callback[colorscheme]
      elseif config.post_callback["*"] ~= nil then
         post_callback = config.post_callback["*"]
      else
         post_callback = default.post_callback["*"]
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

--- Will create data file if the file doesnt aleready exist
local function create_data_file()
   local file_path = utils.get_data_dir() .. "/data"
   local file = io.open( file_path, "r" )

   if not file then
      utils.save_colorscheme( 1 )
   else
      file:close()
   end
end

--- Initialize the plugin with the user config
--- @param config color_skimer_config user config
local function setup( config )
   config = config or {}

   constants.COLORSCHEME_PARAMS = get_colorscheme_params( config )

   create_data_file()

   utils.retrieve_last_colorscheme()
end

return {
   setup = setup,
}
