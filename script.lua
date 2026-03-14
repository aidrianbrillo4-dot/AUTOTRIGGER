-- Settings
local HoldClick = true
local Hotkey = "t"
local HotkeyToggle = true
local TriggerDelay = 0.1 -- delay before shooting

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Target validation functions
local function getCharacterFromTarget(target)
	if not target then
		return nil
	end
	return target:FindFirstAncestorOfClass("Model")
end

local function getPlayerFromTarget(target)
	local character = getCharacterFromTarget(target)
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function hasHumanoid(target)
	local character = getCharacterFromTarget(target)
	return character and character:FindFirstChild("Humanoid") ~= nil
end

local function isTeammate(target)
	local targetPlayer = getPlayerFromTarget(target)
	if not targetPlayer then
		return false
	end
	return targetPlayer.Team == LocalPlayer.Team
end

local function isEnemyTarget(target)
	if not target then
		return false
	end
	if not hasHumanoid(target) then
		return false
	end
	if isTeammate(target) then
		return false
	end
	return true
end

local Enabled = false
local RightClickHeld = false
local CurrentlyPressed = false
local Waiting = false

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

RunService.RenderStepped:Connect(function()
	if Enabled and RightClickHeld then
		if Mouse.Target and isEnemyTarget(Mouse.Target) then
			-- Valid enemy target
			
			if HoldClick then
				if not CurrentlyPressed and not Waiting then
					Waiting = true
					
					task.spawn(function()
						task.wait(TriggerDelay)
						if Enabled and RightClickHeld then
							CurrentlyPressed = true
							mouse1press()
						end
						Waiting = false
					end)
				end
			else
				mouse1click()
			end
		else
			-- Invalid target or no target
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
