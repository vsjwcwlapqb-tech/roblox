-- Frog Game Environment v7
-- Full reference-style environment rebuild: large pond, central frog island,
-- Sakura trees, bushes, stone slabs, decorative statues, flowers, lotus, reeds, fish,
-- six waterfront player bases and clean swimming space.

local Players = game:GetService("Players")
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
local lobby = Instance.new("Model")
lobby.Name = "Lobby"
lobby.Parent = map
local bases = Instance.new("Folder")
bases.Name = "PlayerBases"
bases.Parent = lobby
local decor = Instance.new("Folder")
decor.Name = "PondDecoration"
decor.Parent = world
local fishFolder = Instance.new("Folder")
fishFolder.Name = "PondFish"
fishFolder.Parent = world
local trees = Instance.new("Folder")
trees.Name = "SakuraGrove"
trees.Parent = map
local statues = Instance.new("Folder")
statues.Name = "GardenStatues"
statues.Parent = map

local C = {
 grass = Color3.fromRGB(91,165,83), grass2 = Color3.fromRGB(124,191,103),
 dirt = Color3.fromRGB(105,70,43), sand = Color3.fromRGB(232,210,153),
 stone = Color3.fromRGB(132,136,132), stone2 = Color3.fromRGB(181,181,170),
 stoneDark = Color3.fromRGB(92,96,92), wood = Color3.fromRGB(78,45,31),
 wood2 = Color3.fromRGB(128,77,43), leaf = Color3.fromRGB(69,145,75),
 leaf2 = Color3.fromRGB(93,170,79), reed = Color3.fromRGB(48,126,61),
 sakura = Color3.fromRGB(239,143,190), sakura2 = Color3.fromRGB(255,194,220),
 pink = Color3.fromRGB(255,166,207), white = Color3.fromRGB(255,232,244),
 yellow = Color3.fromRGB(255,216,76), fish = Color3.fromRGB(244,145,61),
 fish2 = Color3.fromRGB(255,205,106), waterPlant = Color3.fromRGB(54,145,77)
}

local function part(name, size, cf, material, color, parent, shape, collide)
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Anchored = true
 p.Material = material or Enum.Material.SmoothPlastic
 p.Color = color or Color3.new(1,1,1)
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.CanCollide = collide ~= false
 p.CanTouch = collide ~= false
 p.CanQuery = collide ~= false
 if shape then p.Shape = shape end
 p.Parent = parent or map
 return p
end

local function ball(name, size, pos, color, parent, material, collide)
 return part(name, size, CFrame.new(pos), material or Enum.Material.SmoothPlastic, color, parent, Enum.PartType.Ball, collide)
end

local function cyl(name, radius, height, pos, color, parent, material, collide)
 return part(name, Vector3.new(height, radius*2, radius*2), CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90)), material or Enum.Material.Wood, color, parent, Enum.PartType.Cylinder, collide)
end

local function between(name, a, b, radius, color, parent, material, collide)
 local d = b-a
 return part(name, Vector3.new(d.Magnitude, radius*2, radius*2), CFrame.lookAt((a+b)/2,b) * CFrame.Angles(0,math.rad(90),0), material or Enum.Material.Wood, color, parent, Enum.PartType.Cylinder, collide)
end

-- 1. REAL LARGE WATER. The pond is Terrain water, not a blue floor.
Terrain:FillBlock(CFrame.new(0,-2,0), Vector3.new(360,14,300), Enum.Material.Water)
for _,v in ipairs({Vector3.new(-178,-2,-148),Vector3.new(178,-2,-148),Vector3.new(-178,-2,148),Vector3.new(178,-2,148)}) do
 Terrain:FillBall(v,58,Enum.Material.Air)
end

-- Shoreline.
part("NorthShore", Vector3.new(320,2,10), CFrame.new(0,5,-156), Enum.Material.Sand, C.sand, map)
part("WestShore", Vector3.new(10,2,270), CFrame.new(-184,5,0), Enum.Material.Sand, C.sand, map)
part("EastShore", Vector3.new(10,2,270), CFrame.new(184,5,0), Enum.Material.Sand, C.sand, map)

