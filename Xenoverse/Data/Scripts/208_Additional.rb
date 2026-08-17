# additional Sprite functionality
class Sprite
  attr_reader :storedBitmap
  attr_accessor :speed
  attr_accessor :toggle
  attr_accessor :end_x
  attr_accessor :end_y
  attr_accessor :param
  attr_accessor :ex
  attr_accessor :ey
  
  def drawRect(width,height,color)
    self.bitmap = Bitmap.new(width,height)
    self.bitmap.fill_rect(0,0,width,height,color)
  end
  
  def center(snap=false)
    self.ox = self.src_rect.width/2
    self.oy = self.src_rect.height/2
    if snap && self.viewport
      self.x = self.viewport.rect.width/2
      self.y = self.viewport.rect.height/2
    end
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
  
  def memorize_bitmap(bitmap = nil)
    @storedBitmap = bitmap if !bitmap.nil?
    @storedBitmap = self.bitmap.clone if bitmap.nil?
  end
  def restore_bitmap
    self.bitmap = @storedBitmap.clone
  end
  
  def toneAll(val)
    self.tone.red += val
    self.tone.green += val
    self.tone.blue += val
  end
  
  def onlineBitmap(url)
    pbDownloadToFile(url,"_temp.png")
    return if !FileTest.exist?("_temp.png")
    self.bitmap = pbBitmap("_temp")
    File.delete("_temp.png")
  end
end
# additional Bitmap functionality
class Bitmap
  def drawCircle(color=Color.new(255,255,255),r=(self.width/2),tx=(self.width/2),ty=(self.height/2),hollow=false)
    self.clear
    # basic circle formula
    # (x - tx)**2 + (y - ty)**2 = r**2
    for x in 0...self.width
      y1 = -Math.sqrt(r**2 - (x - tx)**2).to_i + ty
      y2 =  Math.sqrt(r**2 - (x - tx)**2).to_i + ty
      if hollow
        self.set_pixel(x,y1,color)
        self.set_pixel(x,y2,color)
      else
        for y in y1..y2
          self.set_pixel(x,y,color)
        end
      end
    end
  end
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
#-------------------------------------------------------------------------------
#  Class used to render the background for the special S&M trainer battle
#  animation
#-------------------------------------------------------------------------------
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
#  Misc scripting utilities
#-------------------------------------------------------------------------------
def pbBitmap(name)
  if !pbResolveBitmap(name).nil?
    bmp = BitmapCache.load_bitmap(name)
  else
    p "Image located at '#{name}' was not found!" if $DEBUG
    bmp = Bitmap.new(1,1)
  end
  return bmp
end
#-------------------------------------------------------------------------------
#  F12 Soft-resetting fix
#-------------------------------------------------------------------------------
if defined?(SOFTRESETFIX) && SOFTRESETFIX
unless $f12_fix.nil?
  game_name = defined?($MKXP) ? "Game_n" : "Game"
  if $DEBUG
    Thread.new{system(game_name+" debug")}
  else
    Thread.new{system(game_name)}
  end
  exit
end
$f12_fix = true
end