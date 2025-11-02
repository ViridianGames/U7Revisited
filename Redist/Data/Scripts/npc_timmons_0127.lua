--- Best guess: Manages Timmons's dialogue, a new fighter in Jhelom seeking to prove himself to Master De Snel at the Library of Scars by dueling Sprellic over the stolen honor flag, with flag-based combat triggers.
function npc_timmons_0127(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(127)
        end
        return
    end

    start_conversation()
    switch_talk_to(127)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule(127)
    var_0002 = get_npc_name(127)
    var_0003 = get_npc_name(126)
    var_0004 = get_npc_name(125)
    if not get_flag(377) then
        add_dialogue("You see a very serious young man. He carries himself like a learned and mannered gentleman.")
        set_flag(377, true)
    else
        add_dialogue("\"Dost thou wish to speak with me?\" asks Timmons.")
    end
    if not get_flag(360) and not get_flag(356) then
        add_dialogue("\"I see thou hast the honor flag. As little more than an interested third party in this affair, I ask thee to return the flag to Syria. Please do so.\"")
        return
    end
    if get_flag(368) then
        if var_0001 == 4 then
            add_dialogue("\"Well, " .. var_0000 .. ", I must prove myself to De Snel. If thou art the one who suffers, I will apologize, but I will not back down!\"")
            add_dialogue("\"Prepare to die!\"")
            utility_unknown_1041(100)
            set_alignment(3, var_0002)
            set_alignment(3, var_0003)
            set_alignment(3, var_0004)
            set_schedule_type(0, var_0002)
            set_schedule_type(0, var_0003)
            set_schedule_type(0, var_0004)
            return
        else
            add_dialogue("\"Well, " .. var_0000 .. ", I must prove myself to De Snel. If thou art the one who suffers, so be it! Meet us at the dueling area at next noon!\"")
        end
    end
    add_answer({"bye", "job", "name"})
    while true do
        if cmps("name") then
            add_dialogue("\"Timmons is my name, " .. var_0000 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"At the moment I have no job. I left all that behind in New Magincia. I have come to Jhelom to study under Master De Snel in the Library of Scars.\"")
            add_answer({"Library of Scars", "Jhelom"})
        elseif cmps("Jhelom") then
            add_dialogue("\"I am afraid I would not be able to help thee. I know little of this town, except for the duels. I am newly arrived here myself. Perhaps thou shouldst ask someone else.\"")
            add_answer("duels")
            remove_answer("Jhelom")
        elseif cmps("duels") then
            if not get_flag(356) then
                add_dialogue("\"I had heard of this man Sprellic who claims he is a greater fighter than any in the Library of Scars and how he had stolen the honor flag from their wall. So I sought this man out and challenged him to a duel myself.\"")
                add_answer("Library of Scars")
            else
                add_dialogue("\"Unfortunately, the duels with Sprellic were called off before I had the opportunity to impress Master De Snel.\"")
            end
            remove_answer("duels")
        elseif cmps("Library of Scars") then
            if not get_flag(356) then
                add_dialogue("\"A sailor on a ship at port in New Magincia first told me of the Library of Scars, of how it was the greatest fighting guild in Britannia and how its trainer, Master De Snel, had created the perfect fighting style. I immediately spent every coin I had to come here. But De Snel now refuses to accept me as a student. I know if I can defeat a fighter who claims to be better than anyone in the guild, and help restore its honor in the process, De Snel will have to finally accept me.\"")
            else
                add_dialogue("\"Master De Snel, the trainer at the Library of Scars, has refused me entry until I have proven myself in combat. The only way to prove oneself in combat in the town of Jhelom is by duelling. But my mother raised me to be a perfect gentleman. So far I have not succeeded in offending anyone sufficiently to have them challenge me to a duel. Hmmm. Perhaps I am just not suited to be a member of the Library of Scars.\"")
            end
            remove_answer("Library of Scars")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"It was a pleasure speaking to thee, " .. var_0000 .. ".\"")
end