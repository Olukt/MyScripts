-- This is a LocalScript that should be placed in StarterPlayerScripts or inside the ScreenGui.
-- Creates a GUI with tabs and toggle switches for auto-buying upgrades.
-- Uses FireServer events for all upgrade tabs, analogous to Crystal Upgrade.
-- Assumes events like Upgrade, Perks, Gems, AtomUpgrade, NuclearUpgrade, CrystalUpgrade with args (index, buyMax).
-- For Upgrade: buyMax = false (as per example)
-- For Atoms: buyMax = true (as per example)
-- For others: buyMax = true (analogous to Crystal Upgrade)
-- Auto tab remains with special logic.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local objectsFolder = Workspace:WaitForChild("Objects")
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoUpgradeGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
-- Main frame with rounded corners and gradient
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 10)
-- Content frames
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -45)
contentFrame.Position = UDim2.new(0, 0, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame
-- Tab buttons frame
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame
local tabWidth = 1/8
local tabs = {"Upgrade", "Perks", "Gems", "Atoms", "Nuclear", "Auto", "Crystal Upgrade", "Settings"}
local tabButtons = {}
local contents = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(tabWidth, 0, 1, 0)
    tabButton.Position = UDim2.new((i-1)*tabWidth, 0, 0, 0)
    tabButton.Text = tabName
    tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.BorderSizePixel = 0
    tabButton.TextScaled = true
    tabButton.Parent = tabFrame
    local corner = Instance.new("UICorner", tabButton)
    corner.CornerRadius = UDim.new(0, 5)
    tabButtons[tabName] = tabButton
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 8
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = contentFrame
    content.Visible = (i == 1)
    contents[tabName] = content
end
local upgradeContent = contents["Upgrade"]
local perksContent = contents["Perks"]
local gemsContent = contents["Gems"]
local atomsContent = contents["Atoms"]
local nuclearContent = contents["Nuclear"]
local autoContent = contents["Auto"]
local crystalContent = contents["Crystal Upgrade"]
local settingsContent = contents["Settings"]
-- Drag functionality
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
-- Function to create a toggle switch with better styling
local function createToggle(name, parent, position, eventName, index, buyMax, isAutoSpecial)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.Position = position
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    local switchFrame = Instance.new("Frame", toggleFrame)
    switchFrame.Size = UDim2.new(0.15, 0, 0.6, 0)
    switchFrame.Position = UDim2.new(0.85, 0, 0.2, 0)
    switchFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    switchFrame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", switchFrame)
    corner.CornerRadius = UDim.new(0.5, 0)
    local knob = Instance.new("Frame", switchFrame)
    knob.Size = UDim2.new(0.5, 0, 1, 0)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0.5, 0)
    local state = false
    local autoThread = nil
    local connection = nil
    local function toggle()
        state = not state
        local goalPos = state and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(knob, tweenInfo, {Position = goalPos})
        tween:Play()
        switchFrame.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 80)
        if state then
            if eventName and index then
                autoThread = task.spawn(function()
                    while state do
                        local args = {
                            [1] = index,
                            [2] = buyMax
                        }
                        ReplicatedStorage.Events[eventName]:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end)
            elseif isAutoSpecial == "collect" then
                connection = RunService.Heartbeat:Connect(function()
                    for _, obj in ipairs(objectsFolder:GetChildren()) do
                        if obj:IsA("BasePart") and tonumber(obj.Name) then
                            obj.Position = rootPart.Position
                        end
                    end
                end)
            elseif isAutoSpecial == "machine" then
                autoThread = task.spawn(function()
                    while state do
                        ReplicatedStorage.Events.MachinePower:FireServer()
                        task.wait(0.1)
                    end
                end)
            end
        else
            if autoThread then task.cancel(autoThread) autoThread = nil end
            if connection then connection:Disconnect() connection = nil end
        end
    end
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
    end)
    return toggleFrame
