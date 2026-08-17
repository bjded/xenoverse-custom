SUMMARYFONT = Font.new
SUMMARYFONT.name = [$MKXP ? "Kimberley" : "Kimberley Bl","Verdana"]
SUMMARYFONT.size = $MKXP ? 16 : 18 

SUMMARYITEMFONT = Font.new
SUMMARYITEMFONT.name = ["Barlow Condensed","Verdana"]
SUMMARYITEMFONT.size = $MKXP ? 20 : 22

class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index
	include EAM_Sprite
	
	
  def initialize(viewport=nil,fifthmove=false)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/SummaryNew/ChooseArrow")
    @frame=0
    @index=0
    @fifthmove=fifthmove
    @preselected=false
    @updating=false
    @spriteVisible=true
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index=value
    refresh
  end

  def preselected=(value)
    @preselected=value
    refresh
  end

  def visible=(value)
    super
    @spriteVisible=value if !@updating
  end

  def refresh
    w=@movesel.width
    h=@movesel.height#/2
    self.x=230
    self.y=70+(self.index*26.5)
    self.y-=26 if @fifthmove
    self.y+=10 if @fifthmove && self.index==4
    self.bitmap=@movesel.bitmap
    #if self.preselected
    #  self.src_rect.set(0,h,w,h)
    #else
    #  self.src_rect.set(0,0,w,h)
    #end
  end

  def update
    @updating=true
    super
    @movesel.update
    @updating=false
    refresh
  end
end


