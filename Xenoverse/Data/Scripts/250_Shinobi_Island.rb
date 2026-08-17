class ::Array
  def any(predicate)
    for i in 0...self.length
      return true if predicate.call(self[i])
    end
    return false
  end

  def pick(predicate)
    ret=[]
    for i in 0...self.length
      ret.push(self[i]) if predicate.call(self[i])
    end
    return ret
  end
end

class PokeBattle_Trainer
    attr_accessor(:realBag)
    attr_accessor(:realParty)
    attr_accessor(:inShinobiIsland)
    attr_accessor(:storedLevels)
    attr_accessor(:registeredItem)

    def inShinobiIsland?
      return @inShinobiIsland == true
    end

    def storePartyLevels
      @storedLevels = {}
      for i in $Trainer.party
        echoln "#{i.name} #{i.personalID}"
        @storedLevels[i.personalID] = i.level
      end
      echoln @storedLevels
    end

    def restorePartyLevels
      echoln @storedLevels
      for i in $Trainer.party
        if @storedLevels[i.personalID] != nil
          echoln "#{i.name} #{i.personalID}"
          i.level = @storedLevels[i.personalID]
          i.calcStats
        end
      end
    end


    def enterShinobiIsland
        return if self.inShinobiIsland?() == true #Needed for bug fix
        Kernel.pbMessage(_INTL("Devi scegliere 3 Pokémon da portare con te."))

        banlist = [PBSpecies::LUXFLON,PBSpecies::DIELEBI,PBSpecies::MEW,
        PBSpecies::HOOH,PBSpecies::LUGIA,
        PBSpecies::CELEBI,PBSpecies::DEOXYS,PBSpecies::HEATRAN,PBSpecies::DARKRAI,
        PBSpecies::CRESSELIA,PBSpecies::GENESECT,
        PBSpecies::MELOETTA,PBSpecies::MARSHADOW,PBSpecies::MEWTWOX,
        PBSpecies::TRISHOUT,PBSpecies::SHYLEON,PBSpecies::SHULONG]
        pbFadeOutIn(99999){
          scene=PokemonScreen_Scene.new
          screen=PokemonScreen.new(scene,$Trainer.party)
          ret=screen.pbChooseMultiplePokemon(3,proc{|p| 
          return !banlist.include?(p.species)})
          if ret == nil || ret == -1
            return false 
          else
            @inShinobiIsland = true
            @realBag = $PokemonBag
            @registeredItem = $PokemonBag.registeredItem
            $PokemonBag = PokemonBag.new
            @realParty = $Trainer.party
            
            for item in @realBag.pockets[pbGetPocket(267)]
                $PokemonBag.pbStoreItem(item[0],item[1])
            end
            $PokemonBag.pbStoreItem(PBItems::OLDROD,@realBag.pbQuantity(PBItems::OLDROD)) if @realBag.pbQuantity(PBItems::OLDROD)>0
            $PokemonBag.pbStoreItem(PBItems::GOODROD,@realBag.pbQuantity(PBItems::GOODROD)) if @realBag.pbQuantity(PBItems::GOODROD)>0
            $PokemonBag.pbStoreItem(PBItems::SUPERROD,@realBag.pbQuantity(PBItems::SUPERROD)) if @realBag.pbQuantity(PBItems::SUPERROD)>0
            $PokemonBag.pbStoreItem(PBItems::SPECIALROD,@realBag.pbQuantity(PBItems::SPECIALROD)) if @realBag.pbQuantity(PBItems::SPECIALROD)>0
            $Trainer.party = Marshal.load(Marshal.dump(ret))

            #Removing healing items
            for i in $Trainer.party
              if pbGetPocket(i.item) == 2
                i.item = 0
              end
            end

            return true
          end
        }

    end


    def exitShinobiIsland
        return if !inShinobiIsland?() 
        # Bring back acquired items
        tempBag = $PokemonBag
        $PokemonBag = PokemonBag.new#@realBag if @realBag != nil
        
        if $game_switches[997]==true
          $game_switches[997]=false
        end

        index = 0
        for pocket in tempBag.pockets
            #if index != pbGetPocket(267)
            #    echoln(pocket)
            for item in pocket
              next if item[0]==PBItems::OLDROD
              next if item[0]==PBItems::GOODROD
              next if item[0]==PBItems::SUPERROD
              next if item[0]==PBItems::SPECIALROD
              $PokemonBag.pbStoreItem(item[0],item[1])
            end
            #end
            index+=1
        end
        index = 0
        for pocket in @realBag.pockets
            if index != pbGetPocket(267)
            #    echoln(pocket)
              for item in pocket
                $PokemonBag.pbStoreItem(item[0],item[1])
              end
            end
            index+=1
        end
        #Restore registered item
        if (@registeredItem != nil && @registeredItem>0)
          $PokemonBag.pbRegisterKeyItem(@registeredItem)
        end

        tempPt = $Trainer.party
        $Trainer.party = []
        echoln @realParty
        echoln tempPt
        if $MKXP
          temp = []
          for i in tempPt
            temp.push(i.personalID)
          end
          rp = @realParty.clone
          del = []
          for i in rp
            if temp.include?(i.personalID)
              temp.delete(i.personalID)
              del.push(i)
            end
          end
          rp = rp-del
          $Trainer.party = (tempPt+rp).uniq
        else
          app = @realParty.pick(proc{|p|
            for i in tempPt
              echoln "#{i.personalID} #{p.personalID}"
              return true if i.personalID == p.personalID
            end
          return false})
          echoln "APP"
          echoln app
          $Trainer.party = tempPt + (@realParty-app)
        end
        
        echoln "EXITING FROM SHINOBI ISLAND"

        @inShinobiIsland = false

    end
