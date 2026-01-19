PLUGIN_NAME = "color-skimer"
INTERFACE = {
   buf_id = nil,
   win_id = nil,
}
COLORSCHEME_PARAMS = {}

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

      name_override = {},

      pre_function = {
         ["*"] = function() end
      },
      post_function = {
         ["*"] = function() end
      },

      pre_callback = {
         ["*"] = function() end
      },
      post_callback = {
         ["*"] = function() end
      },
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
local function get_colorscheme_params(options_table)
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
   if options_table.name_override == nil then
      options_table.name_override = default.name_override
   end
   if options_table.pre_function == nil then
      options_table.pre_function = default.pre_function
   end
   if options_table.post_function == nil then
      options_table.post_function = default.post_function
   end
   if options_table.pre_callback == nil then
      options_table.pre_callback = default.pre_callback
   end
   if options_table.post_callback == nil then
      options_table.post_callback = default.post_callback
   end


   for _, colorscheme in ipairs(options_table.colorscheme) do
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
         pre_function = default.pre_function["*"]
      end

      if options_table.post_function[colorscheme] ~= nil then
         post_function = options_table.post_function[colorscheme]
      elseif options_table.post_function["*"] ~= nil then
         post_function = options_table.post_function["*"]
      else
         post_function = default.post_function["*"]
      end

      if options_table.pre_callback[colorscheme] ~= nil then
         pre_callback = options_table.pre_callback[colorscheme]
      elseif options_table.pre_callback["*"] ~= nil then
         pre_callback = options_table.pre_callback["*"]
      else
         pre_callback = default.pre_callback["*"]
      end

      if options_table.post_callback[colorscheme] ~= nil then
         post_callback = options_table.post_callback[colorscheme]
      elseif options_table.post_callback["*"] ~= nil then
         post_callback = options_table.post_callback["*"]
      else
         post_callback = default.post_callback["*"]
      end

      vim.list_extend(result, {
         {
            colorscheme = colorscheme,
            name = name,
            pre_function = pre_function,
            post_function = post_function,
            pre_callback = pre_callback,
            post_callback = post_callback,
         },
      })
   end
   return result
end

-- [[ UTILS ]]

local function get_data_dir()
   local data_home = os.getenv("XDG_DATA_HOME")
   if data_home == nil then
      data_home = os.getenv("HOME") .. "/.local/share"
   end

   local file_dir = data_home .. "/nvim/" .. PLUGIN_NAME

   return file_dir
end

--- this gets the colorscheme id with the colorscheme name
local function get_colorscheme_id_from_colorscheme(colorscheme)
   for id, colorscheme_param in ipairs(COLORSCHEME_PARAMS) do
      if colorscheme == colorscheme_param.colorscheme then
         return id
      end
   end

   return 0
end

local function get_colorscheme_id_from_memory()
   local file_path = get_data_dir() .. "/data"
   local file, err = io.open(file_path, "r")

   if not file then
      print("Could not retrieve the last colorscheme set, err :", err)
      return
   end

   -- only read the first line
   local colorscheme_id = file:read("*l")
   file:close()

   return tonumber(colorscheme_id)
end

--- this will preview the colorscheme, we execute pre and post functions to
--- make sure the colorscheme is displayed correcly.
local function display_colorscheme(colorscheme_param)
   -- TODO: add verify if we have not aleready displayed this theme
   --       by looking at the current theme

   colorscheme_param.pre_function()

   vim.cmd("colorscheme " .. colorscheme_param.colorscheme)

   colorscheme_param.post_function()
end

--- when we have selected the colorscheme we call pre and post callbacks, we
--- also display the colorscheme and save to file
local function save_colorscheme(colorscheme_params)
   colorscheme_params.pre_callback()

   display_colorscheme(colorscheme_params)

   colorscheme_params.post_callback()

   -- saving the file
   local file_dir = get_data_dir()
   os.execute("mkdir -p " .. file_dir)
   local file, err = io.open(file_dir .. "/data", "w")

   if file then
      local plugin_number = get_colorscheme_id_from_colorscheme(colorscheme_params.colorscheme)
      file:write(tostring(plugin_number))
      file:close()
   else
      print("Could not save colorscheme to memory, err :", err)
   end
end

