BOX_TOPBARFONT = Font.new
BOX_TOPBARFONT.name = [$MKXP ? "Kimberley" : "Kimberley Bl","Verdana"]
BOX_TOPBARFONT.size = $MKXP ? 22 : 24

#Lower bar font
BOX_LB = Font.new
BOX_LB.name = [$MKXP ? "Barlow Condensed" : "Barlow Condensed ExtraBold","Verdana"]
BOX_LB.size = $MKXP ? 24 : 26
BOX_LB.bold = $MKXP ? true : false

BOX_ACTFONT = Font.new 
BOX_ACTFONT.name = ["Barlow Condensed","Verdana"]
BOX_ACTFONT.size = $MKXP ? 16 : 18
BOX_ACTFONT.bold = true

BOX_PATH = "Graphics/Pictures/StorageNew/"

class NewPokemonStorage
	
	def initialize()
		@oldfr = Graphics.frame_rate
		Graphics.frame_rate = 60
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		
		@storage = $PokemonStorage
		
		@path = BOX_PATH
		@selIndex = 0
		
		@sprites = {}
		
		@heldmonsprite = nil
		@heldmon = nil
		@heldog = [] #array with the held origin, always PARTY,BOX,ID ex. false,0,9
		
		@sprites["bg"] = EAMSprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(@path + "bg")
		@sprites["bg"].z = -10
		
    	@sprites["abg"] = AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(@path + "animbg")
    
		@sprites["box"] = NewBox.new(@viewport,@storage,@storage.currentBox)
		@sprites["box"].x = 16
		@sprites["box"].y = 48
		
		@sprites["partybox"] = PartyBox.new(@viewport,$Trainer.party)
		@sprites["partybox"].x = 361
		@sprites["partybox"].y = 10
		@sprites["partybox"].z=10
		
		@sprites["top"] = EAMSprite.new(@viewport)
		@sprites["top"].bitmap = pbBitmap(@path + "Topbar")
		@sprites["top"].x = 25
		@sprites["top"].y = 8
		
		@sprites["boxname"] = BitmapSprite.new(276,32,@viewport)
		@sprites["boxname"].bitmap.font = BOX_TOPBARFONT
		@sprites["boxname"].x = 25
		@sprites["boxname"].y = 8
		
		@sprites["cursor"] = EAMSprite.new(@viewport)
		@sprites["cursor"].bitmap=pbBitmap(@path+"selector")
		#@sprites["cursor"].ox = 0
		#@sprites["cursor"].oy = 0
		@sprites["cursor"].x = @sprites["box"].pokemons[@selIndex].x
		@sprites["cursor"].y = @sprites["box"].pokemons[@selIndex].y
		@sprites["cursor"].z = 20
		
		@sprites["lowerbar"] = EAMSprite.new(@viewport)
		@sprites["lowerbar"].bitmap = pbBitmap(@path + "lowerbar")
		@sprites["lowerbar"].y = 345
		@sprites["lowerbar"].bitmap.font = BOX_LB
		#lowerbar overlay
		@sprites["lbo"]=BitmapSprite.new(@sprites["lowerbar"].bitmap.width,@sprites["lowerbar"].bitmap.height,@viewport)
		@sprites["lbo"].y = 345
		@sprites["lbo"].bitmap.font = BOX_LB
		
		drawLowerBarText()
		
		#drawing the action commands bitmaps
		@acsel=[]
		@acunsel=[]
		for i in 0...5
			txt = [_INTL("Move"),_INTL("Summary"),_INTL("Item"),_INTL("Mark"),_INTL("Free")][i]
			@acsel[i] = pbBitmap(@path + "actbutton_sel").clone
			@acunsel[i] = pbBitmap(@path + "actbutton_unsel").clone
			@acsel[i].font = @acunsel[i].font = BOX_ACTFONT
			
			pbDrawTextPositions(@acsel[i],[[txt,75,4,2,Color.new(248,248,248)]])
			pbDrawTextPositions(@acunsel[i],[[txt,75,4,2,Color.new(48,48,48)]])
		end
		
		
		
		updateBoxName()
		
		self.handling
	end
	
	def drawLowerBarText()
		@sprites["lbo"].bitmap.clear
		textpos = []
		textpos.push([_INTL("Jump"),102,3,1,Color.new(248,248,248)])
		textpos.push([_INTL("Actions"),280,3,1,Color.new(248,248,248)])
		if @heldmon == nil
			textpos.push([_INTL("Close"),474,3,1,Color.new(248,248,248)])
		else
			textpos.push([_INTL("Leave"),474,3,1,Color.new(248,248,248)])
		end
		pbDrawTextPositions(@sprites["lbo"].bitmap,textpos)
	end
	
	def updateBoxName()
		@sprites["boxname"].bitmap.clear
		pbDrawTextPositions(@sprites["boxname"].bitmap,[["Box #{@storage.currentBox+1}",138,4,2,Color.new(248,248,248)]])
	end
	
	# 0  1  2  3    16 17
	# 4  5  6  7    18 19
	# 8  9  10 11   20 21
	# 12 13 14 15
	
	def moveCursor(x,y)
		if x==1 #MOVE RIGHT
			if (@selIndex==3 || @selIndex==7 || @selIndex==11 || @selIndex==15)
				if @selIndex==3
					@selIndex=16
				elsif @selIndex==7
					@selIndex=18
				elsif @selIndex==11 || @selIndex == 15
					@selIndex=20
				end
			else
				if @selIndex != 17 && @selIndex != 19 && @selIndex != 21
					@selIndex+=1
				else
					#right border
					if @selIndex==17
						@selIndex=0
					elsif @selIndex==19
						@selIndex=4
					elsif @selIndex==21
						@selIndex=8
					end
				end
			end
		end
		if x==-1 #MOVE LEFT
			if (@selIndex==16 || @selIndex==18 || @selIndex==20)
				if @selIndex==16
					@selIndex=3
				elsif @selIndex==18
					@selIndex=7
				elsif @selIndex==20
					@selIndex=11
				end
			else
				if @selIndex != 0 && @selIndex != 4 && @selIndex != 8 && @selIndex != 12
					@selIndex-=1
				else
					#left border
					if @selIndex==0
						@selIndex=17
					elsif @selIndex==4
						@selIndex=19
					elsif @selIndex==8
						@selIndex=21
					end
				end
			end
		end
		
		if y==1 #MOVE DOWN
			if (@selIndex>=0 && @selIndex<=15)
				if @selIndex != 12 && @selIndex != 13 && @selIndex != 14 && @selIndex != 15
					@selIndex+=4
				else
					#lower border
					if @selIndex==12
						@selIndex=0
					elsif @selIndex==13
						@selIndex=1
					elsif @selIndex==14
						@selIndex=2
					elsif @selIndex==15
						@selIndex=3
					end
				end
			else
				if @selIndex != 20 && @selIndex != 21
					@selIndex+=2
				else
					#lower border
					if @selIndex==20
						@selIndex=16
					elsif @selIndex==21
						@selIndex=17
					end
				end
			end
		end
		
		if y==-1 #MOVE UP
			if (@selIndex>=0 && @selIndex<=15)
				if @selIndex != 0 && @selIndex != 1 && @selIndex != 2 && @selIndex != 3
					@selIndex-=4
				else
					#upper border
					if @selIndex==0
						@selIndex=12
					elsif @selIndex==1
						@selIndex=13
					elsif @selIndex==2
						@selIndex=14
					elsif @selIndex==3
						@selIndex=15
					end
				end
			else
				if @selIndex != 16 && @selIndex != 17
					@selIndex-=2
				else
					#upper border
					if @selIndex==16
						@selIndex=20
					elsif @selIndex==17
						@selIndex=21
					end
				end
			end
		end
		updateCursorPosition
	end
	
	def updateCursorPosition
		if @selIndex>=0 && @selIndex<=15
			@sprites["cursor"].move(@sprites["box"].pokemons[@selIndex].x,@sprites["box"].pokemons[@selIndex].y,4,:ease_out_quad)
		else
			@sprites["cursor"].move(@sprites["partybox"].pokemons[@selIndex-16].x,@sprites["partybox"].pokemons[@selIndex-16].y,4,:ease_out_quad)
		end
		
	end
	
	def update
		@sprites["cursor"].update
		@sprites["box"].update
		@sprites["partybox"].update
    if @sprites["abg"]
			@sprites["abg"].ox+=Dex::ANIMBGSCROLLX
			@sprites["abg"].oy+=Dex::ANIMBGSCROLLY
		end		 
		if @heldmonsprite != nil
			@heldmonsprite.x = @sprites["cursor"].x
			@heldmonsprite.y = @sprites["cursor"].y-20
		end
	end
	
	def handling
		
		loop do 
			Graphics.update
			Input.update
			update
			
			if Input.trigger?(Input::L)
				switchToLeft
			elsif Input.trigger?(Input::R)
				switchToRight
			end
			
			if Input.trigger?(Input::RIGHT)
				moveCursor(1,0)
			end
			
			if Input.trigger?(Input::LEFT)
				moveCursor(-1,0)
			end
			
			if Input.trigger?(Input::DOWN)
				moveCursor(0,1)
			end
			
			if Input.trigger?(Input::UP)
				moveCursor(0,-1)
			end
			
			if Input.trigger?(Input::Y) && (@selIndex>=0&& @selIndex<=15 ? @sprites["box"].currentbox[@selIndex] : @sprites["partybox"].party[@selIndex-16]) #actions menu
				openActions((@selIndex>=0&& @selIndex<=15 ? @sprites["box"].currentbox[@selIndex] : @sprites["partybox"].party[@selIndex-16]))
				next
			end
			
			if Input.trigger?(Input::X) #jump to box
				fb = chooseNumber(_INTL("Where to jump?"),STORAGEBOXES,1,1)
				jump(fb-1)
			end
			
			if Input.trigger?(Input::B)
				if @heldmon != nil #sending the held to its rightful slot
					if @sprites["box"].currentbox.pokemon.include?(@heldmon) #it's in the current box
						for i in 0..15
							if @sprites["box"].currentbox[i]==@heldmon
								@heldmonsprite.move(@sprites["box"].pokemons[i].x,@sprites["box"].pokemons[i].y,8,:ease_out_cubic)
								break
							end		
						end
						8.times do
							Graphics.update
							update
						end
						@sprites["box"].pokemons[i] = @heldmonsprite
						@sprites["box"].pokemons[i].z = 1
						@heldmonsprite = nil
						@heldmon = nil
						@heldog = []
					elsif @sprites["partybox"].party.include?(@heldmon) #it's in the party
						for i in 0..5
							if @sprites["partybox"].party[i]==@heldmon
								@heldmonsprite.move(@sprites["partybox"].pokemons[i].x,@sprites["partybox"].pokemons[i].y,8,:ease_out_cubic)
								break
							end		
						end
						8.times do
							Graphics.update
							update
						end
						@sprites["partybox"].pokemons[i] = @heldmonsprite
						@sprites["partybox"].pokemons[i].z = 11
						@heldmonsprite = nil
						@heldmon = nil
						@heldog = []
					elsif @heldog[1] != @storage.currentBox
						@heldmonsprite.fade(0,8,:ease_out_cubic)
						8.times do
							Graphics.update
							update
						end
						#@sprites["box"].pokemons[i] = @heldmonsprite
						#@sprites["box"].pokemons[i].z = 0
						@heldmonsprite.dispose
						@heldmonsprite = nil
						@heldmon = nil
						@heldog = []
					end
				else
					break
				end
			end
			
			if Input.trigger?(Input::C)
				handleCursor
			end
		end
		self.endscene
	end
	
	def handleCursor
		if @heldmon != nil #release
			if @selIndex>=0 && @selIndex<=15 #cursor over boxes
				if @sprites["box"].currentbox[@selIndex] == @heldmon #if it's the one i'm holding, put down
					#@heldmonsprite = @sprites["box"].pokemons[@selIndex]
					#@heldmonsprite.z = 11
					oldcoord = [@sprites["box"].pokemons[@selIndex].x,@sprites["box"].pokemons[@selIndex].y]
					@sprites["box"].pokemons[@selIndex].dispose						
					@sprites["box"].pokemons[@selIndex]=@heldmonsprite
					@sprites["box"].pokemons[@selIndex].z = 1
					@sprites["box"].pokemons[@selIndex].move(oldcoord[0],oldcoord[1],4,:ease_out_cubic)
					@heldmon = nil
					@heldmonsprite = nil
				elsif @sprites["box"].currentbox[@selIndex] != nil && @sprites["box"].currentbox[@selIndex] != @heldmon #switch
					echoln "#{!@heldog[0]} #{!checkSwitchedParty(@heldmon,@sprites["box"].currentbox[@selIndex])} #{@heldmon.hp<=0}"
					if !@heldog[0] && !checkSwitchedParty(@heldmon,@sprites["box"].currentbox[@selIndex]) && @heldmon.hp<=0
						Kernel.pbMessage(_INTL("You can't leave your Pokémon here!"))
						return
					end
					tmp = @heldmonsprite
					tmpmon = @heldmon
					oldid = @sprites["box"].currentbox.pokemon.index(tmpmon)
					@heldmonsprite = @sprites["box"].pokemons[@selIndex]
					@heldmonsprite.z = 12
					@heldmon = @sprites["box"].currentbox[@selIndex]
					@sprites["box"].pokemons[@selIndex]=tmp
					@sprites["box"].pokemons[@selIndex].z = 1
					@sprites["box"].pokemons[@selIndex].move(@heldmonsprite.x,@heldmonsprite.y,4,:ease_out_cubic)
					if @heldog[0] #held was from party
						@sprites["partybox"].party[@heldog[1]] = @heldmon
					else #held was from box
						if @storage.currentBox == @heldog[1]
							@sprites["box"].currentbox[@heldog[2]] = @heldmon
						else
							@sprites["box"].box[@heldog[1]][@heldog[2]]= @heldmon
						end
					end
					@sprites["box"].currentbox[@selIndex] = tmpmon
				else #leaving on empty slot
					if @heldog[0] && !checkParty(@heldmon)
						Kernel.pbMessage(_INTL("You can't leave your Pokémon here!"))
						return
					end
					@sprites["box"].currentbox[@selIndex] = @heldmon
					oldcoord = [@sprites["box"].pokemons[@selIndex].x,@sprites["box"].pokemons[@selIndex].y]
					@sprites["box"].pokemons[@selIndex] = @heldmonsprite
					@sprites["box"].pokemons[@selIndex].z = @heldog[0] ? 1 : (@heldog[1]==@storage.currentBox ? 1 : 1)
					@sprites["box"].pokemons[@selIndex].move(oldcoord[0],oldcoord[1],4,:ease_out_cubic)
					@heldmonsprite = nil
					@heldmon = nil
					if @heldog[0]
						@sprites["partybox"].party[@heldog[1]] = @heldmon
						@sprites["partybox"].shuffleParty
						#now i reorder the icons
						@sprites["partybox"].reorderIcons
						4.times do 
							Graphics.update
							@sprites["partybox"].pokemons.each{|p| p.update if defined?(p.update)}
						end
					else
						if @storage.currentBox == @heldog[1]
							@sprites["box"].currentbox[@heldog[2]] = @heldmon
						else
							echoln @heldog[1]
							@sprites["box"].box[@heldog[1]][@heldog[2]]= @heldmon
						end
					end
					@heldog=[]
				end
			else #cursor over party
				if @sprites["partybox"].party[@selIndex-16] == @heldmon #if it's the one i'm holding, put down
					#@heldmonsprite = @sprites["box"].pokemons[@selIndex]
					#@heldmonsprite.z = 11
					oldcoord = [@sprites["partybox"].pokemons[@selIndex-16].x,@sprites["partybox"].pokemons[@selIndex-16].y]
					@sprites["partybox"].pokemons[@selIndex-16].dispose						
					@sprites["partybox"].pokemons[@selIndex-16]=@heldmonsprite
					@sprites["partybox"].pokemons[@selIndex-16].z = 11
					@sprites["partybox"].pokemons[@selIndex-16].move(oldcoord[0],oldcoord[1],4,:ease_out_cubic)
					@heldmon = nil
					@heldmonsprite = nil
					@heldog = []
				elsif @sprites["partybox"].party[@selIndex-16] != nil && @sprites["partybox"].party[@selIndex-16] != @heldmon #switch
					echoln "#{!@heldog[0]} #{!checkSwitchedParty(@heldmon,@sprites["partybox"].party[@selIndex-16])} #{(@heldmon.hp<=0 || @heldmon.isEgg?)}"
					if !checkSwitchedParty(@heldmon,@sprites["partybox"].party[@selIndex-16]) && (@heldmon.hp<=0 || @heldmon.isEgg?)
						Kernel.pbMessage(_INTL("You can't leave your Pokémon here!"))
						return
					end
					#storing the currently held pokemon and sprite
					tmp = @heldmonsprite
					tmpmon = @heldmon
					
					@heldmonsprite = @sprites["partybox"].pokemons[@selIndex-16]
					@heldmonsprite.z = 12
					@heldmon = @sprites["partybox"].party[@selIndex-16]
					@sprites["partybox"].pokemons[@selIndex-16]=tmp
					@sprites["partybox"].pokemons[@selIndex-16].z = 11
					@sprites["partybox"].pokemons[@selIndex-16].move(@heldmonsprite.x,@heldmonsprite.y,4,:ease_out_cubic)
					#checking the origin
					if @heldog[0] #held was from party
						@sprites["partybox"].party[@heldog[1]] = @heldmon
					else
						if @storage.currentBox == @heldog[1]
							@sprites["box"].currentbox[@heldog[2]] = @heldmon
						else
							@sprites["box"].box[@heldog[1]][@heldog[2]]= @heldmon
						end
					end
					@sprites["partybox"].party[@selIndex-16] = tmpmon
				else #leaving on empty slot
					@sprites["partybox"].addToParty(@heldmon)#.currentbox[@selIndex] = @heldmon
					oldcoord = [@sprites["partybox"].pokemons[@selIndex-16].x,@sprites["partybox"].pokemons[@selIndex-16].y]
					@sprites["partybox"].pokemons[@selIndex-16] = @heldmonsprite
					@sprites["partybox"].pokemons[@selIndex-16].z = 11
					@sprites["partybox"].pokemons[@selIndex-16].move(oldcoord[0],oldcoord[1],4,:ease_out_cubic)
					@heldmonsprite = nil
					@heldmon = nil
					if @heldog[0]#was from party, so i'm simply gonna reorder it after i move it
						@sprites["partybox"].party[@heldog[1]] = @heldmon
						@sprites["partybox"].shuffleParty
						#now i reorder the icons
						@sprites["partybox"].reorderIcons
						4.times do 
							Graphics.update
							@sprites["partybox"].pokemons.each{|p| p.update if defined?(p.update)}
						end
					else
						if @storage.currentBox == @heldog[1]
							@sprites["box"].currentbox[@heldog[2]] = @heldmon
						else
							echoln @heldog[1]
							@sprites["box"].box[@heldog[1]][@heldog[2]]= @heldmon
						end
						@sprites["partybox"].shuffleParty
						#now i reorder the icons
						@sprites["partybox"].reorderIcons
						4.times do 
							Graphics.update
							@sprites["partybox"].pokemons.each{|p| p.update if defined?(p.update)}
						end
					end
				end
			end
		else #grab
			if @selIndex>=0 && @selIndex<=15 #cursor over boxes
				@heldmonsprite = @sprites["box"].pokemons[@selIndex]
				@heldmonsprite.z = 12
				@heldmon = @sprites["box"].currentbox[@selIndex]
				@heldog = [false,@storage.currentBox,@selIndex]
				@sprites["box"].pokemons[@selIndex]=EAMSprite.new(@viewport)
				@sprites["box"].pokemons[@selIndex].x = @heldmonsprite.x
				@sprites["box"].pokemons[@selIndex].y = @heldmonsprite.y
			else #cursor over party
				@heldmonsprite = @sprites["partybox"].pokemons[@selIndex-16]
				@heldmonsprite.z = 12
				@heldmon = @sprites["partybox"].party[@selIndex-16]
				@heldog = [true,@selIndex-16,-1]
				@sprites["partybox"].pokemons[@selIndex-16]=EAMSprite.new(@viewport)
				@sprites["partybox"].pokemons[@selIndex-16].x = @heldmonsprite.x
				@sprites["partybox"].pokemons[@selIndex-16].y = @heldmonsprite.y
			end
		end
		drawLowerBarText()
	end
	
	#checks if the party without the given Pokémon is still eligible (not all fainted, not 0 pokèmon)
	def checkParty(pkmn)
		ret = false
		for i in @sprites["partybox"].party
			next if i==pkmn
			next if i==nil
			next if i.isEgg?
			if i.hp>0 #this implies that there's at least one more with >0 hp
				ret = true
			end
		end
		return ret
	end

	#checks if the party with the given Pokémon is still eligible (not all fainted, not 0 pokèmon)
	def checkSwitchedParty(pkmn,ignore)
		ret = false
		for i in @sprites["partybox"].party
			next if i==ignore
			next if i==nil
			next if i.isEgg?
			if i.hp>0 #this implies that there's at least one more with >0 hp
				ret = true
			end
		end
		echoln "Ret is #{ret}"
		if pkmn.hp>0 && !pkmn.isEgg?
			ret=true
		end
		return ret
	end
	
	def openActions(pkmn)
		@s = {}
		@s["bg"] = EAMSprite.new(@viewport)
		@s["bg"].z = 50
		@s["bg"].bitmap = pbBitmap(BOX_PATH + "ActionsBG")
		@s["bg"].opacity = 0
		@s["bar"] = EAMSprite.new(@viewport)
		@s["bar"].z = 51
		@s["bar"].bitmap = pbBitmap(BOX_PATH + "ActionsBar").clone
		@s["bar"].y = 343
		@s["bar"].opacity = 0
		
		@s["bar"].bitmap.font = Font.new
		@s["bar"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@s["bar"].bitmap.font.size = $MKXP ? 16 : 18
		
		pbDrawTextPositions(@s["bar"].bitmap,[[pkmn.name,10,10,0,Color.new(248,248,248),Color.new(124,124,124),true],
				[sprintf("Lv.%3d",pkmn.level),150,10,0,Color.new(248,248,248),Color.new(124,124,124),true]])
		
		@s["bar"].bitmap.font = BOX_LB
		pbDrawTextPositions(@s["bar"].bitmap,[[_INTL("Back"),474,5,1,Color.new(48,48,48)]])
		
		@s["marks"] = EAMSprite.new(@viewport)
		@s["marks"].bitmap = Bitmap.new(@s["bar"].bitmap.width,@s["bar"].bitmap.height)
		@s["marks"].z = 51
		@s["marks"].y = 342
		
		drawMarks(pkmn,@s["marks"].bitmap)
		
		if !pkmn.isEgg?
			last = ""
			if pkmn.isDelta?
				last = "d"
			else
				last = (pkmn.form>0 ? "_#{pkmn.form}" : "")
			end
			add=""
			add = "Female/" if pkmn.gender==1 && pbResolveBitmap("Graphics/Battlers/Front/Female/"+sprintf("%03d",pkmn.species)+last)
			@pokemonBitmap = pbBitmap((pkmn.isShiny? ? "Graphics/Battlers/FrontShiny/" : "Graphics/Battlers/Front/")+add+sprintf("%03d",pkmn.species) + last )
			@frameskip = 0
			@frame = 0
			@framecount = @pokemonBitmap.width/@pokemonBitmap.height
			
			@actualBitmap = Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height)
			@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(0,@pokemonBitmap.height*@frame,@pokemonBitmap.height,@pokemonBitmap.height+2))
			#@actualBitmap = @actualBitmap.clone
			#@actualBitmap.fill_rect(0,0,30,30,Color.new(255,0,0))
			if !$MKXP
				@actualBitmap.add_outline(Color.new(248,248,248),1)
			end
		else
			@frameskip = 0
			@frame = 0
			@framecount = 1
			@pokemonBitmap = pbBitmap("Graphics/Battlers/egg")
			@actualBitmap = Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height)
			@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(0,0,@pokemonBitmap.height,@pokemonBitmap.height+2))
			if !$MKXP
				@actualBitmap.add_outline(Color.new(248,248,248),1)
			end
		end
		@s["sprite"]=EAMSprite.new(@viewport)
		@s["sprite"].bitmap = @actualBitmap
		if $MKXP 
			@s["sprite"].add_outline(Color.new(248,248,248),@frame)
		end
		@s["sprite"].ox = @pokemonBitmap.height/2
		@s["sprite"].z = 51
		@s["sprite"].oy = pbGetSpriteBase(@pokemonBitmap)+1
		@s["sprite"].zoom_x = 2
		@s["sprite"].zoom_y = 2
		if pkmn.isEgg?
			@s["sprite"].zoom_x = 1
			@s["sprite"].zoom_y = 1
		end
		@s["sprite"].x = 111
		@s["sprite"].y = 321
		@s["sprite"].opacity = 0
		@index = 0
		#ac = action, sac = selected action
		for i in 0...5
			@s["ac#{i}"]=EAMSprite.new(@viewport)
			@s["sac#{i}"]=EAMSprite.new(@viewport)
			@s["ac#{i}"].bitmap=@acunsel[i]
			@s["sac#{i}"].bitmap=@acsel[i]
			@s["ac#{i}"].x = @s["sac#{i}"].x = 358
			@s["ac#{i}"].y = @s["sac#{i}"].y = 217 + i*24
			@s["ac#{i}"].z = @s["sac#{i}"].z = 52
			if @index == i
				@s["ac#{i}"].opacity = 0
				@s["sac#{i}"].opacity = 0#255
			else
				@s["ac#{i}"].opacity = 0#255
				@s["sac#{i}"].opacity = 0
			end
			if @index==i
				@s["sac#{i}"].fade(255,6)
			else
				@s["ac#{i}"].fade(255,6)
			end
		end
		@s.each_key {|k| @s[k].fade(255,6) if defined?(@s[k].fade) && !k.include?("ac") && !k.include?("sac")}
		
		
		loop do 
			Graphics.update
			Input.update
			actionsUpdate(@index)
			@s.values.each{|s| s.update if defined?(s.update)}
			
			if Input.trigger?(Input::DOWN)
				@index = @index+1>4 ? 0 : @index+1
				for i in 0...5
					if @index == i
						@s["ac#{i}"].fade(0,6)
						@s["sac#{i}"].fade(255,6)
					else
						@s["ac#{i}"].fade(255,6)
						@s["sac#{i}"].fade(0,6)
					end
				end
			elsif Input.trigger?(Input::UP)
				@index = @index-1<0 ? 4 : @index-1
				for i in 0...5
					if @index == i
						@s["ac#{i}"].fade(0,6)
						@s["sac#{i}"].fade(255,6)
					else
						@s["ac#{i}"].fade(255,6)
						@s["sac#{i}"].fade(0,6)
					end
				end
			end
			
			if Input.trigger?(Input::C)
				if @index==0
					fadeOut(@s) {actionsUpdate(@index)}
					pbDisposeSpriteHash(@s)
					handleCursor
					break
				elsif @index==1
					#fadeOut(@s) {actionsUpdate(@index)}
					#pbDisposeSpriteHash(@s)
					merged = @sprites.merge(@s)
					oldsprites=pbFadeOutAndHide(merged)
					scene=PokemonSummaryScene.new
					screen=PokemonSummary.new(scene)
         			if @selIndex<=15
            			@selection=screen.pbStartScreen(@storage.boxes[@storage.currentBox],@selIndex)
					else
						@selection=screen.pbStartScreen($Trainer.party,@selIndex-16)
					end
          #pbSetArrow(@sprites["arrow"],@selection)
					#pbUpdateOverlay(@selection)
					pbFadeInAndShow(merged,oldsprites)
					#handleCursor
					#break
				elsif @index == 2
					ht= ""
					cmds=[]
					if pkmn.item>0 #has an item
						ht = _INTL("What to do with {1}?",PBItems.getName(pkmn.item))
						cmds=[_INTL("Take"),_INTL("Give"),_INTL("Back")]
					else
						ht = _INTL("Want to give {1} an item?",pkmn.name)
						cmds=[_INTL("Give"),_INTL("Back")]
					end
					ch = showCommands(ht,cmds)
					if ch == cmds.length-1
						next
					else
						if pkmn.item>0
							if ch==0 #Take
								if !pkmn.hasItem?
									Kernel.pbMessage(_INTL("{1} isn't holding anything.",pkmn.name))
								elsif !$PokemonBag.pbCanStore?(pkmn.item)
									Kernel.pbMessage("Your bag is full, you couldn't take the item from your Pokémon.")
								else
									$PokemonBag.pbStoreItem(pkmn.item)
									itemname=PBItems.getName(pkmn.item)
									Kernel.pbMessage(_INTL("You took {1} from {2}.",itemname,pkmn.name))
									pkmn.setItem(0)
								end
								#now i need to update the icon
								if @selIndex>=0 && @selIndex<=15 #i'm over the box
									id = @sprites["box"].box[@storage.currentBox].pokemon.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["box"].pokemons[id].z
										@sprites["box"].pokemons[id].setItem(pkmn.item)
										@sprites["box"].pokemons[id].z = oldz
									end
								else #i'm over the party
									id = @sprites["partybox"].party.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["partybox"].pokemons[id].z
										@sprites["partybox"].pokemons[id].setItem(pkmn.item)
										@sprites["partybox"].pokemons[id].z = oldz
									end
								end
								next
							else #it can just be give now
								ret = giveItem(pkmn)
								next if !ret 
								#now i need to update the icon
								if @selIndex>=0 && @selIndex<=15 #i'm over the box
									id = @sprites["box"].box[@storage.currentBox].pokemon.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["box"].pokemons[id].z
										@sprites["box"].pokemons[id].setItem(pkmn.item)
										@sprites["box"].pokemons[id].z = oldz
									end
								else #i'm over the party
									id = @sprites["partybox"].party.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["partybox"].pokemons[id].z
										@sprites["partybox"].pokemons[id].setItem(pkmn.item)
										@sprites["partybox"].pokemons[id].z = oldz
									end
								end
								next
							end
						else
							if ch==0
								ret = giveItem(pkmn)
								next if !ret 
								#now i need to update the icon
								if @selIndex>=0 && @selIndex<=15 #i'm over the box
									id = @sprites["box"].box[@storage.currentBox].pokemon.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["box"].pokemons[id].z
										@sprites["box"].pokemons[id].setItem(pkmn.item)
										@sprites["box"].pokemons[id].z = oldz
									end
								else #i'm over the party
									id = @sprites["partybox"].party.index(pkmn)
									if @heldmon == pkmn
										oldz = @heldmonsprite.z
										@heldmonsprite.setItem(pkmn.item)
										@heldmonsprite.z = oldz
									else
										oldz = @sprites["partybox"].pokemons[id].z
										@sprites["partybox"].pokemons[id].setItem(pkmn.item)
										@sprites["partybox"].pokemons[id].z = oldz
									end
								end
								next
							end
						end
					end
				elsif @index == 3
					setMarkings(pkmn)
					next
				elsif @index == 4 #release
					ret = release(pkmn)
					if ret
						fadeOut(@s) {actionsUpdate(@index)}
						pbDisposeSpriteHash(@s)
						pkmnname=pkmn.name
						#@storage.pbDelete(box,index)
						if @selIndex>=0 && @selIndex<=15 #box pokemon
							held = @heldmon == @sprites["box"].currentbox[@selIndex]
							@sprites["box"].currentbox[@selIndex]=nil
							oldc = [@sprites["box"].pokemons[@selIndex].x,@sprites["box"].pokemons[@selIndex].y,@sprites["box"].pokemons[@selIndex].z]
							if !held
								@sprites["box"].pokemons[@selIndex].setZoomPoint(37,37)
								@sprites["box"].pokemons[@selIndex].zoom(0,0,10)
								10.times do
									Graphics.update
									@sprites["box"].pokemons[@selIndex].update
								end
								@sprites["box"].pokemons[@selIndex] = EAMSprite.new(@viewport)
								@sprites["box"].pokemons[@selIndex].x = oldc[0]
								@sprites["box"].pokemons[@selIndex].y = oldc[1]
								@sprites["box"].pokemons[@selIndex].z = oldc[2]
							else
								@heldmon = nil
								@heldmonsprite.setZoomPoint(37,37)
								@heldmonsprite.zoom(0,0,10)
								10.times do
									Graphics.update
									@heldmonsprite.update
								end
								@heldmonsprite.dispose
								@heldmonsprite = nil
							end
						else #party pokemon
							held = @heldmon == @sprites["partybox"].party[@selIndex-16]
							@sprites["partybox"].party[@selIndex-16] = nil
							oldc = [@sprites["partybox"].pokemons[@selIndex-16].x,@sprites["partybox"].pokemons[@selIndex-16].y,@sprites["partybox"].pokemons[@selIndex-16].z]
							if !held
								@sprites["partybox"].pokemons[@selIndex-16].setZoomPoint(37,37)
								@sprites["partybox"].pokemons[@selIndex-16].zoom(0,0,10)
								10.times do
									Graphics.update
									@sprites["partybox"].pokemons[@selIndex-16].update
								end
								@sprites["partybox"].pokemons[@selIndex-16] = EAMSprite.new(@viewport)
								@sprites["partybox"].pokemons[@selIndex-16].x = oldc[0]
								@sprites["partybox"].pokemons[@selIndex-16].y = oldc[1]
								@sprites["partybox"].pokemons[@selIndex-16].z = oldc[2]
							else
								@heldmon = nil
								@heldmonsprite.setZoomPoint(37,37)
								@heldmonsprite.zoom(0,0,10)
								10.times do
									Graphics.update
									@heldmonsprite.update
								end
								@heldmonsprite.dispose
								@heldmonsprite = nil
							end
							@sprites["partybox"].shuffleParty
							#now i reorder the icons
							@sprites["partybox"].reorderIcons
							4.times do 
								Graphics.update
								@sprites["partybox"].pokemons.each{|p| p.update if defined?(p.update)}
							end
						end
						
						Kernel.pbMessage(_INTL("{1} was released.",pkmnname))
						Kernel.pbMessage(_INTL("Bye-bye, {1}!",pkmnname))
						break
					end
					next
				end
			end
			
			if Input.trigger?(Input::B)
				fadeOut(@s) {actionsUpdate(@index)}
				pbDisposeSpriteHash(@s)
				break
			end
		end
	end
	
	def release(pokemon)
    if [PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::SHYLEON].include?(pokemon.species)
      Kernel.pbMessage(_INTL("You're too attached to this Pokémon to free it."))
      return false
    end
		if [PBSpecies::DIELEBI,PBSpecies::HOOH,PBSpecies::LUGIA,PBSpecies::SABOLT].include?(pokemon.species)
			Kernel.pbMessage(_INTL("You can't release this Pokémon."))
      return false
    end
    if pokemon.isEgg?
      Kernel.pbMessage(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      Kernel.pbMessage(_INTL("Please remove the mail."))
      return false
    end
    if @selIndex>15 && !checkParty(pokemon)
      Kernel.pbMessage(_INTL("That's your last Pokémon!"))
      return false
    end
    command=showCommands(_INTL("Release this Pokémon?"),[_INTL("No"),_INTL("Yes")])
    return command==1
  end
	
	def pbChooseItem(bag)
		merged = @sprites.merge(@s)
    oldsprites=pbFadeOutAndHide(merged)
    scene=PokemonBag_Scene.new
    screen=PokemonBagScreen.new(scene,bag)
    ret=screen.pbGiveItemScreen
    pbFadeInAndShow(merged,oldsprites)
    return ret
  end
	
	def giveItem(pkmn)
		item=pbChooseItem($PokemonBag)
		thisitemname = PBItems.getName(item)
		return false if item<=0
		if pkmn.isEgg?
			Kernel.pbMessage(_INTL("Eggs can't hold items."))
			return false
		elsif pkmn.item!=0
			itemname=PBItems.getName(pkmn.item)
			Kernel.pbMessage(_INTL("{1} is already holding one {2}.\1",pkmn.name,itemname))
			if Kernel.pbConfirmMessage(_INTL("Would you like to switch the two items?"))
				$PokemonBag.pbDeleteItem(item)
				if !$PokemonBag.pbStoreItem(pkmn.item)
					if !$PokemonBag.pbStoreItem(item) # Compensate
						raise _INTL("Can't re-store deleted item in bag")
					end
					Kernel.pbMessage(_INTL("The Bag is full.  The Pokémon's item could not be removed."))
					return false
				else
					pkmn.setItem(item)
					Kernel.pbMessage(_INTL("The {1} was taken and replaced with the {2}.",itemname,thisitemname))
				end
			end
		else
			if !pbIsMail?(item) || pbMailScreen(item,pkmn,pkmnid) # Open the mail screen if necessary
				$PokemonBag.pbDeleteItem(item)
				pkmn.setItem(item)
				Kernel.pbMessage(_INTL("A {1} viene dato {2} da tenere.",pkmn.name,thisitemname))
			end
		end
		return true
	end
	
	def drawMarks(pkmn,bitmap,x=222,y=9)
		bitmap.clear
		sel = pbBitmap("Graphics/Pictures/SummaryNew/marks_sel")
		unsel = pbBitmap("Graphics/Pictures/SummaryNew/marks_unsel")
		marks=[]
		for i in 0...PokemonStorage::MARKINGCHARS.length
			marks.push((pkmn.markings&(1<<i))!=0)
		end
		
		startx = x
		for i in 0...marks.length
			if marks[i]
				bitmap.blt(startx+21*i,y,sel,Rect.new(21*i,0,21,18))
			else
				bitmap.blt(startx+21*i,y,unsel,Rect.new(21*i,0,21,18))
			end
		end
		
	end
	
	def showCommands(helptext,commands)
		path = "Graphics/Pictures/BagNew/"
		@c = {}
		@c["dark"]=EAMSprite.new(@viewport)
		@c["dark"].opacity = 0
		@c["dark"].bitmap = pbBitmap("Graphics/Pictures/PartyNew/Gradient")
		@c["dark"].y = 384-@c["dark"].bitmap.height
		@c["dark"].fade(160,10)
		@c["dark"].z = 150
		@c["box"] = EAMSprite.new(@viewport)
		@c["box"].z = 151
		@c["box"].bitmap = pbBitmap(path + "SelectBox").clone
		@c["box"].bitmap.font = SUMMARYITEMFONT
		@c["box"].bitmap.font.size = $MKXP ? 22 : 24
		anchor = 496
		@cmdid = 0
		for cmd in 0...commands.length
			@c["#{cmd}"] = EAMSprite.new(@viewport)
			@c["#{cmd}"].bitmap = pbBitmap(path + "SCOption").clone
			@c["#{cmd}"].ox = @c["#{cmd}"].bitmap.width
			@c["#{cmd}"].x = anchor
			@c["#{cmd}"].y = 270 - 38*(commands.length-1) + 38*cmd
			@c["#{cmd}"].bitmap.font = SUMMARYITEMFONT
			@c["#{cmd}"].bitmap.font.size = $MKXP ? 22 : 24
			@c["#{cmd}"].z = 152
			pbDrawTextPositions(@c["#{cmd}"].bitmap,[[commands[cmd],74,6,2,Color.new(24,24,24)]])
			
			@c["#{cmd}"].fade(175,10) if cmd != @cmdid
		end
		drawTextExH(@c["box"].bitmap,45,314,434,2,helptext,Color.new(24,24,24),Color.new(24,24,24,0),22)
		
		loop do 
			Graphics.update
			Input.update
			@c.values.each {|s| s.update if defined?(s.update)}
			#cmdUpdate
			
			if Input.trigger?(Input::DOWN)
				@c["#{@cmdid}"].fade(175,10)
				@cmdid = @cmdid+1>=commands.length ? 0 : @cmdid+1
				@c["#{@cmdid}"].fade(255,10)
			elsif Input.trigger?(Input::UP)
				@c["#{@cmdid}"].fade(175,10)
				@cmdid = @cmdid-1<0 ? commands.length-1 : @cmdid-1
				@c["#{@cmdid}"].fade(255,10)
			end
			
			
			
			if Input.trigger?(Input::C)
				#pbFadeOutAndHide(@s){cmdUpdate}
				fadeOut(@c)
				pbDisposeSpriteHash(@c)
				
				return @cmdid
			end
			if Input.trigger?(Input::B)
				#pbFadeOutAndHide(@s){cmdUpdate}
				fadeOut(@c)
				pbDisposeSpriteHash(@c)
				
				return commands.length-1
			end
		end
		
		
	end
	
	def actionsUpdate(id)
		@frameskip +=1
		@frame+=1 if @frameskip ==1
		@frameskip = 0 if @frameskip == 2
		@frame = 0 if @frame>=@framecount
		
		@actualBitmap.clear
		@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height))
		@actualBitmap.add_outline(Color.new(248,248,248),1) if !$MKXP
		@s["sprite"].bitmap = @actualBitmap if @s["sprite"] && @actualBitmap
		if $MKXP 
			@s["sprite"].add_outline(Color.new(248,248,248),@frame)
		end
	end
	
	def jump(target)
		return if target==@storage.currentBox #stop if it's the same box
		if target>@storage.currentBox #slide to left
			@storage.currentBox = target
			nextbox = NewBox.new(@viewport,@storage,@storage.currentBox,@heldmon)
			nextbox.x = 16+300
			nextbox.y = 48
			nextbox.opacity = 0
			nextbox.move(16,48,10,:ease_out_cubic)
			nextbox.fade(255,10,:ease_out_cubic)
			@sprites["box"].move(16-300,48,10,:ease_out_cubic)
			@sprites["box"].fade(0,10,:ease_out_cubic)
		else #slide to right
			@storage.currentBox = target
			nextbox = NewBox.new(@viewport,@storage,@storage.currentBox,@heldmon)
			nextbox.x = 16-300
			nextbox.y = 48
			nextbox.opacity = 0
			nextbox.move(16,48,10,:ease_out_cubic)
			nextbox.fade(255,10,:ease_out_cubic)
			@sprites["box"].move(16+300,48,10,:ease_out_cubic)
			@sprites["box"].fade(0,10,:ease_out_cubic)
		end 
		10.times do
			Graphics.update
			Input.update
			nextbox.update
			@sprites["box"].update
		end
		@sprites["box"].dispose
		@sprites["box"] = nextbox
		updateBoxName()
	end
	
	def switchToLeft
		nxt = @storage.currentBox-1<0 ? @storage.maxBoxes-1 : @storage.currentBox-1
		@storage.currentBox = nxt
		nextbox = NewBox.new(@viewport,@storage,@storage.currentBox,@heldmon)
		nextbox.x = 16-300
		nextbox.y = 48
		nextbox.opacity = 0
		nextbox.move(16,48,10,:ease_out_cubic)
		nextbox.fade(255,10,:ease_out_cubic)
		@sprites["box"].move(16+300,48,10,:ease_out_cubic)
		@sprites["box"].fade(0,10,:ease_out_cubic)
		10.times do
			Graphics.update
			Input.update
			nextbox.update
			@sprites["box"].update
		end
		@sprites["box"].dispose
		@sprites["box"] = nextbox
		updateBoxName()
	end
	
	def switchToRight
		nxt = @storage.currentBox+1>=@storage.maxBoxes ? 0 : @storage.currentBox+1
		@storage.currentBox = nxt
		nextbox = NewBox.new(@viewport,@storage,@storage.currentBox,@heldmon)
		nextbox.x = 16+300
		nextbox.y = 48
		nextbox.opacity = 0
		nextbox.move(16,48,10,:ease_out_cubic)
		nextbox.fade(255,10,:ease_out_cubic)
		@sprites["box"].move(16-300,48,10,:ease_out_cubic)
		@sprites["box"].fade(0,10,:ease_out_cubic)
		10.times do
			Graphics.update
			Input.update
			nextbox.update
			@sprites["box"].update
		end
		@sprites["box"].dispose
		@sprites["box"] = nextbox
		updateBoxName()
	end
	
	
	def fadeOut(s)
		if s
			for cmd in s.values
				cmd.fade(0,15) if defined?(cmd.fade)
			end
			15.times do
				for cmd in s.values
					cmd.update
				end
				yield if block_given?
				Graphics.update
			end
		end
	end
	
	def chooseNumber(helptext,qty,minqt=0,cancel=0)
		@s={}
		
		anchor = 496
		
		path = "Graphics/Pictures/BagNew/"
		
		@s["box"] = EAMSprite.new(@viewport)
		@s["box"].z = 100
		@s["box"].bitmap = pbBitmap(path + "SelectBox").clone
		@s["box"].bitmap.font = SUMMARYITEMFONT
		@s["box"].bitmap.font.size = $MKXP ? 22 : 24
		@s["box"].opacity = 0
		
		drawTextExH(@s["box"].bitmap,45,314,434,2,helptext,Color.new(24,24,24),Color.new(24,24,24,0),22)
		maxqty = qty
		minqty = minqt
		qt = minqty
		bmp = pbBitmap(path + "qtyoption")
		bmp.font = SUMMARYITEMFONT
		bmp.font.size = $MKXP ? 24 : 26
		@s["qtbg"] = EAMSprite.new(@viewport)
		@s["qtbg"].bitmap = bmp.clone
		@s["qtbg"].ox = @s["qtbg"].bitmap.width
		@s["qtbg"].x = anchor
		@s["qtbg"].y = 266
		@s["qtbg"].z = 102
		@s["qtbg"].opacity = 0
		pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,5,1,Color.new(24,24,24)]])
		
		@s["box"].fade(255,6)
		@s["qtbg"].fade(255,6)
		6.times do
			Graphics.update
			Input.update
			@s["box"].update
			@s["qtbg"].update
		end
		loop do
			Graphics.update
			Input.update
			@s.values.each {|s| s.update}
			@s["qtbg"].move(anchor,266,7,:ease_out_quad) if @s["qtbg"].y <= 256
			
			if Input.trigger?(Input::UP)
				qt = qt+1 > maxqty ? minqty : qt+1
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::DOWN)
				qt = qt-1 < minqty ? maxqty : qt-1
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::L)
				qt = qt-10 < minqty ? maxqty : qt-10
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::R)
				qt = qt+10 > maxqty ? minqty : qt+10
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			end
			
			if Input.trigger?(Input::C)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return qt
			end
			if Input.trigger?(Input::B)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return cancel
			end
		end
		
	end
	
	def setMarkings(pkmn)		
		@m={}
		
		anchor = 496
		
		path = "Graphics/Pictures/BagNew/"
		
		@m["box"] = EAMSprite.new(@viewport)
		@m["box"].z = 100
		@m["box"].bitmap = pbBitmap(path + "SelectBox").clone
		@m["box"].bitmap.font = SUMMARYITEMFONT
		@m["box"].bitmap.font.size = $MKXP ? 22 : 24
		@m["box"].opacity = 0
		
		drawTextExH(@m["box"].bitmap,45,314,434,2,_INTL("Choose the Pokémon marks."),Color.new(24,24,24),Color.new(24,24,24,0),22)
		bmp = pbBitmap(path + "SCOption")
		bmp.font = SUMMARYITEMFONT
		bmp.font.size = $MKXP ? 24 : 26
		@m["mbg"] = EAMSprite.new(@viewport)
		@m["mbg"].bitmap = Bitmap.new(168,38)
		@m["mbg"].bitmap.blt(0,0,bmp,Rect.new(0,0,22,38))
		@m["mbg"].bitmap.blt(168-22,0,bmp,Rect.new(148-22,0,22,38))
		@m["mbg"].bitmap.blt(22,0,bmp,Rect.new(22,0,62,38))
		@m["mbg"].bitmap.blt(84,0,bmp,Rect.new(22,0,62,38))
		@m["mbg"].ox = @m["mbg"].bitmap.width
		@m["mbg"].x = anchor
		@m["mbg"].y = 246
		@m["mbg"].z = 102
		@m["mbg"].opacity = 0
		@m["marks"]=EAMSprite.new(@viewport)
		@m["marks"].bitmap = Bitmap.new(@m["mbg"].bitmap.width,@m["mbg"].bitmap.height)
		@m["marks"].x = anchor
		@m["marks"].ox = @m["mbg"].ox
		@m["marks"].y = 246
		@m["marks"].z = 102
		@m["marks"].opacity = 0
		
		@m["cursor"]=EAMSprite.new(@viewport)
		@m["cursor"].bitmap = pbBitmap(BOX_PATH + "markCursor")
		@m["cursor"].y = @m["mbg"].y - 14
		@m["cursor"].x = 348
		@m["cursor"].z = 102
		drawMarks(pkmn,@m["marks"].bitmap,18,10)
		#pbDrawTextPositions(@s["qtbg"].bitmap,[[sprintf("%03d",qt),130,5,1,Color.new(24,24,24)]])
		
		@m["box"].fade(255,6)
		@m["mbg"].fade(255,6)
		@m["marks"].fade(255,6)
		6.times do
			Graphics.update
			Input.update
			@m["box"].update
			@m["mbg"].update
			@m["marks"].update
		end
		id = 0
		loop do
			Graphics.update
			Input.update
			@m.values.each {|s| s.update}
			if Input.trigger?(Input::RIGHT)
				id = id+1>5 ? 0 : id+1
				@m["cursor"].move(348+22*id,@m["mbg"].y - 14,6,:ease_out_cubic)
			elsif Input.trigger?(Input::LEFT)
				id = id-1<0 ? 5 : id-1
				@m["cursor"].move(348+22*id,@m["mbg"].y - 14,6,:ease_out_cubic)
			end
			
			if Input.trigger?(Input::UP)||Input.trigger?(Input::DOWN)
				mask=(1<<id)
				if (pkmn.markings&mask)==0
					pkmn.markings|=mask
				else
					pkmn.markings&=~mask
				end
				drawMarks(pkmn,@m["marks"].bitmap,18,10)
			end
			
			if Input.trigger?(Input::B)
				fadeOut(@m)
				pbDisposeSpriteHash(@m)
				break
			end
		end
		drawMarks(pkmn,@s["marks"].bitmap)
	end
	
	def endscene
		newpt=[]
		for p in @sprites["partybox"].party
			if p != nil
				newpt.push(p)
			end
		end
		$Trainer.party=newpt
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		Graphics.frame_rate = @oldfr
		@viewport.dispose
	end
	