-- 2. PLAYER LOBBY / SIX BASES. Kept narrow so the pond stays dominant.
part("LobbyGround", Vector3.new(310,3,68), CFrame.new(0,3,188), Enum.Material.Grass, C.grass2, lobby)
part("LobbyPlaza", Vector3.new(286,1,42), CFrame.new(0,5,180), Enum.Material.Slate, C.stone2, lobby)
part("LobbyFrontTrim", Vector3.new(300,1,5), CFrame.new(0,5,221), Enum.Material.Sand, C.sand, lobby)

local xs = {-125,-75,-25,25,75,125}
local baseColors = {
 Color3.fromRGB(231,88,91),Color3.fromRGB(241,160,63),Color3.fromRGB(91,190,91),
 Color3.fromRGB(75,143,224),Color3.fromRGB(156,91,220),Color3.fromRGB(235,125,184)
}
local baseSpawns = {}
for i,x in ipairs(xs) do
 local m = Instance.new("Model")
 m.Name = "PlayerBase_"..i
 m:SetAttribute("BaseIndex",i)
 m.Parent = bases
 part("Platform",Vector3.new(43,2,27),CFrame.new(x,6,191),Enum.Material.Wood,C.wood,m)
 part("ColoredMat",Vector3.new(37,.35,21),CFrame.new(x,7.15,191),Enum.Material.SmoothPlastic,baseColors[i],m)
 part("BackWall",Vector3.new(43,10,1.2),CFrame.new(x,11,203.5),Enum.Material.Wood,C.wood,m)
 part("Canopy",Vector3.new(45,1.4,25),CFrame.new(x,17,191),Enum.Material.Wood,C.wood2,m)
 part("Sign",Vector3.new(28,3,.6),CFrame.new(x,18,202.6),Enum.Material.SmoothPlastic,C.sand,m)
 for slot=1,6 do
  local sx=((slot-1)%3-1)*10
  local sz=(math.floor((slot-1)/3)-.5)*8
  ball("DollSlot",Vector3.new(2.6,1.5,2.6),Vector3.new(x+sx,8,191+sz),Color3.fromRGB(241,197,151),m,nil,false)
 end
 local sp = Instance.new("SpawnLocation")
 sp.Name = "BaseSpawn_"..i
 sp.Size = Vector3.new(7,1,7)
 sp.CFrame = CFrame.new(x,8,191)
 sp.Anchored = true
 sp.Neutral = false
 sp.TeamColor = BrickColor.new(baseColors[i])
 sp.AllowTeamChangeOnTouch = false
 sp.Material = Enum.Material.Slate
 sp.Color = baseColors[i]
 sp.Parent = m
 baseSpawns[i] = sp
end

-- 3. SAKURA TREE: real trunk + major branches + twigs + multiple pink crowns.
local function sakuraTree(name, base, scale, parent)
 local m = Instance.new("Model")
 m.Name = name
 m.Parent = parent or trees
 local h = 27*scale
 cyl("Trunk",2.15*scale,h,base+Vector3.new(0,h/2,0),C.wood,m,Enum.Material.Wood,true)
 -- root flare
 for i=1,5 do
  local a=(i-1)/5*math.pi*2
  between("Root",base+Vector3.new(0,1,0),base+Vector3.new(math.cos(a)*4*scale,.6,math.sin(a)*4*scale),.65*scale,C.wood2,m,Enum.Material.Wood,true)
 end
 local joint=base+Vector3.new(0,h*.57,0)
 local ends={
  joint+Vector3.new(-11*scale,7*scale,-3*scale),
  joint+Vector3.new(11*scale,7*scale,3*scale),
  joint+Vector3.new(-6*scale,9*scale,8*scale),
  joint+Vector3.new(6*scale,9*scale,-8*scale),
  joint+Vector3.new(0,11*scale,1*scale)
 }
 for i,e in ipairs(ends) do
  between("MainBranch",joint,e,.9*scale,C.wood,m,Enum.Material.Wood,true)
  local t1=e+Vector3.new((i%2==0 and 5 or -5)*scale,4*scale,((i%3)-1)*3*scale)
  local t2=e+Vector3.new((i%2==0 and -4 or 4)*scale,3*scale,((i%2==0) and -4 or 4)*scale)
  between("Twig",e,t1,.4*scale,C.wood2,m,Enum.Material.Wood,true)
  between("Twig",e,t2,.35*scale,C.wood2,m,Enum.Material.Wood,true)
 end
 local crownPositions={
  ends[1]+Vector3.new(-2,4,0), ends[1]+Vector3.new(4,4,2),
  ends[2]+Vector3.new(2,4,0), ends[2]+Vector3.new(-4,4,-2),
  ends[3]+Vector3.new(0,4,2), ends[4]+Vector3.new(0,4,-2),
  ends[5]+Vector3.new(0,4,0), joint+Vector3.new(-4,8,0), joint+Vector3.new(5,8,1)
 }
 for i,p in ipairs(crownPositions) do
  local q=(6.5+(i%3))*scale
  ball("SakuraCrown",Vector3.new(q*2,q*1.35,q*2),p,i%2==0 and C.sakura2 or C.sakura,m,Enum.Material.SmoothPlastic,false)
  for j=1,3 do
   local a=(j-1)/3*math.pi*2
   ball("FlowerCluster",Vector3.new(2.2*scale,1.2*scale,2.2*scale),p+Vector3.new(math.cos(a)*q*.65,1.2*scale,math.sin(a)*q*.65),C.pink,m,Enum.Material.SmoothPlastic,false)
  end
 end
