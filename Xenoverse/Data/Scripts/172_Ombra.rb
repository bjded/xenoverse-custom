#===============================================================================
# ■ Overworld Shadows by KleinStudio V1.1
# http://pokemonfangames.com
#
# * Making a overworld shadowless
# ** Method 1
#   - Add /noShadow/ to the event name
# ** Method 2
#   - Add the event name to Shadowless_EventNames
#     this is useful for doors for example.
# ** Method 3
#   - Create a new comment in the event and type "NoShadow"
#     If the event is a dependent event you have to put the comment
#     in the common event.
#===============================================================================
# Shadowless event names
Shadowless_EventNames=[
  "NoShadow",
  "BerryPlant",
  "OutdoorLight",
  "Light",
  "HeadbuttTree"
]

# Overworld shadow bitmap
Shadow_Bitmap="Graphics/Pictures/overworldshadow.png"

# Enable shadows for dependent events
Shadows_In_DependentEvents=true

class ShadowSprite
  def initialize(sprite,event,viewport=nil,map=nil,deventname=nil,test=false)
    @rsprite=sprite
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=BitmapCache.load_bitmap(Shadow_Bitmap)
    @event=event
    @map=map
    @disposed=false
    @deventname=deventname
    @viewport=viewport
    @test=test
    update
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite=nil
      @disposed=true
    end
  end
 
  def checkNoShadowNames(eventname)
    return true if eventname.include?("/noShadow/")
    for shadowlessnames in Shadowless_EventNames
      if eventname==shadowlessnames
        return true
      end
    end
    return false
  end

  def update 
    return if @disposed
    if @rsprite.disposed?
      dispose
      return
    end
    
    if !(@event==$game_player)
      eventname=@deventname.nil? ? @event.name : @deventname
      @sprite.visible=!(@event.character_name=="" or @event.character_name=="nil" or 
        @event.bush_depth>0 or checkNoShadowNames(eventname) or !@rsprite.visible)
    else
      @sprite.visible=!(@event.bush_depth>0 or !(@map.id==$game_map.map_id) or $PokemonGlobal.surfing or $PokemonGlobal.bicycle)
    end
		
    if @event!=$game_player
      @sprite.visible=false if pbEventCommentInput(@event,0,"NoShadow")
    end
    
    
    @sprite.visible = false if @event == $game_player && $game_switches[44] == false || pbGetTerrainTag == PBTerrain::Mud
    
    x=@rsprite.x-@rsprite.ox
    character=@rsprite.character
    y=(character.real_y - character.map.display_y + 3)/4+(Game_Map::TILEHEIGHT)
    width=@rsprite.src_rect.width
    height=@rsprite.src_rect.height
    @sprite.x=x+width/2
    @sprite.y=y
    @sprite.ox=@sprite.bitmap.width/2
    @sprite.oy=@sprite.bitmap.height/2+@sprite.bitmap.height/4
    @sprite.z=@rsprite.z-1
    @sprite.opacity = @event.opacity / 5
  end 
end
=begin
class Spriteset_Map
  alias klein_shadow_initialize initialize
  def initialize(map=nil)
    @shadowSprites=[]
    klein_shadow_initialize(map)
    @oldDepedents=dependentEventsSprites.sprites.length
    for sprite in @character_sprites
      next if sprite.character!=$game_player && pbEventCommentInput(sprite.character,0,"NoShadow") 
      @shadowSprites.push(ShadowSprite.new(sprite,sprite.character,@viewport1))
    end
    @shadowSprites.push(ShadowSprite.new(@playersprite,$game_player,@viewport1,@map))
  end
  
  alias klein_shadow_dispose dispose
  def dispose
    klein_shadow_dispose
    for sprite in @shadowSprites
      sprite.dispose
    end
  end
  
  def dependentEventsSprites
    for i in 0...@usersprites.length
      return @usersprites[i] if @usersprites[i].is_a?(DependentEventSprites)
    end
  end
      
  alias klein_shadow_update update
  def update
    klein_shadow_update
    if Shadows_In_DependentEvents && @oldDepedents!=dependentEventsSprites.sprites.length
      for i in 0...$PokemonGlobal.dependentEvents.length      
        event=$PokemonTemp.dependentEvents.realEvents[i]
        sprite=dependentEventsSprites.sprites[i]
        eventname=$PokemonGlobal.dependentEvents[i][8]
        next if sprite.nil? || event.nil?
        next if event!=$game_player && pbEventCommentInput(event,0,"NoShadow") 
        @shadowSprites.push(ShadowSprite.new(sprite,event,@viewport1,nil,eventname, true))
      end
      @oldDepedents=dependentEventsSprites.sprites.length
    end
    
    for sprite in @shadowSprites
      sprite.update
    end
  end 
