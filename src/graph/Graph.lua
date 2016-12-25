local Graphoon = require( 'lib.graphoon.Graphoon' ).Graph;
local Node = require( 'src.graph.Node' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LABEL_FONT   = love.graphics.newFont( 25 );
local DEFAULT_FONT = love.graphics.newFont( 12 );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new(showLabels)
    local self = {};

    Graphoon.setNodeClass( Node );

    local sprite = love.graphics.newImage('res/img/file.png');
    local spritebatch = love.graphics.newSpriteBatch(sprite, 10000, 'stream');

    local graph = Graphoon.new();

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Returns a random sign (+ or -).
    -- @return (number) Randomly returns either -1 or 1.
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    ---
    -- Spawns a new node.
    -- @param id (string) The node's unqiue id based on the folder's full path.
    -- @return   (Node)   The newly spawned node.
    --
    local function spawnRoot( id )
        local parentX, parentY = love.graphics.getDimensions();
        return graph:addNode( id, parentX * 0.5, parentY * 0.5, true, nil, spritebatch, '' );
    end

    ---
    -- Spawns a new node.
    -- @param name     (string) The node's name based on the folder's name.
    -- @param id       (string) The node's unqiue id based on the folder's full path.
    -- @param parent   (Node)   The parent of the node to spawn.
    -- @param parentID (string) The parent's id.
    -- @return         (Node)   The newly spawned node.
    --
    local function spawnNode( name, id, parent, parentID )
        local parentX, parentY = parent:getPosition();
        local offsetX = love.math.random( 100 ) * randomSign();
        local offsetY = love.math.random( 100 ) * randomSign();
        return graph:addNode( id, parentX + offsetX, parentY + offsetY, false, parentID, spritebatch, name );
    end

    ---
    -- Creates all nodes belonging to a path if they don't exist yet.
    -- @param path (string) The path to resolve.
    -- @return     (Node)   The last node in the path.
    --
    local function createNodes( path )
        local parentID;
        for folder in path:gmatch('[^/]+') do
            local nodeID;
            if not parentID then
                nodeID = folder;
            else
                nodeID = parentID .. '/' .. folder;
            end

            if love.filesystem.isFile( nodeID ) then
                local parentNode = graph:getNode( parentID );
                parentNode:addFile( folder:match( '(.+)%.(.+)' ))
            elseif not graph:hasNode( nodeID ) then
                local parentNode = graph:getNode( parentID );
                if not parentNode then
                    spawnRoot( nodeID )
                else
                    spawnNode( folder, nodeID, parentNode, parentID );
                    graph:connectIDs( parentID, nodeID );
                end
            end
            parentID = nodeID;
        end
        return graph:getNode( path );
    end

    local function createGraph( paths )
        for _, path in ipairs( paths ) do
            createNodes( path );
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init( paths )
        createGraph( paths );
    end

    function self:toggleLabels()
        showLabels = not showLabels;
    end

    ---
    -- Draws the graph.
    -- @param camrot   (number) The current camera rotation.
    -- @param camscale (number) The current camera scale.
    --
    function self:draw( camrot, camscale )
        graph:draw( function( node )
            love.graphics.setFont( LABEL_FONT );
            love.graphics.setColor( 255, 255, 255, 105 );
            love.graphics.print( node:getName(), node:getX(), node:getY(), -camrot, 1 / camscale, 1 / camscale, -node:getRadius() * camscale, -node:getRadius() * camscale );
            love.graphics.setColor( 255, 255, 255, 255 );
            love.graphics.setFont( DEFAULT_FONT );
        end,
        function( edge )
            love.graphics.setColor( 60, 60, 60, 255 );
            love.graphics.setLineWidth( 5 );
            love.graphics.line( edge.origin:getX(), edge.origin:getY(), edge.target:getX(), edge.target:getY() );
            love.graphics.setLineWidth( 1 );
            love.graphics.setColor( 255, 255, 255, 255 );
        end);
        love.graphics.draw( spritebatch );
    end

    ---
    -- Updates the graph.
    -- @param dt (number) The delta time passed since the last frame.
    --
    function self:update( dt )
        spritebatch:clear();
        graph:update( dt, function( node )
            node:update( dt );
        end);
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCenter()
        return graph:getCenter();
    end

    function self:getNodeAt( x, y, range )
        return graph:getNodeAt( x, y, range );
    end

    return self;
end

return Graph;
