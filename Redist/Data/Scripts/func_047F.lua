-- Manages Timmons's dialogue in Jhelom, covering his ambition to join De Snel's guild and Sprellic's duel.
function func_047F(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 1 then
        switch_talk_to(127, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = get_item_type(-127)
        local3 = get_item_type(-126)
        local4 = get_item_type(-125)

        add_answer({"bye", "job", "name"})

        if not get_flag(360) and not get_flag(356) then
            say("\"I see thou hast the honor flag. As little more than an interested third party in this affair, I ask thee to return the flag to Syria. Please do so.\"*")
            return
        elseif get_flag(368) then
            if local1 == 4 then
                say("\"Well, " .. local0 .. ", I must prove myself to De Snel. If thou art the one who suffers, I will apologize, but I will not back down!\"")
                say("\"Prepare to die!\"*")
                apply_effect(100) -- Unmapped intrinsic 0911
                set_schedule(3, local2)
                set_schedule(3, local3)
                set_schedule(3, local4)
                set_schedule(0, local2)
                set_schedule(0, local3)
                set_schedule(0, local4)
                return
            else
                say("\"Well, " .. local0 .. ", I must prove myself to De Snel. If thou art the one who suffers, so be it! Meet us at the dueling area at next noon!\"*")
            end
        end

        if not get_flag(377) then
            say("You see a very serious young man. He carries himself like a learned and mannered gentleman.")
            set_flag(377, true)
        else
            say("\"Dost thou wish to speak with me?\" asks Timmons.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Timmons is my name, " .. local0 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"At the moment I have no job. I left all that behind in New Magincia. I have come to Jhelom to study under Master De Snel in the Library of Scars.\"")
                add_answer({"Library of Scars", "Jhelom"})
            elseif answer == "Jhelom" then
                say("\"I am afraid I would not be able to help thee. I know little of this town, except for the duels. I am newly arrived here myself. Perhaps thou shouldst ask someone else.\"")
                add_answer("duels")
                remove_answer("Jhelom")
            elseif answer == "duels" then
                if not get_flag(356) then
                    say("\"I had heard of this man Sprellic who claims he is a greater fighter than any in the Library of Scars and how he had stolen the honor flag from their wall. So I sought this man out and challenged him to a duel myself.\"")
                    add_answer("Library of Scars")
                else
                    say("\"Unfortunately, the duels with Sprellic were called off before I had the opportunity to impress Master De Snel.\"")
                end
                remove_answer("duels")
            elseif answer == "Library of Scars" then
                if not get_flag(356) then
                    say("\"A sailor on a ship at port in New Magincia first told me of the Library of Scars, of how it was the greatest fighting guild in Britannia and how its trainer, Master De Snel, had created the perfect fighting style. I immediately spent every coin I had to come here. But De Snel now refuses to accept me as a student. I know if I can defeat a fighter who claims to be better than anyone in the guild, and help restore its honor in the process, De Snel will have to finally accept me.\"")
                else
                    say("\"Master De Snel, the trainer at the Library of Scars, has refused me entry until I have proven myself in combat. The only way to prove oneself in combat in the town of Jhelom is by duelling. But my mother raised me to be a perfect gentleman. So far I have not succeeded in offending anyone sufficiently to have them challenge me to a duel. Hmmm. Perhaps I am just not suited to be a member of the Library of Scars.\"")
                end
                remove_answer("Library of Scars")
            elseif answer == "bye" then
                say("\"It was a pleasure speaking to thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(127)
    end
    return
end