################################################################################
# BOSS BATTLE
# Version: 1.0
# Date: 02/02/2017
# Developer: Fuji
# All rights reserved.
################################################################################

class PokeBattle_Pokemon
	attr_accessor	:boss
	attr_accessor	:hpMoltiplier
	attr_accessor	:bossBg
	
	def setBoss(hpMoltiplier,bossBg=nil)
		@boss = true
		@hpMoltiplier = hpMoltiplier
		@bossBg = bossBg
		calcStats
	end
	
	alias :initializeBb :initialize
	def initialize(a,b,c=nil,d=true)
		initializeBb(a,b,c,d)
		@boss = false
		@hpMoltiplier = 0
		@bossBg = nil
	end
	
	alias :calcStats_old :calcStats
	def calcStats(formchange = false)
    oldHp = self.hp
		calcStats_old(formchange)
		if @boss && self.hp>0
      echoln "=======> HP: #{self.hp} : #{oldHp} TOTALHP: #{@totalhp} NORMALHP: #{@normalhp}"
      #handles the normalhp in case there were stats overrides
      @normalhp = @statsOverride==nil ? @totalhp : @totalhp / @hpMoltiplier
      diff= @totalhp-oldHp
      #handles the totalhp in case there were stats overrides
			@totalhp *= @hpMoltiplier if @statsOverride==nil

      if (diff == 0)
        self.hp = @totalhp
      else
        diff= @totalhp-oldHp
        
        self.hp = @totalhp-diff
      end
      echoln "=======> HP: #{self.hp} : #{oldHp} TOTALHP: #{@totalhp} NORMALHP: #{@normalhp}"
		end
	end
  
  def denyBoss
    currHp = self.hp
    @boss = false
    @hpMoltiplier = 0
    @bossBg = nil
    calcStats
    self.hp = currHp
  end
  
  def canBeCaptured?
    return self.hp <= @normalhp if @boss
    return true
  end
end

class PokeBattle_Battler
	attr_accessor	:boss
	attr_accessor	:hpMoltiplier
	attr_accessor	:bossBg
	
	alias :pbInitPokemonBb :pbInitPokemon
	def pbInitPokemon(pkmn,pkmnIndex)
		pbInitPokemonBb(pkmn,pkmnIndex)
		@boss = pkmn.boss
		@hpMoltiplier = pkmn.hpMoltiplier
		@bossBg = pkmn.bossBg
    echoln "INITIALIZING NEW BOSS!"
	end
	
	def pbThis(lowercase=false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent
        return lowercase ? _INTL("the foe {1}",self.name) : _INTL("The foe {1}",self.name)
      elsif @boss
				return lowercase ? _INTL("the boss {1}",self.name) : _INTL("The boss {1}",self.name)
			else
        return lowercase ? _INTL("the wild {1}",self.name) : _INTL("The wild {1}",self.name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",self.name)
    else
      return lowercase ? _INTL("the ally {1}",self.name) : _INTL("The ally {1}",self.name)
    end
  end
end

def isXSpecies?(species)
  return isConst?(species,PBSpecies,:ELEKIDX) ||
		isConst?(species,PBSpecies,:ELECTABUZZX)||
		isConst?(species,PBSpecies,:ELECTABURST)||
    isConst?(species,PBSpecies,:SPIRITOMBX) ||
    isConst?(species,PBSpecies,:CARVANHAX) || 
    isConst?(species,PBSpecies,:SHARPEDOX) || 
    isConst?(species,PBSpecies,:PYUKUMUKUX) || 
    isConst?(species,PBSpecies,:PIKACHUX) || 
    isConst?(species,PBSpecies,:RAICHUX) ||
    isConst?(species,PBSpecies,:GALVANTULAX) ||
    isConst?(species,PBSpecies,:JOLTIKX) ||
		isConst?(species,PBSpecies,:SMEARGLEX) ||
		isConst?(species,PBSpecies,:CHIENTILLY) ||
    isConst?(species,PBSpecies,:SLURPUFFX) ||
    isConst?(species,PBSpecies,:GASTLYX) ||
    isConst?(species,PBSpecies,:HAUNTERX) ||
    isConst?(species,PBSpecies,:YAMASKX) ||
    isConst?(species,PBSpecies,:COFAGRIGUSX) ||
    isConst?(species,PBSpecies,:YAMASKX) ||
    isConst?(species,PBSpecies,:GIGASLURPUFFX) ||
    isConst?(species,PBSpecies,:MEWTWOX) ||
    isConst?(species,PBSpecies,:ROSERADEX) ||
    isConst?(species,PBSpecies,:PONYTAX) ||
		isConst?(species,PBSpecies,:RAPIDASHX) ||
		isConst?(species,PBSpecies,:RAPIDASHXBOSS) ||
		isConst?(species,PBSpecies,:RAPIDASHXBOSS2) ||
    isConst?(species,PBSpecies,:CACNEAX) ||
    isConst?(species,PBSpecies,:CACTURNEX) ||
    isConst?(species,PBSpecies,:SWIRLIXX) ||
    isConst?(species,PBSpecies,:BUDEWX) ||
    isConst?(species,PBSpecies,:ROSELIAX) ||
    isConst?(species,PBSpecies,:ROSERADEX) ||
    isConst?(species,PBSpecies,:MAREANIEX) ||
    isConst?(species,PBSpecies,:TOXAPEXX) ||
    isConst?(species,PBSpecies,:LUCARIOX) ||
    isConst?(species,PBSpecies,:BISHARPX) ||
    isConst?(species,PBSpecies,:SCOVILEX) ||
    isConst?(species,PBSpecies,:TYRANITARX) ||
    isConst?(species,PBSpecies,:MEWTWOX) ||
    isConst?(species,PBSpecies,:TAPUKOKOX) ||
    isConst?(species,PBSpecies,:TAPULELEX) ||
    isConst?(species,PBSpecies,:TAPUBULUX) ||
    isConst?(species,PBSpecies,:TAPUFINIX) ||
    isConst?(species,PBSpecies,:PIKACHUX) ||
    isConst?(species,PBSpecies,:GENGARX) ||
    isConst?(species,PBSpecies,:DRAGALISK) ||
	  isConst?(species,PBSpecies,:VERSILDRAGALISK) ||
		isConst?(species,PBSpecies,:VAKUM) ||
    isConst?(species,PBSpecies,:GRENINJAX)||
    isConst?(species,PBSpecies,:DITTOX) ||
    isConst?(species,PBSpecies,:AEGISLASHX)||
    isConst?(species,PBSpecies,:DRAGALISKFURIA)||
    isConst?(species,PBSpecies,:SHYLEONP)||
    isConst?(species,PBSpecies,:TRISHOUTP)||
    isConst?(species,PBSpecies,:SHULONGP)
end
  
SPECIEX = [
  PBSpecies::ELEKIDX,
	PBSpecies::SHARPEDOX,
	PBSpecies::GENGARX,
	PBSpecies::GALVANTULAX,
  PBSpecies::SHYLEON,
  PBSpecies::SHULONG,
  PBSpecies::TRISHOUT,
  PBSpecies::JOLTIKX,
  PBSpecies::SLURPUFFX,
  PBSpecies::GIGASLURPUFFX,
  PBSpecies::MEWTWOX,
  PBSpecies::ROSERADEX,
	PBSpecies::RAPIDASHX,
  PBSpecies::RAPIDASHXBOSS,
	PBSpecies::RAPIDASHXBOSS2,
  PBSpecies::DRAGALISK,
  PBSpecies::VERSILDRAGALISK,
  PBSpecies::LUXFLON,
	PBSpecies::VAKUM,
  PBSpecies::GRENINJAX,
  PBSpecies::DITTOX,
  PBSpecies::AEGISLASHX
]
def pbCheckMakeX(pokemon)
  return -1 if pokemon.species <= 0 || pokemon.isEgg?
  makex = {:BISHARP=>:BISHARPX, :SCOVILE=>:SCOVILEX, :TYRANITAR=>:TYRANITARX}
  for i in makex.keys
    return getConst(PBSpecies,makex[i]) if pokemon.species == getConst(PBSpecies,i)
  end
  return -1
end

def pbTransformToX(pokemon)
  makex = {:BISHARP=>:BISHARPX, :SCOVILE=>:SCOVILEX, :TYRANITAR=>:TYRANITARX}
  return if !makex.keys.any?{|species| getConst(PBSpecies,species) == pokemon.species}
  newSp = 0
  for i in makex.keys
    if getConst(PBSpecies,i) == pokemon.species
      newSp = makex[i]
      break
    end
  end
  p = pokemon.clone
  p.species = getConst(PBSpecies,newSp)
  p.calcStats

  p.resetMoves

  $Trainer.seen[p.species]=true
  $Trainer.owned[p.species]=true
  pbSeenForm(p)

  return p
end

def pbTestX
  $Trainer.party[0].moves[0]=PBMove.new(734)
  pbWildBattle(:ABSOL,25)
end

def hasSpeciesX?(poke)
  ret = false
  for i in 0...SPECIEX.length
    next if poke.species != SPECIEX[i]
    if poke.species == SPECIEX[i]
      ret = true
      break
    end
  end
  return ret
end  

class BossArray < Array
	def visible=(val)
		self.each_index do |key|
      next if !self[key]
      self[key].visible = val
    end
	end
	
	def color=(val)
		self.each_index do |key|
      next if !self[key]
      self[key].color = val
    end
	end
  
  def disposed?
    self.each_index do |i|
      self[i].dispose
    end
  end
	
	def opacity=(val)
		self.each_index do |key|
      #@next if key=="mega" && !@battler.isMega?
      next if !self[key]
      self[key].opacity = val
      self[key].opacity *= 0.25 if key=="shadow"
    end
	end
end

class PokeBattle_Battle
  
  
  alias pbStartBattleCore_ebs pbStartBattleCore unless self.method_defined?(:pbStartBattleCore_ebs)
  def pbStartBattleCore(canlose)
    Graphics.frame_rate = 60
    if !@fullparty1 && @party1.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    #$smAnim = false if ($smAnim && @doublebattle) || EBUISTYLE!=2
    $smAnim = true if $game_switches[85] && (containsNewBosses?(@party2) ? true : !@doublebattle) && !isAuraDraga?()
    if !@opponent
    #========================
    # Initialize wild Pokémon
    #========================
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        if $game_switches[DRAGALISK_UNBEATABLE]==true
          @battlers[1].stages[PBStats::EVASION] = 500
        end
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        @scene.sendingOut=true
        echoln "IS BOSS? #{wildpoke.boss}"
				###
				if wildpoke.boss && !isAuraDraga?()
					pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!",wildpoke.name))
          # GRENINJAX END SENDOUT
          if NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false) #NEWBOSSES.include?($wildSpecies)
            @scene.newBossSequence.finish if @scene.newBossSequence
            @scene.newBossSequence.sendout if @scene.newBossSequence
          else
            @scene.vsBossSequence2_end #if !(wildpoke.species == PBSpecies::DRAGALISK && wildpoke.form > 0)
            @scene.vsBossSequence2_sendout #if !(wildpoke.species == PBSpecies::DRAGALISK && wildpoke.form > 0)
          end
        else
					pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
				end
				###
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        wildpoke=@party2[0]
        if wildpoke.boss && !isAuraDraga?()
          if defined?($dittoxbattle) && $dittoxbattle
            pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!","Ditto X"))
					else
            pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!",wildpoke.name))
          end
          # GRENINJAX END SENDOUT
          if NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false) #NEWBOSSES.include?($wildSpecies)
            @scene.newBossSequence.finish if @scene.newBossSequence
            @scene.newBossSequence.sendout if @scene.newBossSequence
          else
            @scene.vsBossSequence2_end #if !(wildpoke.species == PBSpecies::DRAGALISK && wildpoke.form > 0)
            @scene.vsBossSequence2_sendout #if !(wildpoke.species == PBSpecies::DRAGALISK && wildpoke.form > 0)
          end
        else
          pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
            @party2[0].name,@party2[1].name))
        end
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
    #=======================================
    # Initialize opponents in double battles
    #=======================================
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      @scene.sendingOut=true
      if @opponent.is_a?(Array)
        pbDisplayPaused(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2 < 0
        @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        @scene.smTrainerSequence.finish if @scene.smTrainerSequence
        pbDisplayBrief(_INTL("{1} sent\r out {2}! {3} sent\r out {4}!",@opponent[0].fullname,getBattlerPokemon(@battlers[1]).name,@opponent[1].fullname,getBattlerPokemon(@battlers[3]).name))
        pbSendOutInitial(@doublebattle,1,@party2[sendout1],3,@party2[sendout2])
      else
        if (!self.is_a?(PokeBattle_CableClub) && !self.is_a?(PokeBattle_SpectateCableClub))
          pbDisplayPaused(_INTL("{1}\r\nvuole combattere!",@opponent.fullname))
        else
          pbDisplayBrief(_INTL("{1}\r\nvuole combattere!",@opponent.fullname))
        end
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        
        if @party2[sendout1].species == getID(PBSpecies,:PAWNIARDAB)
          @party2[sendout1].totalHp=9999999
          @party2[sendout1].hp=9999999
					@party2[sendout1].attack=90000
        end
        
        if @party2[sendout2].species == getID(PBSpecies,:PAWNIARDAB)
          @party2[sendout2].totalHp=9999999 
          @party2[sendout2].hp=9999999
					@party2[sendout2].attack=90000
        end
        
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        @scene.smTrainerSequence.finish if @scene.smTrainerSequence
        pbDisplayBrief(_INTL("{1} sent\r out {2} and {3}!",
           @opponent.fullname,getBattlerPokemon(@battlers[1]).name,getBattlerPokemon(@battlers[3]).name))
        pbSendOutInitial(@doublebattle,1,@party2[sendout1],3,@party2[sendout2])
      end
    else
    #======================================
    # Initialize opponent in single battles
    #======================================
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout < 0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[0]
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      @scene.pbStartBattle(self)
      @scene.sendingOut=true
      pbDisplayPaused(_INTL("{1}\r\nvuole combattere!",@opponent.fullname))
      @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
      @scene.smTrainerSequence.finish if @scene.smTrainerSequence
      pbDisplayBrief(_INTL("{1} sent\r out {2}!",@opponent.fullname,getBattlerPokemon(@battlers[1]).name))
      pbSendOutInitial(@doublebattle,1,trainerpoke)
    end
    #=====================================
    # Initialize players in double battles
    #=====================================
    if @doublebattle
      @scene.sendingOut=true
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2 < 0
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
           @player[1].fullname,getBattlerPokemon(@battlers[2]).name,getBattlerPokemon(@battlers[0]).name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Player doesn't have two unfainted Pokémon")
        end
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("Go! {1} and {2}!",getBattlerPokemon(@battlers[0]).name,getBattlerPokemon(@battlers[2]).name))
      end
      pbSendOutInitial(@doublebattle,0,@party1[sendout1],2,@party1[sendout2])
    else
    #====================================
    # Initialize player in single battles
    #====================================
      @scene.sendingOut=true
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout < 0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbDisplayBrief(_INTL("Go! {1}!",getBattlerPokemon(@battlers[0]).name))
      pbSendOutInitial(@doublebattle,0,playerpoke)
    end
    #====================================
    # Displays a message for notifying stat increase
    #====================================
    if wildpoke != nil && wildpoke.boss
      pbDisplay(_INTL("Le statistiche del Pokémon nemico sono più elevate!"))
    end
    #==================
    # Initialize battle
    #==================
    if @weather==PBWeather::SUNNYDAY
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::SANDSTORM
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbDisplay(_INTL("Hail is falling."))
    elsif PBWeather.const_defined?(:HEAVYRAIN) && @weather==PBWeather::HEAVYRAIN
      pbDisplay(_INTL("It is raining heavily."))
    elsif PBWeather.const_defined?(:HARSHSUN) && @weather==PBWeather::HARSHSUN
      pbDisplay(_INTL("The sunlight is extremely harsh."))
    elsif PBWeather.const_defined?(:STRONGWINDS) && @weather==PBWeather::STRONGWINDS
      pbDisplay(_INTL("The wind is strong."))
    end
    pbOnActiveAll   # Abilities
    @turncount=0
    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
			for i in 0...@battlers.length
				if @battlers[i]!=nil
					echoln "#{i} type 1 is #{@battlers[i].type1}"
					echoln "#{i} type 2 is #{@battlers[i].type2}"
					echoln "#{i} has fire type? #{@battlers[i].pbHasType?(:FIRE)}"
					echoln "#{i} has laser focus? #{@battlers[i].effects[PBEffects::LaserFocus]}"
				end
			end
      if @debug && @turncount >=100
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 100 rounds]")
        pbAbort
        break
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      break if @decision > 0
      PBDebug.logonerr{
         pbAttackPhase
      }
      break if @decision > 0
      @scene.clearMessageWindow
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision > 0
      @turncount+=1
			
			break if @turncount == DRAGALISK_BATTLE_MAXTURNS && $game_switches[DRAGALISK_UNBEATABLE]==true
    end
    return pbEndOfBattle(canlose)
  end
