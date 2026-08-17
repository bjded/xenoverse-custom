#===============================================================================
#  Elite Battle system
#    by Luka S.J.
# ----------------
#  Sprites Script
# ----------------  
#  system is based off the original Essentials battle system, made by
#  Poccil & Maruno
#  No additional features added to AI, mechanics 
#  or functionality of the battle system.
#  This update is purely cosmetic, and includes a B/W like dynamic scene with a 
#  custom interface.
#
#  Enjoy the script, and make sure to give credit!
#-------------------------------------------------------------------------------
#  New methods for creating in-battle Pokemon sprites.
#  * creates fixed shadows in the sprite itself
#  * calculates correct positions according to metric data in here
#  * sprites have a different focal point for more precise base placement
#===============================================================================
class DynamicPokemonSprite
  attr_accessor :shadow
  attr_accessor :sprite
  attr_accessor :showshadow
  attr_accessor :status
  attr_accessor :hidden
  attr_accessor :fainted
  attr_accessor :anim
  attr_reader :loaded
  attr_reader :selected
  attr_reader :isSub
  attr_reader :viewport
  attr_reader :pulse

  def initialize(doublebattle,index,viewport=nil)
    @viewport=viewport
    @metrics=load_data("Data/metrics.dat")
    @selected=0
    @frame=0
    
    @status=0
    @loaded=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=0
    @yposition=0
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
      back=(@index%2==0)
    @substitute=AnimatedBitmapWrapper.new("Graphics/Battlers/"+(back ? "substitute_back" : "substitute"),POKEMONSPRITESCALE)
    @overlay=Sprite.new(@viewport)
    @isSub=false
    @lock=false
    @pokemon=nil
    @still=false
    @hidden=false
    @fainted=false
    @anim=false

    @trail = false
    @trails = []
    @trailct = 0
    @trailbmp = nil

    @pulse = 8
    @k = 1
  end

  def battleIndex; return @index; end
  def x; @sprite.x; end
  def y; @sprite.y; end
  def z; @sprite.z; end
  def ox; @sprite.ox; end
  def oy; @sprite.oy; end
  def zoom_x; @sprite.zoom_x; end
  def zoom_y; @sprite.zoom_y; end
  def visible; @sprite.visible; end
  def opacity; @sprite.opacity; end
  def width; @bitmap.width; end
  def height; @bitmap.height; end
  def tone; @sprite.tone; end
  def bitmap; @bitmap.bitmap; end
  def actualBitmap; @bitmap; end
  def disposed?; @sprite.disposed?; end
  def color; @sprite.color; end
  def src_rect; @sprite.src_rect; end
  def blend_type; @sprite.blend_type; end
  def angle; @sprite.angle; end
  def mirror; @sprite.mirror; end
  def src_rect; return @sprite.src_rect; end
  def src_rect=(val)
    @sprite.src_rect=val
  end
  def lock
    @lock=true
  end
  def bitmap=(val)
    @bitmap.bitmap=val
  end
  def x=(val)
    @sprite.x=val
    @shadow.x=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
  end
  def ox=(val)
    @sprite.ox=val
    self.formatShadow
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
  end
  def addOx(val)
    @sprite.ox+=val
    self.formatShadow
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
  end
  def oy=(val)
    @sprite.oy=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def addOy(val)
    @sprite.oy+=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def y=(val)
    @sprite.y=val
    @shadow.y=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
  end
  def z=(val)
    @shadow.z=(val==32) ? 31 : 10
    @sprite.z=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
  end
  def zoom_x=(val)
    @sprite.zoom_x=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def zoom_y=(val)
    @sprite.zoom_y=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def visible=(val)
    return if @hidden
    @sprite.visible=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
            
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def opacity=(val)
    @sprite.opacity=val
    if @trail    
      for t in @trails
        t.x = @sprite.x
        t.y = @sprite.y
        t.ox = @sprite.ox
        t.oy = @sprite.oy
        t.zoom_x = @sprite.zoom_x
        t.zoom_y = @sprite.zoom_y
        t.angle = @sprite.angle
        t.opacity=val
        t.src_rect = @sprite.src_rect
      end
    end
    self.formatShadow
  end
  def tone=(val)
    @sprite.tone=val
  end
  def color=(val)
    @sprite.color=val
  end
  def blend_type=(val)
    @sprite.blend_type=val
    self.formatShadow
  end
  def angle=(val)
    @sprite.angle=(val)
    self.formatShadow
  end
  def mirror=(val)
    @sprite.mirror=(val)
    self.formatShadow
  end
  def dispose
    if @trail
      for t in @trails
        t.dispose
      end
    end
    @sprite.dispose
    @shadow.dispose
  end
  def selected=(val)
    @selected=val
    @sprite.visible=true if !@hidden
  end
  def toneAll(val)
    @sprite.tone.red+=val
    @sprite.tone.green+=val
    @sprite.tone.blue+=val
    
    if @trail
      for t in @trails
        t.tone.red+=val
        t.tone.green+=val
        t.tone.blue+=val
      end
    end
  end
  
  def setBitmap(file,shadow=false)
    @showshadow = shadow
    @bitmap = AnimatedBitmapWrapper.new(file)
    @bitmap.setSpeed(3) 
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone    
    @loaded = true
    self.formatShadow
  end
  
  def setPokemonBitmap(pokemon,back=false)
    return if !pokemon || pokemon.nil?
    @pokemon = pokemon
    if @pokemon.species == PBSpecies::DRAGALISKFURIA && ($game_switches[1330]==false && ($game_switches[1317] || $game_switches[1318]))
      @trail=true
    end
    @altitude = @metrics[2][pokemon.species]
    @altitude = pokemon.is_a?(PokeBattle_Pokemon) ? pokemon.altitude(@altitude) : pokemon.pokemon.altitude(@altitude) 
    if back
      @yposition = @metrics[0][pokemon.species]
      @altitude *= 0.5
    else
      @yposition = @metrics[1][pokemon.species]
    end
		@yposition = pbFormMetricsOverride(pokemon,pokemon.form,@yposition)
    scale = back ? BACKSPRITESCALE : POKEMONSPRITESCALE
    @bitmap = pbLoadPokemonBitmap(pokemon,back,scale)
    @bitmap.setSpeed(3) 
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= pokemon.formOffsetY if pokemon.respond_to?(:formOffsetY)
    if @isSub
      setSubstitute
    end

    @fainted = false
    @loaded = true
    @pulse = 8
    @k = 1
    self.formatShadow
  end
  
  def refreshMetrics(metrics)
    @metrics = metrics
    @altitude = @metrics[2][@pokemon.species]
    if (@index%2==0)
      @yposition = @metrics[0][@pokemon.species]
      @altitude *= 0.5
    else
      @yposition = @metrics[1][@pokemon.species]
    end
    @yposition = pbFormMetricsOverride(pokemon,pokemon.form,@yposition,(@index%2==0))
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= @pokemon.formOffsetY if @pokemon.respond_to?(:formOffsetY)
  end
  
  def setSubstitute
    @isSub = true
    @sprite.bitmap = @substitute.bitmap.clone
    @shadow.bitmap = @substitute.bitmap.clone
    @sprite.ox = @substitute.width/2
    @sprite.oy = @substitute.height
    self.formatShadow
  end
  
  def removeSubstitute
    @isSub = false
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= @pokemon.formOffsetY if @pokemon && @pokemon.respond_to?(:formOffsetY)
    self.formatShadow
  end
  
  def still
    @still = true
  end
  
  def clear
    if @trail
      for t in @trails
        t.dispose
      end
    end
    @sprite.bitmap.clear
    @bitmap.dispose
  end
  
  def formatShadow
    @shadow.zoom_x = @sprite.zoom_x*0.90
    @shadow.zoom_y = @sprite.zoom_y*0.30
    @shadow.ox = @sprite.ox - 6
    @shadow.oy = @sprite.oy - 6
    @shadow.opacity = @sprite.opacity*0.3
    @shadow.tone = Tone.new(-255,-255,-255,255)
    @shadow.visible = @sprite.visible
    @shadow.mirror = @sprite.mirror
    @shadow.angle = @sprite.angle
    
    @shadow.visible = false if !@showshadow
  end
  
  def spriteUpdate
    if @trail    
      for t in @trails
        t.src_rect = @sprite.src_rect
      end
    end
  end


  def update(angle=74)
    if @still
      @still=false
      return
    end
    return if @lock
    return if !@bitmap || @bitmap.disposed?
    if @isSub
      @substitute.update
      @sprite.bitmap=@substitute.bitmap.clone
      @shadow.bitmap=@substitute.bitmap.clone
    else
      @bitmap.update do |bitmap,index,scale|
        if @trail
          if !@fainted
            @trailct += 1  
            @trails << EAMSprite.new(@viewport)
            @trails.last.x = @sprite.x
            @trails.last.y = @sprite.y
            @trails.last.ox = @sprite.ox
            @trails.last.oy = @sprite.oy
            @trails.last.src_rect = @sprite.src_rect
            @trails.last.z = @sprite.z-1
            @trails.last.bitmap = Bitmap.new(bitmap.width,bitmap.height)
            @trails.last.bitmap.stretch_blt(Rect.new(0,0,bitmap.width,bitmap.height),@bitmap.bitmapFile,Rect.new(index*(bitmap.width/scale),0,bitmap.width/scale,bitmap.height/scale))
            @trails.last.color = Color.new(255,255,255)
            @trails.last.coloring(Color.new(0,0,0),12)
            @trails.last.fade(0,32,:ease_out_cubic)
          end
          before = nil
          for t in @trails
            t.x = @sprite.x
            t.y = @sprite.y
            t.ox = @sprite.ox
            t.oy = @sprite.oy
            t.zoom_x = @sprite.zoom_x
            t.zoom_y = @sprite.zoom_y
            t.angle = @sprite.angle            
            t.src_rect = @sprite.src_rect
            if before != nil
              #t.z = before.z-1
            end
            before = t
            t.update
            if t.opacity <= 0
              echoln "disposing t!"
              @trailct -=1
              t.bitmap.dispose
              t.dispose
              @trails.delete(t)
            end
          end
        end
      end
      @sprite.bitmap=@bitmap.bitmap.clone
      @shadow.bitmap=@bitmap.bitmap.clone
    end
    @shadow.skew(angle)
    if !@anim && !@pulse.nil?
      @pulse += @k
      @k *= -1 if @pulse == 128 || @pulse == 8
      case @status
      when 0
        @sprite.color = Color.new(0,0,0,0)
      when 1 #PSN
        @sprite.color = Color.new(109,55,130,@pulse)
      when 2 #PAR
        @sprite.color = Color.new(204,152,44,@pulse)
      when 3 #FRZ
        @sprite.color = Color.new(56,160,193,@pulse)
      when 4 #BRN
        @sprite.color = Color.new(206,73,43,@pulse)
      end
    end
    @anim = false
    # Pokémon sprite blinking when targeted or damaged
    #echoln Graphics.frame_count%3
    #@frame += 1 if ![1,2].include?(Graphics.frame_count%3)
    if @selected==2 # When targeted or damaged
      @sprite.visible = (@frame%10<7) && !@hidden
    end
    self.formatShadow
  end  
