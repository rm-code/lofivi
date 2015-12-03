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

    local mx, my; -- The current mouse position.

    local content;
    local contentOffsetX, contentOffsetY = 0, 0;

    local contentFocus = false;
    local headerFocus = false;
    local cornerFocus = false;

    local resize = false;
    local drag = false;

    local visible;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw()
        if not visible then
            return;
        end

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
        mx, my = love.mouse.getPosition();

        if not resize and not drag then
            contentFocus = x + BORDER_SIZE < mx and x + w - BORDER_SIZE > mx and y + BORDER_SIZE < my and y + h - BORDER_SIZE > my;
            cornerFocus = x + w - BORDER_SIZE < mx and x + w > mx and y + h - BORDER_SIZE < my and y + h > my;
            headerFocus = x < mx and x + w > mx and y < my and y + BORDER_SIZE > my;
        end
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

    function self:mousepressed(mx, my, b)
        if b == 1 then
            if cornerFocus then
                resize = true;
            elseif headerFocus then
                drag = true;
            end
        end
    end

    function self:mousereleased(x, y, b)
        resize, drag = false, false;
    end

    function self:mousemoved(mx, my, dx, dy)
        if drag then
            self:setPosition(x + dx, y + dy);
        elseif resize then
            self:resize(mx, my);
        end
    end

    function self:wheelmoved(x, y)
        self:scroll(0, y);
    end

    function self:doubleclick()
        self:setContentPosition(0, 0);
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

    function self:setVisible(nvisible)
        visible = nvisible;
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

    function self:isVisible()
        return visible;
    end

    return self;
end

return Panel;
