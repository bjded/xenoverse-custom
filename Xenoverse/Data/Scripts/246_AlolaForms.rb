#########################################################################
# Delta Pokemon/Alolan Form code
# This is compatible with Essentials v16.2
# Also compatible with Luka's Elite Battle System (EBS),
#    Klien's BW Essentials kit,
#    and mej's Following Pokemon script
# Note that this code adds the Alolan forms as code within the game
# It does not automatically create the Alolan forms as possible
#    encounters.
# You as the game developer need to decide how you want players to
#    encounter the Alolan Pokemon.
#########################################################################
# To use
# 1.) place in a new script section below "PSystem_Utilities" but
#    above "Main"
#  - if using the EBS or Following Pokemon scripts, place below those
#      scripts as well as "PSystem_Utilities"
# 2.) Decide how you want the player to encounter Delta/Alolan Pokemon
#  - see the bottom of this script for an example that makes Alolan
#      Exeggutor appear on a certain map
#########################################################################
# Please note that the breeding mechanics for Deltaness work under the
#    assumption that your fangame will NOT be taking place in Alola.
# Likewise, the evolution mechanics for Pikachu, Cubone, and Exeggcute
#    work under the assumption that your fangame will NOT be taking
#    place in Alola, but that you DO wish the players to be able to
#    obtain Alolan Raichu, Alolan Marowak, and Alolan Exeggutor in
#    some way.
#########################################################################
ALWAYS_ANIMATED_CAN_SURF=false

WONT_INHERIT_FORM=[
  [PBSpecies::PIKACHU,1],
  [PBSpecies::PIKACHU,2]
]

# Battlers

class PokeBattle_Battler
  def isDelta?
    return (@pokemon) ? @pokemon.isDelta? : false
  end

  def isAlolan?
    return (@pokemon) ? @pokemon.isDelta? : false
  end

  def isEgg?
    return (@pokemon) ? (@pokemon.isEgg? rescue @pokemon.egg? rescue false) : false
  end

  def isAlolaForm?
    return (@pokemon) ? @pokemon.isDelta? : false
  end
	
	def isFemale?
		return self.pokemon.isFemale?
	end
	
	def isShiny?
		return self.pokemon.isShiny?
	end
end

class PokeBattle_FakeBattler
  def isDelta?; return @pokemon.isDelta?; end
  def isAlolan?; return @pokemon.isDelta?; end
  def isAlolaForm?; return @pokemon.isDelta?; end
end

# Pokemon

class PokeBattle_Pokemon
  alias ____mf_getAbilityList getAbilityList
  def getAbilityList
    v=MultipleForms.call("getAbilityList",self)
    return v if v!=nil && v.length>0
    return self.____mf_getAbilityList
  end
  
  # generates the list of Egg Moves
  def possibleEggMoves
    v=MultipleForms.call("possibleEggMoves",self)
    return v if v!=nil
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
         f.pos=(self.species-1)*8
         offset=f.fgetdw
         length=f.fgetdw
         if length>0
           bob=[]
           f.pos=offset
           i=0; loop do break unless i<length
             atk=f.fgetw
             bob.push(atk)
             i+=1
           end
           return bob
         else
           return []
         end
       }
  end
  
  alias __mf_isCompatibleWithMove? isCompatibleWithMove? # Not purged from below
  def isCompatibleWithMove?(move)
    v=MultipleForms.call("getMoveCompatibility",self)
    if v!=nil
      return v.any? {|j| j==move }
    end
    return self.__mf_isCompatibleWithMove?(move)
  end

  attr_accessor(:deltaflag)  # Forces the deltaness (true/false)

  def isDelta?
    return @deltaflag if @deltaflag != nil
        return false
  end

  def isAlolan?
    return isDelta?
  end

  def isAlolaForm?
    return isDelta?
  end
  
  def makeDelta
    @deltaflag=true
    calcStats()
  end

  def hasDelta?
    return File.exists?("Graphics/Pictures/DexNew/Icon/#{getID(PBSpecies,@species)}d.png")
  end

  # provides a fix for forms crashing game
  def spoofForm(val)
    @deltaflag = false
    @form = val
  end
end

def pbGetBabySpecies(species,item1=-1,item2=-1)
  ret=species
  #_EVOTYPEMASK=0x7F
  #_EVODATAMASK=0x80
  #_EVOPREVFORM=0x80
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVOPREVFORM=0x40
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         evo=f.fgetb
         evonib=evo&_EVOTYPEMASK
         level=f.fgetw
         poke=f.fgetw
         if poke<=PBSpecies.maxValue && (evo&_EVODATAMASK)==_EVOPREVFORM # evolved from
          incense = pbGetIncense(pbGetBabySpecies(poke,0,0))
          if (incense>0)
          #checking if any of the parents items are incenses 
           if (item1>=0 && [127,128,129,130,131,132,133,134,135].include?(item1))|| (item2>=0 && [127,128,129,130,131,132,133,134,135].include?(item2))
             #dexdata=pbOpenDexData
             #pbDexDataOffset(dexdata,poke,54)
             #incense=dexdata.fgetw
             #echoln incense
             #dexdata.close
             echoln "Incense is #{incense}"
             ret=poke if item1==incense || item2==incense
           else
            if pbGetIncense(poke)==0
              ret=poke 
            else
              ret=species
            end
           end
          else
            ret=poke
          end
           break
         end
         i+=5
       end
     end
  }
  if ret!=species
    ret=pbGetBabySpecies(ret,item1,item2)
  end
  return ret
end

USENEWBATTLEMECHANICS = true

