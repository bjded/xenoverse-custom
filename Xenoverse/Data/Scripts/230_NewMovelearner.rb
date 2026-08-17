class MoveRelearnerScene
  	VISIBLEMOVES = 4
	
	def fadeOut(s)
		if s
			for cmd in s.values
				cmd.fade(0,15) if defined?(cmd.fade)
			end
			15.times do
				for cmd in s.values
					cmd.update
				end
				Graphics.update
			end
		end
	end
	
	def pbDisplay(msg,brief=false)
		UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
	end

	def drawMoney
		@sprites["moneywindow"].visible=true
		@sprites["moneyoverlay"].visible = true
		@sprites["moneyoverlay"].bitmap.clear
		textpos=[]
		textpos.push([(@bpmode ? _INTL("Points") : _INTL("Money")),24,16,0,Color.new(48,48,48)])
		textpos.push([(@bpmode ? $Trainer.battle_points.to_s : "$"+$Trainer.money.to_s),225,16,1,Color.new(48,48,48)])
		pbDrawTextPositions(@sprites["moneyoverlay"].bitmap,textpos)
	end

	def hideMoney
		@sprites["moneywindow"].visible=false
		@sprites["moneyoverlay"].visible = false
	end



	def pbConfirm(msg)
		@viewport3 = Viewport.new(0,0,512,384)
			@viewport3.z = @viewport2.z+1
			@s={}
			path = "Graphics/Pictures/BagNew/"
			anchor = 496
			
			@s["box"] = EAMSprite.new(@viewport3)
			@s["box"].z = 100
			@s["box"].bitmap = pbBitmap(path + "SelectBox").clone
			@s["box"].bitmap.font = SUMMARYITEMFONT
			@s["box"].bitmap.font.size = $MKXP ? 22 : 24
			
			drawTextExH(@s["box"].bitmap,45,314,434,2,msg,Color.new(24,24,24),Color.new(24,24,24,0),22)
			@s["box"].opacity = 0
			b = pbBitmap(path + "scoption")
			bmp = Bitmap.new(88,38)
			bmp.blt(0,0,b,Rect.new(0,0,22,38))
			bmp.blt(22,0,b,Rect.new(22,0,44,38))
			bmp.blt(88-22,0,b,Rect.new(148-22,0,22,38))
			bmp.font = SUMMARYITEMFONT
			bmp.font.size = $MKXP ? 24 : 26
			@s["yes"] = EAMSprite.new(@viewport3)
			@s["yes"].bitmap = bmp.clone
			@s["yes"].ox = @s["yes"].bitmap.width
			@s["yes"].x = anchor
			@s["yes"].y = 266-40
			@s["yes"].z = 102
			@s["yes"].opacity = 0
			@s["no"] = EAMSprite.new(@viewport3)
			@s["no"].bitmap = bmp.clone
			@s["no"].ox = @s["no"].bitmap.width
			@s["no"].x = anchor
			@s["no"].y = 266
			@s["no"].z = 102
			@s["no"].opacity = 0
			
			
			
			pbDrawTextPositions(@s["yes"].bitmap,[[_INTL("Yes"),44,5,2,Color.new(24,24,24)]])
			pbDrawTextPositions(@s["no"].bitmap,[[_INTL("No"),44,5,2,Color.new(24,24,24)]])
			id = true
			
			@s["box"].fade(255,10)
			@s["yes"].fade(255,10)
			@s["no"].fade(175,10)
			
			loop do
				Graphics.update
				Input.update
				pbUpdate
				@s.values.each{|s| s.update}
				@s["yes"].move(anchor,226,7,:ease_out_cubic) if @s["yes"].y<=216
				@s["no"].move(anchor,266,7,:ease_out_cubic) if @s["no"].y<=256
				if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
					id = !id
					if id==true
						@s["yes"].fade(255,10)
						@s["no"].fade(175,10)
						@s["yes"].move(anchor,216,3,:ease_out_cubic)
					else
						@s["yes"].fade(175,10)
						@s["no"].fade(255,10)
						@s["no"].move(anchor,256,3,:ease_out_cubic)
					end
				end
				
				if Input.trigger?(Input::C)
					fadeOut(@s)
					pbDisposeSpriteHash(@s)
					return id
				end
				
				if Input.trigger?(Input::B)
					fadeOut(@s)
					pbDisposeSpriteHash(@s)
					return false
				end
			end
	end

	# Update the scene here, this is called once each frame
	def pbUpdate
		pbUpdateSpriteHash(@sprites)
			pbUpdateSpriteHash(@moves)
			if @sprites["abg"]
				@sprites["abg"].ox+=1
				@sprites["abg"].oy-=1
			end
	end
	
	def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
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
		return bitmap
	end
	
	def pbStartScene(pokemon,moves)
		@bpmode = false
		@pokemon=pokemon
		@pastmoves=moves
		moveCommands=[]
		moves.each{|i| moveCommands.push(PBMoves.getName(i)) }
		# Create sprite hash
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999
			@path = "Graphics/Pictures/Movelearner/"
		@sprites={}
		#addBackgroundPlane(@sprites,"bg","reminderbg",@viewport)
		@sprites["bg"] = EAMSprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(@path + "bg")
		
		#typebmp = pbBitmap("Graphics/Pictures/types2"+(pbGetLanguage() == 4 ? "_ita" : "_eng"))
		
		@sprites["abg"]=AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(@path + "animbg")
		@sprites["abg"].opacity = 125
		
		@sprites["ui"]=EAMSprite.new(@viewport)
		@sprites["ui"].bitmap = pbBitmap(@path + "ui")
			
		@sprites["arrows"] = EAMSprite.new(@viewport)
		@sprites["arrows"].bitmap = pbBitmap(@path + "arrows") 
			
		@sprites["pokeicon"]=EAMSprite.new(@viewport)#PokemonIconSprite.new(@pokemon,@viewport)
		@sprites["pokeicon"].bitmap = evaluateIcon(pokemon)
		@sprites["pokeicon"].ox = @sprites["pokeicon"].bitmap.width/2
		@sprites["pokeicon"].oy = @sprites["pokeicon"].bitmap.height/2
		@sprites["pokeicon"].x=333
		@sprites["pokeicon"].y=102
			
		
		
		@sprites["moneywindow"]=EAMSprite.new(@viewport)#PokemonIconSprite.new(@pokemon,@viewport)
		@sprites["moneywindow"].bitmap = pbBitmap("Graphics/Pictures/alltutor")
		@sprites["moneywindow"].visible = false
		@sprites["moneywindow"].z = 1000

		@sprites["moneyoverlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["moneyoverlay"].bitmap.font = SUMMARYITEMFONT
		@sprites["moneyoverlay"].bitmap.font.size = $MKXP ? 22 : 24
		@sprites["moneyoverlay"].z = 1000

		@sprites["moveoverlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["moveoverlay"].bitmap.font = SUMMARYITEMFONT
		@sprites["moveoverlay"].bitmap.font.size = $MKXP ? 22 : 24

		@sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay"].bitmap.font = Font.new
		@sprites["overlay"].bitmap.font.name = "Barlow Condensed"
		@sprites["overlay"].bitmap.font.size = $MKXP ? 20 : 22
		
		##drawing the types
		#@sprites["overlay"].bitmap.blt(370,110,typebmp,Rect.new(0,((22)*pokemon.type1),typebmp.width,22))
		#if pokemon.type1 != pokemon.type2
		#	@sprites["overlay"].bitmap.blt(370+84,110,typebmp,Rect.new(0,((22)*pokemon.type2),typebmp.width,22))
		#end
		textpos = []
		#header
		textpos.push([_INTL("Teach which move to {1}?",pokemon.name),256,10,2,Color.new(248,248,248)])
		#pokemon info
		textpos.push([_INTL("{1}",pokemon.name),368,72,0,Color.new(48,48,48)])
		textpos.push([sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),368,96,0,Color.new(48,48,48)])
		textpos.push([sprintf("Lv.%3d",pokemon.level),438,96,0,Color.new(48,48,48)])
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
		
		@sprites["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		textpos=[]
		textpos.push([_INTL("Category"),333,154,2,Color.new(248,248,248)])
		textpos.push([_INTL("Power"),333,179,2,Color.new(248,248,248)])
		textpos.push([_INTL("Accuracy"),333,204,2,Color.new(248,248,248)])
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
		
		textpos=[]
		#close button
		textpos.push([_INTL("Close"),476,354,1,Color.new(248,248,248)])
		@sprites["overlay"].bitmap.font.bold = true
		
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
		pbDrawMoveList
			
		drawMoveInfo(0)
		pbDeactivateWindows(@sprites)
		# Fade in all sprites
		pbFadeInAndShow(@sprites) { pbUpdate }
	end
	
	def drawMoveInfo(index)
		@sprites["moveoverlay"].bitmap.clear
		moveid = @pastmoves[index]
		movedata=PBMoveData.new(moveid)
		basedamage=movedata.basedamage
		type=movedata.type
		category=movedata.category
		accuracy=movedata.accuracy
		move=moveid
		textpos=[]
		#values
		@sprites["moveoverlay"].bitmap.blt(376,(category==0? 154 : 156),pbBitmap("Graphics/Pictures/SummaryNew/cat#{category}"),Rect.new(0,0,27,23))
		textpos.push([(basedamage<=1 ?(basedamage==1 ? "???" : "---" ): sprintf("%d",basedamage)),378,179,0,Color.new(48,48,48)])
		textpos.push([accuracy==0 ? "---" : sprintf("%d",accuracy)+"%",378,204,0,Color.new(48,48,48)])
		@sprites["moveoverlay"].bitmap.font.size = $MKXP ? 22 : 24
		pbDrawTextPositions(@sprites["moveoverlay"].bitmap,textpos)
		
		movedesc = pbGetMessage(MessageTypes::MoveDescriptions,moveid)
		@sprites["moveoverlay"].bitmap.font.size = $MKXP ? 18 : 20
		drawTextExH(@sprites["moveoverlay"].bitmap,301,230,192,4,movedesc,Color.new(48,48,48),Color.new(48,48,48,0),18)
	end
	
	def pbDrawMoveList
			@viewport2=Viewport.new(24,60,238,266)
		@viewport2.z=99999
			bmp = pbBitmap("Graphics/Pictures/EBS/Xenoverse/casellemosse_rs")
			@moves={}
			
			for i in @pastmoves
				md = PBMoveData.new(i)
				if md
					@moves["m#{i}"]=EAMSprite.new(@viewport2)
					@moves["m#{i}"].bitmap = Bitmap.new(232,25)
					@moves["m#{i}"].bitmap.blt(0,0,bmp,Rect.new(0,md.type*25,232,25))
					@moves["m#{i}"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
					@moves["m#{i}"].bitmap.font.size = $MKXP ? 16 : 18
					dark = getDarkerColor(@moves["m#{i}"].bitmap.get_pixel(50,13),0.35)
					pbDrawTextPositions(@moves["m#{i}"].bitmap,[[PBMoves.getName(i),35,3,0,Color.new(248,248,248),dark,true]]) #outlined
					@moves["m#{i}"].y=28*@pastmoves.index(i)
				end
			end
	end
	
	def setSelectedMove(index)
		for m in @moves.keys
			if m=="m#{@pastmoves[index]}"
				@moves[m].move(0,@moves[m].y,4,:ease_out_cubic)
				@moves[m].fade(255,8,:ease_out_cubic)
			else
				@moves[m].move(6,@moves[m].y,4,:ease_out_cubic)
				@moves[m].fade(155,8,:ease_out_cubic)
			end
		end
	end
	
	def scrollMoves(index)
		if @moves["m#{@pastmoves[index]}"].y>240
			for m in @pastmoves
				ypos = 28*@pastmoves.index(m)-(28*(index-8))
				echoln ypos
				
				if m==@pastmoves[index]
					@moves["m#{m}"].move(0,ypos,4,:ease_out_cubic)
				else
					@moves["m#{m}"].move(6,ypos,4,:ease_out_cubic)
				end
					
			end
		elsif @moves["m#{@pastmoves[index]}"].y<0
			for m in @pastmoves
				ypos = 28*@pastmoves.index(m)-(28*(index))
				echoln ypos
				if m==@pastmoves[index]
					@moves["m#{m}"].move(0,ypos,4,:ease_out_cubic)
				else
					@moves["m#{m}"].move(6,ypos,4,:ease_out_cubic)
				end
			end
		end
	end
	
	def wait(frames,index)
		frames.times do
			Graphics.update
			Input.update
			pbUpdate
			scrollMoves(index)
		end
	end

	# Processes the scene
	def pbChooseMove
		index=0
		setSelectedMove(index)
		drawMoveInfo(index)
		maxIndex = @moves.length-1
		loop do 
			Graphics.update
			Input.update
			pbUpdate
			scrollMoves(index)
			if index==0
				@sprites["arrows"].src_rect=Rect.new(0,192,512,192)  #only lower arrow
				@sprites["arrows"].y = 192
			elsif index==maxIndex
				@sprites["arrows"].src_rect=Rect.new(0,0,512,192)  #only upper arrow
				@sprites["arrows"].y = 0
			else
				@sprites["arrows"].src_rect=Rect.new(0,0,512,384)  #both arrows
				@sprites["arrows"].y = 0
			end

			if Input.repeat?(Input::DOWN) || Input.trigger?(Input::DOWN)
				index = index+1>maxIndex ? index : index+1
				setSelectedMove(index)
				drawMoveInfo(index)
			end

			if Input.repeat?(Input::UP) || Input.trigger?(Input::UP)
				index = index-1<0 ? index : index-1
				setSelectedMove(index)
				drawMoveInfo(index)
			end
			
			if Input.trigger?(Input::C) 
				return @pastmoves[index]
			end
			if Input.trigger?(Input::B)
				return 0
			end
		end
	end

	# End the scene here
	def pbEndScene
			merged = @sprites.merge(@moves)
		pbFadeOutAndHide(merged) { pbUpdate } # Fade out all sprites
		pbDisposeSpriteHash(merged) # Dispose all sprites
		@viewport.dispose # Dispose the viewport
			@viewport2.dispose # Dispose the viewport
	end
end

# Screen class for handling game logic
class MoveRelearnerScreen
	def initialize(scene)
	  @scene = scene
	end
  
	def pbStartScreen(pokemon)
	  moves=pbGetRelearnableMoves(pokemon)
	  @scene.pbStartScene(pokemon,moves)
	  loop do
		move=@scene.pbChooseMove
		if move<=0
		  if @scene.pbConfirm(
			_INTL("Give up trying to teach a new move to {1}?",pokemon.name))
			@scene.pbEndScene
			return false
		  end
		else
		  if @scene.pbConfirm(_INTL("Teach {1}?",PBMoves.getName(move)))
			if pbLearnMove(pokemon,move)
			  @scene.pbEndScene
			  return true
			end
		  end
		end
	  end
	end
	
	def pbStartTutorScreen(pokemon)
		mvs = pbGetTutorMoves(pokemon)
		moves=mvs[0]
		tmoves = mvs[1]
		eggmoves = mvs[2]
		@scene.pbStartScene(pokemon,moves)
		loop do
			move=@scene.pbChooseMove
			if move<=0
				if @scene.pbConfirm(
					_INTL("Give up trying to teach a new move to {1}?",pokemon.name))
					@scene.pbEndScene
					return false
				end
			else
				price = 999999999
				if tmoves.include?(move)
					price = 90000
					price -= 16000*($Trainer.numbadges-3) if $Trainer.numbadges>3
				end
				if eggmoves.include?(move)
					price = 150000
					price -= 20000*($Trainer.numbadges-3) if $Trainer.numbadges>3
				end
				@scene.drawMoney
				if @scene.pbConfirm(_INTL("You chose {1}, it will cost {2}$. Do you want to proceed?",PBMoves.getName(move),price))
					if price > $Trainer.money
						Kernel.pbMessage(_INTL("You don't have enough money."))
					else
						if pbLearnMove(pokemon,move)
							$Trainer.money -= price
							@scene.pbEndScene
							return true
						end
					end
				end
				@scene.hideMoney
			end
		end
	end
end

def pbGetTutorMoves(pokemon,recursive = true)
	return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
	moves=[]
	for move in 0...PBMoves.maxValue
		moves << move if pokemon.isCompatibleWithMove?(move)
	end
	#Added all TMs, now to add Egg Moves
	eggmoves = pokemon.possibleEggMoves
	if $preEvolutionsList == []
		pbLoadPreEvoList()
	end
	if recursive
		for sp in $preEvolutionsList[pokemon.species]
			echoln sp
			poke = pbGenerateWildPokemon(sp,5)
			poke.form = pokemon.form
			poke.makeDelta if pokemon.isDelta?
			res = pbGetTutorMoves(poke,false)
			eggmoves = eggmoves + res[2]
		end
	end
	allmoves = moves + eggmoves
	allmoves = allmoves|[]
	return [allmoves,moves,eggmoves] # remove duplicates
end

def pbTutorMoveScreen(pokemon)
  retval=true
  pbFadeOutIn(99999){
     scene=MoveRelearnerScene.new
     screen=MoveRelearnerScreen.new(scene)
     retval=screen.pbStartTutorScreen(pokemon)
  }
  return retval
end