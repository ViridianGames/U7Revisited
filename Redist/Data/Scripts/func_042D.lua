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

          add_answer( "bye")
          add_answer( "job")
          add_answer( "name")
          if flag_00C6 then
              add_answer( "Weston")
          end
          if flag_0094 then
              add_answer( "Fellowship")
          end

          if not flag_00AE then
              add_dialogue("You see a man whose wrinkled face forms a caricature of grumpiness.")
              set_flag(0x00AE, true)
          else
              add_dialogue("\"Thou dost wish words with me, \" .. U7.getPlayerName() .. \"?\" asks Figg.")
          end

          while true do
              if #answers == 0 then
                  add_dialogue("Figg grumbles. \"What now? Speak clearly!\"")
                  add_answer( "bye")
                  add_answer( "job")
                  add_answer( "name")
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  add_dialogue("\"I am Figg.\"")
                  remove_answer("name")
              elseif choice == "job" then
                  add_dialogue("\"I am the caretaker of the Royal Orchards here in Britain.\"")
                  add_answer( "Royal Orchards")
                  add_answer( "caretaker")
              elseif choice == "caretaker" then
                  add_dialogue("\"My responsibilities include caring for the trees, watching over the pickers at harvest time and protecting the Royal Orchard from thieves.\"")
                  add_answer( "thieves")
                  add_answer( "pickers")
                  add_answer( "trees")
                  remove_answer("caretaker")
              elseif choice == "trees" then
                  add_dialogue("\"Apple trees require constant care. I must make sure the trees all have enough water but not too much. I must keep all trees properly trimmed and be watchful so that the crop does not get infested by bugs or worms. I am also required to pick up all of the fallen apples, which is a job in itself.\"")
                  remove_answer("trees")
              elseif choice == "pickers" then
                  add_dialogue("\"Most of them are migrant farmers from Paws. Because they were once farmers, they are convinced they know more about the upkeep of the orchard than I! Of course that is preposterous. Also the pickers do not take orders very well.\"")
                  remove_answer("pickers")
              elseif choice == "thieves" then
                  add_dialogue("\"They would rob us down to the last twig if I gave them the chance! I should be awarded a medal from Lord British himself the way I risk my very life and limb protecting this orchard. Why, I just caught another thief recently. His name was Weston.\"")
                  add_answer( "Weston")
                  remove_answer("thieves")
              elseif choice == "Royal Orchards" then
                  add_dialogue("\"Here are grown the finest apples in all of Britannia. I would let thee sample one but it would be against the law as thou art obviously not of noble stock.\"")
                  remove_answer("Royal Orchards")
              elseif choice == "Weston" then
                  add_dialogue("\"He now resides in the prison, thanks to me! I knew what he was up to from the moment I saw him! He had the look of a hardened apple thief so I had him nicked by the town guard.\"")
                  add_answer( "apple thief")
                  add_answer( "prison")
                  if not flag_0094 then
                      add_answer( "Fellowship")
                  end
                  remove_answer("Weston")
              elseif choice == "prison" then
                  add_dialogue("\"Yes, Weston is now living in our local prison. If thou dost not believe me, thou canst go there and see for thyself!\"")
                  remove_answer("prison")
              elseif choice == "apple thief" then
                  add_dialogue("\"Oh, he came here with some sob story. But when one is as astute an observer of human behavior as I am, one can tell the true intent of people, which is often contrary to what they will say to thee!\"")
                  add_answer( "observer")
                  add_answer( "sob story")
                  remove_answer("apple thief")
              elseif choice == "sob story" then
                  add_dialogue("\"I do not recall, exactly. Something about his impoverished wife and family starving to death in Paws or some load of rubbish.\"")
                  remove_answer("sob story")
              elseif choice == "observer" then
                  add_dialogue("\"Yes, I do consider myself to be a more than passable judge of character. And dost thou know how I became so?\"")
                  local response = U7.callExtern(0x090A, var_0001)
                  if response == 0 then
                      add_dialogue("\"Oh, then art thou not the clever one!\"")
                  else
                      add_dialogue("\"Then I shall tell thee! I am a member of The Fellowship!\"")
                      U7.callExtern(0x0919, var_0002)
                  end
                  remove_answer("observer")
              elseif choice == "Fellowship" then
                  add_dialogue("\"I am a member of the Fellowship, yes. But it would be a crime for me to give apples from the Royal Orchard to The Fellowship, and it would be a violation of my sacred duty. While selling apples is also a violation, I was only trying to do this man Weston a favor. And I suppose these accusations are the thanks I get? Hmph!\"")
                  if U7.getPlayerChoice("Fellowship_member") then
                      add_dialogue("He leans in close to you and speaks lower. \"Thou art also a member of The Fellowship, after all. Am I not thy brother? Shouldst thou not trust me?\" He gives you a crooked wink.")
                      local item_result = U7.giveItem(16, 1, 377)
                      if item_result then
                          add_dialogue("\"Thou seest? I am thy brother!\" He hands you an apple.")
                      else
                          add_dialogue("\"I would give thee an apple to show thee my sincerity, but it seems thou art too encumbered.\"")
                      end
                  else
                      add_dialogue("\"But enough of these desperate accusations from a known criminal.\"")
                      add_answer( "buy")
                  end
                  remove_answer("Fellowship")
              elseif choice == "buy" then
                  add_dialogue("\"I can do thee a favor as well. Wouldst thou like to buy one of these beautiful apples for the merest pittance of five gold coins?\"")
                  local buy_response = U7.callExtern(0x090A, var_0001)
                  if buy_response == 0 then
                      local gold_result = U7.removeGold(5)
                      if gold_result then
                          local item_result = U7.giveItem(16, 1, 377)
                          if item_result then
                              add_dialogue("Figg takes an apple from a nearby basket. After polishing it slightly on his shirt, he hands it to you.")
                          else
                              add_dialogue("\"Thou cannot take thine apple! Thou art carrying too much!\"")
                          end
                      else
                          add_dialogue("\"Thou dost not even have enough gold to buy one apple! Thou hast wasted the time of the King's Caretaker of the Royal Orchard. Away, peasant! Away before I call the guard!\"")
                          U7.abort()
                      end
                  else
                      add_dialogue("\"Very well. But thou art passing up an opportunity that few are offered. In fact, eh, I would appreciate it if thou wouldst not mention our little chat to anyone. Agreed?\"")
                      local agree_response = U7.callExtern(0x090A, var_0001)
                      if agree_response == 0 then
                          add_dialogue("\"Ah, I knew thou wert a good 'un.\"")
                      else
                          add_dialogue("\"No! Well, fine, then.\"")
                          U7.abort()
                      end
                  end
                  remove_answer("buy")
              elseif choice == "bye" then
                  add_dialogue("\"I can see that thou shouldst be on thy way.\"")
                  break
              end
          end
      elseif eventid == 0 then
          U7.callExtern(0x092E, npc_id)
      end
  end

  return func_042D