local function retrieve_last_colorscheme()
   local id = get_colorscheme_id_from_memory()
   display_colorscheme(COLORSCHEME_PARAMS[id])
end

local function write_to_buf()
   local lines = {}

   for _, colorscheme_param in ipairs(COLORSCHEME_PARAMS) do
      vim.list_extend(lines, {
         colorscheme_param.name
      })
   end

   vim.api.nvim_win_set_cursor(INTERFACE.win_id, { 1, 0 })

   -- get sandwiched
   vim.api.nvim_set_option_value("modifiable", true, { buf = INTERFACE.buf_id })
   vim.api.nvim_buf_set_lines(0, 0, 1, false, lines)
   vim.api.nvim_set_option_value("modifiable", false, { buf = INTERFACE.buf_id })
end

local function cursor_moved(interface)
   local line = vim.api.nvim_win_get_cursor(interface.win_id)[1]
   display_colorscheme(COLORSCHEME_PARAMS[line])
end


-- [[ Windows ]]
-- NOTE: this section is inspired by the themery plugin :
--       https://github.com/zaldih/themery.nvim/

local function get_coords()
   local editor_columns = vim.api.nvim_get_option_value("columns", {})
   local editor_rows = vim.api.nvim_get_option_value("lines", {})
   local width = 40
   local height = 15

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

   vim.api.nvim_win_close(INTERFACE.win_id, true)
   INTERFACE = {
      buf_id = nil,
      win_id = nil,
   }
end

local function setup_win_config()
   -- buf options
   vim.api.nvim_set_option_value("filetype", PLUGIN_NAME, { buf = INTERFACE.buf_id })
   vim.api.nvim_set_option_value("modifiable", false, { buf = INTERFACE.buf_id })

   -- win options
   vim.api.nvim_set_option_value("cursorline", true, { win = INTERFACE.win_id })
   vim.api.nvim_set_option_value("scrolloff", 4, { win = INTERFACE.win_id })

   -- autocmds
   vim.api.nvim_create_autocmd("CursorMoved", {
      group = vim.api.nvim_create_augroup(PLUGIN_NAME .. "-WINCONFIG", { clear = true }),
      buffer = INTERFACE.buf_id,
      callback = function()
         cursor_moved(INTERFACE)
      end
   })

   -- TODO: make it configurable (<CR>)
   vim.api.nvim_buf_set_keymap(INTERFACE.buf_id, "n", "<CR>", "", {
      callback = function()
         local line = vim.api.nvim_win_get_cursor(INTERFACE.win_id)[1]
         save_colorscheme(COLORSCHEME_PARAMS[line])
         close_win()
      end
   })
end


local function setup_win_closing()
   vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = INTERFACE.buf_id })

   vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      group = vim.api.nvim_create_augroup(PLUGIN_NAME .. "-WINCLOSING", { clear = true }),
      buffer = INTERFACE.buf_id,
      callback = function()
         close_win()
         retrieve_last_colorscheme()
      end,
      once = true,
   })

   vim.api.nvim_buf_set_keymap(INTERFACE.buf_id, "n", "<ESC>", "", {
      callback = function()
         vim.api.nvim_buf_del_keymap(INTERFACE.buf_id, "n", "<ESC>")
         close_win()
      end,
   })
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

   local buf_id = vim.api.nvim_create_buf(false, true)
   local win_id = vim.api.nvim_open_win(buf_id, true, opts)

   INTERFACE = {
      buf_id = buf_id,
      win_id = win_id,
   }

   setup_win_closing()
   setup_win_config()

   write_to_buf()

   -- place the cursor in the right starting position
   local row = get_colorscheme_id_from_memory()
   if row == 0 then
      row = 1
   end

   local size = 0
   for _, _ in ipairs(COLORSCHEME_PARAMS) do size = size + 1 end

   if row > size then
      row = 1
   end

   print(row)
   vim.api.nvim_win_set_cursor(INTERFACE.win_id, { row, 0 })
end


-- [[ USER INPUT ]]


local function setup(opts)
   COLORSCHEME_PARAMS = get_colorscheme_params(opts)

   -- display_colorscheme( SETTINGS[1] )
   -- save_colorscheme( SETTINGS[1] )

   vim.keymap.set("n", "<leader>h", toggle_win)
end

-- setup({})

return {
   setup = setup,
   color_skimer = toggle_win,
}
