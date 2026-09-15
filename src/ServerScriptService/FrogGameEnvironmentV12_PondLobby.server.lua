-- Frog Game Environment V12
-- REFERENCE LAYOUT BUILD
-- Huge swimming pond + central island + grassy six-player lobby.
-- Individual stones and decorative parts remain normal game scale.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end
Terrain:Clear()

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace

local map = Instance.new("Folder")
map.Name = "ReferenceMapV12"
map.Parent = world

local pondFolder = Instance.new("Folder")
pondFolder.Name = "Pond"
pondFolder.Parent = map
local islandFolder = Instance.new("Folder")
islandFolder.Name = "CentralIsland"
islandFolder.Parent = map
local lobbyFolder = Instance.new("Folder")
lobbyFolder.Name = "Lobby"
lobbyFolder.Parent = map
local decorFolder = Instance.new("Folder")
decorFolder.Name = "Decoration"
decorFolder.Parent = map

local C = {
	stone = Color3.fromRGB(150,153,148), stone2 = Color3.fromRGB(185,185,174),
	grass = Color3.fromRGB(82,145,68), darkGrass = Color3.fromRGB(48,108,55),
	wood = Color3.fromRGB(102,70,45), pink = Color3.fromRGB(245,145,190),
	water = Color3.fromRGB(42,170,205), white = Color3.fromRGB(235,235,220),
}

local function part(name,size,cf,material,color,parent,collide)
	local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Anchored=true
	p.Material=material or Enum.Material.SmoothPlastic p.Color=color or C.stone
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
	p.CanCollide=collide ~= false p.CanTouch=false p.CanQuery=collide ~= false p.Parent=parent
	return p
end

local function ball(name,pos,size,color,material,parent)
	local p=part(name,size,CFrame.new(pos),material or Enum.Material.SmoothPlastic,color,parent,false)
	p.Shape=Enum.PartType.Ball return p
end

-- MASTER DIMENSIONS: pond is intentionally enormous for real swimming space.
local WORLD_X,WORLD_Z = 6600,5400
local POND_X,POND_Z = 6100,4100
local WATER_Y,WATER_DEPTH = 0,-18
local ISLAND_X,ISLAND_Z = 1750,1250

-- Terrain water: actual swimmable water, not a blue floor.
Terrain:FillBlock(CFrame.new(0,WATER_DEPTH/2,0),Vector3.new(POND_X,WATER_Y-WATER_DEPTH,POND_Z),Enum.Material.Water)

-- Soft grassy land strip for the lobby, outside the water.
Terrain:FillBlock(CFrame.new(0,0,2380),Vector3.new(WORLD_X-120,12,520),Enum.Material.Grass)

-- Central island: large low cylinder with grass top and stone shoreline.
local islandBase=part("IslandLand",Vector3.new(ISLAND_X,95,ISLAND_Z),CFrame.new(0,18,0),Enum.Material.Grass,C.grass,islandFolder,true)
islandBase.Shape=Enum.PartType.Cylinder
islandBase.CFrame=CFrame.new(0,18,0)*CFrame.Angles(0,0,math.rad(90))
-- Slightly smaller grass crown.
local crown=part("IslandCrown",Vector3.new(ISLAND_X-80,10,ISLAND_Z-80),CFrame.new(0,70,0),Enum.Material.Grass,Color3.fromRGB(93,158,74),islandFolder,true)
crown.Shape=Enum.PartType.Cylinder crown.CFrame=CFrame.new(0,70,0)*CFrame.Angles(0,0,math.rad(90))

-- Stone shoreline around island.
for i=1,72 do
	local a=(i-1)/72*math.pi*2
	local rx=ISLAND_X/2+35 local rz=ISLAND_Z/2+35
	local x,z=math.cos(a)*rx,math.sin(a)*rz
	local s=10+((i*7)%6)
	local p=part("IslandShoreStone_"..i,Vector3.new(s,8,s*0.72),CFrame.new(x,54,z)*CFrame.Angles(0,-a,0),Enum.Material.Slate,(i%3==0) and C.stone2 or C.stone,islandFolder,true)
	p.Shape=Enum.PartType.Ball
end

-- Natural island paths.
for i=1,15 do
	local x=-620+i*88
	part("IslandPath_"..i,Vector3.new(72,4,105),CFrame.new(x,77,math.sin(i)*120)*CFrame.Angles(0,math.rad((i%3-1)*18),0),Enum.Material.Slate,C.stone2,islandFolder,true)
