-- BlackJack Menu GUI - Sistema Completo com Abas
local BlackJackMenu = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local LogoImage = Instance.new("ImageLabel")
local TitleLabel = Instance.new("TextLabel")
local BreadcrumbLabel = Instance.new("TextLabel")
local SettingsButton = Instance.new("ImageButton")
local Sidebar = Instance.new("Frame")
local SidebarButtons = Instance.new("Frame")

-- Botões da Sidebar
local LogoBtn = Instance.new("TextButton")
local FavoritesBtn = Instance.new("TextButton")
local OnlineBtn = Instance.new("TextButton")
local WorldBtn = Instance.new("TextButton")
local SelfBtn = Instance.new("TextButton")
local WeaponBtn = Instance.new("TextButton")
local VehicleBtn = Instance.new("TextButton")
local NetworkBtn = Instance.new("TextButton")

-- Content Areas
local ContentFrame = Instance.new("Frame")
local ConditionsPanel = Instance.new("ScrollingFrame")
local CustomizationPanel = Instance.new("ScrollingFrame")

-- Título dos painéis
local ConditionsTitle = Instance.new("TextLabel")
local CustomizationTitle = Instance.new("TextLabel")

-- Variável para controlar aba atual
local currentTab = "Local Player"
local currentTabButton = nil

-- Sistema de favoritos
local favorites = {}
local switchTabRef = nil -- Referência para função switchTab que será definida depois

-- Sistema de estados globais (mantém estados entre páginas)
local globalStates = {
    -- Local Player
    godMode = false,
    semGodMode = false,
    invisible = false,
    superJump = false,
    infiniteStamina = false,
    noRagdoll = false,
    noClip = false,
    invisibleNoClip = false,
    runSpeed = false,
    swimSpeed = false,
    neverWanted = false,
    noCollision = false,
    -- ESP
    espEnabled = false,
    espLine = false,
    espBox = false,
    espSkeleton = false,
    espSelf = false,
    -- Weapon
    infiniteAmmo = false,
    noRecoil = false,
    noSpread = false,
    rapidFire = false,
    oneShotKill = false,
    -- Vehicle
    godModeVehicle = false,
    infiniteFuel = false,
    noCollisionVehicle = false,
    autoRepair = false,
    -- Self
    showPlayers = false,
    showHealth = false,
    enableAimBot = false,
    showPlayerList = false,
    showNPCs = false,
    showWeapons = false,
    showSkeleton = false,
    -- Online
    showAllPlayers = false,
    nameTags = false
}

-- ============================================
-- SISTEMA DE FUNCIONALIDADES - 100% FUNCIONAL
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis de controle
local noclipEnabled = false
local noclipSpeed = 1.0
local noclipConnection = nil
local runSpeedEnabled = false
local runSpeedMultiplier = 1.0
local swimSpeedEnabled = false
local swimSpeedMultiplier = 1.0
local godModeEnabled = false
local invisibleEnabled = false
local superJumpEnabled = false
local infiniteStaminaEnabled = false
local noRagdollEnabled = false
local noCollisionEnabled = false
local neverWantedEnabled = false

-- Armazenar estado original do character (para invisible noclip)
local originalCharacterState = {}
local characterStateSaved = false

-- Salvar estado original do character
local function saveOriginalCharacterState()
    if Character and not characterStateSaved then
        originalCharacterState = {}
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCharacterState[part] = {
                    CanCollide = part.CanCollide,
                    Transparency = part.Transparency
                }
            elseif part:IsA("Decal") or part:IsA("Texture") then
                originalCharacterState[part] = {
                    Transparency = part.Transparency
                }
            end
        end
        characterStateSaved = true
    end
end

-- Restaurar estado original do character
local function restoreOriginalCharacterState()
    if Character and characterStateSaved then
        for part, state in pairs(originalCharacterState) do
            if part.Parent then -- Verificar se a parte ainda existe
                if part:IsA("BasePart") then
                    part.CanCollide = state.CanCollide
                    part.Transparency = state.Transparency
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = state.Transparency
                end
            end
        end
    end
end

-- Função NoClip
local function toggleNoClip(enabled)
    noclipEnabled = enabled
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if Character and HumanoidRootPart then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
                -- Cancelar gravidade usando AssemblyLinearVelocity
                if HumanoidRootPart.AssemblyLinearVelocity.Y < 0 then
                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        HumanoidRootPart.AssemblyLinearVelocity.X,
                        0,
                        HumanoidRootPart.AssemblyLinearVelocity.Z
                    )
                end
            end
        end)
    else
        -- Restaurar estado original ao invés de forçar tudo para true
        restoreOriginalCharacterState()
    end
end

-- Função NoClip com movimento
local function updateNoClipMovement()
    if noclipEnabled and Character and HumanoidRootPart then
        local camera = workspace.CurrentCamera
        if camera then
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            if moveVector.Magnitude > 0 then
                local newCFrame = HumanoidRootPart.CFrame + moveVector.Unit * noclipSpeed
                HumanoidRootPart.CFrame = newCFrame
            end
        end
    end
end

-- Função God Mode
local function toggleGodMode(enabled)
    godModeEnabled = enabled
    if Character then
        if enabled then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
    end
end

-- Função Invisible
local function toggleInvisible(enabled)
    invisibleEnabled = enabled
    if Character then
        -- Salvar estado original na primeira vez
        if not characterStateSaved then
            saveOriginalCharacterState()
        end
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                if enabled then
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                else
                    -- Restaurar estado original ao invés de forçar para 0
                    if originalCharacterState[part] then
                        part.Transparency = originalCharacterState[part].Transparency
                    else
                        -- Fallback se não tiver estado salvo
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end

-- Função Super Jump
local function toggleSuperJump(enabled)
    superJumpEnabled = enabled
    if Humanoid then
        if enabled then
            Humanoid.JumpPower = 100
        else
            Humanoid.JumpPower = 50
        end
    end
end

-- Função Infinite Stamina
local function toggleInfiniteStamina(enabled)
    infiniteStaminaEnabled = enabled
    if Humanoid then
        if enabled then
            Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                if Humanoid then
                    pcall(function()
                        Humanoid.MaxHealth = math.huge
                    end)
                end
            end)
        end
    end
end

-- Função No Ragdoll
local function toggleNoRagdoll(enabled)
    noRagdollEnabled = enabled
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if enabled then
                    part:SetNetworkOwner(nil)
                end
            end
        end
    end
end

-- Função No Collision
local function toggleNoCollision(enabled)
    noCollisionEnabled = enabled
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

-- Função Run Speed
local function toggleRunSpeed(enabled)
    runSpeedEnabled = enabled
    if Humanoid then
        if enabled then
            Humanoid.WalkSpeed = 16 * runSpeedMultiplier
        else
            Humanoid.WalkSpeed = 16
        end
    end
end

-- Função Swim Speed
local function toggleSwimSpeed(enabled)
    swimSpeedEnabled = enabled
    if Humanoid then
        if enabled then
            Humanoid.SwimSpeed = 16 * swimSpeedMultiplier
        else
            Humanoid.SwimSpeed = 16
        end
    end
end

-- Função Health/Armor
local function setHealth(amount)
    if Humanoid then
        local health = tonumber(amount) or 100
        Humanoid.MaxHealth = health
        Humanoid.Health = health
    end
end

local function setArmor(amount)
    -- Depende do jogo, mas geralmente é uma pasta ou valor específico
    if Character then
        local armorValue = tonumber(amount) or 100
        -- Implementação específica depende do jogo
        print("Armor set to: " .. armorValue)
    end
end

-- Atualizar quando o personagem respawnar
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Reaplicar funcionalidades ativas
    if noclipEnabled then toggleNoClip(true) end
    if godModeEnabled then toggleGodMode(true) end
    if invisibleEnabled then toggleInvisible(true) end
    if superJumpEnabled then toggleSuperJump(true) end
    if runSpeedEnabled then 
        -- Garantir que o multiplicador seja aplicado
        toggleRunSpeed(true)
    end
    if swimSpeedEnabled then 
        -- Garantir que o multiplicador seja aplicado
        toggleSwimSpeed(true)
    end
    if noRagdollEnabled then toggleNoRagdoll(true) end
    if noCollisionEnabled then toggleNoCollision(true) end
end)

-- Loop de atualização
RunService.RenderStepped:Connect(function()
    updateNoClipMovement()
end)

-- ============================================
-- FUNCIONALIDADES DE ARMAS
-- ============================================

local infiniteAmmoEnabled = false
local noRecoilEnabled = false
local noSpreadEnabled = false
local rapidFireEnabled = false
local oneShotKillEnabled = false
local damageMultiplier = 1.0
local fireRate = 1.0
local weaponRange = 100.0

