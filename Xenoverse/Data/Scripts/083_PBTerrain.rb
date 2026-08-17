################################################################################
# Terrain tags
################################################################################
module PBTerrain
  Ledge           = 1
  Grass           = 2
  Sand            = 3
  Rock            = 4
  DeepWater       = 5
  StillWater      = 6
  Water           = 7
  Waterfall       = 8
  WaterfallCrest  = 9
  TallGrass       = 10
  UnderwaterGrass = 11
  Ice             = 12
  Neutral         = 13
  SootGrass       = 14
  Bridge          = 15
  Mud             = 16
  Lava            = 17
  WaterEdge       = 18
  Reflect         = 19
end


def pbNotWaterTag?(tag)
  return !(tag == PBTerrain::Water || tag == PBTerrain::StillWater)
end

def pbIsSurfableTag?(tag)
  return pbIsWaterTag?(tag)
end

def pbIsPassableLavaTag?(tag)
  return tag==PBTerrain::Lava
end

def pbIsWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::WaterfallCrest ||
         tag==PBTerrain::Waterfall
end

def pbIsWaterEdgeTag?(tag)
  return tag==PBTerrain::WaterEdge
end

def pbIsPassableWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::WaterfallCrest
end

def pbIsJustWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater
end

def pbIsGrassTag?(tag)
  return tag==PBTerrain::Grass ||
         tag==PBTerrain::TallGrass ||
         tag==PBTerrain::UnderwaterGrass
end

def pbIsJustGrassTag?(tag)
  return tag==PBTerrain::Grass
end

def pbIsMudTag?(tag)
  return tag == PBTerrain::Mud
end