-- Frog Game: Pond + Frog Island environment builder
-- Rojo entry point. The world is generated in Workspace when the server starts.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace

local map = Instance.new("Folder")
map.Name = "PondAndIsland"
map.Parent = world

local function part(name, size, cf, material, color, parent, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color or Color3.fromRGB(255,255,255)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = parent or map
	return p
end

local function ball(name, size, pos, color, parent)
	return part(name, size, CFrame.new(pos), Enum.Material.SmoothPlastic, color, parent, Enum.PartType.Ball)
end

local function cyl(name, radius, height, pos, color, parent)
	-- Roblox cylinders are X-axis aligned, so rotate them upright.
	return part(name, Vector3.new(height, radius*2, radius*2), CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90)), Enum.Material.Wood, color, parent, Enum.PartType.Cylinder)
end

local function wedge(name, size, cf, color, parent)
	return part(name, size, cf, Enum.Material.SmoothPlastic, color, parent, Enum.PartType.Wedge)
end

local WATER = Color3.fromRGB(75, 174, 168)
local WATER2 = Color3.fromRGB(96, 197, 188)
local GRASS = Color3.fromRGB(105, 171, 93)
local GRASS2 = Color3.fromRGB(132, 190, 105)
local DIRT = Color3.fromRGB(142, 104, 67)
local SAND = Color3.fromRGB(220, 198, 139)
local WOOD = Color3.fromRGB(106, 72, 48)
local ROCK = Color3.fromRGB(112, 116, 105)
local PETAL = Color3.fromRGB(255, 181, 205)
local SAKURA = Color3.fromRGB(255, 142, 180)
local LEAF = Color3.fromRGB(83, 146, 86)

-- Base terrain / pond.
part("PondBed", Vector3.new(180, 5, 150), CFrame.new(0,-4,0), Enum.Material.Ground, DIRT)
part("PondWater", Vector3.new(168, 1.5, 138), CFrame.new(0,-1.2,0), Enum.Material.Glass, WATER)

-- Soft shoreline strips.
for i = 1, 28 do
	local a = (i/28)*math.pi*2
	local x,z = math.cos(a)*79, math.sin(a)*64
	ball("ShoreStone", Vector3.new(7,3,6), Vector3.new(x,0,z), SAND)
end

-- Central Frog Island: layered, rounded silhouette.
local island = Instance.new("Model")
island.Name = "FrogIsland"
island.Parent = map
part("IslandBase", Vector3.new(74,5,62), CFrame.new(0,1,0), Enum.Material.Ground, DIRT, island)
part("IslandGrass", Vector3.new(68,3,56), CFrame.new(0,4,0), Enum.Material.Grass, GRASS, island)
for i = 1, 18 do
	local a = (i/18)*math.pi*2
	local r = 27 + (i%3)*3
	ball("GrassMound", Vector3.new(18,5,14), Vector3.new(math.cos(a)*r,5,math.sin(a)*r*0.75), GRASS2, island)
end

-- Sandy entrance and natural stone path.
part("IslandEntrance", Vector3.new(12,1,10), CFrame.new(0,5,31), Enum.Material.Sand, SAND, island)
for i = 1, 8 do
	local z = 25 - i*3
	ball("PathStone", Vector3.new(7,1.2,5), Vector3.new((i%2==0 and -2 or 2),5.2,z), ROCK, island)
end

-- Central pond / lily area on the island.
part("IslandPool", Vector3.new(30,0.8,22), CFrame.new(0,6.2,-2), Enum.Material.Glass, WATER2, island)
for i = 1, 9 do
	local a = i/9*math.pi*2
	local x,z = math.cos(a)*10, -2+math.sin(a)*7
	local lily = ball("LilyPad", Vector3.new(4.5,0.35,3.8), Vector3.new(x,6.8,z), Color3.fromRGB(73,145,83), island)
	lily.Shape = Enum.PartType.Cylinder
	lily.CFrame = CFrame.new(x,6.8,z) * CFrame.Angles(0,0,math.rad(90))
end

