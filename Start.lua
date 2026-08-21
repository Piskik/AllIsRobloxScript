-- Сервисы игры
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки по умолчанию
local flySpeed = 50
local normalSpeed = 16
local normalJump = 50

-- Переменные состояний (флаги)
local isFlying = false
local isNoclip = false
local isInfJump = false
local isWallhopEnabled = false

-- Горячие клавиши для ПК (теперь их можно менять)
local HOTKEYS = {
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    InfJump = Enum.KeyCode.J,
    Wallhop = Enum.KeyCode.H
}

-- Создание UI (Главная панель)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevAdminPanelUltimate"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Кнопка Свернуть/Развернуть меню (Всегда видна и ее можно двигать)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 110, 0, 35)
toggleMenuBtn.Position = UDim2.new(0, 15, 0.1, -40)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Text = "📁 СКРЫТЬ МЕНЮ"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 14
toggleMenuBtn.Active = true
toggleMenuBtn.Draggable = true -- Кнопку открытия/закрытия тоже можно двигать
toggleMenuBtn.Parent = screenGui
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 6)

-- Основной контейнер для меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 500)
mainFrame.Position = UDim2.new(0, 15, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Меню можно свободно перетаскивать пальцем/мышкой
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Заголовок меню
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "DEV PANEL v2.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Логика скрытия/показа меню
toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        toggleMenuBtn.Text = "📁 СКРЫТЬ МЕНЮ"
        toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    else
        toggleMenuBtn.Text = "📂 ОТКРЫТЬ МЕНЮ"
        toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    end
end)

-- Панель быстрых кнопок на главном экране (Её можно перетаскивать отдельно!)
local quickActionsFrame = Instance.new("Frame")
quickActionsFrame.Size = UDim2.new(0, 140, 0, 200)
quickActionsFrame.Position = UDim2.new(0, 15, 0.5, 0) -- По умолчанию снизу слева
quickActionsFrame.BackgroundTransparency = 1
quickActionsFrame.Active = true
quickActionsFrame.Draggable = true -- Перетаскивайте быстрые кнопки куда угодно!
quickActionsFrame.Parent = screenGui

local quickLayout = Instance.new("UIListLayout")
quickLayout.Padding = UDim.new(0, 5)
quickLayout.Parent = quickActionsFrame

-- Мобильный интерфейс управления Fly
local mobileFlyControls = Instance.new("Frame")
mobileFlyControls.Size = UDim2.new(0, 70, 0, 150)
mobileFlyControls.Position = UDim2.new(0.85, 0, 0.4, 0)
mobileFlyControls.BackgroundTransparency = 1
mobileFlyControls.Visible = false
mobileFlyControls.Parent = screenGui

local function getHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

-- Переменные для отслеживания изменения клавиш
local bindingAction = nil
local keybindButtons = {}

-- Функция обновления быстрого виджета
local function updateQuickActionWidget(actionName, text, state, hotkeyEnum)
    local quickBtn = quickActionsFrame:FindFirstChild(actionName .. "_Quick")
    if quickBtn then
        local keyText = hotkeyEnum and (" ["..hotkeyEnum.Name.."]") or ""
        if state then
            quickBtn.Text = text .. keyText .. ": ON"
            quickBtn.BackgroundColor3 = Color3.fromRGB(45, 100, 45)
            quickBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            quickBtn.Text = text .. keyText .. ": OFF"
            quickBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            quickBtn.TextColor3 = Color3.fromRGB(240, 80, 80)
        end
    end
end

