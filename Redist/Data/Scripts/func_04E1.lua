--- Best guess: Manages Sintag’s dialogue in Buccaneer’s Den, a tough guard at the House of Games who distrusts Avatars and provides information about Hook and a torture chamber.
function func_04E1(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(0, 225)
        var_0000 = get_schedule()
        var_0001 = unknown_001CH(unknown_001BH(225))
        var_0002 = unknown_0931H(1, 359, 981, 1, 357)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(260) or get_flag(309) then
            add_answer("Hook")
        end
        if not get_flag(686) then
            add_dialogue("You see the meanest, toughest-looking guard you have ever seen in Britannia.")
            set_flag(686, true)
        else
            add_dialogue("\"What?\" Sintag grunts.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Sintag,\" the man grunts.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the guard at the House of Games. I rid the place of trouble-makers.\"")
                add_answer({"trouble-makers", "House of Games"})
            elseif answer == "House of Games" then
                add_dialogue("\"I have worked for the House of Games since The Mister agreed to pay me and asked me to stay. I know all who go in or out. I see everything.\"")
                remove_answer("House of Games")
                add_answer("The Mister")
            elseif answer == "The Mister" then
                add_dialogue("\"That would be Mister Gordy, the overseer of the House of Games. Thou might find him in his office during business hours.\"")
                remove_answer("The Mister")
            elseif answer == "trouble-makers" then
                add_dialogue("\"We see all sorts of trouble-makers in this place. I especially do not like people who claim that they are the Avatar. I find it blasphemous. The last fellow who claimed to be an Avatar was caught cheating. He'll not be doin' that again!\"")
                remove_answer("trouble-makers")
                add_answer({"not again", "all sorts"})
            elseif answer == "all sorts" then
                add_dialogue("\"There is a man named Robin who used to come in here and cheat at the games. He had his two varlets named Battles and Leavell intimidate anyone who tried to stop him. One day my brothers came to visit and we ran Robin, Battles and Leavell all the way off the island! We have not seen them since!\"")
                remove_answer("all sorts")
            elseif answer == "not again" then
                if var_0002 then
                    add_dialogue("The Cube vibrates a little. \"He is in the caverns, in the torture chamber. What's left of him.\"")
                    add_answer({"left of him", "torture chamber"})
                else
                    add_dialogue("\"Thou dost not need to know any more.\"")
                    add_dialogue("Sintag glares at you.")
                end
                remove_answer("not again")
            elseif answer == "torture chamber" then
                if var_0002 then
                    add_dialogue("The Cube vibrates. \"It is where The Fellowship interrogates their prisoners.\"")
                else
                    add_dialogue("\"What torture chamber? Did I say torture chamber?\"")
                end
                remove_answer("torture chamber")
            elseif answer == "left of him" then
                add_dialogue("\"He has been in our care for a while now.\" Sintag smiles enigmatically.")
                remove_answer("left of him")
            elseif answer == "Hook" then
                if var_0001 == 7 then
                    if var_0002 then
                        add_dialogue("The Cube vibrates as Sintag speaks. \"Hook lives in the cavern behind the House of Games. There is a locked door from the gaming room which leads there. I have the key. There is also a secret door in Gordy's office which Hook uses to get home.\"")
                        add_answer("key")
                    else
                        add_dialogue("\"I do not know any man by that description.\"")
                    end
                else
                    add_dialogue("\"Do I look like I am working now? Leave me alone. Come to the House of Games during normal business hours.\"")
                end
                remove_answer("Hook")
            elseif answer == "key" then
                add_dialogue("\"Dost thou want the key?\"")
                if unknown_090AH() then
                    var_0003 = unknown_002CH(false, 10, 234, 641, 1)
                    if var_0003 then
                        add_dialogue("\"Here it is.\"")
                        unknown_0911H(300)
                    else
                        add_dialogue("\"Thou art carrying too much!\"")
                    end
                else
                    add_dialogue("\"Suit thyself.\"")
                end
                remove_answer("key")
            elseif answer == "bye" then
                add_dialogue("Sintag grunts.")
                break
            end
        end
    elseif eventid == 0 then
        var_0001 = unknown_001CH(unknown_001BH(225))
        var_0004 = random2(4, 1)
        if var_0001 == 7 then
            if var_0004 == 1 then
                var_0005 = "@I am watching thine hands!@"
            elseif var_0004 == 2 then
                var_0005 = "@No cheating!@"
            elseif var_0004 == 3 then
                var_0005 = "@Keep thine hands where I can see 'em.@"
            elseif var_0004 == 4 then
                var_0005 = "@No funny stuff with the games.@"
            end
            bark(var_0005, 225)
        else
            return
        end
    end
    return
end