# Breeding
def pbDayCareGenerateEgg
  if pbDayCareDeposited!=2
    return
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the egg")
  end
  pokemon0=$PokemonGlobal.daycare[0][0]
  pokemon1=$PokemonGlobal.daycare[1][0]
  mother=nil
  father=nil
  babyspecies=0
  ditto0=pbIsDitto?(pokemon0) || pbIsDittoX?(pokemon0)
  ditto1=pbIsDitto?(pokemon1) || pbIsDittoX?(pokemon1)
  if (pokemon0.isFemale? || ditto0)
    babyspecies=(ditto0) ? pokemon1.species : pokemon0.species
    mother=pokemon0
    father=pokemon1
  else
    babyspecies=(ditto1) ? pokemon0.species : pokemon1.species
    mother=pokemon1
    father=pokemon0
  end
  babyspecies=pbGetBabySpecies(babyspecies,mother.item,father.item)
  if isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies=getConst(PBSpecies,:PHIONE)
  elsif (isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)) ||
        (isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE))
    babyspecies=[getConst(PBSpecies,:NIDORANmA),
                 getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)) ||
        (isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT))
    babyspecies=[getConst(PBSpecies,:VOLBEAT),
			getConst(PBSpecies,:ILLUMISE)][rand(2)]
	elsif isConst?(babyspecies,PBSpecies,:MUNCHLAX) &&
        !isConst?(mother.item,PBItems,:FULLINCENSE) &&
        !isConst?(father.item,PBItems,:FULLINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:WYNAUT) &&
        !isConst?(mother.item,PBItems,:LAXINCENSE) &&
        !isConst?(father.item,PBItems,:LAXINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:HAPPINY) &&
        !isConst?(mother.item,PBItems,:LUCKINCENSE) &&
        !isConst?(father.item,PBItems,:LUCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:MIMEJR) &&
        !isConst?(mother.item,PBItems,:ODDINCENSE) &&
        !isConst?(father.item,PBItems,:ODDINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:CHINGLING) &&
        !isConst?(mother.item,PBItems,:PUREINCENSE) &&
        !isConst?(father.item,PBItems,:PUREINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:BONSLY) &&
        !isConst?(mother.item,PBItems,:ROCKINCENSE) &&
        !isConst?(father.item,PBItems,:ROCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:BUDEW) &&
        !isConst?(mother.item,PBItems,:ROSEINCENSE) &&
        !isConst?(father.item,PBItems,:ROSEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:AZURILL) &&
        !isConst?(mother.item,PBItems,:SEAINCENSE) &&
        !isConst?(father.item,PBItems,:SEAINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:MANTYKE) &&
        !isConst?(mother.item,PBItems,:WAVEINCENSE) &&
        !isConst?(father.item,PBItems,:WAVEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  end
  # Generate egg
  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,$Trainer)
  # Randomise personal ID
  pid=rand(65536)
  pid|=(rand(65536)<<16)
  egg.personalID=pid
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) ||
     isConst?(babyspecies,PBSpecies,:SHELLOS) ||
     isConst?(babyspecies,PBSpecies,:BASCULIN) ||
     isConst?(babyspecies,PBSpecies,:MINIOR) ||
     isConst?(babyspecies,PBSpecies,:ORICORIO) ||
     (isConst?(mother.item,PBItems,:EVERSTONE) || isConst?(father.item,PBItems,:EVERSTONE))
     if (!WONT_INHERIT_FORM.include?([mother.species,mother.form]))
      egg.form=mother.form
     end
  end
  
  # Inheriting Delta-ness
  if (mother.isDelta? && isConst?(mother.item,PBItems,:EVERSTONE)) ||
     (mother.isDelta? && isConst?(mother.item,PBItems,:STRANGESOUVENIR)) ||
	 (father.isDelta? && isConst?(father.item,PBItems,:EVERSTONE)) ||
     (father.isDelta? && isConst?(father.item,PBItems,:STRANGESOUVENIR))
    egg.makeDelta
  end
  # Inheriting Moves
  moves=[]
  othermoves=[] 
  movefather=father; movemother=mother
  if pbIsDitto?(movefather) && !mother.isFemale?
    movefather=mother; movemother=father
  end
  # Initial Moves
  initialmoves=egg.getMoveList
  moop=egg.possibleEggMoves
  for k in initialmoves
    if k[0]<=EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if mother.knowsMove?(k[1]) && father.knowsMove?(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # TODOMAYBE
  #############################
  # Inheriting Machine Moves
  if !USENEWBATTLEMECHANICS
    for i in 0...$ItemData.length
      next if !$ItemData[i]
      atk=$ItemData[i][ITEMMACHINE]
      next if !atk || atk==0
      if egg.isCompatibleWithMove?(atk)
        moves.push(atk) if movefather.knowsMove?(atk)
      end
    end
  end
  #############################
  # Inheriting Egg Moves
  if moop.length>0 && movefather.isMale?
    for i in moop
      moves.push(i) if movefather.knowsMove?(i)
    end
  end
  ########################
  if USENEWBATTLEMECHANICS && moop.length>0 && movemother.isFemale?
    for i in moop
      moves.push(i) if movemother.knowsMove?(i)
    end
  end
  ########################
  # Volt Tackle
  lightball=false
  if (isConst?(father.species,PBSpecies,:PIKACHU) || 
      isConst?(father.species,PBSpecies,:RAICHU)) && 
      isConst?(father.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if (isConst?(mother.species,PBSpecies,:PIKACHU) || 
      isConst?(mother.species,PBSpecies,:RAICHU)) && 
      isConst?(mother.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  moves|=[] # remove duplicates
  # Assembling move list
  finalmoves=[]
  listend=moves.length-4
  listend=0 if listend<0
  j=0
  for i in listend..listend+3
    moveid=(i>=moves.length) ? 0 : moves[i]
    finalmoves[j]=PBMove.new(moveid)
    j+=1
  end 
  # Inheriting Individual Values
  ivs=[]
  for i in 0...6
    ivs[i]=rand(32)
  end
  ivinherit=[]
  for i in 0...2
    parent=[mother,father][i]
    ivinherit[i]=PBStats::HP if isConst?(parent.item,PBItems,:POWERWEIGHT)
    ivinherit[i]=PBStats::ATTACK if isConst?(parent.item,PBItems,:POWERBRACER)
    ivinherit[i]=PBStats::DEFENSE if isConst?(parent.item,PBItems,:POWERBELT)
    ivinherit[i]=PBStats::SPEED if isConst?(parent.item,PBItems,:POWERANKLET)
    ivinherit[i]=PBStats::SPATK if isConst?(parent.item,PBItems,:POWERLENS)
    ivinherit[i]=PBStats::SPDEF if isConst?(parent.item,PBItems,:POWERBAND)
  end
  num=0; r=rand(2)
  for i in 0...2
    if ivinherit[r]!=nil
      parent=[mother,father][r]
      ivs[ivinherit[r]]=parent.iv[ivinherit[r]]
      num+=1
      break
    end
    r=(r+1)%2
  end
  stats=[PBStats::HP,PBStats::ATTACK,PBStats::DEFENSE,
         PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
  limit=(USENEWBATTLEMECHANICS && (isConst?(mother.item,PBItems,:DESTINYKNOT) ||
         isConst?(father.item,PBItems,:DESTINYKNOT))) ? 5 : 3
  loop do
    freestats=[]
    for i in stats
      freestats.push(i) if !ivinherit.include?(i)
    end
    break if freestats.length==0
    r=freestats[rand(freestats.length)]
    parent=[mother,father][rand(2)]
    ivs[r]=parent.iv[r]
    ivinherit.push(r)
    num+=1
    break if num>=limit
  end
  # Inheriting nature
  newnatures=[]
  newnatures.push(mother.nature) if isConst?(mother.item,PBItems,:EVERSTONE)
  newnatures.push(father.nature) if isConst?(father.item,PBItems,:EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # The initial PID above is the first natural shiny roll. Match wild
  # Pokemon's shiny rate and give the Shiny Charm its extra retry.
  if hasConst?(PBItems,:SHINYCHARM) &&
     $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
    for i in 0...1
      break if egg.isShiny?
      egg.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
  if (!ditto0 && !ditto1)
    if mother.hasHiddenAbility?
      egg.setAbility(mother.abilityIndex) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex)
      else
        egg.setAbility((mother.abilityIndex+1)%2)
      end
    end
  elsif ((!ditto0 && ditto1) || (!ditto1 && ditto0)) && USENEWBATTLEMECHANICS
    parent=(!ditto0) ? mother : father
    if parent.hasHiddenAbility?
      egg.setAbility(parent.abilityIndex) if rand(10)<6
    end
  end
  # Inheriting Poké Ball from the mother
  if mother.isFemale? &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:MASTERBALL) &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:CHERISHBALL)
    egg.ballused=mother.ballused
  end
  egg.iv[0]=ivs[0]
  egg.iv[1]=ivs[1]
  egg.iv[2]=ivs[2]
  egg.iv[3]=ivs[3]
  egg.iv[4]=ivs[4]
  egg.iv[5]=ivs[5]
  egg.moves[0]=finalmoves[0]
  egg.moves[1]=finalmoves[1]
  egg.moves[2]=finalmoves[2]
  egg.moves[3]=finalmoves[3]
  egg.calcStats
  egg.obtainText=_INTL("Day-Care Couple")
  egg.name=_INTL("Egg")
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,babyspecies,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  egg.eggsteps=eggsteps
  if rand(65536)<POKERUSCHANCE
    egg.givePokerus
  end
  $Trainer.party[$Trainer.party.length]=egg
end

##############################################################
# Appearance change
##############################################################
class PokemonSprite < SpriteWrapper
  def setSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,back=false,egg=false,delta=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=species>0 ? pbLoadSpeciesBitmap(species,female,form,shiny,shadow,back,egg,delta) : nil
    self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
  end
end

class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @nicknamed=false
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundOrColoredPlane(@sprites,"background","hatchbg",
      Color.new(248,248,248),@viewport)
    @sprites["dark"] =Sprite.new(@viewport)
		@sprites["dark"].bitmap = Bitmap.new(512,384)
		@sprites["dark"].bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
		@sprites["bg"]=GifAnim.new(0,0,@viewport,true)
		@sprites["bg"].setBitmap("Graphics/Pictures/hatchbg2")
		@sprites["bg"].y=DEFAULTSCREENHEIGHT/2
		@sprites["bg"].zoom_x = 0.5
		@sprites["bg"].zoom_y = 0.5
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setSpeciesBitmap(@pokemon.species,@pokemon.isFemale?,
                                        (@pokemon.form rescue 0),@pokemon.isShiny?,
                                        false,false,true,(@pokemon.isDelta? rescue false)) # Egg sprite
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=48+(Graphics.height-@sprites["pokemon"].bitmap.height)/2
    @sprites["hatch"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    pbFadeInAndShow(@sprites)
  end
end

def pbLoadPokemonBitmap(pokemon, back=false, scale=nil)
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back,scale)
end

# Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadPokemonBitmapSpecies(pokemon, species, back=false, scale=nil)
  ret=nil
  if scale==nil
    scale=1
    if defined?(POKEMONSPRITESCALE)
      scale=POKEMONSPRITESCALE if POKEMONSPRITESCALE != nil
    end
  end
  if pokemon.isEgg?
    bitmapFileName=sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Battlers/%03degg",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Battlers/egg")
      end
    end
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=pbCheckPokemonBitmapFiles([species,back,
                                              (pokemon.isFemale?),
                                              pokemon.isShiny?,
                                              (pokemon.form rescue 0),
                                              (pokemon.isShadow? rescue false),
																							(pokemon.isDelta? rescue false),
																							(pokemon.busted rescue false)]) #used for mimikyu
    # Alter bitmap if supported
    alterBitmap=(MultipleForms.getFunction(species,"alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap=AnimatedBitmap.new(bitmapFileName)
    copiedBitmap=animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each {|bitmap|
      alterBitmap.call(pokemon,bitmap)
    }
    ret=copiedBitmap
    if defined?(DynamicPokemonSprite) # if EBS code exists
      animatedBitmap=AnimatedBitmapWrapper.new(bitmapFileName,scale)
      animatedBitmap.prepareStrip
      for i in 0...animatedBitmap.totalFrames
        alterBitmap.call(pokemon,animatedBitmap.alterBitmap(i))
      end
      animatedBitmap.compileStrip
      ret=animatedBitmap
    end
  elsif bitmapFileName
    ret=AnimatedBitmap.new(bitmapFileName)
    ret=AnimatedBitmapWrapper.new(bitmapFileName,scale) if defined?(DynamicPokemonSprite) # if EBS code exists
  end
  return ret
end

# Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,back=false,egg=false,delta=false,busted=false)
  ret=nil
  if egg
    bitmapFileName=sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Battlers/%03degg",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Battlers/egg")
      end
    end
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow,delta,busted])
  end
  if bitmapFileName
    ret=AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

