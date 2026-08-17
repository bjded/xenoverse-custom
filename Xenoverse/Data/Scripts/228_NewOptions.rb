module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end



class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)            
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end
	
	def name
		return @name
	end
	
	def options
		return @values
	end
	
	def getProc 
		return @getProc
	end
	
	def setProc
		return @setProc
	end
	
  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)             
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart

  def initialize(name,format,optstart,optend,getProc,setProc)
    @name=name
    @format=format
    @optstart=optstart
    @optend=optend
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+@optstart
    index+=1
    if index>@optend
      index=@optstart
    end
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=1
    if index<@optstart
      index=@optend
    end
    return index-@optstart
  end
end

#####################
#
#  Stores game options
# Default options are at the top of script section SpriteWindow.

$SpeechFrames=[
  MessageConfig::TextSkinName, # Default: speech hgss 1
  "speech hgss 2",
  "speech hgss 3",
  "speech hgss 4",
  "speech hgss 5",
  "speech hgss 6",
  "speech hgss 7",
  "speech hgss 8",
  "speech hgss 9",
  "speech hgss 10",
  "speech hgss 11",
  "speech hgss 12",
  "speech hgss 13",
  "speech hgss 14",
  "speech hgss 15",
  "speech hgss 16",
  "speech hgss 17",
  "speech hgss 18",
  "speech hgss 19",
  "speech hgss 20",
  "speech pl 18"
]

$TextFrames=[
  "Graphics/Windowskins/"+MessageConfig::ChoiceSkinName, # Default: choice 1
  "Graphics/Windowskins/choice 2",
  "Graphics/Windowskins/choice 3",
  "Graphics/Windowskins/choice 4",
  "Graphics/Windowskins/choice 5",
  "Graphics/Windowskins/choice 6",
  "Graphics/Windowskins/choice 7",
  "Graphics/Windowskins/choice 8",
  "Graphics/Windowskins/choice 9",
  "Graphics/Windowskins/choice 10",
  "Graphics/Windowskins/choice 11",
  "Graphics/Windowskins/choice 12",
  "Graphics/Windowskins/choice 13",
  "Graphics/Windowskins/choice 14",
  "Graphics/Windowskins/choice 15",
  "Graphics/Windowskins/choice 16",
  "Graphics/Windowskins/choice 17",
  "Graphics/Windowskins/choice 18",
  "Graphics/Windowskins/choice 19",
  "Graphics/Windowskins/choice 20",
  "Graphics/Windowskins/choice 21",
  "Graphics/Windowskins/choice 22",
  "Graphics/Windowskins/choice 23",
  "Graphics/Windowskins/choice 24",
  "Graphics/Windowskins/choice 25",
  "Graphics/Windowskins/choice 26",
  "Graphics/Windowskins/choice 27",
  "Graphics/Windowskins/choice 28"
]

$VersionStyles=[
  [MessageConfig::FontName], # Default font style - Power Green/"Pokemon Emerald"
  ["Power Red and Blue"],
  ["Power Red and Green"],
  ["Power Clear"]
]

def pbSettingToTextSpeed(speed)
  return 2 if speed==0
  return 1 if speed==1
  return -2 if speed==2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed
  return ((Graphics.frame_rate>40) ? -2 : 1)
end



module MessageConfig
  def self.pbDefaultSystemFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::ChoiceSkinName)||""
    else
      return pbResolveBitmap($TextFrames[$PokemonSystem.frame])||""
    end
  end

  def self.pbDefaultSpeechFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::TextSkinName)||""
    else
      return pbResolveBitmap("Graphics/Windowskins/"+$SpeechFrames[$PokemonSystem.textskin])||""
    end
  end

  def self.pbDefaultSystemFontName
    if !$PokemonSystem
      return MessageConfig.pbTryFonts(MessageConfig::FontName,"Arial Narrow","Arial")
    else
      return MessageConfig.pbTryFonts($VersionStyles[$PokemonSystem.font][0],"Arial Narrow","Arial")
    end
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed($PokemonSystem ? $PokemonSystem.textspeed : nil)
  end

  def pbGetSystemTextSpeed
    return $PokemonSystem ? $PokemonSystem.textspeed : ((Graphics.frame_rate>40) ? 2 :  3)
  end
end



