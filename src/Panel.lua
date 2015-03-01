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

local Panel = {};

function Panel.new(x, y, w, h)
    local self = {};

    local w = math.min(love.graphics.getWidth(), w);
    local h = math.min(love.graphics.getHeight(), h);
    local x = math.min(love.graphics.getWidth() - w, x);
    local y = math.min(love.graphics.getHeight() - h, y);
    local content;
    local border = 10;
    local contentOffsetX, contentOffsetY = 0, 0;
    local contentFocus = false;
    local headerFocus = false;
    local cornerFocus = false;
    local minHeight = 100;
    local minWidth = 100;

    function self:draw()
        love.graphics.setColor(255, 255, 255, contentFocus and 40 or 20);
        love.graphics.rectangle('fill', x + border, y + border, w - 2 * border, h - 2 * border);

        love.graphics.setColor(255, 255, 255, headerFocus and 50 or 30);
        love.graphics.rectangle('fill', x + border, y, w - 2 * border, border);

        love.graphics.setColor(255, 255, 255, cornerFocus and 40 or 20);
        love.graphics.rectangle('fill', x + w - border, y + h - border, border, border);

        love.graphics.setColor(255, 255, 255, 255);
        love.graphics.setScissor(x + border, y + border, w - 2 * border, h - 2 * border);
        love.graphics.draw(content, x + contentOffsetX + border, y + contentOffsetY + border);
        love.graphics.setScissor();
    end

    function self:update(dt)
        local mx, my = love.mouse.getPosition();
        contentFocus = x + border < mx and x + w - border > mx and y + border < my and y + h - border > my;
        cornerFocus = x + w - border < mx and x + w > mx and y + h - border < my and y + h > my;
        headerFocus = x < mx and x + w > mx and y < my and y + border > my;
    end

    function self:setContent(c)
        content = c;
    end

    function self:hasContentFocus()
        return contentFocus;
    end

    function self:hasCornerFocus()
        return cornerFocus;
    end

    function self:hasHeaderFocus()
        return headerFocus;
    end

    function self:scroll(dx, dy)
        contentOffsetX = contentOffsetX + dx;
        contentOffsetY = contentOffsetY + dy;
    end

    function self:setContentPosition(x, y)
        contentOffsetX, contentOffsetY = x, y;
    end

    function self:resize(mx, my)
        contentOffsetX, contentOffsetY = 0, 0;
        w = math.max(minWidth, math.min(love.graphics.getWidth() - x, mx - x + border));
        h = math.max(minHeight, math.min(love.graphics.getHeight() - y, my - y + border));
    end

    function self:setPosition(nx, ny)
        x = math.min(love.graphics.getWidth() - w, nx);
        y = math.min(love.graphics.getHeight() - h, ny);
    end

    function self:getWidth()
        return w;
    end

    function self:getHeight()
        return h;
    end

    return self;
end

return Panel;