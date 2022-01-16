local util = {}

util.checkArg = function(n, value, type1, ...)
    if type(value) == type1 then return end
    for x, typex in ipairs(table.pack(...)) do
        if type(value) == typex then return end
    end
    error(string.format("bad argument #%d (%s expected, got %s)", n, type1, type(value)), 2)
end

return util
