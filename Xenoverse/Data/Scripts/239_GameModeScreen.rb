class GameModeScreen
	
	def initialize
		@viewport = Viewport.new(0,0,512,384)
		@viewport.z = 99999
		@viewport.color = Color.new(0,0,0,255)
		
    @undertaleAnim = false
    
		#Background quick animation
		@sense = 0
		@framecounter = 0
		@framewait = 1
		
		@path = "Graphics/Pictures/GameMode/"
		
		@selected = 0
		
		fontname = "Barlow Condensed"
		
		fontsize = $MKXP ? 26 : 28
		
		@baseColor = Color.new(248,248,248)
		@shadowColor = Color.new(28,28,28)
		
		@sprites = {}
		
		@modernDesc = _INTL("La modalità moderna permette di avere un’esperienza più leggera,\n con un sistema di esperienza più simile alle ultime generazioni.")
		
		@classicDesc = _INTL("La modalità classica permette di avere un’esperienza simile ai giochi delle vecchie generazioni, senza esperienza a tutta la squadra.")
		
		@sprites["bg"] = EAMSprite.new(@viewport)
		@sprites["bg"].bitmap = @undertaleAnim ? pbBitmap(@path + "BG") : pbBitmap("Graphics/Pictures/loadbg")
		@sprites["bg"].setZoomPoint(@sprites["bg"].bitmap.width/2,@sprites["bg"].bitmap.height/2)
		@sprites["bg"].ox = @sprites["bg"].bitmap.width/2
		@sprites["bg"].x = @sprites["bg"].ox
		
    if !@undertaleAnim
      @sprites["star1"] = Sprite.new(@viewport)
      @sprites["star1"].bitmap = pbBitmap("Graphics/Titles/star0")
      @sprites["star1"].opacity = 0
      @sprites["star2"] = Sprite.new(@viewport)
      @sprites["star2"].bitmap = pbBitmap("Graphics/Titles/star1")
      @sprites["star2"].opacity = 0
    end
		@sprites["classica"] = Sprite.new(@viewport)
		@sprites["classica"].bitmap = pbBitmap(@path + (@selected == 0 ? "Selected2" : "Normal"))
		@sprites["classica"].ox = @sprites["classica"].bitmap.width/2
    @sprites["classica"].oy = @sprites["classica"].bitmap.height/2
		@sprites["classica"].x = 256
		@sprites["classica"].y = 60
		@sprites["classica"].bitmap.font.name = fontname
		@sprites["classica"].bitmap.font.size = fontsize
		
		@sprites["moderna"] = Sprite.new(@viewport)
		@sprites["moderna"].bitmap = pbBitmap(@path + (@selected == 1 ? "Selected2" : "Normal"))
		@sprites["moderna"].ox = @sprites["moderna"].bitmap.width/2
    @sprites["moderna"].oy = @sprites["moderna"].bitmap.height/2
		@sprites["moderna"].x = 256
		@sprites["moderna"].y = 140
		@sprites["moderna"].bitmap.font.name = fontname
		@sprites["moderna"].bitmap.font.size = fontsize
		
		@sprites["infobox"] = Sprite.new(@viewport)
		@sprites["infobox"].bitmap = pbBitmap(@path + "infobox")
		@sprites["infobox"].ox = @sprites["infobox"].bitmap.width/2
		@sprites["infobox"].x = 256
		@sprites["infobox"].y = 210
		
		@sprites["classicinfo"]=Sprite.new(@viewport)
    @sprites["classicinfo"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["classicinfo"].z=9999
		@sprites["classicinfo"].x = @sprites["classica"].x
		@sprites["classicinfo"].ox = @sprites["classica"].ox
		@sprites["classicinfo"].y = @sprites["classica"].y-@sprites["classica"].bitmap.height/2
    @sprites["classicinfo"].bitmap.font.name = fontname
		@sprites["classicinfo"].bitmap.font.size = fontsize
		
		@sprites["info"]=Sprite.new(@viewport)
    @sprites["info"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["info"].z=9999
		@sprites["info"].x = 256
		@sprites["info"].ox = @sprites["infobox"].ox 
    @sprites["info"].bitmap.font.name = fontname
		@sprites["info"].bitmap.font.size = fontsize-4
		
		@info = @sprites["info"].bitmap
		
		pbDrawOutlineText(@sprites["classicinfo"].bitmap,0,0,
			@sprites["classica"].bitmap.width,@sprites["classica"].bitmap.height,
			_INTL("Classic Mode"),@baseColor,@shadowColor, 1)
		
		pbDrawOutlineText(@sprites["classicinfo"].bitmap,0,78,
			@sprites["classica"].bitmap.width,@sprites["classica"].bitmap.height,
			_INTL("Modern Mode"),@baseColor,@shadowColor, 1)
		
	#	pbDrawOutlineText(@sprites["info"].bitmap,0,0,
	#		@sprites["infobox"].bitmap.width,@sprites["infobox"].bitmap.height,
	#		@selected == 0 ? classicDesc : modernDesc,@baseColor,@shadowColor, 0)
		drawInfo(0)
		self.start
	end
	
	def update
		@sprites["bg"].update
	end
	
	def drawInfo(index = 0,maxCharPerLine=40)		
		@sprites["info"].bitmap.clear
		string = index == 0 ? @classicDesc : @modernDesc
		words = string.split(' ')
		strings = []
		
		while words.length>0
			str = ""
			i = 0
			break if words[i] == nil
			while str.length<maxCharPerLine
				break if words[i] == nil
				break if (str + words[i]).length>maxCharPerLine
				str = str + (i>0 ? " " : "") + words[i]
				i+=1
			end
			strings.push(str)
			str = ""
			words = words[i..words.length-1]	
		end
		
		for i in 0...strings.length
			pbDrawOutlineText(@sprites["info"].bitmap,20,48+28*i,
			@sprites["info"].bitmap.width,@sprites["info"].bitmap.height,
			strings[i],@baseColor,Color.new(48,48,48), 0)
		end
	end
	
	def updateBG
    if @undertaleAnim
      if @sprites["bg"].zoom_x >= 1.5 || @sprites["bg"].zoom_x <= 1
        if @framecounter < @framewait
          @framecounter+=1
        else
          @framecounter = 0
          @sense = @sense == 0 ? 1 : 0
        end
      end
      @sprites["bg"].zoom(1.5,1,90,:ease_in_out_quad) if @sense==0 && @sprites["bg"].zoom_x <= 1
      @sprites["bg"].zoom(1,1,90,:ease_in_out_quad) if @sense==1 && @sprites["bg"].zoom_x >= 1.5	
    else
      @framecounter+=1
		
      if @framecounter<20
        @sprites["star1"].opacity+=255/19
      end
      
      if @framecounter>=40 && @framecounter<60
        @sprites["star1"].opacity-=255/19
        @sprites["star2"].opacity+=255/19
      end
      
      if @framecounter>=70 && @framecounter<90
        @sprites["star2"].opacity-=255/19
      end
      
      if @framecounter>=90
        @frame = 0
      end
    end
	end
	
	def updateButtons
		@sprites["moderna"].bitmap = pbBitmap(@path + (@selected == 1 ? "Selected2" : "Normal"))
		@sprites["moderna"].ox = @sprites["moderna"].bitmap.width/2
    @sprites["moderna"].oy = @sprites["moderna"].bitmap.height/2
		@sprites["classica"].bitmap = pbBitmap(@path + (@selected == 0 ? "Selected2" : "Normal"))
		@sprites["classica"].ox = @sprites["classica"].bitmap.width/2
    @sprites["classica"].oy = @sprites["classica"].bitmap.height/2
	end
	
	def start
		r = 255
		26.times do
			r -=255/25
			@viewport.color = Color.new(0,0,0,r)
		end
		
		loop do
			Graphics.update
			Input.update
			updateBG
			update
			
			if Input.trigger?(Input::UP)
				@selected = @selected == 0 ? 1 : 0
				updateButtons
				drawInfo(@selected)
			elsif Input.trigger?(Input::DOWN)
				@selected = @selected == 0 ? 1 : 0
				updateButtons
				drawInfo(@selected)
			end
			
			if Input.trigger?(Input::C)
				$difficulty = @selected == 0 ? false : true
				break
			end
		end
		self.endscene
	end
	
	def endscene
		pbFadeOutAndHide(@sprites) { updateBG }
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
	
end