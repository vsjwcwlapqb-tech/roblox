local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

-- Parent Folder Cleanup
local existingMap = Workspace:FindFirstChild("FrogGameMap")
if existingMap then existingMap:Destroy() end

local MapFolder = Instance.new("Folder")
MapFolder.Name = "FrogGameMap"
MapFolder.Parent = Workspace

-- Configuration Constants
local MAP_CENTER = Vector3.new(0, 0, 0)
local POND_RADIUS = 180
local ISLAND_RADIUS = 50
local WATER_HEIGHT = 2
local BRIDGE_LENGTH = POND_RADIUS - ISLAND_RADIUS

-- Player Stall Colors (Matching Reference Image)
local STALL_COLORS = {
	Color3.fromRGB(220, 50, 50),   -- 1: Red
	Color3.fromRGB(240, 150, 40),  -- 2: Orange
	Color3.fromRGB(50, 200, 80),   -- 3: Green
	Color3.fromRGB(40, 120, 240),  -- 4: Blue
	Color3.fromRGB(150, 50, 220),  -- 5: Purple
	Color3.fromRGB(230, 100, 180)  -- 6: Pink
}

-- Helper Utility Functions
local function createPart(name, size, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or MapFolder
	return part
end

-- 1. BUILD WATER POND & BED
local pondBed = createPart("PondBed", Vector3.new(POND_RADIUS * 2.4, 4, POND_RADIUS * 2.4), MAP_CENTER - Vector3.new(0, 4, 0), Color3.fromRGB(20, 60, 80), Enum.Material.Slate)
local waterPart = createPart("PondWater", Vector3.new(POND_RADIUS * 2.3, WATER_HEIGHT, POND_RADIUS * 2.3), MAP_CENTER + Vector3.new(0, WATER_HEIGHT/2, 0), Color3.fromRGB(0, 170, 255), Enum.Material.Glass)
waterPart.Transparency = 0.35
waterPart.CanCollide = false

-- 2. BUILD CENTRAL FROG ISLAND
local island = createPart("CentralIsland", Vector3.new(ISLAND_RADIUS * 2, 8, ISLAND_RADIUS * 2), MAP_CENTER + Vector3.new(0, 2, 0), Color3.fromRGB(90, 160, 70), Enum.Material.Grass)
island.Shape = Enum.PartType.Cylinder
island.Orientation = Vector3.new(0, 0, 90)

-- Populate Central Island Foliage (Sakura Trees & Rocks)
for i = 1, 12 do
	local angle = (i / 12) * math.pi * 2
	local dist = math.random(10, ISLAND_RADIUS - 12)
	local pos = MAP_CENTER + Vector3.new(math.cos(angle) * dist, 6, math.sin(angle) * dist)
	
	-- Tree Trunk
	createPart("SakuraTrunk", Vector3.new(2, 10, 2), pos + Vector3.new(0, 5, 0), Color3.fromRGB(100, 70, 45), Enum.Material.Wood)
	-- Tree Canopy (Pink Sakura)
	local canopy = createPart("SakuraLeaves", Vector3.new(10, 8, 10), pos + Vector3.new(0, 11, 0), Color3.fromRGB(255, 180, 210), Enum.Material.Organic)
	canopy.Shape = Enum.PartType.Ball
end

-- 3. BUILD CONNECTING STONE BRIDGE
local bridgeWidth = 14
local bridgeCenterZ = (POND_RADIUS + ISLAND_RADIUS) / 2
local bridge = createPart("MainBridge", Vector3.new(bridgeWidth, 3, BRIDGE_LENGTH), MAP_CENTER + Vector3.new(0, WATER_HEIGHT + 1.5, bridgeCenterZ), Color3.fromRGB(160, 160, 165), Enum.Material.Concrete)

-- Bridge Lanterns
for _, zOffset in ipairs({ISLAND_RADIUS + 10, POND_RADIUS - 10}) do
	for _, xSign in ipairs({-1, 1}) do
		local lampPos = MAP_CENTER + Vector3.new((bridgeWidth/2 + 1) * xSign, WATER_HEIGHT + 4, zOffset)
		createPart("LampPost", Vector3.new(1, 6, 1), lampPos, Color3.fromRGB(60, 60, 60), Enum.Material.Metal)
		local bulb = createPart("LampLight", Vector3.new(2, 2, 2), lampPos + Vector3.new(0, 3, 0), Color3.fromRGB(255, 200, 100), Enum.Material.Neon)
		bulb.Shape = Enum.PartType.Ball
	end
end

-- 4. BUILD PROMENADE & 6 COLOR-CODED PLAYER STALLS
local hubZ = POND_RADIUS + 15
local hubPromenade = createPart("PlayerHubPromenade", Vector3.new(260, 4, 40), MAP_CENTER + Vector3.new(0, 2, hubZ + 10), Color3.fromRGB(180, 180, 185), Enum.Material.Cobblestone)

local stallWidth = 24
local stallSpacing = 32
local startX = -((5 * stallSpacing) / 2)

for i = 1, 6 do
	local color = STALL_COLORS[i]
	local xPos = startX + (i - 1) * stallSpacing
	local stallPos = MAP_CENTER + Vector3.new(xPos, 4.5, hubZ)
	
	-- Base Platform
	local platform = createPart("PlayerPlot_" .. i, Vector3.new(stallWidth, 1, 20), stallPos, color, Enum.Material.SmoothPlastic)
	CollectionService:AddTag(platform, "PlayerPlot")
	platform:SetAttribute("PlotIndex", i)
	
	-- Spawn Point for Player
	local spawnPoint = Instance.new("SpawnLocation")
	spawnPoint.Name = "PlotSpawn_" .. i
	spawnPoint.Size = Vector3.new(6, 1, 6)
	spawnPoint.Position = stallPos + Vector3.new(0, 1, 4)
	spawnPoint.Color = color
	spawnPoint.Neutral = false
	spawnPoint.Duration = 0
	spawnPoint.Anchored = true
	spawnPoint.Parent = MapFolder
	CollectionService:AddTag(spawnPoint, "PlayerSpawn")
	
	-- Stall Roof & Pillars
	createPart("PillarL", Vector3.new(1.5, 8, 1.5), stallPos + Vector3.new(-stallWidth/2 + 1, 4, -8), Color3.fromRGB(80, 50, 30), Enum.Material.Wood, MapFolder)
	createPart("PillarR", Vector3.new(1.5, 8, 1.5), stallPos + Vector3.new(stallWidth/2 - 1, 4, -8), Color3.fromRGB(80, 50, 30), Enum.Material.Wood, MapFolder)
	createPart("StallRoof", Vector3.new(stallWidth + 2, 2, 10), stallPos + Vector3.new(0, 9, -5), color, Enum.Material.SmoothPlastic, MapFolder)
end

-- 5. OUTER PERIMETER PATH & FENCE
local numPathSegments = 36
for i = 1, numPathSegments do
	local angle = (i / numPathSegments) * math.pi * 2
	local pos = MAP_CENTER + Vector3.new(math.cos(angle) * POND_RADIUS, 2, math.sin(angle) * POND_RADIUS)
	
	local pathSeg = createPart("PerimeterPath", Vector3.new(20, 2, 20), pos, Color3.fromRGB(150, 150, 150), Enum.Material.Cobblestone)
	pathSeg.CFrame = CFrame.new(pos, MAP_CENTER)
	
	-- Decorate path with Sakura trees
	if i % 3 == 0 then
		local treePos = MAP_CENTER + Vector3.new(math.cos(angle) * (POND_RADIUS + 12), 2, math.sin(angle) * (POND_RADIUS + 12))
		createPart("OuterTreeTrunk", Vector3.new(2, 12, 2), treePos + Vector3.new(0, 6, 0), Color3.fromRGB(100, 70, 45), Enum.Material.Wood)
		local leaf = createPart("OuterTreeLeaves", Vector3.new(12, 10, 12), treePos + Vector3.new(0, 13, 0), Color3.fromRGB(255, 180, 210), Enum.Material.Organic)
		leaf.Shape = Enum.PartType.Ball
	end
end

-- 6. ATMOSPHERIC LIGHTING SETUP
Lighting.ClockTime = 14
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(130, 150, 180)
Lighting.GlobalShadows = true

print("[EnvironmentBuilder]: Frog Pond Environment Built Successfully!")