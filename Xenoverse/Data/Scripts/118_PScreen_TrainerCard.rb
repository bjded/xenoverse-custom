class PokemonTrainerCardScene

  #Switch lega 576 scheda blu, scheda oro pokedex completato
  
  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @retro=false
    @gymnames=["Alisso","Claudio","Mimosa","Verbena","Crisante","Wallace Daddy","Henné","Surge"]
    @gymcity=["Balansopoli","Campus Ariepoli","Regno di Virgopoli","Aquariopoli","Scorpiopoli","Leopoli","Sagittopoli","Aranciopoli"]
    @badgename=["Radice","Competizione","Zucchero","Marea","El Purgatorio","Ritmo","Circo Sirio","Vecchia Palestra Tuono"]
    @obtBadge=[]
    @basecolor=Color.new(245,245,245)
    @outline=Color.new(20,20,20)
    for i in 0...$Trainer.badges.length
      if $Trainer.badges[i]==true
        @obtBadge.push($Trainer.badges[i])
      else
      end
    end
    
    @bitmap=[pbBitmap("Graphics/Pictures/badge2/scheda"),#pbBitmap("Graphics/Pictures/badge")
    ]
    background=pbResolveBitmap(sprintf("Graphics/Pictures/SchedatrainerF"))
    if $Trainer.isFemale? && background
      if $game_switches[576] && $Trainer.pokedexOwned(0) == pbAllRegionalSpecies(0)
        
      elsif $game_switches[576]
        addBackgroundPlane(@sprites,"bg","SchedatrainerFlega",@viewport)
      else
        addBackgroundPlane(@sprites,"bg","SchedatrainerF",@viewport)
      end
    else
      addBackgroundPlane(@sprites,"bg","trainercardbg",@viewport)
    end
    cardexists=pbResolveBitmap(sprintf("Graphics/Pictures/SchedatrainerF"))
    card = ""
    echo $Trainer.pokedexOwned(0)
    echo "\n"
    echo pbAllRegionalSpecies(0).length
    echo $Trainer.pokedexOwned(0) >= pbAllRegionalSpecies(0).length
    if $game_switches[576] && pbSCELDIW(false) >=  getEldiwDexChecks(true).length
      card = "pokedex"
    elsif $game_switches[576]
      card = "lega"
    end
    if $Trainer.isFemale? && cardexists
      @sprites["card"]=CardSprite.new(@viewport,"Graphics/Pictures/SchedatrainerF" + card,256,-5,256)
    else
      @sprites["card"]=CardSprite.new(@viewport,"Graphics/Pictures/SchedatrainerM" + card,256,-5,256)
    end
		
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].ox=256
    @sprites["overlay"].x=256
    @sprites["overlayc"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlayc"].ox=256
    @sprites["overlayc"].x=256
    @sprites["selector"]=TrainerCardSelector.new(@viewport,20,78)
    @sprites["selector"].z=20
    @sprites["selector"].visible=false
    @sprites["sfade"]=Sprite.new(@viewport)
    @sprites["sfade"].bitmap=Bitmap.new(512,384)
    @sprites["sfade"].bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
    @sprites["sfade"].opacity=0
    @sprites["sfade"].z=9999
    @sprites["medals"]=Sprite.new(@viewport)
    @sprites["medals"].bitmap=@bitmap[0]
    @sprites["medals"].z=7
    @sprites["medals"].visible=@retro
    for i in 0...@obtBadge.length
      if @obtBadge.length>0
      @sprites["badge#{i}"]=Sprite.new(@viewport)
      @sprites["badge#{i}"].bitmap=pbBitmap("Graphics/Pictures/badge2/badge#{i}")
      @sprites["badge#{i}"].visible=@retro
      @sprites["badge#{i}"].z=10
      if $Trainer.badges[i]
        @sprites["badge#{i}"].opacity=255
      else
        @sprites["badge#{i}"].opacity=0
      end
      else
      end
    end
    @sprites["bar"]=EAMSprite.new(@viewport)
		@sprites["bar"].bitmap=pbBitmap("Graphics/Pictures/trcardbar").clone
		@sprites["bar"].y=345
		@sprites["bar"].bitmap.font.name="Barlow Condensed"
		@sprites["bar"].bitmap.font.size = 26
		@sprites["bar"].bitmap.font.bold = true
		@sprites["bar"].z = 20
		pbDrawTextPositions(@sprites["bar"].bitmap,[[_INTL("Badges"),472,2,1,Color.new(248,248,248)]])
    #if $Trainer.badges[0]==true
    #  @sprites["badge0"].visible=true
    #else
    #  @sprites["badge0"].visible=false
    #end
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTrainerCardFront
    if $PokemonGlobal.trainerRecording
      $PokemonGlobal.trainerRecording.play
    end
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawTrainerCardFront
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time=_ISPRINTF("{1:02d}:{2:02d}",hour,min)
    $PokemonGlobal.startTime=pbGetTimeNow if !$PokemonGlobal.startTime
    starttime=_ISPRINTF("{1:s} {2:d}, {3:d}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    pubid=sprintf("%05d",$Trainer.publicID($Trainer.id))
    baseColor=Color.new(250,250,250)
    shadowColor=Color.new(80,80,80)
    outline=Color.new(50,35,135)
    textPositions=[
       [_INTL("Nome"),14,60,0,baseColor,shadowColor],
       [_INTL("{1}",$Trainer.name),252,60,1,baseColor,shadowColor],
       [_INTL("ID No."),332,64,0,baseColor,shadowColor],
       [_INTL("{1}",pubid),468,64,1,baseColor,shadowColor],
       [_INTL("Soldi"),14,98,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money),252,98,1,baseColor,shadowColor],
       [_INTL("Pokédex"),14,136,0,baseColor,shadowColor],
       [_ISPRINTF("{1:d}/{2:d}",$Trainer.pokedexOwned,$Trainer.pokedexSeen),242,136,1,baseColor,shadowColor],
       [_INTL("Tempo"),14,274,0,baseColor,shadowColor],
       [time,247,274,1,baseColor,shadowColor],
       [_INTL("Inizio"),14,312,0,baseColor,shadowColor],
       [starttime,252,312,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    x=72
    region=pbGetCurrentRegion(0) # Get the current region
    imagePositions=[]
    x=33
    pbDrawImagePositions(overlay,imagePositions)
  end

  def pbTrainerCard
    @index=0
    @lookbadge=false
    loop do
      Graphics.update
      Input.update
      self.update
      
      if Input.trigger?(Input::A) #&& @obtBadge.length>0
        10.times do 
          @sprites["sfade"].opacity+=25.5
          Graphics.update
          Input.update
          update
        end
				@sprites["bar"].bitmap.clear
				@sprites["bar"].bitmap=pbBitmap("Graphics/Pictures/trcardbarx").clone
				@sprites["bar"].bitmap.font.name="Barlow Condensed"
				@sprites["bar"].bitmap.font.size = 26
				@sprites["bar"].bitmap.font.bold = true
				pbDrawTextPositions(@sprites["bar"].bitmap,[[_INTL("Back"),472,2,1,Color.new(248,248,248)]])
        @retro=true
        @sprites["medals"].visible=true
        if @obtBadge.length>0
        for i in 0...@obtBadge.length
          @sprites["badge#{i}"].visible=true
        end
        end
        10.times do
          @sprites["sfade"].opacity-=25.5
          Graphics.update
          Input.update
          update
        end
        loop do 
          Graphics.update
          Input.update
          self.update
          if Input.trigger?(Input::LEFT)
            @index-=1
            pbPlayDecisionSE()
          elsif Input.trigger?(Input::RIGHT)
            @index+=1
            pbPlayDecisionSE()
          end
          
          if Input.trigger?(Input::C) && $Trainer.badges[@index]==true
            renderBadgeAnimation(@index)
          end
          if Input.trigger?(Input::B)
            10.times do 
              @sprites["sfade"].opacity+=25.5
              Graphics.update
              Input.update
              update
            end
            @retro=false
            @sprites["medals"].visible=false
            for i in 0...@obtBadge.length
              @sprites["badge#{i}"].visible=false
            end
						@sprites["bar"].bitmap.clear
						@sprites["bar"].bitmap=pbBitmap("Graphics/Pictures/trcardbar").clone
						@sprites["bar"].bitmap.font.name="Barlow Condensed"
						@sprites["bar"].bitmap.font.size = 26
						@sprites["bar"].bitmap.font.bold = true
						pbDrawTextPositions(@sprites["bar"].bitmap,[[_INTL("Badges"),472,2,1,Color.new(248,248,248)]])
            10.times do
              @sprites["sfade"].opacity-=25.5
              Graphics.update
              Input.update
              update
            end
            break
          end
        end
      end
      
      if Input.trigger?(Input::B)
        break
      end
    end 
  end
  
  
  def update
    pbUpdateSpriteHash(@sprites)

    if @index==-1
      @index=@obtBadge.length-1
    elsif @index==@obtBadge.length
      @index=0
    end
    if @obtBadge.length>0
      for i in 0...@obtBadge.length
        if @index==i
          @sprites["badge#{i}"].opacity=255
        else
          @sprites["badge#{i}"].opacity=150
        end
      end
    end
   
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonTrainerCard
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end