def pbCheckPokemonBitmapFiles(params)
  species=params[0]
  back=params[1]
  factors=[]
  factors.push([5,params[5],false]) if params[5] && params[5]!=false    # shadow
	factors.push([7,params[7],false]) if params[7] && params[7]!=false		# busted
  factors.push([2,params[2],false]) if params[2] && params[2]!=false    # gender
  factors.push([3,params[3],false]) if params[3] && params[3]!=false    # shiny
  factors.push([4,params[4].to_s,""]) if params[4] && params[4].to_s!="" &&
                                                      params[4].to_s!="0" # form
  factors.push([6,params[6],false]) if params[6] && params[6]!=false    # shiny
  tshadow=false
  tgender=false
  tshiny=false
  tdelta=false
	tbust=false
	echoln "is busted sprite #{params[7]}"
  tform=""
  for i in 0...2**factors.length
    for j in 0...factors.length
      case factors[j][0]
      when 2  # gender
        tgender=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 3  # shiny
        tshiny=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 4  # form
        tform=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 5  # shadow
        tshadow=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 6  # delta
        tdelta=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
			when 7  # busted
				tbust=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      end
    end
    folder=""
    folder="Front/"
    folder="Back/" if back
    folder="FrontShiny/" if tshiny
    folder="BackShiny/" if back && tshiny
    folder+="Female/" if tgender
		
		bitmapFileName = sprintf("Graphics/Battlers/%s%03d%s%s%s",
			folder,
			species,
			tdelta ? "d" : "",
			tbust ? "b" : "",
			(tform != "" ? "_" + tform : "")) rescue nil
		echoln bitmapFileName
		ret=pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  return nil
end

