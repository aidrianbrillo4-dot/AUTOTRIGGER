-- Settings
local HoldClick = true
local Hotkey = "t" -- Leave blank for always on
local HotkeyToggle = true -- true = press once to toggle on/off, false = hold key

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local RightClickHeld = false
local Toggle = (Hotkey == "")
local CurrentlyPressed = false

-- Hotkey handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Right click hold
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end

    -- Keyboard toggle
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name:lower()

        if key == Hotkey:lower() and Hotkey ~= "" then
            if HotkeyToggle then
                Toggle = not Toggle
            else
                Toggle = true
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    -- Right click release
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false

        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end

    -- Keyboard hold release
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name:lower()

        if not HotkeyToggle and key == Hotkey:lower() and Hotkey ~= "" then
            Toggle = false

            if HoldClick and CurrentlyPressed then
                CurrentlyPressed = false
                mouse1release()
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Toggle and RightClickHeld then
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
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