class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :bgmvolume
  attr_accessor :bgsvolume
  attr_accessor :mevolume
  attr_accessor :sevolume

  def bgmvolume;return 100;end
  def bgsvolume;return 100;end
  def mevolume;return 100;end
  def sevolume;return 100;end

  def language
    return (!@language) ? 0 : @language
  end

  def textskin
    return (!@textskin) ? 0 : @textskin
  end

  def tilemap; return MAPVIEWMODE; end

  def initialize
    @textspeed   = 1   # Text speed (0=slow, 1=mid, 2=fast)
    @battlescene = 0   # Battle scene (animations) (0=on, 1=off)
    @battlestyle = 0   # Battle style (0=shift, 1=set)
    @frame       = 0   # Default window frame (see also $TextFrames)
    @textskin    = 0   # Speech frame
    @font        = 0   # Font (see also $VersionStyles)
    @screensize  = (DEFAULTSCREENZOOM.floor).to_i # 0=half size, 1=full size, 2=double size
    @language    = 0   # Language (see also LANGUAGES in script PokemonSystem)
  end
end


OPT_PATH = "Graphics/Pictures/OptionsNew/"


class PokemonOptionScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

 def pbStartScene
    @oldfr = Graphics.frame_rate
    Graphics.frame_rate = 60
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    #@sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
    #   _INTL("Opzioni"),0,0,Graphics.width,64,@viewport)
    #@sprites["textbox"]=Kernel.pbCreateMessageWindow
    #@sprites["textbox"].letterbyletter=false
    #@sprites["textbox"].text=_INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
		
		@saved = true
		
		@path = OPT_PATH
		
		@sprites["bg"]=EAMSprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(@path+"bg")
		@sprites["abg"]=AnimatedPlane.new(@viewport)
		@sprites["abg"].bitmap = pbBitmap(@path + "abg")
		@sprites["banner"] = EAMSprite.new(@viewport)
		@sprites["banner"].bitmap = pbBitmap(@path + "topbar").clone
		@sprites["banner"].bitmap.font = Font.new
		@sprites["banner"].bitmap.font.size = $MKXP ? 26 : 28
		@sprites["banner"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		
		pbDrawTextPositions(@sprites["banner"].bitmap,[[_INTL("Settings"),71,13,0,Color.new(248,248,248)]])
		
		@sprites["sidebar"] = EAMSprite.new(@viewport)
		@sprites["sidebar"].bitmap = pbBitmap(@path + "sidebar")
		@sprites["sidebar"].x = 470
		@sprites["sidebar"].y = 56
		
		@sprites["lowerbar"]=EAMSprite.new(@viewport)
		@sprites["lowerbar"].bitmap = pbBitmap(@path + "lowerbar").clone
		@sprites["lowerbar"].y = 343
		@sprites["lowerbar"].bitmap.font = Font.new
		@sprites["lowerbar"].bitmap.font.name = "Barlow Condensed"
		@sprites["lowerbar"].bitmap.font.bold = true
		@sprites["lowerbar"].bitmap.font.size = $MKXP ? 22 : 24
		
		
		pbDrawTextPositions(@sprites["lowerbar"].bitmap,[[_INTL("Default"),104,3,1,Color.new(248,248,248)],
																										 [_INTL("Save"),280,3,1,Color.new(248,248,248)],
																										 [_INTL("Back"),474,3,1,Color.new(248,248,248)]])
		
		
    @PokemonOptions=[
       EnumOption.new(_INTL("Velocità testo"),[_INTL("Lento"),_INTL("Medio"),_INTL("Veloce")],
          proc { $PokemonSystem.textspeed },
          proc {|value|  
             $PokemonSystem.textspeed=value 
             MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value)) 
          }
       ),
       EnumOption.new(_INTL("Scena lotta"),[_INTL("On"),_INTL("Off")],
          proc { $PokemonSystem.battlescene },
          proc {|value|  $PokemonSystem.battlescene=value }
       ),
       EnumOption.new(_INTL("Stile lotta"),[_INTL("Shift"),_INTL("Set")],
          proc { $PokemonSystem.battlestyle },
          proc {|value|  $PokemonSystem.battlestyle=value }
       ),
