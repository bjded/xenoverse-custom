#===============================================================================
#  Elite Battle system
#    by Luka S.J.
# ----------------
#  EntryAnimations Script
# ----------------  
#  system is based off the original Essentials battle system, made by
#  Poccil & Maruno
#  No additional features added to AI, mechanics 
#  or functionality of the battle system.
#  This update is purely cosmetic, and includes a B/W like dynamic scene with a 
#  custom interface.
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#-------------------------------------------------------------------------------
#  Replaces the stock battle start animations for trainer (non-VS) and wild
#  battles.
#
#  If you'd like to use just the new transitions from EBS for your project,
#  you'll also need to copy over the EliteBattle_Sprites section of the scripts
#  to your project, as well as the configurations for the following constants:
#      - VIEWPORT_HEIGHT
#      - VIEWPORT_OFFSET
#
#  In order to use the New VS sequence you need the following images in your
#  Graphics/Transitions/ folder:
#      - vsTrainer#{trainer_id}
#      - vsBarNew#{trainer_id}
#
#  In order to use the Elite Four VS sequence you need the following images in your
#  Graphics/Transitions/ folder:
#      - vsTrainer#{trainer_id}
#      - vsBarElite#{trainer_id}
#
#  In order to use the Special VS sequence you need the following images in your
#  Graphics/Transitions/ folder:
#      - vsTrainerSpecial#{trainer_id}
#      - vsBarSpecial#{trainer_id}
#
#
#
#  You can add special transitions for your species by having the following
#  Graphics in your Graphics/Transitions/ folder:
#      - species#{species_id}
#      - speciesBg#{species_id} (optional)
#      - speciesEffA#{species_id} (optional)
#      - speciesEffB#{species_id} (optional)
#      - speciesEffC#{species_id} (optional)
#
#  This style is only compatible with the Next Gen UI
#===============================================================================                           
#===============================================================================
# EBS Sprites transiton section
#===============================================================================
#===============================================================================
#  New functions for the Sprite class
#  adds new bitmap transformations
#===============================================================================
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
#  New class used to render the Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonDefaultBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false,teamskull=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @speed = 1
    @sprites = {}
    # reverts to default
    bg = ["Graphics/Transitions/SunMoon/Default/background",
          "Graphics/Transitions/SunMoon/Default/layer",
          "Graphics/Transitions/SunMoon/Default/final"
         ]
    # gets specific graphics
    for i in 0...3
      str = sprintf("%s%d",bg[i],trainerid)
      evl = bg[i] + "Evil"
      skl = bg[i] + "Skull"
      fdg =  bg[i] + "fdg"
      bg[i] = evl if pbResolveBitmap(evl) && @evilteam
      bg[i] = skl if pbResolveBitmap(skl) && @teamskull
      bg[i] = fdg if pbResolveBitmap(fdg) && $wildSpecies == PBSpecies::DRAGALISKFURIA
      bg[i] = str if pbResolveBitmap(str)
    end
    # creates the 3 background layers
    for i in 0...3
      @sprites["bg#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["bg#{i}"].setBitmap(bg[i],false,(i > 0))
      @sprites["bg#{i}"].z = 200
      @sprites["bg#{i}"].ox = @sprites["bg#{i}"].src_rect.width/2
      @sprites["bg#{i}"].oy = @sprites["bg#{i}"].src_rect.height/2
      @sprites["bg#{i}"].x = viewport.rect.width/2
      @sprites["bg#{i}"].y = viewport.rect.height/2
      @sprites["bg#{i}"].angle = - 8 if $PokemonSystem.screensize < 2
      @sprites["bg#{i}"].color = Color.new(0,0,0)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    for i in 0...3
      @sprites["bg#{i}"].speed = val*(i + 1)
    end
  end
  # updates the background
  def update
    return if self.disposed?
    for i in 0...3
      @sprites["bg#{i}"].update
    end
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for i in 0...3
      @sprites["bg#{i}"].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show; end
end
#-------------------------------------------------------------------------------
#  New class used to render the special Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonSpecialBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # creates the background
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap("Graphics/Transitions/SunMoon/Special/background")
    @sprites["background"].color = Color.new(0,0,0)
    @sprites["background"].z = 200
    # handles the particles for the animation
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
    # loads ring effect
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Special/ring")
    @sprites["ring"].ox = @sprites["ring"].bitmap.width/2
    @sprites["ring"].oy = @sprites["ring"].bitmap.height/2
    @sprites["ring"].x = @viewport.rect.width/2
    @sprites["ring"].y = @viewport.rect.height
    @sprites["ring"].zoom_x = 0
    @sprites["ring"].zoom_y = 0
    @sprites["ring"].z = 500
    @sprites["ring"].visible = false
    @sprites["ring"].color = Color.new(0,0,0)
    # loads sparkle particles
    for j in 0...32
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Special/particle")
      @sprites["s#{j}"].ox = @sprites["s#{j}"].bitmap.width/2
      @sprites["s#{j}"].oy = @sprites["s#{j}"].bitmap.height/2
      @sprites["s#{j}"].opacity = 0
      @sprites["s#{j}"].z = 220
      @sprites["s#{j}"].color = Color.new(0,0,0)
      @fpDx.push(0)
      @fpDy.push(0)
    end
    @fpSpeed = []
    @fpOpac = []
    # loads scrolling particles
    for j in 0...3
      k = j+1
      speed = 2 + rand(5)
      @sprites["p#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["p#{j}"].setBitmap("Graphics/Transitions/SunMoon/Special/glow#{j}")
      @sprites["p#{j}"].speed = speed*4
      @sprites["p#{j}"].direction = -1
      @sprites["p#{j}"].opacity = 0
      @sprites["p#{j}"].z = 220
      @sprites["p#{j}"].zoom_y = 1 + rand(10)*0.005
      @sprites["p#{j}"].color = Color.new(0,0,0)
      @fpSpeed.push(speed)
      @fpOpac.push(4) if j > 0
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    val = 16 if val > 16
    for j in 0...3
      @sprites["p#{j}"].speed = val*2
    end
  end
  # updates the background
  def update
    return if self.disposed?
    # updates background
    @sprites["background"].update
    # updates ring
    if @sprites["ring"].visible && @sprites["ring"].opacity > 0
      @sprites["ring"].zoom_x += 0.2
      @sprites["ring"].zoom_y += 0.2
      @sprites["ring"].opacity -= 16
    end
    # updates sparkle particles
    for j in 0...32
      next if !@sprites["ring"].visible
      next if !@sprites["s#{j}"] || @sprites["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @sprites["s#{j}"].opacity <= 1
        width = @viewport.rect.width
        height = @viewport.rect.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @sprites["s#{j}"].zoom_x = z
        @sprites["s#{j}"].zoom_y = z
        @sprites["s#{j}"].x = x
        @sprites["s#{j}"].y = y
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].angle = rand(360)
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @fpDx[j])*0.05
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @fpDy[j])*0.05
      @sprites["s#{j}"].opacity -= @sprites["s#{j}"].opacity*0.05
      @sprites["s#{j}"].zoom_x -= @sprites["s#{j}"].zoom_x*0.05
      @sprites["s#{j}"].zoom_y -= @sprites["s#{j}"].zoom_y*0.05
    end
    # updates scrolling particles
    for j in 0...3
      next if !@sprites["p#{j}"] || @sprites["p#{j}"].disposed?
      @sprites["p#{j}"].update
      if j == 0
        @sprites["p#{j}"].opacity += 5 if @sprites["p#{j}"].opacity < 155
      else
        @sprites["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@sprites["p#{j}"].opacity >= 255 || @sprites["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 150
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for j in 0...3
      @sprites["p#{j}"].visible = true
    end
    @sprites["ring"].visible = true
    @fpIndex = 0
  end
end
#-------------------------------------------------------------------------------
#  New class used to render the Sun & Moon kahuna VS background
#-------------------------------------------------------------------------------
class SunMoonEliteBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @fpIndex = 0
    # checks for appropriate files
    bg = ["Graphics/Transitions/SunMoon/Elite/background",
          "Graphics/Transitions/SunMoon/Elite/vacuum"
         ]
    for i in 0...2
      str = sprintf("%s%d",bg[i],trainerid)
      bg[i] = str if pbResolveBitmap(str)
    end
    # creates the background
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap(bg[0])
    @sprites["background"].center
    @sprites["background"].x = @viewport.rect.width/2
    @sprites["background"].y = @viewport.rect.height/2
    @sprites["background"].color = Color.new(0,0,0)
    @sprites["background"].z = 200
    # creates particles flying out of the center
    for j in 0...16
      @sprites["e#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/Transitions/SunMoon/Elite/particle")
      @sprites["e#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      w = bmp.width/(1 + rand(3))
      @sprites["e#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["e#{j}"].oy = @sprites["e#{j}"].bitmap.height/2
      @sprites["e#{j}"].angle = rand(360)
      @sprites["e#{j}"].opacity = 0
      @sprites["e#{j}"].x = @viewport.rect.width/2
      @sprites["e#{j}"].y = @viewport.rect.height/2
      @sprites["e#{j}"].speed = (4 + rand(5))
      @sprites["e#{j}"].z = 220
      @sprites["e#{j}"].color = Color.new(0,0,0)
    end
    # creates vacuum waves
    for j in 0...3
      @sprites["ec#{j}"] = Sprite.new(@viewport)
      @sprites["ec#{j}"].bitmap = pbBitmap(bg[1])
      @sprites["ec#{j}"].ox = @sprites["ec#{j}"].bitmap.width/2
      @sprites["ec#{j}"].oy = @sprites["ec#{j}"].bitmap.height/2
      @sprites["ec#{j}"].x = @viewport.rect.width/2
      @sprites["ec#{j}"].y = @viewport.rect.height/2
      @sprites["ec#{j}"].zoom_x = 1.5
      @sprites["ec#{j}"].zoom_y = 1.5
      @sprites["ec#{j}"].opacity = 0
      @sprites["ec#{j}"].z = 205
      @sprites["ec#{j}"].color = Color.new(0,0,0)
    end
    # creates center glow
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Elite/shine")
    @sprites["shine"].ox = @sprites["shine"].src_rect.width/2
    @sprites["shine"].oy = @sprites["shine"].src_rect.height/2
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @viewport.rect.height/2
    @sprites["shine"].z = 210
    @sprites["shine"].visible = false
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # background and shine
    @sprites["background"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
    # updates (and resets) the particles flying from the center
    for j in 0...16
      next if !@sprites["shine"].visible
      if @sprites["e#{j}"].ox < -(@sprites["e#{j}"].viewport.rect.width/2)
        @sprites["e#{j}"].speed = 4 + rand(5)
        @sprites["e#{j}"].opacity = 0
        @sprites["e#{j}"].ox = 0
        @sprites["e#{j}"].angle = rand(360)
        bmp = pbBitmap("Graphics/Transitions/SunMoon/Elite/particle")
        @sprites["e#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        @sprites["e#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      @sprites["e#{j}"].opacity += @sprites["e#{j}"].speed
      @sprites["e#{j}"].ox -=  @sprites["e#{j}"].speed
    end
    # updates the vacuum waves
    for j in 0...3
      next if j > @fpIndex/50
      if @sprites["ec#{j}"].zoom_x <= 0
        @sprites["ec#{j}"].zoom_x = 1.5
        @sprites["ec#{j}"].zoom_y = 1.5
        @sprites["ec#{j}"].opacity = 0
      end
      @sprites["ec#{j}"].opacity +=  8
      @sprites["ec#{j}"].zoom_x -= 0.01
      @sprites["ec#{j}"].zoom_y -= 0.01
    end
    @fpIndex += 1 if @fpIndex < 150
  end
  # used to show other elements
  def show
    @sprites["shine"].visible = true
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  
end
#-------------------------------------------------------------------------------
#  New class used to render the Mother Beast Lusamine styled VS background
#-------------------------------------------------------------------------------
class SunMoonCrazyBackground
  attr_accessor :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # draws a black backdrop
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].drawRect(@viewport.rect.width,@viewport.rect.height,Color.new(0,0,0))
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.new(0,0,0)
    # draws the 3 circular patterns that change hue
    for j in 0...3
      @sprites["b#{j}"] = RainbowSprite.new(@viewport)
      @sprites["b#{j}"].setBitmap("Graphics/Transitions/SunMoon/Crazy/ring#{j}",8)
      @sprites["b#{j}"].ox = @sprites["b#{j}"].bitmap.width/2
      @sprites["b#{j}"].oy = @sprites["b#{j}"].bitmap.height/2
      @sprites["b#{j}"].x = @viewport.rect.width/2
      @sprites["b#{j}"].y = @viewport.rect.height/2
      @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
      @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
      @sprites["b#{j}"].opacity = 64 + 64*(1+j)
      @sprites["b#{j}"].z = 250
      @sprites["b#{j}"].color = Color.new(0,0,0)
    end
    # draws all the particles
    for j in 0...64
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].z = 300
      width = 16 + rand(48)
      height = 16 + rand(16)
      @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
      bmp = pbBitmap("Graphics/Transitions/SunMoon/Crazy/particle")
      @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["p#{j}"].bitmap.hue_change(rand(360))
      @sprites["p#{j}"].ox = width/2
      @sprites["p#{j}"].oy = height + 192 + rand(32)
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].speed = 1 + rand(4)
      @sprites["p#{j}"].x = @viewport.rect.width/2
      @sprites["p#{j}"].y = @viewport.rect.height/2
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].color = Color.new(0,0,0)
    end
    @frame = 0
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # updates the 3 circular patterns changing their hue
    for j in 0...3
      @sprites["b#{j}"].zoom_x -= 0.025
      @sprites["b#{j}"].zoom_y -= 0.025
      @sprites["b#{j}"].opacity -= 4
      if @sprites["b#{j}"].zoom_x <= 0 || @sprites["b#{j}"].opacity <= 0
        @sprites["b#{j}"].zoom_x = 2.25
        @sprites["b#{j}"].zoom_y = 2.25
        @sprites["b#{j}"].opacity = 255
      end
      @sprites["b#{j}"].update if @frame%8==0
    end
    # animates all the particles
    for j in 0...64
      @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + 192 + rand(32)
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].speed = 1 + rand(4)
      end
    end
    @frame += 1
    @frame = 0 if @frame > 128
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show; end
  
end
#-------------------------------------------------------------------------------
#  New class used to render the ultra squad Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonUltraBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap("Graphics/Transitions/SunMoon/Ultra/background",2)
    @sprites["background"].color = Color.new(0,0,0)
    @sprites["background"].z = 200
    @sprites["paths"] = RainbowSprite.new(@viewport)
    @sprites["paths"].setBitmap("Graphics/Transitions/SunMoon/Ultra/overlay",2)
    @sprites["paths"].center
    @sprites["paths"].x = @viewport.rect.width/2
    @sprites["paths"].y = @viewport.rect.height/2
    @sprites["paths"].color = Color.new(0,0,0)
    @sprites["paths"].z = 200
    @sprites["paths"].opacity = 215
    @sprites["paths"].toggle = 1
    @sprites["paths"].visible = false
    # creates the shine effect
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Ultra/shine")
    @sprites["shine"].center
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @viewport.rect.height/2
    @sprites["shine"].color = Color.new(0,0,0)
    @sprites["shine"].z = 200
    # creates the hexagonal zoom patterns
    for i in 0...12
      @sprites["h#{i}"] = Sprite.new(@viewport)
      @sprites["h#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Ultra/ring")
      @sprites["h#{i}"].center
      @sprites["h#{i}"].x = @viewport.rect.width/2
      @sprites["h#{i}"].y = @viewport.rect.height/2
      @sprites["h#{i}"].color = Color.new(0,0,0)
      @sprites["h#{i}"].z = 220
      z = 1
      @sprites["h#{i}"].zoom_x = z
      @sprites["h#{i}"].zoom_y = z
      @sprites["h#{i}"].opacity = 255
    end
    for i in 0...16
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Ultra/particle")
      @sprites["p#{i}"].oy = @sprites["p#{i}"].bitmap.height/2
      @sprites["p#{i}"].x = @viewport.rect.width/2
      @sprites["p#{i}"].y = @viewport.rect.height/2
      @sprites["p#{i}"].angle = rand(360)
      @sprites["p#{i}"].color = Color.new(0,0,0)
      @sprites["p#{i}"].z = 210
      @sprites["p#{i}"].visible = false
    end
    160.times do
      self.update(true)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    if !skip
      @sprites["background"].update
      @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
      @sprites["paths"].update
      @sprites["paths"].opacity -= @sprites["paths"].toggle*2
      @sprites["paths"].toggle *= -1 if @sprites["paths"].opacity <= 85 || @sprites["paths"].opacity >= 215
    end
    for i in 0...12
      next if i > @fpIndex/32
      if @sprites["h#{i}"].opacity <= 0
        @sprites["h#{i}"].zoom_x = 1
        @sprites["h#{i}"].zoom_y = 1
        @sprites["h#{i}"].opacity = 255
      end
      @sprites["h#{i}"].zoom_x += 0.003*(@sprites["h#{i}"].zoom_x**2)
      @sprites["h#{i}"].zoom_y += 0.003*(@sprites["h#{i}"].zoom_y**2)
      @sprites["h#{i}"].opacity -= 1
    end
    for i in 0...16
      next if i > @fpIndex/8
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].ox = 0
        @sprites["p#{i}"].angle = rand(360)
        @sprites["p#{i}"].zoom_x = 1
        @sprites["p#{i}"].zoom_y = 1
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 2
      @sprites["p#{i}"].ox -= 4
      @sprites["p#{i}"].zoom_x += 0.001
      @sprites["p#{i}"].zoom_y += 0.001
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...16
      @sprites["p#{i}"].visible = true
    end
    @sprites["paths"].visible = true
  end
