-- Frog Game Environment V11
-- STEP 1 ONLY: giant master outer stone path / scale foundation.
-- The whole playable footprint is expanded dramatically so the future WATER POND has roughly 10x the V10 planning area.
-- Individual stone slabs stay normal/small. They are NOT enlarged.
-- No pond, island, trees, fish, lotus, lobby, statues or gameplay yet.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace

local foundation = Instance.new("Model")
foundation.Name = "OuterStonePath"
foundation.Parent = world

local guides = Instance.new("Folder")
guides.Name = "ScaleGuides"
guides.Parent = world

local C = {
    stone = Color3.fromRGB(166, 169, 164),
    stoneLight = Color3.fromRGB(202, 202, 194),
    trim = Color3.fromRGB(91, 94, 91),
    guide = Color3.fromRGB(255, 210, 70),
}

local function slab(name, size, cf, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = true
    p.CanTouch = true
    p.CanQuery = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Material = material or Enum.Material.Slate
    p.Color = color or C.stone
    p.Parent = parent
    return p
end

-- MASTER WORLD SCALE
-- V10 footprint was 2100 x 1700.
-- V11 uses 6600 x 5400. This is about 10x the V10 AREA while keeping normal-sized slabs.
-- The future pond gets almost the entire inner footprint.
local OUTER_X = 6600
local OUTER_Z = 5400
local PATH_WIDTH = 14
local PATH_Y = 2
local CORNER_RADIUS_X = 360
local CORNER_RADIUS_Z = 300

local halfX = OUTER_X / 2
local halfZ = OUTER_Z / 2
local innerHalfX = halfX - PATH_WIDTH
local innerHalfZ = halfZ - PATH_WIDTH

local function makeStraightHorizontal(z, startX, endX, sectionName)
    local x = startX
    local index = 0
    while x < endX - 0.1 do
        index += 1
        local length = math.min(10, endX - x)
        local cx = x + length / 2
        slab(sectionName .. "_Slab_" .. index, Vector3.new(math.max(1, length - 0.35), 1.4, PATH_WIDTH), CFrame.new(cx, PATH_Y, z), (index % 4 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
        x += length
    end
end

local function makeStraightVertical(x, startZ, endZ, sectionName)
    local z = startZ
    local index = 0
    while z < endZ - 0.1 do
        index += 1
        local length = math.min(10, endZ - z)
        local cz = z + length / 2
        slab(sectionName .. "_Slab_" .. index, Vector3.new(PATH_WIDTH, 1.4, math.max(1, length - 0.35)), CFrame.new(x, PATH_Y, cz), (index % 4 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
        z += length
    end
end

makeStraightHorizontal(-halfZ + CORNER_RADIUS_Z / 2, -halfX + CORNER_RADIUS_X, halfX - CORNER_RADIUS_X, "NorthOuter")
makeStraightHorizontal( halfZ - CORNER_RADIUS_Z / 2, -halfX + CORNER_RADIUS_X, halfX - CORNER_RADIUS_X, "SouthOuter")
makeStraightVertical(-halfX + CORNER_RADIUS_X / 2, -halfZ + CORNER_RADIUS_Z, halfZ - CORNER_RADIUS_Z, "WestOuter")
makeStraightVertical( halfX - CORNER_RADIUS_X / 2, -halfZ + CORNER_RADIUS_Z, halfZ - CORNER_RADIUS_Z, "EastOuter")

local function makeCorner(cx, cz, sx, sz, label)
    local count = 40
    for i = 1, count do
        local t0 = (i - 1) / count * (math.pi / 2)
        local t1 = i / count * (math.pi / 2)
        local t = (t0 + t1) / 2
        local rx = CORNER_RADIUS_X
        local rz = CORNER_RADIUS_Z
        local px = cx + sx * math.cos(t) * rx
        local pz = cz + sz * math.sin(t) * rz
        local dx = -sx * math.sin(t) * rx
        local dz = sz * math.cos(t) * rz
        local yaw = math.atan2(dz, dx)
        local tangential = 8
        slab(label .. "_Slab_" .. i, Vector3.new(tangential, 1.4, PATH_WIDTH), CFrame.new(px, PATH_Y, pz) * CFrame.Angles(0, yaw, 0), (i % 4 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
    end
end

makeCorner(-halfX + CORNER_RADIUS_X, -halfZ + CORNER_RADIUS_Z, -1, -1, "NorthWestCorner")
makeCorner( halfX - CORNER_RADIUS_X, -halfZ + CORNER_RADIUS_Z,  1, -1, "NorthEastCorner")
makeCorner(-halfX + CORNER_RADIUS_X,  halfZ - CORNER_RADIUS_Z, -1,  1, "SouthWestCorner")
makeCorner( halfX - CORNER_RADIUS_X,  halfZ - CORNER_RADIUS_Z,  1,  1, "SouthEastCorner")

-- Thin inner boundary so the future pond has a clean master edge.
slab("NorthInnerBorder", Vector3.new(OUTER_X - CORNER_RADIUS_X * 2, 0.5, 0.9), CFrame.new(0, PATH_Y + 0.8, -innerHalfZ), C.trim, Enum.Material.Slate, foundation)
slab("SouthInnerBorder", Vector3.new(OUTER_X - CORNER_RADIUS_X * 2, 0.5, 0.9), CFrame.new(0, PATH_Y + 0.8, innerHalfZ), C.trim, Enum.Material.Slate, foundation)
slab("WestInnerBorder", Vector3.new(0.9, 0.5, OUTER_Z - CORNER_RADIUS_Z * 2), CFrame.new(-innerHalfX, PATH_Y + 0.8, 0), C.trim, Enum.Material.Slate, foundation)
slab("EastInnerBorder", Vector3.new(0.9, 0.5, OUTER_Z - CORNER_RADIUS_Z * 2), CFrame.new(innerHalfX, PATH_Y + 0.8, 0), C.trim, Enum.Material.Slate, foundation)

-- Small practical entry markers. These remain normal size even though the world is enormous.
local entryWidth = 28
slab("FrontEntry", Vector3.new(entryWidth, 1.6, PATH_WIDTH + 4), CFrame.new(0, PATH_Y + 0.15, halfZ - PATH_WIDTH / 2), C.stoneLight, Enum.Material.Slate, foundation)
slab("BackEntry", Vector3.new(entryWidth, 1.6, PATH_WIDTH + 4), CFrame.new(0, PATH_Y + 0.15, -halfZ + PATH_WIDTH / 2), C.stoneLight, Enum.Material.Slate, foundation)
slab("LeftEntry", Vector3.new(PATH_WIDTH + 4, 1.6, entryWidth), CFrame.new(-halfX + PATH_WIDTH / 2, PATH_Y + 0.15, 0), C.stoneLight, Enum.Material.Slate, foundation)
slab("RightEntry", Vector3.new(PATH_WIDTH + 4, 1.6, entryWidth), CFrame.new(halfX - PATH_WIDTH / 2, PATH_Y + 0.15, 0), C.stoneLight, Enum.Material.Slate, foundation)

-- Planning guides only. These are the footprints for the NEXT phases.
local function guideMarker(name, size)
    local p = slab(name, size, CFrame.new(0, PATH_Y + 1.1, 0), C.guide, Enum.Material.Neon, guides)
    p.Transparency = 0.5
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
end

-- Huge future swimming pond: about 10x V10 planning area.
guideMarker("FuturePondBounds", Vector3.new(6300, 0.15, 5100))
-- Large central island reserved inside the huge pond; exact shape will be decided after pond testing.
guideMarker("FutureIslandCenter", Vector3.new(1800, 0.2, 1400))

world:SetAttribute("MapVersion", "OuterStonePath_v11_HugePond")
world:SetAttribute("OuterFootprintX", OUTER_X)
world:SetAttribute("OuterFootprintZ", OUTER_Z)
world:SetAttribute("OuterPathWidth", PATH_WIDTH)
world:SetAttribute("StoneSlabModuleLength", 10)
world:SetAttribute("InnerBuildableX", OUTER_X - PATH_WIDTH * 2)
world:SetAttribute("InnerBuildableZ", OUTER_Z - PATH_WIDTH * 2)
world:SetAttribute("FuturePondGuideX", 6300)
world:SetAttribute("FuturePondGuideZ", 5100)
world:SetAttribute("FutureIslandGuideX", 1800)
world:SetAttribute("FutureIslandGuideZ", 1400)

Lighting.ClockTime = 14
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 0.7
Lighting.EnvironmentSpecularScale = 0.35
Lighting.OutdoorAmbient = Color3.fromRGB(170, 175, 170)

print("FrogGame V11 loaded: huge pond boundary; normal-sized stone slabs")