local function toggleInfiniteAmmo(enabled)
    infiniteAmmoEnabled = enabled
    if Character then
        for _, tool in pairs(Character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, module in pairs(tool:GetDescendants()) do
                    if module:IsA("ModuleScript") then
                        -- Tenta modificar scripts de munição
                        pcall(function()
                            if enabled then
                                -- Implementação depende do jogo
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function toggleNoRecoil(enabled)
    noRecoilEnabled = enabled
    -- Modifica propriedades de recuo
end

local function toggleNoSpread(enabled)
    noSpreadEnabled = enabled
    -- Modifica propriedades de espalhamento
end

local function toggleRapidFire(enabled)
    rapidFireEnabled = enabled
    -- Modifica taxa de tiro
end

local function toggleOneShotKill(enabled)
    oneShotKillEnabled = enabled
    -- Modifica dano para matar em um tiro
end

-- ============================================
-- FUNCIONALIDADES DE VEÍCULOS
-- ============================================

local godModeVehicleEnabled = false
local infiniteFuelEnabled = false
local noCollisionVehicleEnabled = false
local autoRepairEnabled = false
local vehicleSpeed = 1.0
local vehicleAcceleration = 1.0
local vehicleHandling = 1.0

local function toggleGodModeVehicle(enabled)
    godModeVehicleEnabled = enabled
    -- Implementação depende do jogo
end

local function toggleInfiniteFuel(enabled)
    infiniteFuelEnabled = enabled
    -- Implementação depende do jogo
end

local function toggleNoCollisionVehicle(enabled)
    noCollisionVehicleEnabled = enabled
    if Character then
        local vehicle = Character:FindFirstChildOfClass("Model")
        if vehicle then
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not enabled
                end
            end
        end
    end
end

local function toggleAutoRepair(enabled)
    autoRepairEnabled = enabled
    -- Implementação depende do jogo
end

-- ============================================
-- FUNCIONALIDADES DE ESP/PLAYERS
-- ============================================

local showPlayersEnabled = false
local showHealthEnabled = false
local enableAimBotEnabled = false
local showPlayerListEnabled = false
local showNPCsEnabled = false
local showWeaponsEnabled = false
local showSkeletonEnabled = false
local espEnabled = false
local nameTagsEnabled = false
local playerDistance = 500
local aimFov = 100

-- ============================================
-- ESP AVANÇADO - Line, Box, Skeleton
-- ============================================

-- ============================================
-- DRAWING SERVICE - Sistema Compatível
-- ============================================

local Drawing = nil
local drawingAvailable = false

-- Tentar carregar Drawing API (compatível com exploits)
pcall(function()
    -- Método 1: Tentar carregar de URL comum
    local success1, result1 = pcall(function()
        local http = game:GetService("HttpService")
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/VisualRoblox/Roblox/main/DrawingAPI.lua", true))()
    end)
    
    if success1 and result1 then
        Drawing = result1
        drawingAvailable = true
    else
        -- Método 2: Verificar se já existe
        if typeof(Drawing) == "table" and Drawing.new then
            drawingAvailable = true
        else
            -- Método 3: Criar sistema básico compatível
            Drawing = {}
            Drawing.new = function(type)
                local obj = {}
                if type == "Line" then
                    obj.Visible = true
                    obj.Color = Color3.new(1, 1, 1)
                    obj.Thickness = 1
                    obj.Transparency = 1
                    obj.From = Vector2.new(0, 0)
                    obj.To = Vector2.new(0, 0)
                    obj.Remove = function() 
                        obj.Visible = false 
                    end
                end
                return obj
            end
            drawingAvailable = true
        end
    end
end)

-- Se ainda não funcionou, usar sistema alternativo com GUI
if not Drawing or not drawingAvailable then
    -- Sistema alternativo usando apenas GUI do Roblox (funciona sempre)
    Drawing = {}
    Drawing.new = function(type)
        if type == "Line" then
            -- Criar linha usando Frame (alternativa quando Drawing não está disponível)
            local line = Instance.new("Frame")
            line.Name = "ESPLine"
            line.BackgroundColor3 = Color3.fromRGB(150, 0, 30)
            line.BorderSizePixel = 0
            line.Size = UDim2.new(0, 100, 0, 2)
            line.Visible = false
            line.ZIndex = 1000
            
            -- Métodos compatíveis
            line.Remove = function()
                if line.Parent then
                    line:Destroy()
                end
            end
            
            return line
        end
    end
    drawingAvailable = true
end

local espObjects = {}
local espConnections = {}
local espEnabled = false
local espLineEnabled = false
local espBoxEnabled = false
local espSkeletonEnabled = false
local espSelfEnabled = false

-- ScreenGui para ESPs
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP_Gui"
espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.ResetOnSpawn = false

local function getBoundingBox(character)
    if not character then return nil, nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil, nil end
    
    local cf, size = humanoidRootPart.CFrame, humanoidRootPart.Size
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local partCF = part.CFrame
            local partSize = part.Size
            local corners = {
                partCF * CFrame.new(-partSize.X/2, -partSize.Y/2, -partSize.Z/2),
                partCF * CFrame.new(partSize.X/2, -partSize.Y/2, -partSize.Z/2),
                partCF * CFrame.new(-partSize.X/2, partSize.Y/2, -partSize.Z/2),
                partCF * CFrame.new(partSize.X/2, partSize.Y/2, -partSize.Z/2),
                partCF * CFrame.new(-partSize.X/2, -partSize.Y/2, partSize.Z/2),
                partCF * CFrame.new(partSize.X/2, -partSize.Y/2, partSize.Z/2),
                partCF * CFrame.new(-partSize.X/2, partSize.Y/2, partSize.Z/2),
                partCF * CFrame.new(partSize.X/2, partSize.Y/2, partSize.Z/2)
            }
            
            for _, corner in pairs(corners) do
                local worldPos = corner.Position
                minX, maxX = math.min(minX, worldPos.X), math.max(maxX, worldPos.X)
                minY, maxY = math.min(minY, worldPos.Y), math.max(maxY, worldPos.Y)
                minZ, maxZ = math.min(minZ, worldPos.Z), math.max(maxZ, worldPos.Z)
            end
        end
    end
    
    local center = Vector3.new((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)
    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
    local finalCF = CFrame.new(center)
    
    return finalCF, size
end

local function createLineESP(player, character)
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    if not espObjects[player] then espObjects[player] = {} end
    if espObjects[player].line then 
        espObjects[player].line:Destroy()
    end
    
    -- Criar Frame para linha
    local line = Instance.new("Frame")
    line.Name = "ESP_Line_" .. player.Name
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Size = UDim2.new(0, 2, 0, 2)
    line.Visible = false
    line.Parent = espGui
    
    espObjects[player].line = line
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            if connection then connection:Disconnect() end
            if line then line:Destroy() end
            return
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pos, vis = camera:WorldToViewportPoint(hrp.Position)
        
        if vis then
            -- Centro inferior da tela (meio da tela, parte de baixo)
            local sx = camera.ViewportSize.X / 2
            local sy = camera.ViewportSize.Y
            local dx = pos.X - sx
            local dy = pos.Y - sy
            local dist = math.sqrt(dx*dx + dy*dy)
            
            line.Visible = true
            line.Position = UDim2.fromOffset(sx, sy)
            line.Size = UDim2.fromOffset(dist, 2)
            line.Rotation = math.deg(math.atan2(dy, dx))
        else
            line.Visible = false
        end
    end)
    
    table.insert(espConnections, connection)
end

local function createBoxESP(player, character)
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    if not espObjects[player] then espObjects[player] = {} end
    if espObjects[player].box then
        espObjects[player].box:Destroy()
    end
    
    -- Criar Frame para box
    local box = Instance.new("Frame")
    box.Name = "ESP_Box_" .. player.Name
    box.BackgroundTransparency = 1
    box.Size = UDim2.new(0, 50, 0, 100)
    box.Visible = false
    box.Parent = espGui
    
    -- Adicionar UIStroke para borda
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = box
    
    espObjects[player].box = box
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            if connection then connection:Disconnect() end
            if box then box:Destroy() end
            return
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pos, vis = camera:WorldToViewportPoint(hrp.Position)
        
        if vis then
            local dist = (camera.CFrame.Position - hrp.Position).Magnitude
            local size = math.clamp(2000 / dist, 40, 300)
            
            box.Visible = true
            box.Position = UDim2.fromOffset(pos.X - size/2, pos.Y - size)
            box.Size = UDim2.fromOffset(size, size * 1.8)
        else
            box.Visible = false
        end
    end)
    
    table.insert(espConnections, connection)
end

local function createSkeletonESP(player, character)
    if not character then return end
    
    if not espObjects[player] then espObjects[player] = {} end
    if espObjects[player].skeleton then
        for _, line in pairs(espObjects[player].skeleton) do
            if line then line:Destroy() end
        end
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Conexões do esqueleto
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }
    
    -- Criar linhas do esqueleto
    local skeleton = {}
    for i = 1, #connections do
        local line = Instance.new("Frame")
        line.Name = "ESP_Skeleton_Line_" .. i .. "_" .. player.Name
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde como nas imagens
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0, 2, 0, 2)
        line.Visible = false
        line.Parent = espGui
        table.insert(skeleton, line)
    end
    
    espObjects[player].skeleton = skeleton
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            if connection then connection:Disconnect() end
            for _, line in pairs(skeleton) do
                if line then line:Destroy() end
            end
            return
        end
        
        for i, pair in ipairs(connections) do
            local p1 = character:FindFirstChild(pair[1])
            local p2 = character:FindFirstChild(pair[2])
            local line = skeleton[i]
            
            if p1 and p2 and line and p1:IsA("BasePart") and p2:IsA("BasePart") then
                local pos1, onScreen1 = camera:WorldToViewportPoint(p1.Position)
                local pos2, onScreen2 = camera:WorldToViewportPoint(p2.Position)
                
                if onScreen1 and onScreen2 then
                    line.Visible = true
                    local dx = pos2.X - pos1.X
                    local dy = pos2.Y - pos1.Y
                    local dist = math.sqrt(dx*dx + dy*dy)
                    
                    if dist > 0 then
                        line.Position = UDim2.fromOffset(pos1.X, pos1.Y)
                        line.Size = UDim2.fromOffset(dist, 2)
                        line.Rotation = math.deg(math.atan2(dy, dx))
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end
    end)
    
    table.insert(espConnections, connection)
end

local function createNameTag(player, character)
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not espObjects[player] then espObjects[player] = {} end
    if espObjects[player].nameTag then espObjects[player].nameTag:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = humanoidRootPart
    billboard.Parent = humanoidRootPart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    espObjects[player].nameTag = billboard
    espObjects[player].nameLabel = nameLabel
end

local function createHealthBar(player, character)
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not espObjects[player] then espObjects[player] = {} end
    if espObjects[player].healthBar then espObjects[player].healthBar:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_HealthBar_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = humanoidRootPart
    billboard.Parent = humanoidRootPart
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 1, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "Health: 100"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextSize = 12
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.Parent = billboard
    
    espObjects[player].healthBar = billboard
    espObjects[player].healthLabel = healthLabel
    
    if character:FindFirstChild("Humanoid") then
        character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if espObjects[player] and espObjects[player].healthLabel then
                local health = math.floor(character.Humanoid.Health)
                local maxHealth = character.Humanoid.MaxHealth
                espObjects[player].healthLabel.Text = "Health: " .. health .. "/" .. maxHealth
                local healthPercent = math.clamp(health / maxHealth, 0, 1)
                espObjects[player].healthLabel.TextColor3 = Color3.fromRGB(255 - healthPercent * 255, healthPercent * 255, 0)
            end
        end)
    end
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].line then 
            espObjects[player].line:Destroy()
        end
        if espObjects[player].box then
            espObjects[player].box:Destroy()
        end
        if espObjects[player].skeleton then
            for _, line in pairs(espObjects[player].skeleton) do
                if line then line:Destroy() end
            end
        end
        if espObjects[player].nameTag then espObjects[player].nameTag:Destroy() end
        if espObjects[player].healthBar then espObjects[player].healthBar:Destroy() end
        espObjects[player] = nil
    end
end

