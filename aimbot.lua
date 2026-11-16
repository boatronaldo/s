-- [[ Blox Fruits Professional PvP Hub (Centudox Style) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESPEnabled = true,
    SpeedEnabled = false,
    SpeedMultiplier = 2.0,
    AimLockEnabled = false,
    SkillAimbotEnabled = false,
    AimbotRange = 300,
    TeamCheck = true,
}

-- [1] Giao diện Hub hiện đại (Clean Hub Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CentuStyleHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Tiêu đề Hub
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CENTUDOX STYLE - PVP HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Khu vực chứa danh sách tính năng
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -16, 1, -60)
Container.Position = UDim2.new(0, 8, 0, 52)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 400)
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

-- Hàm tạo nút chuyển đổi (Toggle) kiểu dáng hiện đại
local function createToggle(name, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ToggleFrame.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.3, -12, 1, 0)
    StatusLabel.Position = UDim2.new(0.7, 0, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "OFF"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    StatusLabel.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = ToggleFrame

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            StatusLabel.Text = "ON"
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
        else
            StatusLabel.Text = "OFF"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        end
        callback(state)
    end)
end

-- Khởi tạo các tính năng trên giao diện
createToggle("ESP Định Vị Người Chơi", "Hiển thị khung nổi bật xung quanh địch", function(state)
    Settings.ESPEnabled = state
end)

createToggle("Tăng Tốc Chạy (Speed)", "Nhân hệ số tốc độ di chuyển", function(state)
    Settings.SpeedEnabled = state
end)

createToggle("Ghim Camera (Camera Lock)", "Khóa góc nhìn camera theo mục tiêu gần", function(state)
    Settings.AimLockEnabled = state
end)

createToggle("Aimbot Skill (Tự xoay hướng)", "Tự động hướng nhân vật về phía mục tiêu", function(state)
    Settings.SkillAimbotEnabled = state
end)

-- Nút thu phóng/ẩn hiện giao diện Hub nhanh
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 110, 0, 32)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ToggleGuiBtn.Text = "Ẩn / Hiện Hub"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.TextSize = 12
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [2] Hệ thống ESP định vị người chơi qua Highlight
local function applyESP(player)
    if player == LocalPlayer then return end
    local function onCharacterAdded(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart and not character:FindFirstChild("PlayerHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerHighlight"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = character
        end
    end
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
Players.PlayerAdded:Connect(applyESP)

-- [3] Thuật toán quét và tìm mục tiêu gần nhất
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = Settings.AimbotRange
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
                local char = player.Character
                if char then
                    local enemyRoot = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if enemyRoot and humanoid and humanoid.Health > 0 then
                        local distance = (enemyRoot.Position - myPos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- [4] Vòng lặp xử lý thời gian thực (Heartbeat tối ưu hóa hiệu suất)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- Xử lý tốc độ chạy
    if Settings.SpeedEnabled and humanoid then
        humanoid.WalkSpeed = 16 * Settings.SpeedMultiplier
    end

    -- Xử lý khóa camera và xoay hướng skill aimbot
    local target = getClosestTarget()
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            -- Ghim camera
            if Settings.AimLockEnabled then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
            end

            -- Aimbot skill tự động xoay hướng nhân vật mượt mà
            if Settings.SkillAimbotEnabled and rootPart then
                local targetPos = Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z)
                rootPart.CFrame = CFrame.new(rootPart.Position, targetPos)
            end
        end
    end
end)

print("[Centudox Style Hub]: Đã khởi động thành công và tối ưu hóa mượt mà!")
