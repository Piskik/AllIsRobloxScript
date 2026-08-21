local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclip = false
local infJump = false
local currentSpeed = 16
local flySpeed = 50
local increment = 10
local bodyVelocity, bodyGyro
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Logo button (image)
local logoBtn = Instance.new("ImageButton")
logoBtn.Size = UDim2.new(0, 38, 0, 38)
logoBtn.Position = UDim2.new(0, 20, 0.5, -19)
logoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logoBtn.Image = "rbxassetid://83542200342727"
logoBtn.BorderSizePixel = 0
logoBtn.Parent = screenGui
Instance.netw("UICorner", logoBtn).CornerRadius = UDim.new(0, 10)

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(100, 180, 255)
logoStroke.Thickness = 2
logoStroke.Parent = logoBtn

local logoDragging = false
local logoDragStart, logoStartPos

logoBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = true
        logoDragStart = input.Position
        logoStartPos = logoBtn.Position
    end
end)

logoBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = false
    end
end)

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 340)
frame.Position = UDim2.new(0.5, -110, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 1.5
stroke.Parent = frame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.Position = UDim2.new(0, 0, 0, 5)
header.BackgroundTransparency = 1
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Text = "рџЋ® Crooksa Hub"
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.Parent = frame

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 60, 0, 60)
upButton.Position = UDim2.new(1, -150, 1, -140)
upButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.Text = "в–І"
upButton.Font = Enum.Font.GothamBold
upButton.TextSize = 22
upButton.BorderSizePixel = 0
upButton.Visible = false
upButton.Parent = screenGui
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 10)

local function makeDivider(yPos)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 190, 0, 1)
    d.Position = UDim2.new(0.5, -95, 0, yPos)
    d.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    d.BorderSizePixel = 0
    d.Parent = frame
end

makeDivider(35)
makeDivider(82)
makeDivider(155)
makeDivider(182)
makeDivider(222)

local function makeToggleButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 190, 0, 30)
    btn.Position = UDim2.new(0.5, -95, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Text = text .. ":  OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function makeAdjustRow(labelText, yPos, defaultVal)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 190, 0, 18)
    label.Position = UDim2.new(0.5, -95, 0, yPos)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Text = labelText .. "  |  " .. defaultVal
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = frame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 45, 0, 26)
    minus.Position = UDim2.new(0.5, -95, 0, yPos + 20)
    minus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minus.TextColor3 = Color3.new(1, 1, 1)
    minus.Text = "в€’"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 18
    minus.BorderSizePixel = 0
    minus.Parent = frame
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 8)

    local display = Instance.new("TextLabel")
    display.Size = UDim2.new(0, 80, 0, 26)
    display.Position = UDim2.new(0.5, -40, 0, yPos + 20)
    display.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    display.TextColor3 = Color3.fromRGB(100, 180, 255)
    display.Text = tostring(defaultVal)
    display.Font = Enum.Font.GothamBold
    display.TextSize = 14
    display.BorderSizePixel = 0
    display.Parent = frame
    Instance.new("UICorner", display).CornerRadius = UDim.new(0, 8)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 45, 0, 26)
    plus.Position = UDim2.new(0.5, 50, 0, yPos + 20)
    plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    plus.TextColor3 = Color3.new(1, 1, 1)
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 18
    plus.BorderSizePixel = 0
    plus.Parent = frame
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 8)

    return label, minus, display, plus
end

local flyBtn = makeToggleButton("вњ€  Fly", 45)
local flySpeedLabel, flyMinus, flyDisplay, flyPlus = makeAdjustRow("вњ€  Fly Speed", 88, flySpeed)
local noclipBtn = makeToggleButton("рџ‘»  Noclip", 160)
local infJumpBtn = makeToggleButton("рџ¦  Inf Jump", 190)
local walkSpeedLabel, walkMinus, walkDisplay, walkPlus = makeAdjustRow("вљЎ Walk Speed", 230, currentSpeed)
local Wall = makeToggleButton("WallHop", 310)

flyMinus.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed - 10, 10, 500)
    flyDisplay.Text = tostring(flySpeed)
    flySpeedLabel.Text = "вњ€  Fly Speed  |  " .. flySpeed
end)

flyPlus.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed + 10, 10, 500)
    flyDisplay.Text = tostring(flySpeed)
    flySpeedLabel.Text = "вњ€  Fly Speed  |  " .. flySpeed
end)

