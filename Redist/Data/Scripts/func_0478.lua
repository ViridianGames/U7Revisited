--- Best guess: Handles dialogue with Joseph, the mayor of Jhelom, discussing the town’s duelling culture, the Library of Scars, the Fellowship’s potential branch, and his neutral stance on Sprellic’s dispute.
function func_0478(eventid, itemref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(120, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if not get_flag(535) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(368) then
            add_answer("Sprellic")
        end
        if not get_flag(370) then
            add_dialogue("You see a man who exudes the outward mannerisms of a shrewd administrator, in contrast to his youthful appearance.")
            set_flag(370, true)
        else
            add_dialogue("Joseph nods his head respectfully to you. \"How may I assist thee?\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"My name is Joseph.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"Presently, I am the mayor of Jhelom.\"")
                add_answer({"Jhelom", "mayor"})
            elseif var_0001 == "mayor" then
                add_dialogue("\"I may seem a bit young for the job, but in a town such as this I am called upon to help keep order as often as administrate. I use my sword and pen in equal measure.\"")
                remove_answer("mayor")
            elseif var_0001 == "Jhelom" then
                add_dialogue("\"This town is a rough place. A fine place for fighting men and women to live. Perhaps thou hast seen our local sport?\"")
                remove_answer("Jhelom")
                add_answer("sport")
            elseif var_0001 == "sport" then
                add_dialogue("\"Why, 'tis duelling! At twelve noon every day, the town square becomes a battlefield.\"")
                add_answer({"battlefield", "duelling"})
                remove_answer("sport")
            elseif var_0001 == "duelling" then
                add_dialogue("\"Well, the sound is worse than the act. 'Tis actually just a form of training and exercise. The fighters practice with targets and such. That is where I can be found, keeping mine own skills sharp.\"")
                remove_answer("duelling")
            elseif var_0001 == "battlefield" then
                add_dialogue("\"I am exaggerating. Many of the fighters in town gather to spar with the training dummies and practice various methods of combat. There are a few harmless matches at times. Some are a bit rough every now and then. Some folks take wagers on it and turn a profit.\"")
                remove_answer("battlefield")
                add_answer({"take wagers", "spar"})
            elseif var_0001 == "spar" then
                add_dialogue("\"Ahem... Of course most duels are simply to the blood, not to the death. It is a practice that helps restrain the passing knaves and rogues.\"")
                remove_answer("spar")
            elseif var_0001 == "take wagers" then
                add_dialogue("\"Speak to Daphne or Ophelia at the Bunk and Stool, our town pub and inn.\"")
                remove_answer("take wagers")
            elseif var_0001 == "Fellowship" then
                add_dialogue("\"That is what many of the duels are fought over! Some say The Fellowship is a load of rot, some say it is the only truth. Others say it is foolishness. Of course, as Mayor I remain neutral on such matters.\"")
                remove_answer("Fellowship")
                add_answer({"foolishness", "truth"})
            elseif var_0001 == "Elizabeth and Abraham" then
                if not get_flag(136) then
                    add_dialogue("\"Elizabeth and Abraham?\" Joseph scratches his head. \"Oh, yes! They were the Fellowship members who were just here! They were trying to start a branch in Jhelom. I am undecided on what to tell them. We will probably have a town meeting to decide if there should be a branch here. The couple said they were returning to Britain for a few days.\"")
                    set_flag(363, true)
                else
                    add_dialogue("\"Elizabeth and Abraham?\" Joseph scratches his head. \"Oh, yes! They were the Fellowship members who were here -- why, it must have been last week or so. I have not seen them since.\"")
                end
                add_answer("Fellowship")
                remove_answer("Elizabeth and Abraham")
            elseif var_0001 == "truth" then
                add_dialogue("\"De Snel, the leader of the Library of Scars, requires that his members fight in many duels. One week they will fight for one cause and the next week for the opposite side.\"")
                remove_answer("truth")
                add_answer({"Library of Scars", "De Snel"})
            elseif var_0001 == "foolishness" then
                if var_0001 then
                    add_dialogue("Joseph looks a little embarrassed. \"I meant no insult to thee as a member of The Fellowship, " .. var_0000 .. ".\"")
                else
                    add_dialogue("\"If thou must know mine opinion,\" he says to you in quiet confidence, \"I agree with those that say The Fellowship is a bunch of foolishness.\"")
                end
                remove_answer("foolishness")
            elseif var_0001 == "De Snel" then
                add_dialogue("\"De Snel says he only wishes the best for his school. If his fighters are ever beaten he throws them out and recruits the winner to join the Library of Scars.\"")
                remove_answer("De Snel")
            elseif var_0001 == "Library of Scars" then
                add_dialogue("\"It attracts fighters from all over Britannia who want to learn from De Snel. They are an unruly bunch. Thou wouldst do best to stay clear of them.\"")
                remove_answer("Library of Scars")
            elseif var_0001 == "Sprellic" then
                add_dialogue("\"Yes, I have heard of the events surrounding this fellow Sprellic and the duels against the Library of Scars, but frankly, mine official policy has been to not get involved in these sort of personal disputes.\"")
                remove_answer("Sprellic")
                add_answer({"personal dispute", "get involved"})
            elseif var_0001 == "get involved" then
                add_dialogue("\"De Snel and I have an understanding. He works his side of the street and I work mine. It is hard enough to maintain order in this town without kindizing that. If I intervene De Snel will challenge me to a duel and if I am killed then his control of our town would be absolute.\"")
                remove_answer("get involved")
                add_answer({"understanding", "challenge"})
            elseif var_0001 == "personal dispute" then
                add_dialogue("\"As Mayor and the peacekeeper I have to pick and choose my fights very carefully. There is no love lost between myself and the members of the Library of Scars, but they can legitimately claim that they have been wronged. I am required to remain impartial in this matter. As far as I can see, Sprellic brought this on himself when he took the honor flag. If thou dost wish to stop the duel, thou dost need only convince him to give it back.\"")
                remove_answer("personal dispute")
            elseif var_0001 == "understanding" then
                add_dialogue("\"Believe me, we are not in each other's company so often because we are friends. We do so to maintain a careful watch on each other. Keep thy friends close, but keep thine enemies closer. Words to live by in Jhelom.\"")
                remove_answer("understanding")
            elseif var_0001 == "challenge" then
                add_dialogue("\"When I say that De Snel would challenge me to a duel I do not mean to insinuate that it would in any way be a fair or honorable contest-- more like a dagger in the back from one of his bullies as I was walking down a dark alley somewhere. That it would be a duel is just the story he would tell to make mine assassination somehow honorable.\"")
                remove_answer("challenge")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Enjoy thy stay in my city. But if thou hast no stomach for fighting thou shouldst not stay long.\"")
    elseif eventid == 0 then
        unknown_092EH(120) --- Guess: Triggers a game event
    end
end