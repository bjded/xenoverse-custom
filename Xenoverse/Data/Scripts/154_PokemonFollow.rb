#===============================================================================
# * Credit to Help-14 for both the original scripts and sprites
# * Change Log:
#===============================================================================

#===============================================================================
# * Edited by zingzags
#===============================================================================
# * Fixed bugs
# * Clean ups
# * Fixed Surf Bug (After Surf is done)
# * Fixed def talk_to_pokemon while in surf
# * Fixed Surf Check
# * Fixed Type Check
# * Added Door Support
# * Fixed Hp Bug
# * Added Pokemon Center Support
# * Animation problems
# * Fixed Walk_time_variable problem
# * Added random item loot
# * Added egg check
#===============================================================================

#===============================================================================
# * Edited by Rayd12smitty
# * Version 1.0
#===============================================================================
# * Fixed Walk_Time_Variable
# * Fixed crash when talking to Pokemon on a different map than the original
#   they appeared on
# * Receiving Items from Pokemon now works
# * Improved Talk_to_Pokemon wiht more messages and special messages
# * Added messages for all Status Conditions
# * Added Party Rotation to switch follower
# * Made Following Pokemon Toggleable
# * Added Animation for Pokemon coming out of Pokeball in sprite_refresh
# * Tidied up script layout and made more user friendly
# * Fixed Issues with Pokemon jumping around on ledges
# * Fixed Badge for Surf Typo in the script
#===============================================================================
# * Version 1.1
#===============================================================================
# * Fixed Surfing so Pokemon doesn't reappear on water when toggled off
# * Changed Layout and location of Toggle Script
#===============================================================================

#===============================================================================
# * Edited by Rayd12smitty and venom12
# * Version 1.2
#===============================================================================
# * Fixed Walk step count so it doesn't add on when Pokemon is toggled off
# * No longer have to manually set Toggle_Following_Switch and
#   Following_Activated_Switch whenever "pbPokemonFollow(x)" is called
# * Now supports Pokemon with multiple forms
# * Items found on specific maps support
# * Support for messages when on a map including a word/phrase in its name
#   rather than a single map
# * Added stepping animation for follower
# * Fixed dismount bike so Pokemon reappears
# * Fixed bike so if it couldn't be used it now can
# * Few other small bike fixes
#===============================================================================

#===============================================================================
# * Version 1.3
#===============================================================================
# * Fixed bug with surf where the Follower could block the player from being
#   able to surf, possibly stranding the player
# * Added script to animate all events named "Poke"
# * Increased time to find an item. I realize now that 5000 frames is less than
#   5 min. Way too short.
#===============================================================================

#===============================================================================
# * To Do
#===============================================================================
# * When Follower is toggled off remove grass/field animations
# * Fix up map transfers a bit more
# * Make NPCs not able to walk over the Follower
#===============================================================================



#===============================================================================
# * Control the following Pokemon
# * Example:
#     FollowingMoveRoute([
#         PBMoveRoute::TurnRight,
#         PBMoveRoute::Wait,4,
#         PBMoveRoute::Jump,0,0
#     ])
# * The Pokemon turns Right, waits 4 frames, and then jumps
# * Call pbPokeStep to animate all events on the map named "Poke"
#===============================================================================
def FollowingMoveRoute(commands,waitComplete=false)
	$PokemonTemp.dependentEvents.SetMoveRoute(commands,waitComplete)
end
def pbPokeStep
	for event in $game_map.events.values
		if event.name=="Poke"               
			pbMoveRoute(event,[PBMoveRoute::StepAnimeOn])
		end
	end
end

#############################àà
def pbShowCommands(message,commands,index=0)
	ret=0
	msgwindow=Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
	msgwindow.viewport=@viewport
	msgwindow.visible=true
	msgwindow.letterbyletter=false
	msgwindow.resizeHeightToFit(message,Graphics.width-180)
	msgwindow.text=message
	pbBottomRight(msgwindow)
	cmdwindow=Window_CommandPokemon.new(commands)
	cmdwindow.viewport=@viewport
	cmdwindow.visible=true
	cmdwindow.resizeToFit(cmdwindow.commands)
	cmdwindow.height=Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
	cmdwindow.update
	cmdwindow.index=index
	pbBottomRight(cmdwindow)
	cmdwindow.y-=msgwindow.height
	loop do
		Graphics.update
		Input.update
		if Input.trigger?(Input::B)
			ret=-1
			break
		end
		if Input.trigger?(Input::C)
			ret=cmdwindow.index
			break
		end
		pbUpdateSpriteHash(@sprites)
		msgwindow.update
		cmdwindow.update
	end
	msgwindow.dispose
	cmdwindow.dispose
	Input.update
	return ret
