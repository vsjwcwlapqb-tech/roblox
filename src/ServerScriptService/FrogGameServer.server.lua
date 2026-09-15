-- Frog Game Environment v5
-- Large pond + large lobby + structured island.
-- Pond uses Roblox Terrain Water so players can enter and swim.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end
Terrain:Clear()
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

local world = Instance.new("Folder")
world.Name = "FrogGame"
world.Parent = Workspace

local map = Instance.new("Folder")
map.Name = "Map"
map.Parent = world
local island = Instance.new("Model")
island.Name = "FrogIsland"
island.Parent = map
local pondDecor = Instance.new("Folder")
pondDecor.Name = "PondDecoration"
pondDecor.Parent = world
local trees = Instance.new("Folder")
trees.Name = "SakuraGrove"
trees.Parent = map
local lobby = Instance.new("Model")
lobby.Name = "LargeLobby"
lobby.Parent = map
local stalls = Instance.new("Folder")
stalls.Name = "PlayerDisplayAreas"
stalls.Parent = lobby
local fishFolder = Instance.new("Folder")
fishFolder.Name = "PondFish"
fishFolder.Parent = world

local C={
 grass=Color3.fromRGB(88,166,82), grass2=Color3.fromRGB(118,190,99),
 dirt=Color3.fromRGB(104,70,43), sand=Color3.fromRGB(230,208,151),
 stone=Color3.fromRGB(126,130,126), stone2=Color3.fromRGB(176,177,166),
 wood=Color3.fromRGB(76,43,29), wood2=Color3.fromRGB(122,72,40),
 leaf=Color3.fromRGB(67,145,73), reed=Color3.fromRGB(48,128,61),
 sakura=Color3.fromRGB(237,139,187), sakura2=Color3.fromRGB(255,190,219),
 pink=Color3.fromRGB(255,163,204), white=Color3.fromRGB(255,231,243),
 yellow=Color3.fromRGB(255,216,76), fish=Color3.fromRGB(244,145,61), fish2=Color3.fromRGB(255,205,106)
}

local function part(name,size,cf,mat,color,parent,shape,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
 p.Material=mat or Enum.Material.SmoothPlastic;p.Color=color or Color3.new(1,1,1)
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=collide~=false;p.CanTouch=collide~=false;p.CanQuery=collide~=false
 if shape then p.Shape=shape end
 p.Parent=parent or map
 return p
end
local function ball(name,size,pos,color,parent,mat,collide)
 return part(name,size,CFrame.new(pos),mat or Enum.Material.SmoothPlastic,color,parent,Enum.PartType.Ball,collide)
end
local function cyl(name,r,h,pos,color,parent,mat,collide)
 return part(name,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),mat or Enum.Material.Wood,color,parent,Enum.PartType.Cylinder,collide)
end
local function between(name,a,b,r,color,parent,mat)
 local d=b-a
 local p=part(name,Vector3.new(d.Magnitude,r*2,r*2),CFrame.lookAt((a+b)/2,b)*CFrame.Angles(0,math.rad(90),0),mat or Enum.Material.Wood,color,parent,Enum.PartType.Cylinder,true)
 return p
end

-- ================================================================
-- WORLD SCALE
-- Pond: 300 x 240, broad swimming area.
-- Island: about 150 x 120.
-- Lobby: about 300 x 110, intentionally much larger than before.
-- ================================================================
local POND_X=300
local POND_Z=238
local WATER_TOP=4
local LOBBY_Z=184

-- Real Terrain water. There is deliberately no blue Part under it.
Terrain:FillBlock(CFrame.new(0,-2,0),Vector3.new(POND_X,12,POND_Z),Enum.Material.Water)
-- Round the four corners of the water silhouette.
for _,v in ipairs({
 Vector3.new(-145,-2,-113),Vector3.new(145,-2,-113),
 Vector3.new(-145,-2,113),Vector3.new(145,-2,113)
}) do
 Terrain:FillBall(v,58,Enum.Material.Air)
end

