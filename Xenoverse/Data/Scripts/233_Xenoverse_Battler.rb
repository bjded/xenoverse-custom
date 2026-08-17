class PokeBattle_Battler
  def pbBust
    @battle.pbDisplay(_INTL("{1}'s disguise was busted!",pbThis))
    @pokemon.busted=true
    #if self.form!=@pokemon.form
    #  self.form=@pokemon.form
    #end
    self.pbUpdate(true) 
    @battle.scene.pbChangePokemon(self,@pokemon)
  end
	
	def hasMoldBreaker
    return true if hasWorkingAbility(:MOLDBREAKER) ||
                   hasWorkingAbility(:TERAVOLT) ||
                   hasWorkingAbility(:TURBOBLAZE)
    return false
  end
	
	# Yields each unfainted ally Pokémon.
  def eachAlly
    @battle.battlers.each do |b|
      yield b if b && !b.fainted? && !b.pbIsOpposing?(@index) && b.index!=@index
    end
  end
	
	def busted
		return @pokemon.busted if @pokemon != nil
		return false
	end
end