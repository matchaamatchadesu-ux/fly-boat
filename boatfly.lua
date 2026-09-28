-- ============================================
-- ボートで空飛び（Blox Fruits用・抜粋版）
-- エクセキューターに貼って実行
-- ============================================
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===== 設定 =====
local BOAT_SPEED = 350      -- ボート速度（大きいほど速い）
local FLY_HEIGHT = 150      -- 飛行する高さ（0にすると普通に海を走る）
local ON = true             -- ON/OFF切り替え（trueで飛行開始）
-- ================

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

RunService.RenderStepped:Connect(function()
    if not ON then return end
    local boat, seat = getMyBoat()
    if not boat then return end

    -- 1. 速度アップ
    seat.MaxSpeed = BOAT_SPEED

    -- 2. ボートと自分の当たり判定をOFF
    for _, p in pairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- 3. Wキーを押しっぱなしにして前進
    VirtualInputManager:SendKeyEvent(true, "W", false, game)

    -- 4. 高さを固定して「空飛び」にする
    if FLY_HEIGHT > 0 then
        local root = boat.PrimaryPart or seat
        local cf = root.CFrame
        root.CFrame = CFrame.new(cf.X, FLY_HEIGHT, cf.Z) * CFrame.Angles(0, select(2, cf:ToEulerAnglesYXZ()), 0)
    end
end)
