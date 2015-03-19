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

local Screen = require('lib/screenmanager/Screen');
local ExtensionHandler = require('src/ExtensionHandler');
local Graph = require('src/graph/Graph');
local Camera = require('lib/camera/Camera');
local ConfigReader = require('src/ConfigReader');
local Panel = require('src/ui/Panel');
local Logo = require('src/ui/Logo');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WARNING_MESSAGE = [[
To use LoFiVi you will have to place the folder structure you want to be visualised in the root folder of LoFiVi's save folder.

After you have placed it there you can use the R-Key to regenerate the graph.

LoFiVi will now open the file directory in which to place the folder.
]];

local CAMERA_ROTATION_SPEED = 0.6;
local CAMERA_TRANSLATION_SPEED = 400;
local CAMERA_TRACKING_SPEED = 2;
local CAMERA_ZOOM_SPEED = 0.6;
local CAMERA_MAX_ZOOM = 0.05;
local CAMERA_MIN_ZOOM = 2;

-- ------------------------------------------------
-- Controls
-- ------------------------------------------------

local camera_zoomIn;
local camera_zoomOut;
local camera_rotateL;
local camera_rotateR;
local camera_n;
local camera_s;
local camera_e;
local camera_w;

local graph_reset;
local take_screenshot;
local toggleLabels;
local toggleFileList;
local toggleFullscreen;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local camera;
    local config;
    local graph;
    local camX, camY;
    local ox, oy;
    local zoom = 1;

    local panel;
    local visible;

    local clickTime = 0;
    local resize = false;
    local drag = false;
    local scroll = false;

    local logo;

    local grabbedNode;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Recursively iterates over the target directory and returns the
    -- full path of all files and folders (including those in subfolders)
    -- as a sequence.
    -- @param dir
    --
    local function recursivelyGetDirectoryItems(dir)
        local pathsList = {};

        local function recurse(dir)
            local items = love.filesystem.getDirectoryItems(dir);
            for _, item in ipairs(items) do
                local file = dir .. "/" .. item;
                if love.filesystem.isDirectory(file) then
                    recurse(file);
                elseif love.filesystem.isFile(file) then
                    pathsList[#pathsList + 1] = file;
                end
            end
        end

        -- Start recursion.
        recurse(dir);

        return pathsList;
    end

    ---
    -- Creates the necessary folders if they don't exist yet, shows a
    -- message box to the user and opens the root folder in a
    -- finder / explorer window.
    --
    local function setUpFolders()
        if not love.filesystem.isDirectory('root') or #love.filesystem.getDirectoryItems('root') == 0 then
            love.filesystem.createDirectory('root');
            love.window.showMessageBox('No content found.', WARNING_MESSAGE, 'warning', false);
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory() .. '/root');
        end
    end

    ---
    -- This function goes over the list of file and folder paths and
    -- checks if a path should be ignored based on the custom ignore list
    -- read from the config file.
    -- @param paths
    -- @param ignoreList
    --
    local function ignoreFiles(paths, ignoreList)
        local newList = {};
        for _, path in ipairs(paths) do

            -- Check if one of the patterns matches the path.
            local ignore = false;
            for _, pattern in ipairs(ignoreList) do
                if path:match(pattern) then
                    ignore = true;
                    print('Ignore path: ' .. path);
                end
            end

            -- Included the path into the new list if none of the patterns matched.
            if not ignore then
                newList[#newList + 1] = path;
            end
        end
        return newList;
    end

    ---
    -- Grabs a screenshot and stores as a png-file using a unix
    -- timestap as a name. It will also set up a 'screenshots' folder
    -- in LoFiVi's save directory if it doesn't exist yet.
    --
    local function createScreenshot()
        local screenshot = love.graphics.newScreenshot();
        love.filesystem.createDirectory('screenshots');
        screenshot:encode('screenshots/' .. os.time() .. '.png');
    end

    ---
    -- Creates the panel containing the sorted list of file extensions.
    --
    local function createPanel()
        local canvas = ExtensionHandler.createCanvas();
        local panel = Panel.new(love.graphics.getWidth() - canvas:getWidth(), 0, canvas:getWidth(), canvas:getHeight() + 20);
        panel:setContent(canvas);
        return panel;
    end

    ---
    -- Creates a list of paths of all files in the root directory and ignores
    -- paths based on the ignore list specified in the config file.
    -- It then proceeds to generate the graph based on the files and folders.
    -- @param path
    -- @param config
    --
    local function createGraph(path, config)
        -- Read the files and folders and checks if some of them will be ignored.
        local pathsList = ignoreFiles(recursivelyGetDirectoryItems(path), config.ignore);

        -- Create a graph using the edited list of files and folders.
        local graph = Graph.new(config.options.showLabels);
        graph:init(pathsList);

        return graph;
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param ox - The current offset of the camera on the x-axis.
    -- @param oy - The current offset of the camera on the y-axis.
    -- @param dt
    --
    local function updateCamera(ox, oy, dt)
        -- Zoom.
        if love.keyboard.isDown(camera_zoomIn) then
            zoom = zoom + CAMERA_ZOOM_SPEED * dt;
        elseif love.keyboard.isDown(camera_zoomOut) then
            zoom = zoom - CAMERA_ZOOM_SPEED * dt;
        end
        zoom = math.max(CAMERA_MAX_ZOOM, math.min(zoom, CAMERA_MIN_ZOOM));
        camera:zoomTo(zoom);

        -- Rotation.
        if love.keyboard.isDown(camera_rotateL) then
            camera:rotate(CAMERA_ROTATION_SPEED * dt);
        elseif love.keyboard.isDown(camera_rotateR) then
            camera:rotate(-CAMERA_ROTATION_SPEED * dt);
        end

        -- Horizontal Movement.
        local dx = 0;
        if love.keyboard.isDown(camera_w) then
            dx = dx - dt * CAMERA_TRANSLATION_SPEED;
        elseif love.keyboard.isDown(camera_e) then
            dx = dx + dt * CAMERA_TRANSLATION_SPEED;
        end
        -- Vertical Movement.
        local dy = 0;
        if love.keyboard.isDown(camera_n) then
            dy = dy - dt * CAMERA_TRANSLATION_SPEED;
        elseif love.keyboard.isDown(camera_s) then
            dy = dy + dt * CAMERA_TRANSLATION_SPEED;
        end

        -- Take the camera rotation into account when calculating the new offset.
        ox = ox + (math.cos(-camera.rot) * dx - math.sin(-camera.rot) * dy);
        oy = oy + (math.sin(-camera.rot) * dx + math.cos(-camera.rot) * dy);

        -- Gradually move the camera to the target position.
        local cx, cy = graph:getCenter();
        camX = camX - (camX - math.floor(cx + ox)) * dt * CAMERA_TRACKING_SPEED;
        camY = camY - (camY - math.floor(cy + oy)) * dt * CAMERA_TRACKING_SPEED;
        camera:lookAt(camX, camY);

        return ox, oy;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        -- Set up the necessary folders.
        setUpFolders();

        -- Load configuration file and set options.
        config = ConfigReader.init();
        love.window.setMode(config.options.screenW, config.options.screenH, {
            fullscreen = config.options.fullscreen,
            fullscreentype = config.options.fsType,
        });
        love.graphics.setBackgroundColor(config.options.bgColor);
        ExtensionHandler.setColorTable(config.fileColors);

        -- Load key bindings.
        camera_zoomIn = config.keyBindings.camera_zoomIn;
        camera_zoomOut = config.keyBindings.camera_zoomOut;
        camera_rotateL = config.keyBindings.camera_rotateL;
        camera_rotateR = config.keyBindings.camera_rotateR;
        camera_n = config.keyBindings.camera_n;
        camera_s = config.keyBindings.camera_s;
        camera_e = config.keyBindings.camera_e;
        camera_w = config.keyBindings.camera_w;
        graph_reset = config.keyBindings.graph_reset;
        take_screenshot = config.keyBindings.take_screenshot;
        toggleLabels = config.keyBindings.toggleLabels;
        toggleFileList = config.keyBindings.toggleFileList;
        toggleFullscreen = config.keyBindings.toggleFullscreen;

        -- Create the camera.
        camera = Camera.new();
        camX, camY = 0, 0;
        ox, oy = 0, 0; -- Camera offset.

        graph = createGraph('root', config);
        panel = createPanel();
        visible = config.options.showFileList;

        -- Load a logo according to the config file.
        logo = Logo.new(config.options.logo,
            config.options.logoPosX,
            config.options.logoPosY,
            config.options.logoScaleX,
            config.options.logoScaleY);
    end

    function self:draw()
        camera:draw(function()
            graph:draw();
        end);

        if visible then
            panel:draw();
        end

        logo:draw();
    end

    function self:update(dt)
        graph:update(dt);
        panel:update(dt);

        -- If the use has clicked on a node it will snap to the mouse position until released.
        if grabbedNode then
            grabbedNode:setPosition(camera:worldCoords(love.mouse.getPosition()));
        end

        -- Update timer for detecting double clicks.
        clickTime = math.min(1.0, clickTime + dt);

        if resize then
            panel:resize(love.mouse.getX(), love.mouse.getY());
        end
        if drag then
            panel:setPosition(love.mouse.getX(), love.mouse.getY());
        end

        ox, oy = updateCamera(ox, oy, dt);
    end

    function self:keypressed(key)
        if key == graph_reset then
            ExtensionHandler.reset();
            graph = createGraph('root', config);
            panel = createPanel();
        elseif key == take_screenshot then
            createScreenshot();
        elseif key == toggleLabels then
            graph:toggleLabels()
        elseif key == toggleFileList then
            visible = not visible;
        elseif key == toggleFullscreen then
            love.window.setFullscreen(not love.window.getFullscreen());
        end
    end

    function self:mousepressed(x, y, b)
        if panel:hasContentFocus() and b == 'l' then
            scroll = true;
        end
        if panel:hasCornerFocus() and b == 'l' then
            resize = true;
        end
        if panel:hasHeaderFocus() and b == 'l' then
            drag = true;
        end

        if b == 'l' and clickTime < 0.5 and panel:hasContentFocus() then
            panel:setContentPosition(0, 0);
            clickTime = 0;
        else
            clickTime = 0;
        end

        if b == 'l' then
            grabbedNode = graph:grab(camera:worldCoords(x, y));
        elseif b == 'r' then
            grabbedNode = nil;
        end
    end

    function self:mousereleased(x, y, b)
        resize = false;
        drag = false;
        scroll = false;
    end

    function self:mousemoved(x, y, dx, dy)
        if scroll then
            panel:scroll(0, dy);
        end
    end

    return self;
end

return MainScreen;