-- Frog Game — Pond + Frog Island v3
-- REAL Roblox Terrain Water for swimming. No blue pond floor Part.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local terrain = Workspace.Terrain

terrain:Clear()
local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace
local map = Instance.new("Folder")
map.Name = "PondAndIsland"
map.Parent = world
local island = Instance.new("Model")
island.Name = "FrogIsland"
island.Parent = map

local GRASS = Color3.fromRGB(89,160,78)
local GRASS2 = Color3.fromRGB(112,184,92)
local DIRT = Color3.fromRGB(105,72,48)
local SAND = Color3.fromRGB(226,205,151)
local WOOD = Color3.fromRGB(91,53,35)
local WOOD2 = Color3.fromRGB(126,77,46)
local ROCK = Color3.fromRGB(119,121,113)
local REED = Color3.fromRGB(60,133,72)
local LEAF = Color3.fromRGB(65,139,73)
local SAKURA = Color3.fromRGB(241,151,194)
local SAKURA2 = Color3.fromRGB(255,188,218)
local LOTUS_PINK = Color3.fromRGB(255,164,204)
local LOTUS_WHITE = Color3.fromRGB(255,232,243)
local LOTUS_YELLOW = Color3.fromRGB(255,218,89)
local FISH = Color3.fromRGB(247,157,72)
local FISH2 = Color3.fromRGB(255,205,111)

local function P(name,size,cf,material,color,parent,shape,collide)
	local p=Instance.new("Part")
	p.Name=name p.Size=size p.CFrame=cf p.Anchored=true
	p.CanCollide=collide~=false p.CanTouch=collide~=false p.CanQuery=collide~=false
	p.Material=material or Enum.Material.SmoothPlastic p.Color=color or Color3.new(1,1,1)
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
	if shape then p.Shape=shape end
	p.Parent=parent or map
	return p
end

local function ball(name,size,pos,color,parent,material,collide)
	return P(name,size,CFrame.new(pos),material or Enum.Material.SmoothPlastic,color,parent,Enum.PartType.Ball,collide)
end

-- Cylinders are rotated because Roblox cylinder length is along local X.
local function cyl(name,radius,height,pos,color,parent,material,collide)
	return P(name,Vector3.new(height,radius*2,radius*2),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),material or Enum.Material.Wood,color,parent,Enum.PartType.Cylinder,collide)
end

-- ============================================================
-- CLEAN LAND RING: pond remains completely open in the middle.
-- ============================================================
P("NorthLand",Vector3.new(260,4,48),CFrame.new(0,-2,-110),Enum.Material.Grass,GRASS)
P("SouthLand",Vector3.new(260,4,48),CFrame.new(0,-2,110),Enum.Material.Grass,GRASS)
P("WestLand",Vector3.new(48,4,172),CFrame.new(-128,-2,0),Enum.Material.Grass,GRASS)
P("EastLand",Vector3.new(48,4,172),CFrame.new(128,-2,0),Enum.Material.Grass,GRASS)

P("SouthBeach",Vector3.new(180,1,10),CFrame.new(0,0.5,88),Enum.Material.Sand,SAND)
P("NorthBeach",Vector3.new(180,1,10),CFrame.new(0,0.5,-88),Enum.Material.Sand,SAND)
P("WestBeach",Vector3.new(10,1,145),CFrame.new(-104,0.5,0),Enum.Material.Sand,SAND)
P("EastBeach",Vector3.new(10,1,145),CFrame.new(104,0.5,0),Enum.Material.Sand,SAND)

-- REAL SWIMMABLE WATER. Water surface is around Y=1 and has volume below it.
terrain:FillBlock(CFrame.new(0,-3,0),Vector3.new(206,8,164),Enum.Material.Water)

-- ============================================================
-- LARGE ORGANIC ISLAND
-- ============================================================
ball("DirtMound",Vector3.new(130,18,106),Vector3.new(0,7,0),DIRT,island,Enum.Material.Ground)
ball("GrassCap",Vector3.new(120,12,96),Vector3.new(0,12,0),GRASS,island,Enum.Material.Grass)

local lobes={
	Vector3.new(-43,12,-25),Vector3.new(-22,12,-43),Vector3.new(8,12,-43),
	Vector3.new(36,12,-31),Vector3.new(48,12,-7),Vector3.new(45,12,20),
	Vector3.new(23,12,39),Vector3.new(-7,12,43),Vector3.new(-35,12,32),Vector3.new(-49,12,7)
}
for i,pos in ipairs(lobes) do
	ball("GrassLobe_"..i,Vector3.new(42,9,31),pos,GRASS2,island,Enum.Material.Grass)
