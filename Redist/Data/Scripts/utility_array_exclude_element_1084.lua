--- Filter a 1-based array, returning a new table with `exclude` removed.
--- Used by party-introduction and a few object scripts.
function utility_unknown_1084(list, exclude)
    local result = {}
    if type(list) ~= "table" then
        return result
    end
    for _, value in ipairs(list) do
        if value ~= exclude then
            table.insert(result, value)
        end
    end
    return result
end
