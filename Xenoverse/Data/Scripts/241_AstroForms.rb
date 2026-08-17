class PokeBattle_Battler
  
  def hasPrimal?
    return false if @effects[PBEffects::Transform]
    if @pokemon
      return (@pokemon.hasPrimalForm? rescue false)
    end
    return false
  end

  def isPrimal?
    if @pokemon
      return (@pokemon.isPrimal? rescue false)
    end
    return false
  end
  
  def pbFaint(showMessage=true)
    if !self.isFainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return true
    end
    if @fainted
#      PBDebug.log("!!!***Can't faint if already fainted")
      return true
    end
    @battle.scene.pbFainted(self)
    pbInitEffects(false)
    # reset status
    self.status=0
    self.statusCount=0
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness("faint")
    end
    @pokemon.makeUnprimal if self.isPrimal?
    @fainted=true
    # reset mega
    if @pokemon.isMega?
      @pokemon.makeUnmega
    end

    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    
		if (!@battle.is_a?(PokeBattle_CableClub)&& !@battle.is_a?(PokeBattle_SpectateCableClub))
			@battle.pbDisplayPaused(_INTL("{1} è esausto!",pbThis)) if showMessage
		else
			@battle.pbDisplayBrief(_INTL("{1} è esausto!",pbThis)) if showMessage
		end
    PBDebug.log("[#{pbThis} fainted]")
    PBDebug.log("[#{pbThis} real hp is #{@pokemon.hp} : #{self.hp}. Is it fainted? #{isFainted?()}]")
    return true
  end
  
end