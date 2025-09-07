--- Best guess: Displays various signs and messages based on item quality, ranging from location names to gravestones and warnings, used for world-building and navigation.
function func_017B(eventid, objectref)
    local var_0000, var_0001
    var_0000 = get_player_name()
    var_0001 = get_object_quality(objectref)
    if var_0001 > 151 then
        open_book(1, {"SIGN", "VALID", "NOT A", "THIS IS"})
    elseif var_0001 == 0 then
        open_book(1, {"lizard", "gilded", "at|(e", "drink"})
    elseif var_0001 == 1 then
        open_book(1, {"47", "~population", "brae~", "skara"})
    elseif var_0001 == 2 then
        open_book(1, {"trinsic"})
    elseif var_0001 == 3 then
        open_book(1, {"hound", "honorable", "(e"})
    elseif var_0001 == 4 then
        open_book(1, {"HALL", "FELLOWSHIP"})
    elseif var_0001 == 5 then
        open_book(1, {"britain"})
    elseif var_0001 == 6 then
        open_book(1, {"THE AVATAR@", "@TRIALS OF", "RAYMUNDO'S", "COMING:"})
    elseif var_0001 == 7 then
        open_book(1, {"NOW", "SEATS", "THY", "RESERVE"})
    elseif var_0001 == 8 then
        open_book(1, {"museum", "royal"})
    elseif var_0001 == 9 then
        open_book(1, {"hall", "music", "(e"})
    elseif var_0001 == 11 then
        open_book(1, {"inn", "wayfarer's", "(e"})
    elseif var_0001 == 12 then
        open_book(1, {"bows", "iolos"})
    elseif var_0001 == 13 then
        open_book(1, {"boar", "blue", "(e"})
    elseif var_0001 == 14 then
        open_book(1, {"clo(iers", "gayes"})
    elseif var_0001 == 15 then
        open_book(1, {"armoury", ",ar", "nor("})
    elseif var_0001 == 16 then
        open_book(1, {"oar", "oaken", "(e"})
    elseif var_0001 == 17 then
        open_book(1, {"bakery"})
    elseif var_0001 == 18 then
        open_book(1, {"jeweler"})
    elseif var_0001 == 19 then
        open_book(1, {"market", "farmers"})
    elseif var_0001 == 20 then
        open_book(1, {"apo(ecary"})
    elseif var_0001 == 21 then
        open_book(1, {"mint", "royal"})
    elseif var_0001 == 22 then
        open_book(1, {"h+ler", "(e", "csil"})
    elseif var_0001 == 23 then
        open_book(1, {"provisions"})
    elseif var_0001 == 24 then
        open_book(1, {"orchards", "royal"})
    elseif var_0001 == 25 then
        open_book(1, {"ART THOU AN AVATAR?", "--", "TEST OF STRENGTH"})
    elseif var_0001 == 26 then
        open_book(1, {"show", "judy", "punch and"})
    elseif var_0001 == 27 then
        open_book(1, {"fish|n|chips"})
    elseif var_0001 == 28 then
        open_book(1, {"cove"})
    elseif var_0001 == 29 then
        open_book(1, {"emerald", "(e"})
    elseif var_0001 == 30 then
        open_book(1, {"out|n|inn"})
    elseif var_0001 == 31 then
        open_book(1, {"walk", "lovers"})
    elseif var_0001 == 32 then
        open_book(1, {"den", "buccaneers"})
    elseif var_0001 == 33 then
        open_book(1, {"(e|ba(s"})
    elseif var_0001 == 34 then
        open_book(1, {"games", "of", "house"})
    elseif var_0001 == 35 then
        open_book(1, {"virgin", "fallen", "(e"})
    elseif var_0001 == 36 then
        open_book(1, {"budos"})
    elseif var_0001 == 37 then
        open_book(1, {"RETREAT", "MEDITATION"})
    elseif var_0001 == 44 then
        open_book(1, {"GO THIS WAY"})
    elseif var_0001 == 52 then
        open_book(1, {"lycaeum"})
    elseif var_0001 == 53 then
        open_book(1, {"dock", "hallowed", "(e"})
    elseif var_0001 == 54 then
        open_book(1, {"knave", "friendly", "(e"})
    elseif var_0001 == 55 then
        open_book(1, {"lizard", "gilded", "(e"})
    elseif var_0001 == 56 then
        open_book(1, {"h+ler"})
    elseif var_0001 == 57 then
        open_book(1, {"provisions", "eldro(s"})
    elseif var_0001 == 58 then
        open_book(1, {"items", "of", "house"})
    elseif var_0001 == 59 then
        open_book(1, {"company", "mini*", "britannian"})
    elseif var_0001 == 60 then
        open_book(1, {"branch", "minoc"})
    elseif var_0001 == 61 then
        open_book(1, {"trainer"})
    elseif var_0001 == 62 then
        open_book(1, {"scholar"})
    elseif var_0001 == 63 then
        open_book(1, {"town|hall"})
    elseif var_0001 == 64 then
        open_book(1, {"magics", "wis-surs"})
    elseif var_0001 == 65 then
        open_book(1, {"observatory"})
    elseif var_0001 == 66 then
        open_book(1, {"vesper"})
    elseif var_0001 == 67 then
        open_book(1, {"moo*low"})
    elseif var_0001 == 68 then
        open_book(1, {"terfin"})
    elseif var_0001 == 69 then
        open_book(1, {"hold", "serpents"})
    elseif var_0001 == 70 then
        open_book(1, {"abbey", "empa("})
    elseif var_0001 == 71 then
        open_book(1, {"jhelom"})
    elseif var_0001 == 72 then
        open_book(1, {"minoc"})
    elseif var_0001 == 73 then
        open_book(1, {"undertaker"})
    elseif var_0001 == 74 then
        open_book(1, {"britannia", "of", "court", "high"})
    elseif var_0001 == 75 then
        open_book(1, {"prison"})
    elseif var_0001 == 76 then
        open_book(1, {"damsel", "mode,", "(e"})
    elseif var_0001 == 77 then
        open_book(1, {"armoury"})
    elseif var_0001 == 78 then
        open_book(1, {"blacksmi("})
    elseif var_0001 == 79 then
        open_book(1, {"center", "recr+tion"})
    elseif var_0001 == 80 then
        open_book(1, {"knowledge", "of", "hall"})
    elseif var_0001 == 81 then
        open_book(1, {"avatar", "(ere", "hello"})
    elseif var_0001 == 82 then
        open_book(1, {"the|avatars", "in|person", "tonight|9-12"})
    elseif var_0001 == 83 then
        open_book(1, {"why?", "ask", "why"})
    elseif var_0001 == 84 then
        open_book(1, {"honor", "of", ",r)t"})
    elseif var_0001 == 85 then
        open_book(1, {"pa(", "paladins"})
    elseif var_0001 == 86 then
        open_book(1, {"FELLOWSHIP", "THE", "OF", "AVENUE"})
    elseif var_0001 == 87 then
        open_book(1, {"walk", "widows"})
    elseif var_0001 == 88 then
        open_book(1, {"hallway", "harolds"})
    elseif var_0001 == 89 then
        open_book(1, {"fools|way"})
    elseif var_0001 == 90 then
        open_book(1, {"road", "whitsaber"})
    elseif var_0001 == 91 then
        open_book(1, {",rand"})
    elseif var_0001 == 92 then
        open_book(1, {"avenue", "chalice"})
    elseif var_0001 == 93 then
        open_book(1, {"coves", "two"})
    elseif var_0001 == 94 then
        open_book(1, {"road", "wall", "we,"})
    elseif var_0001 == 95 then
        open_book(1, {"road", "wall", "+,"})
    elseif var_0001 == 96 then
        open_book(1, {"road", "wall", "nor("})
    elseif var_0001 == 97 then
        open_book(1, {"road", "wall", "sou("})
    elseif var_0001 == 98 then
        open_book(1, {"way", "heroes"})
    elseif var_0001 == 99 then
        open_book(1, {"sou(", "iolos"})
    elseif var_0001 == 100 then
        open_book(1, {"paws"})
    elseif var_0001 == 101 then
        open_book(1, {"salty|dog", "(e"})
    elseif var_0001 == 102 then
        open_book(1, {"SHELTER", "FELLOWSHIP"})
    elseif var_0001 == 103 then
        open_book(1, {"branch", "vesper"})
    elseif var_0001 == 104 then
        open_book(1, {"cork", "checquered", "(e"})
    elseif var_0001 == 105 then
        open_book(1, {"guild", "artists"})
    elseif var_0001 == 106 then
        open_book(1, {",ool", "and", "(e bunk"})
    elseif var_0001 == 107 then
        open_book(1, {"scars", "of", "library", "(e"})
    elseif var_0001 == 108 then
        open_book(1, {"clo(es", "carlyns"})
    elseif var_0001 == 109 then
        open_book(1, {"richard", "lies|ma,er", "walls", "wi(in|(ese"})
    elseif var_0001 == 110 then
        open_book(1, {"ca,le|way"})
    elseif var_0001 == 111 then
        open_book(1, {"lane", "british", "lord"})
    elseif var_0001 == 112 then
        open_book(1, {"noble|road"})
    elseif var_0001 == 113 then
        open_book(1, {"avenue", "we,|end"})
    elseif var_0001 == 114 then
        open_book(1, {"hazle|lane"})
    elseif var_0001 == 115 then
        open_book(1, {"nor(", "square", "park"})
    elseif var_0001 == 116 then
        open_book(1, {"sou(", "square", "park"})
    elseif var_0001 == 117 then
        open_book(1, {",r)t", "market"})
    elseif var_0001 == 118 then
        open_book(1, {"way", "golden"})
    elseif var_0001 == 119 then
        open_book(1, {"avenue", "center"})
    elseif var_0001 == 120 then
        open_book(1, {"lane", "spike"})
    elseif var_0001 == 121 then
        open_book(1, {"avenue", "avatar"})
    elseif var_0001 == 122 then
        open_book(1, {"lane", ",able"})
    elseif var_0001 == 123 then
        open_book(1, {"avenue", "end", "+,"})
    elseif var_0001 == 124 then
        open_book(1, {"road", "farm"})
    elseif var_0001 == 125 then
        open_book(1, {",r)t", "nugget"})
    elseif var_0001 == 126 then
        open_book(1, {"cove", "cool"})
    elseif var_0001 == 127 then
        open_book(1, {"avenue", "end", "nor("})
    elseif var_0001 == 128 then
        open_book(1, {"way", "eye", "golden"})
    elseif var_0001 == 129 then
        open_book(1, {"tower", "dark", "(e", "to"})
    elseif var_0001 == 130 then
        open_book(1, {"LANDSLIDES", "OF", "BEWARE"})
    elseif var_0001 == 131 then
        open_book(1, {"ENTER", "NOT", "DO", "DANGER:"})
    elseif var_0001 == 132 then
        open_book(1, {"one", "number", "old"})
    elseif var_0001 == 133 then
        open_book(1, {"liche", "(e", "free", "do|not"})
    elseif var_0001 == 134 then
        open_book(1, {"wi(in", "mon,ers", "beware"})
    elseif var_0001 == 135 then
        open_book(1, {"graves", "paupers"})
    elseif var_0001 == 136 then
        open_book(1, {"soul", "of|a", "a|soul", "|manrik|"})
    elseif var_0001 == 137 then
        open_book(1, {"(e|loss", "words|for", "jules|no", "here|lies"})
    elseif var_0001 == 138 then
        open_book(1, {"tragedy", "dea(|a", "her", "|morgan|"})
    elseif var_0001 == 139 then
        open_book(1, {"many", "friend|to", "ke(ian", "here|lies"})
    elseif var_0001 == 140 then
        open_book(1, {"his|body", "deeper|(an", "his|soul", "|wadley|"})
    elseif var_0001 == 141 then
        open_book(1, {"spirit", "kindred", "jenna", "here|lies"})
    elseif var_0001 == 142 then
        open_book(1, {"end", "d+d"})
    elseif var_0001 == 143 then
        open_book(1, {"brae", "skara", "to"})
    elseif var_0001 == 144 then
        open_book(1, {"GUARDIAN", "OF|THE", "THRONE", "THE"})
    elseif var_0001 == 145 then
        open_book(1, {"britain", "to", "nor("})
    elseif var_0001 == 146 then
        open_book(1, {"lever", "pull"})
    elseif var_0001 == 147 then
        open_book(1, {"round", "and", "round"})
    elseif var_0001 == 148 then
        open_book(1, {"out", "way"})
    elseif var_0001 == 149 then
        open_book(1, {"open", "doors", "keep"})
    elseif var_0001 == 150 then
        open_book(1, {"tower", "selwyns"})
    elseif var_0001 == 151 then
        open_book(1, {"fire", "(e", "follow"})
    end
end