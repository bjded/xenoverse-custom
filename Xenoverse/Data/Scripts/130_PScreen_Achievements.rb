###############################################################################
# Achievements Screen                                                         #
# by AGSoldier                                                                #
###############################################################################
$orderedAchievements=[]


class Item < Sprite

  attr_accessor :name
  attr_accessor :icon
  attr_accessor :title
  attr_accessor :description
  attr_accessor :unlocked
  attr_accessor :completed
  attr_accessor :selected
  
  def initialize(x, y)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(@viewport)
    self.x = x
    self.y = y
    @default = "Graphics/Achievements/Default"
    @image = Bitmap.new("Graphics/Pictures/Achievements/Screen/selectedItem")
    self.bitmap = Bitmap.new("Graphics/Pictures/Achievements/Screen/selectedItem")
    @baseColor = Color.new(0, 0, 0)
    @@shadowColor = Color.new(64, 64, 64)
    @selected = false
  end
  
  def update
    self.bitmap.clear
    self.bitmap.blt(0, 0, @image, Rect.new(0, 0, 835, 82))
    #self.bitmap.blt(1, 1, Bitmap.new(_INTL(@icon)), Rect.new(0, 0, 80, 80))
    if @unlocked
      self.bitmap.blt(1, 1, Bitmap.new(_INTL(@icon)), Rect.new(0, 0, 80, 80))
    else
      self.bitmap.blt(1, 1, Bitmap.new(_INTL(@default)), Rect.new(0, 0, 80, 80))
    end
    if @selected
      #pbSetSystemFont(self.bitmap)
      pbSetFont(self.bitmap,ACHIEVEMENT_FONT_NAME,ACHIEVEMENT_FONT_SIZE)
      if @unlocked
        Achievement_UI.screenProgressBar(140, 13, self.bitmap, $achievements[@name],true) if !@completed
        #self.bitmap.blt(1, 1, Bitmap.new(_INTL(@icon)), Rect.new(0, 0, 80, 80))
        #self.tone = Tone.new(0, 0, 0 , 0)
        bitmap.font.bold = true# if !$MKXP
        pbDrawTextPositions(self.bitmap, [[$PokemonSystem.language==0 ? @title : $achtr[@title], 85, 13, false, @baseColor]])
        #pbDrawTextPositions(self.bitmap, [[$PokemonSystem.language==0 ? @title : $achtr[@title], 86, 13, false, @baseColor]]) if $MKXP
        bitmap.font.bold = false
        echoln @description
        echoln $achtr[@description]
        pbDrawTextPositions(self.bitmap, [[$PokemonSystem.language==0 ? @description : $achtr[@description], 85, 46, false, @baseColor]])
        
      else
        #self.bitmap.blt(1, 1, Bitmap.new(_INTL(@default)), Rect.new(0, 0, 80, 80))
        #self.tone = Tone.new(0, 0, 0, 255)
        Achievement_UI.screenProgressBar(85, 13, self.bitmap, $achievements[@name])
        #pbDrawTextPositions(self.bitmap, [["???", 100, 13, false, @baseColor]])
        pbDrawTextPositions(self.bitmap, [["???", 85, 46, false, @baseColor]])
      end
    else
      #pbSetSystemFontWithSize(self.bitmap, 50)
      pbSetFont(self.bitmap,ACHIEVEMENT_FONT_NAME,ACHIEVEMENT_FONT_SIZE_NOTSEL)
      if @unlocked
        #self.bitmap.blt(1, 1, Bitmap.new(_INTL(@icon)), Rect.new(0, 0, 80, 80))
        #self.tone = Tone.new(0, 0, 0 , 0)
        bitmap.font.bold = true
        pbDrawTextPositions(self.bitmap, [[$PokemonSystem.language==0 ? @title : $achtr[@title], 95, 15, false, @baseColor]])
        bitmap.font.bold = false
      else
        #self.bitmap.blt(1, 1, Bitmap.new(_INTL(@default)), Rect.new(0, 0, 80, 80))
        #self.tone = Tone.new(0, 0, 0, 255)
        pbDrawTextPositions(self.bitmap, [["???", 95, 15, false, @baseColor]])
      end
      self.zoom_x = 0.5
      self.zoom_y = 0.5
    end
  end
  