end

-- Central clear play area, intentionally flat and clean.
P("FrogPlayArea",Vector3.new(52,1,36),CFrame.new(0,17,4),Enum.Material.Grass,GRASS,island)

-- ============================================================
-- BRIDGE / ENTRANCE
-- ============================================================
local bridge=Instance.new("Model") bridge.Name="IslandBridge" bridge.Parent=map
for i=1,16 do
	local z=84-i*4.2
	local x=math.sin(i*0.7)*2
	local s=ball("BridgeStone",Vector3.new(9,2,6),Vector3.new(x,1.7,z),ROCK,bridge,Enum.Material.Slate)
	s.CFrame=CFrame.new(x,1.7,z)*CFrame.Angles(0,math.rad((i%3-1)*7),0)
end

-- ============================================================
-- FIXED SAKURA TREES
-- ============================================================
local function branchBetween(name,a,b,r,color,parent)
	local d=b-a
	local mid=(a+b)/2
	local cf=CFrame.lookAt(mid,b)*CFrame.Angles(0,math.rad(90),0)
	return P(name,Vector3.new(d.Magnitude,r*2,r*2),cf,Enum.Material.Wood,color,parent,Enum.PartType.Cylinder)
end

local function tree(name,base,scale)
	local m=Instance.new("Model") m.Name=name m.Parent=island
	local h=24*scale
	cyl("Trunk",2*scale,h,base+Vector3.new(0,h/2,0),WOOD,m,Enum.Material.Wood)
	local b=base+Vector3.new(0,h*0.58,0)
	local ends={
		b+Vector3.new(-9*scale,7*scale,-2*scale),
		b+Vector3.new(9*scale,7.5*scale,2*scale),
		b+Vector3.new(0,9*scale,8*scale),
	}
	for i,e in ipairs(ends) do
		branchBetween("PrimaryBranch_"..i,b,e,0.82*scale,WOOD,m)
		local e2=e+Vector3.new((i==2 and 4 or -4)*scale,4*scale,(i-2)*2*scale)
		branchBetween("SecondaryBranch_"..i,e,e2,0.46*scale,WOOD2,m)
	end
	local crowns={
		ends[1]+Vector3.new(-1,4,0),ends[1]+Vector3.new(4,5,2),
		ends[2]+Vector3.new(1,4,0),ends[2]+Vector3.new(-4,5,-2),
		ends[3]+Vector3.new(0,4,1),base+Vector3.new(0,h+8*scale,0)
	}
	for i,c in ipairs(crowns) do
		local s=(7+(i%3)*1.3)*scale
		ball("SakuraCrown_"..i,Vector3.new(s*2,s*1.35,s*2),c,i%2==0 and SAKURA or SAKURA2,m,Enum.Material.SmoothPlastic,false)
	end
end

tree("SakuraTree_Left",Vector3.new(-38,17,-15),1)
tree("SakuraTree_Right",Vector3.new(38,17,-14),1)
tree("SakuraTree_Back",Vector3.new(0,17,-34),1.08)
tree("SakuraTree_BackLeft",Vector3.new(-27,17,28),0.78)
tree("SakuraTree_BackRight",Vector3.new(28,17,28),0.78)

-- ============================================================
-- ORGANIZED BUSHES + SHORE ROCKS
-- ============================================================
local decor=Instance.new("Folder") decor.Name="IslandDecor" decor.Parent=island
local function bush(pos,scale)
	local m=Instance.new("Model") m.Name="Bush" m.Parent=decor
	for i=1,5 do
		local a=(i-1)/5*math.pi*2
		ball("Leaf",Vector3.new(7*scale,5.4*scale,7*scale),pos+Vector3.new(math.cos(a)*2.6*scale,2.7*scale,math.sin(a)*2.6*scale),LEAF,m,Enum.Material.Grass,false)
	end
end
for _,p in ipairs({Vector3.new(-48,17,19),Vector3.new(48,17,19),Vector3.new(-48,17,-27),Vector3.new(48,17,-26),Vector3.new(0,17,40)}) do bush(p,1) end
for i=1,24 do
	local a=(i-1)/24*math.pi*2 local r=53+(i%3)*1.8
	ball("IslandRock",Vector3.new(6+(i%2)*2,3.8,5+(i%3)),Vector3.new(math.cos(a)*r,16.5,math.sin(a)*r*0.78),ROCK,decor,Enum.Material.Slate,false)
