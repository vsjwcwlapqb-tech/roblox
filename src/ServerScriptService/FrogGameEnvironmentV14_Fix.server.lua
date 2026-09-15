-- Frog Game Environment V14/V16 vertical alignment repair
-- Removes legacy yellow baseplate/spawns, keeps real pond water,
-- and lowers the island/decorations so they sit naturally at the waterline.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local function isInFrogGame(instance)
    return instance:FindFirstAncestor("FrogGame") ~= nil
end

-- Remove legacy objects that caused the original giant yellow floor.
for _, child in ipairs(Workspace:GetChildren()) do
    if not isInFrogGame(child) then
        if child:IsA("BasePart") and (child.Name == "Baseplate" or child.Size.X > 1800 or child.Size.Z > 1800) then
            child:Destroy()
        elseif child:IsA("SpawnLocation") then
            child:Destroy()
        end
    end
end

if Terrain then
    Terrain.WaterColor = Color3.fromRGB(35, 155, 194)
    Terrain.WaterTransparency = 0.25
    Terrain.WaterReflectance = 0.05
    Terrain.WaterWaveSize = 0.15
    Terrain.WaterWaveSpeed = 8
end

local function getLobbySpawn()
    local frogGame = Workspace:WaitForChild("FrogGame", 15)
    if not frogGame then return nil end
    local map = frogGame:WaitForChild("ReferenceLayoutV13", 15)
    if not map then return nil end
    local lobby = map:WaitForChild("Lobby", 15)
    if not lobby then return nil end
    return lobby:FindFirstChild("Spawn_1")
end

local function placeCharacter(character)
    local spawn = getLobbySpawn()
    local root = character and character:WaitForChild("HumanoidRootPart", 5)
    if spawn and root then
        root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
    end
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.spawn(placeCharacter, character)
    end)
    if player.Character then
        task.spawn(placeCharacter, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
Players.PlayerAdded:Connect(setupPlayer)

-- The original V13 island was built with its top around Y=55-60 while
-- the pond surface is Y=0.  Lower the island by 40 studs so the land
-- meets the water naturally instead of appearing to float above it.
local function lowerParts(container, amount)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CFrame = obj.CFrame + Vector3.new(0, -amount, 0)
        end
    end
end

local function raiseNamed(container, name, amount)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == name then
            obj.CFrame = obj.CFrame + Vector3.new(0, amount, 0)
        end
    end
end

local function alignMapToWater()
    local frogGame = Workspace:FindFirstChild("FrogGame")
    if not frogGame then return end
    local map = frogGame:FindFirstChild("ReferenceLayoutV13")
    if not map or map:GetAttribute("VerticalAlignmentV16") then return end

    local island = map:FindFirstChild("CentralIsland")
    if island then
        lowerParts(island, 40)
        -- Shore rocks were centered at Y=16 in V13; bring them back to
        -- the shoreline after lowering the rest of the island.
        raiseNamed(island, "IslandShoreRock", 26)
    end

    -- V15 beauty objects are generated separately.  Lower only the
    -- island-centered decorations; floating lotus and pond-edge objects
    -- stay at the water level.
    local beauty = map:FindFirstChild("BeautyDecor")
    local generated = beauty and beauty:FindFirstChild("V15Generated")
    if generated then
        for _, obj in ipairs(generated:GetDescendants()) do
            if obj:IsA("BasePart") then
                local p = obj.Position
                local radial = math.sqrt(p.X*p.X + p.Z*p.Z)
                local keepAtWater = obj.Name == "FloatingLotus" or obj.Name == "FloatingPetal" or obj.Name == "WaterEdgeRock"
                if radial <= 1100 and not keepAtWater then
                    obj.CFrame = obj.CFrame + Vector3.new(0, -45, 0)
                end
            end
        end
    end

    map:SetAttribute("VerticalAlignmentV16", true)
    map:SetAttribute("WaterSurfaceY", 0)
    map:SetAttribute("IslandVerticalOffset", -40)
    print("FrogGame V16 alignment: island lowered to meet pond water surface")
end

-- V13 must finish first, and V15 beauty objects must exist before their
-- island decorations can be aligned.
task.delay(5, alignMapToWater)

task.delay(1, function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            task.spawn(placeCharacter, player.Character)
        end
    end
end)

print("FrogGame V16 repair loaded: water/map vertical alignment enabled")
