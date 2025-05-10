--- Best guess: Displays various signs and messages based on item quality, ranging from location names to gravestones and warnings, used for world-building and navigation.
function func_017B(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        return
    end
    var_0000 = unknown_0908H()
    var_0001 = unknown_0014H(objectref)
    if var_0001 > 151 then
        unknown_0032H({"SIGN", "VALID", "NOT A", "THIS IS"}, 49)
    elseif var_0001 == 0 then
        unknown_0032H({"lizard", "gilded", "at|(e", "drink"}, 49)
    elseif var_0001 == 1 then
        unknown_0032H({"47", "~population", "brae~", "skara"}, 49)
    elseif var_0001 == 2 then
        unknown_0032H({"trinsic"}, 49)
    elseif var_0001 == 3 then
        unknown_0032H({"hound", "honorable", "(e"}, 49)
    elseif var_0001 == 4 then
        unknown_0032H({"HALL", "FELLOWSHIP"}, 49)
    elseif var_0001 == 5 then
        unknown_0032H({"britain"}, 49)
    elseif var_0001 == 6 then
        unknown_0032H({"THE AVATAR@", "@TRIALS OF", "RAYMUNDO'S", "COMING:"}, 49)
    elseif var_0001 == 7 then
        unknown_0032H({"NOW", "SEATS", "THY", "RESERVE"}, 49)
    elseif var_0001 == 8 then
        unknown_0032H({"museum", "royal"}, 49)
    elseif var_0001 == 9 then
        unknown_0032H({"hall", "music", "(e"}, 49)
    elseif var_0001 == 11 then
        unknown_0032H({"inn", "wayfarer's", "(e"}, 49)
    elseif var_0001 == 12 then
        unknown_0032H({"bows", "iolos"}, 49)
    elseif var_0001 == 13 then
        unknown_0032H({"boar", "blue", "(e"}, 49)
    elseif var_0001 == 14 then
        unknown_0032H({"clo(iers", "gayes"}, 49)
    elseif var_0001 == 15 then
        unknown_0032H({"armoury", ",ar", "nor("}, 49)
    elseif var_0001 == 16 then
        unknown_0032H({"oar", "oaken", "(e"}, 49)
    elseif var_0001 == 17 then
        unknown_0032H({"bakery"}, 49)
    elseif var_0001 == 18 then
        unknown_0032H({"jeweler"}, 49)
    elseif var_0001 == 19 then
        unknown_0032H({"market", "farmers"}, 49)
    elseif var_0001 == 20 then
        unknown_0032H({"apo(ecary"}, 49)
    elseif var_0001 == 21 then
        unknown_0032H({"mint", "royal"}, 49)
    elseif var_0001 == 22 then
        unknown_0032H({"h+ler", "(e", "csil"}, 49)
    elseif var_0001 == 23 then
        unknown_0032H({"provisions"}, 49)
    elseif var_0001 == 24 then
        unknown_0032H({"orchards", "royal"}, 49)
    elseif var_0001 == 25 then
        unknown_0032H({"ART THOU AN AVATAR?", " -- ", "TEST OF STRENGTH"}, 49)
    elseif var_0001 == 26 then
        unknown_0032H({"show", "judy", "punch and"}, 49)
    elseif var_0001 == 27 then
        unknown_0032H({"fish|n|chips"}, 49)
    elseif var_0001 == 28 then
        unknown_0032H({"cove"}, 49)
    elseif var_0001 == 29 then
        unknown_0032H({"emerald", "(e", "out|n|inn"}, 49)
    elseif var_0001 == 30 then
        unknown_0032H({"walk", "lovers"}, 49)
    elseif var_0001 == 31 then
        unknown_0032H({"den", "buccaneers", "(e|ba(s"}, 49)
    elseif var_0001 == 32 then
        unknown_0032H({"games", "of", "house"}, 49)
    elseif var_0001 == 33 then
        unknown_0032H({"virgin", "fallen", "(e"}, 49)
    elseif var_0001 == 34 then
        unknown_0032H({"budos"}, 49)
    elseif var_0001 == 35 then
        unknown_0032H({"RETREAT", "MEDITATION"}, 49)
    elseif var_0001 == 36 then
        unknown_0032H({"GO THIS WAY"}, 49)
    elseif var_0001 == 37 then
        unknown_0032H({"lycaeum"}, 49)
    elseif var_0001 == 38 then
        unknown_0032H({"dock"}, 49)
    elseif var_0001 == 39 then
        unknown_0032H({"hallowed", "(e", "knave"}, 49)
    elseif var_0001 == 40 then
        unknown_0032H({"friendly", "(e", "lizard"}, 49)
    elseif var_0001 == 41 then
        unknown_0032H({"gilded", "(e", "h+ler"}, 49)
    elseif var_0001 == 42 then
        unknown_0032H({"provisions", "eldro(s"}, 49)
    elseif var_0001 == 43 then
        unknown_0032H({"items", "of", "house"}, 49)
    elseif var_0001 == 44 then
        unknown_0032H({"company", "mini*", "britannian"}, 49)
    elseif var_0001 == 45 then
        unknown_0032H({"branch", "minoc"}, 49)
    elseif var_0001 == 46 then
        unknown_0032H({"trainer", "scholar"}, 49)
    elseif var_0001 == 47 then
        unknown_0032H({"town|hall"}, 49)
    elseif var_0001 == 48 then
        unknown_0032H({"magics", "wis-surs"}, 49)
    elseif var_0001 == 49 then
        unknown_0032H({"observatory"}, 49)
    elseif var_0001 == 50 then
        unknown_0032H({"vesper"}, 49)
    elseif var_0001 == 51 then
        unknown_0032H({"moo*low"}, 49)
    elseif var_0001 == 52 then
        unknown_0032H({"terfin"}, 49)
    elseif var_0001 == 53 then
        unknown_0032H({"hold", "serpents"}, 49)
    elseif var_0001 == 54 then
        unknown_0032H({"abbey", "empa("}, 49)
    elseif var_0001 == 55 then
        unknown_0032H({"jhelom"}, 49)
    elseif var_0001 == 56 then
        unknown_0032H({"minoc"}, 49)
    elseif var_0001 == 57 then
        unknown_0032H({"undertaker"}, 49)
    elseif var_0001 == 58 then
        unknown_0032H({"britannia", "of", "court"}, 49)
    elseif var_0001 == 59 then
        unknown_0032H({"high", "prison"}, 49)
    elseif var_0001 == 60 then
        unknown_0032H({"damsel", "mode,", "(e"}, 49)
    elseif var_0001 == 61 then
        unknown_0032H({"armoury"}, 49)
    elseif var_0001 == 62 then
        unknown_0032H({"blacksmi("}, 49)
    elseif var_0001 == 63 then
        unknown_0032H({"center", "recr+tion"}, 49)
    elseif var_0001 == 64 then
        unknown_0032H({"knowledge", "of", "hall"}, 49)
    elseif var_0001 == 65 then
        unknown_0032H({"avatar", "(ere"}, 49)
    elseif var_0001 == 66 then
        unknown_0032H({"hello", "the|avatars", "in|person"}, 49)
    elseif var_0001 == 67 then
        unknown_0032H({"tonight|9-12", "why?", "ask"}, 49)
    elseif var_0001 == 68 then
        unknown_0032H({"why", "honor", "of"}, 49)
    elseif var_0001 == 69 then
        unknown_0032H({",r)t", "pa(", "paladins"}, 49)
    elseif var_0001 == 70 then
        unknown_0032H({"FELLOWSHIP", "THE", "OF"}, 49)
    elseif var_0001 == 71 then
        unknown_0032H({"AVENUE", "walk", "widows"}, 49)
    elseif var_0001 == 72 then
        unknown_0032H({"hallway", "harolds"}, 49)
    elseif var_0001 == 73 then
        unknown_0032H({"fools|way"}, 49)
    elseif var_0001 == 74 then
        unknown_0032H({"road", "whitsaber", ",rand"}, 49)
    elseif var_0001 == 75 then
        unknown_0032H({"avenue", "chalice"}, 49)
    elseif var_0001 == 76 then
        unknown_0032H({"coves", "two"}, 49)
    elseif var_0001 == 77 then
        unknown_0032H({"road", "wall", "we,"}, 49)
    elseif var_0001 == 78 then
        unknown_0032H({"road", "wall", "+,"}, 49)
    elseif var_0001 == 79 then
        unknown_0032H({"road", "wall", "nor("}, 49)
    elseif var_0001 == 80 then
        unknown_0032H({"road", "wall", "sou("}, 49)
    elseif var_0001 == 81 then
        unknown_0032H({"way", "heroes"}, 49)
    elseif var_0001 == 82 then
        unknown_0032H({"sou(", "iolos"}, 49)
    elseif var_0001 == 83 then
        unknown_0032H({"paws"}, 49)
    elseif var_0001 == 84 then
        unknown_0032H({"salty|dog", "(e"}, 49)
    elseif var_0001 == 85 then
        unknown_0032H({"SHELTER", "FELLOWSHIP"}, 49)
    elseif var_0001 == 86 then
        unknown_0032H({"branch", "vesper"}, 49)
    elseif var_0001 == 87 then
        unknown_0032H({"cork", "checquered", "(e"}, 49)
    elseif var_0001 == 88 then
        unknown_0032H({"guild", "artists"}, 49)
    elseif var_0001 == 89 then
        unknown_0032H({",ool", "and", "(e bunk"}, 49)
    elseif var_0001 == 90 then
        unknown_0032H({"scars", "of", "library", "(e"}, 49)
    elseif var_0001 == 91 then
        unknown_0032H({"clo(es", "carlyns"}, 49)
    elseif var_0001 == 92 then
        unknown_0032H({"richard", "lies|ma,er", "walls", "wi(in|(ese"}, 49)
    elseif var_0001 == 93 then
        unknown_0032H({"ca,le|way"}, 49)
    elseif var_0001 == 94 then
        unknown_0032H({"lane", "british", "lord"}, 49)
    elseif var_0001 == 95 then
        unknown_0032H({"noble|road"}, 49)
    elseif var_0001 == 96 then
        unknown_0032H({"avenue", "we,|end"}, 49)
    elseif var_0001 == 97 then
        unknown_0032H({"hazle|lane"}, 49)
    elseif var_0001 == 98 then
        unknown_0032H({"nor(", "square", "park"}, 49)
    elseif var_0001 == 99 then
        unknown_0032H({"sou(", "square", "park"}, 49)
    elseif var_0001 == 100 then
        unknown_0032H({",r)t", "market"}, 49)
    elseif var_0001 == 101 then
        unknown_0032H({"way", "golden"}, 49)
    elseif var_0001 == 102 then
        unknown_0032H({"avenue", "center"}, 49)
    elseif var_0001 == 103 then
        unknown_0032H({"lane", "spike"}, 49)
    elseif var_0001 == 104 then
        unknown_0032H({"avenue", "avatar"}, 49)
    elseif var_0001 == 105 then
        unknown_0032H({"lane", ",able"}, 49)
    elseif var_0001 == 106 then
        unknown_0032H({"avenue", "end", "+,"}, 49)
    elseif var_0001 == 107 then
        unknown_0032H({"road", "farm"}, 49)
    elseif var_0001 == 108 then
        unknown_0032H({",r)t", "nugget"}, 49)
    elseif var_0001 == 109 then
        unknown_0032H({"cove", "cool"}, 49)
    elseif var_0001 == 110 then
        unknown_0032H({"avenue", "end", "nor("}, 49)
    elseif var_0001 == 111 then
        unknown_0032H({"way", "eye", "golden"}, 49)
    elseif var_0001 == 112 then
        unknown_0032H({"tower", "dark", "(e", "to"}, 49)
    elseif var_0001 == 113 then
        unknown_0032H({"LANDSLIDES", "OF", "BEWARE"}, 49)
    elseif var_0001 == 114 then
        unknown_0032H({"ENTER", "NOT", "DO", "DANGER:"}, 49)
    elseif var_0001 == 115 then
        unknown_0032H({"one", "number", "old"}, 49)
    elseif var_0001 == 116 then
        unknown_0032H({"liche", "(e", "free", "do|not"}, 49)
    elseif var_0001 == 117 then
        unknown_0032H({"wi(in", "mon,ers", "beware"}, 49)
    elseif var_0001 == 118 then
        unknown_0032H({"graves", "paupers"}, 49)
    elseif var_0001 == 119 then
        unknown_0032H({"soul", "of|a", "a|soul", "|manrik|"}, 49)
    elseif var_0001 == 120 then
        unknown_0032H({"(e|loss", "words|for", "jules|no", "here|lies"}, 49)
    elseif var_0001 == 121 then
        unknown_0032H({"tragedy", "dea(|a", "her", "|morgan|"}, 49)
    elseif var_0001 == 122 then
        unknown_0032H({"many", "friend|to", "ke(ian", "here|lies"}, 49)
    elseif var_0001 == 123 then
        unknown_0032H({"his|body", "deeper|(an", "his|soul", "|wadley|"}, 49)
    elseif var_0001 == 124 then
        unknown_0032H({"spirit", "kindred", "jenna", "here|lies"}, 49)
    elseif var_0001 == 125 then
        unknown_0032H({"end", "d+d"}, 49)
    elseif var_0001 == 126 then
        unknown_0032H({"brae", "skara", "to"}, 49)
    elseif var_0001 == 127 then
        unknown_0032H({"GUARDIAN", "OF|THE", "THRONE", "THE"}, 49)
    elseif var_0001 == 128 then
        unknown_0032H({"britain", "to", "nor("}, 49)
    elseif var_0001 == 129 then
        unknown_0032H({"lever", "pull"}, 49)
    elseif var_0001 == 130 then
        unknown_0032H({"round", "and", "round"}, 49)
    elseif var_0001 == 131 then
        unknown_0032H({"out", "way"}, 49)
    elseif var_0001 == 132 then
        unknown_0032H({"open", "doors", "keep"}, 49)
    elseif var_0001 == 133 then
        unknown_0032H({"tower", "selwyns"}, 49)
    elseif var_0001 == 134 then
        unknown_0032H({"fire", "(e", "follow"}, 49)
    end
    return
end