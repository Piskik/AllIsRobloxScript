-- ====================================================================
-- FINAL FIXED DEV-SOFT SUITE (INFINITE YIELD STYLE) - 100% STABLE
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Дефолтные настройки физики
local flySpeed = 50
local normalSpeed = 16
local normalJump = 50

-- Состояния (флаги)
local states = {
    Fly = false,
    Noclip = false,
    InfJump = false,
    Wallhop = false,
    InfSpeed = false
}

-- Таблица горячих клавиш (Keybinds)
local HOTKEYS = {
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    InfJump = Enum.KeyCode.J,
    Wallhop = Enum.KeyCode.H,
    InfSpeed = Enum.KeyCode.G
}

-- Имена для вывода на экран
local FEATURE_NAMES = {
    Fly = "Fly (Полет)",
    Noclip = "Noclip (Стены)",
    InfJump = "Inf Jump (Прыжки)",
    Wallhop = "Wallhop (От стен)",
    InfSpeed = "Inf Speed (Бег)"
}

-- Создание интерфейса (Core UI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfiniteDevSoftSuite"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- СУПЕРСТАБИЛЬНАЯ ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ (Поддерживает ПК и Телефоны)
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Кнопка Свернуть/Развернуть софт
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 120, 0, 35)
toggleMenuBtn.Position = UDim2.new(0, 15, 0.1, -45)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Text = "📁 СКРЫТЬ СОФТ"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Parent = screenGui
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 6)
makeDraggable(toggleMenuBtn)

-- Главный контейнер софта
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 560)
mainFrame.Position = UDim2.new(0, 15, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
makeDraggable(mainFrame)

-- Заголовок панели
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "⚡ INFINITE DEV-SOFT v3.2 ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- ЦЕНТРАЛЬНОЕ / ГЛАВНОЕ МЕНЮ БЫСТРЫХ КНОПОК
local quickActionsFrame = Instance.new("Frame")
quickActionsFrame.Size = UDim2.new(0, 160, 0, 250)
quickActionsFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
quickActionsFrame.BackgroundTransparency = 0.5
quickActionsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
quickActionsFrame.Parent = screenGui
Instance.new("UICorner", quickActionsFrame).CornerRadius = UDim.new(0, 6)
makeDraggable(quickActionsFrame)

local quickTitle = Instance.new("TextLabel")
quickTitle.Size = UDim2.new(1, 0, 0, 25)
quickTitle.Text = "📌 ГЛАВНЫЙ ЭКРАН"
quickTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
quickTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
quickTitle.Font = Enum.Font.SourceSansBold
quickTitle.TextSize = 11
quickTitle.Parent = quickActionsFrame
Instance.new("UICorner", quickTitle).CornerRadius = UDim.new(0, 6)

local quickPadding = Instance.new("UIPadding")
quickPadding.PaddingTop = UDim.new(0, 30)
quickPadding.PaddingLeft = UDim.new(0, 5)
quickPadding.PaddingRight = UDim.new(0, 5)
quickPadding.Parent = quickActionsFrame

local quickLayout = Instance.new("UIListLayout")
quickLayout.Padding = UDim.new(0, 5)
quickLayout.Parent = quickActionsFrame

-- Мобильный интерфейс для Fly (Вверх / Вниз)
local mobileFlyControls = Instance.new("Frame")
mobileFlyControls.Size = UDim2.new(0, 70, 0, 140)
mobileFlyControls.Position = UDim2.new(0.85, 0, 0.4, 0)
mobileFlyControls.BackgroundTransparency = 1
mobileFlyControls.Visible = false
mobileFlyControls.Parent = screenGui

local function createMobileFlyBtn(text, posPercentY)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 45)
    b.Position = UDim2.new(0, 0, posPercentY, 0)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.4
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.Parent = mobileFlyControls
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end
local mobileUp = createMobileFlyBtn("▲ ВВЕРХ", 0)
local mobileDown = createMobileFlyBtn("▼ ВНИЗ", 0.4)

local function getHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleMenuBtn.Text = mainFrame.Visible and "📁 СКРЫТЬ СОФТ" or "📂 ОТКРЫТЬ СОФТ"
    toggleMenuBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(40, 160, 80)
end)

-- Исправленное обновление виджетов без вылетов
local function updateQuickWidget(actionName)
    local widget = quickActionsFrame:FindFirstChild(actionName .. "_Quick")
    if widget then
        local active = states[actionName]
        local keyName = HOTKEYS[actionName] and HOTKEYS[actionName].Name or "NONE"
        widget.Text = FEATURE_NAMES[actionName] .. " [" .. keyName .. "]: " .. (active and "ON" or "OFF")
        widget.BackgroundColor3 = active and Color3.fromRGB(45, 100, 45) or Color3.fromRGB(40, 40, 40)
        widget.TextColor3 = active and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(240, 80, 80)
    end
end

local mainButtons = {}
local keybindButtons = {}
local bindingAction = nil

local function createFeatureRow(actionName, positionY)
    local button = Instance.new("TextButton")
    button.Name = actionName .. "MainBtn"
    button.Size = UDim2.new(0, 145, 0, 35)
    button.Position = UDim2.new(0, 10, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(240, 80, 80)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 13
    button.Text = FEATURE_NAMES[actionName] .. ": OFF"
    button.Parent = mainFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    mainButtons[actionName] = button

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 45, 0, 35)
    bindBtn.Position = UDim2.new(0, 160, 0, positionY)
    bindBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Text = HOTKEYS[actionName] and HOTKEYS[actionName].Name or "NONE"
    bindBtn.Font = Enum.Font.SourceSans
    bindBtn.TextSize = 11
    bindBtn.Parent = mainFrame
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)
    keybindButtons[actionName] = bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        bindingAction = actionName
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 0)
    end)

    local pin = Instance.new("TextButton")
    pin.Size = UDim2.new(0, 30, 0, 35)
    pin.Position = UDim2.new(0, 210, 0, positionY)
    pin.Text = "⭐"
    pin.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pin.TextColor3 = Color3.fromRGB(255, 255, 255)
    pin.TextSize = 13
    pin.Parent = mainFrame
    Instance.new("UICorner", pin).CornerRadius = UDim.new(0, 5)

    pin.MouseButton1Click:Connect(function()
        local quickName = actionName .. "_Quick"
        if quickActionsFrame:FindFirstChild(quickName) then
            quickActionsFrame:FindFirstChild(quickName):Destroy()
        else
            local quickBtn = Instance.new("TextButton")
            quickBtn.Name = quickName
            quickBtn.Size = UDim2.new(1, 0, 0, 32)
            quickBtn.Font = Enum.Font.SourceSansBold
            quickBtn.TextSize = 11
            quickBtn.Parent = quickActionsFrame
            Instance.new("UICorner", quickBtn).CornerRadius = UDim.new(0, 5)
            
            -- Первичная отрисовка
            local active = states[actionName]
            local keyName = HOTKEYS[actionName] and HOTKEYS[actionName].Name or "NONE"
            quickBtn.Text = FEATURE_NAMES[actionName] .. " [" .. keyName .. "]: " .. (active and "ON" or "OFF")
            quickBtn.BackgroundColor3 = active and Color3.fromRGB(45, 100, 45) or Color3.fromRGB(40, 40, 40)
