-- func_042D.lua
  -- Figg's dialogue about the Royal Orchards and Weston's theft
  local U7 = require("U7LuaFuncs")

  function func_042D(eventid)
      local answers = {}
      local flag_00C6 = U7.getFlag(0x00C6) -- Weston topic
      local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
      local flag_00AE = U7.getFlag(0x00AE) -- First meeting
      local npc_id = -45 -- Figg's NPC ID

      if eventid == 1 then
          _SwitchTalkTo(0, npc_id)
          local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
          local var_0001 = U7.callExtern(0x090A, 1) -- Buy interaction
          local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
          local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
          local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction
          local var_0005 = U7.callExtern(0x08FC, 5) -- Unknown interaction

          table.insert(answers, "bye")
          table.insert(answers, "job")
          table.insert(answers, "name")
          if flag_00C6 then
              table.insert(answers, "Weston")
          end
          if flag_0094 then
              table.insert(answers, "Fellowship")
          end

          if not flag_00AE then
              U7.say("You see a man whose wrinkled face forms a caricature of grumpiness.")
              U7.setFlag(0x00AE, true)
          else
              U7.say("\"Thou dost wish words with me, \" .. U7.getPlayerName() .. \"?\" asks Figg.")
          end

          while true do
              if #answers == 0 then
                  U7.say("Figg grumbles. \"What now? Speak clearly!\"")
                  table.insert(answers, "bye")
                  table.insert(answers, "job")
                  table.insert(answers, "name")
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  U7.say("\"I am Figg.\"")
                  U7.RemoveAnswer("name")
              elseif choice == "job" then
                  U7.say("\"I am the caretaker of the Royal Orchards here in Britain.\"")
                  table.insert(answers, "Royal Orchards")
                  table.insert(answers, "caretaker")
              elseif choice == "caretaker" then
                  U7.say("\"My responsibilities include caring for the trees, watching over the pickers at harvest time and protecting the Royal Orchard from thieves.\"")
                  table.insert(answers, "thieves")
                  table.insert(answers, "pickers")
                  table.insert(answers, "trees")
                  U7.RemoveAnswer("caretaker")
              elseif choice == "trees" then
                  U7.say("\"Apple trees require constant care. I must make sure the trees all have enough water but not too much. I must keep all trees properly trimmed and be watchful so that the crop does not get infested by bugs or worms. I am also required to pick up all of the fallen apples, which is a job in itself.\"")
                  U7.RemoveAnswer("trees")
              elseif choice == "pickers" then
                  U7.say("\"Most of them are migrant farmers from Paws. Because they were once farmers, they are convinced they know more about the upkeep of the orchard than I! Of course that is preposterous. Also the pickers do not take orders very well.\"")
                  U7.RemoveAnswer("pickers")
              elseif choice == "thieves" then
                  U7.say("\"They would rob us down to the last twig if I gave them the chance! I should be awarded a medal from Lord British himself the way I risk my very life and limb protecting this orchard. Why, I just caught another thief recently. His name was Weston.\"")
                  table.insert(answers, "Weston")
                  U7.RemoveAnswer("thieves")
              elseif choice == "Royal Orchards" then
                  U7.say("\"Here are grown the finest apples in all of Britannia. I would let thee sample one but it would be against the law as thou art obviously not of noble stock.\"")
                  U7.RemoveAnswer("Royal Orchards")
              elseif choice == "Weston" then
                  U7.say("\"He now resides in the prison, thanks to me! I knew what he was up to from the moment I saw him! He had the look of a hardened apple thief so I had him nicked by the town guard.\"")
                  table.insert(answers, "apple thief")
                  table.insert(answers, "prison")
                  if not flag_0094 then
                      table.insert(answers, "Fellowship")
                  end
                  U7.RemoveAnswer("Weston")
              elseif choice == "prison" then
                  U7.say("\"Yes, Weston is now living in our local prison. If thou dost not believe me, thou canst go there and see for thyself!\"")
                  U7.RemoveAnswer("prison")
              elseif choice == "apple thief" then
                  U7.say("\"Oh, he came here with some sob story. But when one is as astute an observer of human behavior as I am, one can tell the true intent of people, which is often contrary to what they will say to thee!\"")
                  table.insert(answers, "observer")
                  table.insert(answers, "sob story")
                  U7.RemoveAnswer("apple thief")
              elseif choice == "sob story" then
                  U7.say("\"I do not recall, exactly. Something about his impoverished wife and family starving to death in Paws or some load of rubbish.\"")
                  U7.RemoveAnswer("sob story")
              elseif choice == "observer" then
                  U7.say("\"Yes, I do consider myself to be a more than passable judge of character. And dost thou know how I became so?\"")
                  local response = U7.callExtern(0x090A, var_0001)
                  if response == 0 then
                      U7.say("\"Oh, then art thou not the clever one!\"")
                  else
                      U7.say("\"Then I shall tell thee! I am a member of The Fellowship!\"")
                      U7.callExtern(0x0919, var_0002)
                  end
                  U7.RemoveAnswer("observer")
              elseif choice == "Fellowship" then
                  U7.say("\"I am a member of the Fellowship, yes. But it would be a crime for me to give apples from the Royal Orchard to The Fellowship, and it would be a violation of my sacred duty. While selling apples is also a violation, I was only trying to do this man Weston a favor. And I suppose these accusations are the thanks I get? Hmph!\"")
                  if U7.getPlayerChoice("Fellowship_member") then
                      U7.say("He leans in close to you and speaks lower. \"Thou art also a member of The Fellowship, after all. Am I not thy brother? Shouldst thou not trust me?\" He gives you a crooked wink.")
                      local item_result = U7.giveItem(16, 1, 377)
                      if item_result then
                          U7.say("\"Thou seest? I am thy brother!\" He hands you an apple.")
                      else
                          U7.say("\"I would give thee an apple to show thee my sincerity, but it seems thou art too encumbered.\"")
                      end
                  else
                      U7.say("\"But enough of these desperate accusations from a known criminal.\"")
                      table.insert(answers, "buy")
                  end
                  U7.RemoveAnswer("Fellowship")
              elseif choice == "buy" then
                  U7.say("\"I can do thee a favor as well. Wouldst thou like to buy one of these beautiful apples for the merest pittance of five gold coins?\"")
                  local buy_response = U7.callExtern(0x090A, var_0001)
                  if buy_response == 0 then
                      local gold_result = U7.removeGold(5)
                      if gold_result then
                          local item_result = U7.giveItem(16, 1, 377)
                          if item_result then
                              U7.say("Figg takes an apple from a nearby basket. After polishing it slightly on his shirt, he hands it to you.")
                          else
                              U7.say("\"Thou cannot take thine apple! Thou art carrying too much!\"")
                          end
                      else
                          U7.say("\"Thou dost not even have enough gold to buy one apple! Thou hast wasted the time of the King's Caretaker of the Royal Orchard. Away, peasant! Away before I call the guard!\"")
                          U7.abort()
                      end
                  else
                      U7.say("\"Very well. But thou art passing up an opportunity that few are offered. In fact, eh, I would appreciate it if thou wouldst not mention our little chat to anyone. Agreed?\"")
                      local agree_response = U7.callExtern(0x090A, var_0001)
                      if agree_response == 0 then
                          U7.say("\"Ah, I knew thou wert a good 'un.\"")
                      else
                          U7.say("\"No! Well, fine, then.\"")
                          U7.abort()
                      end
                  end
                  U7.RemoveAnswer("buy")
              elseif choice == "bye" then
                  U7.say("\"I can see that thou shouldst be on thy way.\"")
                  break
              end
          end
      elseif eventid == 0 then
          U7.callExtern(0x092E, npc_id)
      end
  end

  return func_042D