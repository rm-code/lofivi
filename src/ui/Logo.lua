local Logo = {};

function Logo.new(path, x, y, sx, sy)
    local self = {};

    local visible;

    local ok, image = pcall(love.graphics.newImage, path);
    if not ok then
        print("Couldn't load logo from: " .. path);
        image = nil;
    end

    function self:draw()
        if image and visible then
            love.graphics.draw(image, x, y, 0, sx, sy);
        end
    end

    function self:setVisible(nvisible)
        visible = nvisible;
    end

    function self:isVisible()
        return visible;
    end

    return self;
end

return Logo;