end
for i=1,11 do
	local z=-430+i*85
	part("IslandCrossPath_"..i,Vector3.new(105,4,65),CFrame.new(math.cos(i)*100,z,0)*CFrame.Angles(0,math.rad(90),0),Enum.Material.Slate,C.stone2,islandFolder,true)
end

-- Trees: simple stylized cherry trees matching the generated reference.
local function tree(pos,scale)
	local x,y,z=pos
	part("CherryTrunk",Vector3.new(18*scale,100*scale,18*scale),CFrame.new(x,y+50*scale,z),Enum.Material.Wood,C.wood,islandFolder,true)
	for j=1,7 do
		local ox=math.cos(j*2.4)*38*scale local oz=math.sin(j*2.4)*38*scale
		ball("CherryCrown",Vector3.new(x+ox,y+112*scale+math.sin(j)*10*scale,z+oz),Vector3.new(72,62,72)*scale,C.pink,Enum.Material.SmoothPlastic,islandFolder)
	end
end
for _,p in ipairs({{-610,76,-350},{-280,76,320},{80,76,-380},{390,76,300},{610,76,-120},{250,76,120}}) do tree(p,0.72) end

-- Bushes and grass clusters across the island.
local function bush(x,y,z,s)
	for j=1,4 do ball("Bush",Vector3.new(x+(j-2)*14*s,y+18*s,z+math.sin(j)*10*s),Vector3.new(48,36,48)*s,C.darkGrass,Enum.Material.Grass,islandFolder) end
end
for i=1,38 do
	local a=i*2.399 local r=250+(i%5)*115
	bush(math.cos(a)*r,76,math.sin(a)*r,0.55+(i%3)*0.1)
end

-- Grass tufts: intentionally dense around lobby and island perimeter.
local function grassTuft(x,y,z,s,parent)
	for j=1,5 do
		local h=(18+((j*7)%13))*s
		local p=part("GrassBlade",Vector3.new(2.2*s,h,2.2*s),CFrame.new(x+(j-3)*2*s,y+h/2,z+math.sin(j)*2*s)*CFrame.Angles(0,0,math.rad((j-3)*7)),Enum.Material.Grass,C.darkGrass,parent,false)
	end
end

-- Dense lobby grass everywhere around paved player areas.
for x=-3150,3150,85 do
	for z=2150,2620,70 do
		local nearPlaza=math.abs(x)<1550 and z>2260 and z<2520
		if not nearPlaza or (x%170==0) then grassTuft(x,4,z,0.9,lobbyFolder) end
	end
end

-- Lobby paved promenade.
part("LobbyPlaza",Vector3.new(3000,12,290),CFrame.new(0,10,2360),Enum.Material.Slate,C.stone2,lobbyFolder,true)
part("LobbyFrontWalk",Vector3.new(5800,8,70),CFrame.new(0,9,2550),Enum.Material.Slate,C.stone,lobbyFolder,true)
part("LobbyCenterWalk",Vector3.new(80,8,500),CFrame.new(0,9,2360),Enum.Material.Slate,C.stone,lobbyFolder,true)

-- Six colorful player bases like the reference image.
local baseColors={Color3.fromRGB(215,70,70),Color3.fromRGB(235,150,45),Color3.fromRGB(65,175,90),Color3.fromRGB(55,130,220),Color3.fromRGB(145,85,215),Color3.fromRGB(235,105,170)}
for i=1,6 do
	local x=-1250+(i-1)*500
	part("Base_"..i,Vector3.new(360,12,170),CFrame.new(x,20,2320),Enum.Material.Wood,baseColors[i],lobbyFolder,true)
	part("BaseMat_"..i,Vector3.new(280,4,105),CFrame.new(x,29,2320),Enum.Material.SmoothPlastic,baseColors[i],lobbyFolder,true)
	part("BaseBack_"..i,Vector3.new(350,55,12),CFrame.new(x,48,2235),Enum.Material.Wood,C.wood,lobbyFolder,true)
	-- small canopy
	part("Canopy_"..i,Vector3.new(350,10,125),CFrame.new(x,78,2320),Enum.Material.Fabric,baseColors[i],lobbyFolder,true)
	for s=1,5 do
		part("DollSlot_"..i.."_"..s,Vector3.new(42,4,30),CFrame.new(x-105+(s-1)*52,34,2320),Enum.Material.Slate,C.white,lobbyFolder,true)
	end
	local spawn=Instance.new("SpawnLocation") spawn.Name="Spawn_"..i spawn.Size=Vector3.new(54,2,54) spawn.CFrame=CFrame.new(x,35,2470) spawn.Anchored=true spawn.Neutral=true spawn.Color=baseColors[i] spawn.Parent=lobbyFolder