end

class AchievementsScreen
  
  def initialize
    @running = true
    @amount = $achievements.length
    @index = 0
    
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
  
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Achievements/Screen/bg")
    @sprites["bg"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
		@sprites["bg"].bitmap.font.size = 32
		pbDrawTextPositions(@sprites["bg"].bitmap,[[_INTL("Achievements"),256,0,2,Color.new(248,248,248),Color.new(24,24,24),true]])
		
		
    @sprites["up"] = IconSprite.new(0, 0, @viewport)
    @sprites["up"].setBitmap("Graphics/Pictures/Achievements/Screen/up")
    @sprites["up"].x = 435
    @sprites["up"].y = 35
    
    @sprites["down"] = IconSprite.new(0, 0, @viewport)
    @sprites["down"].setBitmap("Graphics/Pictures/Achievements/Screen/down")
    @sprites["down"].x = 435
    @sprites["down"].y = 305
    
    @sprites["item1"] = Item.new(-4, 31)
    @sprites["item1"].opacity = 102
    
    @sprites["item2"] = Item.new(15, 75)
    @sprites["item2"].opacity = 153
    
    @sprites["item3"] = Item.new(35, 119)
    @sprites["item3"].opacity = 204
    
    @sprites["item4"] = Item.new(35, 247)
    @sprites["item4"].opacity = 204
    
    @sprites["item5"] = Item.new(15, 291)
    @sprites["item5"].opacity = 153
    
    @sprites["item6"] = Item.new(-4, 335)
    @sprites["item6"].opacity = 102
    
    @sprites["item7"] = Item.new(40, 163)
    @sprites["item7"].selected = true
    
    self.openScene
  end
  
  def openScene
    self.inputAction
		pbUpdateSpriteHash(@sprites)
    pbFadeInAndShow(@sprites){}
		
    self.mainLoop
  end
  
  def closeScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end
  
  def processInput
    if (Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)) && @index < @amount - 1
      pbSEPlay("Choose")
      @index += 1
			self.inputAction
			pbUpdateSpriteHash(@sprites)
    end
    if (Input.trigger?(Input::UP) || Input.repeat?(Input::UP)) && @index > 0
      pbSEPlay("Choose")
      @index -= 1
			self.inputAction
			pbUpdateSpriteHash(@sprites)
    end
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      @running = false
    end
    
  end
  
  def inputAction
    for i in 1..7      
      if i<4
        value = i-4
      else
        value = (i-3)
      end
      value = 0 if i==7
      @sprites["item#{i}"].visible = (i<4 ? @index >= -value : @index < @amount - value) if i != 7 
      if $achievements[$orderedAchievements[@index+value]] != nil && i != 7 || i==7#$achievements.values[@index + value] != nil && i != 7 || i==7
        @sprites["item#{i}"].completed = $achievements[$orderedAchievements[@index+value]].completed
        @sprites["item#{i}"].unlocked = $achievements[$orderedAchievements[@index+value]].locked ? false : !$achievements[$orderedAchievements[@index+value]].hidden
        @sprites["item#{i}"].name = $achievements[$orderedAchievements[@index+value]].name if i==7
        @sprites["item#{i}"].title = $achievements[$orderedAchievements[@index+value]].title
        @sprites["item#{i}"].icon = $achievements[$orderedAchievements[@index+value]].image
        @sprites["item#{i}"].description = $achievements[$orderedAchievements[@index+value]].description
      end
    end
  end
  
  def mainLoop
    while @running
      Input.update
      Graphics.update
      self.processInput
      #pbUpdateSpriteHash(@sprites)
    end
    pbFadeOutIn(99999){
      self.closeScene
    }
  end
  
end