-- Sandy outer shore, safely outside the water surface.
part("ShoreSouth",Vector3.new(270,2,10),CFrame.new(0,2,132),Enum.Material.Sand,C.sand,map)
part("ShoreNorth",Vector3.new(270,2,10),CFrame.new(0,2,-132),Enum.Material.Sand,C.sand,map)
part("ShoreWest",Vector3.new(10,2,210),CFrame.new(-162,2,0),Enum.Material.Sand,C.sand,map)
part("ShoreEast",Vector3.new(10,2,210),CFrame.new(162,2,0),Enum.Material.Sand,C.sand,map)

-- ================================================================
-- LARGE LOBBY / SPAWN PLAZA
-- ================================================================
-- One clean surface: no stacked/coplanar floors, so no flickering.
part("LobbyGround",Vector3.new(300,3,105),CFrame.new(0,1,LOBBY_Z),Enum.Material.Grass,C.grass2,lobby)
part("LobbyBorder",Vector3.new(300,2,7),CFrame.new(0,3.5,LOBBY_Z-52),Enum.Material.Sand,C.sand,lobby)

-- Large central lobby plaza.
part("LobbyPlaza",Vector3.new(100,1,58),CFrame.new(0,3.1,LOBBY_Z+2),Enum.Material.Slate,C.stone2,lobby)

-- Wide structured stone paths.
for i=-7,7 do
 part("LobbyPath",Vector3.new(8,1.1,6),CFrame.new(i*9,4,LOBBY_Z-35),Enum.Material.Slate,C.stone2,lobby)
end
for i=1,11 do
 part("LobbyCenterPath",Vector3.new(7,1.1,7),CFrame.new(0,4,LOBBY_Z-28+i*7),Enum.Material.Slate,C.stone2,lobby)
end

-- Six large player display areas, evenly arranged around the lobby.
local stallPositions={
 Vector3.new(-105,4,LOBBY_Z+25),Vector3.new(-35,4,LOBBY_Z+25),Vector3.new(35,4,LOBBY_Z+25),Vector3.new(105,4,LOBBY_Z+25),
 Vector3.new(-105,4,LOBBY_Z-28),Vector3.new(105,4,LOBBY_Z-28)
}
for i,pos in ipairs(stallPositions) do
 local m=Instance.new("Model");m.Name="PlayerStall_"..i;m.Parent=stalls
 part("Platform",Vector3.new(48,2,30),CFrame.new(pos),Enum.Material.Wood,C.wood,m)
 part("BackWall",Vector3.new(48,12,1.2),CFrame.new(pos+Vector3.new(0,7,13)),Enum.Material.Wood,C.wood,m)
 part("Canopy",Vector3.new(50,1.5,31),CFrame.new(pos+Vector3.new(0,13,0)),Enum.Material.Wood,C.wood2,m)
 part("Sign",Vector3.new(32,4,.7),CFrame.new(pos+Vector3.new(0,15,11.8)),Enum.Material.SmoothPlastic,C.sand,m)
 for slot=1,6 do
  local x=((slot-1)%3-1)*12
  local z=(math.floor((slot-1)/3)-.5)*9
  ball("DollDisplaySlot",Vector3.new(3.2,3.2,3.2),pos+Vector3.new(x,3,z),Color3.fromRGB(241,197,151),m,nil,false)
 end
end