end
=end
# Whether or not the event names below need to match in capitals as well.
Case_Sensitive = false

No_Shadow_If_Event_Name_Has = [
    # I like to use "extensions" like these. Up to you though.
    ".shadowless",
    ".noshadow",
    ".sl",
    "Door",
    "Stairs",
    "noShadow",
    "NoShadow",
    "BerryPlant",
    "OutdoorLight",
    "Light",
    "HeadbuttTree"
]

# Events that have this in their event name will always receive a shadow.
# Does take "Case_Sensitive" into account.
Always_Give_Shadow_If_Event_Name_Has = [
    "EnemyRight"
]

# Determines whether or not an event should be given a shadow.
def pbShouldGetShadow?(event)
  return true if event.is_a?(Game_Player) # The player will always have a shadow
  page = pbGetActiveEventPage(event)
  return false unless page
  comments = page.list.select { |e| e.code == 108 || e.code == 408 }.map do |e|
    e.parameters.join
  end
  Always_Give_Shadow_If_Event_Name_Has.each do |e|
    name = event.name.clone
    unless Case_Sensitive
      e.downcase!
      name.downcase!
    end
    return true if name.include?(e) || comments.any? { |c| c.include?(e) }
  end
  No_Shadow_If_Event_Name_Has.each do |e|
    name = event.name.clone
    unless Case_Sensitive
      e.downcase!
      name.downcase!
    end
    return false if name.include?(e) || comments.any? { |c| c.include?(e) }
  end
  return true
end

# Extending so we can access some private instance variables.
class Game_Character
  attr_reader :jump_count
end


unless defined?(pbGetActiveEventPage)
  def pbGetActiveEventPage(event, mapid = nil)
    mapid ||= event.map.map_id if event.respond_to?(:map)
    pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
    for i in 0...pages.size
      c = pages[pages.size - 1 - i].condition
      ss = !(c.self_switch_valid && !$game_self_switches[[mapid,
          event.id,c.self_switch_ch]])
      sw1 = !(c.switch1_valid && !$game_switches[c.switch1_id])
      sw2 = !(c.switch2_valid && !$game_switches[c.switch2_id])
      var = true
      if c.variable_valid
        if !c.variable_value || !$game_variables[c.variable_id].is_a?(Numeric) ||
           $game_variables[c.variable_id] < c.variable_value
          var = false
        end
      end
      if ss && sw1 && sw2 && var # All conditions are met
        return pages[pages.size - 1 - i]
      end
    end
    return nil
  end
end

class Spriteset_Map
  attr_accessor :usersprites
end

