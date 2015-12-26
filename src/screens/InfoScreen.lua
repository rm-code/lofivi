local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local InfoPanel = require('src.ui.InfoPanel');

local InfoScreen = {};

function InfoScreen.new()
    local self = Screen.new();

    local infoPanel = InfoPanel.new(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5);

    function self:update(dt)
        infoPanel:update(dt);
    end

    function self:draw()
        infoPanel:draw();
    end

    function self:directorydropped(path)
        love.filesystem.mount(path, 'root');
        ScreenManager.switch('main');
    end

    return self;
end

return InfoScreen;
