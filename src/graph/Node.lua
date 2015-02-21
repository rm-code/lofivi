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

local Node = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FORCE_MAX = 4;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Node.new(name, x, y)
    local self = {};

    local speed = 16;
    local px, py = x, y; -- Position.
    local vx, vy = 0, 0; -- Velocity.
    local ax, ay = 0, 0; -- Acceleration.

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

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:update(dt)
        return;
    end

    function self:draw()
        return;
    end

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

    function self:getName()
        return name;
    end

    return self;
end

return Node;