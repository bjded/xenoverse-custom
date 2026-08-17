class PokeBattle_Pokemon
	attr_accessor(:forcedForm)
	attr_accessor(:canPrimal)
	
	def form
		return @forcedForm if @forcedForm!=nil
		v=MultipleForms.call("getForm",self)
		if v!=nil
			self.form=v if !@form || v!=@form
			return v
		end
		return @form || 0
	end
	
	def formNoCall
		return @form
	end
	
	def form=(value)
		@form=value
		self.calcStats
		MultipleForms.call("onSetForm",self,value)
	end

	def altitude(original)
		v = MultipleForms.call("getAltitude",self)
		Log.i("SPRITE INFO","Altitude is #{v}. Original was #{original}")
		return v if v!=nil
		return original
	end

	
	
	def formNoCall=(value)
		@form=value
		self.calcStats
	end
	
	def hasMegaForm?
		v=MultipleForms.call("getMegaForm",self)
		return v!=nil
	end
	
	def isMega?
		v=MultipleForms.call("getMegaForm",self)
		return v!=nil && v==@form
	end
	
	def makeMega
		v=MultipleForms.call("getMegaForm",self)
		self.form=v if v!=nil
	end
	
	def makeUnmega
		v=MultipleForms.call("getUnmegaForm",self)
		self.form=v if v!=nil
	end
	
	def megaName
		v=MultipleForms.call("getMegaName",self)
		return v if v!=nil
		return ""
	end
	
	#Primal
	def canPrimal?
		return false if canPrimal == nil
		return @canPrimal
	end
	
	def canPrimal=(value)
		@canPrimal = value
	end
	
	def hasPrimalForm?
		v=MultipleForms.call("getPrimalForm",self)
		return v!=nil
	end
	
	def isPrimal?
		v=MultipleForms.call("getPrimalForm",self)
		return v!=nil && v==@form
	end
	
	def makePrimal
		v=MultipleForms.call("getPrimalForm",self)
		echo _INTL("Asking for form {1}",v)
		self.form=v if v!=nil
	end
	
	def makeUnprimal
		v=MultipleForms.call("getUnprimalForm",self)
		if v!=nil; self.form=v
		elsif isPrimal?; self.form=0
		end
	end
	#
	
	def heldItemForm
		v=MultipleForms.call("getForm",self)
		return v if v!=nil
		return ""
	end
	
	alias __mf_baseStats baseStats
	alias __mf_ability ability
	alias __mf_type1 type1
	alias __mf_type2 type2
	alias __mf_weight weight
	alias __mf_height height
	alias __mf_getMoveList getMoveList
	alias __mf_wildHoldItems wildHoldItems
	alias __mf_baseExp baseExp
	alias __mf_evYield evYield
	alias __mf_initialize initialize
	alias __mf_rareness rareness
	
	def baseStats
		v=MultipleForms.call("getBaseStats",self)
		return v if v!=nil
		return self.__mf_baseStats
	end
	
	def rareness
		v = MultipleForms.call("getRareness",self)
		return v if v!=nil
		return self.__mf_rareness
	end

	def ability
		v=MultipleForms.call("ability",self)
		return v if v!=nil
		return self.__mf_ability
	end
	
	def type1
		v=MultipleForms.call("type1",self)
		return v if v!=nil
		return self.__mf_type1
	end
	
	def type2
		v=MultipleForms.call("type2",self)
		return v if v!=nil
		return self.__mf_type2
	end

	def height
		v=MultipleForms.call("height",self)
		echoln v
		return v*100.0 if v!=nil
		return self.__mf_height
	end
	
	def weight
		v=MultipleForms.call("weight",self)
		return v*100.0 if v!=nil
		return self.__mf_weight
	end
	
	def getMoveList
		begin
			v=MultipleForms.call("getMoveList",self)
		rescue
			echoln "MOVES ERROR! FORM #{self.form} IN #{self.species}"
			v=nil
		end
		return v if v!=nil
		return self.__mf_getMoveList
	end
	
	def wildHoldItems
		v=MultipleForms.call("wildHoldItems",self)
		return v if v!=nil
		return self.__mf_wildHoldItems
	end
	
	def baseExp
		v=MultipleForms.call("baseExp",self)
		return v if v!=nil
		return self.__mf_baseExp
	end
	
	def evYield
		v=MultipleForms.call("evYield",self)
		return v if v!=nil
		return self.__mf_evYield
	end

	def checkEvolutionForm(item=0)
		f=MultipleForms.call("getFormOnEvolution",self,item)
		if f != nil
			self.form=f
		end
	end
	
	def initialize(*args)
		__mf_initialize(*args)
		f=MultipleForms.call("getFormOnCreation",self)
		if f
			self.form=f
			self.resetMoves
		end
	end
end



class PokeBattle_RealBattlePeer
	def pbOnEnteringBattle(battle,pokemon)
		f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
		if f
			pokemon.form=f
		end
	end
end



module MultipleForms
	@@formSpecies=HandlerHash.new(:PBSpecies)
	
	def self.get()
		return @@formSpecies
	end

	def self.copy(sym,*syms)
		@@formSpecies.copy(sym,*syms)
	end
	
	def self.register(sym,hash)
		@@formSpecies.add(sym,hash)
	end
	
	def self.registerIf(cond,hash)
		@@formSpecies.addIf(cond,hash)
	end
	
	def self.hasFunction?(pokemon,func)
		spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
		sp=@@formSpecies[spec]
		return sp && sp[func]
	end
	
	def self.getFunction(pokemon,func)
		spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
		sp=@@formSpecies[spec]
		return (sp && sp[func]) ? sp[func] : nil
	end
	
	def self.call(func,pokemon,*args)
		sp=@@formSpecies[pokemon.species]
		return nil if !sp || !sp[func]
		return sp[func].call(pokemon,*args)
	end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
	height=spotpattern.length
	width=spotpattern[0].length
	finalspots=[]
	for yy in 0...height
		echoln "YY: #{yy}"
		for xx in 0...width
			echoln "XX: #{xx}"
			echoln "spot #{spotpattern[yy][xx]}"
			if spotpattern[yy][xx]==1
				xOrg=(x+xx)<<1
				yOrg=(y+yy)<<1
				color=bitmap.get_pixel(xOrg,yOrg)
				r=color.red+red
				g=color.green+green
				b=color.blue+blue
				
				color.red=[[r,0].max,255].min
				color.green=[[g,0].max,255].min
				color.blue=[[b,0].max,255].min
				echoln "Drawing spot at X: #{xx} #{xOrg} Y: #{yy} #{yOrg}"
				finalspots.push([xOrg,yOrg,color])
				finalspots.push([xOrg+1,yOrg,color])
				finalspots.push([xOrg,yOrg+1,color])
				finalspots.push([xOrg+1,yOrg+1,color])
				#bitmap.set_pixel(xOrg,yOrg,color)
				#bitmap.set_pixel(xOrg+1,yOrg,color)
				#bitmap.set_pixel(xOrg,yOrg+1,color)
				#bitmap.set_pixel(xOrg+1,yOrg+1,color)
				
			end   
		end
	end
	return finalspots
end

def pbSpindaSpots(pokemon,bitmap)
	echoln "loading spots"
	spot1=[
		[0,0,1,1,1,1,0,0],
		[0,1,1,1,1,1,1,0],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[0,1,1,1,1,1,1,0],
		[0,0,1,1,1,1,0,0]
	]
	spot2=[
		[0,0,1,1,1,0,0],
		[0,1,1,1,1,1,0],
		[1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1],
		[0,1,1,1,1,1,0],
		[0,0,1,1,1,0,0]
	]
	spot3=[
		[0,0,0,0,0,1,1,1,1,0,0,0,0],
		[0,0,0,1,1,1,1,1,1,1,0,0,0],
		[0,0,1,1,1,1,1,1,1,1,1,0,0],
		[0,1,1,1,1,1,1,1,1,1,1,1,0],
		[0,1,1,1,1,1,1,1,1,1,1,1,0],
		[1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1],
		[0,1,1,1,1,1,1,1,1,1,1,1,0],
		[0,1,1,1,1,1,1,1,1,1,1,1,0],
		[0,0,1,1,1,1,1,1,1,1,1,0,0],
		[0,0,0,1,1,1,1,1,1,1,0,0,0],
		[0,0,0,0,0,1,1,1,0,0,0,0,0]
	]
	spot4=[
		[0,0,0,0,1,1,1,0,0,0,0,0],
		[0,0,1,1,1,1,1,1,1,0,0,0],
		[0,1,1,1,1,1,1,1,1,1,0,0],
		[0,1,1,1,1,1,1,1,1,1,1,0],
		[1,1,1,1,1,1,1,1,1,1,1,0],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,0],
		[0,1,1,1,1,1,1,1,1,1,1,0],
		[0,0,1,1,1,1,1,1,1,1,0,0],
		[0,0,0,0,1,1,1,1,1,0,0,0]
	]
	echoln "loaded spots"
	echoln "checking id"
	id=pokemon.personalID
	echoln id
	h = (id>>28)&15
  	g = (id>>24)&15
  	f = (id>>20)&15
  	e = (id>>16)&15
  	d = (id>>12)&15
  	c = (id>>8)&15
  	b = (id>>4)&15
  	a = (id)&15
	echoln "checked id"
	echoln id
	finalspots = []
	if pokemon.isShiny?
		
		echoln "drawing s spots 1"
		#finalspots.concat(drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150))
		for spot in drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing s spots 2"
		#finalspots.concat(drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150))
		for spot in drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing s spots 3"
		#finalspots.concat(drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150))
		for spot in drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing s spots 4"
		#finalspots.concat(drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150))
		for spot in drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
	else
		echoln "drawing spots 1"
		#finalspots.concat(drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75))
		for spot in drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing spots 2"
		#finalspots.concat(drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75))
		for spot in drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing spots 3"
		#finalspots.concat(drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75))
		for spot in drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
		echoln "drawing spots 4"
		#finalspots.concat(drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75))
		for spot in drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
			bitmap.set_pixel(spot[0],spot[1],spot[2])
		end
	end
	echoln "Number of spots is #{finalspots.length}"
	for spot in finalspots
		bitmap.set_pixel(spot[0],spot[1],spot[2])
	end
end

MultipleForms.register(:UNOWN,{
		"getFormOnCreation"=>proc{|pokemon|
			next rand(28)
		}
	})

MultipleForms.register(:UNOWNELDIW,{
		"getFormOnCreation"=>proc{|pokemon|
			xeno_maps = [457,458,459,460,585,588]

			if $game_map && xeno_maps.include?($game_map.map_id)
				next 1 #XENO FORM
			end
		}
	})

#MultipleForms.register(:SPINDA,{
#		"alterBitmap"=>proc{|pokemon,bitmap|
#			#pbSpindaSpots(pokemon,bitmap)
#		}
#	})

