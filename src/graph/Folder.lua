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

local Folder = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FORCE_MAX = 4;

local LABEL_FONT = love.graphics.newFont(25);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Folder.new(spriteBatch, parent, name, x, y)
    local self = {};

    local files = {};
    local fileCount = 0;
    local children = {};
    local childCount = 0;

    local speed = 64;
    local px, py = x, y; -- Position.
    local vx, vy = 0, 0; -- Velocity.
    local ax, ay = 0, 0; -- Acceleration.

    local radius = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Clamps a value to a certain range.
    -- @param min
    -- @param val
    -- @param max
    --
    local function clamp(min, val, max)
        return math.max(min, math.min(val, max));
    end

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
        return layers[layer].radius;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw(showLabels)
        love.graphics.circle('fill', px, py, 2, 10);

        if showLabels then
            love.graphics.setFont(LABEL_FONT);
            love.graphics.setColor(255, 255, 255, 105);
            love.graphics.print(name, px + 10 + radius, py + 10);
            love.graphics.setColor(255, 255, 255, 255);
            love.graphics.setFont(DEFAULT_FONT);
        end

        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 55);
            love.graphics.line(px, py, node:getX(), node:getY());
            love.graphics.setColor(255, 255, 255, 255);
            node:draw(showLabels);
        end
    end

    function self:update(dt)
        for _, file in pairs(files) do
            spriteBatch:setColor(file:getColor());
            spriteBatch:add(px + file:getOffsetX(), py + file:getOffsetY(), 0, 1, 1, 10,10);
        end
    end

    function self:addFile(name, file)
        files[name] = file;
        fileCount = fileCount + 1;
        radius = plotCircle(files, fileCount);
    end

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    ---
    -- Add a damping factor.
    -- @param f
    --
    function self:damp(f)
        vx, vy = vx * f, vy * f;
    end

    ---
    -- Attracts the node towards nodeB based on a spring force.
    -- @param nodeB
    -- @param spring
    --
    function self:attract(nodeB, spring)
        local dx, dy = self:getX() - nodeB:getX(), self:getY() - nodeB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate spring force and apply it.
        local force = spring * distance;
        self:applyForce(dx * force, dy * force);
    end

    ---
    -- Repels the node from nodeB.
    -- @param fileB
    -- @param charge
    --
    function self:repel(fileB, charge)
        -- Calculate distance vector.
        local dx, dy = self:getX() - fileB:getX(), self:getY() - fileB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate force's strength and apply it to the vector.
        local strength = charge * ((self:getMass() * fileB:getMass()) / (distance * distance));
        dx = dx * strength;
        dy = dy * strength;

        self:applyForce(dx, dy);
    end

    ---
    -- @param fx
    -- @param fy
    --
    function self:applyForce(fx, fy)
        ax = clamp(-FORCE_MAX, ax + fx, FORCE_MAX);
        ay = clamp(-FORCE_MAX, ay + fy, FORCE_MAX);
    end

    ---
    -- Apply the calculated acceleration to the node.
    --
    function self:move(dt)
        vx = vx + ax * dt * speed;
        vy = vy + ay * dt * speed;
        px = px + vx;
        py = py + vy;
        ax, ay = 0, 0; -- Reset acceleration for the next update cycle.
        return px, py;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getX()
        return px;
    end

    function self:getY()
        return py;
    end

    function self:getChild(name)
        return children[name];
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
