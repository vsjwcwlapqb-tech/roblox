-- Frog Game — Pond + Frog Island v2
-- Rebuilt for a large, clearly visible pond, larger organic island,
-- non-overlapping surfaces, lotus flowers, lily pads and animated fish.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Clean previous generated map.
local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end

-- Remove the default baseplate so it cannot z-fight with the generated terrain.
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

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
	p.Color = color or Color3.new(1,1,1)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = parent or map
	return p
end

local function ball(name, size, pos, color, parent, material)
	return part(name, size, CFrame.new(pos), material or Enum.Material.SmoothPlastic, color, parent, Enum.PartType.Ball)
end

local function cylinder(name, radius, height, pos, color, parent, material)
	-- Roblox cylinders have their length along local X; rotate 90° around Z.
	return part(name, Vector3.new(height, radius*2, radius*2), CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90)), material or Enum.Material.Wood, color, parent, Enum.PartType.Cylinder)
end

local WATER = Color3.fromRGB(55, 166, 190)
local WATER_DEEP = Color3.fromRGB(36, 126, 158)
local GRASS = Color3.fromRGB(91, 164, 83)
local GRASS_LIGHT = Color3.fromRGB(123, 190, 101)
local DIRT = Color3.fromRGB(112, 78, 50)
local SAND = Color3.fromRGB(226, 203, 145)
local WOOD = Color3.fromRGB(91, 55, 38)
local ROCK = Color3.fromRGB(112, 116, 108)
local REED = Color3.fromRGB(67, 132, 73)
local PETAL = Color3.fromRGB(255, 177, 210)
local SAKURA = Color3.fromRGB(246, 143, 188)
local LEAF = Color3.fromRGB(72, 143, 79)
local LOTUS_WHITE = Color3.fromRGB(255, 226, 240)
local LOTUS_PINK = Color3.fromRGB(255, 170, 207)
local LOTUS_YELLOW = Color3.fromRGB(255, 218, 95)
local FISH = Color3.fromRGB(246, 159, 74)
local FISH_LIGHT = Color3.fromRGB(255, 205, 110)

-- =========================================================
-- LARGE WATER WORLD
-- =========================================================
-- The water is one clean, low plane. No second coplanar floor is used.
part("PondBottom", Vector3.new(230, 8, 190), CFrame.new(0,-8,0), Enum.Material.Ground, DIRT)
part("PondWater", Vector3.new(214, 2, 174), CFrame.new(0,-1,0), Enum.Material.Glass, WATER)

-- A darker underwater center gives depth without another visible surface.
part("DeepPond", Vector3.new(190, 1, 150), CFrame.new(0,-2.15,0), Enum.Material.SmoothPlastic, WATER_DEEP)

-- Sandy shoreline ring.
for i = 1, 48 do
	local a = (i-1)/48 * math.pi*2
	local rx = 103 + (i%3)*2
	local rz = 83 + (i%4)*2
	ball("ShoreSand", Vector3.new(7,2.5,7), Vector3.new(math.cos(a)*rx,0,math.sin(a)*rz), SAND)
end

-- =========================================================
-- LARGE ORGANIC FROG ISLAND
-- =========================================================
local island = Instance.new("Model")
island.Name = "FrogIsland"
island.Parent = map

-- Large rounded base rather than a small rectangular slab.
ball("IslandCore", Vector3.new(118,12,94), Vector3.new(0,5,0), DIRT, island, Enum.Material.Ground)
ball("IslandGrass", Vector3.new(108,8,84), Vector3.new(0,10,0), GRASS, island, Enum.Material.Grass)

-- Extra grass lobes create an organic silhouette.
local lobes = {
	Vector3.new(-43,10,-18), Vector3.new(-25,10,-34), Vector3.new(0,10,-39),
	Vector3.new(28,10,-32), Vector3.new(45,10,-15), Vector3.new(43,10,17),
	Vector3.new(25,10,31), Vector3.new(0,10,38), Vector3.new(-28,10,32), Vector3.new(-45,10,16)
}
for i,pos in ipairs(lobes) do
	ball("GrassLobe", Vector3.new(38,8,30), pos, GRASS_LIGHT, island, Enum.Material.Grass)
