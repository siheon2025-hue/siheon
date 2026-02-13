-- All In One Ultimate GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	return getCharacter():WaitForChild("Humanoid")
end

local function getRoot()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

-- 상태값
local tpEnabled = false
local speedOn = false
local jumpOn = false
local nightOn = false
local espEnabled = false

local pendingPosition = nil
local marker = nil
local espObjects = {}

-- ===== GUI =====
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 360)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(25,25,25)
title.TextColor3 = Color3.new(1,1,1)
title.Text = "All In One Panel"
Instance.new("UICorner", title).CornerRadius = UDim.new(0,12)

local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1,0,0,20)
credit.Position = UDim2.new(0,0,0,30)
credit.BackgroundTransparency = 1
credit.TextColor3 = Color3.fromRGB(170,170,170)
credit.TextScaled = true
credit.Text = "Developed by siheon_01"

local function makeButton(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.8,0,0,35)
	b.Position = UDim2.new(0.1,0,y,0)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local tpBtn    = makeButton("TP OFF",0.18,Color3.fromRGB(100,100,255))
local speedBtn = makeButton("Speed OFF",0.30,Color3.fromRGB(80,160,255))
local jumpBtn  = makeButton("Jump OFF",0.42,Color3.fromRGB(80,255,120))
local nightBtn = makeButton("Night OFF",0.54,Color3.fromRGB(150,150,255))
local espBtn   = makeButton("위치 확인 끔",0.66,Color3.fromRGB(0,170,255))

-- ===== 기능 =====

tpBtn.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	tpBtn.Text = tpEnabled and "TP ON" or "TP OFF"
end)

speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	getHumanoid().WalkSpeed = speedOn and 32 or 16
	speedBtn.Text = speedOn and "Speed ON" or "Speed OFF"
end)

jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	getHumanoid().JumpPower = jumpOn and 100 or 50
	jumpBtn.Text = jumpOn and "Jump ON" or "Jump OFF"
end)

nightBtn.MouseButton1Click:Connect(function()
	nightOn = not nightOn
	Lighting.ClockTime = nightOn and 0 or 14
	nightBtn.Text = nightOn and "Night ON" or "Night OFF"
end)

-- ===== ESP =====

local function addESP(plr)
	if plr == player then return end
	if not plr.Character then return end
	if espObjects[plr] then return end

	local char = plr.Character
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local head = char:FindFirstChild("Head")
	if not humanoid or not head then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.FillTransparency = 0.5
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = char
	highlight.Parent = char

	local bb = Instance.new("BillboardGui")
	bb.Adornee = head
	bb.AlwaysOnTop = true
	bb.MaxDistance = 0
	bb.Size = UDim2.fromOffset(120,14)
	bb.StudsOffset = Vector3.new(0,2.8,0)
	bb.Parent = head

	local bg = Instance.new("Frame", bb)
	bg.Size = UDim2.fromScale(1,1)
	bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0,6)

	local bar = Instance.new("Frame", bg)
	bar.Size = UDim2.fromScale(1,1)
	bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

	local function update()
		bar.Size = UDim2.fromScale(
			math.clamp(humanoid.Health/humanoid.MaxHealth,0,1),
			1
		)
	end

	update()
	humanoid.HealthChanged:Connect(update)

	espObjects[plr] = {highlight, bb}
end

local function removeAllESP()
	for _, objs in pairs(espObjects) do
		for _, obj in ipairs(objs) do
			if obj then obj:Destroy() end
		end
	end
	table.clear(espObjects)
end

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "위치 확인 킴" or "위치 확인 끔"

	if espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			addESP(plr)
		end
	else
		removeAllESP()
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		if espEnabled then
			task.wait(0.5)
			addESP(plr)
		end
	end)
end)

-- ===== TP 시스템 =====

local confirmFrame = Instance.new("Frame", gui)
confirmFrame.Size = UDim2.new(0, 300, 0, 150)
confirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
confirmFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
confirmFrame.Visible = false
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0,12)

local confirmText = Instance.new("TextLabel", confirmFrame)
confirmText.Size = UDim2.new(1,0,0.4,0)
confirmText.BackgroundTransparency = 1
confirmText.TextColor3 = Color3.new(1,1,1)
confirmText.TextScaled = true
confirmText.Text = "정말로 이동하시겠습니까?"

local coordLabel = Instance.new("TextLabel", confirmFrame)
coordLabel.Size = UDim2.new(1,0,0.2,0)
coordLabel.Position = UDim2.new(0,0,0.4,0)
coordLabel.BackgroundTransparency = 1
coordLabel.TextColor3 = Color3.fromRGB(200,200,200)
coordLabel.TextScaled = true

local yesBtn = makeButton("네",0.65,Color3.fromRGB(80,200,120))
yesBtn.Parent = confirmFrame
yesBtn.Position = UDim2.new(0.1,0,0.65,0)

local noBtn = makeButton("아니요",0.65,Color3.fromRGB(200,80,80))
noBtn.Parent = confirmFrame
noBtn.Position = UDim2.new(0.55,0,0.65,0)

local function teleport(pos)
	getRoot().CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

UserInputService.TouchTap:Connect(function(touchPositions, processed)
	if processed or not tpEnabled then return end

	local pos = touchPositions[1]
	if not pos then return end

	local ray = camera:ScreenPointToRay(pos.X, pos.Y)
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)

	if result then
		pendingPosition = result.Position

		coordLabel.Text = string.format(
			"X: %.1f Y: %.1f Z: %.1f",
			pendingPosition.X,
			pendingPosition.Y,
			pendingPosition.Z
		)

		confirmFrame.Visible = true
	end
end)

yesBtn.MouseButton1Click:Connect(function()
	if pendingPosition then
		teleport(pendingPosition)
	end
	confirmFrame.Visible = false
end)

noBtn.MouseButton1Click:Connect(function()
	confirmFrame.Visible = false
end)
