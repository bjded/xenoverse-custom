#Adding some methods to the PokeBattle_Battle class for luxflon's battle
class PokeBattle_Battle
	
	def pbStartLuxflonBattle(canlose=true)
		PBDebug.log("******************************************")
		begin
			pbStartLuxflonBattleCore(canlose)
		rescue BattleAbortedException
			@decision=0
			@scene.pbEndBattle(@decision)
		end
		return @decision
	end
	
	def pbStartLuxflonBattleCore(canlose=true)
		Kernel.pbMessage("Starting luxflon battle") if $DEBUG
		
		sendout=pbFindNextUnfainted(@party1,0)
		if sendout < 0
			raise _INTL("Il giocatore non ha più Pokémon in grado di lottare")
		end
		playerpoke=@party1[sendout]
		@battlers[0].pbInitialize(playerpoke,sendout,false)
		
		
		
		if !@fullparty1 && @party1.length > MAXPARTYSIZE
			raise ArgumentError.new(_INTL("La squadra 1 ha più di {1} Pokémon.",MAXPARTYSIZE))
		end
		if !@fullparty2 && @party2.length > MAXPARTYSIZE
			raise ArgumentError.new(_INTL("La squadra 2 ha più di {1} Pokémon.",MAXPARTYSIZE))
		end
		$smAnim = false if ($smAnim && @doublebattle) || EBUISTYLE!=2
		if !@opponent
			#========================
			# Initialize wild Pokémon
			#========================
			if @party2.length==1
				if @doublebattle
					raise _INTL("Massimo due Pokémon selvatici nelle lotte in doppio")
				end
				wildpoke=@party2[0]
				@battlers[1].pbInitialize(wildpoke,0,false)
				@peer.pbOnEnteringBattle(self,wildpoke)
				pbSetSeen(wildpoke)
				@scene.pbStartLFBattle(self)
				#@scene.pbShowLuxflon
				@scene.sendingOut=true
				pbDisplayPaused(_INTL("{1} è su tutte le furie!",wildpoke.name))
			elsif @party2.length==2
				if !@doublebattle
					raise _INTL("Massimo un Pokémon selvatico nelle lotte in singolo")
				end
				@battlers[1].pbInitialize(@party2[0],0,false)
				@battlers[3].pbInitialize(@party2[1],0,false)
				@peer.pbOnEnteringBattle(self,@party2[0])
				@peer.pbOnEnteringBattle(self,@party2[1])
				pbSetSeen(@party2[0])
				pbSetSeen(@party2[1])
				@scene.pbStartBattle(self)
				pbDisplayPaused(_INTL("Sono apparsi {1} e\r\n{2} selvatici!",
						@party2[0].name,@party2[1].name))
			else
				raise _INTL("Massimo uno o due Pokémon selvatici")
			end
			#====================================
			# Initialize player in single battles
			#====================================
			#@scene.sendingOut=true
			#sendout=pbFindNextUnfainted(@party1,0)
			#if sendout < 0
			#       raise _INTL("Il giocatore non ha più Pokémon in grado di lottare")
			#end
			#playerpoke=@party1[sendout]
			#@battlers[0].pbInitialize(playerpoke,sendout,false)
			#@scene.pbShowLuxflonBar
			pbWait(10)
			pbDisplayPaused(_INTL("{1} ti si para davanti!",getBattlerPokemon(@battlers[0]).name))
			@scene.pbShowLuxflonBar
			#pbSendOutInitial(@doublebattle,0,playerpoke)
		end
		#==================
		# Initialize battle
		#==================
		if @weather==PBWeather::SUNNYDAY
			pbDisplay(_INTL("La luce solare è accecante."))
		elsif @weather==PBWeather::RAINDANCE
			pbDisplay(_INTL("Piove a dirotto."))
		elsif @weather==PBWeather::SANDSTORM
			pbDisplay(_INTL("Imperversa una tempesta di sabbia."))
		elsif @weather==PBWeather::HAIL
			pbDisplay(_INTL("Grandina."))
		elsif PBWeather.const_defined?(:HEAVYRAIN) && @weather==PBWeather::HEAVYRAIN
			pbDisplay(_INTL("È scoppiato un acquazzone."))
		elsif PBWeather.const_defined?(:HARSHSUN) && @weather==PBWeather::HARSHSUN
			pbDisplay(_INTL("La luce solare è insostenibile."))
		elsif PBWeather.const_defined?(:STRONGWINDS) && @weather==PBWeather::STRONGWINDS
			pbDisplay(_INTL("Soffia un vento di bufera."))
		end
		pbOnActiveAll   # Abilities
		@turncount=0
		index = 0
		loop do   # Now begin the battle loop
			if index == 4
				pbDisplayPaused(_INTL("L'aria si fa pesante..."))
			end
			PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
			if @debug && @turncount >=100
				@decision=pbDecisionOnTime()
				PBDebug.log("***[Undecided after 100 rounds]")
				pbAbort
				break
			end
			PBDebug.logonerr{
				pbSetMoves(index)
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
			index+=1
			pbWait(6)
			@battlers[0].hp=483
			if index==4
				pbDisplayPaused(_INTL("Dragalisk non ha scalfito Luxflon..!"))
			end

			break if index == 5
		end
		return pbEndOfBattle(canlose,true)
	end
	
	def pbSetMoves(index)
		if index <=3
			pbRegisterMove(1,index,true)
		else
			pbRegisterMove(1,rand(4),true)
			pbRegisterMove(0,0,true)
		end
	end
	
end


#Adding some methods to the PokeBattle_Scene class for luxflon's battle
class PokeBattle_Scene
	
	def pbStartLFBattle(battle)
		
		@battle=battle
		angle=($PokemonSystem.screensize < 1) ? 10 : 25
		@vector = Vector.new(-Graphics.width*1.0,VIEWPORT_HEIGHT*1.5,angle,Graphics.width*1.5,2,1)
		@firstsendout=true
		@lastcmd=[0,0,0,0]
		@lastmove=[0,0,0,0]
		@orgPos=nil
		@shadowAngle=60
		@idleTimer=0
		@idleSpeed=[40,0]
		@animationCount=1
		@showingplayer=true
		@showingenemy=true
		@briefmessage=false
		@lowHPBGM=false
		@sprites.clear
		@viewport=Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
		@viewport.z=99999
		@viewport2=Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
		@viewport2.z=999999
		@sprites["weather"] = RPG::BattleWeather.new(@viewport) if !@safaribattle && EBUISTYLE > 0
		@msgview=Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
		@msgview.z=999999
		@msgview2=Viewport.new(0,VIEWPORT_HEIGHT+VIEWPORT_OFFSET,Graphics.width,VIEWPORT_HEIGHT)
		@msgview2.z=999999
		@traineryoffset=(VIEWPORT_HEIGHT-320) # Adjust player's side for screen size
		@foeyoffset=(@traineryoffset*3/4).floor  # Adjust foe's side for screen size
		pbBackdrop
		if @battle.player.is_a?(Array)
			trainerfile=pbPlayerSpriteBackFile(@battle.player[0].trainertype)
			pbAddSprite("player",0,0,trainerfile,@viewport)
			trainerfile=pbTrainerSpriteBackFile(@battle.player[1].trainertype)
			pbAddSprite("playerB",0,0,trainerfile,@viewport)
		else
			trainerfile=pbPlayerSpriteBackFile(@battle.player.trainertype)
			pbAddSprite("player",0,0,trainerfile,@viewport)
		end
		@sprites["player"].x=40
		@sprites["player"].y=VIEWPORT_HEIGHT-@sprites["player"].bitmap.height
		@sprites["player"].z=30
		@sprites["player"].opacity=0
		@sprites["player"].src_rect.set(0,0,@sprites["player"].bitmap.width/4,@sprites["player"].bitmap.height)
		if @sprites["playerB"]
			@sprites["playerB"].x=140
			@sprites["playerB"].y=VIEWPORT_HEIGHT-@sprites["playerB"].bitmap.height
			@sprites["playerB"].z=30
			@sprites["playerB"].opacity=0
			@sprites["playerB"].src_rect.set(0,0,@sprites["playerB"].bitmap.width/4,@sprites["playerB"].bitmap.height)
		end
		if @battle.opponent
			if @battle.opponent.is_a?(Array)
				trainerfile=pbTrainerSpriteFile(@battle.opponent[1].trainertype)
				@sprites["trainer2"]=DynamicTrainerSprite.new(@battle.doublebattle,-2,@viewport,true)
				@sprites["trainer2"].setTrainerBitmap(trainerfile)
				@sprites["trainer2"].z=16
				@sprites["trainer2"].tone=Tone.new(-255,-255,-255,-255)
				trainerfile=pbTrainerSpriteFile(@battle.opponent[0].trainertype)
				@sprites["trainer"]=DynamicTrainerSprite.new(@battle.doublebattle,-1,@viewport,true)
				@sprites["trainer"].setTrainerBitmap(trainerfile)
				@sprites["trainer"].z=11
				@sprites["trainer"].tone=Tone.new(-255,-255,-255,-255)
			else
				trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
				@sprites["trainer"]=DynamicTrainerSprite.new(@battle.doublebattle,-1,@viewport)
				@sprites["trainer"].setTrainerBitmap(trainerfile)
				@sprites["trainer"].z=11
				@sprites["trainer"].tone=Tone.new(-255,-255,-255,-255)
			end
		end
		@sprites["pokemon0"]=DynamicPokemonSprite.new(battle.doublebattle,0,@viewport)
		@sprites["pokemon0"].z=21
		@sprites["pokemon1"]=DynamicPokemonSprite.new(battle.doublebattle,1,@viewport)
		@sprites["pokemon1"].z=11
		if battle.doublebattle
			@sprites["pokemon2"]=DynamicPokemonSprite.new(battle.doublebattle,2,@viewport)
			@sprites["pokemon2"].z=26
			@sprites["pokemon3"]=DynamicPokemonSprite.new(battle.doublebattle,3,@viewport)
			@sprites["pokemon3"].z=16
		end
		
		pbLoadUIElements(battle)
		
		pbSetMessageMode(false)
		trainersprite1=@sprites["trainer"]
		trainersprite2=@sprites["trainer2"]
		if !@battle.opponent
			if @battle.party2.length >=1
				if @battle.party2.length==1
					# wild (single) battle initialization
					@sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
					@sprites["pokemon1"].tone=Tone.new(-255,-255,-255,-255)
					@sprites["pokemon1"].visible=true
					@sprites["pokemon0"].setPokemonBitmap(@battle.party1[0],true)
					@sprites["pokemon0"].tone=Tone.new(-255,-255,-255,-255)
					@sprites["pokemon0"].visible=true
					trainersprite1=@sprites["pokemon1"]
				elsif @battle.party2.length==2
					# wild (double battle initialization)
					@sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
					@sprites["pokemon1"].tone=Tone.new(-255,-255,-255,-255)
					@sprites["pokemon1"].visible=true
					trainersprite1=@sprites["pokemon1"]
					@sprites["pokemon3"].setPokemonBitmap(@battle.party2[1],false)
					@sprites["pokemon3"].tone=Tone.new(-255,-255,-255,-255)
					@sprites["pokemon3"].visible=true
					trainersprite2=@sprites["pokemon3"]
				end
			end
		end
		#################
		# Position for initial transition
		#--------------------------------------------
		black=Sprite.new(@viewport)
		black.z = 99999
		black.bitmap=Bitmap.new(Graphics.width,VIEWPORT_HEIGHT)
		black.bitmap.fill_rect(0,0,Graphics.width,VIEWPORT_HEIGHT,Color.new(0,0,0,0))
		#--------------------------------------------
		if @safaribattle
			@sprites["player"].x-=240
			@sprites["player"].y+=120
		end
		if $smAnim
			if $game_switches[85]
				vsBossSequence2_start(@viewport2,$wildSpecies)
			else
				vsSequenceSM_start(@viewport,@battle.opponent.trainertype)
			end
		end
		#################
		# Play battle entrance
		vector = @battle.doublebattle ? VECTOR2 : VECTOR1
		@vector.force
		#@vector.set(vector)
		@vector.set(VECTORDRAGALISK)
		@vector.inc=0.1
		for i in 0...22
			if @safaribattle
				@sprites["player"].opacity+=25.5
				@sprites["player"].zoom_x=@vector.zoom1
				@sprites["player"].zoom_y=@vector.zoom1
				@sprites["player"].x+=10
				@sprites["player"].y-=5
			end
			if !@battle.opponent && i > 11
				@sprites["pokemon1"].tone.red+=255*0.05 if @sprites["pokemon1"].tone.red < 0
				@sprites["pokemon1"].tone.blue+=255*0.05 if @sprites["pokemon1"].tone.blue < 0
				@sprites["pokemon1"].tone.green+=255*0.05 if @sprites["pokemon1"].tone.green < 0
				@sprites["pokemon1"].tone.gray+=255*0.05 if @sprites["pokemon1"].tone.gray < 0
				@sprites["pokemon0"].tone.red+=255*0.05 if @sprites["pokemon1"].tone.red < 0
				@sprites["pokemon0"].tone.blue+=255*0.05 if @sprites["pokemon1"].tone.blue < 0
				@sprites["pokemon0"].tone.green+=255*0.05 if @sprites["pokemon1"].tone.green < 0
				@sprites["pokemon0"].tone.gray+=255*0.05 if @sprites["pokemon1"].tone.gray < 0
				if @battle.party2.length==2
					@sprites["pokemon3"].tone.red+=255*0.05 if @sprites["pokemon3"].tone.red < 0
					@sprites["pokemon3"].tone.blue+=255*0.05 if @sprites["pokemon3"].tone.blue < 0
					@sprites["pokemon3"].tone.green+=255*0.05 if @sprites["pokemon3"].tone.green < 0
					@sprites["pokemon3"].tone.gray+=255*0.05 if @sprites["pokemon3"].tone.gray < 0
				end
			end
			if @battle.opponent && i > 11
				@sprites["trainer"].tone.red+=255*0.05 if @sprites["trainer"].tone.red < 0
				@sprites["trainer"].tone.blue+=255*0.05 if @sprites["trainer"].tone.blue < 0
				@sprites["trainer"].tone.green+=255*0.05 if @sprites["trainer"].tone.green < 0
				@sprites["trainer"].tone.gray+=255*0.05 if @sprites["trainer"].tone.gray < 0
				if @battle.opponent.is_a?(Array)
					@sprites["trainer2"].tone.red+=255*0.05 if @sprites["trainer2"].tone.red < 0
					@sprites["trainer2"].tone.blue+=255*0.05 if @sprites["trainer2"].tone.blue < 0
					@sprites["trainer2"].tone.green+=255*0.05 if @sprites["trainer2"].tone.green < 0
					@sprites["trainer2"].tone.gray+=255*0.05 if @sprites["trainer2"].tone.gray < 0
				end
			end
			black.opacity-=12 if black.opacity>0
			wait(1,true)
		end
		@vector.inc=0.2
		#################
		# Play cry for wild Pokémon
		if !@battle.opponent
			pbPlayCry(@battle.party2[0])
			pbPlayCry(@battle.party2[1]) if @battle.doublebattle
			for i in 0...10
				@sprites["pokemon1"].tone.red+=255*0.05 if @sprites["pokemon1"].tone.red < 0
				@sprites["pokemon1"].tone.blue+=255*0.05 if @sprites["pokemon1"].tone.blue < 0
				@sprites["pokemon1"].tone.green+=255*0.05 if @sprites["pokemon1"].tone.green < 0
				@sprites["pokemon1"].tone.gray+=255*0.05 if @sprites["pokemon1"].tone.gray < 0
				@sprites["pokemon0"].tone.red+=255*0.05 if @sprites["pokemon1"].tone.red < 0
				@sprites["pokemon0"].tone.blue+=255*0.05 if @sprites["pokemon1"].tone.blue < 0
				@sprites["pokemon0"].tone.green+=255*0.05 if @sprites["pokemon1"].tone.green < 0
				@sprites["pokemon0"].tone.gray+=255*0.05 if @sprites["pokemon1"].tone.gray < 0
				if @battle.party2.length==2
					@sprites["pokemon3"].tone.red+=255*0.05 if @sprites["pokemon3"].tone.red < 0
					@sprites["pokemon3"].tone.blue+=255*0.05 if @sprites["pokemon3"].tone.blue < 0
					@sprites["pokemon3"].tone.green+=255*0.05 if @sprites["pokemon3"].tone.green < 0
					@sprites["pokemon3"].tone.gray+=255*0.05 if @sprites["pokemon3"].tone.gray < 0
				end
				wait(1,true)
			end
		end
		frames1=0
		frames2=0
		frames1=@sprites["trainer"].totalFrames if @sprites["trainer"]
		frames2=@sprites["trainer2"].totalFrames if @sprites["trainer2"]
		if frames1  >  frames2
			maxframes=frames1
		else
			maxframes=frames2
		end
		maxframes = 17 if maxframes < 17
	#else
		@sprites["battlebox1"].x=-264-10
		@sprites["battlebox1"].y=24
		@sprites["battlebox1"].appear
		if @battle.party2.length==2
			@sprites["battlebox1"].y=60
			@sprites["battlebox3"].x=-264-8
			@sprites["battlebox3"].y=8
			@sprites["battlebox3"].appear
		end
		10.times do
			if EBUISTYLE==2
				@sprites["battlebox1"].show
			elsif EBUISTYLE==0 && !defined?(SCREENDUALHEIGHT)
				@sprites["battlebox1"].update
			else
				@sprites["battlebox1"].x+=26
			end
			if @battle.party2.length==2
				if EBUISTYLE==2
					@sprites["battlebox3"].show
				elsif EBUISTYLE==0 && !defined?(SCREENDUALHEIGHT)
					@sprites["battlebox3"].update
				else
					@sprites["battlebox3"].x+=26
				end
			end
			wait(1,true)
		end
		# Show shiny animation for wild Pokémon
		if shinyBattler?(@battle.battlers[1]) && @battle.battlescene
			pbCommonAnimation("Shiny",@battle.battlers[1],nil)
		end
		if @battle.party2.length==2
			if shinyBattler?(@battle.battlers[3]) && @battle.battlescene
				pbCommonAnimation("Shiny",@battle.battlers[3],nil)
			end
		end
		#setVector(VECTORDRAGALISK)
		#setVector(102,384,32,342,0.5,1)
		@vector.set(VECTORDRAGALISK)
	end
	
	
	
	def pbShowLuxflonBar
		@sprites["battlebox#{0}"].x = @viewport.rect.width + 10
		@sprites["battlebox#{0}"].y = [204,0,232,0][0]
		@sprites["battlebox#{0}"].appear
		for i in 0..16
			@sprites["battlebox#{0}"].show
			pbWait(1)
		end
		@sendingOut = false
		@firstsendout = false
	end
	
end

#===============================================================================
#
# Use a script call with "pbStartLuxflonDragaliskBattle" in it and enjoy
#
#===============================================================================


class LuxflonBattle
	
	def initialize
		
	end
	
	def pbStartScreen
		@scene=pbNewBattleScene
		@dragalisk = PokeBattle_Pokemon.new(:DRAGALISK,60)
		@dragalisk.speed = 1000
		@dragalisk.pbDeleteAllMoves
		@dragalisk.pbLearnMove(:VOIDSTAR)
		@dragalisk.pbLearnMove(:DARKPULSE)
		@dragalisk.pbLearnMove(:EARTHQUAKE)
		@dragalisk.pbLearnMove(:FREEZEDRY)
		@luxflon = PokeBattle_Pokemon.new(:LUXFLON,60)
		@luxflon.speed = 1
		@luxflon.defense = 300000
		@luxflon.spDef = 300000
		@luxflon.totalHp = 483
		@luxflon.hp = 483
		@luxflon.pbDeleteAllMoves
		@luxflon.pbLearnMove(:ASTRALLANCE)
		@battle=PokeBattle_Battle.new(@scene,[@luxflon],[@dragalisk],PokeBattle_Trainer.new($Trainer.name,$Trainer.trainertype),nil)
		@battle.internalbattle=true
		@battle.cantescape=true
		pbPrepareBattle(@battle)
	end
	
	def pbPlayScreen
		Kernel.pbMessage("Opening battle!") if $DEBUG
		pbBattleAnimation(pbGetWildBattleBGM(@luxflon.species),-1,"",false){
			pbSceneStandby {
				decision=@battle.pbStartLuxflonBattle
			}
		}
	end
	
end

def pbStartLuxflonDragaliskBattle
	scene = LuxflonBattle.new
	scene.pbStartScreen
	scene.pbPlayScreen  
end