end
-- Upgrades tab toggles (event: Upgrade, buyMax = false as per example)
createToggle("Essence", upgradeContent, UDim2.new(0, 0, 0, 0), "Upgrade", 1, false)
createToggle("Faster Spawn", upgradeContent, UDim2.new(0, 0, 0, 40), "Upgrade", 2, false)
createToggle("Capacity", upgradeContent, UDim2.new(0, 0, 0, 80), "Upgrade", 3, false)
createToggle("More XP Essence", upgradeContent, UDim2.new(0, 0, 0, 120), "Upgrade", 4, false)
-- Perks tab toggles (event: Perks, buyMax = true analogous to Crystal)
createToggle("Essence", perksContent, UDim2.new(0, 0, 0, 0), "Perks", 1, true)
createToggle("Faster Spawn", perksContent, UDim2.new(0, 0, 0, 40), "Perks", 2, true)
createToggle("Walkspeed", perksContent, UDim2.new(0, 0, 0, 80), "Perks", 3, true)
createToggle("Radius", perksContent, UDim2.new(0, 0, 0, 120), "Perks", 4, true)
createToggle("Essence2", perksContent, UDim2.new(0, 0, 0, 160), "Perks", 5, true)
createToggle("Double", perksContent, UDim2.new(0, 0, 0, 200), "Perks", 6, true)
local perksExpansionLabel = Instance.new("TextLabel", perksContent)
perksExpansionLabel.Size = UDim2.new(1, 0, 0, 20)
perksExpansionLabel.Position = UDim2.new(0, 0, 0, 240)
perksExpansionLabel.Text = "PerksExpansion"
perksExpansionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
perksExpansionLabel.BackgroundTransparency = 1
perksExpansionLabel.TextSize = 14
perksExpansionLabel.Font = Enum.Font.Gotham
createToggle("Steel", perksContent, UDim2.new(0, 0, 0, 260), "Perks", 7, true)
createToggle("TierXP", perksContent, UDim2.new(0, 0, 0, 300), "Perks", 8, true)
createToggle("XP", perksContent, UDim2.new(0, 0, 0, 340), "Perks", 9, true)
createToggle("Energy", perksContent, UDim2.new(0, 0, 0, 380), "Perks", 10, true)
-- Gems tab toggles (event: Gems, buyMax = true)
createToggle("Gem Chance", gemsContent, UDim2.new(0, 0, 0, 0), "Gems", 1, true)
createToggle("Essence", gemsContent, UDim2.new(0, 0, 0, 40), "Gems", 2, true)
createToggle("XP", gemsContent, UDim2.new(0, 0, 0, 80), "Gems", 3, true)
createToggle("Tier XP", gemsContent, UDim2.new(0, 0, 0, 120), "Gems", 4, true)
local extraGemLabel = Instance.new("TextLabel", gemsContent)
extraGemLabel.Size = UDim2.new(1, 0, 0, 20)
extraGemLabel.Position = UDim2.new(0, 0, 0, 160)
extraGemLabel.Text = "ExtraGem"
extraGemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
extraGemLabel.BackgroundTransparency = 1
extraGemLabel.TextSize = 14
extraGemLabel.Font = Enum.Font.Gotham
createToggle("Gem Tier", gemsContent, UDim2.new(0, 0, 0, 180), "Gems", 5, true)
createToggle("Nuclear", gemsContent, UDim2.new(0, 0, 0, 220), "Gems", 6, true)
createToggle("MoreXP2", gemsContent, UDim2.new(0, 0, 0, 260), "Gems", 7, true)
-- Atoms tab toggles (event: AtomUpgrade, buyMax = true as per example)
createToggle("Atom", atomsContent, UDim2.new(0, 0, 0, 0), "AtomUpgrade", 1, true)
createToggle("Essence", atomsContent, UDim2.new(0, 0, 0, 40), "AtomUpgrade", 2, true)
createToggle("XP", atomsContent, UDim2.new(0, 0, 0, 80), "AtomUpgrade", 3, true)
createToggle("Gems", atomsContent, UDim2.new(0, 0, 0, 120), "AtomUpgrade", 4, true)
createToggle("Cap", atomsContent, UDim2.new(0, 0, 0, 160), "AtomUpgrade", 5, true)
createToggle("Range", atomsContent, UDim2.new(0, 0, 0, 200), "AtomUpgrade", 6, true)
-- Nuclear tab toggles (event: NuclearUpgrade, buyMax = true)
createToggle("Nuclear", nuclearContent, UDim2.new(0, 0, 0, 0), "NuclearUpgrade", 1, true)
createToggle("Essence", nuclearContent, UDim2.new(0, 0, 0, 40), "NuclearUpgrade", 2, true)
createToggle("TierXp", nuclearContent, UDim2.new(0, 0, 0, 80), "NuclearUpgrade", 3, true)
createToggle("Atom", nuclearContent, UDim2.new(0, 0, 0, 120), "NuclearUpgrade", 4, true)
createToggle("Level Perks", nuclearContent, UDim2.new(0, 0, 0, 160), "NuclearUpgrade", 5, true)
createToggle("Gem Upgrade", nuclearContent, UDim2.new(0, 0, 0, 200), "NuclearUpgrade", 6, true)
-- Crystal Upgrade tab toggles (unchanged, event: CrystalUpgrade, buyMax = true)
createToggle("Essence", crystalContent, UDim2.new(0, 0, 0, 0), "CrystalUpgrade", 1, true)
createToggle("XP", crystalContent, UDim2.new(0, 0, 0, 40), "CrystalUpgrade", 2, true)
createToggle("TierXP", crystalContent, UDim2.new(0, 0, 0, 80), "CrystalUpgrade", 3, true)
createToggle("Crystal", crystalContent, UDim2.new(0, 0, 0, 120), "CrystalUpgrade", 4, true)
createToggle("Nuclear", crystalContent, UDim2.new(0, 0, 0, 160), "CrystalUpgrade", 5, true)
createToggle("Energy", crystalContent, UDim2.new(0, 0, 0, 200), "CrystalUpgrade", 6, true)
createToggle("CreationXP", crystalContent, UDim2.new(0, 0, 0, 240), "CrystalUpgrade", 7, true)
-- Auto tab toggles (special logic, unchanged)
createToggle("AutoCollect", autoContent, UDim2.new(0, 0, 0, 0), nil, nil, nil, "collect")
createToggle("AutoElMachine", autoContent, UDim2.new(0, 0, 0, 40), nil, nil, nil, "machine")
-- Settings tab
local toggleKeyLabel = Instance.new("TextLabel")
toggleKeyLabel.Size = UDim2.new(0.5, 0, 0, 40)
toggleKeyLabel.Position = UDim2.new(0, 10, 0, 10)
toggleKeyLabel.Text = "Toggle Key:"
toggleKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleKeyLabel.BackgroundTransparency = 1
toggleKeyLabel.TextSize = 16
toggleKeyLabel.Font = Enum.Font.Gotham
toggleKeyLabel.Parent = settingsContent
local toggleKeyBox = Instance.new("TextBox")
toggleKeyBox.Size = UDim2.new(0.4, 0, 0, 30)
toggleKeyBox.Position = UDim2.new(0.5, 0, 0, 15)
toggleKeyBox.Text = "E"
toggleKeyBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleKeyBox.BorderSizePixel = 0
toggleKeyBox.Parent = settingsContent
local boxCorner = Instance.new("UICorner", toggleKeyBox)
boxCorner.CornerRadius = UDim.new(0, 5)
local currentToggleKey = Enum.KeyCode.E
local function updateToggleKey()
    local keyName = toggleKeyBox.Text:upper()
    local success, keyCode = pcall(function() return Enum.KeyCode[keyName] end)
    if success and keyCode then
        currentToggleKey = keyCode
    else
        toggleKeyBox.Text = "Invalid"
        task.wait(1)
        toggleKeyBox.Text = "E"
    end
