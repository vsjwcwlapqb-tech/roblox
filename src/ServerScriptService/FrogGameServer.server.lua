-- Frog Game Environment v4
-- IMPORTANT: Pond water is Roblox Terrain water. There is NO blue Part floor.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain

local old = Workspace:FindFirstChild("FrogGame")
if old then old:Destroy() end
Terrain:Clear()
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

local world = Instance.new("Folder", Workspace)
world.Name = "FrogGame"
local map = Instance.new("Folder", world)
map.Name = "PondAndIsland"
local island = Instance.new("Model", map)
island.Name = "FrogIsland"
local decor = Instance.new("Folder", island)
decor.Name = "Decoration"
local pondDecor = Instance.new("Folder", world)
pondDecor.Name = "PondDecoration"
local fishFolder = Instance.new("Folder", world)
fishFolder.Name = "PondFish"

local C = {
 grass=Color3.fromRGB(91,163,82), grass2=Color3.fromRGB(117,184,95),
 dirt=Color3.fromRGB(103,70,45), sand=Color3.fromRGB(226,204,145),
 stone=Color3.fromRGB(125,127,120), stone2=Color3.fromRGB(160,160,150),
 wood=Color3.fromRGB(79,46,31), wood2=Color3.fromRGB(126,76,43),
 leaf=Color3.fromRGB(63,138,71), reed=Color3.fromRGB(48,126,62),
 sakura=Color3.fromRGB(239,145,192), sakura2=Color3.fromRGB(255,190,219),
 pink=Color3.fromRGB(255,164,205), white=Color3.fromRGB(255,232,243),
 yellow=Color3.fromRGB(255,216,78), fish=Color3.fromRGB(245,150,65), fish2=Color3.fromRGB(255,205,105)
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
 local d=b-a;local mid=(a+b)/2
 return part(name,Vector3.new(d.Magnitude,r*2,r*2),CFrame.lookAt(mid,b)*CFrame.Angles(0,math.rad(90),0),mat or Enum.Material.Wood,color,parent,Enum.PartType.Cylinder,true)
end

-- ============================================================
-- POND: flat, large, organic silhouette, REAL SWIMMABLE WATER
-- ============================================================
Terrain:FillBlock(CFrame.new(0,-3,0),Vector3.new(204,10,158),Enum.Material.Water)
-- Remove corners so the pond does not look like a giant rectangle.
for _,p in ipairs({Vector3.new(-96,-3,-70),Vector3.new(96,-3,-70),Vector3.new(-96,-3,70),Vector3.new(96,-3,70)}) do
 Terrain:FillBall(p,44,Enum.Material.Air)
end

-- Large island cut out of the water with a clean air boundary.
Terrain:FillBall(Vector3.new(0,0,0),57,Enum.Material.Air)
Terrain:FillBall(Vector3.new(-36,0,5),32,Enum.Material.Air)
Terrain:FillBall(Vector3.new(36,0,5),32,Enum.Material.Air)

-- Shoreline sand is outside/above the terrain water; no coplanar blue parts.
part("BeachSouth",Vector3.new(150,1,8),CFrame.new(0,2.5,84),Enum.Material.Sand,C.sand)
part("BeachNorth",Vector3.new(150,1,8),CFrame.new(0,2.5,-84),Enum.Material.Sand,C.sand)
part("BeachWest",Vector3.new(8,1,126),CFrame.new(-100,2.5,0),Enum.Material.Sand,C.sand)
part("BeachEast",Vector3.new(8,1,126),CFrame.new(100,2.5,0),Enum.Material.Sand,C.sand)

-- ============================================================
-- LARGE ISLAND
-- ============================================================
ball("IslandBase",Vector3.new(126,18,104),Vector3.new(0,7,0),C.dirt,island,Enum.Material.Ground)
ball("IslandGrass",Vector3.new(116,9,94),Vector3.new(0,15,0),C.grass,island,Enum.Material.Grass)
local lobes={{-44,-22,42,30},{-22,-39,43,29},{7,-43,44,29},{36,-29,42,30},{49,-3,38,30},{45,22,41,29},{23,38,43,29},{-8,42,43,29},{-35,31,41,29},{-49,7,38,30}}
for i,v in ipairs(lobes) do ball("GrassLobe"..i,Vector3.new(v[3],7,v[4]),Vector3.new(v[1],17,v[2]),C.grass2,island,Enum.Material.Grass) end
part("CentralPlayArea",Vector3.new(56,1,38),CFrame.new(0,20,8),Enum.Material.Grass,C.grass,island)

-- ============================================================
-- STONE BRIDGE: REGULARLY SPACED, NOT RANDOM TILES
-- ============================================================
local bridge=Instance.new("Model",map);bridge.Name="IslandBridge"
for i=1,16 do
 local z=78-(i-1)*4.5
 local x=math.sin((i-1)*0.55)*1.6
 local p=part("StoneStep"..i,Vector3.new(9,2,5.5),CFrame.new(x,2.6,z),Enum.Material.Slate,C.stone2,bridge)
 p.CFrame=CFrame.new(x,2.6,z)*CFrame.Angles(0,math.rad(math.sin(i)*3),0)
end

-- ============================================================
-- SAKURA TREES: ROOTED TRUNK + CONNECTED BRANCHES + CROWNS
-- ============================================================
local function tree(name,base,s)
 local m=Instance.new("Model",decor);m.Name=name
 local h=24*s
 cyl("Trunk",2.2*s,h,base+Vector3.new(0,h/2,0),C.wood,m,Enum.Material.Wood,true)
 local j=base+Vector3.new(0,h*.58,0)
 local e={j+Vector3.new(-10*s,7*s,-2*s),j+Vector3.new(10*s,7*s,2*s),j+Vector3.new(-4*s,9*s,8*s),j+Vector3.new(4*s,9*s,-8*s)}
 for i,v in ipairs(e) do
  between("Branch"..i,j,v,.9*s,C.wood,m)
  local t=v+Vector3.new((i%2==0 and 4 or -4)*s,4*s,(i%3-1)*2*s)
  between("Twig"..i,v,t,.48*s,C.wood2,m)
 end
 local crowns={
  e[1]+Vector3.new(-1,3.5,0),e[1]+Vector3.new(4,4.5,1),
  e[2]+Vector3.new(1,3.5,0),e[2]+Vector3.new(-4,4.5,-1),
  e[3]+Vector3.new(0,4,1),e[4]+Vector3.new(0,4,-1),
  base+Vector3.new(0,h+6.5*s,0)
 }
 for i,v in ipairs(crowns) do
  local q=(7+(i%3))*s
  ball("SakuraCrown"..i,Vector3.new(q*2,q*1.35,q*2),v,i%2==0 and C.sakura2 or C.sakura,m,Enum.Material.SmoothPlastic,false)
 end
end

tree("Sakura_Left",Vector3.new(-37,20,-14),1.0)
tree("Sakura_Right",Vector3.new(37,20,-14),1.0)
tree("Sakura_Back",Vector3.new(0,20,-35),1.1)
tree("Sakura_BackLeft",Vector3.new(-29,20,29),.78)
tree("Sakura_BackRight",Vector3.new(29,20,29),.78)

-- ============================================================
-- BUSHES / ROCKS: GROUPED AROUND EDGES
-- ============================================================
local function bush(name,pos,s)
 local m=Instance.new("Model",decor);m.Name=name
 for i=1,6 do
  local a=(i-1)/6*math.pi*2
  ball("Leaf",Vector3.new(7*s,5*s,7*s),pos+Vector3.new(math.cos(a)*2.5*s,2.5*s,math.sin(a)*2.5*s),C.leaf,m,Enum.Material.Grass,false)
 end
end
bush("Bush_LeftFront",Vector3.new(-45,20,23),1)
bush("Bush_RightFront",Vector3.new(45,20,23),1)
bush("Bush_LeftBack",Vector3.new(-47,20,-27),.9)
bush("Bush_RightBack",Vector3.new(47,20,-27),.9)
for i=1,24 do
 local a=(i-1)/24*math.pi*2;local r=53+(i%3)*1.5
 ball("IslandRock"..i,Vector3.new(6+(i%3),3.4,5+(i%2)),Vector3.new(math.cos(a)*r,19,math.sin(a)*r*.78),C.stone,decor,Enum.Material.Slate,false)
end

-- ============================================================
-- LOTUS + LILY PADS: ALL PLACED AT WATER SURFACE
-- ============================================================
local function lily(pos,s)
 local p=cyl("LilyPad",3.3*s,.22,pos,Color3.fromRGB(55,145,72),pondDecor,Enum.Material.Grass,false)
 p.Size=Vector3.new(.22,6.6*s,6.6*s)
 p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))
