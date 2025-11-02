--- Best guess: Handles dialogue with Boots, Lord British's personal cook, discussing her meals, her husband Bennie's forgetfulness, and a shortage of mutton, offering to pay for mutton deliveries.
function npc_boots_0067(eventid, objectref)
    local var_0000

    start_conversation()
    if eventid == 1 then
        switch_talk_to(67)
        add_answer({"bye", "job", "name"})
        if get_flag(114) then
            add_answer("mutton")
        end
        if not get_flag(196) then
            add_dialogue("This is an elderly woman who epitomizes 'grandmotherly'.")
            set_flag(196, true)
        else
            add_dialogue("\"Hello, again!\" Boots says.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"All my brothers and sisters called me 'Boots' when I was a baby, and it hath remained my name ever since.\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"Why, I am Lord British's personal cook! I prepare meals for the entire castle.\"")
                add_answer("meals")
            elseif var_0000 == "meals" then
                add_dialogue("\"Just go to the dining room at breakfast or supper time and mine husband Bennie will serve thee!\"")
                add_answer({"Bennie", "supper", "breakfast"})
                remove_answer("meals")
            elseif var_0000 == "breakfast" then
                add_dialogue("\"For breakfast I usually prepare a dish that my Liege brought with him from his homeland. Here we call it Eggs British. It is served with assorted fruits and tea, of course. It is the King's favorite.\"")
                remove_answer("breakfast")
            elseif var_0000 == "supper" then
                add_dialogue("\"This meal is usually whatever meat or game or fish Lord British requests, accompanied by several additional courses and a fine dessert.\"")
                remove_answer("supper")
            elseif var_0000 == "Bennie" then
                add_dialogue("\"He's a dear, but he has become a little absent-minded in his later years. He never remembers to bring enough meat from the slaughterhouse in Paws. In fact, we are short this week!\"")
                add_answer({"short", "absent-minded"})
                remove_answer("Bennie")
                set_flag(113, true)
            elseif var_0000 == "absent-minded" then
                add_dialogue("\"Last week I asked him to put a little garlic into some soup. He put in the garlic and then forgot about it. So he went and put some more in. Then he forgot he did that. So he put in more. Well, thou canst imagine the look on Lord British's face when he finally did taste that soup! It is a good thing we live and work in the castle of such a just ruler.\"")
                remove_answer("absent-minded")
            elseif var_0000 == "short" then
                add_dialogue("\"That is right, we do not have enough. If thou couldst bring me mutton from the slaughterhouse, I will pay thee 5 gold for every portion thou canst bring. All right?\"")
                var_0000 = select_option()
                if var_0000 then
                    add_dialogue("\"Good, I will be awaiting thy return!\"")
                    set_flag(114, true)
                else
                    add_dialogue("\"Oh dear. Well, I know thou art busy. Some other time, then.\"")
                end
                remove_answer("short")
            elseif var_0000 == "mutton" then
                add_dialogue("\"Splendid! Let's see, we agreed on 5 gold per portion, if I remember correctly.\"")
                utility_unknown_0852() --- Guess: Submits mutton
                remove_answer("mutton")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Bye now!\"")
    elseif eventid == 0 then
        utility_unknown_1070(67) --- Guess: Triggers a game event
    end
end