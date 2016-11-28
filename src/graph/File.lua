local File = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ANIM_TIMER = 3.5;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new File object.
-- @param parentX      (number) The position of the file's parent node along the x-axis.
-- @param parentY      (number) The position of the file's parent node along the y-axis.
-- @param color        (table)  A table containing the RGB values for this file type.
-- @param extension    (string) The file's extension.
-- @return             (File)   A new file instance.
--
function File.new( parentX, parentY, color, extension )
    local self = {};

    -- The target and the current offset from the parent node's position.
    -- This is used to arrange the files around a node.
    local targetOffsetX,  targetOffsetY  = 0, 0;
    local currentOffsetX, currentOffsetY = 0, 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Linear interpolation between a and b.
    -- @param a (number) The current value.
    -- @param b (number) The target value.
    -- @param t (number) The time value.
    -- @return  (number) The interpolated value.
    --
    local function lerp( a, b, t )
        return a + ( b - a ) * t;
    end

    ---
    -- Lerps the file from its current offset position to the target offset.
    -- This adds a nice animation effect when files are rearranged around their
    -- parent nodes.
    -- @param dt   (number) The delta time between frames.
    -- @param tarX (number) The target offset on the x-axis.
    -- @param tarY (number) The target offset on the y-axis.
    --
    local function animate( dt, tarX, tarY )
        currentOffsetX = lerp( currentOffsetX, tarX, dt * ANIM_TIMER );
        currentOffsetY = lerp( currentOffsetY, tarY, dt * ANIM_TIMER );
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- If the file is marked as modified the color will be lerped from the
    -- modified color to the default file color.
    -- @param dt (number) The delta time between frames.
    --
    function self:update( dt )
        animate( dt, targetOffsetX, targetOffsetY );
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the real position of the node on the x-axis.
    -- This is the sum of the parent-node's position and the offset of the file.
    -- @return (number) The position of the file along the x-axis.
    --
    function self:getX()
        return parentX + currentOffsetX;
    end

    ---
    -- Returns the real position of the node on the y-axis.
    -- This is the sum of the parent-node's position and the offset of the file.
    -- @return (number) The position of the file along the y-axis.
    --
    function self:getY()
        return parentY + currentOffsetY;
    end

    ---
    -- Returns the current color of the file. The table uses rgba keys to store
    -- the color.
    -- @return (table) A table containing the RGB values of the file.
    --
    function self:getColor()
        return color;
    end

    ---
    -- Returns the extension of the file as a string.
    -- @return (string) The extension of the file.
    --
    function self:getExtension()
        return extension;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the target offset of the file from its parent node.
    -- This distance is used to plot all the files in a circle around the node.
    -- @param ox (number) The offset from the parent along the x-axis.
    -- @param oy (number) The offset from the parent along the y-axis.
    --
    function self:setOffset( ox, oy )
        targetOffsetX, targetOffsetY = ox, oy;
    end

    ---
    -- Sets the position of the parent node on which the file is located.
    -- @param nx (number) The position of the parent along the x-axis.
    -- @param ny (number) The position of the parent along the y-axis.
    --
    function self:setPosition( nx, ny )
        parentX, parentY = nx, ny;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return File;
