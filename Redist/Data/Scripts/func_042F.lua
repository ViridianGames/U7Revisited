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

          add_answer( "bye")
          add_answer( "job")
          add_answer( "name")
          if flag_007B then
              add_answer( "Charles")
          end

          if not flag_00B0 then
              add_dialogue("This young, lovely tavern wench is sexy and sweet.")
              set_flag(0x00B0, true)
          else
              add_dialogue("\"Hello again!\" bubbly Jeanette says.")
          end

          while true do
              if #answers == 0 then
                  add_dialogue("Jeanette smiles. \"Anything else I can help thee with?\"")
                  add_answer( "bye")
                  add_answer( "job")
                  add_answer( "name")
                  start_dialogue()
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  add_dialogue("\"Jeanette, at thy service!\"")
                  remove_answer("name")
              elseif choice == "job" then
                  add_dialogue("\"I work for Lucy at the Blue Boar. I serve food and drinks.")
                  if U7.getPartyMember(23) then
                      add_dialogue("\"If there is anything thou wouldst like, please say so! And, er, I shall give thee a discount if thou dost buy from me!\"")
                      local result = U7.callExtern(0x08F7, dupre_id)
                      if result == 0 then
                          add_dialogue("\"Why, Sir Dupre! How good to see thee again!\"")
                          _SwitchTalkTo(0, dupre_id)
                          add_dialogue("\"Hello milady! I thought I might re-sample The Blue Boar's fine beverages!\"")
                          _SwitchTalkTo(0, npc_id)
                          add_dialogue("\"Any time, milord! Any time!\"")
                          U7.HideNPC(dupre_id)
                          _SwitchTalkTo(0, npc_id)
                      end
                      add_answer( "buy")
                      add_answer( "drink")
                      add_answer( "food")
                      start_dialogue()
                  else
                      add_dialogue("\"I work during the day and evening hours. Thou shouldst come by the pub then and we shall talk more!\"")
                  end
              elseif choice == "food" then
                  add_dialogue("\"Lucy is a good cook. I recommend everything. Especially Silverleaf.\"")
                  add_answer( "Silverleaf")
                  remove_answer("food")
              elseif choice == "Silverleaf" then
                  add_dialogue("\"Wonderful dish. Try it!\"")
                  remove_answer("Silverleaf")
              elseif choice == "drink" then
                  add_dialogue("\"Thou dost look like thou dost need a good drink!\"")
                  remove_answer("drink")
              elseif choice == "buy" then
                  U7.callExtern(0x08A0, var_0001)
              elseif choice == "Charles" then
                  add_dialogue("\"He spoke of me, did he? Well, he may think again! I cannot bring myself to socialize with the upper class. Those bourgeoisie rich men are obnoxious and egotistical. Besides, I am in love with another.\"")
                  flag_007D = true
                  set_flag(0x007D, true)
                  remove_answer("Charles")
                  add_answer( "another")
                  add_answer( "upper class")
                  start_dialogue()
              elseif choice == "upper class" then
                  add_dialogue("\"They are all alike. They work in castles and have piles of gold and can have any woman they want! On the other hand, a humble merchant is the perfect man.\"")
                  remove_answer("upper class")
              elseif choice == "another" then
                  add_dialogue("\"'Tis Willy the Baker! But he does not know it yet!\" she giggles.")
                  flag_0085 = true
                  set_flag(0x0085, true)
                  local iolo_result = U7.callExtern(0x08F7, iolo_id)
                  if iolo_result == 0 then
                      _SwitchTalkTo(0, iolo_id)
                      add_dialogue("\"A moment, Jeanette! Thou hast it all wrong! Charles is a -servant-! Thou art an ignoramus! Charles is not 'upper class'! He is as working class as thee! 'Tis Willy who is the rich merchant! If thou dost ask me, 'tis Willy who is obnoxious and egotistical. Charles is a dream!\"")
                      U7.HideNPC(iolo_id)
                      _SwitchTalkTo(0, npc_id)
                  else
                      add_dialogue("You point out to Jeanette that Charles is a servant.")
                  end
                  add_dialogue("Jeanette thinks about what was said. \"Thou art right! I cannot believe I have been so blind! Oh, Charles! I can actually consider Charles! And he is... so handsome!\" Jeanette squeals with delight. \"I shall have to flirt with him in earnest next time he is in the pub!\"")
                  flag_007E = true
                  set_flag(0x007E, true)
                  U7.callExtern(0x0911, 20)
                  remove_answer("another")
              elseif choice == "bye" then
                  add_dialogue("\"Farewell!\"")
                  break
              end
          end
      elseif eventid == 0 then
          U7.callExtern(0x092E, npc_id)
      end
  end

  return func_042F