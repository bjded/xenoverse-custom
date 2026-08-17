class SafariZone
  
  
  
  def initialize()
    $Trainer.safariZone = false if $Trainer.safariZone ==  nil
    
    @oldParty = $Trainer.party
    @oldBag = $PokemonBag
    $PokemonBag = PokemonBag.new
    $PokemonBag.pbStoreItem(:OLDBALL,50)
    $Trainer.party = []
		d = PokeBattle_Pokemon.new(:DONANAS,50,$Trainer)
		d.pbDeleteAllMoves
		d.pbLearnMove(:SMACKDOWN)
		d.pbLearnMove(:ROOST)
		d.pbLearnMove(:IRONHEAD)
		d.pbLearnMove(:AERIALACE)
		d.setAbility(1)
    pbAddPokemonSilent(d)
    pbSafariState.pbInProgress(true)
    @progress=0
		$lastUsed=0
		$PokemonGlobal.repel=0
  end
  
  def pbRestoreOldParty
    $Trainer.party = @oldParty
    $PokemonBag = @oldBag
    $lastUsed = 0
    pbSafariState.pbInProgress(false)
    for i in 463...469
      $game_switches[i]=false
    end
  end
  
  def update
    if @progress == 3
      Kernel.pbMessage(_INTL("Ka-ching!"))
    end
  end
 
  def addProgress(val)
    @progress+=val
    checkProgress
  end
  
  def checkProgress
    if @progress == 3
      Kernel.pbMessage(_INTL("Ka-ching!"))
      Kernel.pbMessage(_INTL("You successfully completed the Hero Trial! You may come back now!"))
      pbSafariState.pbGoToStart
      pbRestoreOldParty
      if !$game_switches[996] && pbSafariState.difficulty == 1 #hard
        $game_switches[996] = true
      elsif !$game_switches[995]  && pbSafariState.difficulty == 0 #ez
        $game_switches[995] = true
      end
      $game_map.need_refresh = true
    end
  end
  
  def failed
    Kernel.pbMessage(_INTL("Ka-ching!"))
    Kernel.pbMessage(_INTL("It seems you failed the trial! Come back to the entrance."))
    pbSafariState.pbGoToStart
    pbRestoreOldParty
  end
  
end