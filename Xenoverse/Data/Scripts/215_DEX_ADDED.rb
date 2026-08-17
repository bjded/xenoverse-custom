class PokeBattle_Trainer
	attr_accessor(:xenodex)
	
	def xenodex
		@xenodex = false if @xenodex == nil
		return @xenodex
	end
	
  def shinyseen
    @shinyseen={} if @shinyseen == nil
    return @shinyseen
  end
  
end

def Kernel.pbViewportMessageChooseNumber(viewport,message,params,&block)
  msgwindow=Kernel.pbCreateMessageWindow(viewport,params.messageSkin)
	msgwindow.z = 9999999
  ret=Kernel.pbMessageDisplay(msgwindow,message,true,
     proc {|msgwindow|
        next Kernel.pbChooseNumber(msgwindow,params,&block)
  },&block)
  Kernel.pbDisposeMessageWindow(msgwindow)
  return ret
end

class PokeBattle_Scene
	def pbShowPokedex(pokemon,register=true)
    pbFadeOutIn(999999){
			DexObtained.new(pokemon,pokemon.gender==1 ? true : false,register)
    }
  end
end

IGNORESHINOBI=[
  # Pass 1
  :GROWLITHE,:ARCANINE,:SEEDOT,:NUZLEAF,:SHIFTRY,:MIENFOO,
  :MIENSHAO,:MAGBY,:MAGMAR,:MAGMORTAR,:TURTWIG,:GROTLE,:TORTERRA,:CHIMCHAR,:MONFERNO,:INFERNAPE,
  :PIPLUP,:PRINPLUP,:EMPOLEON,:SURSKIT,:MASQUERAIN,:LOTAD,:LOMBRE,:LUDICOLO,:HORSEA,:SEADRA,
  :KINGDRA,:PSYDUCK,:GOLDUCK,:WOOPER,:QUAGSIRE,:CHEWTLE,:DREDNAW,
  # Pass 2
  :BELLSPROUT, :WEEPINBELL, :VICTREEBEL, :TANGELA, :TANGROWTH,
  :FERROSEED, :FERROTHORN, :MUNNA, :MUSHARNA, :UNOWNELDIW, 
  :SNIVY, :SERVINE, :SERPERIOR,:SWINUB, :PILOSWINE,:MAMOSWINE, :MISDREAVUS, :MISMAGIUS,
  :SNORUNT, :GLALIE, :FROSLASS, :CRYOGONAL, :OSHAWOTT, :DEWOTT, :SAMUROTT, :LARVESTA,
  :VOLCARONA, :GLIGAR, :GLISCOR, :POOCHYENA, :MIGHTYENA, :DEINO, :ZWEILOUS, :HYDREIGON,
  :DURALUDON, :TEPIG, :PIGNITE, :EMBOAR,
  # Pass 3
  :MAWILE,:DUSKULL,:DUSCLOPS,:DUSKNOIR,:PINECO,:FORRETRESS,:SALANDIT,:SALAZZLE,:KANGASKHAN,
  :TORCHIC,:COMBUSKEN,:BLAZIKEN,:BONSLY,:SUDOWOODO,:PARAS,:PARASECT,:TREECKO,:GROVYLE,:SCEPTILE,:MIMEJR,
  :MRMIME,:MUDKIP,:MARSHTOMP,:SWAMPERT,:TOXEL,:TOXTRICITY
]

IGNOREX = [:GRENINJAX]

MYTHDOGS = [PBSpecies::ENTEI,PBSpecies::RAIKOU,PBSpecies::SUICUNE]

BIGX = [:BISHARPX, :RAICHUX, :SCOVILEX, :TYRANITARX, :TAPUKOKOX, :TAPULELEX, :TAPUFINIX, :TAPUBULUX, :DITTOX, :DISPLACEMENTX]

def shouldIgnore?(species)
  ignore = []
  ignore = ((ignore-(ignore&IGNORESHINOBI))+IGNORESHINOBI) #this ensures there are no duplicates
  for i in ignore
    return true if isConst?(species,PBSpecies,i)
  end
  return false
