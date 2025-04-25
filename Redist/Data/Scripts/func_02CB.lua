-- Function 02CB: Tombstone inscriptions
function func_02CB(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 1 then
        -- Note: Original has 'db 2c' here, ignored
        return
    end

    local0 = call_0908H()
    local1 = _GetItemQuality(itemref)

    if local1 > 102 then
        _DisplaySign({"SIGN ZERO", "IS"}, 50)
    elseif local1 == 0 then
        _DisplaySign({"he|died", "where", "buried", "john|doe", "here|lies"}, 50)
    elseif local1 == 1 then
        _DisplaySign({"thy|(umb", "about", "sorry", "|garth|"}, 50)
    elseif local1 == 2 then
        _DisplaySign({"FOREVER", "HERS", "YOUTH IS", "LADY M:"}, 50)
    elseif local1 == 3 then
        _DisplaySign({"forever", "re,", "spirit", "may|his", "|julius|"}, 50)
    elseif local1 == 4 then
        _DisplaySign({"sargeant", "died|a", "argent", "lies", "here"}, 50)
    elseif local1 == 5 then
        _DisplaySign({"numbered", "were", "days", "his", "|darek|"}, 50)
    elseif local1 == 6 then
        _DisplaySign({"wi(|us", "remain", "words", "his", "|malc|"}, 50)
    elseif local1 == 7 then
        _DisplaySign({"soar", "spirit", "her", "may", "|nina|"}, 50)
    elseif local1 == 8 then
        _DisplaySign({"(e|joke", "finished", "he|never", "|bart|"}, 50)
    elseif local1 == 9 then
        _DisplaySign({"flower", "delicate", "a", "|ann|"}, 50)
    elseif local1 == 10 then
        _DisplaySign({"ship", "wi(|(e", "down", "went", "|dallas|"}, 50)
    elseif local1 == 11 then
        _DisplaySign({"pink", "great|in", "looked", "|alan|"}, 50)
    elseif local1 == 12 then
        _DisplaySign({"a pen", "killed|by", "ken", "lies", "here"}, 50)
    elseif local1 == 13 then
        _DisplaySign({"in|hand", "a|pencil", "died|wi(", "|jeff|d|"}, 50)
    elseif local1 == 14 then
        _DisplaySign({"sharp", "were|too", "(e|notes", "|martin|"}, 50)
    elseif local1 == 15 then
        _DisplaySign({"name", "to|his", "a|credit", "|tony|b|"}, 50)
    elseif local1 == 16 then
        _DisplaySign({"him", "ma,ered", "spells", "|philip|"}, 50)
    elseif local1 == 17 then
        _DisplaySign({"end", "till|(e", "laughed", "|chuckles|"}, 50)
    elseif local1 == 18 then
        _DisplaySign({"bad|gump", "of|a|big|", "bit|(e|rump", "|art|d|"}, 50)
    elseif local1 == 19 then
        _DisplaySign({"to|us|all", "a|wonder", "he|was", "|jim|g|"}, 50)
    elseif local1 == 20 then
        _DisplaySign({"a|runner", "rebel|and", "he|was|a", "|will|"}, 50)
    elseif local1 == 21 then
        _DisplaySign({"with|gumps", "from|a|bout", "lost|early", "|mr|mike|"}, 50)
    elseif local1 == 22 then
        _DisplaySign({"made|him", "sleep", "awake", "odd|how", "|paul|"}, 50)
    elseif local1 == 23 then
        _DisplaySign({"d+(", "atomic", "demanded", "he", "|zack|"}, 50)
    elseif local1 == 24 then
        _DisplaySign({"fate", "venomous", "of", "a|victim", "|phil|s|"}, 50)
    elseif local1 == 25 then
        _DisplaySign({"radiation", "danger", "|jeff|w|"}, 50)
    elseif local1 == 26 then
        _DisplaySign({"for|gumps", "source", "a|good", "|tony|z|"}, 50)
    elseif local1 == 27 then
        _DisplaySign({"winged", "he|was|only", "we|(ought", "|bill|b|"}, 50)
    elseif local1 == 28 then
        _DisplaySign({"victim", "guest", "|charles|c|"}, 50)
    elseif local1 == 29 then
        _DisplaySign({"depainted", "dearly", "|danny|"}, 50)
    elseif local1 == 30 then
        _DisplaySign({"greener", "(e|grass", "he|makes", "|bob|"}, 50)
    elseif local1 == 31 then
        _DisplaySign({"gonna", "she|is|a", "donna", "here|lies"}, 50)
    elseif local1 == 32 then
        _DisplaySign({"talent", "of", "a|portrait", "|karl|"}, 50)
    elseif local1 == 33 then
        _DisplaySign({"character", "explosive", "an", "|chris|d|"}, 50)
    elseif local1 == 34 then
        _DisplaySign({"smile", "with|a", "went", "|glen|"}, 50)
    elseif local1 == 35 then
        _DisplaySign({"ending", "fantastic", "had|a", "|bruce|l|"}, 50)
    elseif local1 == 36 then
        _DisplaySign({"br+(", "last", "his", "|loubet|"}, 50)
    elseif local1 == 37 then
        _DisplaySign({"for|good", "comi*|gone", "lo*|time", "|micael|p|"}, 50)
    elseif local1 == 38 then
        _DisplaySign({"over", "is", "(e|party", "|jake|"}, 50)
    elseif local1 == 39 then
        _DisplaySign({"faces", "(ousand", "man|of|a", "|gary|w|"}, 50)
    elseif local1 == 40 then
        _DisplaySign({"life", "full", "it|was|a", "|(e|b+,|"}, 50)
    elseif local1 == 41 then
        _DisplaySign({"much|work", "from|too", "kirk|died", "here|lies"}, 50)
    elseif local1 == 42 then
        _DisplaySign({"opponent", "wor(y", "a", "|targ|"}, 50)
    elseif local1 == 43 then
        _DisplaySign({"crystal", "like|a", "shined", "my,ral", "here|lies"}, 50)
    elseif local1 == 44 then
        _DisplaySign({"not", "and|why", "marc", "here|lies"}, 50)
    elseif local1 == 45 then
        _DisplaySign({"maker", "music", "(e", "|nenad|"}, 50)
    elseif local1 == 46 then
        _DisplaySign({"never|done", "work|was", "his", "john", "here|lies"}, 50)
    elseif local1 == 47 then
        _DisplaySign({"him", "killed", "we", "|bruce|a|"}, 50)
    elseif local1 == 48 then
        _DisplaySign({"loaded", "was", "(e|game", "unaware", "|eric|"}, 50)
    elseif local1 == 49 then
        _DisplaySign({"enough", "is|not", "(e|world", "|raymond|"}, 50)
    elseif local1 == 50 then
        _DisplaySign({"garriot", "by", "died", "|Beth|"}, 50)
    elseif local1 == 51 then
        _DisplaySign({"di*os", "by", "+ten", "|jack|"}, 50)
    elseif local1 == 52 then
        _DisplaySign({"lover", "poisoni*", "hu*|for", "|michelle|"}, 50)
    elseif local1 == 53 then
        _DisplaySign({"tomorrow", "gone", "today", "gone", "|scott|h|"}, 50)
    elseif local1 == 54 then
        _DisplaySign({"mon,er", "(e", "by", "swallowed", "|brian|"}, 50)
    elseif local1 == 55 then
        _DisplaySign({"(e|end", "until", "managed", "|sherry|c|"}, 50)
    elseif local1 == 56 then
        _DisplaySign({"one", "was|job", "quality", "|karen|"}, 50)
    elseif local1 == 57 then
        _DisplaySign({"i|roam", "but|,ill", "here|i|lie", "|j|shelton"}, 50)
    elseif local1 == 58 then
        _DisplaySign({"undergrnd", "under|gun", "underfed", "|marco|"}, 50)
    elseif local1 == 59 then
        _DisplaySign({"of|a|swan", "(e|grace", "she|had", "|lynn|"}, 50)
    elseif local1 == 60 then
        _DisplaySign({"urit", "canus|meus", "me|puergo", "|chenault|"}, 50)
    elseif local1 == 61 then
        _DisplaySign({"cocopuff", "and|tc", "to|dizzy", "|j|crippen|"}, 50)
    elseif local1 == 62 then
        _DisplaySign({"tomb,one", "(e|unknown", "|tim|"}, 50)
    elseif local1 == 63 then
        _DisplaySign({"fireball", "by|grogs", "blown|away", "|na(an|"}, 50)
    elseif local1 == 64 then
        _DisplaySign({"what", "i|drank", "last|words", "|james|n|"}, 50)
    elseif local1 == 65 then
        _DisplaySign({"out", "all|te,ed", "Ben", "here|lies"}, 50)
    elseif local1 == 66 then
        _DisplaySign({"his|h+d", "axe|in", "buried|an", "|scott|"}, 50)
    elseif local1 == 67 then
        _DisplaySign({"exii", "vidi", "veni", "|duke|"}, 50)
    elseif local1 == 68 then
        _DisplaySign({"print", "fit|to", "every(i*", "|mike|h|"}, 50)
    elseif local1 == 69 then
        _DisplaySign({"to|us|all", "sunshine", "she|gave", "|robin|"}, 50)
    elseif local1 == 70 then
        _DisplaySign({"clued|in", "got", "never", "|m|", "|andrew|"}, 50)
    elseif local1 == 71 then
        _DisplaySign({"gr+t", "was", "(e|food", "|wayne|s|"}, 50)
    elseif local1 == 72 then
        _DisplaySign({"delivered", "was", "|craig|c|"}, 50)
    elseif local1 == 73 then
        _DisplaySign({"ate", "never", "fed|but", "|jeff|f|"}, 50)
    elseif local1 == 74 then
        _DisplaySign({"(ought", "for", "food", "|w|hagy"}, 50)
    elseif local1 == 75 then
        _DisplaySign({"wi(|gifts", "arrived", "|stevens|", "|m|"}, 50)
    elseif local1 == 76 then
        _DisplaySign({"dinner", "of", "bringer", "|g|", "|michelle|"}, 50)
    elseif local1 == 77 then
        _DisplaySign({"him", "was", "food", "|brian|s|"}, 50)
    elseif local1 == 78 then
        _DisplaySign({"dinner", "for", "as|in|d|", "d|", "|jackie|"}, 50)
    elseif local1 == 79 then
        _DisplaySign({"record", "perfect", "a", "spained", "|b|adams|"}, 50)
    elseif local1 == 80 then
        _DisplaySign({"now|below", "who|is", "fellow", "a|nice", "|hal|"}, 50)
    elseif local1 == 81 then
        _DisplaySign({"over", "over|and", "friend", "mans|best", "|rover|"}, 50)
    elseif local1 == 82 then
        _DisplaySign({"dies", "never", "love", "age|old", "|felcore|"}, 50)
    elseif local1 == 83 then
        _DisplaySign({"of|course", "hes|d+d", "morse", "tony", "heres"}, 50)
    elseif local1 == 84 then
        _DisplaySign({"gross", "|", "salamon", "larry", "heres"}, 50)
    elseif local1 == 85 then
        _DisplaySign({"faltran", "who|is", "mcdonald", "darren"}, 50)
    elseif local1 == 86 then
        _DisplaySign({"chiltons", "from|(e", "away", "died", "|kevin|b|"}, 50)
    elseif local1 == 87 then
        _DisplaySign({"food", "worm", "michael|", "and", "|beth"}, 50)
    elseif local1 == 88 then
        _DisplaySign({"honorably", "died", "|a|h|"}, 50)
    elseif local1 == 89 then
        _DisplaySign({"went", "and", "gone", "|john|t|"}, 50)
    elseif local1 == 90 then
        _DisplaySign({"here", "installed", "", "|rey|"}, 50)
    elseif local1 == 91 then
        _DisplaySign({"died", "man|never", "deservi*", "a|more", "|rhoode|"}, 50)
    elseif local1 == 92 then
        _DisplaySign({"missed", "she|is", "moment", "every", "|jasner|"}, 50)
    elseif local1 == 93 then
        _DisplaySign({"he|lays", "now|here", "lied", "here|he", "|wampol|"}, 50)
    elseif local1 == 94 then
        _DisplaySign({"spurni*", "lovers", "by|a", "wounded", "|destra|"}, 50)
    elseif local1 == 95 then
        _DisplaySign({"boots|on", "wi(|his", "buried", "|mendar|"}, 50)
    elseif local1 == 96 then
        _DisplaySign({"good", "looked|so", "never", "old|age", "|greghim|"}, 50)
    elseif local1 == 97 then
        _DisplaySign({"now", "but|is", "missed", "was|not", "|sarnan|"}, 50)
    elseif local1 == 98 then
        _DisplaySign({"day", "of|his", "enchanter", "gr+te,", "|erlemar|"}, 50)
    elseif local1 == 99 then
        _DisplaySign({"conquered", "was", "saw|", "came|", "|galler|"}, 50)
    elseif local1 == 100 then
        _DisplaySign({"forever", "worm|food", "for|a|day", "queen", "|elgele(|"}, 50)
    elseif local1 == 101 then
        _DisplaySign({"stops", "never", "(e|si*i*", "|pantor|"}, 50)
    elseif local1 == 102 then
        _DisplaySign({"ma,er", "and", "fa(er", "beloved", "here|lies"}, 50)
    end

    return
end