end

-- Pond/lobby framing trees.
for _,d in ipairs({
 {"LobbyTreeL",Vector3.new(-145,7,170),.78},{"LobbyTreeR",Vector3.new(145,7,170),.78},
 {"LobbyTreeLB",Vector3.new(-145,7,215),.72},{"LobbyTreeRB",Vector3.new(145,7,215),.72},
 {"PondTreeNW",Vector3.new(-158,5,-135),.72},{"PondTreeNE",Vector3.new(158,5,-135),.72}
}) do sakuraTree(d[1],d[2],d[3]) end

-- 4. LARGE CENTRAL FROG ISLAND.
Terrain:FillBall(Vector3.new(0,7,0),74,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(-45,7,8),40,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(45,7,8),40,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(0,12,0),71,Enum.Material.Grass)
Terrain:FillBall(Vector3.new(-43,12,8),39,Enum.Material.Grass)
Terrain:FillBall(Vector3.new(43,12,8),39,Enum.Material.Grass)
part("CentralPlayArea",Vector3.new(82,2,58),CFrame.new(0,21,8),Enum.Material.Grass,C.grass,island)

-- 5. SMALL ROCKS around island edge, never huge boulders.
for i=1,44 do
 local a=(i-1)/44*math.pi*2
 local rx=61+(i%3)*1.5
 local rz=45+(i%2)*1.2
 ball("SmallIslandRock",Vector3.new(3.4+(i%3)*.8,1.7,3.0+(i%2)*.7),Vector3.new(math.cos(a)*rx,20.5,math.sin(a)*rz),i%2==0 and C.stone or C.stone2,island,Enum.Material.Slate,false)
end

-- 6. STONE SLAB PATHS: visible flat slabs, not tiny pebbles.
for i=1,16 do
 local z=139-(i-1)*6.5
 local x=math.sin(i*.45)*1.8
 part("StoneSlab_Bridge",Vector3.new(9,1.4,5),CFrame.new(x,7.2,z)*CFrame.Angles(0,math.rad((i%3-1)*8),0),Enum.Material.Slate,C.stone2,map)
end
for i=1,9 do
 local x=(i-5)*7
 part("StoneSlab_IslandPath",Vector3.new(7,1.1,4.8),CFrame.new(x,22.1,43)*CFrame.Angles(0,math.rad((i%2)*10-5),0),Enum.Material.Slate,C.stone2,island)
end
for i=1,8 do
 local z=37-(i-1)*6
 part("StoneSlab_CenterPath",Vector3.new(6.5,1,4.5),CFrame.new(0,22.1,z),Enum.Material.Slate,C.stone2,island)
end

-- 7. ISLAND SAKURA TREES + BUSHES create visibility breaks around frog areas.
sakuraTree("IslandSakura_Left",Vector3.new(-48,21,-18),.92)
sakuraTree("IslandSakura_Right",Vector3.new(48,21,-18),.92)
sakuraTree("IslandSakura_Back",Vector3.new(0,21,-43),1.05)
sakuraTree("IslandSakura_BackLeft",Vector3.new(-34,21,27),.72)
sakuraTree("IslandSakura_BackRight",Vector3.new(34,21,27),.72)

