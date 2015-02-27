--==================================================================================================
-- Copyright (C) 2014 - 2015 by Robert Machmer                                                     =
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

local ExtensionHandler = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local extensions = {};
local totalFiles = 0;
local colors;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Splits the extension from a file.
-- @param fileName
--
local function splitExtension(fileName)
    local tmp = fileName:reverse();
    local pos = tmp:find('%.');
    if pos then
        return tmp:sub(1, pos):reverse():lower();
    else
        -- Prevents issues with files sans extension.
        return '.?';
    end
end

-- ------------------------------------------------
-- Global Functions
-- ------------------------------------------------

---
-- Draws a list of all authors working on the project.
--
function ExtensionHandler.draw()
    local count = 0;
    love.graphics.print(totalFiles, love.graphics.getWidth() - 120, 20);
    love.graphics.print('Files', love.graphics.getWidth() - 80, 20);
    for ext, tbl in pairs(extensions) do
        count = count + 1;
        love.graphics.setColor(tbl.color);
        love.graphics.print(ext, love.graphics.getWidth() - 80, 20 + count * 20);
        love.graphics.print(tbl.amount, love.graphics.getWidth() - 120, 20 + count * 20);
        love.graphics.setColor(255, 255, 255);
    end
end

---
-- Adds a new file extension to the list.
-- @param fileName
--
function ExtensionHandler.add(fileName)
    local ext = splitExtension(fileName);
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].amount = 0;
        extensions[ext].color = colors[ext] or { love.math.random(0, 255), love.math.random(0, 255), love.math.random(0, 255) };
    end
    extensions[ext].amount = extensions[ext].amount + 1;
    totalFiles = totalFiles + 1;

    return extensions[ext].color;
end

function ExtensionHandler.reset()
    extensions = {};
    totalFiles = 0;
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function ExtensionHandler.setColorTable(cltbl)
    colors = cltbl;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- @param ext
--
function ExtensionHandler.getColor(ext)
    return extensions[ext].color;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ExtensionHandler;
