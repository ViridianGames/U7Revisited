--- Old decompile name for Recall (script 356). The spellbook prefers
--- spell_kal_ort_por_0356. This wrapper keeps a direct call from destroying the caster.
function utility_spellteleport_0356(eventid, objectref)
    if eventid == 1 then
        spell_kal_ort_por_0356(eventid, objectref)
    end
end