-- Rocks around the island.
for i = 1, 20 do
	local a = i/20*math.pi*2
	local r = 31 + (i%4)*2
	ball("IslandRock", Vector3.new(4+(i%3),3,3+(i%2)), Vector3.new(math.cos(a)*r,5,math.sin(a)*r*0.8), ROCK, island)
end

-- Tree builder: stylized Sakura trees matching the reference mood.
local function tree(name, pos, scale)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = island
	local trunkH = 15*scale
	cyl("Trunk", 1.5*scale, trunkH, pos + Vector3.new(0,trunkH/2,0), WOOD, model)
	for k = 1, 4 do
		local ang = k*math.pi/2 + 0.4
		local branchStart = pos + Vector3.new(0,trunkH*0.58,0)
		local endPos = branchStart + Vector3.new(math.cos(ang)*6*scale, 4*scale, math.sin(ang)*6*scale)
		local mid = (branchStart+endPos)/2
		local length = (endPos-branchStart).Magnitude
		local b = cyl("Branch", 0.55*scale, length, mid, WOOD, model)
		b.CFrame = CFrame.lookAt(mid,endPos) * CFrame.Angles(0,math.rad(90),0)
	end
	for j = 1, 9 do
		local a = j/9*math.pi*2
		local rr = (3.5 + (j%3)*1.2)*scale
		ball("SakuraCrown", Vector3.new(rr*2.0,rr*1.25,rr*2.0), pos + Vector3.new(math.cos(a)*rr,trunkH+4*scale+(j%2)*1.2,math.sin(a)*rr), SAKURA, model)
	end
	for j = 1, 5 do
		ball("SakuraLeaf", Vector3.new(2.5*scale,1.8*scale,2.5*scale), pos + Vector3.new((j-3)*2*scale,trunkH+6*scale, (j%2)*3*scale), LEAF, model)
	end
	return model
end

tree("SakuraTree_Center", Vector3.new(0,6,-20), 1.15)
tree("SakuraTree_Left", Vector3.new(-25,6,-7), 0.9)
tree("SakuraTree_Right", Vector3.new(25,6,-8), 0.95)
tree("SakuraTree_BackLeft", Vector3.new(-24,6,17), 0.8)
tree("SakuraTree_BackRight", Vector3.new(24,6,18), 0.82)

-- Bush clusters create the cozy, enclosed island silhouette.
local function bush(pos, s)
	for i=1,5 do
		local a=i/5*math.pi*2
		ball("Bush", Vector3.new(5*s,4*s,5*s), pos+Vector3.new(math.cos(a)*2*s,2*s,math.sin(a)*2*s), LEAF)
	end
end
bush(Vector3.new(-30,6,25),1)
bush(Vector3.new(30,6,25),1)
bush(Vector3.new(-31,6,-25),0.9)
bush(Vector3.new(31,6,-25),0.9)

-- Reeds around the water edge.
for i=1,34 do
	local a=i/34*math.pi*2
	local r=68+(i%4)*4
	local x,z=math.cos(a)*r,math.sin(a)*r*0.78
	for j=1,3 do
		local h=4+(j%3)*1.2
		cyl("Reed",0.18,h,Vector3.new(x+(j-2)*0.7,0+h/2,z+(j%2)*0.6),Color3.fromRGB(92,139,70))
	end
end

-- Lotus flowers floating in the pond.
local function lotus(pos)
	for i=1,7 do
		local a=i/7*math.pi*2
		local p=ball("LotusPetal",Vector3.new(2.6,0.5,1.3),pos+Vector3.new(math.cos(a)*1.2,0.3,math.sin(a)*1.2),PETAL)
		p.CFrame=p.CFrame*CFrame.Angles(0,-a,math.rad(-12))
	end
	ball("LotusCenter",Vector3.new(1.4,0.7,1.4),pos+Vector3.new(0,0.6,0),Color3.fromRGB(255,220,110))
end
lotus(Vector3.new(-48,-0.2,-25))
lotus(Vector3.new(48,-0.2,22))
lotus(Vector3.new(-52,-0.2,30))

