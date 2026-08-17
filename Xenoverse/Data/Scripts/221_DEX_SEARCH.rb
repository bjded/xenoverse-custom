class DexSearch
	
	def initialize(viewport,dexmain,dextype)
		@viewport = viewport
		
		#array of procs that will filter the dex
		@criterias = []
		
		@sprites={}
		
		@dexmain = dexmain
		
		@abg = @dexmain.sprites["abg"]
		
		@types = []
		@types.push(_INTL("Normal"))
		@types.push(_INTL("Fighting"))
		@types.push(_INTL("Flying"))
		@types.push(_INTL("Poison"))
		@types.push(_INTL("Ground"))
		@types.push(_INTL("Rock"))
		@types.push(_INTL("Bug"))
		@types.push(_INTL("Ghost"))
		@types.push(_INTL("Steel"))
		@types.push(_INTL("Sound"))
		@types.push(_INTL("Fire"))
		@types.push(_INTL("Water"))
		@types.push(_INTL("Grass"))
		@types.push(_INTL("Electric"))
		@types.push(_INTL("Psychic"))
		@types.push(_INTL("Ice"))
		@types.push(_INTL("Dragon"))
		@types.push(_INTL("Dark"))
		@types.push(_INTL("Fairy"))
		
		@colors = []
		@colors.push(_INTL("Black"))
		@colors.push(_INTL("Blue"))
		@colors.push(_INTL("Brown"))
		@colors.push(_INTL("Gray"))
		@colors.push(_INTL("Green"))
		@colors.push(_INTL("Pink"))
		@colors.push(_INTL("Purple"))
		@colors.push(_INTL("Red"))
		@colors.push(_INTL("White"))
		@colors.push(_INTL("Yellow"))
		
		
		
		@fieldnames = [_INTL("Name"),_INTL("Type 1"),_INTL("Type 2"),_INTL("Height"),_INTL("Weight"),_INTL("Color"),_INTL("Shape")]
		
		@buttonTexts = [_INTL("Search"),_INTL("Reset"),_INTL("Exit")]
		
		@fieldvalues = @dexmain.savedCriteria#[nil,nil,nil,nil,nil,nil,nil]
		
		@sprites["TopBar"] = Sprite.new(@viewport)
		@sprites["TopBar"].bitmap = pbBitmap(Dex::PATH + "TopBanner_"+dextype)
		@sprites["TopBar"].z = 40
		@dexmain.setDexFont(@sprites["TopBar"].bitmap)
		pbDrawTextPositions(@sprites["TopBar"].bitmap,[[_INTL("{1}",DexCore.countSeen(@dexmain.dex)),152,12,true,Dex::MAINCOLOR],
			[_INTL("{1}",DexCore.countOwned(@dexmain.dex)),206,12,true,Dex::MAINCOLOR]])
		
		@dexmain.setDexFont(@sprites["TopBar"].bitmap,false)
		progress = _INTL("Progress")
		dexdesc = @dexmain.dex == ELDIWDEX ? _INTL("Pokédex di Eldiw") : (@dexmain.dex == XENODEX ? _INTL("Pokédex dello Xenoverse") : _INTL("Pokédex Vintage"))
		pbDrawTextPositions(@sprites["TopBar"].bitmap,[[progress,20,9,false,Dex::MAINCOLOR],
			[dexdesc,266,9,false,Dex::MAINCOLOR]])
		
		#0-6 searchfields, 7-9 function buttons
		@fieldIndex = 0
		
		for i in 0...6
			@sprites["field#{i}"] = EAMSprite.new(@viewport)
			@sprites["field#{i}"].bitmap = pbBitmap(Dex::PATH + "Field_search") if i<6
			@sprites["field#{i}"].bitmap = pbBitmap(Dex::PATH + "Shape_search") if i==6
			@sprites["field#{i}"].x = 14
			@sprites["field#{i}"].y = 58+(54*i)
			@sprites["field#{i}"].z = 40
			@sprites["field#{i}"].fade(180,20,:ease_out_cubic) if i != @fieldIndex
			updateField(i,@fieldnames[i],@fieldvalues[i]==nil ? "-" : stringField(i,@fieldvalues[i]))
		end
		
		for i in 7..9
			@sprites["button#{i}"] = EAMSprite.new(@viewport)
			@sprites["button#{i}"].bitmap = pbBitmap(Dex::PATH + "Button_search").clone
			@sprites["button#{i}"].x = 365
			@sprites["button#{i}"].y = 92 + (81*(i-7))
			@sprites["button#{i}"].bitmap.font.name = Dex::TEXTFONTNAME
			@sprites["button#{i}"].bitmap.font.size = $MKXP ? 22 : 24
			@sprites["button#{i}"].fade(180,20,:ease_out_cubic) if i != @fieldIndex
			pbDrawTextPositions(@sprites["button#{i}"].bitmap,[[@buttonTexts[i-7],52,27,2,Color.new(28,28,28)]])
		end
		
	end
	
	def stringField(i,val)
		if i == 0
			return val
		elsif i == 1 || i ==2
			return @types[val]
		elsif i == 3 || i==4
			return "#{val.begin}-#{val.end}"
		elsif i == 5
			return @colors[val-1]
		end
	end
	
	def updateSelection
		for i in 0...6
			@sprites["field#{i}"].fade(255,20,:ease_out_cubic) if i == @fieldIndex
			@sprites["field#{i}"].fade(180,20,:ease_out_cubic) if i != @fieldIndex
		end
		for i in 7..9
			@sprites["button#{i}"].fade(255,20,:ease_out_cubic) if i == @fieldIndex
			@sprites["button#{i}"].fade(180,20,:ease_out_cubic) if i != @fieldIndex
		end
	end
	
	def updateField(i, fieldname, fieldtext, fieldvalue=nil)
		@sprites["field#{i}"].bitmap = pbBitmap(Dex::PATH + "Field_search").clone if i<6
		@sprites["field#{i}"].bitmap = pbBitmap(Dex::PATH + "Shape_search").clone if i==6
		@sprites["field#{i}"].bitmap.font.name = Dex::NUMBERFONTNAME
		@sprites["field#{i}"].bitmap.font.size = $MKXP ? 22 : 24
		@fieldvalues[i] = fieldvalue
		texts = []
		texts.push([_INTL(fieldname),67,(i==6? 41 : 3),2,Color.new(248,248,248)])
		texts.push([fieldtext,207,(i==6? 41 : 3),2,Color.new(38,38,38)])
		pbDrawTextPositions(@sprites["field#{i}"].bitmap,texts)
	end
	
	def update
		for sprite in @sprites.values
			sprite.update if defined?(sprite.update)
		end
		if @abg
			@abg.ox+=Dex::ANIMBGSCROLLX
			@abg.oy+=Dex::ANIMBGSCROLLY
		end
	end
	
	def handleInput
		
		loop do
			Graphics.update
			Input.update
			update
			
			if Input.trigger?(Input::DOWN)
				@fieldIndex+=1 if @fieldIndex<5 || (@fieldIndex>6 && @fieldIndex<9)
				updateSelection
			end
			if Input.trigger?(Input::UP)
				@fieldIndex-=1 if @fieldIndex>0 && @fieldIndex != 7
				updateSelection
			end
			if Input.trigger?(Input::RIGHT)
				if @fieldIndex>=0 && @fieldIndex<2
					@fieldIndex=7 
				elsif @fieldIndex>=2 && @fieldIndex<4
					@fieldIndex=8 
				elsif @fieldIndex >= 4 && @fieldIndex<6
					@fieldIndex=9
				end
				updateSelection
			end
			if Input.trigger?(Input::LEFT)
				if @fieldIndex==7
					@fieldIndex=0
				elsif @fieldIndex==8
					@fieldIndex=3
				elsif @fieldIndex==9
					@fieldIndex=5
				end
				updateSelection
			end
			
			if Input.trigger?(Input::C)
				#Field handling
				if @fieldIndex>=0 && @fieldIndex <7
					if @fieldIndex == 0
						options = []
						default = 0
						for l in "-ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(//)
							options.push(l)
						end
						@choice = DexSearchChoice.new(@viewport,options,0)
						ret = @choice.selectChoice
						updateField(0,@fieldnames[0],options[ret],ret == 0 ? nil : options[ret])
					elsif @fieldIndex == 1
						options = []
						default = 0
						options.push(_INTL("-"))
						for type in @types
							options.push(type)
						end
						@choice = DexSearchChoice.new(@viewport,options,0)
						ret = @choice.selectChoice
						updateField(1,@fieldnames[1],options[ret],ret-1 == -1 ? nil : ret-1)
					elsif @fieldIndex == 2
						options = []
						default = 0
						options.push(_INTL("-"))
						for type in @types
							options.push(type)
						end
						@choice = DexSearchChoice.new(@viewport,options,0)
						ret = @choice.selectChoice
						updateField(2,@fieldnames[2],options[ret],ret == 0 ? nil : ret-1)
					elsif @fieldIndex == 3
						params=ChooseNumberParams.new
						params.setRange(0,999)
						params.setDefaultValue(0)
						llimit = Kernel.pbViewportMessageChooseNumber(@viewport,_INTL("Choose the lower limit."),params)
						params.setRange(llimit,999)
						params.setDefaultValue(llimit)
						ulimit = Kernel.pbViewportMessageChooseNumber(@viewport,_INTL("Choose the upper limit."),params)
						ret = llimit..ulimit
						updateField(3,@fieldnames[3],"#{llimit}-#{ulimit}",ret.begin == ret.end ? nil : ret)
					elsif @fieldIndex == 4
						params=ChooseNumberParams.new
						params.setRange(0,999)
						params.setDefaultValue(0)
						llimit = Kernel.pbViewportMessageChooseNumber(@viewport,_INTL("Choose the lower limit."),params)
						params.setRange(llimit,999)
						params.setDefaultValue(llimit)
						ulimit = Kernel.pbViewportMessageChooseNumber(@viewport,_INTL("Choose the upper limit."),params)
						ret = llimit..ulimit
						updateField(4,@fieldnames[4],"#{llimit}-#{ulimit}",ret.begin == ret.end ? nil : ret)
					elsif @fieldIndex == 5
						options = []
						default = 0
						options.push(_INTL("-"))
						options.push(_INTL("Black"))
						options.push(_INTL("Blue"))
						options.push(_INTL("Brown"))
						options.push(_INTL("Gray"))
						options.push(_INTL("Green"))
						options.push(_INTL("Pink"))
						options.push(_INTL("Purple"))
						options.push(_INTL("Red"))
						options.push(_INTL("White"))
						options.push(_INTL("Yellow"))
						@choice = DexSearchChoice.new(@viewport,options,0)
						ret = @choice.selectChoice
						updateField(5,@fieldnames[5],options[ret],ret == 0 ? nil : ret-1)
