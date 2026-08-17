class PokeBattle_Pokemon
	attr_accessor(:itemRecycle) # Consumed held item (used in battle only)
  attr_accessor(:itemInitial) # Resulting held item (used in battle only)
  attr_accessor(:belch)       # Whether Pokémon can use Belch (used in battle only)
	
	attr_accessor(:busted)			# Used for mimikyu and Disguise
	
	
	
	def busted
		if @busted==nil
			@busted=false
		end
		return @busted
	end
	
	def busted=(value)
		@busted=value
	end
end