MultipleForms.register(:CASTFORM,{
		"type1"=>proc{|pokemon|
			next if pokemon.form==0            # Normal Form
			case pokemon.form
			when 1; next getID(PBTypes,:FIRE)  # Sunny Form
			when 2; next getID(PBTypes,:WATER) # Rainy Form
			when 3; next getID(PBTypes,:ICE)   # Snowy Form
			end
		},
		"type2"=>proc{|pokemon|
			next if pokemon.form==0            # Normal Form
			case pokemon.form
			when 1; next getID(PBTypes,:FIRE)  # Sunny Form
			when 2; next getID(PBTypes,:WATER) # Rainy Form
			when 3; next getID(PBTypes,:ICE)   # Snowy Form
			end
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:DEOXYS,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0               # Normal Forme
			case pokemon.form
			when 1; next [50,180, 20,150,180, 20] # Attack Forme
			when 2; next [50, 70,160, 90, 70,160] # Defense Forme
			when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
			end
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0    # Normal Forme
			case pokemon.form
			when 1; next [0,2,0,0,1,0] # Attack Forme
			when 2; next [0,0,2,0,0,1] # Defense Forme
			when 3; next [0,0,0,3,0,0] # Speed Forme
			end
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
					[25,:TAUNT],[33,:PURSUIT],[41,:PSYCHIC],[49,:SUPERPOWER],
					[57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:COSMICPOWER],
					[81,:ZAPCANNON],[89,:PSYCHOBOOST],[97,:HYPERBEAM]]
			when 2; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
					[25,:KNOCKOFF],[33,:SPIKES],[41,:PSYCHIC],[49,:SNATCH],
					[57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:IRONDEFENSE],
					[73,:AMNESIA],[81,:RECOVER],[89,:PSYCHOBOOST],
					[97,:COUNTER],[97,:MIRRORCOAT]]
			when 3; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:DOUBLETEAM],
					[25,:KNOCKOFF],[33,:PURSUIT],[41,:PSYCHIC],[49,:SWIFT],
					[57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:AGILITY],
					[81,:RECOVER],[89,:PSYCHOBOOST],[97,:EXTREMESPEED]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:BURMY,{
		"getFormOnCreation"=>proc{|pokemon|
			env=pbGetEnvironment()
			if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
				next 2 # Trash Cloak
			elsif env==PBEnvironment::Sand ||
				env==PBEnvironment::Rock ||
				env==PBEnvironment::Cave
				next 1 # Sandy Cloak
			else
				next 0 # Plant Cloak
			end
		},
		"getFormOnEnteringBattle"=>proc{|pokemon|
			env=pbGetEnvironment()
			if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
				next 2 # Trash Cloak
			elsif env==PBEnvironment::Sand ||
				env==PBEnvironment::Rock ||
				env==PBEnvironment::Cave
				next 1 # Sandy Cloak
			else
				next 0 # Plant Cloak
			end
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:WORMADAM,{
		"getFormOnCreation"=>proc{|pokemon|
			env=pbGetEnvironment()
			if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
				next 2 # Trash Cloak
			elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
				env==PBEnvironment::Cave
				next 1 # Sandy Cloak
			else
				next 0 # Plant Cloak
			end
		},
		"type2"=>proc{|pokemon|
			next if pokemon.form==0             # Plant Cloak
			case pokemon.form
			when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
			when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
			end
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0            # Plant Cloak
			case pokemon.form
			when 1; next [60,79,105,36,59, 85] # Sandy Cloak
			when 2; next [60,69, 95,36,69, 95] # Trash Cloak
			end
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0    # Plant Cloak
			case pokemon.form
			when 1; next [0,0,2,0,0,0] # Sandy Cloak
			when 2; next [0,0,1,0,0,1] # Trash Cloak
			end
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
					[23,:CONFUSION],[26,:ROCKBLAST],[29,:HARDEN],[32,:PSYBEAM],
					[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],[44,:PSYCHIC],
					[47,:FISSURE]]
			when 2; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
					[23,:CONFUSION],[26,:MIRRORSHOT],[29,:METALSOUND],
					[32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],
					[44,:PSYCHIC],[47,:IRONHEAD]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		}
	})

MultipleForms.register(:SHELLOS,{
		"getFormOnCreation"=>proc{|pokemon|
			maps=[629,630]   # Map IDs for second form
			pinkmaps=[631,632]
			if $game_map && maps.include?($game_map.map_id)
				next 1
			elsif $game_map && pinkmaps.include?($game_map.map_id)
				next 0
			end
			next
		}
	})

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:ROTOM,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0     # Normal Form
			next [50,65,107,86,105,107] # All alternate forms
		},
		"type2"=>proc{|pokemon|
			next if pokemon.form==0             # Normal Form
			case pokemon.form
			when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
			when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
			when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
			when 4; next getID(PBTypes,:FLYING) # Fan
			when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
			end
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
			moves=[
				:OVERHEAT,  # Heat, Microwave
				:HYDROPUMP, # Wash, Washing Machine
				:BLIZZARD,  # Frost, Refrigerator
				:AIRSLASH,  # Fan
				:LEAFSTORM  # Mow, Lawnmower
			]
			hasoldmove=-1
			for i in 0...4
				for j in 0...moves.length
					if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
						hasoldmove=i; break
					end
				end
				break if hasoldmove>=0
			end
			if form>0
				newmove=moves[form-1]
				if newmove!=nil && hasConst?(PBMoves,newmove)
					if hasoldmove>=0
						# Automatically replace the old form's special move with the new one's
						oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
						newmovename=PBMoves.getName(getID(PBMoves,newmove))
						pokemon.moves[hasoldmove]=PBMove.new(getID(PBMoves,newmove))
						Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
						Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename))
						Kernel.pbMessage(_INTL("And...\1"))
						Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[itemlevel]",pokemon.name,newmovename))
					else
						# Try to learn the new form's special move
						pbLearnMove(pokemon,getID(PBMoves,newmove),true)
					end
				end
			else
				if hasoldmove>=0
					# Forget the old form's special move
					oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
					pbDeleteMove(pokemon,hasoldmove)
					Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
					if pokemon.moves.find_all{|i| i.id!=0}.length==0
						pbLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
					end
				end
			end
		}
	})

