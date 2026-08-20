-- Сервисы игры
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

-- Горячие клавиши для ПК
local HOTKEYS = {
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    InfJump = Enum.KeyCode.J,
    Wallhop = Enum.KeyCode.H
}

-- Создание UI (Главная панель)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevAdminPanelPro"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основной контейнер для меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 480)
mainFrame.Position = UDim2.new(0, 15, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Позволяет перетаскивать меню по экрану
mainFrame.Parent = screenGui

-- Скругление углов
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Заголовок меню
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "DEV PANEL (MOBILE & PC)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Панель быстрых кнопок (Виджеты на главном экране)
local quickActionsFrame = Instance.new("Frame")
quickActionsFrame.Size = UDim2.new(0, 100, 0, 200)
quickActionsFrame.Position = UDim2.new(1, 10, 0, 0) -- Справа от основного меню
quickActionsFrame.BackgroundTransparency = 1
quickActionsFrame.Parent = mainFrame

local quickLayout = Instance.new("UIListLayout")
quickLayout.Padding = UDim.new(0, 5)
quickLayout.Parent = quickActionsFrame

-- Мобильный интерфейс управления Полетом (появляется только при включении Fly)
local mobileFlyControls = Instance.new("Frame")
mobileFlyControls.Size = UDim2.new(0, 70, 0, 150)
mobileFlyControls.Position = UDim2.new(0.85, 0, 0.4, 0)
mobileFlyControls.BackgroundTransparency = 1
mobileFlyControls.Visible = false
mobileFlyControls.Parent = screenGui

-- Вспомогательная функция получения хуманоида
local function getHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

-- Функция для создания кнопок-переключателей
local function createToggleButton(name, text, positionY, hotkeyText)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text .. " [" .. hotkeyText .. "]: OFF"
    button.Size = UDim2.new(0, 190, 0, 35)
    button.Position = UDim2.new(0, 15, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(240, 80, 80)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = mainFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    
    -- Кнопка быстрого вывода (Звездочка)
    local pin = Instance.new("TextButton")
    pin.Size = UDim2.new(0, 25, 0, 25)
    pin.Position = UDim2.new(1, -30, 0.5, -12)
    pin.Text = "⭐"
    pin.BackgroundTransparency = 1
    pin.TextSize = 14
    pin.Parent = button
    
    pin.MouseButton1Click:Connect(function()
        if quickActionsFrame:FindFirstChild(name .. "_Quick") then
            quickActionsFrame:FindFirstChild(name .. "_Quick"):Destroy()
        else
            local quickBtn = button:Clone()
            quickBtn.Name = name .. "_Quick"
            quickBtn.Size = UDim2.new(0, 120, 0, 35)
            quickBtn.Text = text
            quickBtn:FindFirstChild("TextButton"):Destroy() -- убираем звездочку из клона
            quickBtn.Parent = quickActionsFrame
            
            quickBtn.MouseButton1Click:Connect(function()
                button:Click() -- Симулируем нажатие основной кнопки
            end)
        end
    end)
    
    return button
end

-- Обновление стилей
local function updateButtonVisual(button, state, text)
    local cleanText = string.split(button.Text, ":")[1]
    if state then
        button.Text = cleanText .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(45, 100, 45)
        button.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        button.Text = cleanText .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.TextColor3 = Color3.fromRGB(240, 80, 80)
    end
    
    -- Обновляем и быструю кнопку, если она создана
    local quick = quickActionsFrame:FindFirstChild(button.Name .. "_Quick")
    if quick then
        quick.BackgroundColor3 = button.BackgroundColor3
        quick.TextColor3 = button.TextColor3
    end
end

-- Создание полей ввода
local function createInputField(placeholder, positionY)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 190, 0, 30)
    box.Position = UDim2.new(0, 15, 0, positionY)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.Parent = mainFrame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    return box
end

-- Кнопки действий
local flyBtn = createToggleButton("FlyBtn", "Fly (Полет)", 50, "F")
local noclipBtn = createToggleButton("NoclipBtn", "Noclip", 95, "N")
local infJumpBtn = createToggleButton("InfJumpBtn", "Inf Jump", 140, "J")
local wallhopBtn = createToggleButton("WallhopBtn", "Wallhop", 185, "H")

-- Поля ввода и новые кнопки скорости
local speedInput = createInputField("Ввод WalkSpeed", 235)
local jumpInput = createInputField("Ввод JumpPower", 270)
local flySpeedInput = createInputField("Ввод FlySpeed", 305)

-- Кнопка мгновенного ускорения (Speed Boost)
local boostBtn = Instance.new("TextButton")
boostBtn.Size = UDim2.new(0, 190, 0, 35)
boostBtn.Position = UDim2.new(0, 15, 0, 345)
boostBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
boostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
boostBtn.Text = "⚡ МГНОВЕННОЕ УСКОРЕНИЕ"
boostBtn.Font = Enum.Font.SourceSansBold
boostBtn.TextSize = 14
boostBtn.Parent = mainFrame
Instance.new("UICorner", boostBtn).CornerRadius = UDim.new(0, 5)

-- Ползунок (Слайдер) скорости для мобилок и ПК
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 190, 0, 20)
sliderFrame.Position = UDim2.new(0, 15, 0, 395)
sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderFrame.Parent = mainFrame
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 10)

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 20, 0, 20)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderFrame
Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 10)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 190, 0, 15)
sliderLabel.Position = UDim2.new(0, 15, 0, 420)
sliderLabel.Text = "Настройка скорости ползунком: 16"
sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextSize = 12
sliderLabel.Parent = mainFrame

-- Кнопки высоты для мобильного Fly
local function createMobileFlyBtn(text, posPercentY)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 45)
    b.Position = UDim2.new(0, 0, posPercentY, 0)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.3
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 18
    b.Parent = mobileFlyControls
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end
local mobileUp = createMobileFlyBtn("▲ ВВЕРХ", 0)
local mobileDown = createMobileFlyBtn("▼ ВНИЗ", 0.4)

-- ==================== ЛОГИКА РАБОТЫ МЕХАНИК ====================

-- Слайдер кастомизации скорости бега (от 16 до 250)
local isSliding = false
sliderButton.MouseButton1Down:Connect(function() isSliding = true end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end end)

RunService.RenderStepped:Connect(function()
    if isSliding then
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderX = sliderFrame.AbsolutePosition.X
        local sliderWidth = sliderFrame.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderX) / sliderWidth, 0, 1)
        
        sliderButton.Position = UDim2.new(percentage, -10, 0, 0)
        local calculatedSpeed = math.floor(16 + (percentage * 234))
        sliderLabel.Text = "Настройка скорости ползунком: " .. calculatedSpeed
        
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = calculatedSpeed end
    end
end)

-- Ввод параметров вручную (Enter для подтверждения)
speedInput.FocusLost:Connect(function(ep) if ep and tonumber(speedInput.Text) then local h = getHumanoid() if h then h.WalkSpeed = tonumber(speedInput.Text) end end end)
jumpInput.FocusLost:Connect(function(ep) if ep and tonumber(jumpInput.Text) then local h = getHumanoid() if h then h.UseJumpPower = true h.JumpPower = tonumber(jumpInput.Text) end end end)
flySpeedInput.FocusLost:Connect(function(ep) if ep and tonumber(flySpeedInput.Text) then flySpeed = tonumber(flySpeedInput.Text) end end end)

-- Мгновенная кнопка Speed Boost
boostBtn.MouseButton1Click:Connect(function()



