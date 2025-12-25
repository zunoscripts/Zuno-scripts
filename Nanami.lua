local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local canClick = false 
local currentTimerId = 0 
local isClicking = false -- Anti-Extra M1 Lock

-- Key Switch Logic (PC + PS5)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local isSkill = (input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.Two or 
                     input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonA)
    local isOff = (input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.ButtonY)

    if isOff then
        canClick = false
        currentTimerId = currentTimerId + 1 
        print("GATE CLOSED.")
    elseif isSkill then
        currentTimerId = currentTimerId + 1
        local myTimerId = currentTimerId
        
        isClicking = false -- Reset the lock for the new move
        task.wait(0.20) 
        canClick = true
        print("GATE OPEN (2s Window)")

        task.delay(2, function()
            if currentTimerId == myTimerId then
                canClick = false
            end
        end)
    end
end)

local function handleCrit(gui)
    local mainBar = gui:WaitForChild("MainBar", 5)
    local cutter = mainBar and mainBar:WaitForChild("Cutter", 5)
    if not cutter then return end

    local connection
    connection = RunService.RenderStepped:Connect(function()
        -- Kill if UI gone, or if we already clicked, or if gate closed
        if not gui or not gui.Parent or not canClick or isClicking then
            if not gui or not gui.Parent then connection:Disconnect() end
            return
        end

        local char = player.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local targetPart = gui.Adornee or gui:FindFirstAncestorWhichIsA("BasePart")

        if myRoot and targetPart then
            local distance = (myRoot.Position - targetPart.Position).Magnitude
            local isMine = gui:IsDescendantOf(char) or targetPart:IsDescendantOf(char)

            if isMine or distance <= 100 then
                local currentPos = cutter.Position.X.Scale

                -- The Perfect 0.7 Hit
                if currentPos >= 0.68 and currentPos <= 0.72 then
                    isClicking = true -- IMMEDIATE LOCK (Prevents extra M1)
                    canClick = false 

                    -- Check for Controller
                    if UIS:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
                        -- Send PS5 Circle
                        vim:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
                        task.wait(0.01)
                        vim:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game)
                    else
                        -- Send PC Click
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end

                    print("Ratio Secured! (Single Input Locked)")
                    connection:Disconnect() 
                end
            end
        end
    end)
end

workspace.DescendantAdded:Connect(function(desc)
    if desc.Name == "NanamiCutGUI" then
        handleCrit(desc)
    end
end)

print("Nanami Optimized: PS5 + Extra M1 Protection")