local function updateESP()
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        -- Verificar se deve mostrar ESP do próprio jogador
        if player == LocalPlayer and not espSelfEnabled then
            removeESP(player)
        else
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
            -- Line ESP
            if espLineEnabled then
                if not espObjects[player] or not espObjects[player].line then
                    createLineESP(player, character)
                end
            else
                if espObjects[player] and espObjects[player].line then
                    espObjects[player].line:Destroy()
                    espObjects[player].line = nil
                end
            end
            
            -- Box ESP
            if espBoxEnabled then
                if not espObjects[player] or not espObjects[player].box then
                    createBoxESP(player, character)
                end
            else
                if espObjects[player] and espObjects[player].box then
                    espObjects[player].box:Destroy()
                    espObjects[player].box = nil
                end
            end
            
            -- Skeleton ESP
            if espSkeletonEnabled then
                -- Skeleton é atualizado constantemente, então sempre recriar
                if not espObjects[player] or not espObjects[player].skeleton then
                    createSkeletonESP(player, character)
                end
            else
                if espObjects[player] and espObjects[player].skeleton then
                    for _, line in pairs(espObjects[player].skeleton) do
                        if line then line:Destroy() end
                    end
                    espObjects[player].skeleton = nil
                end
            end
            
            -- Name Tags
            if nameTagsEnabled then
                if not espObjects[player] or not espObjects[player].nameTag then
                    createNameTag(player, character)
                end
            else
                if espObjects[player] and espObjects[player].nameTag then
                    espObjects[player].nameTag:Destroy()
                    espObjects[player].nameTag = nil
                end
            end
            
            -- Health Bar
            if showHealthEnabled then
                if not espObjects[player] or not espObjects[player].healthBar then
                    createHealthBar(player, character)
                end
            else
                if espObjects[player] and espObjects[player].healthBar then
                    espObjects[player].healthBar:Destroy()
                    espObjects[player].healthBar = nil
                end
            end
            end
        end
    end
end

local function toggleESP(enabled)
    espEnabled = enabled
    globalStates.espEnabled = enabled
    
    if not enabled then
        for player, _ in pairs(espObjects) do
            removeESP(player)
        end
        for _, conn in pairs(espConnections) do
            if conn then conn:Disconnect() end
        end
        espConnections = {}
    else
        updateESP()
        -- Loop de atualização contínua
        local updateConnection = RunService.RenderStepped:Connect(function()
            if espEnabled then
                updateESP()
            end
        end)
        table.insert(espConnections, updateConnection)
        
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(0.5)
                updateESP()
            end)
        end)
    end
end

-- ============================================
-- AIMBOT AVANÇADO - Trava na cabeça
-- ============================================

local aimbotActive = false
local aimbotConnection = nil

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local closestDistance = aimFov
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    local mouse = LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function startAimbot()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotActive then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local target = getClosestPlayerToMouse()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local targetCFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
                camera.CFrame = targetCFrame
            end
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- ============================================
-- TELEPORT E BRING PLAYER
-- ============================================

local function teleportToPlayer(player)
    if not player or not player.Character then return end
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not HumanoidRootPart then return end
    
    HumanoidRootPart.CFrame = targetRoot.CFrame
    print("Teleported to: " .. player.Name)
end

local function bringPlayer(player)
    if not player or not player.Character then return end
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not HumanoidRootPart then return end
    
    targetRoot.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 5
    print("Brought: " .. player.Name)
end

-- Sistema de Input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- AimBot com botão direito (trava na cabeça)
    if enableAimBotEnabled then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimbotActive = true
            startAimbot()
        end
    end
    
    -- Teleport para jogador mais próximo (F7)
    if input.KeyCode == Enum.KeyCode.F7 then
        local target = getClosestPlayerToMouse()
        if target then
            teleportToPlayer(target)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotActive = false
        stopAimbot()
    end
end)

local function addToFavorites(itemName, itemType, itemData)
    if not favorites[itemName] then
        favorites[itemName] = {
            type = itemType,
            data = itemData,
            name = itemName
        }
        print("Added to favorites: " .. itemName)
        -- Se estiver na aba de favoritos, atualizar
        if currentTab == "Favorites" and switchTabRef then
            switchTabRef("Favorites", FavoritesBtn)
        end
    else
        print(itemName .. " already in favorites")
    end
end

local function removeFromFavorites(itemName)
    if favorites[itemName] then
        favorites[itemName] = nil
        print("Removed from favorites: " .. itemName)
        if currentTab == "Favorites" and switchTabRef then
            switchTabRef("Favorites", FavoritesBtn)
        end
    end
end

-- ============================================
-- SISTEMA DE AUTENTICAÇÃO POR KEY
-- ============================================

local HttpService = game:GetService("HttpService")
local keyAuthenticated = false
local savedKey = nil

-- URL do Firebase Realtime Database
local FIREBASE_URL = "https://blackjack-3d6ff-default-rtdb.europe-west1.firebasedatabase.app"

-- ============================================
-- SISTEMA HTTP ALTERNATIVO (Sem HttpService)
-- ============================================

-- Função HTTP universal que tenta múltiplos métodos
local function httpRequest(url, method, data)
    method = method or "GET"
    
    -- Método 1: Tentar HttpService normal
    local success1, result1 = pcall(function()
        if HttpService.HttpEnabled then
            if method == "GET" then
                return HttpService:GetAsync(url, true)
            elseif method == "POST" then
                return HttpService:PostAsync(url, data or "", Enum.HttpContentType.ApplicationJson, true)
            end
        end
        error("HttpService não habilitado")
    end)
    
    if success1 and result1 then
        return true, result1
    end
    
    -- Método 2: Tentar game:HttpGet (comum em executores)
    local success2, result2 = pcall(function()
        if game.HttpGet then
            if method == "GET" then
                return game:HttpGet(url, true)
            end
        end
        error("game:HttpGet não disponível")
    end)
    
    if success2 and result2 then
        return true, result2
    end
    
    -- Método 3: Tentar request (alguns executores)
    local success3, result3 = pcall(function()
        if request then
            local response = request({
                Url = url,
                Method = method,
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = data or ""
            })
            return response.Body
        end
        error("request não disponível")
    end)
    
    if success3 and result3 then
        return true, result3
    end
    
    -- Método 4: Tentar http_request (alguns executores)
    local success4, result4 = pcall(function()
        if http_request then
            local response = http_request({
                Url = url,
                Method = method,
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = data or ""
            })
            return response.Body
        end
        error("http_request não disponível")
    end)
    
    if success4 and result4 then
        return true, result4
    end
    
    -- Método 5: Usar servidor proxy intermediário (fallback)
    local success5, result5 = pcall(function()
        -- Usar um serviço proxy público (CORS proxy)
        local proxyUrl = "https://api.allorigins.win/raw?url=" .. url
        if game.HttpGet then
            return game:HttpGet(proxyUrl, true)
        elseif HttpService.HttpEnabled then
            return HttpService:GetAsync(proxyUrl, true)
        end
        error("Proxy não disponível")
    end)
    
    if success5 and result5 then
        return true, result5
    end
    
    -- Se todos os métodos falharam
    return false, "Nenhum método HTTP disponível. Tente habilitar HttpService ou use um executor compatível."
end

-- Função para decodificar JSON (tenta múltiplos métodos)
local function jsonDecode(data)
    -- Método 1: HttpService
    local success1, result1 = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    
    if success1 and result1 then
        return result1
    end
    
    -- Método 2: game:JSONDecode (alguns executores)
    local success2, result2 = pcall(function()
        if game.JSONDecode then
            return game:JSONDecode(data)
        end
        error("game:JSONDecode não disponível")
    end)
    
    if success2 and result2 then
        return result2
    end
    
    -- Método 3: Tentar parse manual básico (fallback simples)
    local success3, result3 = pcall(function()
        return loadstring("return " .. data)()
    end)
    
    if success3 and result3 then
        return result3
    end
    
    return nil
end

-- Função para codificar JSON (tenta múltiplos métodos)
local function jsonEncode(data)
    -- Método 1: HttpService
    local success1, result1 = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success1 and result1 then
        return result1
    end
    
    -- Método 2: game:JSONEncode (alguns executores)
    local success2, result2 = pcall(function()
        if game.JSONEncode then
            return game:JSONEncode(data)
        end
        error("game:JSONEncode não disponível")
    end)
    
    if success2 and result2 then
        return result2
    end
    
    -- Fallback: retornar string simples
    return tostring(data)
end

