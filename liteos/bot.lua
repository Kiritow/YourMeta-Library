local koroutine = require('liteos/kernel').koroutine
local api = require('api')
local bot = {}

-- Bot API
bot.up = function()
    api.move(0, -1)
    koroutine.yield(0)
end

bot.down = function()
    api.move(0, 1)
    koroutine.yield(0)
end

bot.left = function()
    api.move(-1, 0)
    koroutine.yield(0)
end

bot.right = function()
    api.move(0, 1)
    koroutine.yield(0)
end

bot.shutdown = function()
    api.shutdown()
    koroutine.yield(0)
end

bot.broadcast = function(rad, msg)
    api.broadcast(rad, msg)
    koroutine.yield(0)
end

bot.sendto = function(x, y, rad, msg)
    api.sendto(x, y, rad, msg)
    koroutine.yield(0)
end

bot.read = api.getmsgcache

bot.wait = function()
    while api.getmsgcache() == nil do
        koroutine.yield(0)
    end
    return api.getmsgcache()
end

bot.getpos = api.getpos

bot.gethp = api.gethp

bot.getpower = api.getpower

bot.sleep = function(ntick)
    local xtick = ntick
    if not xtick or xtick < 1 then
        xtick = 1
    end
    for i=0, xtick do
        koroutine.yield(0)
    end
end

bot.moveTo = function (tx, ty, max_step)
    local cx, cy = bot.getpos()
    local total = 0
    
    while cx ~= tx or cy ~= ty do
        local choice = 0
        if cx ~= tx and cy ~= ty then
            choice = math.random(0, 100) < 50 and 0 or 1
        elseif cx ~= tx then
            choice = 0
        else
            choice = 1
        end

        if choice then
            if (ty - cy) < 0 then
                bot.up()
            else
                bot.down()
            end
        else
            if (tx - cx) < 0 then
                bot.left()
            else
                bot.right()
            end
        end

        total = total + 1
        if max_step and total >= max_step then break end
    end

    return total
end

return bot
