-- ============================================
-- Blox Fruits / Roblox Delta 用
-- ボート飛行スクリプト（GUI付き・ドラッグ可能・最小化対応）
-- LocalScript として実行
-- ============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local STATE = {
    enabled = false,
    speed = 350,
    height = 150,
    guiVisible = true
}

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

local function getPlayerBoat()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return nil
    end

    local boatsFolder = workspace:FindFirstChild("Boats")
    if boatsFolder then
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            local seat = boat:FindFirstChild("VehicleSeat")
            if seat and seat.Occupant == humanoid then
                return boat, seat
            end
        end
    end

    local seatPart = humanoid.SeatPart
    if seatPart and (seatPart:IsA("VehicleSeat") or seatPart:IsA("Seat")) then
        return seatPart.Parent, seatPart
    end

    return nil
end

-- ===== GUI作成 =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoatFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 290, 0, 280)
mainFrame.Position = UDim2.new(0, 20, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 32, 38)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = Color3.fromRGB(42, 48, 57)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚤 Boat Fly"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 17
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 24, 0, 24)
miniButton.Position = UDim2.new(1, -56, 0, 5)
miniButton.BackgroundColor3 = Color3.fromRGB(100, 105, 118)
miniButton.Text = "_"
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
miniButton.TextSize = 18
miniButton.Font = Enum.Font.GothamBold
miniButton.Parent = titleBar

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 8)
miniCorner.Parent = miniButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -42)
content.Position = UDim2.new(0, 8, 0, 38)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 38)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    STATE.enabled = not STATE.enabled
    toggleBtn.Text = STATE.enabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = STATE.enabled and Color3.fromRGB(50, 180, 90) or Color3.fromRGB(180, 40, 40)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 22)
speedLabel.Position = UDim2.new(0, 0, 0, 52)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "速度: 350"
speedLabel.TextColor3 = Color3.fromRGB(215, 220, 230)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = content

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, 0, 0, 34)
speedBox.Position = UDim2.new(0, 0, 0, 76)
speedBox.BackgroundColor3 = Color3.fromRGB(46, 52, 62)
speedBox.BorderSizePixel = 1
speedBox.BorderColor3 = Color3.fromRGB(120, 170, 255)
speedBox.Text = tostring(STATE.speed)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 15
speedBox.Font = Enum.Font.Gotham
speedBox.Parent = content

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBox

speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)
    if value then
        STATE.speed = clamp(value, 50, 2000)
        speedBox.Text = tostring(STATE.speed)
    else
        speedBox.Text = tostring(STATE.speed)
    end
    speedLabel.Text = "速度: " .. tostring(STATE.speed)
end)

local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(1, 0, 0, 22)
heightLabel.Position = UDim2.new(0, 0, 0, 120)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "高さ: 150"
heightLabel.TextColor3 = Color3.fromRGB(215, 220, 230)
heightLabel.TextSize = 13
heightLabel.Font = Enum.Font.GothamBold
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = content

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(1, 0, 0, 34)
heightBox.Position = UDim2.new(0, 0, 0, 144)
heightBox.BackgroundColor3 = Color3.fromRGB(46, 52, 62)
heightBox.BorderSizePixel = 1
heightBox.BorderColor3 = Color3.fromRGB(120, 170, 255)
heightBox.Text = tostring(STATE.height)
heightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
heightBox.TextSize = 15
heightBox.Font = Enum.Font.Gotham
heightBox.Parent = content

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 8)
heightCorner.Parent = heightBox

heightBox.FocusLost:Connect(function()
    local value = tonumber(heightBox.Text)
    if value then
        STATE.height = clamp(value, 0, 500)
        heightBox.Text = tostring(STATE.height)
    else
        heightBox.Text = tostring(STATE.height)
    end
    heightLabel.Text = "高さ: " .. tostring(STATE.height)
end)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 80)
info.Position = UDim2.new(0, 0, 0, 190)
info.BackgroundColor3 = Color3.fromRGB(38, 44, 52)
info.Text = "W/S: 前後\nA/D: 左右\nSpace: 上昇\nCtrl: 下降\nTab: GUI切替"
info.TextColor3 = Color3.fromRGB(180, 200, 240)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.Parent = content

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = info

-- ===== GUIドラッグ =====
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===== 最小化 =====
local minimized = false
local defaultHeight = 280
local minHeight = 42

miniButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        content.Visible = false
        mainFrame.Size = UDim2.new(0, 290, 0, 42)
        miniButton.Text = "□"
    else
        content.Visible = true
        mainFrame.Size = UDim2.new(0, 290, 0, defaultHeight)
        miniButton.Text = "_"
    end
end)

-- ===== GUI表示/非表示切替 =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        STATE.guiVisible = not STATE.guiVisible
        mainFrame.Visible = STATE.guiVisible
    end
end)

-- ===== ボート移動 =====
local function getMoveDirection()
    local camera = workspace.CurrentCamera
    if not camera then
        return Vector3.new(0, 0, 0)
    end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local direction = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + right
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit
    end

    return direction
end

RunService.RenderStepped:Connect(function()
    if not STATE.enabled then
        return
    end

    local boat, seat = getPlayerBoat()
    if not boat then
        return
    end

    if seat then
        seat.MaxSpeed = STATE.speed
    end

    for _, part in ipairs(boat:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    local root = boat.PrimaryPart or seat
    if not root then
        return
    end

    local moveDirection = getMoveDirection()
    local speedValue = STATE.speed / 65
    local targetPosition = root.Position

    if moveDirection.Magnitude > 0 then
        targetPosition = targetPosition + (moveDirection * speedValue)
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        targetPosition = targetPosition + Vector3.new(0, 1, 0) * speedValue
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        targetPosition = targetPosition - Vector3.new(0, 1, 0) * speedValue
    end

    targetPosition = Vector3.new(targetPosition.X, STATE.height, targetPosition.Z)

    root.CFrame = CFrame.new(targetPosition) * CFrame.Angles(root.CFrame:ToEulerAnglesXYZ())
end)

print("✅ Boat fly script loaded. GUI ready.")