end

-- ============================================================
-- LOTUS + LILY PADS ON REAL WATER
-- ============================================================
local pondDecor=Instance.new("Folder") pondDecor.Name="PondDecor" pondDecor.Parent=world
local function lily(pos,scale)
	local p=cyl("LilyPad",3.4*scale,0.25,pos,Color3.fromRGB(61,145,75),pondDecor,Enum.Material.Grass,false)
	p.Size=Vector3.new(0.25,6.8*scale,6.8*scale)
	p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))
end
local function lotus(pos,scale)
	local m=Instance.new("Model") m.Name="Lotus" m.Parent=pondDecor
	for i=1,8 do
		local a=(i-1)/8*math.pi*2 local r=1.8*scale
		local p=ball("Petal",Vector3.new(3.4*scale,0.8*scale,1.8*scale),pos+Vector3.new(math.cos(a)*r,1.0,math.sin(a)*r),i%2==0 and LOTUS_PINK or LOTUS_WHITE,m,Enum.Material.SmoothPlastic,false)
		p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-a,math.rad(-18))
	end
	ball("GoldenCenter",Vector3.new(2*scale,1*scale,2*scale),pos+Vector3.new(0,1.4,0),LOTUS_YELLOW,m,Enum.Material.SmoothPlastic,false)
end

local lotusSpots={
	Vector3.new(-72,1.2,-43),Vector3.new(72,1.2,-34),Vector3.new(-78,1.2,25),
	Vector3.new(77,1.2,37),Vector3.new(-30,1.2,65),Vector3.new(38,1.2,61)
}
for i,p in ipairs(lotusSpots) do lily(p,1.05) lotus(p,0.9+(i%2)*0.1) end
for _,p in ipairs({Vector3.new(-57,1.15,-20),Vector3.new(55,1.15,-12),Vector3.new(-62,1.15,47),Vector3.new(65,1.15,52),Vector3.new(20,1.15,70),Vector3.new(-12,1.15,-65),Vector3.new(84,1.15,4),Vector3.new(-86,1.15,0)}) do lily(p,0.85) end

-- Reeds form tidy shoreline clusters.
for i=1,30 do
	local a=(i-1)/30*math.pi*2
	local x=math.cos(a)*94 local z=math.sin(a)*74
	for j=1,3 do
		local h=5+(j%3)
		cyl("Reed",0.18,h,Vector3.new(x+(j-2)*0.8,1+h/2,z+(j%2)*0.6),REED,pondDecor,Enum.Material.Grass,false)
	end
end