=begin
					elsif @fieldIndex == 6
						options = []
						default = 0
						options.push(_INTL("-"))
						options.push(_INTL("Head-only"))
						options.push(_INTL("Serpent-like"))
						options.push(_INTL("Fish"))
						options.push(_INTL("Head and arms"))
						options.push(_INTL("Head and base"))
						options.push(_INTL("Tailed bipedal"))
						options.push(_INTL("Head and legs"))
						options.push(_INTL("Quadruped"))
						options.push(_INTL("Has two wings"))
						options.push(_INTL("Tentacles"))
						options.push(_INTL("Multiple bodies"))
						options.push(_INTL("Humanoid"))
						options.push(_INTL("Winged insectoid"))
						options.push(_INTL("Insectoid"))
						@choice = DexSearchChoice.new(@viewport,options,0)
						ret = @choice.selectChoice
						updateField(6,"Shape",ret==0 ? "-" : "",ret == 0 ? nil : ret)
						@sprites["field6"].bitmap.blt(180,26,pbBitmap(Dex::PATH+"icon_shapes"),Rect.new(0,60*(ret-1),60,60)) if ret>0
=end
					end
				else
					if @fieldIndex == 7 #Search
						newlist = applyCriteria
						if newlist.length>0
							pbFadeOutIn(999999){
								@dexmain.setList(newlist) if newlist != @dexmain.dex
								@dexmain.savedCriteria = @fieldvalues
								@viewport.color = Color.new(0,0,0,255)
							}
							break
						else
							msgwindow=Kernel.pbCreateMessageWindow(@viewport,nil)
							msgwindow.z = 9999
							Kernel.pbMessageDisplay(msgwindow,_INTL("No Pokémon found."),{})
							Kernel.pbDisposeMessageWindow(msgwindow)
							Input.update
						end
					elsif @fieldIndex == 8 #reset
						for i in 0...6
							updateField(i,@fieldnames[i],"-",nil)
						end
					elsif @fieldIndex == 9 #exit
						pbFadeOutIn(999999){
							@dexmain.setList(@dexmain.dex)
							@dexmain.savedCriteria = [nil,nil,nil,nil,nil,nil,nil]
							@viewport.color = Color.new(0,0,0,255)
						}
						break
					end
				end
			end
			
			if Input.trigger?(Input::B)
				pbFadeOutIn(999999){
					@dexmain.setList(@dexmain.dex)
					@dexmain.savedCriteria = [nil,nil,nil,nil,nil,nil,nil]
					@viewport.color = Color.new(0,0,0,255)
				}
				break
			end
			
		end
		
		pbDisposeSpriteHash(@sprites)
	end
	
	def applyCriteria
		list = @dexmain.dex
		for value in 0...@fieldvalues.length
			next if @fieldvalues[value] == nil || !@fieldvalues[value]
			list = list.select{|s| evaluateSpecies(s,value)}
		end
		return list
	end
	
	def evaluateSpecies(species,value)
		if value == 0
			return (PBSpecies.getName(species)[0,1] == @fieldvalues[value] && $Trainer.seen[species])
		end
		if value == 1
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,8)
			type1 = (dexdata.fgetb)
			dexdata.close
			return type1 == @fieldvalues[value] && $Trainer.seen[species]
		end
		if value == 2
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,8)
			type1 = (dexdata.fgetb)
			type2 = (dexdata.fgetb)
			dexdata.close
			return type2 == @fieldvalues[value] && $Trainer.seen[species]
		end
		if value == 3
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,8)
			type1 = (dexdata.fgetb)
			type2 = (dexdata.fgetb)
			pbDexDataOffset(dexdata,species,33)
			height=dexdata.fgetw
			dexdata.close
			return height >= @fieldvalues[value].begin && height<=@fieldvalues[value].end && $Trainer.seen[species]
		end
		if value == 4
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,8)
			type1 = (dexdata.fgetb)
			type2 = (dexdata.fgetb)
			pbDexDataOffset(dexdata,species,33)
			height=dexdata.fgetw
			weight=dexdata.fgetw
			dexdata.close
			return weight >= @fieldvalues[value].begin && weight<=@fieldvalues[value].end && $Trainer.seen[species]
		end
		if value == 5
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,6)
			color=dexdata.fgetb
			dexdata.close
			return color == @fieldvalues[value] && $Trainer.seen[species]
		end
