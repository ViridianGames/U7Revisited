--- Best guess: Manages a dialogue with Rowena in Skara Brae, where she is under Horance's control until awakened by a music box, then asks the player to deliver a ring to Trent.
function utility_music_0983()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = is_pc_female()
    var_0001 = get_lord_or_lady()
    if not get_flag(440) then
        switch_talk_to(144, 0)
        add_dialogue("The beautiful ghost looks through you with a slack look. Nothing you do seems to attract her attention.")
        set_flag(423, false)
        return
    end
    if not get_flag(425) then
        var_0002 = npc_id_in_party(-141)
        if var_0002 then
            add_dialogue("The music of the little box makes Rowena turn her head in your direction. She blinks several times as if waking from a dream, or, in this case, a nightmare. When she sees the Liche, she pretends to be enthralled, but as soon as he is no longer looking in her direction, she motions for you to come closer.")
        else
            add_dialogue("The music of the little box makes Rowena turn her head in your direction. She blinks several times as if waking from a dream, or, in this case, a nightmare.")
        end
        add_dialogue("\"I am in control of my mind for the time being, but I know not for how long. Tell me what has transpired in the town outside.\" You relay to her what you know of the events you've heard in town.")
        if not get_flag(455) then
            add_dialogue("\"My poor Trent. I cannot bear to think that he's become so hurt that he would forget our love.\" She wrings her hands in sorrow and notices something on one of them.")
        else
            add_dialogue("\"And what of my poor Trent? He must be heartsick. I must find a way to get a message to him.\" Something on her hand sparkles brilliantly.")
        end
        add_dialogue("\"Please, " .. var_0001 .. ", wouldst thou take this ring to him and tell him that I still love him. Mayhaps it will restore him to the beloved Trent I knew.\"")
        var_0003 = create_new_object(295)
        get_npc_name(-356)
        if utility_position_1031() then
            add_dialogue("She takes a ring from her slender finger and places it in your hand. You expect it to pass right through, but it rests neatly in your palm.")
        else
            var_0004 = update_last_created(get_object_position(-356))
            add_dialogue("She takes a ring from her slender finger and places it in your hand. You expect it to pass right through, and it does. Fortunately, it falls to the floor, softly ringing as it strikes the stones.")
        end
        if var_0000 then
            add_dialogue("\"I thank thee, kind lady. I know not how to repay thee.\"")
        else
            add_dialogue("\"I thank thee, kind sir. I know not how to repay thee.\"")
        end
        add_dialogue("Rowena's eyes begin to look a little glassy and she blinks slowly as if entering a deep trance.")
        set_flag(425, true)
    end
    add_dialogue("She blinks slowly. \"What beautiful music. My Lord... Horance, once gave me a music box like that one.\" Rowena turns away, distracted.")
    return
end