# Quote this section out if you don't want to allow players to change the screen
# size.
       EnumOption.new(_INTL("Schermo"),[_INTL("Medio"),_INTL("Grande")],
          proc { $PokemonSystem.screensize },
          proc {|value|
             oldvalue=$PokemonSystem.screensize
             $PokemonSystem.screensize=value
             $ResizeOffsetX=0
             $ResizeOffsetY=0
             pbSetResizeFactor([1.0,2.0][value])
             if value!=oldvalue
               ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
             end
          }
       )
# ------------------------------------------------------------------------------
    ]
    
		#Console::setup_console
		
		for opt in 0...@PokemonOptions.length
			@sprites["opt#{opt}"] = NewSingleOption.new(@viewport)
			@sprites["opt#{opt}"].setOption(@PokemonOptions[opt])
			@sprites["opt#{opt}"].createOptions
			@sprites["opt#{opt}"].x = 29
			@sprites["opt#{opt}"].y = 86 + opt * 53
		end
		
		@index = 0
		
		@sprites["cursor"] = EAMSprite.new(@viewport)
		@sprites["cursor"].bitmap = pbBitmap(@path + "selector")
		@sprites["cursor"].y = @sprites["opt#{@index}"].y
		@sprites["cursor"].x = 3
		
		#@sprites["testopt"] = NewSingleOption.new(@viewport)
		#@sprites["testopt"].setOption(@PokemonOptions[0])
		#@sprites["testopt"].createOptions
		#@sprites["testopt"].x = 29
		#@sprites["testopt"].y = 86
		
		updateSelectedOption
		#pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
	
	def update
		if @sprites["abg"]
			@sprites["abg"].ox-=1
			@sprites["abg"].oy+=1
		end
		@sprites["cursor"].update
		for opt in 0...@PokemonOptions.length
			@sprites["opt#{opt}"].update
		end
		#@sprites["testopt"].update
	end
	
	def updateSelectedOption
		for opt in 0...@PokemonOptions.length
			@sprites["opt#{opt}"].fade(150,10) if opt != @index
			@sprites["opt#{opt}"].fade(255,10) if opt == @index
		end
	end
	
  def pbOptions
		loop do 
			Graphics.update
			Input.update
			update
			
			if Input.trigger?(Input::UP)
				@index = @index-1<0 ? @index : @index-1
				@sprites["cursor"].move(3,@sprites["opt#{@index}"].y,8,:ease_out_cubic)
				updateSelectedOption
			elsif Input.trigger?(Input::DOWN)
				@index = @index+1>=@PokemonOptions.length ? @index : @index+1
				@sprites["cursor"].move(3,@sprites["opt#{@index}"].y,8,:ease_out_cubic)
				updateSelectedOption
			end
			
			if Input.trigger?(Input::RIGHT)
				@saved = false
				@sprites["opt#{@index}"].increase
			elsif Input.trigger?(Input::LEFT)
				@saved = false
				@sprites["opt#{@index}"].decrease
			end
			
			if Input.trigger?(Input::X) #default everything
				if Kernel.pbConfirmMessage(_INTL("Do you wish to restore the default settings?"))
					for opt in 0...@PokemonOptions.length
						@sprites["opt#{opt}"].enumOption.set(0)
						@sprites["opt#{opt}"].selIndex = 0
						@sprites["opt#{opt}"].updateOptionsPosition
					end
					
					@saved = true
				end
			end
			
			if Input.trigger?(Input::Y) #save changes
				if Kernel.pbConfirmMessage(_INTL("Do you wish to save the current changes?"))
					for opt in 0...@PokemonOptions.length
						@sprites["opt#{opt}"].enumOption.set(@sprites["opt#{opt}"].selIndex)
					end
					@saved = true
				end
			end
			if Input.trigger?(Input::B)
				if @saved
					break
				else
					Kernel.pbMessage(_INTL("There seem to be unsaved changes."))
					if Kernel.pbConfirmMessage(_INTL("Do you wish to save the current changes before closing?"))
						for opt in 0...@PokemonOptions.length
							@sprites["opt#{opt}"].enumOption.set(@sprites["opt#{opt}"].selIndex)
						end
						@saved = true
					end
					break
				end
			end
		end
  end

  def pbEndScene
		# Set the values of each option
   
    pbFadeOutAndHide(@sprites) { pbUpdate }
    
    #Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
    Graphics.frame_rate = @oldfr
  end