end

IMMUNESHINOBI = [PBSpecies::GRENINJAX]

#NEW BOSS TRANSITION
class NewBossBattleTransition
    attr_accessor :speed
    # creates the transition handler
    def initialize(*args)
      echo @variant
      $smAnim=false
      return if args.length < 4
      # sets up main viewports
      @viewport = args[0]
      @viewport.color = Color.new(255,255,255,0)
      @viewport.z+=10000
      @msgview = args[1]
      # sets up variables
      @disposed = false
      @sentout = false
      @scene = args[2]
      @trainerid = args[3]
      @speed = 1
      @sprites = {}
      # retreives additional parameters
      @teamskull = true
      self.getParameters(@trainerid)
      # plays the animation before the main sequence
      
      @evilteam ? self.evilTeam : self.rainbowIntro
      #@teamskull = @variant == "skull"
      
      self.teamSkull if @teamskull
      # initializes the backdrop
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
        @sprites["background"] = SunMoonFuryBackground.new(@viewport,@trainerid,@evilteam)
      when "vip"
        @sprites["background"] = SunMoonVipBackground.new(@viewport,@trainerid,@evilteam)
      else
        @sprites["background"] = SunMoonDefaultBackground.new(@viewport,@trainerid,@evilteam,@teamskull)
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
      @sprites["trainer"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
      @sprites["trainer"].ox = @sprites["trainer"].bitmap.width/2
      @sprites["trainer"].oy = @sprites["trainer"].bitmap.height/2
      @sprites["trainer"].x = @sprites["trainer"].ox if @variant != "plasma" && @variant != "cardinal" 
      @sprites["trainer"].y = @sprites["trainer"].oy
      @sprites["trainer"].tone = Tone.new(255,255,255)
      @sprites["trainer"].zoom_x = 1.32 if @variant != "plasma" && @variant != "cardinal" 
      @sprites["trainer"].zoom_y = 1.32 if @variant != "plasma" && @variant != "cardinal" 
      @sprites["trainer"].opacity = 0
      # sets a bitmap for the trainer
      bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%d",$wildSpecies))
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
      @sprites["shade"].visible = false if @variant == "crazy" || @variant == "plasma" ||@variant == "cardinal" 
      # creates and colours an outer glow for the trainer
      c = Color.new(0,0,0)
      c = Color.new(255,255,255) if @variant == "crazy" || @variant == "digital" || @variant == "plasma" ||@variant == "cardinal" 
      @sprites["glow"].bitmap = bmp.clone
      @sprites["glow"].glow(c,35,false)
      @sprites["glow"].src_rect.set(0,@viewport.rect.height,@viewport.rect.width/2,0)
      @sprites["glow2"].bitmap = @sprites["glow"].bitmap.clone
      @sprites["glow2"].src_rect.set(@viewport.rect.width/2,0,@viewport.rect.width/2,0)
      # creates the fade-out ball graphic overlay
      @sprites["overlay"] = Sprite.new(@viewport)
      @sprites["overlay"].z = 999
      @sprites["overlay"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
      @sprites["overlay"].opacity = 0
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

      
      @sprites["white"] = EAMSprite.new(pvvp)
      @sprites["white"].visible = false
      @sprites["white"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
      @sprites["white"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
      @sprites["blacktop"] = EAMSprite.new(pvvp)
      @sprites["blacktop"].bitmap = Bitmap.new(Graphics.width+100,Graphics.height/2)
      @sprites["blacktop"].bitmap.fill_rect(0,0,@sprites["blacktop"].bitmap.width,@sprites["blacktop"].bitmap.height,Color.new(0,0,0))
      @sprites["blacktop"].x = -50
      @sprites["blacktop"].visible = false
      @sprites["blackbottom"] = EAMSprite.new(pvvp)
      @sprites["blackbottom"].bitmap = Bitmap.new(Graphics.width+100,Graphics.height/2)
      @sprites["blackbottom"].bitmap.fill_rect(0,0,@sprites["blackbottom"].bitmap.width,@sprites["blackbottom"].bitmap.height,Color.new(0,0,0))
      @sprites["blackbottom"].visible = false
      @sprites["blackbottom"].x = -50
      @sprites["blackbottom"].y = Graphics.height/2
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
      @sprites["blacktop"].visible=true
      @sprites["blackbottom"].visible=true
      @sprites["white"].visible = true

      @sprites["blacktop"].moveY(-200,35,:ease_in_expo)
      @sprites["blackbottom"].moveY(Graphics.height/2+200,35,:ease_in_expo)
      30.times do
        Graphics.update
        Input.update
      end
      30.times do
        Graphics.update
        Input.update
      end
      pbSEPlay("Unsheate",70)
      35.times do
        Graphics.update
        Input.update
        @sprites["blacktop"].update
        @sprites["blackbottom"].update
      end

      @sprites["white"].fade(0,20)
      20.times do
        Graphics.update
        Input.update
        @sprites["white"].update
      end
    end

    # starts the animation
    def start
      
      if $wildSpecies == PBSpecies::DRAGALISKFURIA
        echoln "POGGERS"
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
      obmp = pbBitmap("Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}")
      @sprites["background"].speed = 24
      echo "\n I got here SOMEHOW NEW\n"
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
        @sprites["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(@obmp.width*zoom).ceil,(@obmp.height*zoom).ceil),@obmp,@obmp.rect)
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
        @sprites["glow#{i}"].bitmap = pbBitmap("Graphics/Transitions/SunMoon/Common/glow#{@teamskull ? "Skull" : ""}")
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
      ext = ["trainer","special","elite","crazy","ultra","digital","plasma","skull","cardinal","fury"]
      #ext.push("trainer")
      @variant = "trainer"
      for i in 0...ext.length
        @variant = ext[i] if pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",ext[i],trainerid))
      end
      # sets up the rest of the variables
      @obmp = pbBitmap("Graphics/Transitions/SunMoon/Common/ballTransition#{@teamskull ? "Skull" : ""}")
    end
  end
