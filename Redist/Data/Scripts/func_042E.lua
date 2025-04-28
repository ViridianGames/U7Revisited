require "U7LuaFuncs"
-- func_042E.lua
  -- James's dialogue as the innkeeper at Wayfarer's Inn
  local U7 = require("U7LuaFuncs")

  function func_042E(eventid)
      local answers = {}
      local flag_0092 = U7.getFlag(0x0092) -- Cynthia said topic
      local flag_00AF = U7.getFlag(0x00AF) -- First meeting
      local npc_id = -46 -- James's NPC ID

      if eventid == 1 then
          U7.SwitchTalkTo(0, npc_id)
          local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
          local var_0001 = U7.callExtern(0x090A, 1) -- Room interaction
          local var_0002 = U7.callExtern(0x092E, 2) -- Unknown interaction

          table.insert(answers, "bye")
          table.insert(answers, "job")
          table.insert(answers, "name")
          if flag_0092 then
              table.insert(answers, "Cynthia said")
          end

          if not flag_00AF then
              U7.say("You see a sour-faced innkeeper who looks at you as if all of his problems were your fault.")
              U7.setFlag(0x00AF, true)
          else
              U7.say("\"What must I do for thee now, \" .. U7.getPlayerName() .. \"?\" asks James.")
          end

          while true do
              if #answers == 0 then
                  U7.say("James sighs. \"What is it now? Speak up!\"")
                  table.insert(answers, "bye")
                  table.insert(answers, "job")
                  table.insert(answers, "name")
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  U7.say("\"My name is James.\"")
                  U7.RemoveAnswer("name")
              elseif choice == "job" then
                  U7.say("\"I am the proprietor of the inn.\"")
                  table.insert(answers, "inn")
                  table.insert(answers, "proprietor")
              elseif choice == "proprietor" then
                  U7.say("\"It is just another way of saying that I am the man who is the desk clerk. Which thou mayest think is an easy job although it is not, I can assure thee.\"")
                  table.insert(answers, "not easy")
                  table.insert(answers, "desk clerk")
                  U7.RemoveAnswer("proprietor")
              elseif choice == "inn" then
                  U7.say("\"This place is called the Wayfarer's Inn. It has a long and substantial history in Britain. If thy grandparents ever came to town this is probably where they stayed.\"")
                  U7.RemoveAnswer("inn")
              elseif choice == "desk clerk" then
                  U7.say("\"Of course, being desk clerk is not all I do. I must spend all day listening to people talk about their problems as if I am supposed to solve them!\"")
                  table.insert(answers, "solve")
                  table.insert(answers, "listening")
                  U7.RemoveAnswer("desk clerk")
              elseif choice == "listening" then
                  U7.say("\"That is correct, \" .. U7.getPlayerName() .. \". So if thou dost have a problem, allow me the courtesy of not having to hear all about it. Now what was it that I was saying again?\"")
                  U7.RemoveAnswer("listening")
              elseif choice == "solve" then
                  U7.say("\"Maybe solving people's problems is an easy task for other innkeepers, but, not only am I bad at it, I have mine own problems as well.\"")
                  table.insert(answers, "problems")
                  U7.RemoveAnswer("solve")
              elseif choice == "problems" then
                  U7.say("\"I do not like my job! I never wanted to be an innkeeper, I just wanted to keep the place going after my father passed on. Now that I am married to Cynthia, I am more tied down than ever!\"")
                  table.insert(answers, "Cynthia")
                  table.insert(answers, "innkeeper")
                  U7.RemoveAnswer("problems")
              elseif choice == "innkeeper" then
                  U7.say("\"Instead of being an innkeeper I always secretly wanted to be a pirate! When I was not sailing the seas I would be living in Buccaneer's Den.\"")
                  table.insert(answers, "Buccaneer's Den")
                  table.insert(answers, "pirate")
                  U7.RemoveAnswer("innkeeper")
              elseif choice == "Buccaneer's Den" then
                  U7.say("\"As I understand it they have an excellent House of Games there as well as opulent baths. Or at least so I have heard from Gordon, the man who sells fish and chips.\"")
                  U7.RemoveAnswer("Buccaneer's Den")
              elseif choice == "Cynthia" then
                  U7.say("\"Do not mistake my words, \" .. U7.getPlayerName() .. \". I love Cynthia with all mine heart. But there are I times I feel I am too young to be married. Besides, I know I cannot be a good husband for her.\"")
                  table.insert(answers, "good husband")
                  U7.RemoveAnswer("Cynthia")
              elseif choice == "pirate" then
                  U7.say("\"Thou knowest for certain that few if any people would pour their troubles out to pirates. If I were a pirate I could get this bad foot replaced with a peg, too!\"")
                  U7.RemoveAnswer("pirate")
              elseif choice == "good husband" then
                  U7.say("\"How can I make Cynthia happy on the pittance an innkeeper makes when all day long she is counting all that money in the mint? I know I cannot.\"")
                  table.insert(answers, "mint")
                  table.insert(answers, "happy")
                  U7.RemoveAnswer("good husband")
              elseif choice == "mint" then
                  U7.say("\"I know the nature of the heart, my good friend. After being exposed to such large sums of money she shall begin to covet it. As I cannot provide it, she shall leave me to give her heart to a wealthy man. Perhaps a merchant or a nobleman. The thought of it makes my blood boil.\"")
                  U7.RemoveAnswer("mint")
              elseif choice == "not easy" then
                  U7.say("\"When one is an innkeeper one must run around all day long. If anyone wants anything thou art the one who must take care of it for them!\"")
                  table.insert(answers, "room")
                  table.insert(answers, "run around")
                  U7.RemoveAnswer("not easy")
              elseif choice == "run around" then
                  U7.say("\"I spend so much time running around that I have gotten a bad foot.\"")
                  U7.RemoveAnswer("run around")
              elseif choice == "happy" then
                  U7.say("\"Already I can sense she is worried about our marriage. I know that there is something wrong between us.\"")
                  U7.RemoveAnswer("happy")
              elseif choice == "room" then
                  if U7.getSchedule() == 7 then
                      U7.say("\"Oh, I suppose thou wouldst like a room now! There, that is just what I mean! It is ten gold pieces per person for a night. Thou dost want a room, dost thou not?\"")
                      local response = U7.callExtern(0x090A, var_0001)
                      if response == 0 then
                          local party_count = U7.getPartyMembers()
                          local cost = party_count * 10
                          local gold_result = U7.removeGold(cost)
                          if gold_result then
                              local item_result = U7.giveItem(255, 1, 641)
                              if item_result then
                                  U7.say("\"Here is thy room key. It is only good until thou leavest the inn.\"")
                              else
                                  U7.say("\"Thou art carrying too much to take the room key!\"")
                              end
                          else
                              U7.say("\"Thou dost not have enough gold to get a room here. Now I suppose thou shalt be telling me all about how such a sorry state befell thee. Well, I shall not listen to thee!\"")
                          end
                      else
                          U7.say("James wipes his brow. \"Phew! That was a close call!\"")
                      end
                  else
                      U7.say("\"Please, \" .. U7.getPlayerName() .. \". Do allow me some time to myself! Presently I am not doing the business of the inn and I do wish to keep it that way. Thou must attend to the inn during business hours.\"")
                  end
                  U7.RemoveAnswer("room")
              elseif choice == "Cynthia said" then
                  U7.say("You repeat the words that Cynthia had said to you about him. A smile comes across his face. \"Aww, who wants to be a pirate anyway? I would hate that!\" With that he goes back to wiping the bar, but you notice that the smile is still there.")
                  U7.RemoveAnswer("Cynthia said")
              elseif choice == "bye" then
                  U7.say("\"Oh, thou shalt just come back again wanting something else from me! I just know it!\"")
                  break
              end
          end
      elseif eventid == 0 then
          U7.callExtern(0x092E, npc_id)
      end
  end

  return func_042E