class PokemonSummaryScene
	
	def pbUpdate
    pbUpdateSpriteHash(@sprites)
		if @sprites["abg"]
			@sprites["abg"].ox+=Dex::ANIMBGSCROLLX
			@sprites["abg"].oy+=Dex::ANIMBGSCROLLY
		end	
  end
	
	def pbStartScene(party,partyindex,viewportz = 100000)
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    echoln viewportz
    @viewport.z=viewportz 
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    @sprites={}
		@page=0
		@path = "Graphics/Pictures/SummaryNew/"
		@language = pbGetLanguage() == 4 ? 0 : 1		
		
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites["background"]=Sprite.new(@viewport)
		@sprites["background"].bitmap = pbBitmap(@path + "bg")
		@sprites["abg"]=AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(Dex::PATH + "animbg")
		@sprites["lowerbar"]=Sprite.new(@viewport)
		@sprites["lowerbar"].bitmap = pbBitmap(@path + "LowerBar")
		@sprites["lowerbar"].y = 344
		@sprites["lowerbar"].bitmap.font = SUMMARYITEMFONT
		@sprites["lowerbar"].bitmap.font.bold = true
		@sprites["lowerbar"].bitmap.font.size = $MKXP ? 24 : 26
		pbDrawTextPositions(@sprites["lowerbar"].bitmap,[[_INTL("Close"),462,2,1,Color.new(248,248,248)]])
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay"].bitmap.font = SUMMARYFONT
		@sprites["overlay"].z = 30
		#pokemon sprite
		@sprites["pokemon"]=DynamicPokemonSprite.new(false,0,@viewport,false)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].actualBitmap.setSpeed(1)
		@sprites["pokemon"].oy = pbGetSpriteBase(@sprites["pokemon"].sprite.bitmap)
		@sprites["pokemon"].x = 157
		@sprites["pokemon"].y = 247
    if @pokemon.isEgg?
      @sprites["pokemon"].zoom_x = 0.5
      @sprites["pokemon"].zoom_y = 0.5
    end
    @sprites["pokemon"].color=Color.new(0,0,0,0)
		
		@sprites["pokemon"].still if @pokemon.hp<=0
		
		@sprites["pageselect"] = Sprite.new(@viewport)
		@sprites["pageselect"].x = 253
		@sprites["pageselect"].y = 37
		
		###############
		
		@sprites["namebar"]=Sprite.new(@viewport)
		@sprites["namebar"].bitmap=pbBitmap(@path+"namebar")
		@sprites["namebar"].x = 9
		@sprites["namebar"].y = 11
		
		ballused=@pokemon.ballused ? @pokemon.ballused : 0
		@sprites["catchball"]=Sprite.new(@viewport)
		@sprites["catchball"].bitmap = pbBitmap(sprintf("Graphics/Pictures/summaryball%02d",ballused))
		@sprites["catchball"].x = 17
		@sprites["catchball"].y = 18
		
		#TODO status icon
		@sprites["status"]=Sprite.new(@viewport)
		@sprites["status"].bitmap = Bitmap.new(19,19)
		if @pokemon.status != 0 && @pokemon.hp>0
			statusindex = @pokemon.status-1
			@sprites["status"].bitmap.blt(0,0,pbBitmap("Graphics/Pictures/EBS/Xenoverse/STATUS"),Rect.new(19*statusindex,0,19,19))	
		end
		@sprites["status"].x = 214
		@sprites["status"].y = 22
		
		@sprites["helditem"]=Sprite.new(@viewport)
		@sprites["helditem"].bitmap = pbBitmap(@path + "helditembg")
		@sprites["helditem"].visible=@pokemon.item >0
		@sprites["helditem"].x = 46
		@sprites["helditem"].y = 294
		
		@sprites["sliderbg"]=Sprite.new(@viewport)
		@sprites["sliderbg"].bitmap = pbBitmap(@path + "sliderbg")
		@sprites["sliderbg"].x = 9
		@sprites["sliderbg"].y = 56
		
		@sprites["movesel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible=false
		@sprites["movesel"].z = 30
		@pages={} #sprite hash for pages
		refreshMain
		
		drawPageOne(@pokemon)
	end
	
	def pbStartForgetScene(party,partyindex,moveToLearn)
    pbStartScene(party,partyindex)
		drawPageThree(@pokemon)
		mtl = PBMove.new(moveToLearn) if moveToLearn!=0
		movesbmp = pbBitmap("Graphics/Pictures/EBS/Xenoverse/casellemosse_rs")
    @page=3
		if moveToLearn>0
			#rearrange page layout
			@sprites["pageselect"].y-=30
      @sprites["pageselect"].visible = false
			for i in 0..3
				@pages["move#{i}"].y-=26
			end
      
      type = mtl.type
      if i.id == 333
        type = pbHiddenPower(@pokemon.iv)[0]
      end
			@pages["move4"]= EAMSprite.new(@viewport)
			@pages["move4"].bitmap = Bitmap.new(232,25)
			@pages["move4"].bitmap.blt(0,0,movesbmp,Rect.new(0,type*25,232,25))
			@pages["move4"].x = 270
			@pages["move4"].y = 80-16 + 26*4
			@pages["move4"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
			@pages["move4"].bitmap.font.size = $MKXP ? 16 : 18
			dark = getDarkerColor(@pages["move4"].bitmap.get_pixel(50,13),0.35)
			textpos = []
			textpos.push([PBMoves.getName(mtl.id),35,3,0,Color.new(248,248,248),dark,true]) #outlined
			textpos.push([sprintf("%d/%d",mtl.pp,mtl.totalpp),220,3,1,dark])
			pbDrawTextPositions(@pages["move4"].bitmap,textpos)
		end
		
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport,moveToLearn>0)
    @sprites["movesel"].visible=false
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    drawSelectedMove(@pokemon,moveToLearn,@pokemon.moves[0].id)
    merged = @sprites.merge(@pages)
    pbFadeInAndShow(merged)
  end
	
	def refreshMain
		@sprites["overlay"].bitmap.clear
		@sprites["overlay"].bitmap.font = SUMMARYFONT
		ballused=@pokemon.ballused ? @pokemon.ballused : 0
		@sprites["catchball"].bitmap = pbBitmap(sprintf("Graphics/Pictures/summaryball%02d",ballused))
		@sprites["helditem"].visible=@pokemon.item >0
		
		textpos=[]
		textpos.push([@pokemon.name,62,22,0,Color.new(248,248,248)])
		
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
		@sprites["overlay"].bitmap.font.size = $MKXP ? 12 : 14
		textpos=[]
		textpos.push([sprintf("%3d",@pokemon.level),190,25,0,Color.new(248,248,248)])
		textpos.push(["Lv.",174,25,0,Color.new(248,178,13)])
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
		@male = pbBitmap(@path + "male")
		@female = pbBitmap(@path + "female")
		@sprites["overlay"].bitmap.blt(157,20,(@pokemon.gender == 0 ? @male : @female),Rect.new(0,0,40,40)) if @pokemon.gender < 2
		if @pokemon.item>0
			@sprites["overlay"].bitmap.font = SUMMARYITEMFONT
			textpos=[]
			textpos.push([PBItems.getName(@pokemon.item),55,310,0,Color.new(24,24,24)])
			pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    end
    @sprites["status"].bitmap.clear
    if @pokemon.status != 0 && @pokemon.hp>0
			statusindex = @pokemon.status-1
			@sprites["status"].bitmap.blt(0,0,pbBitmap("Graphics/Pictures/EBS/Xenoverse/STATUS"),Rect.new(19*statusindex,0,19,19))	
		end
	end
	
	def drawPageOne(pokemon)
		if pokemon.isEgg?
      drawPageOneEgg(pokemon)
      return
    end
		@sprites["pageselect"].bitmap = pbBitmap(@path + "Info_bar")
		pbDisposeSpriteHash(@pages)
		@pages["bg"]=Sprite.new(@viewport)
		@pages["bg"].bitmap = pbBitmap(@path + "InfoPage")
				
		@pages["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@pages["overlay"].bitmap.font = SUMMARYITEMFONT
		@pages["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		types = pbBitmap("Graphics/Pictures/types2_" + (@language==0 ? "ita" : "eng"))
		typeheight = 22
		type1rect = Rect.new(0,((typeheight)*pokemon.type1),types.width,typeheight)
		type2rect = Rect.new(0,((typeheight)*pokemon.type2),types.width,typeheight)
		
		#fields
		textpos=[]
		textpos.push([_INTL("Number"),260,80,0,Color.new(248,248,248)])
		textpos.push([_INTL("Specie"),260,78+26,0,Color.new(248,248,248)])
		textpos.push([_INTL("Tipo"),260,78+52,0,Color.new(248,248,248)])
		textpos.push([_INTL("OT"),260,78+78,0,Color.new(248,248,248)])
		textpos.push([_INTL("ID No."),260,76+104,0,Color.new(248,248,248)])
		textpos.push([_INTL("Exp points"),260,78+146,0,Color.new(248,248,248)])
		textpos.push([_INTL("Lv. +1"),260,76+172,0,Color.new(248,248,248)])
		pbDrawTextPositions(@pages["overlay"].bitmap,textpos)
		
		#values
		textpos=[]
		eindex = (XENODEX.index(pokemon.species) ? XENODEX.index(pokemon.species) : (RETRODEX.index(pokemon.species) ? RETRODEX.index(pokemon.species) : "???"))
		index = (ELDIWDEX.index(pokemon.species) ? ELDIWDEX.index(pokemon.species) : eindex)
		textpos.push([(index.is_a?(String) ? index : sprintf("%03d",index+1)),338,80,0,Color.new(48,48,48)])
		textpos.push([PBSpecies.getName(pokemon.species),338,78+26,0,Color.new(48,48,48)])
		if pokemon.type1==pokemon.type2
      @pages["overlay"].bitmap.blt(333,131,types,type1rect)
    else
      @pages["overlay"].bitmap.blt(333,131,types,type1rect)
      @pages["overlay"].bitmap.blt(418,131,types,type2rect)
    end
		textpos.push([pokemon.ot,338,78+78,0,Color.new(48,48,48)])
		textpos.push([sprintf("%3d",pokemon.publicID),338,76+104,0,Color.new(48,48,48)])
		textpos.push([sprintf("%d",pokemon.exp),338,78+146,0,Color.new(48,48,48)])
		growthrate=pokemon.growthrate
    startexp=PBExperience.pbGetStartExperience(pokemon.level,growthrate)
    endexp=PBExperience.pbGetStartExperience(pokemon.level+1,growthrate)
		textpos.push([sprintf("%d",endexp-pokemon.exp),338,76+172,0,Color.new(48,48,48)])
		pbDrawTextPositions(@pages["overlay"].bitmap,textpos)
		curlevelexp = pokemon.exp-startexp
		fulllevelexp = endexp-startexp
    if pokemon.level<PBExperience::MAXLEVEL
      @pages["overlay"].bitmap.blt(337,281,pbBitmap(@path + "expbar"),Rect.new(0,0,157.0*(curlevelexp.to_f/fulllevelexp),4))
		end
		#marks
		sel = pbBitmap(@path + "marks_sel")
		unsel = pbBitmap(@path + "marks_unsel")
		marks=[]
		for i in 0...PokemonStorage::MARKINGCHARS.length
			marks.push((pokemon.markings&(1<<i))!=0)
		end
		@pages["marks"]=BitmapSprite.new(246,23,@viewport)
		@pages["marks"].x = 256
		@pages["marks"].y = 309
		startx = 246-sel.width-10
		for i in 0...marks.length
			if marks[i]
				@pages["marks"].bitmap.blt(startx+21*i,2,sel,Rect.new(21*i,0,21,18))
			else
				@pages["marks"].bitmap.blt(startx+21*i,2,unsel,Rect.new(21*i,0,21,18))
			end
		end
		startx-=50
		@pages["marks"].bitmap.blt(startx+3,5,pbBitmap(@path + "pkrs"),Rect.new(0,0,45,13)) if pokemon.pokerus && 	pokemon.pokerus>0
		
		if [PBSpecies::TRISHOUT,PBSpecies::SHYLEON,PBSpecies::SHULONG,PBSpecies::SABOLT].include?(pokemon.species)
			if pokemon.form == 1
				@pages["marks"].bitmap.blt(2,2,pbBitmap(@path + "terr"),Rect.new(0,0,22,20))
			elsif pokemon.form == 2
				@pages["marks"].bitmap.blt(4,1,pbBitmap(@path + "xeno"),Rect.new(0,0,19,21))
			elsif pokemon.form == 3 && pokemon.species != PBSpecies::SABOLT
				@pages["marks"].bitmap.blt(2,1,pbBitmap(@path + "astro"),Rect.new(0,0,21,21))
			end
		end
		if pokemon.isShiny? && RETRODEX.include?(pokemon.species)
			@pages["marks"].bitmap.blt(26+9,4,pbBitmap(@path + "retro"),Rect.new(0,0,21,20))
			@pages["marks"].bitmap.blt(22,-3,pbBitmap(@path + "shiny"),Rect.new(0,0,21,20))
		else
			@pages["marks"].bitmap.blt(26,1,pbBitmap(@path + "shiny"),Rect.new(0,0,21,20)) if pokemon.isShiny?
			@pages["marks"].bitmap.blt(26,2,pbBitmap(@path + "retro"),Rect.new(0,0,21,20)) if RETRODEX.include?(pokemon.species)
		end
	end
	
	def drawPageTwo(pokemon)
		@sprites["pageselect"].bitmap = pbBitmap(@path + "Stats_bar")
		pbDisposeSpriteHash(@pages)
		@pages["bg"]=Sprite.new(@viewport)
		@pages["bg"].bitmap = pbBitmap(@path + "StatsPage")
		
		@pages["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@pages["overlay"].bitmap.font = SUMMARYITEMFONT
		@pages["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		
		#fields
		textpos=[]
		textpos.push([_INTL("HP"),260,80,0,Color.new(248,248,248)])
		textpos.push([_INTL("Attack"),260,122,0,Color.new(248,248,248)])
		textpos.push([_INTL("Defense"),260,147,0,Color.new(248,248,248)])
		textpos.push([_INTL("Sp.Atk"),260,172,0,Color.new(248,248,248)])
		textpos.push([_INTL("Sp.Def"),260,197,0,Color.new(248,248,248)])
		textpos.push([_INTL("Speed"),260,222,0,Color.new(248,248,248)])
		pbDrawTextPositions(@pages["overlay"].bitmap,textpos)

		#values
		textpos=[]
		textpos.push([sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),340,80,0,Color.new(48,48,48)])
		textpos.push([sprintf("%d",pokemon.attack),340,122,0,Color.new(48,48,48)])
		textpos.push([sprintf("%d",pokemon.defense),340,147,0,Color.new(48,48,48)])
		textpos.push([sprintf("%d",pokemon.spatk),340,171,0,Color.new(48,48,48)])
		textpos.push([sprintf("%d",pokemon.spdef),340,197,0,Color.new(48,48,48)])
    textpos.push([sprintf("%d",pokemon.speed),340,222,0,Color.new(48,48,48)])
    #evs
    textpos.push([sprintf("%3d",pokemon.ev[0]),400,80,0,Color.new(30, 214, 98)])
		textpos.push([sprintf("%d",pokemon.ev[1]),380,122,0,Color.new(30, 214, 98)])
		textpos.push([sprintf("%d",pokemon.ev[2]),380,147,0,Color.new(30, 214, 98)])
		textpos.push([sprintf("%d",pokemon.ev[4]),380,171,0,Color.new(30, 214, 98)])
		textpos.push([sprintf("%d",pokemon.ev[5]),380,197,0,Color.new(30, 214, 98)])
    textpos.push([sprintf("%d",pokemon.ev[3]),380,222,0,Color.new(30, 214, 98)])
    #ivs
    textpos.push([sprintf("%3d",pokemon.iv[0]),440,80,0,Color.new(219, 185, 31)])
		textpos.push([sprintf("%d",pokemon.iv[1]),420,122,0,Color.new(219, 185, 31)])
		textpos.push([sprintf("%d",pokemon.iv[2]),420,147,0,Color.new(219, 185, 31)])
		textpos.push([sprintf("%d",pokemon.iv[4]),420,171,0,Color.new(219, 185, 31)])
		textpos.push([sprintf("%d",pokemon.iv[5]),420,197,0,Color.new(219, 185, 31)])
		textpos.push([sprintf("%d",pokemon.iv[3]),420,222,0,Color.new(219, 185, 31)])
		pbDrawTextPositions(@pages["overlay"].bitmap,textpos)
		
		
		#natures modifiers
		natup=(pokemon.nature/5).floor
		natup=(natup>=2 ? (natup==2 ? 4 : natup-1) : natup)
		natdn=(pokemon.nature%5).floor
		natdn=(natdn>=2 ? (natdn==2 ? 4 : natdn-1) : natdn)
		if natup != natdn
			@pages["overlay"].bitmap.blt(478,127+25*natup,pbBitmap(@path+"inc"),Rect.new(0,0,17,16))
			@pages["overlay"].bitmap.blt(478,127+25*natdn,pbBitmap(@path+"dec"),Rect.new(0,0,17,16))
		end
		
		#hp bar
		@pages["overlay"].bitmap.blt(325,108,pbBitmap(@path+"hpbar"),Rect.new(0,0,171*(pokemon.hp.to_f/pokemon.totalhp),11))
		
		#ability
		textpos=[]
		textpos.push([_INTL("Ability"),260,266,0,Color.new(248,248,248)])
		textpos.push([PBAbilities.getName(pokemon.ability),340,266,0,Color.new(48,48,48)])
		pbDrawTextPositions(@pages["overlay"].bitmap,textpos)
		@pages["overlay"].bitmap.font.size = $MKXP ? 18 : 20
		abilitydesc=pbGetMessage(MessageTypes::AbilityDescs,pokemon.ability)
		drawTextExH(@pages["overlay"].bitmap,263,291,231,2,abilitydesc,Color.new(48,48,48),Color.new(48,48,48,0),18)
	end
	
	
	
	def drawPageThree(pokemon)
		@sprites["pageselect"].bitmap = pbBitmap(@path + "Moves_bar")
		pbDisposeSpriteHash(@pages)
		@pages["bg"]=Sprite.new(@viewport)
		@pages["bg"].bitmap = pbBitmap(@path + "MovesPage")
		
		@pages["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@pages["overlay"].bitmap.font = SUMMARYITEMFONT
		@pages["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		numMoves = 0
		movesbmp = pbBitmap("Graphics/Pictures/EBS/Xenoverse/casellemosse_rs")
		for i in pokemon.moves
			if i.id>0
        type = i.type
        if i.id == 333
          type = pbHiddenPower(pokemon.iv)[0]
        end
        @pages["move#{numMoves}"] = EAMSprite.new(@viewport)
				@pages["move#{numMoves}"].bitmap = Bitmap.new(232,25)
				@pages["move#{numMoves}"].bitmap.blt(0,0,movesbmp,Rect.new(0,type*25,232,25))
				@pages["move#{numMoves}"].x = 270
				@pages["move#{numMoves}"].y = 80 + 26*pokemon.moves.index(i)
				@pages["move#{numMoves}"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
				@pages["move#{numMoves}"].bitmap.font.size = $MKXP ? 16 : 18
				dark = getDarkerColor(@pages["move#{numMoves}"].bitmap.get_pixel(50,13),0.35)
				textpos = []
				textpos.push([PBMoves.getName(i.id),35,3,0,Color.new(248,248,248),dark,true]) #outlined
				textpos.push([sprintf("%d/%d",i.pp,i.totalpp),220,3,1,dark])
				pbDrawTextPositions(@pages["move#{numMoves}"].bitmap,textpos)
				numMoves+=1
			end
		end
	end
	
	def drawPageFour(pokemon) #notes
		@sprites["pageselect"].bitmap = pbBitmap(@path + "Notes_bar")
		pbDisposeSpriteHash(@pages)
		@pages["bg"]=Sprite.new(@viewport)
		@pages["bg"].bitmap = pbBitmap(@path + "NotesPage")
		
		@pages["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@pages["overlay"].bitmap.font = SUMMARYITEMFONT
		@pages["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		
		textpos = []
		
		naturename=PBNatures.getName(pokemon.nature)
		memo=""
    shownature=(!(pokemon.isShadow? rescue false)) || pokemon.heartStage<=3
    if shownature
      memo+=_INTL("<c3=ee5439>{1}\n",naturename)
			textpos.push([_INTL("{1} nature",naturename),270,85,0,Color.new(48,48,48)])
    end
    if pokemon.timeReceived
      month=pbGetAbbrevMonthName(pokemon.timeReceived.mon)
      date=pokemon.timeReceived.day
      year=pokemon.timeReceived.year
      memo+=_INTL("<c3=FFFFFF>{1} {2}, {3}\n",month,date,year)
			textpos.push([_INTL("{1} {2}, {3}",month,date,year),270,107,0,Color.new(48,48,48)])
    end
    mapname=pbGetMapNameFromId(pokemon.obtainMap)
    if (pokemon.obtainText rescue false) && pokemon.obtainText!=""
      echoln "pokemon has obtain text"
      mapname=pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=sprintf("<c3=ee5439>%s\n",mapname)
			textpos.push([_INTL("{1}",mapname),270,129,0,Color.new(248,48,18)])
    else
      memo+=_INTL("<c3=FFFFFF>Faraway place\n")
			textpos.push([_INTL("Faraway place"),270,129,0,Color.new(48,48,48)])
    end
    if pokemon.obtainMode
      mettext=[_INTL("Met at Lv. {1}.",pokemon.obtainLevel),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.",pokemon.obtainLevel),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.",pokemon.obtainLevel)
               ][pokemon.obtainMode]
      memo+=sprintf("<c3=FFFFFF>%s\n",mettext)
			textpos.push([_INTL("{1}",mettext),270,151,0,Color.new(48,48,48)])
			t = ""
      if pokemon.obtainMode==1 # hatched
        if pokemon.timeEggHatched
          month=pbGetAbbrevMonthName(pokemon.timeEggHatched.mon)
          date=pokemon.timeEggHatched.day
          year=pokemon.timeEggHatched.year
          memo+=_INTL("<c3=404040>{1} {2}, {3}",month,date,year)
          memo+="\n"
          t+=_INTL("{1} {2}, {3}",month,date,year)
          t+="\n"
					#textpos.push([_INTL("{1} {2}, {3}",month,date,year),270,165,0,Color.new(48,48,48)])
        end
        mapname=pbGetMapNameFromId(pokemon.hatchedMap)
        #mapname=_MAPINTL(mapname) if $PokemonSystem.language==1
        if mapname && mapname!=""
          memo+=sprintf("<c3=ee5439>%s\n",mapname)
					#textpos.push([_INTL("{1}",mapname),270,185,0,Color.new(48,48,48)])
          t+=_INTL("{1}",mapname)
          t+="\n"
				else
          memo+=_INTL("<c3=ee5439>Faraway place\n")
          t+=_INTL("Faraway place")
          t+="\n"
        end
        memo+=_INTL("<c3=FFFFFF>Egg hatched.\n")
        t+=_INTL("Egg hatched.")
				drawTextExH(@pages["overlay"].bitmap,270,185,223,3,t,Color.new(48,48,48),Color.new(48,48,48,0),24)
      else
        memo+="<c3=FFFFFF>\n"
      end
    end
    if shownature
      bestiv=0
      tiebreaker=pokemon.personalID%6
      for i in 0...6
        if pokemon.iv[i]==pokemon.iv[bestiv]
          bestiv=i if i>=tiebreaker && bestiv<tiebreaker
        elsif pokemon.iv[i]>pokemon.iv[bestiv]
          bestiv=i
        end
      end
      characteristic=[_INTL("Loves to eat."),
                      _INTL("Often dozes off."),
                      _INTL("Often scatters things."),
                      _INTL("Scatters things often."),
                      _INTL("Likes to relax."),
                      _INTL("Proud of its power."),
                      _INTL("Likes to thrash about."),
                      _INTL("A little quick tempered."),
                      _INTL("Likes to fight."),
                      _INTL("Quick tempered."),
                      _INTL("Sturdy body."),
                      _INTL("Capable of taking hits."),
                      _INTL("Highly persistent."),
                      _INTL("Good endurance."),
                      _INTL("Good perseverance."),
                      _INTL("Likes to run."),
                      _INTL("Alert to sounds."),
                      _INTL("Impetuous and silly."),
                      _INTL("Somewhat of a clown."),
                      _INTL("Quick to flee."),
                      _INTL("Highly curious."),
                      _INTL("Mischievous."),
                      _INTL("Thoroughly cunning."),
                      _INTL("Often lost in thought."),
                      _INTL("Very finicky."),
                      _INTL("Strong willed."),
                      _INTL("Somewhat vain."),
                      _INTL("Strongly defiant."),
                      _INTL("Hates to lose."),
                      _INTL("Somewhat stubborn.")
											][bestiv*5+pokemon.iv[bestiv]%5]
			
			drawTextExH(@pages["overlay"].bitmap,270,206+(pokemon.obtainMode==1 ? 60 : 0),223,3,characteristic,Color.new(48,48,48),Color.new(48,48,48,0),24)
      #memo+=sprintf("<c3=FFFFFF>%s\n",characteristic)
    end
		
    pbDrawTextPositions(@pages["overlay"].bitmap,textpos)
		#drawFormattedTextEx(@pages["overlay"].bitmap,270,85,220,memo,Color.new(48,48,48),Color.new(0,0,0,0))
	end
	
	def drawPageOneEgg(pokemon)
    @sprites["pageselect"].bitmap = pbBitmap(@path + "Info_bar")
		pbDisposeSpriteHash(@pages)
		@pages["bg"]=Sprite.new(@viewport)
		@pages["bg"].bitmap = pbBitmap(@path + "NotesPage")
		
		@pages["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@pages["overlay"].bitmap.font = SUMMARYITEMFONT
		@pages["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		
		overlay=@pages["overlay"].bitmap
    overlay.clear
    #@sprites["background"].setBitmap("Graphics/Pictures/summaryEgg")
    base=Color.new(248,248,248)
    shadow=Color.new(0,0,0,0)
    memo=""
    if pokemon.timeReceived
      month=pbGetAbbrevMonthName(pokemon.timeReceived.mon)
      date=pokemon.timeReceived.day
      year=pokemon.timeReceived.year
      memo+=_INTL("<c3=FF4A3D,00000000>{1} {2}, {3}</c3>\n",month,date,year)
    end
		memo+="<c3=3D3D3D,00000000>"
    mapname=pbGetMapNameFromId(pokemon.obtainMap)
    if (pokemon.obtainText rescue false) && pokemon.obtainText!=""
      mapname=pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=_INTL("A mysterious Pokémon Egg received in <c3=FF4A3D,00000000>{1}</c3>.\n",mapname)
    end
    memo+="\n"
    memo+=_INTL("<c3=FF4A3D,00000000>\"The Egg Watch\"</c3>\n")
    eggstate=_INTL("It looks like this Egg will take a long time to hatch.")
    eggstate=_INTL("What will hatch from this?  It doesn't seem close to hatching.") if pokemon.eggsteps<10200
    eggstate=_INTL("It appears to move occasionally.  It may be close to hatching.") if pokemon.eggsteps<2550
    eggstate=_INTL("Sounds can be heard coming from inside!  It will hatch soon!") if pokemon.eggsteps<1275
    memo+=sprintf("%s\n",eggstate)
		memo+="</c3>"
    drawFormattedTextEx(overlay,270,85,220,memo,base,shadow)
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
	
	def pbGoToPrevious
    if @page!=0
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex] && !@party[newindex].isEgg?
          @partyindex=newindex
          break
				elsif @party[newindex] && @party[newindex].isEgg?
					@page = 0
					@partyindex=newindex
					break
        end
      end
    else
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex]
          @partyindex=newindex
          break
        end
      end
    end
  end

  def pbGoToNext
    if @page!=0
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex] && !@party[newindex].isEgg?
          @partyindex=newindex
          break
				elsif @party[newindex] && @party[newindex].isEgg?
					@page = 0
					@partyindex=newindex
					break
        end
      end
    else
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex]
          @partyindex=newindex
          break
        end
      end
    end
  end
	
	def pbScene
    pbPlayCry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      end
      dorefresh=false
      if Input.trigger?(Input::C)
        if @page==0
          break
        elsif @page==2
          pbMoveSelection
          dorefresh=true
          drawPageThree(@pokemon)
        end
				
      end
      if Input.trigger?(Input::UP) && @partyindex>0
        oldindex=@partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].actualBitmap.setSpeed(1)
          @sprites["pokemon"].oy = pbGetSpriteBase(@sprites["pokemon"].sprite.bitmap)
          if @pokemon.isEgg?
            @sprites["pokemon"].zoom_x = 0.5
            @sprites["pokemon"].zoom_y = 0.5
          else
            @sprites["pokemon"].zoom_x = 1
            @sprites["pokemon"].zoom_y = 1
          end
          dorefresh=true
          pbPlayCry(@pokemon)
        end
      end
      if Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex=@partyindex
        pbGoToNext
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].actualBitmap.setSpeed(1)
          @sprites["pokemon"].oy = pbGetSpriteBase(@sprites["pokemon"].sprite.bitmap)
          if @pokemon.isEgg?
            @sprites["pokemon"].zoom_x = 0.5
            @sprites["pokemon"].zoom_y = 0.5
          else
            @sprites["pokemon"].zoom_x = 1
            @sprites["pokemon"].zoom_y = 1
          end
          dorefresh=true
          pbPlayCry(@pokemon)
        end
      end
      if Input.trigger?(Input::LEFT) && !@pokemon.isEgg?
        oldpage=@page
        @page-=1
        @page=3 if @page<0
        @page=0 if @page>3
        dorefresh=true
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if Input.trigger?(Input::RIGHT) && !@pokemon.isEgg?
        oldpage=@page
        @page+=1
        @page=3 if @page<0
        @page=0 if @page>3
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if dorefresh
				refreshMain
        case @page
        when 0
          drawPageOne(@pokemon)
        when 1
          drawPageTwo(@pokemon)
        when 2
          drawPageThree(@pokemon)
        when 3
          drawPageFour(@pokemon)
        when 4
          drawPageFive(@pokemon)
        end
      end
    end
    return @partyindex
  end
	
	def pbMoveSelection
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    selmove=0
    oldselmove=0
    switching=false
    drawSelectedMove(@pokemon,0,@pokemon.moves[selmove].id)
		for i in 0...@pokemon.numMoves
			if i != selmove
				@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
				@pages["move#{i}"].color = Color.new(0,0,0,40)
			elsif i == selmove
				@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
				@pages["move#{i}"].color = Color.new(0,0,0,0)
			end
		end
    loop do
			updateMoves(selmove)
      Graphics.update
      Input.update
      pbUpdate
			
      #if @sprites["movepresel"].index==@sprites["movesel"].index
      #  @sprites["movepresel"].z=@sprites["movesel"].z+1
      #else
      #  @sprites["movepresel"].z=@sprites["movesel"].z
      #end
      if Input.trigger?(Input::B)
        break if !switching
        #@sprites["movepresel"].visible=false
        switching=false
      end
      if Input.trigger?(Input::C)
        if selmove==4
          break if !switching
          #@sprites["movepresel"].visible=false
          switching=false
        else
          if !(@pokemon.isShadow? rescue false)
            if !switching
             # @sprites["movepresel"].index=selmove
              oldselmove=selmove
              #@sprites["movepresel"].visible=true
              switching=true
            else
              tmpmove=@pokemon.moves[oldselmove]
              @pokemon.moves[oldselmove]=@pokemon.moves[selmove]
              @pokemon.moves[selmove]=tmpmove
							oldy = @pages["move#{selmove}"].y
							@pages["move#{selmove}"].move(270,@pages["move#{oldselmove}"].y,10,:ease_out_cubic)
							@pages["move#{oldselmove}"].move(270,oldy,10,:ease_out_cubic)
							tmpmovesprite = @pages["move#{selmove}"]
							@pages["move#{selmove}"] = @pages["move#{oldselmove}"]
							@pages["move#{oldselmove}"] = tmpmovesprite
							
              switching=false
              drawSelectedMove(@pokemon,0,@pokemon.moves[selmove].id)
            end
          end
        end
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        selmove=0 if selmove<4 && selmove>=@pokemon.numMoves
        selmove=0 if selmove>=4
        selmove=4 if selmove<0
        @sprites["movesel"].index=selmove
        newmove=@pokemon.moves[selmove].id
        pbPlayCursorSE()
        drawSelectedMove(@pokemon,0,newmove)
				for i in 0...@pokemon.numMoves
					if i != (switching ? oldselmove : selmove)
						@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
						@pages["move#{i}"].color = Color.new(0,0,0,40)
					elsif i == (switching ? oldselmove : selmove)
						@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
						@pages["move#{i}"].color = Color.new(0,0,0,0)
					end
				end
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        selmove=0 if selmove>=4
        selmove=@pokemon.numMoves-1 if selmove<0
        @sprites["movesel"].index=selmove
        newmove=@pokemon.moves[selmove].id
        pbPlayCursorSE()
        drawSelectedMove(@pokemon,0,newmove)
				for i in 0...@pokemon.numMoves
					if i != (switching ? oldselmove : selmove)
						@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
						@pages["move#{i}"].color = Color.new(0,0,0,40)
					elsif i == (switching ? oldselmove : selmove)
						@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
						@pages["move#{i}"].color = Color.new(0,0,0,0)
					end
				end
      end
    end 
    @sprites["movesel"].visible=false
  end
	
	
	
	def pbChooseMoveToForget(moveToLearn)
    selmove=0
    ret=0
    maxmove=(moveToLearn>0) ? 4 : 3
		for i in 0..maxmove
			if i != selmove
				@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
				@pages["move#{i}"].color = Color.new(0,0,0,40)
			elsif i == selmove
				@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
				@pages["move#{i}"].color = Color.new(0,0,0,0)
			end
		end
    loop do
			updateMoves(selmove)
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        ret=4
        break
      end
      if Input.trigger?(Input::C)
        break
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=(moveToLearn>0) ? maxmove : 0
        end
        selmove=0 if selmove>maxmove
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
				for i in 0..maxmove
					if i != selmove
						@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
						@pages["move#{i}"].color = Color.new(0,0,0,40)
					elsif i == selmove
						@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
						@pages["move#{i}"].color = Color.new(0,0,0,0)
					end
				end
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        selmove=maxmove if selmove<0
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
				for i in 0..maxmove
					if i != selmove
						@pages["move#{i}"].move(270,@pages["move#{i}"].y,10,:ease_out_cubic) 
						@pages["move#{i}"].color = Color.new(0,0,0,40)
					elsif i == selmove
						@pages["move#{i}"].move(255,@pages["move#{i}"].y,10,:ease_out_cubic)
						@pages["move#{i}"].color = Color.new(0,0,0,0)
					end
				end
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
    end
    return (ret==4) ? -1 : ret
  end

	
	def drawSelectedMove(pokemon,moveToLearn,moveid)
		@pages["moveinfo"].dispose if @pages["moveinfo"]
		@pages["moveinfo"]=BitmapSprite.new(246,136,@viewport)
		@pages["moveinfo"].x=256
		@pages["moveinfo"].y=198
		
		@pages["moveinfo"].bitmap.font = SUMMARYITEMFONT
		@pages["moveinfo"].bitmap.font.size = $MKXP ? 22 : 24
		movedata=PBMoveData.new(moveid)
    basedamage=movedata.basedamage
    if moveid == 333
      basedamage = pbHiddenPower(pokemon.iv)[1]
    end
    type=movedata.type
    category=movedata.category
    accuracy=movedata.accuracy
		move=moveid
		
		textpos = []
		#fields
		textpos.push([_INTL("Category"),3,0,0,Color.new(248,248,248)])
		textpos.push([_INTL("Power"),3,24,0,Color.new(248,248,248)])
		textpos.push([_INTL("Accuracy"),3,50,0,Color.new(248,248,248)])
		
		#values
		@pages["moveinfo"].bitmap.blt(80,(category==0? 0 : 2),pbBitmap(@path+"cat#{category}"),Rect.new(0,0,27,23))
		textpos.push([(basedamage<=1 ?(basedamage==1 ? "???" : "---" ): sprintf("%d",basedamage)),82,24,0,Color.new(48,48,48)])
		textpos.push([accuracy==0 ? "---" : sprintf("%d",accuracy)+"%",82,50,0,Color.new(48,48,48)])
		
		pbDrawTextPositions(@pages["moveinfo"].bitmap,textpos)
		
		movedesc = pbGetMessage(MessageTypes::MoveDescriptions,moveid)
		@pages["moveinfo"].bitmap.font.size = $MKXP ? 18 : 20
		drawTextExH(@pages["moveinfo"].bitmap,7,76,231,2,movedesc,Color.new(48,48,48),Color.new(48,48,48,0),18)
	end
	
	def updateMoves(index)
		for i in 0...@pokemon.numMoves
			@pages["move#{i}"].update
		end
	end
	
	def pbEndScene
		merged = @sprites.merge(@pages)
    pbFadeOutAndHide(merged) { pbUpdate }
    pbDisposeSpriteHash(merged)
    @typebitmap.dispose
    @viewport.dispose
  end
end

class DynamicPokemonSprite
	alias initialize_old initialize unless self.method_defined?(:initialize_old)
	def initialize(doublebattle,index,viewport=nil,shadow=true)
		initialize_old(doublebattle,index,viewport)
		@showshadow = shadow
	end
end

class PokemonStorage
	MARKINGCHARS=["●","▲","■","♥","★","♦"]
end

def drawTextExH(bitmap,x,y,width,numlines,text,baseColor,shadowColor,h)
  normtext=getLineBrokenChunksH(bitmap,text,width,nil,true,h)
  renderLineBrokenChunksWithShadow(bitmap,x,y,normtext,numlines*32,
     baseColor,shadowColor)
end

def getLineBrokenChunksH(bitmap,value,width,dims,plain=false,th=32)
  x=0
  y=0
  textheight=th
  echoln "BROKEN CHUNKS OUTPUT"
  ret=[]
  if dims
    dims[0]=0
    dims[1]=0
  end
  re=/<c=([^>]+)>/
  reNoMatch=/<c=[^>]+>/
  return ret if !bitmap || bitmap.disposed? || width<=0
  textmsg=value.clone
  lines=1
  color=Font.default_color
  while (c = textmsg.slice!(/\n|\S*\-+|(\S*([ \r\t\f]?))/)) != nil
    break if c==""
    ccheck=c
    if ccheck=="\n"
      x=0
      y+=(textheight==0) ? bitmap.text_size("X").height : textheight
      #textheight=0
      lines+=1
      #echoln "a capo detected! n type"
      next
    end
    if ccheck[/</] && !plain
      textcols=[]
      ccheck.scan(re){ textcols.push(rgbToColor($1)) }
      words=ccheck.split(reNoMatch) # must have no matches because split can include match
    else
      textcols=[]
      words=[ccheck]
    end
    for i in 0...words.length
      word=words[i]
      if word && word!=""
        textSize=bitmap.text_size(word)
        textwidth=textSize.width
        #echoln "textwidth! #{textwidth} - #{width} - #{x>0 && x+textwidth>=width-2}"
        if x>0 && x+textwidth>=width-2
          x=0
          y+=(textheight==0) ? 32 : textheight#32 # (textheight==0) ? bitmap.text_size("X").height : textheight
          #textheight=0
          lines+=1
          #echoln "a capo detected! #{word}"
        end
        textheight=32 if textheight==0# [textheight,textSize.height].max
        ret.push([word,x,y,textwidth,textheight,color])
        x+=textwidth
        dims[0]=x if dims && dims[0]<x
      end
      if textcols[i]
        color=textcols[i]
      end
    end
  end
  dims[1]=y+textheight if dims
  echoln "LINEE BASE: #{lines}"
  return ret
end

def getLinesByTextAndValues(bitmap,value,width,dims,plain=false,th=32)
  x=0
  y=0
  textheight=th
  echoln "GET LINES OUTPUT"
  ret=[]
  if dims
    dims[0]=0
    dims[1]=0
  end
  re=/<c=([^>]+)>/
  reNoMatch=/<c=[^>]+>/
  return ret if !bitmap || bitmap.disposed? || width<=0
  textmsg=value.clone
  lines=1
  color=Font.default_color
  while (c = textmsg.slice!(/\n|\S*\-+|(\S*([ \r\t\f]?))/)) != nil
    break if c==""
    ccheck=c
    if ccheck=="\n"
      x=0
      y+=(textheight==0) ? bitmap.text_size("X").height : textheight
      #lines+=1
      #textheight=0
      lines+=1
      #echoln "a capo detected! n type"
      next
    end
    if ccheck[/</] && !plain
      textcols=[]
      ccheck.scan(re){ textcols.push(rgbToColor($1)) }
      words=ccheck.split(reNoMatch) # must have no matches because split can include match
    else
      textcols=[]
      words=[ccheck]
    end
    for i in 0...words.length
      word=words[i]
      if word && word!=""
        textSize=bitmap.text_size(word)
        textwidth=textSize.width
        #echoln "textwidth! #{textwidth} - #{width} - #{x>0 && x+textwidth>=width-2}"
        if x>0 && x+textwidth>=width-2
          x=0
          y+=(textheight==0) ? 32 : textheight#32 # (textheight==0) ? bitmap.text_size("X").height : textheight
          lines+=1
          #echoln "a capo detected! #{word}"
          #textheight=0
        end
        textheight=32 if textheight==0# [textheight,textSize.height].max
        ret.push([word,x,y,textwidth,textheight,color])
        x+=textwidth
        dims[0]=x if dims && dims[0]<x
      end
      if textcols[i]
        color=textcols[i]
      end
    end
  end
  echoln "by lines linesCount! #{lines} - #{lines == 0 ? (value != "" ? 1 : 0) : lines}"
  dims[1]=y+textheight if dims
  return lines == 1 ? (value != "" ? 1 : 0) : (lines)
end