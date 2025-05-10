--- Best guess: Manages Erethian's dialogue and sword creation sequence, handling item placement and flag updates when event ID is triggered.
function func_06F5(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    switch_talk_to(286, 1)
    add_dialogue("Erethian's face begins to take on an ashen palor, but he looks contented with a job well done. \"As I have said, I myself once attempted to create an artifact of great power. I crafted the hilt from a dark substance that is immutable, save by magical means. The blade, however, is cast of an alloy of this substance and the purest metals known to Britannia. My artistic skills served me well enough to fashion the hilt but, alas, the strength was not in my arm to beat a good temper into the blade. Perhaps, thou canst finish this great artifact for me...\" He pulls a poorly worked blade with a fine hilt out of thin air. \"Fear not to touch the hilt when the blade is hot, for heat apparently does not travel well across the medium of the pure, black substance. I wish thee good luck.\"")
    var_0000 = unknown_0024H(668)
    unknown_0013H(13, var_0000)
    var_0001 = unknown_0036H(unknown_001BH(356))
    if not var_0001 then
        add_dialogue("He hands the sword to you and wearily turns away.*")
    else
        add_dialogue("He places the sword upon the firepit and wearily turns away.*")
        var_0002 = unknown_000EH(10, 739, itemref)
        var_0003 = unknown_0018H(var_0002)
        var_0004 = {var_0003[2] - 1, var_0003[1] + 2, var_0003[3] + 2}
        unknown_0026H(var_0004)
    end
    unknown_0004H(286)
    unknown_001DH(29, itemref)
    unknown_008AH(16, 356)
    var_0005 = unknown_0001H({13, 7719}, itemref)
    var_0006 = unknown_0881H()
    var_0007 = unknown_0002H(13, {17453, 7724}, var_0006)
    var_0008 = unknown_0001H({1693, 8021, 11, 7719}, unknown_001BH(356))
    set_flag(786, true)
    return
end