MultipleForms.register(:GIRATINA,{
		"ability"=>proc{|pokemon|
			next if pokemon.form==0           # Altered Forme
			next getID(PBAbilities,:LEVITATE) # Origin Forme
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 650.0               # Origin Forme
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0       # Altered Forme
			next [150,120,100,90,120,100] # Origin Forme
		},
		"getForm"=>proc{|pokemon|
			maps=[49,50,51,72,73]   # Map IDs for Origin Forme
			if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
				($game_map && maps.include?($game_map.map_id))
				next 1
			end
			next 0
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SHAYMIN,{
		"type2"=>proc{|pokemon|
			next if pokemon.form==0     # Land Forme
			next getID(PBTypes,:FLYING) # Sky Forme
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0              # Land Forme
			next getID(PBAbilities,:SERENEGRACE) # Sky Forme
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Land Forme
			next 5.2                 # Sky Forme
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0      # Land Forme
			next [100,103,75,127,120,75] # Sky Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Land Forme
			next [0,0,0,3,0,0]      # Sky Forme
		},
		"getForm"=>proc{|pokemon|
			next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
			pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
			next nil
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
					[28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
					[55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
					[82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:ARCEUS,{
		"type1"=>proc{|pokemon|
			types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
				:ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
				:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
				:ICE,:DRAGON,:DARK]
			next getID(PBTypes,types[pokemon.form])
		},
		"type2"=>proc{|pokemon|
			types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
				:ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
				:FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
				:ICE,:DRAGON,:DARK]
			next getID(PBTypes,types[pokemon.form])
		},
		"getForm"=>proc{|pokemon|
			next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE)
			next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE)
			next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
			next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
			next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE)
			next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
			next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
			next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE)
			next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
			next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
			next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
			next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
			next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE)
			next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
			next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
			next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE)
			next 0
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:BASCULIN,{
		"getFormOnCreation"=>proc{|pokemon|
			next rand(2)
		},
		"wildHoldItems"=>proc{|pokemon|
			next if pokemon.form==0                 # Red-Striped
			next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
		}
	})

MultipleForms.register(:DARMANITAN,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0      # Standard Mode
			next [105,30,105,55,140,105] # Zen Mode
		},
		"type2"=>proc{|pokemon|
			next if pokemon.form==0      # Standard Mode
			next getID(PBTypes,:PSYCHIC) # Zen Mode
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Standard Mode
			next [0,0,0,0,2,0]      # Zen Mode
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:DEERLING,{
		"getForm"=>proc{|pokemon|
			time=pbGetTimeNow
			next (time.month-1)%4
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:TORNADUS,{
		"getAltitude"=>proc{|pokemon|
			next 0 if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0     # Incarnate Forme
			next [79,100,80,121,110,90] # Therian Forme
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0                # Incarnate Forme
			if pokemon.abilityflag && pokemon.abilityflag!=2
				next getID(PBAbilities,:REGENERATOR) # Therian Forme
			end
			next getID(PBAbilities,:REGENERATOR) # Therian Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Incarnate Forme
			next [0,0,0,3,0,0]      # Therian Forme
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:THUNDURUS,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0     # Incarnate Forme
			next [79,105,70,101,145,80] # Therian Forme
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0               # Incarnate Forme
			if pokemon.abilityflag && pokemon.abilityflag!=2
				next getID(PBAbilities,:VOLTABSORB) # Therian Forme
			end
			next getID(PBAbilities,:VOLTABSORB) # Therian Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Incarnate Forme
			next [0,0,0,0,3,0]      # Therian Forme
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:LANDORUS,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0    # Incarnate Forme
			next [89,145,90,71,105,80] # Therian Forme
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0               # Incarnate Forme
			if pokemon.abilityflag && pokemon.abilityflag!=2
				next getID(PBAbilities,:INTIMIDATE) # Therian Forme
			end
			next getID(PBAbilities,:INTIMIDATE) # Therian Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Incarnate Forme
			next [0,3,0,0,0,0]      # Therian Forme
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})



MultipleForms.register(:ENAMORUS,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0    # Incarnate Forme
			next [74,115,110,46,135,110] # Therian Forme
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0               # Incarnate Forme
			if pokemon.abilityflag && pokemon.abilityflag!=2
				next getID(PBAbilities,:OVERCOAT) # Therian Forme
			end
			next getID(PBAbilities,:OVERCOAT) # Therian Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Incarnate Forme
			next [0,3,0,0,0,0]      # Therian Forme
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:KYUREM,{
		"getBaseStats"=>proc{|pokemon|
			case pokemon.form
			when 1; next [125,120, 90,95,170,100] # White Kyurem
			when 2; next [125,170,100,95,120, 90] # Black Kyurem
			else;   next                          # Kyurem
			end
		},
		"ability"=>proc{|pokemon|
			case pokemon.form
			when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
			when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
			else;   next                                # Kyurem
			end
		},
		"evYield"=>proc{|pokemon|
			case pokemon.form
			when 1; next [0,0,0,0,3,0] # White Kyurem
			when 2; next [0,3,0,0,0,0] # Black Kyurem
			else;   next               # Kyurem
			end
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
					[15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
					[36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
					[57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
					[78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
			when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
					[15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
					[36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
					[57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
					[78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:KELDEO,{
		"getForm"=>proc{|pokemon|
			next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
			next 0                                     # Ordinary Form
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:MELOETTA,{
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0     # Aria Forme
			next [100,128,90,128,77,77] # Pirouette Forme
		},
		"type2"=>proc{|pokemon|
			next if pokemon.form==0       # Aria Forme
			next getID(PBTypes,:FIGHTING) # Pirouette Forme
		},
		"evYield"=>proc{|pokemon|
			next if pokemon.form==0 # Aria Forme
			next [0,1,1,1,0,0]      # Pirouette Forme
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:GENESECT,{
		"getForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
			next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
			next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
			next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
			next 0
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

## TRASFORMAZIONI TERRESTRI E XENOVERSE ###############
=begin
MultipleForms.register(:TRISHOUT,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:LEVITATE) # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,120,100,90,120,100] # Origin Forme
},
"getForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ANELLOT)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
=end

MultipleForms.register(:TRISHOUT,{
		"getPrimalForm"=>proc{|pokemon|
			next 3 if isConst?(pokemon.ability,PBAbilities,:VOICETUNING)
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 2 if $game_map.map_id == 126
			next 0
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0
			next getID(PBAbilities,:GUTS) if pokemon.form==1 	# Terrestre
			next getID(PBAbilities,:HUGEPOWER) if pokemon.form==2 		# Xenoverse
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.9 if pokemon.form==1 #T
			next 1.6 if pokemon.form==2 #X
			next 3.1 if pokemon.form==3 #A
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.9 if pokemon.form==1 #T
			next 1.6 if pokemon.form==2 #X
			next 3.1 if pokemon.form==3 #A
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 20.0 if pokemon.form==1 #T
			next 99.0 if pokemon.form==2 #X
			next 79.0 if pokemon.form==3 #A
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0 || pokemon.form == 4
			next [88,105,55,78,80,44] if pokemon.form==1  # Terrestre
			next [118,60,64,94,155,59] if pokemon.form==2  # Xenoverse
			next [143,140,90,93,140,94] if pokemon.form == 3 #Astro
		},
		"getForm"=>proc{|pokemon|
			if $game_switches[AUTOASTRO_SWITCH]==false
				if !pokemon.canPrimal?
					if isConst?(pokemon.item,PBItems,:ANELLOT)
						next 1 
					elsif isConst?(pokemon.item,PBItems,:ANELLOX)
						next 2 
					elsif !(isConst?(pokemon.item,PBItems,:ANELLOT) && isConst?(pokemon.item,PBItems,:ANELLOX))
						next 0 
					end
				end
			else
				next 3
			end
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:FIREPUNCH],[1,:JETSTRIKE],[1,:CHEERING],[1,:ROAR],[1,:EMBER],
					[1,:TACKLE],[8,:BABBLE],[13,:HOWL],[17,:TAKEDOWN],
					[21,:FIREFANG],[25,:UPROAR],[28,:SCREECH],[32,:FLAMETHROWER],
					[36,:HYPERVOICE],[38,:SOUNDBARRIER],[40,:SWAGGER],[45,:BOOMBURST],
					[51,:ROAR],[56,:SCARYFACE],[61,:FLAREBLITZ]]
			when 2; movelist=[[1,:PRIMALSCREAM],[1,:CHEERING],[1,:SCORCHEDASHES],[1,:HYPERVOICE],[1,:LAVAPLUME],
					[1,:NOBLEROAR],[1,:EMBER],[1,:TACKLE],[8,:BABBLE],
					[13,:HOWL],[17,:TAKEDOWN],[21,:FIREFANG],[25,:UPROAR],
					[28,:SCREECH],[32,:FLAMETHROWER],[36,:PRIMALSCREAM],[38,:SOUNDBARRIER],
					[40,:SWAGGER],[45,:BOOMBURST],[51,:NOBLEROAR],[56,:SCARYFACE],[61,:FLAREBLITZ]]
			when 3; movelist=[[1,:SCRATCH],[1,:GROWL],[6,:BABBLE],[8,:EMBER],[10,:HEADBUTT],
					[12,:BITE],[16,:SONICBOOM],[20,:FLAMEBURST],[25,:REVENGE],
					[30,:FIREFANG],[36,:FLAMETHROWER],[41,:TAKEDOWN],[51,:INFERNO],
					[56,:CRUNCH],[61,:FLAREBLITZ]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
			
		}
	})

MultipleForms.register(:SHYLEON,{
		"getPrimalForm"=>proc{|pokemon|
			#TODO sostituire il metodo con quello giusto
			next 3 if isConst?(pokemon.ability,PBAbilities,:JUNGLESPIRIT)
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 2 if $game_map.map_id == 126
			next 0
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form == 0
			next getID(PBAbilities,:QUICKFEET) if pokemon.form == 1				# Terrestre
			next getID(PBAbilities,:MAJESTICAURA) if pokemon.form==2		    # Xenoverse
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.8 if pokemon.form==1 #T
			next 2.7 if pokemon.form==2 #X
			next 2.9 if pokemon.form==3 #A
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.8 if pokemon.form==1 #T
			next 2.7 if pokemon.form==2 #X
			next 2.9 if pokemon.form==3 #A
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 22.5 if pokemon.form==1 #T
			next 77.0 if pokemon.form==2 #X
			next 80.0 if pokemon.form==3 #A
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form == 0
			next [88,49,63,104,78,68] if pokemon.form == 1						# Terrestre
			next [118,54,73,124,108,73] if pokemon.form == 2					# Xenoverse
			next [143,74,98,154,133,98] if pokemon.form == 3          # Astro
		},
		"getForm"=>proc{|pokemon|
			if $game_switches[AUTOASTRO_SWITCH]==false
				if !pokemon.canPrimal?
					if isConst?(pokemon.item,PBItems,:ANELLOT)
						next 1 
					elsif isConst?(pokemon.item,PBItems,:ANELLOX)
						next 2 
					elsif !(isConst?(pokemon.item,PBItems,:ANELLOT) && isConst?(pokemon.item,PBItems,:ANELLOX))
						next 0 
					end
				end
			else
				next 3
			end
			next
			$PokemonTemp.dependentEvents.refresh_sprite(true)
		},
		
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
				# Forma Terrestre
			when 1; movelist=[[1,:TEETERDANCE],[1,:PSYCHUP],[1,:BENEVOLENCE],[1,:LUNARDANCE],[1,:ABSORB],
					[1,:POUND],[8,:DISARMINGVOICE],[13,:GROWTH],[17,:CAMOUFLAGE],
					[21,:LEAFTORNADO],[25,:MAGICALLEAF],[28,:AGILITY],[32,:GIGADRAIN],
					[36,:DAZZLINGGLEAM],[38,:MAGICWALL],[40,:SYNTHESIS],[45,:MOONBLAST],[48,:EARTHPOWER],[51,:LUNARDANCE],
					[56,:GRASSWHISTLE],[61,:LEAFSTORM]]
				# Forma Xenoverse
			when 2; movelist=[[1,:FERALCLUTCH],[1,:HAWTHORNS],[1,:BENEVOLENCE],[1,:DAZZLINGGLEAM],[1,:HISS],[1,:EXTRASENSORY],
					[1,:ABSORB],[1,:POUND],[8,:DISARMINGVOICE],[13,:GROWTH],[17,:CAMOUFLAGE],
					[21,:LEAFTORNADO],[25,:MAGICALLEAF],[28,:AGILITY],[32,:GIGADRAIN],
					[36,:FERALCLUTCH],[38,:MAGICWALL],[40,:SYNTHESIS],[45,:MOONBLAST],[48,:EARTHPOWER],[51,:EXTRASENSORY],
					[56,:GRASSWHISTLE],[61,:LEAFSTORM]]
			when 3; movelist = [[1,:POUND],[1,:LEER],[6,:DISARMINGVOICE],[8,:ABSORB],
					[10,:GROWTH],[12,:DRAININGKISS],[16,:AGILITY],[20,:PURSUIT],
					[25,:CURSE],[30,:GIGADRAIN],[36,:TAKEDOWN],[41,:DETECT],[48,:EARTHPOWER],[51,:WORRYSEED],
					[56,:FUTURESIGHT],[61,:LEAFSTORM]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SHULONG,{
		"getPrimalForm"=>proc{|pokemon|
			#TODO sostituire il metodo con quello giusto
			next 3 if isConst?(pokemon.ability,PBAbilities,:DRAGONARMOR)
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 2 if $game_map.map_id == 126
			next 0
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0
			next getID(PBAbilities,:MARVELSCALE) if pokemon.form==1		# Forma Terrestre
			next getID(PBAbilities,:SWIFTSWIM) if pokemon.form==2	# Forma Xenoverse
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.8 if pokemon.form==1 #T
			next 2.2 if pokemon.form==2 #X
			next 3.1 if pokemon.form==3 #A
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 29.0 if pokemon.form==1 #T
			next 88.0 if pokemon.form==2 #X
			next 130.0 if pokemon.form==3 #A
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0 
			next [88,45,93,56,75,93] if pokemon.form == 1						# Forma Terrestre
			next [118,55,110,72,85,110] if pokemon.form == 2				# Forma Xenoverse
			next [143,80,156,86,80,155] if pokemon.form == 3      # Forma Astro
		},
		"getForm"=>proc{|pokemon|
			if $game_switches[AUTOASTRO_SWITCH]==false
				if !pokemon.canPrimal?
					if isConst?(pokemon.item,PBItems,:ANELLOT)
						next 1 
					elsif isConst?(pokemon.item,PBItems,:ANELLOX)
						next 2 
					elsif !(isConst?(pokemon.item,PBItems,:ANELLOT) && isConst?(pokemon.item,PBItems,:ANELLOX))
						next 0 
					end
				end
			else
				next 3
			end
			next
			$PokemonTemp.dependentEvents.refresh_sprite(true)
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:IRONDEFENSE],[1,:SLASH],[1,:AQUARING],[1,:WATERGUN],
					[1,:TACKLE],[8,:TWISTER],[13,:HARDEN],[17,:BIDE],[21,:BUBBLEBEAM],
					[25,:DRAGONBREATH],[28,:PROTECT],[32,:MUDDYWATER],[36,:DRAGONTAIL],[38,:DRAGONENDURANCE],[40,:RECOVER],
					[45,:DRAGONPULSE],[48,:VELVETSCALES],[51,:AQUARING],[54,:ACIDRAIN],[56,:RAINDANCE],[61,:HYDROPUMP]]
			when 2; movelist=[[1,:TIDALDRAGOON],[1,:DRAGONTAIL],[1,:RAZORSHELL],[1,:CRUSHCLAW],[1,:WATERGUN],
					[1,:TACKLE],[8,:TWISTER],[13,:HARDEN],[17,:BIDE],[21,:BUBBLEBEAM],
					[25,:DRAGONBREATH],[28,:PROTECT],[32,:MUDDYWATER],[36,:TIDALDRAGOON],[38,:DRAGONENDURANCE],[40,:RECOVER],
					[45,:DRAGONPULSE],[48,:VELVETSCALES],[51,:CRUSHCLAW],[54,:ACIDRAIN],[56,:RAINDANCE],[61,:HYDROPUMP]]	
			when 3; movelist = [[1,:TACKLE],[1,:LEER],[6,:WATERGUN],[8,:DUALCHOP],[10,:PROTECT],
					[12,:BIDE],[16,:BUBBLEBEAM],[20,:RAINDANCE],[25,:RECOVER],
					[30,:AQUATAIL],[36,:MUDDYWATER],[41,:TAKEDOWN],[51,:ACIDARMOR],
					[56,:RAINDANCE],[61,:HYDROPUMP]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SABOLT,{
		"getFormOnCreation"=>proc{|pokemon|
			#next 2 if $game_map.map_id == 126
			next 0
		},
		"ability"=>proc{|pokemon|
			next if pokemon.form==0
			next getID(PBAbilities,:INTIMIDATE) if pokemon.form==1 	# Terrestre
			next getID(PBAbilities,:INTIMIDATE) if pokemon.form==2 		# Xenoverse
		},
		"height"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 0.8 if pokemon.form==1 #T
			next 1.7 if pokemon.form==2 #X
		},
		"weight"=>proc{|pokemon|
			next if pokemon.form==0 # Altered Forme
			next 21.7 if pokemon.form==1 #T
			next 111.0 if pokemon.form==2 #X
		},
		"getBaseStats"=>proc{|pokemon|
			next if pokemon.form==0
			next [88,66,70,80,78,68] if pokemon.form==1  # Terrestre
			next [118,67,123,60,142,90] if pokemon.form==2  # Xenoverse
		},
		"getForm"=>proc{|pokemon|
			if $game_switches[AUTOASTRO_SWITCH]==false
				if !pokemon.canPrimal?
					if isConst?(pokemon.item,PBItems,:ANELLOT)
						next 1 
					elsif isConst?(pokemon.item,PBItems,:ANELLOX)
						next 2 
					elsif !(isConst?(pokemon.item,PBItems,:ANELLOT) && isConst?(pokemon.item,PBItems,:ANELLOX))
						next 0 
					end
				end
			else
				next 3
			end
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:THUNDERPUNCH],[1,:KNOCKOFF],[1,:MEANLOOK],[1,:THUNDERSHOCK],
					[1,:TACKLE],[6,:PURSUIT],[8,:EMBARGO],[13,:ASSURANCE],[18,:SHOCKWAVE],
					[23,:SUCKERPUNCH],[28,:SCARYFACE],[32,:THUNDERBOLT],[36,:DISCHARGE],
					[40,:NASTYPLOT],[45,:NIGHTDAZE],[51,:GLARE],[56,:PHANTOMFORCE],[61,:VOLTTACKLE]]
			when 2; movelist=[[1,:DARKENINGBOLT],[1,:METALBURST],[1,:CRUNCH],
					[1,:MEANLOOK],[1,:THUNDERSHOCK],[1,:FLAMETHROWER],[1,:SCALD],
					[1,:DRAGONPULSE],[1,:DAZZLINGGLEAM],[1,:ENERGYBALL],[1,:HYPERVOICE],
					[1,:FLASHCANNON],[1,:TACKLE],[6,:PURSUIT],
					[8,:EMBARGO],[13,:ASSURANCE],[18,:SHOCKWAVE],[23,:SUCKERPUNCH],
					[28,:SCARYFACE],[32,:THUNDERBOLT],[36,:DARKENINGBOLT],[40,:NASTYPLOT],
					[45,:NIGHTDAZE],[51,:GLARE],[56,:THROATCHOP],[61,:VOLTTACKLE]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
			
		}
	})

MultipleForms.register(:TRANPILLE, {
		"getFormOnCreation"=>proc{|pokemon|
			gengar_maps = [1, 232, 233, 234, 235, 236, 237, 238, 239, 240, 242]
			weavile_maps = [12, 13, 15, 16, 17, 19, 20, 21]
			houndoom_maps = [106, 109, 119, 120, 121, 122, 123, 124, 125, 126, 129, 254, 282, 283, 284, 285]
			ampharos_maps = [181]
			heracross_maps = [18, 77, 450]
			braviary_maps = [135, 241, 263, 266, 275]
			venusaur_maps = [281]
			camerupt_maps = [78, 598]
			bouffalant_maps = [219]
			beedreill_maps = [267, 268, 269, 270, 600]
			tyranitar_maps = [387, 408, 409, 411, 468, 469, 470, 471, 473, 474, 475, 476, 477, 479, 480]
			steelix_maps = [276, 594]
			blastoise_maps = [349]
			hypno_maps = [481, 604]
			alakazam_maps = [271, 286, 287, 288, 289, 290, 292, 293, 294, 295, 296]
			dragonite_maps = [42, 107]
			granbull_maps = [22, 79]
			
			if $game_map && gengar_maps.include?($game_map.map_id)
				next 1
			elsif $game_map && weavile_maps.include?($game_map.map_id)
				next 2
			elsif $game_map && houndoom_maps.include?($game_map.map_id)
				next 3
			elsif $game_map && ampharos_maps.include?($game_map.map_id)
				next 4
			elsif $game_map && heracross_maps.include?($game_map.map_id)
				next 5			
			elsif $game_map && braviary_maps.include?($game_map.map_id)
				next 6
			elsif $game_map && venusaur_maps.include?($game_map.map_id)
				next 7
			elsif $game_map && camerupt_maps.include?($game_map.map_id)
				next 8
			elsif $game_map && bouffalant_maps.include?($game_map.map_id)
				next 9
			elsif $game_map && beedrill_maps.include?($game_map.map_id)
				next 10
			elsif $game_map && tyranitar_maps.include?($game_map.map_id)
				next 11
			elsif $game_map && steelix_maps.include?($game_map.map_id)
				next 12
			elsif $game_map && blastoise_maps.include?($game_map.map_id)
				next 13
			elsif $game_map && hypno_maps.include?($game_map.map_id)
				next 14
			elsif $game_map && alakazam_maps.include?($game_map.map_id)
				next 15
			elsif $game_map && dragonite_maps.include?($game_map.map_id)
				next 16
			elsif $game_map && granbull_maps.include?($game_map.map_id)
				next 17
			else
				next 0
			end
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:GHOST) if pokemon.form == 1   # Gengar Form
			next getID(PBTypes,:ICE) if pokemon.form == 2     # Glalie Form
			next getID(PBTypes,:DARK) if pokemon.form == 3     # Heracross Form
			next getID(PBTypes,:ELECTRIC) if pokemon.form == 4    # Houndoom Form
			next getID(PBTypes,:FIGHTING) if pokemon.form == 5
			next getID(PBTypes,:FLYING) if pokemon.form == 6
			next getID(PBTypes,:GRASS) if pokemon.form == 7
			next getID(PBTypes,:GROUND) if pokemon.form == 8
			next getID(PBTypes,:NORMAL) if pokemon.form == 9
			next getID(PBTypes,:POISON) if pokemon.form == 10
			next getID(PBTypes,:ROCK) if pokemon.form == 11
			next getID(PBTypes,:STEEL) if pokemon.form == 12
			next getID(PBTypes,:WATER) if pokemon.form == 13
			next getID(PBTypes,:SUONO) if pokemon.form == 14
			next getID(PBTypes,:PSYCHIC) if pokemon.form == 15
			next getID(PBTypes,:DRAGON) if pokemon.form == 16
			next getID(PBTypes,:FAIRY) if pokemon.form == 17
			next 
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:TWINEEDLE],[1,:STRINGSHOT],[6,:FELLSTINGER],
					[10,:MIMIC],[12,:SHADOWSNEAK],[15,:BUGBITE],[18,:SCARYFACE],
					[22,:HEX],[26,:ACUPRESSURE],[30,:DIG],[34,:SHADOWBALL],
					[40,:MEGAHORN],[47,:MINIMIZE],[52,:PHANTOMFORCE]]
			when 2; movelist=[[1,:TWINEEDLE],[1,:STRINGSHOT],[6,:FELLSTINGER],[10,:MIMIC],
					[12,:POWDERSNOW],[15,:BUGBITE],[18,:SCARYFACE],[22,:ICEFANG],
					[26,:ACUPRESSURE],[30,:DIG],[34,:ICICLECRASH],[40,:MEGAHORN],
					[47,:MINIMIZE],[52,:BLIZZARD]]
			when 3; movelist=[[1,:TWINEEDLE],[1,:STRINGSHOT],[6,:FELLSTINGER],[10,:MIMIC],
					[12,:TWINEEDLE],[15,:BUGBITE],[18,:SCARYFACE],[22,:STEAMROLLER],
					[26,:ACUPRESSURE],[30,:DIG],[34,:XSCISSOR],[40,:MEGAHORN],
					[47,:MINIMIZE],[52,:UTURN]]
			when 4; movelist=[[1,:TWINEEDLE],[1,:STRINGSHOT],[6,:FELLSTINGER],[10,:MIMIC],
					[12,:PURSUIT],[15,:BUGBITE],[18,:SCARYFACE],[22,:SNARL],
					[26,:ACUPRESSURE],[30,:DIG],[34,:CRUNCH],[40,:MEGAHORN],
					[47,:MINIMIZE],[52,:FOULPLAY]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:BREMAND,{
		"getFormOnCreation"=>proc{|pokemon|
			guitar_maps=[40,631,632]   
			drum_maps=[280,627,628]  
			bass_maps=[135,241,263,266,275,629,630] 
			if $game_map && guitar_maps.include?($game_map.map_id)
				next 1 # GUITAR FORM
			elsif $game_map && drum_maps.include?($game_map.map_id)
				next 2 # DRUM FORM
			elsif $game_map && bass_maps.include?($game_map.map_id)
				next 3 # BASS FORM
			else
				next 0
			end
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:ELECTRIC) if pokemon.form == 1
			next getID(PBTypes,:FIGHTING) if pokemon.form == 2
			next getID(PBTypes,:DARK) if pokemon.form == 3
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [60,60,80,100,100,80] if pokemon.form == 1
			next [100,100,80,60,80,60] if pokemon.form == 2
			next [80,60,100,80,60,100] if pokemon.form == 3
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:GROWL],[1,:POUND],[5,:THUNDERSHOCK],[10,:SING],[15,:THUNDERWAVE],[20,:CHARGEBEAM],[25,:SCREECH],[30,:UPROAR],[35,:HELPINGHAND],[40,:OVERDRIVE],[45,:ELECTROSWING],[50,:THUNDERBOLT],[55,:BOOMBURST],[60,:WILDDANCE]]
			when 2; movelist=[[1,:GROWL],[1,:POUND],[5,:ROCKSMASH],[10,:SING],[15,:BULKUP],[20,:WAKEUPSLAP],[25,:SCREECH],[30,:UPROAR],[35,:HELPINGHAND],[40,:VITALTHROW],[45,:BELLYDRUM],[50,:HAMMERARM],[55,:BOOMBURST],[60,:WILDDANCE]]
			when 3; movelist=[[1,:GROWL],[1,:POUND],[5,:PURSUIT],[10,:SING],[15,:TORMENT],[20,:ASSURANCE],[25,:SCREECH],[30,:UPROAR],[35,:HELPINGHAND],[40,:CRUNCH],[45,:BLUENOTE],[50,:FOULPLAY],[55,:BOOMBURST],[60,:WILDDANCE]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"height"=>proc{|pokemon|
			next 1.0 if pokemon.form == 1
			next 1.7 if pokemon.form == 2
			next 2.0 if pokemon.form == 3
			next
		},
		"weight"=>proc{|pokemon|
			next 30.8 if pokemon.form == 1
			next 65.0 if pokemon.form == 2
			next 67.8 if pokemon.form == 3
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:RAPIDASHX,{
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:ELECTRIC) if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [65, 80, 70, 145, 140, 60] if pokemon.form == 1
			next 
		}
	})

MultipleForms.register(:MEW, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 428
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:LUGIA, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 440
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})
MultipleForms.register(:HOOH, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 478
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:CELEBI, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 443
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:RAIKOU, {
		"getMegaForm"=>proc{|pokemon|
			next 2 if isConst?(pokemon.item,PBItems,:RAIKOUITE) && (pokemon.form == 0 || pokemon.form==2)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 2
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Raikou") if pokemon.form==2
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [90,105,95,135,135,120] if pokemon.form==2
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 448
			next 
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:TERAVOLT) if pokemon.form==2
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})



MultipleForms.register(:ENTEI, {
		"getMegaForm"=>proc{|pokemon|
			next 2 if isConst?(pokemon.item,PBItems,:ENTEITE) && (pokemon.form == 0 || pokemon.form==2)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 2
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Entei") if pokemon.form==2
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [115,135,105,120,110,95] if pokemon.form==2
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 445
			next 
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:SHEERFORCE) if pokemon.form==2
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SUICUNE, {
		"getMegaForm"=>proc{|pokemon|
			next 2 if isConst?(pokemon.item,PBItems,:SUICUNITE) && (pokemon.form == 0 || pokemon.form==2)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 2
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Suicune") if pokemon.form==2
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [100,95,135,105,120,135] if pokemon.form==2
			next
		},
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 461
			next 
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:ICEBODY) if pokemon.form==2
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})


MultipleForms.register(:DEOXYS, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 434
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:CRESSELIA, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 430
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:DARKRAI, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 306
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:HEATRAN, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 426
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:GENESECT, {
		"getFormOnCreation"=>proc{|pokemon|
			next 1 if $game_map.map_id == 432
			next 
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# BULBASAUR
MultipleForms.register(:BULBASAUR,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:POISON) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:SCRATCH],[1,:GROWL],[4,:EMBER],[8,:SMOKESCREEN],
		[12,:DRAGONBREATH],[17,:FIREFANG],[20,:SLASH],[24,:FLAMETHROWER],
		[28,:SCARYFACE],[32,:FIRESPIN],[36,:INFERNO],[40,:FLAREBLITZ]]	if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# IVYSAUR
MultipleForms.register(:IVYSAUR,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:POISON) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:SCRATCH],[1,:GROWL],[1,:EMBER],[1,:SMOKESCREEN],
		[12,:DRAGONBREATH],[19,:FIREFANG],[24,:SLASH],[30,:FLAMETHROWER],
		[37,:SCARYFACE],[42,:FIRESPIN],[48,:INFERNO],[54,:FLAREBLITZ]] if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# CHARMANDER
MultipleForms.register(:CHARMANDER,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[18,:PROTECT],
		[21,:RAINDANCE],[24,:AQUATAIL],[27,:SHELLSMASH],
		[30,:IRONDEFENSE],[33,:HYDROPUMP],[36,:SKULLBASH]]	if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# CHARMELEON
MultipleForms.register(:CHARMELEON,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# SQUIRTLE
MultipleForms.register(:SQUIRTLE,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:TACKLE],[1,:GROWL],[3,:VINEWHIP],[6,:GROWTH],
		[9,:LEECHSEED],[12,:RAZORLEAF],[15,:SLEEPPOWDER],[15,:POISONPOWDER],
		[18,:SEEDBOMB],[21,:TAKEDOWN],[24,:SWEETSCENT],[27,:SYNTHESIS],
		[30,:WORRYSEED],[33,:DOUBLEEDGE],[36,:SOLARBEAM]]	if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# WARTORTLE
MultipleForms.register(:WARTORTLE,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==10
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==10
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		movelist = [[1,:TACKLE],[1,:GROWL],[1,:VINEWHIP],[1,:GROWTH],
		[9,:LEECHSEED],[12,:RAZORLEAF],[15,:SLEEPPOWDER],[15,:POISONPOWDER],
		[20,:SEEDBOMB],[25,:TAKEDOWN],[30,:SWEETSCENT],[35,:SYNTHESIS],
		[40,:WORRYSEED],[45,:DOUBLEEDGE],[58,:SOLARBEAM]] if pokemon.form == 10
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

##### Mega Evolution forms #####################################################

# VENUSAUR
MultipleForms.register(:VENUSAUR,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:VENUSAURITE) && (pokemon.form == 0 || pokemon.form == 1)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 1
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:FIRE) if pokemon.form==10
			next			
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Venusaur") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [80,100,123,80,122,120] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:THICKFAT) if pokemon.form==1
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0 
			movelist = [[1,:DRAGONCLAW],[1,:AIRSLASH],[1,:HEATWAVE],[1,:SCRATCH],
			[1,:GROWL],[1,:EMBER],[1,:SMOKESCREEN],[12,:DRAGONBREATH],[19,:FIREFANG],
			[24,:SLASH],[30,:FLAMETHROWER],[39,:SCARYFACE],[46,:FIRESPIN],
			[54,:INFERNO],[62,:FLAREBLITZ]]		if pokemon.form == 10
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"height"=>proc{|pokemon|
			next 2.4 if pokemon.form==1
			next
		},
		"weight"=>proc{|pokemon|
			next 155.5 if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# CHARIZARD
MultipleForms.register(:CHARIZARD,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:CHARIZARDITET) && (pokemon.form == 0 || pokemon.form == 1)
			next 2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEX) && (pokemon.form == 0 || pokemon.form == 2)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 1 || pokemon.form == 2
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:WATER) if pokemon.form==10
			next			
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Charizard Y") if pokemon.form==1
			next _INTL("Mega Charizard X") if pokemon.form==2
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [78,104,78,100,159,115] if pokemon.form==1
			next [78,130,111,100,130,85] if pokemon.form==2
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:DRAGON) if pokemon.form==2
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0 
			movelist = [[1,:FLASHCANNON],[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],
			[1,:WITHDRAW],[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
			[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[42,:IRONDEFENSE],
			[49,:HYDROPUMP],[56,:SKULLBASH]]	if pokemon.form == 10
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:DROUGHT) if pokemon.form==1
			next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==2
			next
		},
		"weight"=>proc{|pokemon|
			next 110.5 if pokemon.form==1
			next 100.5 if pokemon.form==2
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# BLASTOISE
MultipleForms.register(:BLASTOISE,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:BLASTOISINITE) && (pokemon.form == 0 || pokemon.form == 1)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 1
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:GRASS) if pokemon.form==10
			next			
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:GRASS) if pokemon.form==10
			next			
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Blastoise") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [79,103,120,78,135,115] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0 
			movelist = [[1,:PETALBLIZZARD],[1,:TACKLE],[1,:GROWL],[1,:VINEWHIP],[1,:PETALDANCE],
			[1,:GROWTH],[9,:LEECHSEED],[12,:RAZORLEAF],[15,:SLEEPPOWDER],
			[15,:POISONPOWDER],[20,:SEEDBOMB],[25,:TAKEDOWN],[30,:SWEETSCENT],
			[37,:SYNTHESIS],[44,:WORRYSEED],[51,:DOUBLEEDGE],[58,:SOLARBEAM]]	if pokemon.form == 10
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"weight"=>proc{|pokemon|
			next 101.1 if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SCEPTILE, {
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:SCEPTILITE) && (pokemon.form == 0 || pokemon.form == 1)
		next
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:DRAGON) if pokemon.form==1
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 1
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Sceptile") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [70,110,75,145,145,85] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:LIGHTNINGROD) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

MultipleForms.register(:AUDINO, {
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 1
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Audino") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [103,60,126,50,80,126] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:HEALER) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

# BEEDRILL
MultipleForms.register(:BEEDRILL, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item, PBItems, :BEEDRILLITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Beedrill") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [65, 150, 40, 145, 15, 80] if pokemon.form == 1	
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :ADAPTABILITY) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.4 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 40.5 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# ALAKAZAM
MultipleForms.register(:ALAKAZAM, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:ALAKAZITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Alakazam") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [55, 50, 65, 150, 175, 105] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :TRACE) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.2 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 48.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# GENGAR
MultipleForms.register(:GENGAR, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:GENGARITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 1
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Gengar") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [60, 65, 80, 130, 170, 95] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SHADOWTAG) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.4 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 40.5 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# GYARADOS
MultipleForms.register(:GYARADOS, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:GYARADOSITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Gyarados") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [95, 155, 109, 81, 70, 130] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :MOLDBREAKER) if pokemon.form == 1
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:DARK) if pokemon.form==1
			next
		},
		"height"=>proc{|pokemon|
			next 6.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 305.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# STEELIX
MultipleForms.register(:STEELIX, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:STEELIXITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Steelix") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [75, 125, 230, 30, 55, 95] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SANDFORCE) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 10.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 740.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# SCIZOR
MultipleForms.register(:SCIZOR, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:SCIZORITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Scizor") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70, 150, 140, 75, 65, 100] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :TECHNICIAN) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.0 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 125.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# HERACROSS
MultipleForms.register(:HERACROSS, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:HERACRONITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Heracross") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [80, 185, 115, 75, 40, 105] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SKILLLINK) if pokemon.form == 1
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:FIGHTING) if pokemon.form==1
			next
		},
		"height"=>proc{|pokemon|
			next 1.7 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 62.5 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# HOUNDOOM
MultipleForms.register(:HOUNDOOM, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:HOUNDOOMITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Houndoom") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [75, 90, 90, 115, 140, 90] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SOLARPOWER) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.9 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 49.5 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# TYRANITAR
MultipleForms.register(:TYRANITAR, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:TYRANITARITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Tyranitar") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [100, 164, 150, 71, 95, 120] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SANDSTREAM) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 255.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# AGGRON
MultipleForms.register(:AGGRON, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:AGGRONITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Aggron") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70, 140, 230, 50, 60, 80] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :TECHNICIAN) if pokemon.form == 1
			next
		},
		"type2"=>proc{|pokemon|
			next nil if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.2 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 395.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:BLAZIKEN, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:BLAZIKENITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Blaziken") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [80, 160, 80, 100, 130, 80] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SPEEDBOOST) if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

MultipleForms.register(:SWAMPERT, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:SWAMPERTITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Swampert") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [100,150,110,70,95,110] if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.9 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 102.0 if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SWIFTSWIM) if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# SHARPEDO
MultipleForms.register(:SHARPEDO, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:SHARPEDONITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Sharpedo") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70, 140, 70, 105, 110, 65] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :STRONGJAW) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 130.3 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# CAMERUPT
MultipleForms.register(:CAMERUPT, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:CAMERUPTITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Camerupt") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70, 120, 100, 20, 145, 105] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SHEERFORCE) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 320.5 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# METAGROSS
MultipleForms.register(:METAGROSS, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:METAGROSSITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Metagross") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [80, 145, 150, 110, 105, 110] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :TOUGHCLAW) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 2.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 942.9 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# LOPUNNY
MultipleForms.register(:LOPUNNY, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:LOPUNNITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Lopunny") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [65, 136, 94, 135, 54, 96] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :SCRAPPY) if pokemon.form == 1
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:FIGHTING) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.3 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 28.3 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# AUDINO
MultipleForms.register(:AUDINO, {
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Audino") if pokemon.form == 1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [103, 60, 126, 50, 80, 126] if pokemon.form == 1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities, :HEALER) if pokemon.form == 1
			next
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:SOUND) if pokemon.form == 1
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:FAIRY) if pokemon.form == 1
			next
		},
		"height"=>proc{|pokemon|
			next 1.5 if pokemon.form == 1
			next
		},
		"weight"=>proc{|pokemon|
			next 32.0 if pokemon.form == 1
			next
		},
		"onSetForm"=>proc{|pokemon, form|
			pbSeenForm(pokemon)
		}
	})

# AMPHAROS
MultipleForms.register(:AMPHAROS,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:AMPHAROSITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Ampharos") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [79,103,120,78,135,115] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
			next
		},
		"weight"=>proc{|pokemon|
			next 61.5 if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# ABSOL
MultipleForms.register(:ABSOL,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:ABSOLITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Absol") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [79,103,120,78,135,115] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
			next
		},
		"weight"=>proc{|pokemon|
			next 49.0 if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# LUCARIO
MultipleForms.register(:LUCARIO,{
		"getMegaForm"=>proc{|pokemon|
			next 2 if isConst?(pokemon.item,PBItems,:LUCARITE) && (pokemon.form == 0 || pokemon.form == 2)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0 if pokemon.form == 2
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Lucario") if pokemon.form==2
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70,145,88,112,140,70] if pokemon.form==2
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==2
			next
		},
		"height"=>proc{|pokemon|
			next 1.3 if pokemon.form==2
			next
		},
		"weight"=>proc{|pokemon|
			next 57.5 if pokemon.form==2
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# HYPNO
MultipleForms.register(:HYPNO,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:HYPNOITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Hypno") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [80,100,123,80,122,120] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:INSOMNIA) if pokemon.form==1
			next
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:SUONO) if pokemon.form==1
			next
		},
		"height"=>proc{|pokemon|
			next 2.4 if pokemon.form==1
			next
		},
		"weight"=>proc{|pokemon|
			next 155.5 if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# WEAVILE
MultipleForms.register(:WEAVILE,{
		"getMegaForm"=>proc{|pokemon|
			next 1 if isConst?(pokemon.item,PBItems,:WEAVILITE)
			next
		},
		"getUnmegaForm"=>proc{|pokemon|
			next 0
		},
		"getMegaName"=>proc{|pokemon|
			next _INTL("Mega Weavile") if pokemon.form==1
			next
		},
		"getBaseStats"=>proc{|pokemon|
			next [70,165,90,135,55,95] if pokemon.form==1
			next
		},
		"ability"=>proc{|pokemon|
			next getID(PBAbilities,:TECHNICIAN) if pokemon.form==1
			next
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

# WEAVILE
MultipleForms.register(:GARCHOMP,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:GARCHOMPITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Garchomp") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [108,170,115,92,120,95] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:SANDFORCE) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})
#===============================================================================
# MASGOT HANDLING
#===============================================================================
MultipleForms.register(:MASGOT,{
		"getFormOnCreation"=>proc{|pokemon|
			heracross_maps = [40]
			houndoom_maps = [165,166,167,169,170,171]
			ampharos_maps = [181,182,559]
			bouffalant_maps = [219,224,225,226,227,228,229,230]
			camerupt_maps = [78,80,86,435,436,437,438,439,596,598]
			steelix_maps = [276,593,594]
			alakazam_maps = [286,287,288,289,290,292,294,627,628]
			dragonite_maps = [42]
			granbull_maps = [79]

			#dlc
			gengar_maps = [444,569,571,573]
			venusaur_maps = [446,575,577,579,581]
			weavile_maps = [457,458,459,585,588]

			hypno_maps = [602,604]
			beedrill_maps = [599,600]

			blastoise_maps = [629,630]
			braviary_maps = [631,632]
			tyranitar_maps = [633,637]

			if $game_map && gengar_maps.include?($game_map.map_id)
				next 1 #GENGAR FORM
			elsif $game_map && weavile_maps.include?($game_map.map_id)
				next 2 #WEAVILE FORM
			elsif $game_map && heracross_maps.include?($game_map.map_id)
				next 6 #HERACROSS FORM
			elsif $game_map && venusaur_maps.include?($game_map.map_id)
				next 8 #VENUSAUR FORM
			elsif $game_map && houndoom_maps.include?($game_map.map_id)
				next 4 #HOUNDOOM FORM
			elsif $game_map && ampharos_maps.include?($game_map.map_id)
				next 5 #AMPHAROS FORM
			elsif $game_map && braviary_maps.include?($game_map.map_id)
				next 7 #BRAVIARY FORM
			elsif $game_map && tyranitar_maps.include?($game_map.map_id)
				next 9 #TYRANITAR FORM
			elsif $game_map && bouffalant_maps.include?($game_map.map_id)
				next 10 #BOUFFALANT FORM
			elsif $game_map && beedrill_maps.include?($game_map.map_id)
				next 11 #BEEDRILl MAPS
			elsif $game_map && camerupt_maps.include?($game_map.map_id)
				next 12 #CAMERUPT FORM
			elsif $game_map && steelix_maps.include?($game_map.map_id)
				next 13 #STEELIX FORM
			elsif $game_map && blastoise_maps.include?($game_map.map_id)
				next 14 #BLASTOISE FORM
			elsif $game_map && hypno_maps.include?($game_map.map_id)
				next 15 #HYPNO FORM
			elsif $game_map && alakazam_maps.include?($game_map.map_id)
				next 16 #ALAKAZAM FORM
			elsif $game_map && dragonite_maps.include?($game_map.map_id)
				next 17 #DRAGONITE FORM
			elsif $game_map && granbull_maps.include?($game_map.map_id)
				next 18 #GRANBULL FORM
			else
				next
			end
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:GHOST) if pokemon.form == 1   # Gengar Form
			next getID(PBTypes,:ICE) if pokemon.form == 2     # Weavile Form
			next getID(PBTypes,:DARK) if pokemon.form == 4     # Heracross Form
			next getID(PBTypes,:ELECTRIC) if pokemon.form == 5    # Houndoom Form
			next getID(PBTypes,:FIGHTING) if pokemon.form == 6
			next getID(PBTypes,:FLYING) if pokemon.form == 7
			next getID(PBTypes,:GRASS) if pokemon.form == 8
			next getID(PBTypes,:ROCK) if pokemon.form == 9
			next getID(PBTypes,:NORMAL) if pokemon.form == 10
			next getID(PBTypes,:POISON) if pokemon.form == 11
			next getID(PBTypes,:GROUND) if pokemon.form == 12
			next getID(PBTypes,:STEEL) if pokemon.form == 13
			next getID(PBTypes,:WATER) if pokemon.form == 14
			next getID(PBTypes,:SUONO) if pokemon.form == 15
			next getID(PBTypes,:PSYCHIC) if pokemon.form == 16
			next getID(PBTypes,:DRAGON) if pokemon.form == 17
			next getID(PBTypes,:FAIRY) if pokemon.form == 18
			next 
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.form==0
			movelist=[]
			case pokemon.form
			when 1; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:ASTONISH],[10,:CONFUSERAY],
					[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:HEX],
					[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],
					[45,:FELLSTINGER],[50,:SHADOWBALL]]
			when 2; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:ICESHARD],[10,:TAUNT],
					[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:AVALANCHE],[30,:STICKYWEB],
					[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:ICICLECRASH]]
			when 4; movelist=[[1,:TWINEEDLE],[1,:STRINGSHOT],[6,:FELLSTINGER],[10,:MIMIC],
					[12,:PURSUIT],[15,:BUGBITE],[18,:SCARYFACE],[22,:SNARL],
					[26,:ACUPRESSURE],[30,:DIG],[34,:CRUNCH],[40,:MEGAHORN],
					[47,:MINIMIZE],[52,:FOULPLAY]]
			when 5; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:THUNDERSHOCK],[10,:THUNDERWAVE],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:ELECTROBALL],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:THUNDERBOLT]]
			when 6; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:HORNATTACK],[10,:BULKUP],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:BRICKBREAK],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:CLOSECOMBAT]]
			when 7; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:PECK],[10,:WHIRLWIND],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:AERIALACE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:BRAVEBIRD]]
			when 8; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:VINEWHIP],[10,:LEECHSEED],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:SEEDBOMB],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:PETALBLIZZARD]]
			when 9; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:ROCKTHROW],[10,:STEALTHROCK],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:ROCKSLIDE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:STONEEDGE]]
			when 10; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:HORNATTACK],[10,:SCARYFACE],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:FACADE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:HEADCHARGE]]
			when 11; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:POISONSTING],[10,:TOXIC],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:VENOSHOCK],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:SLUDGEBOMB]]
			when 12; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:EMBER],[10,:AMNESIA],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:BULLDOZE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:EARTHPOWER]]
			when 13; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:BIND],[10,:IRONDEFENSE],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:IRONHEAD],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:IRONTAIL]]
			when 14; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:WATERGUN],[10,:WATERSPORT],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:WATERPULSE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:HYDROPUMP]]
			when 15; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:ROUND],[10,:HYPNOSIS],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:UPROAR],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:SYNCHRONOISE]]
			when 16; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:CONFUSION],[10,:KINESIS],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:PSYCHOCUT],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:PSYCHIC]]
			when 17; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:TWISTER],[10,:DRAGONDANCE],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:DRAGONPULSE],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:DRAGONRUSH]]
			when 18; movelist=[[1,:INFESTATION],[1,:SANDATTACK],[5,:RAGE],[10,:CHARM],[15,:STRUGGLEBUG],[20,:ENDEAVOR],[25,:HEADBUTT],[30,:STICKYWEB],[35,:DIG],[40,:MIMIC],[45,:FELLSTINGER],[50,:PLAYROUGH]]
			end
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})
#===============================================================================
# TOKAKLE
#===============================================================================
MultipleForms.register(:TOKAKLE,{
		"getFormOnCreation"=>proc{|pokemon|
			if $game_map && $game_map.map_id == 219
				next rand(5)
			else
				next
			end
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		}
	})

