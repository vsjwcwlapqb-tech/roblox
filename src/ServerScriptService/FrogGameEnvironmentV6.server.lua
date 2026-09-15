-- Frog Game Environment v6
-- Reference-style layout: very large swimmable lake, central frog island,
-- six waterfront player bases, smaller island stones, organized lotus/fish.

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

local world=Instance.new("Folder",Workspace); world.Name="FrogGame"
local map=Instance.new("Folder",world); map.Name="Map"
local island=Instance.new("Model",map); island.Name="FrogIsland"
local lobby=Instance.new("Model",map); lobby.Name="Lobby"
local bases=Instance.new("Folder",lobby); bases.Name="PlayerBases"
local decor=Instance.new("Folder",world); decor.Name="PondDecoration"
local fishFolder=Instance.new("Folder",world); fishFolder.Name="PondFish"
local trees=Instance.new("Folder",map); trees.Name="SakuraGrove"

local C={grass=Color3.fromRGB(91,165,83),grass2=Color3.fromRGB(124,191,103),dirt=Color3.fromRGB(105,70,43),sand=Color3.fromRGB(232,210,153),stone=Color3.fromRGB(132,136,132),stone2=Color3.fromRGB(181,181,170),wood=Color3.fromRGB(78,45,31),wood2=Color3.fromRGB(128,77,43),leaf=Color3.fromRGB(69,145,75),reed=Color3.fromRGB(48,126,61),sakura=Color3.fromRGB(239,143,190),sakura2=Color3.fromRGB(255,194,220),pink=Color3.fromRGB(255,166,207),white=Color3.fromRGB(255,232,244),yellow=Color3.fromRGB(255,216,76),fish=Color3.fromRGB(244,145,61),fish2=Color3.fromRGB(255,205,106)}

local function part(n,s,cf,mat,col,par,shape,canCollide)
 local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.Material=mat or Enum.Material.SmoothPlastic;p.Color=col or Color3.new(1,1,1);p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CanCollide=canCollide~=false;p.CanTouch=canCollide~=false;p.CanQuery=canCollide~=false
 if shape then p.Shape=shape end;p.Parent=par or map;return p
end
local function ball(n,s,pos,col,par,mat,cc)return part(n,s,CFrame.new(pos),mat or Enum.Material.SmoothPlastic,col,par,Enum.PartType.Ball,cc)end
local function cyl(n,r,h,pos,col,par,mat,cc)return part(n,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),mat or Enum.Material.Wood,col,par,Enum.PartType.Cylinder,cc)end
local function between(n,a,b,r,col,par,mat)local d=b-a;return part(n,Vector3.new(d.Magnitude,r*2,r*2),CFrame.lookAt((a+b)/2,b)*CFrame.Angles(0,math.rad(90),0),mat or Enum.Material.Wood,col,par,Enum.PartType.Cylinder,true)end

-- LARGE WATER FIRST: 360 x 300. It remains dominant around the island.
Terrain:FillBlock(CFrame.new(0,-2,0),Vector3.new(360,14,300),Enum.Material.Water)
for _,v in ipairs({Vector3.new(-178,-2,-148),Vector3.new(178,-2,-148),Vector3.new(-178,-2,148),Vector3.new(178,-2,148)}) do Terrain:FillBall(v,58,Enum.Material.Air) end
part("NorthShore",Vector3.new(320,2,10),CFrame.new(0,5,-156),Enum.Material.Sand,C.sand,map)
part("WestShore",Vector3.new(10,2,270),CFrame.new(-184,5,0),Enum.Material.Sand,C.sand,map)
part("EastShore",Vector3.new(10,2,270),CFrame.new(184,5,0),Enum.Material.Sand,C.sand,map)

-- SHALLOW WATERFRONT LOBBY. Wide, but only 68 studs deep.
part("LobbyGround",Vector3.new(310,3,68),CFrame.new(0,3,188),Enum.Material.Grass,C.grass2,lobby)
part("LobbyPlaza",Vector3.new(286,1,42),CFrame.new(0,5,180),Enum.Material.Slate,C.stone2,lobby)
part("LobbyFrontTrim",Vector3.new(300,1,5),CFrame.new(0,5,221),Enum.Material.Sand,C.sand,lobby)

