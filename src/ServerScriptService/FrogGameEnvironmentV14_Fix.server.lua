-- Frog Game Environment V14
-- Runtime repair for the reference environment.
-- Removes legacy yellow baseplate/spawns, forces real blue pond water,
-- and guarantees players start in the lobby instead of at world origin.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local function isInFrogGame(instance)
    return instance:FindFirstAncestor("FrogGame") ~= nil
end

-- V13 cleared Terrain but did not remove the old Baseplate/SpawnLocation.
-- Those legacy objects are what produced the giant yellow surface in the test.
for _, child in ipairs(Workspace:GetChildren()) do
    if not isInFrogGame(child) then
        if child:IsA("BasePart") and (child.Name == "Baseplate" or child.Size.X > 1800 or child.Size.Z > 1800) then
            child:Destroy()
        elseif child:IsA("SpawnLocation") then
            child:Destroy()
        end
    end
end

-- Make Terrain water look like the intended pond.
if Terrain then
    Terrain.WaterColor = Color3.fromRGB(35, 155, 194)
    Terrain.WaterTransparency = 0.25
    Terrain.WaterReflectance = 0.05
    Terrain.WaterWaveSize = 0.15
    Terrain.WaterWaveSpeed = 8
end

local function getLobbySpawn()
    -- V13 may be starting at the same time as this repair script.
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

task.delay(1, function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            task.spawn(placeCharacter, player.Character)
        end
    end
end)

print("FrogGame V14 repair loaded: legacy yellow baseplate removed, pond water corrected, lobby spawn enforced")
