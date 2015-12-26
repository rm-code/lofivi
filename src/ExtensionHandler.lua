local ExtensionHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

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

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function ExtensionHandler.setColorTable(cltbl)
    colors = cltbl;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function ExtensionHandler.getFiles()
    local toSort = {};
    for ext, tbl in pairs(extensions) do
        toSort[#toSort + 1] = { count = tbl.count, color = tbl.color, extension = ext };
    end
    table.sort(toSort, function(a, b)
        return a.count > b.count;
    end)
    return toSort;
end

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
