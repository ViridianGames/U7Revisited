require "U7LuaFuncs"
-- Manages Denby's dialogue in Britain, covering intelligence-based combat training and pacifist philosophy.
function func_0431(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        switch_talk_to(-49, 0)
        local0 = switch_talk_to(-49)
        local1 = false

        add_answer({"bye", "job", "name"})

        if not get_flag(178) then
            say("You see a fighter with intense eyes and a serious disposition.")
            set_flag(178, true)
        else
            say("\"Yes, Avatar?\" Denby asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Denby.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am a trainer. I specialize in a form of combat which relies on one's ability to use intelligence and physical ability to activate minor magical effects. But I am not a mage. I am a fighter.\"")
                add_answer({"train", "fighter", "magical effects"})
            elseif answer == "magical effects" then
                say("\"For example, I simply teach a combination of physical and mental exercises which increases one's intelligence. This, in turn, gives one an advantage if one desires to practice magic.\"")
                if not get_flag(3) then
                    say("\"Thou shouldst be aware, however, that magic is not working in Britannia these days. It is a dying phenomenon. No one understands why. Nevertheless, my training should increase any magic user's primary chances for casting a spell, as well as their fighting skill.\"")
                end
                remove_answer("magical effects")
            elseif answer == "fighter" then
                say("\"Although I am a fighter, I have dedicated my life to peace. There has been too much fighting in the world as it is. Let history take care of the adversarial qualities which exist in man. I believe in using my skills as a deterrent.\"")
                remove_answer("fighter")
            elseif answer == "train" then
                if local0 == 7 then
                    say("\"My fee for training is 75 gold. Does this meet with the approval of thy purse strings?\"")
                    if get_answer() then
                        apply_effect(75, {6, 2, 1}) -- Unmapped intrinsic 0875
                    else
                        say("Denby bows. \"I am sorry my fee is too high for thee. Perhaps at another time thou wilt realize the value of my services.\"")
                    end
                else
                    say("\"Please return during daylight hours if thou dost wish to train.\"")
                    remove_answer("train")
                end
            elseif answer == "bye" then
                say("Denby puts his palms together and bows.*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-49)
    end
    return
end