end

OPT_OPTFONT = Font.new
OPT_OPTFONT.name = $MKXP ? "Barlow Condensed" : "Barlow Condensed ExtraBold"
OPT_OPTFONT.size = $MKXP ? 22 : 24
#OPT_OPTFONT.bold = true

OPT_SELCOLOR = Color.new(198,129,0)
OPT_NORMALCOLOR = Color.new(150,150,150)

class NewSingleOption<EAMSprite
	attr_accessor(:enumOption)
	attr_accessor(:options)
	attr_accessor(:optionsSprites)
	attr_accessor(:selIndex)
	
	def initialize(*args)
		super(*args)
		@optvp = Viewport.new(160,5,275,44)
		@optvp.z = args[0].z#+1
		self.bitmap = pbBitmap(OPT_PATH + "optionsbar").clone
    self.bitmap.font = OPT_OPTFONT
    if $MKXP
      self.bitmap.font.bold = true
    end
		@selIndex = 0
		@options=[]
		@optionsSprites=[]
		@arrows = EAMSprite.new(@optvp)
		@arrows.bitmap = pbBitmap(OPT_PATH + "arrows")
		@arrows.ox = @arrows.bitmap.width/2
		@arrows.x = 138
		@arrows.y = 8
		@arrows.z = 2
	end
	
	def setOption(opt)
		@enumOption = opt
		@selIndex = @enumOption.get
		pbDrawTextPositions(self.bitmap,[[@enumOption.name,80,14,2,Color.new(248,248,248)]])
	end
	
	def update
		super
		if @optionsSprites != nil
			for opt in @optionsSprites
				opt.update
			end
		end
	end
	
	def createOptions()
		@options = @enumOption.options
		for opt in @options
			@optionsSprites.push(EAMSprite.new(@optvp))
			@optionsSprites.last.bitmap = Bitmap.new(opt.length * 12,44)
			@optionsSprites.last.ox = @optionsSprites.last.bitmap.width/2
			@optionsSprites.last.bitmap.font = OPT_OPTFONT
			@optionsSprites.last.x = 138 + (@options.index(opt)-@selIndex)*90
			updateOptions(@options.index(opt))
		end
	end
	
	def updateOptions(id)
		return if id>@optionsSprites.length
		@optionsSprites[id].bitmap.clear
    @optionsSprites[id].bitmap.font.name = id==@selIndex && !$MKXP ? "Barlow Condensed ExtraBold" :  "Barlow Condensed"
    @optionsSprites[id].bitmap.font.bold = id==@selIndex && $MKXP ? true : false
		pbDrawTextPositions(@optionsSprites[id].bitmap,[[@options[id],@optionsSprites[id].bitmap.width/2,9,2,(id==@selIndex ? OPT_SELCOLOR : OPT_NORMALCOLOR)]])
	end
	
	def increase
		@selIndex = @selIndex+1>=@options.length ? @selIndex : @selIndex+1
		updateOptionsPosition
	end
	
	def decrease
		@selIndex = @selIndex-1<0 ? @selIndex : @selIndex-1
		updateOptionsPosition
	end
	
	#handles options changing color too
	def updateOptionsPosition
		for opt in @options
			id = @options.index(opt)
			updateOptions(id)
			@optionsSprites[id].move(138 + (@options.index(opt)-@selIndex)*90,0,8,:ease_out_cubic)
		end
	end
	
	def x=(value)
		super(value)
		@optvp.rect.x=value+160
	end
	
	def y=(value)
		super(value)
		@optvp.rect.y=value+5
	end
	
	def opacity=(value)
		super(value)
		if @optionsSprites != nil
			for opt in @optionsSprites
				opt.opacity=value
			end
		end
		@arrows.opacity=value
	end
	
	def color=(value)
		super(value)
		if @optionsSprites != nil
			for opt in @optionsSprites
				opt.color=value
			end
		end
		@arrows.color=value
	end
	
	def dispose
		if @optionsSprites != nil
			for opt in @optionsSprites
				opt.dispose
			end
		end
		@arrows.dispose
		@optvp.dispose
		super
	end
	
end


class PokemonOption
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbOptions
    @scene.pbEndScene
  end
end