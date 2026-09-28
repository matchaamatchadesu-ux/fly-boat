-- ============================================
-- ボートで空飛び（Blox Fruits用・自由移動対応・GUI美化版）
-- エクセキューターに貼って実行
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/matchaamatchadesu-ux/fly-boat/main/boatfly_gui.lua"))()
-- ============================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    BOAT_SPEED = 350,
    FLY_HEIGHT = 150,
    FREE_MODE = false,
    ON = true,
    GUI_VISIBLE = true,
    TOUCH_MOVE = Vector2.new(0, 0),
    TOUCH_UP = false,
    TOUCH_DOWN = false,
}

local state = {
    isDragging = false,
    dragStart = Vector2.new(),
    originalPos = UDim2.new(),
    lastTouchPos = Vector2.new(),
    joystickActive = false,
    joystickVector = Vector2.new(0, 0),
}

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function getMyBoat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end

    local seatPart = hum.SeatPart
    if seatPart and (seatPart:IsA("VehicleSeat") or seatPart:IsA("Seat")) then
        return seatPart.Parent, seatPart
    end

    for _, boat in ipairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return boat, seat
        end
    end
    return nil
end

local function updateJoystickFromTouch(pos)
    local pad = script and script:FindFirstChild("_TouchPad")
    if not pad then return end
    local knob = pad:FindFirstChild("Knob")
    if not knob then return end

    local padPos = pad.AbsolutePosition
    local padSize = pad.AbsoluteSize
    local center = padPos + (padSize / 2)
    local delta = pos - center
    local maxDist = math.min(padSize.X, padSize.Y) * 0.35
    local len = delta.Magnitude
    if len > maxDist then
        delta = delta.Unit * maxDist
    end

    local normX = delta.X / maxDist
    local normY = delta.Y / maxDist
    state.joystickVector = Vector2.new(clamp(normX, -1, 1), clamp(normY, -1, 1))
    knob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
end

local function resetJoystick()
    state.joystickActive = false
    state.joystickVector = Vector2.new(0, 0)
    local pad = script and script:FindFirstChild("_TouchPad")
    if pad then
        local knob = pad:FindFirstChild("Knob")
        if knob then
            knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end
end