def pbPokemonIconFile(pokemon)
  bitmapFileName=nil
  bitmapFileName=pbCheckPokemonIconFiles([pokemon.species,
                                          (pokemon.isFemale?),
                                          pokemon.isShiny?,
                                          (pokemon.form rescue 0),
                                          (pokemon.isShadow? rescue false),
                                          pokemon.isDelta?],
                                          pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(params,egg=false)
  species=params[0]
  if egg
    bitmapFileName=sprintf("Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Icons/icon%03degg",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Icons/iconEgg")
      end
    end
    return pbResolveBitmap(bitmapFileName)
  else
    factors=[]
    factors.push([4,params[4],false]) if params[4] && params[4]!=false    # shadow
    factors.push([1,params[1],false]) if params[1] && params[1]!=false    # gender
    factors.push([2,params[2],false]) if params[2] && params[2]!=false    # shiny
    factors.push([5,params[5],false]) if params[5] && params[5]!=false    # delta
    factors.push([3,params[3].to_s,""]) if params[3] && params[3].to_s!="" &&
                                                        params[3].to_s!="0" # form
    tshadow=false
    tgender=false
    tshiny=false
    tdelta=false
    tform=""
    for i in 0...2**factors.length
      for j in 0...factors.length
        case factors[j][0]
        when 1  # gender
          tgender=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        when 2  # shiny
          tshiny=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        when 3  # form
          tform=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        when 4  # shadow
          tshadow=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        when 5  # delta
          tdelta=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        end
      end
      bitmapFileName=sprintf("Graphics/Icons/icon%s%s%s%s%s%s",
        getConstantName(PBSpecies,species),
        tgender ? "f" : "",
        tshiny ? "s" : "",
        tdelta ? "d" : "",
        (tform!="" ? "_"+tform : ""),
        tshadow ? "_shadow" : "") rescue nil
      ret=pbResolveBitmap(bitmapFileName)
      return ret if ret
      bitmapFileName=sprintf("Graphics/Icons/icon%03d%s%s%s%s%s",
        species,
        tgender ? "f" : "",
        tshiny ? "s" : "",
        tdelta ? "d" : "",
        (tform!="" ? "_"+tform : ""),
        tshadow ? "_shadow" : "")
      ret=pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end

#########################################################################
# Following Pokemon compatibility
#########################################################################
class DependentEvents
  def change_sprite(id, shiny=nil, animation=nil, form=nil, gender=nil, shadow=false, delta=nil)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
        file=FOLLOWER_FILE_DIR+pbCheckPokemonFollowerFiles([id,gender,shiny,delta,form,shadow])
        events[i][6]=file
        @realEvents[i].character_name=file
        if animation
          $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
        end
        $game_variables[Walking_Time_Variable]=0
      end
    end
  end

  def refresh_sprite(animation=true)
    if $game_variables[Current_Following_Variable]!=0
      return unless $game_switches[Toggle_Following_Switch]
      return if $PokemonGlobal.bicycle
      if $Trainer.party[0].isShiny?
        shiny=true
      else
        shiny=false
      end
      if defined?($Trainer.party[0].isDelta?)
        delta = $Trainer.party[0].isDelta?
      else
        delta = false
      end
      if $Trainer.party[0].form>0
        form=$Trainer.party[0].form
      else
        form=nil
      end
      if defined?($Trainer.party[0].isShadow?)
        shadow = $Trainer.party[0].isShadow?
      else
        shadow = false
      end
      if $PokemonGlobal.surfing
        if $Trainer.party[0].hp>0 && !$Trainer.party[0].isEgg? && $Trainer.party[0].hasType?(:WATER)
          events=$PokemonGlobal.dependentEvents
          if animation
            for i in 0...events.length
              $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
              pbWait(10)
            end
          end
          change_sprite($Trainer.party[0].species, shiny, false, form, $Trainer.party[0].gender, shadow, delta)
        elsif ALWAYS_ANIMATED_CAN_SURF && ($Trainer.party[0].hasType?(:FLYING) ||
          isConst?($Trainer.party[0].ability,PBAbilities,:LEVITATE) ||
          ALWAYS_ANIMATED_FOLLOWERS.include?($Trainer.party[0].species)) &&
          !(ALWAYS_ANIMATED_EXCEPTION.include?($Trainer.party[0].species)) &&
          $Trainer.party[0].hp>0 && !$Trainer.party[0].isEgg?
          events=$PokemonGlobal.dependentEvents
          if animation
            for i in 0...events.length
              $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
              pbWait(10)
            end
          end
          change_sprite($Trainer.party[0].species, shiny, false, form, $Trainer.party[0].gender, shadow, delta)
        else
          remove_sprite(false)
        end
      elsif $PokemonGlobal.diving
        if $Trainer.party[0].hp>0 && !$Trainer.party[0].isEgg? && $Trainer.party[0].hasType?(:WATER) && WATERPOKEMONCANDIVE
          events=$PokemonGlobal.dependentEvents
          if animation
            for i in 0...events.length
              $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
              pbWait(10)
            end
          end
          change_sprite($Trainer.party[0].species, shiny, false, form, $Trainer.party[0].gender, shadow, delta)
        else
          remove_sprite(false)
        end
      else
        if $Trainer.party[0].hp>0 && !$Trainer.party[0].isEgg? && $scene.is_a?(Scene_Map)
          events=$PokemonGlobal.dependentEvents
          if animation
            for i in 0...events.length
              $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
              pbWait(10)
            end
          end
          change_sprite($Trainer.party[0].species, shiny, false, form, $Trainer.party[0].gender, shadow, delta)
        elsif $Trainer.party[0].hp<=0 || $Trainer.party[0].isEgg?
          remove_sprite(animation)
        end
      end
    else
      check_faint
    end
  end

  def Come_back(shiny=nil, animation=nil, delta=nil)
    return if !$game_variables[Following_Activated_Switch]
    return if $Trainer.party.length==0
    $PokemonTemp.dependentEvents.pbMoveDependentEvents
    events=$PokemonGlobal.dependentEvents
    if $game_variables[Current_Following_Variable]==$Trainer.party[0]
      remove_sprite(false)
      if $scene.is_a?(Scene_Map)
        for i in 0...events.length
          $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
        end
      end
    end
    if $Trainer.party[0].hp>0 && !$Trainer.party[0].isEgg?
      $game_variables[Current_Following_Variable]=$Trainer.party[0]
      refresh_sprite(animation)
    end
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
        file=FOLLOWER_FILE_DIR+pbCheckPokemonFollowerFiles([id,gender,shiny,delta,form,shadow])
        events[i][6]=file
        @realEvents[i].character_name=file
        if animation
          $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
        end
      end
    end
  end
end

# this is an entirely new function, not found in the official release of Following Pokemon
# it searches for Follower sprites the same way base Essentials searches for battlers and icons
# rather than a series of "if-than" events
def pbCheckPokemonFollowerFiles(params)
  species=params[0]
  factors=[]
  factors.push([1,params[1],false]) if params[1] && params[1]!=false    # gender
  factors.push([2,params[2],false]) if params[2] && params[2]!=false    # shiny
  factors.push([3,params[3],false]) if params[3] && params[3]!=false    # delta
  factors.push([4,params[4].to_s,""]) if params[4] && params[4].to_s!="" # form
  factors.push([5,params[5],false]) if params[5] && params[5]!=false    # shadow
  tshadow=false
  tgender=false
  tshiny=false
  tdelta=false
  tform=""
  for i in 0...2**factors.length
    for j in 0...factors.length
      case factors[j][0]
      when 1  # gender
        tgender=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 2  # shiny
        tshiny=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 3  # delta
        tdelta=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 4  # form
        tform=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 5  # shadow
        tshadow=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      end
    end
    bitmapFileName=sprintf("%s%s%s%s%s%s",
      getConstantName(PBSpecies,species),
      tgender ? "f" : "",
      tshiny ? "s" : "",
      tdelta ? "d" : "",
      (tform!="" ? "_"+tform : ""),
      tshadow ? "_shadow" : "") rescue nil
    ret=pbResolveBitmap(sprintf("%s%s%s",FOLLOWER_FILE_PATH,FOLLOWER_FILE_DIR,bitmapFileName))
    return bitmapFileName if ret
    bitmapFileName=sprintf("%03d%s%s%s%s%s",
      species,
      tgender ? "f" : "",
      tshiny ? "s" : "",
      tdelta ? "d" : "",
      (tform!="" ? "_"+tform : ""),
      tshadow ? "_shadow" : "")
    ret=pbResolveBitmap(sprintf("%s%s%s",FOLLOWER_FILE_PATH,FOLLOWER_FILE_DIR,bitmapFileName))
    return bitmapFileName if ret
  end
end

##############################################################
# Hybrid AnimatedBitmapWrapper class to encompass both the
#    EBS version's inputs and the BW version's ones
##############################################################
class AnimatedBitmapWrapper
  attr_reader :width
  attr_reader :height
  attr_reader :totalFrames
  attr_reader :animationFrames
  attr_reader :currentIndex
  attr_accessor :scale
  attr_accessor :bitmapFile

  def initialize(file,twoframe_scale=2)
    raise "filename is nil" if file==nil
    if scale.is_a?(Numeric) # EBS version
      @scale = twoframe_scale
      @twoframe = false
    elsif !!scale == scale # BW version
      @scale = 2
      @twoframe = twoframe_scale
    end
    if @scale==nil
      @scale=2
    end
    @width = 0
    @height = 0
    @frame = 0
    @frames = 2
    @direction = +1
    @animationFinish = false
    @totalFrames = 0
    @currentIndex = 0
    @speed = 1
      # 0 - not moving at all
      # 1 - normal speed
      # 2 - medium speed
      # 3 - slow speed
    begin
    #bmp = pbBitmap(file)#BitmapCache.load_bitmap(file)
		ensure
    #bmp = Bitmap.new(file)
    @bitmapFile=pbBitmap(file)#Bitmap.new(bmp.width,bmp.height)
		end
    #@bitmapFile.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
    # initializes full Pokemon bitmap
    @bitmap=pbBitmap(file)#Bitmap.new(@bitmapFile.width,@bitmapFile.height)
    #@bitmap.blt(0,0,@bitmapFile,Rect.new(0,0,@bitmapFile.width,@bitmapFile.height))
    @width=@bitmapFile.height*@scale
    @height=@bitmap.height*@scale

    @totalFrames=@bitmap.width/@bitmap.height
    @animationFrames=@totalFrames*@frames
    # calculates total number of frames
    @loop_points=[0,@totalFrames]
    # first value is start, second is end

    @actualBitmap=Bitmap.new(@width,@height)
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
  alias initialize_elite initialize

  def length; @totalFrames; end
  def disposed?; @actualBitmap.disposed?; end
  def dispose; @actualBitmap.dispose; end
  def copy; @actualBitmap.clone; end
  def bitmap; @actualBitmap; end
  def bitmap=(val); @actualBitmap=val; end
  def each; end
  def alterBitmap(index); return @strip[index]; end

  def prepareStrip
    @strip=[]
    for i in 0...@totalFrames
      bitmap=Bitmap.new(@width,@height)
      bitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmapFile,Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale))
      @strip.push(bitmap)
    end
  end
  def compileStrip
    @bitmap.clear
    for i in 0...@strip.length
      @bitmap.stretch_blt(Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale),@strip[i],Rect.new(0,0,@width,@height))
    end
  end

  def reverse
    if @direction  >  0
      @direction=-1
    elsif @direction < 0
      @direction=+1
    end
  end

  def setLoop(start, finish)
    @loop_points=[start,finish]
  end

  def setSpeed(value)
    @speed=value
  end

  def toFrame(frame)
    if frame.is_a?(String)
      if frame=="last"
        frame=@totalFrames-1
      else
        frame=0
      end
    end
    frame=@totalFrames if frame > @totalFrames
    frame=0 if frame < 0
    @currentIndex=frame
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end

  def play
    return if @currentIndex >= @loop_points[1]-1
    self.update
  end

  def finished?
    return (@currentIndex==@totalFrames-1)
  end

  def update
    return false if @actualBitmap.disposed?
    return false if @speed < 1
    case @speed
    # frame skip
    when 1
      @frames=2
    when 2
      @frames=4
    when 3
      @frames=5
    when 4 
      @frames=3
    end
    @frame+=1

    if @frame >=@frames
      # processes animation speed
      @currentIndex+=@direction
      @currentIndex=@loop_points[0] if @currentIndex >=@loop_points[1]
      @currentIndex=@loop_points[1]-1 if @currentIndex < @loop_points[0]
      @frame=0
    end
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
    yield @actualBitmap, @currentIndex, @scale if block_given?
    # updates the actual bitmap
  end
  alias update_elite update

  # returns bitmap to original state
  def deanimate
    @frame=0
    @currentIndex=0
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
end

