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
local Folder = require('src/graph/Folder');
local File = require('src/graph/File');
local ExtensionHandler = require('src/ExtensionHandler');
local Camera = require('src/Camera');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WARNING_MESSAGE = [[
To use LoFiVi you will have to place a folder structure you want to be visualised in the root folder of LoFiVi's save folder.

LoFiVi will now open the file directory in which to place the folder.
]];

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local camera;
    local nodes;
    local tree;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Creates a file tree based on a sequence containing
    -- paths to files and subfolders. Each folder is a folder
    -- node which has children folder nodes and files.
    -- @param paths
    --
    local function createFileTree(paths)
        local nodes = { Folder.new(nil, '', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5) };
        local tree = nodes[#nodes];

        -- Iterate over each file path and recursively create
        -- the tree structure for this path.
        for i = 1, #paths do
            local function recurse(path, target)
                local b, e, f = path:find('/', 1);

                if b and e then
                    local folder = path:sub(1, b - 1);
                    local nTarget = target:getChild(folder);

                    if not nTarget then
                        nodes[#nodes + 1] = Folder.new(target, folder, love.math.random(20, 780), love.math.random(20, 580));
                        nTarget = target:addChild(folder, nodes[#nodes]);
                    end
                    recurse(path:sub(b + 1), nTarget);
                else
                    local col = ExtensionHandler.add(path); -- Get a colour for this file.
                    target:addFile(path, File.new(path, col, target:getX() + love.math.random(-5, 5), target:getY() + love.math.random(-5, 5)));
                end
            end

            recurse(paths[i], tree);
        end

        return tree, nodes;
    end

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

    local function getBoundaries(nodes)
        local minX = nodes[1]:getX();
        local maxX = nodes[1]:getX();
        local minY = nodes[1]:getY();
        local maxY = nodes[1]:getY();

        for i = 2, #nodes do
            local nx, ny = nodes[i]:getX(), nodes[i]:getY();

            if not minX or nx < minX then
                minX = nx;
            elseif not maxX or nx > maxX then
                maxX = nx;
            end
            if not minY or ny < minY then
                minY = ny;
            elseif not maxY or ny > maxY then
                maxY = ny;
            end
        end

        return minX, maxX, minY, maxY;
    end

    local function getCenter(minX, maxX, minY, maxY)
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    local function setUpFolders()
        if not love.filesystem.isDirectory('root') or #love.filesystem.getDirectoryItems('root') == 0 then
            love.filesystem.createDirectory('root');
            love.window.showMessageBox('No content found.', WARNING_MESSAGE, 'warning', false);
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory() .. '/root');
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        camera = Camera.new();

        setUpFolders();

        local fileCatalogue = recursivelyGetDirectoryItems('root', '');
        tree, nodes = createFileTree(fileCatalogue);
    end

    function self:draw()
        ExtensionHandler.draw();
        camera:set();
        tree:draw();
        camera:unset();
    end

    function self:update(dt)
        tree:update(dt);

        local cx, cy = getCenter(getBoundaries(nodes));
        camera:track(cx, cy, 5, dt);
    end

    function self:keypressed(key)
        if key == 'r' then
            local fileCatalogue = recursivelyGetDirectoryItems('root', '');
            tree, nodes = createFileTree(fileCatalogue);
        end
    end

    return self;
end

return MainScreen;