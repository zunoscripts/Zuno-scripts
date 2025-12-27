local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuration
local LOCK_KEY = Enum.KeyCode.LeftControl
local locked = false
local target = nil

-- Force the game to allow selection logic (The "Controller Fix")
GuiService.AutoSelectGuiEnabled = true

-- This function mimics the game's internal 'gettarget' logic found in playergui.txt
local function findTarget()
    local children = game.Workspace.Live:GetChildren()
    local bestTarget = nil
    local minDistance = 0.4 -- Matches the game's internal threshold 

    for _, v in pairs(children) do
        if v:IsA("Model") and v.Name ~= player.Name and v:FindFirstChild("HumanoidRootPart") then
            local hrp = v.HumanoidRootPart
            local humanoid = v:FindFirstChild("Humanoid")
            
            -- Check if target is alive and visible 
            if humanoid and humanoid.Health > 0 and v:FindFirstChild("Torso") and v.Torso.Transparency ~= 1 then
                -- Direction math found in your script 
                local lookVec = (CFrame.new(camera.CFrame.p, hrp.Position).lookVector - camera.CFrame.lookVector).magnitude
                
                if lookVec < minDistance then
                    bestTarget = v
                end
            end
        end
    end
    return bestTarget
end

-- Toggle Logic
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == LOCK_KEY then
        if not locked then
            target = findTarget()
            if target then
                locked = true
                print("Locked onto: " .. target.Name)
            end
        else
            locked = false
            target = nil
            print("Lock Released")
        end
    end
end)

-- Camera Tracking
RunService.RenderStepped:Connect(function()
    if locked and target and target:FindFirstChild("HumanoidRootPart") then
        if target.Humanoid.Health <= 0 then
            locked = false
            target = nil
            return
        end
        
        -- Smoothly point camera at target
        local targetPos = target.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end)