end

-- Wide entrance from the mainland.
part("IslandEntrance", Vector3.new(18,2,14), CFrame.new(0,14,48), Enum.Material.Sand, SAND, island)
for i = 1, 11 do
	local z = 45 - i*4
	local x = (i%2==0 and -3 or 3)
	ball("PathStone", Vector3.new(8,1.5,6), Vector3.new(x,15,z), ROCK, island)
end

-- =========================================================
-- CENTRAL ISLAND POND / LOTUS GARDEN
-- =========================================================
-- Large recessed pond clearly visible in the center of the island.
part("IslandPondBed", Vector3.new(48,2,34), CFrame.new(0,14,-3), Enum.Material.SmoothPlastic, WATER_DEEP, island)
part("IslandPondWater", Vector3.new(45,1,31), CFrame.new(0,15,-3), Enum.Material.Glass, WATER, island)

local function lilyPad(pos, scale)
	local pad = cylinder("LilyPad", 2.8*scale, 0.35, pos, Color3.fromRGB(64,143,78), island, Enum.Material.Grass)
	pad.Size = Vector3.new(0.35,5.6*scale,5.6*scale)
	pad.CFrame = CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90))
	pad.CanCollide = false
	return pad
end

local function lotus(pos, scale)
	local model = Instance.new("Model")
	model.Name = "LotusFlower"
	model.Parent = island
	for i = 1, 8 do
		local a = (i-1)/8*math.pi*2
		local r = 1.35*scale
		local petal = part("Petal", Vector3.new(2.8*scale,0.55*scale,1.35*scale), CFrame.new(pos + Vector3.new(math.cos(a)*r,0.65,math.sin(a)*r)) * CFrame.Angles(0,-a,math.rad(-16)), Enum.Material.SmoothPlastic, (i%2==0 and LOTUS_PINK or LOTUS_WHITE), model, Enum.PartType.Ball)
		petal.CanCollide = false
	end
	ball("Center", Vector3.new(1.7*scale,0.9*scale,1.7*scale), pos + Vector3.new(0,1.0,0), LOTUS_YELLOW, model)
end

for _,pos in ipairs({
	Vector3.new(-14,16,-11), Vector3.new(13,16,-8), Vector3.new(-10,16,9),
	Vector3.new(14,16,7), Vector3.new(0,16,-1)
}) do
	lilyPad(pos - Vector3.new(0,0.15,0), 0.9)
end
lotus(Vector3.new(-13,15.8,-8),1)
lotus(Vector3.new(12,15.8,6),0.9)

-- =========================================================
-- FISH: visible animated swimming creatures
-- =========================================================
local fishFolder = Instance.new("Folder")
fishFolder.Name = "PondFish"
fishFolder.Parent = world