end

-- Frog emblem in center of lobby.
local emblem=part("FrogEmblem",Vector3.new(300,5,300),CFrame.new(0,25,2670),Enum.Material.Slate,Color3.fromRGB(130,135,128),lobbyFolder,true)
emblem.Shape=Enum.PartType.Cylinder emblem.CFrame=CFrame.new(0,25,2670)*CFrame.Angles(0,0,math.rad(90))
ball("FrogEyeL",Vector3.new(-65,32,2635),Vector3.new(48,20,48),C.darkGrass,Enum.Material.Grass,lobbyFolder)
ball("FrogEyeR",Vector3.new(65,32,2635),Vector3.new(48,20,48),C.darkGrass,Enum.Material.Grass,lobbyFolder)
part("FrogMouth",Vector3.new(110,8,12),CFrame.new(0,32,2710),Enum.Material.SmoothPlastic,C.darkGrass,lobbyFolder,false)

-- Main bridge from lobby to island, kept simple and readable.
local bridgeFolder=Instance.new("Folder") bridgeFolder.Name="MainBridge" bridgeFolder.Parent=map
for i=1,30 do
	local z=2200-i*70
	part("BridgeStone_"..i,Vector3.new(100,12,55),CFrame.new(0,76,z),Enum.Material.Slate,C.stone2,bridgeFolder,true)
end
for side=-1,1,2 do
	part("BridgeRail_"..side,Vector3.new(10,90,2100),CFrame.new(side*75,125,1120),Enum.Material.Wood,C.wood,bridgeFolder,true)
end

-- Lily pads and flowers spread across the huge swimming area.
local function lily(x,z,scale)
	local p=part("LilyPad",Vector3.new(34*scale,2,34*scale),CFrame.new(x,2,z),Enum.Material.Grass,Color3.fromRGB(72,160,82),pondFolder,false)
	p.Shape=Enum.PartType.Cylinder
	return p
end
for i=1,70 do
	local a=i*2.17 local rx=2600+(i%9)*280 local rz=1550+(i%7)*180
	lily(math.cos(a)*rx,math.sin(a)*rz,0.8+(i%4)*0.18)
end

-- Reeds/grass around pond edges.
for i=1,90 do
	local a=i*2.399 local x=math.cos(a)*(POND_X/2-35) local z=math.sin(a)*(POND_Z/2-35)
	grassTuft(x,5,z,0.9,pondFolder)
end

-- Small decorative rocks in the lobby and around water.
for i=1,75 do
	local x=-3000+(i*347)%6000 local z=2150+(i*83)%480
	local r=8+(i%9)*2
	local p=part("LobbyRock",Vector3.new(r*2,r,r*1.5),CFrame.new(x,10,z)*CFrame.Angles(0,i,0),Enum.Material.Slate,C.stone,lobbyFolder,true)
	p.Shape=Enum.PartType.Ball
end

-- Four dock/boat silhouettes on the outer pond, matching the reference composition.
for side=-1,1,2 do
	for k=1,2 do
		local x=side*(POND_X/2-180) local z=-900+k*600
		part("Dock",Vector3.new(180,12,55),CFrame.new(x,10,z),Enum.Material.Wood,C.wood,decorFolder,true)
		local boat=part("Boat",Vector3.new(110,18,45),CFrame.new(x+side*85,5,z),Enum.Material.Wood,C.wood,decorFolder,true)
		boat.Shape=Enum.PartType.Wedge
	end
end

-- Attributes for later gameplay systems.
world:SetAttribute("MapVersion","ReferenceLayout_v12")
world:SetAttribute("WorldSizeX",WORLD_X) world:SetAttribute("WorldSizeZ",WORLD_Z)
world:SetAttribute("PondSizeX",POND_X) world:SetAttribute("PondSizeZ",POND_Z)
world:SetAttribute("SwimmingAreaStuds","6100x4100")
world:SetAttribute("CentralIslandSize","1750x1250")
world:SetAttribute("MaxPlayers",6) world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300) world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LobbyGrassDense",true)

Lighting.ClockTime=14 Lighting.Brightness=2.2
Lighting.EnvironmentDiffuseScale=0.75 Lighting.EnvironmentSpecularScale=0.4
Lighting.OutdoorAmbient=Color3.fromRGB(175,185,180)

print("FrogGame V12 loaded: huge swimmable pond, central island, dense lobby grass, six bases, bridge")