-- Универсальная функция создания кнопок управления функциями
local function createFeatureRow(actionName, text, positionY)
    -- Основная кнопка переключения лимита физики
    local button = Instance.new("TextButton")
    button.Name = actionName .. "Btn"
    button.Size = UDim2.new(0, 140, 0, 35)
    button.Position = UDim2.new(0, 10, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(240, 80, 80)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 13
    button.Text = text .. ": OFF"
    button.Parent = mainFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)

    -- Кнопка смены горячей клавиши (Keybind)
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 40, 0, 35)
    bindBtn.Position = UDim2.new(0, 155, 0, positionY)
    bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Text = HOTKEYS[actionName] and HOTKEYS[actionName].Name or "NONE"
    bindBtn.Font = Enum.Font.SourceSans
    bindBtn.TextSize = 12
    bindBtn.Parent = mainFrame
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)
    keybindButtons[actionName] = bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        bindingAction = actionName
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 0)
    end)

    -- Кнопка быстрого вывода на главный экран (Звездочка ⭐)
    local pin = Instance.new("TextButton")
    pin.Size = UDim2.new(0, 30, 0, 35)
    pin.Position = UDim2.new(0, 200, 0, positionY)
    pin.Text = "⭐"
    pin.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pin.TextSize = 14
    pin.Parent = mainFrame
    Instance.new("UICorner", pin).CornerRadius = UDim.new(0, 5)

    pin.MouseButton1Click:Connect(function()
        local quickName = actionName .. "_Quick"
        if quickActionsFrame:FindFirstChild(quickName) then
            quickActionsFrame:FindFirstChild(quickName):Destroy()
        else
            local quickBtn = Instance.new("TextButton")
            quickBtn.Name = quickName
            quickBtn.Size = UDim2.new(0, 140, 0, 35)
            quickBtn.Font = Enum.Font.SourceSansBold
            quickBtn.TextSize = 12
            quickBtn.Parent = quickActionsFrame
            Instance.new("UICorner", quickBtn).CornerRadius = UDim.new(0, 5)
            
            -- Получаем текущее состояние флага динамически
            local currentState = false
            if actionName == "Fly" then currentState = isFlying
            elseif actionName == "Noclip" then currentState = isNoclip
            elseif actionName == "InfJump" then currentState = isInfJump
            elseif actionName == "Wallhop" then currentState = isWallhopEnabled end
            
            updateQuickActionWidget(actionName, text, currentState, HOTKEYS[actionName])
            
            quickBtn.MouseButton1Click:Connect(function()
                button:Click() -- Нажатие по кнопке быстрого доступа активирует основную
            end)
        end
    end)

    return button
end

-- Обновление стилей основного меню
local function updateButtonVisual(button, actionName, text, state)
    if state then
        button.Text = text .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(45, 100, 45)
        button.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.TextColor3 = Color3.fromRGB(240, 80, 80)
    end
    updateQuickActionWidget(actionName, text, state, HOTKEYS[actionName])
end

-- Создаем ряды функций
local flyBtn = createFeatureRow("Fly", "Fly (Полет)", 50)
local noclipBtn = createFeatureRow("Noclip", "Noclip (Стены)", 95)
local infJumpBtn = createFeatureRow("InfJump", "Inf Jump", 140)
local wallhopBtn = createFeatureRow("Wallhop", "Wallhop", 185)

-- Логика смены Keybinds с клавиатуры
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if bindingAction and input.UserInputType == Enum.UserInputType.Keyboard then
        HOTKEYS[bindingAction] = input.KeyCode
        keybindButtons[bindingAction].Text = input.KeyCode.Name
        keybindButtons[bindingAction].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        -- Обновляем текст на быстрой панели, если она выведена
        if bindingAction == "Fly" then updateQuickActionWidget("Fly", "Fly (Полет)", isFlying, input.KeyCode)
        elseif bindingAction == "Noclip" then updateQuickActionWidget("Noclip", "Noclip (Стены)", isNoclip, input.KeyCode)
        elseif bindingAction == "InfJump" then updateQuickActionWidget("InfJump", "Inf Jump", isInfJump, input.KeyCode)
        elseif bindingAction == "Wallhop" then updateQuickActionWidget("Wallhop", "Wallhop", isWallhopEnabled, input.KeyCode) end
        
        bindingAction = nil
    end
end)

-- Поля ввода числовых данных физики
local function createInputField(placeholder, positionY)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 220, 0, 30)
    box.Position = UDim2.new(0, 10, 0, positionY)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)