end
local function lotus(name,pos,s)
 local m=Instance.new("Model",pondDecor);m.Name=name
 for i=1,8 do
  local a=(i-1)/8*math.pi*2;local r=1.7*s
  local p=ball("Petal",Vector3.new(3.3*s,.75*s,1.7*s),pos+Vector3.new(math.cos(a)*r,1,math.sin(a)*r),i%2==0 and C.pink or C.white,m,Enum.Material.SmoothPlastic,false)
  p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-a,math.rad(-18))
 end
 ball("LotusCenter",Vector3.new(2*s,.9*s,2*s),pos+Vector3.new(0,1.4,0),C.yellow,m,Enum.Material.SmoothPlastic,false)
end
local lotusSpots={Vector3.new(-73,2,-40),Vector3.new(72,2,-37),Vector3.new(-78,2,22),Vector3.new(78,2,27),Vector3.new(-31,2,64),Vector3.new(35,2,64)}
for i,p in ipairs(lotusSpots) do lily(p,1);lotus("LotusGarden"..i,p,.9+(i%2)*.1) end
for _,p in ipairs({Vector3.new(-55,2,-20),Vector3.new(55,2,-18),Vector3.new(-62,2,45),Vector3.new(62,2,47),Vector3.new(0,2,72),Vector3.new(0,2,-67),Vector3.new(86,2,0),Vector3.new(-86,2,0)}) do lily(p,.82) end