local function bush(name,pos,scale,parent)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=parent or island
 local offsets={
  Vector3.new(-3,2,0),Vector3.new(0,2.6,0),Vector3.new(3,2,0),
  Vector3.new(-1.8,3.7,1.7),Vector3.new(1.8,3.5,-1.5),Vector3.new(0,4.3,2.1)
 }
 for i,o in ipairs(offsets) do
  local c=(i%2==0) and C.leaf2 or C.leaf
  ball("BushLeaf",Vector3.new(6.5*scale,5*scale,6.5*scale),pos+o*scale,c,m,Enum.Material.Grass,false)
 end
 -- little brown base makes the bush visibly grounded
 cyl("BushBase",1.15*scale,1.4*scale,pos+Vector3.new(0,.7*scale,0),C.wood2,m,Enum.Material.Wood,false)
end

local bushPositions={
 Vector3.new(-55,21,18),Vector3.new(55,21,18),Vector3.new(-50,21,-28),Vector3.new(50,21,-28),
 Vector3.new(-25,21,34),Vector3.new(25,21,34),Vector3.new(-63,21,-2),Vector3.new(63,21,-2)
}
for i,p in ipairs(bushPositions) do bush("IslandBush_"..i,p,.85+(i%3)*.08,island) end

-- 8. FLOWER PATCHES on island.
local flowerColors={C.pink,C.white,C.yellow,Color3.fromRGB(160,110,220)}
for i=1,36 do
 local a=(i-1)/36*math.pi*2
 local r=18+(i%5)*7
 local pos=Vector3.new(math.cos(a)*r,22.3,math.sin(a)*r*.7+8)
 ball("Flower",Vector3.new(1.2,1.2,1.2),pos,flowerColors[(i%#flowerColors)+1],island,Enum.Material.SmoothPlastic,false)
 cyl("FlowerStem",.08,1.2,pos+Vector3.new(0,-.6,0),C.reed,island,Enum.Material.Grass,false)
end

-- 9. DECORATIVE STONE STATUES. Two frog garden statues + pedestals.
local function frogStatue(name,pos,scale)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=statues
 part("Pedestal",Vector3.new(7*scale,2.2*scale,7*scale),CFrame.new(pos+Vector3.new(0,1.1*scale,0)),Enum.Material.Slate,C.stoneDark,m)
 part("PedestalTop",Vector3.new(5.8*scale,.7*scale,5.8*scale),CFrame.new(pos+Vector3.new(0,2.55*scale,0)),Enum.Material.Marble,C.stone2,m)
 ball("FrogBody",Vector3.new(6*scale,4.3*scale,5*scale),pos+Vector3.new(0,5*scale,0),C.leaf,m,Enum.Material.SmoothPlastic,false)
 ball("FrogHead",Vector3.new(5.2*scale,3.6*scale,4.8*scale),pos+Vector3.new(0,7.2*scale,.2*scale),C.leaf2,m,Enum.Material.SmoothPlastic,false)
 ball("EyeL",Vector3.new(1.2*scale,1.2*scale,1.2*scale),pos+Vector3.new(-1.7*scale,8.6*scale,-1.5*scale),C.white,m,Enum.Material.SmoothPlastic,false)
 ball("EyeR",Vector3.new(1.2*scale,1.2*scale,1.2*scale),pos+Vector3.new(1.7*scale,8.6*scale,-1.5*scale),C.white,m,Enum.Material.SmoothPlastic,false)
 ball("PupilL",Vector3.new(.45*scale,.45*scale,.45*scale),pos+Vector3.new(-1.7*scale,8.6*scale,-2.05*scale),C.stoneDark,m,Enum.Material.SmoothPlastic,false)
 ball("PupilR",Vector3.new(.45*scale,.45*scale,.45*scale),pos+Vector3.new(1.7*scale,8.6*scale,-2.05*scale),C.stoneDark,m,Enum.Material.SmoothPlastic,false)
end
frogStatue("FrogGardenStatue_Left",Vector3.new(-17,21,2),1)
frogStatue("FrogGardenStatue_Right",Vector3.new(17,21,2),1)

-- 10. LOTUS / LILY GARDENS around the water edge.
local function lilyPad(pos,scale)
 local p=part("LilyPad",Vector3.new(.28,6.4*scale,6.4*scale),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Grass,C.waterPlant,decor,nil,false)
 p.Shape=Enum.PartType.Cylinder
 return p
end
local function lotus(name,pos,scale)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=decor
 for i=1,8 do
  local a=(i-1)/8*math.pi*2
  local r=1.5*scale
  local p=ball("Petal",Vector3.new(3.2*scale,.6*scale,1.5*scale),pos+Vector3.new(math.cos(a)*r,.8,math.sin(a)*r),i%2==0 and C.pink or C.white,m,Enum.Material.SmoothPlastic,false)
  p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-a,math.rad(-18))
 end
 ball("Center",Vector3.new(1.7*scale,.8*scale,1.7*scale),pos+Vector3.new(0,1.15,0),C.yellow,m,Enum.Material.SmoothPlastic,false)
end
local gardens={
 Vector3.new(-130,4,-92),Vector3.new(-70,4,-125),Vector3.new(70,4,-125),Vector3.new(130,4,-92),
 Vector3.new(-145,4,65),Vector3.new(145,4,65),Vector3.new(-118,4,105),Vector3.new(118,4,105),
 Vector3.new(-45,4,125),Vector3.new(45,4,125),Vector3.new(-155,4,-20),Vector3.new(155,4,-20)
}
for i,p in ipairs(gardens) do lilyPad(p,.9);lotus("LotusGarden_"..i,p,.85+(i%2)*.1) end
for _,p in ipairs({Vector3.new(-105,4,-35),Vector3.new(-115,4,30),Vector3.new(105,4,-35),Vector3.new(115,4,30),Vector3.new(-70,4,95),Vector3.new(70,4,95),Vector3.new(-70,4,-95),Vector3.new(70,4,-95)}) do lilyPad(p,.7) end

-- 11. REEDS around outside perimeter only.
for g=1,24 do
 local a=(g-1)/24*math.pi*2
 local cx=math.cos(a)*170
 local cz=math.sin(a)*140
 for j=1,5 do
  local h=4+(j%3)
  cyl("Reed",.14,h,Vector3.new(cx+(j-3)*1.2,5+h/2,cz+(j%2)*.8),C.reed,decor,Enum.Material.Grass,false)
 end
end

-- 12. SMALL SAILBOAT for atmosphere.
local boat=Instance.new("Model")
boat.Name="SmallSailboat"
boat.Parent=decor
part("Hull",Vector3.new(15,2.5,5),CFrame.new(102,4,-52)*CFrame.Angles(0,math.rad(-18),0),Enum.Material.Wood,C.wood,boat)
cyl("Mast",.25,14,Vector3.new(102,11,-52),C.wood2,boat,Enum.Material.Wood,false)
part("Sail",Vector3.new(.3,8,7),CFrame.new(102,11,-52)*CFrame.Angles(0,0,math.rad(12)),Enum.Material.Fabric,C.white,boat,false)

-- 13. FISH in the actual water.
local fishData={}
local fishCenters={
 Vector3.new(-135,-1,-45),Vector3.new(-100,-2,-105),Vector3.new(-40,-1,-125),Vector3.new(40,-2,-125),
 Vector3.new(100,-1,-105),Vector3.new(135,-2,-45),Vector3.new(-145,-1,20),Vector3.new(145,-2,20),
 Vector3.new(-135,-1,70),Vector3.new(135,-2,70),Vector3.new(-80,-1,115),Vector3.new(-25,-2,130),
 Vector3.new(25,-1,130),Vector3.new(80,-2,115),Vector3.new(-165,-1,-105),Vector3.new(165,-2,-105),
 Vector3.new(-165,-1,105),Vector3.new(165,-2,105)
}
for i,pos in ipairs(fishCenters) do
 local m=Instance.new("Model")
 m.Name="Fish_"..i
 m.Parent=fishFolder
 ball("Body",Vector3.new(4,1.5,2.3),pos,C.fish,m,nil,false)
 part("Tail",Vector3.new(.4,1.8,2.3),CFrame.new(pos+Vector3.new(-2,0,0)),Enum.Material.SmoothPlastic,C.fish2,m,Enum.PartType.Wedge,false)
 ball("Eye",Vector3.new(.3,.3,.3),pos+Vector3.new(1.2,.45,-.7),Color3.fromRGB(15,15,15),m,nil,false)
 fishData[#fishData+1]={m=m,cx=pos.X,cz=pos.Z,y=pos.Y,r=10+(i%4)*4,phase=i*.7,s=.16+(i%5)*.025}
end

-- 14. GAMEPLAY REGIONS.
local regions=Instance.new("Folder")
regions.Name="GameplayRegions"
regions.Parent=world
local frogSpawn=part("FrogSpawnRegion",Vector3.new(62,1,42),CFrame.new(0,22,5),Enum.Material.SmoothPlastic,Color3.fromRGB(80,180,100),regions,nil,false)
frogSpawn.Transparency=1
local raceStart=part("RaceStart",Vector3.new(18,1,6),CFrame.new(0,22,43),Enum.Material.SmoothPlastic,Color3.fromRGB(255,225,100),regions,nil,false)
raceStart.Transparency=1
local swimRegion=part("SwimRegion",Vector3.new(350,10,290),CFrame.new(0,0,0),Enum.Material.SmoothPlastic,Color3.fromRGB(50,150,180),regions,nil,false)
swimRegion.Transparency=1

-- 15. PLAYER ASSIGNMENT: each player respawns in their own base.
local assigned={}
local function freeBase()
 for i=1,6 do if not assigned[i] then return i end end
end
local function assign(p)
 local i=freeBase()
 if not i then return end
 assigned[i]=p
 p:SetAttribute("BaseIndex",i)
 p.RespawnLocation=baseSpawns[i]
end
Players.PlayerAdded:Connect(function(p)
 assign(p)
 p.CharacterAdded:Connect(function(c)
  local i=p:GetAttribute("BaseIndex") or 1
  local s=baseSpawns[i]
  if s then c:PivotTo(s.CFrame+Vector3.new(0,4,0)) end
 end)
end)
Players.PlayerRemoving:Connect(function(p)
 for i,v in pairs(assigned) do if v==p then assigned[i]=nil end end
end)
for _,p in ipairs(Players:GetPlayers()) do
 assign(p)
end

-- 16. FALLING SAKURA PETALS.
local petals=Instance.new("Folder")
petals.Name="FallingSakuraPetals"
petals.Parent=world
for i=1,100 do
 local p=part("Petal",Vector3.new(.35,.08,.5),CFrame.new(math.random(-160,160),math.random(18,48),math.random(-145,220)),Enum.Material.SmoothPlastic,C.sakura2,petals,nil,false)
 p:SetAttribute("phase",math.random()*12)
end

-- 17. WORLD ATTRIBUTES.
world:SetAttribute("MapVersion","PondIsland_v7_FullReferenceRebuild")
world:SetAttribute("PondSize","360x300")
world:SetAttribute("WaterIsTerrain",true)
world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("EnvironmentChecklist","SakuraTrees,Bushes,StoneSlabs,Statues,Flowers,Lotus,Reeds,Fish,Sailboat,FrogIsland,PlayerBases")

local t0=os.clock()
RunService.Heartbeat:Connect(function()
 local t=os.clock()-t0
 for _,d in ipairs(fishData) do
  local a=t*d.s+d.phase
  local x=d.cx+math.cos(a)*d.r
  local z=d.cz+math.sin(a)*d.r*.72
  local y=d.y+math.sin(t*1.7+d.phase)*.3
  d.m:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,-a,0))
 end
 for _,p in ipairs(petals:GetChildren()) do
  local ph=p:GetAttribute("phase") or 0
  p.Position=Vector3.new(p.Position.X+math.sin(t*.6+ph)*.012,15+((ph+t*1.5)%28),p.Position.Z+math.cos(t*.5+ph)*.01)
 end
end)

Lighting.ClockTime=16.3
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

print("FrogGame v7 loaded: FULL reference environment with Sakura, bushes, slabs, statues, lotus, fish and large pond")