local fishData = {}
local function makeFish(i, center, radius, phase)
	local model = Instance.new("Model")
	model.Name = "Fish_"..i
	model.Parent = fishFolder

	local body = ball("Body", Vector3.new(2.8,1.4,1.7), center, FISH, model)
	local tail = part("Tail", Vector3.new(0.25,1.5,1.8), CFrame.new(center + Vector3.new(-1.6,0,0)), Enum.Material.SmoothPlastic, FISH_LIGHT, model, Enum.PartType.Wedge)
	tail.CanCollide = false
	body.CanCollide = false
	local eye = ball("Eye", Vector3.new(0.22,0.22,0.22), center + Vector3.new(1.05,0.42,-0.58), Color3.new(0.05,0.05,0.05), model)
	eye.CanCollide = false
	fishData[#fishData+1] = {model=model, radius=radius, phase=phase, y=center.Y, cx=center.X, cz=center.Z, speed=0.35+((i%4)*0.06)}
end

for i = 1, 10 do
	makeFish(i, Vector3.new(-65 + (i%5)*28, -0.1, -38 + math.floor(i/5)*35), 25+(i%3)*7, i*0.8)
end

-- =========================================================
-- TREES + BUSHES
-- =========================================================
local function tree(name, pos, scale)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = island
	local h = 20*scale
	cylinder("Trunk", 1.8*scale, h, pos + Vector3.new(0,h/2,0), WOOD, model)
	for k=1,5 do
		local a=k/5*math.pi*2
		local start=pos+Vector3.new(0,h*0.55,0)
		local finish=start+Vector3.new(math.cos(a)*7*scale,4*scale,math.sin(a)*7*scale)
		local mid=(start+finish)/2
		local b=cylinder("Branch",0.65*scale,(finish-start).Magnitude,mid,WOOD,model)
		b.CFrame=CFrame.lookAt(mid,finish)*CFrame.Angles(0,math.rad(90),0)
	end
	for j=1,11 do
		local a=j/11*math.pi*2
		local r=(4.0+(j%3)*1.3)*scale
		ball("SakuraCrown",Vector3.new(r*2.1,r*1.35,r*2.1),pos+Vector3.new(math.cos(a)*r,h+5*scale+(j%2)*1.5,math.sin(a)*r),SAKURA,model)
	end
end

tree("SakuraTree_Center",Vector3.new(0,14,-29),1.15)
tree("SakuraTree_Left",Vector3.new(-38,14,-8),0.95)
tree("SakuraTree_Right",Vector3.new(38,14,-7),0.95)
tree("SakuraTree_BackLeft",Vector3.new(-31,14,27),0.82)
tree("SakuraTree_BackRight",Vector3.new(31,14,27),0.82)

local function bush(pos,s)
	for i=1,6 do
		local a=i/6*math.pi*2
		ball("Bush",Vector3.new(7*s,5*s,7*s),pos+Vector3.new(math.cos(a)*2.7*s,2.5*s,math.sin(a)*2.7*s),LEAF)
	end
end
for _,p in ipairs({Vector3.new(-48,15,22),Vector3.new(48,15,22),Vector3.new(-49,15,-25),Vector3.new(49,15,-24),Vector3.new(0,15,35)}) do
	bush(p,1)
end

-- Rocks around island edges.
for i=1,28 do
	local a=(i-1)/28*math.pi*2
	local r=51+(i%4)*2
	ball("IslandRock",Vector3.new(5+(i%3),3.5,4+(i%2)),Vector3.new(math.cos(a)*r,15,math.sin(a)*r*0.75),ROCK,island)
end

-- Reeds sit around the OUTER pond, not on top of the island.
for i=1,55 do
	local a=(i-1)/55*math.pi*2
	local rx=91+(i%5)*4
	local rz=72+(i%4)*4
	for j=1,2 do
		local h=5+(j%3)*1.2
		cylinder("Reed",0.2,h,Vector3.new(math.cos(a)*rx+(j-1)*0.8,0.8+h/2,math.sin(a)*rz+(j%2)*0.8),REED)
	end
end

-- =========================================================
-- PLAYER DISPLAY AREAS — OUTSIDE THE MAIN POND
-- =========================================================
local stalls=Instance.new("Folder")
stalls.Name="PlayerDisplayAreas"
stalls.Parent=world
for i=1,6 do
	local a=(i-1)/6*math.pi*2
	local pos=Vector3.new(math.cos(a)*116,4,math.sin(a)*94)
	local stall=Instance.new("Model")
	stall.Name="PlayerStall_"..i
	stall.Parent=stalls
	part("Platform",Vector3.new(22,2,16),CFrame.new(pos),Enum.Material.Wood,WOOD,stall)
	part("BackWall",Vector3.new(22,10,1),CFrame.new(pos+Vector3.new(0,6,6.5)),Enum.Material.Wood,WOOD,stall)
	part("Sign",Vector3.new(15,3,0.6),CFrame.new(pos+Vector3.new(0,11,5.8)),Enum.Material.SmoothPlastic,Color3.fromRGB(245,225,174),stall)
	for slot=1,6 do
		local x=((slot-1)%3-1)*6
		local z=(math.floor((slot-1)/3)-0.5)*5
		ball("DollDisplaySlot",Vector3.new(2.5,2.5,2.5),pos+Vector3.new(x,3,z),Color3.fromRGB(242,202,154),stall)
	end
end

-- Decorative boat at the outer pond.
local boat=Instance.new("Model")
boat.Name="DecorativeSailboat"
boat.Parent=map
part("Hull",Vector3.new(18,3,7),CFrame.new(0,0,86),Enum.Material.Wood,WOOD,boat)
part("Mast",Vector3.new(0.7,17,0.7),CFrame.new(0,8,86),Enum.Material.Wood,WOOD,boat)
part("Sail",Vector3.new(0.4,9,8),CFrame.new(2.8,9,86),Enum.Material.Fabric,Color3.fromRGB(250,244,225),boat)

-- Falling Sakura petals, fewer and slower to keep the scene readable.
local petals=Instance.new("Folder")
petals.Name="FallingSakuraPetals"
petals.Parent=world
for i=1,55 do
	local p=part("Petal",Vector3.new(0.35,0.08,0.5),CFrame.new(math.random(-75,75),math.random(15,38),math.random(-60,60)),Enum.Material.SmoothPlastic,PETAL,petals)
	p.CanCollide=false
	p:SetAttribute("FallPhase",math.random()*10)
end

-- =========================================================
-- GAMEPLAY REGIONS
-- =========================================================
local regions=Instance.new("Folder")
regions.Name="GameplayRegions"
regions.Parent=world
local spawn=part("FrogSpawnRegion",Vector3.new(48,0.5,34),CFrame.new(0,17,-3),Enum.Material.SmoothPlastic,Color3.fromRGB(80,180,100),regions)
spawn.Transparency=1
spawn.CanCollide=false
local start=part("RaceStart",Vector3.new(20,0.5,6),CFrame.new(0,17,35),Enum.Material.SmoothPlastic,Color3.fromRGB(255,230,120),regions)
start.Transparency=1
start.CanCollide=false
local entrance=part("IslandEntranceRegion",Vector3.new(18,0.5,14),CFrame.new(0,17,48),Enum.Material.SmoothPlastic,Color3.fromRGB(120,210,180),regions)
entrrance=nil -- harmless compatibility cleanup; entrance is the actual region
entrance.Transparency=1
entrance.CanCollide=false

world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LegendaryTimerSeconds",1800)
world:SetAttribute("SecretTimerSeconds",3600)
world:SetAttribute("MapVersion","PondIsland_v2")

-- =========================================================
-- FISH + PETAL MOTION
-- =========================================================
local t0=os.clock()
local connection
connection=RunService.Heartbeat:Connect(function()
	if not world.Parent then
		connection:Disconnect()
		return
	end
	local t=os.clock()-t0
	for _,d in ipairs(fishData) do
		local a=t*d.speed+d.phase
		local x=d.cx+math.cos(a)*d.radius
		local z=d.cz+math.sin(a)*d.radius*0.7
		local y=d.y+math.sin(t*2+d.phase)*0.35
		d.model:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,-a,0))
	end
	for _,p in ipairs(petals:GetChildren()) do
		if p:IsA("BasePart") then
			local phase=p:GetAttribute("FallPhase") or 0
			local startY=30+(phase%8)
			local cycle=(t+phase)%12
			p.Position=Vector3.new(p.Position.X+math.sin(t*0.7+phase)*0.01,p.Position.Y,p.Position.Z)
			local y=startY-cycle*2.2
			if y<7 then y=startY end
			p.Position=Vector3.new(p.Position.X,y,p.Position.Z)
			p.Orientation=Vector3.new((t*35+phase*10)%360,(t*20)%360,(t*45+phase*7)%360)
		end
	end
end)

Lighting.ClockTime=16.5
Lighting.Brightness=2.4
Lighting.EnvironmentDiffuseScale=0.6
Lighting.EnvironmentSpecularScale=0.4
Lighting.OutdoorAmbient=Color3.fromRGB(165,175,165)

local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density=0.22
atmosphere.Offset=0.1
atmosphere.Glare=0.08
atmosphere.Haze=0.8
atmosphere.Parent=Lighting

print("FrogGame: Pond + Frog Island v2 loaded — large island, visible pond, lotus and fish.")
