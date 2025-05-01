-- Manages Cubolt's dialogue in Moonglow, as a farmer concerned about his brother Tolemac's involvement with the Fellowship.
function func_049B(eventid, itemref)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        apply_effect(-155) -- Unmapped intrinsic
        return
    end

    switch_talk_to(155, 0)
    local0 = get_player_name()
    local1 = get_party_size()
    local2 = false
    add_answer({"bye", "job", "name"})
    local3 = get_answer()

    if local3 then
        add_dialogue("\"" .. local1 .. "? Thou, too, hast joined the evil organization? But how is this possible? Canst thou not see their tenets vie with the very virtues themselves? Dost thou not feel more like a sheep than a man? I am truly sorry, for if one of Britannia's greatest heroes has fallen in with such filth, then there is no hope for our great land!\" He turns away in disgust.*")
        return
    end

    if not get_flag(511) then
        add_dialogue("You see a man with an unhappy look upon his face.")
        set_flag(511, true)
    else
        add_dialogue("Cubolt looks up. \"Yes, " .. local1 .. "?\"")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"I am Cubolt of Moonglow.\"")
            add_answer("Moonglow")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a farmer, " .. local1 .. ". I manage my farm with the help of Tolemac, my brother, and Morz, our family friend.\"")
            add_answer({"Morz", "Tolemac"})
        elseif answer == "Moonglow" then
            add_dialogue("\"The city occupies the entire island now, including the Lycaeum. Most of the residents still live south, though. We are due east of Britain proper.\"")
            add_answer("residents")
            remove_answer("Moonglow")
        elseif answer == "Morz" then
            add_dialogue("\"My brother and I have known Morz for most of our lives. He is very friendly when he is not too busy worrying about his stutter. Unfortunately, he listens to Tolemac too often.\"")
            add_answer("stutter")
            remove_answer("Morz")
        elseif answer == "stutter" then
            add_dialogue("Cubolt looks down at the ground, shaking his head sadly. \"He started when he was five years old. He and my brother were wrestling in the back of a wagon driven by his parents. They hit a bump and he fell out -- and landed on his head. Ever since, he hath had his stutter.\" He looks back up at you. \"The odd thing is, neither he nor Tolemac remember the accident. Or at least, Tolemac doth not. I cannot convince Morz to talk about it.\"")
            remove_answer("stutter")
        elseif answer == "residents" then
            add_dialogue("\"Zelda, the clerk at the Lycaeum, would be the best person to talk to about Moonglow's residents. Or the bartender, though I do not know his name. I know that the Observatory head and the Lycaeum head are twins, but I have never met either of them. I do know that thou dost not want to talk to Rankin or Balayna at The Fellowship. They are ill news to our once-pleasant city.\"")
            if not local2 then
                add_answer("Fellowship")
            end
            remove_answer("residents")
        elseif answer == "Tolemac" then
            add_dialogue("\"He is my younger brother. Need I say more? I am a little concerned about him though. I am used to his rebellious behavior, but recently he has joined The Fellowship. That frightens me. They frighten me. I have tried to get him to come to his senses, but he is too busy enjoying making me worry to listen. Also, he is trying to get Morz to join. I wish I could get him to reconsider.\"")
            if not local2 then
                add_answer("Fellowship")
            end
            add_answer("reconsider")
            remove_answer("Tolemac")
        elseif answer == "Fellowship" then
            add_dialogue("He spits on the ground. \"A bane to Britannia is what The Fellowship is. They have some odd philosophy that teaches thee to forget who thou art and follow them. The process is dehumanizing, and I think it meshes poorly with the eight virtues. Not only that, but their leader here in Moonglow has persuaded Tolemac to join.\"")
            local2 = true
            remove_answer("Fellowship")
        elseif answer == "reconsider" then
            add_dialogue("\"Unfortunately, Tolemac will not listen to me. However,\" he begins to smile hopefully, \"he just might listen to thee, " .. local1 .. ". Perhaps thou couldst talk him into reconverting. I would very much appreciate that! Perhaps,\" he adds, \"thou couldst also ask Morz not to join.\"")
            set_flag(470, true)
            set_flag(471, true)
            remove_answer("reconsider")
        elseif answer == "bye" then
            add_dialogue("\"Take care, " .. local1 .. ".\"*")
            break
        end
    end
    return
end