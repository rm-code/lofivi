local File = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function File.new(extension, color)
    local self = {};

    local ox, oy;

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setOffset(nox, noy)
        ox, oy = nox, noy;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getOffsetX()
        return ox;
    end

    function self:getOffsetY()
        return oy;
    end

    function self:getColor()
        return color;
    end

    function self:getExtension()
        return extension;
    end

    return self;
end

return File;
