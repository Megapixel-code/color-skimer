local constants = require( "color-skimer.constants" )
local utils = require( "color-skimer.utils" )

--- Function that setup the tables to be read by the rest of the program
--- @param config color_skimer_config user config
--- @return COLORSCHEME_PARAMS return table that can be read by the program
local function get_colorscheme_params( config )
   local default = constants.DEFAULT_CONFIG

   local result = {}

   local name
   local pre_preview
   local post_preview
   local pre_save
   local post_save

   for key, _ in pairs( default ) do
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

      if config.pre_preview[colorscheme] ~= nil then
         pre_preview = config.pre_preview[colorscheme]
      elseif config.pre_preview["*"] ~= nil then
         pre_preview = config.pre_preview["*"]
      else
         pre_preview = default.pre_preview["*"]
      end

      if config.post_preview[colorscheme] ~= nil then
         post_preview = config.post_preview[colorscheme]
      elseif config.post_preview["*"] ~= nil then
         post_preview = config.post_preview["*"]
      else
         post_preview = default.post_preview["*"]
      end

      if config.pre_save[colorscheme] ~= nil then
         pre_save = config.pre_save[colorscheme]
      elseif config.pre_save["*"] ~= nil then
         pre_save = config.pre_save["*"]
      else
         pre_save = default.pre_save["*"]
      end

      if config.post_save[colorscheme] ~= nil then
         post_save = config.post_save[colorscheme]
      elseif config.post_save["*"] ~= nil then
         post_save = config.post_save["*"]
      else
         post_save = default.post_save["*"]
      end

      vim.list_extend( result, {
         {
            colorscheme = colorscheme,
            name = name,
            pre_preview = pre_preview,
            post_preview = post_preview,
            pre_save = pre_save,
            post_save = post_save,
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
