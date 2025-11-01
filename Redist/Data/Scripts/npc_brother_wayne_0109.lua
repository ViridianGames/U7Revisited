--- Best guess: Manages Brother Wayne's dialogue, a lost monk from Empath Abbey, discussing his disorientation, studies with Taylor, and Aimi's garden, with flag-based progression and nature-related topics.
function npc_brother_wayne_0109(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(109)
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 109)
    var_0000 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(714) then
        add_dialogue("You see a monk wandering around apparently without direction.")
        set_flag(714, true)
    else
        add_dialogue("\"Greetings, " .. var_0000 .. ". May I help thee?\" asks Wayne.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"Thou mayest call me Brother Wayne, " .. var_0000 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"My job? Well, I, er, do not truly have one at the moment.\" He looks down at his feet.")
            remove_answer("job")
            add_answer("at the moment")
        elseif cmps("at the moment") then
            add_dialogue("\"Yes, I am... Well, I am lost, " .. var_0000 .. ". I am from the Abbey to the south of here... or to the north.... Mayhaps the northwest.\" He cradles his chin and looks up.~~\"Southeast?\"")
            remove_answer("at the moment")
            add_answer({"Abbey", "lost"})
        elseif cmps("lost") then
            add_dialogue("\"Well... I am sure it is not permanent.\" He blushes. \"I just need to get my bearings, that's all,\" he says unconvincingly.")
            remove_answer("lost")
        elseif cmps("Abbey") then
            add_dialogue("\"I am a monk of the Brotherhood of the Rose. I study geography and nature with a brother named Taylor.\"")
            remove_answer("Abbey")
            add_answer({"Taylor", "nature", "geography"})
        elseif cmps("geography") then
            add_dialogue("\"Well,\" he shrugs, \"I suppose I should have studied a little bit better.\" He smiles sheepishly.")
            remove_answer("geography")
        elseif cmps("nature") then
            add_dialogue("\"There are so many beautiful things to see in Britannia. Both animals and plants alike offer excitement to the observer.\"")
            remove_answer("nature")
            add_answer({"plants", "animals"})
        elseif cmps("Taylor") then
            add_dialogue("\"Well, I haven't actually seen him for some time. I assume he is still continuing his studies.\"")
            remove_answer("Taylor")
        elseif cmps("plants") then
            add_dialogue("\"Ah, yes, " .. var_0000 .. ", they are quite wondrous to see. I highly recommend to thee to always observe thy surroundings. Otherwise, " .. var_0000 .. ", thou wilt miss much in life: flowers, trees, birds... landmarks!\"")
            remove_answer("plants")
            add_answer({"birds", "trees", "flowers"})
        elseif cmps("trees") then
            add_dialogue("\"Ah, my least favorite subject. I find the trees much less interesting than the birds.\"")
            remove_answer("trees")
        elseif cmps("birds") then
            add_dialogue("\"My favorite type of animal! The birds are so free, able to fly vast distances. How I wish I could roam about the open skies... most especially considering my current situation. Thou canst see so much more from the air, I am certain of it!\"")
            remove_answer("birds")
        elseif cmps("flowers") then
            add_dialogue("\"Very, very lovely plants. All the colors of the rainbow, and then some. One of the monks at the Abbey had a lovely flower garden. She may still tend it for all that I know, " .. var_0000 .. ".\"")
            remove_answer("flowers")
            if not get_flag(332) then
                add_answer("She still does.")
            end
        elseif cmps("She still does.") then
            add_dialogue("\"Excellent, " .. var_0000 .. ". I am glad to hear it. 'Twould be a shame were Aimi to give that up for her other... pastime.\"")
            remove_answer("She still does.")
            add_answer("other pastime")
        elseif cmps("other pastime") then
            add_dialogue("\"Aimi also paints. Or rather, makes a bold attempt. I must, of course, commend her for her efforts.\"")
            remove_answer("other pastime")
        elseif cmps("animals") then
            add_dialogue("\"My favorite ones are the birds, especially the Golden-Cheeked Warbler. I love to follow and watch them. They do not seem to have a very good sense of direction, however.\" He sighs. \"But there is a great variety of species in this land.\"")
            remove_answer("animals")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"May thy good fortune guide thee down the trail of life.\"")
    return
end