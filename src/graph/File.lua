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

local File = {};

function File.new(name, color, x, y)
    local self = {};

    local px, py = x, y;
    local vx, vy = 0, 0;
    local ax, ay = 0, 0;

    ---
    -- Apply the calculated acceleration to the node.
    --
    local function move(dt)
        vx = vx + ax;
        vy = vy + ay;

        px = px + vx;
        py = py + vy;

        ax, ay = 0, 0;
    end

    function self:draw()
        love.graphics.setColor(color);
        love.graphics.circle('line', px, py, 5, 20);
        love.graphics.setColor(255, 255, 255, 255);
    end

    function self:update(dt)
        move(dt);
    end

    function self:damp(f)
        vx, vy = vx * f, vy * f;
    end

    function self:applyForce(fx, fy)
        ax, ay = ax + fx, ay + fy;
    end

    function self:getX()
        return px;
    end

    function self:getY()
        return py;
    end

    function self:getMass()
        return 0.01;
    end

    return self;
end

return File;