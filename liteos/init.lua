local koroutine = require('liteos/kernel').koroutine
local kprint = require('liteos/kernel').kprint
local api = require('api')
local entry_table = {}

local function main_entry()
    if not entry_table.entry then return end
    local user_entry = coroutine.create(entry_table.entry)
    local ret = table.pack(KSchedule(user_entry))
    if not ret[1] then
        error(table.concat({'user code error: ', ret[2]}))
    end
end

local function lib_main_entry()
    local user_bt
    local ok, user_error = xpcall(main_entry, function (err)
        user_bt = debug.traceback()
        return err
    end)
    if not ok then
        kprint('main_entry error:', user_error)
        kprint('main_entry stack:', user_bt)
        api.print(string.format('LuaRuntime error: %s Error stack: %s', user_error, user_bt))
        koroutine.yield()  -- yield to perform print, skipped kernel pre-yield as we are not in kernel
    end
    _G._main_entry = nil
end

local entry_cofunc = koroutine.wrap(lib_main_entry)
_G._main_entry = entry_cofunc

return entry_table