end
#-------------------------------------------------------------------------------
#  Animated trainer sprites
#-------------------------------------------------------------------------------
class DynamicTrainerSprite  <  DynamicPokemonSprite
  
  def initialize(doublebattle,index,viewport=nil,trarray=false)
    @viewport=viewport
    @trarray=trarray
    @selected=0
    @frame=0
    
    @status=0
    @loaded=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=0
    @yposition=0
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
    @overlay=Sprite.new(@viewport)
    @lock=false
  end
  
  def totalFrames; @bitmap.animationFrames; end
  def toLastFrame 
    @bitmap.toFrame(@bitmap.totalFrames-1)
    self.update
  end
  def selected; end
    
  def setTrainerBitmap(file)
    @bitmap=AnimatedBitmapWrapper.new(file,TRAINERSPRITESCALE)
    @sprite.bitmap=@bitmap.bitmap.clone
    @shadow.bitmap=@bitmap.bitmap.clone
    @sprite.ox=@bitmap.width/2
    if @doublebattle && @trarray
      if @index==-2
        @sprite.ox-=50
      elsif @index==-1
        @sprite.ox+=50
      end
    end
    @sprite.oy=@bitmap.height-12
    
    self.formatShadow
    @shadow.skew(74)
  end

end
#-------------------------------------------------------------------------------
#  New class used to configure and animate battle backgrounds
#-------------------------------------------------------------------------------
class AnimatedBattleBackground < Sprite
	
  def setBitmap(backdrop,scene)
    blur = 4; blur = BLURBATTLEBACKGROUND if BLURBATTLEBACKGROUND.is_a?(Numeric)
    @eff = {}
    @scene = scene
    if $INEDITOR
      @defaultvector = ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1) 
    else
      @defaultvector = (@scene.battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1) )
    end
    @canAnimate = !pbResolveBitmap("Graphics/BattleBacks/Animation/eff1"+backdrop).nil?
    bg = pbBitmap("Graphics/BattleBacks/battlebg"+backdrop)
    @bmp = Bitmap.new(bg.width*BACKGROUNDSCALAR,bg.width*BACKGROUNDSCALAR)
    @bmp.stretch_blt(Rect.new(0,0,@bmp.width,@bmp.height),bg,Rect.new(0,0,bg.width,bg.height))
    self.bitmap = @bmp.clone
    self.blur_sprite(blur) if BLURBATTLEBACKGROUND
    sx, sy = @scene.vector.spoof(@defaultvector)
    self.ox = 256 + sx
    self.oy = 192 + sy
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"] = Sprite.new(self.viewport)
      bmp = pbBitmap("Graphics/BattleBacks/Animation/eff#{i}"+backdrop)
      @eff["#{i}"].bitmap = Bitmap.new(@bmp.width*2,@bmp.height)
      @eff["#{i}"].bitmap.stretch_blt(Rect.new(0,0,@bmp.width*2,@bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @eff["#{i}"].src_rect.set([0,128,0,-128][i]*BACKGROUNDSCALAR,0,bmp.width*BACKGROUNDSCALAR/2,bmp.height*BACKGROUNDSCALAR)
      @eff["#{i}"].ox = self.ox
      @eff["#{i}"].oy = self.oy
      @eff["#{i}"].blur_sprite(blur) if BLURBATTLEBACKGROUND
    end
    self.update
  end
  
  def update
    if @canAnimate
      @eff["1"].src_rect.x -= 1
      @eff["1"].src_rect.x = 512*BACKGROUNDSCALAR if @eff["1"].src_rect.x <= -256*BACKGROUNDSCALAR
      @eff["2"].src_rect.x += 1
      @eff["2"].src_rect.x = -256*BACKGROUNDSCALAR if @eff["2"].src_rect.x >= 512*BACKGROUNDSCALAR
      @eff["3"].src_rect.x -= 2
      @eff["3"].src_rect.x = 512*BACKGROUNDSCALAR if @eff["3"].src_rect.x <= -256*BACKGROUNDSCALAR
    end    
    # coordinates
    self.x = @scene.vector.x2
    self.y = @scene.vector.y2
    self.angle = ((@scene.vector.angle - @defaultvector[2])*0.5).to_i if $PokemonSystem.screensize < 2 && @scene.sendingOut
    sx, sy = @scene.vector.spoof(@defaultvector)
    self.zoom_x = ((@scene.vector.x2 - @scene.vector.x)*1.0/(sx - @defaultvector[0])*1.0)**0.6
    self.zoom_y = ((@scene.vector.y2 - @scene.vector.y)*1.0/(sy - @defaultvector[1])*1.0)**0.6
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"].x = self.x
      @eff["#{i}"].y = self.y
      @eff["#{i}"].zoom_x = self.zoom_x
      @eff["#{i}"].zoom_y = self.zoom_y
      @eff["#{i}"].visible = true
      if self.angle!=0
        @eff["#{i}"].opacity -= 51
      else
        @eff["#{i}"].opacity += 51
      end
    end
  end
  
  alias dispose_bg dispose unless self.method_defined?(:dispose_bg)
  def dispose
    pbDisposeSpriteHash(@eff)
    dispose_bg
  end
  
  alias :color_bg= :color= unless self.method_defined?(:color_bg=)
  def color=(val)
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"].color = val
    end
    self.color_bg = val
  end
end

#===============================================================================
#  New functions for the Sprite class
#  adds new bitmap transformations
#===============================================================================
class Sprite
  def skew(angle=90)
    return false if !self.bitmap
    angle=angle*(Math::PI/180)
    bitmap=self.bitmap
    rect=Rect.new(0,0,bitmap.width,bitmap.height)
    width=rect.width+((rect.height-1)/Math.tan(angle))
    self.bitmap=Bitmap.new(width,rect.height)
    for i in 0...rect.height
      y=rect.height-i
      x=i/Math.tan(angle)
      self.bitmap.blt(x+rect.x,y+rect.y,bitmap,Rect.new(0,y,rect.width,1))
    end
  end

  def blur_sprite(blur_val=2,opacity=35)
    bitmap = self.bitmap
    self.bitmap = Bitmap.new(bitmap.width,bitmap.height)
    self.bitmap.blt(0,0,bitmap,Rect.new(0,0,bitmap.width,bitmap.height))
    x=0
    y=0
    for i in 1...(8 * blur_val)
      dir = i % 8
      x += (1 + (i / 8))*([0,6,7].include?(dir) ? -1 : 1)*([1,5].include?(dir) ? 0 : 1)
      y += (1 + (i / 8))*([1,4,5,6].include?(dir) ? -1 : 1)*([3,7].include?(dir) ? 0 : 1)
      self.bitmap.blt(x-blur_val,y+(blur_val*2),bitmap,Rect.new(0,0,bitmap.width,bitmap.height),opacity)
    end
  end
  
  def getAvgColor(freq=2)
    return Color.new(0,0,0,0) if !self.bitmap
    bmp = self.bitmap
    width = self.bitmap.width/freq
    height = self.bitmap.height/freq
    red = 0
    green = 0
    blue = 0
    n = width*height
    for x in 0...width
      for y in 0...height
        color = bmp.get_pixel(x*freq,y*freq)
        if color.alpha > 0
          red += color.red
          green += color.green
          blue += color.blue
        end
      end
    end
    avg = Color.new(red/n,green/n,blue/n)
    return avg
  end
  
  def create_outline(color,thickness=2,hard=false)
    return false if !self.bitmap
    bmp = self.bitmap.clone
    self.bitmap = Bitmap.new(bmp.width,bmp.height)
    for x in 0...bmp.width-thickness
      for y in 0...bmp.height
        pixel = bmp.get_pixel(x,y)
        if pixel.alpha > 0
          for i in 1..thickness
            c1 = bmp.get_pixel(x,y-i)
            c2 = bmp.get_pixel(x,y+i)
            c3 = bmp.get_pixel(x-i,y)
            c4 = bmp.get_pixel(x+i,y)
            self.bitmap.set_pixel(x,y-i,color) if c1.alpha <= 0
            self.bitmap.set_pixel(x,y+i,color) if c2.alpha <= 0
            self.bitmap.set_pixel(x-i,y,color) if c3.alpha <= 0
            self.bitmap.set_pixel(x+i,y,color) if c4.alpha <= 0
          end
        end
      end
    end
    self.bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
  end
  
  def colorize(color)
    return false if !self.bitmap
    bmp = self.bitmap.clone
    self.bitmap = Bitmap.new(bmp.width,bmp.height)
    for x in 0...bmp.width
      for y in 0...bmp.height
        pixel = bmp.get_pixel(x,y)
        self.bitmap.set_pixel(x,y,color) if pixel.alpha > 0
      end
    end
  end
  
  def glow(color,opacity=35,keep=true)
    return false if !self.bitmap
    temp_bmp = self.bitmap.clone
    self.colorize(color)
    self.blur_sprite(3,opacity)
    src = self.bitmap.clone
    self.bitmap.clear
    self.bitmap.stretch_blt(Rect.new(-0.005*src.width,-0.015*src.height,src.width*1.01,1.02*src.height),src,Rect.new(0,0,src.width,src.height))
    self.bitmap.blt(0,0,temp_bmp,Rect.new(0,0,temp_bmp.width,temp_bmp.height)) if keep
  end
  
  def fuzz(color,opacity=35)
    return false if !self.bitmap
    self.colorize(color)
    self.blur_sprite(3,opacity)
    src = self.bitmap.clone
    self.bitmap.clear
    self.bitmap.stretch_blt(Rect.new(-0.005*src.width,-0.015*src.height,src.width*1.01,1.02*src.height),src,Rect.new(0,0,src.width,src.height))
  end
  
  def memorize_bitmap
    @storedBitmap = self.bitmap.clone
  end
  def restore_bitmap
    self.bitmap = @storedBitmap.clone
  end
  
  def snapScreen
    bmp = Graphics.snap_to_bitmap
    width = self.viewport ? viewport.rect.width : Graphics.width
    height = self.viewport ? viewport.rect.height : Graphics.height
    x = self.viewport ? viewport.rect.x : 0
    y = self.viewport ? viewport.rect.y : 0
    self.bitmap = Bitmap.new(width,height)
    self.bitmap.blt(0,0,bmp,Rect.new(x,y,width,height))    
  end
  
  def toneAll(val)
    self.tone.red += val
    self.tone.green += val
    self.tone.blue += val
  end
  
end

def setPictureSpriteEB(sprite,picture)
  sprite.visible = picture.visible
  # Set sprite coordinates
  sprite.y = picture.y
  sprite.z = picture.number
  # Set zoom rate, opacity level, and blend method
  sprite.zoom_x = picture.zoom_x / 100.0
  sprite.zoom_y = picture.zoom_y / 100.0
  sprite.opacity = picture.opacity
  sprite.blend_type = picture.blend_type
  # Set rotation angle and color tone
  angle = picture.angle
  sprite.tone = picture.tone
  sprite.color = picture.color
  while angle < 0
    angle += 360
  end
  angle %= 360
  sprite.angle=angle
end
#-------------------------------------------------------------------------------
#  Class used for generating scrolling backgrounds (move animations)
#-------------------------------------------------------------------------------
class ScrollingSprite < Sprite
  attr_accessor :speed
  attr_accessor :direction
  attr_accessor :vertical
  
  def setBitmap(val,vertical=false,pulse=false)
    @vertical = vertical
    @pulse = pulse
    @direction = 1 if @direction.nil?
    @gopac = 1
    @speed = 32 if @speed.nil?
    val = pbBitmap(val) if val.is_a?(String)
    if @vertical
      bmp = Bitmap.new(val.width,val.height*2)
      for i in 0...2
        bmp.blt(0,val.height*i,val,Rect.new(0,0,val.width,val.height))
      end
      self.bitmap = bmp.clone
      y = @direction > 0 ? 0 : val.height
      self.src_rect.set(0,y,val.width,val.height)
    else
      bmp = Bitmap.new(val.width*2,val.height)
      for i in 0...2
        bmp.blt(val.width*i,0,val,Rect.new(0,0,val.width,val.height))
      end
      self.bitmap = bmp.clone
      x = @direction > 0 ? 0 : val.width
      self.src_rect.set(x,0,val.width,val.height)
    end
  end
  
  def update
    if @vertical
      self.src_rect.y += @speed*@direction
      self.src_rect.y = 0 if @direction > 0 && self.src_rect.y >= self.src_rect.height
      self.src_rect.y = self.src_rect.height if @direction < 0 && self.src_rect.y <= 0
    else
      self.src_rect.x += @speed*@direction
      self.src_rect.x = 0 if @direction > 0 && self.src_rect.x >= self.src_rect.width
      self.src_rect.x = self.src_rect.width if @direction < 0 && self.src_rect.x <= 0
    end
    if @pulse
      self.opacity -= @gopac*@speed
      @gopac *= -1 if self.opacity == 255 || self.opacity == 0
    end
  end
    
end

class RainbowSprite < Sprite
  attr_accessor :speed
  
  def setBitmap(val,speed = 1)
    @val = val
    @val = pbBitmap(val) if val.is_a?(String)
    @speed = speed
    self.bitmap = Bitmap.new(@val.width,@val.height)
    self.bitmap.blt(0,0,@val,Rect.new(0,0,@val.width,@val.height))
    @current_hue = 0
  end
  
  def update
    self.bitmap.clear
    self.bitmap.blt(0,0,@val,Rect.new(0,0,@val.width,@val.height))
    self.bitmap.hue_change(@current_hue)
    @current_hue += @speed
    @current_hue = 0 if @current_hue >= 360
  end
  
end
#-------------------------------------------------------------------------------
#  Utilities used for move animations
#-------------------------------------------------------------------------------
class PokeBattle_Scene  
  def getCenter(sprite,zoom=false)
    zoom = zoom ? sprite.zoom_y : 1
    x = sprite.x
    y = sprite.y + (sprite.bitmap.height-sprite.oy)*zoom - sprite.bitmap.height*zoom/2
    return x, y
  end
  
  def alignSprites(sprite,target)
    sprite.ox = sprite.src_rect.width/2
    sprite.oy = sprite.src_rect.height/2
    sprite.x, sprite.y = getCenter(target)
    sprite.zoom_x, sprite.zoom_y = target.zoom_x/2, target.zoom_y/2
  end
  
  def getRealVector(targetindex,player)
    vector = (player ? PLAYERVECTOR : ENEMYVECTOR).clone
    if @battle.doublebattle && !USEBATTLEBASES
      case targetindex
      when 0
        vector[0] = vector[0] + 80
      when 1
        vector[0] = vector[0] + 192
      when 2
        vector[0] = vector[0] - 64
      when 3
        vector[0] = vector[0] - 36
      end
    end
    return vector
  end
  
  def randCircleCord(r,x=nil)
    x = rand(r*2) if x.nil?
    y1 = -Math.sqrt(r**2 - (x - r)**2)
    y2 =  Math.sqrt(r**2 - (x - r)**2)
    return x, (rand(2)==0 ? y1.to_i : y2.to_i) + r
  end
  
  def applySpriteProperties(sprite1,sprite2)
    sprite2.x = sprite1.x
    sprite2.y = sprite1.y
    sprite2.z = sprite1.z
    sprite2.zoom_x = sprite1.zoom_x
    sprite2.zoom_y = sprite1.zoom_y
    sprite2.opacity = sprite1.opacity
    sprite2.angle = sprite1.angle
    sprite2.tone = sprite1.tone
    sprite2.color = sprite1.color
    sprite2.visible = sprite1.visible
  end
end
#===============================================================================
#  Misc. scripting tools
#===============================================================================
def pbBitmap(name)
  if !pbResolveBitmap(name).nil?
    bmp = BitmapCache.load_bitmap(name)
  else
    p "Image located at '#{name}' was not found!" if $DEBUG
    bmp = Bitmap.new(1,1)
  end
  return bmp
end

def checkEBFolderPath
  if !pbResolveBitmap("Graphics/Pictures/EBS/pokeballs").nil?
    return "Graphics/Pictures/EBS"
  else
    return "Graphics/Pictures"
  end
end

def checkEBFolderPathDS
  if !pbResolveBitmap("Graphics/Pictures/EBS/DS/background").nil?
    return "Graphics/Pictures/EBS/DS"
  else
    return "Graphics/Pictures"
  end
end