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
#  In order to use the new Sun/Moon styled trainer battles you need the following
#  in your Graphics/Transitions/ folder:
#      - smTrainer#{trainer_id}
#  Having just the trainersprite will play the animation with the default background
#  found in the Graphics/Transitions/ folder. You can use unique backgrounds for
#  your trainertypes by having the following in your folder:
#      - smBg#{trainer_id}
#      - smBgNext#{trainer_id}
#      - smBgLast#{trainer_id}
#  If you have the smSpecial#{trainer_id} image file in your Graphics/Transitions
#  folder, the game will play a special variant of the SM VS animation.
#  New graphics for default VS backgrounds of any trainertypes registered in the
#  EVIL_TEAM_LIST array are in Graphics/Transitions/ folder:
#      - smBgEvil
#      - smBgNextEvil
#      - smBgLastEvil
#  This style is only compatible with the Next Gen UI
#===============================================================================                           
# List of Pokemon that are going to trigger the "Minor Legendary" battle entry
# animation
MINOR_LEGENDARIES = [
  :MOLTRES,
  :ARTICUNO,
  :ZAPDOS,
  :GIRATINA,
]

# Array handling the automatic queuing of battle BGM
BATTLE_BGM_SPECIES = [
  [:GIRATINA,"giratinabattle.ogg"],
  [[:MOLTRES,:ZAPDOS,:ARTICUNO],"dpplegendary.ogg"],
  [[:REGISTEEL,:REGIROCK,:REGICE,:REGIGIGAS],"regibattle.ogg"],
]

# List of trainertypes triggering the "evil" team animation
EVIL_TEAM_LIST = [
  :TEAMROCKET_M,
  :TEAMROCKET_F,
  :TEAMDIMENSIONF,
  :SCIENZIATODIMENSION,
  :SCIENZIATADIMENSION,
  :SERGENTI_TEAMDIMENSION2,
  :TEAMDIMENSION,
  :TEAMDIMENSION_COPPIA,
  :SERGENTI_TEAMDIMENSION,
  :GENERALEVICTOR,
  :TAMARAFINAL,
  :SERGENTES,
  :HELENA,
  :SERGENTEDONNA,
  :ALTERTREY,
  :SERGENTESIGMA,
  :VERSIL,
  #:TAMARAFURIA
]

# Lista delle specie X che attivano la transizione
X_SPECIES = [
  :ELEKIDX,
  :GALVANTULAX,
  :GENGARX,
  :SHARPEDOX,
  :SHULONG,
  :TRISHOUT,
  :SHYLEON,
  :SLURPUFFX,
  :GIGASLURPUFFX,
  :MEWTWOX,
  :ROSERADEX,
  :RAPIDASHX,
	:RAPIDASHXBOSS,
	:RAPIDASHXBOSS2,
  :DRAGALISK,
  :VERSILDRAGALISK,
  :LUXFLON,
	:VAKUM,
  :AEGISLASHX
]

#-------------------------------------------------------------------------------
alias pbBattleAnimation_ebs pbBattleAnimation unless defined?(pbBattleAnimation_ebs)
def pbBattleAnimation(bgm=nil,trainerid=-1,trainername="",skip=false)
  handled=false
  playingBGS=nil
  playingBGM=nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS=$game_system.getPlayingBGS
    playingBGM=$game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  $smAnim = false
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
    pbBGMPlay(bgm,80)
  else
    pbBGMPlay(pbGetWildBattleBGM(0),80)
  end
  viewport=Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
  viewport.z=99999
