def pbBattleAltForm(species,level,form=0,variable=nil,canescape=true,canlose=false,skipanim=false,shinyflag=nil)
  pkmn = pbGenerateWildPokemon(species,level)
  pkmn.forcedForm=form
  pkmn.resetMoves
  if shinyflag != nil
    if pbGet(shinyflag)==-1
      pbSet(shinyflag,pkmn.isShiny? ? 1 : 0)
    else
      if pbGet(shinyflag)==1
        pkmn.makeShiny
      else
        pkmn.makeNotShiny
      end
    end
  end
  pkmn.calcStats
  skipanim = true if species == PBSpecies::TOKAKLE
  pbWildPokemonBattle(pkmn,variable,canescape,canlose,skipanim)
end

def pbBattleAltPokemonForm(pkmn,form=0,variable=nil,canescape=true,canlose=false,skipanim=false)
  pkmn.forcedForm=form
  pkmn.calcStats
  pbWildPokemonBattle(pkmn,variable,canescape,canlose,skipanim)
end

SAVESHINYFLAG=[PBSpecies::GRENINJAX, PBSpecies::RAIKOU, PBSpecies::ENTEI, PBSpecies::SUICUNE,
               PBSpecies::AEGISLASHX, 
               PBSpecies::TAPUFINIX, PBSpecies::TAPULELEX, PBSpecies::TAPUKOKOX, PBSpecies::TAPUBULUX,
               PBSpecies::DRAGALISKFURIA,
               PBSpecies::TORNADUS, PBSpecies::THUNDURUS, PBSpecies::LANDORUS, PBSpecies::ENAMORUS]

#===============================================================================
# Start a single wild Pokemon battle
#===============================================================================
def pbWildPokemonBattle(pkmn,variable=nil,canescape=true,canlose=false,skipanim=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  genwildpoke=pkmn
  $wildSpecies = pkmn.species


  handled=[nil]
  Events.onWildBattleOverride.trigger(nil,pkmn.species,pkmn.level,handled)
  if handled[0]!=nil
    return handled[0]
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(pkmn.species),-1,"",skipanim) {
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil); i.busted=false if i.busted; end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
				i.makeUnmega rescue nil
				i.busted=false if i.busted
       end
     end
     if decision==1 && RETROMON[pkmn.species]#$game_switches[RETROMONSWITCH] &&
        echoln "WIN BATTLE"
        if $Trainer.retrochain[pkmn.species]
          $Trainer.retrochain[pkmn.species]+=1 if $Trainer.retrochain[pkmn.species]<500
        else
          $Trainer.retrochain[pkmn.species]=1
        end
        echoln $Trainer.retrochain[pkmn.species]
      end
     if decision==2 || decision==5 # if loss or draw
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     if decision==4
       if [PBSpecies::TRISHOUT,
           PBSpecies::SHYLEON,PBSpecies::SHULONG].include?(pkmn.species) && pkmn.forcedForm != nil

          pkmn.forcedForm=nil
          pkmn.setAbility(2)
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Events.onWildBattleEnd.trigger(nil,pkmn.species,pkmn.level,decision)
  $wildSpecies = nil
  return (decision!=2)
end

if !defined?($MKXP) || !$MKXP
  class Array
    def count
      res = 0
      for i in self
        res +=1 if yield i
      end
      return res
    end
  end
end

#===============================================================================
# Start a double wild Pokemon battle
#===============================================================================
def pbDoubleWildPokemonBattle(poke1,poke2,variable=nil,canescape=true,canlose=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke=poke1
  $wildSpecies = poke1.species
  genwildpoke2=poke2
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    combinedParty=[]
    for i in 0...$Trainer.party.length
      combinedParty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      combinedParty[6+i]=othertrainer.party[i]
    end
    battle=PokeBattle_Battle.new(scene,combinedParty,[genwildpoke,genwildpoke2],
       [$Trainer,othertrainer],nil)
    battle.fullparty1=true
  else
    battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke,genwildpoke2],
       $Trainer,nil)
  end
  battle.internalbattle=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(poke1.species)) {
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil);i.busted=false if i.busted; end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
				i.heal
				i.busted=false if i.busted
         i.makeUnmega rescue nil
       end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  return (decision!=2 && decision!=5)
end

################################################################################
# New font in fullbox and richtext support misc
################################################################################
def drawNoShadowFormattedChar(bitmap,ch)
  if ch[5] # If a graphic
    graphic=Bitmap.new(ch[0])
    graphicRect=ch[15]
    bitmap.blt(ch[1], ch[2], graphic,graphicRect,ch[8].alpha)
    graphic.dispose
  else
    if bitmap.font.size!=ch[13]
      bitmap.font.size=ch[13]
    end
    if ch[0]!="\n" && ch[0]!="\r" && ch[0]!=" " && !isWaitChar(ch[0])
      if bitmap.font.bold!=ch[6]
        bitmap.font.bold=ch[6]
      end
      if bitmap.font.italic!=ch[7]
        bitmap.font.italic=ch[7]
      end
      if bitmap.font.name!=ch[12]
        bitmap.font.name=ch[12]
      end
      offset=0
      if bitmap.font.color!=ch[8]
        bitmap.font.color=ch[8]
      end
      bitmap.draw_text(ch[1]+offset,ch[2]+offset,ch[3],ch[4],ch[0])
    else
      if bitmap.font.color!=ch[8]
        bitmap.font.color=ch[8]
      end
    end
    if ch[10] # underline
      bitmap.fill_rect(ch[1],ch[2]+ch[4]-[(ch[4]-bitmap.font.size)/2,0].max-2,
         ch[3]-2,2,ch[8])
    end
    if ch[11] # strikeout
      bitmap.fill_rect(ch[1],ch[2]+(ch[4]/2),ch[3]-2,2,ch[8])
    end
  end
end