class Sprite_Character
  attr_accessor :shadow
  
  alias ow_shadow_init initialize
  def initialize(viewport, character = nil, is_follower = false, is_pokemon = false)
    @viewport = viewport
    @is_follower = is_follower
    ow_shadow_init(@viewport, character)
    
    return unless pbShouldGetShadow?(character)
    return if is_pokemon && @is_follower && defined?(Toggle_Following_Switch) &&
              !$game_switches[Toggle_Following_Switch]
    return if is_pokemon && @is_follower && defined?(Following_Activated_Switch) &&
              !$game_switches[Following_Activated_Switch]
    @character = character
    if @character.is_a?(Game_Event) && !@is_follower
      page = pbGetActiveEventPage(@character)
      return if (!page || !page.graphic || page.graphic.character_name == "")
    end
    make_shadow
  end
  
  def make_shadow
    @shadow.dispose if @shadow
    @shadow = nil
    @shadow = Sprite.new(@viewport)
    @shadow.bitmap = BitmapCache.load_bitmap(Shadow_Bitmap)#(Shadow_Path)
    @shadow.opacity = @character.opacity / 5
    # Center the shadow by halving the origin points
    @shadow.ox = @shadow.bitmap.width / 2.0
    @shadow.oy = @shadow.bitmap.height / 2.0
    # Positioning the shadow
    position_shadow
  end
  
  def position_shadow
    return unless @shadow
    x = @character.screen_x
    y = @character.screen_y

    if @character.jumping? 
      @totaljump = @character.jump_count if !@totaljump

      case @character.jump_count
      when 1..(@totaljump / 3)
        @shadow.zoom_x += 0.1 if @shadow.zoom_x < 1
        @shadow.zoom_y += 0.1 if @shadow.zoom_y < 1
      when (@totaljump / 3 + 1)..(@totaljump / 3 + 2)
        @shadow.zoom_x += 0.05 if @shadow.zoom_x < 1
        @shadow.zoom_y += 0.05 if @shadow.zoom_y < 1
      when (@totaljump / 3 * 2 - 1)..(@totaljump / 3 * 2)
        @shadow.zoom_x -= 0.05 if @shadow.zoom_x > 0
        @shadow.zoom_y -= 0.05 if @shadow.zoom_y > 0
      when (@totaljump / 3 * 2 + 1)..(@totaljump)
        @shadow.zoom_x -= 0.1 if @shadow.zoom_x > 0
        @shadow.zoom_y -= 0.1 if @shadow.zoom_y > 0
      end

      if @character.jump_count == 1
        @shadow.zoom_x = 1.0
        @shadow.zoom_y = 1.0
        @totaljump = nil
      end
    end

    @shadow.x = x
    @shadow.y = @character.screen_y_ground - 3
    @shadow.z = self.z - 1
    if @shadow
      if !@charbitmap || @charbitmap.disposed? || @character.instance_eval { @erased }
        @shadow.dispose
        @shadow = nil
      end
    end
  end
  
  alias ow_shadow_visible visible=
  def visible=(value)
    ow_shadow_visible(value)
    bushdepth = @character.bush_depth
    
    if @shadow
      @shadow.visible = value && (bushdepth == 0)
      #echoln "#{bushdepth} #{@shadow.visible}" if @character == $game_player
      if !self.visible || (@is_follower || @character == $game_player) && ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        @shadow.visible = false
      end
    end
  end

  alias ow_shadow_dispose dispose
  def dispose
    ow_shadow_dispose
    @shadow.dispose if @shadow
    @shadow = nil
  end

  alias ow_shadow_update update
  def update
    ow_shadow_update
    position_shadow
    
    if @character.is_a?(Game_Event)
      page = pbGetActiveEventPage(@character)
      if @old_page != page
        @shadow.dispose if @shadow
        @shadow = nil
        if page && page.graphic && page.graphic.character_name != "" &&
          pbShouldGetShadow?(@character)
          unless @is_follower && defined?(Toggle_Following_Switch) &&
                 !$game_switches[Toggle_Following_Switch]
          unless @is_follower && defined?(Following_Activated_Switch) &&
                   !$game_switches[Following_Activated_Switch]
              make_shadow
            end
          end
        end
      end
    end
    
    @old_page = (@character.is_a?(Game_Event) ? pbGetActiveEventPage(@character) : nil)
    
    bushdepth = @character.bush_depth
    
    if @shadow
      @shadow.opacity = self.opacity / 5
      @shadow.visible = (bushdepth == 0)
      #echoln "#{bushdepth} #{@shadow.visible}" if @character == $game_player
      if !self.visible || (@is_follower || @character == $game_player) && ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        @shadow.visible = false
      end
    end
  end
end

=begin

class DependentEvents
  attr_accessor :realEvents
  alias klein_shadows_addevent addEvent
  def addEvent(event,eventName=nil,commonEvent=nil)
    if event && !event.nil?
      if eventName.nil?
        eventName=event.name 
      end
    end
    klein_shadows_addevent(event,eventName,commonEvent)
  end
end
=end

class DependentEventSprites
  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent do |event, data|
       if data[2] == @map.map_id # Check current map
          echoln "CREATING FOLLOWER SPRITE"
         spr = Sprite_Character.new(@viewport,event,true)
         @sprites.push(spr)
       end
    end
  end
end

=begin
class DependentEventSprites
  attr_accessor :sprites
end
=end