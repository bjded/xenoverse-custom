class SafariState
  attr_accessor :ballcount
  attr_accessor :decision
  attr_accessor :steps

  def initialize
    @start=nil
    @ballcount=0
    @inProgress=false
    @steps=0
    @decision=0
    @difficulty = 0
  end

  def pbReceptionMap
    return @inProgress ? @start[0] : 0
  end

  def inProgress?
    return @inProgress
  end

  def difficulty
    return @difficulty
  end
  
  def difficulty=(val)
    @difficulty = val
  end
  
  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      pbFadeOutIn(99999){
         $game_temp.player_transferring = true
         $game_temp.transition_processing = true
         $game_temp.player_new_map_id = @start[0]
         $game_temp.player_new_x = @start[1]
         $game_temp.player_new_y = @start[2] +1
         $game_temp.player_new_direction = 2
         $Trainer.outfit=0
         $scene.transfer_player
      }
    end
  end
  
  def pbInProgress(val)
    @inProgress=val
  end

  def pbStart#(ballcount)
    @start=[$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
    #@ballcount=ballcount
    @inProgress=true
    #@steps=SAFARISTEPS
  end

  def pbEnd
    @start=nil
    @ballcount=0
    @inProgress=false
    @steps=0
    @decision=0
    $game_map.need_refresh=true
  end
end



Events.onMapChange+=proc{|sender,args|
   if !pbInSafari?
     pbSafariState.pbEnd
   end
}

def pbInSafari?
  if pbSafariState.inProgress?
    return pbSafariState.inProgress?
  end
  return false
end

def pbSafariState
  if !$PokemonGlobal.safariState
    $PokemonGlobal.safariState=SafariState.new
  end
  return $PokemonGlobal.safariState
end

=begin
Events.onStepTakenTransferPossible+=proc {|sender,e|
   handled=e[0]
   next if handled[0]
   if pbInSafari? && pbSafariState.decision==0 && SAFARISTEPS>0
     pbSafariState.steps-=1
     if pbSafariState.steps<=0
       Kernel.pbMessage(_INTL("PA:  Ding-dong!\1")) 
       Kernel.pbMessage(_INTL("PA:  Your safari game is over!"))
       pbSafariState.decision=1
       pbSafariState.pbGoToStart
       handled[0]=true
     end
   end
}
=end

Events.onWildBattleOverride+= proc { |sender,e|
   species=e[0]
   level=e[1]
   handled=e[2]
   next if handled[0]!=nil
   next if !pbInSafari?
   handled[0]=pbNewSafariBattle(species,level,pbSafariState.difficulty)
}

def pbSafariBattle(species,level)
  genwildpoke=pbGenerateWildPokemon(species,level)
  scene=pbNewBattleScene
  battle=PokeBattle_SafariZone.new(scene,$Trainer,[genwildpoke])
  battle.ballcount=pbSafariState.ballcount
  battle.environment=pbGetEnvironment
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle
     }
  }
  pbSafariState.ballcount=battle.ballcount
  Input.update
  if pbSafariState.ballcount<=0
    if decision!=2 && decision!=5
      Kernel.pbMessage(_INTL("Announcer:  You're out of Safari Balls!  Game over!")) 
    end
    pbSafariState.decision=1
    pbSafariState.pbGoToStart
  end
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return decision
end

def pbNewSafariBattle(species,level,variable=nil,canlose=true)
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
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke=pbGenerateWildPokemon(species,level)
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=pbSafariState.difficulty ==0 ? false : true
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil);i.busted=false if i.busted; end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
          i.heal
					i.makeUnmega rescue nil
					i.busted=false if i.busted
       end
     end
     if decision==1 && RETROMON[species]#$game_switches[RETROMONSWITCH] &&
       echoln "WIN BATTLE"
       if $Trainer.retrochain[species]
         $Trainer.retrochain[species]+=1 if $Trainer.retrochain[species]<500
       else
         $Trainer.retrochain[species]=1
       end
       echoln $Trainer.retrochain[species]
     end
     if decision==2 || decision==5 # if loss or draw
       $safariScene.failed
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return (decision!=2)
end