--- Best guess: Triggers a telepathic probe with narrative messages, hiding the NPC and altering game state, likely for a mystical quest event.
function func_03DE(eventid, itemref)
    local var_0000

    if eventid == 1 then
        if not get_flag(769) then
            set_flag(769, true)
            is_player_female()
            switch_talk_to(0, 356)
            start_conversation()
            add_dialogue("You feel as if your mind is being probed, delicately at first, then with more insistence. Images of long past memories flit before your eyes and old emotions resurface. At one point, the images pause as you remember the words Love, Sol, Moons, and Death then a strange sense of deja vu comes over you as the vision comes up to the current time. The images cease and a vast wave of power overwhelms you. A wall of darkness falls...")
            hide_npc(356)
            var_0000 = unknown_0001H({5, 2, 7947, 1, 17447, 8046, 1, 17447, 8045, 1, 17447, 7788}, 356)
            var_0000 = unknown_0001H({707, 8021, 5, 7719}, itemref)
        else
            is_player_female()
            switch_talk_to(0, 356)
            start_conversation()
            add_dialogue("Your mind is quickly probed, then cast aside, leaving you feeling slightly ill and filled with an irrational sense of foreboding.")
        end
    elseif eventid == 2 then
        unknown_008CH(1, 1, 12)
        var_0000 = unknown_0001H({8033, 1, 17447, 8044, 2, 17447, 8045, 3, 7719}, 356)
    end
    return
end