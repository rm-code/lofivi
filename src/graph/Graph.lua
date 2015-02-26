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

local Folder = require('src/graph/Folder');
local File = require('src/graph/File');
local ExtensionHandler = require('src/ExtensionHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new()
    local self = {};

    local tree;
    local nodes;
    local minX, maxX, minY, maxY;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function updateBoundaries(minX, maxX, minY, maxY, nx, ny)
        if nx < minX then
            minX = nx;
        elseif nx > maxX then
            maxX = nx;
        end
        if ny < minY then
            minY = ny;
        elseif ny > maxY then
            maxY = ny;
        end
        return minX, maxX, minY, maxY;
    end

    ---
    -- Creates a file tree based on a sequence containing
    -- paths to files and subfolders. Each folder is a folder
    -- node which has children folder nodes and files.
    -- @param paths
    --
    local function createGraph(paths)
        local nodes = { Folder.new(nil, 'root', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5) };
        local tree = nodes[#nodes];

        for i = 1, #paths do
            local target;

            -- Split the path using pattern matching.
            local splitPath = {};
            for part in paths[i]:gmatch('[^/]+') do
                splitPath[#splitPath + 1] = part;
            end

            -- Iterate over the split parts and create folders and files.
            for i = 1, #splitPath do
                local name = splitPath[i];
                if name == 'root' then
                    target = nodes[1];
                elseif i == #splitPath then
                    local col = ExtensionHandler.add(name); -- Get a colour for this file.
                    target:addFile(name, File.new(name, col));
                else
                    -- Get the next folder as a target. If that folder doesn't exist in our graph yet, create it first.
                    local nt = target:getChild(name);
                    if not nt then
                        -- Calculate random offset at which to place the new folder node.
                        local ox = love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1);
                        local oy = love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1);

                        nodes[#nodes + 1] = Folder.new(target, name, target:getX() + ox, target:getY() + oy);
                        target = target:addChild(name, nodes[#nodes]);
                    else
                        target = nt;
                    end
                end
            end
        end

        return tree, nodes;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(paths)
        tree, nodes = createGraph(paths);
        minX, minY, maxX, maxY = tree:getX(), tree:getX(), tree:getY(), tree:getY();
    end

    function self:draw()
        tree:draw();
    end

    function self:update(dt)
        for i = 1, #nodes do
            local nodeA = nodes[i];
            for j = 1, #nodes do
                local nodeB = nodes[j];
                if nodeA ~= nodeB then
                    if nodeA:isConnectedTo(nodeB) then
                        nodeA:attract(nodeB, -0.001);
                    end
                    nodeA:repel(nodeB, 1000000);
                end
            end

            nodeA:damp(0.95);
            nodeA:update(dt);
            local nx, ny = nodeA:move(dt);
            minX, maxX, minY, maxY = updateBoundaries(minX, maxX, minY, maxY, nx, ny);
        end
    end

    function self:getCenter()
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    return self;
end

return Graph;