def drawNoShadowFormattedChars(bitmap,chars)
  if chars.length==0||!bitmap||bitmap.disposed?
    return
  end
  oldfont=bitmap.font.clone
  for ch in chars
    drawNoShadowFormattedChar(bitmap,ch)
  end
  bitmap.font=oldfont
end

def drawFormattedTextFullbox(bitmap,x,y,width,text,baseColor=nil)
  base=!baseColor ? Color.new(12*8,12*8,12*8) : baseColor.clone
  text="<c2="+colorToRgb16(base)+">"+text
  chars=getFormattedText(bitmap,x,y,width,-1,text,32)
  drawNoShadowFormattedChars(bitmap,chars)
end
################################################################################
# C(hange)F(orm) legendaries
################################################################################

def pbChooseCFLegendaries()
  lege = []
  for x in CF_LEGENDARIES
    lege.push(getID(PBSpecies,x))
  end
  Kernel.pbChoosePokemon(1,3,Proc.new {|pkmn|
    lege.include?(pkmn.species)
  },false)
end

def pbChangeLegendaryForm(index)
  $Trainer.party[index].form = $Trainer.party[index].form==1 ? 0 : 1
end

def testbit
  return ['foo'].pack('p').size
end

################################################################################
# Location box override
################################################################################
class LocationWindow
  def initialize(name)
    @sprites = {}
    @sprites["Image"] = Sprite.new
    @sprites["Image"].z = 99999
    @sprites["overlay"]=Sprite.new
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].z=99999
    @sprites["overlay"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
    #Dimensione standard 20, oltre i
    fontsize = ($MKXP ? 18 : 20) - ($game_map.name.length>13 ? ($game_map.name.length-13)*0.5 : 0)
    @sprites["overlay"].bitmap.font.size = fontsize

    @overlay = @sprites["overlay"].bitmap
    @overlay.clear
    @baseColor=Color.new(248,248,248)

    #Map id delle città in cui viene mostrata la targhetta
    @cities = ["Ranch Spigadoro", "Balansopoli","Vetta Polare", "Campus Ariepoli",
    "Biblioteca Acero","Borgo Gemini", "Regno di Virgopoli", "Aquariopoli",
    "Cansiria", "Scorpiopoli","Stazione di Scorpiopoli", "Quasar Express", "Leopoli",
    "Aeroporto Samuel Oak", "Aeroporto MegaForza", "Ofiuchia", "Sagittopoli",
    "Tauronordia", "Saloon Torobrado","Capricornia", "Aranciopoli", "Covo Dimension", "Palestra Radice",
    "Palestra Competizione", "Palestra Zucchero", "Palestra Marea", "El purgatorio",
    "Palestra Ritmo", "Circo Sirio", "Vecchia Palestra Tuono"]
    @wroutes = ["3","4","13","14","11","15","16","17", "Isola Buconero", "Isola Pigliapesci", "Motonave Cometa", "Relitto Meteora"]
    @caves = ["Grotta Zerokelvin", "Cunicolo Gravità", "Grotta Immersione",
    "Vulcano Pulsar", "Caverna Zenit", "Grotta Cratere","Canyon Asteroide","Area Dugtrio",
    "Zona DNA","Percorso 8","Gola Steelix", "Tempio Shyleon", "Fogne di Sagittopoli",
    "Monte Zodiaco", "Nido Boreale", "Vetta Boreale", "Grotta dell'Epilogo"]
    @xenoverse = ["Mondo Xenoverse"]

    city = "Graphics/Maps/City_loc"
    route = "Graphics/Maps/Route_loc" # this will be relied on if nothing else matches
    cave = "Graphics/Maps/Cave_loc"
    waterRoute = "Graphics/Maps/WaterRoute_loc"
    xenoverse = "Graphics/Maps/Xenoverse_loc"



    if @cities.include?($game_map.name)
      @sprites["Image"].bitmap = pbBitmap(city)
      @shadowColor=Color.new(32,39,39)
    elsif @wroutes.include?($game_map.name)
      @sprites["Image"].bitmap = pbBitmap(waterRoute)
      @shadowColor=Color.new(16,42,53)
    elsif @xenoverse.include?($game_map.name)
      @sprites["Image"].bitmap = pbBitmap(xenoverse)
      @shadowColor=Color.new(38,16,52)
    elsif @caves.include?($game_map.name)
      @sprites["Image"].bitmap = pbBitmap(cave)
      @shadowColor=Color.new(52,30,17)
    else
      @sprites["Image"].bitmap = pbBitmap(route)
      @shadowColor=Color.new(17,52,43)
    end
    @sprites["Image"].zoom_x = 0.25
    @sprites["Image"].zoom_y = 0.25
    @sprites["Image"].x = Graphics.width/2 - @sprites["Image"].bitmap.width/2 * 0.25
    @sprites["overlay"].x = @sprites["Image"].x
    @sprites["Image"].y = 0 - @sprites["Image"].bitmap.height/4

    @window=Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name,Graphics.width)
    @window.x=0
    @window.y=-@window.height
    @window.z=99999
    @currentmap=$game_map.map_id
    @frames=0

    @overlay.clear
    textPositions=[]
    textPositions.push([_INTL("{1}", $game_map.name),@sprites["Image"].bitmap.width/2 * 0.25 + 14,0,2,@baseColor,@shadowColor])
    pbDrawOutlineText(@sprites["overlay"].bitmap,14,-4,@sprites["Image"].bitmap.width/4,@sprites["Image"].bitmap.height/4,_INTL("{1}", $game_map.name),@baseColor,@shadowColor,1)

  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
    @sprites["Image"].dispose
    @overlay.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    @sprites["overlay"].update
    if $game_temp.message_window_showing ||
       @currentmap!=$game_map.map_id
      @window.dispose
      @sprites["Image"].dispose
      @overlay.dispose
      return
    end
    if @frames>70
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height/4)/10)
      @sprites["overlay"].y = @sprites["Image"].y
      @overlay.dispose if @sprites["Image"].y+@sprites["Image"].bitmap.height<0
      @window.dispose if @sprites["Image"].y+@sprites["Image"].bitmap.height<0
      @sprites["Image"].dispose if @sprites["Image"].y+@sprites["Image"].bitmap.height<0
    else
      @sprites["Image"].y+= ((@sprites["Image"].bitmap.height/4)/10) if @sprites["Image"].y<0
      @sprites["overlay"].y = @sprites["Image"].y
      @frames+=1
    end
  end

