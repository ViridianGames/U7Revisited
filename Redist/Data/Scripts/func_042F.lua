-- func_042F.lua
  -- Jeanette's dialogue at the Blue Boar tavern
  local U7 = require("U7LuaFuncs")

  function func_042F(eventid)
      local answers = {}
      local flag_007B = U7.getFlag(0x007B) -- Charles mentioned
      local flag_00B0 = U7.getFlag(0x00B0) -- First meeting
      local flag_007D = false -- Charles inquiry
      local flag_007E = false -- Charles correction
      local flag_0085 = false -- Willy reveal
      local npc_id = -47 -- Jeanette's NPC ID
      local dupre_id = -4 -- Dupre's NPC ID
      local iolo_id = -37 -- Iolo's NPC ID

      if eventid == 1 then
          _SwitchTalkTo(0, npc_id)
          local var_0000 = U7.callExtern(0x08F7, 0) -- External function call
          local var_0001 = U7.callExtern(0x08A0, 1) -- Buy interaction
          local var_0002 = U7.callExtern(0x0911, 2) -- Unknown interaction
          local var_0003 = U7.callExtern(0x092E, 3) -- Unknown interaction

          table.insert(answers, "bye")
          table.insert(answers, "job")
          table.insert(answers, "name")
          if flag_007B then
              table.insert(answers, "Charles")
          end

          if not flag_00B0 then
              U7.say("This young, lovely tavern wench is sexy and sweet.")
              U7.setFlag(0x00B0, true)
          else
              U7.say("\"Hello again!\" bubbly Jeanette says.")
          end

          while true do
              if #answers == 0 then
                  U7.say("Jeanette smiles. \"Anything else I can help thee with?\"")
                  table.insert(answers, "bye")
                  table.insert(answers, "job")
                  table.insert(answers, "name")
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  U7.say("\"Jeanette, at thy service!\"")
                  U7.RemoveAnswer("name")
              elseif choice == "job" then
                  U7.say("\"I work for Lucy at the Blue Boar. I serve food and drinks.")
                  if U7.getPartyMember(23) then
                      U7.say("\"If there is anything thou wouldst like, please say so! And, er, I shall give thee a discount if thou dost buy from me!\"")
                      local result = U7.callExtern(0x08F7, dupre_id)
                      if result == 0 then
                          U7.say("\"Why, Sir Dupre! How good to see thee again!\"")
                          _SwitchTalkTo(0, dupre_id)
                          U7.say("\"Hello milady! I thought I might re-sample The Blue Boar's fine beverages!\"")
                          _SwitchTalkTo(0, npc_id)
                          U7.say("\"Any time, milord! Any time!\"")
                          U7.HideNPC(dupre_id)
                          _SwitchTalkTo(0, npc_id)
                      end
                      table.insert(answers, "buy")
                      table.insert(answers, "drink")
                      table.insert(answers, "food")
                  else
                      U7.say("\"I work during the day and evening hours. Thou shouldst come by the pub then and we shall talk more!\"")
                  end
              elseif choice == "food" then
                  U7.say("\"Lucy is a good cook. I recommend everything. Especially Silverleaf.\"")
                  table.insert(answers, "Silverleaf")
                  U7.RemoveAnswer("food")
              elseif choice == "Silverleaf" then
                  U7.say("\"Wonderful dish. Try it!\"")
                  U7.RemoveAnswer("Silverleaf")
              elseif choice == "drink" then
                  U7.say("\"Thou dost look like thou dost need a good drink!\"")
                  U7.RemoveAnswer("drink")
              elseif choice == "buy" then
                  U7.callExtern(0x08A0, var_0001)
              elseif choice == "Charles" then
                  U7.say("\"He spoke of me, did he? Well, he may think again! I cannot bring myself to socialize with the upper class. Those bourgeoisie rich men are obnoxious and egotistical. Besides, I am in love with another.\"")
                  flag_007D = true
                  U7.setFlag(0x007D, true)
                  U7.RemoveAnswer("Charles")
                  table.insert(answers, "another")
                  table.insert(answers, "upper class")
              elseif choice == "upper class" then
                  U7.say("\"They are all alike. They work in castles and have piles of gold and can have any woman they want! On the other hand, a humble merchant is the perfect man.\"")
                  U7.RemoveAnswer("upper class")
              elseif choice == "another" then
                  U7.say("\"'Tis Willy the Baker! But he does not know it yet!\" she giggles.")
                  flag_0085 = true
                  U7.setFlag(0x0085, true)
                  local iolo_result = U7.callExtern(0x08F7, iolo_id)
                  if iolo_result == 0 then
                      _SwitchTalkTo(0, iolo_id)
                      U7.say("\"A moment, Jeanette! Thou hast it all wrong! Charles is a -servant-! Thou art an ignoramus! Charles is not 'upper class'! He is as working class as thee! 'Tis Willy who is the rich merchant! If thou dost ask me, 'tis Willy who is obnoxious and egotistical. Charles is a dream!\"")
                      U7.HideNPC(iolo_id)
                      _SwitchTalkTo(0, npc_id)
                  else
                      U7.say("You point out to Jeanette that Charles is a servant.")
                  end
                  U7.say("Jeanette thinks about what was said. \"Thou art right! I cannot believe I have been so blind! Oh, Charles! I can actually consider Charles! And he is... so handsome!\" Jeanette squeals with delight. \"I shall have to flirt with him in earnest next time he is in the pub!\"")
                  flag_007E = true
                  U7.setFlag(0x007E, true)
                  U7.callExtern(0x0911, 20)
                  U7.RemoveAnswer("another")
              elseif choice == "bye" then
                  U7.say("\"Farewell!\"")
                  break
              end
          end
      elseif eventid == 0 then
          U7.callExtern(0x092E, npc_id)
      end
  end

  return func_042F