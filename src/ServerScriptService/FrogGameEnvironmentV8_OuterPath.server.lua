-- Frog Game Environment V8
-- STEP 1 ONLY: large outer stone path / scale foundation.
-- No pond, island, trees, fish, lotus, lobby, statues or gameplay yet.
-- The path establishes the final world footprint so the pond and island can be sized against it.

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
    stoneDark = Color3.fromRGB(116, 120, 116),
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

-- WORLD SCALE
-- Outer footprint: approximately 420 x 340 studs.
-- Main path width: 14 studs.
-- Inner opening: approximately 392 x 312 studs.
local OUTER_X = 420
local OUTER_Z = 340
local PATH_WIDTH = 14
local PATH_Y = 2
local CORNER_RADIUS_X = 34
local CORNER_RADIUS_Z = 28

-- Build a rounded-rectangle loop from individual stone slabs.
-- Straight sections use 10-stud slabs. Curves use shorter radial slabs.
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
        slab(sectionName .. "_Slab_" .. index, Vector3.new(length - 0.35, 1.4, PATH_WIDTH), CFrame.new(cx, PATH_Y, z), (index % 3 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
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
        slab(sectionName .. "_Slab_" .. index, Vector3.new(PATH_WIDTH, 1.4, length - 0.35), CFrame.new(x, PATH_Y, cz), (index % 3 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
        z += length
    end
end

-- Straight sides. Corners are completed with curved slab sections below.
makeStraightHorizontal(-halfZ + CORNER_RADIUS_Z / 2, -halfX + CORNER_RADIUS_X, halfX - CORNER_RADIUS_X, "NorthOuter")
makeStraightHorizontal( halfZ - CORNER_RADIUS_Z / 2, -halfX + CORNER_RADIUS_X, halfX - CORNER_RADIUS_X, "SouthOuter")
makeStraightVertical(-halfX + CORNER_RADIUS_X / 2, -halfZ + CORNER_RADIUS_Z, halfZ - CORNER_RADIUS_Z, "WestOuter")
makeStraightVertical( halfX - CORNER_RADIUS_X / 2, -halfZ + CORNER_RADIUS_Z, halfZ - CORNER_RADIUS_Z, "EastOuter")

-- Curved corner stones. Each slab is tangent to an ellipse-like corner.
local function makeCorner(cx, cz, sx, sz, label)
    local count = 12
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
        local arcLength = math.sqrt((rx * (t1 - t0)) ^ 2 + (rz * (t1 - t0)) ^ 2)
        local tangential = math.max(5.2, math.min(9.5, arcLength))
        slab(label .. "_Slab_" .. i, Vector3.new(tangential, 1.4, PATH_WIDTH), CFrame.new(px, PATH_Y, pz) * CFrame.Angles(0, yaw, 0), (i % 3 == 0) and C.stoneLight or C.stone, Enum.Material.Slate, foundation)
    end
end

-- Rounded corners, using centers just inside the footprint.
makeCorner(-halfX + CORNER_RADIUS_X, -halfZ + CORNER_RADIUS_Z, -1, -1, "NorthWestCorner")
makeCorner( halfX - CORNER_RADIUS_X, -halfZ + CORNER_RADIUS_Z,  1, -1, "NorthEastCorner")
makeCorner(-halfX + CORNER_RADIUS_X,  halfZ - CORNER_RADIUS_Z, -1,  1, "SouthWestCorner")
makeCorner( halfX - CORNER_RADIUS_X,  halfZ - CORNER_RADIUS_Z,  1,  1, "SouthEastCorner")

-- Thin darker border on the inside edge. This gives the future pond a very clear boundary.
slab("NorthInnerBorder", Vector3.new(OUTER_X - CORNER_RADIUS_X * 2, 0.5, 0.9), CFrame.new(0, PATH_Y + 0.8, -innerHalfZ), C.trim, Enum.Material.Slate, foundation)
slab("SouthInnerBorder", Vector3.new(OUTER_X - CORNER_RADIUS_X * 2, 0.5, 0.9), CFrame.new(0, PATH_Y + 0.8, innerHalfZ), C.trim, Enum.Material.Slate, foundation)
slab("WestInnerBorder", Vector3.new(0.9, 0.5, OUTER_Z - CORNER_RADIUS_Z * 2), CFrame.new(-innerHalfX, PATH_Y + 0.8, 0), C.trim, Enum.Material.Slate, foundation)
slab("EastInnerBorder", Vector3.new(0.9, 0.5, OUTER_Z - CORNER_RADIUS_Z * 2), CFrame.new(innerHalfX, PATH_Y + 0.8, 0), C.trim, Enum.Material.Slate, foundation)

-- Four broad measuring/entry points. These are only stone path geometry for now.
local entryWidth = 28
slab("FrontEntry", Vector3.new(entryWidth, 1.6, PATH_WIDTH + 4), CFrame.new(0, PATH_Y + 0.15, halfZ - PATH_WIDTH / 2), C.stoneLight, Enum.Material.Slate, foundation)
slab("BackEntry", Vector3.new(entryWidth, 1.6, PATH_WIDTH + 4), CFrame.new(0, PATH_Y + 0.15, -halfZ + PATH_WIDTH / 2), C.stoneLight, Enum.Material.Slate, foundation)
slab("LeftEntry", Vector3.new(PATH_WIDTH + 4, 1.6, entryWidth), CFrame.new(-halfX + PATH_WIDTH / 2, PATH_Y + 0.15, 0), C.stoneLight, Enum.Material.Slate, foundation)
slab("RightEntry", Vector3.new(PATH_WIDTH + 4, 1.6, entryWidth), CFrame.new(halfX - PATH_WIDTH / 2, PATH_Y + 0.15, 0), C.stoneLight, Enum.Material.Slate, foundation)

-- Centered stone markers show the future layout without committing to pond/island geometry yet.
local function guideMarker(name, pos, size)
    local p = slab(name, size, CFrame.new(pos.X, PATH_Y + 1.1, pos.Z), C.guide, Enum.Material.Neon, guides)
    p.Transparency = 0.35
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
end

guideMarker("FuturePondBounds", Vector3.new(0, 0, 0), Vector3.new(390, 0.15, 310))
guideMarker("FutureIslandCenter", Vector3.new(0, 0, 0), Vector3.new(150, 0.2, 120))

-- Attributes are the design measurements for the next phases.
world:SetAttribute("MapVersion", "OuterStonePath_v8")
world:SetAttribute("OuterFootprintX", OUTER_X)
world:SetAttribute("OuterFootprintZ", OUTER_Z)
world:SetAttribute("OuterPathWidth", PATH_WIDTH)
world:SetAttribute("InnerBuildableX", OUTER_X - PATH_WIDTH * 2)
world:SetAttribute("InnerBuildableZ", OUTER_Z - PATH_WIDTH * 2)
world:SetAttribute("FuturePondGuideX", 390)
world:SetAttribute("FuturePondGuideZ", 310)
world:SetAttribute("FutureIslandGuideX", 150)
world:SetAttribute("FutureIslandGuideZ", 120)

-- Neutral lighting for accurate geometry testing.
Lighting.ClockTime = 14
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 0.7
Lighting.EnvironmentSpecularScale = 0.35
Lighting.OutdoorAmbient = Color3.fromRGB(170, 175, 170)

print("FrogGame V8 loaded: OUTER STONE PATH ONLY - world footprint established")