local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("BoatFlyCuteGui")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BoatFlyCuteGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    -- ===== 背景ウィンドウ =====
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 270)
    main.Position = UDim2.new(0, 18, 0, 18)
    main.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = main

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 14, 1, 14)
    shadow.Position = UDim2.new(0, -7, 0, -7)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131604521"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = main

    -- ===== タイトルバー =====
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(38, 45, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 18)
    titleCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.Text = "⛵ BoatFly"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar

    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.new(0, 28, 0, 28)
    minButton.Position = UDim2.new(1, -78, 0, 4)
    minButton.Text = "_"
    minButton.Font = Enum.Font.GothamBold
    minButton.TextSize = 14
    minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minButton.BackgroundColor3 = Color3.fromRGB(90, 115, 255)
    minButton.BorderSizePixel = 0
    minButton.Parent = titleBar
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 10)
    minCorner.Parent = minButton

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -40, 0, 4)
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeButton

    -- ===== コンテンツ =====
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -52)
    content.Position = UDim2.new(0, 10, 0, 42)
    content.BackgroundTransparency = 1
    content.Parent = main

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 34)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(48, 220, 120)
    toggleBtn.Text = "ON"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = content
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleBtn

    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(0, 120, 0, 34)
    modeBtn.Position = UDim2.new(1, -120, 0, 0)
    modeBtn.BackgroundColor3 = Color3.fromRGB(112, 127, 255)
    modeBtn.Text = "自由飛行"
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 13
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeBtn.BorderSizePixel = 0
    modeBtn.Parent = content
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 12)
    modeCorner.Parent = modeBtn

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 22)
    speedLabel.Position = UDim2.new(0, 0, 0, 50)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "速度: 350"
    speedLabel.TextColor3 = Color3.fromRGB(214, 225, 255)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 13
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = content

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, 0, 0, 30)
    speedBox.Position = UDim2.new(0, 0, 0, 72)
    speedBox.Text = "350"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.TextSize = 15
    speedBox.Font = Enum.Font.GothamMedium
    speedBox.BackgroundColor3 = Color3.fromRGB(36, 43, 56)
    speedBox.BorderSizePixel = 0
    speedBox.TextXAlignment = Enum.TextXAlignment.Center
    speedBox.Parent = content
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 10)
    speedCorner.Parent = speedBox

    local heightLabel = Instance.new("TextLabel")
    heightLabel.Size = UDim2.new(1, 0, 0, 22)
    heightLabel.Position = UDim2.new(0, 0, 0, 112)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "高さ: 150"
    heightLabel.TextColor3 = Color3.fromRGB(214, 225, 255)
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextSize = 13
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = content

    local heightBox = Instance.new("TextBox")
    heightBox.Size = UDim2.new(1, 0, 0, 30)
    heightBox.Position = UDim2.new(0, 0, 0, 134)
    heightBox.Text = "150"
    heightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    heightBox.TextSize = 15
    heightBox.Font = Enum.Font.GothamMedium
    heightBox.BackgroundColor3 = Color3.fromRGB(36, 43, 56)
    heightBox.BorderSizePixel = 0
    heightBox.TextXAlignment = Enum.TextXAlignment.Center
    heightBox.Parent = content
    local heightCorner = Instance.new("UICorner")
    heightCorner.CornerRadius = UDim.new(0, 10)
    heightCorner.Parent = heightBox

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 46)
    info.Position = UDim2.new(0, 0, 0, 180)
    info.BackgroundTransparency = 1
    info.Text = "PC: WASD / Space / Ctrl\nMobile: 左スティックで移動"
    info.TextColor3 = Color3.fromRGB(150, 174, 220)
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextWrapped = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Parent = content

    -- ===== タッチスティック =====
    local touchPad = Instance.new("Frame")
    touchPad.Name = "TouchPad"
    touchPad.Size = UDim2.new(0, 150, 0, 150)
    touchPad.Position = UDim2.new(0, 20, 1, -170)
    touchPad.AnchorPoint = Vector2.new(0, 1)
    touchPad.BackgroundColor3 = Color3.fromRGB(35, 41, 52)
    touchPad.BorderSizePixel = 0
    touchPad.Parent = gui
    local padCorner = Instance.new("UICorner")
    padCorner.CornerRadius = UDim.new(0, 75)
    padCorner.Parent = touchPad
    local padAlpha = Instance.new("Frame")
    padAlpha.Size = UDim2.new(1, -22, 1, -22)
    padAlpha.Position = UDim2.new(0, 11, 0, 11)
    padAlpha.BackgroundColor3 = Color3.fromRGB(60, 70, 84)
    padAlpha.BorderSizePixel = 0
    padAlpha.Parent = touchPad
    local padAlphaCorner = Instance.new("UICorner")
    padAlphaCorner.CornerRadius = UDim.new(0, 65)
    padAlphaCorner.Parent = padAlpha

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 46, 0, 46)
    knob.Position = UDim2.new(0.5, -23, 0.5, -23)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(117, 150, 255)
    knob.BorderSizePixel = 0
    knob.Parent = touchPad
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 23)
    knobCorner.Parent = knob

    -- save pad for updateJoystickFromTouch
    script:FindFirstChild("_TouchPad") and script._TouchPad:Destroy()
    local touchHolder = Instance.new("Folder")
    touchHolder.Name = "_TouchPad"
    touchHolder.Parent = script
    touchPad.Parent = touchHolder
    touchPad.Name = "TouchPad"
    knob.Name = "Knob"

    -- ===== イベント =====
    local function updateSpeedFromBox()
        local value = tonumber(speedBox.Text)
        if value then
            CONFIG.BOAT_SPEED = clamp(value, 50, 1000)
            speedLabel.Text = "速度: " .. tostring(CONFIG.BOAT_SPEED)
            speedBox.Text = tostring(CONFIG.BOAT_SPEED)
        else
            speedBox.Text = tostring(CONFIG.BOAT_SPEED)
        end
    end

    local function updateHeightFromBox()
        local value = tonumber(heightBox.Text)
        if value then
            CONFIG.FLY_HEIGHT = clamp(value, 0, 1000)
            heightLabel.Text = "高さ: " .. tostring(CONFIG.FLY_HEIGHT)
            heightBox.Text = tostring(CONFIG.FLY_HEIGHT)
        else
            heightBox.Text = tostring(CONFIG.FLY_HEIGHT)
        end
    end

    speedBox.FocusLost:Connect(updateSpeedFromBox)
    heightBox.FocusLost:Connect(updateHeightFromBox)

    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG.ON = not CONFIG.ON
        toggleBtn.Text = CONFIG.ON and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = CONFIG.ON and Color3.fromRGB(48, 220, 120) or Color3.fromRGB(220, 90, 90)
    end)

    modeBtn.MouseButton1Click:Connect(function()
        CONFIG.FREE_MODE = not CONFIG.FREE_MODE
        modeBtn.Text = CONFIG.FREE_MODE and "自由移動" or "自動飛行"
    end)

    minButton.MouseButton1Click:Connect(function()
        CONFIG.GUI_VISIBLE = not CONFIG.GUI_VISIBLE
        main.Visible = CONFIG.GUI_VISIBLE
    end)

    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- ドラッグ
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.isDragging = true
            state.dragStart = input.Position
            state.originalPos = main.Position

            local connection
            connection = UserInputService.InputChanged:Connect(function(in2)
                if state.isDragging and in2.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = in2.Position - state.dragStart
                    main.Position = state.originalPos + UDim2.new(0, delta.X, 0, delta.Y)
                end
            end)

            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(in3)
                if in3.UserInputType == Enum.UserInputType.MouseButton1 then
                    state.isDragging = false
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)

    -- mobile joystick touch
    touchPad.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        state.joystickActive = true
        updateJoystickFromTouch(input.Position)
    end)

    touchPad.InputChanged:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        if state.joystickActive then
            updateJoystickFromTouch(input.Position)
        end
    end)

    touchPad.InputEnded:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        resetJoystick()
    end)

    return gui