-- Reeds are in neat shoreline groups, not scattered across the island.
for g=1,8 do
 local a=(g-1)/8*math.pi*2;local cx=math.cos(a)*91;local cz=math.sin(a)*69
 for j=1,5 do
  local h=5+(j%3);cyl("Reed",.16,h,Vector3.new(cx+(j-3)*.9,2+h/2,cz+(j%2)*.7),C.reed,pondDecor,Enum.Material.Grass,false)
 end
end

-- ============================================================
-- VISIBLE FISH: SWIM INSIDE THE TERRAIN WATER
-- ============================================================
local fishData={}
local function makeFish(id,pos,r,phase)
 local m=Instance.new("Model",fishFolder);m.Name="Fish"..id
 ball("Body",Vector3.new(3.8,1.5,2.2),pos,C.fish,m,nil,false)
 part("Tail",Vector3.new(.45,1.9,2.3),CFrame.new(pos+Vector3.new(-1.9,0,0)),Enum.Material.SmoothPlastic,C.fish2,m,Enum.PartType.Wedge,false)
 ball("Eye",Vector3.new(.3,.3,.3),pos+Vector3.new(1.1,.45,-.75),Color3.fromRGB(15,15,15),m,nil,false)
 fishData[#fishData+1]={m=m,x=pos.X,z=pos.Z,y=pos.Y,r=r,phase=phase,s=.27+(id%4)*.05}
end
local fp={Vector3.new(-68,-1,-34),Vector3.new(-35,-1,-58),Vector3.new(32,-1,-58),Vector3.new(68,-1,-31),Vector3.new(-76,-1,17),Vector3.new(76,-1,16),Vector3.new(-57,-1,52),Vector3.new(57,-1,54),Vector3.new(-18,-1,69),Vector3.new(20,-1,69),Vector3.new(87,-1,3),Vector3.new(-87,-1,-2)}
for i,p in ipairs(fp) do makeFish(i,p,7+(i%4)*2.5,i*.7) end

-- ============================================================
-- PLAYER DISPLAY STALLS OUTSIDE THE POND
-- ============================================================
local stalls=Instance.new("Folder",world);stalls.Name="PlayerDisplayAreas"
local sp={Vector3.new(-72,3,106),Vector3.new(-24,3,106),Vector3.new(24,3,106),Vector3.new(72,3,106),Vector3.new(-108,3,72),Vector3.new(108,3,72)}
for i,p in ipairs(sp) do
 local m=Instance.new("Model",stalls);m.Name="PlayerStall"..i
 part("Platform",Vector3.new(24,2,15),CFrame.new(p),Enum.Material.Wood,C.wood,m)
 part("Back",Vector3.new(24,9,1),CFrame.new(p+Vector3.new(0,5,6.5)),Enum.Material.Wood,C.wood,m)
 part("Sign",Vector3.new(16,3,.6),CFrame.new(p+Vector3.new(0,10,5.8)),Enum.Material.SmoothPlastic,C.sand,m)
 for slot=1,6 do
  local x=((slot-1)%3-1)*6;local z=(math.floor((slot-1)/3)-.5)*5
  ball("DollSlot",Vector3.new(2.5,2.5,2.5),p+Vector3.new(x,3,z),Color3.fromRGB(241,197,151),m,nil,false)
 end
end

-- Spawn on the mainland so the player starts looking toward the whole pond.
local spawn=Instance.new("SpawnLocation",world)
spawn.Name="PlayerSpawn";spawn.Size=Vector3.new(8,1,8);spawn.CFrame=CFrame.new(0,4,112)
spawn.Anchored=true;spawn.Neutral=true;spawn.Transparency=1;spawn.CanCollide=false

local regions=Instance.new("Folder",world);regions.Name="GameplayRegions"
local frogRegion=part("FrogSpawnRegion",Vector3.new(46,.5,30),CFrame.new(0,20,8),Enum.Material.SmoothPlastic,C.grass,regions,nil,false);frogRegion.Transparency=1
local race=part("RaceStart",Vector3.new(20,.5,6),CFrame.new(0,20,39),Enum.Material.SmoothPlastic,Color3.fromRGB(255,220,90),regions,nil,false);race.Transparency=1

-- Sakura petals.
local petals=Instance.new("Folder",world);petals.Name="SakuraPetals"
for i=1,45 do
 local p=part("Petal",Vector3.new(.35,.08,.5),CFrame.new(math.random(-65,65),math.random(25,45),math.random(-55,45)),Enum.Material.SmoothPlastic,C.sakura2,petals,nil,false)
 p:SetAttribute("phase",math.random()*12)
end

world:SetAttribute("MaxPlayers",6)
world:SetAttribute("MaxFrogs",20)
world:SetAttribute("ActiveRoundSeconds",300)
world:SetAttribute("ResetSeconds",10)
world:SetAttribute("LegendaryTimerSeconds",1800)
world:SetAttribute("SecretTimerSeconds",3600)
world:SetAttribute("MapVersion","PondIsland_v4")

local t0=os.clock()
RunService.Heartbeat:Connect(function()
 local t=os.clock()-t0
 for _,d in ipairs(fishData) do
  local a=t*d.s+d.phase
  d.m:PivotTo(CFrame.new(d.x+math.cos(a)*d.r,d.y+math.sin(t*1.7+d.phase)*.35,d.z+math.sin(a)*d.r*.68)*CFrame.Angles(0,-a,0))
 end
 for _,p in ipairs(petals:GetChildren()) do
  if p:IsA("BasePart") then
   local phase=p:GetAttribute("phase") or 0;local y=45-((t+phase)%12)*2.5
   if y<19 then y=45 end
   p.Position=Vector3.new(p.Position.X+math.sin(t+phase)*.01,y,p.Position.Z)
  end
 end
end)

Lighting.ClockTime=16.2
Lighting.Brightness=2.5
Lighting.EnvironmentDiffuseScale=.65
Lighting.EnvironmentSpecularScale=.35
local at=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
at.Density=.16;at.Haze=.55;at.Glare=.06;at.Parent=Lighting

print("FrogGame v4: real Terrain water, large island, fixed Sakura trees, lotus, lily pads and fish loaded.")