local FilePanel = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FRST_OFFSET = 10;
local SCND_OFFSET = 50;
local LINE_HEIGHT = 20;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FilePanel.new()
    local self = {};

    local x = 0;
    local y = 10;

    local scrolly = 0;
    local scrollVelocity = 0;

    local files;
    local totalFiles;
    local contentHeight;

    local visible;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Draws a counter of all files in the project and
    -- a separate counter for each used file extension.
    --
    function self:draw()
        local py = math.floor( y + scrolly );
        love.graphics.print(totalFiles, x + FRST_OFFSET, py);
        love.graphics.print('Files',    x + SCND_OFFSET, py);
        for i, tbl in ipairs(files) do
            love.graphics.setColor(tbl.color[1], tbl.color[2], tbl.color[3]);
            love.graphics.print(tbl.count,     x + FRST_OFFSET, py + i * LINE_HEIGHT);
            love.graphics.print(tbl.extension, x + SCND_OFFSET, py + i * LINE_HEIGHT);
        end
        love.graphics.setColor(255, 255, 255);
    end

    function self:update()
        scrollVelocity = scrollVelocity * 0.9;
        scrolly = scrolly + scrollVelocity;
        scrolly = math.min(0, math.max( scrolly, love.graphics.getHeight() - contentHeight - 2 * LINE_HEIGHT));
    end

    ---
    -- Scrolls the FilePanel's content.
    -- @param dx
    -- @param dy
    --
    function self:wheelmoved( _, dy )
        scrollVelocity = scrollVelocity + dy;
    end

    function self:doubleclick()
        self:setContentPosition(0, 0);
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setFiles(nfiles)
        files = nfiles;

        totalFiles = 0;
        for _, v in ipairs(files) do
            totalFiles = totalFiles + v.count;
        end
        contentHeight = #files * LINE_HEIGHT;
    end

    function self:setVisible(nvisible)
        visible = nvisible;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:isVisible()
        return visible;
    end

    return self;
end

return FilePanel;
