################################################################################
# MENU SCRIPT
#
# Version 1.0 (Build 1)
# 18/11/15
#
# All right reserved.
################################################################################

def wmFadeIn(object,type)
	object.fade(255,WheelMenu_Option.frames/2,:ease_out_cubic)
	object.setPosition(object.position)
end
def wmZoomIn(object,type)
	object.zoom(1,1,WheelMenu_Option.frames/2,:ease_out_cubic)
end

class WheelMenu_Sprite < Sprite
	include EAM_Sprite
end

class WheelMenu_Option < Sprite
	include EAM_Sprite
	attr_accessor	:text
	attr_reader		:imageName
	attr_reader		:state
	attr_reader		:position
	
	@@frames = 10
	
	@@posX = [256,342,376,342,256,170,136,170]
	@@posY = [72,106,192,278,312,278,192,106]
	
	def self.frames 
		return @@frames
	end
	
	def initialize(text,imageName,pos=-1,state=false)
		viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewport.z = 99999
		super(viewport)
		@text = text
		@option = WheelMenu_Sprite.new(viewport)
		@option.opacity = 0
		@option.y = Graphics.height/2 # 20/2 - height
		@option.bitmap = Bitmap.new(150,40)
		pbSetSystemFont(@option.bitmap)
		@option.bitmap.font.size = $MKXP ? 36 : 38
		@option.bitmap.draw_text(0,0,150,40,@text,1)
		@option.ox = 75	# 150/2 - width
		@option.oy = 20	# 20/2 - height
		@imageName = imageName
		@state = state
		@position = pos
		generatePath
		self.opacity = 0
		self.ox = self.bitmap.width/2
		self.oy = self.bitmap.height/2
		self.x = Graphics.width/2
		self.y = Graphics.height/2
		echoln("WheelMenu_option.new(" + text + "," + imageName + "," + pos.to_s + "," + state.to_s + ")")
	end
	
	def show(pos)
		range = calcolateRange(@position,pos)
		@position = pos
		posXY = getXY(pos)
		echoln("Moving " + text + " on position " + pos.to_s + "(" + posXY[0].to_s + ";" + posXY[1].to_s + ")")
		self.move(posXY[0],posXY[1],@@frames,:ease_out_cubic)
		self.fade(255,@@frames,:ease_out_cubic)
	end
	
	def hide
		self.move(Graphics.width/2,Graphics.height/2,15,:ease_out_cubic)
		self.fade(0,@@frames)
		@option.fade(0,@@frames,:ease_out_cubic) if @state
	end
	
	def imageName=(image)
		@imageName = image
		generatePath
	end
	
	def state(state,pos)
		@state = state
		generatePath
		if state
			self.zoom(1.2,1.2,@@frames,:ease_out_cubic)
			@option.x = (pos >= 0 ? 176 : 336)
			@option.move(256,@option.y,@@frames,:ease_out_cubic)
			@option.fade(255,@@frames,:ease_out_cubic)
		else
			self.zoom(1,1,@@frames,:ease_out_cubic)
			toMove = (pos >= 0 ? 336 : 176)
			@option.move(toMove,@option.y,@@frames,:ease_out_cubic)
			@option.fade(0,@@frames,:ease_out_cubic)
		end
	end
	
	def generatePath
		bitmapPath = "Graphics/Pictures/WheelMenu/" + @imageName
		bitmapPath += "_on" if @state
		self.bitmap = Bitmap.new(bitmapPath)
	end
	
	def position=(pos)
		range = calcolateRange(@position,pos)
		@position = pos
		posXY = getXY(pos)
		echoln("Moving " + text + " on position " + pos.to_s + "(" + posXY[0].to_s + ";" + posXY[1].to_s + ")")
		if range <= 1
			self.move(posXY[0],posXY[1],@@frames,:ease_out_cubic)
		else
			self.fade(0,@@frames/2,:linear_tween,method(:wmFadeIn))
			self.zoom(0.4,0.4,@@frames/2,:linear_tween,method(:wmZoomIn))
		end
	end
	
	def setPosition(pos)
		@position = pos
		posXY = getXY(pos)
		self.x = posXY[0]
		self.y = posXY[1]
	end
	
	def getXY(pos)
		return [@@posX[pos],@@posY[pos]]
	end
	
	def calcolateRange(pos1,pos2)
		return 1 if (pos1 == 7 && pos2 == 0) || (pos1 == 0 && pos2 == 7)
		return (pos1 - pos2).abs
	end
	
	def update()
		super
		@option.update
	end
end

