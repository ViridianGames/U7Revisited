--- Best guess: Manages Yongi’s dialogue in Vesper, a tavern keeper at the Gilded Lizard with strong anti-gargoyle sentiments.
function func_04CF(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000D

    if eventid == 1 then
        switch_talk_to(0, 207)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = "the Avatar"
        var_0003 = unknown_08F7H(4)
        var_0004 = false
        var_0005 = false
        var_0006 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not var_0003 then
            add_dialogue("\"Ah, me good friend, Dupre. What kinna do fer ye this fine day?\"")
            switch_talk_to(0, 4)
            add_dialogue("\"Ah, master Yongi, always ready to offer a tankard of thy finest.\"")
            hide_npc(4)
            switch_talk_to(0, 207)
        end
        if not get_flag(652) then
            add_dialogue("Tending the bar is a jovial-looking man. \"Welcome ta the Gilded Lizard.\"")
            var_0006 = true
            set_flag(652, true)
        else
            add_dialogue("\"Welcome back ta the Gilded Lizard. What may I do fer ye?\" asks Yongi.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Me name is Yongi, \" .. var_0001 .. \".\"")
                remove_answer("name")
                if not var_0006 then
                    add_dialogue("\"And ye are?\"")
                    var_0007 = unknown_090BH({var_0001, var_0002, var_0000})
                    if var_0007 == var_0002 then
                        add_dialogue("\"Aye, \" .. var_0001 .. \". Right ye are. If ye dinna care ta tell me, I don't mind a bit.\" He winks.")
                    elseif var_0007 == var_0000 then
                        add_dialogue("\"Welcome ta me tavern, \" .. var_0000 .. \".\"")
                    elseif var_0007 == var_0001 then
                        add_dialogue("\"Right ye are, \" .. var_0001 .. \". There's no need ta tell anyone yer name.\"")
                    end
                end
            elseif answer == "job" then
                add_dialogue("\"Why, I tend me bar. And lend me ear ta the customers,\" he adds, touching his right ear for emphasis.")
                add_answer({"buy", "customers"})
            elseif answer == "Vesper" then
                add_dialogue("\"Why, I wouldna wanna live anyplace else. 'Course, this town would be a better place if we could rid ourselves of those jackals, the gargoyles.\"")
                if not var_0005 then
                    add_answer("gargoyles")
                end
                remove_answer("Vesper")
            elseif answer == "gargoyles" then
                add_dialogue("\"Gargoyles! What about them? They be the vilest, evilest, cruelest, most despicable things ever ta crawl upon this great land. I kinna tell ye too well ta stay away from them. I kin only imagine whata fine town this'd be if there weren't na more gargoyles. 'Course, I know those dogs are probably sayin' the same about us. Everybody knows they're gonna come an' kill allus in our sleep one evenin'.\"")
                if not var_0004 then
                    add_dialogue("\"Why, only the other day one attacked Blorn. G'won, ask him about it.\"")
                    var_0004 = true
                    add_answer("Blorn")
                end
                var_0005 = true
                remove_answer("gargoyles")
                set_flag(643, true)
            elseif answer == "customers" then
                add_dialogue("\"Well, all I really know in Vesper are me regulars: Cador, Mara, and Blorn. Ye might be wantin' ta talk to Auston, the mayor, or his clerk, Liana. Ah, now there's a fine, young lass.\" He winks at you.")
                add_answer({"Vesper", "Blorn", "Mara", "Cador"})
                remove_answer("customers")
            elseif answer == "Cador" then
                var_0008 = unknown_0037H(unknown_001BH(203))
                if var_0008 then
                    add_dialogue("\"He used ta come here every night, 'til he was killed in a brawl.\" The bartender's eyes narrow as he talks.")
                else
                    add_dialogue("\"He be in here every night after work. Good man, hard worker.\"")
                end
                remove_answer("Cador")
            elseif answer == "Mara" then
                var_0009 = unknown_0037H(unknown_001BH(204))
                if var_0009 then
                    add_dialogue("\"She worked with Cador at the mines. She was more man than most men, that one was. An' she died like it, too -- in a brawl here at the tavern!\" He says, eyeing you suspiciously.")
                else
                    add_dialogue("\"She works with Cador at the mines. Hard as stone, that one. She be more man than most of the men in town.\"")
                end
                remove_answer("Mara")
            elseif answer == "Blorn" then
                add_dialogue("\"There be one who knows what's what. He knows what be wrong with this town! Gargoyles! That is what be wrong. He hates 'em, 'e does.\"")
                if not var_0004 then
                    add_dialogue("\"He was even accosted by one of those jackals not too long ago. Ask 'im about it, why don't ye.\"")
                    var_0004 = true
                end
                if not get_flag(643) and not var_0005 then
                    add_answer("gargoyles")
                end
                remove_answer("Blorn")
                set_flag(643, true)
            elseif answer == "buy" then
                add_dialogue("\"Be ye wantin' food or drink?\"")
                add_answer({"drink", "food"})
                remove_answer("buy")
            elseif answer == "food" then
                unknown_094DH()
                remove_answer("food")
            elseif answer == "drink" then
                unknown_094EH()
                remove_answer("drink")
            elseif answer == "bye" then
                add_dialogue("\"May the road rise up ta meet ye!\"")
                break
            end
        end
    elseif eventid == 0 then
        var_000A = unknown_003BH()
        var_000B = unknown_001CH(unknown_001BH(207))
        var_000C = random(4, 1)
        if var_000A >= 1 and var_000A <= 3 and var_000B == 14 then
            var_000D = "@Zzzzz . . .@"
        elseif (var_000A == 4 or var_000A == 5 or var_000A == 6 or var_000A == 7 or var_000A == 0) and var_000B == 11 then
            if var_000C == 1 then
                var_000D = "@Refreshments here!@"
            elseif var_000C == 2 then
                var_000D = "@Get a fine cup o' wine here!@"
            elseif var_000C == 3 then
                var_000D = "@We have the best spirits here!@"
            elseif var_000C == 4 then
                var_000D = "@No gargoyles allowed!@"
            end
        end
        bark(var_000D, 207)
    end
    return
end