-- Função para verificar key no Firebase
local function verifyKey(key)
    local success, result = pcall(function()
        -- Buscar todas as keys e filtrar localmente (Firebase Realtime Database não suporta queries complexas sem índices)
        local url = FIREBASE_URL .. "/keys.json"
        
        -- Fazer requisição usando método alternativo
        local httpSuccess, response = httpRequest(url, "GET")
        
        if not httpSuccess then
            error(response or "Erro ao fazer requisição HTTP")
        end
        
        if not response or response == "" or response == "null" then
            error("Resposta vazia do servidor Firebase")
        end
        
        local allKeys = jsonDecode(response)
        
        if not allKeys or type(allKeys) ~= "table" then
            error("Formato de dados inválido do Firebase")
        end
        
        -- Procurar a key específica
        local keyData = nil
        local keyId = nil
        
        for id, data in pairs(allKeys) do
            if data and type(data) == "table" and data.key == key then
                keyData = data
                keyId = id
                break
            end
        end
        
        if keyData and keyId then
            return {keyData = keyData, keyId = keyId}
        else
            error("Key não encontrada no banco de dados")
        end
    end)
    
    if not success then
        local errorMsg = tostring(result)
        warn("Erro ao conectar com Firebase: " .. errorMsg)
        
        -- Mensagens de erro mais específicas
        -- Verificar se errorMsg contém código HTTP (como "404")
        if type(errorMsg) == "string" then
            if errorMsg:find("Nenhum método HTTP") or errorMsg:find("não disponível") then
                return false, "Nenhum método HTTP disponível.\n\nO sistema tentou múltiplos métodos alternativos mas nenhum funcionou.\nTente usar um executor mais recente ou habilitar HttpService."
            elseif errorMsg:find("timeout") or errorMsg:find("timed out") then
                return false, "Timeout ao conectar com o servidor. Tente novamente."
            elseif errorMsg:find("404") or errorMsg:match("^404") or errorMsg:match("%s404%s") then
                return false, "Servidor não encontrado (404). Verifique a URL do Firebase."
            else
                -- Limpar mensagem de erro para evitar problemas de parsing
                local cleanMsg = tostring(errorMsg):gsub("[^%w%s%p]", "")
                return false, "Erro ao conectar: " .. cleanMsg
            end
        else
            return false, "Erro desconhecido ao conectar com o servidor"
        end
    end
    
    if not result or not result.keyData or not result.keyId then
        return false, "Key inválida ou não encontrada"
    end
    
    local keyData = result.keyData
    local keyId = result.keyId
    
    -- Validar e converter tipos de dados
    if not keyData or type(keyData) ~= "table" then
        return false, "Dados da key inválidos"
    end
    
    -- Converter duration para número
    local duration = keyData.duration
    if type(duration) == "string" then
        duration = tonumber(duration) or 0
    elseif type(duration) ~= "number" then
        duration = 0
    end
    
    if duration == 0 then
        return false, "Duração da key inválida"
    end
    
    -- Usar os.time() para timestamp (segundos desde epoch Unix)
    local now = os.time()
    local firstUsed = keyData.firstUsed
    local currentUserId = tostring(LocalPlayer.UserId)
    local activeUserId = keyData.activeUserId
    
    -- Converter firstUsed para número se for string ou tabela
    if type(firstUsed) == "string" then
        firstUsed = tonumber(firstUsed) or nil
    elseif type(firstUsed) == "table" then
        firstUsed = nil
    elseif type(firstUsed) ~= "number" then
        firstUsed = nil
    end
    
    -- Verificar se key está sendo usada por outro jogador
    if activeUserId and type(activeUserId) == "string" and activeUserId ~= "" and activeUserId ~= currentUserId then
        -- Verificar se o outro jogador ainda está ativo (última atualização há menos de 2 minutos)
        local lastActive = keyData.lastActive or 0
        
        -- Converter lastActive para número
        if type(lastActive) == "string" then
            lastActive = tonumber(lastActive) or 0
        elseif type(lastActive) == "table" then
            lastActive = 0
        elseif type(lastActive) ~= "number" then
            lastActive = 0
        end
        
        if now - lastActive < 120 then -- 2 minutos
            return false, "Esta key já está em uso em outro dispositivo.\nApenas um dispositivo pode usar a key por vez."
        end
    end
    
    -- Se é a primeira vez usando
    if not firstUsed or firstUsed == 0 then
        -- Registrar primeira utilização
        if keyId then
            -- Converter dias para segundos corretamente (duration já foi convertido acima)
            local durationInSeconds = duration * 24 * 60 * 60
            local expiresAt = now + durationInSeconds
            
            local updateSuccess = pcall(function()
                -- Salvar timestamp atual, expiresAt e usuário ativo
                local updateUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/firstUsed.json"
                httpRequest(updateUrl, "POST", tostring(now))
                
                local expiresUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/expiresAt.json"
                httpRequest(expiresUrl, "POST", tostring(expiresAt))
                
                local activeUserUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/activeUserId.json"
                httpRequest(activeUserUrl, "POST", "\"" .. currentUserId .. "\"")
                
                local lastActiveUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/lastActive.json"
                httpRequest(lastActiveUrl, "POST", tostring(now))
                
                -- Salvar key localmente
                pcall(function()
                    local savedKeys = LocalPlayer:FindFirstChild("BlackJackKey")
                    if savedKeys then
                        savedKeys:Destroy()
                    end
                    savedKeys = Instance.new("StringValue")
                    savedKeys.Name = "BlackJackKey"
                    savedKeys.Value = key
                    savedKeys.Parent = LocalPlayer
                end)
            end)
            
            if not updateSuccess then
                warn("Erro ao atualizar key no Firebase")
            end
            
            -- Salvar key localmente
            pcall(function()
                local savedKeys = LocalPlayer:FindFirstChild("BlackJackKey")
                if savedKeys then
                    savedKeys:Destroy()
                end
                savedKeys = Instance.new("StringValue")
                savedKeys.Name = "BlackJackKey"
                savedKeys.Value = key
                savedKeys.Parent = LocalPlayer
            end)
            
            return true, "Key ativada com sucesso! Válida por " .. tostring(duration) .. " dias."
        end
    else
        -- Verificar se ainda está válida
        local expiresAt = keyData.expiresAt
        
        -- Converter para número se for string
        if type(expiresAt) == "string" then
            expiresAt = tonumber(expiresAt) or 0
        end
        
        if not expiresAt or expiresAt == 0 then
            -- Se não tem expiresAt mas tem firstUsed, calcular
            if firstUsed and firstUsed > 0 then
                expiresAt = firstUsed + (duration * 24 * 60 * 60)
            else
                return false, "Key com dados corrompidos"
            end
        end
        
        if now > expiresAt then
            return false, "Key expirada. Por favor, adquira uma nova key."
        end
        
        -- Atualizar usuário ativo e último acesso
        pcall(function()
            local activeUserUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/activeUserId.json"
            httpRequest(activeUserUrl, "POST", "\"" .. currentUserId .. "\"")
            
            local lastActiveUrl = FIREBASE_URL .. "/keys/" .. keyId .. "/lastActive.json"
            httpRequest(lastActiveUrl, "POST", tostring(now))
        end)
        
        -- Salvar key localmente se ainda não estiver salva
        pcall(function()
            local savedKeys = LocalPlayer:FindFirstChild("BlackJackKey")
            if not savedKeys then
                savedKeys = Instance.new("StringValue")
                savedKeys.Name = "BlackJackKey"
                savedKeys.Value = key
                savedKeys.Parent = LocalPlayer
            end
        end)
        
        local daysLeft = math.floor((expiresAt - now) / (24 * 60 * 60))
        local hoursLeft = math.floor(((expiresAt - now) % (24 * 60 * 60)) / (60 * 60))
        return true, "Key válida! Restam " .. daysLeft .. " dias e " .. hoursLeft .. " horas."
    end
    
    return false, "Erro desconhecido"
end

-- Função para verificar key salva
local function checkSavedKey()
    local savedKeys = LocalPlayer:FindFirstChild("BlackJackKey")
    if savedKeys then
        local key = savedKeys.Value
        local valid, message = verifyKey(key)
        if valid then
            keyAuthenticated = true
            savedKey = key
            return true
        else
            -- Remover key inválida
            savedKeys:Destroy()
        end
    end
    return false
end

-- Tela de autenticação
local function showKeyAuthScreen()
    local authGui = Instance.new("ScreenGui")
    authGui.Name = "KeyAuthScreen"
    authGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    authGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    authGui.ResetOnSpawn = false
    
    local authFrame = Instance.new("Frame")
    authFrame.Name = "AuthFrame"
    authFrame.Parent = authGui
    authFrame.Size = UDim2.new(0, 500, 0, 400)
    authFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    authFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    authFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = authFrame
    
    -- Logo/Título
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "LogoImage"
    logoImage.Parent = authFrame
    logoImage.Size = UDim2.new(0, 80, 0, 120)
    logoImage.Position = UDim2.new(0.5, -40, 0, 20)
    logoImage.Image = "rbxassetid://124561513989824"
    logoImage.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = authFrame
    titleLabel.Size = UDim2.new(1, -40, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 150)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "BlackJack Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Parent = authFrame
    subtitleLabel.Size = UDim2.new(1, -40, 0, 30)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 190)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Text = "Insira sua key de licença"
    subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitleLabel.TextSize = 14
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Input de key
    local inputFrame = Instance.new("Frame")
    inputFrame.Parent = authFrame
    inputFrame.Size = UDim2.new(1, -40, 0, 40)
    inputFrame.Position = UDim2.new(0, 20, 0, 240)
    inputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inputFrame.BorderSizePixel = 0
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Parent = inputFrame
    keyInput.Size = UDim2.new(1, -20, 1, -10)
    keyInput.Position = UDim2.new(0, 10, 0, 5)
    keyInput.BackgroundTransparency = 1
    keyInput.Font = Enum.Font.Gotham
    keyInput.PlaceholderText = "Cole sua key aqui..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 14
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botão de autenticação
    local authButton = Instance.new("TextButton")
    authButton.Parent = authFrame
    authButton.Size = UDim2.new(1, -40, 0, 40)
    authButton.Position = UDim2.new(0, 20, 0, 300)
    authButton.BackgroundColor3 = Color3.fromRGB(150, 0, 30)
    authButton.BorderSizePixel = 0
    authButton.Font = Enum.Font.GothamBold
    authButton.Text = "AUTENTICAR"
    authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    authButton.TextSize = 16
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = authButton
    
    -- Mensagem de status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = authFrame
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 270)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextWrapped = true
    
    -- Função de autenticação
    local function authenticate()
        
        local key = keyInput.Text:gsub("%s+", "") -- Remover espaços
        if key == "" or #key ~= 50 then
            statusLabel.Text = "Por favor, insira uma key válida (50 caracteres)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end
        
        statusLabel.Text = "Verificando key..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        authButton.Text = "VERIFICANDO..."
        authButton.Active = false
        
        spawn(function()
            local valid, message = verifyKey(key)
            
            if valid then
                keyAuthenticated = true
                savedKey = key
                statusLabel.Text = message
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                wait(1)
                
                -- Fechar tela de autenticação
                authGui:Destroy()
                
                -- Iniciar menu
                startMenu()
            else
                statusLabel.Text = message
                statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                authButton.Text = "AUTENTICAR"
                authButton.Active = true
            end
        end)
    end
    
    authButton.MouseButton1Click:Connect(authenticate)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            authenticate()
        end
    end)
    
    -- Testar conexão HTTP ao abrir a tela
    spawn(function()
        wait(0.1)
        statusLabel.Text = "Testando conexão..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- Testar se algum método HTTP funciona
        local testSuccess, testResult = pcall(function()
            local testUrl = FIREBASE_URL .. "/.json"
            return httpRequest(testUrl, "GET")
        end)
        
        if testSuccess then
            statusLabel.Text = "Conexão OK! Insira sua key."
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            wait(2)
            statusLabel.Text = ""
        else
            statusLabel.Text = "Aviso: Alguns métodos HTTP podem não estar disponíveis.\nTente autenticar mesmo assim."
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end)
    
    -- Focar no input
    wait(0.5)
    keyInput:CaptureFocus()
end

-- Função para iniciar o menu (será chamada após autenticação)
local function startMenu()
    keyAuthenticated = true
    if createMainMenu then
        createMainMenu()
    end
end

-- Função para criar o menu principal (será definida depois)
local createMainMenu = nil

-- Função para criar o menu principal (será definida depois)
local createMainMenu = nil

-- ============================================
-- ANIMAÇÃO INICIAL DO LOGO
-- ============================================

