--==================================================================================================
-- Copyright (C) 2015 by Robert Machmer                                                            =
--                                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy                    =
-- of this software and associated documentation files (the "Software"), to deal                   =
-- in the Software without restriction, including without limitation the rights                    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                       =
-- copies of the Software, and to permit persons to whom the Software is                           =
-- furnished to do so, subject to the following conditions:                                        =
--                                                                                                 =
-- The above copyright notice and this permission notice shall be included in                      =
-- all copies or substantial portions of the Software.                                             =
--                                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                       =
-- THE SOFTWARE.                                                                                   =
--==================================================================================================

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
        fullscreen = true,         -- Toggle fullscreen
        fsType = 'desktop',        -- FullscreenMode ('normal' or 'desktop')
        screenW = 0,
        screenH = 0,

        -- See https://love2d.org/wiki/KeyConstant for a list of possible keycodes.
        keyBindings = {
            camera_n =        'w', -- Move camera up
            camera_w =        'a', -- Move camera left
            camera_s =        's', -- Move camera down
            camera_e =        'd', -- Move camera right
            camera_rotateL =  'q', -- Rotate camera left
            camera_rotateR =  'e', -- Rotate camera right
            camera_zoomIn =   '+', -- Zoom in
            camera_zoomOut =  '-', -- Zoom out
            graph_reset =     'r', -- Reloads the whole graph
            take_screenshot = ' ', -- Take a screenshot
            toggleLabels =    '1', -- Hide / Show labels
            toggleFileList =  '2', -- Hide / Show file list
            toggleFullscreen = 'f', -- Toggle fullscreen
        },
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