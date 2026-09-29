-- ============================================
-- ボートで空飛び（Blox Fruits用・自分の移動と同期版）
-- エクセキューターに貼って実行
-- ============================================
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== 設定 =====
local CONFIG = {
    BOAT_SPEED = 350,
    FLY_HEIGHT = 150,
    AUTO_MODE = true,
    ON = true
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
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BoatFlyGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 280)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Text = "⛵ Boat Fly Control"
    title.Parent = mainFrame

    -- ON/OFF
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(0, 150, 0, 25)
    toggleLabel.Position = UDim2.new(0, 10, 0, 40)
    toggleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleLabel.BorderSizePixel = 0
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Text = "Power:"
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = mainFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 120, 0, 25)
    toggleButton.Position = UDim2.new(0, 170, 0, 40)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "ON"
    toggleButton.Parent = mainFrame

    toggleButton.MouseButton1Click:Connect(function()
        CONFIG.ON = not CONFIG.ON
        toggleButton.BackgroundColor3 = CONFIG.ON and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggleButton.Text = CONFIG.ON and "ON" or "OFF"
    end)

    -- モード切り替え
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Name = "ModeLabel"
    modeLabel.Size = UDim2.new(0, 150, 0, 25)
    modeLabel.Position = UDim2.new(0, 10, 0, 70)
    modeLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    modeLabel.BorderSizePixel = 0
    modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeLabel.TextSize = 14
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.Text = "Mode:"
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = mainFrame

    local modeButton = Instance.new("TextButton")
    modeButton.Name = "ModeButton"
    modeButton.Size = UDim2.new(0, 120, 0, 25)
    modeButton.Position = UDim2.new(0, 170, 0, 70)
    modeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    modeButton.BorderSizePixel = 0
    modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeButton.TextSize = 14
    modeButton.Font = Enum.Font.GothamBold
    modeButton.Text = "AUTO"
    modeButton.Parent = mainFrame

    modeButton.MouseButton1Click:Connect(function()
        CONFIG.AUTO_MODE = not CONFIG.AUTO_MODE
        modeButton.BackgroundColor3 = CONFIG.AUTO_MODE and Color3.fromRGB(100, 100, 200) or Color3.fromRGB(200, 100, 100)
        modeButton.Text = CONFIG.AUTO_MODE and "AUTO" or "MANUAL"
    end)

    -- Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 105)
    speedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedLabel.BorderSizePixel = 0
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Speed: 350"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Name = "SpeedBox"
    speedBox.Size = UDim2.new(1, -20, 0, 25)
    speedBox.Position = UDim2.new(0, 10, 0, 125)
    speedBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    speedBox.BorderColor3 = Color3.fromRGB(100, 200, 255)
    speedBox.BorderSizePixel = 1
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.TextSize = 14
    speedBox.Font = Enum.Font.Gotham
    speedBox.Text = "350"
    speedBox.Parent = mainFrame

    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            CONFIG.BOAT_SPEED = val
            speedLabel.Text = "Speed: " .. val
        else
            speedBox.Text = tostring(CONFIG.BOAT_SPEED)
        end
    end)

    -- Height
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Name = "HeightLabel"
    heightLabel.Size = UDim2.new(1, -20, 0, 20)
    heightLabel.Position = UDim2.new(0, 10, 0, 160)
    heightLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    heightLabel.BorderSizePixel = 0
    heightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    heightLabel.TextSize = 12
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.Text = "Height: 150"
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = mainFrame

    local heightBox = Instance.new("TextBox")
    heightBox.Name = "HeightBox"
    heightBox.Size = UDim2.new(1, -20, 0, 25)
    heightBox.Position = UDim2.new(0, 10, 0, 180)
    heightBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    heightBox.BorderColor3 = Color3.fromRGB(100, 200, 255)
    heightBox.BorderSizePixel = 1
    heightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    heightBox.TextSize = 14
    heightBox.Font = Enum.Font.Gotham
    heightBox.Text = "150"
    heightBox.Parent = mainFrame

    heightBox.FocusLost:Connect(function()
        local val = tonumber(heightBox.Text)
        if val and val >= 0 then
            CONFIG.FLY_HEIGHT = val
            heightLabel.Text = "Height: " .. val
        else
            heightBox.Text = tostring(CONFIG.FLY_HEIGHT)
        end
    end)

    -- 説明
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0, 50)
    infoLabel.Position = UDim2.new(0, 10, 0, 220)
    infoLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    infoLabel.BorderSizePixel = 0
    infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "Manual: 自分の移動に同期\nSpace上昇, Ctrl下降"
    infoLabel.TextWrapped = true
    infoLabel.Parent = mainFrame

    return screenGui
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

    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return boat, seat
        end
    end

    return nil
end

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

local function getPlayerMoveVector()
    local char = LocalPlayer.Character
    if not char then return Vector3.new(0, 0, 0) end

    local hum = char:FindFirstChild("Humanoid")
    if not hum then return Vector3.new(0, 0, 0) end

    local moveVec = hum.MoveDirection
    if moveVec.Magnitude > 0 then
        return moveVec
    end

    local keyboard = Vector3.new(0, 0, 0)
    local camera = workspace.CurrentCamera
    if not camera then return Vector3.new(0, 0, 0) end

    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector

    if CONTROL_STATE.moveForward then keyboard = keyboard + forward end
    if CONTROL_STATE.moveBackward then keyboard = keyboard - forward end
    if CONTROL_STATE.moveLeft then keyboard = keyboard - right end
    if CONTROL_STATE.moveRight then keyboard = keyboard + right end

    if keyboard.Magnitude > 0 then
        keyboard = keyboard.Unit
    end

    return keyboard
end

RunService.RenderStepped:Connect(function()
    if not CONFIG.ON then return end

    local boat, seat = getMyBoat()
    if not boat then return end

    seat.MaxSpeed = CONFIG.BOAT_SPEED

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

    if CONFIG.AUTO_MODE then
        VirtualInputManager:SendKeyEvent(true, "W", false, game)

        if CONFIG.FLY_HEIGHT > 0 then
            root.CFrame = CFrame.new(cf.X, CONFIG.FLY_HEIGHT, cf.Z) * CFrame.Angles(0, select(2, cf:ToEulerAnglesYXZ()), 0)
        end
    else
        local playerMove = getPlayerMoveVector()
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if camera then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            moveDir = (forward * playerMove.Z) + (right * playerMove.X)
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
        end

        local moveSpeed = CONFIG.BOAT_SPEED / 60
        local newPos = cf.Position + moveDir * moveSpeed

        if CONTROL_STATE.moveUp then
            newPos = newPos + Vector3.new(0, moveSpeed * 2, 0)
        end

        if CONTROL_STATE.moveDown then
            newPos = newPos - Vector3.new(0, moveSpeed * 2, 0)
        end

        root.CFrame = CFrame.new(newPos) * CFrame.Angles(cf:ToEulerAnglesYXZ())
    end
end)

createGui()
print("✅ Boat Fly Script loaded! GUI is ready. / ボートフライスクリプトがロードされました")
