################################################################################
# Pokedex v2
#   v 1.0
#
################################################################################
ELDIWDEX = pbAllRegionalSpecies(0)#[1021,1022,1023,1024,1025,1026,1027,1028,1029]
ELDIWDEX.delete(0) if ELDIWDEX.include?(0)
NATIONALDEX = []
RETRODEX = []
for i in 1300..1506
	next if [1462,1463,1464].include?(i)
	RETRODEX.push(i)
end
RETRODEX.insert(150,1462) #WEEDLEBETA
RETRODEX.insert(151,1463) #KAKUNABETA
RETRODEX.insert(152,1464) #BEEDRILBETA (KUSANGY)

XENODEX = pbAllRegionalSpecies(1) #[]
XENODEX.delete(0) if XENODEX.include?(0)


class DexMain
  	attr_accessor(:sprites)
	attr_accessor(:viewport)
	attr_accessor(:dex)
	attr_accessor(:savedCriteria)
	
	
	
  def initialize(dexlist=0)
		Console::setup_console if $DEBUG
		pbLoadFormDescTranslation
    	@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    	@viewport.z = 999999
		#$Trainer.seen[244] = false
		#for i in 0...$Trainer.seen.length
	  	#	 $Trainer.seen[i] = false
		#end
		$Trainer.xenodex = true if $DEBUG
		@nationaldex = false
		
		@dexlist = dexlist == 0 ? (@nationaldex ? NATIONALDEX : ELDIWDEX) : (dexlist == 1 ? RETRODEX : XENODEX)
		@dex = @dexlist
		
    	@path = "Graphics/Pictures/DexNew/"
		
    	@sprites = {}
    
		@savedCriteria = [nil,nil,nil,nil,nil,nil,nil]
		
		@standardCriteria = [nil,nil,nil,nil,nil,nil,nil]
		
		dexvalue = @dexlist == ELDIWDEX ? "PokeDex" : (@dexlist == RETRODEX ? "RetroDex" : "XenoDex")
		
    	@sprites["bg"] = Sprite.new(@viewport)
    	@sprites["bg"].bitmap = pbBitmap(Dex::PATH + dexvalue + "_bg")
		@sprites["abg"] = AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(Dex::PATH + "animbg")
		@sprites["overbg"] = Sprite.new(@viewport)
		@sprites["overbg"].bitmap = pbBitmap(Dex::PATH + dexvalue + "_overlay")
		@sprites["overbg"].z = 30
		@sprites["xenobutton"] = Sprite.new(@viewport)
		@sprites["xenobutton"].bitmap = pbBitmap(Dex::PATH + "Xenodex_button") if $Trainer.xenodex && @dexlist != XENODEX && @dexlist != RETRODEX
		@sprites["xenobutton"].x = 106
		@sprites["xenobutton"].y = 343
		@sprites["xenobutton"].z = 30
		
		@sprites["overlay"] = Sprite.new(@viewport)
		@sprites["overlay"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		@sprites["overlay"].z = 31
		setDexFont(@sprites["overlay"].bitmap)
		
		texts = []
		#Seen
		texts.push([_INTL("{1}",DexCore.countSeen(@dexlist)),206,12,true,Dex::MAINCOLOR])
		#Owned
		texts.push([_INTL("{1}",DexCore.countOwned(@dexlist)),152,12,true,Dex::MAINCOLOR])
		pbDrawTextPositions(@sprites["overlay"].bitmap,texts)
		
		setDexFont(@sprites["overlay"].bitmap,false)
		
		texts = []
		#Dexname
		dexname = @dexlist == ELDIWDEX ? _INTL("Pokédex") : (@dexlist == XENODEX ? _INTL("Xenodex") : _INTL("Retrodex"))
		dexname = _INTL("Progress")
		texts.push([dexname,20,9,false,Dex::MAINCOLOR])
		#Dexdesc
		dexdesc = @dexlist == ELDIWDEX ? _INTL("Pokédex di Eldiw") : (@dexlist == XENODEX ? _INTL("Pokédex dello Xenoverse") : _INTL("Pokédex Retrò"))
		texts.push([_INTL("{1}",dexdesc),266,9,false,Dex::MAINCOLOR])
		#Chiudi
		texts.push([_INTL("Close"),460,346,true,Dex::MAINCOLOR])
		#Ricerca
		texts.push([_INTL("Search"),276,346,true,Dex::MAINCOLOR])
		#Xenodex
		texts.push([_INTL("Xenodex"),98,346,true,Dex::MAINCOLOR])  if $Trainer.xenodex && @dexlist != XENODEX && @dexlist != RETRODEX
		
		pbDrawTextPositions(@sprites["overlay"].bitmap,texts)
		
		
		@icons = {}
		updateIcons
		
		@sprites["selIcon"] = Sprite.new(@viewport)
		@sprites["selIcon"].bitmap = pbBitmap(Dex::PATH + "select")
		@sprites["selIcon"].x = @icons["s#{@dexlist[@selIndex]}"].x
		@sprites["selIcon"].y = @icons["s#{@dexlist[@selIndex]}"].y
		
		@sprites["slider"] = EAMSprite.new(@viewport)
		height = (Dex::MAXSLIDERSIZE*(@dexlist.length/Dex::LINE-(@lastpokemonIndex/Dex::LINE)))/(@dexlist.length/Dex::LINE)
		@sprites["slider"].bitmap = Bitmap.new(23,height+23)
		@sprites["slider"].z = 30
		@sprites["slider"].x = 474
		@sprites["slider"].y = 83
		#generating the slider
		slider = @sprites["slider"].bitmap
		slider.blt(0,0,pbBitmap(Dex::PATH + "Slider"),Rect.new(0,0,23,11))
		slider.stretch_blt(Rect.new(0,11,23,height),pbBitmap(Dex::PATH + "Slider"),Rect.new(0,11,23,11))
		slider.blt(0,11+height,pbBitmap(Dex::PATH + "Slider"),Rect.new(0,32,23,12))
		#finished generating the slider
		
		@startsliderY = @sprites["slider"].y
		@maxsliderY = 188-height+11
		
  end
  
	def setList(list)
		@dexlist = list
		updateIcons
	end
	
	def setDexFont(bitmap,number = true)
		bitmap.font.name = Font.exist?(number ? Dex::NUMBERFONTNAME : Dex::TEXTFONTNAME) ? (number ? Dex::NUMBERFONTNAME : Dex::TEXTFONTNAME) : "Arial"
		bitmap.font.size = number ? Dex::NUMBERFONTSIZE : Dex::TEXTFONTSIZE
		bitmap.font.bold = Dex::FONTBOLD
	end
	
	def updateSliderPosition
		currentline = @selIndex / Dex::LINE
		threshold = (currentline*@maxsliderY)/(@lastpokemonIndex/Dex::LINE)
		@sprites["slider"].move(474,@startsliderY+threshold,10,:ease_out_quad)
	end
	
	def lastpokemonIndex
		return @lastpokemonIndex if @lastpokemonIndex
		return 0
	end
	
	def list 
		return @dexlist
	end
	
	def updateIcons
		pbDisposeSpriteHash(@icons)
		@last = DexCore.getLastSeen(@dexlist)
		index = 0
		for species in @dexlist
			@icons["s#{species}"] = DexIcon.new(@viewport,species)
			@icons["s#{species}"].x = Dex::LEFTBORDER + Dex::SPACING*(index%Dex::LINE) + @icons["s#{species}"].bitmap.width * (index%Dex::LINE)
			@icons["s#{species}"].y = 50 + Dex::LINESPACING*(index/Dex::LINE) +  @icons["s#{species}"].bitmap.height * (index/Dex::LINE)
			@icons["s#{species}"].z = 20
			
			index+=1
			break if species == @last
		end
		@lastpokemonIndex = index-1
		@selIndex = 0
	end
	
	def update
		if @sprites["abg"]
			@sprites["abg"].ox+=Dex::ANIMBGSCROLLX
			@sprites["abg"].oy+=Dex::ANIMBGSCROLLY
		end		
		
		@sprites["selIcon"].x = @icons["s#{@dexlist[@selIndex]}"].x if @icons["s#{@dexlist[@selIndex]}"]
		@sprites["selIcon"].y = @icons["s#{@dexlist[@selIndex]}"].y if @icons["s#{@dexlist[@selIndex]}"]
		@sprites["slider"].update
		
		for icon in @icons.values
			icon.update
		end
	end
  
	def scrollIcons()
		index = 0
		targeticon = @icons["s#{@dexlist[@selIndex]}"]
		for species in @dexlist
			icon = @icons["s#{species}"]
			yvalue = 50 + Dex::LINESPACING*(index/Dex::LINE) +  icon.bitmap.height * (index/Dex::LINE)
			#Scroll to a point where s#{@dexlist[@selIndex]} is visible
			yvalue -= (targeticon.y<0) ? (Dex::LINEHEIGHT*(@selIndex/Dex::LINE)) : ((targeticon.y>Dex::BOTTOMTHRESHOLD) ? Dex::LINEHEIGHT*(@selIndex/Dex::LINE-3) : 0) 
			icon.move(icon.x, yvalue, Dex::ICONSCROLLSPEED,:ease_out_cubic)
			index+=1
			break if species == @last
		end
	end
	
	def controlSelectionIndex(newIndex)
		pbPlayDecisionSE()
		oldline = @selIndex/Dex::LINE
		if newIndex<0
			@selIndex = (Dex::LINE*(@lastpokemonIndex/Dex::LINE)+(@selIndex%6))>@lastpokemonIndex ? (Dex::LINE*((@lastpokemonIndex/Dex::LINE)-1)+(@selIndex%6)) : (Dex::LINE*(@lastpokemonIndex/Dex::LINE)+(@selIndex%6))
			scrollIcons if @selIndex/Dex::LINE != oldline	
			updateSliderPosition if @selIndex/Dex::LINE != oldline	
			return
		elsif newIndex > @lastpokemonIndex
			@selIndex = @selIndex%6
			scrollIcons if @selIndex/Dex::LINE != oldline	
			updateSliderPosition if @selIndex/Dex::LINE != oldline	
			return
		end
		@selIndex = newIndex
		
		scrollIcons if @selIndex/Dex::LINE != oldline && (@icons["s#{@dexlist[@selIndex]}"].y<0 || @icons["s#{@dexlist[@selIndex]}"].y>340)
		updateSliderPosition if @selIndex/Dex::LINE != oldline	
	end
	
	def hideMainDex
		for sprites in @sprites.keys
			next if sprites == "bg" || sprites == "abg"
			@sprites[sprites].visible = false
		end
		for icon in @icons.values
			icon.visible = false
		end
	end
	
	def showMainDex
		for sprites in @sprites.keys
			next if sprites == "bg" || sprites == "abg"
			@sprites[sprites].visible = true
		end
		for icon in @icons.values
			icon.visible = true
		end
	end
	
  def inputHandle
    
    loop do
      Graphics.update
			Input.update
			update
			
			controlSelectionIndex(@selIndex+6) if Input.repeat?(Input::DOWN) || Input.trigger?(Input::DOWN)
			controlSelectionIndex(@selIndex-6) if Input.repeat?(Input::UP) || Input.trigger?(Input::UP)
			controlSelectionIndex(@selIndex+1) if Input.repeat?(Input::RIGHT) || Input.trigger?(Input::RIGHT)
			controlSelectionIndex(@selIndex-1) if Input.repeat?(Input::LEFT) || Input.trigger?(Input::LEFT)
			
			if (Input.trigger?(Input::C) && $Trainer.seen[@dexlist[@selIndex]])
				@info = nil
				pbFadeOutIn(999999){
					hideMainDex
					dextype = "PokeDex"
					dextype = "XenoDex" if @dex == XENODEX
					dextype = "RetroDex" if @dex == RETRODEX
					@info = DexInfo.new(@dexlist[@selIndex],dextype,self)
				}
				@info.inputHandle
				pbFadeOutIn(999999){
					@info.close
					showMainDex
				}
			end
			
			if Input.trigger?(Input::A) && $Trainer.xenodex && @dex != XENODEX && @dex != RETRODEX
				@xenodex = nil
				pbFadeOutIn(999999){
					@xenodex = DexMain.new(2)
				}
				@xenodex.inputHandle
			end
			
			if (Input.trigger?(Input::Y))
				
				pbFadeOutIn(999999){
					hideMainDex
					dextype = "PokeDex"
					dextype = "XenoDex" if @dex == XENODEX
					dextype = "RetroDex" if @dex == RETRODEX
					@search = DexSearch.new(@viewport,self,dextype)
				}
				@search.handleInput
				showMainDex
				r=255
				20.times do 
					Graphics.update
					update
					r-=255/19
					@viewport.color = Color.new(0,0,0,r)
				end
			end
			
			if Input.trigger?(Input::B)
				if @savedCriteria != @standardCriteria
					pbFadeOutIn(999999){
						setList(@dex)
						@savedCriteria = @standardCriteria
						}
				else
					break
				end
			end
			
    end 
    self.endscene
  end
  
	def endscene
		@fadeout = @sprites.merge(@icons)
		pbFadeOutAndHide(@fadeout)
    pbDisposeSpriteHash(@sprites)
		pbDisposeSpriteHash(@icons)
    @viewport.dispose
	end
	
end


