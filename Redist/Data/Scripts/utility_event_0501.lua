--- Best guess: Manages Erethian's dialogue and sword creation sequence, handling item placement and flag updates when event ID is triggered.
function utility_event_0501(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    switch_talk_to(286, 1)
    add_dialogue("Erethian's face begins to take on an ashen palor, but he looks contented with a job well done. \"As I have said, I myself once attempted to create an artifact of great power. I crafted the hilt from a dark substance that is immutable, save by magical means. The blade, however, is cast of an alloy of this substance and the purest metals known to Britannia. My artistic skills served me well enough to fashion the hilt but, alas, the strength was not in my arm to beat a good temper into the blade. Perhaps, thou canst finish this great artifact for me...\" He pulls a poorly worked blade with a fine hilt out of thin air. \"Fear not to touch the hilt when the blade is hot, for heat apparently does not travel well across the medium of the pure, black substance. I wish thee good luck.\"")
    var_0000 = create_new_object(668)
    set_object_frame(13, var_0000)
    var_0001 = give_last_created(get_npc_name(356))
    if not var_0001 then
        add_dialogue("He hands the sword to you and wearily turns away.*")
    else
        add_dialogue("He places the sword upon the firepit and wearily turns away.*")
        var_0002 = find_nearest(10, 739, objectref)
        var_0003 = get_object_position(var_0002)
        var_0004 = {var_0003[2] - 1, var_0003[1] + 2, var_0003[3] + 2}
        update_last_created(var_0004)
    end
    hide_npc(286)
    set_schedule_type(29, objectref)
    clear_item_flag(16, 356)
    var_0005 = execute_usecode_array(objectref, {13, 7719})
    var_0006 = utility_event_0897()
    var_0007 = delayed_execute_usecode_array(13, {17453, 7724}, var_0006)
    var_0008 = execute_usecode_array(get_npc_name(356), {1693, 8021, 11, 7719})
    set_flag(786, true)
    return
end