class WheelMenu
	def self.open
		pbSetViableDexes
		commands =[]
		cmdPokedex=-1
		cmdPokemon=-1
		cmdBag=-1
		cmdTrainer=-1
		cmdSave=-1
		cmdOption=-1
		cmdPokegear=-1
		cmdDebug=-1
		cmdQuit=-1
		
		if !$Trainer
			if $DEBUG
				Kernel.pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
				Kernel.pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
			end
			return
		end
		
		commands[cmdPokedex=commands.length]= WheelMenu_Option.new(_INTL("Pokédex"),"pokedex",cmdPokedex) if $Trainer.pokedex && $PokemonGlobal.pokedexViable.length>0
		commands[cmdPokemon=commands.length]= WheelMenu_Option.new(_INTL("Pokémon"),"pokemon",cmdPokemon) if $Trainer.party.length>0
		commands[cmdBag=commands.length]= WheelMenu_Option.new(_INTL("Zaino"),($Trainer.gender == 0 ? "bag" : "bag_female"),cmdBag) if !pbInBugContest?
		commands[cmdPokegear=commands.length]= WheelMenu_Option.new(_INTL("Pokégear"),"cerchioMagico",cmdPokegear) if $Trainer.pokegear
		commands[cmdTrainer=commands.length]= WheelMenu_Option.new($Trainer.name,($Trainer.gender == 0 ? "card" : "card_female"),cmdTrainer)
		if pbInSafari?
			commands[cmdQuit=commands.length]= WheelMenu_Option.new(_INTL("Abbandona"),"exit",cmdQuit)
		elsif pbInBugContest?
			commands[cmdQuit=commands.length]= WheelMenu_Option.new(_INTL("Abbandona"),"exit",cmdQuit)
		else
			commands[cmdSave=commands.length]= WheelMenu_Option.new(_INTL("Salva"),"save",cmdSave) if !$game_system || !$game_system.save_disabled
		end
		commands[cmdOption=commands.length]= WheelMenu_Option.new(_INTL("Opzioni"),"option",cmdOption)
		commands[commands.length]= WheelMenu_Option.new(_INTL("Esci"),"exit",commands.length)
		if $DEBUG
			cmdDebug=commands.length
		else
			cmdDebug = nil
		end
		
		ret = self.showMenu(commands,cmdDebug)
		
		case ret
		when cmdPokedex
			# Pokédex
			if DEXDEPENDSONLOCATION
				pbFadeOutIn(99999) {
					scene=PokemonPokedexScene.new
					screen=PokemonPokedex.new(scene)
					screen.pbStartScreen
					#@scene.pbRefresh
				}
			else
				if $PokemonGlobal.pokedexViable.length==1
					$PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[0]
					$PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
					pbFadeOutIn(99999) {
						scene=PokemonPokedexScene.new
						screen=PokemonPokedex.new(scene)
						screen.pbStartScreen
						#@scene.pbRefresh
					}
				else
					pbLoadRpgxpScene(Scene_PokedexMenu.new)
				end
			end
		when cmdPokegear
			# Pokégear
			pbLoadRpgxpScene(Scene_Pokegear.new)
		when cmdPokemon
			# Pokémon
			sscene=PokemonScreen_Scene.new
			sscreen=PokemonScreen.new(sscene,$Trainer.party)
			hiddenmove=nil
			pbFadeOutIn(99999) { 
				hiddenmove=sscreen.pbPokemonScreen
				if hiddenmove
					@scene.pbEndScene
				else
					#@scene.pbRefresh
				end
			}
			if hiddenmove
				Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
				return
			end
		when cmdBag
			# Borsa
			item=0
			scene=PokemonBag_Scene.new
			screen=PokemonBagScreen.new(scene,$PokemonBag)
			pbFadeOutIn(99999) { 
				item=screen.pbStartScreen 
				if item>0
					@scene.pbEndScene
				else
					#@scene.pbRefresh
				end
			}
			if item>0
				Kernel.pbUseKeyItemInField(item)
				return
			end
		when cmdTrainer
			# Trainer
			scene=PokemonTrainerCardScene.new
			screen=PokemonTrainerCard.new(scene)
			pbFadeOutIn(99999) { 
				screen.pbStartScreen
				#@scene.pbRefresh
			}
		when cmdQuit
			# Quit
			@scene.pbHideMenu
			if pbInSafari?
				if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
					@scene.pbEndScene
					pbSafariState.decision=1
					pbSafariState.pbGoToStart
					return
				else
					pbShowMenu
				end
			else
				if Kernel.pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
					@scene.pbEndScene
					pbBugContestState.pbStartJudging
					return
				else
					pbShowMenu
				end
			end
		when cmdSave
			# Save
			#@scene.pbHideMenu
			scene=PokemonSaveScene.new
			screen=PokemonSave.new(scene)
			screen.pbSaveScreen
			
=begin
			if screen.pbSaveScreen
				@scene.pbEndScene
				endscene=false
				break
			else
				pbShowMenu
			end
