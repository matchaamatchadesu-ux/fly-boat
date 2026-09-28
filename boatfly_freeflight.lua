-- ============================================
-- ボートで自由飛行（Blox Fruits用・FlyGuiV3スタイル）
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
    mainFrame.Size = UDim2.new(0, 280, 0, 180)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Text = "⛵ Boat Free Flight"
    title.Parent = mainFrame

    -- ON/OFF トグル
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(0, 100, 0, 25)
    toggleLabel.Position = UDim2.new(0, 10, 0, 40)
    toggleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleLabel.BorderSizePixel = 0
    toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleLabel.TextSize = 13
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Text = "Status:"
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = mainFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 100, 0, 25)
    toggleButton.Position = UDim2.new(0, 170, 0, 40)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 13
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "ON"
    toggleButton.Parent = mainFrame

    toggleButton.MouseButton1Click:Connect(function()
        CONFIG.ON = not CONFIG.ON
        toggleButton.BackgroundColor3 = CONFIG.ON and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = CONFIG.ON and "ON" or "OFF"
    end)

    -- スピード調整
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, -20, 0, 18)
    speedLabel.Position = UDim2.new(0, 10, 0, 70)
    speedLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    speedLabel.BorderSizePixel = 0
    speedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    speedLabel.TextSize = 11
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Speed: 100"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainFrame

    local speedInput = Instance.new("TextBox")
    speedInput.Name = "SpeedInput"
    speedInput.Size = UDim2.new(1, -20, 0, 22)
    speedInput.Position = UDim2.new(0, 10, 0, 90)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedInput.BorderColor3 = Color3.fromRGB(0, 150, 255)
    speedInput.BorderSizePixel = 1
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 12
    speedInput.Font = Enum.Font.Gotham
    speedInput.Text = "100"
    speedInput.Parent = mainFrame

    speedInput.FocusLost:Connect(function()
        local val = tonumber(speedInput.Text)
        if val and val > 0 then
            CONFIG.BOAT_SPEED = val
            speedLabel.Text = "Speed: " .. val
        else
            speedInput.Text = tostring(CONFIG.BOAT_SPEED)
        end
    end)

    -- 操作説明
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0, 40)
    infoLabel.Position = UDim2.new(0, 10, 0, 120)
    infoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    infoLabel.BorderSizePixel = 0
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "WASD: Move | Space: Up\nCtrl: Down | Mouse: Look"
    infoLabel.TextWrapped = true
    infoLabel.Parent = mainFrame

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
