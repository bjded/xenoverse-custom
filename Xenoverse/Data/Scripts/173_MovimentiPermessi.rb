#===============================================================================
# * Debug Passability Script for Pokémon Essentials by shiney570.
#
# Current Version: V2.0
# 
# 
# * If you have any questions or found a bug let me know.
# * Contact: Skype: imatrix.wt ;  DeviantArt: shiney570
#===============================================================================

# SETTINGS

# When true, the event squares will be visible. (May reduce lag.)
SHOW_EVENTS         = true
# When true, the passability squares will be visible.
SHOW_PASSIBILITY    = true
# When true, the terrain tags will be visible.
SHOW_TERRAIN_TAGS   = true

# Size of the field square. (choose a number between 1 and 15.)
$passa_field_size   = 4
# Size of the event square. (choose a number between 1 and 32.)
$passa_event_size   = 16
$passa_event_size_outline = 2
# Opacity of the squares.
# (choose a number between 0 (invisible) and 255 (visible).)

$passa_opacity        = 200 
# Color of the field squares. (red by default.)
$passa_field_color    = Color.new(255,0,0)
# Color of the event squares. 
$passa_event_color    = Color.new(0,0,0) # (black by default.)
$passa_event_color2   = Color.new(255,255,255)# (white by default.)
# Color of the terrain text.
$passa_terrain_color  = Color.new(255,255,255) # (white by default.)
$passa_terrain_color2  = Color.new(0,0,0) # (black by default.)
#===============================================================================

class Debug_Passability 
  def initialize
    # The next four lines were made for idiots.
    $passa_field_size=4 if ($passa_field_size>15 || $passa_field_size<1)
    $passa_event_size=16 if ($passa_event_size>32 || $passa_field_size<1)
    $passa_event_size_outline=2 if ($passa_event_size_outline>32 || $passa_event_size_outline<1)
    $passa_opacity=200 if ($passa_opacity>255 || $passa_opacity<1)
    # Creating bitmap and sprite.
    if $passa_bitmap
      $passa_bitmap.clear
      $passa_sprite.dispose
      $passa_terrain_bitmap.dispose if $passa_terrain_bitmap
    end
    $passa_bitmap=Bitmap.new($game_map.width*32,$game_map.height*32)
    $passa_sprite=Sprite.new
    $passa_sprite.bitmap=$passa_bitmap
    $passa_sprite.z=100
    $passa_sprite.opacity=$passa_opacity
    $passa_bitmap.clear 
    
    $passa_terrain_bitmap=BitmapSprite.new($game_map.width*32,$game_map.height*32)
    $passa_terrain_bitmap.z=$passa_sprite.z
    $passa_terrain_bitmap.bitmap.font.name="Arial"
    $passa_terrain_bitmap.bitmap.font.size=20
    $passa_terrain=[]
    # Filling the fields.
    for xval in 0..$game_map.width
      for yval in 0..$game_map.height
        x=16+xval*32
        y=16+yval*32
        if isEvent?(xval,yval) 
          $passa_bitmap.fill_rect(x+16-($passa_event_size/2),
          y+16-($passa_event_size/2),$passa_event_size,
          $passa_event_size,$passa_event_color)
          $passa_bitmap.fill_rect(x+16-($passa_event_size/2),
          y+16-($passa_event_size/2),$passa_event_size,
          $passa_event_size_outline,$passa_event_color2)
          $passa_bitmap.fill_rect(x+16-($passa_event_size/2),
          y+16-($passa_event_size/2)+$passa_event_size-$passa_event_size_outline,
          $passa_event_size,$passa_event_size_outline,$passa_event_color2)
          $passa_bitmap.fill_rect(x+16-($passa_event_size/2),
          y+16-($passa_event_size/2),$passa_event_size_outline,
          $passa_event_size,$passa_event_color2)
          $passa_bitmap.fill_rect(x+16-($passa_event_size/2)+$passa_event_size-$passa_event_size_outline,
          y+16-($passa_event_size/2),$passa_event_size_outline,$passa_event_size,
          $passa_event_color2)
        end
        if !playerPassable?(xval,yval,2) # DOWN
          $passa_bitmap.fill_rect(x,y+32-$passa_field_size,32,
          $passa_field_size,$passa_field_color)
        end
        if !playerPassable?(xval,yval,4) # LEFT
          $passa_bitmap.fill_rect(x,y,$passa_field_size,32,
          $passa_field_color)
        end
        if !playerPassable?(xval,yval,6) # RIGHT
          $passa_bitmap.fill_rect(x+32-$passa_field_size,y,
          $passa_field_size,32,$passa_field_color)
        end
        if !playerPassable?(xval,yval,8) # UP
          $passa_bitmap.fill_rect(x,y,32,$passa_field_size,
          $passa_field_color)
        end
        tileHasTerrainTag?(xval,yval) if SHOW_TERRAIN_TAGS
      end
    end
    pbDrawTextPositions($passa_terrain_bitmap.bitmap,$passa_terrain)
  end
  
   # Method which returns the passability of a field.
  def playerPassable?(x, y, d, self_event = nil)
    @passages=$passa_passages
    @priorities=$passa_priorities
    @terrain_tags=$passa_terrain_tags
    bit = (1 << (d / 2 - 1)) & 0x0f
    for i in [2, 1, 0]
      tile_id = $game_map.data[x, y, i]
      # Ignore bridge tiles if not on a bridge
      next if $PokemonMap && $PokemonMap.bridge==0 &&
         tile_id && @terrain_tags[tile_id]==PBTerrain::Bridge
      if tile_id == nil
        return false
      # Make water tiles passable if player is surfing
      elsif $PokemonGlobal.surfing &&
         pbIsPassableWaterTag?(@terrain_tags[tile_id])
        return true
      # Prevent cycling in really tall grass
      elsif $PokemonGlobal.bicycle &&
         @terrain_tags[tile_id]==PBTerrain::TallGrass
        return false
      # Prevent cycling on ice
      elsif $PokemonGlobal.bicycle &&
         @terrain_tags[tile_id]==PBTerrain::Ice
        return false
      # Depend on passability of bridge tile if on bridge
      elsif $PokemonMap && $PokemonMap.bridge>0 &&
         @terrain_tags[tile_id]==PBTerrain::Bridge
        if @passages[tile_id] & bit != 0 ||
           @passages[tile_id] & 0x0f == 0x0f
          return false
        else
          return true
        end
      # Regular passability checks
      elsif @passages[tile_id] & bit != 0
        return false
      elsif @passages[tile_id] & 0x0f == 0x0f
        return false
      elsif @priorities[tile_id] == 0
        return true
      end
    end
    return true
  end
  
  def valid?(x, y)
     return (x >= 0 and x < $game_map.width and y >= 0 and y < $game_map.height)
   end
   
  # Method which returns whether a square is an event or not.
  def isEvent?(x,y)
    return false if !SHOW_EVENTS
    for event in $game_map.events.values
      if ( (x==event.x) && (y==event.y) )
        return true
      end
    end
    return false
  end