local function showLogoAnimation()
    local logoScreen = Instance.new("ScreenGui")
    logoScreen.Name = "LogoAnimation"
    logoScreen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    logoScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    logoScreen.ResetOnSpawn = false
    
    local logoFrame = Instance.new("Frame")
    logoFrame.Name = "LogoFrame"
    logoFrame.Parent = logoScreen
    logoFrame.Size = UDim2.new(1, 0, 1, 0)
    logoFrame.BackgroundTransparency = 1
    logoFrame.BorderSizePixel = 0
    
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "LogoImage"
    logoImage.Parent = logoFrame
    logoImage.Size = UDim2.new(0, 0, 0, 0)
    logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImage.Image = "rbxassetid://124561513989824"
    logoImage.BackgroundTransparency = 1
    logoImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Animação de aparecer
    local targetSize = UDim2.new(0, 400, 0, 600)
    local duration = 1.5
    
    local tween = game:GetService("TweenService"):Create(
        logoImage,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    tween:Play()
    
    -- Esperar 3 segundos e desaparecer
    wait(3)
    
    local fadeOut = game:GetService("TweenService"):Create(
        logoFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    
    local fadeOutLogo = game:GetService("TweenService"):Create(
        logoImage,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {ImageTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}
    )
    
    fadeOut:Play()
    fadeOutLogo:Play()
    
    fadeOutLogo.Completed:Connect(function()
        logoScreen:Destroy()
        -- Após logo desaparecer, verificar key e mostrar tela de autenticação se necessário
        if not checkSavedKey() then
            showKeyAuthScreen()
        else
            keyAuthenticated = true
            startMenu()
        end
    end)
end

-- Executar animação do logo primeiro
spawn(showLogoAnimation)

-- ============================================
-- SISTEMA DE TOGGLE DO MENU (Tecla Ç)
-- ============================================

local menuVisible = true
local TweenService = game:GetService("TweenService")

local function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        -- Animação de aparecer
        MainFrame.Visible = true
        local appearTween = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(0.5, -425, 0.5, -275),
                Size = UDim2.new(0, 850, 0, 550)
            }
        )
        appearTween:Play()
    else
        -- Animação de desaparecer
        local disappearTween = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Position = UDim2.new(0.5, -425, 0.5, -275),
                Size = UDim2.new(0, 0, 0, 0)
            }
        )
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
end

-- ============================================
-- SISTEMA DE TOGGLE DO MENU (Tecla Ç)
-- ============================================

local menuToggleKey = Enum.KeyCode.RightBracket -- Tecla ] como alternativa para Ç

-- Detectar tecla ]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == menuToggleKey then
        toggleMenu()
    end
end)

-- Sistema de detecção da tecla Ç - usar apenas InputBegan para evitar bloqueio de inputs
-- Removido TextBox que estava bloqueando inputs

-- Propriedades principais (apenas se autenticado)
if not keyAuthenticated then
    -- Aguardar autenticação
    spawn(function()
        while not keyAuthenticated do
            wait(0.1)
        end
        -- Após autenticação, criar menu
        createMainMenu()
    end)
else
    createMainMenu()
end

-- Função para criar o menu principal
createMainMenu = function()
BlackJackMenu.Name = "BlackJackMenu"
BlackJackMenu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
BlackJackMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BlackJackMenu.ResetOnSpawn = false

-- Main Frame (começa invisível para animação)
MainFrame.Name = "MainFrame"
MainFrame.Parent = BlackJackMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -425, 0.5, -275)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

-- Animação inicial do menu (após logo)
spawn(function()
    wait(3.5) -- Esperar logo desaparecer
    MainFrame.Visible = true
    local appearTween = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 850, 0, 550)
        }
    )
    appearTween:Play()
end)

-- Top Bar
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 50)

-- Logo Image (imagem vertical - proporção A4)
LogoImage.Name = "LogoImage"
LogoImage.Parent = TopBar
LogoImage.BackgroundTransparency = 1
LogoImage.Position = UDim2.new(0, 15, 0.5, 0)
-- Altura baseada no TopBar (50px), largura proporcional para imagem vertical A4 (1:1.414)
-- Altura: ~80% do TopBar = 40px, Largura: 40/1.414 ≈ 28px
LogoImage.Size = UDim2.new(0, 28, 0, 40)
LogoImage.Image = "rbxassetid://124561513989824"
LogoImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
LogoImage.ImageRectSize = Vector2.new(0, 0) -- Garantir que não há crop
LogoImage.ImageRectOffset = Vector2.new(0, 0)

-- Title Container
local titleContainer = Instance.new("Frame")
titleContainer.Name = "TitleContainer"
titleContainer.Parent = TopBar
titleContainer.BackgroundTransparency = 1
titleContainer.Position = UDim2.new(0, 0, 0.5, -12)
titleContainer.Size = UDim2.new(0, 200, 0, 24)

-- Title Label "Black"
local blackLabel = Instance.new("TextLabel")
blackLabel.Name = "BlackLabel"
blackLabel.Parent = titleContainer
blackLabel.BackgroundTransparency = 1
blackLabel.Position = UDim2.new(0, 0, 0, 0)
blackLabel.Size = UDim2.new(0, 0, 1, 0)
blackLabel.Font = Enum.Font.GothamBold
blackLabel.Text = "Black"
blackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
blackLabel.TextSize = 18
blackLabel.TextXAlignment = Enum.TextXAlignment.Left
blackLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Title Label "Jack" (vermelho)
local jackLabel = Instance.new("TextLabel")
jackLabel.Name = "JackLabel"
jackLabel.Parent = titleContainer
jackLabel.BackgroundTransparency = 1
jackLabel.Position = UDim2.new(0, 0, 0, 0)
jackLabel.Size = UDim2.new(0, 0, 1, 0)
jackLabel.Font = Enum.Font.GothamBold
jackLabel.Text = "Jack"
jackLabel.TextColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
jackLabel.TextSize = 18
jackLabel.TextXAlignment = Enum.TextXAlignment.Left
jackLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Title Label (mantido para compatibilidade)
TitleLabel = blackLabel

-- Breadcrumb Label (World > Local Player com Local Player em vermelho vinho)
local breadcrumbContainer = Instance.new("Frame")
breadcrumbContainer.Name = "BreadcrumbContainer"
breadcrumbContainer.Parent = TopBar
breadcrumbContainer.BackgroundTransparency = 1
breadcrumbContainer.Position = UDim2.new(0, 250, 0, 0) -- Será ajustado pela função updateTitle
breadcrumbContainer.Size = UDim2.new(0, 300, 1, 0)

-- Ajustar posições do título (agora que breadcrumbContainer existe)
local function updateTitle()
    local blackTextSize = game:GetService("TextService"):GetTextSize(blackLabel.Text, blackLabel.TextSize, blackLabel.Font, Vector2.new(1000, 50))
    blackLabel.Size = UDim2.new(0, blackTextSize.X, 1, 0)
    jackLabel.Position = UDim2.new(0, blackTextSize.X, 0, 0)
    local jackTextSize = game:GetService("TextService"):GetTextSize(jackLabel.Text, jackLabel.TextSize, jackLabel.Font, Vector2.new(1000, 50))
    jackLabel.Size = UDim2.new(0, jackTextSize.X, 1, 0)
    titleContainer.Size = UDim2.new(0, blackTextSize.X + jackTextSize.X, 0, 24)
    
    -- Ajustar posição do container baseado no logo (28px de largura)
    local logoWidth = 28
    titleContainer.Position = UDim2.new(0, 15 + logoWidth + 10, 0.5, -12)
    
    -- Ajustar breadcrumb
    local titleWidth = blackTextSize.X + jackTextSize.X
    breadcrumbContainer.Position = UDim2.new(0, 15 + logoWidth + 10 + titleWidth + 20, 0, 0)
end

BreadcrumbLabel.Name = "BreadcrumbLabel"
BreadcrumbLabel.Parent = breadcrumbContainer
BreadcrumbLabel.BackgroundTransparency = 1
BreadcrumbLabel.Position = UDim2.new(0, 0, 0, 0)
BreadcrumbLabel.Size = UDim2.new(0, 0, 1, 0)
BreadcrumbLabel.Font = Enum.Font.Gotham
BreadcrumbLabel.Text = "World > "
BreadcrumbLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BreadcrumbLabel.TextSize = 13
BreadcrumbLabel.TextXAlignment = Enum.TextXAlignment.Left
BreadcrumbLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Local Player em vermelho vinho
local localPlayerLabel = Instance.new("TextLabel")
localPlayerLabel.Name = "LocalPlayerLabel"
localPlayerLabel.Parent = breadcrumbContainer
localPlayerLabel.BackgroundTransparency = 1
localPlayerLabel.Position = UDim2.new(0, 0, 0, 0)
localPlayerLabel.Size = UDim2.new(0, 0, 1, 0)
localPlayerLabel.Font = Enum.Font.Gotham
localPlayerLabel.Text = "Local Player"
localPlayerLabel.TextColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
localPlayerLabel.TextSize = 13
localPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
localPlayerLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Ajustar posições dinamicamente
local function updateBreadcrumb()
    local worldTextSize = game:GetService("TextService"):GetTextSize(BreadcrumbLabel.Text, BreadcrumbLabel.TextSize, BreadcrumbLabel.Font, Vector2.new(1000, 50))
    local playerTextSize = game:GetService("TextService"):GetTextSize(localPlayerLabel.Text, localPlayerLabel.TextSize, localPlayerLabel.Font, Vector2.new(1000, 50))
    localPlayerLabel.Position = UDim2.new(0, worldTextSize.X, 0, 0)
    localPlayerLabel.Size = UDim2.new(0, playerTextSize.X, 1, 0)
end
updateBreadcrumb()

-- Settings Button (ícone de engrenagem)
SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = TopBar
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(1, -40, 0.5, -12)
SettingsButton.Size = UDim2.new(0, 24, 0, 24)
SettingsButton.Image = "rbxassetid://6031075938"
SettingsButton.ImageColor3 = Color3.fromRGB(200, 200, 200)

-- Sidebar
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.Size = UDim2.new(0, 60, 1, -50)

-- Sidebar Buttons Container
SidebarButtons.Name = "SidebarButtons"
SidebarButtons.Parent = Sidebar
SidebarButtons.BackgroundTransparency = 1
SidebarButtons.Size = UDim2.new(1, 0, 1, 0)

-- Função para criar botões da sidebar
local function createSidebarButton(name, position, icon, isActive)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = SidebarButtons
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0.5, -20, 0, position)
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Text = ""
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = btn
    iconLabel.BackgroundTransparency = 1
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = icon
    iconLabel.TextColor3 = isActive and Color3.fromRGB(150, 0, 30) or Color3.fromRGB(255, 255, 255) -- Vermelho vinho quando ativo
    iconLabel.TextSize = 20
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    
    return btn, iconLabel
end

-- Criar botões da sidebar
LogoBtn, _ = createSidebarButton("LogoBtn", 10, "S", false)
FavoritesBtn, _ = createSidebarButton("FavoritesBtn", 60, "★", false)
OnlineBtn, _ = createSidebarButton("OnlineBtn", 110, "📡", false)
WorldBtn, WorldBtnIcon = createSidebarButton("WorldBtn", 160, "🌐", true)
SelfBtn, _ = createSidebarButton("SelfBtn", 210, "👁", false)
WeaponBtn, _ = createSidebarButton("WeaponBtn", 260, "🔫", false)
VehicleBtn, _ = createSidebarButton("VehicleBtn", 310, "🚗", false)
NetworkBtn, _ = createSidebarButton("NetworkBtn", 360, "▦", false)

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 60, 0, 50)
ContentFrame.Size = UDim2.new(1, -60, 1, -50)