end
################################################################################
# Condominio lotta
################################################################################
def pbCreateCondTrainer

  $oldTrainer = $Trainer
  $oldBag = $PokemonBag

  banlist = [PBSpecies::LUXFLON,PBSpecies::DIELEBI,PBSpecies::MEW,
  PBSpecies::HOOH,PBSpecies::LUGIA,PBSpecies::ENTEI,PBSpecies::SUICUNE,PBSpecies::RAIKOU,
  PBSpecies::CELEBI,PBSpecies::DEOXYS,PBSpecies::HEATRAN,PBSpecies::DARKRAI,
  PBSpecies::CRESSELIA,PBSpecies::GENESECT,
  PBSpecies::MELOETTA,PBSpecies::MARSHADOW,PBSpecies::MEWTWOX]
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     screen=PokemonScreen.new(scene,$Trainer.party)
     ret=screen.pbChooseMultiplePokemon(3,proc{|p|
     return !banlist.include?(p.species)})

     return false if ret == nil || ret == -1
     $Trainer = PokeBattle_Trainer.new($oldTrainer.name,$oldTrainer.trainertype)
     $Trainer.party = Marshal.load(Marshal.dump(ret))
     for b in 0...8
      $Trainer.badges[b]=true
     end

     $PokemonBag = PokemonBag.new
  }
  for poke in $Trainer.party
    poke.level = 50
    poke.calcStats
  end
  pbHealAll()
  return true
end

def pbRestoreOldTrainer
  $Trainer = $oldTrainer
  $PokemonBag = $oldBag
end

def pbBackupBag
  $Trainer.backupBag = $PokemonBag.clone
end

def pbRestoreBagFromBackup
  return if $Trainer.backupBag == nil
  $PokemonBag = $Trainer.backupBag 
  $Trainer.backupBag = nil
end

def pbSetPokemonLevel(poke,level)
    poke.level = level
    poke.calcStats
    poke.heal
end

def pbChangeBagWithItems(items,backup = false)
  pbBackupBag() if (backup)
  $PokemonBag = PokemonBag.new

  for i in items
    item = i[0]
    if (i.length>1)
      quantity = i[1]
    else
      quantity = 1
    end
    $PokemonBag.pbStoreItem(item,quantity)
  end
end

def pbTestBagBackup()
  pbChangeBagWithItems([
    [:POTION,50],
    [:MASTERBALL,50]
  ],true)
end


class PokemonScreen
  def pbChooseMultiplePokemon(number,validProc,minlength = 3,cancancel = true)
    annot=[]
    statuses=[]
    ordinals=[
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH")
    ]
    ret=nil
    addedEntry=false
    for i in 0...@party.length
      if validProc.call(@party[i])
        statuses[i]=1
      else
        statuses[i]=2
      end
    end
    for i in 0...@party.length
      annot[i]=ordinals[statuses[i]]
    end
    @scene.pbStartScene(@party,_INTL(""),annot,true)
    loop do
      realorder=[]
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]]=i+3
      end
      for i in 0...@party.length
        annot[i]=ordinals[statuses[i]]
      end
      @scene.pbAnnotate(annot)
      if realorder.length==number && addedEntry
        @scene.pbSelect(6)
      end
      @scene.pbSetHelpText(_INTL(""))
      pkmnid=@scene.pbChoosePokemon(false,true,cancancel){
        yield if block_given?
      }
      addedEntry=false
      if pkmnid==6 && realorder.length>=minlength# Confirm was chosen
        ret=[]
        for i in realorder
          ret.push(@party[i])
        end
        error=[]
        break
        #if !ruleset.isValid?(ret,error)
        #  pbDisplay(error[0])
        #  ret=nil
        #else
        #  break
        #end
      end
      if pkmnid<0 # Canceled
        break
      end
      cmdEntry=-1
      cmdNoEntry=-1
      cmdSummary=-1
      commands=[]
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry=commands.length]=_INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry=commands.length]=_INTL("No Entry")
      end
      pkmn=@party[pkmnid]
      commands[cmdSummary=commands.length]=_INTL("Info")
      commands[commands.length]=_INTL("Chiudi")
      command=@scene.pbShowCommands(_INTL("Che fare con {1}?",pkmn.name),commands,nil,0,pkmn) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=number && number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",number))
        else
          statuses[pkmnid]=realorder.length+3
          addedEntry=true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid]=1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      end
    end
    @scene.pbEndScene
    return ret
  end
end

################################################################################
# Achievements
################################################################################
def pbSTP
  $achievements["Ranger"].progress=49
  $achievements["Capo"].silentProgress(49)
  $achievements["Forte"].silentProgress(49)
end

PLATS=["Stella",
	"EsplosioneScampata",
	"Pescagrossa",
	"Ragno",
	"Tiranno",
	"Fantino",
	"Grossi",
	"Melodia",
	"Finale",
	"Oscuro",
	"Radice",
	"Competizione",
	"Zucchero",
	"Marea",
	"Desolazione",
	"Ritmo",
	"Marchiatura",
	"Onore",
	"Mens",
	"Freddo",
	"Alata",
	"Annientadraghi",
	"Plus",
	"Scontro",
	"Confronto",
	"Autografo",
	"Terminator",
	"Amore",
	"Epilogo",
	"Perseum",
	"Heraclium",
	"Ikarium",
	"Kaiserum",
	"Odysseum",
	"Fashion",
	"Lotte",
	"Dejavu",
	"Spettri",
	"Mamma",
	"Giungla",
	"Fascino",
	"Chiamata",
	"Futuro",
	"Dolcetto",
	"Spaziotempo",
	"Ombre",
	"Talent",
	"Collezionista",
	"Anima",
	"Astra",
	"Fulmine",
	"Specchio",
	"Ranger",
	"Capo",
	"Forte",
	"Passi",
	"Erba",
	"Acchiappali",
	"Ultraball",
	"Ball",
	"Orchestra",
	"Frittata",
	"Passione",
	"Allevatore",
	"Fanatico",
	"Mondo",
	"Brillante",
	"Mercante",
	"Nemici",
	"Tana",
	"Hipster",
	"Leggendaria"
]

