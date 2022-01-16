local strings = {}

strings.split = function(s, sep)
    local parts = {}
    for match in (s .. sep):gmatch("(.-)" .. sep) do
        table.insert(parts, match)
    end
    return parts
end

return strings
