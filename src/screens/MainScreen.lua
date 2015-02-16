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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local tree;

    ---
    -- Creates a file tree based on a sequence containing
    -- paths to files and subfolders. Each folder is a folder
    -- node which has children folder nodes and files.
    -- @param paths
    --
    local function createFileTree(paths)
        local tree = Folder.new(nil, '', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5);

        -- Iterate over each file path and recursively create
        -- the tree structure for this path.
        for i = 1, #paths do
            local function recurse(path, target)
                local b, e, f = path:find('/', 1);

                if b and e then
                    local folder = path:sub(1, b - 1);
                    local target = target:getChild(folder) or target:addChild(folder, Folder.new(target, folder, love.math.random(20, 780), love.math.random(20, 580)));
                    recurse(path:sub(b + 1), target);
                else
                    target:addFile(path, File.new(path, target:getX() + love.math.random(-5, 5), target:getY() + love.math.random(-5, 5)));
                end
            end

            recurse(paths[i], tree);
        end

        return tree;
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

    function self:init()
        local fileCatalogue = recursivelyGetDirectoryItems('root', '');

        tree = createFileTree(fileCatalogue);
    end

    function self:draw()
        tree:draw();
    end

    function self:update(dt)
        tree:update(dt);
    end

    return self;
end

return MainScreen;