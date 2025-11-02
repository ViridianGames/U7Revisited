--- Best guess: Advances the quest by revealing how to restore Bollux using a new heart from the Tree of Life.
function utility_shop_0913(eventid, objectref)
    set_flag(802, true)
    add_dialogue("@'Tis as I suspected. Bollux thought he must sacrifice his own heart...@")
    hide_npc(288) --- Guess: Hides NPC
    say_with_newline("@I don't mean to be irreverent, but did the matter not involve death...@") --- Guess: Says with newline
    switch_talk_to(288) --- Guess: Initiates dialogue
    add_dialogue("@However,' smiles Adjhar, ''tis not necessary, for had Bollux known...@")
    set_flag(801, true)
end