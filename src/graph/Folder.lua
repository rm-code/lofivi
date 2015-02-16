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

local Folder = {};

function Folder.new(name, x, y)
    local self = {};

    local px, py = x, y; -- Position vector.

    local files = {};
    local fileCount = 0;
    local children = {};
    local childCount = 0;

    local function attract(file, x2, y2, spring)
        local dx, dy = file:getX() - x2, file:getY() - y2;
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 100));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate spring force and apply it.
        local force = spring * distance;
        file:applyForce(dx * force, dy * force);
    end

    local function repulse(fileA, fileB, charge)
        -- Calculate distance vector.
        local dx, dy = fileA:getX() - fileB:getX(), fileA:getY() - fileB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 1000));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate force's strength and apply it to the vector.
        local strength = charge * ((fileA:getMass() * fileB:getMass()) / (distance * distance));
        dx = dx * strength;
        dy = dy * strength;

        fileA:applyForce(dx, dy);
    end

    function self:draw()
        love.graphics.circle('fill', px, py, 2, 10);
        love.graphics.print(name, px + 15, py + 15);
        for _, file in pairs(files) do
            file:draw();
        end
        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 35);
            love.graphics.line(px, py, node:getX(), node:getY());
            love.graphics.setColor(255, 255, 255, 255);
            node:draw();
        end
    end

    function self:update(dt)
        for iA, fileA in pairs(files) do
            -- Attract files to their folder.
            attract(fileA, px, py, -0.001);

            for idB, fileB in pairs(files) do
                if fileA ~= fileB then
                    repulse(fileA, fileB, 80000);
                end
            end

            fileA:damp(0.9);
            fileA:update(dt);
        end
        for _, node in pairs(children) do
            node:update(dt);
        end
    end

    function self:addFile(name, file)
        files[name] = file;
        fileCount = fileCount + 1;
    end

    function self:getChild(name)
        return children[name];
    end

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    return self;
end

return Folder;