-- Lobby trees make the starting area feel like a proper hub.
local function tree(name,base,s,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or trees
 local h=27*s
 -- trunk is grounded at base.Y and ends below the crown.
 cyl("Trunk",2.4*s,h,base+Vector3.new(0,h/2,0),C.wood,m,Enum.Material.Wood,true)
 local joint=base+Vector3.new(0,h*.57,0)
 local ends={
  joint+Vector3.new(-11*s,7*s,-3*s),joint+Vector3.new(11*s,7*s,3*s),
  joint+Vector3.new(-5*s,10*s,8*s),joint+Vector3.new(5*s,10*s,-8*s)
 }
 for i,e in ipairs(ends) do
  between("Branch",joint,e,.95*s,C.wood,m,Enum.Material.Wood)
  local twig=e+Vector3.new((i%2==0 and 4 or -4)*s,4*s,(i%3-1)*2*s)
  between("Twig",e,twig,.48*s,C.wood2,m,Enum.Material.Wood)
 end
 local crowns={
  ends[1]+Vector3.new(-2,3,0),ends[1]+Vector3.new(4,4,1),
  ends[2]+Vector3.new(2,3,0),ends[2]+Vector3.new(-4,4,-1),
  ends[3]+Vector3.new(0,4,1),ends[4]+Vector3.new(0,4,-1),
  base+Vector3.new(0,h+6,0)
 }
 for i,p in ipairs(crowns) do
  local q=(7.5+(i%3))*s
  ball("SakuraCrown",Vector3.new(q*2,q*1.35,q*2),p,i%2==0 and C.sakura2 or C.sakura,m,Enum.Material.SmoothPlastic,false)
 end
end

tree("LobbyTree_Left",Vector3.new(-137,4,LOBBY_Z-38),.9)
tree("LobbyTree_Right",Vector3.new(137,4,LOBBY_Z-38),.9)
tree("LobbyTree_BackLeft",Vector3.new(-135,4,LOBBY_Z+43),.8)
tree("LobbyTree_BackRight",Vector3.new(135,4,LOBBY_Z+43),.8)

-- ================================================================
-- LARGE FROG ISLAND
-- ================================================================
-- Terrain grass/dirt island removes water cleanly; no blue floor parts.
Terrain:FillBall(Vector3.new(0,5,0),72,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(-48,5,5),38,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(48,5,5),38,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(0,10,0),70,Enum.Material.Grass)
Terrain:FillBall(Vector3.new(-45,10,4),38,Enum.Material.Grass)
Terrain:FillBall(Vector3.new(45,10,4),38,Enum.Material.Grass)

-- Flatten the central playable area with one clean part above terrain.
part("CentralPlayArea",Vector3.new(82,2,58),CFrame.new(0,20,8),Enum.Material.Grass,C.grass,island)

-- Island shoreline stones in an intentional ring.
for i=1,32 do
 local a=(i-1)/32*math.pi*2
 local x=math.cos(a)*61
 local z=math.sin(a)*46
 ball("IslandShoreRock",Vector3.new(7+(i%3),3.5,6+(i%2)),Vector3.new(x,18,z),C.stone,island,Enum.Material.Slate,false)
end

-- Main entrance bridge from the huge lobby into the island.
local bridge=Instance.new("Model");bridge.Name="WideIslandBridge";bridge.Parent=map
for i=1,19 do
 local z=130-(i-1)*6
 local x=math.sin(i*.45)*2
 local p=part("BridgeStone",Vector3.new(11,2.2,5),CFrame.new(x,6,z),Enum.Material.Slate,C.stone2,bridge)
 p.CFrame=CFrame.new(x,6,z)*CFrame.Angles(0,math.rad(math.sin(i)*2),0)
end

-- Structured paths on island.
for i=-5,5 do
 part("IslandPathStone",Vector3.new(8,1.3,5.5),CFrame.new(i*8,21,42),Enum.Material.Slate,C.stone2,island)
end
for i=1,9 do
 part("IslandCenterStone",Vector3.new(7,1.3,6),CFrame.new(0,21,37-i*6),Enum.Material.Slate,C.stone2,island)
end

-- Sakura grove on island, deliberately placed around the play space.
tree("IslandTree_Left",Vector3.new(-48,20,-18),1.0)
tree("IslandTree_Right",Vector3.new(48,20,-18),1.0)
tree("IslandTree_Back",Vector3.new(0,20,-42),1.15)
tree("IslandTree_BackLeft",Vector3.new(-34,20,28),.78)
tree("IslandTree_BackRight",Vector3.new(34,20,28),.78)

-- Grouped bushes.
local function bush(name,pos,s)
 local m=Instance.new("Model");m.Name=name;m.Parent=island
 for i=1,7 do
  local a=(i-1)/7*math.pi*2
  ball("Leaf",Vector3.new(7*s,5*s,7*s),pos+Vector3.new(math.cos(a)*2.7*s,2.6*s,math.sin(a)*2.7*s),C.leaf,m,Enum.Material.Grass,false)
 end
end
bush("BushLeft",Vector3.new(-49,20,20),1)
bush("BushRight",Vector3.new(49,20,20),1)
bush("BushBackLeft",Vector3.new(-48,20,-28),.85)
bush("BushBackRight",Vector3.new(48,20,-28),.85)

-- ================================================================
-- LOTUS / LILY GARDENS AROUND THE LARGE POND
-- ================================================================
local function lily(pos,s)
 local p=cyl("LilyPad",3.5*s,.24,pos,Color3.fromRGB(53,145,72),pondDecor,Enum.Material.Grass,false)
 p.Size=Vector3.new(.24,7*s,7*s)
 p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))
