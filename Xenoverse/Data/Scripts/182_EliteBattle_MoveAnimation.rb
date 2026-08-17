#===============================================================================
#  Elite Battle system
#    by Luka S.J.
# ----------------
#  MoveAnimations Script
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
#  New move animation engine. Plays custom animations for defined Pokemon moves,
#  if present. Otherwise defaults to default move animations based on the move type
#  and category. Overrides the default animation player, and doesn't allow
#  animations from the Editor to be played. Should you wish to make your own
#  move animations in the editor, do not include this script section in your project.
#  You can code your own move animations, by making a def and calling it
#    pbMoveAnimationSpecific#{3 digit move id}(userindex,targetindex,hitnum=0,multihit=false)
#===============================================================================
class PokeBattle_Scene
  attr_accessor :animationCount
  #-----------------------------------------------------------------------------
  #  Main animation handling core
  #-----------------------------------------------------------------------------
  def pbAnimation(moveid,user,target,hitnum=0)
    # for hitnum, 1 is the charging animation, 0 is the damage animation
    return if !moveid
    # move information
    movedata = PBMoveData.new(moveid)
    move = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveid))
    numhits = user.thisMoveHits
    multihit = !numhits.nil? ? (numhits > @animationCount) : false
    @animationCount+=1
    if numhits.nil?
      @animationCount=1
    elsif @animationCount > numhits
      @animationCount=1
    end
    multitarget = false
    multitarget = move.target if (move.target==PBTargets::AllOpposing || move.target==PBTargets::AllNonUsers)
    target = user if !target
    # clears the current UI
    clearMessageWindow
    isVisible=[false,false,false,false]
    for i in 0...4
      if @sprites["battlebox#{i}"]
        isVisible[i]=@sprites["battlebox#{i}"].visible
        @sprites["battlebox#{i}"].visible=false
      end
    end
    # Substitute animation
    if @sprites["pokemon#{user.index}"] && @battle.battlescene
      subbed = @sprites["pokemon#{user.index}"].isSub
      self.setSubstitute(user.index,false) if subbed
    end
    # gets move animation def name
    anm = "pbMoveAnimationSpecific"+sprintf("%03d",moveid)
    handled = false
    #handled = pbMoveAnimationSpecific551(user.index,target.index,0,multihit)
    if @battle.battlescene
      # checks if def for specific move exists, and then plays it
      if !handled && eval("defined?(#{anm})")
        handled = eval("#{anm}(#{user.index},#{target.index},#{hitnum},#{multihit})")
      end
      # decides which global move animation to play, if any
      if !handled
        handled = playGlobalMoveAnimation(move.type,user.index,target.index,multitarget,multihit,movedata.category,hitnum)
      end
      # in case people want to use the old animation player
      if REPLACEMISSINGANIM && !handled
        animid=pbFindAnimation(moveid,user.index,hitnum)
        return if !animid
        anim=animid[0]
        animations=load_data("Data/PkmnAnimations.rxdata")
        name=PBMoves.getName(moveid)
        pbSaveShadows {
           if animid[1] # On opposing side and using OppMove animation
             pbAnimationCore(animations[anim],target,user,true,name)
           else         # On player's side, and/or using Move animation
             pbAnimationCore(animations[anim],user,target,false,name)
           end
        }
        handled = true
      end
      # if all above failed, plays the move animation for Tackle
      if !handled
        pbMoveAnimationSpecific303(user.index,target.index,0,multihit)
      end
    end
    # Change form to transformed version
    #if PBMoveData.new(moveid).function==0x69 && user && target # Transform
    #  pbChangePokemon(user,target.pokemon)
    #end
    # restores cleared UI
    for i in 0...4
      if @sprites["battlebox#{i}"]
        @sprites["battlebox#{i}"].visible=true if isVisible[i]
      end
    end
    self.afterAnim = true
  end
  #-----------------------------------------------------------------------------
  #  Cartaforbice - Paper cut
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific645(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    @vector.set(vector)
    wait(16,true)
    cx, cy = getCenter(targetsprite,true)
    fp = {}
    fp["whip"] = Sprite.new(targetsprite.viewport)
    fp["whip"].bitmap = pbBitmap("Graphics/Animations/eb645")
    fp["whip"].ox = fp["whip"].bitmap.width*0.75
    fp["whip"].oy = fp["whip"].bitmap.height*0.5
    fp["whip"].angle = 315
    fp["whip"].zoom_x = targetsprite.zoom_x*1.5
    fp["whip"].zoom_y = targetsprite.zoom_y*1.5
    fp["whip"].color = Color.new(255,255,255,0)
    fp["whip"].opacity = 0
    fp["whip"].x = cx + 32*targetsprite.zoom_x
    fp["whip"].y = cy - 48*targetsprite.zoom_y
    fp["whip"].z = player ? 29 : 19

    fp["imp"] = Sprite.new(targetsprite.viewport)
    fp["imp"].bitmap = pbBitmap("Graphics/Animations/eb645_2")
    fp["imp"].ox = fp["imp"].bitmap.width/2
    fp["imp"].oy = fp["imp"].bitmap.height/2
    fp["imp"].zoom_x = targetsprite.zoom_x*2
    fp["imp"].zoom_y = targetsprite.zoom_y*2
    fp["imp"].visible = false
    fp["imp"].x = cx
    fp["imp"].y = cy - 48*targetsprite.zoom_y
    fp["imp"].z = player ? 29 : 19

    posx = []
    posy = []
    angl = []
    zoom = []
    for j in 0...12
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb645_2")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].z = player ? 29 : 19
      fp["#{j}"].visible = false
      z = [1,1.25,0.75,0.5][rand(4)]
      fp["#{j}"].zoom_x = targetsprite.zoom_x*z
      fp["#{j}"].zoom_y = targetsprite.zoom_y*z
      fp["#{j}"].angle = rand(360)
      posx.push(rand(128))
      posy.push(rand(64))
      angl.push((rand(2)==0 ? 1 : -1))
      zoom.push(z)
      fp["#{j}"].opacity = (155+rand(100))
    end
    # start animation
    k = 1
    for i in 0...32
      pbSEPlay("eb_normal4",80) if i == 4
      if i < 16
        fp["whip"].opacity += 128 if i < 4
        fp["whip"].angle += 16
        fp["whip"].color.alpha += 16 if i >= 8
        fp["whip"].zoom_x -= 0.2 if i >= 8
        fp["whip"].zoom_y -= 0.16 if i >= 4
        fp["whip"].opacity -= 64 if i >= 12
        fp["imp"].visible = true if i == 3
        if i >= 4
          fp["imp"].angle += 4
          fp["imp"].zoom_x -= 0.02
          fp["imp"].zoom_x -= 0.02
          fp["imp"].opacity -= 32
        end
        targetsprite.zoom_y -= 0.04*k
        targetsprite.zoom_x += 0.02*k
        targetsprite.tone = Tone.new(255,255,255) if i == 4
        targetsprite.tone.red -= 51 if targetsprite.tone.red > 0
        targetsprite.tone.green -= 51 if targetsprite.tone.green > 0
        targetsprite.tone.blue -= 51 if targetsprite.tone.blue > 0
        k *= -1 if (i-4)%6==0
      end
      cx, cy = getCenter(targetsprite,true)
      for j in 0...12
        next if i < 4
        next if j>(i-4)
        fp["#{j}"].visible = true
        fp["#{j}"].x = cx - 64*targetsprite.zoom_x*zoom[j] + posx[j]*targetsprite.zoom_x*zoom[j]
        fp["#{j}"].y = cy - posy[j]*targetsprite.zoom_y*zoom[j] - 48*targetsprite.zoom_y*zoom[j]# - (i-4)*2*targetsprite.zoom_y
        fp["#{j}"].angle += angl[j]
      end
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    for i in 0...16
      wait(1,true)
      cx, cy = getCenter(targetsprite,true)
      k = 20 - i
      for j in 0...12
        fp["#{j}"].x = cx - 64*targetsprite.zoom_x*zoom[j] + posx[j]*targetsprite.zoom_x*zoom[j]
        fp["#{j}"].y = cy - posy[j]*targetsprite.zoom_y*zoom[j] - 48*targetsprite.zoom_y*zoom[j]# - (k)*2*targetsprite.zoom_y
        fp["#{j}"].opacity -= 16
        fp["#{j}"].angle += angl[j]
        fp["#{j}"].zoom_x = targetsprite.zoom_x
        fp["#{j}"].zoom_y = targetsprite.zoom_y
      end
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Piccantiro - Hot Chili Pepper
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific646(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb646_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0

    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb646")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = usersprite.z + 1
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 0.75 : 1)
    fp["cir"].zoom_y = (player ? 0.75 : 1)
    fp["cir"].opacity = 0

    shake = 4
    k = 0
    # start animation
    for i in 0...40
      if i < 8
        fp["bg"].opacity += 32
      else
        fp["bg"].color.alpha -= 32
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity += 24
      end
      if i == 8
        @vector.set(vector2)
        pbSEPlay("eb_grass2",80)
      end
      fp["bg"].update
      wait(1,true)
    end
    cx, cy = getCenter(usersprite,true)
    dx = []
    dy = []
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb646_2")
      fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
      fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
      fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
      r = 128*usersprite.zoom_x
      z = [0.5,0.25,1,0.75][rand(4)]
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{i}s"].x = cx
      fp["#{i}s"].y = cy
      fp["#{i}s"].zoom_x = z*usersprite.zoom_x
      fp["#{i}s"].zoom_y = z*usersprite.zoom_x
      fp["#{i}s"].visible = false
      fp["#{i}s"].z = usersprite.z + 1
      dx.push(x)
      dy.push(y)
    end

    fp["shot"] = Sprite.new(targetsprite.viewport)
    fp["shot"].bitmap = pbBitmap("Graphics/Animations/eb646_3")
    fp["shot"].ox = fp["shot"].bitmap.width/2
    fp["shot"].oy = fp["shot"].bitmap.height/2
    fp["shot"].z = usersprite.z + 1
    fp["shot"].zoom_x = usersprite.zoom_x
    fp["shot"].zoom_y = usersprite.zoom_x
    fp["shot"].opacity = 0

    x = defaultvector[0]; y = defaultvector[1]
    #x2, y2 = getCenter(targetsprite, true)
    #x2 = targetsprite.x
    #y2 = targetsprite.y
    x2, y2 = @vector.spoof(defaultvector)
    y2+=(player ? 0 : 40)
    x2+=(player ? 60 : 180) #Added to make the animation go over the side of the screens
    fp["shot"].x = cx
    fp["shot"].y = cy
    pbSEPlay("Voltorb Flip Explosion",80)
    k = -1
    echoln "Is player using the shooting move? #{player} X:#{x2} Y:#{y2}"
    # Shoot ball
    for i in 0...20
      cx, cy = getCenter(usersprite)
      @vector.set(defaultvector) if i == 0
      if i > 0
        fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
        #Math.atan(1.0*(cy-y2)/(x2-cx))*(180.0/Math::PI) + (player ? 180 : 0)
        fp["shot"].opacity += 32
        fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
        fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
        fp["shot"].x += (player ? -1 : 1)*(x2 - x)/24#(player ? 1 : 1)*(x2 - cx)/(player ? 72 : 24)
        fp["shot"].y -= (player ? -1 : 1)*(y - y2)/24#(player ? 1 : 1)*(cy - y2)/(player ? 72 : 24)
        for j in 0...8
          fp["#{j}s"].visible = true
          fp["#{j}s"].opacity -= 32
          fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
          fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
        end
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity -= 16
        fp["cir"].x = cx
        fp["cir"].y = cy
      end
      fp["bg"].update
      factor = targetsprite.zoom_x if i == 12
      if i >= 12
        k *= -1 if i%4==0
        targetsprite.zoom_x -= factor*0.01*k
        targetsprite.zoom_y += factor*0.04*k
        targetsprite.still
      end
      wait(1,i < 12)
    end
    shake = 2
    # Hit Target
    16.times do
      fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
      fp["shot"].x += (player ? -1 : 1)*(x2 - x)/(player ? 72 : 24)
      fp["shot"].y -= (player ? -1 : 1)*(y - y2)/(player ? 72 : 24)
      fp["bg"].color.alpha += 16
      fp["bg"].update
      targetsprite.addOx(shake)
      shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 4
      shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 4
      targetsprite.still
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    16.times do
      targetsprite.still
      wait(1,true)
    end
    16.times do
      fp["bg"].opacity -= 16
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Strettabruta - Feral Clutch
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific715(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific027(userindex,targetindex,hitnum,multihit,"feral")
  end
  #-----------------------------------------------------------------------------
  #  Flussodrago - Tidal Dragoon
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific716(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific536(userindex,targetindex,hitnum,multihit,"dragon")
  end
  #-----------------------------------------------------------------------------
  #  Nerafolgore - darkening bolt
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific717(userindex,targetindex,hitnum=0,multihit=false,beam=false,strike=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    q = 0
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    usersprite.color = Color.new(217,189,52,0) if strike
    for i in 0...8
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb717_2")
      fp["#{i}"].src_rect.set(0,0,98,430)
      fp["#{i}"].ox = fp["#{i}"].src_rect.width/2
      fp["#{i}"].oy = fp["#{i}"].src_rect.height
      fp["#{i}"].zoom_x = 0.5
      fp["#{i}"].z = 50
    end
    for i in 0...16
      fp["s#{i}"] = Sprite.new(targetsprite.viewport)
      fp["s#{i}"].bitmap = pbBitmap("Graphics/Animations/eb717_3")
      fp["s#{i}"].ox = fp["s#{i}"].bitmap.width/2
      fp["s#{i}"].oy = fp["s#{i}"].bitmap.height/2
      fp["s#{i}"].opacity = 0
      fp["s#{i}"].z = 51
    end
    m = 0
    fp["circle"] = Sprite.new(usersprite.viewport)
    fp["circle"].bitmap = pbBitmap("Graphics/Animations/eb717")
    fp["circle"].ox = fp["circle"].bitmap.width/2 + 4
    fp["circle"].oy = fp["circle"].bitmap.height/2 + 4
    fp["circle"].opacity = 0
    fp["circle"].z = 50
    fp["circle"].zoom_x = 1
    fp["circle"].zoom_y = 1
    # start animation
    @vector.set(vector)
    16.times do
      fp["bg"].opacity += 12
      wait(1,true)
    end
    cx, cy = getCenter(targetsprite,true)
    fp["circle"].x = cx
    fp["circle"].y = cy
    for i in 0...96
      for j in 0...8
        next if j>(i/4)
        if fp["#{j}"].y <= 0 && i < 32
          pbSEPlay("Thunder3",80) if i%8==0
          fp["#{j}"].x = cx - 32*targetsprite.zoom_x + rand(64)*targetsprite.zoom_x
          fp["#{j}"].src_rect.x = 98*rand(3)
          t = rand(5)*48
          fp["#{j}"].opacity = 255
          fp["#{j}"].tone = Tone.new(t,t,t)
          fp["#{j}"].mirror = (rand(2)==0 ? true : false)
        end
        fp["#{j}"].src_rect.x += 98
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= 294
        fp["#{j}"].y += (player ? @vector.y : @vector.y2)/8.0 if fp["#{j}"].y < (player ? @vector.y : @vector.y2) + 32
        fp["#{j}"].opacity -= 32 if fp["#{j}"].y >= (player ? @vector.y : @vector.y2) + 32
        fp["#{j}"].y = 0 if fp["#{j}"].opacity <= 0
      end
      for n in 0...16
        next if i < 48
        next if n>(i-48)/4
        if fp["s#{n}"].opacity == 0 && fp["s#{n}"].tone.gray == 0
          pbSEPlay("eb_electric1",60) if i%8==0
          r = rand(2); r2 = rand(4)
          fp["s#{n}"].zoom_x = [1,0.8,0.5,0.75][r2]
          fp["s#{n}"].zoom_y = [1,0.8,0.5,0.75][r2]
          fp["s#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(48)
          fp["s#{n}"].x = cx - 48*targetsprite.zoom_x + x*targetsprite.zoom_x
          fp["s#{n}"].y = cy - 48*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["s#{n}"].angle = -Math.atan(1.0*(fp["s#{n}"].y-cy)/(fp["s#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        fp["s#{n}"].opacity += 128 if fp["s#{n}"].tone.gray == 0
        fp["s#{n}"].angle += 180 if (i-16)%2==0
        fp["s#{n}"].tone.gray = 1 if fp["s#{n}"].opacity >= 255
        q += 1 if fp["s#{n}"].opacity >= 255
        fp["s#{n}"].opacity -= 51 if fp["s#{n}"].tone.gray > 0 && q > 96
      end
      fp["circle"].opacity += (i < 48 ? 32 : - 64)
      fp["circle"].angle += 64
      fp["bg"].opacity -= 32 if i >= 90
      targetsprite.still if i >= 32
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Primorgrido - Primal Scream
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific707(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific999(userindex,targetindex,hitnum,multihit,"primal")
  end
  #-----------------------------------------------------------------------------
  #  Divorastelle - Void Star
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific727(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific210(userindex,targetindex,hitnum,multihit,"star")
  end
  #-----------------------------------------------------------------------------
  #  Lancia Astrale - Astral lance
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific728(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb729_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0

    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb728")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = usersprite.z + 1
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 0.75 : 1)
    fp["cir"].zoom_y = (player ? 0.75 : 1)
    fp["cir"].opacity = 0

    shake = 4
    k = 0
    # start animation
    for i in 0...40
      if i < 8
        fp["bg"].opacity += 32
      else
        fp["bg"].color.alpha -= 32
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity += 24
      end
      if i == 8
        @vector.set(vector2)
        pbSEPlay("eb_grass2",80)
      end
      fp["bg"].update
      wait(1,true)
    end
    cx, cy = getCenter(usersprite,true)
    dx = []
    dy = []
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb728_2")
      fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
      fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
      fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
      r = 128*usersprite.zoom_x
      z = [0.5,0.25,1,0.75][rand(4)]
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{i}s"].x = cx
      fp["#{i}s"].y = cy
      fp["#{i}s"].zoom_x = z*usersprite.zoom_x
      fp["#{i}s"].zoom_y = z*usersprite.zoom_x
      fp["#{i}s"].visible = false
      fp["#{i}s"].z = usersprite.z + 1
      dx.push(x)
      dy.push(y)
    end

    fp["shot"] = Sprite.new(targetsprite.viewport)
    fp["shot"].bitmap = pbBitmap("Graphics/Animations/eb728_3")
    fp["shot"].ox = fp["shot"].bitmap.width/2
    fp["shot"].oy = fp["shot"].bitmap.height/2
    fp["shot"].z = usersprite.z + 1
    fp["shot"].zoom_x = usersprite.zoom_x
    fp["shot"].zoom_y = usersprite.zoom_x
    fp["shot"].opacity = 0

    x = defaultvector[0]; y = defaultvector[1]
    x2, y2 = @vector.spoof(defaultvector)
    y2+=(player ? 0 : 40)
    x2+=(player ? 60 : 180) #Added to make the animation go over the side of the screens
    fp["shot"].x = cx
    fp["shot"].y = cy
    pbSEPlay("eb_iron4",80)
    k = -1
    for i in 0...20
      cx, cy = getCenter(usersprite)
      @vector.set(defaultvector) if i == 0
      if i > 0
        fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
        fp["shot"].opacity += 32
        fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
        fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
        fp["shot"].x += (player ? -1 : 1)*(x2 - cx)/24
        fp["shot"].y -= (player ? -1 : 1)*(cy - y2)/24
        for j in 0...8
          fp["#{j}s"].visible = true
          fp["#{j}s"].opacity -= 32
          fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
          fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
        end
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity -= 16
        fp["cir"].x = cx
        fp["cir"].y = cy
      end
      fp["bg"].update
      factor = targetsprite.zoom_x if i == 12
      if i >= 12
        k *= -1 if i%4==0
        targetsprite.zoom_x -= factor*0.01*k
        targetsprite.zoom_y += factor*0.04*k
        targetsprite.still
      end
      wait(1,i < 12)
    end
    shake = 2
    16.times do
      fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
      fp["shot"].x += (player ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (player ? -1 : 1)*(y - y2)/24
      fp["bg"].color.alpha += 16
      fp["bg"].update
      targetsprite.addOx(shake)
      shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 4
      shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 4
      targetsprite.still
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    16.times do
      targetsprite.still
      wait(1,true)
    end
    16.times do
      fp["bg"].opacity -= 16
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ipernova Shyleon
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific729(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb729_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb263_4")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    for i in 0...72
      fp["#{i}2"] = Sprite.new(targetsprite.viewport)
      fp["#{i}2"].bitmap = pbBitmap("Graphics/Animations/eb729_3")
      fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
      fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
      fp["#{i}2"].opacity = 0
      fp["#{i}2"].z = 19
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb263")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].zoom_x = player ? 0.5 : 1
    fp["cir"].zoom_y = player ? 0.5 : 1
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb263_2")
      fp["#{i}s"].ox = -32 -rand(64)
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
      fp["#{i}s"].angle = rand(270)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    # start animation
    @vector.set(vector2)
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      pbSEPlay("Harden") if i == 4
      fp["bg"].update
      wait(1,true)
    end
    wait(4,true)
    pbSEPlay("Psych Up")
    for i in 0...96
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
        next if j>(i)
        cx, cy = getCenter(usersprite)
        x0 = dx[j]
        y0 = dy[j]
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].opacity += 51
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          #fp["#{j}"].visible = false if nextx > cx && nexty < cy
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
        else
          #fp["#{j}"].visible = false if nextx < cx && nexty > cy
          fp["#{j}"].z = targetsprite.z + 1 if nextx < cx && nexty > cy
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      end
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      pbSEPlay("Comet Punch") if i == 64
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 32
      fp["cir"].opacity += (i>72) ? -51 : 255
      fp["bg"].update
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    fp["cir"].opacity = 0
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ipernova Trishout
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific730(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb729_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb263_4")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    for i in 0...72
      fp["#{i}2"] = Sprite.new(targetsprite.viewport)
      fp["#{i}2"].bitmap = pbBitmap("Graphics/Animations/eb730_3")
      fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
      fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
      fp["#{i}2"].opacity = 0
      fp["#{i}2"].z = 19
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb263")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].zoom_x = player ? 0.5 : 1
    fp["cir"].zoom_y = player ? 0.5 : 1
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb263_2")
      fp["#{i}s"].ox = -32 -rand(64)
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
      fp["#{i}s"].angle = rand(270)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    # start animation
    @vector.set(vector2)
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      pbSEPlay("Harden") if i == 4
      fp["bg"].update
      wait(1,true)
    end
    wait(4,true)
    pbSEPlay("Psych Up")
    for i in 0...96
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
        next if j>(i)
        cx, cy = getCenter(usersprite)
        x0 = dx[j]
        y0 = dy[j]
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].opacity += 51
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          #fp["#{j}"].visible = false if nextx > cx && nexty < cy
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
        else
          #fp["#{j}"].visible = false if nextx < cx && nexty > cy
          fp["#{j}"].z = targetsprite.z + 1 if nextx < cx && nexty > cy
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      end
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      pbSEPlay("Comet Punch") if i == 64
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 32
      fp["cir"].opacity += (i>72) ? -51 : 255
      fp["bg"].update
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    fp["cir"].opacity = 0
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ipernova Shulong
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific731(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb729_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb263_4")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    for i in 0...72
      fp["#{i}2"] = Sprite.new(targetsprite.viewport)
      fp["#{i}2"].bitmap = pbBitmap("Graphics/Animations/eb731_3")
      fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
      fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
      fp["#{i}2"].opacity = 0
      fp["#{i}2"].z = 19
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb263")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].zoom_x = player ? 0.5 : 1
    fp["cir"].zoom_y = player ? 0.5 : 1
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb263_2")
      fp["#{i}s"].ox = -32 -rand(64)
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
      fp["#{i}s"].angle = rand(270)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    # start animation
    @vector.set(vector2)
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      pbSEPlay("Harden") if i == 4
      fp["bg"].update
      wait(1,true)
    end
    wait(4,true)
    pbSEPlay("Psych Up")
    for i in 0...96
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
        next if j>(i)
        cx, cy = getCenter(usersprite)
        x0 = dx[j]
        y0 = dy[j]
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].opacity += 51
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          #fp["#{j}"].visible = false if nextx > cx && nexty < cy
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
        else
          #fp["#{j}"].visible = false if nextx < cx && nexty > cy
          fp["#{j}"].z = targetsprite.z + 1 if nextx < cx && nexty > cy
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      end
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      pbSEPlay("Comet Punch") if i == 64
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 32
      fp["cir"].opacity += (i>72) ? -51 : 255
      fp["bg"].update
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    fp["cir"].opacity = 0
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Generic phisical fairy move
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific996(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    fp = {}
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb_fairy_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    @vector.set(vector)
    for i in 0...16
      fp["bg"].opacity += 32 if i >= 8
      wait(1,true)
    end
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    for j in 0...12
      fp["f#{j}"] = Sprite.new(targetsprite.viewport)
      fp["f#{j}"].bitmap = pbBitmap("Graphics/Animations/eb_fairy")
      fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
      fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
      fp["f#{j}"].z = targetsprite.z + 1
      r = 32*factor
      fp["f#{j}"].x = cx - r + rand(r*2)
      fp["f#{j}"].y = cy - r + rand(r*2)
      fp["f#{j}"].visible = false
      fp["f#{j}"].zoom_x = factor
      fp["f#{j}"].zoom_y = factor
      fp["f#{j}"].color = Color.new(180,53,2,0)
    end
    dx = []
    dy = []
    for j in 0...96
      fp["p#{j}"] = Sprite.new(targetsprite.viewport)
      fp["p#{j}"].bitmap = pbBitmap("Graphics/Animations/eb_fairy_2")
      fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
      fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
      fp["p#{j}"].z = targetsprite.z
      r = 148*factor + rand(32)*factor
      x, y = randCircleCord(r)
      fp["p#{j}"].x = cx
      fp["p#{j}"].y = cy
      fp["p#{j}"].visible = false
      fp["p#{j}"].zoom_x = factor
      fp["p#{j}"].zoom_y = factor
      fp["p#{j}"].color = Color.new(180,53,2,0)
      dx.push(cx - r + x)
      dy.push(cy - r + y)
    end
    k = -4
    for i in 0...72
      k *= - 1 if i%4==0
      fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
      for j in 0...12
        next if j>(i/4)
        pbSEPlay("hit",80) if fp["f#{j}"].opacity == 255
        fp["f#{j}"].visible = true
        fp["f#{j}"].zoom_x -= 0.025
        fp["f#{j}"].zoom_y -= 0.025
        fp["f#{j}"].opacity -= 16
        fp["f#{j}"].color.alpha += 32
      end
      for j in 0...96
        next if j>(i*2)
        fp["p#{j}"].visible = true
        fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
        fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
        fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
        fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
        fp["p#{j}"].zoom_x += 0.1
        fp["p#{j}"].zoom_y += 0.1
        fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
      end
      fp["bg"].update
      targetsprite.still
      targetsprite.zoom_x -= factor*0.01*k if i < 56
      targetsprite.zoom_y += factor*0.02*k if i < 56
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    16.times do
      fp["bg"].color.alpha += 16
      fp["bg"].opacity -= 16
      fp["bg"].update
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Generical special fairy move
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific997(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb997_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0

    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb997")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = usersprite.z + 1
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 0.75 : 1)
    fp["cir"].zoom_y = (player ? 0.75 : 1)
    fp["cir"].opacity = 0

    shake = 4
    k = 0
    # start animation
    for i in 0...40
      if i < 8
        fp["bg"].opacity += 32
      else
        fp["bg"].color.alpha -= 32
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity += 24
      end
      if i == 8
        @vector.set(vector2)
        pbSEPlay("eb_grass2",80)
      end
      fp["bg"].update
      wait(1,true)
    end
    cx, cy = getCenter(usersprite,true)
    dx = []
    dy = []
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb997_2")
      fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
      fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
      fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
      r = 128*usersprite.zoom_x
      z = [0.5,0.25,1,0.75][rand(4)]
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{i}s"].x = cx
      fp["#{i}s"].y = cy
      fp["#{i}s"].zoom_x = z*usersprite.zoom_x
      fp["#{i}s"].zoom_y = z*usersprite.zoom_x
      fp["#{i}s"].visible = false
      fp["#{i}s"].z = usersprite.z + 1
      dx.push(x)
      dy.push(y)
    end

    fp["shot"] = Sprite.new(targetsprite.viewport)
    fp["shot"].bitmap = pbBitmap("Graphics/Animations/eb997_3")
    fp["shot"].ox = fp["shot"].bitmap.width/2
    fp["shot"].oy = fp["shot"].bitmap.height/2
    fp["shot"].z = usersprite.z + 1
    fp["shot"].zoom_x = usersprite.zoom_x
    fp["shot"].zoom_y = usersprite.zoom_x
    fp["shot"].opacity = 0

    x = defaultvector[0]; y = defaultvector[1]
    x2, y2 = @vector.spoof(defaultvector)
    y2+=(player ? 0 : 40)
    x2+=(player ? 60 : 180) #Added to make the animation go over the side of the screens
    fp["shot"].x = cx
    fp["shot"].y = cy
    pbSEPlay("eb_normal5",80)
    k = -1
    for i in 0...20
      cx, cy = getCenter(usersprite)
      @vector.set(defaultvector) if i == 0
      if i > 0
        fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
        fp["shot"].opacity += 32
        fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
        fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
        fp["shot"].x += (player ? -1 : 1)*(x2 - cx)/24
        fp["shot"].y -= (player ? -1 : 1)*(cy - y2)/24
        for j in 0...8
          fp["#{j}s"].visible = true
          fp["#{j}s"].opacity -= 32
          fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
          fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
        end
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity -= 16
        fp["cir"].x = cx
        fp["cir"].y = cy
      end
      fp["bg"].update
      factor = targetsprite.zoom_x if i == 12
      if i >= 12
        k *= -1 if i%4==0
        targetsprite.zoom_x -= factor*0.01*k
        targetsprite.zoom_y += factor*0.04*k
        targetsprite.still
      end
      wait(1,i < 12)
    end
    shake = 2
    16.times do
      fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
      fp["shot"].x += (player ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (player ? -1 : 1)*(y - y2)/24
      fp["bg"].color.alpha += 16
      fp["bg"].update
      targetsprite.addOx(shake)
      shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 4
      shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 4
      targetsprite.still
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    16.times do
      targetsprite.still
      wait(1,true)
    end
    16.times do
      fp["bg"].opacity -= 16
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Generic phisical sound move
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific998(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    pbSEPlay("eb_flying1",80)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    cx, cy = getCenter(targetsprite,true)
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb303_2")
      fp["#{i}"].ox = 10
      fp["#{i}"].oy = 10
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 51
      r = rand(3)
      fp["#{i}"].zoom_x = (factor-0.5)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (factor-0.5)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(64))
    end
    wait = []
    for m in 0...8
      fp["w#{m}"] = Sprite.new(targetsprite.viewport)
      fp["w#{m}"].bitmap = pbBitmap("Graphics/Animations/eb_suono_2.png")
      fp["w#{m}"].ox = 20
      fp["w#{m}"].oy = 16
      fp["w#{m}"].opacity = 0
      fp["w#{m}"].z = 50
      fp["w#{m}"].angle = rand(360)
      fp["w#{m}"].zoom_x = factor - 0.5
      fp["w#{m}"].zoom_y = factor - 0.5
      fp["w#{m}"].x = cx - 32*factor + rand(64*factor)
      fp["w#{m}"].y = cy - 112*factor + rand(112*factor)
      wait.push(0)
    end
    pbSEPlay("eb_normal1",80)
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 51
    frame.bitmap = pbBitmap("Graphics/Animations/eb303")
    frame.src_rect.set(0,0,64,64)
    frame.ox = 32
    frame.oy = 32
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    frame.y -= 32*targetsprite.zoom_y
    # start animation
    for i in 1..30
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 64 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for m in 0...8
        next if m>(i/2)
        fp["w#{m}"].angle += 2
        fp["w#{m}"].opacity += 32*(wait[m] < 8 ? 1 : -0.25)
        wait[m] +=  1
      end
      for j in 0...12
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Generic special sound move
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific999(userindex,targetindex,hitnum=0,multihit=false,type="default")
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap(type == "primal" ? "Graphics/Animations/eb707_bg" : "Graphics/Animations/eb_suono_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...128
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap(type == "primal" ? "Graphics/Animations/eb707_2" : "Graphics/Animations/eb_suono_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].visible = false
      fp["#{i}"].z = 50
      rndx.push(rand(256)); prndx.push(rand(72))
      rndy.push(rand(256)); prndy.push(rand(72))
      rangl.push(rand(9))
      dx.push(0)
      dy.push(0)
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap(type == "primal" ? "Graphics/Animations/eb707" : "Graphics/Animations/eb_suono")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 1 : 1.5)*0.5
    fp["cir"].zoom_y = (player ? 1 : 1.5)*0.5
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb_suono_3")
      fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
      fp["#{i}s"].angle = rand(360)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    k = 0
    # start animation
    @vector.set(vector2)
    for i in 0...30
      if i < 10
        fp["bg"].opacity += 25.5
      elsif i < 20
        fp["bg"].color.alpha -= 25.5
      else
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 16*(player2 ? -1 : 1)
        fp["cir"].opacity += 25.5
        fp["cir"].zoom_x += (player ? 1 : 1.5)*0.05
        fp["cir"].zoom_y += (player ? 1 : 1.5)*0.05
        k += 1 if i%4==0; k = 0 if k > 1
        fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
      end
      pbSEPlay("eb_grass2") if i == 20
      fp["bg"].update
      wait(1,true)
    end
    pbSEPlay("eb_wind1",90)
    for i in 0...96
      pbSEPlay("eb_grass1",60) if i%3==0 && i < 64
      for j in 0...128
        next if j>(i*2)
        if !fp["#{j}"].visible
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 46*usersprite.zoom_x*0.5 + prndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 46*usersprite.zoom_y*0.5 + prndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
          fp["#{j}"].visible = true
        end
        cx, cy = getCenter(usersprite)
        x0 = cx - 46*usersprite.zoom_x*0.5 + prndx[j]*usersprite.zoom_x*0.5
        y0 = cy - 46*usersprite.zoom_y*0.5 + prndy[j]*usersprite.zoom_y*0.5
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 128*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 128*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].angle += rangl[j]*2
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
        else
          fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
        end
      end
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 16*(player2 ? -1 : 1)
      fp["cir"].opacity -= (i>=72) ? 51 : 2
      k += 1 if i%4==0; k = 0 if k > 1
      fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      #pbSEPlay("Comet Punch") if i == 64
      fp["bg"].update
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end

  #-----------------------------------------------------------------------------
  #  Bug Bite
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific008(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    # set up animation
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    fp = {}
    dx = []
    dy = []
    da = []
    for j in 0...12
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb008")
      fp["s#{j}"].src_rect.set(32*rand(2),0,32,32)
      fp["s#{j}"].ox = fp["s#{j}"].src_rect.width/2
      fp["s#{j}"].oy = fp["s#{j}"].src_rect.height/2
      r = 32*factor
      fp["s#{j}"].x = cx - r + rand(r*2)
      fp["s#{j}"].y = cy - r + rand(r*2)
      fp["s#{j}"].z = targetsprite.z + 1
      fp["s#{j}"].visible = false
    end
    for j in 0...32
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb008_2")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      r = 32*factor
      x = cx - r + rand(r*2)
      y = cy - r + rand(r)
      fp["#{j}"].x = x
      fp["#{j}"].y = y
      fp["#{j}"].z = targetsprite.z
      fp["#{j}"].visible = false
      fp["#{j}"].angle = rand(360)
      ox = (x < cx ? x-rand(24*factor)-24*factor : x+rand(24*factor)+24*factor)
      oy = y - rand(24*factor) - 24*factor
      dx.push(ox)
      dy.push(oy)
      a = (x < cx ? rand(6)+1 : -rand(6)-1)
      da.push(a)
    end
    # play animation
    for i in 0...64
      for j in 0...32
        next if j>i
        fp["#{j}"].visible = true
        if ((fp["#{j}"].x - dx[j])*0.2).abs < 1
          fp["#{j}"].y += 4
          fp["#{j}"].opacity -= 16
        else
          fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.2
          fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.2
        end
        fp["#{j}"].angle += da[j]*8
      end
      for j in 0...12
        next if j>(i/4)
        fp["s#{j}"].visible = true
        fp["s#{j}"].opacity -= 32
        fp["s#{j}"].zoom_x += 0.02
        fp["s#{j}"].zoom_y += 0.02
        fp["s#{j}"].angle += 8
      end
      targetsprite.zoom_y = factor + 0.32 if i%4 == 0 && i < 48
      targetsprite.zoom_y -= 0.08 if targetsprite.zoom_y > factor
      pbSEPlay("eb_bug1",80) if i%4==0 && i < 48
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Struggle Bug
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific010(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # configure animation
    @vector.set(getRealVector(userindex,player2))
    wait(16,true)
    factor = usersprite.zoom_x
    cx, cy = getCenter(usersprite,true)
    dx = []
    dy = []
    fp = {}
    for j in 0...24
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb010")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      r = 64*factor
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{j}"].x = cx
      fp["#{j}"].y = cx
      fp["#{j}"].z = usersprite.z
      fp["#{j}"].visible = false
      fp["#{j}"].angle = rand(360)
      z = [0.5,1,0.75][rand(3)]
      fp["#{j}"].zoom_x = z
      fp["#{j}"].zoom_y = z
      dx.push(x)
      dy.push(y)
    end
    # start animation
    pbSEPlay("eb_ground1",80)
    for i in 0...48
      for j in 0...24
        next if j>(i*2)
        fp["#{j}"].visible = true
        if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
          fp["#{j}"].opacity -= 32
        else
          fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
          fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
        end
      end
      wait(1)
    end
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    for j in 0...12
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb244_2")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
      r = 32*factor
      fp["s#{j}"].x = cx - r + rand(r*2)
      fp["s#{j}"].y = cy - r + rand(r*2)
      fp["s#{j}"].z = targetsprite.z + 1
      fp["s#{j}"].visible = false
      fp["s#{j}"].tone = Tone.new(255,255,255)
      fp["s#{j}"].angle = rand(360)
    end
    # anim2
    for i in 0...32
      for j in 0...12
        next if j>(i*2)
        fp["s#{j}"].visible = true
        fp["s#{j}"].opacity -= 32
        fp["s#{j}"].zoom_x += 0.02
        fp["s#{j}"].zoom_y += 0.02
        fp["s#{j}"].angle += 8
        fp["s#{j}"].tone.red -= 32
        fp["s#{j}"].tone.green -= 32
        fp["s#{j}"].tone.blue -= 32
      end
      targetsprite.still
      pbSEPlay("eb_normal2",80) if i%4==0 && i < 16
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Crunch
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific024(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
    fp["bg"].opacity = 0
    for i in 0...10
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb024")
      fp["#{i}"].ox = 6
      fp["#{i}"].oy = 5
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)
      rndx.push(rand(128))
      rndy.push(rand(128))
    end
    fp["fang1"] = Sprite.new(targetsprite.viewport)
    fp["fang1"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang1"].ox = fp["fang1"].bitmap.width/2
    fp["fang1"].oy = fp["fang1"].bitmap.height - 20
    fp["fang1"].opacity = 0
    fp["fang1"].z = 41
    fp["fang2"] = Sprite.new(targetsprite.viewport)
    fp["fang2"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang2"].ox = fp["fang1"].bitmap.width/2
    fp["fang2"].oy = fp["fang1"].bitmap.height - 20
    fp["fang2"].opacity = 0
    fp["fang2"].z = 40
    fp["fang2"].angle = 180
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["fang1"].x = cx; fp["fang1"].y = cy
      fp["fang1"].zoom_x = targetsprite.zoom_x; fp["fang1"].zoom_y = targetsprite.zoom_y
      fp["fang2"].x = cx; fp["fang2"].y = cy
      fp["fang2"].zoom_x = targetsprite.zoom_x; fp["fang2"].zoom_y = targetsprite.zoom_y
      if i.between?(20,29)
        fp["fang1"].opacity += 5
        fp["fang1"].oy += 2
        fp["fang2"].opacity += 5
        fp["fang2"].oy += 2
      elsif i.between?(30,40)
        fp["fang1"].opacity += 25.5
        fp["fang1"].oy -= 4
        fp["fang2"].opacity += 25.5
        fp["fang2"].oy -= 4
      else i > 40
        fp["fang1"].opacity -= 26
        fp["fang1"].oy += 2
        fp["fang2"].opacity -= 26
        fp["fang2"].oy += 2
      end
      if i==32
        pbSEPlay("Super Fang")
      end
      for j in 0...10
        next if i < 40
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].angle += 16
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.001
        fp["#{j}"].zoom_y += 0.001
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 32
        else
          fp["#{j}"].opacity += 45
          fp["#{j}"].angle += 16
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        if i >= 56
          targetsprite.tone.red -= 3*2
          targetsprite.tone.green -= 3*2
          targetsprite.tone.blue -= 3*2
          fp["bg"].opacity -= 10
        else
          targetsprite.tone.red += 3*2 if targetsprite.tone.red < 48*2
          targetsprite.tone.green += 3*2 if targetsprite.tone.green < 48*2
          targetsprite.tone.blue += 3*2 if targetsprite.tone.blue < 48*2
        end
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Night Slash
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific027(userindex,targetindex,hitnum=0,multihit=false,type="default")
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    # set up animation
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    fp = {}
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap(type == "feral" ? "Graphics/Animations/eb715_bg" : "Graphics/Animations/eb027_bg")
    fp["bg"].opacity = 0
    fp["bg"].z = 50
    for j in 0...12
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb027_2")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
      r = 128*factor
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      z = [1,0.75,0.5][rand(3)]
      fp["s#{j}"].zoom_x = z
      fp["s#{j}"].zoom_y = z
      fp["s#{j}"].x = cx
      fp["s#{j}"].y = cy
      fp["s#{j}"].z = targetsprite.z + 1
      fp["s#{j}"].visible = false
      dx.push(x)
      dy.push(y)
    end
    fp["slash"] = Sprite.new(targetsprite.viewport)
    fp["slash"].bitmap = pbBitmap(type == "feral" ? "Graphics/Animations/eb715" : "Graphics/Animations/eb027")
    fp["slash"].oy = fp["slash"].bitmap.height/2
    fp["slash"].y = cy
    fp["slash"].x = targetsprite.viewport.rect.width
    fp["slash"].opacity = 0
    fp["slash"].z = 50
    # play animation
    pbSEPlay("gust",90)
    for m in 0...2
      shake = 2
      for i in 0...(m < 1 ? 32 : 16)
        fp["bg"].opacity += 16 if m < 1
        fp["bg"].update
        if m < 1
          fp["slash"].x -= 64 if i >= 28
          fp["slash"].opacity += 64 if i >= 28
        else
          fp["slash"].x += 64 if i >= 12
          fp["slash"].opacity += 64 if i >= 12
        end
        wait(1,true)
      end
      pbSEPlay("hit")
      for i in 0...16
        fp["bg"].opacity -= 16
        for j in 0...12
          fp["s#{j}"].visible = true
          fp["s#{j}"].x -= (fp["s#{j}"].x - dx[j])*0.1
          fp["s#{j}"].y -= (fp["s#{j}"].y - dy[j])*0.1
          fp["s#{j}"].zoom_x -= 0.04
          fp["s#{j}"].zoom_y -= 0.04
          fp["s#{j}"].tone.gray += 16
          fp["s#{j}"].tone.red -= 8
          fp["s#{j}"].tone.green -= 8
          fp["s#{j}"].tone.blue -= 8
          fp["s#{j}"].opacity -= 16
        end
        if m < 1
          fp["slash"].x -= 64
        else
          fp["slash"].x += 64
        end
        fp["slash"].opacity -= 32
        targetsprite.addOx(shake)
        shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
        wait(1)
      end
      targetsprite.ox = targetsprite.bitmap.width/2
      dx.clear
      dy.clear
      fp["slash"].mirror = true
      fp["slash"].ox = fp["slash"].bitmap.width
      fp["slash"].opacity = 0
      fp["slash"].x = 0
      for j in 0...12
        fp["s#{j}"].x = cx
        fp["s#{j}"].y = cy
        fp["s#{j}"].tone = Tone.new(0,0,0,0)
        fp["s#{j}"].opacity = 255
        fp["s#{j}"].visible = false
        z = [1,0.75,0.5][rand(3)]
        fp["s#{j}"].zoom_x = z
        fp["s#{j}"].zoom_y = z
        r = 128*factor
        x, y = randCircleCord(r)
        x = cx - r + x
        y = cy - r + y
        dx.push(x)
        dy.push(y)
      end
    end
    wait(8)
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Bite
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific028(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
    fp["bg"].opacity = 0
    fp["fang1"] = Sprite.new(targetsprite.viewport)
    fp["fang1"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang1"].ox = fp["fang1"].bitmap.width/2
    fp["fang1"].oy = fp["fang1"].bitmap.height - 20
    fp["fang1"].opacity = 0
    fp["fang1"].z = 41
    fp["fang2"] = Sprite.new(targetsprite.viewport)
    fp["fang2"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang2"].ox = fp["fang1"].bitmap.width/2
    fp["fang2"].oy = fp["fang1"].bitmap.height - 20
    fp["fang2"].opacity = 0
    fp["fang2"].z = 40
    fp["fang2"].angle = 180
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["fang1"].x = cx; fp["fang1"].y = cy
      fp["fang1"].zoom_x = targetsprite.zoom_x; fp["fang1"].zoom_y = targetsprite.zoom_y
      fp["fang2"].x = cx; fp["fang2"].y = cy
      fp["fang2"].zoom_x = targetsprite.zoom_x; fp["fang2"].zoom_y = targetsprite.zoom_y
      if i.between?(20,29)
        fp["fang1"].opacity += 5
        fp["fang1"].oy += 2
        fp["fang2"].opacity += 5
        fp["fang2"].oy += 2
      elsif i.between?(30,40)
        fp["fang1"].opacity += 25.5
        fp["fang1"].oy -= 4
        fp["fang2"].opacity += 25.5
        fp["fang2"].oy -= 4
      else i > 40
        fp["fang1"].opacity -= 26
        fp["fang1"].oy += 2
        fp["fang2"].opacity -= 26
        fp["fang2"].oy += 2
      end
      if i==32
        pbSEPlay("Super Fang")
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        fp["bg"].opacity -= 10 if i >= 56
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Dragon Claw
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific057(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    # set up animation
    fp = {}
    speed = []
    for j in 0...32
      fp["#{j}"] = Sprite.new(usersprite.viewport)
      fp["#{j}"].z = player2 ? 29 : 19
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb057")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].color = Color.new(255,255,255,255)
      z = [0.5,1.5,1,0.75,1.25][rand(5)]
      fp["#{j}"].zoom_x = z
      fp["#{j}"].zoom_y = z
      fp["#{j}"].opacity = 0
      speed.push((rand(8)+1)*4)
    end
    for j in 0...8
      fp["s#{j}"] = Sprite.new(usersprite.viewport)
      fp["s#{j}"].z = player2 ? 29 : 19
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb057_2")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
      #z = [0.5,1.5,1,0.75,1.25][rand(5)]
      fp["s#{j}"].color = Color.new(255,255,255,255)
      #fp["s#{j}"].zoom_y = z
      fp["s#{j}"].opacity = 0
    end
    usersprite.color = Color.new(255,0,0,0)
    # start animation
    @vector.set(vector2)
    @vector.inc = 0.1
    oy = usersprite.oy
    k = -1
    for i in 0...64
      k *= -1 if i%4==0
      pbSEPlay("eb_dragon2") if i == 12
      cx, cy = getCenter(usersprite,true)
      for j in 0...32
        next if i < 8
        next if j>(i-8)
        if fp["#{j}"].opacity == 0 && fp["#{j}"].color.alpha == 255
          fp["#{j}"].y = usersprite.y + 8*usersprite.zoom_y - rand(24)*usersprite.zoom_y
          fp["#{j}"].x = cx - 64*usersprite.zoom_x + rand(128)*usersprite.zoom_x
        end
        if fp["#{j}"].color.alpha <= 96
          fp["#{j}"].opacity -= 32
        else
          fp["#{j}"].opacity += 32
        end
        fp["#{j}"].color.alpha -= 16
        fp["#{j}"].y -= speed[j]
      end
      for j in 0...8
        next if i < 12
        next if j>(i-12)/2
        if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
          fp["s#{j}"].y = usersprite.y + 48*usersprite.zoom_y - rand(16)*usersprite.zoom_y
          fp["s#{j}"].x = cx - 64*usersprite.zoom_x + rand(128)*usersprite.zoom_x
        end
        if fp["s#{j}"].color.alpha <= 96
          fp["s#{j}"].opacity -= 32
        else
          fp["s#{j}"].opacity += 32
        end
        fp["s#{j}"].color.alpha -= 16
        fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
        fp["s#{j}"].y -= speed[j]
      end
      if i < 48
        usersprite.color.alpha += 4
      else
        usersprite.color.alpha -= 16
      end
      usersprite.oy -= 2*k if i%2==0
      usersprite.still
      usersprite.anim = true
      wait(1,true)
    end
    usersprite.oy = oy
    @vector.set(vector)
    @vector.inc = 0.2
    wait(16,true)
    cx, cy = getCenter(targetsprite,true)
    fp["claw1"] = Sprite.new(targetsprite.viewport)
    fp["claw1"].bitmap = pbBitmap("Graphics/Animations/eb057_3")
    fp["claw1"].src_rect.set(-82,0,82,174)
    fp["claw1"].ox = fp["claw1"].src_rect.width
    fp["claw1"].oy = fp["claw1"].src_rect.height/2
    fp["claw1"].x = cx - 32*targetsprite.zoom_x
    fp["claw1"].y = cy
    fp["claw1"].z = player ? 29 : 19
    fp["claw2"] = Sprite.new(targetsprite.viewport)
    fp["claw2"].bitmap = pbBitmap("Graphics/Animations/eb057_3")
    fp["claw2"].src_rect.set(-82,0,82,174)
    fp["claw2"].ox = 0
    fp["claw2"].oy = fp["claw2"].src_rect.height/2
    fp["claw2"].x = cx + 32*targetsprite.zoom_x
    fp["claw2"].y = cy
    fp["claw2"].z = player ? 29 : 19
    fp["claw2"].mirror = true
    shake = 4
    for i in 0...32
      targetsprite.still
      pbSEPlay("Slash10") if i == 4 || i == 16
      for j in 1..2
        next if (j-1)>(i/12)
        fp["claw#{j}"].src_rect.x += 82 if fp["claw#{j}"].src_rect.x < 82*3 && i%2==0
      end
      fp["claw1"].visible = false if i == 16
      fp["claw2"].visible = false if i == 32
      if i.between?(4,12) || i.between?(20,28)
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Dragon Breath
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific059(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    targetsprite.color = Color.new(255,0,0,0)
    for m in 0...2
      rndx.push([]); rndy.push([]); dx.push([]); dy.push([])
      for i in 0...96
        str = ["","_2"][rand(2)]
        str = "Graphics/Animations/eb59"+str
        str = "Graphics/Animations/eb59_3" if m == 1
        fp["#{i}#{m}"] = Sprite.new(targetsprite.viewport)
        fp["#{i}#{m}"].bitmap = pbBitmap(str)
        fp["#{i}#{m}"].ox = fp["#{i}#{m}"].bitmap.width/2
        fp["#{i}#{m}"].oy = fp["#{i}#{m}"].bitmap.height/2
        fp["#{i}#{m}"].angle = rand(360)
        fp["#{i}#{m}"].opacity = 0
        if m == 0
          fp["#{i}#{m}"].zoom_x = 0.8
          fp["#{i}#{m}"].zoom_y = 0.8
        end
        fp["#{i}#{m}"].z = player ? 29 : 19
        rndx[m].push(rand([16,128][m]))
        rndy[m].push(rand([16,128][m]))
        dx[m].push(0)
        dy[m].push(0)
      end
    end
    shake = 4
    # start animation
    for i in 0...96
      pbSEPlay("eb_dragon2") if i==8
      pbSEPlay("eb_dragon1") if i==74
      for m in 0...2
        for j in 0...96
          next if j>(i*2)
          if fp["#{j}#{m}"].opacity == 0 && fp["#{j}#{m}"].tone.gray == 0
            cx, cy = getCenter(usersprite,true)
            dx[m][j] = cx - [8,64][m]*usersprite.zoom_x*0.5 + rndx[m][j]*usersprite.zoom_x*0.5
            dy[m][j] = cy - [8,64][m]*usersprite.zoom_y*0.5 + rndy[m][j]*usersprite.zoom_y*0.5
            fp["#{j}#{m}"].x = dx[m][j]
            fp["#{j}#{m}"].y = dy[m][j]
            if m == 1
              fp["#{j}#{m}"].opacity = 55 + rand(151)
              z = [0.5,0.75,1,0.3][rand(4)]
              fp["#{j}#{m}"].zoom_x = z
              fp["#{j}#{m}"].zoom_y = z
            end
          end
          cx, cy = getCenter(usersprite,true)
          x0 = dx[m][j]
          y0 = dy[m][j]
          cx, cy = getCenter(targetsprite,true)
          x2 = cx - [8,64][m]*targetsprite.zoom_x*0.5 + rndx[m][j]*targetsprite.zoom_x*0.5
          y2 = cy - [8,64][m]*targetsprite.zoom_y*0.5 + rndy[m][j]*targetsprite.zoom_y*0.5
          fp["#{j}#{m}"].x += (x2 - x0)*0.1
          fp["#{j}#{m}"].y += (y2 - y0)*0.1
          fp["#{j}#{m}"].opacity += 51 if m == 0
          fp["#{j}#{m}"].zoom_x += 0.04 if m == 0
          fp["#{j}#{m}"].zoom_y += 0.04 if m == 0
          nextx = fp["#{j}#{m}"].x# + (x2 - x0)*0.1
          nexty = fp["#{j}#{m}"].y# + (y2 - y0)*0.1
          if !player
            if nextx > cx && nexty < cy
              fp["#{j}#{m}"].visible = false if m == 0
              fp["#{j}#{m}"].opacity -= 75 if m == 1
              fp["#{j}#{m}"].tone.gray = 1 if m == 1
            end
          else
            if nextx < cx && nexty > cy
              fp["#{j}#{m}"].visible = false if m == 0
              fp["#{j}#{m}"].opacity -= 75 if m == 1
              fp["#{j}#{m}"].tone.gray = 1 if m == 1
            end
          end
        end
      end
      if i >= 58 && i < 74
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.color.alpha += 12
        targetsprite.still
      end
      targetsprite.zoom_y += 0.16 if i == 74
      if i >= 74 && i < 90
        targetsprite.color.alpha -= 12
        targetsprite.ox = targetsprite.bitmap.width/2
        targetsprite.still
        targetsprite.zoom_y -= 0.01
      end
      targetsprite.anim = true
      @vector.set(DUALVECTOR) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,!(i >= 74 && i < 90))
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Bolt Strike
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific064(userindex,targetindex,hitnum=0,multihit=false)
    # Charging animation
    pbMoveAnimationSpecific081(userindex,targetindex,hitnum,multihit,false,true)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1.5
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg2"] = Sprite.new(targetsprite.viewport)
    fp["bg2"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg2"].bitmap.stretch_blt(Rect.new(0,0,fp["bg2"].bitmap.width,fp["bg2"].bitmap.height),pbBitmap("Graphics/Animations/eb064_bg"),Rect.new(0,0,512,384))
    fp["bg2"].opacity = 0
    l = 0
    m = 0
    q = 0
    for i in 0...24
      fp["c#{i}"] = Sprite.new(targetsprite.viewport)
      fp["c#{i}"].bitmap = pbBitmap("Graphics/Animations/eb081")
      fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
      fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
      fp["c#{i}"].opacity = 0
      fp["c#{i}"].z = 51
      rndx.push(rand(256))
      rndy.push(rand(256))
    end
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb064_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 51
    end
    fp["circle"] = Sprite.new(targetsprite.viewport)
    fp["circle"].bitmap = pbBitmap("Graphics/Animations/eb081_3")
    fp["circle"].src_rect.set(0,0,fp["circle"].bitmap.width/2,fp["circle"].bitmap.height)
    fp["circle"].ox = fp["circle"].src_rect.width/2
    fp["circle"].oy = fp["circle"].src_rect.height/2
    fp["circle"].opacity = 0
    fp["circle"].z = targetsprite.z + 1

    fp["half"] = Sprite.new(targetsprite.viewport)
    fp["half"].bitmap = pbBitmap("Graphics/Animations/eb064")
    fp["half"].ox = fp["half"].src_rect.width/2
    fp["half"].oy = fp["half"].src_rect.height/2
    fp["half"].opacity = 0
    fp["half"].zoom_x = 0.5
    fp["half"].zoom_y = 0.5
    fp["half"].color = Color.new(255,255,255,255)
    fp["half"].z = targetsprite.z + 2

    shake = 4
    # start animation
    @vector.set(vector)
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["circle"].x = cx; fp["circle"].y = cy
      fp["half"].x = cx; fp["half"].y = cy
      pbSEPlay("Paralyze1") if i >= 16 && (i-16)%8==0
      if i == 16
        pbSEPlay("slam")
        pbSEPlay("Thunder3")
      end
      for k in 0...24
        next if i < 16
        if fp["c#{k}"].opacity == 0 && fp["c#{k}"].tone.gray == 0
          r = rand(2)
          fp["c#{k}"].zoom_x = (r==0 ? 1 : 0.5)
          fp["c#{k}"].zoom_y = (r==0 ? 1 : 0.5)
          fp["c#{k}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(128*factor)
          rndx[k] = cx - 128*factor*targetsprite.zoom_x + x*targetsprite.zoom_x
          rndy[k] = cy - 128*factor*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["c#{k}"].x = targetsprite.x
          fp["c#{k}"].y = targetsprite.y
        end
        x2 = rndx[k]
        y2 = rndy[k]
        x0 = fp["c#{k}"].x
        y0 = fp["c#{k}"].y
        fp["c#{k}"].x += (x2 - x0)*0.1
        fp["c#{k}"].y += (y2 - y0)*0.1
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["c#{k}"].tone.gray = 1
          fp["c#{k}"].opacity -= 51
        else
          fp["c#{k}"].opacity += 51
        end
      end
      for n in 0...12
        next if i < 16
        if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
          r = rand(2); r2 = rand(4)
          fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(64*factor)
          fp["#{n}"].x = cx - 64*factor*targetsprite.zoom_x + x*targetsprite.zoom_x
          fp["#{n}"].y = cy - 64*factor*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        next if m>(i-16)/4
        fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
        fp["#{n}"].angle += 180 if (i-16)%3==0
        fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
        q += 1 if fp["#{n}"].opacity >= 255
        fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
      end
      if i < 64
        fp["bg2"].opacity += 15
      else
        fp["bg2"].opacity -= 32
      end
      if i.between?(16,24)
        targetsprite.x += (player ? -8 : 4)*((i-16)/4>0 ? -1 : 1)
        targetsprite.y -= (player ? -4 : 2)*((i-16)/4>0 ? -1 : 1)
      end
      targetsprite.tone = Tone.new(250,250,250) if i == 16
      if i >= 16
        if (i-16)/3 > l
          m += 1
          m = 0 if m > 1
          l = (i-16)/3
        end
        targetsprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
        targetsprite.zoom_x += 0.08*(m==0 ? 1 : -1)
        targetsprite.tone.red -= 15 if targetsprite.tone.red > 100
        targetsprite.tone.green -= 17 if targetsprite.tone.green > 80
        targetsprite.tone.blue -= 19 if targetsprite.tone.blue > 60
        fp["circle"].zoom_x += 0.2
        fp["circle"].zoom_y += 0.2
        fp["circle"].opacity += (i>=20 ? -24 : 48)
        fp["half"].zoom_x += 0.1
        fp["half"].zoom_y += 0.06
        fp["half"].opacity += (i>=24 ? -40 : 40)
      end
      usersprite.color.alpha -= 20 if usersprite.color.alpha > 0
      usersprite.anim = true
      wait(1,(i < 16))
    end
    @vector.set(defaultvector) if !multihit
    20.times do
      fp["bg"].opacity -= 15
      targetsprite.tone.red -= 5
      targetsprite.tone.green -= 4
      targetsprite.tone.blue -= 3
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Thunderbolt
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific069(userindex,targetindex,hitnum=0,multihit=false,beam=false,strike=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    q = 0
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    usersprite.color = Color.new(217,189,52,0) if strike
    for i in 0...8
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb069_2")
      fp["#{i}"].src_rect.set(0,0,98,430)
      fp["#{i}"].ox = fp["#{i}"].src_rect.width/2
      fp["#{i}"].oy = fp["#{i}"].src_rect.height
      fp["#{i}"].zoom_x = 0.5
      fp["#{i}"].z = 50
    end
    for i in 0...16
      fp["s#{i}"] = Sprite.new(targetsprite.viewport)
      fp["s#{i}"].bitmap = pbBitmap("Graphics/Animations/eb069_3")
      fp["s#{i}"].ox = fp["s#{i}"].bitmap.width/2
      fp["s#{i}"].oy = fp["s#{i}"].bitmap.height/2
      fp["s#{i}"].opacity = 0
      fp["s#{i}"].z = 51
    end
    m = 0
    fp["circle"] = Sprite.new(usersprite.viewport)
    fp["circle"].bitmap = pbBitmap("Graphics/Animations/eb069")
    fp["circle"].ox = fp["circle"].bitmap.width/2 + 4
    fp["circle"].oy = fp["circle"].bitmap.height/2 + 4
    fp["circle"].opacity = 0
    fp["circle"].z = 50
    fp["circle"].zoom_x = 1
    fp["circle"].zoom_y = 1
    # start animation
    @vector.set(vector)
    16.times do
      fp["bg"].opacity += 12
      wait(1,true)
    end
    cx, cy = getCenter(targetsprite,true)
    fp["circle"].x = cx
    fp["circle"].y = cy
    for i in 0...96
      for j in 0...8
        next if j>(i/4)
        if fp["#{j}"].y <= 0 && i < 32
          pbSEPlay("Thunder3",80) if i%8==0
          fp["#{j}"].x = cx - 32*targetsprite.zoom_x + rand(64)*targetsprite.zoom_x
          fp["#{j}"].src_rect.x = 98*rand(3)
          t = rand(5)*48
          fp["#{j}"].opacity = 255
          fp["#{j}"].tone = Tone.new(t,t,t)
          fp["#{j}"].mirror = (rand(2)==0 ? true : false)
        end
        fp["#{j}"].src_rect.x += 98
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= 294
        fp["#{j}"].y += (player ? @vector.y : @vector.y2)/8.0 if fp["#{j}"].y < (player ? @vector.y : @vector.y2) + 32
        fp["#{j}"].opacity -= 32 if fp["#{j}"].y >= (player ? @vector.y : @vector.y2) + 32
        fp["#{j}"].y = 0 if fp["#{j}"].opacity <= 0
      end
      for n in 0...16
        next if i < 48
        next if n>(i-48)/4
        if fp["s#{n}"].opacity == 0 && fp["s#{n}"].tone.gray == 0
          pbSEPlay("eb_electric1",60) if i%8==0
          r = rand(2); r2 = rand(4)
          fp["s#{n}"].zoom_x = [1,0.8,0.5,0.75][r2]
          fp["s#{n}"].zoom_y = [1,0.8,0.5,0.75][r2]
          fp["s#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(48)
          fp["s#{n}"].x = cx - 48*targetsprite.zoom_x + x*targetsprite.zoom_x
          fp["s#{n}"].y = cy - 48*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["s#{n}"].angle = -Math.atan(1.0*(fp["s#{n}"].y-cy)/(fp["s#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        fp["s#{n}"].opacity += 128 if fp["s#{n}"].tone.gray == 0
        fp["s#{n}"].angle += 180 if (i-16)%2==0
        fp["s#{n}"].tone.gray = 1 if fp["s#{n}"].opacity >= 255
        q += 1 if fp["s#{n}"].opacity >= 255
        fp["s#{n}"].opacity -= 51 if fp["s#{n}"].tone.gray > 0 && q > 96
      end
      fp["circle"].opacity += (i < 48 ? 32 : - 64)
      fp["circle"].angle += 64
      fp["bg"].opacity -= 32 if i >= 90
      targetsprite.still if i >= 32
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Thunder Punch
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific072(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    factor = (player ? 2 : 1.5)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(217/6,189/6,52/6))
    fp["bg"].opacity = 0
    l = 0; m = 0; q = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb064_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 51
    end
    fp["punch"] = Sprite.new(targetsprite.viewport)
    fp["punch"].bitmap = pbBitmap("Graphics/Animations/eb108")
    fp["punch"].ox = fp["punch"].bitmap.width/2
    fp["punch"].oy = fp["punch"].bitmap.height/2
    fp["punch"].opacity = 0
    fp["punch"].z = 40
    fp["punch"].angle = 180
    fp["punch"].zoom_x = player ? 6 : 4
    fp["punch"].zoom_y = player ? 6 : 4
    fp["punch"].color = Color.new(217,189,52,50)
    # start animation
    @vector.set(getRealVector(targetindex,player))
    pbSEPlay("fog2",75)
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["punch"].x = cx
      fp["punch"].y = cy
      fp["punch"].angle -= 45 if i < 40
      fp["punch"].zoom_x -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].zoom_y -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].opacity += 8 if i < 40
      if i >= 40
        fp["punch"].tone = Tone.new(255,255,255) if i == 40
        fp["punch"].toneAll(-25.5)
        fp["punch"].opacity -= 25.5
      end
      pbSEPlay("hit") if i==40
      pbSEPlay("Thunder3") if i==40
      pbSEPlay("Paralyze1") if i%8==0 && i>=52
      for n in 0...12
        next if i < 40
        if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
          r = rand(2); r2 = rand(4)
          fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(48*factor)
          fp["#{n}"].x = cx - 48*factor*targetsprite.zoom_x + x*targetsprite.zoom_x
          fp["#{n}"].y = cy - 48*factor*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        next if m>(i-40)/4
        fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
        fp["#{n}"].angle += 180 if (i-16)%3==0
        fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
        q += 1 if fp["#{n}"].opacity >= 255
        fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
      end
      fp["bg"].opacity += 4 if  i < 40
      fp["bg"].opacity -= 10 if i >= 56
      targetsprite.tone = Tone.new(100,80,60) if i == 40
      if i >= 40
        if (i-40)/3 > l
          m += 1
          m = 0 if m > 1
          l = (i-40)/3
        end
        targetsprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
        targetsprite.zoom_x += 0.08*(m==0 ? 1 : -1)
        targetsprite.tone.red -= 5 if targetsprite.tone.red > 0
        targetsprite.tone.green -= 4 if targetsprite.tone.green > 0
        targetsprite.tone.blue -= 3 if targetsprite.tone.blue > 0
        targetsprite.still
      end
      wait(1,(i < 40))
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Thunder Fang
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific075(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    factor = player ? 2 : 1.5
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(217/6,189/6,52/6))
    fp["bg"].opacity = 0
    fp["fang1"] = Sprite.new(targetsprite.viewport)
    fp["fang1"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang1"].ox = fp["fang1"].bitmap.width/2
    fp["fang1"].oy = fp["fang1"].bitmap.height - 20
    fp["fang1"].opacity = 0
    fp["fang1"].color = Color.new(217,189,52,50)
    fp["fang1"].z = 41
    fp["fang2"] = Sprite.new(targetsprite.viewport)
    fp["fang2"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang2"].ox = fp["fang1"].bitmap.width/2
    fp["fang2"].oy = fp["fang1"].bitmap.height - 20
    fp["fang2"].opacity = 0
    fp["fang2"].color = Color.new(217,189,52,50)
    fp["fang2"].z = 40
    fp["fang2"].angle = 180
    l = 0; m = 0; q = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb064_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 51
    end
    # start animation
    @vector.set(getRealVector(targetindex,player))
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["fang1"].x = cx; fp["fang1"].y = cy
      if i < 32
        fp["fang1"].zoom_x = targetsprite.zoom_x; fp["fang1"].zoom_y = targetsprite.zoom_y
      end
      fp["fang2"].x = cx; fp["fang2"].y = cy
      if i < 32
        fp["fang2"].zoom_x = targetsprite.zoom_x; fp["fang2"].zoom_y = targetsprite.zoom_y
      end
      if i.between?(20,29)
        fp["fang1"].opacity += 5
        fp["fang1"].oy += 2
        fp["fang2"].opacity += 5
        fp["fang2"].oy += 2
      elsif i.between?(30,40)
        fp["fang1"].opacity += 25.5
        fp["fang1"].oy -= 4
        fp["fang2"].opacity += 25.5
        fp["fang2"].oy -= 4
      else i > 40
        fp["fang1"].opacity -= 26
        fp["fang1"].oy += 2
        fp["fang2"].opacity -= 26
        fp["fang2"].oy += 2
      end
      if i==32
        pbSEPlay("Super Fang")
      end
      pbSEPlay("Paralyze1") if i%8==0 && i>=48
      for n in 0...12
        next if i < 32
        if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
          r = rand(2); r2 = rand(4)
          fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
          fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(48*factor)
          fp["#{n}"].x = cx - 48*factor*targetsprite.zoom_x + x*targetsprite.zoom_x
          fp["#{n}"].y = cy - 48*factor*targetsprite.zoom_y + y*targetsprite.zoom_y
          fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
        end
        next if m>(i-32)/4
        fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
        fp["#{n}"].angle += 180 if (i-16)%3==0
        fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
        q += 1 if fp["#{n}"].opacity >= 255
        fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
      end
      fp["bg"].opacity += 4 if  i < 40
      fp["bg"].opacity -= 10 if i >= 56
      targetsprite.tone = Tone.new(100,80,60) if i == 32
      if i >= 32
        if (i-32)/3 > l
          m += 1
          m = 0 if m > 1
          l = (i-32)/3
        end
        targetsprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
        targetsprite.zoom_x += 0.08*(m==0 ? 1 : -1)
        targetsprite.tone.red -= 5 if targetsprite.tone.red > 0
        targetsprite.tone.green -= 4 if targetsprite.tone.green > 0
        targetsprite.tone.blue -= 3 if targetsprite.tone.blue > 0
        targetsprite.still
      end
      wait(1,(i < 32))
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Charge Beam
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific078(userindex,targetindex,hitnum=0,multihit=false)
    # Charging animation
    pbMoveAnimationSpecific081(userindex,targetindex,hitnum,multihit,true)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1.5
    targetsprite.viewport.color = Color.new(255,255,255,255)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 255*0.75
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb078")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    shake = 4
    # start animation
    pbSEPlay("Flash")
    pbSEPlay("Pollen")
    for i in 0...96
      pbSEPlay("Paralyze1") if i%8==0
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        cx, cy = getCenter(targetsprite,true)
        next if j>(i)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        x0 = dx[j]
        y0 = dy[j]
        fp["#{j}"].x += (x2 - x0)*0.05
        fp["#{j}"].y += (y2 - y0)*0.05
        fp["#{j}"].opacity += 32
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x + (x2 - x0)*0.05
        nexty = fp["#{j}"].y + (y2 - y0)*0.05
        if !player
          fp["#{j}"].visible = false if nextx > cx && nexty < cy
        else
          fp["#{j}"].visible = false if nextx < cx && nexty > cy
        end
      end
      if i >= 32
        cx, cy = getCenter(targetsprite,true)
        targetsprite.tone.red += 8 if targetsprite.tone.red < 160
        targetsprite.tone.green += 6.4 if targetsprite.tone.green < 128
        targetsprite.tone.blue += 6.4 if targetsprite.tone.blue < 128
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      @vector.set(DUALVECTOR) if i == 24
      @vector.inc = 0.1 if i == 24
      targetsprite.viewport.color.alpha -= 5 if targetsprite.viewport.color.alpha > 0
      wait(1,true)
    end
    20.times do
      cx, cy = getCenter(targetsprite,true)
      targetsprite.tone.red -= 8
      targetsprite.tone.green -= 6.4
      targetsprite.tone.blue -= 6.4
      targetsprite.addOx(shake)
      shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
      shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
      targetsprite.still
      fp["bg"].opacity -= 15
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    targetsprite.tone = Tone.new(0,0,0)
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Charge
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific081(userindex,targetindex,hitnum=0,multihit=false,beam=false,strike=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(userindex,player)
    factor = 2
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    usersprite.color = Color.new(217,189,52,0) if strike
    rndx = []
    rndy = []
    for i in 0...8
      fp["#{i}"] = Sprite.new(usersprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb081_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
    end
    for i in 0...16
      fp["c#{i}"] = Sprite.new(usersprite.viewport)
      fp["c#{i}"].bitmap = pbBitmap("Graphics/Animations/eb081")
      fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
      fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
      fp["c#{i}"].opacity = 0
      fp["c#{i}"].z = 51
      rndx.push(0)
      rndy.push(0)
    end
    m = 0
    fp["circle"] = Sprite.new(usersprite.viewport)
    fp["circle"].bitmap = pbBitmap("Graphics/Animations/eb081_3")
    fp["circle"].ox = fp["circle"].bitmap.width/4
    fp["circle"].oy = fp["circle"].bitmap.height/2
    fp["circle"].opacity = 0
    fp["circle"].src_rect.set(0,0,484,488)
    fp["circle"].z = 50
    fp["circle"].zoom_x = 0.5
    fp["circle"].zoom_y = 0.5
    # start animation
    @vector.set(vector)
    for i in 0...112
      pbSEPlay("Flash3",90) if i == 32
      pbSEPlay("Saint8") if i == 64
      cx, cy = getCenter(usersprite)
      for j in 0...8
        if fp["#{j}"].opacity == 0
          r = rand(2)
          fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
          fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
          fp["#{j}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(96*factor)
          fp["#{j}"].x = cx - 96*factor*usersprite.zoom_x + x*usersprite.zoom_x
          fp["#{j}"].y = cy - 96*factor*usersprite.zoom_y + y*usersprite.zoom_y
        end
        next if j>(i/8)
        x2 = cx
        y2 = cy
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
        fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*(180.0/Math::PI)# + (rand{4}==0 ? 180 : 0)
        fp["#{j}"].mirror = !fp["#{j}"].mirror if i%2==0
        if i >= 96
          fp["#{j}"].opacity -= 35
        elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{j}"].opacity = 0
        else
          fp["#{j}"].opacity += 35
        end
      end
      for k in 0...16
        if fp["c#{k}"].opacity == 0
          r = rand(2)
          fp["c#{k}"].zoom_x = (r==0 ? 1 : 0.5)
          fp["c#{k}"].zoom_y = (r==0 ? 1 : 0.5)
          fp["c#{k}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
          x, y = randCircleCord(48*factor)
          rndx[k] = cx - 48*factor*usersprite.zoom_x + x*usersprite.zoom_x
          rndy[k] = cy - 48*factor*usersprite.zoom_y + y*usersprite.zoom_y
          fp["c#{k}"].x = cx
          fp["c#{k}"].y = cy
        end
        next if k>(i/4)
        x2 = rndx[k]
        y2 = rndy[k]
        x0 = fp["c#{k}"].x
        y0 = fp["c#{k}"].y
        fp["c#{k}"].x += (x2 - x0)*0.05
        fp["c#{k}"].y += (y2 - y0)*0.05
        fp["c#{k}"].opacity += 5
      end
      fp["circle"].x = cx
      fp["circle"].y = cy
      fp["circle"].opacity += 25.5
      if i < 124
        fp["circle"].zoom_x += 0.01
        fp["circle"].zoom_y += 0.01
      else
        fp["circle"].zoom_x += 0.05
        fp["circle"].zoom_y += 0.05
      end
      m = 1 if i%4==0
      fp["circle"].src_rect.x = 484*m
      m = 0 if i%2==0
      if i < 96
        if strike
          fp["bg"].opacity += 10 if fp["bg"].opacity < 255
        else
          fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.75
        end
      else
        fp["bg"].opacity -= 10 if !beam && !strike
      end
      if strike && i > 16
        usersprite.color.alpha += 10 if usersprite.color.alpha < 200
        fp["circle"].opacity -= 76.5 if i > 106
        for k in 0...16
          next if i < 96
          fp["c#{k}"].opacity -= 30.5
        end
        for j in 0...8
          next if i < 96
          fp["#{j}"].opacity -= 30.5
        end
      end
      usersprite.still if !strike
      usersprite.anim = true if strike
      wait(1,true)
    end
    if strike
      for i in 0...2
        8.times do
          usersprite.x -= (player ? 12 : -6)*(i==0 ? 1 : -1)
          usersprite.y += (player ? 4 : -2)*(i==0 ? 1 : -1)
          usersprite.zoom_y -= (factor*0.04)*(i==0 ? 1 : -1)
          usersprite.still
          wait(1)
        end
      end
    end
    pbDisposeSpriteHash(fp)
    if !beam && !strike
      @vector.set(defaultvector) if !multihit
      targetsprite.viewport.color = Color.new(255,255,255,255)
      10.times do
        targetsprite.viewport.color.alpha -= 25.5
        wait(1,true)
      end
      return true
    end
  end
  #-----------------------------------------------------------------------------
  #  Thunderwave
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific083(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific069(userindex,targetindex,hitnum,multihit)
  end
  #-----------------------------------------------------------------------------
  #  Close Combat
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific086(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    fp = {}
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb086_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    @vector.set(vector)
    for i in 0...16
      fp["bg"].opacity += 32 if i >= 8
      wait(1,true)
    end
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    for j in 0...12
      fp["f#{j}"] = Sprite.new(targetsprite.viewport)
      fp["f#{j}"].bitmap = pbBitmap("Graphics/Animations/eb086")
      fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
      fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
      fp["f#{j}"].z = targetsprite.z + 1
      r = 32*factor
      fp["f#{j}"].x = cx - r + rand(r*2)
      fp["f#{j}"].y = cy - r + rand(r*2)
      fp["f#{j}"].visible = false
      fp["f#{j}"].zoom_x = factor
      fp["f#{j}"].zoom_y = factor
      fp["f#{j}"].color = Color.new(180,53,2,0)
    end
    dx = []
    dy = []
    for j in 0...96
      fp["p#{j}"] = Sprite.new(targetsprite.viewport)
      fp["p#{j}"].bitmap = pbBitmap("Graphics/Animations/eb086_2")
      fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
      fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
      fp["p#{j}"].z = targetsprite.z
      r = 148*factor + rand(32)*factor
      x, y = randCircleCord(r)
      fp["p#{j}"].x = cx
      fp["p#{j}"].y = cy
      fp["p#{j}"].visible = false
      fp["p#{j}"].zoom_x = factor
      fp["p#{j}"].zoom_y = factor
      fp["p#{j}"].color = Color.new(180,53,2,0)
      dx.push(cx - r + x)
      dy.push(cy - r + y)
    end
    k = -4
    for i in 0...72
      k *= - 1 if i%4==0
      fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
      for j in 0...12
        next if j>(i/4)
        pbSEPlay("hit",80) if fp["f#{j}"].opacity == 255
        fp["f#{j}"].visible = true
        fp["f#{j}"].zoom_x -= 0.025
        fp["f#{j}"].zoom_y -= 0.025
        fp["f#{j}"].opacity -= 16
        fp["f#{j}"].color.alpha += 32
      end
      for j in 0...96
        next if j>(i*2)
        fp["p#{j}"].visible = true
        fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
        fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
        fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
        fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
        fp["p#{j}"].zoom_x += 0.1
        fp["p#{j}"].zoom_y += 0.1
        fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
      end
      fp["bg"].update
      targetsprite.still
      targetsprite.zoom_x -= factor*0.01*k if i < 56
      targetsprite.zoom_y += factor*0.02*k if i < 56
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    16.times do
      fp["bg"].color.alpha += 16
      fp["bg"].opacity -= 16
      fp["bg"].update
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Aura Sphere
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific093(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb093_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0

    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb093")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = usersprite.z + 1
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 0.75 : 1)
    fp["cir"].zoom_y = (player ? 0.75 : 1)
    fp["cir"].opacity = 0

    shake = 4
    k = 0
    # start animation
    for i in 0...40
      if i < 8
        fp["bg"].opacity += 32
      else
        fp["bg"].color.alpha -= 32
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity += 24
      end
      if i == 8
        @vector.set(vector2)
        pbSEPlay("eb_grass2",80)
      end
      fp["bg"].update
      wait(1,true)
    end
    cx, cy = getCenter(usersprite,true)
    dx = []
    dy = []
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb093_2")
      fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
      fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
      fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
      r = 128*usersprite.zoom_x
      z = [0.5,0.25,1,0.75][rand(4)]
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      fp["#{i}s"].x = cx
      fp["#{i}s"].y = cy
      fp["#{i}s"].zoom_x = z*usersprite.zoom_x
      fp["#{i}s"].zoom_y = z*usersprite.zoom_x
      fp["#{i}s"].visible = false
      fp["#{i}s"].z = usersprite.z + 1
      dx.push(x)
      dy.push(y)
    end

    fp["shot"] = Sprite.new(targetsprite.viewport)
    fp["shot"].bitmap = pbBitmap("Graphics/Animations/eb093_3")
    fp["shot"].ox = fp["shot"].bitmap.width/2
    fp["shot"].oy = fp["shot"].bitmap.height/2
    fp["shot"].z = usersprite.z + 1
    fp["shot"].zoom_x = usersprite.zoom_x
    fp["shot"].zoom_y = usersprite.zoom_x
    fp["shot"].opacity = 0

    x = defaultvector[0]; y = defaultvector[1]
    x2, y2 = @vector.spoof(defaultvector)
    y2+=(player ? 0 : 40)
    x2+=(player ? 60 : 180) #Added to make the animation go over the side of the screens
    fp["shot"].x = cx
    fp["shot"].y = cy
    pbSEPlay("eb_normal5",80)
    k = -1
    for i in 0...20
      cx, cy = getCenter(usersprite)
      @vector.set(defaultvector) if i == 0
      if i > 0
        fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
        fp["shot"].opacity += 32
        fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
        fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
        fp["shot"].x += (player ? -1 : 1)*(x2 - cx)/24
        fp["shot"].y -= (player ? -1 : 1)*(cy - y2)/24
        for j in 0...8
          fp["#{j}s"].visible = true
          fp["#{j}s"].opacity -= 32
          fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
          fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
        end
        fp["cir"].angle += 24*(player2 ? -1 : 1)
        fp["cir"].opacity -= 16
        fp["cir"].x = cx
        fp["cir"].y = cy
      end
      fp["bg"].update
      factor = targetsprite.zoom_x if i == 12
      if i >= 12
        k *= -1 if i%4==0
        targetsprite.zoom_x -= factor*0.01*k
        targetsprite.zoom_y += factor*0.04*k
        targetsprite.still
      end
      wait(1,i < 12)
    end
    shake = 2
    16.times do
      fp["shot"].angle = Math.atan(1.0*(y-y2)/(x2-x))*(180.0/Math::PI) + (player ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - targetsprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - targetsprite.zoom_y)*0.1
      fp["shot"].x += (player ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (player ? -1 : 1)*(y - y2)/24
      fp["bg"].color.alpha += 16
      fp["bg"].update
      targetsprite.addOx(shake)
      shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 4
      shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 4
      targetsprite.still
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    16.times do
      targetsprite.still
      wait(1,true)
    end
    16.times do
      fp["bg"].opacity -= 16
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Flare Blitz
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific129(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    frame = []
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = pbBitmap("Graphics/Animations/eb129_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for j in 0...16
      fp["f#{j}"] = Sprite.new(usersprite.viewport)
      fp["f#{j}"].bitmap = pbBitmap("Graphics/Animations/eb129")
      fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
      fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
      fp["f#{j}"].x = usersprite.x - 64*usersprite.zoom_x + rand(128)*usersprite.zoom_x
      fp["f#{j}"].y = usersprite.y - 16*usersprite.zoom_y + rand(32)*usersprite.zoom_y
      fp["f#{j}"].visible = false
      z = [1,0.75,0.5,0.8][rand(4)]
      fp["f#{j}"].zoom_x = usersprite.zoom_x*z
      fp["f#{j}"].zoom_y = usersprite.zoom_y*z
      fp["f#{j}"].z = usersprite.z + 1
      frame.push(0)
    end
    pbSEPlay("eb_fire2",60)
    pbSEPlay("eb_fire3",60)
    for i in 0...48
      for j in 0...16
        next if j>(i/2)
        fp["f#{j}"].visible = true
        fp["f#{j}"].y -= 8*usersprite.zoom_y
        fp["f#{j}"].opacity -= 32 if frame[j] >= 8
        frame[j] += 1
      end
      fp["bg"].opacity += 8 if i >= 32
      wait(1,true)
    end
    pbSEPlay("eb_fire4",80)
    @vector.set(vector)
    wait(16,true)
    cx, cy = getCenter(targetsprite)
    fp["flare"] = Sprite.new(targetsprite.viewport)
    fp["flare"].bitmap = pbBitmap("Graphics/Animations/eb129_2")
    fp["flare"].ox = fp["flare"].bitmap.width/2
    fp["flare"].oy = fp["flare"].bitmap.height/2
    fp["flare"].x = cx
    fp["flare"].y = cy
    fp["flare"].zoom_x = targetsprite.zoom_x
    fp["flare"].zoom_y = targetsprite.zoom_y
    fp["flare"].z = targetsprite.z
    fp["flare"].opacity = 0
    for j in 0...3
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb129_3")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].x = cx - 32 + rand(64)
      fp["#{j}"].y = cy - 32 + rand(64)
      fp["#{j}"].z = targetsprite.z + 1
      fp["#{j}"].visible = false
      fp["#{j}"].zoom_x = targetsprite.zoom_x
      fp["#{j}"].zoom_y = targetsprite.zoom_y
    end
    for m in 0...12
      fp["p#{m}"] = Sprite.new(targetsprite.viewport)
      fp["p#{m}"].bitmap = pbBitmap("Graphics/Animations/eb129_4")
      fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
      fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
      fp["p#{m}"].x = cx - 48 + rand(96)
      fp["p#{m}"].y = cy - 48 + rand(96)
      fp["p#{m}"].z = targetsprite.z + 2
      fp["p#{m}"].visible = false
      fp["p#{m}"].zoom_x = targetsprite.zoom_x
      fp["p#{m}"].zoom_y = targetsprite.zoom_y
    end
    targetsprite.color = Color.new(0,0,0,0)
    for i in 0...64
      fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
      fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
      fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
      fp["flare"].angle += 32
      pbSEPlay("eb_fire1",80) if i == 8
      for j in 0...3
        next if i < 12
        next if j>(i-12)/4
        fp["#{j}"].visible = true
        fp["#{j}"].opacity -= 16
        fp["#{j}"].angle += 16
        fp["#{j}"].zoom_x += 0.1
        fp["#{j}"].zoom_y += 0.1
      end
      for m in 0...12
        next if i < 6
        next if m>(i-6)
        fp["p#{m}"].visible = true
        fp["p#{m}"].opacity -= 16
        fp["p#{m}"].y -= 8
      end
      if i >= 48
        fp["bg"].opacity -= 16
        targetsprite.color.alpha -= 16
      else
        targetsprite.color.alpha += 16 if targetsprite.color.alpha < 192
      end
      targetsprite.anim = true
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Heat Wave
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific132(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
    fp["bg"].opacity = 0
    fp["wave"] = AnimatedPlane.new(targetsprite.viewport)
    fp["wave"].bitmap = Bitmap.new(1026,targetsprite.viewport.rect.height)
    fp["wave"].bitmap.stretch_blt(Rect.new(0,0,fp["wave"].bitmap.width,fp["wave"].bitmap.height),pbBitmap("Graphics/Animations/eb132"),Rect.new(0,0,1026,212))
    fp["wave"].opacity = 0
    fp["wave"].z = 50
    @vector.set(DUALVECTOR)
    @vector.inc = 0.1
    pulse = 10
    shake = [4,4,4,4]
    # start animation
    for j in 0...64
      pbSEPlay("Wind8") if j == 24
      fp["wave"].ox += 48
      fp["wave"].opacity += pulse
      pulse = -5 if fp["wave"].opacity > 160
      pulse = +5 if fp["wave"].opacity < 100
      fp["bg"].opacity += 1 if fp["bg"].opacity < 255*0.35
      for i in 0...4
        next if !(player ? [0,2] : [1,3]).include?(i)
        next if !(@sprites["pokemon#{i}"] && @sprites["pokemon#{i}"].visible) || @sprites["pokemon#{i}"].disposed?
        @sprites["pokemon#{i}"].toneAll(3) if j.between?(16,48)
        if j >= 32
          @sprites["pokemon#{i}"].addOx(shake[i])
          shake[i] = -4 if @sprites["pokemon#{i}"].ox > @sprites["pokemon#{i}"].bitmap.width/2 + 2
          shake[i] = 4 if @sprites["pokemon#{i}"].ox < @sprites["pokemon#{i}"].bitmap.width/2 - 2
        end
      end
      @sprites["pokemon#{userindex}"].toneAll(3) if j < 32
      @sprites["pokemon#{userindex}"].still
      wait(1,true)
    end
    for i in 0...4
      next if !(player ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon#{i}"] && @sprites["pokemon#{i}"].visible) || @sprites["pokemon#{i}"].disposed?
      @sprites["pokemon#{i}"].ox = @sprites["pokemon#{i}"].bitmap.width/2
    end
    for j in 0...64
      fp["wave"].ox += 48
      if j < 32
        fp["wave"].opacity += pulse
        pulse = -5 if fp["wave"].opacity > 160
        pulse = +5 if fp["wave"].opacity < 100
      end
      fp["wave"].opacity -= 4 if j >= 32
      fp["bg"].opacity -= 4 if j >= 32
      for i in 0...4
        next if !(player ? [0,2] : [1,3]).include?(i)
        next if !(@sprites["pokemon#{i}"] && @sprites["pokemon#{i}"].visible)
        @sprites["pokemon#{i}"].toneAll(-3) if j >= 32
      end
      @sprites["pokemon#{userindex}"].toneAll(-3) if j >= 32
      @sprites["pokemon#{userindex}"].still
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Flamethrower
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific136(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
    fp["bg"].opacity = 0
    for i in 0...16
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb136")
      fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{i}"].ox = 26
      fp["#{i}"].oy = 101
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      rndx.push(rand(64))
      rndy.push(rand(64))
    end
    shake = 2
    # start animation
    for i in 0...132
      for j in 0...16
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          fp["#{j}"].zoom_x = usersprite.zoom_x
          fp["#{j}"].zoom_y = usersprite.zoom_y
          cx, cy = getCenter(usersprite)
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy + 50*usersprite.zoom_y
        end
        next if j>(i/4)
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 32*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 32*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y + 50*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - targetsprite.zoom_x)*0.1
        fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - targetsprite.zoom_y)*0.1
        fp["#{j}"].src_rect.x += 53 if i%4==0
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{j}"].opacity -= 8
          fp["#{j}"].tone.gray += 8
          fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
          fp["#{j}"].zoom_x -= 0.02
          fp["#{j}"].zoom_y += 0.04
        else
          fp["#{j}"].opacity += 12
        end
      end
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
      pbSEPlay("Fire2",80) if i%12==0 && i <= 96
      pbSEPlay("SMokescreen",120) if i==84
      if i >= 96
        targetsprite.tone.red += 2.4*2 if targetsprite.tone.red < 48*2
        targetsprite.tone.green -= 1.2*2 if targetsprite.tone.green > -24*2
        targetsprite.tone.blue -= 2.4*2 if targetsprite.tone.blue > -48*2
        targetsprite.addOx(shake)
        shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      @vector.set(DUALVECTOR) if i == 24
      @vector.inc = 0.1 if i == 24
      wait(1,true)
    end
    20.times do
      targetsprite.tone.red -= 2.4*2
      targetsprite.tone.green += 1.2*2
      targetsprite.tone.blue += 2.4*2
      targetsprite.addOx(shake)
      shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
      shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
      targetsprite.still
      fp["bg"].opacity -= 15
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Blaze Kick
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific137(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific140(userindex,targetindex,hitnum,multihit,true)
  end
  #-----------------------------------------------------------------------------
  #  Fire Punch
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific140(userindex,targetindex,hitnum=0,multihit=false,kick=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
    fp["bg"].opacity = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb136")
      fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{i}"].ox = 26
      fp["#{i}"].oy = 50
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)/2
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)/2
      rndx.push(rand(144))
      rndy.push(rand(144))
    end
    fp["punch"] = Sprite.new(targetsprite.viewport)
    fp["punch"].bitmap = pbBitmap("Graphics/Animations/eb#{kick ? 137 : 108}")
    fp["punch"].ox = fp["punch"].bitmap.width/2
    fp["punch"].oy = fp["punch"].bitmap.height/2
    fp["punch"].opacity = 0
    fp["punch"].z = 40
    fp["punch"].angle = 180
    fp["punch"].zoom_x = player ? 6 : 4
    fp["punch"].zoom_y = player ? 6 : 4
    fp["punch"].tone = Tone.new(48,16,6)
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    pbSEPlay("fog2",75)
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["punch"].x = cx
      fp["punch"].y = cy
      fp["punch"].angle -= 45 if i < 40
      fp["punch"].zoom_x -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].zoom_y -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].opacity += 8 if i < 40
      if i >= 40
        fp["punch"].tone = Tone.new(255,255,255) if i == 40
        fp["punch"].toneAll(-25.5)
        fp["punch"].opacity -= 25.5
      end
      pbSEPlay("Fire3") if i==40
      for j in 0...12
        next if i < 40
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 72*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 72*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].src_rect.x += 53 if i%2==0
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 16
          fp["#{j}"].tone.gray += 16
          fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
          fp["#{j}"].zoom_x -= 0.005
          fp["#{j}"].zoom_y += 0.01
        else
          fp["#{j}"].opacity += 45
        end
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        if i >= 56
          targetsprite.tone.red -= 3*2
          targetsprite.tone.green += 1.5*2
          targetsprite.tone.blue += 3*2
          fp["bg"].opacity -= 10
        else
          targetsprite.tone.red += 3*2 if targetsprite.tone.red < 48*2
          targetsprite.tone.green -= 1.5*2 if targetsprite.tone.green > -24*2
          targetsprite.tone.blue -= 3*2 if targetsprite.tone.blue > -48*2
        end
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Fire Fang
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific142(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
    fp["bg"].opacity = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb136")
      fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
      fp["#{i}"].ox = 26
      fp["#{i}"].oy = 50
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)/2
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)/2
      rndx.push(rand(64))
      rndy.push(rand(64))
    end
    fp["fang1"] = Sprite.new(targetsprite.viewport)
    fp["fang1"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang1"].ox = fp["fang1"].bitmap.width/2
    fp["fang1"].oy = fp["fang1"].bitmap.height - 20
    fp["fang1"].opacity = 0
    fp["fang1"].z = 41
    fp["fang1"].tone = Tone.new(48,16,6)
    fp["fang2"] = Sprite.new(targetsprite.viewport)
    fp["fang2"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang2"].ox = fp["fang1"].bitmap.width/2
    fp["fang2"].oy = fp["fang1"].bitmap.height - 20
    fp["fang2"].opacity = 0
    fp["fang2"].z = 40
    fp["fang2"].angle = 180
    fp["fang2"].tone = Tone.new(48,16,6)
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["fang1"].x = cx; fp["fang1"].y = cy
      fp["fang1"].zoom_x = targetsprite.zoom_x; fp["fang1"].zoom_y = targetsprite.zoom_y
      fp["fang2"].x = cx; fp["fang2"].y = cy
      fp["fang2"].zoom_x = targetsprite.zoom_x; fp["fang2"].zoom_y = targetsprite.zoom_y
      if i.between?(20,29)
        fp["fang1"].opacity += 5
        fp["fang1"].oy += 2
        fp["fang2"].opacity += 5
        fp["fang2"].oy += 2
      elsif i.between?(30,40)
        fp["fang1"].opacity += 25.5
        fp["fang1"].oy -= 4
        fp["fang2"].opacity += 25.5
        fp["fang2"].oy -= 4
      else i > 40
        fp["fang1"].opacity -= 26
        fp["fang1"].oy += 2
        fp["fang2"].opacity -= 26
        fp["fang2"].oy += 2
      end
      if i==32
        pbSEPlay("Super Fang")
        pbSEPlay("Fire2",75)
      end
      for j in 0...12
        next if i < 40
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 32*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 32*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].src_rect.x += 53 if i%2==0
        fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 24
          fp["#{j}"].tone.gray += 24
          fp["#{j}"].tone.red -= 8; fp["#{j}"].tone.green -= 8; fp["#{j}"].tone.blue -= 8
          fp["#{j}"].zoom_x -= 0.01
          fp["#{j}"].zoom_y += 0.02
        else
          fp["#{j}"].opacity += 45
        end
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        if i >= 56
          targetsprite.tone.red -= 3*2
          targetsprite.tone.green += 1.5*2
          targetsprite.tone.blue += 3*2
          fp["bg"].opacity -= 10
        else
          targetsprite.tone.red += 3*2 if targetsprite.tone.red < 48*2
          targetsprite.tone.green -= 1.5*2 if targetsprite.tone.green > -24*2
          targetsprite.tone.blue -= 3*2 if targetsprite.tone.blue > -48*2
        end
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Fly
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific156(userindex,targetindex,hitnum=0,multihit=false)
    if hitnum == 1
      return moveAnimationFlyUp(userindex,targetindex)
    elsif hitnum == 0
      return moveAnimationFlyDown(userindex,targetindex)
    end
  end

  def moveAnimationFlyUp(userindex,targetindex)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(userindex,player)
    factor = player ? 2 : 1.5
    # set up animation
    fp = {}
    fp["fly"] = Sprite.new(usersprite.viewport)
    fp["fly"].bitmap = pbBitmap("Graphics/Animations/eb156")
    fp["fly"].ox = fp["fly"].bitmap.width/2
    fp["fly"].oy = fp["fly"].bitmap.height/2
    fp["fly"].z = 50
    fp["fly"].x, fp["fly"].y = getCenter(usersprite)
    fp["fly"].opacity = 0
    fp["fly"].zoom_x = factor*1.4
    fp["fly"].zoom_y = factor*1.4
    fp["dnt"] = Sprite.new(usersprite.viewport)
    fp["dnt"].bitmap = pbBitmap("Graphics/Animations/eb156_2")
    fp["dnt"].ox = fp["dnt"].bitmap.width/2
    fp["dnt"].oy = fp["dnt"].bitmap.height/2
    fp["dnt"].z = 50
    fp["dnt"].opacity = 0
    # start animation
    @vector.set(vector)
    wait(20,true)
    pbSEPlay("Refresh")
    for i in 0...20
      cx, cy = getCenter(usersprite)
      fp["fly"].x = cx
      fp["fly"].y = cy
      fp["fly"].zoom_x -= factor*0.4/10
      fp["fly"].zoom_y -= factor*0.4/10
      fp["fly"].opacity += 51
      fp["dnt"].x = cx
      fp["dnt"].y = cy
      fp["dnt"].zoom_x = fp["fly"].zoom_x
      fp["dnt"].zoom_y = fp["fly"].zoom_y
      fp["dnt"].opacity += 25.5
      fp["dnt"].angle -= 16
      usersprite.visible = false if i == 6
      usersprite.hidden = true if i == 6
      wait(1,true)
    end
    10.times do
      fp["fly"].zoom_x += factor*0.4/10
      fp["fly"].zoom_y += factor*0.4/10
      fp["dnt"].zoom_x = fp["fly"].zoom_x
      fp["dnt"].zoom_y = fp["fly"].zoom_y
      fp["dnt"].opacity -= 25.5
      fp["dnt"].angle -= 16
      wait(1,true)
    end
    @vector.set(vector[0],vector[1]+196,vector[2],vector[3],vector[4],vector[5])
    for i in 0...20
      wait(1,true)
      cx, cy = getCenter(usersprite)
      if i < 10
        fp["fly"].zoom_y -= factor*0.02
      elsif
        fp["fly"].zoom_x -= factor*0.02
        fp["fly"].zoom_y += factor*0.04
      end
      fp["fly"].x = cx
      fp["fly"].y = cy
      fp["fly"].y -= 32*(i-10) if i >= 10
      pbSEPlay("eb_flying2") if i == 10
    end
    for i in 0...20
      fp["fly"].y -= 32
      fp["fly"].opacity -= 25.5 if i >= 10
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector)
    wait(20,true)
    return true
  end

  def moveAnimationFlyDown(userindex,targetindex)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1.5
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    fp["drop"] = Sprite.new(targetsprite.viewport)
    fp["drop"].bitmap = pbBitmap("Graphics/Animations/eb156_3")
    fp["drop"].ox = fp["drop"].bitmap.width/2
    fp["drop"].oy = fp["drop"].bitmap.height/2
    fp["drop"].y = 0
    fp["drop"].z = 50
    fp["drop"].visible = false
    # start animation
    @vector.set(defaultvector[0],defaultvector[1]+128,defaultvector[2],defaultvector[3],defaultvector[4],defaultvector[5])
    32.times do
      fp["bg"].opacity += 2
      wait(1,true)
    end
    @vector.set(vector)
    maxy = ((player ? @vector.y : @vector.y2)*0.1).ceil*10 - 80
    fp["drop"].y = -((maxy-(player ? @vector.y-80 : @vector.y2-80))*0.1).ceil*10
    fp["drop"].x = targetsprite.x
    pbSEPlay("Wind1")
    for i in 0...20
      wait(1,true)
      if i >= 10
        fp["drop"].visible = true
        fp["drop"].x = targetsprite.x
        fp["drop"].y += maxy/10
        fp["drop"].zoom_x = targetsprite.zoom_x
        fp["drop"].zoom_y = targetsprite.zoom_y*1.4
      end
      fp["bg"].opacity -= 51 if i >= 15
    end
    usersprite.hidden = false
    usersprite.visible = true
    pbDisposeSpriteHash(fp)
    return pbMoveAnimationSpecific303(userindex,targetindex,0,false,false,true)
  end
  #-----------------------------------------------------------------------------
  #  Air Slash
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific159(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    pbSEPlay("eb_flying1",80)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    cx, cy = getCenter(targetsprite,true)
    da = []
    dx = []
    dy = []
    doj = []
    for i in 0...32
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb159_2")
      fp["#{i}"].ox = 12
      fp["#{i}"].oy = 1
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = targetsprite.z + 1
      r = 128*factor
      z = [1,1.25,0.75,1.5][rand(4)]
      fp["#{i}"].zoom_x = z
      #fp["#{i}"].zoom_y = factor
      fp["#{i}"].x = cx
      fp["#{i}"].y = cy
      fp["#{i}"].tone = Tone.new(255,255,255)
      da.push(rand(2)==0 ? 1 : -1)
      dx.push(cx - r + rand(r*2))
      dy.push(cy - r + rand(r*2))
      doj.push(rand(4)+1)
    end
    fp["slash"] = Sprite.new(targetsprite.viewport)
    fp["slash"].bitmap = pbBitmap("Graphics/Animations/eb159")
    fp["slash"].ox = fp["slash"].bitmap.width/2
    fp["slash"].oy = fp["slash"].bitmap.height/2
    fp["slash"].x = cx
    fp["slash"].y = cy
    #fp["slash"].zoom_x = factor
    #fp["slash"].zoom_y = factor
    fp["slash"].z = targetsprite.z
    fp["slash"].src_rect.height = 0
    pbSEPlay("eb_normal3",80)
    # start animation
    shake = 2
    for i in 0...48
      fp["slash"].src_rect.height += 48 if i < 8
      for j in 0...32
        fp["#{j}"].angle += 32*da[j]
        fp["#{j}"].tone.red -= 8 if fp["#{j}"].tone.red > 0
        fp["#{j}"].tone.green -= 8 if fp["#{j}"].tone.green > 0
        fp["#{j}"].tone.blue -= 8 if fp["#{j}"].tone.blue > 0
        fp["#{j}"].opacity += 16*(i < 24 ? 4 : -1*doj[j])
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.05
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.05
      end
      if i >= 4
        fp["slash"].tone.red += 16 if fp["slash"].tone.red < 255
        fp["slash"].tone.green += 16 if fp["slash"].tone.green < 255
        fp["slash"].tone.blue += 16 if fp["slash"].tone.blue < 255
        fp["slash"].opacity -= 32 if i >= 8
      end
      if i >= 8
        targetsprite.addOx(shake)
        shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Wing Attack
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific164(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    pbSEPlay("eb_flying1",80)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    cx, cy = getCenter(targetsprite,true)
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb303_2")
      fp["#{i}"].ox = 10
      fp["#{i}"].oy = 10
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 51
      r = rand(3)
      fp["#{i}"].zoom_x = (factor-0.5)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (factor-0.5)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(64))
    end
    wait = []
    for m in 0...8
      fp["w#{m}"] = Sprite.new(targetsprite.viewport)
      fp["w#{m}"].bitmap = pbBitmap("Graphics/Animations/eb164")
      fp["w#{m}"].ox = 20
      fp["w#{m}"].oy = 16
      fp["w#{m}"].opacity = 0
      fp["w#{m}"].z = 50
      fp["w#{m}"].angle = rand(360)
      fp["w#{m}"].zoom_x = factor - 0.5
      fp["w#{m}"].zoom_y = factor - 0.5
      fp["w#{m}"].x = cx - 32*factor + rand(64*factor)
      fp["w#{m}"].y = cy - 112*factor + rand(112*factor)
      wait.push(0)
    end
    pbSEPlay("eb_normal1",80)
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 51
    frame.bitmap = pbBitmap("Graphics/Animations/eb303")
    frame.src_rect.set(0,0,64,64)
    frame.ox = 32
    frame.oy = 32
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    frame.y -= 32*targetsprite.zoom_y
    # start animation
    for i in 1..30
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 64 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for m in 0...8
        next if m>(i/2)
        fp["w#{m}"].angle += 2
        fp["w#{m}"].opacity += 32*(wait[m] < 8 ? 1 : -0.25)
        wait[m] +=  1
      end
      for j in 0...12
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Shadow Claw
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific176(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    # set up animation
    fp = {}
    fp["claw"] = Sprite.new(targetsprite.viewport)
    fp["claw"].bitmap = pbBitmap("Graphics/Animations/eb176")
    fp["claw"].ox = fp["claw"].bitmap.width/2
    fp["claw"].oy = fp["claw"].bitmap.height/2
    fp["claw"].x = cx
    fp["claw"].y = cy
    fp["claw"].zoom_x = factor
    fp["claw"].zoom_y = factor
    fp["claw"].src_rect.height = 0
    fp["claw"].z = targetsprite.z + 1
    for j in 0...12
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb176_3")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
      r = 32*factor
      fp["s#{j}"].x = cx - r + rand(r*2)
      fp["s#{j}"].y = cy - r + rand(r*2)
      fp["s#{j}"].opacity = 0
      fp["s#{j}"].z = targetsprite.z
      fp["s#{j}"].angle = rand(360)
    end
    for j in 0...12
      fp["p#{j}"] = Sprite.new(targetsprite.viewport)
      fp["p#{j}"].bitmap = pbBitmap("Graphics/Animations/eb176_2")
      fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
      fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
      r = 48*factor
      fp["p#{j}"].x = cx - r + rand(r*2)
      fp["p#{j}"].y = cy - r + rand(r)
      fp["p#{j}"].opacity = 0
      fp["p#{j}"].z = targetsprite.z + 1
      fp["p#{j}"].color = Color.new(0,0,0,0)
    end
    pbSEPlay("eb_ground1",75)
    for i in 0...64
      pbSEPlay("eb_normal3",85) if i == 4
      fp["claw"].src_rect.height += 16
      for j in 0...12
        next if i < 8
        fp["s#{j}"].opacity += 16*((i-8) < 24 ? 1 : -2)
        fp["s#{j}"].angle += 2
        fp["s#{j}"].zoom_x -= 0.01 if i >= 12 if fp["s#{j}"].zoom_x > 0
        fp["s#{j}"].zoom_y -= 0.01 if i >= 12 if fp["s#{j}"].zoom_y > 0
        #fp["s#{j}"].x += 2*((fp["s#{j}"].x > targetsprite.x) ? 1 : -1)
        #fp["s#{j}"].y += 2*((fp["s#{j}"].x > targetsprite.x) ? 1 : -1)
      end
      for j in 0...12
        next if i < 8
        next if j>(i-8)
        fp["p#{j}"].opacity += 32*((i-8) < 24 ? 1 : -1)
        fp["p#{j}"].color.alpha += 8
        fp["p#{j}"].zoom_x -= 0.05 if i >= 24 if fp["p#{j}"].zoom_x > 0
        fp["p#{j}"].zoom_y -= 0.05 if i >= 24 if fp["p#{j}"].zoom_y > 0
        #fp["p#{j}"].x += 2*((fp["p#{j}"].x > targetsprite.x) ? 1 : -1)
        #fp["p#{j}"].y -= 2
      end
      fp["claw"].opacity -= 32 if i >= 16
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Night Shade
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific183(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    factor = usersprite.zoom_x
    shake = 2
    # play animation
    pbSEPlay("fog2",80)
    16.times do
      fp["bg"].opacity += 8
      usersprite.still
      wait(1,true)
    end
    for i in 0...24
      if i < 16
        usersprite.zoom_x += 0.2*factor/8.0 if usersprite.zoom_x < 1.2*factor
        usersprite.zoom_y += 0.2*factor/8.0 if usersprite.zoom_y < 1.2*factor
        usersprite.tone.red += 8
        usersprite.tone.green += 8
        usersprite.tone.blue += 8
      end
      usersprite.still
      wait(1)
    end
    for i in 0...24
      if i < 24
        targetsprite.addOx(shake)
        shake = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      targetsprite.tone.red -= 16 if i < 16
      targetsprite.tone.green -= 16 if i < 16
      targetsprite.tone.blue -= 16 if i < 16
      targetsprite.still if i >= 12
      usersprite.still
      wait(1)
    end
    8.times do
      usersprite.zoom_x -= 0.2*factor/8.0
      usersprite.zoom_y -= 0.2*factor/8.0
      usersprite.tone.red -= 16
      usersprite.tone.green -= 16
      usersprite.tone.blue -= 16
      usersprite.still
      targetsprite.still
      wait(1)
    end
    16.times do
      targetsprite.tone.red += 16
      targetsprite.tone.green += 16
      targetsprite.tone.blue += 16
      fp["bg"].opacity -= 8
      usersprite.still
      wait(1)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Leaf Storm
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific191(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []; prndx = []
    rndy = []; prndy = []
    rangl = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb191_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...128
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb191_2")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].visible = false
      fp["#{i}"].z = 50
      rndx.push(rand(256)); prndx.push(rand(72))
      rndy.push(rand(256)); prndy.push(rand(72))
      rangl.push(rand(9))
      dx.push(0)
      dy.push(0)
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb191")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].mirror = player2
    fp["cir"].zoom_x = (player ? 1 : 1.5)*0.5
    fp["cir"].zoom_y = (player ? 1 : 1.5)*0.5
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb191_3")
      fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
      fp["#{i}s"].angle = rand(360)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    k = 0
    # start animation
    @vector.set(vector2)
    for i in 0...30
      if i < 10
        fp["bg"].opacity += 25.5
      elsif i < 20
        fp["bg"].color.alpha -= 25.5
      else
        fp["cir"].x, fp["cir"].y = getCenter(usersprite)
        fp["cir"].angle += 16*(player2 ? -1 : 1)
        fp["cir"].opacity += 25.5
        fp["cir"].zoom_x += (player ? 1 : 1.5)*0.05
        fp["cir"].zoom_y += (player ? 1 : 1.5)*0.05
        k += 1 if i%4==0; k = 0 if k > 1
        fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
      end
      pbSEPlay("eb_grass2") if i == 20
      fp["bg"].update
      wait(1,true)
    end
    pbSEPlay("eb_wind1",90)
    for i in 0...96
      pbSEPlay("eb_grass1",60) if i%3==0 && i < 64
      for j in 0...128
        next if j>(i*2)
        if !fp["#{j}"].visible
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 46*usersprite.zoom_x*0.5 + prndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 46*usersprite.zoom_y*0.5 + prndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
          fp["#{j}"].visible = true
        end
        cx, cy = getCenter(usersprite)
        x0 = cx - 46*usersprite.zoom_x*0.5 + prndx[j]*usersprite.zoom_x*0.5
        y0 = cy - 46*usersprite.zoom_y*0.5 + prndy[j]*usersprite.zoom_y*0.5
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 128*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 128*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].angle += rangl[j]*2
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
        else
          fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
        end
      end
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 16*(player2 ? -1 : 1)
      fp["cir"].opacity -= (i>=72) ? 51 : 2
      k += 1 if i%4==0; k = 0 if k > 1
      fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      #pbSEPlay("Comet Punch") if i == 64
      fp["bg"].update
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Solar Beam
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific195(userindex,targetindex,hitnum=0,multihit=false)
    if hitnum == 1
      return moveAnimationSolarCharge(userindex,targetindex)
    elsif hitnum == 0
      return moveAnimationSolarBeam(userindex,targetindex)
    end
  end

  def moveAnimationSolarCharge(userindex,targetindex)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(userindex,player)
    factor = player ? 2 : 1
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    rndx = []
    rndy = []
    for i in 0...12
      fp["#{i}"] = Sprite.new(usersprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb195")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
    end
    k = 0
    c = [Tone.new(211,186,3),Tone.new(0,0,0)]
    # start animation
    @vector.set(vector)
    for i in 0...128
      cx, cy = getCenter(usersprite)
      for j in 0...12
        if fp["#{j}"].opacity == 0
          r = rand(2)
          fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
          fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
          x, y = randCircleCord(64*factor)
          fp["#{j}"].x = cx - 64*factor*usersprite.zoom_x + x*usersprite.zoom_x
          fp["#{j}"].y = cy - 64*factor*usersprite.zoom_y + y*usersprite.zoom_y
        end
        next if j>(i/4)
        x2 = cx
        y2 = cy
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
        fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
        if i >= 96
          fp["#{j}"].opacity -= 35
        elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{j}"].opacity = 0
        else
          fp["#{j}"].opacity += 35
        end
      end
      if i < 96
        fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.6
      else
        fp["bg"].opacity -= 5
      end
      if i < 112
        if i%16 == 0
          k += 1
          k = 0 if k > 1
        end
        usersprite.tone.red += (c[k].red - usersprite.tone.red)*0.2
        usersprite.tone.green += (c[k].green - usersprite.tone.green)*0.2
        usersprite.tone.blue += (c[k].blue - usersprite.tone.blue)*0.2
      end
      pbSEPlay("Absorb2",100) if i == 16
      pbSEPlay("Saint8",70) if i == 16
      wait(1,true)
    end
    usersprite.tone = Tone.new(0,0,0)
    @vector.set(defaultvector)
    pbDisposeSpriteHash(fp)
    return true
  end

  def moveAnimationSolarBeam(userindex,targetindex)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1.5
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb195")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(64))
      rndy.push(rand(64))
      dx.push(0)
      dy.push(0)
    end
    shake = 4
    # start animation
    pbSEPlay("Refresh",150)
    for i in 0...96
      pbSEPlay("Psych Up",80) if i == 48
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 32*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 32*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        cx, cy = getCenter(targetsprite,true)
        next if j>(i)
        x2 = cx - 32*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 32*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = dx[j]
        y0 = dy[j]
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].opacity += 32
        nextx = fp["#{j}"].x + (x2 - x0)*0.1
        nexty = fp["#{j}"].y + (y2 - y0)*0.1
        if !player
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
        else
          fp["#{j}"].z = targetsprite.z + 1 if nextx < cx && nexty > cy
        end
      end
      fp["bg"].opacity += 10 if fp["bg"].opacity < 255*0.75
      if i >= 32
        cx, cy = getCenter(targetsprite,true)
        targetsprite.tone.red += 5.4 if targetsprite.tone.red < 194.4
        targetsprite.tone.green += 3.4 if targetsprite.tone.green < 122.4
        targetsprite.tone.blue += 0.15 if targetsprite.tone.blue < 5.4
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      @vector.set(DUALVECTOR) if i == 24
      @vector.inc = 0.1 if i == 24
      wait(1,true)
    end
    20.times do
      cx, cy = getCenter(targetsprite,true)
      targetsprite.tone.red -= 9.7
      targetsprite.tone.green -= 6.1
      targetsprite.tone.blue -= 0.27
      targetsprite.addOx(shake)
      shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
      shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
      targetsprite.still
      fp["bg"].opacity -= 15
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    targetsprite.tone = Tone.new(0,0,0)
    @vector.set(defaultvector)
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Giga Drain
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific200(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific210(userindex,targetindex,hitnum,multihit,"giga")
  end
  #-----------------------------------------------------------------------------
  #  Mega Drain
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific207(userindex,targetindex,hitnum=0,multihit=false)
    return pbMoveAnimationSpecific210(userindex,targetindex,hitnum,multihit,"mega")
  end
  #-----------------------------------------------------------------------------
  #  Vine Whip
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific208(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    @vector.set(vector)
    wait(16,true)
    cx, cy = getCenter(targetsprite,true)
    fp = {}
    fp["whip"] = Sprite.new(targetsprite.viewport)
    fp["whip"].bitmap = pbBitmap("Graphics/Animations/eb208")
    fp["whip"].ox = fp["whip"].bitmap.width*0.75
    fp["whip"].oy = fp["whip"].bitmap.height*0.5
    fp["whip"].angle = 315
    fp["whip"].zoom_x = targetsprite.zoom_x*1.5
    fp["whip"].zoom_y = targetsprite.zoom_y*1.5
    fp["whip"].color = Color.new(255,255,255,0)
    fp["whip"].opacity = 0
    fp["whip"].x = cx + 32*targetsprite.zoom_x
    fp["whip"].y = cy - 48*targetsprite.zoom_y
    fp["whip"].z = player ? 29 : 19

    fp["imp"] = Sprite.new(targetsprite.viewport)
    fp["imp"].bitmap = pbBitmap("Graphics/Animations/eb244_2")
    fp["imp"].ox = fp["imp"].bitmap.width/2
    fp["imp"].oy = fp["imp"].bitmap.height/2
    fp["imp"].zoom_x = targetsprite.zoom_x*2
    fp["imp"].zoom_y = targetsprite.zoom_y*2
    fp["imp"].visible = false
    fp["imp"].x = cx
    fp["imp"].y = cy - 48*targetsprite.zoom_y
    fp["imp"].z = player ? 29 : 19

    posx = []
    posy = []
    angl = []
    zoom = []
    for j in 0...12
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb208_2")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].z = player ? 29 : 19
      fp["#{j}"].visible = false
      z = [1,1.25,0.75,0.5][rand(4)]
      fp["#{j}"].zoom_x = targetsprite.zoom_x*z
      fp["#{j}"].zoom_y = targetsprite.zoom_y*z
      fp["#{j}"].angle = rand(360)
      posx.push(rand(128))
      posy.push(rand(64))
      angl.push((rand(2)==0 ? 1 : -1))
      zoom.push(z)
      fp["#{j}"].opacity = (155+rand(100))
    end
    # start animation
    k = 1
    for i in 0...32
      pbSEPlay("eb_normal4",80) if i == 4
      if i < 16
        fp["whip"].opacity += 128 if i < 4
        fp["whip"].angle += 16
        fp["whip"].color.alpha += 16 if i >= 8
        fp["whip"].zoom_x -= 0.2 if i >= 8
        fp["whip"].zoom_y -= 0.16 if i >= 4
        fp["whip"].opacity -= 64 if i >= 12
        fp["imp"].visible = true if i == 3
        if i >= 4
          fp["imp"].angle += 4
          fp["imp"].zoom_x -= 0.02
          fp["imp"].zoom_x -= 0.02
          fp["imp"].opacity -= 32
        end
        targetsprite.zoom_y -= 0.04*k
        targetsprite.zoom_x += 0.02*k
        targetsprite.tone = Tone.new(255,255,255) if i == 4
        targetsprite.tone.red -= 51 if targetsprite.tone.red > 0
        targetsprite.tone.green -= 51 if targetsprite.tone.green > 0
        targetsprite.tone.blue -= 51 if targetsprite.tone.blue > 0
        k *= -1 if (i-4)%6==0
      end
      cx, cy = getCenter(targetsprite,true)
      for j in 0...12
        next if i < 4
        next if j>(i-4)
        fp["#{j}"].visible = true
        fp["#{j}"].x = cx - 64*targetsprite.zoom_x*zoom[j] + posx[j]*targetsprite.zoom_x*zoom[j]
        fp["#{j}"].y = cy - posy[j]*targetsprite.zoom_y*zoom[j] - 48*targetsprite.zoom_y*zoom[j]# - (i-4)*2*targetsprite.zoom_y
        fp["#{j}"].angle += angl[j]
      end
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    for i in 0...16
      wait(1,true)
      cx, cy = getCenter(targetsprite,true)
      k = 20 - i
      for j in 0...12
        fp["#{j}"].x = cx - 64*targetsprite.zoom_x*zoom[j] + posx[j]*targetsprite.zoom_x*zoom[j]
        fp["#{j}"].y = cy - posy[j]*targetsprite.zoom_y*zoom[j] - 48*targetsprite.zoom_y*zoom[j]# - (k)*2*targetsprite.zoom_y
        fp["#{j}"].opacity -= 16
        fp["#{j}"].angle += angl[j]
        fp["#{j}"].zoom_x = targetsprite.zoom_x
        fp["#{j}"].zoom_y = targetsprite.zoom_y
      end
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Absorb
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific210(userindex,targetindex,hitnum=0,multihit=false,type="absorb")
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,166,94)) if type == "mega"
    fp["bg"].opacity = 0

    ext = ["eb210","eb210_2"]
    ext = ["eb210","eb207"] if type == "mega"
    ext = ["eb200"] if type == "giga"
    ext = ["eb727"] if type == "star"
    cxT, cyT = getCenter(targetsprite,true)
    cxP, cyP = getCenter(usersprite,true)

    mx = !player ? (cxT-cxP)/2 : (cxP-cxT)/2
    mx += player ? cxT : cxP
    my = !player ? (cyP-cyT)/2 : (cyT-cyP)/2
    my += player ? cyP : cyT

    curves = []
    zoom = []
    frames = ["giga","mega","star"].include?(type) ? 32 : 16
    factor = ((type == "giga" or type == "star") ? 2 : 1)
    if type == "star"
      pbSEPlay("eb_dragon2",factor==2 ? 100 : 80)
    else
      pbSEPlay("Absorb2",factor==2 ? 100 : 80)
    end
    for j in 0...frames
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/"+ext[rand(ext.length)])
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].x = cxT
      fp["#{j}"].y = cyT
      z = [1,0.75,0.5,0.25][rand(4)]
      fp["#{j}"].zoom_x = z*usersprite.zoom_x
      fp["#{j}"].zoom_y = z*usersprite.zoom_y
      ox = -16*factor + rand(32*factor)
      oy = -16*factor + rand(32*factor)
      vert = rand(96)*(rand(2)==0 ? 1 : -1)*(factor**2)
      fp["#{j}"].z = 50
      fp["#{j}"].opacity = 0
      curve = calculateCurve(cxT+ox,cyT+oy,mx,my+vert+oy,cxP+ox,cyP+oy,32)
      curves.push(curve)
      zoom.push(z)
    end
    max = (type == "giga" or type == "star") ? 16 : 8
    for j in 0...max
      fp["s#{j}"] = Sprite.new(usersprite.viewport)
      fp["s#{j}"].bitmap = type == "star" ? pbBitmap("Graphics/Animations/ebHealingSV") : pbBitmap("Graphics/Animations/ebHealing")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
      fp["s#{j}"].zoom_x = usersprite.zoom_x
      fp["s#{j}"].zoom_y = usersprite.zoom_x
      cx, cy = getCenter(usersprite,true)
      fp["s#{j}"].x = cx - 48*usersprite.zoom_x + rand(96)*usersprite.zoom_x
      fp["s#{j}"].y = cy - 48*usersprite.zoom_y + rand(96)*usersprite.zoom_y
      fp["s#{j}"].visible = false
      fp["s#{j}"].z = 51
    end
    for i in 0...64
      fp["bg"].opacity += 16 if fp["bg"].opacity < 128
      for j in 0...frames
        next if j>i/(32/frames)
        k = i - j*(32/frames)
        fp["#{j}"].visible = false if k >= frames
        k = frames - 1 if k >= frames
        k = 0 if k < 0
        if (type == "giga" or type == "star")
          fp["#{j}"].tone.red += 4
          fp["#{j}"].tone.blue += 4
          fp["#{j}"].tone.green += 4
        end
        fp["#{j}"].x = curves[j][k][0]
        fp["#{j}"].y = curves[j][k][1]
        fp["#{j}"].opacity += (k < 16) ? 64 : -16
        fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - targetsprite.zoom_x*zoom[j])*0.1
        fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - targetsprite.zoom_y*zoom[j])*0.1
      end
      for k in 0...max
        next if type == "absorb"
        next if i < frames/2
        next if k>(i-frames/2)/(16/max)
        fp["s#{k}"].visible = true
        fp["s#{k}"].opacity -= 16
        fp["s#{k}"].y -= 2
      end
      if (type == "giga" or type == "star")
        usersprite.tone.red += 8 if usersprite.tone.red < 128
        usersprite.tone.green += 8 if usersprite.tone.green < 128
        usersprite.tone.blue += 8 if usersprite.tone.blue < 128
      end
      pbSEPlay("Recovery",80) if type != "absorb" && i == (frames/2)
      wait(1,true)
    end
    for i in 0...8
      fp["bg"].opacity -= 16
      if (type == "giga" or type == "star")
        usersprite.tone.red -= 16
        usersprite.tone.green -= 16
        usersprite.tone.blue -= 16
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Earthquake
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific223(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    player = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    randx = []
    randy = []
    speed = []
    angle = []
    fp["bg"] = Sprite.new(usersprite.viewport)
    fp["bg"].bitmap = Bitmap.new(usersprite.viewport.rect.width,usersprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    for m in 0...4
      randx.push([]); randy.push([]); speed.push([]); angle.push([])
      targetsprite = @sprites["pokemon#{m}"]
      next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
      next if m == userindex
      for j in 0...32
        fp["#{j}#{m}"] = Sprite.new(usersprite.viewport)
        fp["#{j}#{m}"].bitmap = pbBitmap("Graphics/Animations/eb223")
        fp["#{j}#{m}"].ox = fp["#{j}#{m}"].bitmap.width/2
        fp["#{j}#{m}"].oy = fp["#{j}#{m}"].bitmap.height/2
        fp["#{j}#{m}"].z = 50
        z = [0.5,0.4,0.3,0.7][rand(4)]
        fp["#{j}#{m}"].zoom_x = z
        fp["#{j}#{m}"].zoom_y = z
        fp["#{j}#{m}"].visible = false
        randx[m].push(rand(82)+(rand(2)==0 ? 82 : 0))
        randy[m].push(rand(32)+32)
        speed[m].push(4)
        angle[m].push((rand(8)+1)*(rand(2)==0 ? -1 : 1))
      end
    end
    @vector.set(DUALVECTOR)
    16.times do
      fp["bg"].opacity += 8
      wait(1,true)
    end
    factor = usersprite.zoom_x
    k = -1
    pbSEPlay("Earth4")
    for i in 0...92
      for m in 0...4
        targetsprite = @sprites["pokemon#{m}"]
        next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
        next if m == userindex
        cx, cy = getCenter(targetsprite,true)
        for j in 0...32
          next if j>(i/2)
          if !fp["#{j}#{m}"].visible
            fp["#{j}#{m}"].visible = true
            fp["#{j}#{m}"].x = cx - 82*targetsprite.zoom_x + randx[m][j]*targetsprite.zoom_x
            fp["#{j}#{m}"].y = targetsprite.y
            fp["#{j}#{m}"].zoom_x *= targetsprite.zoom_x
            fp["#{j}#{m}"].zoom_y *= targetsprite.zoom_y
          end
          fp["#{j}#{m}"].y -= speed[m][j]*2*targetsprite.zoom_y
          speed[m][j] *= -1 if (fp["#{j}#{m}"].y <= targetsprite.y - randy[m][j]*targetsprite.zoom_y) || (fp["#{j}#{m}"].y >= targetsprite.y)
          fp["#{j}#{m}"].opacity -= 35 if speed[m][j] < 0
          fp["#{j}#{m}"].angle += angle[m][j]
        end
      end
      usersprite.zoom_x -= 0.2/6 if usersprite.zoom_x > factor
      usersprite.zoom_y += 0.2/6 if usersprite.zoom_y < factor

      moveEntireScene(k*8,0,true,true)
      k *= -1 if i%3==0
      if i%32==0
        pbSEPlay("Earth4",60)
        usersprite.zoom_x = factor*1.2
        usersprite.zoom_y = factor*0.8
      end
      fp["bg"].opacity -= 12 if i >= 72
      wait(1,false)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Earth Power
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific224(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    @vector.set(getRealVector(targetindex,player))
    16.times do
      fp["bg"].opacity += 8
      wait(1,true)
    end
    # set up animation
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    y0 = targetsprite.y
    x = [cx - 64*factor, cx + 64*factor, cx]
    y = [y0, y0, y0 + 24*factor]
    dx = []
    for k in 0...3
      fp["f#{k}"] = Sprite.new(targetsprite.viewport)
      fp["f#{k}"].bitmap = pbBitmap("Graphics/Animations/eb224")
      fp["f#{k}"].ox = fp["f#{k}"].bitmap.width/2
      fp["f#{k}"].oy = fp["f#{k}"].bitmap.height
      fp["f#{k}"].zoom_x = factor + 0.25
      fp["f#{k}"].zoom_y = 0
      fp["f#{k}"].x = x[k]
      fp["f#{k}"].y = y[k]
      fp["f#{k}"].z = targetsprite.z

      for m in 0...16
        fp["p#{k}#{m}"] = Sprite.new(targetsprite.viewport)
        fp["p#{k}#{m}"].bitmap = Bitmap.new(8,8)
        fp["p#{k}#{m}"].ox = 4
        fp["p#{k}#{m}"].oy = 4
        c = [Color.new(139,7,7),Color.new(239,90,1)][rand(2)]
        fp["p#{k}#{m}"].bitmap.drawCircle(c)
        fp["p#{k}#{m}"].visible = false
        z = [1,0.5,0.75,0.25][rand(4)]
        fp["p#{k}#{m}"].zoom_x = z
        fp["p#{k}#{m}"].zoom_y = z
        fp["p#{k}#{m}"].x = x[k] - 16 + rand(32)
        fp["p#{k}#{m}"].y = y[k] - rand(32)
        fp["p#{k}#{m}"].z = targetsprite.z + 1
        dx.push((rand(2)==0 ? 1 : -1)*2)
      end
    end
    # start animation
    for k in 0...3
      wait(8,true)
      j = -1
      l = 6
      pbSEPlay("eb_rock1",80)
      pbSEPlay("Earth4",50,50)
      for i in 0...24
        j *= -1 if i%4==0
        l -= 2 if i%8==0
        fp["f#{k}"].zoom_x -= 0.1 if fp["f#{k}"].zoom_x > 0
        fp["f#{k}"].zoom_y += 0.3
        fp["f#{k}"].opacity -= 24
        moveEntireScene(0,j*l,true,true) if i < 16
        for m in 0...16
          next if m>(i*2)
          fp["p#{k}#{m}"].visible = true
          fp["p#{k}#{m}"].y -= 16
          fp["p#{k}#{m}"].x += dx[m]
          fp["p#{k}#{m}"].opacity -= 16
        end
        wait(1)
      end
    end
    16.times do
      fp["bg"].opacity -= 8
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ice Punch
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific245(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    angl = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
    fp["bg"].opacity = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb248")
      fp["#{i}"].src_rect.set(rand(2)*26,0,26,42)
      fp["#{i}"].ox = 13
      fp["#{i}"].oy = 21
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      r = rand(101)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x - r*0.0075*targetsprite.zoom_x)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y - r*0.0075*targetsprite.zoom_y)
      rndx.push(rand(196))
      rndy.push(rand(196))
      angl.push((1+rand(3))*4*(rand(2)==0 ? 1 : -1))
    end
    fp["punch"] = Sprite.new(targetsprite.viewport)
    fp["punch"].bitmap = pbBitmap("Graphics/Animations/eb108")
    fp["punch"].ox = fp["punch"].bitmap.width/2
    fp["punch"].oy = fp["punch"].bitmap.height/2
    fp["punch"].opacity = 0
    fp["punch"].z = 40
    fp["punch"].angle = 180
    fp["punch"].zoom_x = player ? 6 : 4
    fp["punch"].zoom_y = player ? 6 : 4
    fp["punch"].tone = Tone.new(6,16,48)
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    pbSEPlay("fog2",75)
    for i in 0...72
      cx, cy = getCenter(targetsprite,true)
      fp["punch"].x = cx
      fp["punch"].y = cy
      fp["punch"].angle -= 45 if i < 40
      fp["punch"].zoom_x -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].zoom_y -= player ? 0.2 : 0.15 if i < 40
      fp["punch"].opacity += 8 if i < 40
      if i >= 40
        fp["punch"].tone = Tone.new(255,255,255) if i == 40
        fp["punch"].toneAll(-25.5)
        fp["punch"].opacity -= 25.5
      end
      pbSEPlay("Ice2") if i==40
      pbSEPlay("eb_ice1",75) if i==40
      for j in 0...12
        next if i < 40
        if fp["#{j}"].opacity == 0
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 98*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 98*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].angle += angl[j]
        fp["#{j}"].opacity += 32
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        if i >= 56
          targetsprite.tone.red -= 8
          targetsprite.tone.green -= 8
          targetsprite.tone.blue -= 8
          fp["bg"].opacity -= 10
        else
          targetsprite.tone.red += 8
          targetsprite.tone.green += 8
          targetsprite.tone.blue += 8
        end
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    @vector.set(defaultvector) if !multihit
    20.times do
      cx, cy = getCenter(targetsprite,true)
      for j in 0...12
        fp["#{j}"].x = cx - 98*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        fp["#{j}"].y = cy - 98*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        fp["#{j}"].angle += angl[j]
        fp["#{j}"].opacity -= 13
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ice Beam
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific243(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1
    targetsprite.viewport.color = Color.new(255,255,255,155)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    crndx = []
    crndy = []
    dx = []
    dy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
    fp["bg"].opacity = 0
    for i in 0...16
      fp["c#{i}"] = Sprite.new(targetsprite.viewport)
      fp["c#{i}"].bitmap = pbBitmap("Graphics/Animations/eb250")
      fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
      fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
      fp["c#{i}"].opacity = 0
      fp["c#{i}"].z = 19
      crndx.push(rand(64))
      crndy.push(rand(64))
    end
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb243")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    # start animation
    for i in 0...96
      pbSEPlay("Ice8") if i == 12
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        cx, cy = getCenter(targetsprite,true)
        next if j>(i)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        x0 = dx[j]
        y0 = dy[j]
        fp["#{j}"].x += (x2 - x0)*0.05
        fp["#{j}"].y += (y2 - y0)*0.05
        fp["#{j}"].zoom_x = player ? usersprite.zoom_x : targetsprite.zoom_x
        fp["#{j}"].zoom_y = player ? usersprite.zoom_y : targetsprite.zoom_y
        fp["#{j}"].opacity += 32
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x + (x2 - x0)*0.05
        nexty = fp["#{j}"].y + (y2 - y0)*0.05
        if !player
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
          fp["#{j}"].visible = false if nextx > cx && nexty < cy
        else
          fp["#{j}"].visible = false if nextx < cx && nexty > cy

        end
      end
      pbSEPlay("Ice1") if i>32 && (i-32)%4==0
      for j in 0...16
        cx, cy = getCenter(targetsprite,true)
        if fp["c#{j}"].opacity == 0 && fp["c#{j}"].tone.gray == 0
          fp["c#{j}"].zoom_x = factor*targetsprite.zoom_x
          fp["c#{j}"].zoom_y = factor*targetsprite.zoom_x
          fp["c#{j}"].x = cx
          fp["c#{j}"].y = cy
        end
        next if j>((i-12)/4)
        next if i<12
        x2 = cx - 32*targetsprite.zoom_x + crndx[j]*targetsprite.zoom_x
        y2 = cy - 32*targetsprite.zoom_y + crndy[j]*targetsprite.zoom_y
        x0 = fp["c#{j}"].x
        y0 = fp["c#{j}"].y
        fp["c#{j}"].x += (x2 - x0)*0.2
        fp["c#{j}"].y += (y2 - y0)*0.2
        fp["c#{j}"].angle += 2
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["c#{j}"].opacity -= 24
          fp["c#{j}"].tone.gray += 8
          fp["c#{j}"].angle += 2
        else
          fp["c#{j}"].opacity += 35
        end
      end
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
      if i >= 32
        cx, cy = getCenter(targetsprite,true)
        targetsprite.tone.red += 5.4 if targetsprite.tone.red < 108
        targetsprite.tone.green += 6.4 if targetsprite.tone.green < 128
        targetsprite.tone.blue += 8 if targetsprite.tone.blue < 160
        targetsprite.still
      end
      @vector.set(vector) if i == 24
      @vector.inc = 0.1 if i == 24
      targetsprite.viewport.color.alpha -= 5 if targetsprite.viewport.color.alpha > 0
      wait(1,true)
    end
    20.times do
      cx, cy = getCenter(targetsprite,true)
      targetsprite.tone.red -= 5.4
      targetsprite.tone.green -= 6.4
      targetsprite.tone.blue -= 8
      targetsprite.still
      fp["bg"].opacity -= 15
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    targetsprite.tone = Tone.new(0,0,0)
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Icicle Crash
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific244(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    @vector.set(vector)
    wait(16,true)
    fp = {}
    for j in 0...16
      fp["i#{j}"] = Sprite.new(targetsprite.viewport)
      fp["i#{j}"].bitmap = pbBitmap("Graphics/Animations/eb250")
      fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
      fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
      fp["i#{j}"].opacity = 0
      fp["i#{j}"].zoom_x = targetsprite.zoom_x
      fp["i#{j}"].zoom_y = targetsprite.zoom_y
      fp["i#{j}"].z = player ? 29 : 19
      fp["i#{j}"].x = targetsprite.x + rand(32)*targetsprite.zoom_x*(rand(2)==0 ? 1 : -1)
      fp["i#{j}"].y = targetsprite.y - 8*targetsprite.zoom_y + rand(16)*targetsprite.zoom_y
    end
    for j in 0...5
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = pbBitmap("Graphics/Animations/eb244")
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
      fp["s#{j}"].opacity = 0
      fp["s#{j}"].zoom_x = targetsprite.zoom_x
      fp["s#{j}"].zoom_y = targetsprite.zoom_y
      fp["s#{j}"].z = player ? 29 : 19
      fp["s#{j}"].x = targetsprite.x - 48*targetsprite.zoom_x + rand(96)*targetsprite.zoom_x
      fp["s#{j}"].y = targetsprite.y - 192*targetsprite.zoom_y

      fp["p#{j}"] = Sprite.new(targetsprite.viewport)
      fp["p#{j}"].bitmap = pbBitmap("Graphics/Animations/eb244_2")
      fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
      fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
      fp["p#{j}"].visible = false
      fp["p#{j}"].zoom_x = 2
      fp["p#{j}"].zoom_y = 2
      fp["p#{j}"].z = player ? 29 : 19
      fp["p#{j}"].x = fp["s#{j}"].x
      fp["p#{j}"].y = fp["s#{j}"].y + 192*targetsprite.zoom_y
    end
    k = -2
    for i in 0...64
      k *= -1 if i%4==0 && i >= 8
      pbSEPlay("eb_rock1",70) if i%8==0 && i >0 && i < 48
      for j in 0...5
        next if j>(i/6)
        fp["s#{j}"].opacity += 64
        fp["s#{j}"].y += 24*targetsprite.zoom_y if fp["s#{j}"].y < targetsprite.y
        fp["s#{j}"].zoom_y -= 0.2*targetsprite.zoom_y if fp["s#{j}"].y >= targetsprite.y
        fp["s#{j}"].visible = false if fp["s#{j}"].zoom_y <= 0.4*targetsprite.zoom_y
      end
      for j in 0...5
        next if i < 8
        next if j>(i-8)/8
        fp["p#{j}"].visible = true
        fp["p#{j}"].opacity -= 32
        fp["p#{j}"].zoom_x += 0.02
        fp["p#{j}"].zoom_y += 0.02
        fp["p#{j}"].angle += 8
      end
      for j in 0...16
        next if i < 8
        next if j>(i-8)/2
        fp["i#{j}"].opacity += 32*(fp["i#{j}"].zoom_x <= 0.5*targetsprite.zoom_x ? -1 : 1)
        fp["i#{j}"].zoom_x -= 0.02*targetsprite.zoom_x
        fp["i#{j}"].zoom_y -= 0.02*targetsprite.zoom_y
        fp["i#{j}"].x += 2*targetsprite.zoom_x*(fp["i#{j}"].x >= targetsprite.x ? 1 : -1)
        fp["i#{j}"].angle += 4*(fp["i#{j}"].x >= targetsprite.x ? 1 : -1)
      end
      moveEntireScene(0,k,true,true) if i >= 8 && i < 48
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Aurora Beam
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific246(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    indexes = player ? [0,2] : [1,3]
    vector = getRealVector(targetindex,player)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,0,0))
    fp["bg"].opacity = 0
    for i in 0...36
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb246")
      fp["#{i}"].src_rect.set(44*rand(4),0,44,44)
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/8
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      rndx.push(rand(8))
      rndy.push(rand(8))
    end
    shake = 2
    # start animation
    pbSEPlay("Psych Up")
    for i in 0...128
      pbSEPlay("Ice1",75) if i%8==0
      for j in 0...36
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          fp["#{j}"].zoom_x = usersprite.zoom_x
          fp["#{j}"].zoom_y = usersprite.zoom_y
          cx, cy = getCenter(usersprite)
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        cx, cy = getCenter(targetsprite,true)
        next if j>(i/2)
        x2 = cx - 4*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 4*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - targetsprite.zoom_x)*0.1
        fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - targetsprite.zoom_y)*0.1
        fp["#{j}"].angle += 2
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{j}"].opacity -= 8
          fp["#{j}"].tone.gray += 8
          fp["#{j}"].angle += 2
        else
          fp["#{j}"].opacity += 12
        end
      end
      if i >= 96
        fp["bg"].opacity -= 10
      else
        fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.7
      end
      if i >= 72
        if i >= 96
          targetsprite.tone.red -= 4.8/2
          targetsprite.tone.green -= 4.8/2
          targetsprite.tone.blue -= 4.8/2
        else
          targetsprite.tone.red += 4.8 if targetsprite.tone.red < 96
          targetsprite.tone.green += 4.8 if targetsprite.tone.green < 96
          targetsprite.tone.blue += 4.8 if targetsprite.tone.blue < 96
        end
        targetsprite.still
      end
      @vector.set(vector) if i == 24
      @vector.inc = 0.1 if i == 24
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    targetsprite.tone = Tone.new(0,0,0,0)
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Ice Fang
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific248(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
    fp["bg"].opacity = 0
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb248")
      fp["#{i}"].src_rect.set(0,0,26,42)
      fp["#{i}"].ox = 13
      fp["#{i}"].oy = 21
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = (player ? 29 : 19)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)
      rndx.push(rand(128))
      rndy.push(rand(128))
    end
    fp["fang1"] = Sprite.new(targetsprite.viewport)
    fp["fang1"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang1"].ox = fp["fang1"].bitmap.width/2
    fp["fang1"].oy = fp["fang1"].bitmap.height - 20
    fp["fang1"].opacity = 0
    fp["fang1"].z = 41
    fp["fang1"].tone = Tone.new(6,16,48)
    fp["fang2"] = Sprite.new(targetsprite.viewport)
    fp["fang2"].bitmap = pbBitmap("Graphics/Animations/eb028")
    fp["fang2"].ox = fp["fang1"].bitmap.width/2
    fp["fang2"].oy = fp["fang1"].bitmap.height - 20
    fp["fang2"].opacity = 0
    fp["fang2"].z = 40
    fp["fang2"].angle = 180
    fp["fang2"].tone = Tone.new(6,16,48)
    shake = 4
    # start animation
    @vector.set(getRealVector(targetindex,player))
    for i in 0...92
      cx, cy = getCenter(targetsprite,true)
      fp["fang1"].x = cx; fp["fang1"].y = cy
      fp["fang1"].zoom_x = targetsprite.zoom_x; fp["fang1"].zoom_y = targetsprite.zoom_y
      fp["fang2"].x = cx; fp["fang2"].y = cy
      fp["fang2"].zoom_x = targetsprite.zoom_x; fp["fang2"].zoom_y = targetsprite.zoom_y
      if i.between?(20,29)
        fp["fang1"].opacity += 5
        fp["fang1"].oy += 2
        fp["fang2"].opacity += 5
        fp["fang2"].oy += 2
      elsif i.between?(30,40)
        fp["fang1"].opacity += 25.5
        fp["fang1"].oy -= 4
        fp["fang2"].opacity += 25.5
        fp["fang2"].oy -= 4
      else i > 40
        fp["fang1"].opacity -= 26
        fp["fang1"].oy += 2
        fp["fang2"].opacity -= 26
        fp["fang2"].oy += 2
      end
      if i==32
        pbSEPlay("Super Fang")
        pbSEPlay("eb_ice1",75)
      end
      for j in 0...12
        next if i < 40
        if fp["#{j}"].opacity == 0 && fp["#{j}"].src_rect.x == 0
          fp["#{j}"].x = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
          fp["#{j}"].y = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
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
          fp["#{j}"].opacity += 45 if (i-40)/2 > j
        end
      end
      fp["bg"].opacity += 4 if  i < 40
      if i >= 40
        if i >= 56
          targetsprite.tone.red -= 8
          targetsprite.tone.green -= 8
          targetsprite.tone.blue -= 8
          fp["bg"].opacity -= 10
        else
          targetsprite.tone.red += 8
          targetsprite.tone.green += 8
          targetsprite.tone.blue += 8
        end
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      if i == 72
        targetsprite.ox = targetsprite.bitmap.width/2
        @vector.set(defaultvector) if !multihit
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Icy Wind
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific250(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    indexes = player ? [0,2] : [1,3]
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    # set up animation
    fp = {}
    rndx = [[],[]]
    rndy = [[],[]]
    irndx = [[],[]]
    irndy = [[],[]]
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
    fp["bg"].opacity = 0
    for m in 0...(@battle.doublebattle ? 2 : 1)
      targetsprite = @sprites["pokemon#{indexes[m]}"]
      for i in 0...16
        fp["#{m}#{i}"] = Sprite.new(targetsprite.viewport)
        fp["#{m}#{i}"].bitmap = pbBitmap("Graphics/Animations/eb250")
        fp["#{m}#{i}"].ox = fp["#{m}#{i}"].bitmap.width/2
        fp["#{m}#{i}"].oy = fp["#{m}#{i}"].bitmap.width/2
        fp["#{m}#{i}"].opacity = 0
        fp["#{m}#{i}"].z = (player ? 29 : 19)
        rndx[m].push(rand(64))
        rndy[m].push(rand(64))
      end
    end
    for m in 0...(@battle.doublebattle ? 2 : 1)
      targetsprite = @sprites["pokemon#{indexes[m]}"]
      next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
      for i in 0...8
        fp["i#{m}#{i}"] = Sprite.new(targetsprite.viewport)
        fp["i#{m}#{i}"].bitmap = pbBitmap("Graphics/Animations/eb248")
        fp["i#{m}#{i}"].src_rect.set(0,0,26,42)
        fp["i#{m}#{i}"].ox = 13
        fp["i#{m}#{i}"].oy = 21
        fp["i#{m}#{i}"].opacity = 0
        fp["i#{m}#{i}"].z = (player ? 29 : 19)
        fp["i#{m}#{i}"].zoom_x = (targetsprite.zoom_x)/2
        fp["i#{m}#{i}"].zoom_y = (targetsprite.zoom_y)/2
        irndx[m].push(rand(128))
        irndy[m].push(rand(128))
      end
    end
    shake = [2,2]
    # start animation
    for i in 0...152
      for m in 0...(@battle.doublebattle ? 2 : 1)
        targetsprite = @sprites["pokemon#{indexes[m]}"]
        next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
        for j in 0...16
          if fp["#{m}#{j}"].opacity == 0 && fp["#{m}#{j}"].tone.gray == 0
            fp["#{m}#{j}"].zoom_x = usersprite.zoom_x
            fp["#{m}#{j}"].zoom_y = usersprite.zoom_y
            cx, cy = getCenter(usersprite)
            fp["#{m}#{j}"].x = cx
            fp["#{m}#{j}"].y = cy
          end
          cx, cy = getCenter(targetsprite,true)
          next if j>(i/4)
          x2 = cx - 32*targetsprite.zoom_x + rndx[m][j]*targetsprite.zoom_x
          y2 = cy - 32*targetsprite.zoom_y + rndy[m][j]*targetsprite.zoom_y
          x0 = fp["#{m}#{j}"].x
          y0 = fp["#{m}#{j}"].y
          fp["#{m}#{j}"].x += (x2 - x0)*0.1
          fp["#{m}#{j}"].y += (y2 - y0)*0.1
          fp["#{m}#{j}"].zoom_x -= (fp["#{m}#{j}"].zoom_x - targetsprite.zoom_x)*0.1
          fp["#{m}#{j}"].zoom_y -= (fp["#{m}#{j}"].zoom_y - targetsprite.zoom_y)*0.1
          fp["#{m}#{j}"].angle += 2
          if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
            fp["#{m}#{j}"].opacity -= 8
            fp["#{m}#{j}"].tone.gray += 8
            fp["#{m}#{j}"].angle += 2
          else
            fp["#{m}#{j}"].opacity += 12
          end
        end
      end
      if i >= 132
        fp["bg"].opacity -= 7
      else
        fp["bg"].opacity += 2 if fp["bg"].opacity < 255*0.5
      end
      pbSEPlay("Ice7",80) if i==96
      pbSEPlay("Wind8",70) if i==12
      if i >= 96
        for m in 0...(@battle.doublebattle ? 2 : 1)
          targetsprite = @sprites["pokemon#{indexes[m]}"]
          next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
          cx, cy = getCenter(targetsprite,true)
          if i >= 132
            targetsprite.tone.red -= 4.8
            targetsprite.tone.green -= 4.8
            targetsprite.tone.blue -= 4.8
          else
            targetsprite.tone.red += 4.8 if targetsprite.tone.red < 96
            targetsprite.tone.green += 4.8 if targetsprite.tone.green < 96
            targetsprite.tone.blue += 4.8 if targetsprite.tone.blue < 96
          end
          targetsprite.addOx(shake[m])
          shake[m] = -2 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
          shake[m] = 2 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
          targetsprite.still
          for k in 0...8
            if fp["i#{m}#{k}"].opacity == 0 && fp["i#{m}#{k}"].src_rect.x == 0
              fp["i#{m}#{k}"].x = cx - 64*targetsprite.zoom_x + irndx[m][k]*targetsprite.zoom_x
              fp["i#{m}#{k}"].y = cy - 64*targetsprite.zoom_y + irndy[m][k]*targetsprite.zoom_y
            end
            fp["i#{m}#{k}"].src_rect.x += 26 if i%4==0 && fp["i#{m}#{k}"].opacity >= 255
            fp["i#{m}#{k}"].src_rect.x = 78 if fp["i#{m}#{k}"].src_rect.x > 78
            if fp["i#{m}#{k}"].src_rect.x==78
              fp["i#{m}#{k}"].opacity -= 24
              fp["i#{m}#{k}"].zoom_x += 0.02
              fp["i#{m}#{k}"].zoom_y += 0.02
            elsif fp["i#{m}#{k}"].opacity >= 255
              fp["i#{m}#{k}"].opacity -= 24
              pbSEPlay("Ice1",50)
            else
              fp["i#{m}#{k}"].opacity += 45 if (i-96)/2 > k
            end
          end
        end
      end
      @vector.set(DUALVECTOR) if i == 24
      @vector.inc = 0.1 if i == 24
      wait(1,true)
    end
    for m in 0...(@battle.doublebattle ? 2 : 1)
      targetsprite = @sprites["pokemon#{indexes[m]}"]
      next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
      targetsprite.ox = targetsprite.bitmap.width/2
      targetsprite.tone = Tone.new(0,0,0,0)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Hyper Beam
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific263(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player2 ? 2 : 1
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap("Graphics/Animations/eb263_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    for i in 0...72
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb263_4")
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 19
      rndx.push(rand(16))
      rndy.push(rand(16))
      dx.push(0)
      dy.push(0)
    end
    for i in 0...72
      fp["#{i}2"] = Sprite.new(targetsprite.viewport)
      fp["#{i}2"].bitmap = pbBitmap("Graphics/Animations/eb263_3")
      fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
      fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
      fp["#{i}2"].opacity = 0
      fp["#{i}2"].z = 19
    end
    fp["cir"] = Sprite.new(targetsprite.viewport)
    fp["cir"].bitmap = pbBitmap("Graphics/Animations/eb263")
    fp["cir"].ox = fp["cir"].bitmap.width/2
    fp["cir"].oy = fp["cir"].bitmap.height/2
    fp["cir"].z = 50
    fp["cir"].zoom_x = player ? 0.5 : 1
    fp["cir"].zoom_y = player ? 0.5 : 1
    fp["cir"].opacity = 0
    for i in 0...8
      fp["#{i}s"] = Sprite.new(targetsprite.viewport)
      fp["#{i}s"].bitmap = pbBitmap("Graphics/Animations/eb263_2")
      fp["#{i}s"].ox = -32 -rand(64)
      fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
      fp["#{i}s"].angle = rand(270)
      r = rand(2)
      fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
      fp["#{i}s"].visible = false
      fp["#{i}s"].opacity = 255 - rand(101)
      fp["#{i}s"].z = 50
    end
    shake = 4
    # start animation
    @vector.set(vector2)
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      pbSEPlay("Harden") if i == 4
      fp["bg"].update
      wait(1,true)
    end
    wait(4,true)
    pbSEPlay("Psych Up")
    for i in 0...96
      for j in 0...72
        if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
        next if j>(i)
        cx, cy = getCenter(usersprite)
        x0 = dx[j]
        y0 = dy[j]
        cx, cy = getCenter(targetsprite,true)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].opacity += 51
        fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          #fp["#{j}"].visible = false if nextx > cx && nexty < cy
          fp["#{j}"].z = targetsprite.z - 1 if nextx > cx && nexty < cy
        else
          #fp["#{j}"].visible = false if nextx < cx && nexty > cy
          fp["#{j}"].z = targetsprite.z + 1 if nextx < cx && nexty > cy
        end
        applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      end
      if i >= 64
        targetsprite.addOx(shake)
        shake = -4 if targetsprite.ox > targetsprite.bitmap.width/2 + 2
        shake = 4 if targetsprite.ox < targetsprite.bitmap.width/2 - 2
        targetsprite.still
      end
      pbSEPlay("Comet Punch") if i == 64
      fp["cir"].x, fp["cir"].y = getCenter(usersprite)
      fp["cir"].angle += 32
      fp["cir"].opacity += (i>72) ? -51 : 255
      fp["bg"].update
      for m in 0...8
        fp["#{m}s"].visible = true
        fp["#{m}s"].opacity -= 12
        fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
        fp["#{m}s"].x, fp["#{m}s"].y = getCenter(usersprite)
      end
      @vector.set(vector) if i == 32
      @vector.inc = 0.1 if i == 32
      wait(1,true)
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    fp["cir"].opacity = 0
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Tackle
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific303(userindex,targetindex,hitnum=0,multihit=false,withvector=true,shake=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb303_2")
      fp["#{i}"].ox = 10
      fp["#{i}"].oy = 10
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      r = rand(3)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(64))
    end
    @vector.set(getRealVector(targetindex,player)) if withvector
    wait(20,true) if withvector
    factor = targetsprite.zoom_y
    pbSEPlay("eb_normal1",80)
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 50
    frame.bitmap = pbBitmap("Graphics/Animations/eb303")
    frame.src_rect.set(0,0,64,64)
    frame.ox = 32
    frame.oy = 32
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    frame.y -= 32*targetsprite.zoom_y
    # start animation
    for i in 1..30
      if i < 8 && shake
        x=(i/4 < 1) ? 2 : -2
        moveEntireScene(0,x*2,true,true)
      end
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 64 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for j in 0...12
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
	#-----------------------------------------------------------------------------
	# Transform
	#-----------------------------------------------------------------------------
	def pbMoveAnimationSpecific422(userindex,targetindex,hitnum=0,multihit=false,withvector=true,shake=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
		user = @battle.battlers[userindex]
		target = @battle.battlers[targetindex]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb303_2")
      fp["#{i}"].ox = 10
      fp["#{i}"].oy = 10
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      r = rand(3)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(64))
    end
    @vector.set(getRealVector(targetindex,player)) if withvector
    wait(20,true) if withvector
    factor = targetsprite.zoom_y
    pbSEPlay("eb_normal1",80)
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 50
    frame.bitmap = pbBitmap("Graphics/Animations/eb303")
    frame.src_rect.set(0,0,64,64)
    frame.ox = 32
    frame.oy = 32
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    frame.y -= 32*targetsprite.zoom_y
    # start animation
    for i in 1..30
      if i < 8 && shake
        x=(i/4 < 1) ? 2 : -2
        moveEntireScene(0,x*2,true,true)
      end
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 64 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for j in 0...12
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
		pbChangePokemon(user,target.pokemon)
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Substitute
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific412(userindex,targetindex,hitnum=0,multihit=false)
    pbSEPlay("Substitute")
    self.setSubstitute(userindex,true)
    return true
  end
    #-----------------------------------------------------------------------------
  #  Poison Jab
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific430(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    # set up animation
    factor = targetsprite.zoom_x
    cx, cy = getCenter(targetsprite,true)
    fp = {}
    for j in 0...32
      fp["s#{j}"] = Sprite.new(targetsprite.viewport)
      fp["s#{j}"].bitmap = Bitmap.new(8,8)
      fp["s#{j}"].bitmap.drawCircle(Color.new(25,75,183))
      fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
      fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
      fp["s#{j}"].x = cx
      fp["s#{j}"].y = cy
      fp["s#{j}"].z = targetsprite.z
      fp["s#{j}"].angle = rand(360)
      fp["s#{j}"].visible = false
    end
    for j in 0...16
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb430")
      fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
      fp["#{j}"].angle = rand(360)
      fp["#{j}"].ox = - 80*factor
      fp["#{j}"].x = cx
      fp["#{j}"].y = cy
      fp["#{j}"].z = targetsprite.z + 1
      fp["#{j}"].opacity = 0
    end
    # play animation
    for i in 0...48
      for j in 0...16
        next if j>i
        fp["#{j}"].opacity += 32
        fp["#{j}"].ox += (80*factor/8).ceil
        fp["#{j}"].visible = false if fp["#{j}"].ox >= 0
      end
      for j in 0...32
        next if j>i*2
        fp["s#{j}"].visible = true
        fp["s#{j}"].opacity -= 32
        fp["s#{j}"].oy += 16
      end
      targetsprite.zoom_y = factor + 0.32 if i%6 == 0 && i < 32
      targetsprite.zoom_y -= 0.08 if targetsprite.zoom_y > factor
      pbSEPlay("hit",80) if i%6==0 && i < 32
      pbSEPlay("eb_poison1",60) if i%4==0 && i < 32
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Psychic
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific452(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 2 : 1.5
    # set up animation
    fp = {}
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 6
    fp["bg"].setBitmap("Graphics/Animations/eb452",true)
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    fp["bg"].oy = fp["bg"].src_rect.height/2
    fp["bg"].y = targetsprite.viewport.rect.height/2
    shake = 8
    zoom = -1
    # start animation
    @vector.set(vector)
    for i in 0...72
      pbSEPlay("eb_psychic1",80) if i == 40
      pbSEPlay("eb_psychic2",80) if i == 62
      if i < 10
        fp["bg"].opacity += 25.5
      elsif i < 20
        fp["bg"].color.alpha -= 25.5
      elsif i >= 62
        fp["bg"].color.alpha += 25.5
        targetsprite.tone.red += 18
        targetsprite.tone.green += 18
        targetsprite.tone.blue += 18
        targetsprite.zoom_x += 0.04*factor
        targetsprite.zoom_y += 0.04*factor
      elsif i >= 40
        targetsprite.addOx(shake)
        shake = -8 if targetsprite.ox > targetsprite.bitmap.width/2 + 4
        shake = 8 if targetsprite.ox < targetsprite.bitmap.width/2 - 4
        targetsprite.still
      end
      zoom *= -1 if i%2 == 0
      fp["bg"].update
      fp["bg"].zoom_y += 0.04*zoom
      wait(1,(i<62))
    end
    targetsprite.ox = targetsprite.bitmap.width/2
    10.times do
      targetsprite.tone.red -= 18
      targetsprite.tone.green -= 18
      targetsprite.tone.blue -= 18
      targetsprite.zoom_x -= 0.04*factor
      targetsprite.zoom_y -= 0.04*factor
      targetsprite.still
      wait(1)
    end
    wait(8)
    @vector.set(defaultvector) if !multihit
    10.times do
      fp["bg"].opacity -= 25.5
      targetsprite.still
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Psycho Cut
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific458(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(usersprite,player2)
    # extra parameters
    xt,yt = getCenter(targetsprite,true)
    xp,yp = getCenter(usersprite,true)
    distance_x = xt - xp
    distance_y = yp - yt
    @vector.set(vector2)
    wait(16,true)
    # set up animation
    cx, cy = getCenter(usersprite,true)
    factor = usersprite.zoom_x
    fp = {}
    for j in 0...5
      fp["#{j}"] = Sprite.new(targetsprite.viewport)
      fp["#{j}"].bitmap = pbBitmap("Graphics/Animations/eb458_2")
      fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
      fp["#{j}"].oy = fp["#{j}"].bitmap.height + 16
      fp["#{j}"].zoom_x = factor*0.75
      fp["#{j}"].zoom_y = factor*0.75
      fp["#{j}"].opacity = 0
      fp["#{j}"].x = cx
      fp["#{j}"].y = cy
      fp["#{j}"].z = player2 ? 29 : 19
      fp["#{j}"].angle = 60*j + 30
    end
    fp["ring"] = Sprite.new(targetsprite.viewport)
    fp["ring"].bitmap = pbBitmap("Graphics/Animations/eb458")
    fp["ring"].ox = fp["ring"].bitmap.width/2
    fp["ring"].oy = fp["ring"].bitmap.height/2
    fp["ring"].x = cx
    fp["ring"].y = cy
    fp["ring"].zoom_x = 0
    fp["ring"].zoom_y = 0
    fp["ring"].z = player2 ? 29 : 19
    fp["blade"] = Sprite.new(targetsprite.viewport)
    fp["blade"].bitmap = pbBitmap("Graphics/Animations/eb458_3")
    fp["blade"].ox = fp["blade"].bitmap.width/2
    fp["blade"].oy = fp["blade"].bitmap.height/2
    fp["blade"].x = cx
    fp["blade"].y = cy
    fp["blade"].zoom_x = factor
    fp["blade"].zoom_y = factor
    fp["blade"].z = player2 ? 29 : 19
    fp["blade"].opacity = 0
    fp["blade"].color = Color.new(255,255,255,128)
    fp["blade2"] = Sprite.new(targetsprite.viewport)
    fp["blade2"].bitmap = pbBitmap("Graphics/Animations/eb458_3")
    fp["blade2"].ox = fp["blade2"].bitmap.width/2
    fp["blade2"].oy = fp["blade2"].bitmap.height/2
    fp["blade2"].x = cx
    fp["blade2"].y = cy
    fp["blade2"].zoom_x = factor
    fp["blade2"].zoom_y = factor
    fp["blade2"].z = player ? 29 : 19
    fp["blade2"].opacity = 0
    fp["blade2"].color = Color.new(255,255,255,128)
    for i in 0...96
      cx, cy = getCenter(usersprite,true)
      @vector.set(defaultvector) if !multihit && i == 64
      pbSEPlay("eb_normal3",80) if i == 88
      pbSEPlay("eb_normal3",60) if i == 92
      pbSEPlay("eb_ground1",80) if i == 16
      pbSEPlay("fog2",90) if i == 16
      pbSEPlay("eb_psychic3",80) if i == 64
      if i < 16
        fp["ring"].zoom_x += factor/16.0
        fp["ring"].zoom_y += factor/16.0
      elsif i < 64
        for j in 0...5
          fp["#{j}"].zoom_x += 0.05*factor*((i < 24) ? 0.5 : 0.25)
          fp["#{j}"].zoom_y += 0.05*factor*((i < 24) ? 0.5 : 0.25)
          fp["#{j}"].opacity += 32*((i < 24) ? 1 : -1)
        end
        fp["ring"].opacity -= 8
        fp["blade"].opacity += 16
        fp["blade"].angle += 8
        fp["blade"].color.alpha -= 8 if fp["blade"].color.alpha > 0
      else
        fp["blade"].angle += 8
        fp["blade"].opacity -= 16
        fp["blade"].x = cx
        fp["blade"].y = cy
        fp["blade2"].opacity += 32
        fp["blade2"].x = cx + (i-64)*distance_x/24.0
        fp["blade2"].y = cy - (i-64)*distance_y/24.0
        x2, y2 = getCenter(targetsprite,true)
        x0 = fp["blade2"].x
        y0 = fp["blade2"].y
        fp["blade2"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + 180*(player ? 1 : 0) if i < 88
        fp["blade2"].zoom_x -= (usersprite.zoom_x - targetsprite.zoom_x)/32.0
        fp["blade2"].zoom_y -= (usersprite.zoom_y - targetsprite.zoom_y)/32.0
        if !player
          fp["blade2"].z = targetsprite.z - 1 if x0 > x2 && y0 < y2
        else
          fp["blade2"].z = targetsprite.z + 1 if x0 < x2 && y0 > y2
        end
      end
      wait(1,true)
    end
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Rockslide
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific504(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    indexes = player ? [0,2] : [1,3]
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    v = player ? PLAYERVECTOR : ENEMYVECTOR
    vector = @battle.doublebattle ? v : getRealVector(targetindex,player)
    @vector.set(vector)
    wait(16,true)
    # set up animation
    cx, cy = getCenter(targetsprite,true)
    dy = @vector.y2/12
    fp = {}
    da = []
    factors = []
    for m in 0...(@battle.doublebattle ? 2 : 1)
      targetsprite = @sprites["pokemon#{indexes[m]}"]
      if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
        factors.push(1)
        next
      end
      factors.push(targetsprite.zoom_x)
    end
    for m in 0...(@battle.doublebattle ? 2 : 1)
      targetsprite = @sprites["pokemon#{indexes[m]}"]
      next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
      for j in 0...96
        fp["r#{m}#{j}"] = Sprite.new(targetsprite.viewport)
        fp["r#{m}#{j}"].bitmap = pbBitmap("Graphics/Animations/eb504")
        fp["r#{m}#{j}"].ox = fp["r#{m}#{j}"].bitmap.width/2
        fp["r#{m}#{j}"].oy = fp["r#{m}#{j}"].bitmap.height/2
        r = 80*factors[m]
        z = [1,0.5,0.75,0.25][rand(4)]
        fp["r#{m}#{j}"].zoom_x = z
        fp["r#{m}#{j}"].zoom_y = z
        fp["r#{m}#{j}"].x = targetsprite.x - r + rand(r*2)
        fp["r#{m}#{j}"].y = rand(32*factors[m])
        fp["r#{m}#{j}"].visible = false
        fp["r#{m}#{j}"].angle = rand(360)
        fp["r#{m}#{j}"].z = targetsprite.z + 1
        da.push(rand(2)==0 ? 1 : -1)
      end

      width = targetsprite.bitmap.width/2 - 16
      max = 48# + (width/16)
      for j in 0...max
        fp["d#{m}#{j}"] = Sprite.new(targetsprite.viewport)
        fp["d#{m}#{j}"].bitmap = pbBitmap("Graphics/Animations/ebDustParticle")
        fp["d#{m}#{j}"].ox = fp["d#{m}#{j}"].bitmap.width/2
        fp["d#{m}#{j}"].oy = fp["d#{m}#{j}"].bitmap.height/2
        fp["d#{m}#{j}"].opacity = 0
        fp["d#{m}#{j}"].angle = rand(360)
        fp["d#{m}#{j}"].x = targetsprite.x - width*factors[m] + rand(width*2*factors[m])
        fp["d#{m}#{j}"].y = targetsprite.y - 16*factors[m] + rand(32*factors[m])
        fp["d#{m}#{j}"].z = targetsprite.z + (fp["d#{m}#{j}"].y < targetsprite.y ? -1 : 1)
        zoom = [1,0.8,0.9,0.7][rand(4)]
        fp["d#{m}#{j}"].zoom_x = zoom*factors[m]
        fp["d#{m}#{j}"].zoom_y = zoom*factors[m]
      end
    end
    k = [-1,-1]
    # start animation
    for i in 0...64
      pbSEPlay("eb_rock2",70) if i%8==0
      for m in 0...(@battle.doublebattle ? 2 : 1)
        targetsprite = @sprites["pokemon#{indexes[m]}"]
        next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
        for j in 0...96
          next if j>(i*2)
          fp["r#{m}#{j}"].y += dy
          fp["r#{m}#{j}"].visible = fp["r#{m}#{j}"].y < targetsprite.y - 16*factors[m]
          fp["r#{m}#{j}"].angle += 8*da[j]
        end
        for j in 0...max
          next if i < 8
          next if j>(i-8)/2
          fp["d#{m}#{j}"].opacity += 25.5 if i < 18+j*2
          fp["d#{m}#{j}"].opacity -= 25.5 if i >= 22+j*2
          if fp["d#{m}#{j}"].x >= targetsprite.x
            fp["d#{m}#{j}"].angle += 4
            fp["d#{m}#{j}"].x += 2
          else
            fp["d#{m}#{j}"].angle -= 4
            fp["d#{m}#{j}"].x -= 2
          end
        end
        if i >= 8
          k[m] *= -1 if i%4==0
          targetsprite.zoom_y -= 0.04*k[m]*factors[m]
          targetsprite.zoom_x += 0.02*k[m]*factors[m]
          targetsprite.still
        end
      end
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Iron Head
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific520(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    pbSEPlay("eb_iron2",80,80)
    pbSEPlay("eb_ground1",80)
    for i in 0...2
      for k in 0...4
        usersprite.x += 8*(player ? -1 : 1)*(i==0 ? 1 : -1)
        usersprite.x -= 2*(player ? -1 : 1)*(i==0 ? 1 : -1)
        wait(1)
      end
    end
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    for i in 0...16
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb024")
      fp["#{i}"].ox = 6
      fp["#{i}"].oy = 6
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      r = rand(3)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(128))
    end
    factor = 1
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 50
    frame.bitmap = pbBitmap("Graphics/Animations/eb520")
    frame.src_rect.set(0,0,114,114)
    frame.ox = 57
    frame.oy = 57
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    # start animation
    for i in 1..30
      if i == 6
        pbSEPlay("eb_iron3",90)
        pbSEPlay("eb_iron1",80)
      end
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 114 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for j in 0...16
        next if i < 6
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        fp["#{j}"].angle += 2
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Magnet Bomb
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific523(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    @vector.set(getRealVector(targetindex,player))
    wait(16,true)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    dx = []
    dy = []
    cx, cy = getCenter(targetsprite,true)
    for j in 0..16
      fp["i#{j}"] = Sprite.new(targetsprite.viewport)
      fp["i#{j}"].bitmap = pbBitmap("Graphics/Animations/eb523")
      fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
      fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
      r = 72*factor
      x, y = randCircleCord(r)
      fp["i#{j}"].x = cx - r + rand(r*2)
      fp["i#{j}"].y = cy - r*1.5 + rand(r*2)
      fp["i#{j}"].z = targetsprite.z + 1
      fp["i#{j}"].zoom_x = factor
      fp["i#{j}"].zoom_y = factor
      fp["i#{j}"].opacity = 0
      dx.push(rand(2)==0 ? 1 : -1)
      dy.push(rand(2)==0 ? 1 : -1)
    end
    for m in 0...12
      fp["d#{m}"] = Sprite.new(targetsprite.viewport)
      fp["d#{m}"].bitmap = pbBitmap("Graphics/Animations/eb523_2")
      fp["d#{m}"].src_rect.set(0,0,80,78)
      fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
      fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
      r = 32*factor
      fp["d#{m}"].x = cx - r + rand(r*2)
      fp["d#{m}"].y = cy - r + rand(r*2)
      fp["d#{m}"].z = targetsprite.z + 1
      fp["d#{m}"].opacity = 0
      fp["d#{m}"].angle = rand(360)
    end
    for m in 0...12
      fp["s#{m}"] = Sprite.new(targetsprite.viewport)
      fp["s#{m}"].bitmap = pbBitmap("Graphics/Animations/eb523_2")
      fp["s#{m}"].src_rect.set(80,0,80,78)
      fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
      fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
      r = 32*factor
      fp["s#{m}"].x = fp["d#{m}"].x
      fp["s#{m}"].y = fp["d#{m}"].y
      fp["s#{m}"].z = targetsprite.z + 1
      fp["s#{m}"].opacity = 0
      fp["s#{m}"].angle = fp["d#{m}"].angle
    end
    pbSEPlay("eb_iron4",100)
    for i in 0...48
      k = (i-16)/4
      pbSEPlay("eb_psychic4",80-20*k) if i >= 16 && i%4==0 && i < 28
      for j in 0...16
        next if j>(i/2)
        t = fp["i#{j}"].tone.red
        t += 32 if i%4==0
        t = 0 if t > 96
        fp["i#{j}"].tone = Tone.new(t,t,t)
        fp["i#{j}"].opacity += 16
        fp["i#{j}"].angle += dx[j]
      end
      wait(1)
    end
    for i in 0...64
      pbSEPlay("eb_normal1",80) if i >= 2 && i%4==0 && i < 26
      for j in 0...16
        next if j>(i)
        fp["i#{j}"].x += (cx - fp["i#{j}"].x)*0.5
        fp["i#{j}"].y += (cy - fp["i#{j}"].y)*0.5
        fp["i#{j}"].angle += dx[j]
        fp["i#{j}"].visible = (cx - fp["i#{j}"].x)*0.5 >= 1
      end
      for m in 0...12
        next if i < 6
        next if m>(i-6)/2
        fp["d#{m}"].opacity += 32*(fp["d#{m}"].zoom_x < 1.5 ? 1 : -1)
        fp["d#{m}"].zoom_x += 0.05
        fp["d#{m}"].zoom_y += 0.05
        fp["d#{m}"].angle += 4
        fp["s#{m}"].opacity += 32*(fp["s#{m}"].zoom_x < 1.5 ? 1 : -1)
        fp["s#{m}"].zoom_x += 0.05
        fp["s#{m}"].zoom_y += 0.05
        fp["s#{m}"].angle += 4
      end
      targetsprite.still
      wait(1)
    end
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
  #  Hydro Pump
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific536(userindex,targetindex,hitnum=0,multihit=false,type="default")
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    vector2 = getRealVector(userindex,player2)
    factor = player ? 2 : 1
    # set up animation
    fp = {}
    rndx = [[],[]]
    rndy = [[],[]]
    dx = [[],[]]
    dy = [[],[]]
    fp["bg"] = ScrollingSprite.new(targetsprite.viewport)
    fp["bg"].speed = 64
    fp["bg"].setBitmap(type == "dragon" ? "Graphics/Animations/eb716_bg" : "Graphics/Animations/eb536_bg")
    fp["bg"].color = Color.new(0,0,0,255)
    fp["bg"].opacity = 0
    string = type == "dragon" ? ["eb716_2","eb716"] : ["eb536_2","eb536"]
    rop = [255,80,40,135]
    px = []
    py = []
    for i in 0...12
      fp["p#{i}"] = Sprite.new(targetsprite.viewport)
      fp["p#{i}"].bitmap = Bitmap.new(16,16)
      fp["p#{i}"].bitmap.drawCircle
      fp["p#{i}"].ox = 8
      fp["p#{i}"].oy = 8
      fp["p#{i}"].opacity = 0
      fp["p#{i}"].z = targetsprite.z
      px.push(0)
      py.push(0)
    end
    for m in 0...2
      for i in 0...20
        fp["#{i}#{m}"] = Sprite.new(targetsprite.viewport)
        bmp = pbBitmap("Graphics/Animations/"+string[m])
        fp["#{i}#{m}"].bitmap = Bitmap.new(bmp.width,bmp.height)
        fp["#{i}#{m}"].bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height),(m==0 ? rop[rand(4)] : 255))
        fp["#{i}#{m}"].ox = fp["#{i}#{m}"].bitmap.width/2
        fp["#{i}#{m}"].oy = fp["#{i}#{m}"].bitmap.height/2
        fp["#{i}#{m}"].opacity = 0
        fp["#{i}#{m}"].z = player ? 29 : 19
        fp["#{i}#{m}"].zoom_x = [0.5,1][m]
        fp["#{i}#{m}"].zoom_y = [0.5,1][m]
        rndx[m].push(rand(16))
        rndy[m].push(rand(16))
        dx[m].push(0)
        dy[m].push(0)
      end
    end
    k = 1
    # start animation
    for i in 0...20
      if i < 10
        fp["bg"].opacity += 25.5
      else
        fp["bg"].color.alpha -= 25.5
      end
      fp["bg"].update
      wait(1,true)
    end
    pbSEPlay("Water3",80)
    wait(4,true)
    for i in 0...96
      pbSEPlay("Water5") if i == 12
      for m in 0...2
        for j in 0...20
          if fp["#{j}#{m}"].opacity == 0
            cx, cy = getCenter(usersprite)
            dx[m][j] = cx - 8*usersprite.zoom_x*0.5 + rndx[m][j]*usersprite.zoom_x*0.5
            dy[m][j] = cy - 8*usersprite.zoom_y*0.5 + rndy[m][j]*usersprite.zoom_y*0.5
            fp["#{j}#{m}"].x = dx[m][j]
            fp["#{j}#{m}"].y = dy[m][j]
          end
          cx, cy = getCenter(targetsprite,true)
          next if j>(i/4)
          x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[m][j]*targetsprite.zoom_x*0.5
          y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[m][j]*targetsprite.zoom_y*0.5
          x0 = dx[m][j]
          y0 = dy[m][j]
          fp["#{j}#{m}"].x += (x2 - x0)*0.04*(m+1)
          fp["#{j}#{m}"].y += (y2 - y0)*0.04*(m+1)
          fp["#{j}#{m}"].zoom_x += (1 - fp["#{j}#{m}"].zoom_x)*0.1
          fp["#{j}#{m}"].zoom_y += (1 - fp["#{j}#{m}"].zoom_y)*0.1
          fp["#{j}#{m}"].opacity += 51
          fp["#{j}#{m}"].angle += 8*(m+1)*j
          nextx = fp["#{j}#{m}"].x# + (x2 - x0)*0.1
          nexty = fp["#{j}#{m}"].y# + (y2 - y0)*0.1
          if !player
            fp["#{j}#{m}"].visible = false if nextx > cx && nexty < cy
          else
            fp["#{j}#{m}"].visible = false if nextx < cx && nexty > cy
          end
        end
      end
      for l in 0...12
        next if i < 12
        next if l>((i-12)/4)
        cx, cy = getCenter(targetsprite,true)
        if fp["p#{l}"].opacity <= 0
          fp["p#{l}"].opacity = 255 - rand(101)
          fp["p#{l}"].x = cx
          fp["p#{l}"].y = cy
          r = rand(2)
          fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
          fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
          x, y = randCircleCord(128)
          px[l] = cx - 128*targetsprite.zoom_x + x*targetsprite.zoom_x
          py[l] = cy - 128*targetsprite.zoom_y + y*targetsprite.zoom_y
        end
        x2 = px[l]
        y2 = py[l]
        x0 = fp["p#{l}"].x
        y0 = fp["p#{l}"].y
        fp["p#{l}"].x += (x2 - x0)*0.05
        fp["p#{l}"].y += (y2 - y0)*0.05
        fp["p#{l}"].opacity -= 8
      end
      targetsprite.still if i >= 64
      @vector.set(vector) if i == 64
      @vector.inc = 0.1 if i == 64
      fp["bg"].update
      if i < 64
        k*=-1 if i%4==0
        moveEntireScene(0,k*4,true,true)
      end
      pbSEPlay("Water1") if i == 84
      if i.between?(85,90)
        targetsprite.zoom_x += 0.01
        targetsprite.zoom_y -= 0.04
      elsif i.between?(91,96)
        targetsprite.zoom_x -= 0.01
        targetsprite.zoom_y += 0.04
      end
      wait(1,(i>=64 && i<85))
    end
    for j in 0...20; for m in 0...2; fp["#{j}#{m}"].visible = false; end; end
    for l in 0...12; fp["p#{l}"].visible = false; end
    for i in 0...20
      targetsprite.still
      if i < 10
        fp["bg"].color.alpha += 25.5
      else
        fp["bg"].opacity -= 25.5
      end
      fp["bg"].update
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Crabhammer
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific540(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    # set up animation
    fp = {}
    fp["bg"] = Sprite.new(targetsprite.viewport)
    fp["bg"].bitmap = Bitmap.new(targetsprite.viewport.rect.width,targetsprite.viewport.rect.height)
    fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(57,106,173))
    fp["bg"].opacity = 0
    @vector.set(vector)
    16.times do
      fp["bg"].opacity += 8
      wait(1,true)
    end
    fp["hammer1"] = Sprite.new(targetsprite.viewport)
    fp["hammer1"].bitmap = pbBitmap("Graphics/Animations/eb540_2")
    fp["hammer1"].ox = fp["hammer1"].bitmap.width/2
    fp["hammer1"].oy = fp["hammer1"].bitmap.height
    fp["hammer1"].z = targetsprite.z + 1
    fp["hammer1"].x = targetsprite.x
    fp["hammer2"] = Sprite.new(targetsprite.viewport)
    fp["hammer2"].bitmap = pbBitmap("Graphics/Animations/eb540_3")
    fp["hammer2"].ox = fp["hammer2"].bitmap.width/2
    fp["hammer2"].oy = fp["hammer2"].bitmap.height - 24
    fp["hammer2"].z = targetsprite.z + 1
    fp["hammer2"].x = targetsprite.x
    fp["frame"] = Sprite.new(targetsprite.viewport)
    fp["frame"].z = targetsprite.z + 2
    fp["frame"].bitmap = pbBitmap("Graphics/Animations/eb540")
    fp["frame"].src_rect.set(0,0,64,64)
    fp["frame"].ox = 32
    fp["frame"].oy = 32
    fp["frame"].zoom_x = 0.5*targetsprite.zoom_x
    fp["frame"].zoom_y = 0.5*targetsprite.zoom_y
    fp["frame"].x, fp["frame"].y = getCenter(targetsprite,true)
    fp["frame"].opacity = 0
    fp["frame"].tone = Tone.new(255,255,255)
    px = []
    py = []
    for i in 0...24
      fp["p#{i}"] = Sprite.new(targetsprite.viewport)
      fp["p#{i}"].bitmap = Bitmap.new(16,16)
      fp["p#{i}"].bitmap.drawCircle
      fp["p#{i}"].ox = 8
      fp["p#{i}"].oy = 8
      fp["p#{i}"].opacity = 0
      fp["p#{i}"].z = targetsprite.z
      px.push(0)
      py.push(0)
    end
    pbSEPlay("Water1",80)
    for i in 0...64
      fp["hammer1"].y += targetsprite.y/8.0
      fp["hammer1"].visible = fp["hammer1"].y < targetsprite.y
      if i >= 2
        fp["hammer2"].y += targetsprite.y/8.0
        fp["hammer2"].visible = fp["hammer2"].y < targetsprite.y
      end
      pbSEPlay("eb_normal1",80) if i == 11
      if i.between?(11,15)
        targetsprite.still
        targetsprite.zoom_y-=0.05*targetsprite.zoom_y
        targetsprite.toneAll(-12.8)
        fp["frame"].zoom_x += 0.1*targetsprite.zoom_x
        fp["frame"].zoom_y += 0.1*targetsprite.zoom_y
        fp["frame"].opacity += 51
      end
      fp["frame"].tone = Tone.new(0,0,0) if i == 16
      if i.between?(16,20)
        targetsprite.still
        targetsprite.zoom_y+=0.05*targetsprite.zoom_y
        targetsprite.toneAll(+12.8)
        fp["frame"].angle += 2
      end
      fp["p#{i}"].src_rect.x = 64 if i == 10
      if i >= 20
        fp["frame"].opacity -= 25.5
        fp["frame"].zoom_x += 0.1*targetsprite.zoom_x
        fp["frame"].zoom_y += 0.1*targetsprite.zoom_y
        fp["frame"].angle += 2
      end
      for l in 0...24
        next if i < 10
        next if l>((i-10)*8)
        cx, cy = getCenter(targetsprite,true)
        if fp["p#{l}"].opacity <= 0 && fp["p#{l}"].tone.blue <= 0
          fp["p#{l}"].opacity = 255 - rand(101)
          fp["p#{l}"].x = cx
          fp["p#{l}"].y = cy
          r = rand(2)
          fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
          fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
          x = rand(128); y = rand(128)
          px[l] = cx - 64*targetsprite.zoom_x + x*targetsprite.zoom_x
          py[l] = cy - 64*targetsprite.zoom_y + y*targetsprite.zoom_y
        end
        x2 = px[l]
        y2 = py[l]
        x0 = fp["p#{l}"].x
        y0 = fp["p#{l}"].y
        fp["p#{l}"].x += (x2 - x0)*0.1
        fp["p#{l}"].y += (y2 - y0)*0.1
        fp["p#{l}"].opacity -= 8
        fp["p#{l}"].tone.blue = 1 if fp["p#{l}"].opacity <= 0
      end
      fp["bg"].opacity -= 8 if i >= 48
      wait(1)
    end
    @vector.set(defaultvector) if !multihit
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  Water Gun
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific551(userindex,targetindex,hitnum=0,multihit=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    player2 = (userindex%2==0)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    vector = getRealVector(targetindex,player)
    factor = player ? 1.2 : 0.8
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    dx = []
    dy = []
    px = []
    py = []
    rangl = []
    for i in 0...12
      fp["p#{i}"] = Sprite.new(targetsprite.viewport)
      fp["p#{i}"].bitmap = Bitmap.new(16,16)
      fp["p#{i}"].bitmap.drawCircle
      fp["p#{i}"].ox = 8
      fp["p#{i}"].oy = 8
      fp["p#{i}"].opacity = 0
      fp["p#{i}"].z = targetsprite.z
      px.push(0)
      py.push(0)
    end
    for k in 0...64
      i = 63-k
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      bmp = pbBitmap("Graphics/Animations/eb551")
      fp["#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      fp["#{i}"].bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
      fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
      fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = player ? 29 : 19
      fp["#{i}"].color = Color.new(248,248,248,200)
      rndx.push(rand(16))
      rndy.push(rand(16))
      rangl.push(rand(2))
      dx.push(0)
      dy.push(0)
    end
    for i in 0...64
      pbSEPlay("eb_water1",60) if i%4==0 && i < 48
      for j in 0...64
        if fp["#{j}"].opacity == 0
          cx, cy = getCenter(usersprite)
          dx[j] = cx - 8*usersprite.zoom_x*0.5 + rndx[j]*usersprite.zoom_x*0.5
          dy[j] = cy - 8*usersprite.zoom_y*0.5 + rndy[j]*usersprite.zoom_y*0.5
          fp["#{j}"].x = dx[j]
          fp["#{j}"].y = dy[j]
          fp["#{j}"].zoom_x = 0.8#(!player ? 1.2 : 0.8)#usersprite.zoom_x
          fp["#{j}"].zoom_y = 0.8#(!player ? 1.2 : 0.8)#usersprite.zoom_y
          fp["#{j}"].opacity = 128 if !(j>i*2)
        end
        cx, cy = getCenter(targetsprite,true)
        next if j>(i*2)
        x2 = cx - 8*targetsprite.zoom_x*0.5 + rndx[j]*targetsprite.zoom_x*0.5
        y2 = cy - 8*targetsprite.zoom_y*0.5 + rndy[j]*targetsprite.zoom_y*0.5
        x0 = dx[j]
        y0 = dy[j]
        fp["#{j}"].x += (x2 - x0)*0.1
        fp["#{j}"].y += (y2 - y0)*0.1
        fp["#{j}"].zoom_x += 0.04#(factor - fp["#{j}"].zoom_x)*0.2
        fp["#{j}"].zoom_y += 0.04#(factor - fp["#{j}"].zoom_y)*0.2
        fp["#{j}"].opacity += 32
        fp["#{j}"].angle += 8*(rangl[j]==0 ? -1 : 1)
        fp["#{j}"].color.alpha -= 5 if fp["#{j}"].color.alpha > 0
        nextx = fp["#{j}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}"].y# + (y2 - y0)*0.1
        if !player
          fp["#{j}"].visible = false if nextx > cx && nexty < cy
        else
          fp["#{j}"].visible = false if nextx < cx && nexty > cy
        end
      end
      for l in 0...12
        next if i < 2
        next if l>((i-6)/4)
        cx, cy = getCenter(targetsprite,true)
        if fp["p#{l}"].opacity <= 0 && i < 48
          fp["p#{l}"].opacity = 255 - rand(101)
          fp["p#{l}"].x = cx
          fp["p#{l}"].y = cy
          r = rand(2)
          fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
          fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
          x, y = randCircleCord(96)
          px[l] = cx - 48*targetsprite.zoom_x + x*targetsprite.zoom_x
          py[l] = cy - 48*targetsprite.zoom_y + y*targetsprite.zoom_y
        end
        x2 = px[l]
        y2 = py[l]
        x0 = fp["p#{l}"].x
        y0 = fp["p#{l}"].y
        fp["p#{l}"].x += (x2 - x0)*0.05
        fp["p#{l}"].y += (y2 - y0)*0.05
        fp["p#{l}"].opacity -= 8
      end
      targetsprite.still if i >= 64
      @vector.set(DUALVECTOR) if i == 0
      @vector.inc = 0.1 if i == 64
      wait(1,true)
    end
    for j in 0...48; fp["#{j}"].visible = false; end
    for l in 0...12; fp["p#{l}"].visible = false; end
    @vector.set(defaultvector) if !multihit
    @vector.inc = 0.2
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  DefaultStatusMove
  #-----------------------------------------------------------------------------
  def pbMoveAnimationSpecific000(userindex,targetindex,hitnum=0,multihit=false,withvector=true,shake=false)
    # inital configuration
    usersprite = @sprites["pokemon#{userindex}"]
    targetsprite = @sprites["pokemon#{targetindex}"]
    player = (targetindex%2==0)
    itself = (userindex==targetindex)
    defaultvector = @battle.doublebattle ? VECTOR2 : ($game_switches[DRAGALISK_BATTLE_SWITCH]==true ? VECTORDRAGALISK : VECTOR1)
    factor = targetsprite.zoom_x
    # set up animation
    fp = {}
    rndx = []
    rndy = []
    for i in 0...12
      fp["#{i}"] = Sprite.new(targetsprite.viewport)
      fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/eb_status_2")
      fp["#{i}"].ox = 10
      fp["#{i}"].oy = 10
      fp["#{i}"].opacity = 0
      fp["#{i}"].z = 50
      r = rand(3)
      fp["#{i}"].zoom_x = (targetsprite.zoom_x)*(r==0 ? 1 : 0.5)
      fp["#{i}"].zoom_y = (targetsprite.zoom_y)*(r==0 ? 1 : 0.5)
      fp["#{i}"].tone = Tone.new(60,60,60)
      rndx.push(rand(128))
      rndy.push(rand(64))
    end
    @vector.set(getRealVector(targetindex,player)) if withvector
    wait(20,true) if withvector
    factor = targetsprite.zoom_y
    pbSEPlay("Substitute",100)
    frame = Sprite.new(targetsprite.viewport)
    frame.z = 50
    frame.bitmap = pbBitmap("Graphics/Animations/eb_status")
    frame.src_rect.set(0,0,64,64)
    frame.ox = 32
    frame.oy = 32
    frame.zoom_x = 0.5*factor
    frame.zoom_y = 0.5*factor
    frame.x, frame.y = getCenter(targetsprite,true)
    frame.opacity = 0
    frame.tone = Tone.new(255,255,255)
    frame.y -= 32*targetsprite.zoom_y
    # start animation
    for i in 1..30
      if i < 8 && shake
        x=(i/4 < 1) ? 2 : -2
        moveEntireScene(0,x*2,true,true)
      end
      if i.between?(1,5)
        targetsprite.still
        targetsprite.zoom_y-=0.05*factor
        targetsprite.toneAll(-12.8)
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.opacity += 51
      end
      frame.tone = Tone.new(0,0,0) if i == 6
      if i.between?(6,10)
        targetsprite.still
        targetsprite.zoom_y+=0.05*factor
        targetsprite.toneAll(+12.8)
        frame.angle += 2
      end
      frame.src_rect.x = 64 if i == 10
      if i >= 10
        frame.opacity -= 25.5
        frame.zoom_x += 0.1*factor
        frame.zoom_y += 0.1*factor
        frame.angle += 2
      end
      for j in 0...12
        cx = frame.x; cy = frame.y
        if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
          fp["#{j}"].x = cx
          fp["#{j}"].y = cy
        end
        x2 = cx - 64*targetsprite.zoom_x + rndx[j]*targetsprite.zoom_x
        y2 = cy - 64*targetsprite.zoom_y + rndy[j]*targetsprite.zoom_y
        x0 = fp["#{j}"].x
        y0 = fp["#{j}"].y
        fp["#{j}"].x += (x2 - x0)*0.2
        fp["#{j}"].y += (y2 - y0)*0.2
        fp["#{j}"].zoom_x += 0.01
        fp["#{j}"].zoom_y += 0.01
        if i < 20
          fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
        end
        if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
          fp["#{j}"].opacity -= 51
        else
          fp["#{j}"].opacity += 51
        end
        fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
      end
      wait(1)
    end
    frame.dispose
    pbDisposeSpriteHash(fp)
    @vector.set(defaultvector) if !multihit
    return true
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Global move animation selector
#===============================================================================
# types = [normal, fighting, flying, poison, ground, rock, bug, ghost, steel, sound, fire, water, grass, electric, psychic, ice, dragon, dark, fairy]
# Move IDs for global animations
EBMOVE_PHYS = [303,86,164,430,223,504,8,176,520,998,129,540,208,64,458,244,57,27,996]
EBMOVE_SPEC = [263,93,159,430,224,504,10,183,523,999,136,551,191,69,452,243,59,27,997]
EBMOVE_STAT = 0
EBMOVE_AOPP = ["normal","fighting","flying","poison","ground",504,"bug","ghost","steel","???",132,"water","grass","electric","psychic",250,"dragon","dark",997]
EBMOVE_ANON = ["normal","fighting","flying","poison",223,"rock","bug","ghost","steel","???","fire","water","grass","electric","psychic","ice","dragon","dark",997]
EBMOVE_MHIT = ["normal","fighting",164,430,"ground","rock",8,176,520,998,140,540,208,72,"psychic",248,"dragon","dark","fairy"]
class PokeBattle_Scene
  def playGlobalMoveAnimation(type,userindex,targetindex,multitarget,multihit=false,category=0,hitnum=0)
    anm = "pbMoveAnimationSpecific"+sprintf("%03d",id)
    id = nil
    id = EBMOVE_STAT if id.nil? && category == 2
    id = EBMOVE_AOPP[type] if id.nil? && multitarget == PBTargets::AllOpposing
    id = EBMOVE_ANON[type] if id.nil? && multitarget == PBTargets::AllNonUsers
    id = EBMOVE_MHIT[type] if id.nil? && multihit
    id = EBMOVE_PHYS[type] if id.nil? && category == 0
    id = EBMOVE_SPEC[type] if id.nil? && category == 1
    return false if id.is_a?(String)
    return false if hitnum > 0
    if !id.nil?
      anm = "pbMoveAnimationSpecific"+sprintf("%03d",id)
      if eval("defined?(#{anm})")
        return eval("#{anm}(#{userindex},#{targetindex},0,#{multihit})")
      end
    end
    return false
  end
end
