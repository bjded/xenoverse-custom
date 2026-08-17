class DexObtained
	
	def initialize(pkmn,female = false,register = true,dextype="PokeDex",wtd = true)
		#0 is italian, 1 is english
		@language = pbGetLanguage() == 4 ? 0 : 1
		@wtd = wtd
    	@pkmn = pkmn
    
		@species = species = pkmn.species
		
		@female = female && pbResolveBitmap("Graphics/Battlers/Front/Female/"+sprintf("%03d",@species.to_s))
		
		@descriptionPage = 0
		
		@refdex = ELDIWDEX.include?(@species) ? ELDIWDEX : (XENODEX.include?(species) ? XENODEX : (RETRODEX.include?(species) ? RETRODEX : pbAllRegionalSpecies(-1)))
		
		dextype = "XenoDex" if @refdex==XENODEX
		dextype = "RetroDex" if @refdex==RETRODEX
		
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 999999
		
		@viewport2 = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport2.z = 999999
		@viewport2.rect = Rect.new(0,0,512,0)
		@sprites = {}
		@sprites["bg"] = Sprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(Dex::PATH + dextype + "_bg")
		@sprites["abg"] = AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(Dex::PATH + "animbg")
		#@sprites["abg"].opacity = 0
		
		@sprites["nameBanner"] = Sprite.new(@viewport)
		@sprites["nameBanner"].bitmap = pbBitmap(Dex::PATH + dextype + "_namebar")
		@sprites["nameBanner"].y = 20
		@sprites["nameBanner"].x = 175
		@sprites["nameBanner"].z = 30
		@sprites["icon"] = Sprite.new(@viewport2)
		@sprites["icon"].x = 162
		@sprites["icon"].y = 5
		@sprites["icon"].z = 30
		
		@sprites["overbg"] = Sprite.new(@viewport)
		@sprites["overbg"].bitmap = pbBitmap(Dex::PATH + "Info_overlay")
		
		@sprites["flash"] = Sprite.new(@viewport2)
		@sprites["flash"].z = 99999
		@sprites["flash"].bitmap = Bitmap.new(512,384)
		@sprites["flash"].opacity = 0
		@sprites["flash"].bitmap.fill_rect(0,0,512,384,Color.new(255,255,255))
		
		
		
		@sprites["overlay"] = Sprite.new(@viewport2)
		@sprites["overlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		@sprites["overlay"].z = 31
		@texts = []
		#Pokemon sprite
		@sprites["sprite"] = EAMSprite.new(@viewport2)
		@sprites["sprite"].x = 137
		@sprites["sprite"].zoom_x = Dex::SPRITESIZE
		@sprites["sprite"].zoom_y = Dex::SPRITESIZE
		
		@sprites["type"] = Sprite.new(@viewport2)
		@sprites["type"].x = 334
		@sprites["type"].y = 118
		@sprites["type"].z = 31
		
    @formDescriptions = pbLoadFormInfos if @pkmn.form>0
    
		addPokemonInfo
		
		
		
		@sprites["fixedoverlay"] = Sprite.new(@viewport)
		@sprites["fixedoverlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		
		#Fixed pokemon info text
		texts = [[_INTL("Type"),264,116,0,Color.new(248,248,248)],
			[_INTL("Height"),264,141,0,Color.new(248,248,248)],
			[_INTL("Weight"),264,166,0,Color.new(248,248,248)],] 
		@sprites["fixedoverlay"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["fixedoverlay"].bitmap.font.size = Dex::TEXTFONTSIZE-1
		pbDrawTextPositions(@sprites["fixedoverlay"].bitmap,texts)		
		
		#USED FOR WHAT TO DO SCREEN
		
		@commands = []
		@commands.push("pc")
		if !pbSafariState.inProgress? && !$Trainer.inShinobiIsland?
			@commands.push("party")
		end
		@commands.push("nick")
		@commands.push("info")
		
		for i in 0..@commands.length-1
			@sprites["button#{i}"] = EAMSprite.new(@viewport)
			@sprites["button#{i}"].bitmap = pbBitmap(Dex::PATH + "CatchButton").clone
			@sprites["button#{i}"].ox = @sprites["button#{i}"].bitmap.width/5
			#@sprites["button#{i}"].x = 512/4 + 512/4 * i -(i==1 ? 0 : (i==0 ? 20 : -20))
			additionalx = 10
			additionalx = 50 if (i == 0)
			additionalx = -30 if (i == 3)
			@sprites["button#{i}"].x = @sprites["button#{i}"].bitmap.width*i + additionalx
			@sprites["button#{i}"].y = Graphics.height
			@sprites["button#{i}"].opacity = 0
			@sprites["button#{i}"].bitmap.font = Dex::STANDARDFONT
			#Texts
			if @commands[i] == "pc" # Send to PC
				pbDrawTextPositions(@sprites["button#{i}"].bitmap,[[_INTL("Send to PC"),68,12,2,Color.new(48,48,48)]])
			elsif @commands[i] == "party" # Add to Party
				pbDrawTextPositions(@sprites["button#{i}"].bitmap,[[_INTL("Add to Party"),68,12,2,Color.new(48,48,48)]])
			elsif @commands[i] == "nick" # Nickname
				pbDrawTextPositions(@sprites["button#{i}"].bitmap,[[_INTL("Nickname"),68,12,2,Color.new(48,48,48)]])
			elsif @commands[i] == "info" # Info
				pbDrawTextPositions(@sprites["button#{i}"].bitmap,[[_INTL("Info"),68,12,2,Color.new(48,48,48)]])
			end
		end
		
		#==========================
		
		if register
			self.inloop
		else
			@viewport2.rect=Rect.new(0,0,Graphics.width,Graphics.height)
			@sprites["nameBanner"].visible = false
			@sprites["overbg"].visible = false
			@sprites["overlay"].visible = false
			@sprites["fixedoverlay"].visible = false
			@sprites["type"].visible = false
			@sprites["icon"].visible = false
			@sprites["sprite"].move(Graphics.width/2,@sprites["sprite"].y,20,:ease_in_out_quad)
			20.times do
				@sprites["sprite"].update
				Graphics.update
				update
			end
			
			self.whatToDo
		end
	end
	
	def addPokemonInfo
		#updating sprite info
		@frame = 0
		@frameskip = 0
    st = (@pkmn.isShiny? ? "Graphics/Battlers/FrontShiny/" : "Graphics/Battlers/Front/")
		last = ""
		if !@pkmn.isDelta?
			last = (@pkmn.form>0 ? "_#{@pkmn.form}" : "") #if @forms.length>0
		end
		#last = "" if @forms[@formIndex].is_a?(String) && !@forms[@formIndex].include?("d")
		add = ""
		add = "Female/" if @pkmn.gender==1 && pbResolveBitmap("Graphics/Battlers/Front/Female/"+sprintf("%03d",@species.to_s) + last)
		if @pkmn.isDelta?
			last = (pbResolveBitmap(st+add+sprintf("%03d",@species.to_s) +"d") ? "d" : "")
    end
    @pokemonBitmap = pbBitmap(st+add+sprintf("%03d",@species.to_s) + last )
		
		@frameCount = @pokemonBitmap.width/@pokemonBitmap.height
		@sprites["sprite"].bitmap = $MKXP ? Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height) : @pokemonBitmap
		@sprites["sprite"].ox = @pokemonBitmap.height/2
		@sprites["sprite"].oy = getSpriteBase(@pokemonBitmap)
		@sprites["sprite"].y = 240
		if !$MKXP
			@sprites["sprite"].src_rect = Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height)
		else
			@sprites["sprite"].bitmap.clear
			@sprites["sprite"].bitmap.blt(0,0,@pokemonBitmap,Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height))
		end
		#updating icon info
		@sprites["icon"].bitmap = pbBitmap(Dex::PATH+"Icon/"+@species.to_s+last)
		@sprites["type"].bitmap.clear if @sprites["type"].bitmap
		if @refdex.index(@species)!=nil
			index = @refdex.index(@species)+1
		else
			index = -1
		end
   		formInfos = pbLoadFormInfos
    
		monotype = false
		dexdata = pbOpenDexData
		pbDexDataOffset(dexdata,@species,8)
		type1 = @pkmn.type1#(dexdata.fgetb)
		type2 = @pkmn.type2#(dexdata.fgetb)
		monotype = true if type1==type2
		
    echoln formInfos["#{@pkmn.species}_#{@pkmn.form}"]
    
		types = pbBitmap("Graphics/Pictures/types2_" + (@language==0 ? "ita" : "eng"))
		typeheight = 22
		@sprites["type"].bitmap = Bitmap.new(types.width*2,types.height/19)
		@sprites["type"].bitmap.blt(0,0,types,Rect.new(0,((typeheight)*type1),types.width,typeheight))
		@sprites["type"].bitmap.blt(types.width,0,types,Rect.new(0,((typeheight)*type2),types.width,typeheight)) if !monotype
		pbDexDataOffset(dexdata,@species,33)
		height=(@pkmn.form>0 && formInfos["#{@pkmn.species}_#{@pkmn.form}"] != nil && formInfos["#{@pkmn.species}_#{@pkmn.form}"].height != nil) ? formInfos["#{@pkmn.species}_#{@pkmn.form}"].height*100.0 : dexdata.fgetw
		echo "Height is "
		echoln height
		weight=(@pkmn.form>0 && formInfos["#{@pkmn.species}_#{@pkmn.form}"] != nil && formInfos["#{@pkmn.species}_#{@pkmn.form}"].weight != nil) ? formInfos["#{@pkmn.species}_#{@pkmn.form}"].weight*100.0 : dexdata.fgetw
		dexdata.close
		kind=(@pkmn.form>0 && formInfos["#{@pkmn.species}_#{@pkmn.form}"] != nil && formInfos["#{@pkmn.species}_#{@pkmn.form}"].kind != nil) ? formInfos["#{@pkmn.species}_#{@pkmn.form}"].kind : pbGetMessage(MessageTypes::Kinds,@species)
		dexentry=(@pkmn.form>0 && formInfos["#{@pkmn.species}_#{@pkmn.form}"] != nil && formInfos["#{@pkmn.species}_#{@pkmn.form}"].description != nil) ? formInfos["#{@pkmn.species}_#{@pkmn.form}"].description : pbGetMessage(MessageTypes::Entries,@species)
		inches=(height*0.393701).round
		pounds=(weight*0.22046).round
		@sprites["overlay"].bitmap.clear
		@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE-4
		@texts = []
		@texts.push([_INTL("{1} Pokémon",kind),265,79,0,Dex::MAINCOLOR])
		drawDesc(dexentry,39)
		pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		
		@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE-1
		@texts = []
		if pbGetCountry()==0xF4 # If the user is in the United States
			@texts.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),339,141,0,Color.new(48,48,48)])
			@texts.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),339,166,0,Color.new(48,48,48)])
		else
			@texts.push([_ISPRINTF("{1:.1f} m",height/100.0),339,141,0,Color.new(48,48,48)])
			@texts.push([_ISPRINTF("{1:.1f} kg",weight/100.0),339,166,0,Color.new(48,48,48)])
		end
		pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		
		@sprites["overlay"].bitmap.font.name = Dex::TEXTFONTNAME
		@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE
		@texts = []
		@texts.push([PBSpecies.getName(@species),303,28,0,Dex::MAINCOLOR])
		@texts.push([index > -1 ? sprintf("%03d",index) : "???",268,28,true,Dex::MAINCOLOR])
		pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		
	end
	
	def drawDesc(desc,maxCharPerLine=40)		
		#@sprites["info"].bitmap.clear
		string = desc
		words = string.split(' ')
		strings = []
		
		while words.length>0
			str = ""
			i = 0
			break if words[i] == nil
			while str.length<maxCharPerLine
				echoln words[i] if words[i]!=nil && (words[i] == '\n' || words[i].include?('\n'))
				break if words[i] == nil
				if words[i] == '\n' || words[i].include?('\n')
					if words[i] == '\n'
						words[i] = ""
					else
						words[i] = words[i].chop.chop	
						if (str + words[i]).length<maxCharPerLine
							str = str + (i>0 ? " " : "") + words[i]
							i+=1
						end
					end
					break
				end
				break if (str + words[i]).length>maxCharPerLine
				str = str + (i>0 ? " " : "") + words[i]
				i+=1
			end
			strings.push(str)
			str = ""
			words = words[i..words.length-1]	
		end
		texts = []
		for i in 0...strings.length
			texts.push([strings[i],260,220+20*i,0,Color.new(48,48,48)])
		end
		pbDrawTextPositions(@sprites["overlay"].bitmap,texts)
	end
	
	def getSpriteBase(bitmap)
		srcbitmap = Bitmap.new(bitmap.height,bitmap.height)
		srcbitmap.blt(0,0,bitmap,Rect.new(0,0,bitmap.height,bitmap.height))
		found = false
		ybase = 0
		for y in (0...bitmap.height).to_a.reverse
			for x in 0...bitmap.height
				found = true if srcbitmap.get_pixel(x,y).alpha != 0
				break if found
			end
			ybase = y if found
			break if found
		end
		return ybase
	end
	
	def update
		@frameskip +=1
		if @sprites["abg"]
			@sprites["abg"].ox+=Dex::ANIMBGSCROLLX
			@sprites["abg"].oy+=Dex::ANIMBGSCROLLY
		end
		@frame += 1 if @frameskip == 1
		@frameskip = 0 if @frameskip == 2
		@frame = 0 if @frame>=@frameCount
		if !$MKXP
			@sprites["sprite"].src_rect = Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height)
		else
			@sprites["sprite"].bitmap.clear
			@sprites["sprite"].bitmap.blt(0,0,@pokemonBitmap,Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height))
		end
		
	end
	
	def wait(frames)
		frames.times do
			Graphics.update
			Input.update
			begin
				yield if block_given?
			ensure
			end
		end
	end
	
	def inloop
		pbSEPlay("navopen")
		wait(40) {update}
		r = 0
		80.times do
			Graphics.update
			update
			r+=384/78
			@viewport2.rect=Rect.new(0,0,512,r)
		end		
		@viewport2.rect=Rect.new(0,0,512,384)
		#quick flash
		r = 0
		if @pkmn.form==0
			pbPlayCry(@species,80)
		else
			pbSEPlay(sprintf("%03d",@species)+"Cry_"+(@pkmn.form).to_s,80)
		end
		5.times do
			Graphics.update
			update
			r+=255/4
			@sprites["flash"].opacity = r
		end
    
		wait(10) {update}
		5.times do
			Graphics.update
			update
			r-=255/4
			@sprites["flash"].opacity = r
		end
		loop do
			Graphics.update
			Input.update
			update
			if Input.trigger?(Input::C) || Input.trigger?(Input::B)
				break
			end
		end
		
		#preparing transitions for "what to do" screen
		20.times do
			@sprites["nameBanner"].opacity-=255/19
			@sprites["overbg"].opacity-=255/19
			@sprites["overlay"].opacity-=255/19
			@sprites["fixedoverlay"].opacity-=255/19
			@sprites["type"].opacity-=255/19
			@sprites["icon"].opacity-=255/19
			Graphics.update
			Input.update
			update
		end
		@sprites["sprite"].move(Graphics.width/2,@sprites["sprite"].y,20,:ease_in_out_quad)
		20.times do
			@sprites["sprite"].update
			Graphics.update
			update
		end
    if @wtd
      self.whatToDo
    else
      self.endscene
    end
		#self.endscene
	end
	
	def whatToDo()
		nicknamed = false
		@index = 0
		commands = @commands
		
		maxindex = commands.length
		
		@buttons={}
		for i in commands
			@buttons["b#{i}"] = @sprites["button#{commands.index(i)}"]
		end
		for i in 0..@commands.length-1
			targetHeight = Graphics.height-110
			targetHeight = Graphics.height-60 if (i == 1 || i == 2)
			@sprites["button#{i}"].move(@sprites["button#{i}"].x,targetHeight,20,:ease_out_quad)
			@sprites["button#{i}"].fade(255,20,:ease_out_quad) if i == @index
			@sprites["button#{i}"].fade(175,20,:ease_out_quad) if i != @index
		end
		20.times do
			for i in 0..@commands.length-1
				@sprites["button#{i}"].update
			end
			Graphics.update
			Input.update
			update
		end
		loop do
			maxindex = commands.length-1
			Graphics.update
			Input.update
			update
			for i in 0..@commands.length-1
				targetHeight = Graphics.height-110
				targetHeight = Graphics.height-60 if (i == 1 || i == 2)
				@sprites["button#{i}"].update
				@sprites["button#{i}"].move(@sprites["button#{i}"].x,targetHeight,20,:ease_out_quad) if @sprites["button#{i}"].y<=targetHeight-15
			end
			
			if Input.trigger?(Input::LEFT)
				echoln commands
				@index = @index-1 < 0 ? maxindex:@index-1
				for i in commands
					@buttons["b#{i}"].update
					@buttons["b#{i}"].fade(255,20,:ease_out_quad) if i == commands[@index]
					@buttons["b#{i}"].fade(175,20,:ease_out_quad) if i != commands[@index]
				end
				targetHeight = Graphics.height-110-15
				targetHeight = Graphics.height-60-15 if (@index == 1 || @index == 2)
				@buttons["b#{commands[@index]}"].move(@sprites["button#{@index}"].x,targetHeight,5,:ease_out_cubic)
			elsif Input.trigger?(Input::RIGHT)
				@index = @index+1 > maxindex ? 0 : @index+1
				for i in commands
					@buttons["b#{i}"].update
					@buttons["b#{i}"].fade(255,20,:ease_out_quad) if i == commands[@index]
					@buttons["b#{i}"].fade(175,20,:ease_out_quad) if i != commands[@index]
				end
				targetHeight = Graphics.height-110-15
				targetHeight = Graphics.height-60-15 if (@index == 1 || @index == 2)
				@buttons["b#{commands[@index]}"].move(@sprites["button#{@index}"].x,targetHeight,5,:ease_out_cubic)
			end
			
			if commands.length==0 #to avoid bugs
				break
			end
			
			if Input.trigger?(Input::C) || Input.trigger?(Input::B)
				if commands[@index] == "pc"
          @pkmn.heal
					storedbox = $PokemonStorage.pbStoreCaught(@pkmn)
					if storedbox < 0 && $Trainer.party.length>=6
						message(_INTL("The box and the party are full, you cannot store the Pokémon."))
						break
					elsif storedbox<0
						message(_INTL("The box is full, you cannot store the Pokémon there."))
					else
						message(_INTL("{1} was stored in the Box n°{2}.",@pkmn.name, storedbox+1))
						break
					end
				elsif commands[@index] == "party"
					if $PokemonStorage.full? && $Trainer.party.length>=6
						message(_INTL("The box and the party are full, you cannot store the Pokémon."))
						break
					elsif $Trainer.party.length>=6
						message(_INTL("The party is full, you cannot store the Pokémon there."))
					else
						message(_INTL("{1} was added to the party.",@pkmn.name))
						$Trainer.party[$Trainer.party.length]=@pkmn
						break
					end
				elsif commands[@index] == "info" #kleeee
					pbFadeOutIn(999999) {
						scenex = PokemonSummaryScene.new
						screenx = PokemonSummary.new(scenex)
						screenx.pbStartScreen([@pkmn],0,1000000)
					}
				elsif commands[@index] == "nick" #NICKNAME
					commands.delete("nick")
					nicknamed = true
					@buttons["bnick"].visible = false
					r=0
					20.times do 
						r+=255/19
						@viewport.color = Color.new(0,0,0,r)
						@viewport2.color = @viewport.color
						Graphics.update
						update
					end
          oldname = @pkmn.name
					@pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?",@pkmn.name),0,10,"",@pkmn)
					@pkmn.name = oldname if @pkmn.name == ""
          r=255
					20.times do 
						r-=255/19
						@viewport.color = Color.new(0,0,0,r)
						@viewport2.color = @viewport.color
						Graphics.update
						update
					end
					@index = 0
					for i in commands
						@buttons["b#{i}"].update
						@buttons["b#{i}"].fade(255,20,:ease_out_quad) if i == commands[@index]
						@buttons["b#{i}"].fade(175,20,:ease_out_quad) if i != commands[@index]
					end
				end
				
				
				#break
			end
		end
		self.endscene
	end
	
	def endscene
		pbFadeOutAndHide(@sprites) {update} 
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
		@viewport2.dispose
	end
	
	def message(message,&block)
		msgwindow=Kernel.pbCreateMessageWindow(@viewport,nil)
		Kernel.pbMessageDisplay(msgwindow,message,&block)
		Kernel.pbDisposeMessageWindow(msgwindow)
	end

	def pbSummary(poke)
		oldsprites=pbFadeOutAndHide(@sprites)
		scene=PokemonSummaryScene.new
		screen=PokemonSummary.new(scene)
		if poke
		  screen.pbStartScreen([poke],0)
		end
		pbFadeInAndShow(@sprites,oldsprites)
	  end
	
end

def pbTO
	pbFadeOutIn(99999){
		DexObtained.new(1022)
	}
end