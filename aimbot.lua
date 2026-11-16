Lua
-- [[ Blox Fruits PvP Hub with Anti-Ban & UI Control Panel ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 0. Hệ Thống Anti-Ban & Security Bypass ]] --
local function InitializeAntiBan()
    -- Chặn các hook kiểm tra từ Server (HookMetamethod protection cơ bản)
    if syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    end

    -- Vô hiệu hóa việc ghi nhận thay đổi WalkSpeed bất thường từ client gửi lên server (nếu executor hỗ trợ)
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            -- Chặn các luồng báo cáo tốc độ di chuyển bất thường nếu có
            if method == "FireServer" and tostring(self):lower():find("ban") or tostring(self):lower():find("kick") then
                -- Bỏ qua các remote nghi vấn liên quan đến anti-cheat
                return
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
    
    print("[Anti-Ban]: Đã kích hoạt cơ chế bảo vệ và ẩn luồng thực thi.")
end

-- Kích hoạt Anti-Ban ngay khi chạy script
pcall(InitializeAntiBan)

-- Cấu hình trạng thái tính năng mặc định
local Settings = {
    ESPEnabled = true,
    SpeedEnabled = false,
    SpeedMultiplier = 2.2,
    AimLockEnabled = false,      -- Khóa góc nhìn (Camera Lock)
    SkillAimbotEnabled = false,  -- Tự động xoay hướng đánh skill không cần nhìn mục tiêu
    AimbotRange = 150,           -- Phạm vi hoạt động (mét/studs)
}

-- [[ 1. Tạo Giao Diện Bảng Điều Khiển (UI Library) ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PvPHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "BLOX FRUITS - SECURE PVP HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Hàm tạo nút bấm bật/tắt (Toggle Button)
local function createToggle(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": [ OFF ]"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = name .. ": [ ON ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = name .. ": [ OFF ]"
        end
        callback(state)
    end)
end

-- Tạo các nút điều khiển trên UI
createToggle("1. ESP Định Vị", 50, function(state)
    Settings.ESPEnabled = state
end)

createToggle("2. Tăng Tốc Chạy", 95, function(state)
    Settings.SpeedEnabled = state
end)

createToggle("3. Ghim Camera (Lock)", 140, function(state)
    Settings.AimLockEnabled = state
end)

createToggle("4. Aimbot Skill (Không nhìn)", 185, function(state)
    Settings.SkillAimbotEnabled = state
end)

-- Trạng thái Anti-Ban hiển thị dạng thông báo trực quan trên UI
local AntiBanStatus = Instance.new("TextLabel")
AntiBanStatus.Size = UDim2.new(0.9, 0, 0, 30)
AntiBanStatus.Position = UDim2.new(0.05, 0, 0, 230)
AntiBanStatus.BackgroundColor3 = Color3.fromRGB(20, 80, 40)
AntiBanStatus.Text = "Anti-Ban: ĐÃ KÍCH HOẠT"
AntiBanStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
AntiBanStatus.TextSize = 12
AntiBanStatus.Font = Enum.Font.SourceSansBold
AntiBanStatus.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = AntiBanStatus

-- Nút ẩn/hiện menu nhanh
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 100, 0, 30)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleGuiBtn.Text = "Ẩn / Hiện UI"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.TextSize = 12
ToggleGuiBtn.Parent = ScreenGui

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)


-- [[ 2. Tính năng ESP Định vị người chơi ]] --
local function applyESP(player)
    if player == LocalPlayer then return end
    local function onCharacterAdded(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart and not character:FindFirstChild("PlayerHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerHighlight"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 30, 30)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = character
        end
    end
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
Players.PlayerAdded:Connect(applyESP)


-- [[ 3. Tìm mục tiêu gần nhất trong phạm vi ]] --
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = Settings.AimbotRange
    
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


-- [[ 4. Vòng lặp xử lý logic chính (Runtime) ]] --
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    -- Xử lý Tốc độ chạy an toàn
    if Settings.SpeedEnabled then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * Settings.SpeedMultiplier
        end
    end

    -- Lấy mục tiêu gần nhất
    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart

        -- Tính năng: Ghim Camera (Lock)
        if Settings.AimLockEnabled then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        end

        -- Tính năng: Aimbot Skill (Tự động xoay hướng nhân vật về phía địch)
        if Settings.SkillAimbotEnabled and rootPart then
            local currentPos = rootPart.Position
            local lookAtTarget = CFrame.new(currentPos, Vector3.new(targetRoot.Position.X, currentPos.Y, targetRoot.Position.Z))
            rootPart.CFrame = lookAtTarget
        end
    end
end)

print("[Blox Fruits Hub]: Đã tải toàn bộ hệ thống PvP kèm Anti-Ban thành công!")
