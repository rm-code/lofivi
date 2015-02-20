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

local Node = require('src/graph/Node');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Folder = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Folder.new(parent, name, x, y)
    local self = Node.new(name, x, y);

    local files = {};
    local fileCount = 0;
    local children = {};
    local childCount = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Calculates the arc for a certain angle.
    -- @param radius
    -- @param angle
    --
    local function calcArc(radius, angle)
        return math.pi * radius * (angle / 180);
    end

    ---
    -- Calculates how many layers we need and how many files
    -- can be placed on each layer. This basically generates a
    -- blueprint of how the files need to be arranged.
    --
    local function createOnionLayers(count)
        local MIN_ARC_SIZE = 15;

        local fileCounter = 0;
        local radius = -15; -- Radius of the circle around the node.
        local layers = {
            { radius = radius, amount = fileCounter }
        };

        for i = 1, count do
            fileCounter = fileCounter + 1;

            -- Calculate the arc between the file nodes on the current layer.
            -- The more files are on it the smaller it gets.
            local arc = calcArc(layers[#layers].radius, 360 / fileCounter);

            -- If the arc is smaller than the allowed minimum we store the radius
            -- of the current layer and the number of nodes that can be placed
            -- on that layer and move to the next layer.
            if arc < MIN_ARC_SIZE then
                radius = radius + 15;

                -- Create a new layer.
                layers[#layers + 1] = { radius = radius, amount = 1 };
                fileCounter = 1;
            else
                layers[#layers].amount = fileCounter;
            end
        end

        return layers;
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    -- @param files
    --
    local function plotCircle(files, count)
        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers = createOnionLayers(count);

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local fileCounter = 0;
        local layer = 1;
        for _, file in pairs(files) do
            fileCounter = fileCounter + 1;

            -- If we have more files on the current layer than allowed, we "move"
            -- the file to the next layer (this is why we reset the counter to one
            -- instead of zero).
            if fileCounter > layers[layer].amount then
                layer = layer + 1;
                fileCounter = 1;
            end

            -- Calculate the new position of the file on its layer around the folder node.
            local angle = 360 / layers[layer].amount;
            local x = (layers[layer].radius * math.cos((angle * (fileCounter - 1)) * (math.pi / 180)));
            local y = (layers[layer].radius * math.sin((angle * (fileCounter - 1)) * (math.pi / 180)));
            file:setOffset(x, y);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw()
        love.graphics.circle('fill', self:getX(), self:getY(), 2, 10);
        love.graphics.setColor(255, 255, 255, 35);
        love.graphics.print(name, self:getX() + 5, self:getY() + 5);
        love.graphics.setColor(255, 255, 255, 255);
        for _, file in pairs(files) do
            file:draw();
        end
        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 55);
            love.graphics.line(self:getX(), self:getY(), node:getX(), node:getY());
            love.graphics.setColor(255, 255, 255, 255);
            node:draw();
        end
    end

    function self:update(dt)
        for _, file in pairs(files) do
            file:setParentPosition(self:getX(), self:getY());
        end
    end

    function self:addFile(name, file)
        files[name] = file;
        fileCount = fileCount + 1;
        plotCircle(files, fileCount);
    end

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getChild(name)
        return children[name];
    end

    function self:getChildren()
        return children;
    end

    function self:isConnectedTo(node)
        if parent == node then
            return true;
        end
        for _, v in pairs(children) do
            if node == v then
                return true;
            end
        end
    end

    function self:getMass()
        return 0.01 * childCount + 0.001 * math.max(1, fileCount);
    end

    return self;
end

return Folder;
