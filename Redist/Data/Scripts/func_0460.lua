--- Best guess: Handles dialogue with Jergi, the King of the Gypsies in Minoc, discussing the gypsies’ persecution, the murders of his brother Frederico and sister-in-law Tania, Sasha’s involvement with the Fellowship, and his wife Margareta’s foresight.
function func_0460(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(96, 0)
    var_0000 = get_lord_or_lady()
    var_0001 = unknown_08F7H(83) --- Guess: Checks player status
    if var_0001 then
        add_answer("Margareta")
    end
    if not get_flag(466) then
        add_answer("hourglass")
    end
    if not get_flag(283) then
        add_dialogue("You see a swarthy gypsy with soulful eyes, dressed in colorful clothes. He looks as if he has the weight of the world on his shoulders.")
        set_flag(283, true)
    else
        add_dialogue("\"Greetings vonce again,\" Jergi says as he bows, making a swirling gesture with his hand.")
    end
    add_answer({"bye", "job", "name"})
    while true do
        var_0002 = get_answer()
        if var_0002 == "name" then
            add_dialogue("\"I am Jergi. Pleased to make thine acqvaintance.\"")
            remove_answer("name")
        elseif var_0002 == "job" then
            add_dialogue("\"I am the King ov the Gypsies.\"")
            add_answer("gypsies")
        elseif var_0002 == "gypsies" then
            add_dialogue("\"My people have almost completely died out in this vorld. Now that I am their leader I am making their velfare my sole responsibility. Soon I vill decide if ve vill leave Minoc.\"")
            remove_answer("gypsies")
            add_answer({"Minoc", "died out"})
        elseif var_0002 == "died out" then
            add_dialogue("\"Ve gypsies are a people who live to vander. But there are fewer and fewer places vhere ve are velcome. Ve are victimized by the ancient hatreds that have plagued our kind since the days ov ancient Sosaria.\"")
            remove_answer("died out")
        elseif var_0002 == "Minoc" then
            add_dialogue("\"Our people came here because ve thought ve vould be accepted. It seemed for a very long time that ve vere. But after these savage murders it looks like it is time for us to roam vonce again.\"")
            remove_answer("Minoc")
            add_answer({"murders", "accepted"})
        elseif var_0002 == "accepted" then
            add_dialogue("\"Ve have alvays been subject to the prejudices ov others! Ve are called thieves and vorse! But ve are a people that only vish to play our music, and dance, and live in peace. I thought the people here understood this.\"")
            remove_answer("accepted")
        elseif var_0002 == "murders" then
            add_dialogue("\"Frederico vas mine only brother, and no vone loved Tania more than I did, save for Frederico himself. Vhat happened to them vas unspeakable. I vish I could tell thee more. If thou vishest thou may speak to Sasha, but only briefly. Now is the time for him to mourn.\"")
            remove_answer("murders")
            add_answer({"Sasha", "Tania", "Frederico"})
        elseif var_0002 == "Frederico" then
            add_dialogue("\"Some thought ov my brother Frederico as a harsh man, but those ov us who knew him could see that he vas simply governed by the same prides and passions that rule all gypsies.\"")
            remove_answer("Frederico")
        elseif var_0002 == "Tania" then
            add_dialogue("\"She vas the most beautiful voman I had ever seen. Both my brother and I vere in love vith her. Ve both tried to vin her heart. I failed and thought that I vould spend the rest ov my life vith no vone. It vas not until last year that my vife Margareta and I vere married and my secretly broken heart vas mended.\"")
            remove_answer("Tania")
        elseif var_0002 == "Sasha" then
            add_dialogue("\"He is the son ov Frederico and Tania. He left us to learn more about The Fellowship. Ov course, he feels responsible for vhat happened...\"")
            remove_answer("Sasha")
            add_answer({"Fellowship", "responsible"})
        elseif var_0002 == "responsible" then
            add_dialogue("\"Ve do not blame Sasha for vhat happened. Ve vill not punish him.\"")
            remove_answer("responsible")
        elseif var_0002 == "Fellowship" then
            add_dialogue("\"Sasha vill have to decide if he vants to stay vith his people or return to The Fellowship. I believe he vill make the right choice.\"")
            remove_answer("Fellowship")
        elseif var_0002 == "Margareta" then
            add_dialogue("\"My vife is a vise voman who has some ov the necessary talents to see the future. Thou shouldst speak vith her.\"")
            remove_answer("Margareta")
        elseif var_0002 == "hourglass" then
            add_dialogue("\"I do not know vhat thou art talking about. I know nothing ov a mage named Nicodemus, nor of his hourglass. Be vary -- mages are quite mad these days!\"")
            remove_answer("hourglass")
        elseif var_0002 == "bye" then
            break
        end
    end
    add_dialogue("\"Mayest thou have much fortune in thine endeavors.\"")
end