end

class NewBox < EAMSprite
	attr_accessor(:pokemons)
	attr_accessor(:currentbox)
	attr_accessor(:box)
	
	def initialize(viewport,box,idbox,heldmon = nil)
		super(viewport)
		@box = box
		@currentbox = @box[idbox]
		@pokemons = []
		self.bitmap = pbBitmap(BOX_PATH + "squarebg")
		addPokemonIcons(heldmon)
	end
	
	def box
		return @box
	end
	
	#alias _oupdate update unless defined?(self._oupdate)
	def update
		super
		for i in @pokemons
			i.update if defined?(i.update)
		end
	end
	
	def addPokemonIcons(heldmon=nil)
		for i in 0...@currentbox.length
			pokemon = @currentbox[i]
			if pokemon && pokemon != heldmon
				@pokemons[i]=PCPIcon.new(viewport)
				@pokemons[i].bitmap = evaluateIcon(pokemon)
				@pokemons[i].setItem(pokemon.item)
			else
				@pokemons[i]=EAMSprite.new(viewport)
			end
		end
		repositionIcons
	end
	
	def repositionIcons
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].x =self.x+6+(i%4)*71
				@pokemons[i].y =self.y+6+(i/4)*71
			end
		end
	end
	
	def x=(value)
		super(value)
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].x =self.x+6+(i%4)*71
			end
		end
	end
	
	def y=(value)
		super(value)
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].y =self.y+6+(i/4)*71
			end
		end
	end
	
	def dispose
		super
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].dispose
			end
		end
	end
	
	def color=(value)
		super(value)
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].color = value
			end
		end
	end
	
	def opacity=(value)
		super(value)
		for i in 0...@currentbox.length
			if @pokemons[i]
				@pokemons[i].opacity = value
			end
		end
	end	
	
	def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
    if pokemon.isEgg?
			bmp = "Graphics/Pictures/DexNew/Icon/Egg"
			bitmap = pbBitmap(bmp).clone
			return bitmap
		end
		bmp =""
		bmp += "Graphics/Pictures/DexNew/Icon/#{pokemon.species}"
		if pokemon.gender==1 && pbResolveBitmap(bmp+"f")
			bmp+="f"
		end
		if pokemon.form>0
			if pokemon.isDelta?
				bmp+="d"
			else
				bmp+="_#{pokemon.form}"
			end
		end
    if pokemon.isDelta?
      bmp+="d"
    end
		bitmap = pbBitmap(bmp).clone
		echoln pokemon.item
		if pokemon.isShiny?#item>0
			bitmap.blt(0,0,pbBitmap(BOX_PATH + "shiny"),Rect.new(0,0,31,29))
		end
		return bitmap
	end