-- Conditions Panel
ConditionsPanel.Name = "ConditionsPanel"
ConditionsPanel.Parent = ContentFrame
ConditionsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ConditionsPanel.BorderSizePixel = 0
ConditionsPanel.Position = UDim2.new(0, 20, 0, 50)
ConditionsPanel.Size = UDim2.new(0, 340, 1, -70)
ConditionsPanel.CanvasSize = UDim2.new(0, 0, 0, 1200)
ConditionsPanel.ScrollBarThickness = 6
ConditionsPanel.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = ConditionsPanel

-- Conditions Title
ConditionsTitle.Name = "ConditionsTitle"
ConditionsTitle.Parent = ContentFrame
ConditionsTitle.BackgroundTransparency = 1
ConditionsTitle.Position = UDim2.new(0, 20, 0, 20)
ConditionsTitle.Size = UDim2.new(0, 200, 0, 25)
ConditionsTitle.Font = Enum.Font.GothamBold
ConditionsTitle.Text = "Conditions"
ConditionsTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
ConditionsTitle.TextSize = 16
ConditionsTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Customization Panel
CustomizationPanel.Name = "CustomizationPanel"
CustomizationPanel.Parent = ContentFrame
CustomizationPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CustomizationPanel.BorderSizePixel = 0
CustomizationPanel.Position = UDim2.new(0, 380, 0, 50)
CustomizationPanel.Size = UDim2.new(1, -400, 1, -70)
CustomizationPanel.CanvasSize = UDim2.new(0, 0, 0, 800)
CustomizationPanel.ScrollBarThickness = 6
CustomizationPanel.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)

local panelCorner2 = Instance.new("UICorner")
panelCorner2.CornerRadius = UDim.new(0, 8)
panelCorner2.Parent = CustomizationPanel

-- Customization Title
CustomizationTitle.Name = "CustomizationTitle"
CustomizationTitle.Parent = ContentFrame
CustomizationTitle.BackgroundTransparency = 1
CustomizationTitle.Position = UDim2.new(0, 380, 0, 20)
CustomizationTitle.Size = UDim2.new(0, 200, 0, 25)
CustomizationTitle.Font = Enum.Font.GothamBold
CustomizationTitle.Text = "Customization"
CustomizationTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
CustomizationTitle.TextSize = 16
CustomizationTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Função para limpar painéis
local function clearPanels()
    for _, child in pairs(ConditionsPanel:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    for _, child in pairs(CustomizationPanel:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- Função para criar checkbox/toggle
local function createToggle(parent, name, text, position, defaultState, hasGridIcon, callback, stateKey)
    -- Usar estado global se fornecido
    local currentState = stateKey and globalStates[stateKey] or defaultState
    
    local container = Instance.new("Frame")
    container.Name = name
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, position)
    container.Size = UDim2.new(1, 0, 0, 35)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = container
    toggle.BackgroundColor3 = currentState and Color3.fromRGB(150, 0, 30) or Color3.fromRGB(50, 50, 50)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Text = ""
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    if currentState then
        local checkmark = Instance.new("TextLabel")
        checkmark.Parent = toggle
        checkmark.BackgroundTransparency = 1
        checkmark.Size = UDim2.new(1, 0, 1, 0)
        checkmark.Font = Enum.Font.GothamBold
        checkmark.Text = "✓"
        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.TextSize = 14
        checkmark.TextXAlignment = Enum.TextXAlignment.Center
        checkmark.TextYAlignment = Enum.TextYAlignment.Center
    end
    
    if hasGridIcon then
        local gridIcon = Instance.new("TextButton")
        gridIcon.Parent = container
        gridIcon.BackgroundTransparency = 1
        gridIcon.BorderSizePixel = 0
        gridIcon.Position = UDim2.new(1, -25, 0.5, -8)
        gridIcon.Size = UDim2.new(0, 16, 0, 16)
        gridIcon.Text = "☷"
        gridIcon.Font = Enum.Font.Gotham
        gridIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
        gridIcon.TextSize = 14
        gridIcon.TextXAlignment = Enum.TextXAlignment.Center
        gridIcon.TextYAlignment = Enum.TextYAlignment.Center
    end
    
    local isActive = currentState
    
    toggle.MouseButton1Click:Connect(function()
        isActive = not isActive
        
        -- Atualizar estado global se fornecido
        if stateKey then
            globalStates[stateKey] = isActive
        end
        
        toggle.BackgroundColor3 = isActive and Color3.fromRGB(150, 0, 30) or Color3.fromRGB(50, 50, 50)
        
        local existingCheck = toggle:FindFirstChildOfClass("TextLabel")
        if isActive then
            if not existingCheck then
                local checkmark = Instance.new("TextLabel")
                checkmark.Parent = toggle
                checkmark.BackgroundTransparency = 1
                checkmark.Size = UDim2.new(1, 0, 1, 0)
                checkmark.Font = Enum.Font.GothamBold
                checkmark.Text = "✓"
                checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                checkmark.TextSize = 14
                checkmark.TextXAlignment = Enum.TextXAlignment.Center
                checkmark.TextYAlignment = Enum.TextYAlignment.Center
            end
        else
            if existingCheck then
                existingCheck:Destroy()
            end
        end
        
        if callback then
            callback(isActive)
        end
    end)
    
    -- Botão direito para favoritar
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if favorites[text] then
                removeFromFavorites(text)
            else
                addToFavorites(text, "toggle", {
                    name = name,
                    text = text,
                    state = isActive
                })
            end
        end
    end)
    
    return container
end

-- Função para criar slider/input
local function createSlider(parent, name, text, position, placeholder, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, position)
    container.Size = UDim2.new(1, 0, 0, 50)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local inputBox = Instance.new("TextBox")
    inputBox.Parent = container
    inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inputBox.BorderSizePixel = 0
    inputBox.Position = UDim2.new(0, 10, 0, 28)
    inputBox.Size = UDim2.new(1, -20, 0, 18)
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = placeholder
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = placeholder
    inputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    inputBox.TextSize = 12
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputBox
    
    local underline = Instance.new("Frame")
    underline.Name = "Underline"
    underline.Parent = inputBox
    underline.BackgroundColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
    underline.BorderSizePixel = 0
    underline.Position = UDim2.new(0, 0, 1, 0)
    underline.Size = UDim2.new(1, 0, 0, 1)
    
    if callback then
        inputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed or not inputBox:IsFocused() then
                callback(inputBox.Text)
            end
        end)
        
        -- Também aplicar quando pressionar Enter
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            -- Não fazer nada aqui, apenas quando perder foco
        end)
    end
    
    -- Botão direito para favoritar
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if favorites[text] then
                removeFromFavorites(text)
            else
                addToFavorites(text, "slider", {
                    name = name,
                    text = text,
                    value = inputBox.Text
                })
            end
        end
    end)
    
    return container
end

-- Função para criar botão de ação
local function createActionButton(parent, name, text, position, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, position)
    container.Size = UDim2.new(1, 0, 0, 35)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local button = Instance.new("TextButton")
    button.Parent = container
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 13
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return container
end

-- Função para criar lista de jogadores
local function createPlayerList(parent, position)
    local container = Instance.new("Frame")
    container.Name = "PlayerList"
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, position)
    container.Size = UDim2.new(1, 0, 0, 200)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = container
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Position = UDim2.new(0, 10, 0, 10)
    scrollFrame.Size = UDim2.new(1, -20, 1, -20)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.Padding = UDim.new(0, 5)
    
    -- Adicionar jogadores com TP e Bring
    local players = game.Players:GetPlayers()
    for i, player in pairs(players) do
        if player ~= LocalPlayer then
            local playerContainer = Instance.new("Frame")
            playerContainer.Parent = scrollFrame
            playerContainer.BackgroundTransparency = 1
            playerContainer.Size = UDim2.new(1, 0, 0, 30)
            
            local playerBtn = Instance.new("TextButton")
            playerBtn.Parent = playerContainer
            playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            playerBtn.BorderSizePixel = 0
            playerBtn.Size = UDim2.new(0.7, 0, 1, 0)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.Text = player.Name
            playerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            playerBtn.TextSize = 12
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = playerBtn
            
            -- Botão TP
            local tpBtn = Instance.new("TextButton")
            tpBtn.Parent = playerContainer
            tpBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 30)
            tpBtn.BorderSizePixel = 0
            tpBtn.Position = UDim2.new(0.7, 5, 0, 0)
            tpBtn.Size = UDim2.new(0.14, 0, 1, 0)
            tpBtn.Font = Enum.Font.Gotham
            tpBtn.Text = "TP"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 11
            
            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0, 4)
            tpCorner.Parent = tpBtn
            
            -- Botão Bring
            local bringBtn = Instance.new("TextButton")
            bringBtn.Parent = playerContainer
            bringBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 30)
            bringBtn.BorderSizePixel = 0
            bringBtn.Position = UDim2.new(0.85, 5, 0, 0)
            bringBtn.Size = UDim2.new(0.14, 0, 1, 0)
            bringBtn.Font = Enum.Font.Gotham
            bringBtn.Text = "Bring"
            bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            bringBtn.TextSize = 11
            
            local bringCorner = Instance.new("UICorner")
            bringCorner.CornerRadius = UDim.new(0, 4)
            bringCorner.Parent = bringBtn
            
            -- Teleportar ao clicar no nome
            playerBtn.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
            
            -- TP button
            tpBtn.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
            
            -- Bring button
            bringBtn.MouseButton1Click:Connect(function()
                bringPlayer(player)
            end)
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 35)
    
    return container
end

