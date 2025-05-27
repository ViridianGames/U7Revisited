--- Best guess: Handles dialogue with a Wisp (Xorinia) for trading Alagner's notebook for information about the Time Lord and the Guardian's Black Gate.
function func_0500(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 0 then
        abort()
    end
    var_0000 = get_party_members()
    var_0001 = unknown_001CH(get_npc_name(objectref)) --- Guess: Gets schedule
    switch_talk_to(256, 0)
    if var_0001 ~= 3 then
        add_dialogue("The wisp does not respond.")
        abort()
    end
    add_answer({"bye", "job", "name"})
    var_0002 = unknown_0931H(359, 2, 642, 1, 357) --- Guess: Checks inventory items
    if var_0002 then
        add_answer("notebook")
    end
    if not get_flag(304) then
        add_answer("Time Lord")
    end
    if not get_flag(336) then
        add_dialogue("A ball of light approaches you.")
        add_dialogue("\"'You' are not the entity known as 'Trellek'. 'You' call out in the manner of the species called 'emps'. 'Xorinia' was expecting the entity 'Trellek'.")
        add_dialogue("\"But that is not of importance. From the information 'I' have, the local manifestation before 'me' is the entity known as 'Avatar'.")
        add_dialogue("The Wisp glows brightly a second or two.")
        add_dialogue("\"'Xorinia' wishes to exchange information with the human entity.\"")
        set_flag(336, true)
        unknown_0911H(500) --- Guess: Triggers quest event
    else
        add_dialogue("\"Once again a local manifestation addresses the Xorinite dimension.\"")
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"Highest probabilities indicate that a manifestation from the Xorinite dimension will be called 'Wisp' by the entities known as 'humans'. I am also called 'Xorinia' by other manifestations of the Xorinite dimension.\"")
            remove_answer("name")
            add_answer("Wisp")
        elseif var_0003 == "Wisp" then
            add_dialogue("\"This label has been implemented by human entities to name manifestations from the Xorinite dimension since the time when this dimension was discovered by Xorinite manifestations. Another common name is 'Will-o-the-wisp'.\"")
            add_dialogue("\"The preceding sample of information was provided without charge. Usually there is a fee for information.\"")
            remove_answer("Wisp")
        elseif var_0003 == "information" then
            add_dialogue("\"The Undrian Council seeks information regarding a certain entity by the name of 'Alagner'. 'You' have access to this information. 'I' have information regarding a certain entity which 'you' are seeking. The Undrian Council proposes a trade.\"")
            remove_answer("information")
            add_answer({"trade", "Alagner", "Undrian Council"})
        elseif var_0003 == "Undrian Council" then
            add_dialogue("\"The Council represents what 'your' language defines as 'government'.\"")
            remove_answer("Undrian Council")
        elseif var_0003 == "job" then
            add_dialogue("\"'Xorinia' is a conduit for information between different planes and dimensions. 'Xorinia' also catalogs information which is necessary for growth of the Xorinite community. 'You' have information which may be valuable to 'me'. 'I' also have information that 'you' want.\"")
            add_answer("information")
        elseif var_0003 == "Alagner" then
            add_dialogue("\"The Undrian Council has information that there is a human entity in 'your' dimension that has been called 'the wisest man in Britannia.' This entity is known as 'Alagner' and lives in 'your' colony of 'New Magincia'. 'Alagner' has what the entity calls a 'notebook'. The 'notebook' is a collection of information.\"")
            remove_answer("Alagner")
        elseif var_0003 == "trade" then
            add_dialogue("\"'I' want to absorb the information in Alagner's 'notebook'. If 'you' bring the 'notebook' here, the Undrian Council will release information useful to 'you'. Do 'you' agree to the trade?\"")
            set_flag(307, true)
            var_0004 = select_option()
            if var_0004 then
                add_dialogue("\"'Xorinia' recognizes 'your' usefulness. 'I' shall be here. Human entities will call 'my' activity 'waiting'.\"")
            else
                add_dialogue("\"'Xorinia' recognizes 'your' hostility. 'I' shall be here should 'you' reflect upon 'your' decision and decide to change it.\"")
                unknown_001DH(20, objectref) --- Guess: Sets object behavior
                abort()
            end
            remove_answer("trade")
        elseif var_0003 == "Time Lord" then
            if not get_flag(307) then
                add_dialogue("\"The entity known as 'Time Lord' requests an audience with 'you'. Before 'I' can give 'you' more information about this, 'I' must propose a trade.\"")
                add_answer("information")
            else
                add_dialogue("\"The entity known as 'Time Lord' is a being from the space/time dimension. The Xorinite Dimension has been communicating with 'Time Lord' for what 'humans' call 'centuries'.\"")
            end
            remove_answer("Time Lord")
        elseif var_0003 == "notebook" then
            add_dialogue("\"The human entity is welcomed by 'Xorinia'. 'You' have brought the item 'notebook'. 'I' shall now absorb the information contained therein.\"")
            add_dialogue("The Wisp glows brightly for a few seconds. The notebook remains in your possession.")
            add_dialogue("\"'I' have completed my absorption of the information. 'You' may now return the item 'notebook' to the entity 'Alagner'.\"")
            add_dialogue("\"And now for the exchange of information and delivery of a message.\"")
            set_flag(343, true)
            unknown_0911H(700) --- Guess: Triggers quest event
            remove_answer("notebook")
            add_answer({"message", "exchange"})
        elseif var_0003 == "message" then
            add_dialogue("\"'Xorinia' must deliver a message to 'you'. The entity known as 'Time Lord' requests 'your' audience. 'Time Lord' is trapped at the plane known as the Shrine of Spirituality. 'You' can reach 'him' by using 'your' object 'Orb of the Moons' in the location directly to 'your' 'northwest'.\"")
            set_flag(308, true)
            remove_answer("message")
            add_answer("Time Lord")
        elseif var_0003 == "exchange" then
            add_dialogue("\"Now for the information 'you' seek. 'This' dimension known as 'Britannia' is under attack by an entity called 'The Guardian'.\"")
            add_dialogue("\"'The Guardian' lives in another dimension. 'Xorinia' sometimes trades information with this entity. Do 'you' want to know more about 'The Guardian'?\"")
            var_0004 = select_option()
            if var_0004 then
                add_dialogue("\"'Xorinia' has digested information about 'The Guardian' and can state the following facts:\"")
                add_dialogue("\"'The Guardian' possesses qualities which human entities label 'vain', 'greedy', 'egocentric', and 'malevolent'. 'The Guardian' thrives on power and domination. 'The Guardian' takes 'pleasure' from conquering other worlds. His sensory organs are now focused on 'this' dimension known as 'Britannia'.\"")
                add_dialogue("\"'The Guardian' is attempting to enter 'this' dimension by means of an item human entities call a 'Moongate'. This 'Moongate' is not a 'red' color or 'blue' color 'Moongate', which 'Xorinia' knows is the standard form of this item. 'The Guardian' is building a 'Moongate' of the color 'black'.\"")
                remove_answer("exchange")
                add_answer("Black Gate")
            else
                add_dialogue("\"'Xorinia' always responds to free information. Transaction complete.\"")
            end
            remove_answer("exchange")
        elseif var_0003 == "Black Gate" then
            add_dialogue("\"The 'Black Gate' will be fully functional when the phenomenon known as 'Astronomical Alignment' next occurs.\"")
            add_dialogue("\"Although 'Xorinia' does not normally seek to influence actions of other manifestations, 'Xorinia' warns 'you' that if 'The Guardian' enters 'this' dimension, it will be the end of the dimension known as 'Britannia'. 'The Guardian' is powerful in 'his' own dimension. In 'your' dimension, 'he' will be unstoppable.\"")
            add_dialogue("\"The Undrian Council sincerely hopes this information is useful. Transaction complete.\"")
            set_flag(295, true)
            remove_answer("Black Gate")
        elseif var_0003 == "bye" then
            break
        end
    end
    add_dialogue("\"'Xorinia' always welcomes the exchange of information. Farewell.\"")
    unknown_001DH(20, objectref) --- Guess: Sets object behavior
end