-- Manages the Wisp's (Xorinia's) dialogue in Britannia, facilitating an information trade about Alagner's notebook and the Time Lord, warning about the Guardian's Black Gate.
function func_0500(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    end

    local0 = get_party_members()
    local1 = get_schedule(itemref)
    switch_talk_to(-256, 0)

    if local1 ~= 3 then
        say("The wisp does not respond.*")
        return
    end

    add_answer({"bye", "job", "name"})
    local2 = check_item(-359, 2, 642, 1, -357) -- Unmapped intrinsic
    if local2 then
        add_answer("notebook")
    end
    if get_flag(336) then
        add_answer("Time Lord")
    end

    if not get_flag(336) then
        say("A ball of light approaches you.~~\"'You' are not the entity known as 'Trellek'. 'You' call out in the manner of the species called 'emps'. 'Xorinia' was expecting the entity 'Trellek'.")
        say("\"But that is not of importance. From the information 'I' have, the local manifestation before 'me' is the entity known as 'Avatar'.")
        say("The Wisp glows brightly a second or two.~~\"'Xorinia' wishes to exchange information with the human entity.\"")
        set_flag(336, true)
        apply_effect(500) -- Unmapped intrinsic
    else
        say("\"Once again a local manifestation addresses the Xorinite dimension.\"")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"Highest probabilities indicate that a manifestation from the Xorinite dimension will be called 'Wisp' by the entities known as 'humans'. I am also called 'Xorinia' by other manifestations of the Xorinite dimension.\"")
            remove_answer("name")
            add_answer("Wisp")
        elseif answer == "Wisp" then
            say("\"This label has been implemented by human entities to name manifestations from the Xorinite dimension since the time when this dimension was discovered by Xorinite manifestations. Another common name is 'Will-o-the-wisp'.~~ \"The preceding sample of information was provided without charge. Usually there is a fee for information.\"")
            remove_answer("Wisp")
        elseif answer == "information" then
            say("\"The Undrian Council seeks information regarding a certain entity by the name of 'Alagner'. 'You' have access to this information. 'I' have information regarding a certain entity which 'you' are seeking. The Undrian Council proposes a trade.\"")
            remove_answer("information")
            add_answer({"trade", "Alagner", "Undrian Council"})
        elseif answer == "Undrian Council" then
            say("\"The Council represents what 'your' language defines as 'government'.\"")
            remove_answer("Undrian Council")
        elseif answer == "job" then
            say("\"'Xorinia' is a conduit for information between different planes and dimensions. 'Xorinia' also catalogs information which is necessary for growth of the Xorinite community. 'You' have information which may be valuable to 'me'. 'I' also have information that 'you' want.\"")
            add_answer("information")
        elseif answer == "Alagner" then
            say("\"The Undrian Council has information that there is a human entity in 'your' dimension that has been called 'the wisest man in Britannia.' This entity is known as 'Alagner' and lives in 'your' colony of 'New Magincia'. 'Alagner' has what the entity calls a 'notebook'. The 'notebook' is a collection of information.\"")
            remove_answer("Alagner")
        elseif answer == "trade" then
            say("\"'I' want to absorb the information in Alagner's 'notebook'. If 'you' bring the 'notebook' here, the Undrian Council will release information useful to 'you'. Do 'you' agree to the trade?\"")
            set_flag(307, true)
            local3 = get_answer()
            if local3 then
                say("\"'Xorinia' recognizes 'your' usefulness. 'I' shall be here. Human entities will call 'my' activity 'waiting'.\"")
            else
                say("\"'Xorinia' recognizes 'your' hostility. 'I' shall be here should 'you' reflect upon 'your' decision and decide to change it.\"*")
                apply_effect(20, itemref) -- Unmapped intrinsic
                return
            end
            remove_answer("trade")
        elseif answer == "Time Lord" then
            if not get_flag(307) then
                say("\"The entity known as 'Time Lord' requests an audience with 'you'. Before 'I' can give 'you' more information about this, 'I' must propose a trade.\"")
                add_answer("information")
            else
                say("\"The entity known as 'Time Lord' is a being from the space/time dimension. The Xorinite Dimension has been communicating with 'Time Lord' for what 'humans' call 'centuries'.\"")
            end
            remove_answer("Time Lord")
        elseif answer == "notebook" then
            say("\"The human entity is welcomed by 'Xorinia'. 'You' have brought the item 'notebook'. 'I' shall now absorb the information contained therein.\"~~The Wisp glows brightly for a few seconds. The notebook remains in your possession.~~\"'I' have completed my absorption of the information. 'You' may now return the item 'notebook' to the entity 'Alagner'.~~\"And now for the exchange of information and delivery of a message.\"")
            set_flag(343, true)
            apply_effect(700) -- Unmapped intrinsic
            remove_answer("notebook")
            add_answer({"message", "exchange"})
        elseif answer == "message" then
            say("\"'Xorinia' must deliver a message to 'you'. The entity known as 'Time Lord' requests 'your' audience. 'Time Lord' is trapped at the plane known as the Shrine of Spirituality. 'You' can reach 'him' by using 'your' object 'Orb of the Moons' in the location directly to 'your' 'northwest'.")
            set_flag(308, true)
            remove_answer("message")
            add_answer("Time Lord")
        elseif answer == "exchange" then
            say("\"Now for the information 'you' seek. 'This' dimension known as 'Britannia' is under attack by an entity called 'The Guardian'.~~\"'The Guardian' lives in another dimension. 'Xorinia' sometimes trades information with this entity. Do 'you' want to know more about 'The Guardian'?\"")
            local4 = get_answer()
            if local4 == 1556 then
                say("\"'Xorinia' has digested information about 'The Guardian' and can state the following facts:~~\"'The Guardian' possesses qualities which human entities label 'vain', 'greedy', 'egocentric', and 'malevolent'. 'The Guardian' thrives on power and domination. 'The Guardian' takes 'pleasure' from conquering other worlds. His sensory organs are now focused on 'this' dimension known as 'Britannia'.~~\"'The Guardian' is attempting to enter 'this' dimension by means of an item human entities call a 'Moongate'. This 'Moongate' is not a 'red' color or 'blue' color 'Moongate', which 'Xorinia' knows is the standard form of this item. 'The Guardian' is building a 'Moongate' of the color 'black'.\"")
                remove_answer("exchange")
                add_answer("Black Gate")
            else
                say("\"'Xorinia' always responds to free information. Transaction complete.\"*")
            end
            remove_answer("exchange")
        elseif answer == "Black Gate" then
            say("\"The 'Black Gate' will be fully functional when the phenomenon known as 'Astronomical Alignment' next occurs.~~ \"Although 'Xorinia' does not normally seek to influence actions of other manifestations, 'Xorinia' warns 'you' that if 'The Guardian' enters 'this' dimension, it will be the end of the dimension known as 'Britannia'. 'The Guardian' is powerful in 'his' own dimension. In 'your' dimension, 'he' will be unstoppable.~~\"The Undrian Council sincerely hopes this information is useful. Transaction complete.\"*")
            set_flag(295, true)
            remove_answer("Black Gate")
        elseif answer == "bye" then
            say("\"'Xorinia' always welcomes the exchange of information. Farewell.\"*")
            apply_effect(20, itemref) -- Unmapped intrinsic
            break
        end
    end
    return
end