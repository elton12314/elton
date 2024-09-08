local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local aimbotEnabled = false
local speedBoostEnabled = false  -- Novo estado para a velocidade

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ChatService = game:GetService("Chat")

local verticalOffset = 2
local normalWalkSpeed = 16  -- Velocidade padrão
local boostedWalkSpeed = 30  -- Nova velocidade aumentada

local function createESP(player)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Parent = head
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(0, 1, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Text = player.Name
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            if not player.Character.Head:FindFirstChildOfClass("BillboardGui") then
                createESP(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updateESP()
    end)
end)

updateESP()

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                closestPlayer = otherPlayer
                shortestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

local function aimAtClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, verticalOffset, 0)
        local camera = workspace.CurrentCamera
        local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)
        
        if onScreen then
            local mousePosition = Vector2.new(screenPosition.X, screenPosition.Y)
            local mouseDelta = mousePosition - Vector2.new(mouse.X, mouse.Y)
            mousemoverel(mouseDelta.X, mouseDelta.Y)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        aimAtClosestPlayer()
    end
end)

local function toggleSpeedBoost()
    speedBoostEnabled = not speedBoostEnabled
    if speedBoostEnabled then
        player.Character.Humanoid.WalkSpeed = boostedWalkSpeed
        print("Velocidade aumentada")
    else
        player.Character.Humanoid.WalkSpeed = normalWalkSpeed
        print("Velocidade normal")
    end
end

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.T and not gameProcessedEvent then
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            print("Aimbot ativado")
        else
            print("Aimbot desativado")
        end
    elseif input.KeyCode == Enum.KeyCode.Y and not gameProcessedEvent then
        toggleSpeedBoost()
    end
end)

ChatService.OnMessageDoneFiltering:Connect(function(message)
    if message.Text == "." then
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            print("Aimbot ativado pelo chat")
        else
            print("Aimbot desativado pelo chat")
        end
    elseif message.Text == "speed" then
        toggleSpeedBoost()
    end
end)