def pbCheckPlatinumAchi
	return if $achievements["Platino"].completed
	for a in PLATS
		return if !$achievements[a].completed
	end
	$achievements["Platino"].progress=1
end

def pbTSTPlatinum
	for a in PLATS
		if a!="Leggendaria"
			$achievements[a].silentProgress($achievements[a].amount)
		else
			$achievements[a].progress=($achievements[a].amount)
		end
	end
end

def pbCheckCaughtPokemon
  return if $achievements["Acchiappali"].completed
  regionlist=ELDIWDEX.clone#pbAllRegionalSpecies(0)
  echoln regionlist if $DEBUG
  regionlist.delete(243)
  regionlist.delete(244)
  regionlist.delete(245)
  echoln regionlist if $DEBUG
  echoln regionlist.length if $DEBUG
  #ret=false
  count = 0
  for i in regionlist
    #ret = true
    #ret=false if !$Trainer.owned[i]
    #next if !$Trainer.owned[i]
    #count+=1
		count+=1 if $Trainer.owned[i]
  end
  $achievements["Acchiappali"].silentProgress(count) if !$achievements["Acchiappali"].completed
  if $achievements["Acchiappali"].completed
    $achievements["Acchiappali"].hidden=false
  end
  #$achievements["Acchiappali"].hidden = false if $achievements["Acchiappali"].progress>0
  #return if ret==false
  #$achievements["Acchiappali"].progress = 1 if ret == true && !$achievements["Acchiappali"].completed
end

def pbCheckCaughtPokemonX
  return if $achievements["Mondo"].completed
  regionlist=XENODEX.clone#pbAllRegionalSpecies(0)
  echoln regionlist if $DEBUG
  regionlist.delete(PBSpecies::DITTOX)
  regionlist.delete(PBSpecies::RAICHUX)
  regionlist.delete(PBSpecies::BISHARPX)
	regionlist.delete(PBSpecies::SCOVILEX)
  regionlist.delete(PBSpecies::TYRANITARX)
  regionlist.delete(PBSpecies::TAPUKOKOX)
	regionlist.delete(PBSpecies::TAPUBULUX)
  regionlist.delete(PBSpecies::TAPUFINIX)
  regionlist.delete(PBSpecies::TAPULELEX)
  echoln regionlist if $DEBUG
  echoln regionlist.length if $DEBUG
  #ret=false
  count = 0
  for i in regionlist
    count+=1 if $Trainer.owned[i]
  end
  $achievements["Mondo"].silentProgress(count) if !$achievements["Mondo"].completed
  if $achievements["Mondo"].completed
    $achievements["Mondo"].hidden=false
  end
end

def pbCheckBallsInBag
	return if !$PokemonBag || $achievements["Ball"].completed
	ballList = [:POKEBALL,:GREATBALL,:ULTRABALL,:LEVELBALL,:LUREBALL,:MOONBALL,:HEAVYBALL,:FRIENDBALL,:LOVEBALL,:FASTBALL,
		:REPEATBALL,:TIMERBALL,:NESTBALL,:NETBALL,:DIVEBALL,:LUXURYBALL,:HEALBALL,:QUICKBALL,:DUSKBALL,:XENOBALL]
	for i in ballList
		return if $PokemonBag.pbQuantity(getConst(PBItems,i))<=0
	end
	#if i'm here it means i have all the balls
	$achievements["Ball"].progress=1
end

def pbHasItem?(item)
  return if $Trainer == nil || !$Trainer
  return $PokemonBag.pbQuantity(getConst(PBItems,item))>0
end

def pbCheckAllMegaStones
  return if !$PokemonBag || $achievements["Mega"].completed
	ballList = [:ABSOLITE,:ALAKAZITE,:AUDINITE,:BELLOSSOMITE,:BLASTOISINITE,:BLAZIKENITE,
  :CHARIZARDITET,:CHARIZARDITEX,:ENTEITE,:GARCHOMPITE,:HERACRONITE,:LUCARITE,:LUXRAYITE,
  :MAWILITE,:MIENSHAOITE,:RAIKOUITE,:SCEPTILITE,:SCIZORITE,:SHIFTRYITE,:SUICUNITE,:SWAMPERTITE,
  :TYRANITARITE,:VENUSAURITE,:WEAVILITE,:RAMPARDITE,:ARCANITE,:GENGARITE,:GARDEVOIRITE,
  :ALTARIANITE,:MEWTWONITEX]
	for i in ballList
		return if $PokemonBag.pbQuantity(getConst(PBItems,i))<=0
	end
	#if i'm here it means i have all the balls
	$achievements["Mega"].progress=1
end

def pbCheckBremandForms
	return if !$Trainer || $achievements["Orchestra"].completed
	ret = [false,false,false,false]
	for p in $Trainer.party
		if p.species == PBSpecies::BREMAND
			ret[p.form]=true
		end
	end
	for r in ret
		return if !r
	end
	$achievements["Orchestra"].progress=1
end

def pbEggAchievement
	return if $achievements["Allevatore"].completed
	if !$achievements["Frittata"].completed
		$achievements["Frittata"].progress=1
		$achievements["Passione"].progress=1
	elsif !$achievements["Passione"].completed
		if ($achievements["Passione"].progress+1)%10==0
			$achievements["Passione"].progress=1
		else
			$achievements["Passione"].silentProgress($achievements["Passione"].progress+1)
		end
		if $achievements["Passione"].completed
			$achievements["Allevatore"].progress=($achievements["Passione"].progress)
		end
	else
		if ($achievements["Allevatore"].progress+1)%25==0
			$achievements["Allevatore"].progress=1
		else
			$achievements["Allevatore"].silentProgress($achievements["Allevatore"].progress+1)
		end
	end