#===============================================================================
# CHIMAOOZE
#===============================================================================
MultipleForms.register(:CHIMAOOZE,{
		"getFormOnCreation"=>proc{|pokemon|
			next 0
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		},
		"getBaseStats"=>proc{|pokemon|
			next [45,130,140,30,135,140] if pokemon.form==1
			next
		}
	})
#===============================================================================
# PIKACHU
#===============================================================================
MultipleForms.register(:PIKACHUX,{
		"getFormOnCreation"=>proc{|pokemon|
			next 0
		},
		"onSetForm"=>proc{|pokemon,form|
			pbSeenForm(pokemon)
		},
		"type1"=>proc{|pokemon|
			next getID(PBTypes,:FAIRY) if pokemon.gender == 1 #female
			next 
		},
		"type2"=>proc{|pokemon|
			next getID(PBTypes,:FAIRY) if pokemon.gender==1
			next
		},
		"getMoveList"=>proc{|pokemon|
			next if pokemon.gender==0 # skips if it's male
			movelist=[[1,:QUICKATTACK],[1,:TAILWHIP],[1,:NASTYPLOT],[1,:SWEETKISS],[1,:ENERGYBALL],
				[1,:POWERGEM],[1,:FLAMETHROWER],[1,:THUNDERBOLT],[1,:DISARMINGVOICE],[1,:ICEBEAM],
				[1,:CHARM],[1,:BABYDOLLEYES],[1,:PLAYNICE],[1,:DRAININGKISS],[4,:TICKLE],[8,:DOUBLETEAM],
				[12,:ASSURANCE],[16,:FEINT],[20,:SWIFT],[24,:AGILITY],
				[28,:SLAM],[30,:FAKEOUT],[32,:DAZZLINGGLEAM],[36,:MOONBLAST],[40,:LIGHTSCREEN],[44,:PLAYROUGH]]
			for i in movelist
				i[1]=getConst(PBMoves,i[1])
			end
			next movelist
		},
		"getMoveCompatibility"=>proc{|pokemon|
			next if pokemon.gender==0 
			movelist=[# TMs
					  :TOXIC,:HIDDENPOWER,:LIGHTSCREEN,:PROTECT,:RETURN,
					  :DIG,:BRICKBREAK,:DOUBLETEAM,:REFLECT,:FACADE,
					  :REST,:BENEVOLENCE,:MAGICWALL,:FLING,:GRASSKNOT,
					  :SWAGGER,:SUBSTITUTE,:AFTERYOU,:COVET,:HELPINGHAND,
					  :IRONTAIL,:KNOCKOFF,:DAZZLINGGLEAM]
			for i in 0...movelist.length
			  movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
			end
			next movelist
		 },
		#"getBaseStats"=>proc{|pokemon|
		#   next [86,68,72,106,109,66] if pokemon.gender==1
		#   next
		#}
	})