end

def shouldIgnoreX?(species,ignoreBigX = true)
  return true if isConst?(species,PBSpecies,IGNOREX[0])
  if (ignoreBigX)
    for v in BIGX
      return true if isConst?(species,PBSpecies,v)
    end
  end
  return false
end

def getEldiwDexChecks(ignoreDogs = false)
  ret =[]
  for i in ELDIWDEX
    if shouldIgnore?(i)
      echoln "#{PBSpecies.getName(i)} ignored!"
      next 
    end
    next if ignoreDogs && MYTHDOGS.include?(i)
    ret.push(i)
  end
  return ret
end

def getMonArray(species)
  return if species == nil || species.length==0
  ret = []
  for i in species
    ret.push("#{PBSpecies.getName(i)}:(#{i})")
  end
  echoln ret.join("\n")
end

def getXenoDexChecks(ignoreBigX = true)
  ret = []
  for i in XENODEX
    next if shouldIgnoreX?(i,ignoreBigX)
    ret.push(i)
  end
  return ret
end

def pbCheckCompletion(fullList,checkList)
  #Checking for every entry in the fullList
  for i in fullList
    if (checkList.length <= i || checkList[i] == false)
      echoln "#{PBSpecies.getName(i)} is missing!"
      return false 
    end
  end
  return true
end

def eDexFull?(seen = false)
  return pbCheckCompletion(getEldiwDexChecks(true),seen ? $Trainer.seen : $Trainer.owned)
end

def pbSCELDIW(seen=true,ignore=true)  
  ret = 0
  if seen
    #better check eldiwDexChecks, which already makes all the needed checks
    for i in getEldiwDexChecks(ignore)#ELDIWDEX
      #next if shouldIgnore?(i) && ignore
      ret+=1 if $Trainer.seen[i]
    end
  else
    for i in getEldiwDexChecks(ignore)
      #next if shouldIgnore?(i) && ignore
      ret+=1 if $Trainer.owned[i]
    end
  end
  return ret
end

def pbSCXENO(seen=true)
  ret = 0
  if seen
    for i in XENODEX
      next if shouldIgnoreX?(i)
      ret+=1 if $Trainer.seen[i]
    end
  else
    for i in XENODEX
      next if shouldIgnoreX?(i)
      ret+=1 if $Trainer.owned[i]
    end
  end
  return ret
end

def pbSCRETRO(seen=true)
  ret = 0
  if seen
    for i in RETRODEX
      ret+=1 if $Trainer.seen[i]
    end
  else
    for i in RETRODEX
      ret+=1 if $Trainer.owned[i]
    end
  end
  return ret
end

# Form description translation
$fdtr={}

def pbCreateFormDescTranslation
  f = File.open("PBS/fdtr.txt","w")
  formdesc = pbLoadFormInfos
  for k in formdesc.keys
    kind = formdesc[k].kind == nil ? "NO_KIND_SET (DO NOT REMOVE THIS LINE)" : formdesc[k].kind
    f.write(kind)
    f.write("\n")
		f.write(kind)
		f.write("\n")
		f.write(formdesc[k].description)
		f.write("\n")
		f.write(formdesc[k].description)
		f.write("\n")
	end
	f.close
end

def pbLoadFormDescTranslation
	f = File.open("PBS/fdtr.txt")
	l=0
	key=nil
  lines = []
	f.readlines.each do |linea|
		if linea[0,1] != "#"
     # echoln "#{linea[0,1]} - #{linea}"
      lines << linea
    end
	end
	f.close

  for line in lines
    if l%2==0
      $fdtr[line.gsub("\n","")]=nil
      key=line.gsub("\n","")
    else
      echoln "#{key} => #{line.gsub("\n","")}"
      $fdtr[key]=line.gsub("\n","")
      key=nil
    end
    l+=1
  end

end