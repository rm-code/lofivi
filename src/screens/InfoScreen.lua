local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local INFO_MESSAGE = 'Drag a folder here to create a new graph!';

local LABEL_FONT = love.graphics.newFont(25);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InfoScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InfoScreen.new()
    local self = Screen.new();

    love.window.setMode( 400, 400 );

    function self:draw()
        love.graphics.setFont(LABEL_FONT);
        love.graphics.printf(INFO_MESSAGE, 0, love.graphics.getHeight() * 0.5, 400, 'center');
        love.graphics.setFont(DEFAULT_FONT);
    end

    function self:directorydropped(path)
        love.filesystem.mount(path, 'root');
        ScreenManager.switch('main');
    end

    return self;
end

return InfoScreen;