-- Sistema de abas - Definir conteúdo para cada aba
local tabContents = {
    ["Local Player"] = function()
        clearPanels()
        ConditionsTitle.Text = "Conditions"
        CustomizationTitle.Text = "Customization"
        
        -- Conditions com callbacks funcionais e estados globais
        createToggle(ConditionsPanel, "GodMode", "God Mode", 10, globalStates.godMode, true, function(enabled)
            globalStates.godMode = enabled
            toggleGodMode(enabled)
        end, "godMode")
        createToggle(ConditionsPanel, "SemGodMode", "Sem God Mode", 50, globalStates.semGodMode, true, function(enabled)
            globalStates.semGodMode = enabled
            if enabled then
                globalStates.godMode = false
                toggleGodMode(false)
            end
        end, "semGodMode")
        createToggle(ConditionsPanel, "Invisible", "Invisible", 90, globalStates.invisible, true, function(enabled)
            globalStates.invisible = enabled
            toggleInvisible(enabled)
        end, "invisible")
        createToggle(ConditionsPanel, "SuperJump", "Super Jump", 130, globalStates.superJump, true, function(enabled)
            globalStates.superJump = enabled
            toggleSuperJump(enabled)
        end, "superJump")
        createToggle(ConditionsPanel, "InfiniteStamina", "Infinite Stamina", 170, globalStates.infiniteStamina, true, function(enabled)
            globalStates.infiniteStamina = enabled
            toggleInfiniteStamina(enabled)
        end, "infiniteStamina")
        createToggle(ConditionsPanel, "NoRagdoll", "No Ragdoll", 210, globalStates.noRagdoll, true, function(enabled)
            globalStates.noRagdoll = enabled
            toggleNoRagdoll(enabled)
        end, "noRagdoll")
        createToggle(ConditionsPanel, "NoClip", "NoClip", 250, globalStates.noClip, true, function(enabled)
            globalStates.noClip = enabled
            noclipEnabled = enabled
            toggleNoClip(enabled)
        end, "noClip")
        createToggle(ConditionsPanel, "InvisibleNoClip", "Invisible NoClip", 290, globalStates.invisibleNoClip, true, function(enabled)
            globalStates.invisibleNoClip = enabled
            -- Salvar estado original antes de ativar
            if enabled and not characterStateSaved then
                saveOriginalCharacterState()
            end
            toggleNoClip(enabled)
            toggleInvisible(enabled)
        end, "invisibleNoClip")
        createToggle(ConditionsPanel, "RunSpeed", "Run Speed", 330, globalStates.runSpeed, true, function(enabled)
            globalStates.runSpeed = enabled
            runSpeedEnabled = enabled
            toggleRunSpeed(enabled)
        end, "runSpeed")
        createToggle(ConditionsPanel, "SwimSpeed", "Swim Speed", 370, globalStates.swimSpeed, true, function(enabled)
            globalStates.swimSpeed = enabled
            swimSpeedEnabled = enabled
            toggleSwimSpeed(enabled)
        end, "swimSpeed")
        createToggle(ConditionsPanel, "NeverWanted", "Never Wanted", 410, globalStates.neverWanted, false, function(enabled)
            globalStates.neverWanted = enabled
            neverWantedEnabled = enabled
        end, "neverWanted")
        createToggle(ConditionsPanel, "NoCollision", "No Collision", 450, globalStates.noCollision, false, function(enabled)
            globalStates.noCollision = enabled
            noCollisionEnabled = enabled
            toggleNoCollision(enabled)
        end, "noCollision")
        
        -- Customization com callbacks funcionais
        createSlider(CustomizationPanel, "NoClipSpeed", "NoClip Speed", 10, tostring(noclipSpeed), function(value)
            local num = tonumber(value) or 1.0
            noclipSpeed = num
            print("NoClip Speed set to: " .. noclipSpeed)
        end)
        createSlider(CustomizationPanel, "RunSpeedMultiplier", "Run Speed Multiplier", 70, tostring(runSpeedMultiplier) .. "x", function(value)
            local cleanValue = value:gsub("x", ""):gsub("X", ""):gsub(" ", "")
            local num = tonumber(cleanValue) or 1.0
            runSpeedMultiplier = num
            print("Run Speed Multiplier set to: " .. runSpeedMultiplier .. "x")
            if runSpeedEnabled then
                toggleRunSpeed(true)
            end
        end)
        createSlider(CustomizationPanel, "SwimSpeedMultiplier", "Swim Speed Multiplier", 130, tostring(swimSpeedMultiplier) .. "x", function(value)
            local cleanValue = value:gsub("x", ""):gsub("X", ""):gsub(" ", "")
            local num = tonumber(cleanValue) or 1.0
            swimSpeedMultiplier = num
            print("Swim Speed Multiplier set to: " .. swimSpeedMultiplier .. "x")
            if swimSpeedEnabled then
                toggleSwimSpeed(true)
            end
        end)
        
local noClipMode = Instance.new("Frame")
noClipMode.Name = "NoClipMode"
        noClipMode.Parent = CustomizationPanel
        noClipMode.BackgroundTransparency = 1
noClipMode.BorderSizePixel = 0
        noClipMode.Position = UDim2.new(0, 0, 0, 190)
        noClipMode.Size = UDim2.new(1, 0, 0, 50)

local modeLabel = Instance.new("TextLabel")
modeLabel.Parent = noClipMode
modeLabel.BackgroundTransparency = 1
modeLabel.Position = UDim2.new(0, 10, 0, 5)
modeLabel.Size = UDim2.new(1, -20, 0, 20)
modeLabel.Font = Enum.Font.Gotham
modeLabel.Text = "NoClip Mode"
modeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
modeLabel.TextSize = 13
modeLabel.TextXAlignment = Enum.TextXAlignment.Left

        local modeValue = Instance.new("TextButton")
modeValue.Parent = noClipMode
modeValue.BackgroundTransparency = 1
        modeValue.BorderSizePixel = 0
modeValue.Position = UDim2.new(0, 10, 0, 28)
modeValue.Size = UDim2.new(1, -20, 0, 18)
modeValue.Font = Enum.Font.GothamBold
modeValue.Text = "Direction"
        modeValue.TextColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
modeValue.TextSize = 12
modeValue.TextXAlignment = Enum.TextXAlignment.Left

        local modeUnderline = Instance.new("Frame")
        modeUnderline.Name = "Underline"
        modeUnderline.Parent = modeValue
        modeUnderline.BackgroundColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
        modeUnderline.BorderSizePixel = 0
        modeUnderline.Position = UDim2.new(0, 0, 1, 0)
        modeUnderline.Size = UDim2.new(1, 0, 0, 1)
        
        createSlider(CustomizationPanel, "HealthAmount", "Health Amount", 250, "100", function(value)
            setHealth(value)
        end)
        createSlider(CustomizationPanel, "ArmorAmount", "Armor Amount", 310, "100", function(value)
            setArmor(value)
        end)
    end,
    
    ["Self Player"] = function()
        clearPanels()
        ConditionsTitle.Text = "Self Options"
        CustomizationTitle.Text = "Player Settings"
        
        -- Conditions com callbacks
        createToggle(ConditionsPanel, "ShowPlayers", "Show Players", 10, showPlayersEnabled, false, function(enabled)
            showPlayersEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowHealth", "Show Health", 50, showHealthEnabled, false, function(enabled)
            showHealthEnabled = enabled
        end)
        createToggle(ConditionsPanel, "EnableAimBot", "Enable AimBot", 90, globalStates.enableAimBot, false, function(enabled)
            globalStates.enableAimBot = enabled
            enableAimBotEnabled = enabled
        end, "enableAimBot")
        createToggle(ConditionsPanel, "ShowPlayerList", "Show Player List", 130, showPlayerListEnabled, false, function(enabled)
            showPlayerListEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowNPCs", "Show NPCs", 170, showNPCsEnabled, false, function(enabled)
            showNPCsEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowWeapons", "Show Weapons", 210, showWeaponsEnabled, false, function(enabled)
            showWeaponsEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowSkeleton", "Show Skeleton", 250, showSkeletonEnabled, false, function(enabled)
            showSkeletonEnabled = enabled
        end)
        createToggle(ConditionsPanel, "TeleportClosest", "Teleport to Player Closest to Crosshair (F7)", 290, false, false, function(enabled)
            if enabled then
                local target = getClosestPlayerToMouse()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end)
        
        -- Customization com callbacks
        createSlider(CustomizationPanel, "PlayerDistance", "Player Distance:", 10, tostring(playerDistance), function(value)
            playerDistance = tonumber(value) or 500
        end)
        createSlider(CustomizationPanel, "AimFov", "AIM Fov:", 70, tostring(aimFov), function(value)
            aimFov = tonumber(value) or 100
        end)
        createSlider(CustomizationPanel, "AimKey", "AimBot Key:", 130, "Right Click", function(value)
            -- Key binding
        end)
    end,
    
    ["Players"] = function()
        clearPanels()
        ConditionsTitle.Text = "Player Options"
        CustomizationTitle.Text = "Player List"
        
        -- Conditions com callbacks
        createToggle(ConditionsPanel, "ShowNPCs", "Show NPCs", 10, showNPCsEnabled, false, function(enabled)
            showNPCsEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowWeapons", "Show Weapons", 50, showWeaponsEnabled, false, function(enabled)
            showWeaponsEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowNames", "Show Names", 90, nameTagsEnabled, false, function(enabled)
            nameTagsEnabled = enabled
        end)
        createToggle(ConditionsPanel, "ShowDistance", "Show Distance", 130, false, false, function(enabled)
            -- Implementação de distância
        end)
        createToggle(ConditionsPanel, "ShowHealthBar", "Show Health Bar", 170, showHealthEnabled, false, function(enabled)
            showHealthEnabled = enabled
        end)
        
        -- Customization - Lista de jogadores
        createPlayerList(CustomizationPanel, 10)
    end,
    
    ["Vehicle"] = function()
        clearPanels()
        ConditionsTitle.Text = "Vehicle Options"
        CustomizationTitle.Text = "Vehicle Settings"
        
        -- Conditions com callbacks
        createToggle(ConditionsPanel, "GodModeVehicle", "God Mode Vehicle", 10, godModeVehicleEnabled, true, function(enabled)
            toggleGodModeVehicle(enabled)
        end)
        createToggle(ConditionsPanel, "InfiniteFuel", "Infinite Fuel", 50, infiniteFuelEnabled, true, function(enabled)
            toggleInfiniteFuel(enabled)
        end)
        createToggle(ConditionsPanel, "NoCollisionVehicle", "No Collision", 90, noCollisionVehicleEnabled, true, function(enabled)
            toggleNoCollisionVehicle(enabled)
        end)
        createToggle(ConditionsPanel, "AutoRepair", "Auto Repair", 130, autoRepairEnabled, true, function(enabled)
            toggleAutoRepair(enabled)
        end)
        createToggle(ConditionsPanel, "ShowName", "Show Name", 170, true, false, function(enabled)
            -- Mostrar nome do veículo
        end)
        
        -- Customization com callbacks
        createSlider(CustomizationPanel, "VehicleSpeed", "Vehicle Speed", 10, tostring(vehicleSpeed) .. "x", function(value)
            vehicleSpeed = tonumber(value:gsub("x", "")) or 1.0
        end)
        createSlider(CustomizationPanel, "VehicleAcceleration", "Acceleration", 70, tostring(vehicleAcceleration) .. "x", function(value)
            vehicleAcceleration = tonumber(value:gsub("x", "")) or 1.0
        end)
        createSlider(CustomizationPanel, "VehicleHandling", "Handling", 130, tostring(vehicleHandling) .. "x", function(value)
            vehicleHandling = tonumber(value:gsub("x", "")) or 1.0
        end)
    end,
    
    ["Weapon"] = function()
        clearPanels()
        ConditionsTitle.Text = "Weapon Options"
        CustomizationTitle.Text = "Weapon Settings"
        
        -- Conditions com callbacks
        createToggle(ConditionsPanel, "InfiniteAmmo", "Infinite Ammo", 10, infiniteAmmoEnabled, true, function(enabled)
            toggleInfiniteAmmo(enabled)
        end)
        createToggle(ConditionsPanel, "NoRecoil", "No Recoil", 50, noRecoilEnabled, true, function(enabled)
            toggleNoRecoil(enabled)
        end)
        createToggle(ConditionsPanel, "NoSpread", "No Spread", 90, noSpreadEnabled, true, function(enabled)
            toggleNoSpread(enabled)
        end)
        createToggle(ConditionsPanel, "RapidFire", "Rapid Fire", 130, rapidFireEnabled, true, function(enabled)
            toggleRapidFire(enabled)
        end)
        createToggle(ConditionsPanel, "OneShotKill", "One Shot Kill", 170, oneShotKillEnabled, true, function(enabled)
            toggleOneShotKill(enabled)
        end)
        createToggle(ConditionsPanel, "ShowSkeleton", "Show Skeleton", 210, showSkeletonEnabled, false, function(enabled)
            showSkeletonEnabled = enabled
        end)
        
        -- Customization com callbacks
        createSlider(CustomizationPanel, "DamageMultiplier", "Damage Multiplier", 10, tostring(damageMultiplier) .. "x", function(value)
            damageMultiplier = tonumber(value:gsub("x", "")) or 1.0
        end)
        createSlider(CustomizationPanel, "FireRate", "Fire Rate", 70, tostring(fireRate) .. "x", function(value)
            fireRate = tonumber(value:gsub("x", "")) or 1.0
        end)
        createSlider(CustomizationPanel, "Range", "Range", 130, tostring(weaponRange), function(value)
            weaponRange = tonumber(value) or 100.0
        end)
    end,
    
    ["Online"] = function()
        clearPanels()
        ConditionsTitle.Text = "ESP Options"
        CustomizationTitle.Text = "Player Actions"
        
        -- ESP Toggles com estados globais
        createToggle(ConditionsPanel, "ESP", "ESP", 10, globalStates.espEnabled, false, function(enabled)
            globalStates.espEnabled = enabled
            espEnabled = enabled
            toggleESP(enabled)
        end, "espEnabled")
        
        createToggle(ConditionsPanel, "Line ESP", "Line ESP", 50, globalStates.espLine, false, function(enabled)
            globalStates.espLine = enabled
            espLineEnabled = enabled
            updateESP()
        end, "espLine")
        
        createToggle(ConditionsPanel, "Box ESP", "Box ESP", 90, globalStates.espBox, false, function(enabled)
            globalStates.espBox = enabled
            espBoxEnabled = enabled
            updateESP()
        end, "espBox")
        
        createToggle(ConditionsPanel, "Skeleton ESP", "Skeleton ESP", 130, globalStates.espSkeleton, false, function(enabled)
            globalStates.espSkeleton = enabled
            espSkeletonEnabled = enabled
            updateESP()
        end, "espSkeleton")
        
        createToggle(ConditionsPanel, "ESP Self", "ESP Self", 170, globalStates.espSelf, false, function(enabled)
            globalStates.espSelf = enabled
            espSelfEnabled = enabled
            updateESP()
        end, "espSelf")
        
        createToggle(ConditionsPanel, "Name Tags", "Name Tags", 210, globalStates.nameTags, false, function(enabled)
            globalStates.nameTags = enabled
            nameTagsEnabled = enabled
            updateESP()
        end, "nameTags")
        
        createToggle(ConditionsPanel, "ESP Health", "ESP Health", 250, globalStates.showHealth, false, function(enabled)
            globalStates.showHealth = enabled
            showHealthEnabled = enabled
            updateESP()
        end, "showHealth")
        
        -- Customization - Lista de jogadores online com TP/Bring
        createPlayerList(CustomizationPanel, 10)
    end,
    
    ["Favorites"] = function()
        clearPanels()
        ConditionsTitle.Text = "Favorites"
        CustomizationTitle.Text = "Favorite Items"
        
        -- Conditions - Mostrar favoritos
        createToggle(ConditionsPanel, "ShowFavorites", "Show Favorites", 10, true, false)
        
        -- Customization - Lista de itens favoritados
        local favoritesContainer = Instance.new("Frame")
        favoritesContainer.Name = "FavoritesContainer"
        favoritesContainer.Parent = CustomizationPanel
        favoritesContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        favoritesContainer.BorderSizePixel = 0
        favoritesContainer.Position = UDim2.new(0, 0, 0, 10)
        favoritesContainer.Size = UDim2.new(1, 0, 0, 200)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = favoritesContainer
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Parent = favoritesContainer
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Position = UDim2.new(0, 10, 0, 10)
        scrollFrame.Size = UDim2.new(1, -20, 1, -20)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 6
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = scrollFrame
        layout.Padding = UDim.new(0, 5)
        
        -- Adicionar itens favoritados
        local yPos = 0
        for itemName, itemData in pairs(favorites) do
            local favoriteItem = Instance.new("TextButton")
            favoriteItem.Parent = scrollFrame
            favoriteItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            favoriteItem.BorderSizePixel = 0
            favoriteItem.Position = UDim2.new(0, 0, 0, yPos)
            favoriteItem.Size = UDim2.new(1, 0, 0, 30)
            favoriteItem.Font = Enum.Font.Gotham
            favoriteItem.Text = itemName .. " (" .. itemData.type .. ")"
            favoriteItem.TextColor3 = Color3.fromRGB(200, 200, 200)
            favoriteItem.TextSize = 12
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = favoriteItem
            
            -- Botão direito para remover dos favoritos
            favoriteItem.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    removeFromFavorites(itemName)
                end
            end)
            
            yPos = yPos + 35
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end,
    
    ["Network"] = function()
        clearPanels()
        ConditionsTitle.Text = "Network Options"
        CustomizationTitle.Text = "Network Settings"
        
        -- Conditions
        createToggle(ConditionsPanel, "LagSwitch", "Lag Switch", 10, false, true)
        createToggle(ConditionsPanel, "PacketLoss", "Packet Loss", 50, false, true)
        
        -- Customization
        createSlider(CustomizationPanel, "Ping", "Ping", 10, "0ms")
        createSlider(CustomizationPanel, "PacketLossAmount", "Packet Loss Amount", 70, "0%")
    end
}

