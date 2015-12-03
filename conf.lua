local GAME_TITLE = "LoFiVi";

local GAME_IDENTITY = "rmcode_LoFiVi";

local GAME_VERSION = "0121";

local LOVE_VERSION = "0.10.0";

-- ------------------------------------------------
-- Global Functions
-- ------------------------------------------------

---
-- Initialise löve's config file.
-- @param _conf
--
function love.conf(t)
    t.identity = GAME_IDENTITY;
    t.version = LOVE_VERSION;
    t.console = true;

    t.window.title = GAME_TITLE;
    t.window.icon = nil;
    t.window.width = 0;
    t.window.height = 0;
    t.window.borderless = false;
    t.window.resizable = true;
    t.window.minwidth = 800;
    t.window.minheight = 600;
    t.window.fullscreen = false;
    t.window.fullscreentype = "exclusive";
    t.window.vsync = true;
    t.window.fsaa = 0;
    t.window.display = 1;
    t.window.highdpi = false;
    t.window.srgb = false;
    t.window.x = nil;
    t.window.y = nil;

    t.modules.audio = true;
    t.modules.event = true;
    t.modules.graphics = true;
    t.modules.image = true;
    t.modules.joystick = true;
    t.modules.keyboard = true;
    t.modules.math = true;
    t.modules.mouse = true;
    t.modules.physics = true;
    t.modules.sound = true;
    t.modules.system = true;
    t.modules.timer = true;
    t.modules.window = true;
end

---
-- Returns the game's version.
--
function getVersion()
    if GAME_VERSION then
        return GAME_VERSION;
    end
end

---
-- Returns the title.
--
function getTitle()
    if GAME_TITLE then
        return GAME_TITLE;
    end
end
