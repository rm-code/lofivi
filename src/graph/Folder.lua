local Folder = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FORCE_MAX = 4;

local LABEL_FONT = love.graphics.newFont(25);
local DEFAULT_FONT = love.graphics.newFont(12);

local SPRITE_SIZE = 24;
local SPRITE_SCALE_FACTOR = SPRITE_SIZE / 256;
local SPRITE_OFFSET = 128;
local MIN_ARC_SIZE = SPRITE_SIZE;

local FORCE_SPRING = -0.001;
local FORCE_CHARGE = 1000000;

local DAMPING_FACTOR = 0.95;

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local speed;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Folder.new(spriteBatch, parent, name, x, y)
    local self = {};

    local files = {};
    local fileCount = 0;
    local children = {};
    local childCount = 0;

    local posX, posY = x, y;
    local velX, velY = 0, 0;
    local accX, accY = 0, 0;

    local radius = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Clamps a value to a certain range.
    -- @param min
    -- @param val
    -- @param max
    --
    local function clamp(min, val, max)
        return math.max(min, math.min(val, max));
    end

    ---
    -- Calculates the new xy-acceleration for this node.
    -- The values are clamped to keep the graph from "exploding".
    -- @param fx - The force to apply in x-direction.
    -- @param fy - The force to apply in y-direction.
    --
    local function applyForce(fx, fy)
        accX = clamp(-FORCE_MAX, accX + fx, FORCE_MAX);
        accY = clamp(-FORCE_MAX, accY + fy, FORCE_MAX);
    end

    ---
    -- Calculates the arc for a certain angle.
    -- @param radius
    -- @param angle
    --
    local function calcArc(radius, angle)
        return math.pi * radius * (angle / 180);
    end

    ---
    -- Calculates how many layers we need and how many files
    -- can be placed on each layer. This basically generates a
    -- blueprint of how the files need to be arranged.
    --
    local function createOnionLayers(count)
        local fileCounter = 0;
        local radius = -SPRITE_SIZE; -- Radius of the circle around the node.
        local layers = {
            { radius = radius, amount = fileCounter }
        };

        for i = 1, count do
            fileCounter = fileCounter + 1;

            -- Calculate the arc between the file nodes on the current layer.
            -- The more files are on it the smaller it gets.
            local arc = calcArc(layers[#layers].radius, 360 / fileCounter);

            -- If the arc is smaller than the allowed minimum we store the radius
            -- of the current layer and the number of nodes that can be placed
            -- on that layer and move to the next layer.
            if arc < MIN_ARC_SIZE then
                radius = radius + SPRITE_SIZE;

                -- Create a new layer.
                layers[#layers + 1] = { radius = radius, amount = 1 };
                fileCounter = 1;
            else
                layers[#layers].amount = fileCounter;
            end
        end

        return layers;
    end

    ---
    -- Update the node's position based on the calculated velocity and
    -- acceleration.
    --
    local function move(dt)
        velX = (velX + accX * dt * speed) * DAMPING_FACTOR;
        velY = (velY + accY * dt * speed) * DAMPING_FACTOR;
        posX = posX + velX;
        posY = posY + velY;
        accX, accY = 0, 0;
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    -- @param files
    --
    local function plotCircle(files, count)
        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers = createOnionLayers(count);

        -- Sort files based on their extension before placing them.
        local toSort = {};
        for _, file in pairs(files) do
            toSort[#toSort + 1] = { extension = file:getExtension(), file = file };
        end
        table.sort(toSort, function(a, b)
            return a.extension > b.extension;
        end)

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local fileCounter = 0;
        local layer = 1;
        for i = 1, #toSort do
            local file = toSort[i].file;
            fileCounter = fileCounter + 1;

            -- If we have more files on the current layer than allowed, we "move"
            -- the file to the next layer (this is why we reset the counter to one
            -- instead of zero).
            if fileCounter > layers[layer].amount then
                layer = layer + 1;
                fileCounter = 1;
            end

            -- Calculate the new position of the file on its layer around the folder node.
            local angle = 360 / layers[layer].amount;
            local x = (layers[layer].radius * math.cos((angle * (fileCounter - 1)) * (math.pi / 180)));
            local y = (layers[layer].radius * math.sin((angle * (fileCounter - 1)) * (math.pi / 180)));
            file:setOffset(x, y);
        end
        return layers[layer].radius;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw(rotation, showLabels)
        love.graphics.circle('fill', posX, posY, 2, 10);

        if showLabels then
            love.graphics.setFont(LABEL_FONT);
            love.graphics.setColor(255, 255, 255, 105);
            love.graphics.print(name, posX, posY, -rotation, 1, 1, -radius, -radius);
            love.graphics.setColor(255, 255, 255, 255);
            love.graphics.setFont(DEFAULT_FONT);
        end

        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 55);
            love.graphics.line(posX, posY, node:getX(), node:getY());
            love.graphics.setColor(255, 255, 255, 255);
            node:draw(rotation, showLabels);
        end
    end

    function self:update(dt)
        move(dt);
        for name, file in pairs(files) do
            spriteBatch:setColor(file:getColor());
            spriteBatch:add(posX + file:getOffsetX(), posY + file:getOffsetY(), 0, SPRITE_SCALE_FACTOR, SPRITE_SCALE_FACTOR, SPRITE_OFFSET, SPRITE_OFFSET);
        end
    end

    function self:addFile(name, file)
        files[name] = file;
        fileCount = fileCount + 1;
        radius = plotCircle(files, fileCount);
    end

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    ---
    -- Calculate and apply attraction and repulsion forces.
    -- @param node
    --
    function self:calculateForces(node)
        if self == node then return end

        -- Calculate distance vector and normalise it.
        local dx, dy = posX - node:getX(), posY - node:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        dx = dx / distance;
        dy = dy / distance;

        -- Attract to node if they are connected.
        local strength;
        if self:isConnectedTo(node) then
            strength = FORCE_SPRING * distance;
            applyForce(dx * strength, dy * strength);
        end

        -- Repel unconnected nodes.
        strength = FORCE_CHARGE * ((self:getMass() * node:getMass()) / (distance * distance));
        applyForce(dx * strength, dy * strength);
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setPosition(nx, ny)
        posX, posY = nx, ny;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getX()
        return posX;
    end

    function self:getY()
        return posY;
    end

    function self:getChild(name)
        return children[name];
    end

    function self:isConnectedTo(node)
        for _, v in pairs(children) do
            if node == v then
                return true;
            end
        end
        return parent == node;
    end

    function self:getMass()
        return 0.015 * (childCount + math.log(math.max(SPRITE_SIZE, radius)));
    end

    return self;
end

function Folder.setSpeed(nspeed)
    speed = nspeed;
end

return Folder;