-- SIX BASES ON THE WATERFRONT. Each player gets their own SpawnLocation.
local xs={-125,-75,-25,25,75,125}
local baseColors={Color3.fromRGB(231,88,91),Color3.fromRGB(241,160,63),Color3.fromRGB(91,190,91),Color3.fromRGB(75,143,224),Color3.fromRGB(156,91,220),Color3.fromRGB(235,125,184)}
local baseSpawns={}
for i,x in ipairs(xs) do
 local m=Instance.new("Model",bases);m.Name="PlayerBase_"..i;m:SetAttribute("BaseIndex",i)
 part("Platform",Vector3.new(43,2,27),CFrame.new(x,6,191),Enum.Material.Wood,C.wood,m)
 part("ColoredMat",Vector3.new(37,.35,21),CFrame.new(x,7.15,191),Enum.Material.SmoothPlastic,baseColors[i],m)
 part("BackWall",Vector3.new(43,10,1.2),CFrame.new(x,11,203.5),Enum.Material.Wood,C.wood,m)
 part("Canopy",Vector3.new(45,1.4,25),CFrame.new(x,17,191),Enum.Material.Wood,C.wood2,m)
 part("Sign",Vector3.new(28,3,.6),CFrame.new(x,18,202.6),Enum.Material.SmoothPlastic,C.sand,m)
 for slot=1,6 do local sx=((slot-1)%3-1)*10;local sz=(math.floor((slot-1)/3)-.5)*8;ball("DollSlot",Vector3.new(2.6,1.5,2.6),Vector3.new(x+sx,8,191+sz),Color3.fromRGB(241,197,151),m,nil,false) end
 local sp=Instance.new("SpawnLocation");sp.Name="BaseSpawn_"..i;sp.Size=Vector3.new(7,1,7);sp.CFrame=CFrame.new(x,8,191);sp.Anchored=true;sp.Neutral=false;sp.TeamColor=BrickColor.new(baseColors[i]);sp.AllowTeamChangeOnTouch=false;sp.Material=Enum.Material.Slate;sp.Color=baseColors[i];sp.Parent=m;baseSpawns[i]=sp
end

-- GROUNDED SAKURA TREE SYSTEM.
local function tree(name,base,s,par)
 local m=Instance.new("Model",par or trees);m.Name=name;local h=28*s
 cyl("Trunk",2.2*s,h,base+Vector3.new(0,h/2,0),C.wood,m,Enum.Material.Wood,true)
 local joint=base+Vector3.new(0,h*.58,0)
 local ends={joint+Vector3.new(-10*s,7*s,-3*s),joint+Vector3.new(10*s,7*s,3*s),joint+Vector3.new(-5*s,9*s,8*s),joint+Vector3.new(5*s,9*s,-8*s)}
 for i,e in ipairs(ends) do between("Branch",joint,e,.85*s,C.wood,m,Enum.Material.Wood);local twig=e+Vector3.new((i%2==0 and 4 or -4)*s,4*s,(i%3-1)*2*s);between("Twig",e,twig,.42*s,C.wood2,m,Enum.Material.Wood) end
 for i,p in ipairs({ends[1]+Vector3.new(-2,3,0),ends[1]+Vector3.new(4,4,1),ends[2]+Vector3.new(2,3,0),ends[2]+Vector3.new(-4,4,-1),ends[3]+Vector3.new(0,4,1),ends[4]+Vector3.new(0,4,-1),joint+Vector3.new(0,9*s,0)}) do local q=(7+(i%3))*s;ball("SakuraCrown",Vector3.new(q*2,q*1.3,q*2),p,i%2==0 and C.sakura2 or C.sakura,m,Enum.Material.SmoothPlastic,false) end
end
for _,d in ipairs({{"LobbyTreeL",Vector3.new(-145,7,170),.78},{"LobbyTreeR",Vector3.new(145,7,170),.78},{"LobbyTreeLB",Vector3.new(-145,7,215),.72},{"LobbyTreeRB",Vector3.new(145,7,215),.72}}) do tree(d[1],d[2],d[3]) end

-- CENTRAL ISLAND: about 150 x 120, high enough to read clearly from the lobby.
Terrain:FillBall(Vector3.new(0,7,0),74,Enum.Material.Ground);Terrain:FillBall(Vector3.new(-45,7,8),40,Enum.Material.Ground);Terrain:FillBall(Vector3.new(45,7,8),40,Enum.Material.Ground)
Terrain:FillBall(Vector3.new(0,12,0),71,Enum.Material.Grass);Terrain:FillBall(Vector3.new(-43,12,8),39,Enum.Material.Grass);Terrain:FillBall(Vector3.new(43,12,8),39,Enum.Material.Grass)
part("CentralPlayArea",Vector3.new(82,2,58),CFrame.new(0,21,8),Enum.Material.Grass,C.grass,island)

