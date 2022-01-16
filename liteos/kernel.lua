local api = require('api')
local koroutine = coroutine
local kprint = print
local user_print_cache = {}

local function user_print(...)
    local xt = {}
    for i, v in ipairs(table.pack(...)) do
        table.insert(xt, tostring(v))
    end
    table.insert(user_print_cache, table.concat(xt, ' '))
    kprint(...)
end

local ucoroutine = {}
local uco_pool = {}
local uco_upper = nil
local uco_next = nil
setmetatable(uco_pool, {__mode = "k"})

ucoroutine.create = function (f)
    local uco = koroutine.create(f)
    uco_pool[uco] = {}
    return uco
end

ucoroutine.running = function ()
    return koroutine.running()
end

ucoroutine.isyieldable = function ()
    return uco_pool[ucoroutine.running()].upper ~= nil
end

ucoroutine.resume = function (uco, ...)
    uco_pool[uco].upper = uco_upper
    uco_next = uco
    return koroutine.yield(1, table.pack(...))
end

ucoroutine.status = function (uco)
    return koroutine.status(uco)
end

ucoroutine.wrap = function (f)
    
end

ucoroutine.yield = function (...)
    uco_next = uco_pool[ucoroutine.running()].upper
    return koroutine.yield(2, table.pack(...))
end

function KSchedule(entry_uco)
    uco_next = entry_uco
    local uco_next_args = {}

    while true do
        uco_upper = uco_next
        local ret = table.pack(koroutine.resume(uco_next, table.unpack(uco_next_args)))
        if not ret[1] then
            if uco_pool[uco_upper].upper ~= nil then
                -- pop error back to resume caller
                uco_next = uco_pool[uco_upper].upper
                uco_next_args = table.pack(false, ret[2])
            else
                -- kernel return to caller, this should be a top-level one
                return false, ret[2]
            end
        elseif koroutine.status(uco_upper) == "dead" then
            if uco_pool[uco_upper].upper ~= nil then
                uco_next = uco_pool[uco_upper].upper
                uco_next_args = table.pack(true, ret[3] and table.unpack(ret[3]) or nil)
            else
                return true, ret[3] and table.unpack(ret[3]) or nil
            end
        else
            if ret[2] == 1 then -- resume from something
                uco_next_args = ret[3]
            elseif ret[2] == 2 then -- yield from something
                uco_next_args = table.pack(true, table.unpack(ret[3]))
            else -- c function call
                -- handle print here
                api.print(table.concat(user_print_cache, '\n'))
                user_print_cache = {}
                koroutine.yield()
                uco_next_args = {}
                -- keep uco_next untouch, resume in next loop
            end
        end
    end
end

_G.coroutine = ucoroutine
_G.print = user_print

return {
    koroutine = koroutine,
    kprint = kprint
}
