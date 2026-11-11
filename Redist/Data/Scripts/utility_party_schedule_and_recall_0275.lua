--- Func0613. Recall the party to the location stored on this virtue stone.
--- The original also forced every party member onto schedule 0x1F. The party
--- is placed by recall_virtue_stone, which clears the Codex attunement flag.
function utility_party_schedule_and_recall_0275(eventid, objectref)
    recall_virtue_stone(objectref)
end
