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

local Screen = require('lib/screenmanager/Screen');
local ExtensionHandler = require('src/ExtensionHandler');
local Graph = require('src/graph/Graph');
local Camera = require('src/Camera');
local ConfigReader = require('src/ConfigReader');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WARNING_MESSAGE = [[
To use LoFiVi you will have to place the folder structure you want to be visualised in the root folder of LoFiVi's save folder.

After you have placed it there you can use the R-Key to regenerate the graph.

LoFiVi will now open the file directory in which to place the folder.
]];

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local camera;
    local config;
    local graph;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Recursively iterates over the target directory and returns the
    -- full path of all files and folders (including those in subfolders)
    -- as a sequence.
    -- @param dir
    --
    local function recursivelyGetDirectoryItems(dir)
        local catalogue = {};

        local function recurse(dir)
            local items = love.filesystem.getDirectoryItems(dir);
            for _, item in ipairs(items) do
                local file = dir .. "/" .. item;
                if love.filesystem.isDirectory(file) then
                    recurse(file);
                elseif love.filesystem.isFile(file) then
                    catalogue[#catalogue + 1] = file;
                end
            end
        end

        -- Start recursion.
        recurse(dir);

        return catalogue;
    end

    local function setUpFolders()
        if not love.filesystem.isDirectory('root') or #love.filesystem.getDirectoryItems('root') == 0 then
            love.filesystem.createDirectory('root');
            love.window.showMessageBox('No content found.', WARNING_MESSAGE, 'warning', false);
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory() .. '/root');
        end
    end

    local function ignoreFiles(paths, ignoreList)
        local newList = {};
        for _, path in ipairs(paths) do

            -- Check if one of the patterns matches the path.
            local ignore = false;
            for _, pattern in ipairs(ignoreList) do
                if path:match(pattern) then
                    ignore = true;
                    print('Ignore path: ' .. path);
                end
            end

            -- Included the path into the new list if none of the patterns matched.
            if not ignore then
                newList[#newList + 1] = path;
            end
        end
        return newList;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        config = ConfigReader.init();
        love.graphics.setBackgroundColor(config.options.bgColor);

        camera = Camera.new();

        setUpFolders();

        local fileCatalogue = recursivelyGetDirectoryItems('root', '');
        fileCatalogue = ignoreFiles(fileCatalogue, config.ignore);

        graph = Graph.new();
        graph:init(fileCatalogue);
    end

    function self:draw()
        ExtensionHandler.draw();
        camera:set();
        graph:draw();
        camera:unset();
    end

    function self:update(dt)
        graph:update(dt);

        local cx, cy = graph:getCenter();
        camera:track(cx, cy, 5, dt);
    end

    function self:keypressed(key)
        if key == 'r' then
            ExtensionHandler.reset();
            local fileCatalogue = recursivelyGetDirectoryItems('root', '');
            graph:init(fileCatalogue);
        end
    end

    return self;
end

return MainScreen;