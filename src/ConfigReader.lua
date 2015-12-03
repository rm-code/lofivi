local ConfigReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'config.lua';
local FILE_TEMPLATE = [[
-- ------------------------------- --
-- LoFiVi - Configuration File.    --
-- ------------------------------- --

return {
    options = {
        bgColor = { 0, 0, 0 },
        showLabels = false,
        showFileList = true,

        fullscreen = true,      -- Toggle fullscreen
        fsType = 'desktop',     -- FullscreenMode ('normal' or 'desktop')
        screenW = 0,
        screenH = 0,

        showLogo = true,
        logo = 'logo.png',      -- A custom logo to load.
        logoPosX = 10,          -- The logo's screen-position.
        logoPosY = 10,
        logoScaleX = 1,         -- The logo's scale.
        logoScaleY = 1,

        nodeSpeed = 128,        -- Defines the speed for moving nodes around
    },

    -- See https://love2d.org/wiki/KeyConstant for a list of possible keycodes.
    keyBindings = {
        camera_n =         'w', -- Move camera up
        camera_w =         'a', -- Move camera left
        camera_s =         's', -- Move camera down
        camera_e =         'd', -- Move camera right
        camera_rotateL =   'q', -- Rotate camera left
        camera_rotateR =   'e', -- Rotate camera right
        camera_zoomIn =    '+', -- Zoom in
        camera_zoomOut =   '-', -- Zoom out
        graph_reset =      'r', -- Reloads the whole graph
        take_screenshot =  ' ', -- Take a screenshot
        toggleLabels =     '1', -- Hide / Show labels
        toggleFileList =   '2', -- Hide / Show file list
        toggleLogo =       '3', -- Hide / Show logo
        toggleFullscreen = 'f', -- Toggle fullscreen
        exit =             'escape', -- Exit
    },

    -- Can be used to assign a specific color to a file extension (RGB or RGBA).
    fileColors = {
        -- ['.example'] = { 255, 0, 0, 255 },
    },

    -- You can use lua patterns or simple string matching to ignore
    -- certain files and folders when creating a graph.
    ignore = {
        '^.*%/%.',          -- Ignore files and folders that start with a fullstop.
    },
};
]]

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local config;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function loadFile(name, default)
    if not love.filesystem.isFile(name) then
        local file = love.filesystem.newFile(name);
        file:open('w');
        file:write(default);
        file:close();
    end
    return love.filesystem.load(name)();
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function ConfigReader.init()
    config = loadFile(FILE_NAME, FILE_TEMPLATE);
    return config;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function ConfigReader.getConfig(section)
    return config[section];
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ConfigReader;