end
#===============================================================================
# * Toggle for Following Pokemon
#===============================================================================
def pbToggleFollowingPokemon
	if $game_switches[Following_Activated_Switch]==true
		if $game_switches[Toggle_Following_Switch]==true
			$PokemonTemp.dependentEvents.remove_sprite(true)
			#$PokemonTemp.pbRemoveDependencies
			$PokemonTemp.pbSwap
			pbWait(1)
			$game_switches[Toggle_Following_Switch]=false
		else
			$FollowingFinishedSurfing = false
			$PokemonTemp.pbSwap
			$PokemonTemp.dependentEvents.refresh_sprite(true)
			pbWait(1)
			$game_switches[Toggle_Following_Switch]=true
		end
	end
end



class DependentEvents
	#===============================================================================
	# Raises The Current Pokemon's Happiness level +1 per each time the 
	# Walk_time_Variable reachs 5000 then resets to 0
	# ItemWalk, is when the variable reaches a certain amount, that you are able 
	# to talk to your pokemon to recieve an item
	#===============================================================================
	def add_following_time
		$PokemonTemp.dependentEvents.update_stepping
		if $game_switches[Toggle_Following_Switch]==true && $Trainer.party.length>=1
			$game_variables[Walking_Time_Variable]+=1 if $game_variables[Current_Following_Variable]!=$Trainer.party.length
			$game_variables[Walking_Item_Variable]+=1 if $game_variables[Current_Following_Variable]!=$Trainer.party.length
			if $game_variables[Walking_Time_Variable]==5000
				$Trainer.party[0].happiness+=1
				$game_variables[Walking_Time_Variable]=0
			end
			if $game_variables[Walking_Item_Variable]==1000
				if $game_variables[ItemWalk]==15
				else
					$game_variables[ItemWalk]+=1
				end
				$game_variables[Walking_Item_Variable]=0
			end
		end
	end
	
	#===============================================================================
	# * refresh_sprite
	# * Updates the sprite sprite with an animation
	#===============================================================================
	def refresh_sprite(animation, menu=nil)
		#pokemon = nil
		if $PokemonGlobal.surfing==false
			for i in 0...$Trainer.party.length
				if $Trainer.party[i].species == PBSpecies::SHYLEON || $Trainer.party[i].species == PBSpecies::TRISHOUT || $Trainer.party[i].species == PBSpecies::SHULONG
					pokemon = $Trainer.party[i]
					break
				else 
					pokemon = nil
					remove_sprite
					break
				end
			end
			if $Trainer.party.length != $game_variables[Current_Following_Variable]
				if pokemon != nil
					shiny = pokemon.isShiny?
					form = pokemon.form != 0 ? pokemon.form : nil
					change_sprite(pokemon.species, shiny, animation, form)
					if pokemon.hp<=0
						remove_sprite
					end
					#else
					#remove_sprite
				end
			end
		else
			remove_sprite
		end
	end
	#===============================================================================
	# * change_sprite(id, shiny, animation)
	# * Example, to change sprite to shiny lugia with animation:
	#     change_sprite(249, true, true)
	# * If just change sprite:
	#     change_sprite(249)
	#===============================================================================
	def change_sprite(id, shiny=nil, animation=nil, form=nil)
		events=$PokemonGlobal.dependentEvents
		for i in 0...events.length
			if events[i][8] != "Dependent" && pbGetTerrainTag != PBTerrain::Ice
				events[i][8]="Dependent"
			end
			if events[i] && events[i][8]=="Dependent"
				if shiny==true
					events[i][6]=sprintf("%03ds",id)
					if FileTest.image_exist?("Graphics/Characters/"+events[i][6])
						@realEvents[i].character_name=sprintf("%03ds",id)
					else
						events[i][6]=sprintf("%03d",id)
						@realEvents[i].character_name=sprintf("%03d",id)
					end
				else
					for j in 0...$Trainer.party.length
						if $Trainer.party[j].species == PBSpecies::SHYLEON || $Trainer.party[j].species == PBSpecies::TRISHOUT || $Trainer.party[j].species == PBSpecies::SHULONG || $Trainer.party[j].species == PBSpecies::ELEKIDX
							if $Trainer.party[j].form != 0
								events[i][6]=sprintf("%03d",id)
								@realEvents[i].character_name=sprintf("%03d_%d",id,$Trainer.party[j].form)
							else
								events[i][6]=sprintf("%03d",id)
								@realEvents[i].character_name=sprintf("%03d",id)
							end
						end
					end
				end
				if animation==true
					$scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
				end
				$game_variables[Walking_Time_Variable]=0
			end
		end
	end
	#===============================================================================
	# * update_stepping
	# * Adds step animation for followers
	#===============================================================================  
	def update_stepping
		FollowingMoveRoute([PBMoveRoute::StepAnimeOff])
		FollowingMoveRoute([PBMoveRoute::StepAnimeOn])
	end
	#===============================================================================
	# * remove_sprite(animation)
	# * Example, to remove sprite with animation:
	#     remove_sprite(true)
	# * If just remove sprite:
	#     remove_sprite
	#===============================================================================
	def remove_sprite(animation=nil)
		events=$PokemonGlobal.dependentEvents
		for i in 0...events.length
			if events[i] && events[i][8]=="Dependent"
				events[i][8]=sprintf("nil")
				#events[i][8]="Dependent"
				@realEvents[i].character_name=sprintf("nil")
				if animation==true
					#change_sprite(0)
					$scene.spriteset.addUserAnimation(Animation_Come_In,@realEvents[i].x,@realEvents[i].y)
					pbWait(10)
				end
				#for j in 0...$Trainer.party.length
				#  if $Trainer.party[j].species == PBSpecies::SHYLEON || $Trainer.party[j].species == PBSpecies::TRISHOUT || $Trainer.party[j].species == PBSpecies::SHULONG || $Trainer.party[j].species == PBSpecies::ELEKIDX
				#    $game_variables[Current_Following_Variable] = $Trainer.party[j]
				#    break
				#  end
				#end
				$game_variables[Current_Following_Variable]=$Trainer.party[0]
				$game_variables[Walking_Time_Variable]=0
			end
		end
	end
	#===============================================================================
	# * check_surf(animation)
	# * If current Pokemon is a water Pokemon, it is still following.
	# * If current Pokemon is not a water Pokemon, remove sprite.
	# * Require Water_Pokemon_Can_Surf = true to enable
	#===============================================================================
	def check_surf(animation=nil)
		events=$PokemonGlobal.dependentEvents
		for i in 0...events.length
			if events[i] && events[i][8]=="Dependent"
				events[i][6]=sprintf("nil")
				@realEvents[i].character_name=sprintf("nil")
			else
				if $Trainer.party[0].hp>0 && !$Trainer.party[0].egg?
					if $Trainer.party[0].hasType?(:WATER)
					else
						remove_sprite
						pbWait(20)
					end
				elsif $Trainer.party[0].hp<=0 
				end
			end
		end
	end
	#===============================================================================
	# * talk_to_pokemon
	# * It will run when you talk to Pokemon following
	#===============================================================================
	def talk_to_pokemon
		#e=$Trainer.party[0]
		#===============================================================================
		# * Il giocatore parla solo con lo starter,
		# * commentare il codice qui sotto e levare l'ashtag sopra per
		# * far parlare con il primo in squadra (normale)
		for i in 0...$Trainer.party.length
			if $Trainer.party[i].species == PBSpecies::SHYLEON || $Trainer.party[i].species == PBSpecies::TRISHOUT || $Trainer.party[i].species == PBSpecies::SHULONG || $Trainer.party[i].species == PBSpecies::ELEKIDX
				e = $Trainer.party[i]
				break
			end
		end
		#===============================================================================
		events=$PokemonGlobal.dependentEvents
		for i in 0...events.length
			if events[i] && events[i][8]=="Dependent"
				pos_x=@realEvents[i].x
				pos_y=@realEvents[i].y
			end
		end
		if e==0
		else
			if e.hp>0 && !$Trainer.party[0].egg?
				if $PokemonGlobal.surfing==true || $PokemonGlobal.bicycle==true
					$PokemonTemp.dependentEvents.remove_sprite
				else
					#===============================================================================
					# * Checks to make sure the Pokemon isn't blocking a surfable water surface
					# * If the water is blocked by the sprite (even though it is invisible) and
					#   the player should be able to surf, calls surf
					#===============================================================================
					terrain=Kernel.pbFacingTerrainTag
					notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
					if pbIsSurfableTag?(terrain) || !notCliff
						if !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && !$PokemonGlobal.surfing
							if $DEBUG
								$FollowingFinishedSurfing = false
								pbOdysseumN
							elsif (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
								$FollowingFinishedSurfing = false
								pbOdysseumN
							end
						end
						#===============================================================================
						# * talk_to_pokemon when possible begins here
						#===============================================================================
					elsif e!=6 && $game_switches[Toggle_Following_Switch]==true
						pbPlayCry(e.species)
						random1=6 # random message if no special conditions apply
						mapname=$game_map.name # Get's current map name
						#===============================================================================
						# * Pokemon Messages when Status Condition
						#===============================================================================          
						if e.status==PBStatuses::POISON && e.hp>0 && !e.egg? # Pokemon Poisoned
							$scene.spriteset.addUserAnimation(Emo_Poison, pos_x, pos_y-2)
							pbWait(120)
							Kernel.pbMessage(_INTL("{1} is shivering with the effects of being poisoned.",e.name))
							
						elsif e.status==PBStatuses::BURN && e.hp>0 && !e.egg? # Pokemon Burned
							$scene.spriteset.addUserAnimation(Emo_Hate, pos_x, pos_y-2)
							pbWait(70)
							Kernel.pbMessage(_INTL("{1}'s burn looks painful.",e.name))
							
						elsif e.status==PBStatuses::FROZEN && e.hp>0 && !e.egg? # Pokemon Frozen
							$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
							pbWait(100)
							Kernel.pbMessage(_INTL("{1} seems very cold. It's frozen solid!",e.name))
							
						elsif e.status==PBStatuses::SLEEP && e.hp>0 && !e.egg? # Pokemon Asleep
							$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
							pbWait(100)
							Kernel.pbMessage(_INTL("{1} seems really tired.",e.name))
							
						elsif e.status==PBStatuses::PARALYSIS && e.hp>0 && !e.egg? # Pokemon Paralyzed
							$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
							pbWait(100)
							Kernel.pbMessage(_INTL("{1} is standing still and twitching.",e.name))
							#===============================================================================
							# * Pokemon is holding an item on a Specific Map
							#===============================================================================           
						elsif $game_variables[ItemWalk]==15 and mapname=="Item Map" # Pokemon has item and is on map "Item Map"
							items=[:MASTERBALL,:MASTERBALL] # This array can be edited and extended. Look at the one below for a guide
							random2=0
							loop do
								random2=rand(items.length)
								break if hasConst?(PBItems,items[random2])
							end
							Kernel.pbMessage(_INTL("{1} seems to be holding something.",e.name))
							Kernel.pbPokemonFound(getConst(PBItems,items[random2]))
							$game_variables[ItemWalk]=0
							#===============================================================================
							# * Pokemon is holding an item on any other map
							#===============================================================================            
						elsif $game_variables[ItemWalk]==15 # Pokemon has Item
							items=[:POTION,:SUPERPOTION,:FULLRESTORE,:REVIVE,:PPUP,
								:PPMAX,:RARECANDY,:REPEL,:MAXREPEL,:ESCAPEROPE,
								:HONEY,:TINYMUSHROOM,:PEARL,:NUGGET,:GREATBALL,
								:ULTRABALL,:REDAPRICORN,:BLUAPRICORN,:YLWAPRICORN,:GRNAPRICORN,:PNKAPRICORN,
								:BLKAPRICORN,:WHTAPRICORN
							]
							random2=0
							loop do
								random2=rand(items.length)
								break if hasConst?(PBItems,items[random2])
							end
							
							Kernel.pbMessage(_INTL("{1} seems to be holding something.",e.name))
							Kernel.pbPokemonFound(getConst(PBItems,items[random2]))
							$game_variables[ItemWalk]=0
							#===============================================================================
							# * Examples of Map Specific Messages
							#===============================================================================
						elsif mapname=="Dusk Forest" && e.hasType?(:BUG) # Bug Type in Dusk Forest
							$scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
							pbWait(50)
							random3=rand(3)
							if random3==0
								Kernel.pbMessage(_INTL("{1} seems highly interested in the trees.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} seems to enjoy the buzzing of the bug Pokémon.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} is jumping around restlessly in the forest.",e.name,$Trainer.name))
							end
							
						elsif mapname=="Old Lab" # In the Old Lab
							$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
							pbWait(100)
							random3=rand(3)
							if random3==0
								Kernel.pbMessage(_INTL("{1} is touching some kind of switch.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} has a cord in its mouth!",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} seems to want to touch the machinery.",e.name,$Trainer.name))
							end  
							
						elsif mapname=="Home" # In the Player's Home
							$scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)
							pbWait(70)
							random3=rand(3)
							if random3==0
								Kernel.pbMessage(_INTL("{1} is sniffing around the room.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} noticed {2}'s mom is nearby.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} seems to want to settle down at home.",e.name,$Trainer.name))
							end
						elsif mapname.include?("Route") # On any map that includes "Route" in the name
							# Animation goes here
							# Appropriate wait time for animation goes here
							# random3=rand(x)
							# different random messages
							#===============================================================================
							# * Random Messages if none of the above apply
							#===============================================================================            
						elsif random1==0 # Music Note
							$scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
							pbWait(50)
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} seems to want to play with {2}.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} is singing and humming.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} is looking up at the sky.",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} swayed and danced around as it pleased.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} is pulling out the grass.",e.name,$Trainer.name))
							end
							
						elsif random1==1 # Hate/Angry Face
							$scene.spriteset.addUserAnimation(Emo_Hate, pos_x, pos_y-2)
							pbWait(70)
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} let out a roar!",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} is making a face like it's angry!",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} seems to be angry for some reason.",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} chewed on your feet.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} is trying to be intimidating.",e.name,$Trainer.name))
							end
							
						elsif random1==2 # ... Emoji
							$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
							pbWait(100)
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} is looking down steadily.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} is sniffing at the floor.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} is concentrating deeply.",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} faced this way and nodded.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} is glaring straight into {2}'s eyes.",e.name,$Trainer.name))
							end
							
						elsif random1==3 # Happy Face
							$scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)
							pbWait(70)
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} began poking you in the stomach.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} looks very happy.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} happily cuddled up to you.",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} is so happy that it can't stand still.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} looks like it wants to lead!",e.name,$Trainer.name))
							end
							
						elsif random1==4 # Heart Emoji
							$scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)
							pbWait(70)
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} suddenly started walking closer.",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("Woah! {1} suddenly hugged {2}.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} is rubbing up against you.",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} is keeping close to {2}.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} blushed.",e.name,$Trainer.name))
							end
							
						elsif random1==5 # No Emoji
							random3=rand(5)
							if random3==0
								Kernel.pbMessage(_INTL("{1} spun around in a circle!",e.name,$Trainer.name))
							elsif random3==1
								Kernel.pbMessage(_INTL("{1} let our a battle cry.",e.name,$Trainer.name))
							elsif random3==2
								Kernel.pbMessage(_INTL("{1} is on the lookout!",e.name,$Trainer.name))
							elsif random3==3
								Kernel.pbMessage(_INTL("{1} is standing patiently.",e.name,$Trainer.name))
							elsif random3==4
								Kernel.pbMessage(_INTL("{1} is looking around restlessly.",e.name,$Trainer.name))
							end
							
							
							
							
							#===============================================================================
							# * This random message shows the Pokemon's Happiness Level
							#===============================================================================             
							
							
							
						elsif random1==6 # Check Happiness Level
							if $Trainer.pokemonParty[0].species==PBSpecies::TRISHOUT
								
							elsif e.happiness>0 && e.happiness<=50
								$scene.spriteset.addUserAnimation(Emo_Hate, pos_x, pos_y-2)
								pbWait(70)
								Kernel.pbMessage(_INTL("{1} hates to travel with {2}.",e.name,$Trainer.name))
							elsif e.happiness>50 && e.happiness<=100
								$scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
								pbWait(100)
								Kernel.pbMessage(_INTL("{1} is still unsure about traveling with {2} is a good thing or not.",e.name,$Trainer.name))
							elsif e.happiness>100 && e.happiness<150
								$scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)
								Kernel.pbMessage(_INTL("{1} is happy traveling with {2}.",e.name,$Trainer.name))
							elsif e.happiness>=150
								$scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)
								pbWait(70)
								Kernel.pbMessage(_INTL("{1} loves traveling with {2}.",e.name,$Trainer.name))
								
							end
						end
					else
					end
				end
			end
		end
	end
	#===============================================================================
	# * Pokemon reapear after using surf
	#===============================================================================
	def Come_back(shiny=nil, animation=nil)
		events=$PokemonGlobal.dependentEvents
		if $game_variables[Current_Following_Variable]==$Trainer.party.length
			remove_sprite(false)
			for i in 0...events.length 
				$scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
			end
		else
			if $Trainer.party[0].isShiny?
				shiny=true
			else
				shiny=false
			end
			change_sprite($Trainer.party[0].species, shiny, false)
		end
		for i in 0..$Trainer.party.length-1
			if $Trainer.party[i].hp>0 && !$Trainer.party[0].egg?
				$game_variables[Current_Following_Variable]=i
				refresh_sprite(false)
				break
			end
		end
		for i in 0...events.length 
			for i in 0..$Trainer.party.length-1
				if $Trainer.party[i].hp<=0 
					id = $Trainer.party[i].species
				else
					id = $Trainer.party[i].species
				end
			end
			if events[i] && events[i][8]=="Dependent"
				if shiny==true
					events[i][6]=sprintf("%03ds",id)
					if FileTest.image_exist?("Graphics/Characters/"+events[i][6])
						@realEvents[i].character_name=sprintf("%03ds",id)
					else
						events[i][6]=sprintf("%03d",id)
						@realEvents[i].character_name=sprintf("%03d",id)
					end
				else
					events[i][6]=sprintf("%03d",id)
					@realEvents[i].character_name=sprintf("%03d",id)
				end
				if animation==true
				else
				end
			end 
		end 
	end
	#===============================================================================
	# * check_faint
	# * If current Pokemon is fainted, removes the sprite
	#===============================================================================
	def check_faint
		if $PokemonGlobal.surfing==true || $PokemonGlobal.bicycle==true
		else
			if $Trainer.party[0].hp<=0 
				$game_variables[Current_Following_Variable]=0 
				remove_sprite
			elsif $Trainer.party[0].hp>0 && !$Trainer.party[0].egg?
			end 
		end
	end
	#===============================================================================
	# * SetMoveRoute
	# * Used in the "Control Following Pokemon" Script listed farther above
	#===============================================================================
	def SetMoveRoute(commands,waitComplete=false)
		events=$PokemonGlobal.dependentEvents
		for i in 0...events.length
			if events[i] && events[i][8]=="Dependent"
				pbMoveRoute(@realEvents[i],commands,waitComplete)
				$PokemonTemp.dependentEvents.refresh_sprite(false)
			end
		end
	end