-- ============================================================
-- FISH IN THE WATER
-- ============================================================
local fishFolder=Instance.new("Folder") fishFolder.Name="PondFish" fishFolder.Parent=world
local fishData={}
local function fish(id,pos,radius,phase)
	local m=Instance.new("Model") m.Name="Fish_"..id m.Parent=fishFolder
	ball("Body",Vector3.new(3.5,1.6,2.1),pos,FISH,m,Enum.Material.SmoothPlastic,false)
	P("Tail",Vector3.new(0.4,1.8,2.2),CFrame.new(pos+Vector3.new(-1.8,0,0)),Enum.Material.SmoothPlastic,FISH2,m,Enum.PartType.Wedge,false)
	ball("Eye",Vector3.new(0.3,0.3,0.3),pos+Vector3.new(1.05,0.45,-0.75),Color3.new(0.03,0.03,0.03),m,Enum.Material.SmoothPlastic,false)
	fishData[#fishData+1]={model=m,cx=pos.X,cz=pos.Z,y=pos.Y,r=radius,phase=phase,speed=0.3+(id%4)*0.05}
end
local fishSpots={
	Vector3.new(-68,-1,-36),Vector3.new(-35,-1,-60),Vector3.new(30,-1,-58),Vector3.new(68,-1,-32),
	Vector3.new(-74,-1,18),Vector3.new(76,-1,17),Vector3.new(-55,-1,55),Vector3.new(57,-1,57),
	Vector3.new(-15,-1,72),Vector3.new(20,-1,70),Vector3.new(88,-1,0),Vector3.new(-88,-1,0)
}
for i,p in ipairs(fishSpots) do fish(i,p,8+(i%4)*3,i*0.7) end

-- ============================================================
-- OUTER PLAYER DISPLAY AREAS
-- ============================================================
local stalls=Instance.new("Folder") stalls.Name="PlayerDisplayAreas" stalls.Parent=world
local stallSpots={Vector3.new(-72,1.5,106),Vector3.new(-25,1.5,106),Vector3.new(25,1.5,106),Vector3.new(72,1.5,106),Vector3.new(-108,1.5,70),Vector3.new(108,1.5,70)}
for i,pos in ipairs(stallSpots) do
	local m=Instance.new("Model") m.Name="PlayerStall_"..i m.Parent=stalls
	P("Platform",Vector3.new(24,2,15),CFrame.new(pos),Enum.Material.Wood,WOOD,m)
	P("BackWall",Vector3.new(24,9,1),CFrame.new(pos+Vector3.new(0,5,6.5)),Enum.Material.Wood,WOOD,m)
	P("Sign",Vector3.new(16,3,0.6),CFrame.new(pos+Vector3.new(0,10,5.8)),Enum.Material.SmoothPlastic,SAND,m)
	for slot=1,6 do
		local x=((slot-1)%3-1)*6 local z=(math.floor((slot-1)/3)-0.5)*5
		ball("DollSlot",Vector3.new(2.4,2.4,2.4),pos+Vector3.new(x,3,z),Color3.fromRGB(241,203,157),m,Enum.Material.SmoothPlastic,false)
	end
end

-- Boat floating on real water.
local boat=Instance.new("Model") boat.Name="DecorativeSailboat" boat.Parent=map
P("Hull",Vector3.new(20,3,8),CFrame.new(-48,0.8,-72),Enum.Material.Wood,WOOD,boat)
cyl("Mast",0.45,16,Vector3.new(-48,9,-72),WOOD,boat)
P("Sail",Vector3.new(0.5,9,8),CFrame.new(-44.5,9,-72),Enum.Material.Fabric,Color3.fromRGB(250,245,226),boat)

-- ============================================================
-- GAMEPLAY REGIONS
-- ============================================================
local regions=Instance.new("Folder") regions.Name="GameplayRegions" regions.Parent=world
local function region(name,size,pos)
	local p=P(name,size,CFrame.new(pos),Enum.Material.SmoothPlastic,Color3.new(1,1,1),regions,nil,false)
	p.Transparency=1 return p
end
region("FrogSpawnRegion",Vector3.new(42,0.5,30),Vector3.new(0,18,4))
region("RaceStart",Vector3.new(20,0.5,6),Vector3.new(0,18,42))
region("IslandEntranceRegion",Vector3.new(18,0.5,8),Vector3.new(0,18,52))

world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LegendaryTimerSeconds",1800)
world:SetAttribute("SecretTimerSeconds",3600)
world:SetAttribute("MapVersion","PondIsland_v3_Swimmable")

-- Sakura petals.
local petals=Instance.new("Folder") petals.Name="FallingSakuraPetals" petals.Parent=world
for i=1,45 do
	local p=P("Petal",Vector3.new(0.35,0.08,0.5),CFrame.new(math.random(-70,70),math.random(18,42),math.random(-60,60)),Enum.Material.SmoothPlastic,SAKURA2,petals,nil,false)
	p:SetAttribute("Phase",math.random()*12)
end

local t0=os.clock()
RunService.Heartbeat:Connect(function()
	local t=os.clock()-t0
	for _,d in ipairs(fishData) do
		local a=t*d.speed+d.phase
		d.model:PivotTo(CFrame.new(d.cx+math.cos(a)*d.r,d.y+math.sin(t*1.8+d.phase)*0.35,d.cz+math.sin(a)*d.r*0.72)*CFrame.Angles(0,-a,0))
	end
	for _,p in ipairs(petals:GetChildren()) do
		local phase=p:GetAttribute("Phase") or 0 local cycle=(t+phase)%14
		local y=42-cycle*2.2 if y<5 then y=42 end
		p.Position=Vector3.new(p.Position.X+math.sin(t*0.6+phase)*0.012,y,p.Position.Z)
		p.Orientation=Vector3.new((t*28+phase*8)%360,(t*18)%360,(t*42+phase*6)%360)
	end
end)

Lighting.ClockTime=16.2
Lighting.Brightness=2.4
Lighting.EnvironmentDiffuseScale=0.65
Lighting.EnvironmentSpecularScale=0.35
Lighting.OutdoorAmbient=Color3.fromRGB(165,175,170)
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density=0.18 atmosphere.Offset=0.1 atmosphere.Haze=0.6 atmosphere.Glare=0.05 atmosphere.Parent=Lighting

print("FrogGame v3: swimmable Terrain Water, large island, fixed Sakura trees, lotus and fish")