##############################################################
# Evolution differences
##############################################################
def pbGetEvolvedFormData(species,delta=false)
  ret=[]
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  _EVONEXTFORM=0x00
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         evo=f.fgetb
         evonib=evo&_EVOTYPEMASK
         level=f.fgetw
         poke=f.fgetw
         if (evo&_EVODATAMASK)==_EVONEXTFORM
           ret.push([evonib,level,poke])
         end
         i+=5
       end
     end
  }
  if delta
    ret[0][0]=27 if isConst?(species,PBSpecies,:RATTATA) # Alolan Rattata only evolves at night
    ret[0][0]=1 if isConst?(species,PBSpecies,:MEOWTHELDIW) # Alolan Meowth evolves via friendship
    # Alolan Vulpix and Alolan Sandshrew evolve via the Ice Stone if it exists
		ret[0][0]=7 if isConst?(species,PBSpecies,:VULPIX)
    ret[0][1]=781 if isConst?(species,PBSpecies,:VULPIX)# && getConst(PBItems,:ICESTONE)!=nil
    ret[0][0]=7 if isConst?(species,PBSpecies,:SANDSHREW) && getConst(PBItems,:ICESTONE)!=nil
    ret[0][1]=781 if isConst?(species,PBSpecies,:SANDSHREW)#getConst(PBItems,:ICESTONE) if isConst?(species,PBSpecies,:SANDSHREW) && getConst(PBItems,:ICESTONE)!=nil
  end
  return ret
end

def pbCheckEvolutionEx(pokemon)
  rushnoevo=[:BLINGRIMM, :PEPEQUENO, :SCOVILE, :EXCALIBOULD, :PECKABONE,:BIDOOF]
  for species in rushnoevo
    return -1 if isConst?(pokemon.species,PBSpecies,species) && pokemon.form>0
  end
  return -1 if pokemon.species<=0 || pokemon.isEgg?
  return -1 if isConst?(pokemon.species,PBSpecies,:PICHU) && pokemon.form==1
  return -1 if isConst?(pokemon.item,PBItems,:EVERSTONE) &&
               !isConst?(pokemon.species,PBSpecies,:KADABRA)
  
  ret = -1
  echoln pbGetEvolvedFormData(pokemon.species)
  if pokemon.form > 0 && EXPLICIT_FORM_EVOLUTIONS.has_key?([pokemon.species,pokemon.form])
    res = pbCheckFormEvolution(pokemon) {|pokemon,form1,form2,form3| yield pokemon,form1,form2,form3} 
    ret = res[0]
    return ret if res[1] != -1
  end

  for form in pbGetEvolvedFormData(pokemon.species,pokemon.isDelta?)
		echoln "check #{form}"
    ret = yield pokemon,form[0],form[1],form[2]
		echoln "check #{ret}"
    break if ret>0
  end
  return ret
end

# Pikachu, Cubone (at night), and Exeggcute holding the Strange Souvenir
#    will evolve into Alolan Raichu, Alolan Marowak, and Alolan Exeggutor
#    respectively.  (The item will not be consumed.)
# Remove this function if you wish this not to be the case.
=begin
class PokemonEvolutionScene
  def pbStartScreen(pokemon,newspecies)
    @sprites={}
    @bgviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z=99999
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @msgviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @msgviewport.z=99999
    @pokemon=pokemon
    @newspecies=newspecies
    addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
       Color.new(248,248,248),@bgviewport)
    rsprite1=PokemonSprite.new(@viewport)
    rsprite2=PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon,false)
    if isConst?(pokemon.item,PBItems,:STRANGESOUVENIR)
      if (isConst?(@newspecies,PBSpecies,:MAROWAK) && PBDayNight.isNight?) ||
          isConst?(@newspecies,PBSpecies,:RAICHU) ||
          isConst?(@newspecies,PBSpecies,:EXEGGUTOR)
        @pokemon.makeDelta
      end
    end
    rsprite2.setPokemonBitmapSpecies(@pokemon,@newspecies,false)
    rsprite1.ox=rsprite1.bitmap.width/2
    rsprite1.oy=rsprite1.bitmap.height/2
    rsprite2.ox=rsprite2.bitmap.width/2
    rsprite2.oy=rsprite2.bitmap.height/2
    rsprite1.x=Graphics.width/2
    rsprite1.y=(Graphics.height-64)/2
    rsprite2.x=rsprite1.x
    rsprite2.y=rsprite1.y
    rsprite2.opacity=0
    @sprites["rsprite1"]=rsprite1
    @sprites["rsprite2"]=rsprite2
    pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@msgviewport)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end
