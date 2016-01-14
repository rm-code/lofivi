local Screen = require('lib.screenmanager.Screen');
local ExtensionHandler = require('src.ExtensionHandler');
local Graph = require('src.graph.Graph');
local Folder = require('src.graph.Folder');
local Camera = require('lib.camera.Camera');
local ConfigReader = require('src.ConfigReader');
local FilePanel = require('src.ui.FilePanel');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

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
local exit;

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

    local filePanel;

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
    local function recursivelyGetDirectoryItems( dir )
        local pathsList = {};

        local function recurse( rdir )
            local items = love.filesystem.getDirectoryItems( rdir );
            for _, item in ipairs(items) do
                local file = rdir .. "/" .. item;
                if love.filesystem.isDirectory(file) then
                    recurse(file);
                elseif love.filesystem.isFile(file) then
                    pathsList[#pathsList + 1] = file;
                end
            end
        end

        -- Start recursion.
        recurse( dir );

        return pathsList;
    end

    ---
    -- Creates the root folder we'll mount our directories to later on.
    --
    local function setUpFolders()
        if not love.filesystem.isDirectory('root') then
            love.filesystem.createDirectory('root');
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
        local filename = os.time() .. '.png';
        love.filesystem.createDirectory('screenshots');
        love.graphics.newScreenshot():encode('png', 'screenshots/' .. filename);
        print('Created screenshot: ' .. filename);
    end

    ---
    -- Creates the panel containing the sorted list of file extensions.
    --
    local function createFilePanel(pvisible)
        local newfilePanel = FilePanel.new();
        newfilePanel:setFiles( ExtensionHandler.getFiles() );
        newfilePanel:setVisible(pvisible);
        return newfilePanel;
    end

    ---
    -- Creates a list of paths of all files in the root directory and ignores
    -- paths based on the ignore list specified in the config file.
    -- It then proceeds to generate the graph based on the files and folders.
    -- @param path
    -- @param config
    --
    local function createGraph(path, cfg)
        -- Read the files and folders and checks if some of them will be ignored.
        local pathsList = ignoreFiles(recursivelyGetDirectoryItems(path), cfg.ignore);

        -- Create a graph using the edited list of files and folders.
        local newGraph = Graph.new(cfg.options.showLabels);
        newGraph:init(pathsList);

        return newGraph;
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param ox - The current offset of the camera on the x-axis.
    -- @param oy - The current offset of the camera on the y-axis.
    -- @param dt
    --
    local function updateCamera( offsetX, offsetY, dt )
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
        offsetX = offsetX + (math.cos(-camera.rot) * dx - math.sin(-camera.rot) * dy);
        offsetY = offsetY + (math.sin(-camera.rot) * dx + math.cos(-camera.rot) * dy);

        -- Gradually move the camera to the target position.
        local cx, cy = graph:getCenter();
        camX = camX - (camX - math.floor(cx + offsetX)) * dt * CAMERA_TRACKING_SPEED;
        camY = camY - (camY - math.floor(cy + offsetY)) * dt * CAMERA_TRACKING_SPEED;
        camera:lookAt(camX, camY);

        return offsetX, offsetY;
    end

    local function resetGraph()
        ExtensionHandler.reset();
        graph = createGraph('root', config);
        filePanel = createFilePanel(filePanel:isVisible());
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
        exit = config.keyBindings.exit;

        -- Create the camera.
        camera = Camera.new();
        camX, camY = 0, 0;
        ox, oy = 0, 0; -- Camera offset.

        filePanel = createFilePanel(config.options.showFileList);

        -- Define the node's speed.
        Folder.setSpeed(config.options.nodeSpeed);

        love.graphics.setLineWidth(5);

        resetGraph();
    end

    function self:draw()
        camera:draw(function()
            graph:draw(camera.rot);
        end);

        filePanel:draw();
    end

    function self:update(dt)
        graph:update(dt);
        filePanel:update(dt);

        -- If the use has clicked on a node it will snap to the mouse position until released.
        if grabbedNode then
            grabbedNode:setPosition(camera:worldCoords(love.mouse.getPosition()));
        end

        ox, oy = updateCamera(ox, oy, dt);
    end

    function self:keypressed(key)
        if key == graph_reset then
            resetGraph(filePanel:isVisible());
        elseif key == take_screenshot then
            createScreenshot();
        elseif key == toggleLabels then
            graph:toggleLabels()
        elseif key == toggleFileList then
            filePanel:setVisible(not filePanel:isVisible());
        elseif key == toggleFullscreen then
            love.window.setFullscreen(not love.window.getFullscreen());
        elseif key == exit then
            love.event.quit();
        end
    end

    function self:mousepressed(x, y, b)
        if b == 1 then
            grabbedNode = graph:grab(camera:worldCoords(x, y));
        elseif b == 2 then
            grabbedNode = nil;
        end
    end

    function self:wheelmoved(x, y)
        filePanel:wheelmoved(x, y);
    end

    function self:directorydropped(path)
        love.filesystem.mount(path, 'root');
        resetGraph();
    end

    return self;
end

return MainScreen;