end
local function lotus(name,pos,s)
 local m=Instance.new("Model");m.Name=name;m.Parent=pondDecor
 for i=1,8 do
  local a=(i-1)/8*math.pi*2
  local r=1.8*s
  local p=ball("Petal",Vector3.new(3.6*s,.7*s,1.8*s),pos+Vector3.new(math.cos(a)*r,.8,math.sin(a)*r),i%2==0 and C.pink or C.white,m,Enum.Material.SmoothPlastic,false)
  p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-a,math.rad(-18))
 end
 ball("Center",Vector3.new(2*s,.9*s,2*s),pos+Vector3.new(0,1.25,0),C.yellow,m,Enum.Material.SmoothPlastic,false)
end

local lotusSpots={
 Vector3.new(-112,4,-72),Vector3.new(-62,4,-103),Vector3.new(35,4,-103),Vector3.new(112,4,-70),
 Vector3.new(-124,4,18),Vector3.new(124,4,18),Vector3.new(-105,4,76),Vector3.new(105,4,78),
 Vector3.new(-45,4,105),Vector3.new(45,4,105),Vector3.new(0,4,-110),Vector3.new(0,4,112)
}
for i,p in ipairs(lotusSpots) do
 lily(p,.95+(i%3)*.05)
 lotus("LotusGarden_"..i,p,.9+(i%2)*.12)
end

for _,p in ipairs({
 Vector3.new(-91,4,-30),Vector3.new(91,4,-32),Vector3.new(-96,4,48),Vector3.new(96,4,50),
 Vector3.new(-72,4,92),Vector3.new(72,4,92),Vector3.new(-137,4,-20),Vector3.new(137,4,-20),
 Vector3.new(-137,4,55),Vector3.new(137,4,55),Vector3.new(-42,4,-112),Vector3.new(42,4,-112)
}) do lily(p,.78) end

-- Neat reed clusters around the outer shoreline.
for g=1,16 do
 local a=(g-1)/16*math.pi*2
 local cx=math.cos(a)*139
 local cz=math.sin(a)*107
 for j=1,6 do
  local h=5+(j%3)*1.1
  cyl("Reed",.16,h,Vector3.new(cx+(j-3)*1.1,4+h/2,cz+(j%2)*.9),C.reed,pondDecor,Enum.Material.Grass,false)
 end
end

