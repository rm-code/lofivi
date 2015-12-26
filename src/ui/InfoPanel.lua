local Panel = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local INFO_MESSAGE = 'Drag a folder here to create a new graph!';

local LABEL_FONT = love.graphics.newFont(25);
local DEFAULT_FONT = love.graphics.newFont(12);

local MIN_HEIGHT = 100;
local MIN_WIDTH = 100;
local BORDER_SIZE = 10;
local TIME_BEFORE_OFFSET = 2;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Panel.new(x, y)
    local self = {};

    local x = math.min(x, love.graphics.getWidth() - LABEL_FONT:getWidth(INFO_MESSAGE));
    local y = math.min(y, love.graphics.getHeight() - LABEL_FONT:getHeight(INFO_MESSAGE));

    local passedTime = 0;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:update(dt)
        passedTime = passedTime + dt;
        if passedTime >= TIME_BEFORE_OFFSET then
            x = love.math.random(0, love.graphics.getWidth() - LABEL_FONT:getWidth(INFO_MESSAGE));
            y = love.math.random(0, love.graphics.getHeight() - LABEL_FONT:getHeight(INFO_MESSAGE));
            passedTime = 0;
        end
    end

    function self:draw()
        love.graphics.setFont(LABEL_FONT);
        love.graphics.print(INFO_MESSAGE, x, y);
        love.graphics.setFont(DEFAULT_FONT);
    end

    return self;
end

return Panel;
