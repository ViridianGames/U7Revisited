--- Best guess: Handles dialogue with Xanthia, a candelabra maker in Minoc’s Artist’s Guild, discussing her work for the Fellowship, the murders of Frederico and Tania, and the Guild’s challenges, with a focus on the candelabra found at the murder site.
function func_0456(eventid, itemref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(86, 0)
        var_0000 = get_lord_or_lady()
        if not get_flag(273) then
            add_dialogue("You see a cheerful woman with bright eyes and blonde hair.")
            set_flag(273, true)
        else
            add_dialogue("\"Hello again, " .. var_0000 .. ".\" says Xanthia.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"Hello, my name is Xanthia.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am a member of the Artist's Guild in Minoc. I make and sell candelabras.\"")
                    add_answer({"candelabras", "Minoc", "Artist's Guild"})
                else
                    add_dialogue("\"If thou wouldst not mind, we can perhaps get to know each other during a more sociable occasion! Two people have been recently murdered over at William's sawmill! This is hardly the time to get to know someone!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0001 == "Artist's Guild" then
                add_dialogue("\"We are a guild of artists and craftspeople united for the common good and dedicated to the advancement of the arts, as well as showing other artists that it is possible to exist solely by thine own efforts without sacrificing thy creativity.\"")
                remove_answer("Artist's Guild")
            elseif var_0001 == "candelabras" then
                add_dialogue("\"I make simple candelabras, but sometimes I will do commissioned work, making more specific ones. I was hired by The Fellowship to make the candelabras for all of their Fellowship halls.\"")
                remove_answer("candelabras")
                add_answer("Fellowship")
            elseif var_0001 == "Fellowship" then
                add_dialogue("\"Elynor, the head of the local Fellowship branch, showed me a picture of the Fellowship symbol and I based the design for my candelabra on that.\"")
                remove_answer("Fellowship")
                add_answer("Elynor")
                if not get_flag(290) then
                    add_answer("candelabra at murder site")
                end
            elseif var_0001 == "Elynor" then
                add_dialogue("\"Yes, she's quite a recruiter. Why, she got Burnside, our Mayor, to join, as well as Gregor, the local head of the Britannian Mining Company, and Owen, our shipwright. He is soon to be famous, I am sorry to say. She has never asked me to join, thank goodness.\"")
                remove_answer("Elynor")
                add_answer("Owen")
            elseif var_0001 == "candelabra at murder site" then
                add_dialogue("You describe the candelabra found at the murder scene to Xanthia. Her eyes widen with recognition. \"Yes, that is one of the candelabras I made. 'Twas in the sawmill at the murder site?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("Xanthia looks shocked. \"How horrible! I swear I do not know how it could have gotten there! Thou shouldst certainly ask Elynor about it!\"")
                else
                    add_dialogue("She gives you a slightly cross look. \"Well, I hope that thou didst not steal it from Elynor.\"")
                end
                set_flag(293, true)
                remove_answer("candelabra at murder site")
            elseif var_0001 == "Minoc" then
                add_dialogue("\"With the success of the mine, Minoc is a prosperous city. Not a place where one is used to having murders happen. A good place for our Artist's Guild to do well. But things have always been hard for us here. Now I fear they may get worse.\"")
                remove_answer("Minoc")
                add_answer({"murders", "worse"})
            elseif var_0001 == "worse" then
                add_dialogue("\"That is what Gladstone says. Thou hadst better ask him about it.\"")
                remove_answer("worse")
            elseif var_0001 == "murders" then
                add_dialogue("\"It is so terrible! I never knew Frederico or Tania personally, but I did meet their son, Sasha, once. He was a nice boy, if somewhat misguided. He spent the night with us once at the Artist's Guild, as a guest of Seara.\"")
                set_flag(254, true)
                remove_answer("murders")
            elseif var_0001 == "Owen" then
                add_dialogue("\"They are to build a monument to Owen for some reason or another. Owen and Elynor refuse to use anyone from the Guild to help build it! Rather rude of them, dost thou not think?\"")
                remove_answer("Owen")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Farewell, " .. var_0000 .. ". I hope I was of some assistance to thee.\"")
    elseif eventid == 0 then
        unknown_092EH(86) --- Guess: Triggers a game event
    end
end