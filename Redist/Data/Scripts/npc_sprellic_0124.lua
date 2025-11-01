--- Best guess: Manages Sprellic's dialogue, the timid innkeeper of The Bunk and Stool in Jhelom, discussing his predicament with stolen honor flag and impending duels, with flag-based resolutions and a detailed story.
function npc_sprellic_0124(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(124)
        end
        return
    end

    start_conversation()
    switch_talk_to(124)
    var_0000 = get_lord_or_lady()
    var_0001 = is_player_wearing_fellowship_medallion()
    var_0002 = false
    var_0003 = is_dead(get_npc_name(125))
    var_0004 = is_dead(get_npc_name(126))
    var_0005 = is_dead(get_npc_name(127))
    if var_0003 and var_0004 and var_0005 then
        var_0002 = true
    end
    if not get_flag(360) and not get_flag(362) then
        add_answer("I have false flag")
    end
    if var_0002 or get_flag(362) then
        add_answer("thou art safe now")
        remove_answer("I have false flag")
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(376) then
        add_dialogue("You see a scrawny and timid-looking man who eyes you fearfully.")
        add_dialogue("\"Oh, my!\" he cries. \"'Tis really the Avatar this time! Please do not hurt me, Avatar!\"")
        set_flag(376, true)
        add_answer("this time")
    else
        add_dialogue("\"Greetings again, " .. var_0000 .. ",\" says Sprellic.")
    end
    if not get_flag(390) and not get_flag(368) and not get_flag(362) then
        add_answer("champion")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Sprellic.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the proprietor of the Bunk and Stool here in Jhelom.\"")
            add_answer({"Jhelom", "Bunk and Stool"})
        elseif cmps("Bunk and Stool") then
            add_dialogue("\"It is the local inn where all the fighters from the Library of Scars come to drink. They would wreck the place every night if not for Ophelia and Daphne.\"")
            if not get_flag(362) and not var_0002 then
                add_dialogue("\"But that does not matter for soon I will be dead.\"")
                add_answer("dead?")
            end
            remove_answer("Bunk and Stool")
            add_answer({"Daphne", "Ophelia", "Library of Scars"})
        elseif cmps("Jhelom") then
            add_dialogue("\"This is a town of fighters who pass their time fighting each other in bloody duels. It is no place for me. I should never have left Minoc!\"")
            remove_answer("Jhelom")
        elseif cmps("Library of Scars") then
            add_dialogue("\"It is the club of fighters run by Master De Snel! Second home to the fiercest and most ruthless fighters in all of Britannia.\"")
            remove_answer("Library of Scars")
        elseif cmps("Ophelia") then
            add_dialogue("\"Ophelia is one of my barmaids. She is gorgeous. If Daphne cannot handle our patrons when they become unruly, Ophelia will simply charm them.\"")
            remove_answer("Ophelia")
        elseif cmps("Daphne") then
            add_dialogue("\"Daphne is one of my barmaids. She is, ahem, rather large. If Ophelia cannot charm our patrons when they become unruly, Daphne wrestles them to the ground.\"")
            remove_answer("Daphne")
        elseif cmps({"dead?", "this time"}) then
            add_dialogue("\"'Tis a long story. I shall probably be dead before I can finish it.\"")
            remove_answer({"dead?", "this time"})
            add_answer("story")
        elseif cmps("story") then
            add_dialogue("\"My tale is a strange one. It may disturb and puzzle thee. Art thou certain thou wouldst like to hear it?\"")
            var_0006 = ask_yes_no()
            if not var_0006 then
                add_dialogue("\"Well, then I hope I was of some assistance to thee. Farewell forever, " .. var_0000 .. ".\"")
                return
            end
            add_dialogue("\"It all started the previous evening. I had given Ophelia and Daphne the evening off. A stranger had come to mine inn... A very odd stranger.\"")
            add_dialogue("\"He... he claimed he was the -Avatar-!\"")
            add_dialogue("\"...And I believed him, which shows thee how gullible I am!\"")
            add_answer("stranger")
            remove_answer("story")
        elseif cmps("stranger") then
            add_dialogue("\"His eccentricity seemed to be surpassed only by his wealth. He booked both rooms in the inn so that he could try each bed and decide for himself which one was the most comfortable. As for food, he was voracious.\"")
            if var_0001 then
                add_dialogue("\"No offense, but he was also a member of The Fellowship!\"")
            else
                add_dialogue("\"He was a member of The Fellowship, too!\"")
            end
            remove_answer("stranger")
            add_answer({"food", "eccentricity"})
        elseif cmps("eccentricity") then
            add_dialogue("\"I fear that this stranger was not who he claimed to be at all. I was a victim of a great and terrible deception that was perpetrated upon me.\"")
            remove_answer("eccentricity")
        elseif cmps("food") then
            add_dialogue("\"This stranger ordered one of every kind of food and drink on the menu. So if he ever wanted anything, it would be right there to eat. I was cooking for hours. But then it got worse. He went to bed.\"")
            remove_answer("food")
            add_answer({"bed", "cooking"})
        elseif cmps("cooking") then
            add_dialogue("\"Of course most of the food he left was uneaten! I had to give it away once it started to spoil!\"")
            remove_answer("cooking")
        elseif cmps("bed") then
            add_dialogue("\"After he went to bed, he complained that he was too cold. I brought him more and more blankets, but it was not enough. Finally, he had every blanket in the inn. And he was still cold!\"")
            remove_answer("bed")
            add_answer("cold")
        elseif cmps("cold") then
            add_dialogue("\"In desperation I ran down the street. It was the middle of the night. All of the shops were closed. The only thing I could find was some sort of old tapestry hanging on a wall. So I took it down.\"")
            remove_answer("cold")
            add_answer({"tapestry", "night"})
        elseif cmps("night") then
            add_dialogue("\"Actually, now as I recall being out in the night air, it was a quite tolerable evening. Alas, I was oblivious to little else but the prospect of earning a goodly sum in the service of the stranger. Woe is me!\"")
            remove_answer("night")
        elseif cmps("tapestry") then
            add_dialogue("\"The next thing I remember there was an angry woman chasing after me. For some reason she wanted to kill me! I managed to get away from her and get back to the inn and cover the stranger with the tapestry. Finally he fell asleep.\"")
            remove_answer("tapestry")
            add_answer({"asleep", "angry woman"})
        elseif cmps("angry woman") then
            add_dialogue("\"Actually, I had seen this angry woman before. She would enter mine establishment upon occasion. Unfortunately, this was our first formal acquaintance.\"")
            remove_answer("angry woman")
        elseif cmps("asleep") then
            add_dialogue("\"I also fell asleep, only I slept late. When I awoke the guest was gone. He had not paid his bill and had taken all the blankets, even the tapestry. Before I could go look for him I had a visitor.\"")
            remove_answer("asleep")
            add_answer({"visitor", "gone"})
        elseif cmps("gone") then
            add_dialogue("\"As I have said, I was rooked by a professional. A Master Criminal, no doubt -- and one who is still at large!\"")
            remove_answer("gone")
        elseif cmps("visitor") then
            add_dialogue("\"It was the woman who had chased me the night before. Her name was Syria. She said I had stolen the honor flag from the wall of the Library of Scars. She also challenged me to a duel to the death unless I gave it back. And she is much bigger than I! When I tried to explain that I could not give it back, she hit me. It hurt. A lot!\"")
            remove_answer("visitor")
            add_answer({"duel", "hit"})
        elseif cmps("hit") then
            add_dialogue("\"I will say this of the Lady Syria. She is quite beautiful when she is angry... At least, the visions of her that swam through mine head after she had hit me were quite beautiful. Tragically, I awoke.\"")
            remove_answer("hit")
        elseif cmps("duel") then
            add_dialogue("\"Later that day I ran into a man named Vokes. He is a fighter at the Library of Scars. He asked me to return the honor flag and when I tried to tell him I could not, he hit me. Then he challenged me to a duel to the death to be fought right after my duel with Syria.\"")
            add_dialogue("\"After Vokes left, I encountered a man named Timmons. He asked me to return the honor flag to the Library of Scars. I told him I could not and he also challenged me to a duel to the death. I told him I was busy, but he scheduled the challenge for right after my duel with Vokes.\"")
            add_dialogue("\"Timmons, Vokes and Syria are the three toughest fighters in Jhelom. I could not hope to survive against one of them, let alone all three. The mysterious guest and the honor flag are nowhere to be found. Even now my barmaids are taking bets on the manner of my demise!\"")
            remove_answer("duel")
            add_answer({"demise", "Syria", "Vokes", "Timmons"})
        elseif cmps("Timmons") then
            add_dialogue("\"Timmons has come to Jhelom only recently. I can tell thee nothing more of him.\"")
            remove_answer("Timmons")
        elseif cmps("Vokes") then
            add_dialogue("\"He is a fearless warrior, who cherishes any opportunity for combat. Beware of him.\"")
            remove_answer("Vokes")
        elseif cmps("Syria") then
            add_dialogue("\"She is not as bad as she may appear to be. No doubt that woman has a temper. But I am sure she is quite nice once thou hast gotten the chance to know her. If not for these sad circumstances, we might have gotten the chance to get to know each other better.\"")
            remove_answer("Syria")
        elseif cmps("demise") then
            add_dialogue("\"Mine only hope for survival is to find a champion who could stand up to the fiercest fighters in Jhelom.\"")
            set_flag(390, true)
            remove_answer("demise")
            add_answer("champion")
        elseif cmps("champion") then
            add_dialogue("\"Wouldst thou be my champion, Avatar?\"")
            var_0007 = ask_yes_no()
            if var_0007 then
                add_dialogue("Sprellic falls to his knees before you in gratitude. \"Avatar, thou hast saved my life! I cannot thank thee enough!\"")
                set_flag(368, true)
            else
                add_dialogue("\"Oh, well. I had no choice but to ask.\"")
            end
            remove_answer("champion")
        elseif cmps("thou art safe now") then
            add_dialogue("You tell Sprellic that the situation has been resolved and how it was done.")
            add_dialogue("Sprellic practically kisses your feet.")
            add_dialogue("\"How can I ever thank thee? Thou art the most noble person I have ever met! I shalt be forever in thy debt! I thank thee!\"")
            remove_answer("thou art safe now")
        elseif cmps("I have false flag") then
            add_dialogue("You tell Sprellic that Kliftin made you a false flag.")
            add_dialogue("\"How ingenious! Please! Deliver it to Syria as soon as thou art able! And I thank thee for thy trouble in helping me!\"")
            remove_answer("I have false flag")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Good day to thee, Avatar.\"")
    return
end