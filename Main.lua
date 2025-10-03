-- This is a LocalScript that should be placed in StarterPlayerScripts or inside the ScreenGui.
-- Creates a GUI with initial animation text, then two tabs: Scripts and Others.
-- Drag functionality, toggle key (E), kill button in Others.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
-- Main frame with rounded corners
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 10)
-- Initial animation text (smaller size, more beautiful font)
local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 1, 0)
introText.Position = UDim2.new(0, 0, 0, 0)
introText.BackgroundTransparency = 1
introText.Text = "This script made by Olukt\nThanks for using."
introText.TextColor3 = Color3.fromRGB(255, 255, 255)
introText.TextSize = 18  -- Smaller text size
introText.Font = Enum.Font.SourceSansBold  -- More beautiful, clean font
introText.TextStrokeTransparency = 0.5
introText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
introText.TextXAlignment = Enum.TextXAlignment.Center
introText.TextYAlignment = Enum.TextYAlignment.Center
introText.Parent = mainFrame
introText.TextTransparency = 1
introText.TextSize = 0  -- Start from 0 for scale effect
-- Content frames (initially hidden)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -45)
contentFrame.Position = UDim2.new(0, 0, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Visible = false
contentFrame.Parent = mainFrame
-- Tab buttons frame (initially hidden)
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.Visible = false
tabFrame.Parent = mainFrame
local tabWidth = 0.5
local tabs = {"Scripts", "Others"}
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
local scriptsContent = contents["Scripts"]
local othersContent = contents["Others"]
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
-- Toggle key (E)
local currentToggleKey = Enum.KeyCode.E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == currentToggleKey then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
-- Enhanced animation sequence: fade in with scale up, pause, fade out with scale down
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local fadeInTween = TweenService:Create(introText, tweenInfo, {
    TextTransparency = 0,
    TextSize = 18
})
local fadeOutTween = TweenService:Create(introText, tweenInfo, {
    TextTransparency = 1,
    TextSize = 0
})
fadeInTween:Play()
fadeInTween.Completed:Connect(function()
    task.wait(2)
    fadeOutTween:Play()
    fadeOutTween.Completed:Connect(function()
        introText.Visible = false
        contentFrame.Visible = true
        tabFrame.Visible = true
        switchTab(tabButtons["Scripts"], scriptsContent)
    end)
end)
-- Scripts tab: Space Incremental button (closes GUI after click)
local spaceIncButton = Instance.new("TextButton")
spaceIncButton.Size = UDim2.new(0.8, 0, 0, 40)
spaceIncButton.Position = UDim2.new(0.1, 0, 0, 10)
spaceIncButton.Text = "Space Incremental"
spaceIncButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
spaceIncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spaceIncButton.BorderSizePixel = 0
spaceIncButton.TextSize = 16
spaceIncButton.Font = Enum.Font.Gotham
spaceIncButton.Parent = scriptsContent
local spaceIncCorner = Instance.new("UICorner", spaceIncButton)
spaceIncCorner.CornerRadius = UDim.new(0, 5)
spaceIncButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Olukt/Space-Incremental-/refs/heads/main/Space%20Inc.lua"))()
    screenGui:Destroy()  -- Close GUI after executing the script
end)
-- Others tab buttons
-- Dex++ button
local dexButton = Instance.new("TextButton")
dexButton.Size = UDim2.new(0.8, 0, 0, 40)
dexButton.Position = UDim2.new(0.1, 0, 0, 10)
dexButton.Text = "Dex++"
dexButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
dexButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dexButton.BorderSizePixel = 0
dexButton.TextSize = 16
dexButton.Font = Enum.Font.Gotham
dexButton.Parent = othersContent
local dexCorner = Instance.new("UICorner", dexButton)
dexCorner.CornerRadius = UDim.new(0, 5)
dexButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
end)
-- InfYield button
local infYieldButton = Instance.new("TextButton")
infYieldButton.Size = UDim2.new(0.8, 0, 0, 40)
infYieldButton.Position = UDim2.new(0.1, 0, 0, 60)
infYieldButton.Text = "InfYield"
infYieldButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
infYieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infYieldButton.BorderSizePixel = 0
infYieldButton.TextSize = 16
infYieldButton.Font = Enum.Font.Gotham
infYieldButton.Parent = othersContent
local infYieldCorner = Instance.new("UICorner", infYieldButton)
infYieldCorner.CornerRadius = UDim.new(0, 5)
infYieldButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Infinite-Yield-Free-55471"))()
end)
-- Checker button
local checkerButton = Instance.new("TextButton")
checkerButton.Size = UDim2.new(0.8, 0, 0, 40)
checkerButton.Position = UDim2.new(0.1, 0, 0, 110)
checkerButton.Text = "Checker"
checkerButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
checkerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
checkerButton.BorderSizePixel = 0
checkerButton.TextSize = 16
checkerButton.Font = Enum.Font.Gotham
checkerButton.Parent = othersContent
local checkerCorner = Instance.new("UICorner", checkerButton)
checkerCorner.CornerRadius = UDim.new(0, 5)
checkerButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/refs/heads/master/SimpleSpy.lua"))()
end)
-- Kill button in Others
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0.8, 0, 0, 40)
killButton.Position = UDim2.new(0.1, 0, 0, 160)
killButton.Text = "Kill GUI"
killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.BorderSizePixel = 0
killButton.TextSize = 16
killButton.Font = Enum.Font.Gotham
killButton.Parent = othersContent
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
tabButtons["Scripts"].MouseButton1Click:Connect(function() switchTab(tabButtons["Scripts"], scriptsContent) end)
tabButtons["Others"].MouseButton1Click:Connect(function() switchTab(tabButtons["Others"], othersContent) end)
-- Initial setup: GUI visible, start animation
mainFrame.Visible = true
