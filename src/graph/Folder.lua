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

local Node = require('src/graph/Node');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Folder = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Folder.new(parent, name, x, y)
    local self = Node.new(name, x, y);

    local files = {};
    local fileCount = 0;
    local children = {};
    local childCount = 0;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw()
        love.graphics.circle('fill', self:getX(), self:getY(), 2, 10);
        love.graphics.setColor(255, 255, 255, 35);
        love.graphics.print(name, self:getX() + 5, self:getY() + 5);
        love.graphics.setColor(255, 255, 255, 255);
        for _, file in pairs(files) do
            file:draw();
        end
        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 55);
            love.graphics.line(self:getX(), self:getY(), node:getX(), node:getY());
            love.graphics.setColor(255, 255, 255, 255);
            node:draw();
        end
    end

    function self:update(dt)
        for iA, fileA in pairs(files) do
            -- Attract files to their folder.
            fileA:attract(self, -0.008);

            for idB, fileB in pairs(files) do
                if fileA ~= fileB then
                    fileA:repel(fileB, 80000);
                end
            end

            fileA:damp(0.9);
            fileA:move(dt);
        end
    end

    function self:addFile(name, file)
        files[name] = file;
        fileCount = fileCount + 1;
    end

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getChild(name)
        return children[name];
    end

    function self:getChildren()
        return children;
    end

    function self:isConnectedTo(node)
        if parent == node then
            return true;
        end
        for _, v in pairs(children) do
            if node == v then
                return true;
            end
        end
    end

    function self:getMass()
        return 0.01 * childCount + 0.001 * math.max(1, fileCount);
    end

    return self;
end

return Folder;