end

################################################################################
# Load screen icon class
################################################################################

class NewIconSprite < EAMSprite
  def initialize(pokemon,viewport,zoom=0.5)
    super(viewport)
    @pokemon=pokemon
    self.bitmap = evaluateIcon(@pokemon) if @pokemon!=nil
    self.zoom_x = zoom
    self.zoom_y = zoom
  end
  def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
    if pokemon.isEgg?
			bmp = "Graphics/Pictures/DexNew/Icon/Egg"
			bitmap = pbBitmap(bmp).clone
			return bitmap
		end
		bmp =""
		bmp += "Graphics/Pictures/DexNew/Icon/#{pokemon.species}"
		if pokemon.gender==1 && pbResolveBitmap(bmp+"f")
			bmp+="f"
		end
		if pokemon.formNoCall != nil && (pokemon.formNoCall)>0
			if pokemon.isDelta?
				bmp+="d"
			else
				bmp+="_#{pokemon.formNoCall}"
			end
		end
    if pokemon.isDelta?
      bmp+="d"
    end
		bitmap = pbBitmap(bmp).clone
		echoln pokemon.item
		return bitmap
	end
end

def pbFormMetricsOverride(pokemon,form=0,og=0,back=false)
	if [PBSpecies::SHULONG,PBSpecies::TRISHOUT].include?(pokemon.species) && form>0
		return 30 if pokemon.species==PBSpecies::SHULONG && form==2 && back
		return 60 if pokemon.species==PBSpecies::SHULONG && form==2 && !back
		return 30 if pokemon.species==PBSpecies::SHULONG && form==3 && !back
		return 40 if pokemon.species==PBSpecies::TRISHOUT && form==2 && !back
	end
	return og
end

def pbFixLuxflon
  return if !$game_switches[611]
  return if $game_switches[1001]
  for i in $Trainer.party
    if i.boss && i.species == PBSpecies::LUXFLON
      i.boss = false
      i.calcStats
    end
  end
  for k in 0...STORAGEBOXES
    for p in 0...16
      if $PokemonStorage[k][p]!=nil && $PokemonStorage[k][p].species==PBSpecies::LUXFLON && $PokemonStorage[k][p].boss
        $PokemonStorage[k][p].boss=false
        $PokemonStorage[k][p].calcStats
      end
    end
  end
  $game_switches[1001]=true
end

def pbGetIncense(baby)
  if isConst?(baby,PBSpecies,:MUNCHLAX) && hasConst?(PBSpecies,:SNORLAX)
    return getConst(PBItems,:FULLINCENSE)
  elsif isConst?(baby,PBSpecies,:WYNAUT) && hasConst?(PBSpecies,:WOBBUFFET)
    return getConst(PBItems,:LAXINCENSE)
  elsif isConst?(baby,PBSpecies,:HAPPINY) && hasConst?(PBSpecies,:CHANSEY)
    return getConst(PBItems,:LUCKINCENSE)
  elsif isConst?(baby,PBSpecies,:MIMEJR) && hasConst?(PBSpecies,:MRMIME)
    return getConst(PBItems,:ODDINCENSE)
  elsif isConst?(baby,PBSpecies,:CHINGLING) && hasConst?(PBSpecies,:CHIMECHO)
    return getConst(PBItems,:PUREINCENSE)
  elsif isConst?(baby,PBSpecies,:BONSLY) && hasConst?(PBSpecies,:SUDOWOODO)
    return getConst(PBItems,:ROCKINCENSE)
  elsif isConst?(baby,PBSpecies,:BUDEW) && hasConst?(PBSpecies,:ROSELIA)
    return getConst(PBItems,:ROSEINCENSE)
  elsif isConst?(baby,PBSpecies,:AZURILL) && hasConst?(PBSpecies,:MARILL)
    return getConst(PBItems,:SEAINCENSE)
  elsif isConst?(baby,PBSpecies,:MANTYKE) && hasConst?(PBSpecies,:MANTINE)
    return getConst(PBItems,:WAVEINCENSE)
  end
  return 0
end

# Faster method for drawing outlines in MKXP.

