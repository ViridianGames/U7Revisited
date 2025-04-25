-- Generates a random mad-libs style dialogue phrase using external functions.
function func_086F()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20

    if get_random(0, 3) == 0 then
        local0 = get_random(0, 1) == 0 and external_0865H() or external_0866H() -- Unmapped intrinsic
    else
        local0 = get_random(0, 1) == 0 and external_086CH() or external_086DH() -- Unmapped intrinsic
    end
    local1 = local0[1]
    local2 = local0[2]
    local3 = get_random(0, 1) == 0 and external_0865H() or external_0866H() -- Unmapped intrinsic
    local4 = get_random(0, 1) == 0 and external_0865H() or external_0866H() -- Unmapped intrinsic
    local5 = get_random(0, 1) == 0 and external_0865H() or external_0866H() -- Unmapped intrinsic
    local5 = local5[2]
    local0 = external_0867H() -- Unmapped intrinsic
    local6 = local0[1]
    local7 = local0[2]
    local0 = get_random(0, 1) == 0 and external_0868H() or external_0869H() -- Unmapped intrinsic
    local8 = local0[1]
    local9 = local0[2]
    local10 = local0[3]
    local11 = get_random(0, 1) == 0 and external_086AH() or external_086BH() -- Unmapped intrinsic
    local0 = get_random(0, 1) == 0 and external_086CH() or external_086DH() -- Unmapped intrinsic
    local12 = local0[1]
    local13 = local0[2]
    local14 = external_086EH() -- Unmapped intrinsic
    local0 = get_random(0, 36)
    if local0 == 0 then
        local15 = "I'll show you my " .. local6 .. " " .. local1 .. " if you show me yours."
    elseif local0 == 1 then
        local15 = "All of my " .. local6 .. " " .. local2 .. " are " .. local10 .. " " .. local11 .. "."
    elseif local0 == 2 then
        local15 = "Stop " .. local10 .. " my " .. local6 .. " " .. local1 .. ", please."
    elseif local0 == 3 then
        local15 = "Have you seen my " .. local1 .. "? It's " .. local10 .. " " .. local11 .. "."
    elseif local0 == 4 then
        local15 = "There is no " .. local1 .. " for you today, little " .. local12 .. ", only death."
    elseif local0 == 5 then
        local16 = external_0096H(local6) -- Unmapped intrinsic
        local15 = "Am I having " .. local16 .. " " .. local6 .. " " .. local1 .. " yet?"
    elseif local0 == 6 then
        local16 = external_0096H(local6) -- Unmapped intrinsic
        local15 = "Where is my attorney? I need " .. local16 .. " " .. local6 .. " " .. local1 .. " right away."
    elseif local0 == 7 then
        local15 = "You saved my " .. local6 .. " " .. local12 .. " from " .. local1 .. ", " .. local14 .. ". How can I ever repay you?"
    elseif local0 == 8 then
        local16 = external_0096H(local1) -- Unmapped intrinsic
        local15 = "^" .. local16 .. " " .. local1 .. ", " .. local16 .. " " .. local1 .. ", my kingdom for " .. local16 .. " " .. local1 .. "!"
    elseif local0 == 9 then
        local16 = external_0096H(local1) -- Unmapped intrinsic
        local15 = "Frankly, my dear, I don't give " .. local16 .. " " .. local1 .. "."
    elseif local0 == 10 then
        local15 = "As " .. local2 .. " are my witness, I'll never go " .. local6 .. " again."
    elseif local0 == 11 then
        local15 = "Oh my, " .. local14 .. ", I don't think we're in Kansas anymore."
    elseif local0 == 12 then
        local15 = "May I borrow your " .. local1 .. "? Mine seems to be " .. local6 .. " " .. local11 .. "."
    elseif local0 == 13 then
        local15 = "My " .. local13 .. " are " .. local10 .. " " .. local11 .. "."
    elseif local0 == 14 then
        local15 = "You shall know the " .. local1 .. " and the " .. local1 .. " shall make you " .. local6 .. "."
    elseif local0 == 15 then
        local16 = external_0096H(local12) -- Unmapped intrinsic
        local15 = "Thou shalt not " .. local8 .. " to " .. local16 .. " " .. local12 .. ", " .. local14 .. "."
    elseif local0 == 16 then
        local15 = "Honor thy father and thy " .. local1 .. ", " .. local14 .. "."
    elseif local0 == 17 then
        local15 = "Thou shalt not covet thy neighbor's " .. local1 .. ", " .. local14 .. "."
    elseif local0 == 18 then
        local16 = external_0096H(local1) -- Unmapped intrinsic
        local15 = "Neither a borrower nor " .. local16 .. " " .. local1 .. " be."
    elseif local0 == 19 then
        local15 = "Never " .. local8 .. " a gift " .. local12 .. " in the " .. local1 .. "."
    elseif local0 == 20 then
        local15 = "A fool and his " .. local1 .. " are soon " .. local6 .. "."
    elseif local0 == 21 then
        local15 = "Workers of the world, " .. local8 .. "! You have nothing to lose but your " .. local2 .. "!"
    elseif local0 == 22 then
        local15 = "Ich bin ein " .. local1 .. "er."
    elseif local0 == 23 then
        local15 = "Damn the " .. local2 .. "! ^" .. local6 .. " speed ahead!"
    elseif local0 == 24 then
        local15 = "Ask not what your " .. local6 .. " " .. local1 .. " can do for you, but what you can do for your " .. local6 .. " " .. local1 .. "."
    elseif local0 == 25 then
        local15 = "^" .. local14 .. "! " .. local14 .. "! You damn " .. local12 .. "."
    elseif local0 == 26 then
        local15 = "Let me just remind you that the " .. local2 .. " of " .. local3 .. " may be more " .. local6 .. " than they appear."
    elseif local0 == 27 then
        local15 = "Destroy your " .. local6 .. " and " .. local7 .. " life before it is too late, " .. local14 .. "."
    elseif local0 == 28 then
        local16 = external_0096H(local6) -- Unmapped intrinsic
        local17 = external_0096H(local1) -- Unmapped intrinsic
        local15 = "My head feels like " .. local16 .. " " .. local6 .. " with " .. local17 .. " " .. local1 .. " pointed at it."
    elseif local0 == 29 then
        local15 = "Beautiful, " .. local14 .. ", I'll have my " .. local1 .. " call your " .. local1 .. "."
    elseif local0 == 30 then
        local15 = "No thank you, I'm watching my " .. local1 .. " intake."
    elseif local0 == 31 then
        local16 = external_0096H(local6) -- Unmapped intrinsic
        local18 = "Ode to " .. local16 .. " " .. local6 .. " " .. local1 .. ". "
        local15 = "O how the " .. local13 .. " of " .. local1 .. " " .. local8 .. " " .. local11 .. " amidst the " .. local6 .. " " .. local3 .. "."
    elseif local0 == 32 then
        local16 = external_0096H(local6) -- Unmapped intrinsic
        local15 = "Shall I compare thee to " .. local16 .. " " .. local6 .. " " .. local1 .. "? Thou art far more " .. local7 .. "."
    elseif local0 == 33 then
        local19 = external_0096H(local1) -- Unmapped intrinsic
        local15 = "To be " .. local19 .. " " .. local1 .. " or not to be. That is the " .. local3 .. ". Whether tis nobler in the " .. local4 .. " to " .. local8 .. " the " .. local2 .. " and " .. local5 .. " of " .. local6 .. " " .. local3 .. " or..."
    elseif local0 == 34 then
        local15 = "This morning I saw a small " .. local1 .. " " .. local10 .. " " .. local11 .. ". How the seasons of " .. local6 .. " " .. local3 .. " come and go. Death falls upon us all."
    elseif local0 == 35 then
        local15 = "Rage, rage against the " .. local10 .. " of the " .. local1 .. "."
    elseif local0 == 36 then
        local15 = "Love in the turning " .. local1 .. ". The small " .. local13 .. " " .. local8 .. " " .. local11 .. ". The " .. local6 .. " " .. local5 .. " whisper their " .. local7 .. " muses. Oh, the turning " .. local1 .. "."
    end
    return local18 and (local18 .. local15) or local15
end