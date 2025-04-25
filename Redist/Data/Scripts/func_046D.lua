-- Manages Brother Wayne's dialogue near Empath Abbey, covering his aimless wandering, studies with Taylor, and love for nature.
function func_046D(eventid, itemref)
    local local0

    if eventid == 1 then
        switch_talk_to(-109, 0)
        local0 = get_player_name()

        add_answer({"bye", "job", "name"})

        if not get_flag(714) then
            say("You see a monk wandering around apparently without direction.")
            set_flag(714, true)
        else
            say("\"Greetings, " .. local0 .. ". May I help thee?\" asks Wayne.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Thou mayest call me Brother Wayne, " .. local0 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"My job? Well, I, er, do not truly have one at the moment.\" He looks down at his feet.")
                remove_answer("job")
                add_answer("at the moment")
            elseif answer == "at the moment" then
                say("\"Yes, I am... Well, I am lost, " .. local0 .. ". I am from the Abbey to the south of here... or to the north.... Mayhaps the northwest.\" He cradles his chin and looks up.~~\"Southeast?\"")
                remove_answer("at the moment")
                add_answer({"Abbey", "lost"})
            elseif answer == "lost" then
                say("\"Well... I am sure it is not permanent.\" He blushes. \"I just need to get my bearings, that's all,\" he says unconvincingly.")
                remove_answer("lost")
            elseif answer == "Abbey" then
                say("\"I am a monk of the Brotherhood of the Rose. I study geography and nature with a brother named Taylor.\"")
                remove_answer("Abbey")
                add_answer({"Taylor", "nature", "geography"})
            elseif answer == "geography" then
                say("\"Well,\" he shrugs, \"I suppose I should have studied a little bit better.\" He smiles sheepishly.")
                remove_answer("geography")
            elseif answer == "nature" then
                say("\"There are so many beautiful things to see in Britannia. Both animals and plants alike offer excitement to the observer.\"")
                remove_answer("nature")
                add_answer({"plants", "animals"})
            elseif answer == "Taylor" then
                say("\"Well, I haven't actually seen him for some time. I assume he is still continuing his studies.\"")
                remove_answer("Taylor")
            elseif answer == "plants" then
                say("\"Ah, yes, " .. local0 .. ", they are quite wondrous to see. I highly recommend to thee to always observe thy surroundings. Otherwise, " .. local0 .. ", thou wilt miss much in life: flowers, trees, birds... landmarks!\"")
                remove_answer("plants")
                add_answer({"birds", "trees", "flowers"})
            elseif answer == "trees" then
                say("\"Ah, my least favorite subject. I find the trees much less interesting than the birds.\"")
                remove_answer("trees")
            elseif answer == "birds" then
                say("\"My favorite type of animal! The birds are so free, able to fly vast distances. How I wish I could roam about the open skies... most especially considering my current situation. Thou canst see so much more from the air, I am certain of it!\"")
                remove_answer("birds")
            elseif answer == "flowers" then
                say("\"Very, very lovely plants. All the colors of the rainbow, and then some. One of the monks at the Abbey had a lovely flower garden. She may still tend it for all that I know, " .. local0 .. ".\"")
                remove_answer("flowers")
                if not get_flag(332) then
                    add_answer("She still does.")
                end
            elseif answer == "She still does." then
                say("\"Excellent, " .. local0 .. ". I am glad to hear it. 'Twould be a shame were Aimi to give that up for her other... pastime.\"")
                remove_answer("She still does.")
                add_answer("other pastime")
            elseif answer == "other pastime" then
                say("\"Aimi also paints. Or rather, makes a bold attempt. I must, of course, commend her for her efforts.\"")
                remove_answer("other pastime")
            elseif answer == "animals" then
                say("\"My favorite ones are the birds, especially the Golden-Cheeked Warbler. I love to follow and watch them. They do not seem to have a very good sense of direction, however.\" He sighs. \"But there is a great variety of species in this land.\"")
                remove_answer("animals")
            elseif answer == "bye" then
                say("\"May thy good fortune guide thee down the trail of life.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-109)
    end
    return
end