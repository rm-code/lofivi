local Folder = require('src.graph.Folder');
local File = require('src.graph.File');
local ExtensionHandler = require('src.ExtensionHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new(showLabels)
    local self = {};

    local tree;
    local nodes;
    local minX, maxX, minY, maxY;

    local showLabels = showLabels;

    local sprite = love.graphics.newImage('res/img/file.png');
    local spritebatch = love.graphics.newSpriteBatch(sprite, 10000, 'stream');

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function updateBoundaries(minX, maxX, minY, maxY, nx, ny)
        return math.min(nx, minX), math.max(nx, maxX), math.min(ny, minY), math.max(ny, maxY);
    end

    ---
    -- Creates a file tree based on a sequence containing
    -- paths to files and subfolders. Each folder is a folder
    -- node which has children folder nodes and files.
    -- @param paths
    --
    local function createGraph(paths)
        local nodes = { Folder.new(spritebatch, nil, 'root', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5) };
        local tree = nodes[#nodes];
        local fileCounter = 0;

        for i = 1, #paths do
            local target;

            -- Split the path using pattern matching.
            local splitPath = {};
            for part in paths[i]:gmatch('[^/]+') do
                splitPath[#splitPath + 1] = part;
            end

            -- Iterate over the split parts and create folders and files.
            for i = 1, #splitPath do
                local name = splitPath[i];
                if name == 'root' then
                    target = nodes[1];
                elseif i == #splitPath then
                    local col, ext = ExtensionHandler.add(name); -- Get a colour for this file.
                    target:addFile(name, File.new(ext, col));
                    fileCounter = fileCounter + 1;
                else
                    -- Get the next folder as a target. If that folder doesn't exist in our graph yet, create it first.
                    local nt = target:getChild(name);
                    if not nt then
                        -- Calculate random offset at which to place the new folder node.
                        local ox = love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1);
                        local oy = love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1);

                        nodes[#nodes + 1] = Folder.new(spritebatch, target, name, target:getX() + ox, target:getY() + oy);
                        target = target:addChild(name, nodes[#nodes]);
                    else
                        target = nt;
                    end
                end
            end
        end

        print('Created ' .. #nodes .. ' folders and ' .. fileCounter .. ' files.');

        return tree, nodes;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(paths)
        tree, nodes = createGraph(paths);
        minX, minY, maxX, maxY = tree:getX(), tree:getX(), tree:getY(), tree:getY();
    end

    function self:draw(rotation)
        tree:draw(rotation, showLabels);
        love.graphics.draw(spritebatch);
    end

    function self:update(dt)
        spritebatch:clear();

        for i = 1, #nodes do
            for j = 1, #nodes do
                nodes[i]:calculateForces(nodes[j]);
            end
            nodes[i]:update(dt);
        end

        minX, maxX, minY, maxY = tree:getX(), tree:getX(), tree:getY(), tree:getY();
    end

    function self:toggleLabels()
        showLabels = not showLabels;
    end

    function self:grab(x, y)
        for i = 1, #nodes do
            local node = nodes[i];
            local margin = 15;
            if x < node:getX() + margin
                    and x > node:getX() - margin
                    and y < node:getY() + margin
                    and y > node:getY() - margin then
                return node;
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCenter()
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    return self;
end

return Graph;