end

class PCPIcon < EAMSprite
	
	def initialize(*args)
		super(*args)
		@item = EAMSprite.new(args[0])
		@item.bitmap = pbBitmap(BOX_PATH + "item_icon")
		@item.x = self.x + 44
		@item.y = self.y + 44
		@item.z = 50
		@item.visible=false
	end
	
	def setItem(item)
		if item>0
			@item.visible=true
		else
			@item.visible=false
		end
	end
	
	def x=(value)
		super(value)
		@item.x=value + 44
	end
	
	def y=(value)
		super(value)
		@item.y=value + 44
	end
	
	def color=(value)
		super(value)
		@item.color=value
	end
	
	def opacity=(value)
		super(value)
		@item.opacity=value
	end
	
	def zoom_x=(value)
		super(value)
		@item.zoom_x=value
	end
	
	def zoom_y=(value)
		super(value)
		@item.zoom_y=value
	end
	
end

class PartyBox < EAMSprite
	attr_accessor(:pokemons)
	attr_accessor(:party)
	
	def initialize(viewport,party)
		super(viewport)
		@party = party
		@pokemons = []
		self.bitmap = pbBitmap(BOX_PATH + "partybg")
		addPokemonIcons
	end
	
	def addToParty(pokemon)
		for i in 0...6
			if @party[i]==nil
				@party[i]=pokemon
				break
			end
		end
		return i
	end
	
	def shuffleParty
		for i in 0...6
			if @party[i]==nil
				j=i
				while j<5
					j+=1
					break if @party[j]!=nil
				end
				if @party[j]!=nil
					@party[i] = @party[j]
					@party[j] = nil
				end
			end
			if @pokemons[i].bitmap == nil
				k=i
				while k<5
					k+=1
					break if @pokemons[k].bitmap != nil
				end
				if @pokemons[k].bitmap != nil
					tmp = @pokemons[i]
					@pokemons[i] = @pokemons[k]
					@pokemons[k] = tmp
				end
			end
		end
	end
	
	#alias _oupdate update unless defined?(self._oupdate)
	def update
		#_oupdate
		super
		for i in @pokemons
			i.update if defined?(i.update)
		end
	end
	
	def clearPokemonIcons
		for i in @pokemons
			i.dispose if i
			i = nil
		end
	end
	
	def addPokemonIcons
		for i in 0...6#@party.length
			pokemon = @party[i]
			if pokemon
				@pokemons[i]=PCPIcon.new(viewport)
				@pokemons[i].bitmap = evaluateIcon(pokemon)
				@pokemons[i].setItem(pokemon.item)
			else
				@pokemons[i]=EAMSprite.new(viewport)
			end
			@pokemons[i].z = self.z
		end
		#reorderIcons
	end
	
	def reorderIcons
		for i in 0...6#@party.length
			if @pokemons[i]
				@pokemons[i].move(self.x+1+(i%2)*73,self.y+1+(i/2)*71,4,:ease_out_cubic) if defined?(@pokemons[i].move)
				#@pokemons[i].x =
				#@pokemons[i].y =self.y+1+(i/2)*71
			end
		end
	end
	
	def x=(value)
		super(value)
		for i in 0...6#@party.length
			if @pokemons[i]
				@pokemons[i].x =self.x+1+(i%2)*73
			end
		end
	end
	
	def y=(value)
		super(value)
		for i in 0...6#@currentbox.length
			if @pokemons[i]
				@pokemons[i].y =self.y+1+(i/2)*71
			end
		end
	end
	
	def z=(value)
		super(value)
		for i in 0...6
			if @pokemons[i]
				@pokemons[i].z =value
			end
		end
	end
	
	def dispose
		super
		for i in 0...6
			if @pokemons[i]
				@pokemons[i].dispose
			end
		end
	end
	
	def color=(value)
		super(value)
		for i in 0...6
			if @pokemons[i]
				@pokemons[i].color = value
			end
		end
	end
	
	def opacity=(value)
		super(value)
		for i in 0...6
			if @pokemons[i]
				@pokemons[i].opacity = value
			end
		end
	end	
	
	def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
    if pokemon.isEgg?
			bmp = "Graphics/Pictures/DexNew/Icon/Egg"
			bitmap = pbBitmap(bmp).clone
			return bitmap
		end
		bmp =""
		bmp += "Graphics/Pictures/DexNew/Icon/#{pokemon.species}"
		if pokemon.gender==1 && pbResolveBitmap(bmp+"f")
			bmp+="f"
		end
		if pokemon.form>0
			if pokemon.isDelta?
				bmp+="d"
			else
				bmp+="_#{pokemon.form}"
			end
		end
    if pokemon.isDelta?
      bmp+="d"
    end
		bitmap = pbBitmap(bmp).clone
		if pokemon.isShiny?#item>0
			bitmap.blt(0,0,pbBitmap(BOX_PATH + "shiny"),Rect.new(0,0,31,29))
		end
		return bitmap
	end
	
