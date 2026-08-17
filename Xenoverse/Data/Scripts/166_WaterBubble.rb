#===============================================================================
# Water Bubbles script by KleinStudio
# http://kleinstudio.deviantart.com
# This script will show water bubbles for a good beach effect
#===============================================================================
# Terrain tag where the water animation will be displayed
WBTERRAINTAG=16
WATERPICTURE="Graphics/Pictures/water"
FILL_SPEED = 2.9
UNFILL_SPEED = 1.9
$poison_pause = false
$saved_bar = nil

#===============================================================================
# Water Anim class
# It will load and create the sprite and bitmap in map when needed
# Based in Luka SJ Animated Bitmap Wrapper
#===============================================================================
def inMud?
  return $game_map.terrain_tag($game_player.x, $game_player.y)==WBTERRAINTAG
end

class ProgressBar < BitmapSprite
  
  attr_accessor :progress
  
  def initialize(progress = 0)
    echoln("INITALIZING NEW BAR!")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99
    super(Graphics.width, Graphics.height, @viewport)
    @image = Bitmap.new(_INTL("Graphics/Pictures/Veleno/progressione"))
    @x = (Graphics.width - 366) / 2 + 45
    @y = Graphics.height - @image.height - 44
    @speed = FILL_SPEED / 1000.0
    @progress = 0
  end
  
  def update
    if inMud? && !$poison_pause
			echoln("Percentuale barra veleno: #{@progress*100}%")
      if @progress >= 1
        @progress = 0
        for i in 0...$Trainer.party.length
          if $Trainer.party[i].status != PBStatuses::POISON
            $Trainer.party[i].status = PBStatuses::POISON
            pbSEPlay("Poison.ogg")
            break
          end
        end
      else
        @progress += @speed
      end
    else
      @progress -= UNFILL_SPEED / 1000.0 if !$poison_pause
      @progress = 0 if @progress <= 0
    end
    self.bitmap.clear
    self.bitmap.blt(@x, @y, @image, Rect.new(0, 0, @image.width * @progress, @image.height))
  end
  
end

class BarraVeleno < BitmapSprite
  
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100
    super(Graphics.width, Graphics.height, @viewport)
    @image = Bitmap.new(_INTL("Graphics/Pictures/Veleno/barra"))
    @x = (Graphics.width - @image.width) / 2
    @y = Graphics.height - @image.height - 30
    @progression = ProgressBar.new
  end
  
  def canDispose?
    return @progression.progress <= 0
  end
  
  def update
    @progression.update
    self.bitmap.clear
    if @progression.progress > 0 || inMud?
      self.bitmap.blt(@x, @y, @image, Rect.new(0, 0, @image.width, @image.height))
    end
  end
  
end