=end
##############################################################
# Alolan Form differences
##############################################################
MultipleForms.register(:RATTATA,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:GLUTTONY),0],
          [getID(PBAbilities,:HUSTLE),1],
          [getID(PBAbilities,:THICKFAT),2]]
  end
  next
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:ICEBEAM,
             :BLIZZARD,:PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,
             :SHADOWBALL,:DOUBLETEAM,:SLUDGEBOMB,:TORMENT,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:QUASH,
             :EMBARGO,:SHADOWCLAW,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
             :UTURN,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:COUNTER,:FINALGAMBIT,:FURYSWIPES,:MEFIRST,:REVENGE,
             :REVERSAL,:SNATCH,:STOCKPILE,:SWALLOW,:SWITCHEROO,
             :UPROAR]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:RATICATE,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 25.5 if pokemon.isDelta?
  next
},
"getBaseStats"=>proc{|pokemon|
   next [75,71,70,77,40,80] if pokemon.isDelta?
   next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:GLUTTONY),0],
          [getID(PBAbilities,:HUSTLE),1],
          [getID(PBAbilities,:THICKFAT),2]]
  end
  next
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:ICEBEAM,
             :BLIZZARD,:PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,
             :SHADOWBALL,:DOUBLETEAM,:SLUDGEBOMB,:TORMENT,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:QUASH,
             :EMBARGO,:SHADOWCLAW,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
             :UTURN,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE,
             :ROAR,:BULKUP,:VENOSHOCK,:SUNNYDAY,:HYPERBEAM,
             :SLUDGEWAVE,:GIGAIMPACT,:SWORDSDANCE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:RAICHU,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:PSYCHIC) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 0.7 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 21.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:SURGESURFER),0],
          [getID(PBAbilities,:SURGESURFER),2]]
  end
  next
},
"getBaseStats"=>proc{|pokemon|
   next [60,85,50,110,95,85] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[]
   movelist=[[1,:PSYCHIC],[1,:SPEEDSWAP],[1,:THUNDERSHOCK],
             [1,:TAILWHIP],[1,:QUICKATTACK],[1,:THUNDERBOLT]]
   for i in movelist
     i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :PSYSHOCK,:CALMMIND,:TOXIC,:HIDDENPOWER,:HYPERBEAM,
             :LIGHTSCREEN,:PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,
             :THUNDERBOLT,:THUNDER,:RETURN,:PSYCHIC,:BRICKBREAK,
             :DOUBLETEAM,:REFLECT,:FACADE,:REST,:ATTRACT,
             :THIEF,:ROUND,:ECHOEDVOICE,:FOCUSBLAST,:FLING,
             :CHARGEBEAM,:GIGAIMPACT,:VOLTSWITCH,:THUNDERWAVE,
             :GRASSKNOT,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,
             :WILDCHARGE,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:SANDSHREW,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:ICE) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:STEEL) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 0.6 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 40.0 if pokemon.isDelta?
  next
},
"getBaseStats"=>proc{|pokemon|
   next [50,75,90,40,10,35] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:SCRATCH],[1,:DEFENSECURL],[3,:BIDE],[5,:POWDERSNOW],
              [7,:ICEBALL],[9,:RAPIDSPIN],[11,:FURYCUTTER],[14,:METALCLAW],
              [17,:SWIFT],[20,:FURYSWIPES],[23,:IRONDEFENSE],[26,:SLASH],
              [30,:IRONHEAD],[34,:GYROBALL],[38,:SWORDSDANCE],[42,:HAIL],
              [46,:BLIZZARD]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,
             :BLIZZARD,:PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,
             :RETURN,:LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,
             :FACADE,:REST,:ATTRACT,:THIEF,:ROUND,
             :FLING,:SHADOWCLAW,:AURORAVEIL,:GYROBALL,:SWORDSDANCE,
             :BULLDOZE,:FROSTBREATH,:ROCKSLIDE,:XSCISSOR,
             :POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,
             :CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) #if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:AMNESIA,:CHIPAWAY,:COUNTER,:CRUSHCLAW,:CURSE,
             :ENDURE,:FLAIL,:ICICLECRASH,:ICICLESPEAR,:METALCLAW,
             :NIGHTSLASH]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:SNOWCLOAK),0]] if getID(PBAbilities,:SLUSHRUSH)==nil
    next [[getID(PBAbilities,:SNOWCLOAK),0],
          [getID(PBAbilities,:SLUSHRUSH),2]]
  end
  next
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:SANDSLASH,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:ICE) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:STEEL) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 1.2 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 55.0 if pokemon.isDelta?
  next
},
"getBaseStats"=>proc{|pokemon|
   next [75,100,120,65,25,65] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:ICICLESPEAR],[1,:METALBURST],[1,:ICICLECRASH],[1,:SLASH],
              [1,:DEFENSECURL],[1,:ICEBALL],[1,:METALCLAW]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,
             :BLIZZARD,:PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,
             :RETURN,:LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,
             :FACADE,:REST,:ATTRACT,:THIEF,:ROUND,
             :FLING,:SHADOWCLAW,:AURORAVEIL,:GYROBALL,:SWORDSDANCE,
             :BULLDOZE,:FROSTBREATH,:ROCKSLIDE,:XSCISSOR,
             :POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,
             :CONFIDE,:HYPERBEAM,:FOCUSBLAST,:GIGAIMPACT]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:SNOWCLOAK),0]] if getID(PBAbilities,:SLUSHRUSH)==nil
    next [[getID(PBAbilities,:SNOWCLOAK),0],
          [getID(PBAbilities,:SLUSHRUSH),2]]
  end
  next
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:VULPIX,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:ICE) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:ICE) if pokemon.isDelta?
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:POWDERSNOW],[4,:TAILWHIP],[7,:ROAR],[9,:BABYDOLLEYES],
              [10,:ICESHARD],[12,:CONFUSERAY],[15,:ICYWIND],
              [18,:PAYBACK],[20,:MIST],[23,:FEINTATTACK],[26,:HEX],
              [28,:AURORABEAM],[31,:EXTRASENSORY],[34,:SAFEGUARD],
              [36,:ICEBEAM],[39,:IMPRISON],[42,:BLIZZARD],[44,:GRUDGE],
              [47,:CAPTIVATE],[50,:SHEERCOLD]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :ROAR,:TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,
             :BLIZZARD,:PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,
             :RETURN,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,:ROUND,
             :PAYBACK,:AURORAVEIL,:PSYCHUP,:FROSTBREATH,
             :SWAGGER,:SLEEPTALK,:SUBSTITUTE,
             :CONFIDE,:DARKPULSE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:AGILITY,:CHARM,:DISABLE,:ENCORE,:EXTRASENSORY,
             :FLAIL,:FREEZEDRY,:HOWL,:HYPNOSIS,:MOONBLAST,
             :POWERSWAP,:SPITE,:SECRETPOWER,:TAILSLAP]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:SNOWCLOAK),0],
          [getID(PBAbilities,:SNOWWARNING),2]]
  end
  next
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:NINETALES,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:ICE) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:FAIRY) if pokemon.isDelta?
  next
},
"getBaseStats"=>proc{|pokemon|
   next [73,67,75,109,81,100] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:DAZZLINGGLEAM],[1,:IMPRISON],[1,:NASTYPLOT],[1,:ICEBEAM],
              [1,:ICESHARD],[1,:CONFUSERAY],[1,:SAFEGUARD]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :ROAR,:TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,
             :BLIZZARD,:PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,
             :RETURN,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,:ROUND,
             :PAYBACK,:AURORAVEIL,:PSYCHUP,:FROSTBREATH,
             :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:CONFIDE,:DARKPULSE,
             :PSYSHOCK,:CALMMIND,:GIGAIMPACT,:DREAMEATER,:DAZZLINGGLEAM]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:SNOWCLOAK),0],
          [getID(PBAbilities,:SNOWCLOAK),1],
          [getID(PBAbilities,:SNOWWARNING),2]]
  end
  next
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:DIGLETT,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:STEEL) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 1.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:TANGLINGHAIR)==nil
      next [[getID(PBAbilities,:SANDVEIL),0],
            [getID(PBAbilities,:GOOEY),1],
            [getID(PBAbilities,:SANDFORCE),2]]
    end
    next [[getID(PBAbilities,:SANDVEIL),0],
          [getID(PBAbilities,:TANGLINGHAIR),1],
          [getID(PBAbilities,:SANDFORCE),2]]
  end
  next
},
"getBaseStats"=>proc{|pokemon|
   next [10,55,30,90,35,45] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:SANDATTACK],[1,:METALCLAW],[4,:GROWL],[7,:ASTONISH],
              [10,:MUDSLAP],[14,:MAGNITUDE],[18,:BULLDOZE],
              [22,:SUCKERPUNCH],[25,:MUDBOMB],[28,:EARTHPOWER],[31,:DIG],
              [35,:IRONHEAD],[39,:EARTHQUAKE],[43,:FISSURE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,
             :FRUSTRATION,:EARTHQUAKE,:RETURN,:DOUBLETEAM,
             :SLUDGEBOMB,:SANDSTORM,:ROCKTOMB,:AERIALACE,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,
             :SHADOWCLAW,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:FLASHCANNON,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:ANCIENTPOWER,:BEATUP,:ENDURE,:FEINTATTACK,
             :FINALGAMBIT,:HEADBUTT,:MEMENTO,:METALSOUND,
             :PURSUIT,:REVERSAL,:THRASH]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:DUGTRIO,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:STEEL) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 66.6 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:TANGLINGHAIR)==nil
      next [[getID(PBAbilities,:SANDVEIL),0],
            [getID(PBAbilities,:GOOEY),1],
            [getID(PBAbilities,:SANDFORCE),2]]
    end
    next [[getID(PBAbilities,:SANDVEIL),0],
          [getID(PBAbilities,:TANGLINGHAIR),1],
          [getID(PBAbilities,:SANDFORCE),2]]
  end
  next
},
"getBaseStats"=>proc{|pokemon|
   next [35,100,60,110,50,70] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:SANDTOMB],[1,:ROTOTILLER],[1,:NIGHTSLASH],
              [1,:TRIATTACK],[1,:SANDATTACK],[1,:METALCLAW],
              [1,:GROWL],[4,:GROWL],[7,:ASTONISH],
              [10,:MUDSLAP],[14,:MAGNITUDE],[18,:BULLDOZE],
              [22,:SUCKERPUNCH],[25,:MUDBOMB],[30,:EARTHPOWER],[35,:DIG],
              [41,:IRONHEAD],[47,:EARTHQUAKE],[53,:FISSURE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,
             :FRUSTRATION,:EARTHQUAKE,:RETURN,:DOUBLETEAM,
             :SLUDGEBOMB,:SANDSTORM,:ROCKTOMB,:AERIALACE,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,
             :SHADOWCLAW,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:FLASHCANNON,:CONFIDE,:HYPERBEAM,
             :SLUDGEWAVE,:GIGAIMPACT,:STONEEDGE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:MEOWTHELDIW,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:PICKUP),0],
          [getID(PBAbilities,:TECHNICIAN),1],
          [getID(PBAbilities,:RATTLED),2]]
  end
  next
},
"getBaseStats"=>proc{|pokemon|
   next [40,35,34,90,50,40] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:SCRATCH],[1,:GROWL],[6,:BITE],[9,:FAKEOUT],
              [14,:FURYSWIPES],[17,:SCREECH],[22,:FEINTATTACK],
              [25,:TAUNT],[30,:PAYDAY],[33,:SLASH],[38,:NASTYPLOT],
              [41,:ASSURANCE],[46,:CAPTIVATE],[49,:NIGHTSLASH],
              [50,:FEINT],[55,:DARKPULSE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
             :RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
             :SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,
             :EMBARGO,:SHADOWCLAW,:PAYBACK,:PSYCHUP,:DREAMEATER,
             :SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:DARKPULSE,
             :CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:AMNESIA,:ASSIST,:CHARM,:COVET,:FLAIL,:FLATTER,
             :FOULPLAY,:HYPNOSIS,:PARTINGSHOT,:PUNISHMENT,
             :SNATCH,:SPITE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:PERSIANELDIW,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 1.1 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 33.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:FURCOAT),0],
          [getID(PBAbilities,:TECHNICIAN),1],
          [getID(PBAbilities,:RATTLED),2]]
  end
  next
},
"getBaseStats"=>proc{|pokemon|
   next [65,60,60,115,75,65] if pokemon.isDelta?
   next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:SWIFT],[1,:QUASH],[1,:PLAYROUGH],[1,:SWITCHEROO],
              [1,:SCRATCH],[1,:GROWL],[1,:BITE],[1,:FAKEOUT],
              [6,:BITE],[9,:FAKEOUT],[14,:FURYSWIPES],[17,:SCREECH],
              [22,:FEINTATTACK],[25,:TAUNT],[32,:POWERGEM],[37,:SLASH],
              [44,:NASTYPLOT],[49,:ASSURANCE],[56,:CAPTIVATE],
              [61,:NIGHTSLASH],[65,:FEINT],[69,:DARKPULSE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
             :RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
             :SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,:FACADE,
             :REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,
             :EMBARGO,:SHADOWCLAW,:PAYBACK,:PSYCHUP,:DREAMEATER,
             :SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:DARKPULSE,
             :CONFIDE,:ROAR,:HYPERBEAM,:GIGAIMPACT,:SNARL]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:GEODUDE,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:ELECTRIC) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 20.3 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:GALVANIZE)==nil
      next [[getID(PBAbilities,:MAGNETPULL),0],
            [getID(PBAbilities,:STURDY),1]]
    end
    next [[getID(PBAbilities,:MAGNETPULL),0],
          [getID(PBAbilities,:STURDY),1],
          [getID(PBAbilities,:GALVANIZE),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:TACKLE],[1,:DEFENSECURL],[4,:CHARGE],[6,:ROCKPOLISH],
              [10,:ROLLOUT],[12,:SPARK],[16,:ROCKTHROW],[18,:SMACKDOWN],
              [22,:THUNDERPUNCH],[24,:SELFDESTRUCT],[28,:STEALTHROCK],
              [30,:ROCKBLAST],[34,:DISCHARGE],[36,:EXPLOSION],
              [40,:DOUBLEEDGE],[42,:STONEEDGE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SMACKDOWN,
             :THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,:BRICKBREAK,
             :DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,:FIREBLAST,
             :ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
             :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,
             :ROCKPOLISH,:STONEEDGE,:VOLTSWITCH,:GYROBALL,
             :BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:NATUREPOWER,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:AUTOTOMIZE,:BLOCK,:COUNTER,:CURSE,:ENDURE,:FLAIL,
             :MAGNETRISE,:ROCKCLIMB,:SCREECH,:WIDEGUARD]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:GRAVELER,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:ELECTRIC) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 110.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:GALVANIZE)==nil
      next [[getID(PBAbilities,:MAGNETPULL),0],
            [getID(PBAbilities,:STURDY),1]]
    end
    next [[getID(PBAbilities,:MAGNETPULL),0],
          [getID(PBAbilities,:STURDY),1],
          [getID(PBAbilities,:GALVANIZE),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],[1,:ROCKPOLISH],
              [4,:CHARGE],[6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
              [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
              [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
              [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
              [54,:STONEEDGE]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SMACKDOWN,
             :THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,:BRICKBREAK,
             :DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,:FIREBLAST,
             :ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
             :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,
             :ROCKPOLISH,:STONEEDGE,:VOLTSWITCH,:GYROBALL,
             :BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:NATUREPOWER,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:GOLEM,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:ELECTRIC) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 110.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:GALVANIZE)==nil
      next [[getID(PBAbilities,:MAGNETPULL),0],
            [getID(PBAbilities,:STURDY),1]]
    end
    next [[getID(PBAbilities,:MAGNETPULL),0],
          [getID(PBAbilities,:STURDY),1],
          [getID(PBAbilities,:GALVANIZE),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:HEAVYSLAM],[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],
              [1,:ROCKPOLISH],[4,:CHARGE],[6,:ROCKPOLISH],
              [10,:STEAMROLLER],[12,:SPARK],[16,:ROCKTHROW],
              [18,:SMACKDOWN],[22,:THUNDERPUNCH],[24,:SELFDESTRUCT],
              [30,:STEALTHROCK],[34,:ROCKBLAST],[40,:DISCHARGE],
              [44,:EXPLOSION],[50,:DOUBLEEDGE],[54,:STONEEDGE],
              [60,:HEAVYSLAM]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SMACKDOWN,
             :THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,:BRICKBREAK,
             :DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,:FIREBLAST,
             :ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
             :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,
             :ROCKPOLISH,:STONEEDGE,:VOLTSWITCH,:GYROBALL,
             :BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:ROAR,:HYPERBEAM,
             :FRUSTRATION,:ECHOEDVOICE,:FOCUSBLAST,:GIGAIMPACT,
             :WILDCHARGE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:GRIMER,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 0.7 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 42.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:POWEROFALCHEMY)==nil
      if getID(PBAbilities,:RECEIVER)==nil
        next [[getID(PBAbilities,:POISONTOUCH),0],
              [getID(PBAbilities,:GLUTTONY),1]]
      end
      next [[getID(PBAbilities,:POISONTOUCH),0],
            [getID(PBAbilities,:GLUTTONY),1],
            [getID(PBAbilities,:RECEIVER),2]]
    end
    next [[getID(PBAbilities,:POISONTOUCH),0],
          [getID(PBAbilities,:GLUTTONY),1],
          [getID(PBAbilities,:POWEROFALCHEMY),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:POUND],[1,:POISONGAS],[4,:HARDEN],[7,:BITE],[12,:DISABLE],
              [15,:ACIDSPRAY],[18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],
              [29,:KNOCKOFF],[32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],
              [43,:ACIDARMOR],[46,:BELCH],[48,:MEMENTO]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
             :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
             :DOUBLETEAM,:SLUDGEWAVE,:FLAMETHROWER,:SLUDGEBOMB,
             :FIREBLAST,:ROCKTOMB,:TORMENT,:FACADE,:REST,:ATTRACT,
             :THIEF,:ROUND,:FLING,:BRUTALSWING,:QUASH,:EMBARGO,
             :EXPLOSION,:PAYBACK,:ROCKPOLISH,:STONEEDGE,:INFESTATION,
             :POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:SNARL,:CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"possibleEggMoves"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[:ASSURANCE,:CLEARSMOG,:CURSE,:IMPRISON,:MEANLOOK,:PURSUIT,
             :SCARYFACE,:SHADOWSNEAK,:SPITE,:STOCKPILE,:SPITUP,:SWALLOW]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:MUK,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:DARK) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 1.0 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 52.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    if getID(PBAbilities,:POWEROFALCHEMY)==nil
      if getID(PBAbilities,:RECEIVER)==nil
        next [[getID(PBAbilities,:POISONTOUCH),0],
              [getID(PBAbilities,:GLUTTONY),1]]
      end
      next [[getID(PBAbilities,:POISONTOUCH),0],
            [getID(PBAbilities,:GLUTTONY),1],
            [getID(PBAbilities,:RECEIVER),2]]
    end
    next [[getID(PBAbilities,:POISONTOUCH),0],
          [getID(PBAbilities,:GLUTTONY),1],
          [getID(PBAbilities,:POWEROFALCHEMY),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:VENOMDRENCH],[1,:POUND],[1,:POISONGAS],[1,:HARDEN],
              [1,:BITE],[4,:HARDEN],[7,:BITE],[12,:DISABLE],
              [15,:ACIDSPRAY],[18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],
              [29,:KNOCKOFF],[32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],
              [46,:ACIDARMOR],[52,:BELCH],[57,:MEMENTO]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1]) #if getConst(PBMoves,movelist[i])!=nil
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
             :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
             :DOUBLETEAM,:SLUDGEWAVE,:FLAMETHROWER,:SLUDGEBOMB,
             :FIREBLAST,:ROCKTOMB,:TORMENT,:FACADE,:REST,:ATTRACT,
             :THIEF,:ROUND,:FLING,:BRUTALSWING,:QUASH,:EMBARGO,
             :EXPLOSION,:PAYBACK,:ROCKPOLISH,:STONEEDGE,:INFESTATION,
             :POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:SNARL,
             :CONFIDE,:HYPERBEAM,:BRICKBREAK,:FOCUSBLAST,
             :GIGAIMPACT,:DARKPULSE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:EXEGGUTOR,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:DRAGON) if pokemon.isDelta?
  next
},
"height"=>proc{|pokemon|
  next 10.9 if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 415.6 if pokemon.isDelta?
  next
},
"getBaseStats"=>proc{|pokemon|
   next [95,105,85,45,125,75] if pokemon.isDelta?
   next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:FRISK),0],
          [getID(PBAbilities,:HARVEST),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:DRAGONHAMMER],[1,:SEEDBOMB],[1,:BARRAGE],[1,:HYPNOSIS],
              [1,:CONFUSION],[17,:PSYSHOCK],[27,:EGGBOMB],[37,:WOODHAMMER],
              [47,:LEAFSTORM]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1])
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :PSYSHOCK,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
             :LIGHTSCREEN,:PROTECT,:FRUSTRATION,:SOLARBEAM,:EARTHQUAKE,
             :RETURN,:PSYCHIC,:BRICKBREAK,:DOUBLETEAM,:REFLECT,
             :FLAMETHROWER,:SLUDGEBOMB,:FACADE,:REST,:ATTRACT,
             :THIEF,:ROUND,:ENERGYBALL,:BRUTALSWING,:EXPLOSION,
             :GIGAIMPACT,:SWORDSDANCE,:PSYCHUP,:BULLDOZE,:DRAGONTAIL,
             :INFESTATION,:DREAMEATER,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
             :SUBSTITUTE,:TRICKROOM,:NATUREPOWER,:CONFIDE,:DRACOMETEOR]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

