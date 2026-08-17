class SceltaStarter
  
  STARTERLEVEL = 5
  
  def initialize(pkmn1, pkmn2, pkmn3, mode = 0)
		@oldfr = Graphics.frame_rate
		Graphics.frame_rate = 60
    @pkmn1=pkmn1; @pkmn2=pkmn2; @pkmn3=pkmn3
		
    @mode = mode
    @select=1
    @selected = false
    @confirm = 1
		
		@folder = mode == 0 ? "Graphics/Pictures/SceltaStarter/" : "Graphics/Pictures/SceltaStarter2/"
		
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    
		typebmp = pbBitmap($PokemonSystem.language == 0 ? "Graphics/Pictures/types2_ita" : "Graphics/Pictures/types2_eng")
    
    detfontsize = $MKXP ? 26 : 28

    # BACKGROUNDS
    @sprites["bg"]=IconSprite.new(0,0,@viewport)    
    @sprites["bg"].setBitmap(@folder+"bg")
    @sprites["bg"].opacity=0
    
    @sprites["blurBg"]=IconSprite.new(0,0,@viewport)
    @sprites["blurBg"].setBitmap(@folder+"blurBg")
    @sprites["blurBg"].opacity = 0
    
		@sprites["lb"]=IconSprite.new(0,0,@viewport)
    @sprites["lb"].setBitmap(@folder+"lowerbar")
    @sprites["lb"].y = 284
		
    #SHULONG
    @sprites["shulong"] = IconSprite.new(0,0,@viewport)
    @sprites["shulong"].setBitmap(@folder+"shulong")
    @sprites["shulong"].x = 345
    @sprites["shulong"].y = 54
    @sprites["shulong"].opacity = 0
    
    @sprites["shulongSel"]=IconSprite.new(0,0,@viewport)
    @sprites["shulongSel"].setBitmap(@folder+"shulongSel")
    @sprites["shulongSel"].x = 345
    @sprites["shulongSel"].y = 54
    @sprites["shulongSel"].opacity = 0
    
    @sprites["shulongDet"]=Sprite.new(@viewport)
    #@sprites["shulongDet"].setBitmap(@folder+"shulongDet")
		@sprites["shulongDet"].bitmap = Bitmap.new(512,384)
    @sprites["shulongDet"].y = 0
		@sprites["shulongDet"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["shulongDet"].bitmap.font.size = detfontsize
    @sprites["shulongDet"].visible = false
		pbDrawTextPositions(@sprites["shulongDet"].bitmap,[[PBSpecies.getName(@pkmn3),256,294,2,Color.new(248,248,248)]])
		pk = PokeBattle_Pokemon.new(@pkmn3,5,$Trainer)
		if pk.type1==pk.type2 #monotype
			@sprites["shulongDet"].bitmap.blt(220,330,typebmp,Rect.new(0,22*pk.type1,81,22))
		else
			@sprites["shulongDet"].bitmap.blt(256-86,330,typebmp,Rect.new(0,22*pk.type1,81,22))
			@sprites["shulongDet"].bitmap.blt(256+5,330,typebmp,Rect.new(0,22*pk.type2,81,22))
		end
    
    # SHYLEON
    @sprites["shyleon"]=IconSprite.new(0,0,@viewport)
    @sprites["shyleon"].setBitmap(@folder+"shyleon")
    @sprites["shyleon"].x = 19
    @sprites["shyleon"].y = 54
    @sprites["shyleon"].opacity = 0
    
    @sprites["shyleonSel"]=IconSprite.new(0,0,@viewport)
    @sprites["shyleonSel"].setBitmap(@folder+"shyleonSel")
    @sprites["shyleonSel"].x = 19
    @sprites["shyleonSel"].y = 54
    @sprites["shyleonSel"].opacity = 0
    
    @sprites["shyleonDet"]=Sprite.new(@viewport)
		@sprites["shyleonDet"].bitmap = Bitmap.new(512,384)
    #@sprites["shyleonDet"].setBitmap(@folder+"shyleonDet")
    @sprites["shyleonDet"].y = 0
    @sprites["shyleonDet"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["shyleonDet"].bitmap.font.size = detfontsize
    @sprites["shyleonDet"].visible = false
		pbDrawTextPositions(@sprites["shyleonDet"].bitmap,[[PBSpecies.getName(@pkmn1),256,294,2,Color.new(248,248,248)]])
		pk = PokeBattle_Pokemon.new(@pkmn1,5,$Trainer)
		if pk.type1==pk.type2 #monotype
			@sprites["shyleonDet"].bitmap.blt(220,330,typebmp,Rect.new(0,22*pk.type1,81,22))
		else
			@sprites["shyleonDet"].bitmap.blt(256-86,330,typebmp,Rect.new(0,22*pk.type1,81,22))
			@sprites["shyleonDet"].bitmap.blt(256+5,330,typebmp,Rect.new(0,22*pk.type2,81,22))
		end
		
    # TRISHOUT
    @sprites["trishout"]=IconSprite.new(0,0,@viewport)
    @sprites["trishout"].setBitmap(@folder+"trishout")
    @sprites["trishout"].x = 182
    @sprites["trishout"].y = 54
    @sprites["trishout"].opacity = 0
    
    @sprites["trishoutSel"]=IconSprite.new(0,0,@viewport)
    @sprites["trishoutSel"].setBitmap(@folder+"trishoutSel")
    @sprites["trishoutSel"].x = 182
    @sprites["trishoutSel"].y = 54
    @sprites["trishoutSel"].opacity = 0
    
    @sprites["trishoutDet"]=Sprite.new(@viewport)
		@sprites["trishoutDet"].bitmap = Bitmap.new(512,384)
    #@sprites["trishoutDet"].setBitmap(@folder+"trishoutDet")
    @sprites["trishoutDet"].y = 0
    @sprites["trishoutDet"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["trishoutDet"].bitmap.font.size = detfontsize
    @sprites["trishoutDet"].visible = false
		pbDrawTextPositions(@sprites["trishoutDet"].bitmap,[[PBSpecies.getName(@pkmn2),256,294,2,Color.new(248,248,248)]])
		pk = PokeBattle_Pokemon.new(@pkmn2,5,$Trainer)
		if pk.type1==pk.type2 #monotype
			@sprites["trishoutDet"].bitmap.blt(220,330,typebmp,Rect.new(0,22*pk.type1,81,22))
		else
			@sprites["trishoutDet"].bitmap.blt(256-86,330,typebmp,Rect.new(0,22*pk.type1,81,22))
			@sprites["trishoutDet"].bitmap.blt(256+5,330,typebmp,Rect.new(0,22*pk.type2,81,22))
		end
		
    # CONFIRM
    @sprites["confirm"]=IconSprite.new(0,0,@viewport)
		@sprites["confirm"].bitmap = Bitmap.new(512,384)
    #@sprites["confirm"].setBitmap(@folder+"confirm")
    @sprites["confirm"].x = 0
    @sprites["confirm"].y = 0
    @sprites["confirm"].opacity = 0
		@sprites["confirm"].bitmap.font.name = "Barlow Condensed"
		@sprites["confirm"].bitmap.font.size = 24
		#pbDrawTextPositions(@sprites["confirm"].bitmap,[[_INTL("Vuoi scegliere {1} come tuo compagno di avventura?",),256,310,2,Color.new(248,248,248)]])
    
    # SI
    @sprites["si"]=IconSprite.new(0,0,@viewport)
    @sprites["si"].bitmap = pbBitmap(@folder+"notsel").clone#setBitmap(@folder+"notsel")
		@sprites["si"].ox = @sprites["si"].bitmap.width/2
		@sprites["si"].oy = @sprites["si"].bitmap.height/2
    @sprites["si"].x = 467
    @sprites["si"].y = 226
    @sprites["si"].opacity = 0
		@sprites["si"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["si"].bitmap.font.size = $MKXP ? 22 : 24
		pbDrawTextPositions(@sprites["si"].bitmap,[[_INTL("Sì"),40,6,2,Color.new(119,119,119)]])
    
    @sprites["siSel"]=IconSprite.new(0,0,@viewport)
    @sprites["siSel"].bitmap = pbBitmap(@folder+"sel").clone#setBitmap(@folder+"sel")
    @sprites["siSel"].opacity = 0
		@sprites["siSel"].ox = @sprites["siSel"].bitmap.width/2
		@sprites["siSel"].oy = @sprites["siSel"].bitmap.height/2
    @sprites["siSel"].x = 467
    @sprites["siSel"].y = 226
    @sprites["siSel"].visible = false
		@sprites["siSel"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["siSel"].bitmap.font.size = $MKXP ? 22 : 24
    pbDrawTextPositions(@sprites["siSel"].bitmap,[[_INTL("Sì"),40,6,2,Color.new(60,59,54)]])
		
    # NO
    @sprites["no"]=IconSprite.new(0,0,@viewport)
    @sprites["no"].bitmap = pbBitmap(@folder+"notsel").clone #setBitmap(@folder+"notsel")
		@sprites["no"].ox = @sprites["no"].bitmap.width/2
		@sprites["no"].oy = @sprites["no"].bitmap.height/2
    @sprites["no"].x = 467
    @sprites["no"].y = 264
    @sprites["no"].opacity = 0
		@sprites["no"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["no"].bitmap.font.size = $MKXP ? 22 : 24
    pbDrawTextPositions(@sprites["no"].bitmap,[[_INTL("No"),40,6,2,Color.new(119,119,119)]])
		
    @sprites["noSel"]=IconSprite.new(0,0,@viewport)
    @sprites["noSel"].bitmap = pbBitmap(@folder+"sel").clone#setBitmap(@folder+"sel")
    @sprites["noSel"].opacity = 0
		@sprites["noSel"].ox = @sprites["siSel"].bitmap.width/2
		@sprites["noSel"].oy = @sprites["siSel"].bitmap.height/2
    @sprites["noSel"].x = 467
    @sprites["noSel"].y = 264
    @sprites["noSel"].visible = false
		@sprites["noSel"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["noSel"].bitmap.font.size = $MKXP ? 22 : 24
		pbDrawTextPositions(@sprites["noSel"].bitmap,[[_INTL("No"),40,6	,2,Color.new(60,59,54)]])
    
    # DATAS
    @data={}
    @data["pkmn_0"]=PokeBattle_Pokemon.new(@pkmn1,STARTERLEVEL)
    @data["pkmn_1"]=PokeBattle_Pokemon.new(@pkmn2,STARTERLEVEL)
    @data["pkmn_2"]=PokeBattle_Pokemon.new(@pkmn3,STARTERLEVEL)
    @pokemon=@data["pkmn_#{@select}"]    
    self.openscene
  end
  
  def openscene
    25.times do
      @sprites["bg"].opacity+=10.2
      pbWait(2)
    end
    25.times do
      @sprites["blurBg"].opacity+=10.2
      @sprites["shulong"].opacity += 10.2
      @sprites["shulongSel"].opacity += 10.2
      @sprites["shyleon"].opacity += 10.2
      @sprites["shyleonSel"].opacity += 10.2
      @sprites["trishout"].opacity += 10.2
      @sprites["trishoutSel"].opacity += 10.2
      pbWait(1)
    end
    self.gettinginput
    self.input_action
  end
  
  def closescene
    pbFadeOutIn(99999) {
      @sprites["bg"].opacity = 0
      @sprites["blurBg"].opacity = 0
      @sprites["shulong"].opacity = 0
      @sprites["shulongSel"].opacity = 0
      @sprites["shulongDet"].opacity = 0
      @sprites["shyleon"].opacity = 0
      @sprites["shyleonSel"].opacity = 0
      @sprites["shyleonDet"].opacity = 0
      @sprites["trishout"].opacity = 0
      @sprites["trishoutSel"].opacity = 0
      @sprites["trishoutDet"].opacity = 0
      @sprites["confirm"].opacity = 0
      @sprites["si"].opacity = 0
      @sprites["siSel"].opacity = 0
      @sprites["no"].opacity = 0
      @sprites["noSel"].opacity = 0
			@sprites["lb"].opacity = 0
    }
		Graphics.frame_rate = @oldfr
  end
  
  def gettinginput
    pokemon=[@pkmn1, @pkmn2, @pkmn3]
    if !@selected
      if Input.trigger?(Input::RIGHT)  && @select <3
        @select+=1
      elsif Input.trigger?(Input::LEFT) && @select >0
        @select-=1
      end
    else
      if Input.trigger?(Input::DOWN) && @confirm < 1
        @confirm += 1
      elsif Input.trigger?(Input::UP) && @confirm > 0
        @confirm -= 1
      end
    end
    if Input.trigger?(Input::C) && !@selected
      @selected = true
      @sprites["noSel"].visible = true
      pbSEPlay(sprintf("%03dCry",pokemon[@select]),100)
			@sprites["confirm"].bitmap.clear
			pbDrawTextPositions(@sprites["confirm"].bitmap,[[_INTL("Vuoi scegliere {1} come tuo compagno di avventura?",PBSpecies.getName(pokemon[@select])),256,310,2,Color.new(248,248,248)]])
      25.times do
				Graphics.update
				Input.update
				@sprites["shulongDet"].opacity-=10.2
				@sprites["shyleonDet"].opacity-=10.2
				@sprites["trishoutDet"].opacity-=10.2
        @sprites["confirm"].opacity += 10.2
        @sprites["si"].opacity += 10.2
        @sprites["siSel"].opacity += 10.2
        @sprites["no"].opacity += 10.2
        @sprites["noSel"].opacity += 10.2
      end
    else
      if Input.trigger?(Input::C)
        if @confirm == 1
          25.times do
						Graphics.update
						Input.update
						@sprites["shulongDet"].opacity+=10.2
						@sprites["shyleonDet"].opacity+=10.2
						@sprites["trishoutDet"].opacity+=10.2
            @sprites["confirm"].opacity -= 10.2
            @sprites["si"].opacity -= 10.2
            @sprites["siSel"].opacity -= 10.2
            @sprites["no"].opacity -= 10.2
            @sprites["noSel"].opacity -= 10.2
          end
          @selected = false
        else
          @pokemon = @data["pkmn_#{@select}"]
          $game_switches[7] = true
          $game_switches[(@mode==0 ? 51 + @select : 612+@select)] = true
          self.closescene
        end
      end
    end
  end
  
  def input_action
    while !$game_switches[7]
      Graphics.update
      Input.update
      self.gettinginput
      if !@selected
        if @select == 0
          @sprites["shulongSel"].visible = false
          @sprites["shulongDet"].visible = false
          @sprites["shyleonSel"].visible = true
          @sprites["shyleonDet"].visible = true
          @sprites["trishoutSel"].visible = false
          @sprites["trishoutDet"].visible = false
        elsif @select == 1
          @sprites["shulongSel"].visible = false
          @sprites["shulongDet"].visible = false
          @sprites["shyleonSel"].visible = false
          @sprites["shyleonDet"].visible = false
          @sprites["trishoutSel"].visible = true
          @sprites["trishoutDet"].visible = true
        else
          @sprites["shulongSel"].visible = true
          @sprites["shulongDet"].visible = true
          @sprites["shyleonSel"].visible = false
          @sprites["shyleonDet"].visible = false
          @sprites["trishoutSel"].visible = false
          @sprites["trishoutDet"].visible = false
        end
      else
        if @confirm == 0
          @sprites["siSel"].visible = true
          @sprites["noSel"].visible = false
        else
          @sprites["siSel"].visible = false
          @sprites["noSel"].visible = true
        end
      end
    end
  end
  
end