-- SMALLER ISLAND STONES: 3.8-5 studs, not giant boulders.
for i=1,40 do local a=(i-1)/40*math.pi*2;ball("SmallIslandStone",Vector3.new(3.8+(i%2)*1.2,1.8,3.4+(i%2)),Vector3.new(math.cos(a)*61,20,math.sin(a)*46),C.stone,island,Enum.Material.Slate,false) end
-- Small, evenly spaced bridge stones.
for i=1,15 do local z=142-(i-1)*6;part("BridgeStone",Vector3.new(8,1.6,4),CFrame.new(math.sin(i*.45)*1.5,7,z),Enum.Material.Slate,C.stone2,map) end
for i=-4,4 do part("IslandPathStone",Vector3.new(6,1,4),CFrame.new(i*7,22,43),Enum.Material.Slate,C.stone2,island) end
for i=1,8 do part("IslandCenterStone",Vector3.new(5.5,1,4.5),CFrame.new(0,22,38-i*6),Enum.Material.Slate,C.stone2,island) end

-- Sakura trees leave the middle open.
tree("IslandTreeLeft",Vector3.new(-48,21,-18),.92)
tree("IslandTreeRight",Vector3.new(48,21,-18),.92)
tree("IslandTreeBack",Vector3.new(0,21,-43),1.08)
tree("IslandTreeBackLeft",Vector3.new(-34,21,27),.72)
tree("IslandTreeBackRight",Vector3.new(34,21,27),.72)

local function bush(name,pos,s)local m=Instance.new("Model",island);m.Name=name;for i=1,6 do local a=(i-1)/6*math.pi*2;ball("Leaf",Vector3.new(6*s,4.5*s,6*s),pos+Vector3.new(math.cos(a)*2.4*s,2.2*s,math.sin(a)*2.4*s),C.leaf,m,Enum.Material.Grass,false)end end
bush("BushLeft",Vector3.new(-50,21,20),.9);bush("BushRight",Vector3.new(50,21,20),.9);bush("BushBackLeft",Vector3.new(-48,21,-28),.78);bush("BushBackRight",Vector3.new(48,21,-28),.78)

-- LOTUS AND LILY GARDENS: perimeter clusters leave clear swimming corridors.
local function lily(pos,s)local p=cyl("LilyPad",3.1*s,.22,pos,Color3.fromRGB(55,145,74),decor,Enum.Material.Grass,false);p.Size=Vector3.new(.22,6.2*s,6.2*s);p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))end
local function lotus(name,pos,s)local m=Instance.new("Model",decor);m.Name=name;for i=1,8 do local a=(i-1)/8*math.pi*2;local r=1.5*s;local p=ball("Petal",Vector3.new(3.2*s,.6*s,1.5*s),pos+Vector3.new(math.cos(a)*r,.8,math.sin(a)*r),i%2==0 and C.pink or C.white,m,Enum.Material.SmoothPlastic,false);p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-a,math.rad(-18))end;ball("Center",Vector3.new(1.7*s,.8*s,1.7*s),pos+Vector3.new(0,1.15,0),C.yellow,m,Enum.Material.SmoothPlastic,false)end
local gardens={Vector3.new(-130,4,-92),Vector3.new(-70,4,-125),Vector3.new(70,4,-125),Vector3.new(130,4,-92),Vector3.new(-145,4,65),Vector3.new(145,4,65),Vector3.new(-118,4,105),Vector3.new(118,4,105),Vector3.new(-45,4,125),Vector3.new(45,4,125),Vector3.new(-155,4,-20),Vector3.new(155,4,-20)}
for i,p in ipairs(gardens) do lily(p,.9);lotus("LotusGarden_"..i,p,.85+(i%2)*.1) end
for _,p in ipairs({Vector3.new(-105,4,-35),Vector3.new(-115,4,30),Vector3.new(105,4,-35),Vector3.new(115,4,30),Vector3.new(-70,4,95),Vector3.new(70,4,95),Vector3.new(-70,4,-95),Vector3.new(70,4,-95)}) do lily(p,.7) end

-- Reeds at the outer perimeter only.
for g=1,20 do local a=(g-1)/20*math.pi*2;local cx=math.cos(a)*170;local cz=math.sin(a)*140;for j=1,5 do local h=4+(j%3);cyl("Reed",.14,h,Vector3.new(cx+(j-3)*1.2,5+h/2,cz+(j%2)*.8),C.reed,decor,Enum.Material.Grass,false)end end