MultipleForms.register(:MAROWAK,{
"getFormName"=>proc{|pokemon|
  next _INTL("Alola Form") if pokemon.isDelta?
  next
},
"type1"=>proc{|pokemon|
  next getID(PBTypes,:FIRE) if pokemon.isDelta?
  next
},
"type2"=>proc{|pokemon|
  next getID(PBTypes,:GHOST) if pokemon.isDelta?
  next
},
"weight"=>proc{|pokemon|
  next 34.0 if pokemon.isDelta?
  next
},
"getAbilityList"=>proc{|pokemon|
  if pokemon.isDelta?
    next [[getID(PBAbilities,:CURSEDBODY),0],
          [getID(PBAbilities,:LIGHTNINGROD),1],
          [getID(PBAbilities,:ROCKHEAD),2]]
  end
  next
},
"getMoveList"=>proc{|pokemon|
  next if !pokemon.isDelta?
  movelist=[]
  if pokemon.isDelta?
    movelist=[[1,:GROWL],[1,:TAILWHIP],[1,:BONECLUB],[1,:FLAMEWHEEL],
              [3,:TAILWHIP],[7,:BONECLUB],[11,:FLAMEWHEEL],[13,:LEER],
              [17,:HEX],[21,:BONEMERANG],[23,:WILLOWISP],[27,:SHADOWBONE],
              [33,:THRASH],[37,:FLING],[43,:STOMPINGTANTRUM],[49,:ENDEAVOR],
              [53,:FLAREBLITZ],[59,:RETALIATE],[65,:BONERUSH]]
  end
  for i in movelist
    i[1]=getConst(PBMoves,i[1])
  end
  next movelist
},
"getMoveCompatibility"=>proc{|pokemon|
   next if !pokemon.isDelta?
   movelist=[# TMs
             :TOXIC,:HIDDENPOWER,:SUNNYDAY,:ICEBEAM,:BLIZZARD,:HYPERBEAM,
             :PROTECT,:RAINDANCE,:FRUSTRATION,:SMACKDOWN,:THUNDERBOLT,
             :THUNDER,:EARTHQUAKE,:RETURN,:SHADOWBALL,:BRICKBREAK,:DOUBLETEAM,
             :FLAMETHROWER,:SANDSTORM,:FIREBLAST,:ROCKTOMB,:AERIALACE,:FACADE,
             :FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,
             :FOCUSBLAST,:FALSESWIPE,:FLING,:BRUTALSWING,:WILLOWISP,
             :GIGAIMPACT,:STONEEDGE,:SWORDSDANCE,:BULLDOZE,:ROCKSLIDE,
             :DREAMEATER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
             :CONFIDE]
   for i in 0...movelist.length
     movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
  pbSeenForm(pokemon)
}
})