end
#-------------------------------------------------------------------------------
#  New class used to render a custom Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonDigitalBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/Transitions/SunMoon/Digital/background",
             "Graphics/Transitions/SunMoon/Digital/particle",
             "Graphics/Transitions/SunMoon/Digital/shine"
    ]
    for i in 0...files.length
      str = sprintf("%s%d",files[i],trainerid)
      files[i] = str if pbResolveBitmap(str)
    end
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.new(0,0,0)
    for i in 0...16
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[1])
      @sprites["p#{i}"].z = 205
      @sprites["p#{i}"].color = Color.new(0,0,0)
      @sprites["p#{i}"].oy = @sprites["p#{i}"].bitmap.height/2
      @sprites["p#{i}"].x = @viewport.rect.width/2
      @sprites["p#{i}"].y = @viewport.rect.height/2
      @sprites["p#{i}"].angle = rand(16)*22.5
      @sprites["p#{i}"].visible = false
    end
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[2])
    @sprites["shine"].center
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @viewport.rect.height/2
    @sprites["shine"].color = Color.new(0,0,0)
    @sprites["shine"].z = 210
    @sprites["shine"].toggle = 1
    # draws all the little tiles
    tile_size = 32.0
    opacity = 25
    offset = 2
    @x = (@viewport.rect.width/tile_size).ceil
    @y = (@viewport.rect.height/tile_size).ceil
    for i in 0...@x
      for j in 0...@y
        sprite = Sprite.new(@viewport)
        sprite.bitmap = Bitmap.new(tile_size,tile_size)
        sprite.bitmap.fill_rect(offset,offset,tile_size-offset*2,tile_size-offset*2,Color.new(255,255,255,opacity))
        sprite.x = i * tile_size
        sprite.y = j * tile_size
        sprite.color = Color.new(0,0,0)
        sprite.visible = false
        sprite.z = 220
        o = opacity + rand(156)
        sprite.opacity = 0
        @tiles.push(sprite)
        @data.push([o,rand(5)+4])
      end
    end
  end
  # sets the speed of the sprites
  def speed=(val)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    for i in 0...@tiles.length
      @tiles[i].opacity += @data[i][1]
      @data[i][1] *= -1 if @tiles[i].opacity <= 0 || @tiles[i].opacity >= @data[i][0]
    end
    for i in 0...16
      next if i > @fpIndex/16
      if @sprites["p#{i}"].ox < - @viewport.rect.width/2
        @sprites["p#{i}"].angle = rand(16)*22.5
        @sprites["p#{i}"].ox = 0
        @sprites["p#{i}"].opacity = 255
        @sprites["p#{i}"].zoom_x = 1
        @sprites["p#{i}"].zoom_y = 1
      end
      @sprites["p#{i}"].zoom_x += 0.001
      @sprites["p#{i}"].zoom_y += 0.001
      @sprites["p#{i}"].opacity -= 4
      @sprites["p#{i}"].ox -= 4
    end
    @sprites["shine"].zoom_x += 0.04*@sprites["shine"].toggle
    @sprites["shine"].zoom_y += 0.04*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 1 || @sprites["shine"].zoom_x >= 1.4
    @fpIndex += 1 if @fpIndex < 256
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for tile in @tiles
      tile.color.alpha -= factor
    end
    for key in @sprites.keys
      next if key == "bg"
      @sprites[key].color.alpha -= factor
    end
    self.update
  end
  # disposes of everything
  def dispose
    @disposed = true
    for tile in @tiles
      tile.dispose
    end
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...16
      @sprites["p#{i}"].visible = true
    end
    for tile in @tiles
      tile.visible = true
    end
    @sprites["bg"].color.alpha = 0
  end
end
#-------------------------------------------------------------------------------
#  New class used to render a custom Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonPlasmaBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/Transitions/SunMoon/Plasma/background",
             "Graphics/Transitions/SunMoon/Plasma/beam",
             "Graphics/Transitions/SunMoon/Plasma/streaks",
             "Graphics/Transitions/SunMoon/Plasma/shine",
             "Graphics/Transitions/SunMoon/Plasma/particle"
    ]
    for i in 0...files.length
      str = sprintf("%s%d",files[i],trainerid)
      files[i] = str if pbResolveBitmap(str)
    end
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.new(0,0,0)
    # creates plasma beam
    for i in 0...2
      @sprites["beam#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["beam#{i}"].setBitmap(files[i+1])
      @sprites["beam#{i}"].speed = [32,48][i]
      @sprites["beam#{i}"].center
      @sprites["beam#{i}"].x = @viewport.rect.width/2
      @sprites["beam#{i}"].y = @viewport.rect.height/2 - 16
      @sprites["beam#{i}"].zoom_y = 0
      @sprites["beam#{i}"].z = 210
      @sprites["beam#{i}"].color = Color.new(0,0,0)
    end
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[3])
    @sprites["shine"].center
    @sprites["shine"].x = @viewport.rect.width
    @sprites["shine"].y = @viewport.rect.height/2 - 16
    @sprites["shine"].z = 220
    @sprites["shine"].visible = false
    @sprites["shine"].toggle = 1
    for i in 0...32
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[4])
      @sprites["p#{i}"].center
      @sprites["p#{i}"].opacity = 0
      @sprites["p#{i}"].z = 215
      @sprites["p#{i}"].visible = false
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    @speed = val
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["shine"].angle += 8 if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].zoom_y -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.8 || @sprites["shine"].zoom_x >= 1.2
    for i in 0...2
      @sprites["beam#{i}"].update
    end
    for i in 0...32
      next if i > @fpIndex/4
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].x = @sprites["shine"].x
        @sprites["p#{i}"].y = @sprites["shine"].y
        r = 256 + rand(129)
        cx, cy = randCircleCord(r)
        @sprites["p#{i}"].ex = @sprites["shine"].x - (cx - r).abs
        @sprites["p#{i}"].ey = @sprites["shine"].y - r/2 + cy/2
        z = 0.4 + rand(7)/10.0
        @sprites["p#{i}"].zoom_x = z
        @sprites["p#{i}"].zoom_y = z
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 8
      @sprites["p#{i}"].x -= (@sprites["p#{i}"].x - @sprites["p#{i}"].ex)*0.1
      @sprites["p#{i}"].y -= (@sprites["p#{i}"].y - @sprites["p#{i}"].ey)*0.1
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      next if key == "bg"
      @sprites[key].color.alpha -= factor
    end
    for i in 0...2
      @sprites["beam#{i}"].zoom_y += 0.1 if @sprites["beam#{i}"].color.alpha <= 164 && @sprites["beam#{i}"].zoom_y < 1
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    for key in @sprites.keys
      @sprites[key].visible = true
    end
  end
end
#-------------------------------------------------------------------------------
#  New class used to render a custom Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonCardinalBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/Transitions/SunMoon/Cardinal/background",
             "Graphics/Transitions/SunMoon/Cardinal/beam",
             "Graphics/Transitions/SunMoon/Cardinal/streaks",
             "Graphics/Transitions/SunMoon/Cardinal/shine",
             "Graphics/Transitions/SunMoon/Cardinal/particle",
             "Graphics/Transitions/SunMoon/Cardinal/Cardinal",
    ]
    for i in 0...files.length
      str = sprintf("%s%d",files[i],trainerid)
      files[i] = str if pbResolveBitmap(str)
    end
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.new(0,0,0)
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap(files[5])
    @sprites["logo"].z = 400
    @sprites["logo"].y = Graphics.height/2 - @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = 50
    @sprites["logo"].visible=false
    # creates plasma beam
    for i in 0...2
      @sprites["beam#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["beam#{i}"].setBitmap(files[i+1])
      @sprites["beam#{i}"].speed = [32,48][i]
      @sprites["beam#{i}"].center
      @sprites["beam#{i}"].x = @viewport.rect.width/2
      @sprites["beam#{i}"].y = @viewport.rect.height/2 - 16
      @sprites["beam#{i}"].zoom_y = 0
      @sprites["beam#{i}"].z = 210
      @sprites["beam#{i}"].color = Color.new(0,0,0)
    end
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[3])
    @sprites["shine"].center
    @sprites["shine"].x = @viewport.rect.width
    @sprites["shine"].y = @viewport.rect.height/2 - 16
    @sprites["shine"].z = 220
    @sprites["shine"].visible = false
    @sprites["shine"].toggle = 1
    for i in 0...32
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[4])
      @sprites["p#{i}"].center
      @sprites["p#{i}"].opacity = 0
      @sprites["p#{i}"].z = 215
      @sprites["p#{i}"].visible = false
    end
    
  end
  # sets the speed of the sprites
  def speed=(val)
    @speed = val
  end
  # updates the background
  def update(skip=false)
    
    return if self.disposed?
    @sprites["shine"].angle += 8 if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].zoom_y -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.8 || @sprites["shine"].zoom_x >= 1.2
    for i in 0...2
      @sprites["beam#{i}"].update
    end
    for i in 0...32
      next if i > @fpIndex/4
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].x = @sprites["shine"].x
        @sprites["p#{i}"].y = @sprites["shine"].y
        r = 256 + rand(129)
        cx, cy = randCircleCord(r)
        @sprites["p#{i}"].ex = @sprites["shine"].x - (cx - r).abs
        @sprites["p#{i}"].ey = @sprites["shine"].y - r/2 + cy/2
        z = 0.4 + rand(7)/10.0
        @sprites["p#{i}"].zoom_x = z
        @sprites["p#{i}"].zoom_y = z
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 8
      @sprites["p#{i}"].x -= (@sprites["p#{i}"].x - @sprites["p#{i}"].ex)*0.1
      @sprites["p#{i}"].y -= (@sprites["p#{i}"].y - @sprites["p#{i}"].ey)*0.1
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    
    for key in @sprites.keys
      next if key == "bg" || key == "logo"
      @sprites[key].color.alpha -= factor
    end
    for i in 0...2
      @sprites["beam#{i}"].zoom_y += 0.1 if @sprites["beam#{i}"].color.alpha <= 164 && @sprites["beam#{i}"].zoom_y < 1
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
    
  def displayLogo
    @sprites["logo"].visible = true
  end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    for key in @sprites.keys
      next if key == "logo"
      @sprites[key].visible = true
    end
  end
end
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class SunMoonFuryBackground
  attr_accessor :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # draws a black backdrop
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].drawRect(@viewport.rect.width,@viewport.rect.height,Color.new(0,0,0))
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.new(0,0,0)
    # draws the 3 circular patterns that change hue
    for j in 0...3
      @sprites["b#{j}"] = RainbowSprite.new(@viewport)
      @sprites["b#{j}"].setBitmap("Graphics/Transitions/SunMoon/Fury/ring#{j}",8)
      @sprites["b#{j}"].ox = @sprites["b#{j}"].bitmap.width/2
      @sprites["b#{j}"].oy = @sprites["b#{j}"].bitmap.height/2
      @sprites["b#{j}"].x = @viewport.rect.width/2
      @sprites["b#{j}"].y = @viewport.rect.height/2
      @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
      @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
      @sprites["b#{j}"].opacity = 64 + 64*(1+j)
      @sprites["b#{j}"].z = 250
      @sprites["b#{j}"].color = Color.new(0,0,0)
    end
    # draws all the particles
    for j in 0...64
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].z = 300
      width = 16 + rand(48)
      height = 16 + rand(16)
      @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
      bmp = pbBitmap("Graphics/Transitions/SunMoon/Fury/particle")
      @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      #@sprites["p#{j}"].bitmap.hue_change(rand(360))
      @sprites["p#{j}"].ox = width/2
      @sprites["p#{j}"].oy = height + 192 + rand(32)
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].speed = 1 + rand(4)
      @sprites["p#{j}"].x = @viewport.rect.width/2
      @sprites["p#{j}"].y = @viewport.rect.height/2
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      #@sprites["p#{j}"].color = Color.new(0,0,0)
    end
    @frame = 0
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # updates the 3 circular patterns changing their hue
    for j in 0...3
      @sprites["b#{j}"].zoom_x -= 0.025
      @sprites["b#{j}"].zoom_y -= 0.025
      @sprites["b#{j}"].opacity -= 4
      if @sprites["b#{j}"].zoom_x <= 0 || @sprites["b#{j}"].opacity <= 0
        @sprites["b#{j}"].zoom_x = 2.25
        @sprites["b#{j}"].zoom_y = 2.25
        @sprites["b#{j}"].opacity = 255
      end
      #@sprites["b#{j}"].update if @frame%8==0
    end
    # animates all the particles
    for j in 0...64
      @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + 192 + rand(32)
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].speed = 1 + rand(4)
      end
    end
    @frame += 1
    @frame = 0 if @frame > 128
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show; end
  
end
#-------------------------------------------------------------------------------
#  VIP Transition
#-------------------------------------------------------------------------------
class SunMoonVipBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # creates the background
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap("Graphics/Transitions/SunMoon/Vip/background")
    @sprites["background"].color = Color.new(0,0,0)
    @sprites["background"].z = 200

    @sprites["logo"] = RainbowSprite.new(@viewport)
    @sprites["logo"].setBitmap("Graphics/Transitions/SunMoon/Vip/logoTournament")
    #@sprites["logo"].color = Color.new(0,0,0)
    @sprites["logo"].z = 200

    # handles the particles for the animation
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
    # loads ring effect
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Vip/ring")
    @sprites["ring"].ox = @sprites["ring"].bitmap.width/2
    @sprites["ring"].oy = @sprites["ring"].bitmap.height/2
    @sprites["ring"].x = @viewport.rect.width/2
    @sprites["ring"].y = @viewport.rect.height
    @sprites["ring"].zoom_x = 0
    @sprites["ring"].zoom_y = 0
    @sprites["ring"].z = 500
    @sprites["ring"].visible = false
    @sprites["ring"].color = Color.new(0,0,0)
    # loads sparkle particles
    for j in 0...32
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Vip/particle")
      @sprites["s#{j}"].ox = @sprites["s#{j}"].bitmap.width/2
      @sprites["s#{j}"].oy = @sprites["s#{j}"].bitmap.height/2
      @sprites["s#{j}"].opacity = 0
      @sprites["s#{j}"].z = 220
      @sprites["s#{j}"].color = Color.new(0,0,0)
      @fpDx.push(0)
      @fpDy.push(0)
    end
    @fpSpeed = []
    @fpOpac = []
    # loads scrolling particles
    for j in 0...3
      k = j+1
      speed = 2 + rand(5)
      @sprites["p#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["p#{j}"].setBitmap("Graphics/Transitions/SunMoon/Vip/newglow#{j}")
      @sprites["p#{j}"].speed = speed*4
      @sprites["p#{j}"].direction = j%2==0 ? 1 : -1
      @sprites["p#{j}"].opacity = 0
      @sprites["p#{j}"].z = 220
      @sprites["p#{j}"].zoom_y = 1 + rand(10)*0.005
      @sprites["p#{j}"].color = Color.new(0,0,0)
      @fpSpeed.push(speed)
      @fpOpac.push(4) if j > 0
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    val = 16 if val > 16
    for j in 0...3
      @sprites["p#{j}"].speed = val*2
    end
  end
  # updates the background
  def update
    return if self.disposed?
    # updates background
    #@sprites["background"].update
    # updates ring
    if @sprites["ring"].visible && @sprites["ring"].opacity > 0
      @sprites["ring"].zoom_x += 0.2
      @sprites["ring"].zoom_y += 0.2
      @sprites["ring"].opacity -= 16
    end
    # updates sparkle particles
    for j in 0...32
      next if !@sprites["ring"].visible
      next if !@sprites["s#{j}"] || @sprites["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @sprites["s#{j}"].opacity <= 1
        width = @viewport.rect.width
        height = @viewport.rect.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @sprites["s#{j}"].zoom_x = z
        @sprites["s#{j}"].zoom_y = z
        @sprites["s#{j}"].x = x
        @sprites["s#{j}"].y = y
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].angle = rand(360)
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @fpDx[j])*0.05
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @fpDy[j])*0.05
      @sprites["s#{j}"].opacity -= @sprites["s#{j}"].opacity*0.05
      @sprites["s#{j}"].zoom_x -= @sprites["s#{j}"].zoom_x*0.05
      @sprites["s#{j}"].zoom_y -= @sprites["s#{j}"].zoom_y*0.05
    end
    # updates scrolling particles
    for j in 0...3
      next if !@sprites["p#{j}"] || @sprites["p#{j}"].disposed?
      @sprites["p#{j}"].update
      if j == 0
        @sprites["p#{j}"].opacity += 5 if @sprites["p#{j}"].opacity < 155
      else
        @sprites["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@sprites["p#{j}"].opacity >= 255 || @sprites["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 150
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for j in 0...3
      @sprites["p#{j}"].visible = true
    end
    @sprites["ring"].visible = true
    @fpIndex = 0
  end
end
#-------------------------------------------------------------------------------
#  New class used to render the ultra squad Sun & Moon styled VS background
#-------------------------------------------------------------------------------
class SunMoonOnlineBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap("Graphics/Transitions/SunMoon/Online/background",2)
    @sprites["background"].color = Color.new(0,0,0)
    @sprites["background"].z = 200
    @sprites["paths"] = RainbowSprite.new(@viewport)
    @sprites["paths"].setBitmap("Graphics/Transitions/SunMoon/Online/overlay",2)
    @sprites["paths"].center
    @sprites["paths"].x = @viewport.rect.width/2
    @sprites["paths"].y = @viewport.rect.height/2
    @sprites["paths"].color = Color.new(0,0,0)
    @sprites["paths"].z = 200
    @sprites["paths"].opacity = 215
    @sprites["paths"].toggle = 1
    @sprites["paths"].visible = false
    # creates the shine effect
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Online/shine")
    @sprites["shine"].center
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @viewport.rect.height/2
    @sprites["shine"].color = Color.new(0,0,0)
    @sprites["shine"].z = 200
    # creates the hexagonal zoom patterns
    for i in 0...12
      @sprites["h#{i}"] = Sprite.new(@viewport)
      @sprites["h#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Ultra/ring")
      @sprites["h#{i}"].center
      @sprites["h#{i}"].x = @viewport.rect.width/2
      @sprites["h#{i}"].y = @viewport.rect.height/2
      @sprites["h#{i}"].color = Color.new(0,0,0)
      @sprites["h#{i}"].z = 220
      z = 1
      @sprites["h#{i}"].zoom_x = z
      @sprites["h#{i}"].zoom_y = z
      @sprites["h#{i}"].opacity = 255
    end
    for i in 0...16
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Ultra/particle")
      @sprites["p#{i}"].oy = @sprites["p#{i}"].bitmap.height/2
      @sprites["p#{i}"].x = @viewport.rect.width/2
      @sprites["p#{i}"].y = @viewport.rect.height/2
      @sprites["p#{i}"].angle = rand(360)
      @sprites["p#{i}"].color = Color.new(0,0,0)
      @sprites["p#{i}"].z = 210
      @sprites["p#{i}"].visible = false
    end
    160.times do
      self.update(true)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    if !skip
      @sprites["background"].update
      @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
      @sprites["paths"].update
      @sprites["paths"].opacity -= @sprites["paths"].toggle*2
      @sprites["paths"].toggle *= -1 if @sprites["paths"].opacity <= 85 || @sprites["paths"].opacity >= 215
    end
    for i in 0...12
      next if i > @fpIndex/32
      if @sprites["h#{i}"].opacity <= 0
        @sprites["h#{i}"].zoom_x = 1
        @sprites["h#{i}"].zoom_y = 1
        @sprites["h#{i}"].opacity = 255
      end
      @sprites["h#{i}"].zoom_x += 0.003*(@sprites["h#{i}"].zoom_x**2)
      @sprites["h#{i}"].zoom_y += 0.003*(@sprites["h#{i}"].zoom_y**2)
      @sprites["h#{i}"].opacity -= 1
    end
    for i in 0...16
      next if i > @fpIndex/8
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].ox = 0
        @sprites["p#{i}"].angle = rand(360)
        @sprites["p#{i}"].zoom_x = 1
        @sprites["p#{i}"].zoom_y = 1
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 2
      @sprites["p#{i}"].ox -= 4
      @sprites["p#{i}"].zoom_x += 0.001
      @sprites["p#{i}"].zoom_y += 0.001
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...16
      @sprites["p#{i}"].visible = true
    end
    @sprites["paths"].visible = true
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
# EBS transition section
#===============================================================================