end

def pbChooseSinglePokemon
	chosen = -1
    pbFadeOutIn(99999) {
      scene = PokemonScreen_Scene.new
      screen = PokemonScreen.new(scene, $Trainer.party)
      screen.pbStartScene(_INTL("Choose a Pokémon."), false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    }
    return chosen
end

def pbPokeCenterPC
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.",$Trainer.name))
  if $game_switches[1332] == true
	if $game_switches[4900] == false
		Kernel.pbMessage(_INTL("Paolo left a message."))
		Kernel.pbMessage(_INTL("Paolo: Hey, you! Look, we really want you to get into our new invention, so we decided to let you in on this SUPER\\wt[12]-TOP\\wt[12]-SECRET\\wt[12] invention!"))
		Kernel.pbMessage(_INTL("Paolo: It's called <b>Virtual Move Tutor</b> and trust me, it'll come in handy!"))
		Kernel.pbMessage(_INTL("Paolo: It analyzes the genetic data of any of your Pokémons and lets it learn any move it could be compatible with!"))
		Kernel.pbMessage(_INTL("Paolo: But only if it's not one that needs experience! You know, it's not an almighty tool!"))
		Kernel.pbMessage(_INTL("Paolo: By the way... It'll be a little pricey... But we can make some discounts for you if you get more famous..."))
		Kernel.pbMessage(_INTL("Paolo: ...so get more badges and the price just might drop!"))
		Kernel.pbMessage(_INTL("Paolo: I have to go now, there's another really important project that's waiting for me! See ya!"))
		$game_switches[4900] = true
	end
	choices = [_INTL("Usa Box"),_INTL("Virtual Move Tutor")]
	rt = pbNewChoice(Fullbox_Option.createFromArray(choices),-1)
	if rt > -1
		if rt == 0
			pbFadeOutIn(99999){
				NewPokemonStorage.new
			}
		else
			pokemon = pbChooseSinglePokemon
			if pokemon != -1
				if RETRODEX.include?($Trainer.party[pokemon].species)
					Kernel.pbMessage(_INTL("This Pokémon is not compatible with the Virtual Move Tutor!"))
				else
					pbTutorMoveScreen($Trainer.party[pokemon])
				end
			end
			
		end
	end
  else
	pbFadeOutIn(99999){
		NewPokemonStorage.new
	}
  end
  pbSEPlay("computerclose")
  $PokemonTemp.dependentEvents.refresh_sprite(true)
end