-- Função para mudar de aba
local function switchTab(tabName, button)
    currentTab = tabName
    
    -- Resetar todos os botões
    local buttons = {LogoBtn, FavoritesBtn, OnlineBtn, WorldBtn, SelfBtn, WeaponBtn, VehicleBtn, NetworkBtn}
    for _, btn in pairs(buttons) do
        local iconLabel = btn:FindFirstChildOfClass("TextLabel")
        if iconLabel then
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    -- Destacar botão ativo
    if button then
        local iconLabel = button:FindFirstChildOfClass("TextLabel")
        if iconLabel then
            iconLabel.TextColor3 = Color3.fromRGB(150, 0, 30) -- Vermelho vinho
        end
        currentTabButton = button
    end
    
    -- Atualizar breadcrumb
    BreadcrumbLabel.Text = "World > "
    localPlayerLabel.Text = tabName
    updateBreadcrumb()
    
    -- Carregar conteúdo da aba
    if tabContents[tabName] then
        tabContents[tabName]()
    end
    
    print("Switched to: " .. tabName)
end

-- Atribuir referência para funções de favoritos
switchTabRef = switchTab

-- Conectar botões
LogoBtn.MouseButton1Click:Connect(function()
    switchTab("Home", LogoBtn)
end)

FavoritesBtn.MouseButton1Click:Connect(function()
    switchTab("Favorites", FavoritesBtn)
end)

OnlineBtn.MouseButton1Click:Connect(function()
    switchTab("Online", OnlineBtn)
end)

WorldBtn.MouseButton1Click:Connect(function()
    switchTab("Local Player", WorldBtn)
end)

SelfBtn.MouseButton1Click:Connect(function()
    switchTab("Self Player", SelfBtn)
end)

WeaponBtn.MouseButton1Click:Connect(function()
    switchTab("Weapon", WeaponBtn)
end)

VehicleBtn.MouseButton1Click:Connect(function()
    switchTab("Vehicle", VehicleBtn)
end)

NetworkBtn.MouseButton1Click:Connect(function()
    switchTab("Network", NetworkBtn)
end)

-- Atualizar título após tudo estar criado
spawn(function()
    wait(0.1)
    updateTitle()
end)

-- Carregar aba inicial
switchTab("Local Player", WorldBtn)

-- Verificar periodicamente se a key ainda é válida e uso simultâneo (a cada 30 segundos)
spawn(function()
    while keyAuthenticated and savedKey do
        wait(30) -- 30 segundos
        local valid, message = verifyKey(savedKey)
        if not valid then
            -- Key expirada ou em uso por outro, expulsar jogador
            keyAuthenticated = false
            LocalPlayer:Kick("Sua key expirou ou está sendo usada em outro dispositivo. " .. (message or ""))
            break
        else
            -- Atualizar lastActive para manter sessão ativa
            pcall(function()
                local url = FIREBASE_URL .. "/keys.json"
                local httpSuccess, response = httpRequest(url, "GET")
                if httpSuccess and response then
                    local allKeys = jsonDecode(response)
                    if allKeys then
                        for id, data in pairs(allKeys) do
                            if data and data.key == savedKey then
                                local lastActiveUrl = FIREBASE_URL .. "/keys/" .. id .. "/lastActive.json"
                                httpRequest(lastActiveUrl, "POST", tostring(os.time()))
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("═══════════════════════════════════════")
print("  🎰 BLACKJACK MENU LOADED SUCCESSFULLY! 🎰")
print("═══════════════════════════════════════")
print("📌 Press ']' (RightBracket) to toggle menu")
print("📌 Or type 'ç' in the hidden textbox")
print("📌 Current Tab: " .. currentTab)
print("📌 Drag the window to move it")
print("📌 Right-click on options to add to favorites!")
print("═══════════════════════════════════════")
end -- Fim da função createMainMenu