# Fade to gray a few times.
  viewport.color=Color.new(17*8,17*8,17*8)
  3.times do
    viewport.color.alpha=0
    6.times do
      viewport.color.alpha+=30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    6.times do
      viewport.color.alpha-=30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  
  if trainerid>=0 && !handled
    tgraphic = sprintf("Graphics/Transitions/smTrainer%d",trainerid)
    tgraphic2 = sprintf("Graphics/Transitions/smSpecial%d",trainerid)
    e_team = false
    for val in EVIL_TEAM_LIST
      if val.is_a?(Numeric)
        id = val
      elsif val.is_a?(Symbol)
        id = getConst(PBTrainers,val)
      end
      e_team = true if !id.nil? && trainerid == id
    end
    handled = vsEvilTeam(viewport) if e_team
    if (pbResolveBitmap(tgraphic) || pbResolveBitmap(tgraphic2)) && defined?(EBUISTYLE)
      viewport.color = Color.new(0,0,0,0)
      8.times do
        next if handled
        viewport.color.alpha += 32
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
      handled = true
      $smAnim = true
    end
    tbargraphic=sprintf("Graphics/Transitions/vsBarSpecial%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic=sprintf("Graphics/Transitions/vsBarSpecial%d",trainerid) if !pbResolveBitmap(tbargraphic)
    tgraphic=sprintf("Graphics/Transitions/vsTrainerSpecial%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tgraphic=sprintf("Graphics/Transitions/vsTrainerSpecial%d",trainerid) if !pbResolveBitmap(tgraphic)
    if pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceSpecial(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic=sprintf("Graphics/Transitions/vsBarElite%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic=sprintf("Graphics/Transitions/vsBarElite%d",trainerid) if !pbResolveBitmap(tbargraphic)
    tgraphic=sprintf("Graphics/Transitions/vsTrainer%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tgraphic=sprintf("Graphics/Transitions/vsTrainer%d",trainerid) if !pbResolveBitmap(tgraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceElite(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic=sprintf("Graphics/Transitions/vsBarNew%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic=sprintf("Graphics/Transitions/vsBarNew%d",trainerid) if !pbResolveBitmap(tbargraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceNew(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
    tbargraphic=sprintf("Graphics/Transitions/vsBar%s",getConstantName(PBTrainers,trainerid)) rescue nil
    tbargraphic=sprintf("Graphics/Transitions/vsBar%d",trainerid) if !pbResolveBitmap(tbargraphic)
    if pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic) && !handled
      handled = vsSequenceEssentials(viewport,trainername,trainerid,tbargraphic,tgraphic)
    end
  end
  if !handled && trainerid > -1
    case rand(3)
    when 0
      ebTrainerAnimation1(viewport)
    when 1
      ebTrainerAnimation2(viewport)
    when 2
      ebTrainerAnimation3(viewport)
    end
    handled=true
  end
  if !handled && !skip
    minor = false
    if !$wildSpecies.nil?
      for species in MINOR_LEGENDARIES
        num = species if species.is_a?(Numeric)
        num = getConst(PBSpecies,species) if species.is_a?(Symbol)
        minor = true if $wildSpecies == num
      end
    end
    if !$wildSpecies.nil? && queuedIsRegi?
      ebWildAnimationRegi(viewport)
    elsif !$wildSpecies.nil? && isBoss?
      if !(NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false))
        echoln "STARTING OLD TRANSITION"
        vsXSpecies(viewport,$wildSpecies)
      end
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
    handled=true
  end
  pbPushFade
  yield if block_given?
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM=nil
  $PokemonGlobal.nextBattleME=nil
  $PokemonGlobal.nextBattleBack=nil
  $PokemonEncounters.clearStepCount
  for j in 0..17
    viewport.color=Color.new(0,0,0,(17-j)*15)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
  $smAnim = false
end

$xSpecies = false

alias pbWildBattle_ebs pbWildBattle unless defined?(pbWildBattle_ebs)
def pbWildBattle(*args)
  $poison_pause = true if inMud?
  Kernel.pbMessage("Dio ladro") if $xSpecies
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

def vsEvilTeam(viewport)
  fp = {}
  viewport.color = Color.new(0,0,0,0)
  8.times do
    viewport.color.alpha += 32
    pbWait(1)
  end
  
  fp["bg"] = Sprite.new(viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/Transitions/evilTeamBg")
  fp["bg"].color = Color.new(0,0,0)
  
  fp["bg2"] = Sprite.new(viewport)
  fp["bg2"].bitmap = pbBitmap("Graphics/Transitions/evilTeamEff5")
  fp["bg2"].ox = fp["bg2"].bitmap.width/2
  fp["bg2"].oy = fp["bg2"].bitmap.height/2
  fp["bg2"].x = viewport.rect.width/2
  fp["bg2"].y = viewport.rect.height/2
  fp["bg2"].visible = false
  
  speed = []
  for j in 0...16
    fp["e1_#{j}"] = Sprite.new(viewport)
    bmp = pbBitmap("Graphics/Transitions/evilTeamEff1")
    fp["e1_#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
    w = bmp.width/(1 + rand(3))
    fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
    fp["e1_#{j}"].oy = fp["e1_#{j}"].bitmap.height/2
    fp["e1_#{j}"].angle = rand(360)
    fp["e1_#{j}"].opacity = 0
    fp["e1_#{j}"].x = viewport.rect.width/2
    fp["e1_#{j}"].y = viewport.rect.height/2
    speed.push(4 + rand(5))
  end
  
  fp["logo"] = Sprite.new(viewport)
  fp["logo"].bitmap = pbBitmap("Graphics/Transitions/evilTeamLogo")
  fp["logo"].ox = fp["logo"].bitmap.width/2
  fp["logo"].oy = fp["logo"].bitmap.height/2
  fp["logo"].x = viewport.rect.width/2
  fp["logo"].y = viewport.rect.height/2
  fp["logo"].memorize_bitmap
  fp["logo"].bitmap = pbBitmap("Graphics/Transitions/evilTeamLogo2")
  fp["logo"].zoom_x = 2
  fp["logo"].zoom_y = 2
  fp["logo"].z = 50
  
  fp["ring"] = Sprite.new(viewport)
  fp["ring"].bitmap = pbBitmap("Graphics/Transitions/evilTeamEff2")
  fp["ring"].ox = fp["ring"].bitmap.width/2
  fp["ring"].oy = fp["ring"].bitmap.height/2
  fp["ring"].x = viewport.rect.width/2
  fp["ring"].y = viewport.rect.height/2
  fp["ring"].zoom_x = 0
  fp["ring"].zoom_y = 0 
  fp["ring"].z = 100
  
  pbSEPlay("transition1",80)
  
  for j in 0...32
    fp["e2_#{j}"] = Sprite.new(viewport)
    bmp = pbBitmap("Graphics/Transitions/evilTeamEff4")
    fp["e2_#{j}"].bitmap = pbBitmap("Graphics/Transitions/evilTeamEff4")
    fp["e2_#{j}"].oy = fp["e2_#{j}"].bitmap.height/2
    fp["e2_#{j}"].angle = rand(360)
    fp["e2_#{j}"].opacity = 0
    fp["e2_#{j}"].x = viewport.rect.width/2
    fp["e2_#{j}"].y = viewport.rect.height/2
    fp["e2_#{j}"].z = 100
  end
  
  fp["ring2"] = Sprite.new(viewport)
  fp["ring2"].bitmap = pbBitmap("Graphics/Transitions/evilTeamEff3")
  fp["ring2"].ox = fp["ring2"].bitmap.width/2
  fp["ring2"].oy = fp["ring2"].bitmap.height/2
  fp["ring2"].x = viewport.rect.width/2
  fp["ring2"].y = viewport.rect.height/2
  fp["ring2"].visible = false
  fp["ring2"].zoom_x = 0
  fp["ring2"].zoom_y = 0 
  fp["ring2"].z = 100
    
  for i in 0...32
    viewport.color.alpha -= 8 if viewport.color.alpha > 0
    fp["logo"].zoom_x -= 1/32.0
    fp["logo"].zoom_y -= 1/32.0
    for j in 0...16
      next if j > i/4
      if fp["e1_#{j}"].ox < -(viewport.rect.width/2)
        speed[j] = 4 + rand(5)
        fp["e1_#{j}"].opacity = 0
        fp["e1_#{j}"].ox = 0
        fp["e1_#{j}"].angle = rand(360)
        bmp = pbBitmap("Graphics/Transitions/evilTeamEff1")
        fp["e1_#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      fp["e1_#{j}"].opacity += speed[j]
      fp["e1_#{j}"].ox -=  speed[j]
    end
    pbWait(1)
  end
  fp["logo"].color = Color.new(255,255,255)
  fp["logo"].restore_bitmap
  fp["ring2"].visible = true
  fp["bg2"].visible = true
  viewport.color = Color.new(255,255,255)
  for i in 0...144
    if i >= 128
      viewport.color.alpha += 16
    else
      viewport.color.alpha -= 16 if viewport.color.alpha > 0
    end
    fp["logo"].color.alpha -= 16 if fp["logo"].color.alpha > 0
    fp["bg"].color.alpha -= 8 if fp["bg"].color.alpha > 0
    for j in 0...16
      if fp["e1_#{j}"].ox < -(viewport.rect.width/2)
        speed[j] = 4 + rand(5)
        fp["e1_#{j}"].opacity = 0
        fp["e1_#{j}"].ox = 0
        fp["e1_#{j}"].angle = rand(360)
        bmp = pbBitmap("Graphics/Transitions/evilTeamEff1")
        fp["e1_#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      fp["e1_#{j}"].opacity += speed[j]
      fp["e1_#{j}"].ox -=  speed[j]
    end
    for j in 0...32
      next if j > i*2
      fp["e2_#{j}"].ox -= 16
      fp["e2_#{j}"].opacity += 16
    end
    fp["ring"].zoom_x += 0.1
    fp["ring"].zoom_y += 0.1
    fp["ring"].opacity -= 8
    fp["ring2"].zoom_x += 0.2 if fp["ring2"].zoom_x < 3
    fp["ring2"].zoom_y += 0.2 if fp["ring2"].zoom_y < 3
    fp["ring2"].opacity -= 16
    fp["bg2"].angle += 2 if $PokemonSystem.screensize < 2  
    pbWait(1)
  end
  pbDisposeSpriteHash(fp)
  8.times do
    viewport.color.red -= 255/8.0
    viewport.color.green -= 255/8.0
    viewport.color.blue -= 255/8.0
    pbWait(1)
  end  
end

def vsXSpecies(viewport,species=nil)
  fp = {}
  num = []
  
  for poke in X_SPECIES
    num.push(getConst(PBSpecies,poke))
  end
  
  directory = ["Graphics/Transitions/X/Elekid X/",
               "Graphics/Transitions/X/Galvantula X/",
               "Graphics/Transitions/X/Gengar X/",
               "Graphics/Transitions/X/Sharpedo X/",
               "Graphics/Transitions/X/Shulong X/",
               "Graphics/Transitions/X/Trishout X/",
               "Graphics/Transitions/X/Shyleon X/",
               "Graphics/Transitions/X/Slurpuff X/",
               "Graphics/Transitions/X/Slurpuff X/",
               "Graphics/Transitions/X/Mewtwo X/",
							 "Graphics/Transitions/X/Roserade X/",
							 "Graphics/Transitions/X/Rapidash X Normal/",
							 "Graphics/Transitions/X/Rapidash X Normal/",
							 "Graphics/Transitions/X/Rapidash X Berserk/",
               "Graphics/Transitions/X/Dragalisk/",
               "Graphics/Transitions/X/VersilDragalisk/",
							 "Graphics/Transitions/X/Luxflon/",
							 "Graphics/Transitions/X/Vakum/",
               "Graphics/Transitions/X/Aegislash X/"]
  viewport.color = Color.new(0,0,0,0)
  8.times do
    viewport.color.alpha += 32
    pbWait(1)
  end
  fp["bg"] = Sprite.new(viewport)
  fp["bg"].bitmap = pbBitmap(directory[0]+"evilTeamBg") if $DEBUG
  for bg in 0...X_SPECIES.length
    if num[bg] == species
      fp["bg"].bitmap = pbBitmap(directory[bg] + "evilTeamBg")
    end
  end
  fp["bg"].color = Color.new(0,0,0)
  
  fp["bg2"] = Sprite.new(viewport)
  fp["bg2"].bitmap = pbBitmap(directory[0] + "evilTeamEff5") if $DEBUG
  for eff5 in 0...X_SPECIES.length
    if num[eff5] == species 
      fp["bg2"].bitmap = pbBitmap(directory[eff5] + "evilTeamEff5")
    end
  end
  fp["bg2"].ox = fp["bg2"].bitmap.width/2
  fp["bg2"].oy = fp["bg2"].bitmap.height/2
  fp["bg2"].x = viewport.rect.width/2
  fp["bg2"].y = viewport.rect.height/2
  fp["bg2"].visible = false
  
  speed = []
  for j in 0...16
    fp["e1_#{j}"] = Sprite.new(viewport)
    bmp = pbBitmap(directory[0] + "evilTeamEff1") if $DEBUG
    for eff1 in 0...X_SPECIES.length
      if num[eff1] == species 
        bmp = pbBitmap(directory[eff1] + "evilTeamEff1")
      end
    end
    fp["e1_#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
    w = bmp.width/(1 + rand(3))
    fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
    fp["e1_#{j}"].oy = fp["e1_#{j}"].bitmap.height/2
    fp["e1_#{j}"].angle = rand(360)
    fp["e1_#{j}"].opacity = 0
    fp["e1_#{j}"].x = viewport.rect.width/2
    fp["e1_#{j}"].y = viewport.rect.height/2
    speed.push(4 + rand(5))
  end
  
  fp["logo"] = Sprite.new(viewport)
  fp["logo"].bitmap = pbBitmap(directory[0] + "evilTeamLogo") if $DEBUG
  for logo in 0...X_SPECIES.length
    if num[logo] == species 
      fp["logo"].bitmap = pbBitmap(directory[logo] + "evilTeamLogo")
    end
  end  
  fp["logo"].ox = fp["logo"].bitmap.width/2
  fp["logo"].oy = fp["logo"].bitmap.height/2
  fp["logo"].x = viewport.rect.width/2
  fp["logo"].y = viewport.rect.height/2
  fp["logo"].memorize_bitmap
  fp["logo"].bitmap = pbBitmap(directory[0] + "evilTeamLogo2") if $DEBUG
  for logo in 0...X_SPECIES.length
    if num[logo] == species 
      fp["logo"].bitmap = pbBitmap(directory[logo] + "evilTeamLogo2")
    end
  end
  fp["logo"].zoom_x = 2
  fp["logo"].zoom_y = 2
  fp["logo"].z = 50
  
  fp["ring"] = Sprite.new(viewport)
  fp["ring"].bitmap = pbBitmap(directory[0] + "evilTeamEff2") if $DEBUG
  for eff2 in 0...X_SPECIES.length
    if num[eff2] == species 
      fp["ring"].bitmap = pbBitmap(directory[eff2] + "evilTeamEff2")
    end
  end
  fp["ring"].ox = fp["ring"].bitmap.width/2
  fp["ring"].oy = fp["ring"].bitmap.height/2
  fp["ring"].x = viewport.rect.width/2
  fp["ring"].y = viewport.rect.height/2
  fp["ring"].zoom_x = 0
  fp["ring"].zoom_y = 0 
  fp["ring"].z = 100
  
  pbSEPlay("transition1",80)
  for j in 0...32
    fp["e2_#{j}"] = Sprite.new(viewport)
    for eff4 in 0...X_SPECIES.length
      if num[eff4] == species 
        bmp = pbBitmap(directory[eff4] + "evilTeamEff4")
      end
    end
    fp["e2_#{j}"].bitmap = pbBitmap("Graphics/Transitions/evilTeamEff4")
    fp["e2_#{j}"].oy = fp["e2_#{j}"].bitmap.height/2
    fp["e2_#{j}"].angle = rand(360)
    fp["e2_#{j}"].opacity = 0
    fp["e2_#{j}"].x = viewport.rect.width/2
    fp["e2_#{j}"].y = viewport.rect.height/2
    fp["e2_#{j}"].z = 100
  end
  
  fp["ring2"] = Sprite.new(viewport)
  fp["ring2"].bitmap = pbBitmap(directory[0] + "evilTeamEff3") if $DEBUG
  for eff3 in 0...X_SPECIES.length
    if num[eff3] == species 
      fp["ring2"].bitmap = pbBitmap(directory[eff3] + "evilTeamEff3")
    end
  end
  fp["ring2"].ox = fp["ring2"].bitmap.width/2
  fp["ring2"].oy = fp["ring2"].bitmap.height/2
  fp["ring2"].x = viewport.rect.width/2
  fp["ring2"].y = viewport.rect.height/2
  fp["ring2"].visible = false
  fp["ring2"].zoom_x = 0
  fp["ring2"].zoom_y = 0 
  fp["ring2"].z = 100
  
  
  for i in 0...32
    viewport.color.alpha -= 8 if viewport.color.alpha > 0
    fp["logo"].zoom_x -= 1/32.0
    fp["logo"].zoom_y -= 1/32.0
    for j in 0...16
      next if j > i/4
      if fp["e1_#{j}"].ox < -(viewport.rect.width/2)
        speed[j] = 4 + rand(5)
        fp["e1_#{j}"].opacity = 0
        fp["e1_#{j}"].ox = 0
        fp["e1_#{j}"].angle = rand(360)
        bmp = pbBitmap(directory[0] + "evilTeamEff1") if $DEBUG
        for eff1 in 0...X_SPECIES.length
          if num[eff1] == species 
            bmp = pbBitmap(directory[eff1] + "evilTeamEff1")
          end
        end
        fp["e1_#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      fp["e1_#{j}"].opacity += speed[j]
      fp["e1_#{j}"].ox -=  speed[j]
    end
    pbWait(1)
  end
  fp["logo"].color = Color.new(255,255,255)
  fp["logo"].restore_bitmap
  fp["ring2"].visible = true
  fp["bg2"].visible = true
  viewport.color = Color.new(255,255,255)
  for i in 0...144
    if i >= 128
      viewport.color.alpha += 16
    else
      viewport.color.alpha -= 16 if viewport.color.alpha > 0
    end
    fp["logo"].color.alpha -= 16 if fp["logo"].color.alpha > 0
    fp["bg"].color.alpha -= 8 if fp["bg"].color.alpha > 0
    for j in 0...16
      if fp["e1_#{j}"].ox < -(viewport.rect.width/2)
        speed[j] = 4 + rand(5)
        fp["e1_#{j}"].opacity = 0
        fp["e1_#{j}"].ox = 0
        fp["e1_#{j}"].angle = rand(360)
        bmp = pbBitmap(directory[0] + "evilTeamEff1") if $DEBUG
        for eff1 in 0...X_SPECIES.length
          if num[eff1] == species 
            bmp = pbBitmap(directory[eff1] + "evilTeamEff1")
          end
        end
        fp["e1_#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        fp["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      fp["e1_#{j}"].opacity += speed[j]
      fp["e1_#{j}"].ox -=  speed[j]
    end
    for j in 0...32
      next if j > i*2
      fp["e2_#{j}"].ox -= 16
      fp["e2_#{j}"].opacity += 16
    end
    fp["ring"].zoom_x += 0.1
    fp["ring"].zoom_y += 0.1
    fp["ring"].opacity -= 8
    fp["ring2"].zoom_x += 0.2 if fp["ring2"].zoom_x < 3
    fp["ring2"].zoom_y += 0.2 if fp["ring2"].zoom_y < 3
    fp["ring2"].opacity -= 16
    fp["bg2"].angle += 2 if $PokemonSystem.screensize < 2  
    pbWait(1)
  end
  pbDisposeSpriteHash(fp)
  8.times do
    viewport.color.red -= 255/8.0
    viewport.color.green -= 255/8.0
    viewport.color.blue -= 255/8.0
    pbWait(1)
  end  
end
#-------------------------------------------------------------------------------
# Custom animations for wild battles
#-------------------------------------------------------------------------------
def queuedIsRegi?
  ret = false
  for poke in [:REGIROCK,:REGISTEEL,:REGICE,:REGIGIGAS]
    num = getConst(PBSpecies,poke)
    next if num.nil? || ret
    if $wildSpecies == num
      ret = true
    end
  end
  return ret
end

def isSpeciesX?
  ret = false
  for poke in X_SPECIES
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
  index = [PBSpecies::REGIROCK,PBSpecies::REGISTEEL,PBSpecies::REGICE,PBSpecies::REGIGIGAS].index($wildSpecies)
  width = viewport.rect.width
  height = viewport.rect.height
  viewport.color = Color.new(0,0,0,0)
  fp["back"] = Sprite.new(viewport)
  fp["back"].bitmap = Graphics.snap_to_bitmap
  fp["back"].blur_sprite
  c = index < 3 ? 0 : 255
  fp["back"].color = Color.new(c,c,c,128*(index < 3 ? 1 : 2))
  fp["back"].z = 99999
  fp["back"].opacity = 0
  x = [
  [width*0.5,width*0.25,width*0.75,width*0.25,width*0.75,width*0.25,width*0.75],
  [width*0.5,width*0.3,width*0.7,width*0.15,width*0.85,width*0.3,width*0.7],
  [width*0.5,width*0.325,width*0.675,width*0.5,width*0.5,width*0.15,width*0.85],
  [width*0.5,width*0.5,width*0.5,width*0.5,width*0.35,width*0.65,width*0.5]
  ]
  y = [
  [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.75,height*0.25],
  [height*0.5,height*0.25,height*0.75,height*0.5,height*0.5,height*0.75,height*0.25],
  [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.5,height*0.5],
  [height*0.9,height*0.74,height*0.58,height*0.4,height*0.25,height*0.25,height*0.1]
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
    if index < 3
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

def ebWildAnimationMinor(viewport)
  bmp = Graphics.snap_to_bitmap
  max = 50
  amax = 4
  frames = {}
  zoom = 1
  viewport.color = Color.new(255,255,155,0)
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
      viewport.color.alpha+=12
      viewport.color.blue+=5
    end
    pbWait(1)
  end
  frames["#{max+19}"].tone = Tone.new(255,255,255)
  pbWait(10)
  10.times do
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
      backdrop.tone.red+=3
      backdrop.tone.green+=3
      backdrop.tone.blue+=3
      pbWait(1)
    end
  end
  viewport.color = Color.new(0,0,0,0)
  10.times do
    viewport.color.alpha+=25.5
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
      sprites["#{i}"].color.alpha+=25.5 if sprites["#{i}"].color.alpha < 255 && f >= (64 - (48-i))
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
  pbSEPlay("Flash2")
  pbSEPlay("Sword2")
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
  pbSEPlay("Sword2")
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
  bbar1.bitmap = Bitmap.new(viewport.rect.width,1)
  bbar1.bitmap.fill_rect(0,0,viewport.rect.width,1,Color.new(0,0,0))
  bbar1.y = bar.y - bar.oy 
  bbar1.zoom_y = 0
  bbar1.z = 99
  
  bbar2 = Sprite.new(viewport)
  bbar2.bitmap = Bitmap.new(viewport.rect.width,1)
  bbar2.bitmap.fill_rect(0,0,viewport.rect.width,1,Color.new(0,0,0))
  bbar2.oy = 1
  bbar2.y = bar.y + bar.oy + 1
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
      pbSEPlay("Ice8",80) if i==32
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
      pbSEPlay("Saint9",50)
      pbSEPlay("Flash2",50)
      if colorReset
        light1.color = Color.new(0,0,0,0)
        light2.color = Color.new(0,0,0,0)
        light3.color = Color.new(0,0,0,0)
      end
    end
    if i >= max-8
      bbar1.zoom_y+=(bar.bitmap.height+2)/16.0
      bbar2.zoom_y+=(bar.bitmap.height+2)/16.0
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
      pbSEPlay("Saint9",50)
      pbSEPlay("Flash2",50)
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
  pbDrawOutlineText(name.bitmap,110,viewport.rect.height-128,-1,-1,"#{trainername}",Color.new(255,255,255),Color.new(0,0,0),2)
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
  trainer.x = -viewport.rect.width/2
  trainer.z = 100
  trainer.color = Color.new(0,0,0,255)
  
  shadow = Sprite.new(viewport)
  shadow.bitmap = pbBitmap(tgraphic)
  shadow.x = viewport.rect.width/2 + 22
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
    trainer.x += ((viewport.rect.width/2)-trainer.x)*0.2
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
    trainer.x += ((viewport.rect.width+64)-trainer.x)*0.2
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
# Sun & Moon VS animation
#-------------------------------------------------------------------------------
class PokeBattle_Scene
  def vsSequenceSM_start(viewport,trainerid)
    @smSpecial = pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",trainerid))
    
    evil = false
    for val in EVIL_TEAM_LIST
      if val.is_a?(Numeric)
        id = val
      elsif val.is_a?(Symbol)
        id = getConst(PBTrainers,val)
      end
      evil = true if !id.nil? && trainerid == id
    end
    
    bgstring = "Graphics/Transitions/smBg#{trainerid}"
    bgstring2 = "Graphics/Transitions/smBgNext#{trainerid}"
    bgstring3 = "Graphics/Transitions/smBgLast#{trainerid}"
  
    @vs = {}
  
    @vs["bg"] = @smSpecial ? RainbowSprite.new(viewport) : ScrollingSprite.new(viewport)
    @vs["bg"].setBitmap("Graphics/Transitions/smBgDefault")
    @vs["bg"].setBitmap("Graphics/Transitions/smBgEvil") if evil
    @vs["bg"].setBitmap(bgstring) if pbResolveBitmap(bgstring)
    @vs["bg"].setBitmap("Graphics/Transitions/smBgSpecial") if @smSpecial
    @vs["bg"].color = Color.new(0,0,0,255)
    @vs["bg"].speed = @smSpecial ? 4 : 32
    @vs["bg"].ox = @vs["bg"].src_rect.width/2
    @vs["bg"].oy = @vs["bg"].src_rect.height/2
    @vs["bg"].x = viewport.rect.width/2
    @vs["bg"].y = viewport.rect.height/2
    @vs["bg"].angle = - 8 if !@smSpecial && $PokemonSystem.screensize < 2  
    @vs["bg"].z = 200
    if !@smSpecial
      @vs["bg2"] = ScrollingSprite.new(viewport)
      @vs["bg2"].setBitmap("Graphics/Transitions/smBgLastDefault",false,true)
      @vs["bg2"].setBitmap("Graphics/Transitions/smBgLastEvil",false,true) if evil
      @vs["bg2"].setBitmap(bgstring3,false,true) if pbResolveBitmap(bgstring3)
      @vs["bg2"].color = Color.new(0,0,0,255)
      @vs["bg2"].speed = 64
      @vs["bg2"].ox = @vs["bg2"].src_rect.width/2
      @vs["bg2"].oy = @vs["bg2"].src_rect.height/2
      @vs["bg2"].x = viewport.rect.width/2
      @vs["bg2"].y = viewport.rect.height/2
      @vs["bg2"].angle = - 8 if $PokemonSystem.screensize < 2  
      @vs["bg2"].z = 200
      @vs["bg3"] = ScrollingSprite.new(viewport)
      @vs["bg3"].setBitmap("Graphics/Transitions/smBgNextDefault",false,true)
      @vs["bg3"].setBitmap("Graphics/Transitions/smBgNextEvil",false,true) if evil
      @vs["bg3"].setBitmap(bgstring2,false,true) if pbResolveBitmap(bgstring2)
      @vs["bg3"].color = Color.new(0,0,0,255)
      @vs["bg3"].speed = 80
      @vs["bg3"].ox = @vs["bg3"].src_rect.width/2
      @vs["bg3"].oy = @vs["bg3"].src_rect.height/2
      @vs["bg3"].x = viewport.rect.width/2
      @vs["bg3"].y = viewport.rect.height/2
      @vs["bg3"].angle = - 8 if $PokemonSystem.screensize < 2  
      @vs["bg3"].z = 200
    end
  
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
    if @smSpecial
      @vsFp["ring"] = Sprite.new(viewport)
      @vsFp["ring"].bitmap = pbBitmap("Graphics/Transitions/smRing")
      @vsFp["ring"].ox = @vsFp["ring"].bitmap.width/2
      @vsFp["ring"].oy = @vsFp["ring"].bitmap.height/2
      @vsFp["ring"].x = viewport.rect.width/2
      @vsFp["ring"].y = viewport.rect.height
      @vsFp["ring"].zoom_x = 0
      @vsFp["ring"].zoom_y = 0
      @vsFp["ring"].z = 500
      
      for j in 0...32
        @vsFp["s#{j}"] = Sprite.new(viewport)
        @vsFp["s#{j}"].bitmap = pbBitmap("Graphics/Transitions/smSpec")
        @vsFp["s#{j}"].ox = @vsFp["s#{j}"].bitmap.width/2
        @vsFp["s#{j}"].oy = @vsFp["s#{j}"].bitmap.height/2
        @vsFp["s#{j}"].opacity = 0
        @vsFp["s#{j}"].z = 220
        @fpDx.push(0)
        @fpDy.push(0)
      end
      
      @fpSpeed = []
      @fpOpac = []
      for j in 0...3
        k = j+1
        speed = 2 + rand(5)
        @vsFp["p#{j}"] = ScrollingSprite.new(viewport)
        @vsFp["p#{j}"].setBitmap("Graphics/Transitions/smSpecEff#{k}")
        @vsFp["p#{j}"].speed = speed*4
        @vsFp["p#{j}"].direction = -1
        @vsFp["p#{j}"].opacity = 0
        @vsFp["p#{j}"].z = 400
        @vsFp["p#{j}"].zoom_y = 1 + rand(10)*0.005
        @fpSpeed.push(speed)
        @fpOpac.push(4) if j > 0
      end
    end
    
    @vs["shade"] = Sprite.new(viewport)
    @vs["shade"].z = 250
    @vs["glow"] = Sprite.new(viewport)
    @vs["glow"].y = viewport.rect.height
    @vs["glow"].z = 250
    @vs["glow2"] = Sprite.new(viewport)
    @vs["glow2"].x = viewport.rect.width/2
    @vs["glow2"].z = 250
  
    @vs["trainer"] = Sprite.new(viewport)
    @vs["trainer"].z = 350
    @vs["trainer"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["trainer"].ox = @vs["trainer"].bitmap.width/2
    @vs["trainer"].oy = @vs["trainer"].bitmap.height/2
    @vs["trainer"].x = @vs["trainer"].ox
    @vs["trainer"].y = @vs["trainer"].oy
    @vs["trainer"].tone = Tone.new(255,255,255)
    @vs["trainer"].zoom_x = 1.32
    @vs["trainer"].zoom_y = 1.32
    @vs["trainer"].opacity = 0
  
    t_ext = @smSpecial ? "Special" : "Trainer"
    bmp = pbBitmap("Graphics/Transitions/sm#{t_ext}#{trainerid}")
    ox = (@vs["trainer"].bitmap.width - bmp.width)/2
    oy = (@vs["trainer"].bitmap.height - bmp.height)/2
    @vs["trainer"].bitmap.blt(ox,oy,bmp,Rect.new(0,0,bmp.width,bmp.height))
    bmp = @vs["trainer"].bitmap.clone
  
    @vs["shade"].bitmap = bmp.clone
    @vs["shade"].color = Color.new(10,169,245,224)
    @vs["shade"].opacity = 0
  
    @vs["glow"].bitmap = bmp.clone
    @vs["glow"].glow(Color.new(0,0,0),35,false)
    @vs["glow"].src_rect.set(0,viewport.rect.height,viewport.rect.width/2,0)
    @vs["glow2"].bitmap = @vs["glow"].bitmap.clone
    @vs["glow2"].src_rect.set(viewport.rect.width/2,0,viewport.rect.width/2,0)
  
    @vs["overlay"] = Sprite.new(viewport)
    @vs["overlay"].z = 999
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["overlay"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @vs["overlay"].opacity = 0
    16.times do
      @vs["trainer"].zoom_x -= 0.02
      @vs["trainer"].zoom_y -= 0.02
      @vs["trainer"].opacity += 32
      Graphics.update
    end
    @vs["trainer"].zoom_x = 1; @vs["trainer"].zoom_y = 1
    @commandWindow.drawLineup if !defined?(SCREENDUALHEIGHT)
    @commandWindow.lineupY(-32) if !defined?(SCREENDUALHEIGHT)
    for i in 0...16
      @commandWindow.showArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["trainer"].tone.red -= 16
      @vs["trainer"].tone.green -= 16
      @vs["trainer"].tone.blue -= 16
      @vs["bg"].color.alpha -= 16
      if !@smSpecial
        @vs["bg2"].color.alpha -= 16
        @vs["bg3"].color.alpha -= 16
      end
      if @smSpecial
        @vsFp["ring"].zoom_x += 0.2
        @vsFp["ring"].zoom_y += 0.2
        @vsFp["ring"].opacity -= 16
      end
      self.vsSequenceSM_update
      Graphics.update
    end
    16.times do
      self.vsSequenceSM_update
      Graphics.update
    end
    pbSEPlay("transition2",100)
    for i in 0...16
      @vs["trainer"].tone.red -= 32*(i < 8 ? -1 : 1)
      @vs["trainer"].tone.green -= 32*(i < 8 ? -1 : 1)
      @vs["trainer"].tone.blue -= 32*(i < 8 ? -1 : 1)
      @vs["bg"].speed = (@smSpecial ? 2 : 16) if i == 8
      if !@smSpecial
        @vs["bg2"].speed = 2 if i == 8
        @vs["bg3"].speed = 6 if i == 8
      end
      for j in 0...3
        next if !@smSpecial
        next if i != 8
        @vsFp["p#{j}"].speed /= 4
      end
      self.vsSequenceSM_update
      Graphics.update
    end
    16.times do
      @vs["glow"].src_rect.height += 24
      @vs["glow"].src_rect.y -= 24
      @vs["glow"].y -= 24
      @vs["glow2"].src_rect.height += 24
      self.vsSequenceSM_update
      Graphics.update
    end
    8.times do
      @vs["glow"].tone.red += 32
      @vs["glow"].tone.green += 32
      @vs["glow"].tone.blue += 32
      @vs["glow2"].tone.red += 32
      @vs["glow2"].tone.green += 32
      @vs["glow2"].tone.blue += 32
      self.vsSequenceSM_update
      Graphics.update
    end
    for i in 0...4
      @vs["trainer"].tone.red += 64
      @vs["trainer"].tone.green += 64
      @vs["trainer"].tone.blue += 64
      if !@smSpecial
        @vs["bg"].x += 2
        @vs["bg2"].x += 2
        @vs["bg3"].x += 2
      end
      self.vsSequenceSM_update
      Graphics.update
    end
    for j in 0...3
      next if !@smSpecial
      @vsFp["p#{j}"].z = 300
    end
    for i in 0...8
      @vs["trainer"].tone.red -= 32
      @vs["trainer"].tone.green -= 32
      @vs["trainer"].tone.blue -= 32
      @vs["shade"].opacity += 32
      @vs["shade"].x -= 4
      if i < 4 && !@smSpecial
        @vs["bg"].x -= 2
        @vs["bg2"].x -= 2
        @vs["bg3"].x -= 2
      end
      self.vsSequenceSM_update
      Graphics.update
    end 
  end

  def vsSequenceSM_update
    @vs["bg"].update if @vs["bg"] && !@vs["bg"].disposed?
    @vs["bg2"].update if @vs["bg2"] && !@vs["bg2"].disposed?
    @vs["bg3"].update if @vs["bg3"] && !@vs["bg3"].disposed?
    for j in 0...32
      next if !@smSpecial
      next if !@vsFp["s#{j}"] || @vsFp["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @vsFp["s#{j}"].opacity <= 1
        width = @vs["bg"].viewport.rect.width
        height = @vs["bg"].viewport.rect.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @vsFp["s#{j}"].zoom_x = z
        @vsFp["s#{j}"].zoom_y = z
        @vsFp["s#{j}"].x = x
        @vsFp["s#{j}"].y = y
        @vsFp["s#{j}"].opacity = 255
        @vsFp["s#{j}"].angle = rand(360)
      end
      @vsFp["s#{j}"].x -= (@vsFp["s#{j}"].x - @fpDx[j])*0.05
      @vsFp["s#{j}"].y -= (@vsFp["s#{j}"].y - @fpDy[j])*0.05
      @vsFp["s#{j}"].opacity -= @vsFp["s#{j}"].opacity*0.05
      @vsFp["s#{j}"].zoom_x -= @vsFp["s#{j}"].zoom_x*0.05
      @vsFp["s#{j}"].zoom_y -= @vsFp["s#{j}"].zoom_y*0.05
    end
    for j in 0...3
      next if !@smSpecial
      next if !@vsFp["p#{j}"] || @vsFp["p#{j}"].disposed?
      @vsFp["p#{j}"].update
      if j == 0
        @vsFp["p#{j}"].opacity += 5 if @vsFp["p#{j}"].opacity < 155
      else
        @vsFp["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@vsFp["p#{j}"].opacity >= 255 || @vsFp["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 128
  end

  def vsSequenceSM_end
    echoln(@vs)
    viewport = @viewport
    zoom = 4.0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    @vs["bg"].speed = @smSpecial ? 4 : 32
    if !@smSpecial
      @vs["bg2"].speed = 64
      @vs["bg3"].speed = 8
    end
    for j in 0...3
      next if !@smSpecial
      @vsFp["p#{j}"].speed *= 4
    end
    for i in 0..20
      @vs["trainer"].x += 6*(i/5 + 1)
      @vs["glow"].x += 6*(i/5 + 1)
      @vs["glow2"].x += 6*(i/5 + 1)
      @commandWindow.hideArrows if i < 10 && !defined?(SCREENDUALHEIGHT)
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity += 64
      zoom -= 4.0/20
      self.vsSequenceSM_update
      @vs["shade"].opacity -= 16
      Graphics.update
    end
    @commandWindow.lineupY(+32) if !defined?(SCREENDUALHEIGHT)
    pbDisposeSpriteHash(@vs)  
    pbDisposeSpriteHash(@vsFp)
    @vs["overlay"] = Sprite.new(@msgview)
    @vs["overlay"].z = 9999999
    @vs["overlay"].bitmap = Bitmap.new(@msgview.rect.width,@msgview.rect.height)
    @vs["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,@msgview.rect.height,Color.new(0,0,0))
  end

  def vsSequenceSM_sendout
    $smAnim = false
    viewport = @msgview
    zoom = 0
    obmp = pbBitmap("Graphics/Transitions/ballTransition")
    21.times do
      @vs["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @vs["overlay"].bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      @vs["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @vs["overlay"].opacity -= 12.8
      zoom += 4.0/20
      wait(1,true)
    end
    @vs["overlay"].dispose
  end
end