#===============================================================================
# TOXTRICITY
#===============================================================================
MultipleForms.register(:TOXTRICITY,{
	"getFormOnCreation"=>proc{|pokemon|
		#Schiva, Sicura, Placida, Timida, Seria, Modesta, Mite, Quieta, Ritrosa, Calma, Gentile o Cauta = BASSO
		echoln "TOXTRICITY NATURE IS #{pokemon.nature}"
		next 1 if [PBNatures::LONELY, PBNatures::BOLD, PBNatures::RELAXED, PBNatures::TIMID, PBNatures::SERIOUS, PBNatures::MODEST, PBNatures::MILD, PBNatures::QUIET,
				   PBNatures::BASHFUL, PBNatures::CALM, PBNatures::GENTLE, PBNatures::CAREFUL].include?(pokemon.nature)
		next 0
	},
	"getFormOnEvolution"=>proc{|pokemon,item|
		#Schiva, Sicura, Placida, Timida, Seria, Modesta, Mite, Quieta, Ritrosa, Calma, Gentile o Cauta = BASSO
		echoln "TOXTRICITY NATURE IS #{pokemon.nature}"
		next 1 if [PBNatures::LONELY, PBNatures::BOLD, PBNatures::RELAXED, PBNatures::TIMID, PBNatures::SERIOUS, PBNatures::MODEST, PBNatures::MILD, PBNatures::QUIET,
				   PBNatures::BASHFUL, PBNatures::CALM, PBNatures::GENTLE, PBNatures::CAREFUL].include?(pokemon.nature)
		next 0
	},
	"getForm"=>proc{|pokemon|
		#Schiva, Sicura, Placida, Timida, Seria, Modesta, Mite, Quieta, Ritrosa, Calma, Gentile o Cauta = BASSO
		echoln "TOXTRICITY NATURE IS #{pokemon.nature}"
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:MINUS) if pokemon.form==1 && pokemon.abilityIndex==1 #BASS form
		next 
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 # skips if it's melody
		movelist = [[1,:SPARK],[1,:EERIEIMPULSE],[1,:BELCH],[1,:TEARFULLOOK],[1,:NUZZLE],[1,:GROWL],[1,:FLAIL],[1,:ACID],[1,:THUNDERSHOCK],[1,:ACIDSPRAY],
		[1,:LEER],[1,:ACIDSPRAY],[4,:CHARGE],[8,:ACIDSPRAY],[12,:ACIDSPRAY],[16,:TAUNT],[20,:VENOSHOCK],[24,:SCREECH],[28,:SWAGGER],[32,:TOXIC],
		[36,:DISCHARGE],[40,:POISONJAB],[44,:OVERDRIVE],[48,:BOOMBURST],[52,:CONTROLLOPOLARE]]		
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	}
	#"getBaseStats"=>proc{|pokemon|
	#   next [86,68,72,106,109,66] if pokemon.gender==1
	#   next
	#}
})
#===============================================================================
# PIKACHU
#===============================================================================
MultipleForms.register(:PIKACHU,{
	"getAltitude"=>proc{|pokemon|
		next 24 if pokemon.form == 1
		next
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FLYING) if pokemon.form==1
		next getID(PBTypes,:WATER) if pokemon.form==2
		next 
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 # skips if it's melody
		movelist = [[1,:QUICKATTACK],[1,:TAILWHIP],[1,:NASTYPLOT],[1,:SWEETKISS],[1,:NUZZLE],
		[1,:CHARM],[1,:GROWL],[1,:PLAYNICE],[1,:THUNDERSHOCK],[1,:THUNDERWAVE],[8,:DOUBLETEAM],
		[12,:ELECTROBALL],[16,:FEINT],[20,:SPARK],[24,:AGILITY],[28,:SLAM],[32,:DISCHARGE],
		[36,:THUNDERBOLT],[38,:FLY],[40,:LIGHTSCREEN],[44,:THUNDER]]		if pokemon.form == 1
		movelist = [[1,:QUICKATTACK],[1,:TAILWHIP],[1,:NASTYPLOT],[1,:SWEETKISS],[1,:NUZZLE],
		[1,:CHARM],[1,:GROWL],[1,:PLAYNICE],[1,:THUNDERSHOCK],[1,:THUNDERWAVE],[8,:DOUBLETEAM],
		[12,:ELECTROBALL],[16,:FEINT],[20,:SPARK],[24,:AGILITY],[28,:SLAM],[32,:DISCHARGE],
		[36,:THUNDERBOLT],[38,:SURF],[40,:LIGHTSCREEN],[44,:THUNDER]]		if pokemon.form == 2
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

#===============================================================================
# GOD BIDOOF
#===============================================================================
MultipleForms.register(:BIDOOF,{
	"type1"=>proc{|pokemon|
		next if pokemon.form == 0
		case pokemon.form
			when 2; next getID(PBTypes,:FIGHTING)
			when 3; next getID(PBTypes,:FLYING)		
			when 4; next getID(PBTypes,:POISON)
			when 5; next getID(PBTypes,:GROUND)
			when 6; next getID(PBTypes,:ROCK)
			when 7; next getID(PBTypes,:BUG)
			when 8; next getID(PBTypes,:GHOST)
			when 9; next getID(PBTypes,:STEEL)
			when 10; next getID(PBTypes,:FIRE)
			when 11; next getID(PBTypes,:WATER)
			when 12; next getID(PBTypes,:GRASS)
			when 13; next getID(PBTypes,:ELECTRIC)
			when 14; next getID(PBTypes,:PSYCHIC)
			when 15; next getID(PBTypes,:ICE)
			when 16; next getID(PBTypes,:DRAGON)
			when 17; next getID(PBTypes,:DARK)
			when 18; next getID(PBTypes,:FAIRY)
			when 19; next getID(PBTypes,:SUONO)
		end
	},
	"type2"=>proc{|pokemon|
		next if pokemon.form == 0
		case pokemon.form
			when 2; next getID(PBTypes,:FIGHTING)
			when 3; next getID(PBTypes,:FLYING)		
			when 4; next getID(PBTypes,:POISON)
			when 5; next getID(PBTypes,:GROUND)
			when 6; next getID(PBTypes,:ROCK)
			when 7; next getID(PBTypes,:BUG)
			when 8; next getID(PBTypes,:GHOST)
			when 9; next getID(PBTypes,:STEEL)
			when 10; next getID(PBTypes,:FIRE)
			when 11; next getID(PBTypes,:WATER)
			when 12; next getID(PBTypes,:GRASS)
			when 13; next getID(PBTypes,:ELECTRIC)
			when 14; next getID(PBTypes,:PSYCHIC)
			when 15; next getID(PBTypes,:ICE)
			when 16; next getID(PBTypes,:DRAGON)
			when 17; next getID(PBTypes,:DARK)
			when 18; next getID(PBTypes,:FAIRY)
			when 19; next getID(PBTypes,:SUONO)
		end
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:MULTITYPE) if pokemon.form>=1 #God form
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		#next getID(PBAbilities,:MULTITYPE)
		
		next 
	},
	"getForm"=>proc{|pokemon|
		echoln "FORM NO CALL #{pokemon.formNoCall}"
		next 0  if pokemon.formNoCall == 0
		next 2  if isConst?(pokemon.item,PBItems,:FISTPLATE)
		next 3  if isConst?(pokemon.item,PBItems,:SKYPLATE)
		next 4  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
		next 5  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
		next 6  if isConst?(pokemon.item,PBItems,:STONEPLATE)
		next 7  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
		next 8  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
		next 9  if isConst?(pokemon.item,PBItems,:IRONPLATE)
		next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
		next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
		next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
		next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
		next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE)
		next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
		next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
		next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE)
		next 18 if isConst?(pokemon.item,PBItems,:PIXIEPLATE)
		next 19 if isConst?(pokemon.item,PBItems,:SOUNDPLATE) #SOUND
		next 1  if pokemon.formNoCall != nil && pokemon.formNoCall >= 1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# MEGA SHIFTRY
MultipleForms.register(:SHIFTRY,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:SHIFTRYITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getAltitude"=>proc{|pokemon|
		next 24 if pokemon.form == 1
		next
	},
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FLYING) if pokemon.form==1
		next 
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Shiftry") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [120,100,80,40,160,80] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:GALEWINGS) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# MEGA BELLOSSOM
MultipleForms.register(:BELLOSSOM,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:BELLOSSOMITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},	
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Bellossom") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [155,80,85,50,110,100] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:FLASHFIRE) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# MEGA ABSOL
MultipleForms.register(:ABSOL,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:ABSOLITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Absol") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [65,150,60,115,115,60] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# MEGA MAWILE
MultipleForms.register(:MAWILE,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:MAWILITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Mawile") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [50,105,125,50,55,95] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:HUGEPOWER) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# MEGA LINOONE
MultipleForms.register(:LINOONE,{
	"getMegaForm"=>proc{|pokemon|
		next 2 if isConst?(pokemon.item,PBItems,:LINOONITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Linoone") if pokemon.form==2
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [50,195,125,50,55,105] if pokemon.form==2
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:HUGEPOWER) if pokemon.form==2
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

#LUXRAY
MultipleForms.register(:LUXRAY,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:LUXRAYITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Luxray") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [80,175,85,123,75,85] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:LEVITATE) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

#MIENSHAO
MultipleForms.register(:MIENSHAO,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:MIENSHAOITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Mienshao") if pokemon.form==1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [65,155,90,115,95,90] if pokemon.form==1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities,:WATERSTREAM) if pokemon.form==1
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})


#MIENSHAO
MultipleForms.register(:DONANAS,{
	"getRareness"=>proc{|pokemon|
		next 6 if pokemon.form == 6
		next
	},
	"onSetForm"=>proc{|pokemon,form|
		pbSeenForm(pokemon)
	}
})

# CHIKORITA
MultipleForms.register(:CHIKORITA,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[18,:PROTECT],
		#[21,:RAINDANCE],[24,:AQUATAIL],[27,:SHELLSMASH],
		#[30,:IRONDEFENSE],[33,:HYDROPUMP],[36,:SKULLBASH]]	if pokemon.form == 1

		movelist = [[1,:LEER],[1,:SCRATCH],[6,:WATERGUN],[8,:RAGE],[13,:BITE],[15,:SCARYFACE],
		[20,:ICEFANG],[22,:FLAIL],[27,:CRUNCH],[29,:CHIPAWAY],[34,:SLASH],
		[36,:SCREECH],[41,:THRASH],[43,:AQUATAIL],[48,:SUPERPOWER],[50,:HYDROPUMP]] if pokemon.form == 1

		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# BAYLEEF
MultipleForms.register(:BAYLEEF,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:LEER],[1,:SCRATCH],[1,:WATERGUN],[6,:WATERGUN],
		[8,:RAGE],[13,:BITE],[15,:SCARYFACE],[21,:ICEFANG],
		[24,:FLAIL],[30,:CRUNCH],[33,:CHIPAWAY],[39,:SLASH],
		[42,:SCREECH],[48,:THRASH],[51,:AQUATAIL],[57,:SUPERPOWER],[60,:HYDROPUMP]] if pokemon.form == 1
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# MEGANIUM
MultipleForms.register(:MEGANIUM,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:WATER) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:LEER],[1,:SCRATCH],[1,:WATERGUN],[6,:WATERGUN],
		[8,:RAGE],[13,:BITE],[15,:SCARYFACE],[21,:ICEFANG],
		[24,:FLAIL],[30,:CRUNCH],[33,:CHIPAWAY],[39,:SLASH],
		[42,:SCREECH],[48,:THRASH],[51,:AQUATAIL],[57,:SUPERPOWER],[60,:HYDROPUMP]] if pokemon.form == 1
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# CYNDAQUIL
MultipleForms.register(:CYNDAQUIL,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[18,:PROTECT],
		#[21,:RAINDANCE],[24,:AQUATAIL],[27,:SHELLSMASH],
		#[30,:IRONDEFENSE],[33,:HYDROPUMP],[36,:SKULLBASH]]	if pokemon.form == 1

		movelist = [[1,:TACKLE],[1,:GROWL],[6,:RAZORLEAF],[9,:POISONPOWDER],[12,:SYNTHESIS],
		[17,:REFLECT],[20,:MAGICALLEAF],[23,:NATURALGIFT],[28,:SWEETSCENT],
		[31,:LIGHTSCREEN],[34,:BODYSLAM],[39,:SAFEGUARD],
		[42,:AROMATHERAPY],[45,:SOLARBEAM]] if pokemon.form == 1

		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# QUILAVA
MultipleForms.register(:QUILAVA,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:TACKLE],[1,:GROWL],[1,:RAZORLEAF],[1,:POISONPOWDER],
		[6,:RAZORLEAF],[9,:POISONPOWDER],[12,:SYNTHESIS],[18,:REFLECT],
		[22,:MAGICALLEAF],[26,:NATURALGIFT],[32,:SWEETSCENT],[36,:LIGHTSCREEN],
		[40,:BODYSLAM],[46,:SAFEGUARD],[50,:AROMATHERAPY],[54,:SOLARBEAM]] if pokemon.form == 1
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# TYPHLOSION
MultipleForms.register(:TYPHLOSION,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GRASS) if pokemon.form==1
		next getID(PBTypes,:GHOST) if pokemon.form==2
		next			
	},
	"getAbilityList"=>proc{|pokemon|
		if pokemon.form==2
		  next [[getID(PBAbilities,:BLAZE),0],
				[getID(PBAbilities,:BLAZE),1],
				[getID(PBAbilities,:FRISK),2]]
		end
		next
	  },
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:PETALBLIZZARD],[1,:PETALDANCE],[1,:TACKLE],[1,:GROWL],
		[1,:RAZORLEAF],[1,:POISONPOWDER],[6,:RAZORLEAF],[9,:POISONPOWDER],
		[12,:SYNTHESIS],[18,:REFLECT],[22,:MAGICALLEAF],[26,:NATURALGIFT],
		[32,:PETALDANCE],[34,:SWEETSCENT],[40,:LIGHTSCREEN],[46,:BODYSLAM],
		[54,:SAFEGUARD],[60,:AROMATHERAPY],[66,:SOLARBEAM],[70,:PETALBLIZZARD]] if pokemon.form == 1

		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist if pokemon.form == 1

		movelist = [[1,:TACKLE],[1,:EMBER],[1,:ERUPTION],[1,:LEER],
		[1,:SMOKESCREEN],[1,:DOUBLEEDGE],[1,:GYROBALL],[1,:SHADOWBALL],
		[13,:QUICKATTACK],[20,:FLAMEWHEEL],[24,:DEFENSECURL],[31,:SWIFT],
		[35,:FLAMECHARGE],[43,:LAVAPLUME],[48,:FLAMETHROWER],[56,:INFERNO],
		[61,:ROLLOUT],[74,:OVERHEAT]] if pokemon.form == 2

		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist if pokemon.form == 2
		next
	},
	"getMoveCompatibility"=>proc{|pokemon|
		next if pokemon.form != 2
		movelist=[# TMs
				  :TAKEDOWN,:FIREFANG,:HIDDENPOWER,:SUNNYDAY,:LOWKICK,:PROTECT,
				  :CONFUSERAY,:FIRESPIN,:FACADE,:AERIALACE,:BULLDOZE,
				  :SHADOWBALL,:HEX,:SWIFT,:FLAMECHARGE,:NIGHTSHADE,
				  :ENDURE,:SUNNYDAY,:DIG,:BRICKBREAK,:ZENHEADBUTT,:SHADOWCLAW,
				  :BODYSLAM,:FIREPUNCH,:THUNDERPUNCH,:SLEEPTALK,:STOMPINGTANTRUM,
				  :REST,:ROCKSLIDE,:IRONHEAD,:SUBSTITUTE,:WILLOWISP,
				  :SHADOWBALL,:HEATWAVE,:FLAMETHROWER,:PLAYROUGH,:CALMMIND,
				  :REVERSAL,:FIREBLAST,:FIREPLEDGE,:WILDCHARGE,:EARTHQUAKE,
				  :GIGAIMPACT,:BLASTBURN,:OVERHEAT,:FOCUSBLAST,:HYPERBEAM,
				  :FLAREBLITZ,:SOLARBEAM]
		for i in 0...movelist.length
		  movelist[i]=getConst(PBMoves,movelist[i]) if getConst(PBMoves,movelist[i])!=nil
		end
		next movelist
	 },	 
	"getFormOnEvolution"=>proc{|pokemon,item|
		next 2 if pokemon.form==0 && item == PBItems::ANCIENTSTONE
		next			
	},
})

