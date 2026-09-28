-- ============================================
-- ボートで自由飛行（Blox Fruits用・FlyGuiV3スタイル・ドラッグ可能版・スマホ用移動スティック対応）
-- エクセキューターに貼って実行またはloadstringで実行
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/matchaamatchadesu-ux/fly-boat/main/boatfly_freeflight.lua"))()
-- ============================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== デフォルト設定 =====
local CONFIG = {
    BOAT_SPEED = 100,
    ON = true,
    SENSITIVITY = 1.0,
    TOUCH_MODE = UserInputService.TouchEnabled
}

local CONTROL_STATE = {
    moveForward = false,
    moveBackward = false,
    moveLeft = false,
    moveRight = false,
    moveUp = false,
    moveDown = false
}

local JOYSTICK_STATE = {
    active = false,
    id = nil,
    vector = Vector2.new(0, 0),
    knob = nil,
    base = nil,
    maxRadius = 40
}

local GUI_STATE = {
    isMinimized = false,
    isDragging = false,
    dragStart = Vector2.new(0, 0),
    frameStart = UDim2.new(0, 10, 0, 10)
}

-- ===== GUI作成 =====
local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("BoatFlyGui")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BoatFlyGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- メインフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 280)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    -- タイトルバー
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Text = "⛵ Boat Free Flight"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "−"
    minimizeButton.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.Parent = titleBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(0, 100, 0, 25)
    toggleLabel.Position = UDim2.new(0, 10, 0, 10)
    toggleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleLabel.BorderSizePixel = 0
    toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleLabel.TextSize = 13
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Text = "Status:"
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = contentFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 100, 0, 25)
    toggleButton.Position = UDim2.new(0, 170, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 13
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "ON"
    toggleButton.Parent = contentFrame

    toggleButton.MouseButton1Click:Connect(function()
        CONFIG.ON = not CONFIG.ON
        toggleButton.BackgroundColor3 = CONFIG.ON and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = CONFIG.ON and "ON" or "OFF"
    end)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, -20, 0, 18)
    speedLabel.Position = UDim2.new(0, 10, 0, 45)
    speedLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    speedLabel.BorderSizePixel = 0
    speedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Speed: 100"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = contentFrame

    local speedSliderBg = Instance.new("Frame")
    speedSliderBg.Name = "SpeedSliderBg"
    speedSliderBg.Size = UDim2.new(1, -20, 0, 5)
    speedSliderBg.Position = UDim2.new(0, 10, 0, 68)
    speedSliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    speedSliderBg.BorderSizePixel = 0
    speedSliderBg.Parent = contentFrame

    local speedSlider = Instance.new("Frame")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0.2, 0, 1, 0)
    speedSlider.Position = UDim2.new(0, 0, 0, 0)
    speedSlider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSlider.BorderSizePixel = 0
    speedSlider.Parent = speedSliderBg

    local speedInput = Instance.new("TextBox")
    speedInput.Name = "SpeedInput"
    speedInput.Size = UDim2.new(1, -20, 0, 22)
    speedInput.Position = UDim2.new(0, 10, 0, 80)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedInput.BorderColor3 = Color3.fromRGB(0, 150, 255)
    speedInput.BorderSizePixel = 1
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.Text = "100"
    speedInput.Parent = contentFrame

    speedInput.FocusLost:Connect(function()
        local val = tonumber(speedInput.Text)
        if val and val > 0 then
            CONFIG.BOAT_SPEED = math.min(val, 500)
            speedLabel.Text = "Speed: " .. CONFIG.BOAT_SPEED
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
            speedSlider.Size = UDim2.new(CONFIG.BOAT_SPEED / 500, 0, 1, 0)
        else
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
        end
    end)

    local speedSliderInput = Instance.new("TextButton")
    speedSliderInput.Name = "SpeedSliderInput"
    speedSliderInput.Size = UDim2.new(1, 0, 1, 0)
    speedSliderInput.Position = UDim2.new(0, 0, 0, 0)
    speedSliderInput.BackgroundTransparency = 1
    speedSliderInput.BorderSizePixel = 0
    speedSliderInput.Text = ""
    speedSliderInput.Parent = speedSliderBg

    local function updateSpeedFromSliderPercent(percent)
        local p = math.clamp(percent, 0, 1)
        CONFIG.BOAT_SPEED = math.floor(p * 500)
        if CONFIG.BOAT_SPEED < 1 then CONFIG.BOAT_SPEED = 1 end
        speedSlider.Size = UDim2.new(p, 0, 1, 0)
        speedLabel.Text = "Speed: " .. CONFIG.BOAT_SPEED
        speedInput.Text = tostring(CONFIG.BOAT_SPEED)
    end

    speedSliderInput.MouseButton1Down:Connect(function()
        local connection
        local connection2

        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local bgAbsSize = speedSliderBg.AbsoluteSize.X
                local bgAbsPos = speedSliderBg.AbsolutePosition.X
                local mouseX = LocalPlayer:GetMouse().X
                local clickX = math.clamp(mouseX - bgAbsPos, 0, bgAbsSize)
                local percent = clickX / bgAbsSize
                updateSpeedFromSliderPercent(percent)
            end
        end)

        connection2 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                connection2:Disconnect()
            end
        end)
    end)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0, 60)
    infoLabel.Position = UDim2.new(0, 10, 0, 110)
    infoLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    infoLabel.BorderColor3 = Color3.fromRGB(0, 100, 150)
    infoLabel.BorderSizePixel = 1
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "WASD: Move | Space: Up\nCtrl: Down | Mouse: Look"
    infoLabel.TextWrapped = true
    infoLabel.Parent = contentFrame

    -- スマホ用ジョイスティック
    local touchPad = Instance.new("Frame")
    touchPad.Name = "TouchPad"
    touchPad.Size = UDim2.new(0, 130, 0, 130)
    touchPad.Position = UDim2.new(1, -150, 1, -150)
    touchPad.AnchorPoint = Vector2.new(0, 0)
    touchPad.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    touchPad.BorderColor3 = Color3.fromRGB(0, 150, 255)
    touchPad.BorderSizePixel = 2
    touchPad.Parent = screenGui

    local touchPadVisible = UserInputService.TouchEnabled
    touchPad.Visible = touchPadVisible

    local touchBase = Instance.new("Frame")
    touchBase.Name = "TouchBase"
    touchBase.Size = UDim2.new(0, 110, 0, 110)
    touchBase.Position = UDim2.new(0.5, 0, 0.5, 0)
    touchBase.AnchorPoint = Vector2.new(0.5, 0.5)
    touchBase.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    touchBase.BorderSizePixel = 0
    touchBase.Parent = touchPad

    local touchBaseCircle = Instance.new("UICorner")
    touchBaseCircle.CornerRadius = UDim.new(1, 0)
    touchBaseCircle.Parent = touchBase

    local touchKnob = Instance.new("Frame")
    touchKnob.Name = "TouchKnob"
    touchKnob.Size = UDim2.new(0, 42, 0, 42)
    touchKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
    touchKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    touchKnob.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    touchKnob.BorderSizePixel = 0
    touchKnob.Parent = touchBase

    local touchKnobCorner = Instance.new("UICorner")
    touchKnobCorner.CornerRadius = UDim.new(1, 0)
    touchKnobCorner.Parent = touchKnob

    JOYSTICK_STATE.base = touchBase
    JOYSTICK_STATE.knob = touchKnob
    JOYSTICK_STATE.maxRadius = 40

    local function setStickFromVector(vec2)
        local clamped = vec2
        local length = clamped.Magnitude
        if length > 1 then
            clamped = clamped.Unit
        end
        local x = clamped.X * JOYSTICK_STATE.maxRadius
        local y = clamped.Y * JOYSTICK_STATE.maxRadius
        JOYSTICK_STATE.knob.Position = UDim2.new(0.5, x, 0.5, y)
        JOYSTICK_STATE.vector = Vector2.new(clamped.X, clamped.Y)
    end

    local function resetStick()
        JOYSTICK_STATE.active = false
        JOYSTICK_STATE.id = nil
        JOYSTICK_STATE.vector = Vector2.new(0, 0)
        JOYSTICK_STATE.knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    end

    touchBase.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            JOYSTICK_STATE.active = true
            JOYSTICK_STATE.id = input.PointerId
            local center = touchBase.AbsolutePosition + (touchBase.AbsoluteSize / 2)
            local delta = input.Position - center
            local len = delta.Magnitude
            local max = JOYSTICK_STATE.maxRadius
            if len > max then
                delta = delta.Unit * max
            end
            setStickFromVector(Vector2.new(delta.X / max, delta.Y / max))
        end
    end)

    touchBase.InputChanged:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Touch and JOYSTICK_STATE.active and input.PointerId == JOYSTICK_STATE.id then
            local center = touchBase.AbsolutePosition + (touchBase.AbsoluteSize / 2)
            local delta = input.Position - center
            local len = delta.Magnitude
            local max = JOYSTICK_STATE.maxRadius
            if len > max then
                delta = delta.Unit * max
            end
            local vec = Vector2.new(delta.X / max, delta.Y / max)
            setStickFromVector(vec)
        end
    end)

    touchBase.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Touch and JOYSTICK_STATE.active and input.PointerId == JOYSTICK_STATE.id then
            resetStick()
        end
    end)

    local isDragging = false
    local dragInput
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            dragInput = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input2.Position - dragStart
                    mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
                end
            end)
        end
    end)

    titleBar.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            if dragInput then
                dragInput:Disconnect()
            end
        end
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        GUI_STATE.isMinimized = not GUI_STATE.isMinimized
        if GUI_STATE.isMinimized then
            contentFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 280, 0, 30)
            minimizeButton.Text = "+"
        else
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 280, 0, 280)
            minimizeButton.Text = "−"
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

