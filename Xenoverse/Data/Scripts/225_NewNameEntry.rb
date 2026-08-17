class PokemonEntryScene
	def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=1000000
		@sprites["bg"]=Sprite.new(@viewport)
		@sprites["bg"].bitmap=pbBitmap("Graphics/Pictures/NameEntry/nicknamebg")
		
		@sprites["entrybg"]=Sprite.new(@viewport)
		@sprites["entrybg"].bitmap=pbBitmap("Graphics/Pictures/NameEntry/entry")
		@sprites["entrybg"].x = Graphics.width/2 - @sprites["entrybg"].bitmap.width/2
		@sprites["entrybg"].y = 2
		if USEKEYBOARD
      @sprites["entry"]=Window_TextEntry_KeyboardNEW.new(initialText,0,0,260,96,helptext,true)
    else
      @sprites["entry"]=Window_TextEntry.new(initialText,0,0,400,96,helptext,true)
    end
		@sprites["entry"].x=(Graphics.width/2)-(@sprites["entry"].width/2)+20
		@sprites["entry"].y = 26
    @sprites["entry"].viewport=@viewport
    @sprites["entry"].visible=true
		@minlength=minlength
    @maxlength=maxlength
    @symtype=0
    @sprites["entry"].maxlength=maxlength
		@sprites["helpwindow"] = BitmapSprite.new(512,28,@viewport)
		
		@sprites["hw"] = BitmapSprite.new(512,28,@viewport)
		@sprites["hw"].y = 343
		@sprites["hw"].bitmap.font = SUMMARYITEMFONT
		@sprites["hw"].bitmap.font.size = $MKXP ? 22 : 24
		textpos = []
		if minlength==0
			textpos.push([_INTL("Enter text using the keyboard. Press ESC to cancel, or ENTER to confirm."),256,2,2,Color.new(248,248,248)])
    else
			textpos.push([_INTL("Enter text using the keyboard. Press ENTER to confirm."),256,2,2,Color.new(248,248,248)])
    end
		pbDrawTextPositions(@sprites["hw"].bitmap,textpos)
		
		case subject
    when 1   # Player
      if $PokemonGlobal
				if $PokemonGlobal.playerID==0 #MALE
					@sprites["subject"]=Sprite.new(@viewport)
					@sprites["subject"].bitmap= pbBitmap("Graphics/Pictures/NameEntry/maleIcon")
				else #FEMALE
					@sprites["subject"]=Sprite.new(@viewport)
					@sprites["subject"].bitmap= pbBitmap("Graphics/Pictures/NameEntry/femaleIcon")
				end
				@sprites["subject"].ox = @sprites["subject"].bitmap.width/2
				@sprites["subject"].oy = @sprites["subject"].bitmap.height/2
        @sprites["subject"].x=89
        @sprites["subject"].y=52
=begin
        meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
				echoln meta
        if meta
          filename=pbGetPlayerCharset(meta,1)
          @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
          charwidth=@sprites["subject"].bitmap.width
          charheight=@sprites["subject"].bitmap.height
          @sprites["subject"].x = 44*2 - charwidth/8
          @sprites["subject"].y = 38*2 - charheight/4
        end
=end
      end
    when 2   # Pokémon
      if pokemon
				@sprites["subject"] = Sprite.new(@viewport)
				path = "Graphics/Pictures/DexNew/Icon/"
				add = ""
				add += pokemon.species.to_s
				add += "f" if pbResolveBitmap(path+add+"f") && pokemon.gender==1
				add += "_#{pokemon.form}" if pokemon.form>0 && !pokemon.isDelta?
        add += "d" if pokemon.isDelta? && pbResolveBitmap(path+add+"d")
				@sprites["subject"].bitmap = pbBitmap(path+add)
        @sprites["subject"].ox = @sprites["subject"].bitmap.width/2
				@sprites["subject"].oy = @sprites["subject"].bitmap.height/2
        @sprites["subject"].x=89
        @sprites["subject"].y=52
        @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
        @sprites["gender"].x=426
        @sprites["gender"].y=55
        @sprites["gender"].bitmap.clear
				gpath = pokemon.gender==1 ? "Graphics/Pictures/SummaryNew/Female" : "Graphics/Pictures/SummaryNew/Male"
				@sprites["gender"].bitmap.blt(0,0,pbBitmap(gpath),Rect.new(0,0,32,32)) if pokemon.gender<2
      end
    when 3   # Storage box
    when 4   # NPC
    end
    pbFadeInAndShow(@sprites)
	end
end

class Window_TextEntry_KeyboardNEW < Window_TextEntry_Keyboard
	def initialize(*args)
		super(*args)
		setup
		if $MKXP 
			Input.gets #Used to clear text cache
		end
	end
	
	def setup
		self.__setWindowskin(Bitmap.new(1,1))
		@curfont = SUMMARYITEMFONT
		self.contents.font = SUMMARYITEMFONT
		self.contents.font.size = $MKXP ? 24 : 26
		#self.contents.font.bold = false
		@baseColor=Color.new(24,24,24)
		@shadowColor=Color.new(168,184,184,0)
	end
end