# TOTODILE
MultipleForms.register(:TOTODILE,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[18,:PROTECT],
		#[21,:RAINDANCE],[24,:AQUATAIL],[27,:SHELLSMASH],
		#[30,:IRONDEFENSE],[33,:HYDROPUMP],[36,:SKULLBASH]]	if pokemon.form == 1

		movelist = [[1,:TACKLE],[1,:LEER],[6,:SMOKESCREEN],[10,:EMBER],
		[13,:QUICKATTACK],[19,:FLAMEWHEEL],[22,:DEFENSECURL],[28,:FLAMECHARGE],
		[31,:SWIFT],[37,:LAVAPLUME],[40,:FLAMETHROWER],[46,:INFERNO],[49,:ROLLOUT],
		[55,:DOUBLEEDGE],[58,:BURNUP],[64,:ERUPTION]] if pokemon.form == 1

		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# CROCONAW
MultipleForms.register(:CROCONAW,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:TACKLE],[1,:LEER],[1,:SMOKESCREEN],[6,:SMOKESCREEN],
		[10,:EMBER],[13,:QUICKATTACK],[20,:FLAMEWHEEL],[24,:DEFENSECURL],
		[31,:FLAMECHARGE],[35,:SWIFT],[42,:LAVAPLUME],[46,:FLAMETHROWER],
		[53,:INFERNO],[57,:ROLLOUT],[64,:DOUBLEEDGE],[68,:BURNUP],[75,:ERUPTION]] if pokemon.form == 1
		
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

