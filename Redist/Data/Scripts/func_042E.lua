-- func_042E.lua
  -- James's dialogue as the innkeeper at Wayfarer's Inn
  
  function func_042E(eventid)
      local answers = {}
      local flag_0092 = get_flag(0x0092) -- Cynthia said topic
      local flag_00AF = get_flag(0x00AF) -- First meeting
      local npc_id = -46 -- James's NPC ID

      if eventid == 1 then
          switch_talk_to(npc_id, 0)
          local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
          local var_0001 = call_extern(0x090A, 1) -- Room interaction
          local var_0002 = call_extern(0x092E, 2) -- Unknown interaction

          add_answer( "bye")
          add_answer( "job")
          add_answer( "name")
          if flag_0092 then
              add_answer( "Cynthia said")
          end

          if not flag_00AF then
              add_dialogue("You see a sour-faced innkeeper who looks at you as if all of his problems were your fault.")
              set_flag(0x00AF, true)
          else
              add_dialogue("\"What must I do for thee now, \" .. get_player_name() .. \"?\" asks James.")
          end

          while true do
              if #answers == 0 then
                  add_dialogue("James sighs. \"What is it now? Speak up!\"")
                  add_answer( "bye")
                  add_answer( "job")
                  add_answer( "name")
              end

              local choice = get_answer(answers)
              if choice == "name" then
                  add_dialogue("\"My name is James.\"")
                  remove_answer("name")
              elseif choice == "job" then
                  add_dialogue("\"I am the proprietor of the inn.\"")
                  add_answer( "inn")
                  add_answer( "proprietor")
              elseif choice == "proprietor" then
                  add_dialogue("\"It is just another way of saying that I am the man who is the desk clerk. Which thou mayest think is an easy job although it is not, I can assure thee.\"")
                  add_answer( "not easy")
                  add_answer( "desk clerk")
                  remove_answer("proprietor")
              elseif choice == "inn" then
                  add_dialogue("\"This place is called the Wayfarer's Inn. It has a long and substantial history in Britain. If thy grandparents ever came to town this is probably where they stayed.\"")
                  remove_answer("inn")
              elseif choice == "desk clerk" then
                  add_dialogue("\"Of course, being desk clerk is not all I do. I must spend all day listening to people talk about their problems as if I am supposed to solve them!\"")
                  add_answer( "solve")
                  add_answer( "listening")
                  remove_answer("desk clerk")
              elseif choice == "listening" then
                  add_dialogue("\"That is correct, \" .. get_player_name() .. \". So if thou dost have a problem, allow me the courtesy of not having to hear all about it. Now what was it that I was saying again?\"")
                  remove_answer("listening")
              elseif choice == "solve" then
                  add_dialogue("\"Maybe solving people's problems is an easy task for other innkeepers, but, not only am I bad at it, I have mine own problems as well.\"")
                  add_answer( "problems")
                  remove_answer("solve")
              elseif choice == "problems" then
                  add_dialogue("\"I do not like my job! I never wanted to be an innkeeper, I just wanted to keep the place going after my father passed on. Now that I am married to Cynthia, I am more tied down than ever!\"")
                  add_answer( "Cynthia")
                  add_answer( "innkeeper")
                  remove_answer("problems")
              elseif choice == "innkeeper" then
                  add_dialogue("\"Instead of being an innkeeper I always secretly wanted to be a pirate! When I was not sailing the seas I would be living in Buccaneer's Den.\"")
                  add_answer( "Buccaneer's Den")
                  add_answer( "pirate")
                  remove_answer("innkeeper")
              elseif choice == "Buccaneer's Den" then
                  add_dialogue("\"As I understand it they have an excellent House of Games there as well as opulent baths. Or at least so I have heard from Gordon, the man who sells fish and chips.\"")
                  remove_answer("Buccaneer's Den")
              elseif choice == "Cynthia" then
                  add_dialogue("\"Do not mistake my words, \" .. get_player_name() .. \". I love Cynthia with all mine heart. But there are I times I feel I am too young to be married. Besides, I know I cannot be a good husband for her.\"")
                  add_answer( "good husband")
                  remove_answer("Cynthia")
              elseif choice == "pirate" then
                  add_dialogue("\"Thou knowest for certain that few if any people would pour their troubles out to pirates. If I were a pirate I could get this bad foot replaced with a peg, too!\"")
                  remove_answer("pirate")
              elseif choice == "good husband" then
                  add_dialogue("\"How can I make Cynthia happy on the pittance an innkeeper makes when all day long she is counting all that money in the mint? I know I cannot.\"")
                  add_answer( "mint")
                  add_answer( "happy")
                  remove_answer("good husband")
              elseif choice == "mint" then
                  add_dialogue("\"I know the nature of the heart, my good friend. After being exposed to such large sums of money she shall begin to covet it. As I cannot provide it, she shall leave me to give her heart to a wealthy man. Perhaps a merchant or a nobleman. The thought of it makes my blood boil.\"")
                  remove_answer("mint")
              elseif choice == "not easy" then
                  add_dialogue("\"When one is an innkeeper one must run around all day long. If anyone wants anything thou art the one who must take care of it for them!\"")
                  add_answer( "room")
                  add_answer( "run around")
                  remove_answer("not easy")
              elseif choice == "run around" then
                  add_dialogue("\"I spend so much time running around that I have gotten a bad foot.\"")
                  remove_answer("run around")
              elseif choice == "happy" then
                  add_dialogue("\"Already I can sense she is worried about our marriage. I know that there is something wrong between us.\"")
                  remove_answer("happy")
              elseif choice == "room" then
                  if get_schedule() == 7 then
                      add_dialogue("\"Oh, I suppose thou wouldst like a room now! There, that is just what I mean! It is ten gold pieces per person for a night. Thou dost want a room, dost thou not?\"")
                      local response = call_extern(0x090A, var_0001)
                      if response == 0 then
                          local party_count = U7.getPartyMembers()
                          local cost = party_count * 10
                          local gold_result = U7.removeGold(cost)
                          if gold_result then
                              local item_result = U7.giveItem(255, 1, 641)
                              if item_result then
                                  add_dialogue("\"Here is thy room key. It is only good until thou leavest the inn.\"")
                              else
                                  add_dialogue("\"Thou art carrying too much to take the room key!\"")
                              end
                          else
                              add_dialogue("\"Thou dost not have enough gold to get a room here. Now I suppose thou shalt be telling me all about how such a sorry state befell thee. Well, I shall not listen to thee!\"")
                          end
                      else
                          add_dialogue("James wipes his brow. \"Phew! That was a close call!\"")
                      end
                  else
                      add_dialogue("\"Please, \" .. get_player_name() .. \". Do allow me some time to myself! Presently I am not doing the business of the inn and I do wish to keep it that way. Thou must attend to the inn during business hours.\"")
                  end
                  remove_answer("room")
              elseif choice == "Cynthia said" then
                  add_dialogue("You repeat the words that Cynthia had said to you about him. A smile comes across his face. \"Aww, who wants to be a pirate anyway? I would hate that!\" With that he goes back to wiping the bar, but you notice that the smile is still there.")
                  remove_answer("Cynthia said")
              elseif choice == "bye" then
                  add_dialogue("\"Oh, thou shalt just come back again wanting something else from me! I just know it!\"")
                  break
              end
          end
      elseif eventid == 0 then
          call_extern(0x092E, npc_id)
      end
  end

  return func_042E