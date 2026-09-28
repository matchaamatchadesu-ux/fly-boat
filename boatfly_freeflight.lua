-- ============================================
-- ボートで自由飛行（Blox Fruits用・Eキー切替 + スマホ移動スティック対応 + GUI付き）
-- エクセキューターに貼って実行
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local CONFIG = {
    FLY_SPEED = 50,
    ON = false,
    GUI_WIDTH = 280,
    GUI_HEIGHT = 280
}

local STATE = {
    flyBody = nil,
    moveVector = Vector2.new(0, 0),
    up = false,
    down = false,
    minimized = false,
    lastSeat = nil,
    lastRoot = nil
}

-- ===== ボート取得 =====
local function getBoatSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end

    local seatPart = hum.SeatPart
    if seatPart and (seatPart:IsA("VehicleSeat") or seatPart:IsA("Seat")) then
        return seatPart
    end

    for _, boat in ipairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return seat
        end
    end
    return nil
end

-- ===== スティック入力 =====
local function getTouchStickVector()
    if not UserInputService.TouchEnabled then
        return Vector2.new(0, 0)
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local touchGui = playerGui:FindFirstChild("TouchGui")
    if not touchGui then
        return Vector2.new(0, 0)
    end

    local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
    if not touchControlFrame then
        return Vector2.new(0, 0)
    end

    local joystick = touchControlFrame:FindFirstChild("Movement")
    if joystick then
        local center = joystick.AbsolutePosition + (joystick.AbsoluteSize / 2)
        local mouse = LocalPlayer:GetMouse()
        local delta = Vector2.new(mouse.X - center.X, mouse.Y - center.Y)
        local max = joystick.AbsoluteSize.X * 0.5
        if max <= 0 then return Vector2.new(0,0) end
        delta = Vector2.new(math.clamp(delta.X / max, -1, 1), math.clamp(delta.Y / max, -1, 1))
        return Vector2.new(delta.X, -delta.Y)
    end

    return Vector2.new(0, 0)
end

-- ===== GUI =====
local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("BoatFlyGui")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BoatFlyGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Text = "⛵ Boat Fly"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -90, 0, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "−"
    minimizeButton.Parent = titleBar

    local resizeButton = Instance.new("TextButton")
    resizeButton.Name = "ResizeButton"
    resizeButton.Size = UDim2.new(0, 30, 0, 30)
    resizeButton.Position = UDim2.new(1, -60, 0, 0)
    resizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    resizeButton.BorderSizePixel = 0
    resizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resizeButton.TextSize = 16
    resizeButton.Font = Enum.Font.GothamBold
    resizeButton.Text = "⟷"
    resizeButton.Parent = titleBar

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
    toggleButton.BackgroundColor3 = CONFIG.ON and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 13
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = CONFIG.ON and "ON" or "OFF"
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
    speedLabel.Text = "Speed: 50"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = contentFrame

    local speedInput = Instance.new("TextBox")
    speedInput.Name = "SpeedInput"
    speedInput.Size = UDim2.new(1, -20, 0, 22)
    speedInput.Position = UDim2.new(0, 10, 0, 70)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedInput.BorderColor3 = Color3.fromRGB(0, 150, 255)
    speedInput.BorderSizePixel = 1
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.Text = "50"
    speedInput.Parent = contentFrame

    speedInput.FocusLost:Connect(function()
        local val = tonumber(speedInput.Text)
        if val then
            CONFIG.FLY_SPEED = math.clamp(val, 10, 300)
            speedLabel.Text = "Speed: " .. tostring(CONFIG.FLY_SPEED)
            speedInput.Text = tostring(CONFIG.FLY_SPEED)
        else
            speedInput.Text = tostring(CONFIG.FLY_SPEED)
        end
    end)

    local infoText = "E: ON/OFF\nMobile: left stick\nDesktop: WASD / Space / Ctrl"
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0, 70)
    infoLabel.Position = UDim2.new(0, 10, 0, 100)
    infoLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    infoLabel.BorderColor3 = Color3.fromRGB(0, 100, 150)
    infoLabel.BorderSizePixel = 1
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = infoText
    infoLabel.TextWrapped = true
    infoLabel.Parent = contentFrame

    -- ドラッグ
    local dragging = false
    local dragStartPos
    local dragStartFrame

    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            dragStartFrame = mainFrame.Position
            local moved
            moved = UserInputService.InputChanged:Connect(function(input2)
                if dragging and input2.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input2.Position - dragStartPos
                    mainFrame.Position = dragStartFrame + UDim2.new(0, delta.X, 0, delta.Y)
                end
            end)
            local ended
            ended = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    moved:Disconnect()
                    ended:Disconnect()
                end
            end)
        end
    end)

    -- 最小化
    minimizeButton.MouseButton1Click:Connect(function()
        STATE.minimized = not STATE.minimized
        if STATE.minimized then
            contentFrame.Visible = false
            mainFrame.Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, 30)
            minimizeButton.Text = "+"
        else
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT)
            minimizeButton.Text = "−"
        end
    end)

    -- サイズ変更
    resizeButton.MouseButton1Down:Connect(function()
        local startMouse = UserInputService:GetMouseLocation()
        local startSize = mainFrame.Size
        local resizing = true

        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local dx = mouse.X - startMouse.X
                local dy = mouse.Y - startMouse.Y
                local newW = math.clamp(startSize.X.Offset + dx, 200, 420)
                local newH = math.clamp(startSize.Y.Offset + dy, 150, 420)
                mainFrame.Size = UDim2.new(0, newW, 0, newH)
                CONFIG.GUI_WIDTH = newW
                CONFIG.GUI_HEIGHT = newH
            end
        end)

        local endConn
        endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
                moveConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