-- Six player display stalls around the pond perimeter.
local stalls=Instance.new("Folder")
stalls.Name="PlayerDisplayAreas"
stalls.Parent=world
for i=1,6 do
	local a=(i-1)/6*math.pi*2
	local pos=Vector3.new(math.cos(a)*78,2,math.sin(a)*62)
	local stall=Instance.new("Model")
	stall.Name="PlayerStall_"..i
	stall.Parent=stalls
	part("Platform",Vector3.new(18,2,12),CFrame.new(pos),Enum.Material.Wood,WOOD,stall)
	part("BackWall",Vector3.new(18,10,1),CFrame.new(pos+Vector3.new(0,6,5)),Enum.Material.Wood,WOOD,stall)
	part("Sign",Vector3.new(12,3,0.6),CFrame.new(pos+Vector3.new(0,11,4.2)),Enum.Material.SmoothPlastic,Color3.fromRGB(245,225,174),stall)
	for slot=1,6 do
		local x=((slot-1)%3-1)*5
		local z=(math.floor((slot-1)/3)-0.5)*4
		ball("DollDisplaySlot",Vector3.new(2.2,2.2,2.2),pos+Vector3.new(x,3,z),Color3.fromRGB(242,202,154),stall)
	end
end

-- Decorative boat.
local boat=Instance.new("Model")
boat.Name="DecorativeSailboat"
boat.Parent=map
part("Hull",Vector3.new(14,2.5,5),CFrame.new(0,0,52)*CFrame.Angles(0,0,0),Enum.Material.Wood,WOOD,boat)
part("Mast",Vector3.new(0.5,13,0.5),CFrame.new(0,7,52),Enum.Material.Wood,WOOD,boat)
part("Sail",Vector3.new(0.4,7,6),CFrame.new(2.2,8,52),Enum.Material.Fabric,Color3.fromRGB(250,244,225),boat)

-- Falling Sakura petals for the requested ambience.
local petals=Instance.new("Folder")
petals.Name="FallingSakuraPetals"
petals.Parent=world
for i=1,80 do
	local p=part("Petal",Vector3.new(0.35,0.08,0.5),CFrame.new(math.random(-70,70),math.random(7,28),math.random(-60,60)),Enum.Material.SmoothPlastic,PETAL,petals)
	p.CanCollide=false
	local target=p.Position+Vector3.new(math.random(-10,10),-25,math.random(-10,10))
	local duration=8+math.random()*8
	TweenService:Create(p,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=target,Rotation=Vector3.new(math.random(0,360),math.random(0,360),math.random(0,360))}):Play()
end

-- Spawn / gameplay regions for the later systems.
local regions=Instance.new("Folder")
regions.Name="GameplayRegions"
regions.Parent=world
local spawn=part("FrogSpawnRegion",Vector3.new(40,0.5,26),CFrame.new(0,7,-2),Enum.Material.SmoothPlastic,Color3.fromRGB(80,180,100),regions)
spawn.Transparency=1
spawn.CanCollide=false
local start=part("RaceStart",Vector3.new(16,0.5,5),CFrame.new(0,7,23),Enum.Material.SmoothPlastic,Color3.fromRGB(255,230,120),regions)
start.Transparency=0.65
local entrance=part("IslandEntranceRegion",Vector3.new(12,0.5,10),CFrame.new(0,7,31),Enum.Material.SmoothPlastic,Color3.fromRGB(120,210,180),regions)
entrrance=nil
entrance.Transparency=1
entrance.CanCollide=false

-- World tuning attributes used by upcoming gameplay systems.
world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LegendaryTimerSeconds",1800)
world:SetAttribute("SecretTimerSeconds",3600)
world:SetAttribute("MapVersion","PondIsland_v1")

Lighting.ClockTime=16.5
Lighting.Brightness=2.2
Lighting.EnvironmentDiffuseScale=0.55
Lighting.EnvironmentSpecularScale=0.35
Lighting.OutdoorAmbient=Color3.fromRGB(160,170,155)

local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density=0.28
atmosphere.Offset=0.1
atmosphere.Glare=0.12
atmosphere.Haze=1.2
atmosphere.Parent=Lighting

print("FrogGame: Pond + Frog Island environment loaded successfully.")
