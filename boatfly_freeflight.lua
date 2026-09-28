-- ============================================
-- ボートで自由飛行（Blox Fruits用・FlyGuiV3スタイル・ドラッグ可能版）
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
    SENSITIVITY = 1.0
}

local CONTROL_STATE = {
    moveForward = false,
    moveBackward = false,
    moveLeft = false,
    moveRight = false,
    moveUp = false,
    moveDown = false
}

local GUI_STATE = {
    isMinimized = false,
    isDragging = false,
    dragStart = Vector2.new(0, 0),
    frameStart = UDim2.new(0, 10, 0, 10)
}

-- ===== GUI作成 =====
local function createGui()
    -- 既に存在したら削除
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

    -- タイトルバー（ドラッグ用）
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    -- タイトルテキスト
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

    -- 最小化ボタン
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

    -- 閉じるボタン
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

    -- コンテンツフレーム
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    -- ON/OFF トグル
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

    -- スピードラベル
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

    -- スピードスライダーの背景
    local speedSliderBg = Instance.new("Frame")
    speedSliderBg.Name = "SpeedSliderBg"
    speedSliderBg.Size = UDim2.new(1, -20, 0, 5)
    speedSliderBg.Position = UDim2.new(0, 10, 0, 68)
    speedSliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    speedSliderBg.BorderSizePixel = 0
    speedSliderBg.Parent = contentFrame

    -- スピードスライダー
    local speedSlider = Instance.new("Frame")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0.5, 0, 1, 0)
    speedSlider.Position = UDim2.new(0, 0, 0, 0)
    speedSlider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSlider.BorderSizePixel = 0
    speedSlider.Parent = speedSliderBg

    -- スピード入力フィールド
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
            CONFIG.BOAT_SPEED = math.min(val, 500)  -- 最大500
            speedLabel.Text = "Speed: " .. CONFIG.BOAT_SPEED
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
            speedSlider.Size = UDim2.new(CONFIG.BOAT_SPEED / 500, 0, 1, 0)
        else
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
        end
    end)

    speedInput.Changed:Connect(function()
        -- リアルタイム更新
        local val = tonumber(speedInput.Text)
        if val and val > 0 and val <= 500 then
            CONFIG.BOAT_SPEED = val
            speedLabel.Text = "Speed: " .. math.floor(val)
            speedSlider.Size = UDim2.new(val / 500, 0, 1, 0)
        end
    end)

    -- スピードスライダー背景をクリック可能にする
    local speedSliderInput = Instance.new("TextButton")
    speedSliderInput.Name = "SpeedSliderInput"
    speedSliderInput.Size = UDim2.new(1, 0, 1, 0)
    speedSliderInput.Position = UDim2.new(0, 0, 0, 0)
    speedSliderInput.BackgroundTransparency = 1
    speedSliderInput.BorderSizePixel = 0
    speedSliderInput.Text = ""
    speedSliderInput.Parent = speedSliderBg

    speedSliderInput.MouseButton1Down:Connect(function()
        local userInputService = UserInputService
        local connection
        connection = userInputService.InputChanged:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local bgAbsSize = speedSliderBg.AbsoluteSize.X
            local bgAbsPos = speedSliderBg.AbsolutePosition.X
            local clickX = math.clamp(mouse.X - bgAbsPos, 0, bgAbsSize)
            local percentage = clickX / bgAbsSize
            CONFIG.BOAT_SPEED = math.floor(percentage * 500)
            speedSlider.Size = UDim2.new(percentage, 0, 1, 0)
            speedLabel.Text = "Speed: " .. CONFIG.BOAT_SPEED
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
        end)

        local connection2 = userInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                connection2:Disconnect()
            end
        end)
    end)

    -- 操作説明
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

    -- ドラッグ機能
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
            
            dragInput = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
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

    -- 最小化機能
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

    -- 閉じる機能
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

    -- 当たり判定をOFF
    for _, p in pairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- 自由飛行処理
    local root = boat.PrimaryPart or seat
    local cf = root.CFrame
    local camera = workspace.CurrentCamera
    
    -- マウスの向きを取得（FlyGuiV3スタイル）
    local direction = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = camera.CFrame.UpVector

    local moveDir = Vector3.new(0, 0, 0)
    
    if CONTROL_STATE.moveForward then moveDir = moveDir + direction end
    if CONTROL_STATE.moveBackward then moveDir = moveDir - direction end
    if CONTROL_STATE.moveLeft then moveDir = moveDir - right end
    if CONTROL_STATE.moveRight then moveDir = moveDir + right end
    if CONTROL_STATE.moveUp then moveDir = moveDir + up end
    if CONTROL_STATE.moveDown then moveDir = moveDir - up end

    -- 速度調整
    local moveSpeed = CONFIG.BOAT_SPEED / 60

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end

    local newPos = cf.Position + moveDir * moveSpeed

    -- カメラの向きに合わせてボートの向きを更新
    root.CFrame = CFrame.new(newPos, newPos + direction)
end)

-- ===== GUI作成実行 =====
createGui()
print("✅ Boat Free Flight loaded! / ボート自由飛行がロードされました")
