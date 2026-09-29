-- ============================================
-- ボートで空飛び（Blox Fruits用・自由移動版）
-- エクセキューターに貼って実行
-- ============================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    ENABLED = false,
    BOAT_SPEED = 350,
    FLY_HEIGHT = 150,
    GUI_VISIBLE = true,
}

local function clamp(v, min, max)
    if v < min then return min end
    if v > max then return max end
    return v
end

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

    local seatPart = hum.SeatPart
    if seatPart and (seatPart:IsA("VehicleSeat") or seatPart:IsA("Seat")) then
        return seatPart.Parent, seatPart
    end

    return nil
end

-- ===== GUI作成 =====
local gui = Instance.new("ScreenGui")
gui.Name = "BoatFlyGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 350, 0, 400)
main.Position = UDim2.new(0, 12, 0, 12)
main.BackgroundColor3 = Color3.fromRGB(26, 30, 38)
main.BorderSizePixel = 0
main.Parent = gui

local uic = Instance.new("UICorner")
uic.CornerRadius = UDim.new(0, 14)
uic.Parent = main

-- タイトルバー
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(43, 52, 67)
title.Text = "🚤 ボートフライ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 15)
titlePadding.Parent = title

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = title

-- 閉じるボタン
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -40, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- コンテンツフレーム
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -30, 1, -60)
content.Position = UDim2.new(0, 15, 0, 50)
content.BackgroundTransparency = 1
content.Parent = main

-- ON/OFFボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    CONFIG.ENABLED = not CONFIG.ENABLED
    toggleButton.Text = CONFIG.ENABLED and "ON" or "OFF"
    toggleButton.BackgroundColor3 = CONFIG.ENABLED and Color3.fromRGB(52, 196, 92) or Color3.fromRGB(180, 40, 40)
end)

-- 速度ラベル
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 55)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "速度: 350"
speedLabel.TextColor3 = Color3.fromRGB(215, 220, 230)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = content

-- 速度入力ボックス
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, 0, 0, 35)
speedInput.Position = UDim2.new(0, 0, 0, 82)
speedInput.BackgroundColor3 = Color3.fromRGB(46, 52, 62)
speedInput.Text = tostring(CONFIG.BOAT_SPEED)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 15
speedInput.Font = Enum.Font.Gotham
speedInput.BorderSizePixel = 1
speedInput.BorderColor3 = Color3.fromRGB(120, 170, 255)
speedInput.Parent = content

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 10)
speedCorner.Parent = speedInput

speedInput.FocusLost:Connect(function()
    local v = tonumber(speedInput.Text)
    if v then
        CONFIG.BOAT_SPEED = clamp(v, 50, 1500)
        speedInput.Text = tostring(CONFIG.BOAT_SPEED)
        speedLabel.Text = "速度: " .. tostring(CONFIG.BOAT_SPEED)
    else
        speedInput.Text = tostring(CONFIG.BOAT_SPEED)
    end
end)

-- 高さラベル
local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(1, 0, 0, 25)
heightLabel.Position = UDim2.new(0, 0, 0, 130)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "高さ: 150"
heightLabel.TextColor3 = Color3.fromRGB(215, 220, 230)
heightLabel.TextSize = 13
heightLabel.Font = Enum.Font.GothamBold
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = content

-- 高さ入力ボックス
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(1, 0, 0, 35)
heightInput.Position = UDim2.new(0, 0, 0, 157)
heightInput.BackgroundColor3 = Color3.fromRGB(46, 52, 62)
heightInput.Text = tostring(CONFIG.FLY_HEIGHT)
heightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
heightInput.TextSize = 15
heightInput.Font = Enum.Font.Gotham
heightInput.BorderSizePixel = 1
heightInput.BorderColor3 = Color3.fromRGB(120, 170, 255)
heightInput.Parent = content

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 10)
heightCorner.Parent = heightInput

heightInput.FocusLost:Connect(function()
    local v = tonumber(heightInput.Text)
    if v then
        CONFIG.FLY_HEIGHT = clamp(v, 0, 500)
        heightInput.Text = tostring(CONFIG.FLY_HEIGHT)
        heightLabel.Text = "高さ: " .. tostring(CONFIG.FLY_HEIGHT)
    else
        heightInput.Text = tostring(CONFIG.FLY_HEIGHT)
    end
end)

-- 説明テキスト
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 100)
info.Position = UDim2.new(0, 0, 0, 210)
info.BackgroundColor3 = Color3.fromRGB(43, 52, 67)
info.TextColor3 = Color3.fromRGB(180, 200, 240)
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.Text = "【操作方法】\n\nW: 前進  S: 後進\nA: 左移動  D: 右移動\nSPACE: 上昇\nCTRL: 下降\n\nTAB: GUI表示切替"
info.Parent = content

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 10)
infoCorner.Parent = info

-- TABキーでGUI切り替え
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        CONFIG.GUI_VISIBLE = not CONFIG.GUI_VISIBLE
        main.Visible = CONFIG.GUI_VISIBLE
    end
end)

-- ===== 移動ベクトル取得 =====
local function getMoveVector()
    local char = LocalPlayer.Character
    if not char then return Vector3.new(0, 0, 0) end

    local hum = char:FindFirstChild("Humanoid")
    if not hum then return Vector3.new(0, 0, 0) end

    local move = hum.MoveDirection
    if move.Magnitude > 0 then
        return move
    end

    local camera = workspace.CurrentCamera
    if not camera then return Vector3.new(0, 0, 0) end

    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local dir = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end

    if dir.Magnitude > 0 then
        dir = dir.Unit
    end

    return dir
end

-- ===== メインループ =====
RunService.RenderStepped:Connect(function()
    if not CONFIG.ENABLED then return end

    local boat, seat = getMyBoat()
    if not boat then return end

    if seat then
        seat.MaxSpeed = CONFIG.BOAT_SPEED
    end

    for _, p in pairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    local root = boat.PrimaryPart or seat
    if not root then return end

    local move = getMoveVector()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local moveDir = (forward * move.Z) + (right * move.X)

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    else
        moveDir = Vector3.new(0, 0, 0)
    end

    local speed = CONFIG.BOAT_SPEED / 65
    local targetPos = root.Position

    if moveDir.Magnitude > 0 then
        targetPos = targetPos + (moveDir * speed)
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        targetPos = targetPos + (Vector3.new(0, 1, 0) * speed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        targetPos = targetPos - (Vector3.new(0, 1, 0) * speed)
    end

    if CONFIG.FLY_HEIGHT > 0 then
        targetPos = Vector3.new(targetPos.X, CONFIG.FLY_HEIGHT, targetPos.Z)
    end

    root.CFrame = CFrame.new(targetPos) * CFrame.Angles(root.CFrame:ToEulerAnglesXYZ())
end)

print("✅ Boat Fly loaded. GUI ready. ON/OFF で開始")
