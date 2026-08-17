class DexInfo
	
	#species is the current species opened,
	#dextype is the string with the dex name
	def initialize(species,dextype,dexmain)
		#0 is italian, 1 is english
		@language = pbGetLanguage() == 4 ? 0 : 1
		
		@dexmain = dexmain
		@species = species
		
    @shiny = false
    
		@seenlist = DexCore.seenList(@dexmain.list)
		@seenIndex = @seenlist.index(@species)
		
		@descriptionPage = 0
		
		
		@sprites = {}
		@abg = dexmain.sprites["abg"]
		
		@viewport = dexmain.viewport
		
		@form = 0
		
		@sprites["nameBanner"] = Sprite.new(@viewport)
		@sprites["nameBanner"].bitmap = pbBitmap(Dex::PATH + dextype + "_namebar")
		@sprites["nameBanner"].y = 20
		@sprites["nameBanner"].x = 175
		@sprites["nameBanner"].z = 30
		@sprites["icon"] = DexIcon.new(@viewport,@species)#Sprite.new(@viewport)
		@sprites["icon"].opacity = 255
    @sprites["icon"].tone = Tone.new(0,0,0,0)
		@sprites["icon"].color = Color.new(0,0,0,0)
    @sprites["icon"].x = 162
		@sprites["icon"].y = 5
		@sprites["icon"].z = 30
		
		@sprites["overlay"] = Sprite.new(@viewport)
		@sprites["overlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		@sprites["overlay"].z = 31
		@texts = []
		#Pokemon sprite
		@sprites["sprite"] = Sprite.new(@viewport)
		@sprites["sprite"].x = 137
		@sprites["sprite"].zoom_x = Dex::SPRITESIZE
		@sprites["sprite"].zoom_y = Dex::SPRITESIZE
		
		@sprites["type"] = Sprite.new(@viewport)
		@sprites["type"].x = 334
		@sprites["type"].y = 118
		@sprites["type"].z = 31
		@formDescriptions = pbLoadFormInfos
		
		@sprites["shinybutton"]=EAMSprite.new(@viewport)
		@sprites["shinybutton"].x = 286
		@sprites["shinybutton"].y = 343
		@sprites["shinybutton"].bitmap = pbBitmap(Dex::PATH+"info_shiny")
		@sprites["shinybutton"].visible = $Trainer.shinyseen[@species]
		@sprites["shinybutton"].z=20    
    
		@icons = {}
		createFormInfo
		
		updatePokemonInfo
		
		@sprites["sidebar"] = Sprite.new(@viewport)
		@sprites["sidebar"].bitmap = pbBitmap(Dex::PATH + "SideBar")
		
		@sprites["formarrows"] = Sprite.new(@viewport)
		@sprites["formarrows"].bitmap = pbBitmap(Dex::PATH + "FormArrows")
		@sprites["formarrows"].x = 46
		@sprites["formarrows"].y = 273
		@sprites["formarrows"].z = 30
		
		@sprites["slider"] = EAMSprite.new(@viewport)
		if @dexmain.lastpokemonIndex>0
			height = (Dex::MAXSLIDERSIZE*(@dexmain.list.length/Dex::LINE-(@dexmain.lastpokemonIndex/Dex::LINE)))/(@dexmain.list.length.to_f/Dex::LINE)#
		else
			height = Dex::MAXSLIDERSIZE
		end
		
		@sprites["slider"].bitmap = Bitmap.new(23,height+23)
		@sprites["slider"].z = 30
		@sprites["slider"].x = 14
		#generating the slider
		slider = @sprites["slider"].bitmap
		slider.blt(0,0,pbBitmap(Dex::PATH + "Slider"),Rect.new(0,0,23,11))
		slider.stretch_blt(Rect.new(0,11,23,height.to_i),pbBitmap(Dex::PATH + "Slider"),Rect.new(0,11,23,11))
		slider.blt(0,11+height,pbBitmap(Dex::PATH + "Slider"),Rect.new(0,32,23,12))
		#finished generating the slider
		
		@startsliderY = 83
		@maxsliderY = 188-height+11
		
		currentline =  @dexmain.list.index(@species)/ Dex::LINE
		if @dexmain.lastpokemonIndex.to_f>0
			threshold = (currentline*@maxsliderY)/(@dexmain.lastpokemonIndex.to_f/Dex::LINE)
		else
			threshold = 0
		end
		
		@sprites["slider"].y = @startsliderY+threshold
		
		@sprites["overbg"] = Sprite.new(@viewport)
		@sprites["overbg"].bitmap = pbBitmap(Dex::PATH + "Info_overlay")
		@sprites["bottombar"] = Sprite.new(@viewport)
		@sprites["bottombar"].bitmap = pbBitmap(Dex::PATH + "Info_lowerBar")
		
		@sprites["fixedoverlay"] = Sprite.new(@viewport)
		@sprites["fixedoverlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		
		#Fixed pokemon info text
		texts = [[_INTL("Type"),264,116,0,Color.new(248,248,248)],
			[_INTL("Height"),264,141,0,Color.new(248,248,248)],
			[_INTL("Weight"),264,166,0,Color.new(248,248,248)],] 
		@sprites["fixedoverlay"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["fixedoverlay"].bitmap.font.size = Dex::TEXTFONTSIZE-1
		pbDrawTextPositions(@sprites["fixedoverlay"].bitmap,texts)
		
		#Fixed button texts
		texts = []
		texts.push([_INTL("Close"),460,346,true,Dex::MAINCOLOR])
		texts.push([_INTL("Habitat"),98,346,true,Dex::MAINCOLOR])
		@sprites["fixedoverlay"].bitmap.font.name = Dex::NUMBERFONTNAME
    @sprites["fixedoverlay"].bitmap.font.bold = true
		@sprites["fixedoverlay"].bitmap.font.size = Dex::TEXTFONTSIZE
		pbDrawTextPositions(@sprites["fixedoverlay"].bitmap,texts)
		
		
		
		self.updateSliderPosition
	end
	
	def update
		@frameskip +=1
		if @abg
			@abg.ox+=Dex::ANIMBGSCROLLX
			@abg.oy+=Dex::ANIMBGSCROLLY
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
		@sprites["slider"].update
		
		for icon in @icons.values
			icon.update
		end
	end
	
	def updateSliderPosition
		currentline =  @dexmain.list.index(@species)/ Dex::LINE
		if @dexmain.lastpokemonIndex>0
		threshold = (currentline*@maxsliderY)/(@dexmain.lastpokemonIndex.to_f/Dex::LINE)
		else
		threshold = 0
		end
		
		@sprites["slider"].move(14,@startsliderY+threshold,10,:ease_out_quad)
	end
	
	def updatePokemonInfo		
		#updating sprite info
		@frame = 0
		@frameskip = 0
    
    	st = (@shiny ? "Graphics/Battlers/FrontShiny/" : "Graphics/Battlers/Front/")
		@sprites["shinybutton"].visible = $Trainer.shinyseen[@species]
    
    	last = ""
		if !@forms[@formIndex].is_a?(String)
			last = (@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : "") if @forms.length>0
		else
			last = (@forms[@formIndex].include?("d") ? "d" : "")
		end
		last = "" if @forms[@formIndex].is_a?(String) && !@forms[@formIndex].include?("d")
		add=""
		add = "Female/" if @forms[@formIndex].is_a?(String) && !@forms[@formIndex].include?("d")
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
		#@sprites["icon"].bitmap = pbBitmap(Dex::PATH+"Icon/"+@species.to_s)
		@sprites["icon"].dispose
		@sprites["icon"] = DexIcon.new(@viewport,@species)
		@sprites["icon"].x = 162
		@sprites["icon"].y = 5
		@sprites["icon"].z = 30
		@sprites["icon"].tone = Tone.new(0,0,0,0)
		@sprites["icon"].color = Color.new(0,0,0,0)
		@sprites["icon"].opacity = 255
		@sprites["type"].bitmap.clear if @sprites["type"].bitmap
		
		index = @dexmain.dex.index(@species)+1
		echoln @forms
    
		if $Trainer.owned[@species]
			monotype = false
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,@species,8)
			type1 = (dexdata.fgetb)
			type2 = (dexdata.fgetb)
			if @forms.length>0 && @forms[@formIndex] != 0
				type1 = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type1 if @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type1 != type1 && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type1 != nil
				type2 = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type2 if @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type2 != type2 && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].type2 != nil
			end
			monotype = true if type1==type2
			
			types = pbBitmap("Graphics/Pictures/types2_" + (@language==0 ? "ita" : "eng"))
			typeheight = 22
			@sprites["type"].bitmap = Bitmap.new(types.width*2,types.height/19)
			@sprites["type"].bitmap.blt(0,0,types,Rect.new(0,((typeheight)*type1),types.width,typeheight))
			@sprites["type"].bitmap.blt(types.width,0,types,Rect.new(0,((typeheight)*type2),types.width,typeheight)) if !monotype
			pbDexDataOffset(dexdata,@species,33)
			height=dexdata.fgetw
			if @forms.length>0
				femalecond = @forms[@formIndex].is_a?(String) && !@forms[@formIndex].include?("d")
				anyformcond = @forms[@formIndex].is_a?(String) || @forms[@formIndex]>0
			end
      		if @forms.length>0 && (femalecond ? false : anyformcond) && @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].height != nil
				height = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].height*100.0
			end
			weight=dexdata.fgetw
			if @forms.length>0 && (femalecond ? false : anyformcond) && @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].weight != nil
				echoln "Formdesc weight override!"
				weight = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].weight*100.0
				
			end
			echoln weight
			dexdata.close
			kind=pbGetMessage(MessageTypes::Kinds,@species)
			if @forms.length>0 && (femalecond ? false : anyformcond) && @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].kind != nil
				kind = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].kind
			end
			dexentry=pbGetMessage(MessageTypes::Entries,@species)
			if @forms.length>0 && (femalecond ? false : anyformcond) && @formDescriptions["#{@species}_#{@forms[@formIndex]}"] && @formDescriptions["#{@species}_#{@forms[@formIndex]}"].description != ""
				dexentry = @formDescriptions["#{@species}_#{@forms[@formIndex]}"].description
			end
			inches=((height)*0.393701).round
			pounds=((weight)*0.22046).round
			@sprites["overlay"].bitmap.clear
			@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
			@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE-4
			@texts = []
			#if @formIndex == 0
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
      if $game_switches[950] && RETROMON[@species] != nil
        if $Trainer.retrochain[@species]==nil
          $Trainer.retrochain[@species]=0
        end
        pbDrawTextPositions(@sprites["overlay"].bitmap,[[_INTL("Defeated: {1}",$Trainer.retrochain[@species]),20,20,0,Color.new(248,248,248)]])
      end
			pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		else
			@sprites["overlay"].bitmap.clear
			@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
			@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE-4
			@texts = []
			@texts.push([_INTL("????? Pokémon"),265,79,0,Dex::MAINCOLOR])
			pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
			
			
			@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
			@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE-1
			@texts = []
			if pbGetCountry()==0xF4 # If the user is in the United States
				@texts.push([_ISPRINTF("?????\""),339,141,0,Color.new(48,48,48)])
				@texts.push([_ISPRINTF("????? lbs."),339,166,0,Color.new(48,48,48)])
			else
				@texts.push([_ISPRINTF("????? m"),339,141,0,Color.new(48,48,48)])
				@texts.push([_ISPRINTF("????? kg"),339,166,0,Color.new(48,48,48)])
			end
			pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		end
		
    if $Trainer.shinyseen[@species]
			@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
			@sprites["overlay"].bitmap.font.bold = true
			@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE
			pbDrawTextPositions(@sprites["overlay"].bitmap,[[(@shiny ? _INTL("Hide Shiny") : _INTL("Show Shiny")),282,346,1,Color.new(248,248,248)]])
		end
    
		@sprites["overlay"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["overlay"].bitmap.font.bold = true
		@sprites["overlay"].bitmap.font.size = Dex::TEXTFONTSIZE
		@texts = []
		name = PBSpecies.getName(@species)
		name = "Persian" if @forms[@formIndex].is_a?(String) && @species == PBSpecies::PERSIANELDIW
		@texts.push([name,303,28,0,Dex::MAINCOLOR])
		@texts.push([sprintf("%03d",index),268,28,true,Dex::MAINCOLOR])
		pbDrawTextPositions(@sprites["overlay"].bitmap,@texts)
		@sprites["overlay"].bitmap.font.bold = false
		updateFormInfo
		
	end
	
	def createFormInfo
		pbDisposeSpriteHash(@icons)
		@forms = []
		@formIndex = 0
    echoln $Trainer.formseen[@species][0]
    echoln $Trainer.formseen[@species][1]
		for j in 0...2
			for i in 0...$Trainer.formseen[@species][j].length
				f = $Trainer.formseen[@species][j][i]
				if i == 1 && !@forms.include?(i) && pbResolveBitmap(Dex::PATH + "Icon/#{@species}d")
					@forms.push("#{i}d")
					echoln "found delta form"
					next
				end
				@forms.push(i) if f == true && !@forms.include?(i)
				@forms.push("#{i}f") if j==1 && f == true && pbResolveBitmap(Dex::PATH + "Icon/#{@species}f") && !@forms.include?("#{i}f")
			end
		end
		echoln @forms
		index = 0
		for i in @forms
      echoln i
			if !(i.is_a?(String))
				@icons["f#{i}"] = EAMSprite.new(@viewport)
				@icons["f#{i}"].bitmap = pbBitmap(Dex::PATH + "Icon/"+@species.to_s+(i>0? "_#{i}" : ""))
				@icons["f#{i}"].x = 145 + 50*index
				@icons["f#{i}"].y = 285
				@icons["f#{i}"].ox = 75/2
				@icons["f#{i}"].oy = 74/2
				@icons["f#{i}"].zoom_x = 0
				@icons["f#{i}"].zoom_y = 0
			else
				f = i[0,1]
				v = (i.include?("d") ? "d" : "f")
				@icons["f#{f}#{v}"] = EAMSprite.new(@viewport)
				@icons["f#{f}#{v}"].bitmap = pbBitmap(Dex::PATH + "Icon/"+@species.to_s+(i.include?("d") ? "d" : "f"))
				@icons["f#{f}#{v}"].x = 145 + 50*index
				@icons["f#{f}#{v}"].y = 285
				@icons["f#{f}#{v}"].ox = 75/2
				@icons["f#{f}#{v}"].oy = 74/2
				@icons["f#{f}#{v}"].zoom_x = 0
				@icons["f#{f}#{v}"].zoom_y = 0
			end
			index +=1
		end
		if @forms.length>0
			v = Proc.new{|i| (i.include?("d") ? "d" : "f")}
			value = @forms[@formIndex].is_a?(String) ? "#{@forms[@formIndex][0,1]}#{v.call(@forms[@formIndex])}": @forms[@formIndex]
			@icons["f#{value}"].zoom_x = 1
			@icons["f#{value}"].zoom_y = 1
			if @forms.length>1
				value = @forms[@formIndex+1].is_a?(String) ? "#{@forms[@formIndex+1][0,1]}#{v.call(@forms[@formIndex+1])}": @forms[@formIndex+1]
				@icons["f#{value}"].zoom_x = 0.5
				@icons["f#{value}"].zoom_y = 0.5
			end
		end
	end
	
	def updateFormInfo
		#getting either delta or female form
		v = Proc.new{|i| (i.include?("d") ? "d" : "f")}
		for i in 0...@forms.length
			x = 145 + 50*i - 50*@formIndex
			value = @forms[i].is_a?(String) ? "#{@forms[i][0,1]}#{v.call(@forms[i])}": @forms[i]
			@icons["f#{value}"].move(x,285,15,:ease_out_cubic) 
		end
		
		value1 = @forms[@formIndex].is_a?(String) ? "#{@forms[@formIndex][0,1]}#{v.call(@forms[@formIndex])}": @forms[@formIndex]
		value2 = @forms[@formIndex-1].is_a?(String) ? "#{@forms[@formIndex-1][0,1]}#{v.call(@forms[@formIndex-1])}": @forms[@formIndex-1] if @formIndex>0
		value3 = @forms[@formIndex-2].is_a?(String) ? "#{@forms[@formIndex-2][0,1]}#{v.call(@forms[@formIndex-2])}": @forms[@formIndex-2] if @formIndex>1
		value4 = @forms[@formIndex+1].is_a?(String) ? "#{@forms[@formIndex+1][0,1]}#{v.call(@forms[@formIndex+1])}": @forms[@formIndex+1] if @formIndex<@forms.length-1
		value5 = @forms[@formIndex+2].is_a?(String) ? "#{@forms[@formIndex+2][0,1]}#{v.call(@forms[@formIndex+2])}": @forms[@formIndex+2] if @formIndex<@forms.length-2
		@icons["f#{value1}"].zoom(1,1,15,:ease_out_quad) if @icons["f#{value1}"]
		@icons["f#{value2}"].zoom(0.5,0.5,15,:ease_out_quad) if @formIndex>0 && @icons["f#{value2}"]
		@icons["f#{value3}"].zoom(0,0,15,:ease_out_quad) if @formIndex>1 && @icons["f#{value3}"]
		@icons["f#{value4}"].zoom(0.5,0.5,10,:ease_out_quad) if @formIndex<@forms.length-1 && @icons["f#{value4}"]
		@icons["f#{value5}"].zoom(0,0,10,:ease_out_quad) if @formIndex<@forms.length-2 && @icons["f#{value5}"]
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
	
	def drawText(bitmap,x,y,width,numlines,text,baseColor,shadowColor)
		normtext=getLineBrokenChunks(bitmap,text,width,nil,true)
		renderLineBrokenChunksWithShadow(bitmap,x,y,normtext,numlines*32,
			baseColor,shadowColor)
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
	
	def inputHandle
    if @forms.length==0
      pbPlayCry(@species,80)
    else
      if !@forms[@formIndex].is_a?(String)
				pbSEPlay(sprintf("%03d",@species)+"Cry"+(@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : ""),80)
			else
				pbSEPlay(sprintf("%03d",@species)+"Cry",80)
			end
    end
		loop do
			Graphics.update
			Input.update
			update
			
			if (Input.trigger?(Input::DOWN))
				@seenIndex = @seenIndex+1>=@seenlist.length ? 0 : @seenIndex+1
				@species = @seenlist[@seenIndex]
        @shiny=false
				createFormInfo
				updatePokemonInfo()
        if @forms.length==0
          pbPlayCry(@species,80)
        else
          if !@forms[@formIndex].is_a?(String)
						pbSEPlay(sprintf("%03d",@species)+"Cry"+(@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : ""),80)
					else
						pbSEPlay(sprintf("%03d",@species)+"Cry",80)
					end
        end
				updateSliderPosition
			elsif (Input.trigger?(Input::UP))
				@seenIndex = @seenIndex-1<0 ? @seenlist.length-1 : @seenIndex-1
				@species = @seenlist[@seenIndex]
        @shiny=false
				createFormInfo
				updatePokemonInfo()
        if @forms.length==0
          pbPlayCry(@species,80)
        else
          if !@forms[@formIndex].is_a?(String)
						pbSEPlay(sprintf("%03d",@species)+"Cry"+(@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : ""),80)
					else
						pbSEPlay(sprintf("%03d",@species)+"Cry",80)
					end
        end
				updateSliderPosition
			end
			
			if (Input.trigger?(Input::RIGHT)) && @forms.length>1
				oldid = @formIndex
				@formIndex = (@formIndex+1 > @forms.length-1) ? @formIndex : @formIndex+1
				if !@forms[@formIndex].is_a?(String)
					pbSEPlay(sprintf("%03d",@species)+"Cry"+(@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : ""),80)
				else
					pbSEPlay(sprintf("%03d",@species)+"Cry",80)
				end
        if @formIndex != oldid
					updatePokemonInfo()
				end
			elsif (Input.trigger?(Input::LEFT)) && @forms.length>1
				oldid = @formIndex
				@formIndex = (@formIndex-1 < 0) ? @formIndex : @formIndex-1	
        if !@forms[@formIndex].is_a?(String)
					pbSEPlay(sprintf("%03d",@species)+"Cry"+(@forms[@formIndex]>0 ? "_#{@forms[@formIndex]}" : ""),80)
				else
					pbSEPlay(sprintf("%03d",@species)+"Cry",80)
				end
				if @formIndex != oldid
					updatePokemonInfo()
				end
			end
			
      if Input.trigger?(Input::Y) && $Trainer.shinyseen[@species]
        @shiny=!@shiny
        updatePokemonInfo()
      end
      
			if (Input.trigger?(Input::A))
				r = 0
				20.times do
					Graphics.update
					r+=255/19
					@viewport.color = Color.new(0,0,0,r)
					update
				end
				pbFadeOutIn(999999){
					update
					@nest = DexNest.new(@viewport,@species)
					@viewport.color = Color.new(0,0,0,0)
				}
				day = true
				loop do
					Graphics.update
					Input.update
					update
					@nest.update
					if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
						day = !day
						@nest.loadEncounters(day)
					end
					if Input.trigger?(Input::B)
						break
					end
				end
				pbFadeOutIn(999999){
					@viewport.color = Color.new(0,0,0,r)
					@nest.close
				}
				20.times do
					Graphics.update
					r-=255/19
					@viewport.color = Color.new(0,0,0,r)
					update
				end
			elsif Input.trigger?(Input::B)
				break
			end
		end
	end
	
	def close
		pbDisposeSpriteHash(@sprites)
		pbDisposeSpriteHash(@icons)
	end
	
end