# Method which checks whether a tile has a terrain tag.
  def tileHasTerrainTag?(x,y)
    if $game_map.terrain_tag(x,y)>0
     # p "#{$game_map.terrain_tag(x,y)} #{x} #{y}"
      $passa_terrain.push([_INTL("{1}",$game_map.terrain_tag(x,y)),
      32+32*x,22+32*y,2,$passa_terrain_color,$passa_terrain_color2])
    end
  end
end

# Updating Game_Map so the passable method won't have undefined methods.
class Game_Map
  alias old_setup_kodsn :setup
  def setup(map_id)
    old_setup_kodsn(map_id)
    $passa_passages=@passages 
    $passa_priorities=@priorities 
    $passa_terrain_tags=@terrain_tags 
  end
end

# Disposes the Passability stuff.
def dispose_Debug_Passability 
  $passa_sprite.dispose
  $passa_bitmap.clear
  $passa_terrain_bitmap.dispose
  $passa_sprite=nil
  $passa_bitmap=nil
  $passa_terrain_bitmap=nil
end

# Weird method which checks whether the Debug Passability needs an update or not.
def passability_needs_update?
  $passa_event_array="" if !$passa_event_array
  $passa_event_array2=""
  for event in $game_map.events.values
    $passa_event_array2.insert($passa_event_array2.length,"#{event.x}") if SHOW_EVENTS
    $passa_event_array2.insert($passa_event_array2.length,"#{event.y}") if SHOW_EVENTS
  end
  if $PokemonMap
    $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonMap.bridge}") if SHOW_PASSIBILITY
    $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonMap.movedEvents}") if SHOW_PASSIBILITY
    $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonMap.erasedEvents}") if SHOW_PASSIBILITY
  end
  $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonGlobal.bicycle}") if SHOW_PASSIBILITY
  $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonGlobal.surfing}") if SHOW_PASSIBILITY
  $passa_event_array2.insert($passa_event_array2.length,"#{$PokemonGlobal.sliding}") if SHOW_PASSIBILITY
  $passa_event_array2.insert($passa_event_array2.length,"#{$game_map}") if SHOW_PASSIBILITY
  if $passa_event_array == $passa_event_array2
    return false
  else
    $passa_event_array=$passa_event_array2
    return true
  end
end

# Fixes Bug with jumping.
class Game_Player < Game_Character
  alias old_update_shiney :update
  def update
    if $passa_sprite
      Debug_Passability.new if passability_needs_update?
      $passa_sprite.x= -($game_map.display_x/4)-16 
      $passa_sprite.y= -($game_map.display_y/4)-16
      if $passa_terrain_bitmap
        $passa_terrain_bitmap.x=$passa_sprite.x
        $passa_terrain_bitmap.y=$passa_sprite.y
      end
     end     
    old_update_shiney
  end
end

if !$MKXP
# Creating Input K.
  module Input  
    K = 42
    class << self
      alias old_self_button_to_key_shiney :buttonToKey
    end
    
    def self.buttonToKey(button)
      case button    
      when Input::K
        return [0x4B] # K
      end 
      self.old_self_button_to_key_shiney(button)
    end
  end
end
# Updating Scene_Map
class Scene_Map 
  def main
    createSpritesets
    Graphics.transition      
    loop do
      if $passa_sprite
        Debug_Passability.new if passability_needs_update?
        $passa_sprite.x= -($game_map.display_x/4)-16 
        $passa_sprite.y= -($game_map.display_y/4)-16
        if $passa_terrain_bitmap
          $passa_terrain_bitmap.x=$passa_sprite.x
          $passa_terrain_bitmap.y=$passa_sprite.y
        end
      end      
      Graphics.update
      Input.update
      update
      if Input.trigger?($MKXP ? [0x4B] : Input::K) && $DEBUG
        if $passa_sprite
          dispose_Debug_Passability
        else
          Debug_Passability.new
        end
      end
      #if SAVESTATES
      #  update_savestates
      #end
      #if ($saveStateFrameCount && SAVESTATES )
      #  $saveStateFrameCount+=1
      #  if $saveStateFrameCount>=80
      #    $saveStateBitmap.bitmap.clear
      #    $saveStateFrameCount=nil
      #  end
      #end
      if $scene != self
        break
      end
    end
    Graphics.freeze
    disposeSpritesets
    if $game_temp.to_title
      Graphics.transition
      Graphics.freeze
    end
  end
end