if $MKXP


  class Sprite
    attr_accessor :cachedOutlined

    def cachedOutlined
      @cachedOutlined = {} if @cachedOutlined == nil
      return @cachedOutlined
    end

    def add_outline(c1,frame=0,cache = true)
      #self.bitmap.add_outline(c1)
      return if !self.bitmap
      if cache
        if !cachedOutlined.keys.include?(frame)
          bmp = self.bitmap.clone
          self.bitmap = Bitmap.new(bmp.width,bmp.height)
          self.bitmap.blt(-1,0,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
          self.bitmap.blt(1,0,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
          self.bitmap.blt(0,-1,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
          self.bitmap.blt(0,1,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
          self.bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
          for y in 0...bmp.height
            for x in 0...bmp.width
              pixel = self.bitmap.get_pixel(x,y)
              if pixel.alpha>0 && pixel.alpha <255
                self.bitmap.set_pixel(x,y,c1)
              end
            end
          end
          cachedOutlined[frame] = self.bitmap.clone
        else
          self.bitmap = cachedOutlined[frame].clone
        end
      else
        bmp = self.bitmap.clone
        self.bitmap = Bitmap.new(bmp.width,bmp.height)
        self.bitmap.blt(-1,0,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
        self.bitmap.blt(1,0,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
        self.bitmap.blt(0,-1,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
        self.bitmap.blt(0,1,bmp,Rect.new(0,0,bmp.width,bmp.height),80)
        self.bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
        for y in 0...bmp.height
          for x in 0...bmp.width
            pixel = self.bitmap.get_pixel(x,y)
            if pixel.alpha>0 && pixel.alpha <255
              self.bitmap.set_pixel(x,y,c1)
            end
          end
        end
      end
=begin
      x0,y0 = 0,0
      found = false
      for y in 0...bmp.height
        for x in 0...bmp.width
          pixel = self.bitmap.get_pixel(x,y)
          if pixel.alpha>0 && pixel.alpha <255
            x0,y0 = x,y
            self.bitmap.set_pixel(x,y,Color.new(255,0,0))
            found = true
            break
          end
          #pixel = self.bitmap.get_pixel(x,y)
          #if pixel.alpha > 0 && pixel.alpha < 255
          #  self.bitmap.set_pixel(x,y,c1)
          #end
        end
        break if found
      end

      nextfound = true
      pass = 0
      while nextfound
        nextfound = false
        pass+=1
        tmpx0,tmpy0 = x0,y0
        echoln "===== #{pass} PASS"
        #priority on linear rather than diagonal
        if self.bitmap.get_pixel(x0-1,y0-1).alpha>0 && self.bitmap.get_pixel(x0-1,y0-1).alpha<255 && pass>1
          nextfound = true
          tmpx0,tmpy0 = x0-1,y0-1
          echoln "Found at x-1,y-1"
        end
        if self.bitmap.get_pixel(x0,y0-1).alpha>0 && self.bitmap.get_pixel(x0,y0-1).alpha<255 && pass>1
          nextfound = true
          tmpx0,tmpy0 = x0,y0-1
          echoln "Found at x,y-1"
        end
        if self.bitmap.get_pixel(x0+1,y0-1).alpha>0 && self.bitmap.get_pixel(x0+1,y0-1).alpha<255
          nextfound = true
          tmpx0,tmpy0 = x0+1,y0-1
          echoln "Found at x+1,y-1"
        end
        if self.bitmap.get_pixel(x0+1,y0).alpha>0 && self.bitmap.get_pixel(x0+1,y0).alpha<255
          nextfound = true
          tmpx0,tmpy0 = x0+1,y0
          echoln "Found at x+1,y"
        end
        if self.bitmap.get_pixel(x0+1,y0+1).alpha>0 && self.bitmap.get_pixel(x0+1,y0+1).alpha<255
          nextfound = true
          tmpx0,tmpy0 = x0+1,y0+1
          echoln "Found at x+1,y+1"
        end
        if self.bitmap.get_pixel(x0,y0+1).alpha>0 && self.bitmap.get_pixel(x0,y0+1).alpha<255 && pass>1
          nextfound = true
          tmpx0,tmpy0 = x0,y0+1
          echoln "Found at x,y+1"
        end
        if self.bitmap.get_pixel(x0-1,y0+1).alpha>0 && self.bitmap.get_pixel(x0-1,y0+1).alpha<255 && pass>1
          nextfound = true
          tmpx0,tmpy0 = x0-1,y0+1
          echoln "Found at x-1,y+1"
        end
        if self.bitmap.get_pixel(x0-1,y0).alpha>0 && self.bitmap.get_pixel(x0-1,y0).alpha<255 && pass>1
          nextfound = true
          tmpx0,tmpy0 = x0-1,y0
          echoln "Found at x-1,y"
        end
        x0,y0 = tmpx0,tmpy0
        self.bitmap.set_pixel(x0,y0,c1) if nextfound == true
      end

=end
    end
  end

end


###############################################################################################
#
###############################################################################################
def pbRegisterPartnerWithPartyEV(trainerid,trainername,partyid=0,evhash = nil)
  Kernel.pbCancelVehicles
  trainer=pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject=PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  
  #party here
  if evhash!=nil && evhash.is_a?(Hash)
    echoln "Setting up EVS #{trainer[2]}"
    #looping over party
    for p in trainer[2]
      spfound=nil
      found = false
      evhash.keys.each {|species| if isConst?(p.species,PBSpecies,species);spfound=species;found=true;end;}
      echoln "Handling #{p.name}"
      if found
        echoln "Detected Species EV!"
        evs = evhash[spfound]
        for stat in evs.keys
          if [:hp,:attack,:defense,:spatk,:spdef,:speed].include?(stat)
            case stat
            when :hp
              p.ev[0]=evs[:hp]
            when :attack
              p.ev[1]=evs[:attack]
            when :defense
              p.ev[2]=evs[:defense]
            when :spatk
              p.ev[4]=evs[:spatk]
            when :spdef
              p.ev[5]=evs[:spdef]
            when :speed
              p.ev[3]=evs[:speed]
            end
          end
        end
      end
    end

    echoln "handled party"
  end

  for i in trainer[2]
    i.trainerID=trainerobject.id
    i.ot=trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partner=[trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end

def testEV
  pbRegisterPartnerWithPartyEV(PBTrainers::VERSILBUNKER,"Versil",0,{
    :CROBAT=>{
      :attack=>252,
      :defense =>4,
      :speed =>252
    },
    :REXQUIEM=>{
      :hp=>252,
      :attack=>252,
      :defense=>4
    },
    :FERALIGATR=>{
      :attack=>252,
      :speed=>252,
      :hp=>4
    },
    :WEAVILE=>{
      :attack=>252,
      :speed=>252,
      :defense=>4
    },
    :ENTEI=>{
      :attack=>252,
      :defense=>4,
      :speed=>252
    }
  })
end

EXPLICIT_FORM_EVOLUTIONS={
  [PBSpecies::GROWLITHE,1]=>[PBEvolution::Item,PBItems::ANCIENTSTONE,PBSpecies::ARCANINE],
  [PBSpecies::PIKACHU,1]=>[nil,nil,nil],
  [PBSpecies::PIKACHU,2]=>[nil,nil,nil],
  [PBSpecies::SALANDIT,1]=>[nil,nil,nil],
  [PBSpecies::INKAY,1]=>[nil,nil,nil],
  [PBSpecies::TORRACAT,1]=>[nil,nil,nil],
}

def pbCheckFormEvolution(pokemon)
  if EXPLICIT_FORM_EVOLUTIONS.has_key?([pokemon.species,pokemon.form])
    rt = yield pokemon,EXPLICIT_FORM_EVOLUTIONS[[pokemon.species,pokemon.form]][0],EXPLICIT_FORM_EVOLUTIONS[[pokemon.species,pokemon.form]][1],EXPLICIT_FORM_EVOLUTIONS[[pokemon.species,pokemon.form]][2]
    return [rt,0]
  end
  return [-1,-1]
end

def pbIsMegaStone?(item)
  if (isConst?(item,PBItems,:VENUSAURITE) ||
      isConst?(item,PBItems,:CHARIZARDITET) ||
      isConst?(item,PBItems,:CHARIZARDITEX) ||
      isConst?(item,PBItems,:BLASTOISINITE) ||
      isConst?(item,PBItems,:ABOMASITE) ||
      isConst?(item,PBItems,:ABSOLITE) ||
      isConst?(item,PBItems,:LINOONITE) ||
      isConst?(item,PBItems,:AERODACTYLITE) ||
      isConst?(item,PBItems,:AGGRONITE) ||
      isConst?(item,PBItems,:ALAKAZITE) ||
      isConst?(item,PBItems,:ALTARIANITE) ||
      isConst?(item,PBItems,:AMPHAROSITE) ||
      isConst?(item,PBItems,:AUDINITE) ||
      isConst?(item,PBItems,:BANETTITE) ||
      isConst?(item,PBItems,:BEEDRILLITE) ||
      isConst?(item,PBItems,:BLAZIKENITE) ||
      isConst?(item,PBItems,:CAMERUPTITE) ||
      isConst?(item,PBItems,:DIANCITE) ||
      isConst?(item,PBItems,:GALLADITE) ||
      isConst?(item,PBItems,:GARCHOMPITE) ||
      isConst?(item,PBItems,:GARDEVOIRITE) ||
      isConst?(item,PBItems,:GENGARITE) ||
      isConst?(item,PBItems,:GLALITITE) ||
      isConst?(item,PBItems,:GYARADOSITE) ||
      isConst?(item,PBItems,:HERACRONITE) ||
      isConst?(item,PBItems,:HOUNDOOMINITE) ||
      isConst?(item,PBItems,:KANGASKHANITE) ||
      isConst?(item,PBItems,:LATIASITE) ||
      isConst?(item,PBItems,:LATIOSITE) ||
      isConst?(item,PBItems,:LOPUNNITE) ||
      isConst?(item,PBItems,:LUCARITE) ||
      isConst?(item,PBItems,:MANECTITE) ||
      isConst?(item,PBItems,:MAWILITE) ||
      isConst?(item,PBItems,:MEDICHAMITE) ||
      isConst?(item,PBItems,:METAGROSSITE) ||
      isConst?(item,PBItems,:MEWTWONITEX) ||
      isConst?(item,PBItems,:MEWTWONITEY) ||
      isConst?(item,PBItems,:PIDGEOTITE) ||
      isConst?(item,PBItems,:PINSIRITE) ||
      isConst?(item,PBItems,:SABLENITE) ||
      isConst?(item,PBItems,:SALAMENCITE) ||
      isConst?(item,PBItems,:SCEPTILITE) ||
      isConst?(item,PBItems,:SCIZORITE) ||
      isConst?(item,PBItems,:SHARPEDONITE) ||
      isConst?(item,PBItems,:SLOWBRONITE) ||
      isConst?(item,PBItems,:STEELIXITE) ||
      isConst?(item,PBItems,:SWAMPERTITE) ||
      isConst?(item,PBItems,:TYRANITARITE) ||
      isConst?(item,PBItems,:SHIFTRYITE) ||
      isConst?(item,PBItems,:BELLOSSOMITE) ||
      isConst?(item,PBItems,:LUXRAYITE) ||
      isConst?(item,PBItems,:MIENSHAOITE) ||
      isConst?(item,PBItems,:RAMPARDITE) ||
      isConst?(item,PBItems,:ARCANITE))
    return true
  end
  return false
end

SWAPSTYLES = {
  PBSpecies::LUCARIO => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::GLACEON => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::LEAFEON => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::BIDOOF => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::PIKACHU => [proc {|x| x.form == 0 && [615,616].include?($game_map.map_id)},
                         proc {|x| x.form = 1 + [615,616].index($game_map.map_id)}],
  PBSpecies::CHARMANDER => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::CHARMELEON => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::CHARIZARD => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  
  PBSpecies::BULBASAUR => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::IVYSAUR => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::VENUSAUR => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  
  PBSpecies::SQUIRTLE => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::WARTORTLE => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  PBSpecies::BLASTOISE => [proc {|x| x.form == 0},proc {|x| x.form = 10}],
  
  PBSpecies::TREECKO => [proc {|x| x.form == 0},proc {|x| x.form = 2}],
  PBSpecies::GROVYLE => [proc {|x| x.form == 0},proc {|x| x.form = 2}],
  PBSpecies::SCEPTILE => [proc {|x| x.form == 0},proc {|x| x.form = 2}],

  
  PBSpecies::SKRAVROOM => [proc {|x| x.form == 0 && [615,616].include?($game_map.map_id)},
                         proc {|x| x.form = 1 + [615,616].index($game_map.map_id)}],
  PBSpecies::HYSTEARIC => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::WYSTEARIA => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::KOINKOIN => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::GACHIGACHOO => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::KROOKODILE => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::GRENINJA => [proc {|x| x.form == 0},proc {|x| x.form = 1}],

  
  PBSpecies::CYNDAQUIL => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::QUILAVA => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::TYPHLOSION => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  
  PBSpecies::CHIKORITA => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::BAYLEEF => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::MEGANIUM => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  
  PBSpecies::TOTODILE => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::CROCONAW => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::FERALIGATR => [proc {|x| x.form == 0},proc {|x| x.form = 1}],

  
  PBSpecies::DITTO => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::MRMIME => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::GENGAR => [proc {|x| x.form == 0},proc {|x| x.form = 2}],

  
  PBSpecies::LINOONE => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::INKAY => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::TORRACAT => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::SALANDIT => [proc {|x| x.form == 0},proc {|x| x.form = 1}],
  PBSpecies::XATU => [proc {|x| x.form == 0},proc {|x| x.form = 1}],

}

def pbMakeSwap(pokemon)
  return if !pbCheckSwapStyle(pokemon) #???? How the fuck did you make it here?
  SWAPSTYLES[pokemon.species][1].call(pokemon)
  return pokemon
end

def pbCheckSwapStyle(pokemon)
  if SWAPSTYLES.keys.include?(pokemon.species)
    return SWAPSTYLES[pokemon.species][0].call(pokemon)
  end
  return false
end

def pbSaveTries(time = 0)
  tries = $game_variables[200]
  File.open(RTP.getSaveFileName("#{$Trainer.id}_#{time}"),"w+"){|f| f.write(tries+1)}
end

def pbLoadTries(time = 0)
  if File.exists?(RTP.getSaveFileName("#{$Trainer.id}_#{time}"))
    $game_variables[200] = File.read(RTP.getSaveFileName("#{$Trainer.id}_#{time}")).to_i
  end
end

# Represents a window with no formatting capabilities.  Its text color can be set,
# though, and line breaks are supported, but the text is generally unformatted.
class Window_BrailleBox < Window_UnformattedTextPokemon
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  # Letter-by-letter mode.  This mode is not supported in this class.
  attr_accessor :letterbyletter
  attr_accessor :textHeight

  def text=(value)
    @text=value
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    self.contents.clear
    drawTextExH(self.contents,0,0,self.contents.width,0,
      @text.gsub(/[^ \n]/,"é"),Color.new(@baseColor.red,@baseColor.green,@baseColor.blue,@baseColor.alpha/5),Color.new(0,0,0,0),@textHeight)
    drawTextExH(self.contents,0,0,self.contents.width,0,
       @text.gsub(/\r/,""),@baseColor,@shadowColor,@textHeight)
  end

  def getLines(text,width,height = nil) #-TEXTPADDING*2
    return getLinesByTextAndValues(self.contents,text.gsub(/\r/,""),width,nil,true, height == nil ? @textHeight : height)
  end

end

def pbDisplayBrailleText(text = "",height = -1)
  @sprites = {}    
  @sprites["itemtextwindow"]=Window_BrailleBox.new("")
  @sprites["itemtextwindow"].x=36
  @sprites["itemtextwindow"].width=Graphics.width-72
  @sprites["itemtextwindow"].textHeight = height == -1 ? 36 : height
  @sprites["itemtextwindow"].height=228
  @sprites["itemtextwindow"].baseColor=Color.new(42,42,42)
  @sprites["itemtextwindow"].shadowColor=Color.new(0,0,0,0)
  pbSetFont(@sprites["itemtextwindow"].contents, "Braille Normal", 29)
  #linesCount = @sprites["itemtextwindow"].getLines(text)
  #linesCount = 4;
  linesCount = @sprites["itemtextwindow"].getLines(text,@sprites["itemtextwindow"].contents.width)

  echoln "#{text} - linesCount:#{linesCount}"
  @sprites["itemtextwindow"].y=172 - linesCount * 18
  @sprites["itemtextwindow"].height=30 + linesCount * 36
  @sprites["itemtextwindow"].visible=true
  #@sprites["itemtextwindow"].viewport=@viewport
  #@sprites["itemtextwindow"].windowskin=nil
  @sprites["itemtextwindow"].text = text
  
  #linecount = @sprites["itemtextwindow"].getLines(text,36)
  loop do
    Graphics.update
    Input.update

    if (Input.trigger?(Input::C)||Input.trigger?(Input::B))
      break
    end

  end

  #pbFadeOutAndHide(@sprites)
  @sprites.values.each {|x|
    x.opacity=0
    x.dispose
    Graphics.update
  }
  pbDisposeSpriteHash(@sprites)
  pbWait(5)
end

REGICE_SWITCH = 1420
REGIROCK_SWITCH = 1419
REGISTEEL_SWITCH = 1421
REGIELEKI_SWITCH = 1422
REGIDRAGO_SWITCH = 1423

def pbMirrorBattle(playerside = true)
  $trainerbossbattle = true
  if (playerside)
    trainer=PokeBattle_Trainer.new(_INTL("Vakuum"),$Trainer.gender == 0 ? PBTrainers::VAKUMFINALM : PBTrainers::VAKUMFINALF)
    trainer.setForeignID($Trainer) if $Trainer
    party = []
    for i in 0...$Trainer.party.length
      # Setting up the Pokemon
      pkmn = $Trainer.party[i].clone
      pkmn.level=pkmn.level
      party.push(pkmn)
    end
    trainer.party = party
    result = pbBossTrainerBattle([trainer,[],trainer.party],_INTL("..."),true)
  else
    tempTrainer = $Trainer.clone
    $Trainer=PokeBattle_Trainer.new(_INTL("Vakuum"),tempTrainer.gender == 0 ? PBTrainers::VAKUMFINALM : PBTrainers::VAKUMFINALF)
    $Trainer.setForeignID($Trainer) if $Trainer
    party = []
    for i in 0...tempTrainer.party.length
      # Setting up the Pokemon
      pkmn = tempTrainer.party[i].clone
      pkmn.level=pkmn.level
      party.push(pkmn)
    end
    $Trainer.party = party
    result = pbBossTrainerBattle([tempTrainer,[],tempTrainer.party],_INTL("..."),true)
    
    $Trainer = tempTrainer
  
  end
  $trainerbossbattle = false
  return result
end