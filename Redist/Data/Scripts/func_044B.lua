-- func_044B.lua
  -- Rudyom's dialogue about magic, moongates, and blackrock
  local U7 = require("U7LuaFuncs")

  function func_044B(eventid)
      local answers = {}
      local flag_0065 = U7.getFlag(0x0065) -- Moongates/blackrock topics
      local flag_00E7 = U7.getFlag(0x00E7) -- First meeting
      local flag_0003 = U7.getFlag(0x0003) -- Magic ether state
      local flag_0004 = U7.getFlag(0x0004) -- Moongates gone
      local npc_id = -74 -- Rudyom's NPC ID

      if eventid == 1 then
          _SwitchTalkTo(0, npc_id)
          local var_0000 = U7.callExtern(0x090A, 0) -- Unknown interaction
          local var_0001 = U7.callExtern(0x08DB, 1) -- Spells interaction
          local var_0002 = U7.callExtern(0x08DC, 2) -- Reagents interaction
          local var_0003 = U7.callExtern(0x0911, 3) -- Unknown interaction

          table.insert(answers, "bye")
          table.insert(answers, "job")
          table.insert(answers, "name")
          if flag_0065 then
              table.insert(answers, "Moongates")
              table.insert(answers, "blackrock")
          end

          if not flag_00E7 then
              U7.say("This elderly mage looks older and more senile than when you last saw him.")
              U7.setFlag(0x00E7, true)
          elseif not flag_0003 then
              U7.say("\"Who art thou?\" Rudyom asks. \"Oh -- I remember.\"")
          else
              U7.say("\"Hello again, Avatar!\" Rudyom says, beaming.")
          end

          while true do
              if #answers == 0 then
                  U7.say("Rudyom looks confused. \"What was that? Let's try again.\"")
                  table.insert(answers, "bye")
                  table.insert(answers, "job")
                  table.insert(answers, "name")
              end

              local choice = U7.getPlayerChoice(answers)
              if choice == "name" then
                  U7.say("\"That I know. My name is Rudyom.\"")
                  U7.RemoveAnswer("name")
              elseif choice == "job" then
                  if not flag_0003 then
                      U7.say("\"I am not sure anymore. I was a powerful mage at one time! Now nothing works. Magic is afoul! I suppose I could sell thee some reagents and spells if thou dost want. And mind the carpet -- it does not work!\"")
                      table.insert(answers, "carpet")
                  else
                      U7.say("\"I am a powerful mage! Magic is my milieu! I can sell thee spells or reagents.\"")
                  end
                  table.insert(answers, "reagents")
                  table.insert(answers, "spells")
                  table.insert(answers, "magic")
              elseif choice == "magic" then
                  if not flag_0003 then
                      U7.say("\"I do not understand what is wrong. My magic does not work so well anymore.\"")
                  else
                      U7.say("\"The ether is flowing freely! Magic is with us once again!\"")
                  end
                  U7.RemoveAnswer("magic")
              elseif choice == "carpet" then
                  U7.say("\"The big blue carpet. 'Tis a flying carpet. It does not work like it should.\"")
                  U7.say("Rudyom looks around and scratches his head.")
                  U7.say("\"Funny. It was here a while ago. Oh! I remember now. Some adventurers borrowed my flying carpet a few weeks ago. When they returned they said they had lost it near Serpent's Spine. Somewhere in the vicinity of the Lost River. I suppose if thou didst want to go and find it, thou couldst keep it. It did not work very well. Perhaps thou canst make it work. I did not like the color, anyway!\"")
                  U7.RemoveAnswer("carpet")
              elseif choice == "spells" then
                  U7.say("\"Dost thou wish to buy some spells?\"")
                  if U7.callExtern(0x090A, var_0000) == 0 then
                      U7.callExtern(0x08DB, var_0001)
                  else
                      U7.say("\"Oh. Never mind, then.\"")
                  end
              elseif choice == "reagents" then
                  U7.say("\"Dost thou wish to buy some reagents?\"")
                  if U7.callExtern(0x090A, var_