-- ================================================================
-- FISH: LARGE SWIMMING POND
-- ================================================================
local fishData={}
local function makeFish(id,pos,r,phase)
 local m=Instance.new("Model");m.Name="Fish_"..id;m.Parent=fishFolder
 ball("Body",Vector3.new(4.2,1.6,2.4),pos,C.fish,m,nil,false)
 part("Tail",Vector3.new(.45,2,2.5),CFrame.new(pos+Vector3.new(-2.1,0,0)),Enum.Material.SmoothPlastic,C.fish2,m,Enum.PartType.Wedge,false)
 ball("Eye",Vector3.new(.32,.32,.32),pos+Vector3.new(1.25,.5,-.8),Color3.fromRGB(15,15,15),m,nil,false)
 fishData[#fishData+1]={m=m,cx=pos.X,cz=pos.Z,y=pos.Y,r=r,phase=phase,s=.18+(id%5)*.035}
end
local fishPositions={
 Vector3.new(-105,-1,-65),Vector3.new(-72,-2,-95),Vector3.new(-25,-1,-108),Vector3.new(28,-2,-104),Vector3.new(75,-1,-92),Vector3.new(110,-2,-55),
 Vector3.new(-118,-1,-5),Vector3.new(118,-2,8),Vector3.new(-120,-1,55),Vector3.new(120,-2,57),
 Vector3.new(-83,-1,88),Vector3.new(-38,-2,105),Vector3.new(38,-1,108),Vector3.new(83,-2,88),Vector3.new(0,-1,118),Vector3.new(0,-2,-120)
}
for i,p in ipairs(fishPositions) do makeFish(i,p,9+(i%5)*4,i*.73) end

-- Decorative sailboat at the far side, kept out of the swim lanes.
local boat=Instance.new("Model");boat.Name="DecorativeSailboat";boat.Parent=map
part("Hull",Vector3.new(26,4,9),CFrame.new(0,5,-126),Enum.Material.Wood,C.wood,boat)
cyl("Mast",.45,22,Vector3.new(0,16,-126),C.wood,boat,Enum.Material.Wood,true)
part("Sail",Vector3.new(.5,13,11),CFrame.new(4.2,16,-126),Enum.Material.Fabric,Color3.fromRGB(250,244,225),boat)

-- ================================================================
-- PETALS
-- ================================================================
local petals=Instance.new("Folder");petals.Name="FallingSakuraPetals";petals.Parent=world
for i=1,85 do
 local p=part("Petal",Vector3.new(.35,.08,.5),CFrame.new(math.random(-135,135),math.random(12,45),math.random(-125,125)),Enum.Material.SmoothPlastic,C.sakura2,petals,nil,false)
 p:SetAttribute("phase",math.random()*12)
end

-- Spawn point in the large lobby, facing the pond/island.
local spawn=Instance.new("SpawnLocation")
spawn.Name="PlayerSpawn"
spawn.Size=Vector3.new(8,1,8)
spawn.CFrame=CFrame.new(0,5,LOBBY_Z-38)*CFrame.Angles(0,math.pi,0)
spawn.Anchored=true
spawn.Neutral=true
spawn.Material=Enum.Material.Slate
spawn.Color=C.stone2
spawn.Parent=world

local regions=Instance.new("Folder");regions.Name="GameplayRegions";regions.Parent=world
local frogSpawn=part("FrogSpawnRegion",Vector3.new(64,1,42),CFrame.new(0,21,5),Enum.Material.SmoothPlastic,Color3.fromRGB(80,180,100),regions,nil,false)
frogSpawn.Transparency=1
local raceStart=part("RaceStart",Vector3.new(22,1,7),CFrame.new(0,21,43),Enum.Material.SmoothPlastic,Color3.fromRGB(255,225,100),regions,nil,false)
raceStart.Transparency=1
local swimRegion=part("SwimRegion",Vector3.new(280,8,218),CFrame.new(0,0,0),Enum.Material.SmoothPlastic,Color3.fromRGB(50,150,180),regions,nil,false)
swimRegion.Transparency=1

world:SetAttribute("MapVersion","PondIsland_v5_Large")
world:SetAttribute("PondSize","300x238")
world:SetAttribute("LobbySize","300x105")
world:SetAttribute("WaterIsTerrain",true)
world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LegendaryTimerSeconds",1800)
world:SetAttribute("SecretTimerSeconds",3600)

-- ================================================================
-- MOTION
-- ================================================================
local t0=os.clock()
RunService.Heartbeat:Connect(function()
 local t=os.clock()-t0
 for _,d in ipairs(fishData) do
  local a=t*d.s+d.phase
  local x=d.cx+math.cos(a)*d.r
  local z=d.cz+math.sin(a)*d.r*.72
  local y=d.y+math.sin(t*1.8+d.phase)*.3
  d.m:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,-a,0))
 end
 for _,p in ipairs(petals:GetChildren()) do
  if p:IsA("BasePart") then
   local ph=p:GetAttribute("phase") or 0
   local y=14+((ph+t*1.5)%25)
   p.Position=Vector3.new(p.Position.X+math.sin(t*.7+ph)*.015,y,p.Position.Z+math.cos(t*.6+ph)*.012)
   p.Orientation=Vector3.new((t*35+ph*10)%360,(t*18)%360,(t*42+ph*7)%360)
  end
 end
end)

Lighting.ClockTime=16.2
Lighting.Brightness=2.5
Lighting.EnvironmentDiffuseScale=.65
Lighting.EnvironmentSpecularScale=.4
Lighting.OutdoorAmbient=Color3.fromRGB(170,180,170)
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density=.2
atmosphere.Offset=.1
atmosphere.Glare=.08
atmosphere.Haze=.65
atmosphere.Parent=Lighting

print("FrogGame v5 loaded: LARGE SWIMMABLE POND + LARGE LOBBY + STRUCTURED FROG ISLAND")
