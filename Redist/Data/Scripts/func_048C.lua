-- Manages Markham's dialogue in Skara Brae, as the ghostly barkeep of the Keg O' Spirits, covering the tavern's history, the fire, and Horance's influence.
function func_048C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        switch_talk_to(-140, 0)
        if not get_flag(436) then
            say("This undead fellow looks through you. Though he is obviously aware of his surroundings, you are quite sure that he doesn't even see you.*")
            return
        end

        if get_flag(458) then
            local0 = "Paulette"
        else
            local0 = "barmaid"
        end
        local1 = "it's not all his fault"
        local2 = false
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        local3 = get_part_of_day()
        local4 = get_schedule(-140)
        if not get_flag(426) then
            if local3 == 0 or local3 == 1 then
                if local4 == 14 then
                    say("You attempt to start a conversation with the portly ghost, but he seems distanced from you and everything else.*")
                    return
                elseif local4 ~= 16 then
                    say("The heavy-set ghost looks a bit shaken and his speech is a little slurred as he says, \"Excuse me, yer honor. But I got me a splittin' headache. Do ya mind if we continue this little chat later?\"~~He begins to rub his temples with both hands.*")
                    return
                end
            end
        end
        local5 = switch_talk_to(-144)
        if local5 then
            say("\"Oh, hello there, lady Rowena. 'Tis good to see ye again. It brings a ray o' sunshine into this old man's heart ta see yer beauteous face,\" he says, smiling.*")
            switch_talk_to(-144, 0)
            say("She curtsies delicately and smiles back.~~\"Hello, Markham. It is good, indeed, to see that none of this horrible business can keep thee from giving a lady a compliment.\"*")
            hide_npc(-144)
            switch_talk_to(-140, 0)
        end
        local6 = switch_talk_to(-147)
        if local6 then
            say("\"Oh, uh, hello there Mayor. I thought ye were sequestered in the Town Hall. Well, uh, it's good ta see ya again.\"*")
            switch_talk_to(-147, 0)
            say("\"Yes, well, it is good to see thee again, too.\"*")
            hide_npc(-147)
            switch_talk_to(-140, 0)
            set_flag(445, true)
        end
        if not get_flag(452) then
            say("The corpulent, undead barkeep greets you with a wide, gruesome smile. \"Come, stranger. Have a seat near old Markham and tell me o' yer travels. I don't often get visitors in here anymore.\"")
            set_flag(452, true)
        else
            say("Markham hails you and drinks down a tankard of the house spirits. \"Welcome, my friend. Sit with me a while and enliven my eternity with yer wondrous wit.\" He smiles in that charming way that only the half-rotted can.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            local answer = get_answer()
            if answer == "name" then
                say("The heavy-set zombie wipes his mouth off on the back of his hand. \"I be Markham. Markham o' the Keg.\" He pats the large keg of wine he carries.")
                local7 = switch_talk_to(-145)
                if local7 and not get_flag(441) then
                    if not local2 then
                        hide_npc(-146)
                    end
                    if not get_flag(420) then
                        switch_talk_to(-145, 0)
                        say("The lovely " .. local0 .. " strolls over and pats Markham's rather large belly. \"Yes, he's Markham of the Keg, all right.\" She smiles sweetly down at the older man.*")
                        hide_npc(-145)
                        switch_talk_to(-140, 0)
                        say("\"That's enough of that!\" Markham smacks the pretty young woman on her ghostly posterior.~~ \"Make yerself useful and fetch me a haunch o' venison.\" She turns away, giggling. He looks at you with a mirthful expression, \"I just don't know what I'm goin' ta do with that girl.\"")
                    end
                end
                remove_answer("name")
            elseif answer == "job" then
                say("\"Why, I run this fine establishment, the Keg O' Spirits.\" For a moment he becomes serious. \"This place once drew folk from all across Britannia, gargoyle and human alike. Until the fire, that is.\"")
                add_answer({"fire", "Keg O' Spirits"})
            elseif answer == "fire" then
                say("He looks uncomfortable, \"Caine blew the town to the four winds, and now we're all trapped here, slaves of that bastard Horance.\" Tiny blue flames appear in the pupils of his glazed eyes, then go out as he regains his composure.")
                add_answer({"Horance", "Caine"})
                local8 = switch_talk_to(-146)
                if local8 and get_flag(442) then
                    switch_talk_to(-146, 0)
                    say("\"Please, Markham. Have a little pity for Caine. He was trying to create something to save the town when he made his fatal mistake.\" The pale ghost looks deeply troubled.")
                    hide_npc(-146)
                    switch_talk_to(-140, 0)
                    local2 = true
                    local1 = "yer right Quen,"
                end
                say("\"Oh, I suppose " .. local1 .. " he was tryin' ta help us when he called the proverbial fires o' Hell down on us. It just rankles me to have died in my prime.\" His roguish smile once again lightens his ghostly visage.")
                remove_answer("fire")
            elseif answer == "Caine" then
                say("A look of disgust comes to his disfigured features. \"That tortured soul haunts the crater made by his foolish mistake. I wouldn't go near him though, he's a bit daft, ya know.\" He refills his mug from the cask at his side and swigs down most of the wine in one swallow.")
                add_answer("tortured soul")
                remove_answer("Caine")
            elseif answer == "tortured soul" then
                say("\"That's just the name the rest of us in Skara Brae call him -- the Tortured One,\" he grins, embarrassed.")
                remove_answer("tortured soul")
                add_answer("Skara Brae")
            elseif answer == "Skara Brae" then
                say("\"That's the name o' the island yer on.\" He shakes his head.")
                remove_answer("Skara Brae")
            elseif answer == "Horance" then
                say("\"For all the years I've been in Skara Brae, he's been a raving lunatic. What with all o' them silly rhymes and his crazy laughter.~~\"Then one night, we all hears thunder when there isn't a cloud in the starry sky, and I seem to recall a full moon...\" He gets a thoughtful look on his face. \"But as I was sayin', there was this thunder, then this deep, dark laughter coming from the tower on the northern point -- Horance's Dark Tower.\" After this he falls silent for a moment.")
                if local2 then
                    switch_talk_to(-146, 0)
                    say("The pale ghost moves forward and whispers, \"I was already living in the half world of the dead when these events took place, and ever since, I've felt a strange pull coming from the tower.\"*")
                    hide_npc(-146)
                    switch_talk_to(-140, 0)
                end
                say("After a brief swig, he continues, \"Then, even worse... I'm out checkin' on the cows when I hears a sound like moanin'. It's off to the east, so I look that way, into the graveyard y'know, and what do I see?~~\"I'll tell ya what I seen. The graves, rippin' open like the people in 'em got a place to go.\" Eyes wide, he tips back another sip.")
                remove_answer("Horance")
            elseif answer == "Keg O' Spirits" then
                say("He truly looks sad as he says, \"This place was once my pride and joy. The Keg was known all 'round Britannia, and a few other places, too. Well, now it don't look like too much, but in it's heyday, it saw the likes of nobles, knights, minstrels, and merchants. And o' course, a bit o' riff raff to be sure.\" He winks at you. His spirit seems indomitable.")
                remove_answer("Keg O' Spirits")
            elseif answer == "sacrifice" then
                if not get_flag(410) then
                    say("You relate the need for a sacrifice to enter the Well of Souls. Afterwards, Markham seems to think long and hard.~~\"So, yer wantin' me to go mad as a March hare, an' jump right into this... Well O' Souls?\" He looks at you incredulously.~~\"Listen now. I haven't had courage like that since I were a young lad. Since then I got some sense, too. You'll have to look elsewhere fer yer sacrifice.\"")
                    set_flag(410, true)
                else
                    say("\"All right, now. I already told ya. I ain't interested.\" He looks a little put out by your persistence.*")
                    return
                end
                remove_answer("sacrifice")
            elseif answer == "bye" then
                say("\"Oh, are ya leavin' then? Well, ya take care now. And watch out for those walkin' dead. Some o' them aren't too happy about their state, and none too picky about who they complain to, neither.\"*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end