#===============================================================================
# HISUIAN GROWLITHE
#===============================================================================
MultipleForms.register(:GROWLITHE,{
  "getFormOnCreation"=>proc{|pokemon|
    if $game_map && [633,637].include?($game_map.map_id)
      next 1 #HISUI FORM
    else
      next
    end
  },
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:ROCK) if pokemon.form == 1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [60,75,45,55,65,50] if pokemon.form==1
		next
	},
	"height"=>proc{|pokemon|
		next 0.8 if pokemon.form == 1
		next
	},
	"weight"=>proc{|pokemon|
		next 22.7 if pokemon.form == 1
		next
	},
  "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form == 0
    movelist=[# TMs
              :ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,
              :PROTECT,:SAFEGUARD,:RETURN,:DIG,
              :DOUBLETEAM,:FLAMETHROWER,:FIREBLAST,:ROCKTOMB,:FACADE,
              :FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,
              :OVERHEAT,:WILLOWISP,:SWAGGER,:SUBSTITUTE,:WILDCHARGE,
              :SMACKDOWN,:STRENGTH,:ROCKSMASH,:ROCKSLIDE,:STEALTHROCK]
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
    end
    next movelist if pokemon.form == 1
  },
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 # skips if standard growlithe
		movelist = [[1,:EMBER],[1,:LEER],[4,:HOWL],[8,:BITE],[12,:FLAMEWHEEL],[16,:ROCKTHROW],[20,:HELPINGHAND],[24,:FIREFANG],[28,:ROCKTOMB],[32,:CRUNCH],
		[36,:LEER],[40,:TAKEDOWN],[40,:FLAMETHROWER],[44,:ROAR],[48,:PLAYROUGH],[52,:HEADSMASH],[56,:FLAREBLITZ]]		
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist if pokemon.form == 1
	},
  "wildHoldItems"=>proc{|pokemon|
    next if pokemon.form==0                 # Standard
    next [0,getID(PBItems,:ANCIENTSTONE),0] # Hisui
  }
})

MultipleForms.register(:ARCANINE,{
  "getMegaForm"=>proc{|pokemon|
		next 2 if isConst?(pokemon.item,PBItems,:ARCANITE) && (pokemon.form == 0 || pokemon.form==2)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 2
	},
  "getFormOnCreation"=>proc{|pokemon|
    if $game_map && [633,634].include?($game_map.map_id)
      next 1 #HISUI FORM
    else
      next
    end
  },
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:ROCK) if pokemon.form == 1
		next getID(PBTypes,:FAIRY) if pokemon.form == 2
		next
	},
  "getMegaName"=>proc{|pokemon|
		next _INTL("Mega Arcanine") if pokemon.form == 2
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [90,115,80,90,95,80] if pokemon.form==1
		#     +10  0    0   +60  +30  0
		next [100, 110, 80, 155, 130, 80] if pokemon.form == 2
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities, :SOLARPROMINENCE) if pokemon.form == 2 #fix
		next
	},
	"height"=>proc{|pokemon|
		next 2.0 if pokemon.form == 1
		next 2.3 if pokemon.form == 2
		next
	},
	"weight"=>proc{|pokemon|
		next 168.0 if pokemon.form == 1
		next 145.0 if pokemon.form == 2
		next
	},
  "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form == 0
    movelist=[# TMs
              :ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
              :PROTECT,:SAFEGUARD,:RETURN,:DIG,
              :DOUBLETEAM,:FLAMETHROWER,:FIREBLAST,:ROCKTOMB,:FACADE,
              :FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,
              :OVERHEAT,:WILLOWISP,:GIGAIMPACT,:BULLDOZE,:SWAGGER,:SUBSTITUTE,:WILDCHARGE,
              :SMACKDOWN,:STRENGTH,:ROCKSMASH,:STONEEDGE,:ROCKSLIDE,:STEALTHROCK]
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
    end
    next movelist if pokemon.form == 1
  },
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 # skips if standard growlithe
		movelist = [[1,:TACKLE],[5,:EMBER],[9,:BITE],[15,:FIREFANG],[21,:ROCKSLIDE],[29,:HEATCRASH],
                [33,:CRUNCH],[37,:DOUBLEEDGE],[47,:FLAREBLITZ]]
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist if pokemon.form == 1
	},
  "wildHoldItems"=>proc{|pokemon|
    next if pokemon.form==0                 # Standard
    next [0,getID(PBItems,:ANCIENTSTONE),0] # Hisui
  },
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})
