require "U7LuaFuncs"
-- Function 017B: Manages sign text display
function func_017B(itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid() ~= 1 then
        return
    end
    local0 = call_0908H()
    local1 = callis_0014(itemref)
    if local1 > 151 then
        callis_0032({"SIGN", "VALID", "NOT A", "THIS IS"}, 49)
    elseif local1 == 0 then
        callis_0032({"lizard", "gilded", "at|(e", "drink"}, 49)
    elseif local1 == 1 then
        callis_0032({"47", "~population", "brae~", "skara"}, 49)
    elseif local1 == 2 then
        callis_0032({"trinsic"}, 49)
    elseif local1 == 3 then
        callis_0032({"hound", "honorable", "(e"}, 49)
    elseif local1 == 4 then
        callis_0032({"HALL", "FELLOWSHIP"}, 49)
    elseif local1 == 5 then
        callis_0032({"britain"}, 49)
    elseif local1 == 6 then
        callis_0032({"THE AVATAR@", "@TRIALS OF", "RAYMUNDO'S", "COMING:"}, 49)
    elseif local1 == 7 then
        callis_0032({"NOW", "SEATS", "THY", "RESERVE"}, 49)
    elseif local1 == 8 then
        callis_0032({"museum", "royal"}, 49)
    elseif local1 == 9 then
        callis_0032({"hall", "music", "(e"}, 49)
    elseif local1 == 11 then
        callis_0032({"inn", "wayfarer's", "(e"}, 49)
    elseif local1 == 12 then
        callis_0032({"bows", "iolos"}, 49)
    elseif local1 == 13 then
        callis_0032({"boar", "blue", "(e"}, 49)
    elseif local1 == 14 then
        callis_0032({"clo(iers", "gayes"}, 49)
    elseif local1 == 15 then
        callis_0032({"armoury", ",ar", "nor("}, 49)
    elseif local1 == 16 then
        callis_0032({"oar", "oaken", "(e"}, 49)
    elseif local1 == 17 then
        callis_0032({"bakery"}, 49)
    elseif local1 == 18 then
        callis_0032({"jeweler"}, 49)
    elseif local1 == 19 then
        callis_0032({"market", "farmers"}, 49)
    elseif local1 == 20 then
        callis_0032({"apo(ecary"}, 49)
    elseif local1 == 21 then
        callis_0032({"mint", "royal"}, 49)
    elseif local1 == 22 then
        callis_0032({"h+ler", "(e", "csil"}, 49)
    elseif local1 == 23 then
        callis_0032({"provisions"}, 49)
    elseif local1 == 24 then
        callis_0032({"orchards", "royal"}, 49)
    elseif local1 == 25 then
        callis_0032({"ART THOU AN AVATAR?", " -- ", "TEST OF STRENGTH"}, 49)
    elseif local1 == 26 then
        callis_0032({"show", "judy", "punch and"}, 49)
    elseif local1 == 27 then
        callis_0032({"fish|n|chips"}, 49)
    elseif local1 == 28 then
        callis_0032({"cove"}, 49)
    elseif local1 == 29 then
        callis_0032({"emerald", "(e", "out|n|inn"}, 49)
    elseif local1 == 30 then
        callis_0032({"walk", "lovers"}, 49)
    elseif local1 == 31 then
        callis_0032({"den", "buccaneers", "(e|ba(s"}, 49)
    elseif local1 == 32 then
        callis_0032({"games", "of", "house"}, 49)
    elseif local1 == 33 then
        callis_0032({"virgin", "fallen", "(e"}, 49)
    elseif local1 == 34 then
        callis_0032({"budos"}, 49)
    elseif local1 == 35 then
        callis_0032({"RETREAT", "MEDITATION"}, 49)
    elseif local1 == 36 then
        callis_0032({"GO THIS WAY"}, 49)
    elseif local1 == 37 then
        callis_0032({"lycaeum"}, 49)
    elseif local1 == 38 then
        callis_0032({"dock", "hallowed", "(e"}, 49)
    elseif local1 == 39 then
        callis_0032({"knave", "friendly", "(e"}, 49)
    elseif local1 == 40 then
        callis_0032({"lizard", "gilded", "(e"}, 49)
    elseif local1 == 41 then
        callis_0032({"h+ler", "provisions"}, 49)
    elseif local1 == 42 then
        callis_0032({"eldro(s", "items", "of", "house"}, 49)
    elseif local1 == 43 then
        callis_0032({"company", "mini*", "britannian"}, 49)
    elseif local1 == 44 then
        callis_0032({"branch", "minoc"}, 49)
    elseif local1 == 45 then
        callis_0032({"trainer", "scholar"}, 49)
    elseif local1 == 46 then
        callis_0032({"town|hall"}, 49)
    elseif local1 == 47 then
        callis_0032({"magics", "wis-surs"}, 49)
    elseif local1 == 48 then
        callis_0032({"observatory"}, 49)
    elseif local1 == 49 then
        callis_0032({"vesper"}, 49)
    elseif local1 == 50 then
        callis_0032({"moo*low"}, 49)
    elseif local1 == 51 then
        callis_0032({"terfin"}, 49)
    elseif local1 == 52 then
        callis_0032({"hold", "serpents"}, 49)
    elseif local1 == 53 then
        callis_0032({"abbey", "empa("}, 49)
    elseif local1 == 54 then
        callis_0032({"jhelom"}, 49)
    elseif local1 == 55 then
        callis_0032({"minoc"}, 49)
    elseif local1 == 56 then
        callis_0032({"undertaker"}, 49)
    elseif local1 == 57 then
        callis_0032({"britannia", "of", "court"}, 49)
    elseif local1 == 58 then
        callis_0032({"high", "prison"}, 49)
    elseif local1 == 59 then
        callis_0032({"damsel", "mode,", "(e"}, 49)
    elseif local1 == 60 then
        callis_0032({"armoury", "blacksmi("}, 49)
    elseif local1 == 61 then
        callis_0032({"center", "recr+tion"}, 49)
    elseif local1 == 62 then
        callis_0032({"knowledge", "of", "hall"}, 49)
    elseif local1 == 63 then
        callis_0032({"avatar", "(ere"}, 49)
    elseif local1 == 64 then
        callis_0032({"hello", "the|avatars", "in|person", "tonight|9-12"}, 49)
    elseif local1 == 65 then
        callis_0032({"why?", "ask", "why"}, 49)
    elseif local1 == 66 then
        callis_0032({"honor", "of", ",r)t"}, 49)
    elseif local1 == 67 then
        callis_0032({"pa(", "paladins"}, 49)
    elseif local1 == 68 then
        callis_0032({"FELLOWSHIP", "THE", "OF", "AVENUE"}, 49)
    elseif local1 == 69 then
        callis_0032({"walk", "widows"}, 49)
    elseif local1 == 70 then
        callis_0032({"hallway", "harolds"}, 49)
    elseif local1 == 71 then
        callis_0032({"fools|way"}, 49)
    elseif local1 == 72 then
        callis_0032({"road", "whitsaber", ",rand"}, 49)
    elseif local1 == 73 then
        callis_0032({"avenue", "chalice"}, 49)
    elseif local1 == 74 then
        callis_0032({"coves", "two"}, 49)
    elseif local1 == 75 then
        callis_0032({"road", "wall", "we,"}, 49)
    elseif local1 == 76 then
        callis_0032({"road", "wall", "we,"}, 49)
    elseif local1 == 77 then
        callis_0032({"road", "wall", "we,"}, 49)
    elseif local1 == 78 then
        callis_0032({"road", "wall", "we,"}, 49)
    elseif local1 == 79 then
        callis_0032({"road", "wall", "+,"}, 49)
    elseif local1 == 80 then
        callis_0032({"road", "wall", "+,"}, 49)
    elseif local1 == 81 then
        callis_0032({"road", "wall", "+,"}, 49)
    elseif local1 == 82 then
        callis_0032({"road", "wall", "nor("}, 49)
    elseif local1 == 83 then
        callis_0032({"road", "wall", "sou("}, 49)
    elseif local1 == 84 then
        callis_0032({"way", "heroes"}, 49)
    elseif local1 == 85 then
        callis_0032({"sou(", "iolos"}, 49)
    elseif local1 == 86 then
        callis_0032({"paws"}, 49)
    elseif local1 == 87 then
        callis_0032({"salty|dog", "(e"}, 49)
    elseif local1 == 88 then
        callis_0032({"SHELTER", "FELLOWSHIP"}, 49)
    elseif local1 == 89 then
        callis_0032({"branch", "vesper"}, 49)
    elseif local1 == 90 then
        callis_0032({"cork", "checquered", "(e"}, 49)
    elseif local1 == 91 then
        callis_0032({"guild", "artists"}, 49)
    elseif local1 == 92 then
        callis_0032({",ool", "and", "(e bunk"}, 49)
    elseif local1 == 93 then
        callis_0032({"scars", "of", "library", "(e"}, 49)
    elseif local1 == 94 then
        callis_0032({"clo(es", "carlyns"}, 49)
    elseif local1 == 95 then
        callis_0032({"richard", "lies|ma,er", "walls", "wi(in|(ese"}, 49)
    elseif local1 == 96 then
        callis_0032({"ca,le|way"}, 49)
    elseif local1 == 97 then
        callis_0032({"lane", "british", "lord"}, 49)
    elseif local1 == 98 then
        callis_0032({"noble|road"}, 49)
    elseif local1 == 99 then
        callis_0032({"avenue", "we,|end"}, 49)
    elseif local1 == 100 then
        callis_0032({"hazle|lane"}, 49)
    elseif local1 == 101 then
        callis_0032({"nor(", "square", "park"}, 49)
    elseif local1 == 102 then
        callis_0032({"sou(", "square", "park"}, 49)
    elseif local1 == 103 then
        callis_0032({",r)t", "market"}, 49)
    elseif local1 == 104 then
        callis_0032({"way", "golden"}, 49)
    elseif local1 == 105 then
        callis_0032({"avenue", "center"}, 49)
    elseif local1 == 106 then
        callis_0032({"lane", "spike"}, 49)
    elseif local1 == 107 then
        callis_0032({"avenue", "avatar"}, 49)
    elseif local1 == 108 then
        callis_0032({"lane", ",able"}, 49)
    elseif local1 == 109 then
        callis_0032({"avenue", "end", "+,"}, 49)
    elseif local1 == 110 then
        callis_0032({"road", "farm"}, 49)
    elseif local1 == 111 then
        callis_0032({",r)t", "nugget"}, 49)
    elseif local1 == 112 then
        callis_0032({"cove", "cool"}, 49)
    elseif local1 == 113 then
        callis_0032({"avenue", "end", "nor("}, 49)
    elseif local1 == 114 then
        callis_0032({"way", "eye", "golden"}, 49)
    elseif local1 == 115 then
        callis_0032({"tower", "dark", "(e", "to"}, 49)
    elseif local1 == 116 then
        callis_0032({"LANDSLIDES", "OF", "BEWARE"}, 49)
    elseif local1 == 117 then
        callis_0032({"ENTER", "NOT", "DO", "DANGER:"}, 49)
    elseif local1 == 118 then
        callis_0032({"one", "number", "old"}, 49)
    elseif local1 == 119 then
        callis_0032({"liche", "(e", "free", "do|not"}, 49)
    elseif local1 == 120 then
        callis_0032({"wi(in", "mon,ers", "beware"}, 49)
    elseif local1 == 121 then
        callis_0032({"graves", "paupers"}, 49)
    elseif local1 == 122 then
        callis_0032({"soul", "of|a", "a|soul", "|manrik|"}, 49)
    elseif local1 == 123 then
        callis_0032({"(e|loss", "words|for", "jules|no", "here|lies"}, 49)
    elseif local1 == 124 then
        callis_0032({"tragedy", "dea(|a", "her", "|morgan|"}, 49)
    elseif local1 == 125 then
        callis_0032({"many", "friend|to", "ke(ian", "here|lies"}, 49)
    elseif local1 == 126 then
        callis_0032({"his|body", "deeper|(an", "his|soul", "|wadley|"}, 49)
    elseif local1 == 127 then
        callis_0032({"spirit", "kindred", "jenna", "here|lies"}, 49)
    elseif local1 == 128 then
        callis_0032({"end", "d+d"}, 49)
    elseif local1 == 129 then
        callis_0032({"brae", "skara", "to"}, 49)
    elseif local1 == 130 then
        callis_0032({"GUARDIAN", "OF|THE", "THRONE", "THE"}, 49)
    elseif local1 == 131 then
        callis_0032({"britain", "to", "nor("}, 49)
    elseif local1 == 132 then
        callis_0032({"lever", "pull"}, 49)
    elseif local1 == 133 then
        callis_0032({"round", "and", "round"}, 49)
    elseif local1 == 134 then
        callis_0032({"out", "way"}, 49)
    elseif local1 == 135 then
        callis_0032({"open", "doors", "keep"}, 49)
    elseif local1 == 136 then
        callis_0032({"tower", "selwyns"}, 49)
    elseif local1 == 137 then
        callis_0032({"fire", "(e", "follow"}, 49)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end