alias pbBattleAnimation_ebs pbBattleAnimation unless defined?(pbBattleAnimation_ebs)
def pbBattleAnimation(bgm=nil,trainerid=-1,trainername="",skip = false)
  if false
    foe = trainername
    trainerid = (foe[0][0].trainertype rescue -1)
    trainername = (foe[0][0].name rescue "")
  end
  $smAnim = false
  handled = false
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  $specialSpecies = false
  pbMEFade(0.25)
  pbWait(10)
  pbMEStop
  for value in BATTLE_BGM_SPECIES
    if value[0].is_a?(Array)
      for species in value[0]
        num = species if species.is_a?(Numeric)
        num = getConst(PBSpecies,species) if species.is_a?(Symbol)
        bgm = value[1] if !num.nil? && trainerid < 0 && num == $wildSpecies
      end
    else
      num = value[0] if value[0].is_a?(Numeric)
      num = getConst(PBSpecies,value[0]) if value[0].is_a?(Symbol)
      bgm = value[1] if !num.nil? && trainerid < 0 && num == $wildSpecies
    end
  end
  if bgm
    if $MKXP && playingBGM != nil
      if bgm.is_a?(String)
        pbBGMPlay(bgm,80)
      else
        echoln "INTO #{bgm.name.gsub(/.mp3|.mid|.wav/,"")} from #{playingBGM.name.gsub(/.mp3|.mid|.wav/,"")}" if !bgm.is_a?(String)
        if bgm.name.gsub(/.mp3|.mid|.wav/,"") != playingBGM.name.gsub(/.mp3|.mid|.wav/,"")
          pbBGMPlay(bgm,80)
        end
      end
    else
      pbBGMPlay(bgm,80)
    end
  else
    pbBGMPlay(pbGetWildBattleBGM(0),80)
  end
  e_team = false
  for val in EVIL_TEAM_LIST
    if val.is_a?(Numeric)
      id = val
    elsif val.is_a?(Symbol)
      id = getConst(PBTrainers,val)
    end
    e_team = true if !id.nil? && trainerid == id
  end
  viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
  viewport.z = 99999
  # Fade to gray a few times.
  viewport.color = Color.new(17*8,17*8,17*8)
  3.times do
    viewport.color.alpha = 0
    6.times do
      viewport.color.alpha += 30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    6.times do
      viewport.color.alpha -= 30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  
  echoln "TRANSITION: checking handled cases"

  if trainerid >= 0 && !handled
    # checks if the Sun & Moon styled VS sequence is to be played
    handled = checkIfNewTransition(trainerid)
    $smAnim = true if handled
    handled = vsEvilTeam(viewport) if e_team && !handled
    #handled = SunMoonBattleTransitions.new.evilTeam(viewport) if e_team && !handled
    # classic VS sequences
    tbargraphic = sprintf("Graphics/Transitions/vsBarSpecial%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic = sprintf("Graphics/Transitions/vsBarSpecial%d",trainerid) if !pbResolveBitmap(tbargraphic)
    tgraphic = sprintf("Graphics/Transitions/vsTrainerSpecial%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tgraphic = sprintf("Graphics/Transitions/vsTrainerSpecial%d",trainerid) if !pbResolveBitmap(tgraphic)
    if pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceSpecial(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic = sprintf("Graphics/Transitions/vsBarElite%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic = sprintf("Graphics/Transitions/vsBarElite%d",trainerid) if !pbResolveBitmap(tbargraphic)
    tgraphic = sprintf("Graphics/Transitions/vsTrainer%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tgraphic = sprintf("Graphics/Transitions/vsTrainer%d",trainerid) if !pbResolveBitmap(tgraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceElite(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic = sprintf("Graphics/Transitions/vsBarNew%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic = sprintf("Graphics/Transitions/vsBarNew%d",trainerid) if !pbResolveBitmap(tbargraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceNew(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic = sprintf("Graphics/Transitions/vsBar%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic = sprintf("Graphics/Transitions/vsBar%d",trainerid) if !pbResolveBitmap(tbargraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceEssentials(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
  end
  if !handled && trainerid >= 0
    case rand(3)
    when 0
      ebTrainerAnimation1(viewport)
    when 1
      ebTrainerAnimation2(viewport)
    when 2
      ebTrainerAnimation3(viewport)
    end
    handled = true
  end
  if !handled
    minor = false
    if !$wildSpecies.nil?
      for species in MINOR_LEGENDARIES
        num = species if species.is_a?(Numeric)
        num = getConst(PBSpecies,species) if species.is_a?(Symbol)
        minor = true if $wildSpecies == num
      end
      special = pbResolveBitmap("Graphics/Transitions/species#{$wildSpecies}")
    end
    echoln "TRANSITION: checking which animation to play"
    if !$wildSpecies.nil? && queuedIsRegi?
      ebWildAnimationRegi(viewport)
    elsif !$wildSpecies.nil? && isAuraDraga?
      vsXSpecies(viewport,$wildSpecies) 
    elsif !$wildSpecies.nil? && isBoss?
      if !(NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false)) #NEWBOSSES.include?($wildSpecies)
        echoln "STARTING OLD TRANSITION"
        if isXSpecies?($wildSpecies)
          vsXSpecies(viewport,$wildSpecies)
        else
          ebWildAnimationMinor(viewport,true) 
        end
      else
        echoln "TRANSITION: playing ebWildAnimationMinor"
        ebWildAnimationMinor(viewport,true) 
      end
    elsif !$wildSpecies.nil? && special
      ebWildAnimationMinor(viewport,true) 
      $specialSpecies = true
    elsif !$wildSpecies.nil? && minor
      ebWildAnimationMinor(viewport) 
    elsif !$wildLevel.nil? && $wildLevel > $Trainer.party[0].level
      ebWildAnimationOverlevel(viewport)
    elsif $PokemonGlobal && ($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.fishing)
      ebWildAnimationWater(viewport)    
    elsif $PokemonEncounters && $PokemonEncounters.isCave?
      ebWildAnimationCave(viewport)
    elsif pbGetMetadata($game_map.map_id,MetadataOutdoor)
      ebWildAnimationOutdoor(viewport)
    else 
      ebWildAnimationIndoor(viewport)
    end
    handled = true
  end
  pbPushFade
  yield if block_given?
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM = nil
  $PokemonGlobal.nextBattleME = nil
  $PokemonGlobal.nextBattleBack = nil
  $PokemonEncounters.clearStepCount
  for j in 0..17
    viewport.color = Color.new(0,0,0,(17-j)*15)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
end

alias pbWildBattle_ebs pbWildBattle unless defined?(pbWildBattle_ebs)
def pbWildBattle(*args)
  species = args[0]
  if species.is_a?(String) || species.is_a?(Symbol)
    $wildSpecies = getConst(PBSpecies,species)
  else
    $wildSpecies = species
  end
  $wildLevel = args[1]
  return pbWildBattle_ebs(*args)
  $wildSpecies = nil
  $wildLevel = nil
end
#-------------------------------------------------------------------------------
# Custom animations for trainer battles
#-------------------------------------------------------------------------------
def ebTrainerAnimation1(viewport)
  ball=Sprite.new(viewport)
  ball.bitmap=pbBitmap("Graphics/Transitions/vsBall")
  ball.ox=ball.bitmap.width/2
  ball.oy=ball.bitmap.height/2
  ball.x=viewport.rect.width/2
  ball.y=viewport.rect.height/2
  ball.zoom_x=0
  ball.zoom_y=0
  16.times do
    ball.angle+=22.5
    ball.zoom_x+=0.0625
    ball.zoom_y+=0.0625
    pbWait(1)
  end
  bmp=Graphics.snap_to_bitmap
  pbWait(8)
  ball.dispose
  black=Sprite.new(viewport)
  black.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  black.bitmap.fill_rect(0,0,viewport.rect.width,viewport.rect.height,Color.new(0,0,0))
  field1=Sprite.new(viewport)
  field1.bitmap=bmp
  field1.src_rect.height=VIEWPORT_HEIGHT/2
  field2=Sprite.new(viewport)
  field2.bitmap=bmp
  field2.y=VIEWPORT_HEIGHT/2
  field2.src_rect.height=VIEWPORT_HEIGHT/2
  field2.src_rect.y=(VIEWPORT_HEIGHT+VIEWPORT_OFFSET)/2
  16.times do
    field1.x-=viewport.rect.width/16
    field2.x+=viewport.rect.width/16
    pbWait(1)
  end
  viewport.color=Color.new(0,0,0,255)
  black.dispose
  field1.dispose
  field2.dispose
end

def ebTrainerAnimation2(viewport)
  bmp=Graphics.snap_to_bitmap
  black=Sprite.new(viewport)
  black.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  black.bitmap.fill_rect(0,0,viewport.rect.width,viewport.rect.height,Color.new(0,0,0))
  field1=Sprite.new(viewport)
  field1.bitmap=bmp
  field1.src_rect.height=VIEWPORT_HEIGHT/2
  field2=Sprite.new(viewport)
  field2.bitmap=bmp
  field2.y=VIEWPORT_HEIGHT/2
  field2.src_rect.height=VIEWPORT_HEIGHT/2
  field2.src_rect.y=(VIEWPORT_HEIGHT+VIEWPORT_OFFSET)/2
  ball1=Sprite.new(viewport)
  ball1.bitmap=pbBitmap("Graphics/Transitions/vsBall")
  ball1.ox=ball1.bitmap.width/2
  ball1.oy=ball1.bitmap.height/2
  ball1.x=viewport.rect.width+ball1.ox
  ball1.y=viewport.rect.height/4
  ball1.zoom_x=0.5
  ball1.zoom_y=0.5
  ball2=Sprite.new(viewport)
  ball2.bitmap=pbBitmap("Graphics/Transitions/vsBall")
  ball2.ox=ball2.bitmap.width/2
  ball2.oy=ball2.bitmap.height/2
  ball2.y=(viewport.rect.height/4)*3
  ball2.x=-ball2.ox
  ball2.zoom_x=0.5
  ball2.zoom_y=0.5
  16.times do
    ball1.x-=(viewport.rect.width/8)
    ball2.x+=(viewport.rect.width/8)
    pbWait(1)
  end
  32.times do
    field1.x-=(viewport.rect.width/16)
    field1.y-=(viewport.rect.height/32)
    field2.x+=(viewport.rect.width/16)
    field2.y+=(viewport.rect.height/32)
    pbWait(1)
  end
  viewport.color=Color.new(0,0,0,255)
  black.dispose
  ball1.dispose
  ball2.dispose
  field1.dispose
  field2.dispose
end

def ebTrainerAnimation3(viewport)
  balls = {}
  rects = {}
  ball = Bitmap.new(viewport.rect.height/6,viewport.rect.height/6)
  bmp = pbBitmap("Graphics/Transitions/vsBall")
  ball.stretch_blt(Rect.new(0,0,ball.width,ball.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
  for i in 0...6
    rects["#{i}"] = Sprite.new(viewport)
    rects["#{i}"].bitmap = Bitmap.new(1,viewport.rect.height/6)
    rects["#{i}"].bitmap.fill_rect(0,0,1,viewport.rect.height/6,Color.new(0,0,0))
    rects["#{i}"].x = (i%2==0) ? -32 : viewport.rect.width+32
    rects["#{i}"].ox = (i%2==0) ? 0 : 1
    rects["#{i}"].y = (viewport.rect.height/6)*i
    
    balls["#{i}"] = Sprite.new(viewport)
    balls["#{i}"].bitmap = ball
    balls["#{i}"].ox = ball.width/2
    balls["#{i}"].oy = ball.height/2
    balls["#{i}"].x = rects["#{i}"].x
    balls["#{i}"].y = rects["#{i}"].y + rects["#{i}"].bitmap.height/2
  end
  for j in 0...28
    for i in 0...6
      balls["#{i}"].x+=(i%2==0) ? 24 : -24
      balls["#{i}"].angle-=(i%2==0) ? 42 : -42
      rects["#{i}"].zoom_x+=24
    end
    pbWait(1)
  end
  viewport.color = Color.new(0,0,0,255)
  pbDisposeSpriteHash(balls)
  pbDisposeSpriteHash(rects)
end
#-------------------------------------------------------------------------------
# Custom animations for wild battles
#-------------------------------------------------------------------------------
def queuedIsRegi?
  ret = false
  for poke in [:REGIROCK,:REGISTEEL,:REGICE,:REGIGIGAS,:REGINALOUS,:REGIELEKI,:REGIDRAGO]
    num = getConst(PBSpecies,poke)
    next if num.nil? || ret
    if $wildSpecies == num
      ret = true
    end
  end
  return ret
end

def ebWildAnimationRegi(viewport)
  fp = {}
  index = [PBSpecies::REGIROCK,PBSpecies::REGISTEEL,PBSpecies::REGICE,PBSpecies::REGIGIGAS,PBSpecies::REGINALOUS,PBSpecies::REGIELEKI,PBSpecies::REGIDRAGO].index($wildSpecies)
  width = viewport.rect.width
  height = viewport.rect.height
  viewport.color = Color.new(0,0,0,0)
  fp["back"] = Sprite.new(viewport)
  fp["back"].bitmap = Graphics.snap_to_bitmap
  fp["back"].blur_sprite
  c = index != 3 ? 0 : 255
  fp["back"].color = Color.new(c,c,c,128*(index != 3 ? 1 : 2))
  fp["back"].z = 99999
  fp["back"].opacity = 0
  x = [
  [width*0.5,width*0.25,width*0.75,width*0.25,width*0.75,width*0.25,width*0.75],
  [width*0.5,width*0.3,width*0.7,width*0.15,width*0.85,width*0.3,width*0.7],
  [width*0.5,width*0.325,width*0.675,width*0.5,width*0.5,width*0.15,width*0.85],
  [width*0.5,width*0.5,width*0.5,width*0.5,width*0.35,width*0.65,width*0.5], #regigigas
  [width*0.3,width*0.7,width*0.5,width*0.5,width*0.7,width*0.3,width*0.5], #regina
  [width*0.5,width*0.325,width*0.675,width*0.175,width*0.825,width*0.175,width*0.825], #regieleki
  [width*0.5,width*0.30,width*0.70,width*0.35,width*0.65,width*0.5,width*0.5] #regidrago
  ]
  y = [
  [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.75,height*0.25],
  [height*0.5,height*0.25,height*0.75,height*0.5,height*0.5,height*0.75,height*0.25],
  [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.5,height*0.5],
  [height*0.9,height*0.74,height*0.58,height*0.4,height*0.25,height*0.25,height*0.1], #regigigas
  [height*0.75,height*0.5,height*0.87,height*0.38,height*0.75,height*0.5,height*0.15], #regina
  [height*0.5,height*0.5,height*0.5,height*0.4,height*0.6,height*0.6,height*0.4], #regieleki
  [height*0.30,height*0.2,height*0.2,height*0.42,height*0.42,height*0.55,height*0.8] #regidrago

  
  ]
  for j in 0...14
    fp["#{j}"] = Sprite.new(viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/Transitions/regi")
    fp["#{j}"].src_rect.set(96*(j/7),100*index,96,100)
    fp["#{j}"].ox = fp["#{j}"].src_rect.width/2
    fp["#{j}"].oy = fp["#{j}"].src_rect.height/2
    fp["#{j}"].x = x[index][j%7]
    fp["#{j}"].y = y[index][j%7]
    fp["#{j}"].opacity = 0
    fp["#{j}"].z = 99999
  end
  8.times do
    fp["back"].opacity += 32
    pbWait(1)
  end
  k = -2
  for i in 0...72
    if index != 3
      k += 2 if i%8==0
    else
      k += (k==3 ? 2 : 1) if i%4==0
    end
    k = 6 if k > 6
    for j in 0..k
      fp["#{j}"].opacity += 32
      fp["#{j+7}"].opacity += 26 if fp["#{j}"].opacity >= 255
      fp["#{j}"].visible = fp["#{j+7}"].opacity < 255
    end
    fp["back"].color.alpha += 2 if fp["back"].color.alpha < 255
    pbWait(1)
  end
  8.times do
    viewport.color.alpha += 32
    pbWait(1)
  end
  pbDisposeSpriteHash(fp)
end

def ebWildAnimationOutdoor(viewport)
  screen=Sprite.new(viewport)
  screen.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  black=Color.new(0,0,0)
  width=viewport.rect.width/16
  height=viewport.rect.height/4
  for i in 0...16
    if i < 8
      x1=width+(i%8)*(width*2)
      x2=viewport.rect.width-width-(i%8)*(width*2)
    else
      x2=width+(i%8)*(width*2)
      x1=viewport.rect.width-width-(i%8)*(width*2)
    end
    y1=(i/8)*height
    y2=viewport.rect.height-height-y1
    for j in 1...3
      ext=j*(width/2)
      screen.bitmap.fill_rect(x1,y1,ext,height,black)
      screen.bitmap.fill_rect(x1-ext,y1,ext,height,black)
      screen.bitmap.fill_rect(x2,y2,ext,height,black)
      screen.bitmap.fill_rect(x2-ext,y2,ext,height,black)
      pbWait(1)
    end  
  end  
  viewport.color=Color.new(0,0,0,255)
  screen.dispose
end

def ebWildAnimationIndoor(viewport)
  screen=Sprite.new(viewport)
  screen.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  black=Color.new(0,0,0)
  width=viewport.rect.width
  height=viewport.rect.height/16
  for i in 1...17
    for j in 0...16
      x=(j%2==0) ? 0 : viewport.rect.width-i*(width/16)
      screen.bitmap.fill_rect(x,j*height,i*(width/16),height,black)
    end
    pbWait(1)
  end
  viewport.color=Color.new(0,0,0,255)
  pbWait(10)
  screen.dispose
end

def ebWildAnimationCave(viewport)
  screen=Sprite.new(viewport)
  screen.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  black=Color.new(0,0,0)
  width=viewport.rect.width/4
  height=viewport.rect.height/4
  sprites={}
  for i in 0...16
    sprites["#{i}"]=Sprite.new(viewport)
    sprites["#{i}"].bitmap=Bitmap.new(width,height)
    sprites["#{i}"].bitmap.fill_rect(0,0,width,height,black)
    sprites["#{i}"].ox=width/2
    sprites["#{i}"].oy=height/2
    sprites["#{i}"].x=width/2+width*(i%4)
    sprites["#{i}"].y=viewport.rect.height-height/2-height*(i/4)
    sprites["#{i}"].zoom_x=0
    sprites["#{i}"].zoom_y=0
  end
  seq=[[0],[4,1],[8,5,2],[12,9,6,3],[13,10,7],[14,11],[15]]
  for i in 0...seq.length
    5.times do
      for j in 0...seq[i].length
        n=seq[i][j]
        sprites["#{n}"].zoom_x+=0.2
        sprites["#{n}"].zoom_y+=0.2
      end
      pbWait(1)
    end
  end
  viewport.color=Color.new(0,0,0,255)
  pbWait(1)
  pbDisposeSpriteHash(sprites)
  screen.dispose
end

def ebWildAnimationMinor(viewport,special=false)
  bmp = Graphics.snap_to_bitmap
  max = 50
  amax = 4
  frames = {}
  zoom = 1
  viewport.color = special ? Color.new(64,64,64,0) : Color.new(255,255,155,0)
  20.times do
    viewport.color.alpha+=2
    pbWait(1)
  end
  for i in 0...(max+20)
    if !(i%2==0)
      if i > max*0.75
        zoom+=0.3
      else
        zoom-=0.01
      end
      angle = 0 if angle.nil?
      angle = (i%3==0) ? rand(amax*2) - amax : angle
      frames["#{i}"] = Sprite.new(viewport)
      frames["#{i}"].bitmap = bmp
      frames["#{i}"].src_rect.set(0,0,viewport.rect.width,viewport.rect.height)
      frames["#{i}"].ox = viewport.rect.width/2
      frames["#{i}"].oy = viewport.rect.height/2
      frames["#{i}"].x = viewport.rect.width/2
      frames["#{i}"].y = viewport.rect.height/2
      frames["#{i}"].angle = angle
      frames["#{i}"].zoom_x = zoom
      frames["#{i}"].zoom_y = zoom
      frames["#{i}"].tone = Tone.new(i/4,i/4,i/4)
      frames["#{i}"].opacity = 30
    end
    if i >= max
      viewport.color.alpha += 12
      if special
        viewport.color.red -= 64/20.0
        viewport.color.green -= 64/20.0
        viewport.color.blue -= 64/20.0
      else
        viewport.color.blue += 5
      end
    end
    pbWait(1)
  end
  frames["#{max+19}"].tone = Tone.new(255,255,255)
  pbWait(10)
  10.times do
    next if special
    viewport.color.red-=25.5
    viewport.color.green-=25.5
    viewport.color.blue-=25.5
    pbWait(1)
  end
  pbDisposeSpriteHash(frames)
end

def ebWildAnimationOverlevel(viewport)
  height = viewport.rect.height/4
  width = viewport.rect.width/10
  backdrop = Sprite.new(viewport)
  backdrop.bitmap = Graphics.snap_to_bitmap
  sprite = Sprite.new(viewport)
  sprite.bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
  for j in 0...4
    y = [0,2,1,3]
    for i in 1..10
      sprite.bitmap.fill_rect(0,height*y[j],width*i,height,Color.new(255,255,255))
      backdrop.tone.red += 3
      backdrop.tone.green += 3
      backdrop.tone.blue += 3
      pbWait(1)
    end
  end
  viewport.color = Color.new(0,0,0,0)
  10.times do
    viewport.color.alpha += 25.5
    pbWait(1)
  end
  backdrop.dispose
  sprite.dispose
end

def ebWildAnimationWater(viewport)
  bmp = Graphics.snap_to_bitmap
  split = 12
  n = viewport.rect.height/split
  sprites = {}
  black = Sprite.new(viewport)
  black.bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
  black.bitmap.fill_rect(0,0,black.bitmap.width,black.bitmap.height,Color.new(0,0,0))
  for i in 0...n
    sprites["#{i}"] = Sprite.new(viewport)
    sprites["#{i}"].bitmap = bmp
    sprites["#{i}"].ox = bmp.width/2
    sprites["#{i}"].x = viewport.rect.width/2
    sprites["#{i}"].y = i*split
    sprites["#{i}"].src_rect.set(0,i*split,bmp.width,split)
    sprites["#{i}"].color = Color.new(0,0,0,0)
  end
  for f in 0...64
    for i in 0...n
      o = Math.sin(f - i*0.5)
      sprites["#{i}"].x = viewport.rect.width/2 + 16*o if f >= i
      sprites["#{i}"].color.alpha += 25.5 if sprites["#{i}"].color.alpha < 255 && f >= (64 - (48-i))
    end
    pbWait(1)
  end
  viewport.color = Color.new(0,0,0,255)
  pbDisposeSpriteHash(sprites)
end
#-------------------------------------------------------------------------------
# VS. animation, by Luka S.J.
# Tweaked by Maruno.
# (official Essentials one)
#-------------------------------------------------------------------------------
def vsSequenceEssentials(viewport,trainername,trainerid,tbargraphic,tgraphic)
  outfit=$Trainer ? $Trainer.outfit : 0
  # Set up
  viewplayer=Viewport.new(0,viewport.rect.height/3,viewport.rect.width/2,128)
  viewplayer.z=viewport.z
  viewopp=Viewport.new(viewport.rect.width/2,viewport.rect.height/3,viewport.rect.width/2,128)
  viewopp.z=viewport.z
  viewvs=Viewport.new(0,0,viewport.rect.width,viewport.rect.height)
  viewvs.z=viewport.z
  xoffset=(viewport.rect.width/2)/10
  xoffset=xoffset.round
  xoffset=xoffset*10
  fade=Sprite.new(viewport)
  fade.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsFlash")
  fade.tone=Tone.new(-255,-255,-255)
  fade.opacity=100
  overlay=Sprite.new(viewport)
  overlay.bitmap=Bitmap.new(viewport.rect.width,viewport.rect.height)
  pbSetSystemFont(overlay.bitmap)
  bar1=Sprite.new(viewplayer)
  pbargraphic=sprintf("Graphics/Transitions/vsBar%s_%d",getConstantName(PBTrainers,$Trainer.trainertype),outfit) rescue nil
  pbargraphic=sprintf("Graphics/Transitions/vsBar%d_%d",$Trainer.trainertype,outfit) if !pbResolveBitmap(pbargraphic)
  if !pbResolveBitmap(pbargraphic)
    pbargraphic=sprintf("Graphics/Transitions/vsBar%s",getConstantName(PBTrainers,$Trainer.trainertype)) rescue nil
  end
  pbargraphic=sprintf("Graphics/Transitions/vsBar%d",$Trainer.trainertype) if !pbResolveBitmap(pbargraphic)
  bar1.bitmap=BitmapCache.load_bitmap(pbargraphic)
  bar1.x=-xoffset
  bar2=Sprite.new(viewopp)
  bar2.bitmap=BitmapCache.load_bitmap(tbargraphic)
  bar2.x=xoffset
  vs=Sprite.new(viewvs)
  vs.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vs")
  vs.ox=vs.bitmap.width/2
  vs.oy=vs.bitmap.height/2
  vs.x=viewport.rect.width/2
  vs.y=viewport.rect.height/1.5
  vs.visible=false
  flash=Sprite.new(viewvs)
  flash.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsFlash")
  flash.opacity=0
  # Animation
  10.times do
    bar1.x+=xoffset/10
    bar2.x-=xoffset/10
    pbWait(1)
  end
  pbSEPlay("#{SE_EXTRA_PATH}Flash2")
  pbSEPlay("#{SE_EXTRA_PATH}Sword2")
  flash.opacity=255
  bar1.dispose
  bar2.dispose
  bar1=AnimatedPlane.new(viewplayer)
  bar1.bitmap=BitmapCache.load_bitmap(pbargraphic)
  player=Sprite.new(viewplayer)
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%s_%d",getConstantName(PBTrainers,$Trainer.trainertype),outfit) rescue nil
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%d_%d",$Trainer.trainertype,outfit) if !pbResolveBitmap(pgraphic)
  if !pbResolveBitmap(pgraphic)
    pgraphic=sprintf("Graphics/Transitions/vsTrainer%s",getConstantName(PBTrainers,$Trainer.trainertype)) rescue nil
  end
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%d",$Trainer.trainertype) if !pbResolveBitmap(pgraphic)
  player.bitmap=BitmapCache.load_bitmap(pgraphic)
  player.x=-xoffset
  bar2=AnimatedPlane.new(viewopp)
  bar2.bitmap=BitmapCache.load_bitmap(tbargraphic)
  trainer=Sprite.new(viewopp)
  trainer.bitmap=BitmapCache.load_bitmap(tgraphic)
  trainer.x=xoffset
  trainer.tone=Tone.new(-255,-255,-255)
  25.times do
    flash.opacity-=51 if flash.opacity>0
    bar1.ox-=16
    bar2.ox+=16
    pbWait(1)
  end
  11.times do
    bar1.ox-=16
    bar2.ox+=16
    player.x+=xoffset/10
    trainer.x-=xoffset/10
    pbWait(1)
  end
  2.times do
    bar1.ox-=16
    bar2.ox+=16
    player.x-=xoffset/20
    trainer.x+=xoffset/20
    pbWait(1)
  end
  10.times do
    bar1.ox-=16
    bar2.ox+=16
    pbWait(1)
  end
  val=2
  flash.opacity=255
  vs.visible=true
  trainer.tone=Tone.new(0,0,0)
  textpos=[
    [_INTL("{1}",$Trainer.name),viewport.rect.width/4,(viewport.rect.height/1.5)+10,2,
      Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
    [_INTL("{1}",trainername),(viewport.rect.width/4)+(viewport.rect.width/2),(viewport.rect.height/1.5)+10,2,
      Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
  ]
  pbDrawTextPositions(overlay.bitmap,textpos)
  pbSEPlay("#{SE_EXTRA_PATH}Sword2")
  70.times do
    bar1.ox-=16
    bar2.ox+=16
    flash.opacity-=25.5 if flash.opacity>0
    vs.x+=val
    vs.y-=val
    val=2 if vs.x<=(viewport.rect.width/2)-2
    val=-2 if vs.x>=(viewport.rect.width/2)+2
    pbWait(1)
  end
  30.times do
    bar1.ox-=16
    bar2.ox+=16
    vs.zoom_x+=0.2
    vs.zoom_y+=0.2
    pbWait(1)
  end
  flash.tone=Tone.new(-255,-255,-255)
  10.times do
    bar1.ox-=16
    bar2.ox+=16
    flash.opacity+=25.5
    pbWait(1)
  end
  # End
  player.dispose
  trainer.dispose
  flash.dispose
  vs.dispose
  bar1.dispose
  bar2.dispose
  overlay.dispose
  fade.dispose
  viewvs.dispose
  viewopp.dispose
  viewplayer.dispose
  viewport.color=Color.new(0,0,0,255)
  return true
end
#-------------------------------------------------------------------------------
# New EBS VS. animation
#-------------------------------------------------------------------------------
def vsSequenceNew(viewport,trainername,trainerid,tbargraphic,tgraphic)
  #------------------
  # sets the face2 graphic to be the shadow instead of larger mug
  showShadow = false
  # decides whether or not to colour the vsLight(s) according to the vsBar
  colorLight = false
  # decides whether or not to return to default white colour 
  colorReset = false
  #------------------
  ow = Sprite.new(viewport)
  ow.bitmap = Graphics.snap_to_bitmap
  ow.blur_sprite
  ow.opacity = 0
  ow.tone = Tone.new(-92,-92,-92)
  
  bmp = pbBitmap("Graphics/Transitions/vsLight3")
  globaly = viewport.rect.height*0.4
  
  bar = Sprite.new(viewport)
  bar.bitmap = pbBitmap(tbargraphic)
  bar.ox = bar.bitmap.width
  bar.oy = bar.bitmap.height/2
  bar.x = viewport.rect.width*2 + 64
  bar.y = globaly
  
  color = bar.bitmap.get_pixel(bar.bitmap.width/2,1)
  
  bbar1 = Sprite.new(viewport)
  bbar1.bitmap = Bitmap.new(viewport.rect.width,2)
  bbar1.bitmap.fill_rect(0,0,viewport.rect.width,2,Color.new(0,0,0))
  bbar1.y = bar.y - bar.oy 
  bbar1.zoom_y = 0
  bbar1.z = 99
  
  bbar2 = Sprite.new(viewport)
  bbar2.bitmap = Bitmap.new(viewport.rect.width,2)
  bbar2.bitmap.fill_rect(0,0,viewport.rect.width,2,Color.new(0,0,0))
  bbar2.oy = 2
  bbar2.y = bar.y + bar.oy + 8
  bbar2.zoom_y = 0
  bbar2.z = 99
  
  face2 = Sprite.new(viewport)
  face2.bitmap = pbBitmap(tgraphic)
  face2.src_rect.set(0,face2.bitmap.height/4,face2.bitmap.width,face2.bitmap.height/2) if !showShadow
  face2.oy = face2.src_rect.height/2
  face2.y = globaly
  face2.zoom_x = 2 if !showShadow
  face2.zoom_y = 2 if !showShadow
  face2.opacity = showShadow ? 255 : 92
  face2.visible = false
  face2.x = showShadow ? (viewport.rect.width - face2.bitmap.width + 16) : (viewport.rect.width - face2.bitmap.width*2 + 64)
  face2.color = Color.new(0,0,0,255) if showShadow
  
  light3 = Sprite.new(viewport)
  light3.bitmap = Bitmap.new(bmp.width*2,bmp.height)
  for i in 0...2
    light3.bitmap.blt(bmp.width*i,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
  end
  light3.x = viewport.rect.width
  light3.oy = bmp.height/2
  light3.y = globaly
  light3.color = color if colorLight
  
  light1 = Sprite.new(viewport)
  light1.bitmap = pbBitmap("Graphics/Transitions/vsLight1")
  light1.ox = light1.bitmap.width/2
  light1.oy = light1.bitmap.height/2
  light1.x = viewport.rect.width*0.25
  light1.y = globaly
  light1.zoom_x = 0
  light1.zoom_y = 0
  light1.color = color if colorLight
  
  light2 = Sprite.new(viewport)
  light2.bitmap = pbBitmap("Graphics/Transitions/vsLight2")
  light2.ox = light2.bitmap.width/2
  light2.oy = light2.bitmap.height/2
  light2.x = viewport.rect.width*0.25
  light2.y = globaly
  light2.zoom_x = 0
  light2.zoom_y = 0
  light2.color = color if colorLight
  
  vs = Sprite.new(viewport)
  vs.bitmap = pbBitmap("Graphics/Transitions/vs")
  vs.ox = vs.bitmap.width/2
  vs.oy = vs.bitmap.height/2
  vs.x = viewport.rect.width*0.25
  vs.y = globaly
  vs.opacity = 0
  vs.zoom_x = 4
  vs.zoom_y = 4
  
  face1 = Sprite.new(viewport)
  face1.bitmap = pbBitmap(tgraphic)
  face1.oy = face1.bitmap.height/2
  face1.y = globaly
  face1.x = viewport.rect.width
  face1.color = Color.new(0,0,0,255)
  
  name = Sprite.new(viewport)
  name.bitmap = Bitmap.new(viewport.rect.width/2,96)
  pbSetSystemFont(name.bitmap)
  name.ox = name.bitmap.width/2
  name.x = viewport.rect.width*0.75
  name.y = bar.y + bar.oy
  pbDrawTextPositions(name.bitmap,[[trainername,name.bitmap.width/2,4,2,Color.new(255,255,255),nil]])
  name.visible = false
  
  ripples = Sprite.new(viewport)
  ripples.bitmap = pbBitmap("Graphics/Transitions/ripples")
  ripples.ox = ripples.bitmap.width/2
  ripples.oy = ripples.bitmap.height/2
  ripples.x = vs.x
  ripples.y = globaly
  ripples.opacity = 0
  ripples.z = 99
  ripples.zoom_x = 0.0
  ripples.zoom_y = 0.0
  
  8.times do
    light1.zoom_x+=1.0/16
    light1.zoom_y+=1.0/16
    light2.zoom_x+=1.0/8
    light2.zoom_y+=1.0/8
    light1.angle-=32
    light2.angle+=64
    light3.x-=64
    ow.opacity+=12.8
    pbWait(1)
  end
  n = false
  k = false
  max = 224
  for i in 0...max
    n = !n if i%8==0
    k = !k if i%4==0
    ow.opacity+=12.8 if ow.opacity < 255
    light1.zoom_x+=(n ? 1.0/16 : -1.0/16)
    light1.zoom_y+=(n ? 1.0/16 : -1.0/16)
    light1.angle-=16
    light2.angle+=32
    light3.x-=32
    light3.x = 0 if light3.x <= -light3.bitmap.width/2
    if i >= 32 && i < 41
      bar.x-=64
      pbSEPlay("#{SE_EXTRA_PATH}Ice8",80) if i==32
    end
    if i >= 32
      face1.x-=(face1.x-viewport.rect.width/2)*0.1
    end
    viewport.color.alpha-=255/20.0 if viewport.color.alpha > 0
    face2.x -= (showShadow ? -1 : 1) if i%(showShadow ? 4 : 2)==0 && face2.visible
    vs.x+=(k ? 2 : -2)/2 if i >= 72
    vs.y-=(k ? 2 : -2)/2 if i >= 72
    ripples.opacity-=12.8 if ripples.opacity > 0
    ripples.zoom_x+=0.2 if ripples.opacity > 0
    ripples.zoom_y+=0.2 if ripples.opacity > 0
    if i > 62
      vs.opacity+=25.5 if vs.opacity < 255
      vs.zoom_x-=0.2 if vs.zoom_x > 1
      vs.zoom_y-=0.2 if vs.zoom_y > 1
    end
    if i==72
      viewport.color = Color.new(255,255,255,255)
      ow.color = Color.new(0,0,0,255)
      face2.visible = true
      face1.color = Color.new(0,0,0,0)
      name.visible = true
      ripples.opacity = 255
      pbSEPlay("#{SE_EXTRA_PATH}Saint9",50)
      pbSEPlay("#{SE_EXTRA_PATH}Flash2",50)
      if colorReset
        light1.color = Color.new(0,0,0,0)
        light2.color = Color.new(0,0,0,0)
        light3.color = Color.new(0,0,0,0)
      end
    end
    if i >= max-8
      bbar1.zoom_y+=8
      bbar2.zoom_y+=8
      name.opacity-=255/4.0
    end
    pbWait(1)
  end
  viewport.color = Color.new(0,0,0,255)
  ow.dispose
  bar.dispose
  bbar1.dispose
  bbar2.dispose
  face1.dispose
  face2.dispose
  light1.dispose
  light2.dispose
  light3.dispose
  ripples.dispose
  vs.dispose
  return true
end
#-------------------------------------------------------------------------------
# Elite Four EBS VS. animation
#-------------------------------------------------------------------------------
def vsSequenceElite(viewport,trainername,trainerid,tbargraphic,tgraphic)
  ow = Sprite.new(viewport)
  ow.bitmap = Graphics.snap_to_bitmap
  ow.blur_sprite
  ow.opacity = 0
  ow.tone = Tone.new(-92,-92,-92)
  
  effect1 = Sprite.new(viewport)
  effect1.bitmap = pbBitmap("Graphics/Transitions/vsBg")
  effect1.ox = effect1.bitmap.width/2
  effect1.x = viewport.rect.width/2
  effect1.oy = effect1.bitmap.height/2
  effect1.y = viewport.rect.height/2
  effect1.visible = false
  
  names = Sprite.new(viewport)
  names.bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
  names.z = 999
  pbSetSystemFont(names.bitmap)
  txt = [
    [trainername,viewport.rect.width*0.25,viewport.rect.height*0.25+32,2,Color.new(255,255,255),Color.new(32,32,32)],
    [$Trainer.name,viewport.rect.width*0.75,viewport.rect.height*0.75+32,2,Color.new(255,255,255),Color.new(32,32,32)]
  ]
  pbDrawTextPositions(names.bitmap,txt)
  names.visible = false
    
  bmp = pbBitmap("Graphics/Transitions/vsLight3")
  
  bar1 = Sprite.new(viewport)
  bar1.bitmap = pbBitmap(tbargraphic)
  bar1.oy = bar1.bitmap.height/2
  bar1.y = viewport.rect.height*0.25
  bar1.x = viewport.rect.width
  
  light1 = Sprite.new(viewport)
  light1.bitmap = Bitmap.new(bmp.width*2,bmp.height)
  for i in 0...2
    light1.bitmap.blt(bmp.width*i,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
  end
  light1.x = viewport.rect.width
  light1.oy = bmp.height/2
  light1.y = viewport.rect.height*0.25
  
  shadow1 = Sprite.new(viewport)
  shadow1.bitmap = pbBitmap(tgraphic)
  shadow1.oy = shadow1.bitmap.height/2
  shadow1.y = viewport.rect.height*0.25
  shadow1.x = viewport.rect.width/2 - 16
  shadow1.color = Color.new(0,0,0,255)
  shadow1.opacity = 96
  shadow1.visible = false
  
  face1 = Sprite.new(viewport)
  face1.bitmap = pbBitmap(tgraphic)
  face1.oy = face1.bitmap.height/2
  face1.y = viewport.rect.height*0.25
  face1.x = viewport.rect.width
  face1.color = Color.new(0,0,0,255)
  
  #-------------------
  outfit=$Trainer ? $Trainer.outfit : 0
  pbargraphic=sprintf("Graphics/Transitions/vsBarElite%s_%d",getConstantName(PBTrainers,$Trainer.trainertype),outfit) rescue nil
  pbargraphic=sprintf("Graphics/Transitions/vsBarElite%d_%d",$Trainer.trainertype,outfit) if !pbResolveBitmap(pbargraphic)
  if !pbResolveBitmap(pbargraphic)
    pbargraphic=sprintf("Graphics/Transitions/vsBarElite%s",getConstantName(PBTrainers,$Trainer.trainertype)) rescue nil
  end
  pbargraphic=sprintf("Graphics/Transitions/vsBarElite%d",$Trainer.trainertype) if !pbResolveBitmap(pbargraphic)
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%s_%d",getConstantName(PBTrainers,$Trainer.trainertype),outfit) rescue nil
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%d_%d",$Trainer.trainertype,outfit) if !pbResolveBitmap(pgraphic)
  if !pbResolveBitmap(pgraphic)
    pgraphic=sprintf("Graphics/Transitions/vsTrainer%s",getConstantName(PBTrainers,$Trainer.trainertype)) rescue nil
  end
  pgraphic=sprintf("Graphics/Transitions/vsTrainer%d",$Trainer.trainertype) if !pbResolveBitmap(pgraphic)
  #-------------------
  
  bar2 = Sprite.new(viewport)
  bar2.bitmap = pbBitmap(pbargraphic)
  bar2.oy = bar2.bitmap.height/2
  bar2.y = viewport.rect.height*0.75
  bar2.x = -bar2.bitmap.width
  
  light2 = Sprite.new(viewport)
  light2.bitmap = light1.bitmap.clone
  light2.mirror = true
  light2.x = -light2.bitmap.width
  light2.oy = bmp.height/2
  light2.y = viewport.rect.height*0.75
  
  shadow2 = Sprite.new(viewport)
  shadow2.bitmap = pbBitmap(pgraphic)
  shadow2.oy = shadow2.bitmap.height/2
  shadow2.y = viewport.rect.height*0.75
  shadow2.x = 16
  shadow2.color = Color.new(0,0,0,255)
  shadow2.opacity = 96
  shadow2.visible = false
  
  face2 = Sprite.new(viewport)
  face2.bitmap = pbBitmap(pgraphic)
  face2.oy = face2.bitmap.height/2
  face2.y = viewport.rect.height*0.75
  face2.x = -face2.bitmap.width
  face2.color = Color.new(0,0,0,255)

  ripples = Sprite.new(viewport)
  ripples.bitmap = pbBitmap("Graphics/Transitions/ripples")
  ripples.ox = ripples.bitmap.width/2
  ripples.oy = ripples.bitmap.height/2
  ripples.x = viewport.rect.width/2
  ripples.y = viewport.rect.height/2
  ripples.opacity = 0
  ripples.zoom_x = 0.0
  ripples.zoom_y = 0.0
  ripples.z = 999
  
  vs = Sprite.new(viewport)
  vs.bitmap = pbBitmap("Graphics/Transitions/vs")
  vs.ox = vs.bitmap.width/2
  vs.oy = vs.bitmap.height/2
  vs.x = viewport.rect.width/2
  vs.y = viewport.rect.height/2
  vs.opacity = 0
  vs.zoom_x = 4
  vs.zoom_y = 4
  vs.z = 999
  
  max = 224
  k = false
  for i in 0...max
    k = !k if i%4==0
    viewport.color.alpha-=255/16.0 if viewport.color.alpha > 0
    ow.opacity+=12.8 if ow.opacity < 255
    light1.x-=(light1.x > 0) ? 64 : 32
    light1.x = 0 if light1.x <= -light1.bitmap.width/2
    bar1.x-=(bar1.x)*0.2 if i >= 32
    
    face1.x-=(face1.x-viewport.rect.width/2)*0.1 if i >= 16
    face2.x+=(0-face2.x)*0.1 if i >= 16
    
    light2.x+=(light2.x < -light2.bitmap.width/2) ? 64 : 32
    light2.x = -light2.bitmap.width/2 if light2.x >= 0
    bar2.x+=(0-bar2.x)*0.2 if i >= 32
    
    effect1.angle+=2 if $PokemonSystem.screensize < 2
    vs.x+=(k ? 2 : -2)/2 if i >= 72
    vs.y-=(k ? 2 : -2)/2 if i >= 72
    ripples.opacity-=12.8 if ripples.opacity > 0
    ripples.zoom_x+=0.2 if ripples.opacity > 0
    ripples.zoom_y+=0.2 if ripples.opacity > 0
    if i%4 == 0
      shadow1.x-=1
      shadow2.x+=1
    end
    if i > 62 && i < max-16
      vs.opacity+=25.5 if vs.opacity < 255
      vs.zoom_x-=0.2 if vs.zoom_x > 1
      vs.zoom_y-=0.2 if vs.zoom_y > 1
    end
    if i == 72
      face1.color = Color.new(0,0,0,0)
      face2.color = Color.new(0,0,0,0)
      viewport.color = Color.new(255,255,255,255)
      ow.color = Color.new(0,0,0,255)
      effect1.visible = true
      ripples.opacity = 255
      names.visible = true
      shadow1.visible = true
      shadow2.visible = true
      pbSEPlay("#{SE_EXTRA_PATH}Saint9",50)
      pbSEPlay("#{SE_EXTRA_PATH}Flash2",50)
    end
    viewport.color = Color.new(0,0,0,0) if i == max-17
    if i >= max-16
      vs.zoom_x+=0.2
      vs.zoom_y+=0.2
      viewport.color.alpha+=255/8.0
    end
    
    pbWait(1)
  end
  viewport.color = Color.new(0,0,0,255)
  ow.dispose
  effect1.dispose
  bar1.dispose
  bar2.dispose
  light1.dispose
  light2.dispose
  face1.dispose
  face2.dispose
  shadow1.dispose
  shadow2.dispose
  names.dispose
  vs.dispose
  ripples.dispose
  return true
end
#-------------------------------------------------------------------------------
# Special EBS VS. animation
#-------------------------------------------------------------------------------
def vsSequenceSpecial(viewport,trainername,trainerid,tbargraphic,tgraphic)
  ow = Sprite.new(viewport)
  ow.bitmap = Graphics.snap_to_bitmap
  ow.blur_sprite
  ow.opacity = 0
  
  bg = Sprite.new(viewport)
  bg.visible = false
  
  light = AnimatedPlane.new(viewport)
  light.bitmap = pbBitmap("Graphics/Transitions/vsSpecialLight")
  light.opacity = 0
  
  vss = Sprite.new(viewport)
  vss.bitmap = pbBitmap("Graphics/Transitions/vs")
  vss.color = Color.new(0,0,0,255)
  vss.ox = vss.bitmap.width/2
  vss.oy = vss.bitmap.height/2
  vss.x = 110 + 16
  vss.y = 132 + 16
  vss.opacity = 128
  vss.visible = false
  
  vs = Sprite.new(viewport)
  vs.bitmap = pbBitmap("Graphics/Transitions/vs")
  vs.ox = vs.bitmap.width/2
  vs.oy = vs.bitmap.height/2
  vs.x = 110
  vs.y = 132
  vs.visible = false
  
  names = Sprite.new(viewport)
  names.x = 6
  names.y = 4
  names.opacity = 128
  names.color = Color.new(0,0,0,255)
  names.visible = false
   
  name = Sprite.new(viewport)
  name.bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
  name.bitmap.font.name = "Arial"
  name.bitmap.font.size = $MKXP ? 46 : 48
  name.visible = false
  pbDrawOutlineText(name.bitmap,64,viewport.rect.height-160,-1,-1,"#{trainername}",Color.new(255,255,255),Color.new(0,0,0),2)
  names.bitmap = name.bitmap.clone
  
  border1 = Sprite.new(viewport)
  border1.bitmap = pbBitmap("Graphics/Transitions/vsBorder")
  border1.zoom_x = 1.2
  border1.y = -border1.bitmap.height
  border1.z = 99
  
  border2 = Sprite.new(viewport)
  border2.bitmap = pbBitmap("Graphics/Transitions/vsBorder")
  border2.zoom_x = 1.2
  border2.x = viewport.rect.width
  border2.angle = 180
  border2.y = viewport.rect.height+border2.bitmap.height
  border2.z = 99
  
  trainer = Sprite.new(viewport)
  trainer.bitmap = pbBitmap(tgraphic)
  trainer.x = 0
  trainer.ox = trainer.bitmap.width
  trainer.z = 100
  trainer.color = Color.new(0,0,0,255)
  
  shadow = Sprite.new(viewport)
  shadow.bitmap = pbBitmap(tgraphic)
  shadow.x = viewport.rect.width + 22
  shadow.ox = shadow.bitmap.width
  shadow.y = 22
  shadow.color = Color.new(0,0,0,255)
  shadow.opacity = 128
  shadow.visible = false
  
  if pbResolveBitmap(tbargraphic)
    bg.bitmap = pbBitmap(tbargraphic)
  else
    bg.bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    color = trainer.getAvgColor
    avg = ((color.red+color.green+color.blue)/3)-120
    color = Color.new(color.red-avg,color.green-avg,color.blue-avg)
    bg.bitmap.fill_rect(0,0,viewport.rect.width,viewport.rect.height,color)
  end
  
  y1 = border1.y.to_f
  y2 = border2.y.to_f
  30.times do
    ow.opacity += 12.8
    y1 += ((70-border1.bitmap.height)-y1)*0.2
    border1.y = y1
    y2 -= (y2-(viewport.rect.height+border2.bitmap.height-70))*0.2
    border2.y = y2
    light.opacity+=12.8
    light.ox += 24
    pbWait(1)
  end
  40.times do
    trainer.x += ((viewport.rect.width)-trainer.x)*0.2
    light.ox += 24
    pbWait(1)
  end
  
  viewport.tone = Tone.new(255,255,255)
  bg.visible = true
  shadow.visible = true
  vs.visible = true
  vss.visible = true
  name.visible = true
  names.visible = true
  trainer.color = Color.new(0,0,0,0)
  
  p = 1
  20.times do
    viewport.tone.red -= 255/20.0
    viewport.tone.green -= 255/20.0
    viewport.tone.blue -= 255/20.0
    light.ox += 24
    vs.x += p; vs.y -= p
    p = -1 if vs.x >= 112
    p = +1 if vs.x <= 108
    vss.x = vs.x + 16; vss.y = vs.y + 16    
    pbWait(1)
  end
  120.times do
    light.ox += 24
    vs.x += p; vs.y -= p
    p = -1 if vs.x >= 112
    p = +1 if vs.x <= 108
    vss.x = vs.x + 16; vss.y = vs.y + 16    
    pbWait(1)
  end
  y1 = border1.y.to_f
  y2 = border2.y.to_f
  6.times do
    trainer.x -= 1
    shadow.x = trainer.x + 22
    light.ox += 24
    vs.x += p; vs.y -= p
    p = -1 if vs.x >= 112
    p = +1 if vs.x <= 108
    vss.x = vs.x + 16; vss.y = vs.y + 16    
    pbWait(1)
  end
  30.times do
    trainer.x += ((viewport.rect.width*2)-trainer.x)*0.2
    shadow.x = trainer.x + 22
    y1 += ((0)-y1)*0.2
    border1.y = y1
    y2 -= (y2-(viewport.rect.height))*0.2
    border2.y = y2
    light.ox += 24
    vs.x += p; vs.y -= p
    p = -1 if vs.x >= 112
    p = +1 if vs.x <= 108
    vss.x = vs.x + 16; vss.y = vs.y + 16    
    pbWait(1)
  end
  ow.dispose
  bg.dispose
  vs.dispose
  vss.dispose
  name.dispose
  names.dispose
  trainer.dispose
  shadow.dispose
  light.dispose
  viewport.color=Color.new(0,0,0,255)
  return true
end
#-------------------------------------------------------------------------------
# Special Pokemon VS animation
#-------------------------------------------------------------------------------
class PokeBattle_Scene
  # called within the scene to update animation
  def ebSpecialSpecies_update
    return if !@vsFp
    for j in 0...3
      if @vsFp["ec#{j}"].zoom_x <= 0
        @vsFp["ec#{j}"].zoom_x = 2
        @vsFp["ec#{j}"].zoom_y = 2
        @vsFp["ec#{j}"].opacity = 255
      end
      @vsFp["ec#{j}"].opacity -=  3
      @vsFp["ec#{j}"].zoom_x -= 0.02
      @vsFp["ec#{j}"].zoom_y -= 0.02
    end
    @vsFp["poke1"].src_rect.height += 40 if @vsFp["poke1"].src_rect.height < 640
    @vsFp["poke1"].opacity -= 2*@vsFp["poke1"].toggle
    @vsFp["poke1"].toggle *= -1 if @vsFp["poke1"].opacity <= 0 || @vsFp["poke1"].opacity >= 255
    @vsFp["bg"].angle += 1 if $PokemonSystem.screensize < 2
  end
  # called within the scene to initialize and start the animation
  def ebSpecialSpecies_start(viewport)
    species = $wildSpecies
    viewport.color = Color.new(255,255,255,0)
  
    @vsFp = {}
    # graphics for bars covering the viewport
    @vsFp["bar1"] = Sprite.new(viewport)
    @vsFp["bar1"].drawRect(viewport.rect.width,viewport.rect.height/2,Color.new(0,0,0))
    @vsFp["bar1"].z = 999
    @vsFp["bar2"] = Sprite.new(viewport)
    @vsFp["bar2"].drawRect(viewport.rect.width,viewport.rect.height/2 + 2,Color.new(0,0,0))
    @vsFp["bar2"].oy = @vsFp["bar2"].bitmap.height
    @vsFp["bar2"].y = viewport.rect.height + 2
    @vsFp["bar2"].z = 999
    # background graphic
    @vsFp["bg"] = Sprite.new(viewport)
    str = "Graphics/Transitions/speciesBg#{species}"
    str = "Graphics/Transitions/speciesBg" if !pbResolveBitmap(str)
    @vsFp["bg"].bitmap = pbBitmap(str)
    @vsFp["bg"].ox = @vsFp["bg"].src_rect.width/2
    @vsFp["bg"].oy = @vsFp["bg"].src_rect.height/2
    @vsFp["bg"].x = viewport.rect.width/2
    @vsFp["bg"].y = viewport.rect.height/2
    # "electricity" effect that scrolls horizontally behind the Pokemon
    @vsFp["streak"] = ScrollingSprite.new(viewport)
    @vsFp["streak"].setBitmap("Graphics/Transitions/vsLight3")
    @vsFp["streak"].x = viewport.rect.width
    @vsFp["streak"].y = viewport.rect.height/2
    @vsFp["streak"].speed = 64
    @vsFp["streak"].oy = @vsFp["streak"].bitmap.height/2
    # initial particles
    for j in 0...24
      n = ["B","C"][rand(2)]
      @vsFp["p#{j}"] = Sprite.new(viewport)
      str = "Graphics/Transitions/speciesEff#{n}#{species}"
      str = "Graphics/Transitions/speciesEff#{n}" if !pbResolveBitmap(str)
      @vsFp["p#{j}"].bitmap = pbBitmap(str)
      @vsFp["p#{j}"].ox = @vsFp["p#{j}"].bitmap.width/2
      @vsFp["p#{j}"].oy = @vsFp["p#{j}"].bitmap.height/2
      @vsFp["p#{j}"].x = viewport.rect.width + 48
      y = viewport.rect.height*0.5*0.72 + rand(0.28*viewport.rect.height)
      @vsFp["p#{j}"].y = y
      @vsFp["p#{j}"].speed = rand(4) + 1
      @vsFp["p#{j}"].z = 1 if rand(2)==0
    end
    # main Pokemon graphic
    @vsFp["poke1"] = Sprite.new(viewport)
    @vsFp["poke1"].bitmap = pbBitmap("Graphics/Transitions/species#{species}")
    @vsFp["poke1"].ox = @vsFp["poke1"].bitmap.width/2
    @vsFp["poke1"].oy = @vsFp["poke1"].bitmap.height*0.25
    @vsFp["poke1"].x = viewport.rect.width/2
    @vsFp["poke1"].y = viewport.rect.height/2
    @vsFp["poke1"].glow(Color.new(101,136,194),35,false)
    @vsFp["poke1"].src_rect.height = 0
    @vsFp["poke1"].toggle = -1
    @vsFp["poke2"] = Sprite.new(viewport)
    @vsFp["poke2"].bitmap = pbBitmap("Graphics/Transitions/species#{species}")
    @vsFp["poke2"].ox = @vsFp["poke2"].bitmap.width/2
    @vsFp["poke2"].oy = @vsFp["poke2"].bitmap.height*0.25
    @vsFp["poke2"].x = viewport.rect.width
    @vsFp["poke2"].y = viewport.rect.height/2
    @vsFp["poke2"].opacity = 0
    # ring particles which zoom towards the center of viewport
    for j in 0...3
      @vsFp["ec#{j}"] = Sprite.new(viewport)
      str = "Graphics/Transitions/speciesEffA#{species}"
      str = "Graphics/Transitions/speciesEffA" if !pbResolveBitmap(str)
      @vsFp["ec#{j}"].bitmap = pbBitmap(str)
      @vsFp["ec#{j}"].ox = @vsFp["ec#{j}"].bitmap.width/2
      @vsFp["ec#{j}"].oy = @vsFp["ec#{j}"].bitmap.height/2
      @vsFp["ec#{j}"].x = viewport.rect.width/2
      @vsFp["ec#{j}"].y = viewport.rect.height/2
      @vsFp["ec#{j}"].zoom_x = 2
      @vsFp["ec#{j}"].zoom_y = 2
      @vsFp["ec#{j}"].opacity = 255
    end
    # starts the animation
    for i in 0...64
      @vsFp["streak"].x -= 64 if @vsFp["streak"].x > 0
      @vsFp["streak"].update if @vsFp["streak"].x <= 0
      @vsFp["streak"].opacity -= 16 if i >= 48
      @vsFp["bar1"].zoom_y -= 0.02 if @vsFp["bar1"].zoom_y > 0.72
      @vsFp["bar2"].zoom_y -= 0.02 if @vsFp["bar2"].zoom_y > 0.72
      @vsFp["poke2"].opacity += 16
      @vsFp["poke2"].x -= (@vsFp["poke2"].x - viewport.rect.width/2)*0.1
      for j in 0...3
        next if j > i/50
        if @vsFp["ec#{j}"].zoom_x <= 0
          @vsFp["ec#{j}"].zoom_x = 2
          @vsFp["ec#{j}"].zoom_y = 2
          @vsFp["ec#{j}"].opacity = 255
        end
        @vsFp["ec#{j}"].opacity -=  3
        @vsFp["ec#{j}"].zoom_x -= 0.02
        @vsFp["ec#{j}"].zoom_y -= 0.02
      end
      for j in 0...24
        next if j > i/2 
        @vsFp["p#{j}"].x -= 32*@vsFp["p#{j}"].speed
      end
      @vsFp["bg"].angle += 1 if $PokemonSystem.screensize < 2
      Graphics.update
    end
    # changes focus to Pokemon graphic
    for i in 0...8
      @vsFp["bar1"].zoom_y -= 0.72/8
      @vsFp["bar2"].zoom_y -= 0.72/8
      @vsFp["poke1"].y -= 8
      @vsFp["poke2"].y -= 8
      if i >= 4
        viewport.color.alpha += 64
      end
      ebSpecialSpecies_update
      Graphics.update
    end
    # flash and impact of screen
    @vsFp["poke1"].oy = @vsFp["poke1"].bitmap.height/2
    @vsFp["poke1"].y = viewport.rect.height/2
    @vsFp["poke2"].oy = @vsFp["poke2"].bitmap.height/2
    @vsFp["poke2"].y = viewport.rect.height/2
    @vsFp["impact"] = Sprite.new(viewport)
    @vsFp["impact"].bitmap = pbBitmap("Graphics/Pictures/impact")
    @vsFp["impact"].ox = @vsFp["impact"].bitmap.width/2
    @vsFp["impact"].oy = @vsFp["impact"].bitmap.height/2
    @vsFp["impact"].x = viewport.rect.width/2
    @vsFp["impact"].y = viewport.rect.height/2
    @vsFp["impact"].z = 999
    @vsFp["impact"].opacity = 0
    pbPlayCry(species)
    k = -1
    # fades flash
    for i in 0...32
      viewport.color.alpha -= 16 if viewport.color.alpha > 0
      @vsFp["bg"].y += k*4 if i < 16
      @vsFp["poke2"].y += k*4 if i < 16
      k *= -1 if i%2==0
      @vsFp["impact"].opacity += (i < 24) ? 64 : -32
      @vsFp["impact"].angle += 180 if i%4 == 0
      @vsFp["impact"].mirror = !@vsFp["impact"].mirror if i%4 == 2
      ebSpecialSpecies_update
      Graphics.update
    end
  end
  # called to end the sequence and dispose of sprites
  def ebSpecialSpecies_end
    bmp = Graphics.snap_to_bitmap
    view = @vsFp["poke1"].viewport
    pbDisposeSpriteHash(@vsFp)
    @vsFp["ov1"] = Sprite.new(view)
    @vsFp["ov1"].bitmap = bmp
    @vsFp["ov1"].ox = bmp.width/2
    @vsFp["ov1"].oy = bmp.height/2
    @vsFp["ov1"].x = viewport.rect.width/2
    @vsFp["ov1"].y = viewport.rect.height/2
    @vsFp["ov2"] = Sprite.new(view)
    @vsFp["ov2"].bitmap = bmp
    @vsFp["ov2"].blur_sprite(3)
    @vsFp["ov2"].ox = bmp.width/2
    @vsFp["ov2"].oy = bmp.height/2
    @vsFp["ov2"].x = viewport.rect.width/2
    @vsFp["ov2"].y = viewport.rect.height/2
    @vsFp["ov2"].opacity = 0
    # final zooming transition
    for i in 0...32
      @vsFp["ov1"].zoom_x += 0.02
      @vsFp["ov1"].zoom_y += 0.02
      @vsFp["ov2"].zoom_x += 0.02
      @vsFp["ov2"].zoom_y += 0.02
      @vsFp["ov2"].opacity += 12
      if i >= 16
        @vsFp["ov2"].tone.red += 16
        @vsFp["ov2"].tone.green += 16
        @vsFp["ov2"].tone.blue += 16
      end
      Graphics.update
    end
    8.times do; Graphics.update; end
    @vsFp["ov1"].opacity = 0
    $specialSpecies = false
    @sprites["battlebox1"].appear
    for i in 0...16
      @vsFp["ov2"].opacity -= 16
      if i < 10
        if EBUISTYLE==2
          @sprites["battlebox1"].show
        elsif EBUISTYLE==0
          @sprites["battlebox1"].update
        else
          @sprites["battlebox1"].x+=26
        end
      end
      animateBattleSprites
      Graphics.update
    end
    pbDisposeSpriteHash(@vsFp)
  end

end
#-------------------------------------------------------------------------------
#  The main class responsible for loading up the S/M styled transitions
#-------------------------------------------------------------------------------
class SunMoonBattleTransitions
  attr_accessor :speed
  # creates the transition handler
  def initialize(*args)
    echo @variant
    $smAnim=false
    return if args.length < 4
    # sets up main viewports
    @viewport = args[0]
    @viewport.color = Color.new(255,255,255,0)
    @msgview = args[1]
    # sets up variables
    @disposed = false
    @sentout = false
    @scene = args[2]
    @trainerid = args[3]
    @speed = 1
    @sprites = {}
    # retreives additional parameters
    self.getParameters(@trainerid)
    # plays the animation before the main sequence
    @evilteam ? self.evilTeam : self.rainbowIntro
    @teamskull = @variant == "skull"
    self.teamSkull if @teamskull
    # initializes the backdrop
    

    if $onlinebattle
      @evilteam=false
      @sprites["background"] = SunMoonOnlineBackground.new(@viewport,@trainerid,@evilteam)
      @oldVariant = @variant
      @variant = "ultra"
    else
      case @variant
      when "special"
        @sprites["background"] = SunMoonSpecialBackground.new(@viewport,@trainerid,@evilteam)
      when "elite"
        @sprites["background"] = SunMoonEliteBackground.new(@viewport,@trainerid,@evilteam)
      when "crazy"
        @sprites["background"] = SunMoonCrazyBackground.new(@viewport,@trainerid,@evilteam)
      when "ultra"
        @sprites["background"] = SunMoonUltraBackground.new(@viewport,@trainerid,@evilteam)
      when "digital"
        @sprites["background"] = SunMoonDigitalBackground.new(@viewport,@trainerid,@evilteam)
      when "plasma"
        @sprites["background"] = SunMoonPlasmaBackground.new(@viewport,@trainerid,@evilteam)
      when "cardinal"
        echoln "starting cardinal sequence"
        @sprites["background"] = SunMoonCardinalBackground.new(@viewport,@trainerid,@evilteam)
      when "fury"
        echoln "starting fury sequence"
        @teamskull = true
        self.teamSkull if @teamskull
        @sprites["background"] = SunMoonFuryBackground.new(@viewport,@trainerid,@evilteam)
      when "vip"
        @sprites["background"] = SunMoonVipBackground.new(@viewport,@trainerid,@evilteam)
      else
        @sprites["background"] = SunMoonDefaultBackground.new(@viewport,@trainerid,@evilteam,@teamskull)
      end
    end

    @sprites["background"].speed = 24
    # trainer shadow
    @sprites["shade"] = Sprite.new(@viewport)
    @sprites["shade"].z = 250
    # trainer glow (left)
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].y = @viewport.rect.height
    @sprites["glow"].z = 250
    # trainer glow (right)
    @sprites["glow2"] = Sprite.new(@viewport)
    @sprites["glow2"].z = 250
    # trainer graphic
    @sprites["trainer"] = Sprite.new(@viewport)
    @sprites["trainer"].z = 350

    if @variant == "fury" || @variant == "fdg"
      @sprites["trainer"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height*1.5)
      
      @sprites["trainer"].ox = @sprites["trainer"].bitmap.width/2
      @sprites["trainer"].oy = @sprites["trainer"].bitmap.height/2.5
      @sprites["trainer"].x = Graphics.width/2#@sprites["trainer"].ox if @variant != "plasma" && @variant != "cardinal"
      @sprites["trainer"].y = Graphics.height/2#@sprites["trainer"].oy
    else
      @sprites["trainer"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
      
      @sprites["trainer"].ox = @sprites["trainer"].bitmap.width/2
      @sprites["trainer"].oy = @sprites["trainer"].bitmap.height/2
      @sprites["trainer"].x = @sprites["trainer"].ox if @variant != "plasma" && @variant != "cardinal"
      @sprites["trainer"].y = @sprites["trainer"].oy
    end

    @sprites["trainer"].tone = Tone.new(255,255,255)
    @sprites["trainer"].zoom_x = 1.32 if @variant != "plasma" && @variant != "cardinal" 
    @sprites["trainer"].zoom_y = 1.32 if @variant != "plasma" && @variant != "cardinal"
    #@sprites["trainer"].zoom_x = 0.66 if @variant == "fury" 
    #@sprites["trainer"].zoom_y = 0.66 if @variant == "fury" 
    @sprites["trainer"].opacity = 0
    # sets a bitmap for the trainer
    if $onlinebattle
      if pbResolveBitmap(sprintf("Graphics/Transitions/smTrainer%d",@trainerid)) != nil
        bmp = pbBitmap(sprintf("Graphics/Transitions/smTrainer%d",@trainerid))
      elsif pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",@trainerid)) != nil
        bmp = pbBitmap(sprintf("Graphics/Transitions/smSpecial%d",@trainerid))
      elsif pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",@oldVariant,@trainerid)) != nil
        bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",@oldVariant,@trainerid))
      end
    else
      bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",@variant,@trainerid))
    end
    ox = (@sprites["trainer"].bitmap.width - bmp.width)/2
    oy = (@sprites["trainer"].bitmap.height - bmp.height)/2
    @sprites["trainer"].bitmap.blt(ox,oy,bmp,Rect.new(0,0,bmp.width,bmp.height))
    bmp = @sprites["trainer"].bitmap.clone
    # colours the shadow
    @sprites["shade"].bitmap = bmp.clone
    @sprites["shade"].color = Color.new(10,169,245,204)
    @sprites["shade"].color = Color.new(150,115,255,204) if @variant == "elite"
    @sprites["shade"].color = Color.new(115,216,145,204) if @variant == "digital"
    @sprites["shade"].opacity = 0
    @sprites["shade"].visible = false if @variant == "crazy" || @variant == "plasma" ||@variant == "cardinal" || @variant == "fury" 
    # creates and colours an outer glow for the trainer
    c = Color.new(0,0,0)
    c = Color.new(255,255,255) if @variant == "crazy" || @variant == "digital" || @variant == "plasma" ||@variant == "cardinal" || @variant == "fury" 
    if @variant == "fury"
      @sprites["glow"].bitmap = bmp.clone
      @sprites["glow"].glow(c,35,false)
      @sprites["glow"].src_rect.set(0,@viewport.rect.height+36,bmp.width/2,0)
      @sprites["glow2"].bitmap = @sprites["glow"].bitmap.clone
      @sprites["glow2"].src_rect.set(bmp.width/2,36,bmp.width/2,0)
    else
      @sprites["glow"].bitmap = bmp.clone
      @sprites["glow"].glow(c,35,false)
      @sprites["glow"].src_rect.set(0,@viewport.rect.height,@viewport.rect.width/2,0)
      @sprites["glow2"].bitmap = @sprites["glow"].bitmap.clone
      @sprites["glow2"].src_rect.set(@viewport.rect.width/2,0,@viewport.rect.width/2,0)
    end
    # creates the fade-out ball graphic overlay
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].z = 999
    @sprites["overlay"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
    @sprites["overlay"].opacity = 0
  end
  

  def trainerPreview
    pvvp = Viewport.new(0,0,Graphics.width,Graphics.height)
    pvvp.z = @viewport.z + 1

    @sprites["trainerpv"] = Sprite.new(pvvp)
    @sprites["trainerpv"].bitmap = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",@variant,@trainerid))
    @sprites["trainerpv"].opacity = 0
    @sprites["trainerpv"].zoom_x = 2
    @sprites["trainerpv"].zoom_y = 2
    @sprites["trainerpv"].oy = @sprites["trainerpv"].bitmap.height
    @sprites["trainerpv"].ox = @sprites["trainerpv"].bitmap.width/2
    @sprites["trainerpv"].y = Graphics.height
    @sprites["trainerpv"].x = 0
    @sprites["trainerpv"].tone = Tone.new(0,0,0,255)
    i = 0
    60.times do
      Graphics.update
      Input.update
      @sprites["trainerpv"].opacity += 185/10 if i < 10
      @sprites["trainerpv"].x+=1
      @sprites["trainerpv"].opacity -= 185/10 if i >= 50
      i+=1
    end

    @sprites["trainerpv"].oy = @sprites["trainerpv"].bitmap.height/3
    @sprites["trainerpv"].y = Graphics.height
    @sprites["trainerpv"].x = Graphics.width 
    pbWait(30)
    i=0
    60.times do
      Graphics.update
      Input.update
      @sprites["trainerpv"].opacity += 185/10 if i < 10
      @sprites["trainerpv"].x-=1
      @sprites["trainerpv"].opacity -= 185/10 if i >= 50
      i+=1
    end


  end

  def pokemonPreview
    pvvp = Viewport.new(0,0,Graphics.width,Graphics.height)
    pvvp.z = @viewport.z + 1

    @sprites["pokemonpv"] = Sprite.new(pvvp)
    @sprites["pokemonpv"].bitmap = pbBitmap(sprintf("Graphics/Transitions/SunMoon/fdg%d",$wildSpecies))
    @sprites["pokemonpv"].opacity = 0
    @sprites["pokemonpv"].zoom_x = 2
    @sprites["pokemonpv"].zoom_y = 2
    @sprites["pokemonpv"].oy = @sprites["pokemonpv"].bitmap.height
    @sprites["pokemonpv"].ox = @sprites["pokemonpv"].bitmap.width/2
    @sprites["pokemonpv"].y = Graphics.height
    @sprites["pokemonpv"].x = 0
    @sprites["pokemonpv"].tone = Tone.new(0,0,0,255)
    i = 0
    60.times do
      Graphics.update
      Input.update
      @sprites["pokemonpv"].opacity += 185/10 if i < 10
      @sprites["pokemonpv"].x+=1
      @sprites["pokemonpv"].opacity -= 185/10 if i >= 50
      i+=1
    end

    @sprites["pokemonpv"].oy = @sprites["pokemonpv"].bitmap.height/3
    @sprites["pokemonpv"].y = Graphics.height
    @sprites["pokemonpv"].x = Graphics.width 
    pbWait(30)
    i=0
    60.times do
      Graphics.update
      Input.update
      @sprites["pokemonpv"].opacity += 185/10 if i < 10
      @sprites["pokemonpv"].x-=1
      @sprites["pokemonpv"].opacity -= 185/10 if i >= 50
      i+=1
    end


  end

  # starts the animation
  def start
    self.trainerPreview if @variant == "fury"
    if $wildSpecies == PBSpecies::DRAGALISKFURIA
      self.pokemonPreview if $wildSpecies == PBSpecies::DRAGALISKFURIA
    end
    return if self.disposed?
    # fades in viewport
    16.times do
      @viewport.color.alpha -= 16 if @viewport.color.alpha > 0
      if @variant == "plasma" || @variant == "cardinal" 
        @sprites["trainer"].x += (@viewport.rect.width/3)/8
        self.update
      else
        @sprites["trainer"].zoom_x -= 0.02
        @sprites["trainer"].zoom_y -= 0.02
      end
      @sprites["trainer"].opacity += 32
      Graphics.update
    end
    @sprites["trainer"].zoom_x = 1
    @sprites["trainer"].zoom_y = 1
    # prepares party ball preview
    if EBUISTYLE == 2
      #@scene.commandWindow.drawLineup
      #@scene.commandWindow.lineupY(-32)
    end
    # fades in trainer
    for i in 0...16
      #@scene.commandWindow.showArrows if i < 10 if EBUISTYLE == 2
      @sprites["trainer"].tone.red -= 16
      @sprites["trainer"].tone.green -= 16
      @sprites["trainer"].tone.blue -= 16
      @sprites["background"].reduceAlpha(16)
      self.update
      Graphics.update
    end
    # wait
    16.times do
      self.update
      Graphics.update
    end
    # flashes trainer
    for i in 0...10
      @sprites["trainer"].tone.red -= 64*(i < 6 ? -1 : 1)
      @sprites["trainer"].tone.green -= 64*(i < 6 ? -1 : 1)
      @sprites["trainer"].tone.blue -= 64*(i < 6 ? -1 : 1)
      @sprites["background"].speed = 4 if i == 4
      self.update
      Graphics.update
    end
    @sprites["trainer"].tone = Tone.new(0,0,0)
    # wraps glow around trainer
    16.times do
      @sprites["glow"].src_rect.height += @viewport.rect.height/16
      @sprites["glow"].src_rect.y -= @viewport.rect.height/16
      @sprites["glow"].y -= @viewport.rect.height/16
      @sprites["glow2"].src_rect.height += @viewport.rect.height/16
      self.update
      Graphics.update
    end
    # flashes viewport
    #@viewport.color = Color.new(255,255,255,0)
    8.times do
      if @variant != "plasma" && @variant != "cardinal" 
        @sprites["glow"].tone.red += 32
        @sprites["glow"].tone.green += 32
        @sprites["glow"].tone.blue += 32
        @sprites["glow2"].tone.red += 32
        @sprites["glow2"].tone.green += 32
        @sprites["glow2"].tone.blue += 32
      end
      self.update
      Graphics.update
    end
    # loads additional background elements
    @sprites["background"].show
    if @variant == "plasma" ||@variant == "cardinal" 
      @sprites["glow"].color = Color.new(148,90,40)
      @sprites["glow2"].color = Color.new(148,90,40)
    end
    # flashes trainer
    for i in 0...4
      @viewport.color.alpha += 32
      @sprites["trainer"].tone.red += 64
      @sprites["trainer"].tone.green += 64
      @sprites["trainer"].tone.blue += 64
      @sprites["trainer"].update
      self.update
      Graphics.update
    end
    for j in 0...4
      @viewport.color.alpha += 32
      self.update
      Graphics.update
    end
    # wait
    24.times do
      self.update
      Graphics.update
    end
    @sprites["background"].displayLogo if @variant == "cardinal"
    # returns everything to normal
    for i in 0...8
      @viewport.color.alpha -= 32
      @sprites["trainer"].tone.red -= 32 if @sprites["trainer"].tone.red > 0
      @sprites["trainer"].tone.green -= 32 if @sprites["trainer"].tone.green > 0
      @sprites["trainer"].tone.blue -= 32 if @sprites["trainer"].tone.blue > 0
      @sprites["trainer"].update
      @sprites["shade"].opacity += 32
      @sprites["shade"].x -= 4
      self.update
      Graphics.update
    end
    #@sprites["trainer"].tone = Tone.new(0,0,0)
  end
  # main update call
  def update
    return if self.disposed?
    @sprites["background"].update
    @sprites["glow"].x = @sprites["trainer"].x - @sprites["trainer"].bitmap.width/2
    @sprites["glow2"].x = @sprites["trainer"].x
  end
  # called before Trainer sends out their Pokemon
  def finish
    return if self.disposed?
    # final transition
    viewport = @viewport
    zoom = 4.0
    echoln "Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}  NEWTRANSITION 1"
    obmp = pbBitmap("Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}#{$ISINTOURNAMENT ? "Vip" : ""}")
    @sprites["background"].speed = 24
    echo "\n I got here SOMEHOW \n"
    # zooms in ball graphic overlay
    for i in 0..20
      #@scene.commandWindow.hideArrows if i < 10 if EBUISTYLE == 2
      @sprites["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @sprites["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @sprites["overlay"].opacity += 64
      zoom -= 4.0/20
      self.update
      Graphics.update
    end
    # resets party preview position
    #@scene.commandWindow.lineupY(+32) if EBUISTYLE == 2
    # disposes of current sprites
    self.dispose
    # re-loads overlay
    @sprites["overlay"] = Sprite.new(@msgview)
    @sprites["overlay"].z = 9999999
    @sprites["overlay"].bitmap = Bitmap.new(@msgview.rect.width,@msgview.rect.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,@msgview.rect.height,Color.new(0,0,0))
  end
  # called during Trainer sendout
  def sendout
    return if @sentout
    $smAnim = false
    # transitions from VS sequence to the battle scene
    zoom = 0
    obmp = pbBitmap("Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}#{$ISINTOURNAMENT ? "Vip" : ""}")
    
    # zooms out ball graphic overlay
    21.times do
      @sprites["overlay"].bitmap.clear
      ox = (1 - zoom)*@msgview.rect.width*0.5
      oy = (1 - zoom)*@msgview.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @sprites["overlay"].bitmap.fill_rect(0,0,width,@msgview.rect.height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(@msgview.rect.width-width,0,width,@msgview.rect.height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.fill_rect(0,@msgview.rect.height-height,@msgview.rect.width,height,Color.new(0,0,0))
      @sprites["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,obmp.rect)
      @sprites["overlay"].opacity -= 12.8
      zoom += 4.0/20
      @scene.wait(1,true)
    end
    # disposes of final graphic
    @sprites["overlay"].dispose
    @sentout = true
  end
  # disposes all sprites
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # compatibility for pbFadeOutAndHide
  def color; end
  def color=(val); end
  # plays the little rainbow sequence before the animation (can be standalone)
  def rainbowIntro(viewport=nil)
    @viewport = viewport if !@viewport && !viewport.nil?
    @sprites = {} if !@sprites
    # takes screenshot
    bmp = Graphics.snap_to_bitmap
    # creates non-blurred overlay
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = bmp
    @sprites["bg1"].ox = bmp.width/2
    @sprites["bg1"].oy = bmp.height/2
    @sprites["bg1"].x = @viewport.rect.width/2
    @sprites["bg1"].y = @viewport.rect.height/2
    # creates blurred overlay
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = bmp
    @sprites["bg2"].blur_sprite(3)
    @sprites["bg2"].ox = bmp.width/2
    @sprites["bg2"].oy = bmp.height/2
    @sprites["bg2"].x = @viewport.rect.width/2
    @sprites["bg2"].y = @viewport.rect.height/2
    @sprites["bg2"].opacity = 0
    # creates rainbow rings
    for i in 1..2
      z = [0.35,0.1]
      @sprites["glow#{i}"] = Sprite.new(@viewport)
      @sprites["glow#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Common/glow")
      @sprites["glow#{i}"].ox = @sprites["glow#{i}"].bitmap.width/2
      @sprites["glow#{i}"].oy = @sprites["glow#{i}"].bitmap.height/2
      @sprites["glow#{i}"].x = @viewport.rect.width/2
      @sprites["glow#{i}"].y = @viewport.rect.height/2
      @sprites["glow#{i}"].zoom_x = z[i-1]
      @sprites["glow#{i}"].zoom_y = z[i-1]
      @sprites["glow#{i}"].opacity = 0
    end
    # main animation
    for i in 0...32
      # zooms in the two screenshots
      @sprites["bg1"].zoom_x += 0.02
      @sprites["bg1"].zoom_y += 0.02
      @sprites["bg2"].zoom_x += 0.02
      @sprites["bg2"].zoom_y += 0.02
      # fades in the blurry screenshot
      @sprites["bg2"].opacity += 12
      # fades to white
      if i >= 16
        @sprites["bg2"].tone.red += 16
        @sprites["bg2"].tone.green += 16
        @sprites["bg2"].tone.blue += 16
      end
      # zooms in rainbow rings
      if i >= 28
        @sprites["glow1"].opacity += 64
        @sprites["glow1"].zoom_x += 0.02
        @sprites["glow1"].zoom_y += 0.02
      end
      Graphics.update
    end
    # second part of animation
    for i in 0...52
      # zooms in rainbow rings
      @sprites["glow1"].zoom_x += 0.02
      @sprites["glow1"].zoom_y += 0.02
      if i >= 8
        @sprites["glow2"].opacity += 64
        @sprites["glow2"].zoom_x += 0.02
        @sprites["glow2"].zoom_y += 0.02
      end
      # fades viewport to white
      if i >= 36
        @viewport.color.alpha += 16
      end
      Graphics.update
    end
    # disposes of the elements
    pbDisposeSpriteHash(@sprites)
  end
  # displays the animation for the evil team logo (can be standalone)
  def evilTeam(viewport=nil)
    @viewport = viewport if !@viewport && !viewport.nil?
    @sprites = {} if !@sprites
    @viewport.color = Color.new(0,0,0,0)
    # fades viewport to black
    8.times do
      @viewport.color.alpha += 32
      pbWait(1)
    end
    # creates background graphic
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/background")
    @sprites["bg"].color = Color.new(0,0,0)
    # creates background swirl
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/swirl")
    @sprites["bg2"].ox = @sprites["bg2"].bitmap.width/2
    @sprites["bg2"].oy = @sprites["bg2"].bitmap.height/2
    @sprites["bg2"].x = @viewport.rect.width/2
    @sprites["bg2"].y = @viewport.rect.height/2
    @sprites["bg2"].visible = false
    # sets up all particles
    speed = []
    for j in 0...16
      @sprites["e1_#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ray0")
      @sprites["e1_#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      w = bmp.width/(1 + rand(3))
      @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["e1_#{j}"].oy = @sprites["e1_#{j}"].bitmap.height/2
      @sprites["e1_#{j}"].angle = rand(360)
      @sprites["e1_#{j}"].opacity = 0
      @sprites["e1_#{j}"].x = @viewport.rect.width/2
      @sprites["e1_#{j}"].y = @viewport.rect.height/2
      speed.push(4 + rand(5))
    end
    # creates logo
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/logo0")
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2
    @sprites["logo"].y = @viewport.rect.height/2
    @sprites["logo"].memorize_bitmap
    @sprites["logo"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/logo1")
    @sprites["logo"].zoom_x = 2
    @sprites["logo"].zoom_y = 2
    @sprites["logo"].z = 50
    # creates flash ring graphic
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ring0")
    @sprites["ring"].ox = @sprites["ring"].bitmap.width/2
    @sprites["ring"].oy = @sprites["ring"].bitmap.height/2
    @sprites["ring"].x = @viewport.rect.width/2
    @sprites["ring"].y = @viewport.rect.height/2
    @sprites["ring"].zoom_x = 0
    @sprites["ring"].zoom_y = 0 
    @sprites["ring"].z = 100
    # creates secondary particles
    for j in 0...32
      @sprites["e2_#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ray1")
      @sprites["e2_#{j}"].bitmap = bmp
      @sprites["e2_#{j}"].oy = @sprites["e2_#{j}"].bitmap.height/2
      @sprites["e2_#{j}"].angle = rand(360)
      @sprites["e2_#{j}"].opacity = 0
      @sprites["e2_#{j}"].x = @viewport.rect.width/2
      @sprites["e2_#{j}"].y = @viewport.rect.height/2
      @sprites["e2_#{j}"].z = 100
    end
    # creates secondary flash ring
    @sprites["ring2"] = Sprite.new(@viewport)
    @sprites["ring2"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ring1")
    @sprites["ring2"].ox = @sprites["ring2"].bitmap.width/2
    @sprites["ring2"].oy = @sprites["ring2"].bitmap.height/2
    @sprites["ring2"].x = @viewport.rect.width/2
    @sprites["ring2"].y = @viewport.rect.height/2
    @sprites["ring2"].visible = false
    @sprites["ring2"].zoom_x = 0
    @sprites["ring2"].zoom_y = 0 
    @sprites["ring2"].z = 100
    # first phase of animation
    for i in 0...32
      @viewport.color.alpha -= 8 if @viewport.color.alpha > 0
      @sprites["logo"].zoom_x -= 1/32.0
      @sprites["logo"].zoom_y -= 1/32.0
      for j in 0...16
        next if j > i/4
        if @sprites["e1_#{j}"].ox < -(@viewport.rect.width/2)
          speed[j] = 4 + rand(5)
          @sprites["e1_#{j}"].opacity = 0
          @sprites["e1_#{j}"].ox = 0
          @sprites["e1_#{j}"].angle = rand(360)
          bmp = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ray1")
          @sprites["e1_#{j}"].bitmap.clear
          w = bmp.width/(1 + rand(3))
          @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
        end
        @sprites["e1_#{j}"].opacity += speed[j]
        @sprites["e1_#{j}"].ox -=  speed[j]
      end
      pbWait(1)
    end
    # configures logo graphic
    @sprites["logo"].color = Color.new(255,255,255)
    @sprites["logo"].restore_bitmap
    @sprites["ring2"].visible = true
    @sprites["bg2"].visible = true
    @viewport.color = Color.new(255,255,255)
    # final animation of background and particles
    for i in 0...144
      if i >= 128
        @viewport.color.alpha += 16
      else
        @viewport.color.alpha -= 16 if @viewport.color.alpha > 0
      end
      @sprites["logo"].color.alpha -= 16 if @sprites["logo"].color.alpha > 0
      @sprites["bg"].color.alpha -= 8 if @sprites["bg"].color.alpha > 0
      for j in 0...16
        if @sprites["e1_#{j}"].ox < -(@viewport.rect.width/2)
          speed[j] = 4 + rand(5)
          @sprites["e1_#{j}"].opacity = 0
          @sprites["e1_#{j}"].ox = 0
          @sprites["e1_#{j}"].angle = rand(360)
          bmp = pbBitmap("Graphics/Transitions/SunMoon/EvilTeam/ray0")
          @sprites["e1_#{j}"].bitmap.clear
          w = bmp.width/(1 + rand(3))
          @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
        end
        @sprites["e1_#{j}"].opacity += speed[j]
        @sprites["e1_#{j}"].ox -=  speed[j]
      end
      for j in 0...32
        next if j > i*2
        @sprites["e2_#{j}"].ox -= 16
        @sprites["e2_#{j}"].opacity += 16
      end
      @sprites["ring"].zoom_x += 0.1
      @sprites["ring"].zoom_y += 0.1
      @sprites["ring"].opacity -= 8
      @sprites["ring2"].zoom_x += 0.2 if @sprites["ring2"].zoom_x < 3
      @sprites["ring2"].zoom_y += 0.2 if @sprites["ring2"].zoom_y < 3
      @sprites["ring2"].opacity -= 16
      @sprites["bg2"].angle += 2 if $PokemonSystem.screensize < 2  
      pbWait(1)
    end
    # disposes all sprites
    pbDisposeSpriteHash(@sprites)
    # fades viewport
    8.times do
      @viewport.color.red -= 255/8.0
      @viewport.color.green -= 255/8.0
      @viewport.color.blue -= 255/8.0
      pbWait(1)
    end  
    return true
  end
  # plays Team Skull styled intro animation
  def teamSkull
    @fpIndex = 0
    @spIndex = 0
    
    pbWait(4)
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/background")
    @sprites["bg"].color = Color.new(0,0,0,92)
    
    for j in 0...20
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/smoke")
      @sprites["s#{j}"].center(true)
      @sprites["s#{j}"].opacity = 0
    end
    
    for i in 0...16
      @sprites["r#{i}"] = Sprite.new(@viewport)
      @sprites["r#{i}"].opacity = 0
    end
    
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/logo")
    @sprites["logo"].center(true)
    @sprites["logo"].z = 9999
    @sprites["logo"].zoom_x = 2
    @sprites["logo"].zoom_y = 2
    @sprites["logo"].color = Color.new(0,0,0)
    
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/shine")
    @sprites["shine"].center(true)
    @sprites["shine"].x -= 72
    @sprites["shine"].y -= 64
    @sprites["shine"].z = 99999
    @sprites["shine"].opacity = 0
    @sprites["shine"].zoom_x = 0.6
    @sprites["shine"].zoom_y = 0.4
    @sprites["shine"].angle = 30
    
    @sprites["rainbow"] = Sprite.new(@viewport)
    @sprites["rainbow"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/rainbow")
    @sprites["rainbow"].center(true)
    @sprites["rainbow"].z = 99999
    @sprites["rainbow"].opacity = 0
    
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/glow")
    @sprites["glow"].center(true)
    @sprites["glow"].opacity = 0
    @sprites["glow"].z = 9
    @sprites["glow"].zoom_x = 0.6
    @sprites["glow"].zoom_y = 0.6
    
    @sprites["burst"] = Sprite.new(@viewport)
    @sprites["burst"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/burst")
    @sprites["burst"].center(true)
    @sprites["burst"].zoom_x = 0
    @sprites["burst"].zoom_y = 0
    @sprites["burst"].opacity = 0
    @sprites["burst"].z = 999
    @sprites["burst"].color = Color.new(255,255,255,0)
    
    for j in 0...24
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/particle")
      @sprites["p#{j}"].center(true)
      @sprites["p#{j}"].center
      z = 1 - rand(81)/100.0
      @sprites["p#{j}"].zoom_x = z
      @sprites["p#{j}"].zoom_y = z
      @sprites["p#{j}"].param = 1 + rand(8)
      r = 256 + rand(65)
      cx, cy = randCircleCord(r)
      @sprites["p#{j}"].ex = @sprites["p#{j}"].x - r + cx
      @sprites["p#{j}"].ey = @sprites["p#{j}"].y - r + cy
      r = rand(33)/100.0
      @sprites["p#{j}"].x = @viewport.rect.width/2 - (@sprites["p#{j}"].ex - @viewport.rect.width/2)*r
      @sprites["p#{j}"].y = @viewport.rect.height/2 - (@viewport.rect.height/2 - @sprites["p#{j}"].ey)*r
      @sprites["p#{j}"].visible = false
    end
    
    x = [@viewport.rect.width/3,@viewport.rect.width+32,16,-32,2*@viewport.rect.width/3,@viewport.rect.width+32,0,@viewport.rect.width+64]
    y = [@viewport.rect.height+32,@viewport.rect.height+32,-32,@viewport.rect.height/2,@viewport.rect.height+64,@viewport.rect.height/2,@viewport.rect.height-64,@viewport.rect.height/2+32]
    a = [50,135,-70,10,105,165,-30,190]
    for j in 0...8
      @sprites["sl#{j}"] = Sprite.new(@viewport)
      @sprites["sl#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/paint0")
      @sprites["sl#{j}"].oy = @sprites["sl#{j}"].bitmap.height/2
      @sprites["sl#{j}"].z = j < 2 ? 999 : 99999
      @sprites["sl#{j}"].ox = -@sprites["sl#{j}"].bitmap.width
      @sprites["sl#{j}"].x = x[j]
      @sprites["sl#{j}"].y = y[j]
      @sprites["sl#{j}"].angle = a[j]
      @sprites["sl#{j}"].param = (@sprites["sl#{j}"].bitmap.width/8)
    end
    
    for j in 0...12
      @sprites["sp#{j}"] = Sprite.new(@viewport)
      @sprites["sp#{j}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Skull/splat#{rand(3)}")
      @sprites["sp#{j}"].center
      @sprites["sp#{j}"].x = rand(@viewport.rect.width)
      @sprites["sp#{j}"].y = rand(@viewport.rect.height)
      @sprites["sp#{j}"].visible = false
      z = 1 + rand(40)/100.0
      @sprites["sp#{j}"].zoom_x = z
      @sprites["sp#{j}"].zoom_y = z
      @sprites["sp#{j}"].z = 99999
    end
    
    for i in 0...32
      @viewport.color.alpha -= 16
      @sprites["logo"].zoom_x -= 1/32.0
      @sprites["logo"].zoom_y -= 1/32.0
      @sprites["logo"].color.alpha -= 8
      for j in 0...16
        next if j > @fpIndex/2
        if @sprites["r#{j}"].opacity <= 0
          bmp = pbBitmap("Graphics/Transitions/SunMoon/Skull/ray")
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center(true)
          @sprites["r#{j}"].ox = -(64 + rand(17))
          @sprites["r#{j}"].zoom_x = 1
          @sprites["r#{j}"].zoom_y = 1
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
        if @sprites["r#{j}"].ox > -128
          @sprites["r#{j}"].opacity += 8
        else
          @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
        end
      end
      if i >= 24
        @sprites["shine"].opacity += 48
        @sprites["shine"].zoom_x += 0.02
        @sprites["shine"].zoom_y += 0.02
      end
      @fpIndex += 1
      Graphics.update
    end
    @viewport.color = Color.new(0,0,0,0)
    for i in 0...128
      @sprites["shine"].opacity -= 16
      @sprites["shine"].zoom_x += 0.02
      @sprites["shine"].zoom_y += 0.02
      if i < 8
        z = (i < 4) ? 0.02 : -0.02
        @sprites["logo"].zoom_x -= z
        @sprites["logo"].zoom_y -= z
      end
      for j in 0...16
        if @sprites["r#{j}"].opacity <= 0
          bmp = pbBitmap("Graphics/Transitions/SunMoon/Skull/ray")
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center(true)
          @sprites["r#{j}"].ox = -(64 + rand(17))
          @sprites["r#{j}"].zoom_x = 1
          @sprites["r#{j}"].zoom_y = 1
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
        if @sprites["r#{j}"].ox > -128
          @sprites["r#{j}"].opacity += 8
        else
          @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
        end
      end
      for j in 0...24
        @sprites["p#{j}"].visible = true
        next if @sprites["p#{j}"].opacity <= 0
        x = (@sprites["p#{j}"].ex - @viewport.rect.width/2)/(4.0*@sprites["p#{j}"].param)
        y = (@viewport.rect.height/2 - @sprites["p#{j}"].ey)/(4.0*@sprites["p#{j}"].param)
        @sprites["p#{j}"].x -= x
        @sprites["p#{j}"].y -= y
        @sprites["p#{j}"].opacity -= @sprites["p#{j}"].param
      end
      for j in 0...20
        if @sprites["s#{j}"].opacity <= 0
          @sprites["s#{j}"].opacity = 255
          r = 160 + rand(33)
          cx, cy = randCircleCord(r)
          @sprites["s#{j}"].center(true)
          @sprites["s#{j}"].ex = @sprites["s#{j}"].x - r + cx
          @sprites["s#{j}"].ey = @sprites["s#{j}"].y - r + cy
          @sprites["s#{j}"].toggle = rand(2)==0 ? 2 : -2
          @sprites["s#{j}"].param = 2 + rand(4)
          z = 1 - rand(41)/100.0
          @sprites["s#{j}"].zoom_x = z
          @sprites["s#{j}"].zoom_y = z
        end
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].ex)*0.02
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].ey)*0.02
        @sprites["s#{j}"].opacity -= @sprites["s#{j}"].param*1.5
        @sprites["s#{j}"].angle += @sprites["s#{j}"].toggle if $PokemonSystem.screensize < 2
        @sprites["s#{j}"].zoom_x -= 0.002
        @sprites["s#{j}"].zoom_y -= 0.002
      end
      @sprites["bg"].color.alpha -= 2
      @sprites["glow"].opacity += (i < 6) ? 48 : -24
      @sprites["glow"].zoom_x += 0.05
      @sprites["glow"].zoom_y += 0.05
      @sprites["rainbow"].zoom_x += 0.01
      @sprites["rainbow"].zoom_y += 0.01
      @sprites["rainbow"].opacity += (i < 16) ? 32 : -16
      @sprites["burst"].zoom_x += 0.2
      @sprites["burst"].zoom_y += 0.2
      @sprites["burst"].color.alpha += 20
      @sprites["burst"].opacity += 16
      if i >= 72
        for j in 0...8
          next if j > @spIndex/6
          @sprites["sl#{j}"].ox += @sprites["sl#{j}"].param if @sprites["sl#{j}"].ox < 0
        end
        for j in 0...12
          next if @spIndex < 4
          next if j > (@spIndex-4)/4
          @sprites["sp#{j}"].visible = true
        end
        @spIndex += 1
      end
      @viewport.color.alpha += 16 if i >= 112
      Graphics.update
    end
    pbDisposeSpriteHash(@sprites)
  end
  # fetches secondary parameters for the animations
  def getParameters(trainerid)
    # method used to check if battling against a registered evil team member
    @evilteam = false
    for val in EVIL_TEAM_LIST
      if val.is_a?(Numeric)
        id = val
      elsif val.is_a?(Symbol)
        id = getConst(PBTrainers,val)
      end
      @evilteam = true if !id.nil? && trainerid == id
    end
    # methods used to determine special variants
    ext = ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury","vip"]
    #ext.push("trainer")
    @variant = "trainer"
    for i in 0...ext.length
      @variant = ext[i] if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext[i],trainerid))
    end
    # sets up the rest of the variables
    @obmp = pbBitmap("Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}")
  end
end
# returns true if game is supposed to load a Sun & Moon styled VS sequence
def checkIfSunMoonTransition(trainerid)
  ret = false
  for ext in ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury","vip"]
    ret = true if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext,trainerid))
  end
  $smAnim = ret
  return ret
end

def checkIfSunMoonTrainer(trainerid)
  ret = false
  for ext in ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury","vip"]
    ret = true if pbResolveBitmap(sprintf("Graphics/Transitions/sm%s%d",ext.capitalize,trainerid))
    ret = true if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext,trainerid))
  end
  $smAnim = ret
end

def checkIfNewTransition(trainerid,ignoreonline = false)
  ret = false
  return true if $onlinebattle && !ignoreonline
  echo sprintf("Graphics/Transitions/SunMoon/%s%d","cardinal",trainerid)
  for ext in ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury","vip"]
    ret = true if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext,trainerid))
  end
  return ret
end

def getNewTransitionVariant(trainerid)
  echo sprintf("Graphics/Transitions/SunMoon/%s%d","cardinal",trainerid)
  ret = nil
  for ext in ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury","vip"]
    ret = ext if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext,trainerid))
  end
  return ret
end