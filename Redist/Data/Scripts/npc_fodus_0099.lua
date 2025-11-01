--- Best guess: Handles dialogue with Fodus, a sick gargoyle miner in the Minoc mine, discussing his job, the “secret ore” (blackrock), and his need for “silver fluid” (possibly venom), revealing delirious insights into mine operations.
function npc_fodus_0099(eventid, objectref)
    local var_0000

    start_conversation()
    if eventid == 0 then
        abort()
    end
    if eventid == 1 then
        switch_talk_to(99, 0)
        var_0000 = get_lord_or_lady()
        if not get_flag(285) then
            add_dialogue("You see a wingless gargoyle with a terrible skin disease. It looks as if his face is falling off in patches.")
            set_flag(285, true)
        else
            add_dialogue("\"To want something else?\" Fodus asks.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"To be named Fodus.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"To be a digger in the mines. To be looking for iron ore and lead and...\"")
                add_answer("and...")
            elseif var_0001 == "and..." then
                add_dialogue("\"The secret ore...\"")
                add_dialogue("A wave of delirium passes over the gargoyle. \"To... to be going back to work now, Mikos!... To be working hard!... To have no need to give me any more of the silver fluid...\"")
                set_flag(263, true)
                remove_answer("and...")
                add_answer({"silver fluid", "secret ore"})
            elseif var_0001 == "secret ore" then
                add_dialogue("\"To be called... blackrock.\"")
                remove_answer("secret ore")
                add_answer("blackrock")
            elseif var_0001 == "blackrock" then
                add_dialogue("\"To be the lode located in a hidden area of the mine...\" The gargoyle's eyes roll up into his head. He is obviously sick.")
                remove_answer("blackrock")
            elseif var_0001 == "silver fluid" then
                add_dialogue("\"To need the venom... to have more venom...\"")
                remove_answer("silver fluid")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"To be going back to work now, Mikos...\"")
    end
end