=begin
		if value == 6
			dexdata = pbOpenDexData
			pbDexDataOffset(dexdata,species,6)
		  color=dexdata.fgetb
			dexdata.close
			return color == @fieldvalues[value] && $Trainer.seen[species]
		end
=end
	end
	
end

class DexSearchChoice
	
	def initialize(viewport,options,default)
		@viewport = viewport
		@sprites = {}
		
		@input = options
		
		@default = default
		
		@sprites["choicebg"] = Sprite.new(@viewport)
		@sprites["choicebg"].bitmap = pbBitmap(Dex::PATH + "ChoiceBG")
		@sprites["choicebg"].x = 325
		@sprites["choicebg"].z = 50
		
		@sprites["carrow"] = EAMSprite.new(@viewport)
		@sprites["carrow"].bitmap = pbBitmap(Dex::PATH + "ChooseArrow")
		@sprites["carrow"].x = 304
		@sprites["carrow"].y = 167
		@sprites["carrow"].z = 51
		
		@selectionIndex = @default
		@options={}
		for option in options
			@options[option] = EAMSprite.new(@viewport)
			@options[option].bitmap = Bitmap.new(30*option.length,30)
			#@options[option].bitmap.fill_rect(0,0,@options[option].bitmap.width,@options[option].bitmap.height-5,Color.new(255,0,0))
			@options[option].bitmap.font.name = Dex::TEXTFONTNAME
			@options[option].bitmap.font.size = $MKXP ? 24 : 26
			@options[option].ox = @options[option].bitmap.width/2
			@options[option].oy = 15
			@options[option].x = 409
			@options[option].y = 192 + 30*options.index(option) - 30*@selectionIndex
			@options[option].z = 51
			pbDrawTextPositions(@options[option].bitmap,[[option,@options[option].ox,6,2,Color.new(248,248,248),Color.new(0,0,0),true]])
		end
		
	end
	
	def update
		for option in @options.values
			option.update
		end
		@sprites["carrow"].move(274,51,20,:ease_in_out_cubic) if @sprites["carrow"].x == 304
		@sprites["carrow"].move(304,51,20,:ease_in_out_cubic) if @sprites["carrow"].x == 274
	end
	
	
	def updateOptionPositions
		for option in @input
			@options[option].move(409,192 + 30*@input.index(option) - 30*@selectionIndex,20,:ease_in_out_cubic)
		end
	end
	
	def selectChoice
		ret = nil
		loop do
			Graphics.update
			Input.update
			update
			
			if Input.trigger?(Input::UP)
				@selectionIndex -= 1
				@selectionIndex = @options.length-1 if @selectionIndex<0
				updateOptionPositions
			end
			
			if Input.trigger?(Input::DOWN)
				@selectionIndex += 1
				@selectionIndex = 0 if @selectionIndex>=@options.length
				updateOptionPositions
			end
			
			if Input.trigger?(Input::C)
				ret = @selectionIndex
				break
			end
			
			if Input.trigger?(Input::B)
				ret = @default
				break
			end
		end
		20.times do
			for sprite in @sprites.merge(@options).values
				sprite.opacity-=255/19
			end
			Graphics.update
		end
		return ret
	end
	
end