-- Frog Game Environment V11
-- FOUNDATION ONLY
-- Rebuilt from scratch: large playable footprint + normal-sized modular stone perimeter.
-- This phase intentionally contains NO pond, island, trees, fish, lotus, lobby or gameplay.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace

local foundation = Instance.new("Model")
foundation.Name = "Foundation"
foundation.Parent = world

local path = Instance.new("Folder")
path.Name = "OuterStonePath"
path.Parent = foundation

local guides = Instance.new("Folder")
guides.Name = "PlanningGuides"
guides.Parent = foundation

-- MASTER SCALE
-- Large enough for the intended shared swimming pond and central island.
local WORLD_X = 6600
local WORLD_Z = 5400
local PATH_WIDTH = 18
local SLAB_LENGTH = 12
local SLAB_GAP = 0.7
local PATH_Y = 1.5
local CORNER_RX = 420
local CORNER_RZ = 360

local COLORS = {
	stone = Color3.fromRGB(150, 153, 148),
	stoneAlt = Color3.fromRGB(174, 176, 168),
	edge = Color3.fromRGB(88, 91, 87),
	guide = Color3.fromRGB(255, 210, 70),
}

local function makePart(name, size, cf, material, color, parent)
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
	p.Material = material
	p.Color = color
	p.Parent = parent
	return p
end

local function stone(name, size, cf, index)
	local p = makePart(name, size, cf, Enum.Material.Slate, (index % 5 == 0) and COLORS.stoneAlt or COLORS.stone, path)
	-- Tiny height variation keeps the path organic without changing its module scale.
	p.CFrame = cf * CFrame.new(0, ((index % 3) - 1) * 0.05, 0)
	return p
end

-- Use a rounded rectangle centerline. Every module remains a normal 12-stud slab.
local hx = WORLD_X / 2 - CORNER_RX
local hz = WORLD_Z / 2 - CORNER_RZ

local function straightHorizontal(z, x0, x1, label, direction)
	local x = x0
	local i = 0
	while x < x1 - 0.01 do
		i += 1
		local len = math.min(SLAB_LENGTH, x1 - x)
		local actual = math.max(2, len - SLAB_GAP)
		local cx = x + len / 2
		stone(label .. string.format("_%04d", i), Vector3.new(actual, 1.5, PATH_WIDTH), CFrame.new(cx, PATH_Y, z), i)
		x += len
	end
end

local function straightVertical(x, z0, z1, label)
	local z = z0
	local i = 0
	while z < z1 - 0.01 do
		i += 1
		local len = math.min(SLAB_LENGTH, z1 - z)
		local actual = math.max(2, len - SLAB_GAP)
		local cz = z + len / 2
		stone(label .. string.format("_%04d", i), Vector3.new(PATH_WIDTH, 1.5, actual), CFrame.new(x, PATH_Y, cz), i)
		z += len
	end
end

straightHorizontal(-WORLD_Z/2, -hx, hx, "North")
straightHorizontal( WORLD_Z/2, -hx, hx, "South")
straightVertical(-WORLD_X/2, -hz, hz, "West")
straightVertical( WORLD_X/2, -hz, hz, "East")

-- Four true quarter-circle corners. Stones are tangent to the curve and evenly spaced.
local function corner(centerX, centerZ, startAngle, label, phase)
	local arcLength = math.pi * math.sqrt((CORNER_RX^2 + CORNER_RZ^2) / 2) / 2
	local count = math.max(24, math.ceil(arcLength / SLAB_LENGTH))
	for i = 1, count do
		local a0 = startAngle + (i - 1) * (math.pi/2) / count
		local a1 = startAngle + i * (math.pi/2) / count
		local a = (a0 + a1) / 2
		local x = centerX + math.cos(a) * CORNER_RX
		local z = centerZ + math.sin(a) * CORNER_RZ
		local tx = -math.sin(a) * CORNER_RX
		local tz = math.cos(a) * CORNER_RZ
		local yaw = math.atan2(tz, tx)
		local tangentLen = math.max(5, 0.92 * (arcLength / count))
		stone(label .. string.format("_%04d", i), Vector3.new(tangentLen, 1.5, PATH_WIDTH), CFrame.new(x, PATH_Y, z) * CFrame.Angles(0, yaw, 0), i + phase)
	end