end

class NextGenDataBox  <  SpriteWrapper
	alias :initialize_bb :initialize
	def initialize(battler,doublebattle,viewport=nil,player=nil,scene=nil,boss=true,bossMul=4)
		initialize_bb(battler,doublebattle,viewport,player,scene)
		@boss = @battler.boss
		@bossMultiplier = @battler.hpMoltiplier
	end
	
	def setUp
    # reset of the set-up procedure
    @loaded = false
    @showing = false
    @second = false
    pbDisposeSpriteHash(@sprites)
    @sprites.clear
    # initializes all the necessary components
		@sprites["bg"] = Sprite.new(@viewport)
		if @battler.boss && !@battler.bossBg.nil?
			#@sprites["bg"].bitmap = pbBitmap(@path+"bgs/"+@battler.bossBg)
		end
		
    @sprites["mega"] = Sprite.new(@viewport)
    @sprites["mega"].opacity = 0
    
    @sprites["gender"] = Sprite.new(@viewport)
    @sprites["gender"].zoom_x = 0.5
    @sprites["gender"].zoom_y = 0.5
    @sprites["layer1"] = Sprite.new(@viewport)
    @sprites["layer1"].bitmap = pbBitmap(@path+"HPBAR_SQUARE (multiply)")
    @sprites["layer1"].src_rect.height = 64 if !@showexp
    #@sprites["layer1"].mirror = !@playerpoke
    
    @sprites["shadow"] = Sprite.new(@viewport)
    @sprites["shadow"].bitmap = Bitmap.new(@sprites["layer1"].bitmap.width,@sprites["layer1"].bitmap.height)
    @sprites["shadow"].z = -1
    @sprites["shadow"].opacity = 255*0.25
    @sprites["shadow"].color = Color.new(0,0,0,255)
    
    @sprites["hpbg"] = Sprite.new(@viewport)
    @hpBarBmp = pbBitmap(@path+"HPBAR_KO")
    @sprites["hpbg"].bitmap = @hpBarBmp#Bitmap.new(@hpBarBmp.width,@hpBarBmp.height)
    #@sprites["hpbg"].mirror = !@playerpoke
    #renew boss status
    @boss = @battler.boss
		if @boss
      #Renew multiplier
      @bossMultiplier = @battler.hpMoltiplier
			@hpBars = Array.new
			echoln("BARS ARE #{@bossMultiplier-1}")
			for i in 0...@bossMultiplier
				@hpBars[i]=pbBitmap(@path+"HPBAR_FULL")
			end
			@sprites["hp2"] = Sprite.new(@viewport)
			@hpBarBmp = pbBitmap(@path+"HPBAR_FULL")
			@sprites["hp2"].bitmap = Bitmap.new(@hpBarBmp.width,@hpBarBmp.height)
			@sprites["hp2"].mirror = !@playerpoke
			@sprites["hp2"].opacity = 100
			
			@sprites["hp"] = Sprite.new(@viewport)
			@sprites["hp"].bitmap = Bitmap.new(@hpBarBmp.width,@hpBarBmp.height)
			@sprites["hp"].mirror = !@playerpoke

			@sprites["hp_point"] = BossArray.new
			@pointsBitmap = Array.new
			@noPointBitmap = Bitmap.new(24,4)#pbBitmap(@path+"BOSSHPBAR_EXPIRED")
			for i in 0...@bossMultiplier-1
				@pointsBitmap[i] = pbBitmap(@path+"BOSSHPBAR_SINGLE")
				@sprites["hp_point"][i] = Sprite.new(@viewport)
				@sprites["hp_point"][i].bitmap = Bitmap.new(@noPointBitmap.width,@noPointBitmap.height)
			end
		else
			@sprites["hp"] = Sprite.new(@viewport)
			@hpBarBmp = pbBitmap(@path+"HPBAR_FULL")
			@sprites["hp"].bitmap = Bitmap.new(@hpBarBmp.width,@hpBarBmp.height)
			#@sprites["hp"].mirror = !@playerpoke
		end
    
    @sprites["expbg"] = Sprite.new(@viewport)
    @sprites["expbg"].bitmap = pbBitmap(@path+"EXPBAR_EMPTY")
    @sprites["expbg"].src_rect.y = @sprites["expbg"].bitmap.height*-1 if !@showexp
    @sprites["expbg"].src_rect.width = 0 if @boss || @battler.index%2!=0
    
    @sprites["exp"] = Sprite.new(@viewport)
    @sprites["exp"].bitmap = pbBitmap(@path+"EXPBAR_FULL")
    @sprites["exp"].src_rect.y = @sprites["exp"].bitmap.height*-1 if !@showexp
    @sprites["exp"].src_rect.width = 0 if @boss || @battler.index%2!=0
    
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(@sprites["layer1"].bitmap.width+500,@sprites["layer1"].bitmap.height+500)
    @sprites["text"].z = 9
    pbSetSystemFont(@sprites["text"].bitmap)
    
    #self.opacity = 255
  end
	
	def updateHpBar
		if (@boss)

			# updates the current state of the HP bar
			# the bar's colour hue gets dynamically adjusted (i.e. not through sprites)
			# HP bar is mirrored for opposing Pokemon
			#hpbar = @battler.totalhp==0 ? 0 : (1.0*(self.hp % (@bossMultiplier-1)-1)*@sprites["hp"].bitmap.width/(@battler.totalhp / @bossMultiplier)).ceil
			normalHp = (1.0 * @battler.totalhp / @bossMultiplier)
      currHp = self.hp % normalHp.to_i == 0 ? self.hp / @bossMultiplier : self.hp % normalHp.ceil.to_i
      #echoln "#{@battler.name} ::: CurrHP info :: currHp:#{currHp} "
      #echoln "cond:#{self.hp % normalHp == 0} - r1: #{self.hp} / #{@bossMultiplier} = #{self.hp / @bossMultiplier} - r2: #{self.hp} % #{normalHp} = #{self.hp % normalHp}"
      hpbar = @battler.totalhp == 0 ? 0 : (1.0*currHp*@sprites["hp"].bitmap.width/normalHp).ceil
      remainingPoints = (self.hp / normalHp).ceil.to_i - 1
      #echoln "#{@battler.name} ::: Remaining Points:#{remainingPoints}(#{self.hp % (@battler.totalhp/@bossMultiplier)}) Hp:#{self.hp} TotalHp:#{@battler.totalhp} Multiplier:#{@bossMultiplier}"
			#echoln "#{@battler.name} ::: Graphics info: hpbar:#{hpbar} - currHp:#{currHp} - width:#{@sprites["hp"].bitmap.width} - normalHp:#{normalHp}"
      #echoln("#{remainingPoints.to_s} - #{self.hp.to_s}/#{normalHp.to_s}")
			
			@sprites["hp_point"].each_index do |i|
				@sprites["hp_point"][i].bitmap.clear
				if (remainingPoints > i)
					#echoln("Remain: #{remainingPoints.to_s} - i: #{i.to_s} - #{@pointsBitmap[i].to_s}")
					#echoln("Array: #{@pointsBitmap.inspect}")
					@sprites["hp_point"][i].bitmap.blt(0,0,@pointsBitmap[i],Rect.new(0,0,@noPointBitmap.width,@noPointBitmap.height))
				else
					@sprites["hp_point"][i].bitmap.blt(0,0,@noPointBitmap,Rect.new(0,0,@noPointBitmap.width,@noPointBitmap.height))
				end
			end

			@sprites["hp"].src_rect.x = @sprites["hp"].bitmap.width - hpbar if !@playerpoke
			@sprites["hp"].src_rect.width = hpbar
			hue = (0-120)*(1-(self.hp.to_f/@battler.totalhp))
			@sprites["hp"].bitmap.clear
			@sprites["hp"].bitmap.blt(0,0,@hpBars[remainingPoints],Rect.new(0,0,@hpBarBmp.width,@hpBarBmp.height))
			@sprites["hp"].bitmap.hue_change(hue) if remainingPoints == 0

			# Set the bar bg (brutto)
			if remainingPoints > 0
				@sprites["hp2"].src_rect.x = 0 #@sprites["hp"].bitmap.width - 188 if !@playerpoke
				@sprites["hp2"].src_rect.width = 171
				@sprites["hp2"].bitmap.clear
				@sprites["hp2"].bitmap.blt(0,0,@hpBars[remainingPoints-1],Rect.new(0,0,@hpBarBmp.width,@hpBarBmp.height))
				@sprites["hp2"].visible = true
			else
				@sprites["hp2"].visible = false
			end
		else
			# updates the current state of the HP bar
			# the bar's colour hue gets dynamically adjusted (i.e. not through sprites)
			# HP bar is mirrored for opposing Pokemon
			hpbar = @battler.totalhp==0 ? 0 : (1.0*self.hp*@sprites["hp"].bitmap.width/@battler.totalhp).ceil
			#@sprites["hp"].src_rect.x = @sprites["hp"].bitmap.width - hpbar if !@playerpoke
			@sprites["hp"].src_rect.width = hpbar
			hue = (0-120)*(1-(self.hp.to_f/@battler.totalhp))
			@sprites["hp"].bitmap.clear
			@sprites["hp"].bitmap.blt(0,0,@hpBarBmp,Rect.new(0,0,@hpBarBmp.width,@hpBarBmp.height))
			@sprites["hp"].bitmap.hue_change(hue)
		end
  end
	
	alias :x_old :x=
	def x=(val)
		return if !@loaded
		x_old(val)
		if @boss
			@sprites["bg"].x = @sprites["layer1"].x
			@sprites["hp2"].x = @sprites["layer1"].x + 11# + 23 + (!@playerpoke ? 4 : 0)
			@sprites["hp_point"].each_index do |i|
				@sprites["hp_point"][i].x = @sprites["layer1"].x + 12 + (!@playerpoke ? 4 : 0) + (i * 28)
			end
		end
	end
	
	alias :y_old :y=
	def y=(val)
		return if !@loaded
		y_old(val)
		if @boss
			@sprites["bg"].y = @sprites["layer1"].y
			@sprites["hp2"].y = @sprites["layer1"].y - 6
			@sprites["hp_point"].each_index do |i|
				@sprites["hp_point"][i].y = @sprites["layer1"].y + 8
			end
		end
	end
	
