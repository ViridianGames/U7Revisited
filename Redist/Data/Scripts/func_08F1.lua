-- Function 08F1: Manages insult generation
function func_08F1(local0)
    -- Local variables (2 as per .localc)
    local local1, local2

    local1 = {"coward", "toad", "snake", "scoundrel", "wretch", "deceiver", "viper"}
    local2 = local0
    while local2 == local0 do
        local2 = local1[callis_0010(callis_005E(local1), 1)]
    end
    return local2
end