local ExtensionHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LIST_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 14);
local DEFAULT_FONT = love.graphics.newFont(12);

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
-- Adds a new file extension to the list.
-- @param fileName
--
function ExtensionHandler.add(fileName)
    local ext = splitExtension(fileName);
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].count = 0;
        extensions[ext].color = colors[ext] or { love.math.random(0, 255), love.math.random(0, 255), love.math.random(0, 255) };
    end
    extensions[ext].count = extensions[ext].count + 1;
    totalFiles = totalFiles + 1;

    return extensions[ext].color, ext;
end

function ExtensionHandler.reset()
    extensions = {};
    totalFiles = 0;
end

function ExtensionHandler.createCanvas()
    local toSort = {};
    for ext, tbl in pairs(extensions) do
        toSort[#toSort + 1] = { count = tbl.count, color = tbl.color, extension = ext };
    end
    table.sort(toSort, function(a, b)
        return a.count > b.count;
    end)

    local width = 150;
    local height = 20 + #toSort * 20;

    local canvas = love.graphics.newCanvas(width, height);
    canvas:renderTo(function()
        love.graphics.setBlendMode('alpha');
        love.graphics.setFont(LIST_FONT);
        love.graphics.print(string.format('%5.d %s', totalFiles, 'Files', 0, 20));
        for i = 1, #toSort do
            love.graphics.setColor(toSort[i].color);
            love.graphics.print(string.format('%5.d %s', toSort[i].count, toSort[i].extension), 0, i * 20);
            love.graphics.setColor(255, 255, 255);
        end
        love.graphics.setBlendMode('alpha');
        love.graphics.setFont(DEFAULT_FONT);
    end);

    return canvas;
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
