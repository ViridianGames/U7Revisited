-- Function 0877: Nastassia's tale
function func_0877(eventid, itemref)
    add_dialogue(itemref, "\"I shall tell thee the story of the only unhappy person in Cove -- Nastassia. She is the only person in town without a lover. Not that she does not have suitors -- she is quite beautiful! All she thinks about is the Shrine of Compassion, which is where thou wouldst probably find her at this moment.\"~~De Maria strums his lute and sings:~~")
    add_dialogue(itemref, "\"There once was a maid Ariana~ Who held the shrine so dear.~ She asked that her offspring do likewise~ And keep it so year after year.\"")
    add_dialogue(itemref, "\"Her son Mikhail became mayor~ With a goal to keep in fashion~ The towne's old, belov'd reputation~ As the city of love and passion!\"")
    add_dialogue(itemref, "\"Mikhail's oldest child was Magda;~ She built Lovers' Walk, a fine park,~ Where Cove's lovers, both young and old,~ Could court outdoors in the dark!\"")
    add_dialogue(itemref, "\"Ah, but the clouds of misfortune do hide~ Where the sun's brightness seemeth most fair.~ And poor Nadia, Magda's daughter,~ Of misfortune had more than her share!\"")
    add_dialogue(itemref, "\"It began when Nadia did wed one day~ To Julius, a not-so-wealthy young lad.~ He left her with child and went far away.~ As for Nadia's poor heart, 'twas sad.\"")
    add_dialogue(itemref, "\"One day from Yew the fateful news came~ That Julius by a beast was killed;~ The child came early, 'twas a difficult birth;~ And Nadia's soul became chilled.\"")
    add_dialogue(itemref, "\"With dagger in hand and child in arm~ To the Shrine did Nadia run.~ She plunged the dagger into her own breast;~ Never again would she see the sun.\"")
    add_dialogue(itemref, "\"Nastassia grew up an orphan, you see,~ Unloved and unwanted by all;~ Today she walks cloaked in solitude~ Awaiting her destiny's call.\"")
    add_dialogue(itemref, "\"And that is poor Nastassia's tale. Perhaps thou canst cheer her. Find her, I beseech thee!\"*")
    set_flag(224, true)
    return
end