end
toggleKeyBox.FocusLost:Connect(updateToggleKey)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == currentToggleKey then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
-- Kill button in Settings
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0.8, 0, 0, 40)
killButton.Position = UDim2.new(0.1, 0, 0, 60)
killButton.Text = "Kill GUI"
killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.BorderSizePixel = 0
killButton.TextSize = 16
killButton.Font = Enum.Font.Gotham
killButton.Parent = settingsContent
local killCorner = Instance.new("UICorner", killButton)
killCorner.CornerRadius = UDim.new(0, 5)
killButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
-- Tab switching function
local function switchTab(selectedButton, selectedContent)
    for _, content in pairs(contents) do content.Visible = false end
    selectedContent.Visible = true
    for _, button in pairs(tabButtons) do button.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
    selectedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end
tabButtons["Upgrade"].MouseButton1Click:Connect(function() switchTab(tabButtons["Upgrade"], upgradeContent) end)
tabButtons["Perks"].MouseButton1Click:Connect(function() switchTab(tabButtons["Perks"], perksContent) end)
tabButtons["Gems"].MouseButton1Click:Connect(function() switchTab(tabButtons["Gems"], gemsContent) end)
tabButtons["Atoms"].MouseButton1Click:Connect(function() switchTab(tabButtons["Atoms"], atomsContent) end)
tabButtons["Nuclear"].MouseButton1Click:Connect(function() switchTab(tabButtons["Nuclear"], nuclearContent) end)
tabButtons["Auto"].MouseButton1Click:Connect(function() switchTab(tabButtons["Auto"], autoContent) end)
tabButtons["Crystal Upgrade"].MouseButton1Click:Connect(function() switchTab(tabButtons["Crystal Upgrade"], crystalContent) end)
tabButtons["Settings"].MouseButton1Click:Connect(function() switchTab(tabButtons["Settings"], settingsContent) end)
-- Initial tab
switchTab(tabButtons["Upgrade"], upgradeContent)
