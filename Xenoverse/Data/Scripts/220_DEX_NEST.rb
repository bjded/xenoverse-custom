class DexNest
	
	def initialize(viewport,species)
		@viewport = viewport
		@sprites={}
		@frame = 60
		@maxframe = 80
		@species = species
		pointsize = 16
		
		@sprites["region"] = Sprite.new(@viewport)
		@sprites["region"].z = 40
		
		@sprites["region"].bitmap = pbBitmap("Graphics/Pictures/mapRegion0")
		
		@monsterIcon = pbBitmap("Graphics/Pictures/monsterIcon")
		@xsize = 512/pointsize
		@ysize = 384/pointsize
		
		@sprites["daytime"] = Sprite.new(@viewport)
		@sprites["daytime"].z = 50
		@sprites["daytime"].x = 12
		@sprites["daytime"].y = Graphics.height - 35 - 12

		@points = {}
		for y in 0..@ysize
			@points[y] = Hash.new
			for x in 0..@xsize
				@points[y][x] = Sprite.new(@viewport)
				@points[y][x].z = 41
				@points[y][x].x = x*pointsize
				@points[y][x].y = y*pointsize
				@points[y][x].zoom_x = 0.5
				@points[y][x].zoom_y = 0.5
			end
		end
		
		pbRgssOpen("Data/townmap.dat","rb"){|f|
			@mapdata=Marshal.load(f)
		}
		@region = 0
		loadEncounters(true)
		#echoln points
		
	end
	
	def loadEncounters(day=true)
		echoln "#{day ? "DAY" : "NIGHT"}"
		@sprites["daytime"].bitmap = pbBitmap("Graphics/Pictures/DexNew/#{(day ? "nestday" : "nestnight")}")
		if @sprites["unknown"] && @sprites["unknown"].is_a?(Sprite)
			@sprites["unknown"].dispose
		end
		
		for y in 0..@ysize
			for x in 0..@xsize
				if @points[y][y] != nil
					@points[y][x].bitmap.clear if @points[y][x].bitmap != nil
				end
			end
		end
		encdata=load_data("Data/encounters.dat")
		points=[]
		mapwidth=1+PokemonRegionMapScene::RIGHT-PokemonRegionMapScene::LEFT
		for enc in encdata.keys
			enctypes=encdata[enc][1]
			if (day ? pbFindEncounterDay(enctypes,@species) : pbFindEncounterNight(enctypes,@species))
				mappos=pbGetMetadata(enc,MetadataMapPosition)
				if mappos && mappos[0]==@region
					showpoint=true
					for loc in @mapdata[@region][2]
						showpoint=false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
						loc[7] && !$game_switches[loc[7]]
					end
					if showpoint
						mapsize=pbGetMetadata(enc,MetadataMapSize)
						if mapsize && mapsize[0] && mapsize[0]>0
							sqwidth=mapsize[0]
							sqheight=(mapsize[1].length*1.0/mapsize[0]).ceil
							for i in 0...sqwidth
								for j in 0...sqheight
									if mapsize[1][i+j*sqwidth,1].to_i>0
										points[mappos[1]+i+(mappos[2]+j)*mapwidth]=true
									end
								end
							end
						else
							points[mappos[1]+mappos[2]*mapwidth]=true
						end
					end
				end
			end
		end
		echoln "Length #{@points.length} #{points.length}" 
		if points.include?(true)
			for point in 0...points.length
				@points[point/@xsize][point% (@xsize)].bitmap = @monsterIcon.clone if points[point]
			end
		else
			@sprites["unknown"] = Sprite.new(@viewport)
			@sprites["unknown"].z = 42
			@sprites["unknown"].bitmap = pbBitmap(Dex::PATH + "unknownBG")
			@sprites["unknown"].bitmap.font.name = "Barlow Condensed"
			@sprites["unknown"].bitmap.font.size = $MKXP ? 28 : 30
			pbDrawTextPositions(@sprites["unknown"].bitmap,[[_INTL("Unknown"),256,177,2,Color.new(248,248,248)]])
		end
	end

	def update
		@frame+=1
		if @frame > @maxframe
			@frame = 0
		end
		for y in 0..@ysize
			for x in 0..@xsize
				if @points[y][x] && @points[y][x].bitmap
					@points[y][x].opacity-=255/19 if @frame>=60
					@points[y][x].opacity+=255/19 if @frame<=20
				end
			end
		end
		
	end
	
	
	def close
		pbDisposeSpriteHash(@sprites)
		for hash in @points.values
			pbDisposeSpriteHash(hash)
		end
	end
end

def pbFindEncounterDay(encounter,species)
	return false if !encounter
	for i in 0...encounter.length
		next if !encounter[i] || i==11
		for j in 0...encounter[i].length
			return true if encounter[i][j][0]==species
		end
	end
	return false
end

def pbFindEncounterNight(encounter,species)
	return false if !encounter
	for i in 0...encounter.length
		next if !encounter[i] || ![0,1,2,3,4,5,6,11].include?(i)#(i!=11 && i!=0)
		for j in 0...encounter[i].length
			return true if encounter[i][j][0]==species
		end
	end
	return false
end