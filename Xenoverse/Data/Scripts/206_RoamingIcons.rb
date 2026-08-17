#===============================================================================
# * Roaming Icon - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays icons on map for roaming
# pokémon.
#
#===============================================================================
#
# To this script works, put it above main. On script section PScreen_RegionMap,
# add line 'drawRoamingPosition(mapindex)' before line 
# 'if playerpos && mapindex==playerpos[0]'. For each roaming pokémon icon, put
# an image on "Graphics/Pictures/mapPokemonXXX.png" changing XXX for species
# number, where "Graphics/Pictures/mapPokemon000.png" is the default one.
#
#===============================================================================

=begin
class PokemonRegionMapScene
  def drawRoamingPosition(mapindex)
    for roamPos in $PokemonGlobal.roamPosition
      roamingData = RoamingSpecies[roamPos[0]]
      active = $game_switches[roamingData[2]] && !($PokemonGlobal.roamPokemon.size <= roamPos[0] || !$PokemonGlobal.roamPokemon[roamPos[0]])
			
			echoln "active: #{active}"
			echoln "roam data: #{roamPos[0]}"
			echoln "switch active: #{$game_switches[roamingData[2]]}"
			echoln "roam pokemon: #{$PokemonGlobal.roamPokemon}"
			echoln "roam pokemon species: #{$PokemonGlobal.roamPokemon[0].species}" if $PokemonGlobal.roamPokemon.length>=1
			echoln "roam pokemon size: #{$PokemonGlobal.roamPokemon.size}"
			echoln "active info: #{$PokemonGlobal.roamPokemon.size <= roamPos[0] || !$PokemonGlobal.roamPokemon[roamPos[0]]}"
			echoln "active info cond 1: #{$PokemonGlobal.roamPokemon.size <= roamPos[0]}"
			echoln "active info cond 2: #{!$PokemonGlobal.roamPokemon[roamPos[0]]}"
			echoln "roampos global: #{$PokemonGlobal.roamPosition}"
			echoln "cur roam pos: #{roamPos}"
      next if !active
      species=getID(PBSpecies,roamingData[0])
			echoln "species: #{species}"
      next if !species || species<=0
      pokepos = $game_map ? pbGetMetadata(roamPos[1],MetadataMapPosition) : nil
			echoln "mapindex: #{mapindex!=pokepos[0]}"
      next if mapindex!=pokepos[0]
      x = pokepos[1]
      y = pokepos[2]
      @sprites["roaming#{species}"] = IconSprite.new(0,0,@viewport)
      @sprites["roaming#{species}"].setBitmap(getRoamingIcon(species))
      @sprites["roaming#{species}"].x = -SQUAREWIDTH/2+(x*SQUAREWIDTH)+(
        Graphics.width-@sprites["map"].bitmap.width
      )/2
      @sprites["roaming#{species}"].y = -SQUAREHEIGHT/2+(y*SQUAREHEIGHT)+(
        Graphics.height-@sprites["map"].bitmap.height
      )/2
    end
  end
  
  def getRoamingIcon(species)
    return nil if !species
    fileName = sprintf("Graphics/Pictures/mapPokemon%03d", species)
    ret = pbResolveBitmap(fileName)
    if !ret
      fileName = "Graphics/Pictures/mapPokemon000"
      ret = pbResolveBitmap(fileName)
    end
    return ret
  end
end
=end
class PokemonRegionMapScene
  def drawRoamingPosition(mapindex)
    for roamPos in $PokemonGlobal.roamPosition
      roamingData = RoamingSpecies[roamPos[0]]
      active = $game_switches[roamingData[2]] && (
        $PokemonGlobal.roamPokemon.size <= roamPos[0] || 
        $PokemonGlobal.roamPokemon[roamPos[0]]!=true
      )
      next if !active
      species=getID(PBSpecies,roamingData[0])
      next if !species || species<=0
      pokepos = $game_map ? pbGetMetadata(roamPos[1],MetadataMapPosition) : nil 
      next if mapindex!=pokepos[0]
      x = pokepos[1]
      y = pokepos[2]
      @sprites["roaming#{species}"] = IconSprite.new(0,0,@viewport)
      @sprites["roaming#{species}"].setBitmap(getRoamingIcon(species))
      @sprites["roaming#{species}"].x = -SQUAREWIDTH/2+(x*SQUAREWIDTH)+(
        Graphics.width-@sprites["map"].bitmap.width
      )/2
      @sprites["roaming#{species}"].y = -SQUAREHEIGHT/2+(y*SQUAREHEIGHT)+(
        Graphics.height-@sprites["map"].bitmap.height
      )/2
    end
  end
  
  def getRoamingIcon(species)
    return nil if !species
    fileName = sprintf("Graphics/Pictures/mapPokemon%03d", species)
    ret = pbResolveBitmap(fileName)
    if !ret
      fileName = "Graphics/Pictures/mapPokemon000"
      ret = pbResolveBitmap(fileName)
    end
    return ret
  end
	
	alias __pbUpdate pbUpdate
	def pbUpdate
		if @frame == nil
			@frame = 0
		end
		@frame+=1
		@sprites["cursor"].z=2
		
    for roamer in $PokemonGlobal.roamPosition
      roamingData = RoamingSpecies[roamer[0]]
      active = $game_switches[roamingData[2]] && (
        $PokemonGlobal.roamPokemon.size <= roamer[0] || 
        $PokemonGlobal.roamPokemon[roamer[0]]!=true
      )
      next if !active
      species=getID(PBSpecies,roamingData[0])
      next if !species || species<=0
      pokepos = $game_map ? pbGetMetadata(roamer[1],MetadataMapPosition) : nil
      if @frame!=nil && @sprites.keys.include?("roaming#{species}")
        if (@frame/40).to_f == @frame.to_f/40
          @sprites["roaming#{species}"].z = @sprites["roaming#{species}"].z==0 ? 1 : 0
        end
      end
    end
			
		__pbUpdate
	end
end