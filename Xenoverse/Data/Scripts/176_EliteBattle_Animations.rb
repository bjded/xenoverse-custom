#===============================================================================
#  Elite Battle system
#    by Luka S.J.
# ----------------
#  Animations Script
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
#  Core alterations to the animation player.
#  Additional functions added to help with sprite animations and their
#  positioning.
#===============================================================================
#  Vectors to give random movement to the battle "camera" during idle periods
#  You can always add more if you feel like it
RANDOM_CAMERA = [
  [-24,424,36,360,1,1],
  [162,288,26,250,1,1],
  [86,402,43,308,1,1],
  [154,278,32,212,1,1],
  [226,332,45,190,1,1],
  [66,300,40,308,1,1],
  [178,320,24,322,1.2,1],
  [122,294,20,322,0.8,1],
  [112,458,32,346,1,1],
  [72,414,30,382,1.2,1],
  [132,344,30,358,1.2,1],
  [192,342,38,328,0.8,1],
  [192,468,32,346,1,1],
]
class PokeBattle_Scene
  attr_reader :vector
  def getWeatherAnim(weather)
    # v 15.x
    # 0: No weather, 1: Rain, 2: Storm, 3: Snow, 4: Sandstorm, 5: Sunny, 6: Heavy rain, 7: Blizzard
    # v 16.x
    # 0: No weather, 1: Rain, 2: Storm, 3: Snow, 4: Blizzard, 5: Sandstorm, 6: Heavy rain, 7: Sunny
    case weather
    when PBWeather::SUNNYDAY
      return isVersion15? ? 5 : 7
    when PBWeather::RAINDANCE
      return 1
    when PBWeather::SANDSTORM
      return isVersion15? ? 4 : 5
    when PBWeather::HAIL
      return 3
    else
      return isVersion15? ? 5 : 7 if PBWeather.const_defined?(:DESOLATELAND) && weather==PBWeather::DESOLATELAND
      return 6 if PBWeather.const_defined?(:PRIMORDIALSEA) && weather==PBWeather::PRIMORDIALSEA
      return 0
    end
  end
  #=============================================================================
  #  Misc code to automize sprite animation and placement
  #=============================================================================
  def animateBattleSprites(align=false,smanim=false)
    vsSequenceSM_update if $smAnim && !smanim && !@smTrainerSequence
    @smTrainerSequence.update if @smTrainerSequence
    @newBossSequence.update if @newBossSequence
    @vector.update
    alignBattleScene
    if !$smAnim && !@safaribattle && (@animweather.nil? || @battle.weather!=@animweather) && EBUISTYLE > 0
      @sprites["weather"].type = getWeatherAnim(@battle.weather)
      @sprites["weather"].max = 36
      @sprites["weather"].ox = $game_map.display_x / 4
      @sprites["weather"].oy = $game_map.display_y / 4
      @animweather=@battle.weather
    end
    @sprites["weather"].update if @sprites["weather"] && !@sprites["weather"].disposed?
    @idleTimer+=1 if @idleTimer >= 0
    @lastMotion=nil if @idleTimer < 0
    @sprites["player"].x+=(40-@sprites["player"].x)/4 if @safaribattle && @sprites["player"] && @playerfix
    for i in 0...4
      if @sprites["pokemon#{i}"]
        if @sprites["pokemon#{i}"].loaded
          status=@battle.battlers[i].status
          case status
          when PBStatuses::SLEEP
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(3) if (@sprites["pokemon#{i}"].actualBitmap!=nil)
          when PBStatuses::PARALYSIS
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(3) if (@sprites["pokemon#{i}"].actualBitmap!=nil)
            @sprites["pokemon#{i}"].status=2
          when PBStatuses::FROZEN
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(0) if (@sprites["pokemon#{i}"].actualBitmap!=nil)
            @sprites["pokemon#{i}"].status=3
          when PBStatuses::POISON
            @sprites["pokemon#{i}"].status=1
          when PBStatuses::BURN
            @sprites["pokemon#{i}"].status=4
          else
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(4) if (@sprites["pokemon#{i}"].actualBitmap!=nil)
            @sprites["pokemon#{i}"].status=0
          end
        end
        @sprites["pokemon#{i}"].update(@vector.angle+49)
        @sprites["battlebox#{i}"].update if @sprites["battlebox#{i}"] && @sprites["pokemon#{i}"].loaded
      end
      if !@orgPos.nil? && @idleTimer > (@lastMotion.nil? ? BATTLEMOTIONTIMER*Graphics.frame_rate : BATTLEMOTIONTIMER*Graphics.frame_rate*0.5) && @vector.finished? && !@safaribattle
        @vector.inc = 0.005*(rand(4)+1)
        loop do
          n = rand(RANDOM_CAMERA.length)
          if !(n==@lastMotion)
            @lastMotion=n
            break
          end
        end
        #setVector(RANDOM_CAMERA[@lastMotion])
        #@idleTimer=0
      end
      next if !align
      base=(i%2==0) ? "playerbase" : "enemybase"
      zoom = (i%2==0) ? 2 : 1 #BACKSPRITESCALE : 1
      if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].x=@sprites["#{base}"].x
        @sprites["pokemon#{i}"].y=@sprites["#{base}"].y
        @sprites["pokemon#{i}"].zoom_x=@sprites["#{base}"].zoom_x*zoom
        @sprites["pokemon#{i}"].zoom_y=@sprites["#{base}"].zoom_y*zoom/@vector.zoom2
        @sprites["pokemon#{i}"].angle=@sprites["#{base}"].angle
        if @battle.doublebattle && i/2==0
          @sprites["pokemon#{i}"].x-=50*@sprites["pokemon#{i}"].zoom_x
        elsif @battle.doublebattle && i/2==1
          @sprites["pokemon#{i}"].x+=50*@sprites["pokemon#{i}"].zoom_x
        end
        @sprites["pokemon1"].x-=25*@sprites["pokemon1"].zoom_x if @battle.doublebattle && !USEBATTLEBASES
        @sprites["pokemon2"].x+=10*@sprites["pokemon2"].zoom_x if @battle.doublebattle && !USEBATTLEBASES
        @sprites["pokemon2"].y+=10*@sprites["pokemon2"].zoom_x if @battle.doublebattle && !USEBATTLEBASES
      end
      for t in 0...2
        n=(t==0) ? "" : "2"
        if @sprites["trainer#{n}"]
          @sprites["trainer#{n}"].x=@sprites["enemybase"].x
          @sprites["trainer#{n}"].y=@sprites["enemybase"].y
          @sprites["trainer#{n}"].angle=@sprites["enemybase"].angle
          @sprites["trainer#{n}"].zoom_x=@sprites["enemybase"].zoom_x
          @sprites["trainer#{n}"].zoom_y=@sprites["enemybase"].zoom_y/@vector.zoom2
        end
      end
    end
  end

  def moveEntireScene(x=0,y=0,lock=true,bypass=false,except=nil)
    unless bypass
      return if DISABLESCENEMOTION
      return if EBUISTYLE==0 && defined?(SCREENDUALHEIGHT)
    end
    for i in 0...4
      next if !i.nil? && i == except
      @sprites["pokemon#{i}"].x+=x if @sprites["pokemon#{i}"]
      @sprites["pokemon#{i}"].y+=y if @sprites["pokemon#{i}"]
    end
    @vector.x+=x
    @vector.y+=y
    return if !lock
    return if @orgPos.nil?
    @orgPos[0]+=x
    @orgPos[1]+=y
  end
  
  def moveUpperRight(cw=nil)
    if !DISABLESCENEMOTION
      @vector.lock
      @vector.inc=0.2
      @vector.add("x",40)
      @vector.add("y",-20)
      @vector.add("scale",-30)
      @vector.add("angle",-0)
      @vector.add("zoom2",-0.1)
      if !@orgPos.nil?
        @orgPos[0]+=40
        @orgPos[1]+=-20
        @orgPos[3]+=-30
        @orgPos[2]+=-0
      end
    end
    10.times do
      cw.show if !cw.nil?
      wait(1,true)
    end
  end
  
  def moveLowerLeft(cw=nil)
    if !DISABLESCENEMOTION
      @vector.lock
      @vector.inc=0.2
      @vector.add("x",-40)
      @vector.add("y",20)
      @vector.add("scale",30)
      @vector.add("angle",0)
      @vector.add("zoom2",0.1)
      if !@orgPos.nil?
        @orgPos[0]+=-40
        @orgPos[1]+=20
        @orgPos[3]+=30
        @orgPos[2]+=0
      end
    end
    10.times do
      cw.hide if !cw.nil?
      wait(1,true)
    end
  end
  
  def moveRight(cw=nil)
    if !DISABLESCENEMOTION
      @vector.lock
      @vector.inc=0.2
      @vector.add("x",80)
      if !@orgPos.nil?
        @orgPos[0]+=80
      end
    end
    10.times do
      cw.show if !cw.nil?
      wait(1,true)
    end
  end
  
  def moveLeft(cw=nil)
    if !DISABLESCENEMOTION
      @vector.lock
      @vector.inc=0.2
      @vector.add("x",-80)
      if !@orgPos.nil?
        @orgPos[0]+=-80
      end
    end
    10.times do
      cw.hide if !cw.nil?
      wait(1,true)
    end
  end
  
  def wait(frames,align=false)
    frames.times do
      animateBattleSprites(align,$smAnim)
      Graphics.update if !$smAnim
    end
  end
  
  def setVector(*args)
    return if DISABLESCENEMOTION
    if args[0].is_a?(Array)
      x,y,angle,scale,zoom1,zoom2 = args[0]
    else
      x,y,angle,scale,zoom1,zoom2 = args
    end
    vector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @vector.set(x+@orgPos[0]-vector[0],y+@orgPos[1]-vector[1],
                angle+@orgPos[2]-vector[2],scale+@orgPos[3]-vector[3],
                zoom1+@orgPos[4]-vector[4],zoom2)
  end
  
  def alignBattleScene
    vector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @sprites["battlebg"].update
    @sprites["enemybase"].x=(@vector.x2).to_i
    @sprites["enemybase"].y=(@vector.y2).to_i
    @sprites["enemybase"].zoom_x=(@vector.zoom1)
    @sprites["enemybase"].zoom_y=(@vector.zoom1)*(@vector.zoom2)
    @sprites["enemybase"].angle=(@vector.locked?) ? 0 : (@sprites["battlebg"].angle).to_i if self.sendingOut
    @sprites["playerbase"].x=(@vector.x).to_i
    @sprites["playerbase"].y=(@vector.y).to_i
    @sprites["playerbase"].zoom_x=(@vector.zoom1)
    @sprites["playerbase"].zoom_y=(@vector.zoom1)*(@vector.zoom2)
    @sprites["playerbase"].angle=(@vector.locked?) ? 0 : (@sprites["battlebg"].angle).to_i if self.sendingOut
  end
  
  def revertMoveTransformations(index)
    if @sprites["pokemon#{index}"] && @sprites["pokemon#{index}"].hidden
      @sprites["pokemon#{index}"].hidden = false
      @sprites["pokemon#{index}"].visible = true
    end
  end
    
  #=============================================================================
  #  Common animations player
  #=============================================================================
  alias pbCommonAnimation_ebs pbCommonAnimation unless self.method_defined?(:pbCommonAnimation_ebs)
  def pbCommonAnimation(animname,user,target,hitnum=0)
    return false if ["Rain","Hail","Sandstorm","Sunny","ShadowSky","HealthDown"].include?(animname)
    return false if ["MegaEvolution","MegaEvolution2"].include?(animname) && !CUSTOMANIMATIONS
    anm = "pbCommonAnimation"+animname
    target = user if target.nil?
    # return pbCommonAnimationStatUp(user.index,target.index,hitnum)
    if eval("defined?(#{anm})")
      return eval("#{anm}(#{user.index},#{target.index},#{hitnum})") if !CUSTOMANIMATIONS
    end
    return pbCommonAnimation_ebs(animname,user,target,hitnum)
  end
  
  # Burned
  def pbCommonAnimationBurn(userindex,targetindex,hitnum=0)
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    rndx = []
    rndy = []
    shake = 2
    k = -1
    factor = player ? 1 : 0.5
    cx, cy = getCenter(poke,true)
    for i in 0...3
      fp["#{i}"] = Sprite.new(poke.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb136")
      fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{i}"].ox = 26
      fp["#{i}"].oy = 101
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      rndx.push(rand(64))
      rndy.push(rand(64))
      fp["#{i}"].x = cx - 32*factor + rndx[i]*factor
      fp["#{i}"].y = cy - 32*factor + rndy[i]*factor + 50*factor
    end
    pbSEPlay("eb_fire1",80)
    for i in 0...32
      k *= -1 if i%16==0
      for j in 0...3
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          fp["#{j}"].zoom_x = factor
          fp["#{j}"].zoom_y = factor
          fp["#{j}"].y -= 2*factor
        end
        next if j>(i/4)
        fp["#{j}"].src_rect.x += 53 if i%4==0
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
        if fp["#{j}"].opacity == 255 || fp["#{j}"].tone.gray > 0
          fp["#{j}"].opacity -= 16
          fp["#{j}"].tone.gray += 8
          fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
          fp["#{j}"].zoom_x -= 0.01
          fp["#{j}"].zoom_y += 0.02
        else
          fp["#{j}"].opacity += 51
        end
      end
      poke.tone.red += 2.4*k
      poke.tone.green -= 1.2*k
      poke.tone.blue -= 2.4*k
      poke.addOx(shake)
      shake = -2 if poke.ox > poke.bitmap.width/2 + 2
      shake = 2 if poke.ox < poke.bitmap.width/2 - 2
      poke.still
      wait(1,true)
    end
    poke.ox = poke.bitmap.width/2
    pbDisposeSpriteHash(fp)
  end
  
  # Poisoned
  def pbCommonAnimationPoison(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    shake = 1
    k = -0.1
    inc = 1
    factor = poke.zoom_x
    cx, cy = getCenter(poke,true)
    endy = []
    for j in 0...12
      fp["#{j}"] = Sprite.new(poke.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/ebPoison#{rand(3)+1}")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].x = cx - 48*factor + rand(96)*factor
      fp["#{j}"].y = cy
      z = [1,0.9,0.8][rand(3)]
      fp["#{j}"].zoom_x = z*factor
      fp["#{j}"].zoom_y = z*factor
      fp["#{j}"].opacity = 0
      fp["#{j}"].z = player ? 29 : 19
      endy.push(cy - 64*factor - rand(32)*factor)
    end
    for i in 0...32
      pbSEPlay("eb_poison1",80) if i%8==0
      poke.addOx(shake)
      k *= -1 if i%16==0
      inc += k
      for j in 0...12
        next if j>(i/2)
        fp["#{j}"].y -= (fp["#{j}"].y - endy[j])*0.06
        fp["#{j}"].opacity += 51 if i < 16
        fp["#{j}"].opacity -= 16 if i >= 16
        fp["#{j}"].x -= 1*factor*(fp["#{j}"].x < cx ? 1 : -1)
        fp["#{j}"].angle += 4*(fp["#{j}"].x < cx ? 1 : -1)
      end
      shake = -1*inc.round if poke.ox > poke.bitmap.width/2# + 2*inc.round
      shake = 1*inc.round if poke.ox < poke.bitmap.width/2# - 2*inc.round
      poke.still
      poke.color.alpha += k*60
      poke.anim = true
      wait(1,true)
    end
    poke.ox = poke.bitmap.width/2
    pbDisposeSpriteHash(fp)
  end
  
  # Frozen
  def pbCommonAnimationFrozen(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    rndx = []
    rndy = []
    shake = 2
    k = -1
    factor = poke.zoom_x
    for i in 0...12
      fp["#{i}"] = Sprite.new(poke.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb248")
      fp["#{i}"].src_rect.set(rand(2)*26,0,26,42)
      fp["#{i}"].ox = 13
      fp["#{i}"].oy = 21
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      r = rand(101)
      fp["#{i}"].zoom_x = (factor - r*0.0075*factor)
      fp["#{i}"].zoom_y = (factor - r*0.0075*factor)
      rndx.push(rand(96))
      rndy.push(rand(96))
    end
    pbSEPlay("eb_ice1")
    for i in 0...32
      k *= -1 if i%8==0
      for j in 0...12
        next if j>(i/2)
        if fp["#{j}"].opacity == 0
          cx, cy = getCenter(poke,true)
          fp["#{j}"].x = cx - 48*factor + rndx[j]*factor
          fp["#{j}"].y = cy - 48*factor + rndy[j]*factor
        end
        fp["#{j}"].src_rect.x += 26 if i%4==0 && fp["#{j}"].opacity >= 255
        fp["#{j}"].src_rect.x = 78 if fp["#{j}"].src_rect.x > 78
        if fp["#{j}"].src_rect.x==78
          fp["#{j}"].opacity -= 24
          fp["#{j}"].zoom_x += 0.02
          fp["#{j}"].zoom_y += 0.02
        elsif fp["#{j}"].opacity >= 255
          fp["#{j}"].opacity -= 24
        else
          fp["#{j}"].opacity += 45 if (i)/2 > k
        end
      end
      poke.tone.red += 3.2*k
      poke.tone.green += 3.2*k
      poke.tone.blue += 3.2*k
      poke.still
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
  end
  
  # Paralyzed
  def pbCommonAnimationParalysis(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    k = -1
    factor = poke.zoom_x
    for i in 0...12
      fp["#{i}"] = Sprite.new(poke.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb064_3")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = player ? 29 : 19
    end
    pbSEPlay("eb_electric1")
    for i in 0...32
      k *= -1 if i%16==0
      for n in 0...12
        next if n>(i/2)
        if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
          r = rand(2); r2 = rand(4)
          fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
          cx, cy = getCenter(poke,true)
          x, y = randCircleCord(32*factor)
          fp["#{n}"].x = cx - 32*factor*poke.zoom_x + x*poke.zoom_x
          fp["#{n}"].y = cy - 32*factor*poke.zoom_y + y*poke.zoom_y
          fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        fp["#{n}"].opacity += 155 if i < 27
        fp["#{n}"].angle += 180 if i%2==0
        fp["#{n}"].opacity -= 51 if i >= 27
      end
      poke.tone.red -= 14*k
      poke.tone.green -= 14*k
      poke.tone.blue -= 14*k
      poke.still
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
  end
  
  # Shiny
  def pbCommonAnimationShiny(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    k = -1
    factor = poke.zoom_x
    for i in 0...16
      cx, cy = getCenter(poke,true)
      fp["#{i}"] = Sprite.new(poke.viewport)
      str = "Graphics/Animations/ebShiny1"
      str = "Graphics/Animations/ebShiny2" if i >= 8
      fp["#{i}"].bitmap = pbBitmap(str)
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].x = cx
      fp["#{i}"].y = cy
      fp["#{i}"].zoom_x = factor
      fp["#{i}"].zoom_y = factor
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = player ? 29 : 19
    end
    for j in 0...8
      fp["s#{j}"] = Sprite.new(poke.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/ebShiny3")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
      fp["s#{j}"].opacity = 0
      z = [1,0.75,1.25,0.5][rand(4)]*factor
      fp["s#{j}"].zoom_x = z
      fp["s#{j}"].zoom_y = z
      cx, cy = getCenter(poke,true)
      fp["s#{j}"].x = cx - 32*factor + rand(64)*factor
      fp["s#{j}"].y = cy - 32*factor + rand(64)*factor
      fp["s#{j}"].opacity = 0
      fp["s#{j}"].z = player ? 29 : 19
    end
    pbSEPlay("shiny")
    for i in 0...48
      k *= -1 if i%24==0
      cx, cy = getCenter(poke,true)
      for j in 0...16
        next if (j >= 8 && i < 16)
        a = (j < 8 ? -30 : -15) + 45*(j%8) + i*2
        r = poke.bitmap.width*factor/2.5
        x = cx + r*Math.cos(a*(Math::PI/180))
        y = cy - r*Math.sin(a*(Math::PI/180))
        x = (x - fp["#{j}"].x)*0.1
        y = (y - fp["#{j}"].y)*0.1
        fp["#{j}"].x += x
        fp["#{j}"].y += y
        fp["#{j}"].angle += 8
        if j < 8
          fp["#{j}"].opacity += 51 if i < 16
          if i >= 16
            fp["#{j}"].opacity -= 16
            fp["#{j}"].zoom_x -= 0.04*factor
            fp["#{j}"].zoom_y -= 0.04*factor
          end
        else
          fp["#{j}"].opacity += 51 if i < 32
          if i >= 32
            fp["#{j}"].opacity -= 16
            fp["#{j}"].zoom_x -= 0.02*factor
            fp["#{j}"].zoom_y -= 0.02*factor
          end
        end
      end
      poke.tone.red += 3.2*k/2
      poke.tone.green += 3.2*k/2
      poke.tone.blue += 3.2*k/2
      wait(1,true)
    end
    pbSEPlay("eb_shine1",80)
    for i in 0...16
      for j in 0...8
        next if j>i
        fp["s#{j}"].opacity += 51
        fp["s#{j}"].zoom_x -= fp["s#{j}"].zoom_x*0.25 if fp["s#{j}"].opacity >= 255
        fp["s#{j}"].zoom_y -= fp["s#{j}"].zoom_y*0.25 if fp["s#{j}"].opacity >= 255
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
  end
  
  # Confused
  def pbCommonAnimationConfusion(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    k = -1
    factor = poke.zoom_x
    reversed = []
    cx, cy = getCenter(poke,true)
    width = 128*factor
    for j in 0...8
      fp["#{j}"] = Sprite.new(poke.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/ebConfused")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].zoom_x = factor
      fp["#{j}"].zoom_y = factor
      fp["#{j}"].opacity
      fp["#{j}"].y = cy - 32*factor
      fp["#{j}"].x = cx + 64*factor - (j%4)*32*factor
      reversed.push([false,true][j/4])
    end
    vol = 80
    for i in 0...64
      k = i if i < 16
      pbSEPlay("eb_confusion1",vol) if i%8==0
      vol -= 5 if i%8==0
      for j in 0...8
        reversed[j] = true if fp["#{j}"].x <= cx - 64*factor
        reversed[j] = false if fp["#{j}"].x >= cx + 64*factor
        fp["#{j}"].z = reversed[j] ? poke.z - 1 : poke.z + 1
        fp["#{j}"].y = cy - 48*factor - k*2*factor - (reversed[j] ? 4*factor : 0)
        fp["#{j}"].x -= reversed[j] ? -4*factor : 4*factor
        fp["#{j}"].opacity += 16 if i < 16
        fp["#{j}"].opacity -= 16 if i >= 48
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
  end
  
  # Sleeping
  def pbCommonAnimationSleep(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    fp = {}
    k = -1
    r = []
    factor = poke.zoom_x
    for i in 0...3
      fp["#{i}"] = Sprite.new(poke.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/ebSleep")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].angle = player ? 55 : 125
      fp["#{i}"].zoom_x = 0
      fp["#{i}"].zoom_y = 0
      fp["#{i}"].z = player ? 29 : 19
      fp["#{i}"].tone = Tone.new(192,192,192)
      r.push(0)
    end
    pbSEPlay("eb_snore",80)
    for j in 0...48
      cx, cy = getCenter(poke,true)
      for i in 0...3
        next if i>(j/12)
        fp["#{i}"].zoom_x += ((1*factor) - fp["#{i}"].zoom_x)*0.1
        fp["#{i}"].zoom_y += ((1*factor) - fp["#{i}"].zoom_y)*0.1
        a = player ? 55 : 125
        r[i] += 4*factor
        x = cx + r[i]*Math.cos(a*(Math::PI/180)) + 16*factor*(player ? 1 : -1)
        y = cy - r[i]*Math.sin(a*(Math::PI/180)) - 32*factor
        fp["#{i}"].x = x
        fp["#{i}"].y = y
        fp["#{i}"].opacity -= 16 if r[i] >= 64
        fp["#{i}"].tone.red -= 16 if fp["#{i}"].tone.red > 0
        fp["#{i}"].tone.green -= 16 if fp["#{i}"].tone.green > 0
        fp["#{i}"].tone.blue -= 16 if fp["#{i}"].tone.blue > 0
        fp["#{i}"].angle += player ? - 1 : 1
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
  end
  
  # Stat Down
  def pbCommonAnimationStatDown(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    pt = {}
    rndx = []
    rndy = []
    tone = []
    timer = []
    speed = []
    endy = poke.y - poke.bitmap.height*(player ? 1.5 : 1)
    pt["bg"] = Sprite.new(poke.viewport)
    pt["bg"].bitmap = Bitmap.new(poke.viewport.rect.width,poke.viewport.rect.height)
    pt["bg"].bitmap.fill_rect(0,0,pt["bg"].bitmap.width,pt["bg"].bitmap.height,Color.new(122,36,27))
    pt["bg"].opacity = 0
    for i in 0...64
      s = rand(2)
      y = rand(poke.bitmap.height*0.25)+1
      c = [Color.new(214,84,69),Color.new(238,145,128),Color.new(230,53,80)][rand(3)]
      pt["#{i}"] = Sprite.new(poke.viewport)
      pt["#{i}"].bitmap = Bitmap.new(14,14)
      pt["#{i}"].bitmap.drawCircle(c)
      pt["#{i}"].ox = pt["#{i}"].bitmap.width/2
      pt["#{i}"].oy = pt["#{i}"].bitmap.height/2
      width = (96/poke.bitmap.width*0.5).to_i
      pt["#{i}"].x = poke.x + rand((64 + width)*poke.zoom_x - 16)*(s==0 ? 1 : -1)
      #pt["#{i}"].x = poke.x + (rand(poke.bitmap.width*poke.zoom_x*0.6)-8)*(s==0 ? 1 : -1)
      pt["#{i}"].y = endy - y*poke.zoom_y
      pt["#{i}"].z = poke.z + (rand(2)==0 ? 1 : -1)
      r = rand(4)
      pt["#{i}"].zoom_x = poke.zoom_x*[1,0.9,0.95,0.85][r]*0.84
      pt["#{i}"].zoom_y = poke.zoom_y*[1,0.9,0.95,0.85][r]*0.84
      pt["#{i}"].opacity = 0
      pt["#{i}"].tone = Tone.new(128,128,128)
      tone.push(128)
      rndx.push(pt["#{i}"].x + rand(32)*(s==0 ? 1 : -1))
      rndy.push(poke.y + poke.bitmap.height - poke.oy)
      timer.push(0)
      speed.push((rand(50)+1)*0.002)
    end
    pbSEPlay("stat_down")
    for i in 0...64
      for j in 0...64
        next if j>(i*2)
        timer[j] += 1
        pt["#{j}"].x += (rndx[j] - pt["#{j}"].x)*speed[j]
        pt["#{j}"].y -= (pt["#{j}"].y - rndy[j])*speed[j]
        tone[j] -= 8 if tone[j] > 0 
        pt["#{j}"].tone = Tone.new(tone[j],tone[j],tone[j])
        pt["#{j}"].angle += 4
        if timer[j] > 8
          pt["#{j}"].opacity -= 8
          pt["#{j}"].zoom_x -= 0.02*poke.zoom_x if pt["#{j}"].zoom_x > 0
          pt["#{j}"].zoom_y -= 0.02*poke.zoom_y if pt["#{j}"].zoom_y > 0
        else
          pt["#{j}"].opacity += 25 if pt["#{j}"].opacity < 200
          pt["#{j}"].zoom_x += 0.025*poke.zoom_x
          pt["#{j}"].zoom_y += 0.025*poke.zoom_y
        end
      end
      if i >= 48
        pt["bg"].opacity -= 4
      elsif i < 16
        pt["bg"].opacity += 4
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(pt)
  end
  
  # Stat Up
  def pbCommonAnimationStatUp(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    pt = {}
    rndx = []
    rndy = []
    tone = []
    timer = []
    speed = []
    endy = poke.y - poke.bitmap.height*(player ? 1.5 : 1)
    pt["bg"] = Sprite.new(poke.viewport)
    pt["bg"].bitmap = Bitmap.new(poke.viewport.rect.width,poke.viewport.rect.height)
    pt["bg"].bitmap.fill_rect(0,0,pt["bg"].bitmap.width,pt["bg"].bitmap.height,Color.new(14,58,103))
    pt["bg"].opacity = 0
    for i in 0...64
      s = rand(2)
      y = rand(64)+1
      c = [Color.new(128,183,238),Color.new(74,128,208),Color.new(54,141,228)][rand(3)]
      pt["#{i}"] = Sprite.new(poke.viewport)
      pt["#{i}"].bitmap = Bitmap.new(14,14)
      pt["#{i}"].bitmap.drawCircle(c)
      pt["#{i}"].ox = pt["#{i}"].bitmap.width/2
      pt["#{i}"].oy = pt["#{i}"].bitmap.height/2
      width = (96/poke.bitmap.width*0.5).to_i
      pt["#{i}"].x = poke.x + rand((64 + width)*poke.zoom_x - 16)*(s==0 ? 1 : -1)
      #pt["#{i}"].x = poke.x + (rand(poke.bitmap.width*poke.zoom_x*0.4)-8)*(s==0 ? 1 : -1)
      pt["#{i}"].y = poke.y
      pt["#{i}"].z = poke.z + (rand(2)==0 ? 1 : -1)
      r = rand(4)
      pt["#{i}"].zoom_x = poke.zoom_x*[1,0.9,0.95,0.85][r]*0.84
      pt["#{i}"].zoom_y = poke.zoom_y*[1,0.9,0.95,0.85][r]*0.84
      pt["#{i}"].opacity = 0
      pt["#{i}"].tone = Tone.new(128,128,128)
      tone.push(128)
      rndx.push(pt["#{i}"].x + rand(32)*(s==0 ? 1 : -1))
      rndy.push(endy - y*poke.zoom_y)
      timer.push(0)
      speed.push((rand(50)+1)*0.002)
    end
    pbSEPlay("stat_up")
    for i in 0...64
      for j in 0...64
        next if j>(i*2)
        timer[j] += 1
        pt["#{j}"].x += (rndx[j] - pt["#{j}"].x)*speed[j]
        pt["#{j}"].y -= (pt["#{j}"].y - rndy[j])*speed[j]
        tone[j] -= 8 if tone[j] > 0 
        pt["#{j}"].tone = Tone.new(tone[j],tone[j],tone[j])
        pt["#{j}"].angle += 4
        if timer[j] > 8
          pt["#{j}"].opacity -= 8
          pt["#{j}"].zoom_x -= 0.02*poke.zoom_x if pt["#{j}"].zoom_x > 0
          pt["#{j}"].zoom_y -= 0.02*poke.zoom_y if pt["#{j}"].zoom_y > 0
        else
          pt["#{j}"].opacity += 25 if pt["#{j}"].opacity < 200
          pt["#{j}"].zoom_x += 0.025*poke.zoom_x
          pt["#{j}"].zoom_y += 0.025*poke.zoom_y
        end
      end
      if i >= 48
        pt["bg"].opacity -= 4
      elsif i < 16
        pt["bg"].opacity += 4
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(pt)
  end
  
  # Healing
  def pbCommonAnimationHealthUp(userindex,targetindex,hitnum=0)
    return if targetindex.nil?
    wait(16,true) if self.afterAnim
    poke = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    pt = {}
    rndx = []
    rndy = []
    tone = []
    timer = []
    speed = []
    endy = poke.y - poke.bitmap.height*(player ? 1.5 : 1)
    pt["bg"] = Sprite.new(poke.viewport)
    pt["bg"].bitmap = Bitmap.new(poke.viewport.rect.width,poke.viewport.rect.height)
    pt["bg"].bitmap.fill_rect(0,0,pt["bg"].bitmap.width,pt["bg"].bitmap.height,Color.new(19,98,21))
    pt["bg"].opacity = 0
    for i in 0...32
      s = rand(2)
      y = rand(64)+1
      c = [Color.new(92,202,81),Color.new(68,215,105),Color.new(192,235,180)][rand(3)]
      pt["#{i}"] = Sprite.new(poke.viewport)
      pt["#{i}"].bitmap = Bitmap.new(14,14)
      pt["#{i}"].bitmap.drawCircle(c)
      pt["#{i}"].ox = pt["#{i}"].bitmap.width/2
      pt["#{i}"].oy = pt["#{i}"].bitmap.height/2
      width = (96/poke.bitmap.width*0.5).to_i
      pt["#{i}"].x = poke.x + rand((64 + width)*poke.zoom_x - 32)*(s==0 ? 1 : -1)
      #pt["#{i}"].x = poke.x + (rand(poke.bitmap.width*poke.zoom_x*0.4)-8)*(s==0 ? 1 : -1)
      pt["#{i}"].y = poke.y
      pt["#{i}"].z = poke.z + (rand(2)==0 ? 1 : -1)
      r = rand(4)
      pt["#{i}"].zoom_x = poke.zoom_x*[1,0.9,0.75,0.5][r]*0.84
      pt["#{i}"].zoom_y = poke.zoom_y*[1,0.9,0.75,0.5][r]*0.84
      pt["#{i}"].opacity = 0
      pt["#{i}"].tone = Tone.new(128,128,128)
      tone.push(128)
      rndx.push(pt["#{i}"].x + rand(32)*(s==0 ? 1 : -1))
      rndy.push(endy - y*poke.zoom_y)
      timer.push(0)
      speed.push((rand(50)+1)*0.002)
    end
    for j in 0...12
      pt["s#{j}"] = Sprite.new(poke.viewport)
      pt["s#{j}"].bitmap = pbBitmap("Graphics/Animations/ebHealing")
      pt["s#{j}"].ox = pt["s#{j}"].bitmap.width/2
      pt["s#{j}"].oy = pt["s#{j}"].bitmap.height/2
      pt["s#{j}"].opacity = 0
      z = [1,0.75,1.25,0.5][rand(4)]*poke.zoom_x
      pt["s#{j}"].zoom_x = z
      pt["s#{j}"].zoom_y = z
      cx, cy = getCenter(poke,true)
      pt["s#{j}"].x = cx - 32*poke.zoom_x + rand(64)*poke.zoom_x
      pt["s#{j}"].y = cy - 32*poke.zoom_x + rand(64)*poke.zoom_x
      pt["s#{j}"].opacity = 0
      pt["s#{j}"].z = player ? 29 : 19
    end
    pbSEPlay("Protect")
    for i in 0...64
      for j in 0...32
        next if j>(i)
        timer[j] += 1
        pt["#{j}"].x += (rndx[j] - pt["#{j}"].x)*speed[j]
        pt["#{j}"].y -= (pt["#{j}"].y - rndy[j])*speed[j]
        tone[j] -= 8 if tone[j] > 0 
        pt["#{j}"].tone = Tone.new(tone[j],tone[j],tone[j])
        pt["#{j}"].angle += 4
        if timer[j] > 8
          pt["#{j}"].opacity -= 8
          pt["#{j}"].zoom_x -= 0.02*poke.zoom_x if pt["#{j}"].zoom_x > 0
          pt["#{j}"].zoom_y -= 0.02*poke.zoom_y if pt["#{j}"].zoom_y > 0
        else
          pt["#{j}"].opacity += 25 if pt["#{j}"].opacity < 200
          pt["#{j}"].zoom_x += 0.025*poke.zoom_x
          pt["#{j}"].zoom_y += 0.025*poke.zoom_y
        end
      end
      for k in 0...12
        next if k>i
        pt["s#{k}"].opacity += 51
        pt["s#{k}"].zoom_x -= pt["s#{k}"].zoom_x*0.25 if pt["s#{k}"].opacity >= 255 && pt["s#{k}"].zoom_x > 0
        pt["s#{k}"].zoom_y -= pt["s#{k}"].zoom_y*0.25 if pt["s#{k}"].opacity >= 255 && pt["s#{k}"].zoom_y > 0
      end
      if i >= 48
        pt["bg"].opacity -= 4
      elsif i < 16
        pt["bg"].opacity += 4
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(pt)
  end
  #=============================================================================
  #  For in battle sprite changes
  #=============================================================================
  alias pbChangePokemon_ebs pbChangePokemon unless self.method_defined?(:pbChangePokemon_ebs)
  def pbChangePokemon(attacker,pokemon)
    return pbMegaAnimation(attacker,pokemon) if pokemon.isMega? && !CUSTOMANIMATIONS
    pbDisplayEffect(@battle.abilityChange) if EFFECTMESSAGES && !@battle.abilityChange.nil?
    @battle.abilityChange = nil
    pkmn=@sprites["pokemon#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    t=0
    10.times do
      t+=51 if t < 255
      pkmn.tone=Tone.new(t,t,t)
      pkmn.zoom_x+=0.05
      pkmn.zoom_y+=0.05
      wait(1)
    end
    pkmn.setPokemonBitmap(pokemon,back)
    10.times do
      t-=51 if t > 0
      pkmn.tone=Tone.new(t,t,t)
      pkmn.zoom_x-=0.05
      pkmn.zoom_y-=0.05
      wait(1)
    end
  end
    
  def pbMegaAnimation(attacker,pokemon)
    for i in 0...4
      @sprites["battlebox#{i}"].visible=false if @sprites["battlebox#{i}"]
    end
    clearMessageWindow
    
    pkmn=@sprites["pokemon#{attacker.index}"]
    org_z = pkmn.z
    pkmn.z=32
    
    vector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    back=!@battle.pbIsOpposing?(attacker.index)
    if !back
      @vector.set(ENEMYVECTOR)
      zoom = 1.5
    else
      @vector.set(PLAYERVECTOR)
      zoom = 1
    end
    light = Sprite.new(@viewport)
    light.z = pkmn.z+1
    light.bitmap = Bitmap.new(pkmn.bitmap.width*1.25*pkmn.zoom_x*zoom,pkmn.bitmap.height*1.25*pkmn.zoom_y*zoom)
    light.bitmap.drawCircle
    light.ox = light.bitmap.width/2
    light.oy = light.bitmap.height/2
    light.zoom_x = 0.75
    light.zoom_y = 0.75
    light.opacity = 0
    
    scroll = Sprite.new(@viewport)
    bmp = pbBitmap("Graphics/Animations/finger.spoon")
    scroll.bitmap = Bitmap.new(Graphics.width*2,VIEWPORT_HEIGHT)
    scroll.bitmap.stretch_blt(Rect.new(0,0,Graphics.width,VIEWPORT_HEIGHT),bmp,Rect.new(199,213,170,144))
    scroll.bitmap.stretch_blt(Rect.new(Graphics.width,0,Graphics.width,VIEWPORT_HEIGHT),bmp,Rect.new(199,213,170,144))
    scroll.tone = Tone.new(128,32,32)
    scroll.opacity = 0
    scroll.z = 30
    20.times do
      scroll.x-=32
      scroll.x = 0 if scroll.x <= -Graphics.width
      scroll.opacity+=8
      wait(1,true)
    end
    light.x = pkmn.x
    light.y = pkmn.y - (pkmn.bitmap.height-pkmn.oy) - pkmn.bitmap.height/2
    
    pbSEPlay("Harden",100)
    10.times do
      light.zoom_x+=0.05
      light.zoom_y+=0.05
      light.opacity+=26
      scroll.x-=32
      scroll.x = 0 if scroll.x <= -Graphics.width
      scroll.opacity+=8
      wait(1)
    end
    pbSEPlay("Shell Smash",100)
    5.times do
      5.times do
        light.zoom_x+=0.02
        light.zoom_y+=0.02
        scroll.x-=32
        scroll.x = 0 if scroll.x <= -Graphics.width
        scroll.opacity+=8
        wait(1)
      end
      5.times do
        light.zoom_x-=0.02
        light.zoom_y-=0.02
        scroll.x-=32
        scroll.x = 0 if scroll.x <= -Graphics.width
        scroll.opacity+=8
        wait(1)
      end
    end
    2.times do
      light.zoom_x+=0.7
      light.zoom_y+=0.7
      wait(1)
    end
    light.zoom_x = 20
    light.zoom_y = 20
    scroll.dispose
    pkmn.setPokemonBitmap(pokemon,back)
    pkmn.z = org_z
    wait(10)
    25.times do
      light.opacity-=11
      wait(1)
    end
    pbPlayCry(pokemon,100)
    wait(Graphics.frame_rate)
    @vector.set(vector)
    wait(20,true)
    
    for i in 0...4
      @sprites["battlebox#{i}"].visible=true if @sprites["battlebox#{i}"]
    end
  end
  #=============================================================================
  #  New animation core for move animations
  #=============================================================================
  alias pbAnimation_ebs pbAnimation unless self.method_defined?(:pbAnimation_ebs)
  def pbAnimation(moveid,user,target,hitnum=0)
    animid=pbFindAnimation(moveid,user.index,hitnum)
    return if !animid
    anim=animid[0]
    animations=load_data("Data/PkmnAnimations.rxdata")
    name=PBMoves.getName(moveid)
    # Substitute animation
    if @sprites["pokemon#{user.index}"] && @battle.battlescene && !self.respond_to?(:playGlobalMoveAnimation)
      subbed = @sprites["pokemon#{user.index}"].isSub
      self.setSubstitute(user.index,false) if subbed
    end
    pbSaveShadows {
       if animid[1] # On opposing side and using OppMove animation
         pbAnimationCore(animations[anim],target,user,true,name)
       else         # On player's side, and/or using Move animation
         pbAnimationCore(animations[anim],user,target,false,name)
       end
    }
    if PBMoveData.new(moveid).function==0x69 && user && target # Transform
      # Change form to transformed version
      pbChangePokemon(user,target.pokemon) if !self.respond_to?(:playGlobalMoveAnimation)
    end
  end
  
  alias pbAnimationCore_ebs pbAnimationCore unless self.method_defined?(:pbAnimationCore_ebs)
  def pbAnimationCore(animation,user,target,oppmove=false,movename="")
    return if !animation
    clearMessageWindow
    isVisible=[false,false,false,false]
    for i in 0...4
      next if self.respond_to?(:playGlobalMoveAnimation)
      if @sprites["battlebox#{i}"]
        isVisible[i]=@sprites["battlebox#{i}"].visible
        @sprites["battlebox#{i}"].visible=false
      end
    end
    @briefmessage=false
    usersprite=(user) ? @sprites["pokemon#{user.index}"] : nil
    targetsprite=(target) ? @sprites["pokemon#{target.index}"] : nil
    target=user if !targetsprite && !target
    # Special animations
    special=(
      ["Quick Attack","Flamethrower","Tail Whip"].include?(movename)
    )
    # Vector movement
    fakeplayer=PBAnimationPlayerX.new(animation,user,target,self,oppmove)
    fakeplayer.start
    vector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    if !(target==user) && !user.nil?
      focus=fakeplayer.getFocus
      if focus==3 || special # both
        @vector.set(DUALVECTOR)
      elsif focus==1
        if target.index%2==0 && user.index%2==1 # player
          @vector.set(PLAYERVECTOR)
        elsif target.index%2==1 && user.index%2==0 # opponent
          @vector.set(ENEMYVECTOR)
        end
      end
    end
    fakeplayer.dispose
    wait(20,true)
    # end
    olduserx=usersprite ? usersprite.x-usersprite.ox : 0
    uy=usersprite ? (usersprite.bitmap.height*usersprite.zoom_y)/2 - ((usersprite.bitmap.height-usersprite.oy)*usersprite.zoom_y) : 0
    oldusery=usersprite ? usersprite.y-uy : 0
    oldtargetx=targetsprite ? targetsprite.x-targetsprite.ox : 0
    ty=targetsprite ? (targetsprite.bitmap.height*targetsprite.zoom_y)/2 - ((targetsprite.bitmap.height-targetsprite.oy)*targetsprite.zoom_y) : 0
    oldtargety=targetsprite ? targetsprite.y-ty : 0

    useroy = usersprite.oy if usersprite
    targetoy = targetsprite.oy if targetsprite
    
    animplayer=PBAnimationPlayerX.new(animation,user,target,self,oppmove)
    if !targetsprite
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery,
         olduserx+(userwidth/2),oldusery)
    else
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      targetwidth=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.width
      targetheight=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery,
         oldtargetx+(targetwidth/2),oldtargety)
    end
    animplayer.start
    while animplayer.playing?
      animplayer.update
      animateBattleSprites
      pbGraphicsUpdate
      pbInputUpdate
    end
    animplayer.dispose
    usersprite.oy = useroy if usersprite
    targetsprite.oy = targetoy if targetsprite
    vector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @vector.set(vector)
    for i in 0...4
      next if self.respond_to?(:playGlobalMoveAnimation)
      if @sprites["battlebox#{i}"]
        @sprites["battlebox#{i}"].visible=true if isVisible[i]
      end
    end
    wait(20,true) if !(target==user) && !user.nil? && !self.respond_to?(:playGlobalMoveAnimation)
  end
end

#===============================================================================
#  New aliased methods for Sprite animations within the battle system
#===============================================================================
def pbSpriteSetAnimFrame(sprite,frame,user=nil,target=nil,ineditor=false)
  return if !sprite
  if !frame
    sprite.visible=false
    sprite.src_rect=Rect.new(0,0,1,1)
    return
  end
  sprite.blend_type=frame[AnimFrame::BLENDTYPE]
  sprite.angle=frame[AnimFrame::ANGLE]
  sprite.mirror=(frame[AnimFrame::MIRROR]>0)
  sprite.opacity=frame[AnimFrame::OPACITY]
  sprite.visible=true
  if !frame[AnimFrame::VISIBLE]==1 && ineditor
    sprite.opacity/=2
  else
    sprite.visible=(frame[AnimFrame::VISIBLE]==1)
  end
  pattern=frame[AnimFrame::PATTERN]
  if pattern>=0
    animwidth=192
    sprite.src_rect.set((pattern%5)*animwidth,(pattern/5)*animwidth,
       animwidth,animwidth)
  else
    if sprite.respond_to?(:battleIndex) && sprite.battleIndex
      index = sprite.battleIndex
    else
      index = user.battleIndex
    end
    z = (index%2==1) ? 1 : 2#BACKSPRITESCALE
    zoom = (index%2==1) ? @scene.sprites["enemybase"].zoom_x : @scene.sprites["playerbase"].zoom_x
    sprite.zoom_x = (frame[AnimFrame::ZOOMX]*zoom*z)/100.0
    sprite.zoom_y = (frame[AnimFrame::ZOOMY]*zoom*z)/100.0
  end
  sprite.zoom_x=frame[AnimFrame::ZOOMX]/100.0 if pattern>=0
  sprite.zoom_y=frame[AnimFrame::ZOOMY]/100.0 if pattern>=0
  sprite.color.set(
     frame[AnimFrame::COLORRED],
     frame[AnimFrame::COLORGREEN],
     frame[AnimFrame::COLORBLUE],
     frame[AnimFrame::COLORALPHA]
  )
  sprite.tone.set(
     frame[AnimFrame::TONERED],
     frame[AnimFrame::TONEGREEN],
     frame[AnimFrame::TONEBLUE],
     frame[AnimFrame::TONEGRAY] 
  )
  sprite.ox=sprite.src_rect.width/2 if pattern>=0
  sprite.oy=sprite.src_rect.height/2 if pattern>=0
  sprite.x=frame[AnimFrame::X]
  sprite.y=frame[AnimFrame::Y]
  if sprite!=user && sprite!=target
    case frame[AnimFrame::PRIORITY]
    when 0   # Behind everything
      sprite.z=5
    when 1   # In front of everything
      sprite.z=35
    when 2   # Just behind focus
      if frame[AnimFrame::FOCUS]==1 # Focused on target
        sprite.z=(target) ? target.z-1 : 5
      elsif frame[AnimFrame::FOCUS]==2 # Focused on user
        sprite.z=(user) ? user.z-1 : 5
      else # Focused on user and target, or screen
        sprite.z=5
      end
    when 3   # Just in front of focus
      if frame[AnimFrame::FOCUS]==1 # Focused on target
        sprite.z=(target) ? target.z+1 : 35
      elsif frame[AnimFrame::FOCUS]==2 # Focused on user
        sprite.z=(user) ? user.z+1 : 35
      else # Focused on user and target, or screen
        sprite.z=35
      end
    else
      sprite.z=35
    end
  end
end

class PBAnimationPlayerX
  
  def getFocus
    return 1 if @frame < 0
    pattern=1
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      # Set each cel sprite acoordingly
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        next if !sprite
        focus=cel[AnimFrame::FOCUS]
      end
      return [pattern,focus].max
    end
    return 1
  end

  alias initialize_eb initialize unless self.method_defined?(:initialize_eb)
  def initialize(animation,user,target,scene=nil,oppmove=false,ineditor=false)
    initialize_eb(animation,user,target,scene,oppmove,ineditor)
  end
  
  alias update_eb update unless self.method_defined?(:update_eb)
  def update
    return if @frame<0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame<0
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap if @animsprites[i]
      end
    end
    @bgGraphic.update
    @bgColor.update
    @foGraphic.update
    @foColor.update
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      # Make all cel sprites invisible
      for i in 0...MAXSPRITES
        @animsprites[i].visible=false if @animsprites[i]
      end
      # Set each cel sprite acoordingly
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        next if !sprite
        # Set cel sprite's graphic
        if cel[AnimFrame::PATTERN]==-1
          sprite.bitmap=@userbitmap
        elsif cel[AnimFrame::PATTERN]==-2
          sprite.bitmap=@targetbitmap
        else
          sprite.bitmap=@animbitmap
        end
        # Apply settings to the cel sprite
        pbSpriteSetAnimFrame(sprite,cel,@usersprite,@targetsprite,false)
        case cel[AnimFrame::FOCUS]
        when 1   # Focused on target
          sprite.x=cel[AnimFrame::X]+@targetOrig[0]-PokeBattle_SceneConstants::FOCUSTARGET_X
          sprite.y=cel[AnimFrame::Y]+@targetOrig[1]-PokeBattle_SceneConstants::FOCUSTARGET_Y
          sprite.y-=64 if defined?(SCREENDUALHEIGHT) && cel[AnimFrame::PATTERN]>=0
        when 2   # Focused on user
          sprite.x=cel[AnimFrame::X]+@userOrig[0]-PokeBattle_SceneConstants::FOCUSUSER_X
          sprite.y=cel[AnimFrame::Y]+@userOrig[1]-PokeBattle_SceneConstants::FOCUSUSER_Y
          sprite.y-=64 if defined?(SCREENDUALHEIGHT) && cel[AnimFrame::PATTERN]>=0
        when 3   # Focused on user and target
          if @srcLine && @dstLine
            point=transformPoint(
               @srcLine[0],@srcLine[1],@srcLine[2],@srcLine[3],
               @dstLine[0],@dstLine[1],@dstLine[2],@dstLine[3],
               sprite.x,sprite.y)
            sprite.x=point[0] 
            sprite.y=point[1]
            if isReversed(@srcLine[0],@srcLine[2],@dstLine[0],@dstLine[2]) &&
               cel[AnimFrame::PATTERN]>=0
              # Reverse direction
              sprite.mirror=!sprite.mirror
            end
          end
        end
        sprite.x+=64 if @ineditor
        sprite.y+=64 if @ineditor
        # EB positioning addition
        if cel[AnimFrame::PATTERN]<0 && !defined?(SCREENDUALHEIGHT)
          offset=( (sprite.oy*sprite.zoom_y)-(sprite.bitmap.height-sprite.oy)*sprite.zoom_y )/2
          #offset+=(sprite.zoom_y*sprite.oy)/2 if sprite.isSub
          sprite.y+=offset
        end
      end
      # Play timings
      @animation.playTiming(@frame>>1,@bgGraphic,@bgColor,@foGraphic,@foColor,@oldbg,@oldfo,@user)
    end
    @frame+=1
  end

end

module RPG
  class Weather
    alias initialize_ebs initialize unless self.method_defined?(:initialize_ebs)
    alias dispose_ebs dispose unless self.method_defined?(:dispose_ebs)
  end
  class BattleWeather < Weather
    attr_accessor :visible
    
    def initialize(viewport = nil)
      @disposed = false
      @visible = true
      initialize_ebs(viewport)
      @viewport.z = @origviewport.z
    end
    
    def dispose
      dispose_ebs
      @disposed = true
    end
    
    def disposed?
      return @disposed
    end
    def color
      return @viewport.color
    end
    def color=(val)
      @viewport.color=val
    end
  end
end
#-------------------------------------------------------------------------------
#  Handles the animation during the ball burst upon Pokemon entry
#-------------------------------------------------------------------------------
class EBBallBurst
  def initialize(viewport,x=0,y=0,z=50,factor=1,balltype=0)
    balltype = 0 if pbResolveBitmap("Graphics/Animations/Ballburst/shine#{balltype}").nil?
    @balltype = balltype
    @viewport = viewport
    @factor = factor
    @fp = {}
    @index = 0
    @tone = 255.0
    @pzoom = []
    @poy = []
    @szoom = []
    @rangl = []
    @rad = []
    @catching = false
    @recall = false
    for j in 0...8
      @fp["s#{j}"] = Sprite.new(@viewport)
      @fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/Ballburst/ray#{balltype}")
      @fp["s#{j}"].oy = @fp["s#{j}"].bitmap.height/2
      @fp["s#{j}"].zoom_x = 0
      @fp["s#{j}"].zoom_y = 0
      @fp["s#{j}"].tone = Tone.new(255,255,255)
      @fp["s#{j}"].x = x
      @fp["s#{j}"].y = y
      @fp["s#{j}"].z = z
      @fp["s#{j}"].angle = rand(360)
      @szoom.push([1.0,1.25,0.75,0.5][rand(4)]*@factor)
    end
    @fp["cir"] = Sprite.new(@viewport)
    @fp["cir"].bitmap = pbBitmap("Graphics/Animations/Ballburst/shine#{balltype}")
    @fp["cir"].ox = @fp["cir"].bitmap.width/2
    @fp["cir"].oy = @fp["cir"].bitmap.height/2
    @fp["cir"].x = x
    @fp["cir"].y = y
    @fp["cir"].zoom_x = 0
    @fp["cir"].zoom_y = 0
    @fp["cir"].tone = Tone.new(255,255,255)
    @fp["cir"].z = z
    for k in 0...16
      str = ["particle","eff"][rand(2)]
      @fp["p#{k}"] = Sprite.new(@viewport)
      @fp["p#{k}"].bitmap = pbBitmap("Graphics/Animations/Ballburst/#{str}#{balltype}")
      @fp["p#{k}"].ox = @fp["p#{k}"].bitmap.width/2
      @fp["p#{k}"].oy = @fp["p#{k}"].bitmap.height/2
      @pzoom.push([1.0,0.3,0.75,0.5][rand(4)]*@factor)
      @fp["p#{k}"].zoom_x = 1*@factor
      @fp["p#{k}"].zoom_y = 1*@factor
      @fp["p#{k}"].tone = Tone.new(255,255,255)
      @fp["p#{k}"].x = x
      @fp["p#{k}"].y = y
      @fp["p#{k}"].z = z
      @fp["p#{k}"].opacity = 0
      @fp["p#{k}"].angle = rand(360)
      @rangl.push(rand(360))
      @poy.push(rand(4)+3)
      @rad.push(0)
    end
    @x = x; @y = y; @z = z
  end
  
  def update
    return self.reverse if @catching
    i = @index # i
    for j in 0...8
      next if i < 4
      next if j > (i-4)/2
      @fp["s#{j}"].zoom_x += (@szoom[j]*0.1)
      @fp["s#{j}"].zoom_y += (@szoom[j]*0.1)
      @fp["s#{j}"].opacity -= 8 if @fp["s#{j}"].zoom_x >= 1
    end
    for k in 0...16
      next if i < 4
      next if k > (i-4)
      @fp["p#{k}"].opacity += 25.5 if i < 22
      @fp["p#{k}"].zoom_x -= (@fp["p#{k}"].zoom_x - @pzoom[k])*0.1
      @fp["p#{k}"].zoom_y -= (@fp["p#{k}"].zoom_y - @pzoom[k])*0.1
      a = @rangl[k]
      @rad[k] += @poy[k]*@factor; r = @rad[k]
      x = @x + r*Math.cos(a*(Math::PI/180))
      y = @y - r*Math.sin(a*(Math::PI/180))
      @fp["p#{k}"].x = x
      @fp["p#{k}"].y = y
      @fp["p#{k}"].angle += 4
    end
    if i >= 22
      for j in 0...8
        @fp["s#{j}"].opacity -= 26
      end
      for k in 0...16
        @fp["p#{k}"].opacity -= 26
      end
      @fp["cir"].opacity -= 26
    end
    @tone -= 25.5 if i >= 4 && @tone > 0
    for j in 0...8
      @fp["s#{j}"].tone = Tone.new(@tone,@tone,@tone)
    end
    for k in 0...16
      @fp["p#{k}"].tone = Tone.new(@tone,@tone,@tone)
    end
    @fp["cir"].tone = Tone.new(@tone,@tone,@tone)
    @fp["cir"].zoom_x += (@factor*1.5 - @fp["cir"].zoom_x)*0.06
    @fp["cir"].zoom_y += (@factor*1.5 - @fp["cir"].zoom_y)*0.06
    @fp["cir"].angle -= 4 if $PokemonSystem.screensize < 2    
    @index += 1 # i
  end
  
  def reverse
    i = @index # i
    @tone -= 25.5 if i >= 4 && @tone > 0
    for j in 0...8
      next if i < 4
      next if j > (i-4)/2
      next if @recall
      @fp["s#{j}"].zoom_x += (@szoom[j]*0.1)
      @fp["s#{j}"].zoom_y += (@szoom[j]*0.1)
      @fp["s#{j}"].opacity -= 8 if @fp["s#{j}"].zoom_x >= 1
    end
    if i >= 22
      for j in 0...8
        @fp["s#{j}"].opacity -= 26
      end
    end
    for j in 0...8
      @fp["s#{j}"].tone = Tone.new(@tone,@tone,@tone)
    end
    for k in 0...16
      a = k*22.5 + 11.5 + i*4
      r = 128*@factor - i*8*@factor
      x = @x + r*Math.cos(a*(Math::PI/180))
      y = @y - r*Math.sin(a*(Math::PI/180))
      @fp["p#{k}"].x = x
      @fp["p#{k}"].y = y
      @fp["p#{k}"].angle += 8
      @fp["p#{k}"].opacity += 32 if i < 8
      @fp["p#{k}"].opacity -= 32 if i >= 8
    end
    @fp["cir"].tone = Tone.new(@tone,@tone,@tone)
    @fp["cir"].zoom_x -= (@fp["cir"].zoom_x - 0.5*@factor)*0.06
    @fp["cir"].zoom_y -= (@fp["cir"].zoom_y - 0.5*@factor)*0.06
    @fp["cir"].opacity += 25.5 if i < 16
    @fp["cir"].opacity -= 16 if i >= 16
    @fp["cir"].angle -= 4 if $PokemonSystem.screensize < 2 
    @index += 1 # i
  end
  
  def dispose
    pbDisposeSpriteHash(@fp)
  end
  
  def catching
    @catching = true
    for k in 0...16
      a = k*22.5 + 11.5
      r = 128*@factor
      x = @x + r*Math.cos(a*(Math::PI/180))
      y = @y - r*Math.sin(a*(Math::PI/180))
      @fp["p#{k}"].x = x
      @fp["p#{k}"].y = y
      @fp["p#{k}"].tone = Tone.new(0,0,0)
      @fp["p#{k}"].opacity = 0
      str = ["particle","eff"][k%2]
      @fp["p#{k}"].bitmap = pbBitmap("Graphics/Animations/Ballburst/#{str}#{@balltype}")
      @fp["p#{k}"].ox = @fp["p#{k}"].bitmap.width/2
      @fp["p#{k}"].oy = @fp["p#{k}"].bitmap.height/2
    end
    @fp["cir"].zoom_x = 2*@factor
    @fp["cir"].zoom_y = 2*@factor
  end
  
  def recall
    @recall = true
    self.catching
  end
  
end
#-------------------------------------------------------------------------------
#  Handles the animation of dust particles when heavy Pokemon are sent out
#-------------------------------------------------------------------------------
class EBDustParticle
  
  def initialize(viewport,sprite,factor=1)
    @viewport = viewport
    @x = sprite.x
    @y = sprite.y
    @z = sprite.z
    @factor = sprite.zoom_x
    @index = 0
    @fp = {}
    width = sprite.bitmap.width/2 - 16
    @max = 16 + (width/16)
    for j in 0...@max
      @fp["#{j}"] = Sprite.new(@viewport)
      @fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/ebDustParticle")
      @fp["#{j}"].ox = @fp["#{j}"].bitmap.width/2
      @fp["#{j}"].oy = @fp["#{j}"].bitmap.height/2
      @fp["#{j}"].opacity = 0
      @fp["#{j}"].angle = rand(360)
      @fp["#{j}"].x = @x - width*@factor + rand(width*2*@factor)
      @fp["#{j}"].y = @y - 16*@factor + rand(32*@factor)
      @fp["#{j}"].z = @z + (@fp["#{j}"].y < @y ? -1 : 1)
      zoom = [1,0.8,0.9,0.7][rand(4)]
      @fp["#{j}"].zoom_x = zoom*@factor
      @fp["#{j}"].zoom_y = zoom*@factor
    end
  end
  
  def update
    i = @index
    for j in 0...@max
      @fp["#{j}"].opacity += 25.5 if i < 10
      @fp["#{j}"].opacity -= 25.5 if i >= 14
      if @fp["#{j}"].x >= @x
        @fp["#{j}"].angle += 4
        @fp["#{j}"].x += 2
      else
        @fp["#{j}"].angle -= 4
        @fp["#{j}"].x -= 2
      end
      #@fp["#{j}"].y += 1
    end
    @index += 1
  end
  
  def dispose
    pbDisposeSpriteHash(@fp)
  end
  
end
#===============================================================================
#  Additional classes and functions added to calcualte the positions of the
#  scene elements in the battle system.
#  Makes for smoother animation/movement and adds more depth to the system.
#===============================================================================                           
class Vector
  attr_reader :x
  attr_reader :y
  attr_reader :angle
  attr_reader :scale
  attr_reader :x2
  attr_reader :y2
  attr_accessor :zoom1
  attr_accessor :zoom2
  attr_accessor :inc
  attr_accessor :set
  
  def initialize(x=0,y=0,angle=0,scale=1,zoom1=1,zoom2=1)
    @x=x.to_f
    @y=y.to_f
    @angle=angle.to_f
    @scale=scale.to_f
    @zoom1=zoom1.to_f
    @zoom2=zoom2.to_f
    @inc=0.2
    @set=[@x,@y,@scale,@angle,@zoom1,@zoom2]
    @locked=false
    @force=false
    @constant=1
    self.calculate
  end
  
  def calculate
    angle=@angle*(Math::PI/180)
    width=Math.cos(angle)*@scale
    height=Math.sin(angle)*@scale
    @x2=@x+width
    @y2=@y-height
  end
  
  def spoof(*args)
    if args[0].is_a?(Array)
      x,y,angle,scale,zoom1,zoom2 = args[0]
    else
      x,y,angle,scale,zoom1,zoom2 = args
    end
    angle=angle*(Math::PI/180)
    width=Math.cos(angle)*scale
    height=Math.sin(angle)*scale
    x2=x+width
    y2=y-height
    return x2, y2
  end
  
  def angle=(val)
    @angle=val
    self.calculate
  end
  
  def scale=(val)
    @scale=val
    self.calculate
  end
  
  def x=(val)
    @x=val
    @set[0]=val
    self.calculate
  end
  
  def y=(val)
    @y=val
    @set[1]=val
    self.calculate
  end
  
  def force
    @force = true
  end
  
  def set(*args)
    return if DISABLESCENEMOTION && !@force
    @force = false
    if args[0].is_a?(Array)
      x,y,angle,scale,zoom1,zoom2 = args[0]
    else
      x,y,angle,scale,zoom1,zoom2 = args
    end
    @set=[x,y,angle,scale,zoom1,zoom2] 
    @constant=rand(4)+1
  end
  
  def add(field="",amount=0.0)
    case field
    when "x"
      @set[0]=@x+amount
    when "y"
      @set[1]=@y+amount
    when "angle"
      @set[2]=@angle+amount
    when "scale"
      @set[3]=@scale+amount
    when "zoom1"
      @set[4]=@zoom1+amount
    when "zoom2"
      @set[5]=@zoom2+amount
    end
  end
  
  def setXY(x,y)
    @set[0]=x
    @set[1]=y
  end
    
  def locked?
    return @locked
  end
  
  def lock
    @locked=!@locked
  end
  
  def update
    @x+=(@set[0]-@x)*@inc
    @y+=(@set[1]-@y)*@inc
    @angle+=(@set[2]-@angle)*@inc
    @scale+=(@set[3]-@scale)*@inc
    @zoom1+=(@set[4]-@zoom1)*@inc
    @zoom2+=(@set[5]-@zoom2)*@inc
    self.calculate
  end
  
  def finished?
    return ((@set[0]-@x)*@inc).abs <= 0.05*@constant
  end
  
end

def calculateCurve(x1,y1,x2,y2,x3,y3,frames=10)
  output=[]
  curve=[x1,y1,x2,y2,x3,y3,x3,y3]
  step=1.0/frames
  t=0.0
  frames.times do
    point=getCubicPoint2(curve,t)
    output.push([point[0],point[1]])
    t+=step
  end
  return output
end

def singleDecInt?(number)
  number*=10
  return (number%10==0)
end