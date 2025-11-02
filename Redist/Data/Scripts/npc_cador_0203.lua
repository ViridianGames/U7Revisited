--- Best guess: Manages Cador's dialogue in Vesper, a mining overseer with mixed feelings about gargoyles and pride in The Fellowship.
function npc_cador_0203(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(203)
        var_0000 = get_lord_or_lady()
        var_0001 = get_player_name()
        var_0002 = "the Avatar"
        var_0003 = get_schedule(203)
        var_0004 = get_npc_name(203)
        var_0005 = get_npc_name(204)
        var_0006 = get_schedule_type(var_0004)
        var_0007 = get_alignment(var_0004)
        start_conversation()
        add_answer({"Fellowship", "bye", "job", "name"})
        if var_0007 == 2 then
            set_schedule_type(0, var_0004)
            set_schedule_type(0, var_0005)
        end
        if get_flag(644) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(648) then
            add_dialogue("You see a broad-shouldered man with a solemn look about him.")
            set_flag(648, true)
        else
            add_dialogue("\"Yes, \" .. var_0000 .. \"?\" says Cador.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The man shakes your hand. \"I am Cador.\"")
                if var_0006 == 26 then
                    add_dialogue("\"And thy name is?\"")
                    var_0008 = utility_unknown_1035({var_0000, var_0002, var_0001})
                    if var_0008 == var_0002 then
                        add_dialogue("\"What? Dost thou mean to tell me that thou art the one who brought those gargoyles to our precious land?\" He turns quite angry.")
                        add_dialogue("\"Daemon lover!\"")
                        set_schedule_type(0, var_0004)
                        set_alignment(2, var_0004)
                        set_schedule_type(0, var_0005)
                        set_alignment(2, var_0005)
                        return
                    else
                        add_dialogue("\"I am happy to make thine acquaintance, \" .. var_0000 .. \".\"")
                    end
                end
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I oversee the local branch of the Britannian Mining Company in Vesper. We mine many different minerals.\"")
                add_answer({"minerals", "We", "Vesper"})
            elseif answer == "minerals" then
                add_dialogue("\"Gold and lead.\"")
                remove_answer("minerals")
            elseif answer == "Vesper" then
                add_dialogue("\"That is the name of our town. Liana at town hall can give thee any more information that thou mightest need, but I have lived here with my family since the branch opened.\"")
                add_answer({"family", "Liana"})
                remove_answer("Vesper")
            elseif answer == "Fellowship" then
                add_dialogue("\"It is a wonderful organization. They perform many works of charity and special events -- parades and such.\"  He points to his medallion. \"As thou canst see, I am a member. I fully believe in the triad of inner strength.\"")
                if get_flag(644) then
                    add_dialogue("\"As a matter of fact, two Fellowship officials were just here. They said it was important to see how a town's economy worked before starting a branch in that town. Dost thou realize what that means?\" He smiles proudly. \"They are going to build a Fellowship branch here in Vesper.\"")
                end
                add_answer("triad")
                remove_answer("Fellowship")
            elseif answer == "triad" then
                add_dialogue("\"Those are The Fellowship's three basic principles: Strive for Unity, Trust thy Brother, and Worthiness Precedes Reward.\"")
                remove_answer("triad")
            elseif answer == "Elizabeth and Abraham" then
                add_dialogue("\"They were the two Fellowship officials that were here! They only stayed for a minute or two. I have no idea where they are now.\"")
                remove_answer("Elizabeth and Abraham")
            elseif answer == "We" then
                add_dialogue("\"I work with Mara and a gargoyle named Lap-Lem.\"")
                add_answer({"Lap-Lem", "Mara"})
                remove_answer("We")
            elseif answer == "Mara" then
                add_dialogue("\"She is a fantastic worker. Better than most men I have mined with.\"")
                remove_answer("Mara")
            elseif answer == "Lap-Lem" then
                add_dialogue("\"Well, for a gargoyle, he is not too lazy. He works much harder than that other one who left, Anmanivas. But I would fain let him go if we did not need the extra hand.\"")
                remove_answer("Lap-Lem")
            elseif answer == "Liana" then
                add_dialogue("\"She keeps the records at town hall.\"")
                remove_answer("Liana")
            elseif answer == "family" then
                add_dialogue("\"Yes, my wife, Yvella, and my daughter, Catherine.\"")
                remove_answer("family")
            elseif answer == "bye" then
                add_dialogue("\"It has been a pleasure, \" .. var_0000 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end