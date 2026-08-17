class PokeBattle_Trainer
  attr_accessor(:name)
  attr_accessor(:id)
  attr_accessor(:expmoderna)
  attr_accessor(:metaID)
  attr_accessor(:trainertype)
  attr_accessor(:outfit)
  attr_accessor(:badges)
  attr_accessor(:money)
  attr_accessor(:seen)
  attr_accessor(:owned)
  attr_accessor(:formseen)
  attr_accessor(:formlastseen)
  attr_accessor(:shadowcaught)
  attr_accessor(:party)
  attr_accessor(:pokedex)    # Whether the Pokédex was obtained
  attr_accessor(:pokegear)   # Whether the Pokégear was obtained
  attr_accessor(:language)
  attr_accessor(:expmoderna)
  attr_accessor(:safariZone)
  attr_accessor(:lastGameVersion)
  attr_accessor(:alterparty)
  attr_accessor(:backupBag)
  
  def trainerTypeName   # Name of this trainer type (localized)
    return PBTrainers.getName(@trainertype) rescue _INTL("PkMn Trainer")
  end

  def fullname
    return _INTL("{1} {2}",self.trainerTypeName,@name)
  end

  def publicID(id=nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end

  def secretID(id=nil)   # Other portion of the ID
    return id ? id>>16 : @id>>16
  end

  def getForeignID   # Random ID other than this Trainer's ID
    fid=0
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid 
  end

  def setForeignID(other)
    @id=other.getForeignID
  end

  def metaID
    @metaID=$PokemonGlobal.playerID if !@metaID && $PokemonGlobal
    @metaID=0 if !@metaID
    return @metaID
  end

  def outfit
    @outfit=0 if !@outfit
    return @outfit
  end

  def language
    @language=pbGetLanguage() if !@language
    return @language
  end

  def money=(value)
    @money=[[value,MAXMONEY].min,0].max
  end

  def moneyEarned   # Money won when trainer is defeated
    ret=0
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       return 30 if !trainertypes[@trainertype]
       ret=trainertypes[@trainertype][3]
    }
    return ret
  end

  def skill   # Skill level (for AI)
    ret=0
    if defined?($ISINTOURNAMENT) && $ISINTOURNAMENT
      return 80 if !SKILL_LEVELS[@trainertype]
      return SKILL_LEVELS[@trainertype]
    end
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       return 30 if !trainertypes[@trainertype]
       ret=trainertypes[@trainertype][8]
    }
    return ret
  end

  def numbadges   # Number of badges
    ret=0
    for i in 0...@badges.length
      ret+=1 if @badges[i]
    end
    return ret
  end

  def gender
    ret=2   # 2 = gender unknown
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       if !trainertypes[trainertype]
         ret=2
       else
         ret=trainertypes[trainertype][7]
         ret=2 if !ret
       end
    }
    return ret
  end

  def isMale?; return self.gender==0; end
  def isFemale?; return self.gender==1; end

  def pokemonParty
    return party().find_all {|item| item && !item.isEgg? }
  end

  def ablePokemonParty
    return party().find_all {|item| item && !item.isEgg? && item.hp>0 }
  end

  def partyCount
    return party().length
  end

  def party
    @alterparty = [] if @alterparty==nil
    return @party if $game_switches == nil
    return @party if ![61,52,9].include?(@outfit)
    return @alterparty if $game_switches[1351]
    return @party
  end

  def pokemonCount
    ret=0
    for i in 0...party().length
      ret+=1 if party()[i] && !party()[i].isEgg?
    end
    return ret
  end

  def ablePokemonCount
    ret=0
    for i in 0...party().length
      ret+=1 if party()[i] && !party()[i].isEgg? && party()[i].hp>0
    end
    return ret
  end

  def firstParty
    return nil if party().length==0
    return party()[0]
  end

  def firstPokemon
    p=self.pokemonParty
    return nil if p.length==0
    return p[0]
  end

  def firstAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[0]
  end

  def lastParty
    return nil if party().length==0
    return party()[party().length-1]
  end

  def lastPokemon
    p=self.pokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def lastAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def pokedexSeen(region=-1)   # Number of Pokémon seen
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @seen[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @seen[i]
      end
    end
    return ret
  end

  def pokedexOwned(region=-1)   # Number of Pokémon owned
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @owned[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @owned[i]
      end
    end
    return ret
  end

  def numFormsSeen(species)
    ret=0
    array=@formseen[species]
    for i in 0...[array[0].length,array[1].length].max
      ret+=1 if array[0][i] || array[1][i]
    end
    return ret
  end

  def hasSeen?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @seen[species] : false
  end

  def hasOwned?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @owned[species] : false
  end

  def setSeen(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @seen[species]=true if species>0
  end

  def setOwned(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @owned[species]=true if species>0
  end

  def clearPokedex
    @seen=[]
    @owned=[]
    @formseen=[]
    @formlastseen=[]
    for i in 1..PBSpecies.maxValue
      @seen[i]=false
      @owned[i]=false
      @formlastseen[i]=[]
      @formseen[i]=[[],[]]
    end
  end
  
  def expmoderna
    @expmoderna = false if (@expmoderna == nil)
    return @expmoderna
  end
  
  def ballused
    return @ballused
  end
  
  def balladd(value)
    @ballused+=(value)
  end
  
  def trainerdef
    return @trainerdef
  end
  
  def traineradd(value)
    @trainerdef+=(value)
  end
  
  def storedStarter
    return @storedStarters
  end

  def setStored(value)
    @storedStarters=value
  end
  
  def safariZone
    return @safariZone
  end

  def lastGameVersion 
    return @lastGameVersion
  end
  
  def initialize(name,trainertype)
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @metaID=0
    @outfit=0
    @pokegear=false
    @pokedex=false
    @ballused=0
    @trainerdef=0
    @storedStarters = nil
    @expmoderna = $difficulty
    @safariZone = false
    @lastGameVersion=GAME_VERSION
    clearPokedex
    @shadowcaught=[]
    for i in 1..PBSpecies.maxValue
      @shadowcaught[i]=false
    end
    @badges=[]
    for i in 0...8
      @badges[i]=false
    end
    @money=INITIALMONEY
    @party=[]
    @alterparty=[]
    @backupBag = nil
  end
end