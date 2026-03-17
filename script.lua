-- Settings
local Hotkey = "t"
local HotkeyToggle = true
local HoldClick = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local RightClickHeld = false
local CurrentlyPressed = false

-- 🔍 Check if target is enemy
local function IsEnemy(character)
    local player = Players:GetPlayerFromCharacter(character)

    if player then
        return player.Team ~= LocalPlayer.Team
    end

    return false
end

-- 🎯 Raycast setup (ignores teammates)
local function GetTarget()
    local ignoreList = {LocalPlayer.Character}

    for _, player in pairs(Players:GetPlayers()) do
        if player.Team == LocalPlayer.Team and player.Character then
            table.insert(ignoreList, player.Character)
        end
    end

    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = ignoreList

    local origin = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector * 1000

    local ray = workspace:Raycast(origin, direction, RaycastParams)

    if ray and ray.Instance then
        local character = ray.Instance:FindFirstAncestorOfClass("Model")
        if character and character:FindFirstChild("Humanoid") then
            if IsEnemy(character) then
                return true
            end
        end
    end

    return false
end

-- 🔘 Hotkey toggle
Mouse.KeyDown:Connect(function(key)
    key = key:lower()

    if key == Hotkey:lower() then
        if HotkeyToggle then
            Enabled = not Enabled
            print("Autotrigger:", Enabled and "ON" or "OFF")
        else
            Enabled = true
        end
    end
end)

Mouse.KeyUp:Connect(function(key)
    key = key:lower()

    if not HotkeyToggle and key == Hotkey:lower() then
        Enabled = false
    end
end)

-- 🖱 Right click detect (scope)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false

        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)

-- 🔄 Main loop
RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        if GetTarget() then
            if HoldClick then
                if not CurrentlyPressed then
                    CurrentlyPressed = true
                    mouse1press()
                end
            else
                mouse1click()
            end
        else
            if HoldClick and CurrentlyPressed then
                CurrentlyPressed = false
                mouse1release()
            end
        end
    else
        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)