-- Fish are spread through the actual water.
local fishData={}
local fishCenters={Vector3.new(-135,-1,-45),Vector3.new(-100,-2,-105),Vector3.new(-40,-1,-125),Vector3.new(40,-2,-125),Vector3.new(100,-1,-105),Vector3.new(135,-2,-45),Vector3.new(-145,-1,20),Vector3.new(145,-2,20),Vector3.new(-135,-1,70),Vector3.new(135,-2,70),Vector3.new(-80,-1,115),Vector3.new(-25,-2,130),Vector3.new(25,-1,130),Vector3.new(80,-2,115),Vector3.new(-165,-1,-105),Vector3.new(165,-2,-105),Vector3.new(-165,-1,105),Vector3.new(165,-2,105)}
for i,pos in ipairs(fishCenters) do local m=Instance.new("Model",fishFolder);m.Name="Fish_"..i;ball("Body",Vector3.new(4,1.5,2.3),pos,C.fish,m,nil,false);part("Tail",Vector3.new(.4,1.8,2.3),CFrame.new(pos+Vector3.new(-2,0,0)),Enum.Material.SmoothPlastic,C.fish2,m,Enum.PartType.Wedge,false);ball("Eye",Vector3.new(.3,.3,.3),pos+Vector3.new(1.2,.45,-.7),Color3.fromRGB(15,15,15),m,nil,false);fishData[#fishData+1]={m=m,cx=pos.X,cz=pos.Z,y=pos.Y,r=10+(i%4)*4,phase=i*.7,s=.16+(i%5)*.025}end

-- Each player starts in their own base, not in the island center.
local assigned={}
local function freeBase()for i=1,6 do if not assigned[i] then return i end end end
local function assign(p)local i=freeBase();if not i then return end;assigned[i]=p;p:SetAttribute("BaseIndex",i);p.RespawnLocation=baseSpawns[i] end
Players.PlayerAdded:Connect(function(p)assign(p);p.CharacterAdded:Connect(function(c)local i=p:GetAttribute("BaseIndex") or 1;local s=baseSpawns[i];if s then c:PivotTo(s.CFrame+Vector3.new(0,4,0))end end)end)
Players.PlayerRemoving:Connect(function(p)for i,v in pairs(assigned)do if v==p then assigned[i]=nil end end end)

local regions=Instance.new("Folder",world);regions.Name="GameplayRegions"
local frogSpawn=part("FrogSpawnRegion",Vector3.new(62,1,42),CFrame.new(0,22,5),Enum.Material.SmoothPlastic,Color3.fromRGB(80,180,100),regions,nil,false);frogSpawn.Transparency=1
local raceStart=part("RaceStart",Vector3.new(18,1,6),CFrame.new(0,22,43),Enum.Material.SmoothPlastic,Color3.fromRGB(255,225,100),regions,nil,false);raceStart.Transparency=1
local swimRegion=part("SwimRegion",Vector3.new(350,10,290),CFrame.new(0,0,0),Enum.Material.SmoothPlastic,Color3.fromRGB(50,150,180),regions,nil,false);swimRegion.Transparency=1

local petals=Instance.new("Folder",world);petals.Name="FallingSakuraPetals"
for i=1,75 do local p=part("Petal",Vector3.new(.35,.08,.5),CFrame.new(math.random(-155,155),math.random(18,45),math.random(-140,215)),Enum.Material.SmoothPlastic,C.sakura2,petals,nil,false);p:SetAttribute("phase",math.random()*12)end

world:SetAttribute("MapVersion","PondIsland_v6_ReferenceLayout");world:SetAttribute("PondSize","360x300");world:SetAttribute("WaterIsTerrain",true);world:SetAttribute("LobbySize","300x68");world:SetAttribute("MaxPlayers",6);world:SetAttribute("MaxFrogs",20);world:SetAttribute("ActiveRoundSeconds",300);world:SetAttribute("ResetSeconds",10)

local t0=os.clock();RunService.Heartbeat:Connect(function()local t=os.clock()-t0;for _,d in ipairs(fishData)do local a=t*d.s+d.phase;local x=d.cx+math.cos(a)*d.r;local z=d.cz+math.sin(a)*d.r*.72;local y=d.y+math.sin(t*1.7+d.phase)*.3;d.m:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,-a,0))end;for _,p in ipairs(petals:GetChildren())do local ph=p:GetAttribute("phase")or 0;p.Position=Vector3.new(p.Position.X+math.sin(t*.6+ph)*.012,15+((ph+t*1.5)%28),p.Position.Z+math.cos(t*.5+ph)*.01)end end)
Lighting.ClockTime=16.3;Lighting.Brightness=2.5;Lighting.EnvironmentDiffuseScale=.65;Lighting.EnvironmentSpecularScale=.4;Lighting.OutdoorAmbient=Color3.fromRGB(170,180,170)
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")or Instance.new("Atmosphere");atmosphere.Density=.2;atmosphere.Offset=.1;atmosphere.Glare=.08;atmosphere.Haze=.65;atmosphere.Parent=Lighting
print("FrogGame v6 loaded: huge swim lake + waterfront player bases + central island")