class WaterAnim
 def initialize(sprite,event,viewport=nil,map=nil)
   @barra = nil
   @rsprite=sprite
   @event=event
   @map=map
   @disposed=false
   @viewport=viewport
   @wateranim=false
   @frame = 0
   @frames = 4
   @totalFrames = 0
   @currentIndex = 0
   @bitmapFile=BitmapCache.load_bitmap(WATERPICTURE)
   @bitmap=Bitmap.new(@bitmapFile.width,@bitmapFile.height)
   @bitmap.blt(0,0,@bitmapFile,Rect.new(0,0,@bitmapFile.width,@bitmapFile.height))
   @width=@bitmap.height*2
   @height=@bitmap.height*2
   @totalFrames=@bitmap.width/@bitmap.height
   @animationFrames=@totalFrames*@frames
   @loop_points=[0,@totalFrames]    
   @actualBitmap=Bitmap.new(@width,@height)
   @actualBitmap.clear
   @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/2),0,@width/2,@height/2))
   update
 end

 def dispose
   if !@disposed
    @actualBitmap.dispose if @actualBitmap && !@actualBitmap.disposed?
    @sprite.dispose if @sprite && !@sprite.disposed?
    @sprite=nil
    @disposed=true
    @wateranim=false
   end
 end

 def disposed?
   @disposed
 end
 
 def createWaterAnim(x2,y2)
   return if @wateranim
   @sprite=Sprite.new(@viewport)
   @sprite.bitmap=@actualBitmap
   @sprite.x=x2
   @sprite.y=y2
   pbDayNightTint(@sprite)
   @wateranim=true
 end
  
  def updateAnim
    return if !@wateranim || @sprite && @sprite.disposed? || !@event.moving?
    @frames=4
    @frame+=1
    if @frame >=@frames
      @currentIndex+=1
      @currentIndex=@loop_points[0] if @currentIndex >=@loop_points[1]
      @currentIndex=@loop_points[1]-1 if @currentIndex < @loop_points[0]
      @frame=0
    end
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/2),0,@width/2,@height/2))
    @sprite.bitmap=@actualBitmap
  end
  
 def isInWaterTileId
   if @event==$game_player && 
     newmapinfo=getTileIdFromNewMap
     if newmapinfo.is_a?(Array)
        if newmapinfo[0].terrain_tag(newmapinfo[1],newmapinfo[2])==WBTERRAINTAG
          return true
        end
      end
   end
  if $game_map.terrain_tag(@event.x,@event.y)==WBTERRAINTAG
    return true
  end
   return false
 end
 
  def playerTransfering
   return $game_player.x<=0 || $game_player.y<=0 ||
      ($game_map && ($game_player.x>=$game_map.width ||
      $game_player.y>=$game_map.height))
  end
    
  def getTileIdFromNewMap
    xbehind=($game_player.direction==4) ? $game_player.x+1 : 
    ($game_player.direction==6) ? $game_player.x-1 : $game_player.x
    ybehind=($game_player.direction==8) ? $game_player.y+1 : 
    ($game_player.direction==2) ? $game_player.y-1 : $game_player.y
    if !$game_map.valid?($game_player.x,$game_player.y) || !$game_map.valid?(xbehind,ybehind)
      return if !$MapFactory
      newhere=$MapFactory.getNewMap($game_player.x,$game_player.y)
      if $game_map.valid?($game_player.x,$game_player.y)
        heremap=$game_player.map; herex=$game_player.x; herey=$game_player.y
      elsif newhere && newhere[0]
        heremap=newhere[0]; herex=newhere[1]; herey=newhere[2]
      end
      return [heremap, herex, herey]
    end
  end
    
 def update 
   return if !$scene || !$scene.is_a?(Scene_Map) ||
   @event!=$game_player && (@event.character_name=="" || 
   @event.name.include?("/nowater/"))
   return if @event != $game_player && pbEventCommentInput(@event,0,"NoWater")
   updateAnim
   getTileIdFromNewMap
   @sprite.dispose if @sprite && !@sprite.disposed? && !isInWaterTileId
   @wateranim=false if @sprite && @sprite.disposed?
   if @barra == nil && $saved_bar != nil
     @barra = $saved_bar
     $saved_bar = nil
   end
   if @barra != nil
     $saved_bar = @barra if $poison_pause
     @barra.update
     if @barra.canDispose? && !inMud?
       @barra = nil
       echoln("DISPOSED")
     end
   end
   return if disposed? or !isInWaterTileId
   @barra = BarraVeleno.new if @barra == nil
   x=@rsprite.x-@rsprite.ox
   y=@rsprite.y-@rsprite.oy
   createWaterAnim(x,y)
   @sprite.update if @sprite
   width=@rsprite.src_rect.width
   height=@rsprite.src_rect.height
   @sprite.x=x+width/2
   @sprite.y=y+height
   @sprite.visible=@rsprite.visible
   @sprite.ox=@sprite.bitmap.width/2
   @sprite.oy=@sprite.bitmap.height-4
   @sprite.z=@rsprite.z
 end
end

#===============================================================================
# Spriteset Map edit
# It will create a Water Anim for every character and make it visible 
# when needed
#===============================================================================
class Spriteset_Map
  alias water_old_initialize initialize
  def initialize(map=nil)
    @waterSprites=[]
    water_old_initialize(map)
    for sprite in @character_sprites
      @waterSprites.push(WaterAnim.new(sprite,sprite.character,@viewport1)) if sprite.character!=$game_player
    end
    @waterSprites.push(WaterAnim.new(@playersprite,$game_player,@viewport1,@map))
  end
  
  alias water_old_dispose dispose
  def dispose
    water_old_dispose
    for sprite in @waterSprites
      sprite.dispose
    end
    @waterSprites.clear
  end
    
  alias water_old_update update
  def update
    water_old_update
    for sprite in @waterSprites
      sprite.update
    end
  end
end