# FERALIGATR
MultipleForms.register(:FERALIGATR,{
	"type1"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FIRE) if pokemon.form==1
		next			
	},
	"getMoveList"=>proc{|pokemon|
		next if pokemon.form==0 
		#movelist = [[1,:TACKLE],[1,:TAILWHIP],[1,:WATERGUN],[1,:WITHDRAW],
		#[9,:RAPIDSPIN],[12,:BITE],[15,:WATERPULSE],[20,:PROTECT],
		#[25,:RAINDANCE],[30,:AQUATAIL],[35,:SHELLSMASH],[40,:IRONDEFENSE],
		#[45,:HYDROPUMP],[50,:SKULLBASH]] if pokemon.form == 1

		movelist = [[1,:ERUPTION],[1,:DOUBLEEDGE],[1,:EMBER],[1,:GYROBALL],
		[1,:TACKLE],[1,:LEER],[1,:SMOKESCREEN],[6,:SMOKESCREEN],[10,:EMBER],
		[13,:QUICKATTACK],[20,:FLAMEWHEEL],[24,:DEFENSECURL],[31,:FLAMECHARGE],
		[35,:SWIFT],[43,:LAVAPLUME],[48,:FLAMETHROWER],[56,:INFERNO],[61,:ROLLOUT],
		[69,:DOUBLEEDGE],[74,:BURNUP],[82,:ERUPTION]] if pokemon.form == 1
		
		for i in movelist
			i[1]=getConst(PBMoves,i[1])
		end
		next movelist
	},
})

