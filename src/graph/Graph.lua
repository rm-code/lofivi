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

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Creates a file tree based on a sequence containing
    -- paths to files and subfolders. Each folder is a folder
    -- node which has children folder nodes and files.
    -- @param paths
    --
    local function createGraph(paths)
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
    -- Attracts nodeA towards nodeB based on a spring force.
    -- @param nodeA
    -- @param nodeB
    -- @param spring
    --
    local function attract(nodeA, nodeB, spring)
        local dx, dy = nodeA:getX() - nodeB:getX(), nodeA:getY() - nodeB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 100));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate spring force and apply it.
        local force = spring * distance;
        nodeA:applyForce(dx * force, dy * force);
    end

    ---
    -- Repels nodeA from nodeB.
    -- @param fileA
    -- @param fileB
    -- @param charge
    --
    local function repel(fileA, fileB, charge)
        -- Calculate distance vector.
        local dx, dy = fileA:getX() - fileB:getX(), fileA:getY() - fileB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 1000));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate force's strength and apply it to the vector.
        local strength = charge * ((fileA:getMass() * fileB:getMass()) / (distance * distance));
        dx = dx * strength;
        dy = dy * strength;

        fileA:applyForce(dx, dy);
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(paths)
        tree, nodes = createGraph(paths);
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
                        attract(nodeA, nodeB, -0.001);
                    end
                    repel(nodeA, nodeB, 1000000);
                end
            end

            nodeA:damp(0.95);
            nodeA:update(dt);
        end
    end

    function self:getBoundaries(nodes)
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

    function self:getCenter()
        local minX, maxX, minY, maxY;
        if nodes then
            minX, maxX, minY, maxY = self:getBoundaries(nodes);
        else
            minX, maxX, minY, maxY = 0, 0, 0, 0;
        end
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    return self;
end

return Graph;