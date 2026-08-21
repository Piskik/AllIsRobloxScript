
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

-- Создание UI (Главный экран)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevAdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Функция для быстрого создания кнопок переключения (Toggle)
local function createToggleButton(name, text, positionY)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text .. ": OFF"
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 15, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 100, 100) -- Красный по умолчанию (выключен)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.BorderSizePixel = 2
    button.Parent = screenGui
    return button
end

-- Функция обновления визуального стиля кнопок
local function updateButtonVisual(button, state)
    if state then
        button.Text = string.split(button.Text, ":")[1] .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        button.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        button.Text = string.split(button.Text, ":")[1] .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Создаем элементы UI на экране
local flyBtn = createToggleButton("FlyBtn", "Fly (Режим полета)", 20)
local noclipBtn = createToggleButton("NoclipBtn", "Noclip (Сквозь стены)", 70)
local infJumpBtn = createToggleButton("InfJumpBtn", "Inf Jump (Беск. прыжок)", 120)
local wallhopBtn = createToggleButton("WallhopBtn", "Wallhop (Прыжки от стен)", 170)

-- Поля ввода числовых значений физики
local function createInputField(placeholder, positionY)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 180, 0, 35)
    box.Position = UDim2.new(0, 15, 0, positionY)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.Parent = screenGui
    return box
end

local speedInput = createInputField("Скорость бега (WalkSpeed)", 220)
local jumpInput = createInputField("Сила прыжка (JumpPower)", 265)
local flySpeedInput = createInputField("Скорость полета (FlySpeed)", 310)

-- ==================== ЛОГИКА МЕХАНИК ====================

-- 1. Контроль скорости и прыжка через поля ввода
local function getHumanoid()
    local character = player.Character
    if character then
        return character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local value = tonumber(speedInput.Text)
        local hum = getHumanoid()
        if value and hum then
            normalSpeed = value
            hum.WalkSpeed = value
        end
    end
end)

jumpInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local value = tonumber(jumpInput.Text)
        local hum = getHumanoid()
        if value and hum then
            normalJump = value
            hum.UseJumpPower = true
            hum.JumpPower = value
        end
    end
end)

flySpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local value = tonumber(flySpeedInput.Text)
        if value then flySpeed = value end
    end
end)


-- 2. Механика Fly (Полет)
local flyConnection
flyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    updateButtonVisual(flyBtn, isFlying)
    
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    if isFlying then
        hum.PlatformStand = true -- Отключаем стандартную анимацию/физику ходьбы
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = root
        
        -- Цикл пересчета направления движения камеры
        flyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
            
            bodyVelocity.Velocity = direction.Unit * flySpeed
            if direction == Vector3.new(0,0,0) then bodyVelocity.Velocity = Vector3.new(0,0,0) end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        local bv = root:FindFirstChild("FlyVelocity")
        if bv then bv:Destroy() end
        hum.PlatformStand = false
    end
end)


-- 3. Механика Noclip (Прохождение сквозь стены)
RunService.Stepped:Connect(function()
    if isNoclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    isNoclip = not isNoclip
    updateButtonVisual(noclipBtn, isNoclip)
end)


-- 4. Механика Infinite Jump (Бесконечный прыжок)
UserInputService.JumpRequest:Connect(function()
    if isInfJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    isInfJump = not isInfJump
    updateButtonVisual(infJumpBtn, isInfJump)
end)


-- 5. Механика Wallhop (Разрешение повторного прыжка от стен)
wallhopBtn.MouseButton1Click:Connect(function()
    isWallhopEnabled = not isWallhopEnabled
    updateButtonVisual(wallhopBtn, isWallhopEnabled)
end)

-- Простая реализация проверки касания стены для Wallhop
UserInputService.JumpRequest:Connect(function()
    if isWallhopEnabled and not isInfJump then
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
            -- Создаем луч вперед, чтобы проверить, стоим ли мы вплотную к стене
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local rayDirection = root.CFrame.LookVector * 2.5
            local raycastResult = workspace:Raycast(root.Position, rayDirection, raycastParams)
            
            if raycastResult then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Сброс параметров при возрождении персонажа
player.CharacterAdded:Connect(function(char)
    isFlying = false
    updateButtonVisual(flyBtn, false)
    if flyConnection then flyConnection:Disconnect() end
    
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = normalSpeed
    hum.UseJumpPower = true
    hum.JumpPower = normalJump
end)
