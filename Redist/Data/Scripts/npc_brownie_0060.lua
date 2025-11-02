--- Best guess: Manages Brownie's dialogue, discussing his farming life, failed mayoral campaign, and need for help with pumpkins, with flag-based job offers and loops for setting up farm tasks.
function npc_brownie_0060(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(60)
        end
        add_dialogue("\"Good day, " .. get_lord_or_lady() .. ".\"")
        return
    end

    start_conversation()
    switch_talk_to(60)
    var_0000 = get_lord_or_lady()
    var_0001 = is_player_wearing_fellowship_medallion()
    add_answer({"bye", "job", "name"})
    if not get_flag(206) then
        add_answer("pumpkins")
    end
    if not get_flag(189) then
        add_dialogue("You see a farmer who, despite showing considerable wear from hard work, appears energetic, cheerful and friendly.")
        set_flag(189, true)
    else
        add_dialogue("\"Hello again, " .. var_0000 .. ",\" Brownie greets you.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Brownie.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Well, I ran for the office of Mayor of Britain once, but I lost. Now I am back doing what I have been doing since I was a boy. Working the farm.\"")
            add_answer({"farm", "Mayor"})
        elseif cmps("Mayor") then
            add_dialogue("\"Patterson won the election. He spent a lot of money on his campaign. Most of it to buy votes. But I am not bitter. I was just not meant to be Mayor.\"")
            remove_answer("Mayor")
            add_answer({"election", "Patterson"})
        elseif cmps("Patterson") then
            add_dialogue("\"Patterson courted the support of The Fellowship. They forced a vote from all their members. Once word spread, my support drained away. No one wants to be on the losing side.\" Brownie sighs.")
            remove_answer("Patterson")
            add_answer({"losing", "Fellowship"})
        elseif cmps("election") then
            add_dialogue("\"I do not really have any wish to succeed in politics. It just made me ill seeing all of the people with riches mistreat all of the people who are poor, and then have to listen to them talk about how the class system has been abolished.\"")
            remove_answer("election")
        elseif cmps("Fellowship") then
            if var_0001 then
                add_dialogue("Brownie gestures toward your medallion. \"Frankly, I do not know what thou seest in that group.\"")
            else
                add_dialogue("\"If thou art not with The Fellowship thou art against them. I think they saw me as a potential enemy that had to be stopped.\"")
            end
            remove_answer("Fellowship")
        elseif cmps("losing") then
            add_dialogue("\"Of course, I could have won the election if I had wanted to. I had information about Patterson that would have ruined any chances of him winning.\"")
            remove_answer("losing")
            add_answer("information")
        elseif cmps("information") then
            add_dialogue("\"I could have revealed a secret about Patterson but if I did it would have hurt someone close to him very much. I did not want to be mayor that badly.\"")
            remove_answer("information")
            add_answer("secret")
        elseif cmps("secret") then
            add_dialogue("\"Patterson does little to hide his secret. If thou dost keep an eye on him thou wilt surely learn of it sooner or later.\"")
            remove_answer("secret")
        elseif cmps("farm") then
            add_dialogue("\"I feel more at home on the farm growing vegetables. There is another farmer named Mack who works a farm near Britain as well. He raises chickens.\"")
            remove_answer("farm")
            add_answer({"Mack", "vegetables"})
        elseif cmps("Mack") then
            add_dialogue("\"I like him. He even voted for me. But to tell thee the truth about Mack, he is a lunatic.\"")
            remove_answer("Mack")
        elseif cmps("vegetables") then
            add_dialogue("\"I raise pumpkins. But I am in a bind at the moment and need some help.\"")
            remove_answer("vegetables")
            add_answer({"help", "bind"})
        elseif cmps("bind") then
            add_dialogue("\"I strained my back the other day lifting heavy pumpkins. I cannot so much as lift a small one today! And I need help with the harvest of pumpkins so that I can get them to the market.\"")
            remove_answer("bind")
        elseif cmps("help") then
            add_dialogue("\"There are piles of pumpkins at the north end of the field. I need them brought down near my farmhouse. If thou wilt help me by bringing the pumpkins to me, I will gladly pay thee for thy work. How does one gold coin for every pumpkin carried sound?\"")
            var_0002 = ask_yes_no()
            if var_0002 then
                add_dialogue("\"How nice! A helper! Please, feel free to start work at any time!\"")
                set_flag(206, true)
                var_0003 = find_nearby_avatar(20)
                var_0004 = find_nearby_avatar(21)
                for i = 1, 11 do
                    set_item_flag(i, var_0007)
                end
                for i = 1, 11 do
                    set_item_flag(i, var_0007)
                end
            else
                add_dialogue("\"Perhaps some other time, then.\"")
            end
            remove_answer("help")
        elseif cmps("pumpkins") then
            if not get_flag(206) then
                utility_unknown_0855()
            else
                add_dialogue("\"Thou shouldst simply go to the north end of the field and bring back as many pumpkins as thou can carry!\"")
            end
            remove_answer("pumpkins")
        elseif cmps("bye") then
            break
        end
    end
    return
end