-- ===== フライトを開始/停止 =====
local function startFlying()
    if CONFIG.ON then return end

    local seat = getBoatSeat()
    if not seat then
        print("ボートに乗っていません")
        return
    end

    local rootPart = seat.Parent:FindFirstChild("HumanoidRootPart") or seat
    if not rootPart then
        print("rootPartが見つかりません")
        return
    end

    CONFIG.ON = true
    STATE.lastSeat = seat
    STATE.lastRoot = rootPart

    if STATE.flyBody then STATE.flyBody:Destroy() end
    local flyBody = Instance.new("BodyVelocity")
    flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBody.Velocity = Vector3.new(0, 0, 0)
    flyBody.Parent = rootPart
    STATE.flyBody = flyBody

    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.CFrame = rootPart.CFrame
    gyro.Parent = rootPart

    print("ボート飛行: ON")
end

local function stopFlying()
    if not CONFIG.ON then return end
    CONFIG.ON = false
    if STATE.flyBody then
        STATE.flyBody:Destroy()
        STATE.flyBody = nil
    end
    print("ボート飛行: OFF")
end

-- ===== Eキー切替 =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        if CONFIG.ON then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- ===== キーボード入力 =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then STATE.moveVector = STATE.moveVector + Vector2.new(0, 1) end
    if input.KeyCode == Enum.KeyCode.S then STATE.moveVector = STATE.moveVector + Vector2.new(0, -1) end
    if input.KeyCode == Enum.KeyCode.A then STATE.moveVector = STATE.moveVector + Vector2.new(-1, 0) end
    if input.KeyCode == Enum.KeyCode.D then STATE.moveVector = STATE.moveVector + Vector2.new(1, 0) end
    if input.KeyCode == Enum.KeyCode.Space then STATE.up = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then STATE.down = true end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then STATE.moveVector = STATE.moveVector - Vector2.new(0, 1) end
    if input.KeyCode == Enum.KeyCode.S then STATE.moveVector = STATE.moveVector - Vector2.new(0, -1) end
    if input.KeyCode == Enum.KeyCode.A then STATE.moveVector = STATE.moveVector - Vector2.new(-1, 0) end
    if input.KeyCode == Enum.KeyCode.D then STATE.moveVector = STATE.moveVector - Vector2.new(1, 0) end
    if input.KeyCode == Enum.KeyCode.Space then STATE.up = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then STATE.down = false end
end)

-- ===== メインループ =====
RunService.RenderStepped:Connect(function()
    if not CONFIG.ON or not STATE.flyBody then return end

    local seat = getBoatSeat()
    if not seat then
        stopFlying()
        return
    end

    local rootPart = seat.Parent:FindFirstChild("HumanoidRootPart") or seat
    if not rootPart then return end

    if STATE.flyBody.Parent ~= rootPart then
        STATE.flyBody.Parent = rootPart
    end

    local camera = workspace.CurrentCamera
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local upVector = Vector3.new(0, 1, 0)

    local touchDir = getTouchStickVector()
    local combined = STATE.moveVector + touchDir
    if combined.Magnitude > 0 then
        combined = combined.Unit
    else
        combined = Vector2.new(0, 0)
    end

    local moveDir = Vector3.new(0, 0, 0)
    moveDir = moveDir + (forward * combined.Y)
    moveDir = moveDir + (right * combined.X)

    if STATE.up then moveDir = moveDir + upVector end
    if STATE.down then moveDir = moveDir - upVector end

    if moveDir.Magnitude > 0 then
        STATE.flyBody.Velocity = moveDir.Unit * CONFIG.FLY_SPEED
    else
        STATE.flyBody.Velocity = Vector3.new(0, 0, 0)
    end
end)

createGui()
print("Boat fly script ready. Press E to toggle flight.")
