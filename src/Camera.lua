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

local Camera = {};

function Camera.new()
    local self = {};

    local px, py = 0, 0;
    local scale = 1;
    local angle = 0;

    function self:set()
        love.graphics.push();
        local width = love.graphics.getWidth();
        local height = love.graphics.getHeight();

        love.graphics.scale(scale, scale);
        love.graphics.translate(-px, -py);
        love.graphics.translate(width / (2 * scale), height / (2 * scale));

        love.graphics.translate(width / 2, height / 2);
        love.graphics.rotate(angle);
        love.graphics.translate(-width / 2, -height / 2);
    end

    function self:unset()
        love.graphics.pop();
    end

    function self:track(tarX, tarY, speed, dt)
        px = px - (px - math.floor(tarX)) * dt * speed;
        py = py - (py - math.floor(tarY)) * dt * speed;
    end

    function self:zoom(factor, dt)
        scale = scale + factor * dt;
    end

    function self:rotate(da, dt)
        angle = angle + da * dt;
    end

    return self;
end

return Camera;