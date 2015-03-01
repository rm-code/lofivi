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

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MIN_HEIGHT = 100;
local MIN_WIDTH = 100;
local BORDER_SIZE = 10;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Panel.new(x, y, w, h)
    local self = {};

    local w = math.min(love.graphics.getWidth(), w);
    local h = math.min(love.graphics.getHeight(), h);
    local x = math.min(love.graphics.getWidth() - w, x);
    local y = math.min(love.graphics.getHeight() - h, y);

    local content;
    local contentOffsetX, contentOffsetY = 0, 0;
    local contentFocus = false;
    local headerFocus = false;
    local cornerFocus = false;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw()
        love.graphics.setColor(255, 255, 255, contentFocus and 40 or 20);
        love.graphics.rectangle('fill', x + BORDER_SIZE, y + BORDER_SIZE, w - 2 * BORDER_SIZE, h - 2 * BORDER_SIZE);

        love.graphics.setColor(255, 255, 255, headerFocus and 50 or 30);
        love.graphics.rectangle('fill', x + BORDER_SIZE, y, w - 2 * BORDER_SIZE, BORDER_SIZE);

        love.graphics.setColor(255, 255, 255, cornerFocus and 40 or 20);
        love.graphics.rectangle('fill', x + w - BORDER_SIZE, y + h - BORDER_SIZE, BORDER_SIZE, BORDER_SIZE);

        love.graphics.setColor(255, 255, 255, 255);
        love.graphics.setScissor(x + BORDER_SIZE, y + BORDER_SIZE, w - 2 * BORDER_SIZE, h - 2 * BORDER_SIZE);
        love.graphics.draw(content, x + contentOffsetX + BORDER_SIZE, y + contentOffsetY + BORDER_SIZE);
        love.graphics.setScissor();
    end

    ---
    -- Updates the panel and checks if the mouse is hovering over
    -- any elements.
    -- @param dt
    --
    function self:update(dt)
        local mx, my = love.mouse.getPosition();
        contentFocus = x + BORDER_SIZE < mx and x + w - BORDER_SIZE > mx and y + BORDER_SIZE < my and y + h - BORDER_SIZE > my;
        cornerFocus = x + w - BORDER_SIZE < mx and x + w > mx and y + h - BORDER_SIZE < my and y + h > my;
        headerFocus = x < mx and x + w > mx and y < my and y + BORDER_SIZE > my;
    end

    ---
    -- Scrolls the panel's content.
    -- @param dx
    -- @param dy
    --
    function self:scroll(dx, dy)
        contentOffsetX = contentOffsetX + dx;
        contentOffsetY = contentOffsetY + dy;
    end

    ---
    -- Resizes the panel and resets the content's offset.
    -- @param mx
    -- @param my
    --
    function self:resize(mx, my)
        contentOffsetX, contentOffsetY = 0, 0;
        w = math.max(MIN_WIDTH, math.min(love.graphics.getWidth() - x, mx - x + BORDER_SIZE));
        h = math.max(MIN_HEIGHT, math.min(love.graphics.getHeight() - y, my - y + BORDER_SIZE));
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setContent(c)
        content = c;
    end

    ---
    -- Sets the position of the panel's content.
    -- @param x
    -- @param y
    --
    function self:setContentPosition(x, y)
        contentOffsetX, contentOffsetY = x, y;
    end

    ---
    -- Sets the position of the panel on screen.
    -- The values are clamped so the panel can't be moved offscreen.
    -- @param nx
    -- @param ny
    --
    function self:setPosition(nx, ny)
        x = math.min(love.graphics.getWidth() - w, nx);
        y = math.min(love.graphics.getHeight() - h, ny);
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:hasContentFocus()
        return contentFocus;
    end

    function self:hasCornerFocus()
        return cornerFocus;
    end

    function self:hasHeaderFocus()
        return headerFocus;
    end

    return self;
end

return Panel;