-- ===== ボート取得関数 =====
local function getMyBoat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return boat, seat
        end
    end
    return nil
end

-- ===== キー入力処理 =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then CONTROL_STATE.moveForward = true end
    if input.KeyCode == Enum.KeyCode.A then CONTROL_STATE.moveLeft = true end
    if input.KeyCode == Enum.KeyCode.S then CONTROL_STATE.moveBackward = true end
    if input.KeyCode == Enum.KeyCode.D then CONTROL_STATE.moveRight = true end
    if input.KeyCode == Enum.KeyCode.Space then CONTROL_STATE.moveUp = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then CONTROL_STATE.moveDown = true end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then CONTROL_STATE.moveForward = false end
    if input.KeyCode == Enum.KeyCode.A then CONTROL_STATE.moveLeft = false end
    if input.KeyCode == Enum.KeyCode.S then CONTROL_STATE.moveBackward = false end
    if input.KeyCode == Enum.KeyCode.D then CONTROL_STATE.moveRight = false end
    if input.KeyCode == Enum.KeyCode.Space then CONTROL_STATE.moveUp = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then CONTROL_STATE.moveDown = false end
end)

-- ===== メインループ（自由飛行） =====
RunService.RenderStepped:Connect(function()
    if not CONFIG.ON then return end

    local boat, seat = getMyBoat()
    if not boat then return end

    for _, p in pairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    local root = boat.PrimaryPart or seat
    local cf = root.CFrame
    local camera = workspace.CurrentCamera
    local direction = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = camera.CFrame.UpVector

    local moveDir2D = Vector2.new(0, 0)

    if CONTROL_STATE.moveForward then moveDir2D.Y += 1 end
    if CONTROL_STATE.moveBackward then moveDir2D.Y -= 1 end
    if CONTROL_STATE.moveLeft then moveDir2D.X -= 1 end
    if CONTROL_STATE.moveRight then moveDir2D.X += 1 end

    if JOYSTICK_STATE.active then
        moveDir2D = moveDir2D + JOYSTICK_STATE.vector
    end

    local moveDir = Vector3.new(0, 0, 0)
    if moveDir2D.Magnitude > 0 then
        moveDir = (direction * moveDir2D.Y) + (right * moveDir2D.X)
        moveDir = moveDir.Unit
    end

    local moveSpeed = CONFIG.BOAT_SPEED / 60
    local newPos = cf.Position + moveDir * moveSpeed

    if CONTROL_STATE.moveUp then newPos = newPos + (up * moveSpeed * 1.5) end
    if CONTROL_STATE.moveDown then newPos = newPos - (up * moveSpeed * 1.5) end

    if JOYSTICK_STATE.active then
        local vert = JOYSTICK_STATE.vector.Y
        if vert > 0 then
            newPos = newPos + (up * moveSpeed * 1.5 * vert)
        elseif vert < 0 then
            newPos = newPos - (up * moveSpeed * 1.5 * math.abs(vert))
        end
    end

    local lookTarget = newPos + direction
    root.CFrame = CFrame.new(newPos, lookTarget)
end)

createGui()
print("✅ Boat Free Flight loaded! / ボート自由飛行がロードされました")
