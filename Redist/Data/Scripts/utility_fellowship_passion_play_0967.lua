--- Best guess: Manages a scripted Fellowship play performance, promoting their philosophy through a theatrical narrative, with NPC interactions and flag setting.
--- " ~~" in BG dialogue strings marks a new add_dialogue bubble (split so text fits the box).
function utility_ship_0967()
    -- Called from Paul's conversation (already start_conversation()'d).
    -- Just queue dialogue into the active conversation; do not push another.
    local var_0000, var_0001

    -- Split BG " ~~" verse markers into separate dialogue entries.
    local function add_verses(text)
        local start = 1
        while true do
            local i, j = string.find(text, " ~~", start, true)
            if not i then
                local rest = string.sub(text, start)
                if rest ~= "" then
                    add_dialogue(rest)
                end
                break
            end
            local part = string.sub(text, start, i - 1)
            if part ~= "" then
                add_dialogue(part)
            end
            start = j + 1
        end
    end

    switch_talk_to(233)
    -- Companions comment only when actually in the party (Iolo=1, Spark=2).
    var_0000 = npc_id_in_party(1) or npc_id_in_party(1)
    var_0001 = npc_id_in_party(2) or npc_id_in_party(2)
    add_dialogue("As the actors take their places and don masks, you settle down to watch the action.")
    if var_0001 then
        second_speaker(2, 0, "Spark whispers to you, \"I wish there was a confectioner that sold candied apples!\"")
    end
    add_dialogue("The music starts the play, as Paul takes center stage and addresses the audience.")
    add_verses("\"Welcome to Our Tale, ~~A tale so true to life. ~~'Tis a tale of tragedy ~~A man has lost his wife.")
    add_verses("\"But the story need not be sad ~~When The Fellowship is here. ~~The Triad of Inner Strength ~~Gives one no cause to fear.\"")
    hide_npc(233)
    switch_talk_to(235)
    add_dialogue("Dustin takes the stage as Paul moves away. Meryl lies on the ground in front of him and assumes a death-like pose.")
    add_verses("\"'Tis doom! 'Tis despair! 'Tis death! ~~My beloved wife is gone! ~~Disease has taken her away ~~And left me with but a song.\"")
    add_dialogue("Dustin puts his head in his hands and mimes sobbing. As he sobs, Meryl rises from her \"death\" in a ghost-like fashion, then addresses Dustin.")
    switch_talk_to(234)
    add_verses("\"Mine husband, my love! ~~Do not despair! 'Tis not doom! ~~Thou shalt rise above ~~All this melancholy and gloom!\"")
    switch_talk_to(235)
    add_verses("\"Who doth speak to me? ~~Could it be she? ~~Or have I indeed gone mad? ~~But who else -could- it be?\"")
    switch_talk_to(234)
    add_verses("\"Mine husband, thou must listen. ~~Thou hast thy comfort within thy grip. ~~Thou must only seek them out -- ~~Those that can help -- The Fellowship!\"")
    hide_npc(234)
    switch_talk_to(235)
    add_dialogue("Meryl drifts off stage, leaving Dustin alone.")
    add_verses("\"The Fellowship, she said? ~~But what do I need with it? ~~I have mine eight virtues and mine healers ~~With these nothing else will fit!\"")
    switch_talk_to(233)
    add_dialogue("Paul enters the stage with Meryl, who now wears a different mask.")
    add_verses("\"But that is where thou art wrong! ~~The Fellowship exists to help thee! ~~The Triad of Inner Strength is here ~~To give thee a sense of unity!\"")
    add_verses("\"Join us now and thou wilt see. ~~Join thy brothers and our plan ~~To promote the tenets of our group -- ~~Thou wilt be a better man.\"")
    add_dialogue("At this point, an elaborate mimed sequence reveals how Dustin joins The Fellowship, receives his medallion from a \"branch leader\", portrayed by Paul, and receives congratulations from Meryl.")
    add_verses("\"Strive for Unity at all times, ~~And Trust Thy Brother through all ill, ~~For Worthiness Precedes thine own Reward ~~Hark to our words -- it surely will!\"")
    switch_talk_to(235)
    add_verses("\"I shall give half my wealth to thee! ~~I shall do thy bidding and then wait. ~~My reward shall come one day ~~And free me from mine awful fate.\"")
    add_dialogue("Dustin mimes giving Paul some money. Paul exits, then Dustin lies down on the stage and mimes going to sleep.")
    add_dialogue("After a moment, Meryl enters the stage, dances around Dustin's body, sprinkling some kind of sparkling dust on him.")
    if var_0000 then
        second_speaker(1, 0, "Iolo whispers to you. \"I am particularly enjoying the visual effects. The script is a little weak, dost thou not think?\"")
    end
    add_dialogue("Meryl leaves the stage and Dustin 'wakes up'. Lo and behold, he finds a bag near his place of sleep. Upon opening it, he finds a bundle of gold!")
    add_verses("\"By Lord British I declare! ~~'Tis my reward! From the air! ~~The voice I heard at night was right ~~About my wretched life I will not care!")
    add_verses("\"The voice came to me in a dream ~~'Twas mine 'inner' voice, so fair. ~~I now have a companion and provider, ~~And a master about whom I care.\"")
    add_dialogue("You are jarred by the actor's choice of words -- 'companion', 'provider', and 'master'. You realize you have heard them before.")
    if var_0001 then
        second_speaker(2, 0, "\"This is really awful.\"")
    end
    add_dialogue("Paul and Meryl join Dustin on stage and they all hold hands.")
    switch_talk_to(233)
    add_verses("\"The Fellowship can give thee purpose ~~To join is thine only choice ~~Commit thyself to our just cause ~~And find thine inner voice.\"")
    add_dialogue("At that point, the actors bow, and you realize it is the end. You give them polite applause.")
    set_flag(10, true)
    if var_0000 then
        second_speaker(1, 0, "\"What do they mean about the voice? I am not sure I understand. 'Twas a confusing play. I did not like it at all.\"")
        second_speaker(1, 0, "\"We have wasted our time and money! That is the last time that I let thee decide how best we entertain ourselves!\"")
    end
    return
end