end

-- Corner centers are inset by the radii; angle ranges connect the four straight runs.
corner(-hx, -hz, math.pi, "NW", 1)
corner( hx, -hz, -math.pi/2, "NE", 2)
corner(-hx,  hz, math.pi/2, "SW", 3)
corner( hx,  hz, 0, "SE", 4)

-- Clean, low inner boundary. It is a guide edge, not an oversized stone wall.
local innerX = WORLD_X/2 - PATH_WIDTH
local innerZ = WORLD_Z/2 - PATH_WIDTH
makePart("InnerNorthEdge", Vector3.new(WORLD_X - 2*CORNER_RX, 0.35, 1), CFrame.new(0, PATH_Y + 0.9, -innerZ), Enum.Material.Slate, COLORS.edge, foundation)
makePart("InnerSouthEdge", Vector3.new(WORLD_X - 2*CORNER_RX, 0.35, 1), CFrame.new(0, PATH_Y + 0.9, innerZ), Enum.Material.Slate, COLORS.edge, foundation)
makePart("InnerWestEdge", Vector3.new(1, 0.35, WORLD_Z - 2*CORNER_RZ), CFrame.new(-innerX, PATH_Y + 0.9, 0), Enum.Material.Slate, COLORS.edge, foundation)
makePart("InnerEastEdge", Vector3.new(1, 0.35, WORLD_Z - 2*CORNER_RZ), CFrame.new(innerX, PATH_Y + 0.9, 0), Enum.Material.Slate, COLORS.edge, foundation)

-- Four simple entry pads establish orientation without becoming another system.
local function entry(name, size, cf)
	local p = makePart(name, size, cf, Enum.Material.Slate, COLORS.stoneAlt, path)
	p:SetAttribute("FoundationEntry", true)
end
entry("NorthEntry", Vector3.new(36, 1.8, PATH_WIDTH + 8), CFrame.new(0, PATH_Y + 0.1, -WORLD_Z/2))
entry("SouthEntry", Vector3.new(36, 1.8, PATH_WIDTH + 8), CFrame.new(0, PATH_Y + 0.1, WORLD_Z/2))
entry("WestEntry", Vector3.new(PATH_WIDTH + 8, 1.8, 36), CFrame.new(-WORLD_X/2, PATH_Y + 0.1, 0))
entry("EastEntry", Vector3.new(PATH_WIDTH + 8, 1.8, 36), CFrame.new(WORLD_X/2, PATH_Y + 0.1, 0))

-- Planning guides are transparent and non-collidable; they make the next build measurable.
local function guide(name, size, y)
	local p = makePart(name, Vector3.new(size.X, 0.15, size.Z), CFrame.new(0, y, 0), Enum.Material.Neon, COLORS.guide, guides)
	p.Transparency = 0.92
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
end

guide("FuturePondFootprint", Vector3.new(6300, 0.15, 5100), PATH_Y + 1.0)

guide("FutureIslandPlanningArea", Vector3.new(1800, 0.15, 1400), PATH_Y + 1.15)

world:SetAttribute("MapVersion", "Foundation_v11_Rebuilt")
world:SetAttribute("WorldSizeX", WORLD_X)
world:SetAttribute("WorldSizeZ", WORLD_Z)
world:SetAttribute("OuterPathWidth", PATH_WIDTH)
world:SetAttribute("NormalSlabLength", SLAB_LENGTH)
world:SetAttribute("FuturePondX", 6300)
world:SetAttribute("FuturePondZ", 5100)
world:SetAttribute("FoundationOnly", true)

Lighting.ClockTime = 14
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 0.7
Lighting.EnvironmentSpecularScale = 0.35
Lighting.OutdoorAmbient = Color3.fromRGB(170, 175, 170)

print("FrogGame Foundation V11 rebuilt: huge footprint, normal-sized stone path, no other systems")