=end
		when cmdDebug
			# Debug
			pbFadeOutIn(99999) { 
				pbDebugMenu
				#@scene.pbRefresh
			}
		when cmdOption
			# Option
			scene=PokemonOptionScene.new
			screen=PokemonOption.new(scene)
			pbFadeOutIn(99999) {
				screen.pbStartScreen
				pbUpdateSceneMap
				#@scene.pbRefresh
			}
		end
		echoln("Exit with " + ret.to_s)
		return ret
	end
	
	def self.showMenu(commands,cmdDebug)
		ret=-1
		sprites ={}
		stopInput = false
		stopFrame = 0
		wheelIndex = $PokemonTemp.menuLastChoice
		wheelIndex = 0 if !wheelIndex
		pbSEPlay("menu")
		commands.each { |com| com.show(getPosValue(com.position - wheelIndex, commands.length))}
		viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewport.z = 99997
		sprites["background"] = WheelMenu_Sprite.new(viewport)
		sprites["background"].opacity = 0
		sprites["background"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		color = Color.new(0,0,0,150)
		sprites["background"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,color)
		sprites["background"].fade(255,WheelMenu_Option.frames)
		viewportFront = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewportFront.z = 99999
		viewportBack = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewportBack.z = 99998
		if $DEBUG
			sprites["sprite"] = WheelMenu_Sprite.new(viewportFront)
			sprites["sprite"].bitmap = Bitmap.new("Graphics/Pictures/WheelMenu/cerchioMagico")
			sprites["sprite"].opacity = 0
			sprites["sprite"].x = 40
			sprites["sprite"].y = 40
			sprites["sprite"].ox = sprites["sprite"].bitmap.width/2
			sprites["sprite"].oy = sprites["sprite"].bitmap.height/2
			sprites["sprite"].zoom_x = 0.5
			sprites["sprite"].zoom_y = 0.5
			sprites["sprite"].fade(255,WheelMenu_Option.frames,:ease_out_cubic)
			sprites["sprite"].zoom(1,1,WheelMenu_Option.frames,:ease_out_cubic)
			sprites["text"] = WheelMenu_Sprite.new(viewportFront)
			sprites["text"].bitmap = Bitmap.new(300,80)
			sprites["text"].bitmap.draw_text(0,0,300,80,_INTL("Debug (A)"))
			sprites["text"].opacity = 0
			sprites["text"].x = 80
			sprites["text"].y = 0
			sprites["text"].fade(255,WheelMenu_Option.frames,:ease_out_cubic)
		end
		color = Color.new(0,0,0,150)
		sprites["textbg"] = WheelMenu_Sprite.new(viewportBack)
		sprites["textbg"].bitmap = Bitmap.new(Graphics.width,50)
		sprites["textbg"].bitmap.fill_rect(0,0,Graphics.width,50,color)
		sprites["textbg"].x = 0
		sprites["textbg"].y = Graphics.height/2
		sprites["textbg"].oy = 25
		sprites["textbg"].zoom_y = 0
		sprites["textbg"].zoom(1,1,WheelMenu_Option.frames,:ease_out_cubic)
		commands[wheelIndex].state(true,1)
		
		loop do
			commands.each { |com| com.update }
			pbUpdateSpriteHash(sprites)
			Graphics.update
			Input.update
			if stopInput
				stopFrame += 1
				if stopFrame > WheelMenu_Option.frames/2
					stopInput = false
				end
			end
			if !stopInput
				if Input.trigger?(Input::B)
					ret=-2
					pbSEPlay("menu")
					break
				end
				if Input.trigger?(Input::C)
					ret=wheelIndex
					$PokemonTemp.menuLastChoice=ret
					pbSEPlay("Select")
					break
				end
				if Input.trigger?(Input::X) && $DEBUG
					ret = cmdDebug		# Riferimento al DEBUG come sempre ultima opzione
					pbSEPlay("Select")
					break
				end
				if Input.trigger?(Input::LEFT)
					wheelIndex = self.left(commands,wheelIndex)
					stopInput = true
					stopFrame = 0
					pbSEPlay("Select")
				end
				if Input.trigger?(Input::RIGHT)
					wheelIndex = self.right(commands,wheelIndex)
					stopInput = true
					stopFrame = 0
					pbSEPlay("Select")
				end
			end
		end
		
		disposeMenu(commands)
		while commands[0].isAnimating?
			sprites["background"].fade(0,WheelMenu_Option.frames,:ease_out_cubic)
			if sprites["sprite"] != nil
				sprites["sprite"].fade(0,WheelMenu_Option.frames,:ease_out_cubic)
				sprites["text"].fade(0,WheelMenu_Option.frames,:ease_out_cubic)
			end
			sprites["textbg"].zoom(1,0,WheelMenu_Option.frames,:ease_out_cubic)
			commands.each { |com| com.update }
			pbUpdateSpriteHash(sprites)
			Graphics.update
		end
		commands.each { |com| com.dispose }
		return ret
	end
	
	def self.left(commands,index,pos=-1)
		return self.right(commands,index,pos)
	end
	
	def self.right(commands,index,pos=1)
		commands[index].state(false,pos)
		commands.each { |com| com.position=getPosValue(com.position + pos, commands.length)}
		index = getPosValue(index - pos,commands.length)
		commands[index].state(true,pos)
		return index
	end
	
	def self.disposeMenu(commands)
		commands.each { |com| com.hide }
	end
	
	def self.getPosValue(pos,length)
		return pos % length
	end
end

class Scene_Map
	def call_menu
		$game_temp.menu_calling = false
    $game_player.straighten
    $game_map.update
		WheelMenu.open
	end
end