end

#===============================================================================
# Sun Moon Animation for Boss Battles
#===============================================================================
class PokeBattle_Scene
  def vsBossSequenceSM_start(viewport,dexNum)
    @vs = {}
    
    @vs["bg"] = ScrollingSprite.new(viewport)
    @vs["bg"].setBitmap("Graphics/Transitions/smBgBoss#{dexNum}")
    @vs["bg"].color = Color.new(0,0,0,255)
    @vs["bg"].speed = 0
    @vs["bg"].ox = @vs["bg"].src_rect.width/2
    @vs["bg"].oy = @vs["bg"].src_rect.height/2
    @vs["bg"].x = viewport.rect.width/2
    @vs["bg"].y = viewport.rect.height/2
    @vs["bg"].angle = - 8 if $PokemonSystem.screensize < 2  
    @vs["bg"].z = 200
  
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
		
      @vsFp["ring"] = Sprite.new(viewport)
      @vsFp["ring"].bitmap = pbBitmap("Graphics/Transitions/smRing")
      @vsFp["ring"].ox = @vsFp["ring"].bitmap.width/2
      @vsFp["ring"].oy = @vsFp["ring"].bitmap.height/2
      @vsFp["ring"].x = viewport.rect.width/2
      @vsFp["ring"].y = viewport.rect.height
      @vsFp["ring"].zoom_x = 0
      @vsFp["ring"].zoom_y = 0
      @vsFp["ring"].z = 500
      
      for j in 0...32
        @vsFp["s#{j}"] = Sprite.new(@viewport)
        @vsFp["s#{j}"].bitmap = pbBitmap("Graphics/Transitions/smSpec")
        @vsFp["s#{j}"].ox = @vsFp["s#{j}"].bitmap.width/2
        @vsFp["s#{j}"].oy = @vsFp["s#{j}"].bitmap.height/2
        @vsFp["s#{j}"].opacity = 0
        @vsFp["s#{j}"].z = 220
        @fpDx.push(0)
        @fpDy.push(0)
      end
      
      @fpSpeed = []
      @fpOpac = []
      for j in 0...3
        k = j+1
        speed = 2 + rand(5)
        @vsFp["p#{j}"] = ScrollingSprite.new(viewport)
        @vsFp["p#{j}"].setBitmap("Graphics/Transitions/smSpecEff#{k}")
        @vsFp["p#{j}"].speed = speed*4
        @vsFp["p#{j}"].direction = -1
        @vsFp["p#{j}"].opacity = 0
        @vsFp["p#{j}"].z = 400
        @vsFp["p#{j}"].zoom_y = 1 + rand(10)*0.005
        @fpSpeed.push(speed)
        @fpOpac.push(4) if j > 0
      end
    
    
    @vs["shade"] = Sprite.new(viewport)
    @vs["shade"].z = 250
    @vs["glow"] = Sprite.new(viewport)
    @vs["glow"].y = viewport.rect.height
    @vs["glow"].z = 250
    @vs["glow2"] = Sprite.new(viewport)
    @vs["glow2"].x = viewport.rect.width/2
    @vs["glow2"].z = 250
  
    @vs["boss"] = Sprite.new(viewport)
    @vs["boss"].z = 350
    @vs["boss"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["boss"].ox = @vs["boss"].bitmap.width/2
    @vs["boss"].oy = @vs["boss"].bitmap.height/2
    @vs["boss"].x = @vs["boss"].ox
    @vs["boss"].y = @vs["boss"].oy
    @vs["boss"].tone = Tone.new(255,255,255)
    @vs["boss"].zoom_x = 1.32
    @vs["boss"].zoom_y = 1.32
    @vs["boss"].opacity = 0
  
    bmp = pbBitmap("Graphics/Transitions/smBoss#{dexNum}")
    ox = (@vs["boss"].bitmap.width - bmp.width)/2
    oy = (@vs["boss"].bitmap.height - bmp.height)/2
    @vs["boss"].bitmap.blt(ox,oy,bmp,Rect.new(0,0,bmp.width,bmp.height))
    bmp = @vs["boss"].bitmap.clone
  
    @vs["shade"].bitmap = bmp.clone
    @vs["shade"].color = Color.new(10,169,245,224)
    @vs["shade"].opacity = 0
  
    @vs["glow"].bitmap = bmp.clone
    @vs["glow"].glow(Color.new(0,0,0),35,false)
    @vs["glow"].src_rect.set(0,viewport.rect.height,viewport.rect.width/2,0)
    @vs["glow2"].bitmap = @vs["glow"].bitmap.clone
    @vs["glow2"].src_rect.set(viewport.rect.width/2,0,viewport.rect.width/2,0)
  
    @vs["overlay"] = Sprite.new(viewport)
    @vs["overlay"].z = 999# + 200
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["overlay"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["overlay"].opacity = 0
    16.times do
      @vs["boss"].zoom_x -= 0.02
      @vs["boss"].zoom_y -= 0.02
      @vs["boss"].opacity += 32
      Graphics.update
    end
    @vs["boss"].zoom_x = 1; @vs["boss"].zoom_y = 1
    @commandWindow.drawLineup if !defined?(SCREENDUALHEIGHT)
    @commandWindow.lineupY(-32) if !defined?(SCREENDUALHEIGHT)
    for i in 0...16
      @commandWindow.showArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["boss"].tone.red -= 16
      @vs["boss"].tone.green -= 16
      @vs["boss"].tone.blue -= 16
      @vs["bg"].color.alpha -= 16
      self.vsSequenceSM_update
      Graphics.update
    end
    16.times do
      self.vsSequenceSM_update
      Graphics.update
    end
    for i in 0...16
      @vs["boss"].tone.red -= 32*(i < 8 ? -1 : 1)
      @vs["boss"].tone.green -= 32*(i < 8 ? -1 : 1)
      @vs["boss"].tone.blue -= 32*(i < 8 ? -1 : 1)
      #@vs["bg"].speed = 16 if i == 8
      for j in 0...3
        next if i != 8
        @vsFp["p#{j}"].speed /= 4
      end
      self.vsSequenceSM_update
      Graphics.update
    end
    16.times do
      @vs["glow"].src_rect.height += 24
      @vs["glow"].src_rect.y -= 24
      @vs["glow"].y -= 24
      @vs["glow2"].src_rect.height += 24
      self.vsSequenceSM_update
      Graphics.update
    end
    8.times do
      @vs["glow"].tone.red += 32
      @vs["glow"].tone.green += 32
      @vs["glow"].tone.blue += 32
      @vs["glow2"].tone.red += 32
      @vs["glow2"].tone.green += 32
      @vs["glow2"].tone.blue += 32
      self.vsSequenceSM_update
      Graphics.update
    end
    for i in 0...4
      @vs["boss"].tone.red += 64
      @vs["boss"].tone.green += 64
      @vs["boss"].tone.blue += 64
      self.vsSequenceSM_update
      Graphics.update
    end
    for j in 0...3
      @vsFp["p#{j}"].z = 300
    end
    for i in 0...8
      @vs["boss"].tone.red -= 32
      @vs["boss"].tone.green -= 32
      @vs["boss"].tone.blue -= 32
      @vs["shade"].opacity += 32
      @vs["shade"].x -= 4
      self.vsSequenceSM_update
      Graphics.update
    end
  end

  def vsBossSequenceSM_update
    @vs["bg"].update if @vs["bg"] && !@vs["bg"].disposed?
    for j in 0...32
      next if !@vsFp["s#{j}"] || @vsFp["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @vsFp["s#{j}"].opacity <= 1
        width = @vs["bg"].viewport.rect.width
        height = @vs["bg"].viewport.rect.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @vsFp["s#{j}"].zoom_x = z
        @vsFp["s#{j}"].zoom_y = z
        @vsFp["s#{j}"].x = x
        @vsFp["s#{j}"].y = y
        @vsFp["s#{j}"].opacity = 255
        @vsFp["s#{j}"].angle = rand(360)
      end
      @vsFp["s#{j}"].x -= (@vsFp["s#{j}"].x - @fpDx[j])*0.05
      @vsFp["s#{j}"].y -= (@vsFp["s#{j}"].y - @fpDy[j])*0.05
      @vsFp["s#{j}"].opacity -= @vsFp["s#{j}"].opacity*0.05
      @vsFp["s#{j}"].zoom_x -= @vsFp["s#{j}"].zoom_x*0.05
      @vsFp["s#{j}"].zoom_y -= @vsFp["s#{j}"].zoom_y*0.05
    end
    for j in 0...3
      next if !@vsFp["p#{j}"] || @vsFp["p#{j}"].disposed?
      @vsFp["p#{j}"].update
      if j == 0
        @vsFp["p#{j}"].opacity += 5 if @vsFp["p#{j}"].opacity < 155
      else
        @vsFp["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@vsFp["p#{j}"].opacity >= 255 || @vsFp["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 128
  end

  def vsBossSequenceSM_end
    viewport = @viewport
    zoom = 4.0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["bg"].speed = 32
    for j in 0...3
      @vsFp["p#{j}"].speed *= 4
    end
    for i in 0..20
      @vs["boss"].x += 6*(i/5 + 1)
      @vs["glow"].x += 6*(i/5 + 1)
      @vs["glow2"].x += 6*(i/5 + 1)
      @commandWindow.hideArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity += 64
      zoom -= 4.0/20
      self.vsSequenceSM_update
      @vs["shade"].opacity -= 16
      Graphics.update
    end
    @commandWindow.lineupY(+32) if !defined?(SCREENDUALHEIGHT)
    pbDisposeSpriteHash(@vs)  
    pbDisposeSpriteHash(@vsFp)
    @vs["overlay"] = Sprite.new(@msgview)
    @vs["overlay"].z = 9999999
    @vs["overlay"].bitmap = Bitmap.new(@msgview.rect.width,@msgview.rect.height)
    @vs["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,@msgview.rect.height,Color.new(0,0,0))
  end

  def vsBossSequenceSM_sendout
    $smAnim = false
    viewport = @msgview
    zoom = 0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    21.times do
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity -= 12.8
      zoom += 4.0/20
      wait(1,true)
    end
    @vs["overlay"].dispose
  end
  
  def vsBossSequence2_start(viewport,species)
    @smSpecial = false
    evil = false
    trainerid=79
    num=[]
    for poke in X_SPECIES
      num.push(getConst(PBSpecies,poke))
    end
    
    directory = ["Graphics/Transitions/X/Elekid X/",
               "Graphics/Transitions/X/Galvantula X/",
               "Graphics/Transitions/X/Gengar X/",
               "Graphics/Transitions/X/Sharpedo X/",
               "Graphics/Transitions/X/Shulong X/",
               "Graphics/Transitions/X/Trishout X/",
               "Graphics/Transitions/X/Shyleon X/",
               "Graphics/Transitions/X/Slurpuff X/",
               "Graphics/Transitions/X/Slurpuff X/",
               "Graphics/Transitions/X/Mewtwo X/",
							 "Graphics/Transitions/X/Roserade X/",
							 "Graphics/Transitions/X/Rapidash X Normal/",
							 "Graphics/Transitions/X/Rapidash X Normal/",
							 "Graphics/Transitions/X/Rapidash X Berserk/",
               "Graphics/Transitions/X/Dragalisk/",
               "Graphics/Transitions/X/VersilDragalisk/",
							 "Graphics/Transitions/X/Luxflon/",
							 "Graphics/Transitions/X/Vakum/",
               "Graphics/Transitions/X/Aegislash X/",]
		
    @vs = {}
  
    bgstring = "Graphics/Transitions/smBg#{trainerid}"
    bgstring2 = "Graphics/Transitions/smBgNext#{trainerid}"
    bgstring3 = "Graphics/Transitions/smBgLast#{trainerid}"
    
    @vs["bg"] = @smSpecial ? RainbowSprite.new(viewport) : ScrollingSprite.new(viewport)
    for bg in 0...X_SPECIES.length
      if num[bg] == species 
        @vs["bg"].setBitmap(directory[bg] + "smBgEvil")
      end
    end    
    @vs["bg"].color = Color.new(0,0,0,255)
    @vs["bg"].speed = @smSpecial ? 4 : 32
    @vs["bg"].ox = @vs["bg"].src_rect.width/2
    @vs["bg"].oy = @vs["bg"].src_rect.height/2
    @vs["bg"].x = viewport.rect.width/2
    @vs["bg"].y = viewport.rect.height/2
    @vs["bg"].angle = - 8 if !@smSpecial && $PokemonSystem.screensize < 2  
    @vs["bg"].z = 200
    if !@smSpecial
      @vs["bg2"] = ScrollingSprite.new(viewport)
      for bg2 in 0...X_SPECIES.length
        if num[bg2] == species 
          @vs["bg2"].setBitmap(directory[bg2] + "smBgLastEvil")
        end
      end    
      @vs["bg2"].color = Color.new(0,0,0,255)
      @vs["bg2"].speed = 64
      @vs["bg2"].ox = @vs["bg2"].src_rect.width/2
      @vs["bg2"].oy = @vs["bg2"].src_rect.height/2
      @vs["bg2"].x = viewport.rect.width/2
      @vs["bg2"].y = viewport.rect.height/2
      @vs["bg2"].angle = - 8 if $PokemonSystem.screensize < 2  
      @vs["bg2"].z = 200
      @vs["bg3"] = ScrollingSprite.new(viewport)
      for bg3 in 0...X_SPECIES.length
        if num[bg3] == species 
          @vs["bg3"].setBitmap(directory[bg3] + "smBgNextEvil")
        end
      end    
      @vs["bg3"].color = Color.new(0,0,0,255)
      @vs["bg3"].speed = 80
      @vs["bg3"].ox = @vs["bg3"].src_rect.width/2
      @vs["bg3"].oy = @vs["bg3"].src_rect.height/2
      @vs["bg3"].x = viewport.rect.width/2
      @vs["bg3"].y = viewport.rect.height/2
      @vs["bg3"].angle = - 8 if $PokemonSystem.screensize < 2  
      @vs["bg3"].z = 200
    end
  
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
    
    @vs["shade"] = Sprite.new(viewport)
    @vs["shade"].z = 250
    @vs["glow"] = Sprite.new(viewport)
    @vs["glow"].y = viewport.rect.height
    @vs["glow"].z = 250
    @vs["glow2"] = Sprite.new(viewport)
    @vs["glow2"].x = viewport.rect.width/2
    @vs["glow2"].z = 250
  
    @vs["boss"] = Sprite.new(viewport)
    @vs["boss"].z = 350
    @vs["boss"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["boss"].ox = @vs["boss"].bitmap.width/2
    @vs["boss"].oy = @vs["boss"].bitmap.height/2
    @vs["boss"].x = @vs["boss"].ox
    @vs["boss"].y = @vs["boss"].oy
    @vs["boss"].tone = Tone.new(255,255,255)
    @vs["boss"].zoom_x = 1.32
    @vs["boss"].zoom_y = 1.32
    @vs["boss"].opacity = 0
  
    
    for boss in 0...X_SPECIES.length
      if num[boss] == species 
        bmp = pbBitmap(directory[boss] + "boss")
      end
    end
    ox = (@vs["boss"].bitmap.width - bmp.width)/2
    oy = (@vs["boss"].bitmap.height - bmp.height)/2
    @vs["boss"].bitmap.blt(ox,oy,bmp,Rect.new(0,0,bmp.width,bmp.height))
    bmp = @vs["boss"].bitmap.clone
  
    @vs["shade"].bitmap = bmp.clone
    @vs["shade"].color = Color.new(10,169,245,224)
    @vs["shade"].opacity = 0
  
    @vs["glow"].bitmap = bmp.clone
    @vs["glow"].glow(Color.new(0,0,0),35,false)
    @vs["glow"].src_rect.set(0,viewport.rect.height,viewport.rect.width/2,0)
    @vs["glow2"].bitmap = @vs["glow"].bitmap.clone
    @vs["glow2"].src_rect.set(viewport.rect.width/2,0,viewport.rect.width/2,0)
  
    @vs["overlay"] = Sprite.new(viewport)
    @vs["overlay"].z = 999
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["overlay"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["overlay"].opacity = 0
    16.times do
      @vs["boss"].zoom_x -= 0.02
      @vs["boss"].zoom_y -= 0.02
      @vs["boss"].opacity += 32
      Graphics.update
    end
    @vs["boss"].zoom_x = 1; @vs["boss"].zoom_y = 1
    @commandWindow.drawLineup if !defined?(SCREENDUALHEIGHT)
    @commandWindow.lineupY(-32) if !defined?(SCREENDUALHEIGHT)
    for i in 0...16
      @commandWindow.showArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["boss"].tone.red -= 16
      @vs["boss"].tone.green -= 16
      @vs["boss"].tone.blue -= 16
      @vs["bg"].color.alpha -= 16
      if !@smSpecial
        @vs["bg2"].color.alpha -= 16
        @vs["bg3"].color.alpha -= 16
      end
      if @smSpecial
        @vsFp["ring"].zoom_x += 0.2
        @vsFp["ring"].zoom_y += 0.2
        @vsFp["ring"].opacity -= 16
      end
      self.vsBossSequence2_update
      Graphics.update
    end
    16.times do
      self.vsBossSequence2_update
      Graphics.update
    end
    pbSEPlay("transition2",100)
    for i in 0...16
      @vs["boss"].tone.red -= 32*(i < 8 ? -1 : 1)
      @vs["boss"].tone.green -= 32*(i < 8 ? -1 : 1)
      @vs["boss"].tone.blue -= 32*(i < 8 ? -1 : 1)
      @vs["bg"].speed = (@smSpecial ? 2 : 16) if i == 8
      if !@smSpecial
        @vs["bg2"].speed = 2 if i == 8
        @vs["bg3"].speed = 6 if i == 8
      end
      for j in 0...3
        next if !@smSpecial
        next if i != 8
        @vsFp["p#{j}"].speed /= 4
      end
      self.vsBossSequence2_update
      Graphics.update
    end
    16.times do
      @vs["glow"].src_rect.height += 24
      @vs["glow"].src_rect.y -= 24
      @vs["glow"].y -= 24
      @vs["glow2"].src_rect.height += 24
      self.vsBossSequence2_update
      Graphics.update
    end
    8.times do
      @vs["glow"].tone.red += 32
      @vs["glow"].tone.green += 32
      @vs["glow"].tone.blue += 32
      @vs["glow2"].tone.red += 32
      @vs["glow2"].tone.green += 32
      @vs["glow2"].tone.blue += 32
      self.vsBossSequence2_update
      Graphics.update
    end
    for i in 0...4
      @vs["boss"].tone.red += 64
      @vs["boss"].tone.green += 64
      @vs["boss"].tone.blue += 64
      if !@smSpecial
        @vs["bg"].x += 2
        @vs["bg2"].x += 2
        @vs["bg3"].x += 2
      end
      self.vsBossSequence2_update
      Graphics.update
    end
    for j in 0...3
      next if !@smSpecial
      @vsFp["p#{j}"].z = 300
    end
    for i in 0...8
      @vs["boss"].tone.red -= 32
      @vs["boss"].tone.green -= 32
      @vs["boss"].tone.blue -= 32
      @vs["shade"].opacity += 32
      @vs["shade"].x -= 4
      if i < 4 && !@smSpecial
        @vs["bg"].x -= 2
        @vs["bg2"].x -= 2
        @vs["bg3"].x -= 2
      end
      self.vsBossSequence2_update
      Graphics.update
    end 
  end

  def vsBossSequence2_update
    @vs["bg"].update if @vs["bg"] && !@vs["bg"].disposed?
    @vs["bg2"].update if @vs["bg2"] && !@vs["bg2"].disposed?
    @vs["bg3"].update if @vs["bg3"] && !@vs["bg3"].disposed?
    for j in 0...32
      next if !@smSpecial
      next if !@vsFp["s#{j}"] || @vsFp["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @vsFp["s#{j}"].opacity <= 1
        width = @vs["bg"].viewport.rect.width
        height = @vs["bg"].viewport.rect.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @vsFp["s#{j}"].zoom_x = z
        @vsFp["s#{j}"].zoom_y = z
        @vsFp["s#{j}"].x = x
        @vsFp["s#{j}"].y = y
        @vsFp["s#{j}"].opacity = 255
        @vsFp["s#{j}"].angle = rand(360)
      end
      @vsFp["s#{j}"].x -= (@vsFp["s#{j}"].x - @fpDx[j])*0.05
      @vsFp["s#{j}"].y -= (@vsFp["s#{j}"].y - @fpDy[j])*0.05
      @vsFp["s#{j}"].opacity -= @vsFp["s#{j}"].opacity*0.05
      @vsFp["s#{j}"].zoom_x -= @vsFp["s#{j}"].zoom_x*0.05
      @vsFp["s#{j}"].zoom_y -= @vsFp["s#{j}"].zoom_y*0.05
    end
    for j in 0...3
      next if !@smSpecial
      next if !@vsFp["p#{j}"] || @vsFp["p#{j}"].disposed?
      @vsFp["p#{j}"].update
      if j == 0
        @vsFp["p#{j}"].opacity += 5 if @vsFp["p#{j}"].opacity < 155
      else
        @vsFp["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@vsFp["p#{j}"].opacity >= 255 || @vsFp["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 128
  end

  def vsBossSequence2_end
    echoln(@vs)
    viewport = @viewport
    zoom = 4.0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["bg"].speed = @smSpecial ? 4 : 32
    if !@smSpecial
      @vs["bg2"].speed = 64
      @vs["bg3"].speed = 8
    end
    for j in 0...3
      next if !@smSpecial
      @vsFp["p#{j}"].speed *= 4
    end
    for i in 0..20
      @vs["boss"].x += 6*(i/5 + 1)
      @vs["glow"].x += 6*(i/5 + 1)
      @vs["glow2"].x += 6*(i/5 + 1)
      @commandWindow.hideArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity += 64
      zoom -= 4.0/20
      self.vsBossSequence2_update
      @vs["shade"].opacity -= 16
      Graphics.update
    end
    @commandWindow.lineupY(+32) if !defined?(SCREENDUALHEIGHT)
    pbDisposeSpriteHash(@vs)  
    pbDisposeSpriteHash(@vsFp)
    @vs["overlay"] = Sprite.new(@msgview)
    @vs["overlay"].z = 9999999
    @vs["overlay"].bitmap = Bitmap.new(@msgview.rect.width,@msgview.rect.height)
    @vs["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,@msgview.rect.height,Color.new(0,0,0))
  end

  def vsBossSequence2_sendout
    $smAnim = false
    viewport = @msgview
    zoom = 0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    21.times do
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity -= 12.8
      zoom += 4.0/20
      wait(1,true)
    end
    @vs["overlay"].dispose
  end
end

# Lista dei boss
BOSS_LIST = [
  :ELEKIDX,
	:SHARPEDOX,
	:GENGARX,
	:GALVANTULAX,
  :SHYLEON,
  :SHULONG,
  :TRISHOUT,
  :SLURPUFFX,
  :GIGASLURPUFFX,
  :MEWTWOX,
  :ROSERADEX,
	:RAPIDASHXBOSS,
	:RAPIDASHXBOSS2,
  :DRAGALISK,
  :VERSILDRAGALISK,
  :LUXFLON,
	:VAKUM,
  :GRENINJAX,
  :SUICUNE,
  :ENTEI,
  :RAIKOU,
  :VENUSAUR,
  :CHARIZARD,
  :BLASTOISE,
  
  :AEGISLASHX,
  :TAPUFINIX,
  :TAPULELEX,
  :TAPUKOKOX,
  :TAPUBULUX,
  :DRAGALISKFURIA,
  :TORNADUS,
  :THUNDURUS,
  :LANDORUS,
  :ENAMORUS,

  :MEWTWO
]

NEWBOSSES = [PBSpecies::GRENINJAX,
             PBSpecies::SUICUNE,
             PBSpecies::ENTEI,
             PBSpecies::RAIKOU,
             PBSpecies::VENUSAUR,
             PBSpecies::CHARIZARD,
             PBSpecies::BLASTOISE,
             PBSpecies::ELEKIDX,
             PBSpecies::GALVANTULAX,
             PBSpecies::RAPIDASHXBOSS2,
             PBSpecies::ROSERADEX,
             PBSpecies::TAPUFINIX,
             PBSpecies::TAPULELEX,
             PBSpecies::TAPUKOKOX,
             PBSpecies::TAPUBULUX,
             PBSpecies::DRAGALISKFURIA,
             PBSpecies::TORNADUS,
             PBSpecies::THUNDURUS,
             PBSpecies::LANDORUS,
             PBSpecies::ENAMORUS,
             PBSpecies::MEWTWO]

def isAuraDraga?
  ret = false
  ret = true if $wildSpecies == PBSpecies::DRAGALISK && ($game_switches[1317] || $game_switches[1318])
  return ret
end

def isBoss?
  ret = false
  for poke in BOSS_LIST
    num = getConst(PBSpecies,poke)
    next if num.nil? || ret
    if $wildSpecies == num
      ret = true
    end
  end
  return ret
end

class BossModifiers
  
  attr_accessor :lives
  attr_accessor :bgs
  attr_accessor :item
  
  def initialize
    @lives = 2
    @bgs = nil
    @item = nil
  end
  
  def set(lives, bgs, item)
    @lives = lives
    @bgs = bgs
    @item = item
  end
  
  def clear
    @lives = 2
    @bgs = nil
    @item = nil
  end
  
end

$mods = BossModifiers.new

def pbStartBossBattle(species, level, lives, bgs=nil, item = nil,canescape = true, modifiers = [],moves=[])
  $game_switches[85] = true
  $mods.set(lives, bgs, item)
	if modifiers != [] && modifiers != nil
		modifiers=[modifiers[0]*lives,modifiers[1],modifiers[2],modifiers[3],modifiers[4],modifiers[5]]
	end
	result = pbWildBattle(species, level, nil, false, true, modifiers,moves)
  $game_switches[85] = false
  return result
end

def pbStartBossBattleMon(pokemon, bgs = nil, item = nil, canescape = true,variable = nil)
	result = pbWildPokemonBattle(pokemon, variable, canescape, true)
  return result
end

def pbDoubleBossBattle(pokemon1,pokemon2,canescape=true,canlose = true)
  result = pbDoubleWildPokemonBattle(pokemon1,pokemon2,nil,canescape,canlose)
  return result
end

def containsNewBosses?(party)
  species = []
  for i in party
    species.push(i.species)
  end
  for v in NEWBOSSES
    return true if species.include?(v)
  end
  return false
end

def pbVenusaurBossBattle
  $furiousBattle = true
  $game_switches[85] = true
  $mods.set(2, nil, nil)
  $wildSpecies = PBSpecies::VENUSAUR
  pkmn = pbGenerateWildPokemon(PBSpecies::VENUSAUR,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:LEECHSEED, :SLEEPPOWDER, :GIGADRAIN, :SLUDGEBOMB]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=364*2
  pkmn.hp=pkmn.totalhp
  pkmn.attack=212
  pkmn.defense=282
  pkmn.spAtk=377
  pkmn.spDef=277
  pkmn.speed=196

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbCharizardBossBattle
  $furiousBattle = true
  $game_switches[85] = true
  $mods.set(2, nil, nil)
  $wildSpecies = PBSpecies::CHARIZARD
  #Charizard Y
  pkmn = pbGenerateWildPokemon(PBSpecies::CHARIZARD,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:SOLARBEAM, :HEATWAVE, :AIRSLASH, :ANCIENTPOWER]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=297*2
  pkmn.hp=pkmn.totalhp
  pkmn.attack=191
  pkmn.defense=192
  pkmn.spAtk=417
  pkmn.spDef=267
  pkmn.speed=328

  #Charizard X
  pkmn2 = pbGenerateWildPokemon(PBSpecies::CHARIZARD,100)
  pkmn2.forcedForm = 2
  pkmn2.pbDeleteAllMoves
  moves = [:FIREPUNCH, :DRAGONCLAW, :THUNDERPUNCH, :ROCKSLIDE]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  pkmn2.totalHp=297*2
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=359
  pkmn2.defense=258
  pkmn2.spAtk=266
  pkmn2.spDef=207
  pkmn2.speed=328

  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbBlastoiseBossBattle
  $furiousBattle = true
  $game_switches[85] = true
  $mods.set(2, nil, nil)
  $wildSpecies = PBSpecies::BLASTOISE
  pkmn = pbGenerateWildPokemon(PBSpecies::BLASTOISE,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:ICEBEAM, :AURASPHERE, :SCALD, :FLASHCANNON]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=362*2
  pkmn.hp=pkmn.totalhp
  pkmn.attack=189
  pkmn.defense=277
  pkmn.spAtk=405
  pkmn.spDef=266
  pkmn.speed=192

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbSuicuneBossBattle
  $furiousBattle = true
  pbRegisterPartner(PBTrainers::EVANSUICUNE,"Claudio")
  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::SUICUNE
  pkmn = pbGenerateWildPokemon(PBSpecies::SUICUNE,100) 
  pkmn.forcedForm = 2
  pkmn.totalHp=808
  pkmn.hp=pkmn.totalhp
  pkmn.attack=203
  pkmn.defense=369
  pkmn.spAtk=525
  pkmn.spDef=405
  pkmn.speed=927
  pkmn.pbDeleteAllMoves
  moves = [:SURF, :BLIZZARD, :AQUARING, :PROTECT]
  for m in moves
    pkmn.pbLearnMove(m)
  end

  $mods.set(2, nil, nil)
  pkmn2 = pbGenerateWildPokemon(PBSpecies::VAPOREON,100)
  pkmn2.setItem(:HEATROCK)
  pkmn2.totalHp=928
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=149
  pkmn2.defense=240
  pkmn2.spAtk=319
  pkmn2.spDef=289
  pkmn2.speed=801
  pkmn2.pbDeleteAllMoves
  moves = [:HAIL, :SCALD, :HELPINGHAND, :ICEBEAM]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbEnteiBossBattle
  $furiousBattle = true
  pbRegisterPartner(PBTrainers::HENNEENTEI,"Henné")
  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::ENTEI
  pkmn = pbGenerateWildPokemon(PBSpecies::ENTEI,100) 
  pkmn.forcedForm = 2
  pkmn.totalHp=869
  pkmn.hp=pkmn.totalhp
  pkmn.attack=394
  pkmn.defense=219
  pkmn.spAtk=230
  pkmn.spDef=289
  pkmn.speed=930
  pkmn.pbDeleteAllMoves
  moves = [:SACREDFIRE, :HOWL, :EXTREMESPEED, :STONEEDGE]
  for m in moves
    pkmn.pbLearnMove(m)
  end

  $mods.set(2, nil, nil)
  pkmn2 = pbGenerateWildPokemon(PBSpecies::FLAREON,100)
  pkmn2.setItem(:HEATROCK)
  pkmn2.totalHp=668
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=394
  pkmn2.defense=219
  pkmn2.spAtk=203
  pkmn2.spDef=319
  pkmn2.speed=572
  pkmn2.pbDeleteAllMoves
  moves = [:SUNNYDAY, :FIREFANG, :HELPINGHAND, :SOUNDPLEDGE]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbRaikouBossBattle
  $furiousBattle = true
  pbRegisterPartner(PBTrainers::RUTARAIKOU,"Ruta")
  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::RAIKOU
  pkmn = pbGenerateWildPokemon(PBSpecies::RAIKOU,100) 
  pkmn.forcedForm = 2
  pkmn.totalHp=768
  pkmn.hp=pkmn.totalhp
  pkmn.attack=246
  pkmn.defense=289
  pkmn.spAtk=369
  pkmn.spDef=339
  pkmn.speed=999
  pkmn.pbDeleteAllMoves
  moves = [:THUNDERBOLT, :CALMMIND, :SCALD, :AURASPHERE]
  for m in moves
    pkmn.pbLearnMove(m)
  end

  $mods.set(2, nil, nil)
  pkmn2 = pbGenerateWildPokemon(PBSpecies::JOLTEON,100)
  pkmn2.setItem(:DAMPROCK)
  pkmn2.totalHp=668
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=149
  pkmn2.defense=219
  pkmn2.spAtk=319
  pkmn2.spDef=289
  pkmn2.speed=985
  pkmn2.pbDeleteAllMoves
  moves = [:RAINDANCE, :THUNDERBOLT, :HELPINGHAND, :SHADOWBALL]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbEleSharpBossBattle
  $furiousBattle = true
  pbRegisterPartnerWithPartyEV(PBTrainers::REVOLVER,"Revolver",0,{
    :TOXICROAK=>{
      :attack=>252,
      :hp =>4,
      :speed =>252
    },
    :UMBREON=>{
      :hp=>252,
      :defense=>252,
      :spdef=>4
    }
  })
  $game_switches[85] = true
  $mods.set(3, nil, nil)
  $wildSpecies = PBSpecies::ELEKIDX
  $dittoxbattle = true
  #Elekid X
  pkmn = pbGenerateWildPokemon(PBSpecies::ELEKIDX,100)
  pkmn.pbDeleteAllMoves
  moves = [:TOXIC, :HEATWAVE, :TORMENT, :LIGHTSCREEN]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=324*2
  pkmn.hp=pkmn.totalhp
  pkmn.attack=257
  pkmn.defense=200
  pkmn.spAtk=341
  pkmn.spDef=259
  pkmn.speed=417
  pkmn.item=0

  #Sharpedo X  
  $mods.set(4, nil, nil)
  pkmn2 = pbGenerateWildPokemon(PBSpecies::SHARPEDOX,100)
  pkmn2.pbDeleteAllMoves
  moves = [:PHANTOMFORCE, :LIQUIDATION, :POISONJAB, :HEADSMASH]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  pkmn2.totalHp=397*2
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=420
  pkmn2.defense=239
  pkmn2.spAtk=240
  pkmn2.spDef=239
  pkmn2.speed=450
  pkmn2.item=0

  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  $dittoxbattle = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbGalvGeBossBattle
  $furiousBattle = true
  pbRegisterPartnerWithPartyEV(PBTrainers::MAURICEBUNKER,"Maurice",0,{
    :RAICHU=>{
      :spatk=>252,
      :defense=>4,
      :speed=>252
    },
    :METAGROSS=>{
      :hp=>252,
      :attack=>96,
      :spdef=>160
    }
  })
  $game_switches[85] = true
  $mods.set(4, nil, nil)
  $wildSpecies = PBSpecies::GALVANTULAX
  $dittoxbattle = true
  
  #Galvantula
  pkmn = pbGenerateWildPokemon(PBSpecies::GALVANTULAX,100)
  pkmn.pbDeleteAllMoves
  moves = [:RAINDANCE, :STEALTHROCK, :ICYWIND, :ROUND]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=794
  pkmn.hp=pkmn.totalhp
  pkmn.attack=352#299
  pkmn.defense=273#243
  pkmn.spAtk=426#394
  pkmn.spDef=273#243
  pkmn.speed=527#523
  pkmn.item=0

  #Gengar
  pkmn2 = pbGenerateWildPokemon(PBSpecies::GENGARX,100)
  pkmn2.pbDeleteAllMoves
  moves = [:DRAGONPULSE, :PSYSHOCK, :SHADOWBALL, :DRAGONENDURANCE]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  pkmn2.totalHp=846#1030   #Multiply by 2.6
  pkmn2.hp=pkmn2.totalhp   #everything else by 1.3
  pkmn2.attack=340#280
  pkmn2.defense=229#334
  pkmn2.spAtk=427#512
  pkmn2.spDef=233#349
  pkmn2.speed=297#267
  pkmn2.item=0

  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  $dittoxbattle = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbRapiPuffBossBattle
  $furiousBattle = true
  pbRegisterPartnerWithPartyEV(PBTrainers::CRISANTEBUNKER,"Crisante",0,{
    :CACTURNEX=>{
      :hp=>4,
      :attack=>128,
      :spatk=>124,
      :defense=>128,
      :spdef=>124
    },
    :SCARPHASMO=>{
      :spdef=>252,
      :spatk=>252,
      :hp=>4
    }
  })
  $game_switches[85] = true
  $mods.set(4, nil, nil)
  $wildSpecies = PBSpecies::RAPIDASHXBOSS2
  $dittoxbattle = true

  #Rapidash X
  pkmn = pbGenerateWildPokemon(PBSpecies::RAPIDASHXBOSS2,100)
  pkmn.pbDeleteAllMoves
  moves = [:COTTONGUARD, :AIRCUTTER, :ICEBEAM, :THUNDER]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=800
  pkmn.hp=pkmn.totalhp
  pkmn.attack=387
  pkmn.defense=264
  pkmn.spAtk=390
  pkmn.spDef=222
  pkmn.speed=424
  pkmn.item=0

  #Slurpuff X
  $mods.set(5, nil, nil)
  pkmn2 = pbGenerateWildPokemon(PBSpecies::SLURPUFFX,100)
  pkmn2.pbDeleteAllMoves
  moves = [:RAINDANCE, :VENOMDRENCH, :SUBWOOFER, :LIGHTSCREEN]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  pkmn2.totalHp=1270
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=195
  pkmn2.defense=288
  pkmn2.spAtk=207
  pkmn2.spDef=288
  pkmn2.speed=203
  pkmn2.item=0

  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  $dittoxbattle = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbRoseTwoBossBattle
  $furiousBattle = true
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

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::ROSERADEX
  $dittoxbattle = true

  #Roserade X
  pkmn = pbGenerateWildPokemon(PBSpecies::ROSERADEX,100)
  pkmn.pbDeleteAllMoves
  moves = [:HYPERVOICE, :PSYCHIC, :SLUDGEBOMB, :ICICLECRASH]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=838
  pkmn.hp=pkmn.totalhp
  pkmn.attack=293
  pkmn.defense=261
  pkmn.spAtk=396
  pkmn.spDef=254
  pkmn.speed=512
  pkmn.item=0

  #Mewtwo X
  pkmn2 = pbGenerateWildPokemon(PBSpecies::MEWTWOX,100)
  pkmn2.pbDeleteAllMoves
  moves = [:LEECHLIFE, :DRAGONCLAW, :POWERUPPUNCH, :ROCKSLIDE]
  for m in moves
    pkmn2.pbLearnMove(m)
  end
  pkmn2.totalHp=1072
  pkmn2.hp=pkmn2.totalhp
  pkmn2.attack=394
  pkmn2.defense=313
  pkmn2.spAtk=394
  pkmn2.spDef=313
  pkmn2.speed=427
  pkmn2.item=0

  result = pbDoubleBossBattle(pkmn,pkmn2,false,true)
  $game_switches[85] = false
  $dittoxbattle = false
  pbDeregisterPartner()
  $furiousBattle = false
  return result
end

def pbAegiBossBattle
  #$furiousBattle = true

  $game_switches[85] = true
  $mods.set(3, nil, nil)
  $wildSpecies = PBSpecies::AEGISLASHX

  #Tapu Fini X
  pkmn = pbGenerateWildPokemon(PBSpecies::AEGISLASHX,100)
  pkmn.pbDeleteAllMoves
  moves = [:IRONTAIL, :ROCKSLIDE, :PHANTOMFORCE, :PLAYROUGH]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.setAbility(1) #NoGuard
  pkmn.totalHp=538
  pkmn.hp=pkmn.totalhp
  pkmn.attack=524
  pkmn.defense=244
  pkmn.spAtk=180
  pkmn.spDef=250
  pkmn.speed=412
  pkmn.item=PBItems::WEAKNESSPOLICY

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  #$furiousBattle = false
  return result
end

def pbTapuFiniBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::TAPUFINIX

  #Tapu Fini X
  if $game_switches[1212]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUFINIX,100)
    pkmn.pbDeleteAllMoves
    moves = [:DARKPULSE, :PSYCHIC, :SURF, :CALMMIND]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=698
    pkmn.hp=pkmn.totalhp
    pkmn.attack=293
    pkmn.defense=320
    pkmn.spAtk=426
    pkmn.spDef=290
    pkmn.speed=280
    pkmn.item=PBItems::SITRUSBERRY
  elsif $game_switches[1213]==true #HARD
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUFINIX,100)
    pkmn.pbDeleteAllMoves
    moves = [:DARKPULSE, :PSYCHIC, :FLAMETHROWER, :CALMMIND]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=888
    pkmn.hp=pkmn.totalhp
    pkmn.attack=293
    pkmn.defense=380
    pkmn.spAtk=556
    pkmn.spDef=350
    pkmn.speed=350
    pkmn.item=PBItems::SITRUSBERRY
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbTapuLeleBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::TAPULELEX

   #Tapu Lele X
  if $game_switches[1216]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPULELEX,100)
    pkmn.pbDeleteAllMoves
    moves = [:NIGHTDAZE, :PSYCHIC, :ICEBEAM, :TOXIC]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=758
    pkmn.hp=pkmn.totalhp
    pkmn.attack=293
    pkmn.defense=521
    pkmn.spAtk=316
    pkmn.spDef=494
    pkmn.speed=312
    pkmn.item=PBItems::LIFEORB
  elsif $game_switches[1217]==true #HARD
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPULELEX,100)
    pkmn.pbDeleteAllMoves
    moves = [:HAIL, :TORMENT, :ICEBEAM, :TOXIC]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=918
    pkmn.hp=pkmn.totalhp
    pkmn.attack=293
    pkmn.defense=581
    pkmn.spAtk=386
    pkmn.spDef=524
    pkmn.speed=382
    pkmn.item=PBItems::LEFTOVERS
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbTapuKokoBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::TAPUKOKOX

  #Tapu Koko X
  if $game_switches[1218]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUKOKOX,100)
    pkmn.pbDeleteAllMoves
    moves = [:SUBSTITUTE, :FLASHCANNON, :DARKPULSE, :BRAVEBIRD]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=746
    pkmn.hp=pkmn.totalhp
    pkmn.attack=383
    pkmn.defense=290
    pkmn.spAtk=402
    pkmn.spDef=320
    pkmn.speed=582
    pkmn.item=PBItems::SHARPBEAK
  elsif $game_switches[1219]==true #HARD
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUKOKOX,100)
    pkmn.pbDeleteAllMoves
    moves = [:WORKUP, :FLASHCANNON, :DARKPULSE, :BRAVEBIRD]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=878
    pkmn.hp=pkmn.totalhp
    pkmn.attack=413
    pkmn.defense=340
    pkmn.spAtk=466
    pkmn.spDef=370
    pkmn.speed=812
    pkmn.item=PBItems::SHARPBEAK
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbTapuBuluBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(6, nil, nil)
  $wildSpecies = PBSpecies::TAPUBULUX

  #Tapu Bulu X
  if $game_switches[1268]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUBULUX,100)
    pkmn.pbDeleteAllMoves
    moves = [:SUPERPOWER, :OUTRAGE, :MEGAHORN, :NIGHTSLASH]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=808
    pkmn.hp=pkmn.totalhp
    pkmn.attack=513
    pkmn.defense=381
    pkmn.spAtk=286
    pkmn.spDef=254
    pkmn.speed=194
    pkmn.item=PBItems::DRACOPLATE
  elsif $game_switches[1269]==true #HARD
    pkmn = pbGenerateWildPokemon(PBSpecies::TAPUBULUX,100)
    pkmn.pbDeleteAllMoves
    moves = [:IRONHEAD, :DRAGONDANCE, :DRAGONCLAW, :NIGHTSLASH]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=988
    pkmn.hp=pkmn.totalhp
    pkmn.attack=613
    pkmn.defense=421
    pkmn.spAtk=326
    pkmn.spDef=294
    pkmn.speed=234
    pkmn.item=PBItems::EXPERTBELT
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbTamaraBossBattle
  
  trainer=PokeBattle_Trainer.new(_INTL("Tamara"),PBTrainers::TAMARAFURIA)
  trainer.setForeignID($Trainer) if $Trainer
  party = []
  $trainerbossbattle = true
  $game_switches[85]=true
  species = [PBSpecies::TOXAPEX, PBSpecies::SCIZOR, PBSpecies::WYSTEARIA, PBSpecies::VESPIQUEN, PBSpecies::SCOVILEX, PBSpecies::SCEPTILE]
  items = [PBItems::LEFTOVERS, PBItems::SHELLBELL, PBItems::BIGROOT, 0, PBItems::ASSAULTVEST, PBItems::SCEPTILITE]
  healthbars = [3,3,2,3,3,4]
  partyMoves = [
    [:ACIDRAIN, :TOXICSPIKES, :BANEFULBUNKER, :RAINDANCE], #TOXAPEX - REGENERATOR
    [:SWORDSDANCE, :BRUTALSWING, :XSCISSOR, :IRONHEAD], #SCIZOR - TECHNICIAN
    [:GIGADRAIN,:FAKETEARS,:BOOMBURST,:TOXIC], #WYSTEARIA - SYNTHESIZER
    [:ACROBATICS, :DEFENDORDER, :SWAGGER, :BATONPASS], #VESPIQUEN - PRESSURE
    [:TUONO, :ENERGYBALL, :FLAMETHROWER, :SLUDGEBOMB], #SCOVILEX - EFFECTSPORE
    [:SUBSTITUTE, :LEECHSEED, :DRAGONPULSE, :GIGADRAIN]  #SCEPTILE MEGA - LIGHTINGROD
  ]
  stats = [
    #HP, atk, def, spe, spa, spd
    [967,370,425,243,334,417], #TOXAPEX - REGENERATOR
    [733,544,416,326,304,347], #SCIZOR - TECHNICIAN
    [638,293,383,192,445,444], #WYSTEARIA - SYNTHESIZER
    [727,369,368,256,369,368], #VESPIQUEN - PRESSURE
    [942,379,369,485,400,384], #SCOVILEX - EFFECTSPORE
    [1052,448,388,555,555,423]  #SCEPTILE MEGA - LIGHTINGROD
  ]
  for i in 0...6
    #$mods.set(healthbars[i], nil, nil)
    # Setting up the Pokemon
    pkmn = pbGenerateWildPokemon(species[i],100)
    pkmn.item = items[i]
    pkmn.pbDeleteAllMoves
    moves = partyMoves[i]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=stats[i][0]
    pkmn.hp=pkmn.totalhp
    pkmn.attack=stats[i][1]
    pkmn.defense=stats[i][2]
    pkmn.spAtk=stats[i][4]
    pkmn.spDef=stats[i][5]
    pkmn.speed=stats[i][3]
    pkmn.statsOverride = stats[i]
    echoln "Healthbars #{healthbars[i]}"
    pkmn.setBoss(healthbars[i])
    party.push(pkmn)
  end
  for i in 0...6 
    echoln "MOLTIPLIER #{party[i].hpMoltiplier}"
  end
  trainer.party = party
  result = pbBossTrainerBattle([trainer,[],trainer.party],_INTL("..."))
  $game_switches[85]=false
  $trainerbossbattle = false
  return result
end

def pbVakumBossBattle(hardmode = false)
  
  trainer=PokeBattle_Trainer.new(_INTL("Vakuum"),PBTrainers::VAKUM)
  trainer.setForeignID($Trainer) if $Trainer
  party = []
  $trainerbossbattle = true
  $game_switches[85]=true
  species = [PBSpecies::EGORGEON, PBSpecies::TORNADUS, PBSpecies::THUNDURUS, PBSpecies::LANDORUS, PBSpecies::ENAMORUS]
  
  if $game_switches[1318]==true #HARD
    hardmode = true
  end

  if (!hardmode)
    #easy
    partyMoves = [
      [:THUNDER, :DRAGONPULSE, :DAZZLINGGLEAM, :AQUATAIL], #EGORGEON - DRIZZLE
      [:HURRICANE, :ACROBATICS, :PSYCHIC, :SLUDGEBOMB], #TORNADUS - DEFIANT
      [:THUNDER, :WILDCHARGE, :DARKPULSE, :HAMMERARM], #THUNDURUS - DEFIANT
      [:EARTHQUAKE, :STONEEDGE, :HAMMERARM, :UTURN], #LANDORUS - SHEER FORCE
      [:MOONBLAST, :HURRICANE, :EARTHPOWER, :SLUDGEBOMB], #ENAMORUS - COMPETITIVE
    ]
  else
    #hard
    partyMoves = [
      [:THUNDER, :DRAGONPULSE, :EARTHPOWER, :VELVETSCALES], #EGORGEON - DRIZZLE
      [:HURRICANE, :CALMMIND, :THUNDERBOLT, :CANNONFLASH], #TORNADUS - COMPETITIVE
      [:THUNDER, :ICEBEAM, :DARKPULSE, :NASTYPLOT], #THUNDURUS - COMPETITIVE
      [:EARTHQUAKE, :STONEEDGE, :HAMMERARM, :BULKUP], #LANDORUS - INTIMIDATE
      [:FLEURCANNON, :HURRICANE, :EARTHPOWER, :THUNDER], #ENAMORUS - CONTRARY
    ]
  end

  if (!hardmode)
    #easy
    items = [PBItems::ASSAULTVEST, PBItems::FLYINGGEM, PBItems::MAGNET, PBItems::WIDELENS, PBItems::LIFEORB]
  else
    #hard
    items = [PBItems::REDCARD, PBItems::WEAKNESSPOLICY, PBItems::LIFEORB, PBItems::LAXINCENSE, PBItems::LIFEORB]
  end

  if (!hardmode)
    #easy
    healthbars = [2,3,3,3,3]
  else
    #hard
    healthbars = [3,4,4,4,4]
  end

  if (!hardmode)
    #easy
    abilities = [PBAbilities::DRIZZLE,PBAbilities::DEFIANT,PBAbilities::DEFIANT,PBAbilities::SANDFORCE,PBAbilities::COMPETITIVE]
  else
    #hard
    abilities = [PBAbilities::DRIZZLE,PBAbilities::COMPETITIVE,PBAbilities::COMPETITIVE,PBAbilities::INTIMIDATE,PBAbilities::CONTRARY]
  end

  if (!hardmode)
    #easy
    stats = [
      #HP, atk, def, spe, spa, spd
      [548,328,309,409,456,309], #EGORGEON - DRIZZLE
      [544,356,289,391,433,309], #TORNADUS - DEFIANT
      [544,356,289,391,433,309], #THUNDURUS - DEFIANT
      [584,443,339,371,346,309], #LANDORUS - SHEER FORCE
      [524,366,289,381,455,309], #ENAMORUS - COMPETITIVE
    ]
  else
    #hard
    stats = [
      #HP, atk, def, spe, spa, spd
      [768,378,369,449,516,369], #EGORGEON - DRIZZLE
      [764,406,349,431,493,369], #TORNADUS - DEFIANT
      [764,406,349,431,493,369], #THUNDURUS - DEFIANT
      [804,493,359,411,406,369], #LANDORUS - SHEER FORCE
      [744,416,349,421,515,369], #ENAMORUS - COMPETITIVE
    ]
  end

  if (!hardmode)
    forms = [0,0,0,0,0]
  else
    forms = [0,1,1,1,1]
  end
  
  for i in 0...species.length
    #$mods.set(healthbars[i], nil, nil)
    # Setting up the Pokemon
    pkmn = pbGenerateWildPokemon(species[i],100)
    pkmn.item = items[i]
    pkmn.pbDeleteAllMoves
    moves = partyMoves[i]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=stats[i][0]
    pkmn.hp=pkmn.totalhp
    pkmn.attack=stats[i][1]
    pkmn.defense=stats[i][2]
    pkmn.spAtk=stats[i][4]
    pkmn.spDef=stats[i][5]
    pkmn.speed=stats[i][3]
    pkmn.statsOverride = stats[i]
    pkmn.forcedForm = forms[i]
    pkmn.abilityOverride = abilities[i]
    echoln "Healthbars #{healthbars[i]}"
    pkmn.setBoss(healthbars[i])
    party.push(pkmn)
  end
  for i in 0...species.length
    echoln "MOLTIPLIER #{party[i].hpMoltiplier}"
  end
  trainer.party = party
  result = pbBossTrainerBattle([trainer,[],trainer.party],_INTL("..."))
  $game_switches[85]=false
  $trainerbossbattle = false
  return result
end

def pbDraga1BossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(4, nil, nil)
  $wildSpecies = PBSpecies::DRAGALISK

  #Draga Furia 1
  if $game_switches[1317]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::DRAGALISK,100)
    pkmn.forcedForm = 1
    pkmn.pbDeleteAllMoves
    moves = [:FROSTBREATH, :SHADOWBALL, :EARTHPOWER, :THUNDERBOLT]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=600
    pkmn.hp=pkmn.totalhp
    pkmn.attack=463
    pkmn.defense=321
    pkmn.spAtk=463
    pkmn.spDef=321
    pkmn.speed=494
    pkmn.item = 0
  elsif $game_switches[1318]==true #HARD
    $mods.set(5, nil, nil)
    pkmn = pbGenerateWildPokemon(PBSpecies::DRAGALISK,100)
    pkmn.forcedForm = 1
    pkmn.pbDeleteAllMoves
    moves = [:TORMENT, :PROTECT, :PSYCHOSHIFT, :FROSTBREATH]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=750
    pkmn.hp=pkmn.totalhp
    pkmn.attack=513
    pkmn.defense=461
    pkmn.spAtk=513
    pkmn.spDef=461
    pkmn.speed=494
    pkmn.item = 0
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbDraga2BossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(6, nil, nil)
  $wildSpecies = PBSpecies::DRAGALISKFURIA

  #Draga Furia 1
  if $game_switches[1317]==true #EASY
    pkmn = pbGenerateWildPokemon(PBSpecies::DRAGALISKFURIA,100)
    pkmn.pbDeleteAllMoves
    moves = [:VOIDSTAR, :EARTHQUAKE, :DARKPULSE, :FREEZEDRY]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=750
    pkmn.hp=pkmn.totalhp
    pkmn.attack=533
    pkmn.defense=321
    pkmn.spAtk=533
    pkmn.spDef=321
    pkmn.speed=494
    pkmn.item = 0
  elsif $game_switches[1318]==true #HARD
    $mods.set(8, nil, nil)
    pkmn = pbGenerateWildPokemon(PBSpecies::DRAGALISKFURIA,100)
    pkmn.pbDeleteAllMoves
    moves = [:DIVINEJUDGEMENT, :VOIDSTAR, :EARTHQUAKE, :NASTYPLOT]
    for m in moves
      pkmn.pbLearnMove(m)
    end
    pkmn.totalHp=1000
    pkmn.hp=pkmn.totalhp
    pkmn.attack=553
    pkmn.defense=391
    pkmn.spAtk=553
    pkmn.spDef=391
    pkmn.speed=554
    pkmn.item = PBItems::PETAYABERRY
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbTornadusBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::TORNADUS

  pkmn = pbGenerateWildPokemon(PBSpecies::TORNADUS,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:HURRICANE, :CALMMIND, :THUNDERBOLT, :RAINDANCE]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=700
  pkmn.hp=pkmn.totalhp
  pkmn.attack=463
  pkmn.defense=321
  pkmn.spAtk=503
  pkmn.spDef=321
  pkmn.speed=404
  pkmn.item = 0

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbThundurusBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::THUNDURUS

  pkmn = pbGenerateWildPokemon(PBSpecies::THUNDURUS,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:THUNDER, :ICEBEAM, :DARKPULSE, :NASTYPLOT]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=700
  pkmn.hp=pkmn.totalhp
  pkmn.attack=423
  pkmn.defense=281
  pkmn.spAtk=563
  pkmn.spDef=311
  pkmn.speed=364
  pkmn.item = 0

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbLandorusBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::LANDORUS

  pkmn = pbGenerateWildPokemon(PBSpecies::LANDORUS,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:EARTHQUAKE, :STONEEDGE, :HAMMERARM, :BULKUP]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=780
  pkmn.hp=pkmn.totalhp
  pkmn.attack=563
  pkmn.defense=311
  pkmn.spAtk=423
  pkmn.spDef=281
  pkmn.speed=264
  pkmn.item = 0

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbEnamorusBossBattle
  $furiousBattle = true

  $game_switches[85] = true
  $mods.set(5, nil, nil)
  $wildSpecies = PBSpecies::ENAMORUS

  pkmn = pbGenerateWildPokemon(PBSpecies::ENAMORUS,100)
  pkmn.forcedForm = 1
  pkmn.pbDeleteAllMoves
  moves = [:MOONBLAST, :FLAMETHROWER, :EARTHPOWER, :CALMMIND]
  for m in moves
    pkmn.pbLearnMove(m)
  end
  pkmn.totalHp=700
  pkmn.hp=pkmn.totalhp
  pkmn.attack=463
  pkmn.defense=281
  pkmn.spAtk=523
  pkmn.spDef=311
  pkmn.speed=378
  pkmn.item = 0

  result = pbStartBossBattleMon(pkmn,nil,nil,false)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end

def pbSecretBossBattle
  $furiousBattle = true
  $game_switches[85] = true
  $mods.set(8, nil, nil)
  $wildSpecies = PBSpecies::MEWTWO

  pkmn = pbGenerateWildPokemon(PBSpecies::MEWTWO,100)
  pkmn.form=1
  pkmn.pbDeleteAllMoves
  moves = [:REST, :PSYSTRIKE, :NASTYPLOT, :MIRACLEEYE]
  for m in moves
    pkmn.pbLearnMove(m)
  end

  result = pbStartBossBattleMon(pkmn,nil,nil,false,160)
  $game_switches[85] = false
  $furiousBattle = false
  return result
end


def pbBossTrainerBattle(trainer,endspeech,internalbattle = true)
  #trainer=pbLoadTrainerTournament(trainerid,trainername,trainerparty)
  #def pbTrainerBattle(trainerid,trainername,endspeech,
  #  doublebattle=false,trainerparty=0,canlose=false,variable=nil)
  doublebattle=false
  trainerparty=0
  canlose=true
  variable=nil
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    return false
  end
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  if $PokemonTemp.waitingTrainer
    combinedParty=[]
    fullparty2=false
    if false
      if $PokemonTemp.waitingTrainer[0][2].length>3
        raise _INTL("Opponent 1's party has more than three Pokémon, which is not allowed")
      end
      if trainer[2].length>3
        raise _INTL("Opponent 2's party has more than three Pokémon, which is not allowed")
      end
    elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[6+i]=trainer[2][i]
      end
      fullparty2=true
    else
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[3+i]=trainer[2][i]
      end
      fullparty2=false
    end
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.doublebattle=battle.pbDoubleBattleAllowed?()
    battle.endspeech=$PokemonTemp.waitingTrainer[2]
    battle.endspeech2=endspeech
    battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
  else
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
    battle.fullparty1=fullparty1
    battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
    battle.items=trainer[1]
    trainerbgm=pbGetTrainerBattleBGM(trainer[0])
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
      $PokemonTemp.waitingTrainer=nil
    end
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=internalbattle
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil); end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
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
     else
       Events.onEndBattle.trigger(nil,decision)
       if decision==1
         if $PokemonTemp.waitingTrainer
           pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
         end
       end
     end
  }
  Input.update
  pbSet(variable,decision)
  $PokemonTemp.waitingTrainer=nil
  return (decision==1)
end

WILDAIMONSTER=
{
  PBSpecies::TAPUFINIX => 1213,
  PBSpecies::TAPULELEX => 1217,
  PBSpecies::TAPUKOKOX => 1219,
  PBSpecies::TAPUBULUX => 1269,
  PBSpecies::DRAGALISK => 1318,
  PBSpecies::DRAGALISKFURIA => 1318,
  PBSpecies::TORNADUS => 1318,
  PBSpecies::THUNDURUS => 1318,
  PBSpecies::LANDORUS => 1318,
  PBSpecies::ENAMORUS => 1318,
}

ALWAYSWILDAIMONSTER = 
{  
  PBSpecies::MEWTWO => true
}


Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if $mods.item != nil
    pokemon.item = $mods.item
    $mods.item = nil
  end
  #echoln "boss:#{isBoss?} 85:#{$game_switches[85]}"
  if isBoss? && $game_switches[85]
    pokemon.setBoss($mods.lives,$bgs != nil ? $mods.bgs : "test2")
  end
}