end

local gui = createGui()

-- ===== キー入力 =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE + Vector2.new(0, 1) end
    if input.KeyCode == Enum.KeyCode.S then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE + Vector2.new(0, -1) end
    if input.KeyCode == Enum.KeyCode.A then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE + Vector2.new(-1, 0) end
    if input.KeyCode == Enum.KeyCode.D then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE + Vector2.new(1, 0) end
    if input.KeyCode == Enum.KeyCode.Space then CONFIG.TOUCH_UP = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then CONFIG.TOUCH_DOWN = true end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE - Vector2.new(0, 1) end
    if input.KeyCode == Enum.KeyCode.S then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE - Vector2.new(0, -1) end
    if input.KeyCode == Enum.KeyCode.A then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE - Vector2.new(-1, 0) end
    if input.KeyCode == Enum.KeyCode.D then CONFIG.TOUCH_MOVE = CONFIG.TOUCH_MOVE - Vector2.new(1, 0) end
    if input.KeyCode == Enum.KeyCode.Space then CONFIG.TOUCH_UP = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then CONFIG.TOUCH_DOWN = false end
end)

-- ===== メインループ =====
RunService.RenderStepped:Connect(function()
    if not CONFIG.ON then return end

    local boat, seat = getMyBoat()
    if not boat then return end

    for _, p in ipairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    local root = boat.PrimaryPart or seat
    local camera = workspace.CurrentCamera
    local cf = root.CFrame
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local upVec = Vector3.new(0, 1, 0)

    local keyDir = CONFIG.TOUCH_MOVE
    local joyDir = state.joystickVector
    local move2D = keyDir + joyDir

    if move2D.Magnitude > 0 then
        move2D = move2D.Unit
    else
        move2D = Vector2.new(0, 0)
    end

    if CONFIG.FREE_MODE then
        local moveDir = (forward * move2D.Y) + (right * move2D.X)
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        else
            moveDir = Vector3.new(0, 0, 0)
        end

        local moveSpeed = CONFIG.BOAT_SPEED / 60
        local newPos = cf.Position + moveDir * moveSpeed

        if CONFIG.TOUCH_UP then
            newPos = newPos + (upVec * moveSpeed * 1.5)
        end
        if CONFIG.TOUCH_DOWN then
            newPos = newPos - (upVec * moveSpeed * 1.5)
        end

        local look = newPos + forward
        root.CFrame = CFrame.new(newPos, look)
    else
        -- 自動飛行（元のW押しっぱなし）
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        if CONFIG.FLY_HEIGHT > 0 then
            local targetY = CONFIG.FLY_HEIGHT
            local rotation = CFrame.new(cf.X, targetY, cf.Z) * CFrame.Angles(0, select(2, cf:ToEulerAnglesYXZ()), 0)
            root.CFrame = rotation
        end
    end
end)

print("✅ BoatFly loaded. Press ON/OFF or E key if needed.")