walkMinus.MouseButton1Click:Connect(function()
    currentSpeed = math.clamp(currentSpeed - increment, 16, 500)
    humanoid.WalkSpeed = currentSpeed
    walkDisplay.Text = tostring(currentSpeed)
    walkSpeedLabel.Text = "вљЎ Walk Speed  |  " .. currentSpeed
end)

walkPlus.MouseButton1Click:Connect(function()
    currentSpeed = math.clamp(currentSpeed + increment, 16, 500)
    humanoid.WalkSpeed = currentSpeed
    walkDisplay.Text = tostring(currentSpeed)
    walkSpeedLabel.Text = "вљЎ Walk Speed  |  " .. currentSpeed
end)

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 60, 0, 60)
upButton.Position = UDim2.new(1, -150, 1, -140)
upButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.Text = "в–І"
upButton.Font = Enum.Font.GothamBold
upButton.TextSize = 22
upButton.BorderSizePixel = 0
upButton.Visible = false
upButton.Parent = screenGui
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 10)

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 60, 0, 60)
downButton.Position = UDim2.new(1, -150, 1, -70)
downButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.Text = "в–ј"
downButton.Font = Enum.Font.GothamBold
downButton.TextSize = 22
downButton.BorderSizePixel = 0
downButton.Visible = false
downButton.Parent = screenGui
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 10)

local goingUp = false
local goingDown = false

upButton.MouseButton1Down:Connect(function() goingUp = true end)
upButton.MouseButton1Up:Connect(function() goingUp = false end)
downButton.MouseButton1Down:Connect(function() goingDown = true end)
downButton.MouseButton1Up:Connect(function() goingDown = false end)

UIS.TouchStarted:Connect(function(touch, processed)
    if processed then
        local pos = touch.Position
        local function hitting(btn)
            local p = btn.AbsolutePosition
            local s = btn.AbsoluteSize
            return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
        end
        if hitting(upButton) then goingUp = true end
        if hitting(downButton) then goingDown = true end
    end
end)

UIS.TouchEnded:Connect(function()
    goingUp = false
    goingDown = false
end)

local function startFly()
    flying = true
    flyBtn.Text = "вњ€  Fly:  ON"
    flyBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
    humanoid.PlatformStand = true
    upButton.Visible = true
    downButton.Visible = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = camera.CFrame
    bodyGyro.Parent = rootPart
end

local function stopFly()
    flying = false
    flyBtn.Text = "вњ€  Fly:  OFF"
    flyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    humanoid.PlatformStand = false
    upButton.Visible = false
    downButton.Visible = false
    goingUp = false
    goingDown = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        noclipBtn.Text = "рџ‘»  Noclip:  ON"
        noclipBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
    else
        noclipBtn.Text = "рџ‘»  Noclip:  OFF"
        noclipBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    if infJump then
        infJumpBtn.Text = "рџ¦  Inf Jump:  ON"
        infJumpBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
    else
        infJumpBtn.Text = "рџ¦  Inf Jump:  OFF"
        infJumpBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

UIS.JumpRequest:Connect(function()
    if infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local guiOpen = true
logoBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    frame.Visible = guiOpen
end)

local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or
       input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or
       input.UserInputType == Enum.UserInputType.MouseMove then
        if logoDragging then
            local delta = input.Position - logoDragStart
            logoBtn.Position = UDim2.new(
                logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X,
                logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y
            )
        end
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

RS.RenderStepped:Connect(function()
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if flying then
        bodyGyro.CFrame = camera.CFrame
        local moveVector = Vector3.zero
        local cf = camera.CFrame

        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        local mobileMove = humanoid.MoveDirection
        if mobileMove.Magnitude > 0 then
            moveVector = moveVector + Vector3.new(mobileMove.X, 0, mobileMove.Z)
        end

        if goingUp then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if goingDown then moveVector = moveVector - Vector3.new(0, 1, 0) end

        bodyVelocity.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * flySpeed or Vector3.zero
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid.WalkSpeed = currentSpeed
    flying = false
    noclip = false
    infJump = false
    flyBtn.Text = "вњ€  Fly:  OFF"
    flyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    noclipBtn.Text = "рџ‘»  Noclip:  OFF"
    noclipBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    infJumpBtn.Text = "рџ¦  Inf Jump:  OFF"
    infJumpBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    upButton.Visible = false
    downButton.Visible = false
end)

local isWallhopEnabled = false

wall.MouseButton1Click:Connect(function()
    isWallhopEnabled = not isWallhopEnabled
    updateButtonVisual(wallhopBtn, isWallhopEnabled)
end)

-- Простая реализация проверки касания стены для Wallhop
UIS.JumpRequest:Connect(function()
    if isWallhopEnabled and not InfJump then
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
end