MultipleForms.register(:ALTARIA,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:ALTARIANITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 1
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FAIRY) if pokemon.form == 1
		next			
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Altaria") if pokemon.form == 1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [75, 110, 110, 80, 110, 105] if pokemon.form == 1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities, :PIXILATE) if pokemon.form == 1
		next
	},
	"height"=>proc{|pokemon|
		next 1.5 if pokemon.form == 1
		next
	},
	"weight"=>proc{|pokemon|
		next 20.6 if pokemon.form == 1
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

MultipleForms.register(:MEWTWO,{
	"getMegaForm"=>proc{|pokemon|
		next 2 if isConst?(pokemon.item,PBItems,:MEWTWONITEX) && (pokemon.form == 0 || pokemon.form == 2)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 2
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:FIGHTING) if pokemon.form == 2
		next			
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("MegaMewtwo X") if pokemon.form == 2
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [106, 190, 100, 130, 154, 100] if pokemon.form == 2
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities, :STEADFAST) if pokemon.form == 2
		next
	},
	"height"=>proc{|pokemon|
		next 2.3 if pokemon.form == 2
		next
	},
	"weight"=>proc{|pokemon|
		next 127.0 if pokemon.form == 2
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

MultipleForms.register(:RAMPARDOS,{
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:RAMPARDITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 1
	},
	"type2"=>proc{|pokemon|
		next getID(PBTypes,:GROUND) if pokemon.form == 1
		next			
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Rampardos") if pokemon.form == 1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [118, 205, 100, 48, 55, 70] if pokemon.form == 1 #fix
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities, :SOLIDROCK) if pokemon.form == 1 #fix
		next
	},
	"height"=>proc{|pokemon|
		next 2.1 if pokemon.form == 1 #fix
		next
	},
	"weight"=>proc{|pokemon|
		next 240.6 if pokemon.form == 1 #fix
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

# GARDEVOIR
MultipleForms.register(:GARDEVOIR, {
	"getMegaForm"=>proc{|pokemon|
		next 1 if isConst?(pokemon.item,PBItems,:GARDEVOIRITE)
		next
	},
	"getUnmegaForm"=>proc{|pokemon|
		next 0 if pokemon.form == 1
	},
	"getMegaName"=>proc{|pokemon|
		next _INTL("Mega Gardevoir") if pokemon.form == 1
		next
	},
	"getBaseStats"=>proc{|pokemon|
		next [68, 85, 65, 100, 165, 135] if pokemon.form == 1
		next
	},
	"ability"=>proc{|pokemon|
		next getID(PBAbilities, :PIXILATE) if pokemon.form == 1
		next
	},
	"height"=>proc{|pokemon|
		next 1.6 if pokemon.form == 1
		next
	},
	"weight"=>proc{|pokemon|
		next 48.4 if pokemon.form == 1
		next
	},
	"onSetForm"=>proc{|pokemon, form|
		pbSeenForm(pokemon)
	}
})

def pbExtractFormsData
	code = File.open("formExtractor.rb", "r") { |file| file.read }
    begin
      eval(code, nil, "formExtractor.rb")
    rescue ScriptError
      echoln "AN ERROR OCCURRED! #{$!.message}"
		#raise ScriptError.new($!.message)
    rescue
      $!.message.sub!($!.message, traceback_report)
      raise_traceback_error
    end
end
