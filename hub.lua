-- [[ Blox Fruits All-in-One PvP Hub ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình tính năng (Có thể bật/tắt tùy ý)
local Settings = {
    ESPEnabled = true,        -- Bật/tắt định vị người chơi qua tường
    SpeedEnabled = true,      -- Bật/tắt tăng tốc chạy
    SpeedMultiplier = 2.2,    -- Hệ số nhân tốc độ (16 là mặc định)
    AimLockEnabled = true,    -- Bật/tắt khóa camera vào mục tiêu gần nhất
}

-- [[ 1. Tính năng ESP Định vị người chơi ]] --
local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart and not character:FindFirstChild("PlayerHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerHighlight"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 30, 30) -- Màu đỏ nổi bật
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = character
        end
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

if Settings.ESPEnabled then
    for _, player in ipairs(Players:GetPlayers()) do
        applyESP(player)
    end
    Players.PlayerAdded:Connect(applyESP)
end

-- [[ 2 & 3. Tìm mục tiêu gần nhất cho Aimbot ]] --
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and humanoid and humanoid.Health > 0 then
                local distance = (enemyRoot.Position - myPos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- [[ Vòng lặp xử lý chính (Runtime Loop) ]] --
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Xử lý Tăng tốc chạy
    if Settings.SpeedEnabled then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * Settings.SpeedMultiplier
        end
    end

    -- Xử lý Khóa mục tiêu (Skill Aimbot)
    if Settings.AimLockEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            -- Hướng camera trực diện vào kẻ địch để hỗ trợ tung chiêu chính xác
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

print("[Blox Fruits Hub]: Đã tải và kích hoạt thành công toàn bộ tính năng PvP!")