end



#===============================================================================
# * Auto add Script to Kernel.pbSurf, It'll check curent Pokemon when surf
#===============================================================================
def Kernel.pbSurf
	#  if $game_player.pbHasDependentEvents?
	#    return false
	#  end
	if $DEBUG ||
		(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
		movefinder=Kernel.pbCheckMove(:SURF)
		if $DEBUG || movefinder
			if Kernel.pbConfirmMessage(_INTL("The water is dyed a deep blue...  Would you like to surf?"))
				speciesname=!movefinder ? $Trainer.name : movefinder.name
				Kernel.pbMessage(_INTL("{1} used Surf!",speciesname))
				pbHiddenMoveAnimation(movefinder)
				#        $PokemonTemp.dependentEvents.check_surf
				surfbgm=pbGetMetadata(0,MetadataSurfBGM)
				$PokemonTemp.dependentEvents.check_surf
				if surfbgm
					pbCueBGM(surfbgm,0.5)
				end
				pbStartSurfing()
				return true
			end
		end
	end
	return false
end

def pbStartSurfing()
	#>Old Code
	#Kernel.pbCancelVehicles
	#$PokemonEncounters.clearStepCount
	#$PokemonTemp.dependentEvents.remove_sprite
	#$PokemonGlobal.surfing=true
	#Kernel.pbUpdateVehicle
	#Kernel.pbJumpToward
	#Kernel.pbUpdateVehicle
	#$game_player.check_event_trigger_here([1,2])
	#>New Code
	Kernel.pbCancelVehicles
	$PokemonEncounters.clearStepCount
	$PokemonTemp.dependentEvents.remove_sprite
	$PokemonGlobal.surfing=true
	Kernel.pbUpdateVehicle
	dist = 1
	dist *= 2 if $game_player.direction == 4 || $game_player.direction==6
	$game_player.through = true
	Kernel.pbJumpToward(dist)
	Kernel.pbUpdateVehicle
	$game_player.through = false
	$game_player.check_event_trigger_here([1,2])
end
#===============================================================================
# * Auto add Script to pbEndSurf, It'll show sprite after surf
#===============================================================================
def pbEndSurf(xOffset,yOffset)
	#>Old code
	#return false if !$PokemonGlobal.surfing
	#x=$game_player.x
	#y=$game_player.y
	#currentTag=$game_map.terrain_tag(x,y)
	#facingTag=Kernel.pbFacingTerrainTag
	#if pbIsSurfableTag?(currentTag)&&!pbIsSurfableTag?(facingTag)
	#  if Kernel.pbJumpToward
	#    Kernel.pbCancelVehicles
	#    $game_map.autoplayAsCue
	#    $game_player.increase_steps
	#    result=$game_player.check_event_trigger_here([1,2])
	#    Kernel.pbOnStepTaken(result)
	#    $FollowingFinishedSurfing = true
	#  end
	#  return true
	#end
	#return false
	#>New Code
	return false if !$PokemonGlobal.surfing
	x=$game_player.x
	y=$game_player.y
	currentTag=$game_map.terrain_tag(x,y)
	facingTag=Kernel.pbFacingTerrainTag
	if $game_player.direction == 4 || $game_player.direction==6
		facingTag=$game_map.terrain_tag(x-2,y) if $game_player.direction == 4 
		facingTag=$game_map.terrain_tag(x+2,y)if $game_player.direction==6
	end
	if pbIsSurfableTag?(currentTag)&&(!pbIsSurfableTag?(facingTag) || pbNotWaterTag?(facingTag) )
		dist = 1
		dist *= 2 if $game_player.direction == 4 || $game_player.direction==6
		if Kernel.pbJumpToward(dist)
			Kernel.pbCancelVehicles
			$game_map.autoplayAsCue
			$game_player.increase_steps
			result=$game_player.check_event_trigger_here([1,2])
			Kernel.pbOnStepTaken(result)
			$FollowingFinishedSurfing = true
		end
		return true
	end
	return false
end
#===============================================================================
# * Auto add Script to Kernel.pbCanUseHiddenMove, fix HM bug
#===============================================================================
def Kernel.pbCanUseHiddenMove?(pkmn,move)
	if move.is_a?(Symbol)
		move=getConst(PBMoves,move)
	end
	case move
=begin
    when PBMoves::FLY
      if !$DEBUG && !$Trainer.badges[BADGEFORFLY]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
   #  if $game_player.pbHasDependentEvents?
   #    Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
   #    return false
   #  end
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    when PBMoves::CUT
      if !$DEBUG && !$Trainer.badges[BADGEFORCUT]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || facingEvent.name!="Tree"
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    when PBMoves::HEADBUTT
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || facingEvent.name!="HeadbuttTree"
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    when PBMoves::SURF
      terrain=Kernel.pbFacingTerrainTag
      if !$DEBUG && !$Trainer.badges[BADGEFORSURF]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      if $PokemonGlobal.surfing
        Kernel.pbMessage(_INTL("You're already surfing."))
        return false
      end
   #   if $game_player.pbHasDependentEvents?
   #      Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
   #      return false
   #   end
      terrain=Kernel.pbFacingTerrainTag
      if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
        Kernel.pbMessage(_INTL("Let's enjoy cycling!"))
        return false
      end
      if !pbIsWaterEdgeTag?(terrain)
        Kernel.pbMessage(_INTL("No surfing here!"))
        return false
      end
      return true
    when PBMoves::STRENGTH
      if !$DEBUG && !$Trainer.badges[BADGEFORSTRENGTH]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || facingEvent.name!="Boulder"
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true  
    when PBMoves::ROCKSMASH
      terrain=Kernel.pbFacingTerrainTag
      if !$DEBUG && !$Trainer.badges[BADGEFORROCKSMASH]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || facingEvent.name!="Rock"
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true  
    when PBMoves::FLASH
      if !$DEBUG && !$Trainer.badges[BADGEFORFLASH]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      if $PokemonGlobal.flashUsed
        Kernel.pbMessage(_INTL("This is in use already."))
        return false
      end
      return true
    when PBMoves::WATERFALL
      if !$DEBUG && !$Trainer.badges[BADGEFORWATERFALL]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      terrain=Kernel.pbFacingTerrainTag
      if terrain!=PBTerrain::Waterfall
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    when PBMoves::DIVE
      if !$DEBUG && !$Trainer.badges[BADGEFORDIVE]
        Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
        return false
      end
      if $PokemonGlobal.diving
        return true
      end
      if $game_player.terrain_tag!=PBTerrain::DeepWater
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    when PBMoves::TELEPORT
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
   #  if $game_player.pbHasDependentEvents?
   #    Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
   #    return false
   #  end
      healing=$PokemonGlobal.healingSpot
      if !healing
        healing=pbGetMetadata(0,MetadataHome) # Home
      end
      if healing
        mapname=pbGetMapNameFromId(healing[0])
        if Kernel.pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?",mapname))
          return true
        end
        return false
      else
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
    when PBMoves::DIG
      escape=pbGetMetadata($game_map.map_id,MetadataEscapePoint)
      if !escape
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      if $game_player.pbHasDependentEvents?
        Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
        return false
      end
      mapname=pbGetMapNameFromId(escape[0])
      if Kernel.pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
        return true
      end
      return false
    when PBMoves::SWEETSCENT
      return true
    else
      return HiddenMoveHandlers.triggerCanUseMove(move,pkmn)
    end
=end
	when PBMoves::STRENGTH
		if $game_map.map_id == 684 && $game_player.x == 20 && $game_player.y == 15 && !$game_switches[REGISTEEL_SWITCH]
			$regiSpecial=true
			return true
		end
	when PBMoves::FLY
		if pbHasSpecies?(:SCALEON) && $game_map.map_id == 688 &&
			 $game_player.x == 25 && $game_player.y == 26 && !$game_switches[REGIDRAGO_SWITCH]
			$regiSpecial=true
			return true
		end
	when PBMoves::ROCKSMASH
		terrain=Kernel.pbFacingTerrainTag
		facingEvent=$game_player.pbFacingEvent
		echoln "MAP INFO #{$game_map.map_id} - X:#{$game_player.x} Y:#{$game_player.y}"
		if $game_map.map_id == 680 && $game_player.x == 20 && $game_player.y == 21 && !$game_switches[REGIROCK_SWITCH]
			$regiSpecial=true
			return true
		end
		if !facingEvent || facingEvent.name!="Rock"
			Kernel.pbMessage(_INTL("Can't use that here."))
			return false
		end
		return true
	when PBMoves::CUT		
	  	if pbHasSpecies?(:BANDEON) && $game_map.map_id == 686 &&
			$game_player.x == 18 && $game_player.y == 26 && !$game_switches[REGIELEKI_SWITCH]
			$regiSpecial=true
			return true
		end
		facingEvent=$game_player.pbFacingEvent
		if !facingEvent || facingEvent.name!="Tree"
			Kernel.pbMessage(_INTL("Can't use that here."))
			return false
		end
		return true
	when PBMoves::SURF
		if $game_map.map_id == 682 && $game_player.x == 15 && $game_player.y == 15 && !$game_switches[REGICE_SWITCH]
			$regiSpecial=true
			return true
		end
		terrain=Kernel.pbFacingTerrainTag
		if !$DEBUG && !$Trainer.badges[BADGEFORSURF]
			Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
			return false
		end
		if $PokemonGlobal.surfing
			Kernel.pbMessage(_INTL("You're already surfing."))
			return false
		end
		#   if $game_player.pbHasDependentEvents?
		#      Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
		#      return false
		#   end
		terrain=Kernel.pbFacingTerrainTag
		if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
			Kernel.pbMessage(_INTL("Let's enjoy cycling!"))
			return false
		end
		if !pbIsWaterEdgeTag?(terrain)
			Kernel.pbMessage(_INTL("No surfing here!"))
			return false
		end
		return true
	end
	return true
end



#===============================================================================
# * Auto add Script to Kernel.pbMountBike
#===============================================================================
def Kernel.pbMountBike
	return if $PokemonGlobal.bicycle
	$PokemonGlobal.bicycle=true
	if $game_switches[Toggle_Following_Switch]==true
		$PokemonTemp.dependentEvents.remove_sprite(true)
	end
	Kernel.pbUpdateVehicle
	bikebgm=pbGetMetadata(0,MetadataBicycleBGM)
	if bikebgm
		pbCueBGM(bikebgm,0.5)
	end
end
#===============================================================================
# * Auto add Script to Kernel.pbDismountBike
#===============================================================================
def Kernel.pbDismountBike
	return if !$PokemonGlobal.bicycle
	$PokemonGlobal.bicycle=false
	$FollowingFinishedSurfing = true
	Kernel.pbUpdateVehicle
	$game_map.autoplayAsCue
end
#===============================================================================
# * Auto add Script to pbBikeCheck
#===============================================================================
def pbBikeCheck
	if $PokemonGlobal.surfing ||
		(!$PokemonGlobal.bicycle && pbGetTerrainTag==PBTerrain::TallGrass)
		Kernel.pbMessage(_INTL("Can't use that here."))
		return false
	end
	#  if $game_player.pbHasDependentEvents?
	#    Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
	#    return false
	#  end
	if $PokemonGlobal.bicycle
		if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
			Kernel.pbMessage(_INTL("You can't dismount your Bike here."))
			return false
		end
		return true
	else
		val=pbGetMetadata($game_map.map_id,MetadataBicycle)
		val=pbGetMetadata($game_map.map_id,MetadataOutdoor) if val==nil
		if !val
			Kernel.pbMessage(_INTL("Can't use that here."))
			return false
		end
		return true
	end
end

#===============================================================================
# * Auto add Script to pbTrainerPC
#===============================================================================
def pbTrainerPC
	Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.",$Trainer.name))
	pbTrainerPCMenu
	pbSEPlay("computerclose")
	$PokemonTemp.dependentEvents.refresh_sprite(true)
end
#===============================================================================
# * Auto add Script to class TrainerPC
#===============================================================================
class TrainerPC
	def shouldShow?
		return true
	end
	
	def name
		return _INTL("{1}'s PC",$Trainer.name)
	end
	
	def access
		Kernel.pbMessage(_INTL("\\se[accesspc]Accessed {1}'s PC.",$Trainer.name))
		pbTrainerPCMenu
		$PokemonTemp.dependentEvents.refresh_sprite(true)
	end
end
#===============================================================================
# * Auto add Script to pbPokeCenterPC
#===============================================================================
=begin
def pbPokeCenterPC
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.",$Trainer.name))
  loop do
    commands=PokemonPCList.getCommandList()
    command=Kernel.pbMessage(_INTL("Which PC should be accessed?"),
       commands,commands.length)
    if !PokemonPCList.callCommand(command)
      break
    end
  end
  pbSEPlay("computerclose")
  $PokemonTemp.dependentEvents.refresh_sprite(true)
end
=end

#===============================================================================
# * Auto add Script to Events.onStepTakenFieldMovement
# * Fixed End Surf for Toggle
# * NEED TO FIX GRASS ANIMATION PROBLEM
#===============================================================================
Events.onStepTakenFieldMovement+=proc{|sender,e|
	event=e[0] # Get the event affected by field movement
	currentTag=pbGetTerrainTag(event)
	if pbGetTerrainTag(event,true)==PBTerrain::Grass  # Won't show if under bridge
		$scene.spriteset.addUserAnimation(GRASS_ANIMATION_ID,event.x,event.y) if $scene.is_a?(Scene_Map)
	elsif event==$game_player && currentTag==PBTerrain::WaterfallCrest
		# Descend waterfall, but only if this event is the player
		Kernel.pbDescendWaterfall(event)
	elsif event==$game_player && currentTag==PBTerrain::Ice
		$PokemonTemp.dependentEvents.remove_sprite
	end
	if $FollowingFinishedSurfing==true && $game_switches[Toggle_Following_Switch]==true
		$PokemonTemp.dependentEvents.Come_back(true)
		$FollowingFinishedSurfing = false
	end
}

#===============================================================================
# * Start Pokemon Following
# * x is the Event ID that will become the follower
#===============================================================================
def pbPokemonFollow(x)
	Kernel.pbAddDependency2(x, "Dependent", CommonEvent)
	$PokemonTemp.dependentEvents.refresh_sprite(true)# if !currentTag==PBTerrain::Ice
	$game_switches[Following_Activated_Switch]=true
	$game_switches[Toggle_Following_Switch]=true
end