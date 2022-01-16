local function table_copy(st)
    if not st then return nil end

    local t = {}
    for k, v in pairs(st) do
        t[k] = v
    end
    return t
end

local function co_resume(co, ...)
    local ret = table.pack(coroutine.resume(co, ...))
    if check_deadline() then coroutine.yield() end
    return table.unpack(ret)
end

local function co_wrap(fn)
    local co = coroutine.create(fn)
    return function(...)
        local ret = table.pack(co_resume(co, ...))
        if ret[1] then
            return table.unpack(ret, 2)
        else
            coroutine.close(co)
            error(ret[2], 2)
        end
    end
end

-- Isolate env for user code
local newG = {
    assert = assert,
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawlen = rawlen,
    rawset = rawset,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    warn = warn,
    xpcall = xpcall,
    require = require,

    math = table_copy(math),
    string = table_copy(string),
    table = table_copy(table),
    utf8 = table_copy(utf8),
    coroutine = table_copy(coroutine),
    debug = {
        traceback = debug.traceback,
    },
}

newG.coroutine.resume = co_resume
newG.coroutine.wrap = co_wrap

newG._G = newG

return newG
