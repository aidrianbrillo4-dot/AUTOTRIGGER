-- Settings
local HoldClick = true
local Hotkey = "x"
local HotkeyToggle = true

-- SCOPE DELAY SETTINGS
local ScopeDelay = 0.15 -- Delay in seconds after scoping (0 = instant)
local ScopedIn = false
local ScopeDelayTime = 0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local RightClickHeld = false
local CurrentlyPressed = false

-- Hotkey handling
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

-- Right click (scope) handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightClickHeld = true
		ScopedIn = true
		ScopeDelayTime = tick()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightClickHeld = false
		ScopedIn = false
		if HoldClick and CurrentlyPressed then
			CurrentlyPressed = false
			mouse1release()
		end
	end
end)

-- Main render loop
RunService.RenderStepped:Connect(function()
	local delayPassed = (tick() - ScopeDelayTime) >= ScopeDelay
	
	local target = Mouse.Target
	local character = target and target:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	local hasValidTarget = 
		Enabled 
		and RightClickHeld 
		and ScopedIn 
		and delayPassed 
		and target 
		and humanoid 
		and humanoid.Health > 0

	if hasValidTarget then
		if not CurrentlyPressed then
			CurrentlyPressed = true
			mouse1press()
		end
	else
		if HoldClick and CurrentlyPressed then
			CurrentlyPressed = false
			mouse1release()
		end
	end
end)
