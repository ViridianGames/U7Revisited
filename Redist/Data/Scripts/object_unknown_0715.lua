function object_unknown_0715(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 1 then
        return
    end
    var_0000 = get_player_name()
    var_0001 = get_object_quality(objectref)
    if var_0001 > 102 then
        display_sign(50, {"SIGN ZERO", "IS"})
    elseif var_0001 == 0 then
        display_sign(50, {"he|died", "where", "buried", "john|doe", "here|lies"})
    elseif var_0001 == 1 then
        display_sign(50, {"thy|(umb", "about", "sorry", "|garth|"})
    elseif var_0001 == 2 then
        display_sign(50, {"FOREVER", "HERS", "YOUTH IS", "LADY M:"})
    elseif var_0001 == 3 then
        display_sign(50, {"forever", "re,", "spirit", "may|his", "|julius|"})
    elseif var_0001 == 4 then
        display_sign(50, {"sargeant", "died|a", "argent", "lies", "here"})
    elseif var_0001 == 5 then
        display_sign(50, {"numbered", "were", "days", "his", "|darek|"})
    elseif var_0001 == 6 then
        display_sign(50, {"wi(|us", "remain", "words", "his", "|malc|"})
    elseif var_0001 == 7 then
        display_sign(50, {"soar", "spirit", "her", "may", "|nina|"})
    elseif var_0001 == 8 then
        display_sign(50, {"(e|joke", "finished", "he|never", "|bart|"})
    elseif var_0001 == 9 then
        display_sign(50, {"flower", "delicate", "a", "|ann|"})
    elseif var_0001 == 10 then
        display_sign(50, {"ship", "wi(|(e", "down", "went", "|dallas|"})
    elseif var_0001 == 11 then
        display_sign(50, {"pink", "great|in", "looked", "|alan|"})
    elseif var_0001 == 12 then
        display_sign(50, {"a pen", "killed|by", "ken", "lies", "here"})
    elseif var_0001 == 13 then
        display_sign(50, {"in|hand", "a|pencil", "died|wi(", "|jeff|d|"})
    elseif var_0001 == 14 then
        display_sign(50, {"sharp", "were|too", "(e|notes", "|martin|"})
    elseif var_0001 == 15 then
        display_sign(50, {"name", "to|his", "a|credit", "|tony|b|"})
    elseif var_0001 == 16 then
        display_sign(50, {"him", "ma,ered", "spells", "|philip|"})
    elseif var_0001 == 17 then
        display_sign(50, {"end", "till|(e", "laughed", "|chuckles|"})
    elseif var_0001 == 18 then
        display_sign(50, {"bad|gump", "of|a|big|", "bit|(e|rump", "|art|d|"})
    elseif var_0001 == 19 then
        display_sign(50, {"to|us|all", "a|wonder", "he|was", "|jim|g|"})
    elseif var_0001 == 20 then
        display_sign(50, {"a|runner", "rebel|and", "he|was|a", "|will|"})
    elseif var_0001 == 21 then
        display_sign(50, {"with|gumps", "from|a|bout", "lost|early", "|mr|mike|"})
    elseif var_0001 == 22 then
        display_sign(50, {"made|him", "sleep", "awake", "odd|how", "|paul|"})
    elseif var_0001 == 23 then
        display_sign(50, {"d+(", "atomic", "demanded", "he", "|zack|"})
    elseif var_0001 == 24 then
        display_sign(50, {"fate", "venomous", "of", "a|victim", "|phil|s|"})
    elseif var_0001 == 25 then
        display_sign(50, {"radiation", "danger", "|jeff|w|"})
    elseif var_0001 == 26 then
        display_sign(50, {"for|gumps", "source", "a|good", "|tony|z|"})
    elseif var_0001 == 27 then
        display_sign(50, {"winged", "he|was|only", "we|(ought", "|bill|b|"})
    elseif var_0001 == 28 then
        display_sign(50, {"victim", "guest", "|charles|c|"})
    elseif var_0001 == 29 then
        display_sign(50, {"depainted", "dearly", "|danny|"})
    elseif var_0001 == 30 then
        display_sign(50, {"greener", "(e|grass", "he|makes", "|bob|"})
    elseif var_0001 == 31 then
        display_sign(50, {"gonna", "she|is|a", "donna"})
    elseif var_0001 == 32 then
        display_sign(50, {"here|lies", "talent", "of", "a|portrait", "|karl|"})
    elseif var_0001 == 33 then
        display_sign(50, {"character", "explosive", "an", "|chris|d|"})
    elseif var_0001 == 34 then
        display_sign(50, {"smile", "with|a", "went", "|glen|"})
    elseif var_0001 == 35 then
        display_sign(50, {"ending", "fantastic", "had|a", "|bruce|l|"})
    elseif var_0001 == 36 then
        display_sign(50, {"br+(", "last", "his", "|loubet|"})
    elseif var_0001 == 37 then
        display_sign(50, {"for|good", "comi*|gone", "lo*|time", "|micael|p|"})
    elseif var_0001 == 38 then
        display_sign(50, {"over", "is", "(e|party", "|jake|"})
    elseif var_0001 == 39 then
        display_sign(50, {"faces", "(ousand", "man|of|a", "|gary|w|"})
    elseif var_0001 == 40 then
        display_sign(50, {"life", "full", "it|was|a", "|(e|b+,|"})
    elseif var_0001 == 41 then
        display_sign(50, {"much|work", "from|too", "kirk|died", "here|lies"})
    elseif var_0001 == 42 then
        display_sign(50, {"opponent", "wor(y", "a", "|targ|"})
    elseif var_0001 == 43 then
        display_sign(50, {"crystal", "like|a", "shined", "my,ral", "here|lies"})
    elseif var_0001 == 44 then
        display_sign(50, {"not", "and|why", "marc", "here|lies"})
    elseif var_0001 == 45 then
        display_sign(50, {"maker", "music", "(e", "|nenad|"})
    elseif var_0001 == 46 then
        display_sign(50, {"never|done", "work|was", "his", "john", "here|lies"})
    elseif var_0001 == 47 then
        display_sign(50, {"him", "killed", "we", "|bruce|a|"})
    elseif var_0001 == 48 then
        display_sign(50, {"loaded", "was", "(e|game", "unaware", "|eric|"})
    elseif var_0001 == 49 then
        display_sign(50, {"enough", "is|not", "(e|world", "|raymond|"})
    elseif var_0001 == 50 then
        display_sign(50, {"garriot", "by", "died", "|Beth|"})
    elseif var_0001 == 51 then
        display_sign(50, {"di*os", "by", "+ten", "|jack|"})
    elseif var_0001 == 52 then
        display_sign(50, {"lover", "poisoni*", "hu*|for", "|michelle|"})
    elseif var_0001 == 53 then
        display_sign(50, {"tomtorrow", "gone", "today", "gone", "|scott|h|"})
    elseif var_0001 == 54 then
        display_sign(50, {"mon,er", "(e", "by", "swallowed", "|brian|"})
    elseif var_0001 == 55 then
        display_sign(50, {"(e|end", "until", "managed", "|sherry|c|"})
    elseif var_0001 == 56 then
        display_sign(50, {"one", "was|job", "quality", "|karen|"})
    elseif var_0001 == 57 then
        display_sign(50, {"i|roam", "but|,ill", "here|i|lie", "|j|shelton"})
    elseif var_0001 == 58 then
        display_sign(50, {"undergrnd", "under|gun", "underfed", "|marco|"})
    elseif var_0001 == 59 then
        display_sign(50, {"of|a|swan", "(e|grace", "she|had", "|lynn|"})
    elseif var_0001 == 60 then
        display_sign(50, {"urit", "canus|meus", "me|puergo", "|chenault|"})
    elseif var_0001 == 61 then
        display_sign(50, {"cocopuff", "and|tc", "to|dizzy", "|j|crippen|"})
    elseif var_0001 == 62 then
        display_sign(50, {"tomb,one", "(e|unknown", "|tim|"})
    elseif var_0001 == 63 then
        display_sign(50, {"fireball", "by|grogs", "blown|away", "|na(an|"})
    elseif var_0001 == 64 then
        display_sign(50, {"what", "i|drank", "last|words", "|james|n|"})
    elseif var_0001 == 65 then
        display_sign(50, {"out", "all|te,ed", "Ben", "here|lies"})
    elseif var_0001 == 66 then
        display_sign(50, {"his|h+d", "axe|in", "buried|an", "|scott|"})
    elseif var_0001 == 67 then
        display_sign(50, {"exii", "vidi", "veni", "|duke|"})
    elseif var_0001 == 68 then
        display_sign(50, {"print", "fit|to", "every(i*", "|mike|h|"})
    elseif var_0001 == 69 then
        display_sign(50, {"to|us|all", "sunshine", "she|gave", "|robin|"})
    elseif var_0001 == 70 then
        display_sign(50, {"clued|in", "got", "never", "|m|", "|andrew|"})
    elseif var_0001 == 71 then
        display_sign(50, {"gr+t", "was", "(e|food", "|wayne|s|"})
    elseif var_0001 == 72 then
        display_sign(50, {"delivered", "was", "|craig|c|"})
    elseif var_0001 == 73 then
        display_sign(50, {"ate", "never", "fed|but", "|jeff|f|"})
    elseif var_0001 == 74 then
        display_sign(50, {"(ought", "for", "food", "|w|hagy"})
    elseif var_0001 == 75 then
        display_sign(50, {"wi(|gifts", "arrived", "|stevens|", "|m|"})
    elseif var_0001 == 76 then
        display_sign(50, {"dinner", "of", "bringer", "|g|", "|michelle|"})
    elseif var_0001 == 77 then
        display_sign(50, {"him", "was", "food", "|brian|s|"})
    elseif var_0001 == 78 then
        display_sign(50, {"dinner", "for", "as|in|d|", "d|", "|jackie|"})
    elseif var_0001 == 79 then
        display_sign(50, {"record", "perfect", "a", "spained", "|b|adams|"})
    elseif var_0001 == 80 then
        display_sign(50, {"now|below", "who|is", "fellow", "a|nice", "|hal|"})
    elseif var_0001 == 81 then
        display_sign(50, {"over", "over|and", "friend", "mans|best", "|rover|"})
    elseif var_0001 == 82 then
        display_sign(50, {"dies", "never", "love", "age|old", "|felcore|"})
    elseif var_0001 == 83 then
        display_sign(50, {"of|course", "hes|d+d", "morse", "tony", "heres"})
    elseif var_0001 == 84 then
        display_sign(50, {"gross", "|", "salamon", "larry", "heres"})
    elseif var_0001 == 85 then
        display_sign(50, {"faltran", "who|is", "mcdonald", "darren"})
    elseif var_0001 == 86 then
        display_sign(50, {"chiltons", "from|(e", "away", "died", "|kevin|b|"})
    elseif var_0001 == 87 then
        display_sign(50, {"food", "worm", "michael|", "and", "|beth"})
    elseif var_0001 == 88 then
        display_sign(50, {"honorably", "died", "|a|h|"})
    elseif var_0001 == 89 then
        display_sign(50, {"went", "and", "gone", "|john|t|"})
    elseif var_0001 == 90 then
        display_sign(50, {"here", "installed", "", "|rey|"})
    elseif var_0001 == 91 then
        display_sign(50, {"died", "man|never", "deservi*", "a|more", "|rhoode|"})
    elseif var_0001 == 92 then
        display_sign(50, {"missed", "she|is", "moment", "every", "|jasner|"})
    elseif var_0001 == 93 then
        display_sign(50, {"he|lays", "now|here", "lied", "here|he", "|wampol|"})
    elseif var_0001 == 94 then
        display_sign(50, {"spurni*", "lovers", "by|a", "wounded", "|destra|"})
    elseif var_0001 == 95 then
        display_sign(50, {"boots|on", "wi(|his", "buried", "|mendar|"})
    elseif var_0001 == 96 then
        display_sign(50, {"good", "looked|so", "never", "old|age", "|greghim|"})
    elseif var_0001 == 97 then
        display_sign(50, {"now", "but|is", "missed", "was|not", "|sarnan|"})
    elseif var_0001 == 98 then
        display_sign(50, {"day", "of|his", "enchanter", "gr+te,", "|erlemar|"})
    elseif var_0001 == 99 then
        display_sign(50, {"conquered", "was", "saw|", "came|", "|galler|"})
    elseif var_0001 == 100 then
        display_sign(50, {"forever", "worm|food", "for|a|day", "queen", "|elgele(|"})
    elseif var_0001 == 101 then
        display_sign(50, {"stops", "never", "(e|si*i*", "|pantor|"})
    elseif var_0001 == 102 then
        display_sign(50, {"ma,er", "and", "fa(er", "beloved", "here|lies"})
    end
    return
end