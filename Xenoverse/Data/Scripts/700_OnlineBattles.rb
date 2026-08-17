#####################################################################
# ONLINE BATTLES
#####################################################################
class OnlineLobby
  attr_accessor(:playerList)
  attr_accessor(:selectionIndex)
  attr_accessor(:buttonSelectionIndex)
  attr_accessor(:canRefresh)
  attr_accessor(:connection)


  LIGHTBLUE = Color.new(131,218,230)

  MAX_VISIBLE_PLAYERS = 11

  YES = _INTL("Yes")

  FADE_TIME = 12
  HEADER_SPEED = 400
  HEADER_TEXT_SPEED = 20 #Higher, slower

  LOBBY_BGM = "Online Lobby"

  ENABLE_BATTLE_TIMER = false

  def initialize()
    @canRefresh = false
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 9999
    @viewport2 = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z = 999999
    @sprites={}

    @shownUI = false

    @listOffset = 0

    @path = "Graphics/Pictures/Online/"

    @selectionIndex = 0

    @buttonSelectionIndex = 1
    @buttonSelectionEnabled = false
    #ID - Name - Debug - Status
    @playerList=[]
    @frame = 0
    @toggleParty = false

    @lastServerMessage = ""

    status=[:blocked,:matchmaking,:trading,:waiting,:matched]
  
    Graphics.frame_rate = 60

  
    pbFadeOutIn(999999){
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = pbBitmap(@path + "BG")

      @sprites["animbg"]=AnimatedPlane.new(@viewport)
      @sprites["animbg"].bitmap=pbBitmap(@path + "repeatbg")

      @sprites["refresh"] = Sprite.new(@viewport)
      @sprites["refresh"].bitmap = pbBitmap(@path + "refresh")
      @sprites["refresh"].x = 242
      @sprites["refresh"].y = 304
      @sprites["refresh"].visible = false

      @sprites["list"] = Sprite.new(@viewport)
      @sprites["list"].bitmap = pbBitmap(@path + "playerlist")
      @sprites["list"].x = 14
      @sprites["list"].y = 44
      @sprites["list"].visible = false

      @sprites["avatarbox"] = EAMSprite.new(@viewport)
      @sprites["avatarbox"].bitmap = pbBitmap(@path + "avatarbox")
      @sprites["avatarbox"].x = 348
      @sprites["avatarbox"].y = 54
      @sprites["avatarbox"].visible = false
      id = $Trainer.online_trainer_type
      echoln id
      bmp = nil
      if pbResolveBitmap(sprintf("Graphics/Transitions/smTrainer%d",id)) != nil
        bmp = pbBitmap(sprintf("Graphics/Transitions/smTrainer%d",id))
      elsif pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",id)) != nil
        bmp = pbBitmap(sprintf("Graphics/Transitions/smSpecial%d",id))
      elsif checkIfNewTransition(id,true)#pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id)) != nil
        variant = getNewTransitionVariant(id)
        bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id))
      end
      @sprites["avatar"] = Sprite.new(@viewport)
      echoln "check for #{@path + "Avatars/major_icon#{id}"}"
      if pbResolveBitmap(@path + "Avatars/major_icon#{id}")
        @sprites["avatar"].bitmap = pbBitmap(@path + "Avatars/major_icon#{id}").clone
        @sprites["avatar"].x = 346
      else
        if bmp != nil
          resbmp = Bitmap.new(bmp.width/2,bmp.height/2)
          resbmp.stretch_blt(Rect.new(0,0,bmp.width/2,bmp.height/2),bmp,Rect.new(0,0,bmp.width,bmp.height))
          @sprites["avatar"].bitmap = resbmp
          @sprites["avatar"].bitmap = @sprites["avatar"].bitmap.mask!(@path+"avatarbox",0,@sprites["avatar"].bitmap.height/6)
        end
        @sprites["avatar"].x = 348
      end
      @sprites["avatar"].y = 54
      @sprites["avatar"].visible = false
      
      @sprites["avatarborder"] = EAMSprite.new(@viewport)
      @sprites["avatarborder"].bitmap = pbBitmap(@path + "Avatars/avatar_border_0")
      @sprites["avatarborder"].visible = false
      @sprites["avatarborder"].ox = @sprites["avatarborder"].bitmap.width/2
      @sprites["avatarborder"].oy = @sprites["avatarborder"].bitmap.height/2
      @sprites["avatarborder"].x = 414
      @sprites["avatarborder"].y = 122
      #self.createUI
    }
  end

  def endScene
    pbFadeOutAndHide(@sprites)
  end

  def openSettings(msgwindow)
    sett = ["bgButton","bgmButton","saveRentalButton","rentalButton","useRentalButton"]

    settDetails = {
      "bgButton"=>{
        :t => _INTL("Battle Background"),
        :info => _INTL("Pick a battle background for your battles.")
      },
      "bgmButton"=>{
        :t => _INTL("Battle Music"),
        :info => _INTL("Pick a battle BGM for your battles.")
      },
      "saveRentalButton"=>{
        :t => _INTL("Save Rental Team"),
        :info => _INTL("Creates a rental team using your current party.")
      },
      "rentalButton"=>{
        :t => _INTL("Pick Rental Team"),
        :info => _INTL("Set the code for the Rental Team you wish to use.")
      },
      "useRentalButton"=>{
        :t => _INTL("Use Rental Team"),
        :info => _INTL("Using Rental Team: {1}", $Trainer.useRentalTeam ? _INTL("Yes") : _INTL("No"))
      },

    }

    selIndex = 0
    oldId = 0

    settsprites={}
    #create sprites for settings interface
    for st in sett
      settsprites[st] = EAMSprite.new(@viewport)
      settsprites[st].bitmap = pbBitmap(@path + "SettingsButton").clone
      settsprites[st].ox = settsprites[st].bitmap.width/2
      settsprites[st].x = Graphics.width/2
      settsprites[st].y = 60 + 35*sett.index(st)
      settsprites[st].opacity = 0
      pbSetFont(settsprites[st].bitmap, "Barlow Condensed", 24)
      settsprites[st].bitmap.font.color=Color.new(24,24,24)
      settsprites[st].bitmap.draw_text(0,0,settsprites[st].bitmap.width,settsprites[st].bitmap.height,settDetails[st][:t],1)
      settsprites[st].fade(sett.index(st) == selIndex ? 255 : 128,20,:ease_out_cubic)
    end

    @bbpath = "Graphics/Battlebacks/Battlebg"

    bgs = CableClub.getOnlineBattleBackList()

    currentBgIndex = bgs.index($Trainer.online_battle_bg)

    bgms = CableClub.getOnlineBGMList()

    currentBgmIndex = bgms.index($Trainer.online_battle_bgm)

    settsprites["background"] = EAMSprite.new(@viewport)
    settsprites["background"].bitmap = pbBitmap(@bbpath + bgs[currentBgIndex])
    settsprites["background"].ox = settsprites["background"].bitmap.width/2
    settsprites["background"].oy = settsprites["background"].bitmap.height/2
    settsprites["background"].x = Graphics.width/2
    settsprites["background"].y = Graphics.height/2
    settsprites["background"].zoom_x*=0.6
    settsprites["background"].zoom_y*=0.6
    settsprites["background"].opacity = 0

    sprites = ["refresh","list","avatarbox","avatar","avatarborder","selection","status","battleButton","tradeButton","settingsButton","leaveButton"]
    opacities = []
    for s in sprites
      opacities << @sprites[s].opacity
    end
    20.times do
      for s in sprites
        @sprites[s].opacity-=opacities[sprites.index(s)]/20 + 1
      end
      Graphics.update
      Input.update
      self.update(false)
    end

    20.times do 
      for st in sett
        settsprites[st].update
      end
      Graphics.update
      Input.update
      self.update(false)
    end

    msgwindow.visible = true
    Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)

    loop do 
      Graphics.update
      Input.update
      self.update(false)
      for st in sett
        settsprites[st].update
      end

      if oldId != selIndex
        for st in sett
          settsprites[st].fade(128,15) if sett.index(st) == oldId
          settsprites[st].fade(255,15) if sett.index(st) == selIndex
        end
        Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)
        oldId = selIndex
      end

      if Input.trigger?(Input::DOWN)
        selIndex+=1
        if selIndex >= sett.length
          selIndex = 0
        end
      end

      if Input.trigger?(Input::UP)
        selIndex-=1
        if selIndex < 0
          selIndex = sett.length-1
        end
      end

      if Input.trigger?(Input::C)
        case selIndex
        when 0 # BATTLE BACKGROUND SELECTION
          settsprites["background"].fade(255,10,:ease_in_cubic)
          10.times do 
            settsprites["background"].update
            Graphics.update
            Input.update
            self.update(false)
          end
          loop do 
            Graphics.update
            Input.update
            self.update(false)
            for st in sett
              settsprites[st].update
            end

            if Input.trigger?(Input::RIGHT)
              currentBgIndex += 1
              currentBgIndex  = 0 if currentBgIndex >= bgs.length
              settsprites["background"].bitmap = pbBitmap(@bbpath + bgs[currentBgIndex])
              settsprites["background"].ox = settsprites["background"].bitmap.width/2
              settsprites["background"].oy = settsprites["background"].bitmap.height/2
            end

            if Input.trigger?(Input::LEFT)
              currentBgIndex -= 1
              currentBgIndex  = bgs.length-1 if currentBgIndex < 0
              settsprites["background"].bitmap = pbBitmap(@bbpath + bgs[currentBgIndex])
              settsprites["background"].ox = settsprites["background"].bitmap.width/2
              settsprites["background"].oy = settsprites["background"].bitmap.height/2
            end

            if Input.trigger?(Input::C)
              Kernel.pbMessageDisplay(msgwindow,_INTL("Do you want to use this battle background?"))
              if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                $Trainer.online_battle_bg = bgs[currentBgIndex]
                echoln "Set battle background #{$Trainer.online_battle_bg}"
                break
              end
            end

            if Input.trigger?(Input::B)
              break
            end
          end
          settsprites["background"].fade(0,10,:ease_in_cubic)
          10.times do 
            settsprites["background"].update
            Graphics.update
            Input.update
            self.update(false)
          end
        when 1 # BATTLE BGM SELECTION
          pbBGMPlay(bgms[currentBgmIndex])
          Kernel.pbMessageDisplay(msgwindow,_INTL("Pick the BGM you would like to hear in Online Battles. Press < and > to change BGM."),false)
          loop do
            Graphics.update
            Input.update
            self.update(false)
            for st in sett
              settsprites[st].update
            end
            if Input.trigger?(Input::RIGHT)
              currentBgmIndex+= 1
              currentBgmIndex = 0 if currentBgmIndex >= bgms.length
              pbBGMPlay(bgms[currentBgmIndex])
            end
            if Input.trigger?(Input::LEFT)
              currentBgmIndex-= 1
              currentBgmIndex = bgms.length-1 if currentBgmIndex < 0
              pbBGMPlay(bgms[currentBgmIndex])
            end
            if Input.trigger?(Input::C)
              Kernel.pbMessageDisplay(msgwindow,_INTL("Do you want to use this BGM?"))
              if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                $Trainer.online_battle_bgm = bgms[currentBgmIndex]
                echoln "Set battle bgm #{$Trainer.online_battle_bgm}"
                break
              else
                Kernel.pbMessageDisplay(msgwindow,_INTL("Pick the BGM you would like to hear in Online Battles. Press < and > to change BGM."),false)
              end
            end

            if Input.trigger?(Input::B)
              break
            end
          end
          pbBGMPlay(LOBBY_BGM,80)
          Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)
        when 2
          connection.send do |writer|
            writer.sym(:saveRental) #empty|fill
          end
          code = nil
          while (code == nil)

            Input.update
            Graphics.update
            self.update

            @connection.updateExp([:rentalCode]) do |record|
              case (type = record.sym)
              when :rentalCode
                code = record.str
                Kernel.pbMessageDisplay(msgwindow,_INTL("Your Rental code is: {1}\nCAREFUL! You won't see this again, so write it down!",code))
                Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)
              else
                raise "Unknown message: #{type}"
              end
            end
          end
        when 3
          code = pbEnterText(_INTL("Rental Team Code"),0,8)
          if code != nil && code != ""
            @connection.send do |writer|
              writer.sym(:getRental) 
              writer.str(code)
            end
            party = nil
            while (party == nil)
              Input.update
              Graphics.update
              self.update(false)

              @connection.updateExp([:found,:notFound]) do |record|
                case (type = record.sym)
                when :found
                  author = record.str
                  party = CableClub::parse_party(record)
                  
                  msgwindow.visible = true
                  Kernel.pbMessageDisplay(msgwindow, _INTL("Rental Team found!\nMade by: {1}\\^",author))
                  ch = -1
                  while (ch != 2 && ch != 1)
                    ch = Kernel.pbShowCommands(msgwindow,[_INTL("Show Team"), _INTL("Use Team"), _INTL("Leave")],2)
                    if ch == 0
                      sscene=PokemonScreen_Scene.new
                      sscreen=PokemonScreen.new(sscene,party)
                      pbFadeOutIn(99999) { 
                        hiddenmove=sscreen.pbPokemonScreen
                        if hiddenmove && !@scene.nil?
                          @scene.pbEndScene
                        end
                      }
                    elsif ch == 1
                      $Trainer.rentalTeamCode = code
                    end            
                  end
                  Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)
                when :notFound
                  Kernel.pbMessage(_INTL("No Rental Team found."))
                  party = -1
                else
                  raise "Unknown message: #{type}"
                end
              end
            end
          end
        when 4
          $Trainer.useRentalTeam = !$Trainer.useRentalTeam
          pbSave()
          settDetails[sett[selIndex]][:info] = _INTL("Using Rental Team: {1}", $Trainer.useRentalTeam ? _INTL("Yes") : _INTL("No"))
          Kernel.pbMessageDisplay(msgwindow,settDetails[sett[selIndex]][:info],false)
        else
        end
      end


      if Input.trigger?(Input::B)
        break
      end
    end
    
    for st in settsprites.keys
      settsprites[st].fade(0,20,:ease_in_cubic)
    end

    20.times do 
      for st in settsprites.keys
        settsprites[st].update
      end
      Graphics.update
      Input.update
      self.update(false)
    end

    #Dispose unused sprites
    pbDisposeSpriteHash(settsprites)

    20.times do
      for s in sprites
        @sprites[s].opacity+=opacities[sprites.index(s)]/20 + 1
      end
      Graphics.update
      Input.update
      self.update(false)
    end
  end

  def displayUI(state)
    @shownUI = state
    @sprites["refresh"].visible = state
    @sprites["list"].visible = state
    @sprites["avatarbox"].visible = state
    @sprites["avatar"].visible = state
    @sprites["avatarborder"].visible = state
    if (state && @sprites["selection"]==nil)
      self.createUI
    end
  end

  def createBattleTimer 
    @viewport3 = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport3.z = 1000000
    @counter = {}
    @counter["bg"] = Sprite.new(@viewport3)
    @counter["bg"].y = 160
    @counter["bg"].bitmap = Bitmap.new(200,24)
    @counter["bg"].bitmap.fill_rect(0,0,200,24,Color.new(0,0,0,120))
    @counter["bg"].visible = ENABLE_BATTLE_TIMER
    pbSetSmallFont(@counter["bg"].bitmap)
  end

  def updateTime(text)
    @counter["bg"].bitmap = Bitmap.new(200,24)
    @counter["bg"].bitmap.fill_rect(0,0,200,24,Color.new(0,0,0,120))
    pbSetSmallFont(@counter["bg"].bitmap)

    @counter["bg"].bitmap.draw_text(6,2,200,24,text)
  end

  def deleteBattleTimer
    @viewport3.dispose
    for sprite in @counter.values
      sprite.dispose if sprite.is_a?(Sprite)
    end
  end

  def toggleOpponentParty
    if !@toggleParty
      showParty
    else
      hideParty
    end
  end

  def createUI()
    @sprites["selection"] = Sprite.new(@viewport)
    @sprites["selection"].bitmap = Bitmap.new(298,23)
    @sprites["selection"].bitmap.fill_rect(0,0,298,23,Color.new(24,24,24,75))
    @sprites["selection"].x = 4 + @sprites["list"].x
    @sprites["selection"].y = 27+23*@selectionIndex + @sprites["list"].y
    @sprites["selection"].z = 4 #this has to be shown on top of others

    @sprites["status"] = Sprite.new(@viewport)
    @sprites["status"].bitmap = Bitmap.new(Graphics.width,30)
    #@sprites["status"].bitmap.fill_rect(0,0,300,30,Color.new(0,0,0,75))
    @sprites["status"].y = Graphics.height-30
    
    @sprites["partyBar"] = Sprite.new(@viewport2)
    @sprites["partyBar"].bitmap = Bitmap.new(Graphics.width,74)
    @sprites["partyBar"].bitmap.fill_rect(0,0,Graphics.width,74,Color.new(0,0,0,75))
    @sprites["partyBar"].z = 5
    @sprites["partyBar"].visible = false

    for i in 0...6
      @sprites["party#{i}"] = Sprite.new(@viewport2)
      @sprites["party#{i}"].x = 85*i
      @sprites["party#{i}"].z = 6
      @sprites["party#{i}"].visible = false
    end

    @sprites["battleButton"] = EAMSprite.new(@viewport)
    @sprites["battleButton"].bitmap = pbBitmap(@path + "battle").clone
    @sprites["battleButton"].x = 334
    @sprites["battleButton"].y = 196
    pbSetFont(@sprites["battleButton"].bitmap, "Barlow Condensed", 26)
    @sprites["battleButton"].bitmap.font.color=Color.new(24,24,24)
    @sprites["battleButton"].bitmap.draw_text(0,0,@sprites["battleButton"].bitmap.width,@sprites["battleButton"].bitmap.height,_INTL("Battle"),1)

    @sprites["tradeButton"] = EAMSprite.new(@viewport)
    @sprites["tradeButton"].bitmap = pbBitmap(@path + "trade").clone
    @sprites["tradeButton"].x = 334
    @sprites["tradeButton"].y = 238
    pbSetFont(@sprites["tradeButton"].bitmap, "Barlow Condensed", 26)
    @sprites["tradeButton"].bitmap.font.color=Color.new(24,24,24)
    @sprites["tradeButton"].bitmap.draw_text(0,0,@sprites["tradeButton"].bitmap.width,@sprites["tradeButton"].bitmap.height,_INTL("Trade"),1)

    @sprites["settingsButton"] = EAMSprite.new(@viewport)
    @sprites["settingsButton"].bitmap = pbBitmap(@path + "settings").clone
    @sprites["settingsButton"].x = Graphics.width-@sprites["settingsButton"].bitmap.width
    @sprites["settingsButton"].y = 284
    pbSetFont(@sprites["settingsButton"].bitmap, "Barlow Condensed", 22)
    @sprites["settingsButton"].bitmap.font.color=Color.new(24,24,24)
    @sprites["settingsButton"].bitmap.draw_text(0,0,@sprites["settingsButton"].bitmap.width,@sprites["settingsButton"].bitmap.height,_INTL("Settings"),1)

    @sprites["leaveButton"] = EAMSprite.new(@viewport)
    @sprites["leaveButton"].bitmap = pbBitmap(@path + "leave").clone
    @sprites["leaveButton"].x = Graphics.width-@sprites["leaveButton"].bitmap.width
    @sprites["leaveButton"].y = 318
    pbSetFont(@sprites["leaveButton"].bitmap, "Barlow Condensed", 22)
    @sprites["leaveButton"].bitmap.font.bold = true
    @sprites["leaveButton"].bitmap.font.color=Color.new(244,244,244)
    @sprites["leaveButton"].bitmap.draw_text(0, 0, @sprites["leaveButton"].bitmap.width, @sprites["leaveButton"].bitmap.height, _INTL("Leave"), 1)


    @buttons = [@sprites["avatarbox"],@sprites["battleButton"],@sprites["tradeButton"],@sprites["settingsButton"],@sprites["leaveButton"]]

    for b in @buttons
      b.fade(200,FADE_TIME,:ease_out_cubic)
    end

    @sprites["header"] = EAMSprite.new(@viewport)
    @sprites["header"].bitmap = pbBitmap(@path+"Header")
    @sprites["header"].z = 22
    @sprites["header"].y = -70
    @sprites["headerText"] = EAMSprite.new(@viewport)
    @sprites["headerText"].bitmap = Bitmap.new(Graphics.width,30)
    @sprites["headerText"].z = 23
    @sprites["headerText"].y = -70+14
    pbSetFont(@sprites["headerText"].bitmap, "Power Clear", 28)

    @sprites["headerLines"] = EAMSprite.new(@viewport)
    @sprites["headerLines"].bitmap = pbBitmap(@path + "HeaderLines")
    @sprites["headerLines"].opacity = 128
    @sprites["headerLines"].y = -70+12
    @sprites["headerLines"].z = 24
    pbBGMPlay(LOBBY_BGM)
  end

  def updateServerMessage(text)
    echoln "Server message: #{text}"    
    if @lastServerMessage == "" && text != "" #appear
      echoln "The server message should slide down"
      @sprites["header"].move(0,0,40,:ease_out_cubic)
      #@sprites["headerText"].moveY(14,40,:ease_out_cubic)
      #@sprites["headerLines"].move(0,12,40,:ease_out_cubic)
    elsif @lastServerMessage != "" && text == "" #disappear
      echoln "The server message should slide up"
      @sprites["header"].move(0,-70,40,:ease_in_cubic)
      #@sprites["headerText"].moveY(-70+14,40,:ease_in_cubic)
      #@sprites["headerLines"].move(0,-70+12,40,:ease_in_cubic)
    end
    if @lastServerMessage != text
      echoln "Updating message!"

      @sprites["headerText"].bitmap = Bitmap.new(11*text.length,30)
      pbSetFont(@sprites["headerText"].bitmap, "Power Clear", $MKXP ? 23 : 25) #should be 31 to be pixel perfect but too bad
      @sprites["headerText"].bitmap.font.color=Color.new(235, 134, 33)
      @sprites["headerText"].bitmap.draw_text(0,0,@sprites["headerText"].bitmap.width,@sprites["headerText"].bitmap.height,text,0)
      #place it out of sight
      @sprites["headerText"].x = Graphics.width
      @sprites["headerText"].moveX(-@sprites["headerText"].bitmap.width,HEADER_SPEED + HEADER_TEXT_SPEED*text.length)
      @lastServerMessage = text
    end
  end

  def setButtonSelection(state)
    @buttonSelectionEnabled = state
    if state
      @buttonSelectionIndex = 1
      for i in 0...@buttons.length
        if i != @buttonSelectionIndex
          @buttons[i].fade(128,FADE_TIME,:ease_out_cubic) 
        else
          @buttons[i].fade(255,FADE_TIME,:ease_out_cubic) 
        end
      end
    else
      for b in @buttons
        b.fade(200,FADE_TIME,:ease_out_cubic)
      end
    end
  end

  def buttonSelection(amount)
    #0: Battle 1: Trade 2: Settings 3: Leave
    old_id = @buttonSelectionIndex
    @buttonSelectionIndex+=amount
    if @buttonSelectionIndex >= @buttons.length
      @buttonSelectionIndex = 0
    end
    if @buttonSelectionIndex < 0
      @buttonSelectionIndex = @buttons.length-1
    end

    @buttons[old_id].fade(128,FADE_TIME,:ease_out_cubic) if old_id < @buttons.length
    @buttons[@buttonSelectionIndex].fade(255,FADE_TIME,:ease_out_cubic) if @buttonSelectionIndex < @buttons.length

  end

  def selectPartyOnline(party,opp_party)
    partySelector = OnlinePartySelection.new(party,opp_party)
  end

  # don't care about showing or not
  def updateParty(party)
    for i in 0...party.length
      poke = party[i]
      @sprites["party#{i}"].bitmap = evaluateIcon(poke)
    end
  end

  def displayParty(party)
    for i in 0...6
      @sprites["party#{i}"].visible =false
    end
    @toggleParty = true
    @sprites["partyBar"].visible = true
    for i in 0...party.length
      poke = party[i]
      
      @sprites["party#{i}"].bitmap = evaluateIcon(poke)
      @sprites["party#{i}"].visible = true
    end
  end

  def hideParty    
    @sprites["partyBar"].visible = false
    for i in 0...6
      @sprites["party#{i}"].visible = false
    end
    @toggleParty = false
  end

  def showParty
    @sprites["partyBar"].visible = true
    for i in 0...6
      @sprites["party#{i}"].visible = true
    end
    @toggleParty = true
  end

  def updateStatus(text)
    @sprites["status"].bitmap.clear()
    @sprites["status"].bitmap.fill_rect(0,0,Graphics.width,30,Color.new(0,0,0,75))
    pbSetFont(@sprites["status"].bitmap, "Barlow Condensed", 24)
    @sprites["status"].bitmap.draw_text(6,0,Graphics.width,30,text)
  end

  def pbDisplayAvaiblePlayerList(list,moveselector = false)
    # Updating the list every time it gets updated on screen
    if list != @playerlist
      @playerList = list
    end

    
    moveSelector(0) if moveselector
    # Disposing of old sprites
    @sprites["list"].bitmap = pbBitmap(@path + "playerlist").clone
    pbSetFont(@sprites["list"].bitmap,"Barlow Condensed",22)
    textpos = [
      ["ID",12,4,0,Color.new(232,232,232)],
      [_INTL("Name"),102,4,0,Color.new(232,232,232)],
      [_INTL("Status"),244,4,0,Color.new(232,232,232)],
    ]
    imagepos = []
    for entry in @playerList
      if @playerList.index(entry) < @listOffset
        next
      end
      if @playerList.index(entry)+1-@listOffset > MAX_VISIBLE_PLAYERS
        break
      end
      y = 4+23*(@playerList.index(entry)+1-@listOffset)
      icony = 31+23*(@playerList.index(entry)-@listOffset)
      textpos.push(["#{"%05d" % entry[0]}",70,y,1,Color.new(22,22,22)])
      textpos.push(["#{entry[1]}",102,y,0,Color.new(22,22,22)])

      ballimage=@path + entry[3].to_s
      imagepos.push([ballimage,256,icony,0,0,-1,-1])
      #@sprites["list"].bitmap.draw_text(6,6+30*list.index(entry),250,30,"#{"%05d" % entry[0]}:#{entry[1]}-#{entry[3]}")
    end
    pbDrawTextPositions(@sprites["list"].bitmap,textpos)
    pbDrawImagePositions(@sprites["list"].bitmap,imagepos)
  end

  def disableSelector
    @sprites["selection"].visible = false
  end

  def enableSelector
    @sprites["selection"].visible = true
  end

  def moveSelector(amount)
    return if @playerList.length == 0 #No player online
    @selectionIndex+=amount
    if @selectionIndex-@listOffset>=MAX_VISIBLE_PLAYERS && amount > 0
      @listOffset+=amount
      pbDisplayAvaiblePlayerList(@playerList)
    elsif @selectionIndex < @listOffset
      @listOffset+=amount
      pbDisplayAvaiblePlayerList(@playerList)
    end


    if (@selectionIndex>=@playerList.length)
      if @selectionIndex>=MAX_VISIBLE_PLAYERS && amount > 0
        @listOffset=0
        pbDisplayAvaiblePlayerList(@playerList)
      end
      @selectionIndex = 0
    elsif (@selectionIndex < 0)
      @selectionIndex = @playerList.length - 1
      if @selectionIndex>=MAX_VISIBLE_PLAYERS
        @listOffset=@playerList.length - MAX_VISIBLE_PLAYERS
        pbDisplayAvaiblePlayerList(@playerList)
      else
        @listOffset=0
        pbDisplayAvaiblePlayerList(@playerList)
      end
    end

    echoln "MOVED SELECTION TO #{@selectionIndex} => OFFSET #{@listOffset}"
  end

  def pbAvatarSelectionScreen(msgwindow)

    special = {
      :KAY2 => "Kay",
      :ALICE2 => "Alice",
      :CAPOPALESTRA_ERBA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Alisso"),
      :CAPOPALESTRA_FOLLETTO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Mimosa"),
      :EVANCAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Claudio"),
      :ALEXANDRACAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Verbena"),
      :MAURICE => pbGetMessageFromHash(MessageTypes::TrainerNames,"Maurice"),
      :SILVIA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Silvia"),
      :RUBENCAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Crisante"),
      :SERGENTEDONNA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Tamara"),
      :WALLACECAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Wallace Daddy"),
      :TEAMDIMENSIONF => pbGetMessageFromHash(MessageTypes::TrainerNames,"T3S"),
      :SERGENTI_TEAMDIMENSION2 => pbGetMessageFromHash(MessageTypes::TrainerNames,"A & B"),
      :SURGECAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Surge"),
      :HENNECAPO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Henné"),
      :GENGARCIRCO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Gengar"),
      :WILLTOURNAMENT => pbGetMessageFromHash(MessageTypes::TrainerNames,"Will"),
      :ALTERTREY => pbGetMessageFromHash(MessageTypes::TrainerNames,"Trey"),
      :RIVALE => pbGetMessageFromHash(MessageTypes::TrainerNames,"Trey"),
      :RUTA2 => pbGetMessageFromHash(MessageTypes::TrainerNames,"Ruta"),
      :FINALSAUL => pbGetMessageFromHash(MessageTypes::TrainerNames,"Saul"),
      :MUNHALLOWEEN => "Mun",
      :MINHALLOWEEN => "Min",
      :DARKKAYTRISHOUT => "Alter",
      :DARKALICETRISHOUT => "Alter",
      :GENERALEVICTOR => "Victor",
      :GOLD => "Gold",
      :CHUA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Chua"),
      :CASTALIA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Castalia"),
      :PEYOTE => pbGetMessageFromHash(MessageTypes::TrainerNames,"Peyote"),
      :OLEANDRO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Oleandro"),
      :ASTER => pbGetMessageFromHash(MessageTypes::TrainerNames,"Aster"),
      :TARASSACO => pbGetMessageFromHash(MessageTypes::TrainerNames,"Tarassaco"),
      :FINALMAMMA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Edera"),
      :VAKUM => "Vakuum",
      :VERSIL => "Versil",
      :TAMARAFURIA => pbGetMessageFromHash(MessageTypes::TrainerNames,"Tamara"),
      :LANCETOURNAMENT => "Lance",
      :LEOTOURNAMENT => "Leo",
      :ERIKATOURNAMENT => "Erika",
      :DANTETOURNAMENT => "Dante",
      :SERGENTESIGMA => "S",
      :STELLATOURNAMENT => pbGetMessageFromHash(MessageTypes::TrainerNames,"Stella"),
      :SOTISTOURNAMENT => pbGetMessageFromHash(MessageTypes::TrainerNames,"Sotis"),
      :GLADIONTOURNAMENT => pbGetMessageFromHash(MessageTypes::TrainerNames,"Iridio"),
      :GRETATOURNAMENT => pbGetMessageFromHash(MessageTypes::TrainerNames,"Valentina"),
    }


    sprites = {}
    sprites['bg'] = Sprite.new(@viewport)
    sprites['bg'].bitmap = pbBitmap(@path + "BG")
    #sprites['bg'].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    #sprites['bg'].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,LIGHTBLUE)
    sprites['bg'].z = 120
    sprites['bg'].visible = false
    

    sprites["animbg"]=AnimatedPlane.new(@viewport)
    sprites["animbg"].bitmap=pbBitmap(@path + "repeatbg")
    sprites["animbg"].z = 120
    sprites["animbg"].visible = false

    oldz = msgwindow.z
    msgwindow.z = 999999
    msgwindow.visible = false

    
    currentSelectedAvatar = 0
    selectedAvatar = 0
    availableAvatars = CableClub.getOnlineTrainerTypeList()

    id = getConst(PBTrainers,availableAvatars[selectedAvatar].is_a?(Array) ? availableAvatars[selectedAvatar][$Trainer.gender] : availableAvatars[selectedAvatar])

    if special.keys.include?(availableAvatars[selectedAvatar])
      name = pbGetMessageFromHash(MessageTypes::TrainerNames,special[availableAvatars[selectedAvatar]])
    end
    bmp = nil
    if pbResolveBitmap(sprintf("Graphics/Transitions/smTrainer%d",id)) != nil
      bmp = pbBitmap(sprintf("Graphics/Transitions/smTrainer%d",id))
    elsif pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",id)) != nil
      bmp = pbBitmap(sprintf("Graphics/Transitions/smSpecial%d",id))
    elsif checkIfNewTransition(id,true)#pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id)) != nil
      variant = getNewTransitionVariant(id)
      bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id))
    end

    sprites['avatar'] = Sprite.new(@viewport)
    sprites['avatar'].z = 121
    sprites['avatar'].visible = false
    sprites['avatar'].bitmap = bmp if bmp != nil
    sprites['avatar'].ox = sprites['avatar'].bitmap.width/2 if bmp != nil
    sprites['avatar'].x = Graphics.width/2

    sprites['name'] = Sprite.new(@viewport)
    sprites['name'].z = 121
    sprites['name'].visible = false
    sprites['name'].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    sprites['name'].bitmap.clear
    pbSetFont(sprites['name'].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",40)
    if special.keys.include?(availableAvatars[selectedAvatar])
      textpos = [
        [name,495,30,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true],
      ]
      pbDrawTextPositions(sprites['name'].bitmap,textpos)
      tt=PBTrainers.getName(id)
      pbSetFont(sprites['name'].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",20)
      textpos = [
        [tt,495,75,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true]
      ]
      pbDrawTextPositions(sprites['name'].bitmap,textpos)
    else
      
      tt=PBTrainers.getName(id)
      textpos = [
        [tt,495,30,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true],
      ]
      pbDrawTextPositions(sprites['name'].bitmap,textpos)
    end


    sprites['avatareffect'] = EAMSprite.new(@viewport)
    sprites['avatareffect'].z = 120
    sprites['avatareffect'].visible = false
    sprites['avatareffect'].bitmap = bmp if bmp != nil
    sprites['avatareffect'].ox = sprites['avatareffect'].bitmap.width/2 if bmp != nil
    sprites['avatareffect'].x = Graphics.width/3
    sprites['avatareffect'].y = -100
    sprites['avatareffect'].zoom_x = 2
    sprites['avatareffect'].zoom_y = 2
    sprites['avatareffect'].tone = Tone.new(-255,108,128,255)
    sprites['avatareffect'].opacity = 180
    sprites['avatareffect'].fade(0,40)
    sprites['avatareffect'].moveX(Graphics.width/4,80,:ease_out_cubic)


    sprites['pick'] = Sprite.new(@viewport)
    sprites['pick'].z = 122
    sprites['pick'].visible = false
    sprites['pick'].bitmap = pbBitmap(@path + "pickavatar").clone
    pbSetFont(sprites['pick'].bitmap,"Barlow Condensed",20)
    sprites['pick'].bitmap.draw_text(0,-2,sprites['pick'].bitmap.width,sprites['pick'].bitmap.height,_INTL("Pick your avatar"),1)

    sprites["avatarbar"] = Sprite.new(@viewport)
    sprites["avatarbar"].z = 122
    sprites["avatarbar"].visible = false
    sprites["avatarbar"].bitmap=pbBitmap(@path + "avatar_lower_bar")
    sprites["avatarbar"].ox = sprites["avatarbar"].bitmap.width/2
    sprites["avatarbar"].oy = sprites["avatarbar"].bitmap.height
    sprites["avatarbar"].x = Graphics.width/2
    sprites["avatarbar"].y = Graphics.height

    sprites["redarrow"] = Sprite.new(@viewport)
    sprites["redarrow"].z = 123
    sprites["redarrow"].bitmap=pbBitmap(@path + "avatar_red_arrow")
    sprites["redarrow"].visible = false
    sprites["redarrow"].ox = sprites["redarrow"].bitmap.width/2
    sprites["redarrow"].oy = sprites["redarrow"].bitmap.height
    sprites["redarrow"].x = Graphics.width/2
    sprites["redarrow"].y = Graphics.height

    sprites["sidearrows"] = Sprite.new(@viewport)
    sprites["sidearrows"].z = 123
    sprites["sidearrows"].bitmap=pbBitmap(@path + "side_arrows")
    sprites["sidearrows"].ox = sprites["sidearrows"].bitmap.width/2
    sprites["sidearrows"].x = Graphics.width/2
    sprites["sidearrows"].y = 327

    for i in 0...5
      sprites["trainerIcon#{i}"] = Sprite.new(@viewport)
      sprites["trainerIcon#{i}"].z = 122
      tid = currentSelectedAvatar+i-2
      if tid >= availableAvatars.length
        tid = tid-availableAvatars.length
      end
      if pbResolveBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}")
        
        sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}").clone #TODO: Change with actual avatar
        
        sprites["trainerIcon#{i}"].x = 117 + 69*i
        sprites["trainerIcon#{i}"].y = 343
      else
        sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/Lance").clone
        
        sprites["trainerIcon#{i}"].x = 118 + 69*i
        sprites["trainerIcon#{i}"].y = 344
      end
      sprites["trainerIcon#{i}"].ox = sprites["trainerIcon#{i}"].bitmap.width/2
      sprites["trainerIcon#{i}"].oy = sprites["trainerIcon#{i}"].bitmap.height/2
      sprites["trainerIcon#{i}"].visible = false
    end

    pbFadeOutIn(999999){
      sprites['bg'].visible = true
      sprites['avatar'].visible = true
      sprites['avatareffect'].visible = true
      sprites["animbg"].visible = true
      sprites["avatarbar"].visible = true
      sprites["redarrow"].visible = true
      for i in 0...5
        sprites["trainerIcon#{i}"].visible = true
      end
      sprites['name'].visible = true
      sprites['pick'].visible = true

    }

    loop do
      Graphics.update
      Input.update
      self.update(false)
      sprites["animbg"].oy += 0.5
      sprites["animbg"].ox += 0.5
      sprites['avatareffect'].update
      if selectedAvatar != currentSelectedAvatar
        
        selectedAvatar = currentSelectedAvatar
        id = getConst(PBTrainers,availableAvatars[selectedAvatar].is_a?(Array) ? availableAvatars[selectedAvatar][$Trainer.gender] : availableAvatars[selectedAvatar])

        if special.keys.include?(availableAvatars[selectedAvatar])
          name = pbGetMessageFromHash(MessageTypes::TrainerNames,special[availableAvatars[selectedAvatar]])
        end
        bmp = nil
        if pbResolveBitmap(sprintf("Graphics/Transitions/smTrainer%d",id)) != nil
          bmp = pbBitmap(sprintf("Graphics/Transitions/smTrainer%d",id))
        elsif pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",id)) != nil
          bmp = pbBitmap(sprintf("Graphics/Transitions/smSpecial%d",id))
        elsif checkIfNewTransition(id,true)#pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id)) != nil
          variant = getNewTransitionVariant(id)
          bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id))
        end

        
        sprites['name'].bitmap.clear
        if special.keys.include?(availableAvatars[selectedAvatar])
          pbSetFont(sprites['name'].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",40)
          textpos = [
            [name,495,30,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true],
          ]
          pbDrawTextPositions(sprites['name'].bitmap,textpos)
          tt=PBTrainers.getName(id)
          pbSetFont(sprites['name'].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",20)
          textpos = [
            [tt,495,75,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true]
          ]
          pbDrawTextPositions(sprites['name'].bitmap,textpos)
        else
          pbSetFont(sprites['name'].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",30)
          tt=PBTrainers.getName(id)
          textpos = [
            [tt,495,30,1,Color.new(232,232,232),Color.new(24, 24, 24, 20),true],
          ]
          pbDrawTextPositions(sprites['name'].bitmap,textpos)
        end

        sprites['avatar'].bitmap = bmp if bmp != nil
        sprites['avatareffect'].bitmap = bmp if bmp != nil
        sprites['avatareffect'].x = Graphics.width/3
        
        sprites['avatareffect'].opacity = 180
        sprites['avatareffect'].fade(0,40)
        sprites['avatareffect'].moveX(Graphics.width/4,80,:ease_out_cubic)
        echoln "Updated to selectedAvatar #{selectedAvatar}"
      end


      if Input.trigger?(Input::RIGHT)
        currentSelectedAvatar+=1
        echoln "Updated currentSelectedAvatar #{currentSelectedAvatar}"
        if (currentSelectedAvatar>=availableAvatars.length)
          currentSelectedAvatar=0
        end
        
        for i in 0...5
          tid = currentSelectedAvatar+i-2
          if tid >= availableAvatars.length
            tid = tid-availableAvatars.length
          end
          if pbResolveBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}")
            sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}").clone #TODO: Change with actual avatar
            
            sprites["trainerIcon#{i}"].x = 117 + 69*i
            sprites["trainerIcon#{i}"].y = 343
          else
            sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/Lance").clone
            
            sprites["trainerIcon#{i}"].x = 118 + 69*i
            sprites["trainerIcon#{i}"].y = 344
          end
        end
      end

      if Input.trigger?(Input::LEFT)
        currentSelectedAvatar-=1
        echoln "Updated currentSelectedAvatar #{currentSelectedAvatar}"
        if (currentSelectedAvatar<0)
          currentSelectedAvatar=availableAvatars.length-1
        end
        
        for i in 0...5
          tid = currentSelectedAvatar+i-2
          if tid >= availableAvatars.length
            tid = tid-availableAvatars.length
          end
          if pbResolveBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}")
            sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/minor_icon#{getConst(PBTrainers,availableAvatars[tid])}").clone #TODO: Change with actual avatar
                
            sprites["trainerIcon#{i}"].x = 117 + 69*i
            sprites["trainerIcon#{i}"].y = 343
          else
            sprites["trainerIcon#{i}"].bitmap = pbBitmap(@path + "Avatars/Lance").clone
            
            sprites["trainerIcon#{i}"].x = 118 + 69*i
            sprites["trainerIcon#{i}"].y = 344
          end
        end
      end

      if Input.trigger?(Input::C)
        if selectedAvatar != currentSelectedAvatar
        
          selectedAvatar = currentSelectedAvatar
          id = getConst(PBTrainers,availableAvatars[selectedAvatar].is_a?(Array) ? availableAvatars[selectedAvatar][$Trainer.gender] : availableAvatars[selectedAvatar])
  
          bmp = nil
          if pbResolveBitmap(sprintf("Graphics/Transitions/smTrainer%d",id)) != nil
            bmp = pbBitmap(sprintf("Graphics/Transitions/smTrainer%d",id))
          elsif pbResolveBitmap(sprintf("Graphics/Transitions/smSpecial%d",id)) != nil
            bmp = pbBitmap(sprintf("Graphics/Transitions/smSpecial%d",id))
          elsif checkIfNewTransition(id,true)#pbResolveBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id)) != nil
            variant = getNewTransitionVariant(id)
            bmp = pbBitmap(sprintf("Graphics/Transitions/SunMoon/%s%d",variant,id))
          end
  
          sprites['avatar'].bitmap = bmp if bmp != nil
          sprites['avatareffect'].bitmap = bmp if bmp != nil
          echoln "Updated to selectedAvatar #{selectedAvatar}"
        end
        if special.keys.include?(availableAvatars[selectedAvatar])
          trainername = pbGetMessageFromHash(MessageTypes::TrainerNames,special[availableAvatars[selectedAvatar]])
          msg = _INTL("Would you like to look like {1}?",trainername)
        else
          trainername = PBTrainers.getName(id)
          if ['a','e','i','o','u'].include?(trainername[0,1].downcase)
            msg=_INTL("Would you like to look like an {1}?",trainername)
          else
            msg=_INTL("Would you like to look like a {1}?",trainername)
          end
        end
        msgwindow.visible = true
        Kernel.pbMessageDisplay(msgwindow,msg)
        if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
          #accept, thus change the avatar
          $Trainer.online_trainer_type=id
          if pbResolveBitmap(@path + "Avatars/major_icon#{id}")
            @sprites["avatar"].bitmap = pbBitmap(@path + "Avatars/major_icon#{id}").clone
          else
            if bmp != nil
              resbmp = Bitmap.new(bmp.width/2,bmp.height/2)
              resbmp.stretch_blt(Rect.new(0,0,bmp.width/2,bmp.height/2),bmp,Rect.new(0,0,bmp.width,bmp.height))
              @sprites["avatar"].bitmap = resbmp
              @sprites["avatar"].bitmap = @sprites["avatar"].bitmap.mask!(@path+"avatarbox",0,@sprites["avatar"].bitmap.height/6)
            end
          end
          break
        end
        
        msgwindow.visible = false
      end

      if Input.trigger?(Input::B)
        msgwindow.visible = true
        Kernel.pbMessageDisplay(msgwindow,_INTL("Would you like to go back?"))
        if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
          break
        end
        
        msgwindow.visible = false
      end
    end

    msgwindow.z = oldz
    pbFadeOutIn(999999) { 
      Graphics.update;
      Input.update;
      sprites['bg'].visible = false
      sprites['avatar'].visible = false
      sprites['avatareffect'].visible = false
      sprites["animbg"].visible = false
      sprites["avatarbar"].visible = false
      sprites["redarrow"].visible = false
      for i in 0...5
        sprites["trainerIcon#{i}"].visible = false
      end
      sprites['name'].visible = false
      sprites['pick'].visible = false
     }
    
    pbDisposeSpriteHash(sprites)
  end

	def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
    	if pokemon.isEgg?
			bmp = "Graphics/Pictures/DexNew/Icon/Egg"
			bitmap = pbBitmap(bmp).clone
			return bitmap
		end
		bmp =""
		bmp += "Graphics/Pictures/DexNew/Icon/#{pokemon.species}"
		if pokemon.gender==1 && pbResolveBitmap(bmp+"f")
			bmp+="f"
		end
		if pokemon.form>0
			if pokemon.isDelta?
				bmp+="d"
			else
				bmp+="_#{pokemon.form}"
			end
		end
    if pokemon.isDelta?
      bmp+="d"
    end
		bitmap = pbBitmap(bmp).clone
		if pokemon.isShiny?#item>0
			bitmap.blt(0,0,pbBitmap(BOX_PATH + "shiny"),Rect.new(0,0,31,29))
		end
		return bitmap
	end

  # This is supposed to be called with Input.update and Graphics.update inside a loop,
  # so no need to add those here
  def update(refresh = true)
    return if !@shownUI

    #updating the selection bar position
    @sprites["selection"].y = 27+23*(@selectionIndex-@listOffset) + @sprites["list"].y

    for button in @buttons
      button.update
    end

    @sprites["header"].update
    @sprites["headerText"].update
    @sprites["headerText"].y = @sprites["header"].y + 8
    @sprites["headerLines"].y = @sprites["header"].y + 12

    if @sprites["headerText"].x == -@sprites["headerText"].bitmap.width
      @sprites["headerText"].x = Graphics.width
      @sprites["headerText"].moveX(-@sprites["headerText"].bitmap.width,HEADER_SPEED + HEADER_TEXT_SPEED*@lastServerMessage.length)
    end

    @sprites["refresh"].opacity = @canRefresh ? 255 : 128 if refresh

    @sprites["animbg"].oy += 0.5
    @sprites["animbg"].ox += 0.5
  end


  def dispose
    #self.endScene
    @viewport.dispose
    for sprite in @sprites.values
      sprite.dispose if sprite.is_a?(Sprite)
    end
    Graphics.frame_rate = 40
  end
end

def pbCheckOpenProcess(processname)
  status = `tasklist | find "#{processname}"`
  if status.empty?
    #echoln "Process #{processname} is not running"
    return false
  else
    echoln "Process #{processname} is running"
    return true
  end
end

def pbCheckForCE(connection)
end

class OnlinePartySelection
  attr_accessor(:selected)

  def result
    return @selected
  end

  def initialize(player, party, opponent_name, opp_party, max_selectable,min_selectable,cancancel = true,validProc = nil)
    @playername = player.name
    @party = party
    @enemyname = opponent_name
    @enemyparty = opp_party
    @max_select = max_selectable
    @min_select = min_selectable
    @cancancel = cancancel

    @selectionIndex = 0

    @annot=[]
    @statuses=[]
    ordinals=[
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH")
    ]

    @selected = []

    addedEntry=false
    
    for i in 0...@party.length
      if validProc != nil && validProc.call(@party[i])
        @statuses[i]=1
      else
        @statuses[i]=2
      end
    end
    for i in 0...@party.length
      @annot[i]=ordinals[@statuses[i]]
    end

    oldfr = Graphics.frame_rate
    Graphics.frame_rate = 60
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 1000000
    @sprites = {}
    @path = "Graphics/Pictures/Online/"
    @selpath = @path + "Selection/"
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].z = 50
    @sprites["bg"].bitmap = pbBitmap(@path + "BG")

    @sprites["anibg"] = AnimatedPlane.new(@viewport)
    @sprites["anibg"].z = 51
    @sprites["anibg"].bitmap=pbBitmap(@path + "repeatbg")

    @sprites["todo"] = EAMSprite.new(@viewport)
    @sprites["todo"].z = 52
    @sprites["todo"].bitmap = pbBitmap(@selpath + "pickLabel")    
    pbSetFont(@sprites["todo"].bitmap,"Barlow Condensed",18)
    pbDrawTextPositions(@sprites["todo"].bitmap,[[_INTL("Pick your Pokémons."),4,0,0,Color.new(243,243,243)]])

    @sprites["lowerbar"] = EAMSprite.new(@viewport)
    @sprites["lowerbar"].z = 55
    @sprites["lowerbar"].bitmap = pbBitmap("Graphics/Pictures/PartyNew/LowerBanner").clone
		@sprites["lowerbar"].y = Graphics.height-(@sprites["lowerbar"].bitmap.height-2)
    pbSetFont(@sprites["lowerbar"].bitmap,"Barlow Condensed",$MKXP ? 23 : 25)
    @sprites["lowerbar"].bitmap.blt(200-34,0,pbBitmap("Graphics/Pictures/PartyNew/ConfirmButton"),Rect.new(0,0,34,34))

    @sprites["lowerbar"].bitmap.font.bold = true
		pbDrawTextPositions(@sprites["lowerbar"].bitmap,[[_INTL("Confirm"),200-38,2,1,Color.new(248,248,248)],
        [_INTL("Close"),464,2,1,@cancancel ? Color.new(248,248,248) : Color.new(128,128,128)],
				[_INTL("Select"),332,2,1,Color.new(248,248,248)]])
        
    #end -110, start 0
    @sprites["playerbox"] = EAMSprite.new(@viewport)
    @sprites["playerbox"].z = 52
    @sprites["playerbox"].bitmap = pbBitmap(@selpath + "playerBox").clone
    @sprites["playerbox"].x = -110
    @sprites["playerbox"].y = 21
    pbSetFont(@sprites["playerbox"].bitmap,"Barlow Condensed",18)
    @sprites["playerbox"].bitmap.font.color = Color.new(10,10,10)
    pbDrawTextPositions(@sprites["playerbox"].bitmap,[[@playername,396,1,1,Color.new(10,10,10)]])

    @sprites["selectionCount"] = EAMSprite.new(@viewport)
    @sprites["selectionCount"].z = 53
    @sprites["selectionCount"].x = @sprites["playerbox"].x + 144
    @sprites["selectionCount"].y = @sprites["playerbox"].y + 16
    @sprites["selectionCount"].bitmap = Bitmap.new(300,50)
    pbSetFont(@sprites["selectionCount"].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",20)
    pbDrawTextPositions(@sprites["selectionCount"].bitmap,[["0/#{@max_select}",300,1,1,Color.new(44,180,247)]])
    @sprites["playerbox"].addChild(@sprites["selectionCount"])

    #end Graphhics.width, start 110
    @sprites["enemybox"] = EAMSprite.new(@viewport)
    @sprites["enemybox"].z = 52
    @sprites["enemybox"].bitmap = pbBitmap(@selpath + "enemyBox").clone
    @sprites["enemybox"].ox = @sprites["enemybox"].bitmap.width
    @sprites["enemybox"].x = Graphics.width
    @sprites["enemybox"].y = 6

    @sprites["f5b"] = EAMSprite.new(@viewport)
    @sprites["f5b"].z = 53
    @sprites["f5b"].bitmap = pbBitmap(@selpath + "f5open").clone
    @sprites["f5b"].x = 366
    @sprites["f5b"].y = 333
    @sprites["enemybox"].addChild(@sprites["f5b"])


    @sprites["enemyname"] = EAMSprite.new(@viewport)
    @sprites["enemyname"].z = 57
    @sprites["enemyname"].bitmap = Bitmap.new(166,30)
    @sprites["enemyname"].x = @sprites["enemybox"].x - 200
    @sprites["enemyname"].y = @sprites["enemybox"].y + 11
    pbSetFont(@sprites["enemyname"].bitmap,"Barlow Condensed",18)
    @sprites["enemyname"].bitmap.font.color = Color.new(10,10,10)
    pbDrawTextPositions(@sprites["enemyname"].bitmap,[[@enemyname,108,6,2,Color.new(10,10,10)]])

    @sprites["enemybox"].addChild(@sprites["enemyname"])

    @sprites["enemyball"] = EAMSprite.new(@viewport)
    @sprites["enemyball"].z = 53
    @sprites["enemyball"].bitmap = pbBitmap(@selpath + "ball")
    @sprites["enemyball"].ox = @sprites["enemyball"].bitmap.width/2
    @sprites["enemyball"].oy = @sprites["enemyball"].bitmap.height/2
    @sprites["enemyball"].x = 486
    @sprites["enemyball"].y = 41

    @sprites["enemybox"].addChild(@sprites["enemyball"])

    @sprites["selector"]= EAMSprite.new(@viewport)
    @sprites["selector"].z = 52
    @sprites["selector"].bitmap = pbBitmap(@selpath + "Selector")


    buildParties(@party,@enemyparty)

    @toggleEnemyparty = false;
    
    if @toggleEnemyparty
      @sprites["enemybox"].moveX(Graphics.width,1,:ease_out_cubic)
      @sprites["enemyname"].fade(255,1,:ease_out_cubic)
      @sprites["playerbox"].moveX(-110,1,:ease_out_cubic)
      @sprites["enemyball"].rotate(720,1,:ease_out_cubic)
    else
      @sprites["enemybox"].moveX(Graphics.width+110,1,:ease_out_cubic)
      @sprites["enemyname"].fade(0,1,:ease_out_cubic)
      @sprites["playerbox"].moveX(0,1,:ease_out_cubic)
      @sprites["enemyball"].rotate(0,1,:ease_out_cubic)
    end
    @sprites["f5b"].bitmap = pbBitmap(@selpath + "f5close").clone
    moveParties(@toggleEnemyparty,1)
    @toggleEnemyparty = !@toggleEnemyparty
    1.times do 
      Graphics.update
      update()
    end


    self.run()
    #Close selection and return the results
    
    Graphics.frame_rate = oldfr
  end

  def commandsUpdate
		@frameskip +=1
		@frame+=1 if @frameskip ==1
		@frameskip = 0 if @frameskip == 2
		@frame = 0 if @frame>=@framecount
		for i in 0...@size
			@cmds["cmd#{i}"].update if defined?(@cmds["cmd#{i}"].update)
		end
		
		@actualBitmap.clear# = Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height)
		#@actualBitmap.fill_rect(0,0,30,30,Color.new(255,0,0))#debug
		@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(@pokemonBitmap.height*@frame,0,@pokemonBitmap.height,@pokemonBitmap.height))
		#@actualBitmap = @actualBitmap.clone
		@actualBitmap.add_outline(Color.new(248,248,248),1) if !$MKXP
		@cmds["sprite"].bitmap = @actualBitmap if @cmds["sprite"] && @actualBitmap
		if $MKXP 
			@cmds["sprite"].add_outline(Color.new(248,248,248),@frame)
			#@cmds["sprite"].create_outline(Color.new(248,248,248),1)
		end
	end
	
	def updateCmds
		for i in 0...@size
			@cmds["cmd#{i}"].fade(175,10) if @index != i
			@cmds["cmd#{i}"].fade(255,10) if @index == i
		end
	end

  def fadeOut(hash,frames=20)
		r= 255
		frames.times do
			Graphics.update
      update
			commandsUpdate
			r-=255/(frames-1)
			for value in hash.values
				value.opacity = r
			end
		end
	end
	
	def fadeIn(hash,frames=20)
		r=0
		frames.times do
			Graphics.update
			commandsUpdate
			r+=255/(frames-1)
			for value in hash.values
				value.opacity = r if !value.is_a?(EAMSprite)
				
			end
		end
	end

  def pbShowCommands(helptext,commands,y=nil,index=0,pkmn=nil,x=0)
		ret=-1
		return ret if pkmn==nil
		@cmds={}
    @frameskip = 0
    @frame = 0
		@cmds["bg"]=Sprite.new(@viewport)
		@cmds["bg"].bitmap = pbBitmap("Graphics/Pictures/PartyNew/gradient")
		@cmds["bg"].y = 384-292
		@cmds["bg"].z = 140
		if !pkmn.isEgg?
			last = ""
			if pkmn.isDelta?
				last = "d"
			else
				last = (pkmn.form>0 ? "_#{pkmn.form}" : "")
			end
			add=""
			add = "Female/" if pkmn.gender==1 && pbResolveBitmap("Graphics/Battlers/Front/Female/"+sprintf("%03d",pkmn.species)+last)
			@pokemonBitmap = pbBitmap((pkmn.isShiny? ? "Graphics/Battlers/FrontShiny/" : "Graphics/Battlers/Front/")+add+sprintf("%03d",pkmn.species) + last )
			@frameskip = 0
			@frame = 0
			@framecount = @pokemonBitmap.width/@pokemonBitmap.height
			echoln (pkmn.isShiny? ? "Graphics/Battlers/FrontShiny/" : "Graphics/Battlers/Front/")+add+sprintf("%03d",pkmn.species) + last 
			@actualBitmap = Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height)
			@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(0,@pokemonBitmap.height*@frame,@pokemonBitmap.height,@pokemonBitmap.height+2))
			#@actualBitmap = @actualBitmap.clone
			#@actualBitmap.fill_rect(0,0,30,30,Color.new(255,0,0))
			if !$MKXP
				@actualBitmap.add_outline(Color.new(248,248,248),1)
			end
		else
			@frameskip = 0
			@frame = 0
			@framecount = 1
			@pokemonBitmap = pbBitmap("Graphics/Battlers/egg")
			@actualBitmap = Bitmap.new(@pokemonBitmap.height,@pokemonBitmap.height)
			@actualBitmap.blt(0,0,@pokemonBitmap,Rect.new(0,0,@pokemonBitmap.height,@pokemonBitmap.height+2))
			@actualBitmap.add_outline(Color.new(248,248,248),1) if !$MKXP
		end
		@cmds["sprite"]=Sprite.new(@viewport)
		@cmds["sprite"].bitmap = @actualBitmap# @pokemonBitmap.clone
		if $MKXP 
			@cmds["sprite"].add_outline(Color.new(248,248,248),@frame)
			#@cmds["sprite"].create_outline(Color.new(248,248,248),1)
		end
    	#@cmds["sprite"].create_outline(Color.new(248,248,248),1)
		#@cmds["sprite"].bitmap.add_outline(Color.new(248,248,248),1)
		@cmds["sprite"].ox = @pokemonBitmap.height/2
		@cmds["sprite"].z = 141
		@cmds["sprite"].oy = pbGetSpriteBase(@pokemonBitmap)+1
		#@cmds["sprite"].src_rect = Rect.new(0,@pokemonBitmap.height*@frame,@pokemonBitmap.height,@pokemonBitmap.height+2)
		@cmds["sprite"].zoom_x = 2
		@cmds["sprite"].zoom_y = 2
		if pkmn.isEgg?
			@cmds["sprite"].zoom_x = 1
			@cmds["sprite"].zoom_y = 1
		end
		@cmds["sprite"].x = 111
		@cmds["sprite"].y = 331#331
		
		@buttonBitmap = pbBitmap("Graphics/Pictures/PartyNew/Button")
		
		@cmds["overlay"] = Sprite.new(@viewport)
		@cmds["overlay"].z = 142
		@cmds["overlay"].bitmap = Bitmap.new(512,384)
		@cmds["overlay"].bitmap.font.name = "Barlow Condensed"
		@cmds["overlay"].bitmap.font.bold = true
		@cmds["overlay"].bitmap.font.size = $MKXP ? 23 : 25
		
		pbDrawTextPositions(@cmds["overlay"].bitmap,[[helptext,30,348,0,Color.new(248,248,248)]])
		@startY = 374-34*commands.length
		@index = 0
		@size = commands.length
		for i in 0...@size
			@cmds["cmd#{i}"] = EAMSprite.new(@viewport)
			if x==0
				@cmds["cmd#{i}"].bitmap = @buttonBitmap.clone
			else
				@cmds["cmd#{i}"].bitmap = Bitmap.new(@buttonBitmap.width+x*3,@buttonBitmap.height)
				@cmds["cmd#{i}"].bitmap.blt(0,0,@buttonBitmap,Rect.new(0,0,30,34))
				@cmds["cmd#{i}"].bitmap.blt(@cmds["cmd#{i}"].bitmap.width-30,0,@buttonBitmap,Rect.new(@cmds["cmd#{i}"].bitmap.width-30,0,30,34))
				@cmds["cmd#{i}"].bitmap.blt(30,0,@buttonBitmap,Rect.new(30,0,86,34))
				@cmds["cmd#{i}"].bitmap.blt(30+86,0,@buttonBitmap,Rect.new(30,0,x*3,34))
			end
			@cmds["cmd#{i}"].z = 142
			@cmds["cmd#{i}"].y = @startY+34*i
			@cmds["cmd#{i}"].x = 357  - (x>0 ? x*3 : 0)
			@cmds["cmd#{i}"].fade(175,10) if @index != i
			@cmds["cmd#{i}"].bitmap.font.name = "Barlow Condensed"
			@cmds["cmd#{i}"].bitmap.font.size = $MKXP ? 19 : 21
			@cmds["cmd#{i}"].bitmap.font.bold = true
			pbDrawTextPositions(@cmds["cmd#{i}"].bitmap,[[commands[i],@cmds["cmd#{i}"].bitmap.width/2,7,2,Color.new(18,54,83)]])
		end
		for s in @cmds.values
			s.opacity = 0
		end
		updateCmds
		fadeIn(@cmds,10)
		loop do
			Graphics.update
			Input.update
      update
			commandsUpdate
			
			if Input.trigger?(Input::DOWN)
				@index+=1
				if @index>=commands.length
					@index = 0
				end
				updateCmds
			elsif Input.trigger?(Input::UP)
				@index-=1
				if @index<0
					@index = commands.length-1
				end
				updateCmds
			end
			
			if Input.trigger?(Input::C)
				ret = @index
				fadeOut(@cmds,10)
				pbDisposeSpriteHash(@cmds)
				break
			end
			
			if Input.trigger?(Input::B)
				fadeOut(@cmds,10)
				pbDisposeSpriteHash(@cmds)
				break
			end
		end
		return ret
	end

  def buildParties(party,enemyparty)
    # Player Party first
    for i in 0...6
      next if i >= party.length || party[i]==nil
      @sprites["party#{i}"] = EAMSprite.new(@viewport)
      @sprites["party#{i}"].z = 53
      @sprites["party#{i}"].bitmap = pbBitmap(@selpath + "playerSlot").clone
      #now on to build the slot
      icon = evaluateIcon(party[i])
      @sprites["party#{i}"].x = i%2 == 0 ? 4 : 172
      @sprites["party#{i}"].y = 52 + 100*(i/2)

      @sprites["party#{i}"].bitmap.blt(0,0,icon,Rect.new(4,3,72,73))
      if party[i].hasItem?
        itemslot = pbBitmap(@selpath + "itemLabel").clone
        pbSetFont(itemslot,"Barlow Condensed",16)
        itemslot.draw_text(22,3,itemslot.width-24,itemslot.height-8,PBItems.getName(party[i].item),0)
        @sprites["party#{i}"].bitmap.blt(50,50,itemslot,Rect.new(0,0,itemslot.width,itemslot.height))
      end
    
      pbSetFont(@sprites["party#{i}"].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",16)
      textpos=[[party[i].name,70,18,0,Color.new(43,82,113)]]
      pbDrawTextPositions(@sprites["party#{i}"].bitmap,textpos)
      
      pbSetFont(@sprites["party#{i}"].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",13)
      textpos=[["Lv. #{party[i].level}",70,34,0,Color.new(43,82,113)]]
      #write hp here too
      pbDrawTextPositions(@sprites["party#{i}"].bitmap,textpos)

      if party[i].gender != 2
        gender = pbBitmap("Graphics/Pictures/PartyNew/#{party[i].gender == 0 ? "MALE" : "FEMALE"}").clone
        @sprites["party#{i}"].bitmap.stretch_blt(Rect.new(100 + "#{party[i].level}".length*4,36,gender.width/1.5,gender.height/1.5),gender,Rect.new(0,0,gender.width,gender.height))
      end

      if party[i].isShiny?
        gender = pbBitmap("Graphics/Pictures/SummaryNew/shiny").clone
        @sprites["party#{i}"].bitmap.stretch_blt(Rect.new(120 + "#{party[i].level}".length*4,36,gender.width/1.5,gender.height/1.5),gender,Rect.new(0,0,gender.width,gender.height))
      end

      if @statuses[i] != 2
        pbSetFont(@sprites["party#{i}"].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",10)
        textpos = [["#{party[i].hp}/#{party[i].totalhp}",34,76,2,Color.new(243,243,243)]]
        pbDrawTextPositions(@sprites["party#{i}"].bitmap,textpos)

        hpbarbg = pbBitmap(@selpath + "hpbarBg").clone
        @sprites["party#{i}"].bitmap.blt(55,77,hpbarbg, Rect.new(0,0,hpbarbg.width,hpbarbg.height))

        hpbar = pbBitmap(@selpath + "hpbar").clone
        hpwidth = party[i].hp.to_f/party[i].totalhp.to_f * hpbar.width
        @sprites["party#{i}"].bitmap.blt(57,79,hpbar, Rect.new(0,0,hpwidth.to_i,hpbar.height))
      else
        pbSetFont(@sprites["party#{i}"].bitmap,$MKXP ? "Kimberley" : "Kimberley Bl",14)
        textpos = [[@annot[i],84,74,2,Color.new(243,243,243)]]
        pbDrawTextPositions(@sprites["party#{i}"].bitmap,textpos)
      end

      @sprites["status#{i}"] = EAMSprite.new(@viewport)
      @sprites["status#{i}"].z = 54
      @sprites["status#{i}"].x = 18 + 166 * (i%2)
      @sprites["status#{i}"].y = 60 + 102 * (i/2)
      @sprites["status#{i}"].ox = 13
      @sprites["status#{i}"].oy = 13 
      @sprites["status#{i}"].visible = false
      @sprites["party#{i}"].addChild(@sprites["status#{i}"])
    end

    for i in 0...6
      next if i >= enemyparty.length || enemyparty[i]==nil
      @sprites["enemyparty#{i}"] = EAMSprite.new(@viewport)
      @sprites["enemyparty#{i}"].z = 53
      @sprites["enemyparty#{i}"].bitmap = pbBitmap(@selpath + "enemySlot").clone
      icon = evaluateIcon(enemyparty[i])
      @sprites["enemyparty#{i}"].bitmap.blt(0,1,icon,Rect.new(0,0,72,73))
      @sprites["enemyparty#{i}"].x = 363 + (i%2 == 1 ? 70 : 0)
      @sprites["enemyparty#{i}"].y = 55 + 42*i%2 + 86 * i/2
      @sprites["enemybox"].addChild(@sprites["enemyparty#{i}"])
    end

  end

  def moveParties(togglestate,frames = 20)
    for i in 0...6
      if !togglestate
        
        @sprites["party#{i}"].moveX(i%2==0 ? 34 : 242,frames,:ease_out_cubic) if @sprites.keys.include?("party#{i}")
        @sprites["enemyparty#{i}"].fade(0,frames-4 < 1? 1 : frames-4) if @sprites.keys.include?("enemyparty#{i}")
      else
        @sprites["party#{i}"].moveX(i%2==0 ? 4 : 172,20,:ease_out_cubic) if @sprites.keys.include?("party#{i}")
        @sprites["enemyparty#{i}"].fade(255,frames-4 < 1? 1 : frames-4) if @sprites.keys.include?("enemyparty#{i}")
      end
    end
    if !togglestate
      @sprites["f5b"].bitmap = pbBitmap(@selpath + "f5close").clone
      @sprites["selector"].moveX(33 + (@selectionIndex % 2 == 1 ? 208 : 0),frames,:ease_out_cubic)
    else      
      @sprites["f5b"].bitmap = pbBitmap(@selpath + "f5open").clone
      @sprites["selector"].moveX(3 + (@selectionIndex % 2 == 1 ? 168 : 0),frames,:ease_out_cubic)
    end
  end

  def evaluateIcon(pokemon)
		bitmap = Bitmap.new(75,74)
    	if pokemon.isEgg?
			bmp = "Graphics/Pictures/DexNew/Icon/Egg"
			bitmap = pbBitmap(bmp).clone
			return bitmap
		end
		bmp =""
		bmp += "Graphics/Pictures/DexNew/Icon/#{pokemon.species}"
		if pokemon.gender==1 && pbResolveBitmap(bmp+"f")
			bmp+="f"
		end
		if pokemon.form>0
			if pokemon.isDelta?
				bmp+="d"
			else
				bmp+="_#{pokemon.form}"
			end
		end
    if pokemon.isDelta?
      bmp+="d"
    end
		bitmap = pbBitmap(bmp).clone
		#if pokemon.isShiny?#item>0
	  #	 bitmap.blt(40,0,pbBitmap(BOX_PATH + "shiny"),Rect.new(0,0,31,29))
		#end
		return bitmap
	end

  def run()
    loop do
      Graphics.update
      Input.update
      self.update

      if Input.trigger?(Input::F5)
        if @toggleEnemyparty
          @sprites["enemybox"].moveX(Graphics.width,20,:ease_out_cubic)
          @sprites["enemyname"].fade(255,20,:ease_out_cubic)
          @sprites["playerbox"].moveX(-110,20,:ease_out_cubic)
          @sprites["enemyball"].rotate(720,20,:ease_out_cubic)
        else
          @sprites["enemybox"].moveX(Graphics.width+110,20,:ease_out_cubic)
          @sprites["enemyname"].fade(0,20,:ease_out_cubic)
          @sprites["playerbox"].moveX(0,20,:ease_out_cubic)
          @sprites["enemyball"].rotate(0,20,:ease_out_cubic)
        end
        moveParties(@toggleEnemyparty)
        @toggleEnemyparty = !@toggleEnemyparty
      end

      if Input.trigger?(Input::C)
        cmdEntry=-1
        cmdNoEntry=-1
        cmdSummary=-1
        commands=[]
        if (@statuses[@selectionIndex] || 0) == 1
          commands[cmdEntry=commands.length]=_INTL("Entry")
        elsif (@statuses[@selectionIndex] || 0) > 2
          commands[cmdNoEntry=commands.length]=_INTL("No Entry")
        end
        pkmn=@party[@selectionIndex]
        commands[cmdSummary=commands.length]=_INTL("Info")
        commands[commands.length]=_INTL("Chiudi")
        ret = pbShowCommands(_INTL("Che fare con {1}?",pkmn.name),commands,0,@selectionIndex,pkmn)
        next if ret == -1 #canceled
        if cmdEntry>=0 && ret==cmdEntry
          if @selected.length>=@max_select && @max_select>0
            pbDisplay(_INTL("No more than {1} Pokémon may enter.",@max_select))
          else
            #@statuses[pkmnid]=realorder.length+3
            @selected << pkmn
            addedEntry=true
          end
        elsif cmdNoEntry>=0 && ret==cmdNoEntry
          #@statuses[pkmnid]=1
          @selected.delete(pkmn)
        elsif cmdSummary>=0 && ret==cmdSummary
          oldsprites=pbFadeOutAndHide(@sprites)
          scene=PokemonSummaryScene.new
          screen=PokemonSummary.new(scene)
          screen.pbStartScreen(@party,@selectionIndex)
          pbFadeInAndShow(@sprites,oldsprites)
        end

        updateStatuses()
      end

      if Input.trigger?(Input::RIGHT)
        baseid = @selectionIndex/2
        if @selectionIndex % 2 == 0 #even
          @selectionIndex+=1
          @selectionIndex-=1 if @selectionIndex >= @party.length
        else
          @selectionIndex-=1
        end
      end

      if Input.trigger?(Input::DOWN)
        startid = @selectionIndex
        @selectionIndex += 2
        echoln "#{@selectionIndex}"
        echoln "#{@selectionIndex >= @party.length && startid != @party.length-1 && @party.length % 2 == 1}"
        echoln "#{@selectionIndex >= @party.length} && #{startid != @party.length-1} && #{@party.length % 2 == 1}"
        if @selectionIndex >= @party.length
          if startid != @party.length-1 && @party.length % 2 == 1
            @selectionIndex = @party.length-1
          else
            @selectionIndex = 0 + startid % 2
          end
        end
      end

      if Input.trigger?(Input::UP)
        startid = @selectionIndex
        @selectionIndex -= 2
        if @selectionIndex < 0
          if startid == 0 
            pos = [4,2,0]
            while pos.length > 1
              if pos.max<@party.length
                break
              else
                pos.delete(pos.max)
              end
            end
            @selectionIndex = pos.first
          else
            pos = [5,3,1]
            while pos.length > 1
              if pos.max<@party.length
                break
              else
                pos.delete(pos.max)
              end
            end
            @selectionIndex = pos.first
          end
        end
      end

      if Input.trigger?(Input::LEFT)
        baseid = @selectionIndex/2
        if @selectionIndex % 2 == 0 #even
          @selectionIndex+=1
          @selectionIndex-=1 if @selectionIndex >= @party.length
        else
          @selectionIndex-=1
        end
      end

      if Input.trigger?(Input::A)
        if @selected.length < @min_select
          pbDisplay(_INTL("Devi scegliere almeno {1} Pokémon.",@min_select))
          next
        end
        msgwindow = Kernel.pbCreateMessageWindow()
        msgwindow.z = 1000000

        Kernel.pbMessageDisplay(msgwindow,_INTL("Are you sure?"),false)
        if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
          msgwindow.visible = false
          Kernel.pbDisposeMessageWindow(msgwindow)
          break
        end
        msgwindow.visible = false
        Kernel.pbDisposeMessageWindow(msgwindow)
      end


      if Input.trigger?(Input::B) && @cancancel
        @selected = -1
        break
      end
    end
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end

  def pbDisplay(message)    
    msgwindow = Kernel.pbCreateMessageWindow()
    msgwindow.z = 1000000

    Kernel.pbMessageDisplay(msgwindow,message)
    msgwindow.visible = false
    Kernel.pbDisposeMessageWindow(msgwindow)
  end

  def updateStatuses()
    for i in 0...6
      if @selected.include?(@party[i])
        @statuses[i] = 3 #selected
      else
        @statuses[i] = @statuses[i] == 3 ? 1 : @statuses[i]
      end
    end
    #after statuses update
    for i in 0...6 
      if @sprites.keys.include?("status#{i}")
        if @selected.include?(@party[i])
          echoln "#{@party[i].name} #{@selpath}#{@selected.index(@party[i])}"
          @sprites["status#{i}"].bitmap = pbBitmap(@selpath + "#{@selected.index(@party[i])+1}")
          @sprites["status#{i}"].visible = true
        else
          @sprites["status#{i}"].visible = false
        end
      end
    end

    @sprites["selectionCount"].bitmap.clear
    pbDrawTextPositions(@sprites["selectionCount"].bitmap,[["#{@selected.length}/#{@max_select}",300,1,1,Color.new(44,180,247)]])
  end

  def update
    
    @sprites["selector"].x = @toggleEnemyparty ? 33 + (@selectionIndex % 2 == 1 ? 208 : 0) : 3 + (@selectionIndex % 2 == 1 ? 168 : 0)
    @sprites["selector"].y = 60 + 100*(@selectionIndex/2)

    @sprites["anibg"].oy += 0.5
    @sprites["anibg"].ox += 0.5



    for s in @sprites.values
      s.update
    end
  end

end

def pbTSC
  randparty = []
  randMons = [:LUCARIO,:SHIFTRY,:BLAZIKEN,:MAWILE,:LUXRAY,:ALAKAZAM]
  for i in 0...6
    randparty << pbGenerateWildPokemon(randMons[i],50)
  end
  scos = OnlinePartySelection.new($Trainer,$Trainer.party,"Red",randparty,3,1,true,proc{|x|
    return !([PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::SHYLEON].include?(x.species) && x.form == 0 && x.abilityIndex == 2)#x.species > 1050
  })
  echoln scos.result
end

class BattleRequest
  #weedleteam
  #@@url = "https://www.weedleteam.com/request.php"

  @@url = "http://xntst.altervista.org/BattleRequest.php"

  ### MAIN UTILITY METHODS HERE
  def self.makeRequest(type, data = {})
      data["type"] = type
      return pbPostData(@@url,data)
  end

  def self.requestGift(type, code, data = {})
      data["type"] = type
      data["code"] = code
      return pbPostData(@@url,data)
  end

  def self.exists(type, code, data={})
      data["type"] = type
      data["code"] = code
      return pbPostData(@@url,data)
  end
  
  ### SHORTHANDS
  def self.getPlayerList()
    data={}
    #data["beta"] = "CBT"
    data["type"] = "getPlayerList"
    res = pbPostData(@@url,data)
    playerlist = []
    for entry in res.split("\r\n")
      player = entry.split("</s>")
      player[-1] = player[-1].to_sym
      playerlist.push(player)
    end
    return playerlist
  end


end

def pbTOB
  roomno = rand(100000)
  res = BattleRequest.makeRequest("makeRoom",{"RoomNo"=>roomno})
  echoln res

  alive = true
  while(alive)
    #checks the room status every second. 
    pbWait(60)
    echoln BattleRequest.makeRequest("getDebug",{"RoomNo"=>roomno})

    if(Input.trigger?(Input::B))
      alive = false
    end
  end
end

def pbTO(roomno)
  alive = true
  while(alive)
    #checks the room status every second. 
    pbWait(60)
    echoln BattleRequest.makeRequest("getDebug",{"RoomNo"=>roomno})

    if(Input.trigger?(Input::B))
      alive = false
    end
  end
end

def pbOnlineLobby
  lobby = OnlineLobby.new
  #Da mettere nell'evento
  if $Trainer.party.length == 0
    Kernel.pbMessage(_INTL("I'm sorry, you must have a Pokémon to enter the Cable Club."))
    lobby.dispose
    return
  end

  if $Trainer.party.any? {|pokemon| pokemon.abilityOverride != nil }    
    Kernel.pbMessage(_INTL("I'm sorry, you have Pokémons not allowed in the Cable Club."))
    lobby.dispose
    return
  end
  
  #oldParty = $Trainer.party
  msgwindow = Kernel.pbCreateMessageWindow()
  msgwindow.z = 10000
  begin
    Kernel.pbMessageDisplay(msgwindow, _INTL("Starting connection..."),false)
    pbWait(5)
    partner_trainer_id = ""

    # HINT: Startup/Cleanup required for Khaikaa's v17 for some reason.
    begin
      wsadata = "\0" * 1024 # Hope this is big enough, I don't have a compiler to sizeof(WSADATA) on...
      res = Win32API.new("ws2_32", "WSAStartup", "IP", "I").call(0x0202, wsadata)
      case res
        #Actual connection
      when 0; CableClub::enlist(msgwindow,lobby)
      else; raise Connection::Disconnected.new("winsock error")
      end
    ensure
      Win32API.new("ws2_32", "WSACleanup", "", "").call()
    end
    raise Connection::Disconnected.new("disconnected")
  rescue Connection::Disconnected => e
    msgwindow.visible = true
    lobby.dispose
    
    #$Trainer.party = oldParty
    case e.message
    when "disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("Thank you for using the Dimensional Corridor. We hope to see you again soon."))
      return true
    when "invalid party"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, your party contains a Pokémon not allowed."))
      return false
    when "peer disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the other trainer has disconnected."))
      return true
    when "connection break"
      Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, the connection with the server was interrupted."))
      return false
    else
      Kernel.pbMessageDisplay(msgwindow, _INTL("An error has occurred! Aborting Dimensional projection..."))
      return false
    end
  rescue Errno::ECONNREFUSED
    Kernel.pbMessageDisplay(msgwindow, _INTL("You cannot access the Dimensional Corridor now. Try again later."))
    return false
  rescue
    pbPrintException($!)
    Kernel.pbMessageDisplay(msgwindow, _INTL("An error has occurred! Aborting Dimensional projection..."))
    return false
  ensure
    Kernel.pbDisposeMessageWindow(msgwindow)
    lobby.dispose
  end
  
end

########################################################################
# Online Features are down here
########################################################################

def isUberValid?(poke)
  banned = [PBSpecies::LUXFLON,PBSpecies::MEWTWOX,PBSpecies::DRAGALISK]
  if banned.include?(poke.species)
    return false
  end
  return true
end

def isStandardValid?(poke)
  banned = [PBSpecies::LUXFLON,PBSpecies::MEWTWOX,PBSpecies::DRAGALISK,
            PBSpecies::TAPUBULUX,PBSpecies::DARKRAI,PBSpecies::DEOXYS]
  if banned.include?(poke.species)
    return false
  end

  #Astro forms
  if [PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::SHYLEON].include?(poke.species)
    if poke.ability == 240 || poke.ability == 241 || poke.ability == 242
      return false
    end
  end


  return true
end

module CableClub
  HOST = "95.173.136.70" # for fun and profit
  PORT = 9999

  
  ONLINE_TRAINER_TYPE_LIST = [
    [:KAY2,:ALICE2],
   # [:POKEMONTRAINER_Red,:POKEMONTRAINER_Leaf],
   # [:PSYCHIC_M,:PSYCHIC_F],
   # [:BLACKBELT,:CRUSHGIRL],
   # [:COOLTRAINER_M,:COOLTRAINER_F]
  ]

  BATTLE_TIERS={
    :anythinggoes => Proc.new {|x| true},
    :ubers => Proc.new{|x| isUberValid?(x) && !RETRODEX.include?(x.species)},
    :standard => Proc.new{|x| isStandardValid?(x) && !RETRODEX.include?(x.species)},
    :retroonly => Proc.new {|x| RETRODEX.include?(x.species)},
  }

  BATTLE_TIERS_NAMES={
    :anythinggoes => _INTL("Anything Goes"),
    :ubers => _INTL("Uber"),
    :standard => _INTL("Standard"),
    :retroonly => _INTL("Retro Only")
  }

  BATTLE_TIERS_NUMBERS={
    :anythinggoes =>{
      :single => 6,
      :double => 4
    },
    :standard =>{
      :single => 6,
      :double => 4
    },
    :ubers =>{
      :single => 6,
      :double => 4
    },
    :retroonly =>{
      :single => 6,
      :double => 4
    },
  }

  def self.getOnlineTrainerTypeList()
    ret = []
    # Standard
    ret.push(:KAY2)
    ret.push(:ALICE2)
    ret.push(:CAPOPALESTRA_ERBA) if $game_switches[27]
    ret.push(:TEAMDIMENSION) if $game_switches[143]
    ret.push(:MERCANTEELDIW) if $game_switches[1026]
    ret.push(:RIVALE) if $game_switches[82]
    ret.push(:DARKALICETRISHOUT) if $game_switches[174]
    ret.push(:DARKKAYTRISHOUT) if $game_switches[174]
    ret.push(:CAPOPALESTRA_FOLLETTO) if $game_switches[169]
    ret.push(:EVANCAPO) if $game_switches[99]
    ret.push(:GENNARO) if $game_switches[523]
    ret.push(:MERCANTEALOLA) if $game_switches[1044]
    ret.push(:MUNHALLOWEEN) if $game_switches[1044]
    ret.push(:MINHALLOWEEN) if $game_switches[1044]
    ret.push(:ALEXANDRACAPO) if $game_switches[227]
    ret.push(:MAURICE) if $game_switches[236]
    ret.push(:SILVIA) if $game_switches[278]
    ret.push(:RUBENCAPO) if $game_switches[295]
    ret.push(:SERGENTEDONNA) if $game_switches[559]
    ret.push(:WALLACECAPO) if $game_switches[371]
    ret.push(:TEAMDIMENSIONF) if $game_switches[361]
    ret.push(:SERGENTI_TEAMDIMENSION2) if $game_switches[141]
    ret.push(:SURGECAPO) if $game_switches[459]
    ret.push(:HENNECAPO) if $game_switches[529]
    ret.push(:GENGARCIRCO) if $game_switches[1185]
    ret.push(:ALTERTREY) if $game_switches[545]
    ret.push(:SERGENTESIGMA) if $game_switches[558]
    ret.push(:GENERALEVICTOR) if $game_switches[575]
    ret.push(:GOLD) if $game_switches[619]
    ret.push(:RUTA2) if $game_switches[570]
    ret.push(:FINALSAUL) if $game_switches[573]
    ret.push(:CHUA) if $game_switches[858]
    ret.push(:CASTALIA) if $game_switches[859]
    ret.push(:PEYOTE) if $game_switches[860]
    ret.push(:OLEANDRO) if $game_switches[861]
    ret.push(:ASTER) if $game_switches[866]
    ret.push(:VERSIL) if $game_switches[627]
    ret.push(:TARASSACO) if $game_switches[796]
    ret.push(:FINALMAMMA) if $game_switches[800]
    ret.push(:TAMARAFURIA) if $game_switches[1178]
    ret.push(:LANCETOURNAMENT) if $game_switches[1182]
    ret.push(:ERIKATOURNAMENT) if $game_switches[1181]
    ret.push(:LEOTOURNAMENT) if $game_switches[1184]
    ret.push(:DANTETOURNAMENT) if $game_switches[1183]
    ret.push(:WILLTOURNAMENT) if $game_switches[247]
    ret.push(:VAKUM) if $game_switches[1330]
    ret.push(:STELLATOURNAMENT) if $game_switches[1344]
    ret.push(:SOTISTOURNAMENT) if $game_switches[1346]
    ret.push(:GLADIONTOURNAMENT) if $game_switches[1345]
    ret.push(:GRETATOURNAMENT) if $game_switches[1347]

    specialTrainers = CableClub.getSpecialTrainers($Trainer.uniqueSaveID)
    if specialTrainers.length > 0
      for s in specialTrainers
        ret << s
      end
    end
    return ret
  end

  def self.getSpecialTrainers(saveID)
    ret = []
    types = BattleRequest.makeRequest("getSpecialSkins",{"UID"=>saveID}).split("</s>")
    if types.length > 0
      for i in 0...types.length
        types[i] = types[i].to_sym
        ret << types[i]
      end
    end
    echoln types
    return ret
  end

  def self.getOnlineBattleBackList()
    ret=[]
    ret << "Online"
    ret << "alexandra" if $game_switches[227] 
    ret << "Apollo" if $game_switches[1185]
    ret << "Aster" if $game_switches[866]
    ret << "Beach" 
    ret << "Bosco"
    ret << "Bulu" if $game_switches[1270]
    ret << "Campus" if $game_switches[143]
    ret << "Canyon" if $game_switches[499]
    ret << "Cavern" 
    ret << "Circo" if $game_switches[529]
    ret << "CovoDimension" if $game_switches[555]
    ret << "Druddigon" if $game_switches[166]
    ret << "Elite" if $game_switches[858]
    ret << "Elite2" if $game_switches[859]
    ret << "Elite3" if $game_switches[860]
    ret << "Elite4" if $game_switches[861]
    ret << "Entei" if $game_switches[1067]
    ret << "FinalVakuum" if $game_switches[1330]
    ret << "Fini" if $game_switches[1214]
    ret << "Gola" if $game_switches[386]
    ret << "GoldNight" if $game_switches[619]
    ret << "Grottaghiacciolo"
    ret << "goldenstudio" if $game_switches[861]
    ret << "Koko" if $game_switches[1220]
    ret << "Lele" if $game_switches[1215]
    ret << "Meloetta" if $game_switches[782]
    ret << "MondoXenoverse" if $game_switches[861]
    ret << "Palestradaddy"
    ret << "palestraoasi" if $game_switches[227]
    ret << "Residence" if $game_switches[1178]
    ret << "Saloon" if $game_switches[861]
    ret << "Shinobi" if $game_switches[1006]
    ret << "Suicune" if $game_switches[1084]
    ret << "Teatro" if $game_switches[49]
    ret << "tempioshyleon" if $game_switches[565]
    ret << "Vakum" if $game_switches[1330]
    ret << "Westopoli" if $game_switches[295]
    ret << "Zodiacoalterato" if $game_switches[1296]
    return ret
  end

  def self.getOnlineBGMList()
    ret=[]
    ret << "OnlineVS"
    ret << "VS Surge"
    ret << "VS. Alter Trey"
    ret << "VS. Battle Fury"
    ret << "VS. Cani Leggendari"
    ret << "vs. dielebi"
    ret << "VS. Dragalisk Furia"
    ret << "VS. Dragalisk"
    ret << "VS. Ethan"
    ret << "VS. Gym Apollo"
    ret << "VS. Gym Leader"
    ret << "VS. Luxflon"
    ret << "VS. MarshadowMeloetta"
    ret << "VS. Sabolt"
    ret << "VS. Spettri"
    ret << "VS. Tamara Fury"
    ret << "VS. Team Dimension"
    ret << "VS. Tray"
    ret << "VS. Vakum"
    ret << "VS. Versil Dragalisk"
    ret << "VS. Versil"
    ret << "VS. Victor"
    ret << "VS. VIP"
    ret << "VS. XBoss"
    ret << "VS.Cardinali"
    ret << "VS.Champion"
    ret << "vs.Mimikyu"
    ret << "vs.Rivale"
    ret << "VS.RivaleAlt"
    ret << "VS.Trainer"
    ret << "VS.Vakum"
    ret << "VS-AB"
    return ret
  end
end

class PokeBattle_Trainer
  attr_accessor :rentalTeamCode
  attr_accessor :useRentalTeam

  def useRentalTeam
    if @useRentalTeam == nil
      return false
    end
    return @useRentalTeam
  end

  def rentalTeamCode
    return @rentalTeamCode || ""
  end

  attr_accessor :username
  def username
    return @name if @username == nil || @username.length < 1
    return @username
  end

  attr_writer :online_trainer_type
  def online_trainer_type
    return @online_trainer_type || getConst(PBTrainers,CableClub.getOnlineTrainerTypeList()[$Trainer.gender])#self.trainertype
  end

  attr_reader :uniqueSaveID
  def getSaveID(connection)
    if @uniqueSaveID == nil
      if connection.can_send?
        connection.send do |writer|
          writer.sym(:getSaveID)
        end
      end
      obtained = false
      loop do 
        Graphics.update
        Input.update
        break if obtained
        connection.updateExp([:saveID]) do |record|
          case (type = record.sym)
          when :saveID
            @uniqueSaveID = record.str
            obtained = true
            pbSave()
          end
        end
      end
    else
      if connection.can_send?
        connection.send do |writer|
          writer.sym(:setSaveID)
          writer.str($Trainer.uniqueSaveID)
        end
      end
      obtained = false
      loop do 
        Graphics.update
        Input.update
        break if obtained
        connection.updateExp([:saveID]) do |record|
          case (type = record.sym)
          when :saveID
            receivedID = record.str
            if receivedID != @uniqueSaveID
              @uniqueSaveID = receivedID
              pbSave()
            end
            obtained = true
          end
        end
      end
    end
  end

  attr_accessor :online_battle_bg
  def online_battle_bg
    return @online_battle_bg || "Online"
  end

  attr_accessor :online_battle_bgm
  def online_battle_bgm
    return @online_battle_bgm || "OnlineVS"
  end

  attr_accessor :backupParty
end

# TODO: Automatically timeout.

def pbGetTiersNames()
  ret = []
  for t in CableClub::BATTLE_TIERS.keys
    ret.push([CableClub::BATTLE_TIERS_NAMES[t],t])
  end
  ret.sort! {|x,y| x[0]<=>y[0]}
  return ret + [[_INTL("Cancel"),-1]]
end

# Returns false if an error occurred.
def pbCableClub
  if $Trainer.party.length == 0
    Kernel.pbMessage(_INTL("I'm sorry, you must have a Pokémon to enter the Cable Club."))
    return
  end
  msgwindow = Kernel.pbCreateMessageWindow()
  begin
    Kernel.pbMessageDisplay(msgwindow, _ISPRINTF("What's the ID of the trainer you're searching for? (Your ID: {1:05d})\\^",$Trainer.publicID($Trainer.id)))
    partner_trainer_id = ""
    loop do
      partner_trainer_id = Kernel.pbFreeText(msgwindow, partner_trainer_id, false, 5)
      return if partner_trainer_id.empty?
      break if partner_trainer_id =~ /^[0-9]{5}$/
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} is not a trainer ID.", partner_trainer_id))
    end
    # HINT: Startup/Cleanup required for Khaikaa's v17 for some reason.
    begin
      wsadata = "\0" * 1024 # Hope this is big enough, I don't have a compiler to sizeof(WSADATA) on...
      res = Win32API.new("ws2_32", "WSAStartup", "IP", "I").call(0x0202, wsadata)
      case res
      when 0; CableClub::connect_to(msgwindow, partner_trainer_id)
      else; raise Connection::Disconnected.new("winsock error")
      end
    ensure
      Win32API.new("ws2_32", "WSACleanup", "", "").call()
    end
    raise Connection::Disconnected.new("disconnected")
  rescue Connection::Disconnected => e
    case e.message
    when "disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("Thank you for using the Cable Club. We hope to see you again soon."))
      return true
    when "invalid party"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, your party contains Pokémon not allowed in the Cable Club."))
      return false
    when "peer disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the other trainer has disconnected."))
      return true
    else
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server has malfunctioned!"))
      return false
    end
  rescue Errno::ECONNREFUSED
    Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server is down at the moment."))
    return false
  rescue
    pbPrintException($!)
    Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club has malfunctioned!"))
    return false
  ensure
    Kernel.pbDisposeMessageWindow(msgwindow)
  end
end

module CableClub
  attr_accessor :timeoutCounter
  attr_reader   :maxTimeOut

  WINREWARD = [:BOTTLECAP,:GOLDBOTTLECAP,:ULTRARARECANDY,:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS,:PPMAX]

  def self.timeoutCounter
    @timeoutCounter = 0 if @timeoutCounter == nil
    return @timeoutCounter
  end

  def self.timeoutCounter=(value)
    @timeoutCounter = value
    return @timeoutCounter
  end

  def self.maxTimeOut
    return 300 if @maxTimeOut == nil
    return @maxTimeOut
  end

  def self.pokemon_order(client_id)
    case client_id
    when 0; [0, 1, 2, 3]
    when 1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.pokemon_target_order(client_id)
    case client_id
    when 0..1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.resetPartner()
    @partner_uid = ""
    @partner_id = -1
    @partner_name = nil
    @partner_party = nil
    @partner_battle_party = nil
  end

  def self.handle_await_server(connection,msgwindow)
    connection.updateExp([:connectionInfo]) do |record|
      case (type = record.sym)
      when :connectionInfo
        @uid = record.str
        @md5 = record.str
      end
    end
    if connection.can_send? && (@uid != nil && @md5 != nil)
      echoln "#{@uid} #{@md5}"
      connection.send do |writer|
        writer.sym(:enlist)
        writer.str($Trainer.username + ":#{@md5}:#{@uid}" )
        writer.int($Trainer.id)
        #writer.int($Trainer.online_trainer_type)
        write_party(writer)
      end   
      pbFadeOutIn(999999){
        @ui.displayUI(true)
        @ui.pbDisplayAvaiblePlayerList(getPlayerList)
      }

      $Trainer.getSaveID(connection)
      @state = :enlisted
    else
      pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\nConnecting to online server",$Trainer.publicID($Trainer.id)), @frame)
    end
  end

  def self.canRefreshPlayerList?()
    return @frame / 180 > 0
  end

  def self.getPlayerList()
    ret = BattleRequest.getPlayerList()
    toremove = nil
    for entry in ret
      toremove = entry if entry[2]==@uid
    end
    ret.delete(toremove)
    return ret
  end

  def self.handle_enlist(connection,msgwindow)
    ####### Input handling for enlisted state
    # In this kind of state we want to be able to go up and down the player list, and be able to refresh it.
    @ui.hideParty

    #echoln "Handling enlist! Can refresh player list? #{canRefreshPlayerList?()}"
    if Input.trigger?(Input::F5) && canRefreshPlayerList?()
      Kernel.pbMessage(_INTL("Refreshing player list..."))
      @ui.pbDisplayAvaiblePlayerList(getPlayerList())
      @frame = 0
    end

    if Input.trigger?(Input::UP)
      if @navigatingPlayerList
        @ui.moveSelector(-1)
      else
        @ui.buttonSelection(-1)
      end
      @ui.update
    end
    if Input.trigger?(Input::DOWN)
      if @navigatingPlayerList
        @ui.moveSelector(1)
      else
        @ui.buttonSelection(1)
      end
      @ui.update
    end

    if Input.trigger?(Input::RIGHT) && @navigatingPlayerList
      @navigatingPlayerList = false
      @ui.disableSelector
      @ui.setButtonSelection(true)
    end

    if Input.trigger?(Input::LEFT) && !@navigatingPlayerList
      @navigatingPlayerList = true
      @ui.enableSelector
      @ui.setButtonSelection(false)
    end



    #if Input.triggerex?(0x24)
    #  connection.send do |writer|
    #    writer.sym(:fwd)
    #    writer.str(@ui.playerList[@ui.selectionIndex][2])
    #    writer.sym(:message)
    #    writer.str(pbEnterText("Daje",0,50))
    #  end
    #  Kernel.pbMessage("Wow")
    #end

    if Input.trigger?(Input::C)
      if @navigatingPlayerList
        if @ui.playerList.length>0
          msgwindow.visible = true
          Kernel.pbMessageDisplay(msgwindow, _INTL("Do you want to start a connection with {1}?",@ui.playerList[@ui.selectionIndex][1]))
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            Kernel.pbMessageDisplay(msgwindow, _INTL("Would you like to send a message to {1}?",@ui.playerList[@ui.selectionIndex][1]))
            if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
              sendMessage = pbEnterText(_INTL("Message to send?"), 0, 50, _INTL("Ciao! Vuoi connetterti?"))
            else
              sendMessage = ""
            end
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@ui.playerList[@ui.selectionIndex][2])
              writer.sym(:askAcceptInteraction)
              writer.int($Trainer.id)
              writer.str($Trainer.username)
              writer.str(@uid)
              writer.str(sendMessage)
            end
            @client_id = 0
            @partner_uid = @ui.playerList[@ui.selectionIndex][2]
            @partner_name = @ui.playerList[@ui.selectionIndex][1]
            
            Kernel.pbMessageDisplay(msgwindow, _INTL("Your ID: {1}\nAsked {2} for interaction...",_ISPRINTF("{1:05d}", $Trainer.publicID($Trainer.id)),@partner_name),false)
            @state = :await_interaction_accept
            @timeoutCounter = 0
            return
          else
            msgwindow.visible = false
            pbWait(8)
          end
        else
          pbPlayBuzzerSE()
        end
      else
        case @ui.buttonSelectionIndex
        when 0 #Avatar
          msgwindow.visible = true
          Kernel.pbMessageDisplay(msgwindow, _INTL("Would you like to change your avatar?"))
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            # Requesting the list of available avatars
            @ui.pbAvatarSelectionScreen(msgwindow)
          end
          msgwindow.visible = false
        when 1 #Battle matchmaking
          msgwindow.visible = true
          Kernel.pbMessageDisplay(msgwindow, _INTL("Would you like to enter unranked matchmaking?"),false)
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            # Send unranked matchmaking info
            Kernel.pbMessageDisplay(msgwindow, _INTL("What kind of battle would you like to take part in?"))
            command = Kernel.pbShowCommands(msgwindow, [_INTL("Single Battle"), _INTL("Double Battle"), _INTL("No")], 2)
            if command != 2
              @battle_type = case command
              when 0; :single
              when 1; :double
              else; raise "Unknown battle type"
              end
              @rentalParty = nil
              @chosenTier = chooseTier(connection,msgwindow,@battle_type,nil)

              if (@chosenTier == nil)
                msgwindow.visible = false
                return
              end

              connection.send do |writer|
                writer.sym(:searchUnranked)
                writer.sym(@battle_type)
                writer.sym(@chosenTier)
              end
              @cancancelSelection = false
              @battleTeam = nil
              @state=:unrankedMatchmaking
              Kernel.pbMessageDisplay(msgwindow, _INTL("Matchmaking..."),false)
              return
            else
              msgwindow.visible = false
            end
          else
            Kernel.pbMessageDisplay(msgwindow, _INTL("Skipped connection."))
          end
          msgwindow.visible = false
        when 2 #wonder trade matchmaking

          connection.send do |writer|
            writer.sym(:wtStatus) #empty|fill
          end
          @state = :await_wt_info
        when 3 # settings
          @ui.openSettings(msgwindow)
          msgwindow.visible = false
          return
        when 4 # leave
          msgwindow.visible = true
          message = case @state
            when :await_server; _INTL("Abort connection?\\^")
            when :await_partner; _INTL("Abort search?\\^")
            else; _INTL("Disconnect?\\^")
            end
          Kernel.pbMessageDisplay(msgwindow, message)
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0 
            @closeOnline = true
            return
          end
          msgwindow.visible = false
          return
        end
      end
    end

    handle_spectate(connection,@ui)

    ##################################################
    ## Standard handling for the remainder
    ##################################################


    #QUESTO È IL PROBLEMA
    #pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nEnlisted, waiting to join lobby",$Trainer.publicID($Trainer.id)), @frame)    

    #if (@frame%60 == 0) #Requesting player list every X seconds
      #@ui.pbDisplayAvaiblePlayerList(BattleRequest.getPlayerList())
    #end

    connection.updateExp([:found,:askAcceptInteraction,:message,:serverMessage]) do |record|
      case (type = record.sym)
      when :found
        @client_id = record.int
        @partner_name = record.str
        @partner_party = parse_party(record)
        Kernel.pbMessageDisplay(msgwindow, _INTL("{1} connected!", @partner_name))
        if @client_id == 0
          @state = :choose_activity
        else
          @state = :await_choose_activity
        end
      when :askAcceptInteraction
        id = record.int
        name = record.str
        uid = record.str
        greetmessage = record.str
        msgwindow.visible = true
        if greetmessage == ""
          greetmessage = _INTL("{1} asked for connection. Do you want to start the connection?\\^",name)
        else
          greetmessage = "#{name}: #{greetmessage}"
        end  
        Kernel.pbMessageDisplay(msgwindow, greetmessage)
        command = Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2)
        # Accepted
        if command == 0
          @partner_name = name
          @partner_id = id
          @partner_uid = uid
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:acceptInteraction)
              writer.str($Trainer.username)
              write_party(writer)
            end
          end
          @client_id = 1
          @state = :await_partner
        else

          Kernel.pbMessageDisplay(msgwindow, _INTL("Connection refused.\\^"))
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(uid)
              writer.sym(:cancel)
              writer.str(@uid)
            end
          end
          msgwindow.visible = false
        end
      when :serverMessage      
        @ui.updateServerMessage(record.str)
      when :message
        Kernel.pbMessage(record.str)
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_spectate(connection,ui)
  end

  def self.handle_await_wt_info(connection,msgwindow)
    #empty|fill
    connection.updateExp([:empty,:fill]) do |record|
      case(type=record.sym)
      when :fill
        traded = record.str
        if traded == "1" #traded
          partner_name = record.str
          partner_pkmn = parse_pkmn(record)
          your_pkmn = parse_pkmn(record)#$Trainer.party[@wtchosen]
          partner_speciesname = (partner_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,partner_pkmn.species))
          your_speciesname = (your_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,your_pkmn.species))
          # HERE THE ACTUAL TRADE IS BEING HANDLED          
          partner = PokeBattle_Trainer.new(partner_name, $Trainer.trainertype)
          do_wtrade(your_pkmn, partner, partner_pkmn) #trade scene
          
          @wtchosen=-1
          @state = :enlisted
        elsif traded == "0" #not traded
          #scemo chi legge
          
          msgwindow.visible = true
          Kernel.pbMessageDisplay(msgwindow, _INTL("Your Pokémon wasn't traded yet."))          
          msgwindow.visible = false
          @state = :enlisted
        else
          #casino incredibile assurdo
        end
      when :empty
        msgwindow.visible = true
        if $Trainer.party.length < 2
          Kernel.pbMessageDisplay(msgwindow, _INTL("Can't enter Wonder Trade with less than 2 Pokémon."))
        else
          Kernel.pbMessageDisplay(msgwindow, _INTL("Would you like to start a Wonder Trade?"))
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            valid = false
            while !valid
              @wtchosen = choose_pokemon
              if $Trainer.party[@wtchosen].isEgg?
                if $Trainer.party.any? { |p| p != $Trainer.party[@wtchosen] && p.hp > 0 && !p.isEgg?}
                  valid = true
                end
              end
              if $Trainer.party[@wtchosen].hp > 0 &&
                ![PBSpecies::SHYLEON,PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::DIELEBI,PBSpecies::SABOLT,PBSpecies::LUXFLON,PBSpecies::DRAGALISKFURIA].include?($Trainer.party[@wtchosen].species) && 
                ($Trainer.party[@wtchosen].item != nil ? ![PBItems::ANELLOT,PBItems::ANELLOX].include?($Trainer.party[@wtchosen].item) : true)
                valid = true
              end
              break if @wtchosen < 0
              
              if !valid
                msgwindow.visible = true
                Kernel.pbMessageDisplay(msgwindow, _INTL("You can't trade this Pokémon."))
                msgwindow.visible = false
              end
            end
            if @wtchosen >= 0
              connection.send do |writer|
                writer.sym(:wonderTrade)
                write_pkmn(writer,$Trainer.party[@wtchosen])
              end
              oldfriendwhodied = $Trainer.party[@wtchosen].name
              pbRemovePokemonAt(@wtchosen)
              pbSave()
              Kernel.pbMessageDisplay(msgwindow,_INTL("Bye, {1}!",oldfriendwhodied),true)
              msgwindow.visible = false
              @state = :enlisted
              return
            end
          else
          end
        end  
        msgwindow.visible = false
        @state = :enlisted
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_wonder_trading(connection,msgwindow)
    #pbMessageDisplayDots(msgwindow,_INTL("Wonder trading"),@frame)
    connection.updateExp([:wtFound]) do |record|
      case(type=record.sym)
      when :wtFound
        partner_name = record.str
        partner_pkmn = parse_pkmn(record)
        your_pkmn = $Trainer.party[@wtchosen]
        partner_speciesname = (partner_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,partner_pkmn.species))
        your_speciesname = (your_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,your_pkmn.species))
        # HERE THE ACTUAL TRADE IS BEING HANDLED          
        partner = PokeBattle_Trainer.new(partner_name, $Trainer.trainertype)
        do_trade(@wtchosen, partner, partner_pkmn) #trade scene
        
        @wtchosen=-1
        @state = :enlisted
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_unranked_matchmaking(connection,msgwindow)
    connection.updateExp([:foundOpponent,:trainerData]) do |record|
      case(type = record.sym)
      when :foundOpponent
        @partner_uid = record.str
        @client_id = record.int
        echoln "FOUND OPPONENT"
        if connection.can_send?
          connection.send do |writer|
            writer.sym(:fwd)
            writer.sym(@partner_uid)
            writer.sym(:trainerData)
            writer.str($Trainer.username)
            if $Trainer.useRentalTeam && $Trainer.rentalTeamCode != ""
              if (@rentalParty == nil)
                write_party(writer)
              else
                write_custom_party(@rentalParty, writer)
              end
            else
              write_party(writer)
            end
          end
        end
      when :trainerData
        @matchmaking = true
        @partner_name = record.str
        @partner_party = parse_party(record)
        @partner_battle_party = @partner_party
        #@ui.displayParty(@partner_party)
        msgwindow.visible = false          
        connection.send do |writer|
          writer.sym(:resetReady)
          writer.str(@partner_uid)
          writer.str(@uid)
        end
        connection.send do |writer|
          writer.sym(:clearRandom)
          writer.str(@client_id == 0 ? @uid + @partner_uid : @partner_uid + @uid)
        end
        
        msgwindow.visible = true
        Kernel.pbMessageDisplay(msgwindow,_INTL("Matched with {1}!",@partner_name))
        @state = :await_party_selection
      else
        raise "Unknown message: #{type}"
      end
    end

  end

  def self.handle_await_interaction_accept(connection,msgwindow)
    #pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nAsked X for interaction",$Trainer.publicID($Trainer.id)), @frame)
    #if (@frame%180 == 0) #Requesting player list every X seconds
    #  @ui.pbDisplayAvaiblePlayerList(self.getPlayerList())
    #end
    connection.updateExp([:acceptInteraction,:cancel,:partnerDisconnected],true) do |record|
      case (type = record.sym)
      when :acceptInteraction
        #@client_id = record.int
        @partner_name = record.str
        @partner_party = parse_party(record)
        @ui.displayParty(@partner_party)
        if connection.can_send?
          connection.send do |writer|
            writer.sym(:fwd)
            writer.sym(@partner_uid)
            writer.sym(:found)
            writer.str($Trainer.username)
            write_party(writer)
          end
        end
        @cancancelSelection = true
        Kernel.pbMessageDisplay(msgwindow, _INTL("{1} connected!", @partner_name))
        if @client_id == 0
          @state = :choose_activity
        else
          @state = :await_choose_activity
        end
      when :cancel
        if record.str == @partner_uid
          Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to interact.", @partner_name))
          @ui.hideParty
          @state = :enlisted
          resetPartner()
        end
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        raise "Unknown message: #{type}"
      end
    end
    if @timeoutCounter > @maxTimeOut
      Kernel.pbMessageDisplay(msgwindow, _INTL("The connection timed out."))
      @ui.hideParty
      @state = :enlisted
      resetPartner()
    end
  end

  def self.handle_await_partner(connection,msgwindow)
    pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\nSearching",$Trainer.publicID($Trainer.id)), @frame)
    connection.updateExp([:found,:partnerDisconnected],true) do |record|
      case (type = record.sym)
      when :found
        #@client_id = record.int
        @partner_name = record.str
        @partner_party = parse_party(record)
        @ui.displayParty(@partner_party)
        Kernel.pbMessageDisplay(msgwindow, _INTL("{1} connected!", @partner_name))
        @cancancelSelection = true
        if @client_id == 0
          @state = :choose_activity
        else
          Kernel.pbMessageDisplay(msgwindow,_INTL("Waiting for {1} to pick an activity...",@partner_name),false)
          @state = :await_choose_activity
        end
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_choose_activity(connection,msgwindow)
    Kernel.pbMessageDisplay(msgwindow, _INTL("Choose an activity.\\^"))
    command = Kernel.pbShowCommands(msgwindow, [_INTL("Single Battle"), _INTL("Double Battle"), _INTL("Trade")], -1)
    case command
    when 0..1 # Battle
      
      @battle_type = case command
      when 0; :single
      when 1; :double
      else; raise "Unknown battle type"
      end
      @rentalParty = nil
      @chosenTier = chooseTier(connection,msgwindow,@battle_type,@partner_party)

      if (@chosenTier == nil)
        return
      end
      @battleTeam = nil
      
      # QUESTI VANNO AL SERVER
      connection.send do |writer|
        writer.sym(:clearRandom)
        writer.str(@client_id == 0 ? @uid + @partner_uid : @partner_uid + @uid)
      end

      #Send battle request data
      
      connection.send do |writer|
        writer.sym(:fwd)
        writer.str(@partner_uid)
        writer.sym(:battle)
        @seed = rand(2**31)
        writer.int(@seed)
        writer.sym(@battle_type)
        writer.int($Trainer.online_trainer_type)
        writer.sym(@chosenTier)
        write_custom_party(@rentalParty == nil ? $Trainer.party : @rentalParty,writer)
      end
      @activity = :battle
      @state = :await_accept_activity

      when 2 # Trade
        connection.send do |writer|
          writer.sym(:fwd)
          writer.str(@partner_uid)
          writer.sym(:trade)
        end
        @activity = :trade
        @state = :await_accept_activity

      else # Cancel
        # TODO: Confirmation box?
        Kernel.pbMessageDisplay(msgwindow, _INTL("Would you like to disconnect?"))
        if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
          connection.send do |writer|
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:cancelInteraction)
          end
          @ui.hideParty
          @state = :enlisted
        end
        return
      end
  end

  def self.handle_await_accept_activity(connection,msgwindow)
    echoln "#{@state}: awaiting leader to choose activity"
    pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to accept", @partner_name), @frame)
    connection.updateExp([:ok,:invalidParty,:acceptTrade,:cancel,:leaveParty,:partnerDisconnected]) do |record|
      case (type = record.sym)
      when :ok #BATTLE ONLY
          #Kernel.pbDisposeMessageWindow(msgwindow)
        case @activity
        when :battle
          msgwindow.visible = false
          @partner_battle_party = parse_party(record)
          connection.send do |writer|
            writer.sym(:resetReady)
            writer.str(@partner_uid)
            writer.str(@uid)
          end
          #do_battle(connection, @client_id, @seed, @battle_type, partner, @partner_party,[@uid,@partner_uid])
          #msgwindow.visible = true
          @state = :await_party_selection
        else
          print "Unknown activity: #{@activity}"
        end
      when :invalidParty
        Kernel.pbMessageDisplay(msgwindow, _INTL("Sorry, looks like your opponent can't enter this Tier with the current team."))
        @state = :choose_activity
      when :acceptTrade #TRADE ONLY
        case @activity
        when :trade
          #@chosen = choose_pokemon          
          valid = false
          while !valid
            @chosen = choose_pokemon
            if $Trainer.party[@chosen].isEgg?
              if $Trainer.party.any? { |p| p != $Trainer.party[@chosen] && p.hp > 0 && !p.isEgg?}
                valid = true
              end
            end
            if $Trainer.party[@chosen].hp > 0 &&
              ![PBSpecies::SHYLEON,PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::DIELEBI,PBSpecies::SABOLT,PBSpecies::LUXFLON,PBSpecies::DRAGALISKFURIA].include?($Trainer.party[@chosen].species) && 
              ($Trainer.party[@chosen].item != nil ? ![PBItems::ANELLOT,PBItems::ANELLOX].include?($Trainer.party[@chosen].item) : true)
              valid = true
            end
            break if @chosen < 0
              
            if !valid
              msgwindow.visible = true
              Kernel.pbMessageDisplay(msgwindow, _INTL("You can't trade this Pokémon."))
              msgwindow.visible = false
            end
          end
          if @chosen >= 0
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:chosenPokemon)
              writer.int(@chosen)
            end
            @state = :await_trade_confirm
          else
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:cancel)
            end
            connection.discard(1)
            @state = :choose_activity
          end
        else
          print "Unknown activity: #{@activity}"
        end
      when :cancel
        Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to {2}.", @partner_name,@activity.to_s))
        @state = :choose_activity
      when :leaveParty
        # disconnect only if the partner who sent the disconnection is your current partner
        Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
        @state = :enlisted
        resetPartner()
        return
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        print "Unknown message: #{type}"
      end
    end
  end

  def self.handle_await_choose_activity(connection,msgwindow)
    #pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick an activity", @partner_name), @frame)
    connection.updateExp([:battle,:trade,:cancelInteraction,:partnerDisconnected]) do |record|
      case (type = record.sym)
      when :battle
        @seed = record.int
        @battle_type = record.sym
        trainertype = record.int
        @chosenTier = record.sym
        @partner_battle_party = parse_party(record)
        partner = PokeBattle_Trainer.new(@partner_name, trainertype)
        (partner.partyID=0) rescue nil # EBDX compat
        #rental team check for validity
        valid = true
        @rentalParty = nil
        partyToCheck = $Trainer.party
        #Retrieving Rental party info
        if $Trainer.useRentalTeam && $Trainer.rentalTeamCode != ""
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:getRental) 
              writer.str($Trainer.rentalTeamCode)
            end
            res = nil
            while (res == nil)
              Input.update
              Graphics.update
              connection.updateExp([:found,:notFound]) do |record|
                case (type = record.sym)
                when :found
                  author = record.str
                  res = parse_party(record)
                else
                  res = -1
                end
              end
            end
            if (res != nil && res != -1)
              partyToCheck = res
              @rentalParty = res
            end
          end
        end
        valid = checkValidity(msgwindow,false,@battle_type,@chosenTier,partyToCheck,nil)
        # Auto-reject double battles that we cannot participate in.
        if !valid
          connection.send do |writer|
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:invalidParty)
          end
          @state = :await_choose_activity
        elsif @battle_type == :double && partyToCheck.length < 2
          connection.send do |writer|
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:cancel)
          end
          @state = :await_choose_activity
        else
          Kernel.pbMessageDisplay(msgwindow, _INTL("{1} wants to battle at {2}!\\^", @partner_name, BATTLE_TIERS_NAMES[@chosenTier]))
          if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            msgwindow.visible = false #Kernel.pbDisposeMessageWindow(msgwindow)
            @battleTeam = nil
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:ok)
              write_custom_party(partyToCheck,writer)
            end
            # QUESTI VANNO AL SERVER
            connection.send do |writer|
              writer.sym(:clearRandom)
              writer.str(@client_id == 0 ? @uid + @partner_uid : @partner_uid + @uid)
            end
            connection.send do |writer|
              writer.sym(:resetReady)
              writer.str(@partner_uid)
              writer.str(@uid)
            end
            @state = :await_party_selection
            #do_battle(connection, @client_id, @seed, @battle_type, partner, @partner_party,battleTeam,[@uid,@partner_uid])
            #msgwindow.visible = true
          else
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:cancel)
            end
            @state = :await_choose_activity
          end
        end

      when :trade
        Kernel.pbMessageDisplay(msgwindow, _INTL("{1} wants to trade!\\^", @partner_name))
        if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
          msgwindow.visible = true #Kernel.pbDisposeMessageWindow(msgwindow)
          connection.send do |writer|
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:acceptTrade)
          end
          #@chosen = choose_pokemon
          valid = false
          while !valid
            @chosen = choose_pokemon
            if $Trainer.party[@chosen].isEgg?
              if $Trainer.party.any? { |p| p != $Trainer.party[@chosen] && p.hp > 0 && !p.isEgg?}
                valid = true
              end
            end
            if $Trainer.party[@chosen].hp > 0 &&
              ![PBSpecies::SHYLEON,PBSpecies::TRISHOUT,PBSpecies::SHULONG,PBSpecies::DIELEBI,PBSpecies::SABOLT,PBSpecies::LUXFLON,PBSpecies::DRAGALISKFURIA].include?($Trainer.party[@chosen].species) && 
              ($Trainer.party[@chosen].item != nil ? ![PBItems::ANELLOT,PBItems::ANELLOX].include?($Trainer.party[@chosen].item) : true)
              valid = true
            end
            break if @chosen < 0
              
            if !valid
              msgwindow.visible = true
              Kernel.pbMessageDisplay(msgwindow, _INTL("You can't trade this Pokémon."))
              msgwindow.visible = false
            end
          end
          if @chosen >= 0
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:chosenPokemon)
              writer.int(@chosen)
            end
            @state = :await_trade_confirm
          else
            connection.send do |writer|
              writer.sym(:fwd)
              writer.str(@partner_uid)
              writer.sym(:cancel)
            end
            connection.discard(1)
            @state = :await_choose_activity
          end
        else
          connection.send do |writer|
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:cancel)
          end
          @state = :await_choose_activity
        end
      when :cancelInteraction
        # disconnect only if the partner who sent the disconnection is your current partner
        Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} didn't want to interact after all.",@partner_name))
        @state = :enlisted
        return
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_await_party_selection(connection,msgwindow)
    if @battleTeam == nil
      pbFadeOutIn(99999){
        #scene=PokemonScreen_Scene.new
        #screen=PokemonScreen.new(scene,$Trainer.party)
        #ret=screen.pbChooseMultiplePokemon(BATTLE_TIERS_NUMBERS[@chosenTier][@battle_type],
        #   proc{|p| BATTLE_TIERS[@chosenTier].call(p)}, @battle_type==:single ? 1 : 2,@cancancelSelection) {
        #     if Input.trigger?(Input::F5)
        #        @ui.toggleOpponentParty()
        #     end
        #   }
   
        #if !(ret == nil || ret == -1)
        #  @battleTeam = ret
        #end
        party = $Trainer.party
        if $Trainer.rentalTeamCode != "" && @rentalParty != nil
          party = @rentalParty
        end
        ret = OnlinePartySelection.new($Trainer,party,@partner_name,@partner_battle_party,BATTLE_TIERS_NUMBERS[@chosenTier][@battle_type],@battle_type==:single ? 1 : 2,@cancancelSelection,proc{|x|
          return BATTLE_TIERS[@chosenTier].call(x)
        })
        @battleTeam = ret.result
      }      
            
      # if I didn't choose any pokemon it's just like if i canceled
      if @battleTeam == nil || @battleTeam == -1
        connection.send do |writer|
          writer.sym(:fwd)
          writer.str(@partner_uid)
          writer.sym(:cancelSelection)
        end
        msgwindow.visible = true
        if !@matchmaking
          @ui.showParty
          @state = @client_id == 0 ? :choose_activity : :await_choose_activity if @state != :enlisted
        else
          @state = :enlisted
        end
        return
      end

      connection.send do |writer|
        writer.sym(:fwd)
        writer.str(@partner_uid)
        writer.sym(:party)
        writer.int($Trainer.online_trainer_type)
        writer.sym(@battle_type)
        write_custom_party(@battleTeam,writer)
      end

    end
    msgwindow.visible = true
    pbMessageDisplayDots(msgwindow,_INTL("Awaiting Partner Party..."),@frame)
    connection.updateExp([:party,:cancelSelection,:partnerDisconnected]) do |record|
      case (type = record.sym)
      when :party
        trainertype = record.int
        partner = PokeBattle_Trainer.new(@partner_name, trainertype)
        (partner.partyID=0) rescue nil # EBDX compat
        tp = record.sym
        opp_party = parse_party(record)
        @ui.hideParty
        do_battle(connection, @client_id, @seed, @battle_type, partner, opp_party,@battleTeam,[@uid,@partner_uid],@ui)
        @battleTeam = nil
        if !@matchmaking
          @ui.showParty
          msgwindow.visible = true
          @state = @client_id == 0 ? :choose_activity : :await_choose_activity if @state != :enlisted
        else
          @state = :enlisted
        end
      when :cancelSelection
        msgwindow.visible = true
        Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} canceled the selection.",@partner_name))
        if !@matchmaking
          @state = @client_id == 0 ? :choose_activity : :await_choose_activity if @state != :enlisted
        else
          @state = :enlisted
        end
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      end
    end
  end

  def self.handle_await_trade_pokemon(connection,msgwindow)
    if @partner_confirm
      pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to resynchronize", @partner_name), @frame)
    else
      pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", @partner_name), @frame)
    end

    connection.updateExp([:acceptChosenPokemon,:update,:cancel,:partnerDisconnected]) do |record|
      case (type = record.sym)
      when :acceptChosenPokemon
        partner = PokeBattle_Trainer.new(@partner_name, $Trainer.trainertype)
        pbHealAll
        @partner_party.each {|pkmn| pkmn.heal}
        pkmn = @partner_party[@partner_chosen]
        @partner_party[@partner_chosen] = $Trainer.party[@chosen]
        connection.send do |writer|
          writer.sym(:logTrade)
          writer.str(@partner_uid)
          write_pkmn(writer, $Trainer.party[@chosen])
          writer.str("@p2")
          write_pkmn(writer, pkmn)
        end
        do_trade(@chosen, partner, pkmn) #trade scene
        connection.send do |writer|
          writer.sym(:fwd)
          writer.str(@partner_uid)
          writer.sym(:update)
          write_pkmn(writer, $Trainer.party[@chosen])
        end
        @partner_confirm = true

      when :update
        @partner_party[@partner_chosen] = parse_pkmn(record)
        @partner_chosen = nil
        @partner_confirm = false
        if @client_id == 0
          @state = :choose_activity
        else
          @state = :await_choose_activity
        end
        @ui.updateParty(@partner_party)
      when :cancel
        Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", @partner_name))
        @partner_chosen = nil
        @partner_confirm = false
        if @client_id == 0
          @state = :choose_activity
        else
          @state = :await_choose_activity
        end
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        raise "Unknown message: #{type}"
      end
    end
  end

  def self.handle_await_trade_confirm(connection,msgwindow)
    if @partner_chosen.nil?
      pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick a Pokémon", @partner_name), @frame)
    else
      pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", @partner_name), @frame)
    end

    connection.updateExp([:chosenPokemon,:cancel,:partnerDisconnected]) do |record|
      case (type = record.sym)
      when :chosenPokemon
        @partner_chosen = record.int
        pbHealAll
        @partner_party.each {|pkmn| pkmn.heal}
        partner_pkmn = @partner_party[@partner_chosen]
        your_pkmn = $Trainer.party[@chosen]
        abort=$Trainer.ablePokemonCount==1 && your_pkmn==$Trainer.ablePokemonParty[0] && partner_pkmn.isEgg?
        able_party=@partner_party.find_all { |p| p && !p.isEgg? && !p.isFainted? }
        abort|=able_party.length==1 && partner_pkmn==able_party[0] && your_pkmn.isEgg?
        unless abort
          partner_speciesname = (partner_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,partner_pkmn.species))
          your_speciesname = (your_pkmn.isEgg?) ? _INTL("Egg") : PBSpecies.getName(getID(PBSpecies,your_pkmn.species))
          
          # HERE THE ACTUAL TRADE IS BEING HANDLED          
          loop do
            Kernel.pbMessageDisplay(msgwindow, _INTL("{1} has offered {2} ({3}) for your {4} ({5}).\\^",@partner_name,
                partner_pkmn.name,partner_speciesname,your_pkmn.name,your_speciesname))
            command = Kernel.pbShowCommands(msgwindow, [_INTL("Check {1}'s offer",@partner_name), _INTL("Check My Offer"), _INTL("Accept/Deny Trade")], -1)
            case command
            when 0
              check_pokemon(partner_pkmn)
            when 1
              check_pokemon(your_pkmn)
            when 2
              Kernel.pbMessageDisplay(msgwindow, _INTL("Confirm the trade of {1} ({2}) for your {3} ({4}).\\^",partner_pkmn.name,partner_speciesname,
                  your_pkmn.name,your_speciesname))
              if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                connection.send do |writer|
                  writer.sym(:fwd)
                  writer.str(@partner_uid)
                  writer.sym(:acceptChosenPokemon)
                  #write_pkmn(writer, $Trainer.party[@chosen])
                end
                @state = :await_trade_pokemon
                break
              else
                connection.send do |writer|
                  writer.sym(:fwd)
                  writer.str(@partner_uid)
                  writer.sym(:cancel)
                end
                @partner_chosen = nil
                connection.discard(1)
                if @client_id == 0
                  @state = :choose_activity
                else
                  @state = :await_choose_activity
                end
                break
              end
            end
          end
        else
          Kernel.pbMessageDisplay(msgwindow, _INTL("The trade was unable to be completed."))
          @partner_chosen = nil
          if @client_id == 0
            @state = :choose_activity
          else
            @state = :await_choose_activity
          end
        end
        
      when :cancel
        Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", @partner_name))
        @partner_chosen = nil
        if @client_id == 0
          @state = :choose_activity
        else
          @state = :await_choose_activity
        end
      when :partnerDisconnected
        # disconnect only if the partner who sent the disconnection is your current partner
        if @partner_uid == record.str
          Kernel.pbMessageDisplay(msgwindow,_INTL("Sorry, {1} disconnected.",@partner_name))
          @state = :enlisted
          return
        end
      else
        raise "Unknown message: #{type}"
      end
    end  
  end

  def self.enlist(msgwindow,ui)
    #pbChangeOnlineTrainerType()
    #pbMessageDisplayDots(msgwindow, _INTL("Connecting"), 0)
    out = nil
    host = nil
    port = nil
    
    @uid = nil
    @md5 = nil
    @ui = ui
    @handlers = {}
    # Waiting to be connected to the server.
    # Note: does nothing without a non-blocking connection.
    @handlers[:await_server] = Proc.new {|connection, msgwindow| handle_await_server(connection,msgwindow)}
    @handlers[:enlisted] = Proc.new {|connection, msgwindow| handle_enlist(connection,msgwindow)}
    # The leader is awaiting 
    @handlers[:await_interaction_accept] = Proc.new {|connection, msgwindow| handle_await_interaction_accept(connection,msgwindow)}
    # Waiting to be connected to the partner.
    @handlers[:await_partner] = Proc.new {|connection, msgwindow| handle_await_partner(connection,msgwindow)}
    # Choosing an activity (leader only).
    @handlers[:choose_activity] = Proc.new {|connection, msgwindow| handle_choose_activity(connection,msgwindow)}
    # Waiting for the partner to accept our activity (leader only).
    @handlers[:await_accept_activity] = Proc.new {|connection, msgwindow| handle_await_accept_activity(connection,msgwindow)}
    # Waiting for the partner to select an activity (follower only).
    @handlers[:await_choose_activity] = Proc.new {|connection, msgwindow| handle_await_choose_activity(connection,msgwindow)}
    # Waiting for the partner to select their party.
    @handlers[:await_party_selection] = Proc.new{|connection,msgwindow| handle_await_party_selection(connection,msgwindow)}
    # Waiting for the partner to select a Pokémon to trade.
    @handlers[:await_trade_pokemon] = Proc.new {|connection, msgwindow| handle_await_trade_pokemon(connection,msgwindow)}
    @handlers[:await_trade_confirm] = Proc.new {|connection, msgwindow| handle_await_trade_confirm(connection,msgwindow)}
    
    @handlers[:unrankedMatchmaking] = Proc.new {|connection, msgwindow| handle_unranked_matchmaking(connection,msgwindow)}
    @handlers[:wonderTrading] = Proc.new {|connection, msgwindow| handle_wonder_trading(connection,msgwindow)}

    @handlers[:await_wt_info] = Proc.new {|connection, msgwindow| handle_await_wt_info(connection,msgwindow)}

    @timeoutCounter = 0
    @maxTimeOut = 60 * 30

    #connport = port+1+rand(9)

    Connection.open("127.0.0.1", 42169) do |connection|#(host, connport) do |connection|
      ui.connection = connection
      @state = :await_server
      @last_state = nil
      @client_id = 0               # 0 = SENDER, 1 = RECEIVER
      @partner_uid = ""
      @partner_id = -1
      @partner_name = nil
      @partner_party = nil
      @partner_battle_party = nil
      @battleTeam = nil
      @frame = 0
      @activity = nil
      @seed = nil
      @battle_type = nil
      @chosen = nil
      @partner_chosen = nil
      @partner_confirm = false
      @chosenTier = nil
      @matchmaking = false
      @navigatingPlayerList = true

      @cancancelSelection = true


      loop do
        break if @closeOnline
        if (@frame%20==0)
          pbCheckForCE(connection)
        end
        if @state != @last_state
          if @state == :enlisted
            @matchmaking = false
            msgwindow.visible = false
            @ui.updateStatus(_INTL("Choose a partner or start matchmaking."))
            #Kernel.pbMessageDisplay(msgwindow,_INTL("Choose a partner."),false)
            @partner_uid = nil

            #Ask for new server message if there's any
            if connection.can_send?
              connection.send do |writer|
                writer.sym(:getServerMessage)
              end
            end
          else
            msgwindow.visible = true if @state != :await_wt_info
          end
          @last_state = @state
          @frame = 0
        else
          @frame += 1# if @frame < 180
        end

        Input.update
        Graphics.update
        @ui.canRefresh = canRefreshPlayerList?()
        @ui.update
        
        if Input.trigger?(Input::B)
          case @state
          when :unrankedMatchmaking
            msgwindow.visible = true          
            Kernel.pbMessageDisplay(msgwindow, _INTL("Do you want to exit matchmaking?"),false)
            if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
              connection.send do |writer|
                writer.sym(:forfeitMatchmaking)
              end
              @state = :enlisted
            end
            msgwindow.visible = false
          when :await_choose_activity
            msgwindow.visible = true
            Kernel.pbMessageDisplay(msgwindow, _INTL("Do you want to stop the connection with your partner?"),false)
            if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
              connection.send do |writer|
                writer.sym(:fwd)
                writer.str(@partner_uid)
                writer.sym(:leaveParty)
              end
              resetPartner()
              @state = :enlisted
              msgwindow.visible = false
              next
            end
          when :wonderTrading
            msgwindow.visible = true
            Kernel.pbMessageDisplay(msgwindow, _INTL("Do you want to cancel the Wonder Trade?"),false)
            if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
              connection.send do |writer|
                writer.sym(:cancelWT)
              end
              @wtchosen = -1
              @state = :enlisted
              msgwindow.visible = false
              next
            end
          when :await_interaction_accept
            msgwindow.visible = true
            Kernel.pbMessageDisplay(msgwindow, _INTL("Do you want to cancel the interaction?"),false)
            if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
              connection.send do |writer|
                writer.sym(:cancelAskInteraction)
              end
              @state = :enlisted
              msgwindow.visible = false
              next
            end
          else
            msgwindow.visible = true
            message = case @state
              when :await_server; _INTL("Abort connection?\\^")
              when :await_partner; _INTL("Abort search?\\^")
              else; _INTL("Disconnect?\\^")
              end
            Kernel.pbMessageDisplay(msgwindow, message)
            return if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
            msgwindow.visible = false
          end
        end
        
        if @handlers.keys.include?(@state)
          @handlers[@state].call(connection,msgwindow)
        else
          raise "Unknown state: #{@state}"
        end

      end

      connection.send do |writer|
        writer.sym(:closeConnection)
      end

      @closeOnline = false
    end
  end


  def self.pbMessageDisplayDots(msgwindow, message, frame)
    #msgwindow.text = message + "...".slice(0..(frame/8) % 3)
    Kernel.pbMessageDisplay(msgwindow, message + "...".slice(0..(frame/8) % 3) + "\\^", false)
  end

  # NO !defined?(ESSENTIALSVERSION) && !defined?(ESSENTIALS_VERSION)
  # NO defined?(ESSENTIALSVERSION) && ESSENTIALSVERSION =~ /^17/
  # NO defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/

  # Renamed constants, yay...
  def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party,own_party, uids,ui)
    #echoln "AOOOOOOOOOOO SO PARTITO IO"
    #$Trainer.backupParty = $Trainer.party.dup
    $Trainer.backupParty  = $Trainer.party.map {|x| x.clone}
    $Trainer.party = own_party
    $Trainer.party.each do |pike|
      pike.level = 50
      pike.calcStats
    end
    pbHealAll # Avoids having to transmit damaged state.
    partner_party_clone = partner_party.map {|y| y.clone}
    partner_party_clone.each {|pkmn| 
      pkmn.heal
      pkmn.level = 50
      pkmn.calcStats
    }

    $PokemonGlobal.nextBattleBack = $Trainer.online_battle_bg
    $PokemonGlobal.nextBattleBGM = $Trainer.online_battle_bgm

    scene = pbNewBattleScene
    battle = PokeBattle_CableClub.new(connection, @client_id, scene, partner_party_clone, partner, uids, ui)
    battle.fullparty1 = battle.fullparty2 = true
    battle.endspeech = ""
    battle.items = []
    battle.internalbattle = false
    case battle_type
    when :single
      battle.doublebattle = false
    when :double
      battle.doublebattle = true
    else
      raise "Unknown battle type: #{battle_type}"
    end
    trainerbgm = pbGetTrainerBattleBGM(partner)
    Events.onStartBattle.trigger(nil, nil)
    pbPrepareBattle(battle)
    exc = nil
    $onlinebattle = true
    ui.createBattleTimer
    result = 0
    pbBattleAnimation(trainerbgm, partner.trainertype, partner.name) {
      pbSceneStandby {
        # XXX: Hope we call rand in the same order in both clients...
        begin
          result = battle.pbStartBattle(true)
        rescue Connection::Disconnected => e
          scene.pbEndBattle(0)
          exc = $!
        rescue PokeBattle_Battle::BattleAbortedException => ex
          result = battle.decision
          echoln "result of the battle is #{result}"
        ensure
          $onlinebattle = false
          $Trainer.party = $Trainer.backupParty
          pbHealAll # Avoids having to transmit damaged state.
          result = 2 if result == 3
          mg = Kernel.pbCreateMessageWindow
          mg.z = 999999
          if result == 1
            Kernel.pbMessageDisplay(mg,_INTL("You won!"))
            if @matchmaking && battle.turncount > 2
              qt = 8
              Kernel.pbMessage(_INTL("{1} ha ottenuto {2} Punti Lotta!",$Trainer.name,qt))
              $Trainer.battle_points += qt
              reward = WINREWARD[rand(WINREWARD.length)]
              rewardname = getID(PBItems,reward)
              Kernel.pbMessage(_INTL("Inoltre..."))
              Kernel.pbMessage(_INTL("...{1} riceve {2}!",$Trainer.name,PBItems.getName(rewardname)))
              Kernel.pbReceiveItem(reward)
              pbSave()
            end
          end
          if result == 2
            Kernel.pbMessageDisplay(mg,_INTL("You lost!")) 
            if @matchmaking && battle.turncount > 2
              qt = 4
              Kernel.pbMessage(_INTL("{1} ha ottenuto {2} Punti Lotta!",$Trainer.name,qt))
              $Trainer.battle_points += qt
              pbSave()
            end
          end
          Kernel.pbDisposeMessageWindow(mg)

        end
      }
    }
    if result != 0
      connection.send do |writer|
        writer.sym(:battleResult)
        writer.int(result)
      end
    end
    #File.open("RecordedBattle.xvr","wb"){|f|
    #  f.write(battle.pbDumpRecord)#Marshal.dump(battle.pbDumpRecord,f)
    #}
    pbHealAll # Avoids having to transmit damaged state.
    ui.deleteBattleTimer
    $onlinebattle = false
    @state = :enlisted if battle.disconnected
    $Trainer.party = $Trainer.backupParty
    raise exc if exc
  end

  def self.do_spectate(connection,target_uid,ui)
    # Spectate code goes here
  end

  def self.do_trade(index, you, your_pkmn)
    my_pkmn = $Trainer.party[index]
    your_pkmn.obtainMode = 2 # traded
    $Trainer.party[index] = your_pkmn
    $Trainer.seen[your_pkmn.species] = true
    $Trainer.owned[your_pkmn.species] = true
    pbSeenForm(your_pkmn)
    pbSave()
    pbFadeOutInWithMusic(99999) {
      scene = PokemonTradeScene.new
      scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.username, you.name)
      scene.pbTrade
      scene.pbEndScreen
    }
    #$Trainer.party[index] = your_pkmn
  end

  def self.do_wtrade(my_pkmn, you, your_pkmn)
    your_pkmn.obtainMode = 2 # traded
    pbAddPokemonSilent(your_pkmn)
    pbSeenForm(your_pkmn)
    pbSave()
    pbFadeOutInWithMusic(99999) {
      scene = PokemonTradeScene.new
      scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.username, you.name)
      scene.pbTrade
      scene.pbEndScreen
    }
    #$Trainer.party[index] = your_pkmn
  end

  def self.checkValidity(msgwindow, showmsg, battleType, tier, party, opp_party)
    vp = 0 #valid pokemons
    vopp = 0 #valid opp pokemons
    for p in party
      if (BATTLE_TIERS[tier].call(p))
        vp +=1
      end
    end

    if battleType == :single
      if vp < 1
        Kernel.pbMessageDisplay(msgwindow, _INTL("Sorry, looks like you can't enter this Tier with your current team.")) if showmsg
        return
      end
    elsif battleType == :double 
      if vp < 2
        Kernel.pbMessageDisplay(msgwindow, _INTL("Sorry, looks like you can't enter this Tier with your current team.")) if showmsg
        return
      end
    end

    if opp_party != nil
      for p in opp_party
        if (BATTLE_TIERS[tier].call(p))
          vopp +=1
        end
      end
      
      if battleType == :single
        if vopp < 1
          Kernel.pbMessageDisplay(msgwindow, _INTL("Sorry, looks like your opponent can't enter this Tier with the current team.")) if showmsg
          return
        end
      elsif battleType == :double 
        if vopp < 2
          Kernel.pbMessageDisplay(msgwindow, _INTL("Sorry, looks like your opponent can't enter this Tier with the current team.")) if showmsg
          return
        end
      end
    end
    validCommand = true
  end

  def self.chooseTier(connection, msgwindow, battleType, opp_party)
    Kernel.pbMessageDisplay(msgwindow, _INTL("Choose a tier."))
    tiers = pbGetTiersNames()
    tierNames = []
    for t in tiers
      tierNames.push(t[0])
    end
    validCommand = false
    party = $Trainer.party
    # opp_party = nil means we're in matchmaking
    if $Trainer.useRentalTeam && $Trainer.rentalTeamCode != ""
      if connection.can_send?
        connection.send do |writer|
          writer.sym(:getRental) 
          writer.str($Trainer.rentalTeamCode)
        end
        res = nil
        while (res == nil)
          Input.update
          Graphics.update
          connection.updateExp([:found,:notFound]) do |record|
            case (type = record.sym)
            when :found
              author = record.str
              res = parse_party(record)
            else
              res = -1
            end
          end
        end
        if (res != nil && res != -1)
          party = res
          @rentalParty = res
        end
      end
    end
    while !validCommand
      command = Kernel.pbShowCommands(msgwindow, tierNames, -1)
      if command == -1 || command == tierNames.length-1
        command = -1
        break
      end
      validCommand = checkValidity(msgwindow, true, battleType, tiers[command][1], party, opp_party)
    end
    #command ora mi punta al simbolo che identifica il tier, POG
    if command != -1
      return tiers[command][1]
    else
      return nil
    end
  end

  def self.choose_pokemon
    chosen = -1
    pbFadeOutIn(99999) {
      scene = PokemonScreen_Scene.new
      screen = PokemonScreen.new(scene, $Trainer.party)
      screen.pbStartScene(_INTL("Choose a Pokémon."), false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    }
    return chosen
  end
  
  def self.check_pokemon(pkmn)
    pbFadeOutIn(99999) {
      scene = PokemonSummaryScene.new
      screen = PokemonSummary.new(scene)
      screen.pbStartScreen([pkmn],0)
    }
  end

  def self.write_party(writer)
    writer.int($Trainer.party.length)
    $Trainer.party.each do |pkmn|
      write_pkmn(writer, pkmn)
    end
  end

  def self.write_custom_party(party, writer)
    writer.int(party.length)
    party.each do |pkmn|
      write_pkmn(writer, pkmn)
    end
  end

  def self.write_pkmn_toc(pkmn)
    writer = RecordWriter.new
    write_pkmn(writer,pkmn)
    echoln writer.line!
  end

  def self.write_pkmn(writer, pkmn)
    is_v18 = defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
    writer.int(pkmn.species)
    writer.int(pkmn.level)
    writer.int(pkmn.personalID)
    writer.int(pkmn.trainerID)
    writer.str(pkmn.ot)
    writer.int(pkmn.otgender)
    writer.int(pkmn.language)
    writer.int(pkmn.exp)
    writer.int(pkmn.form)
    writer.int(pkmn.item)
    writer.int(pkmn.moves.length)
    pkmn.moves.each do |move|
      writer.int(move.id)
      writer.int(move.ppup)
    end
    writer.int(pkmn.firstmoves.length)
    pkmn.firstmoves.each do |move|
      writer.int(move)
    end
    # in hindsight, don't really need to send the calculated values
    writer.nil_or(:int, pkmn.genderflag)
    writer.nil_or(:bool, pkmn.shinyflag)
    writer.nil_or(:int, pkmn.abilityflag)
    writer.nil_or(:int, pkmn.natureflag)
    writer.nil_or(:int, pkmn.natureOverride) if is_v18
    for i in 0...6
      writer.int(pkmn.iv[i])
      writer.nil_or(:bool, pkmn.ivMaxed[i]) if is_v18
      writer.int(pkmn.ev[i])
    end
    if (pkmn.isDelta?)
      writer.bool(true)
    else
      writer.bool(false)
    end
    writer.int(pkmn.happiness)
    writer.str(pkmn.name)
    writer.int(pkmn.ballused)
    writer.int(pkmn.eggsteps)
    writer.nil_or(:int,pkmn.pokerus)
    writer.int(pkmn.obtainMap)
    writer.nil_or(:str,pkmn.obtainText)
    writer.int(pkmn.obtainLevel)
    writer.int(pkmn.obtainMode)
    writer.int(pkmn.hatchedMap)
    writer.int(pkmn.cool)
    writer.int(pkmn.beauty)
    writer.int(pkmn.cute)
    writer.int(pkmn.smart)
    writer.int(pkmn.tough)
    writer.int(pkmn.sheen)
    writer.int(pkmn.ribbonCount)
    pkmn.ribbons.each do |ribbon|
      writer.int(ribbon)
    end
    writer.bool(!!pkmn.mail)
    if pkmn.mail
      writer.int(pkmn.mail.item)
      writer.str(pkmn.mail.message)
      writer.str(pkmn.mail.sender)
      if pkmn.mail.poke1
        #[species,gender,shininess,form,shadowness,is egg]
        writer.int(pkmn.mail.poke1[0])
        writer.int(pkmn.mail.poke1[1])
        writer.bool(pkmn.mail.poke1[2])
        writer.int(pkmn.mail.poke1[3])
        writer.bool(pkmn.mail.poke1[4])
        writer.bool(pkmn.mail.poke1[5])
      else
        writer.nil_or(:int,nil)
      end
      if pkmn.mail.poke2
        #[species,gender,shininess,form,shadowness,is egg]
        writer.int(pkmn.mail.poke2[0])
        writer.int(pkmn.mail.poke2[1])
        writer.bool(pkmn.mail.poke2[2])
        writer.int(pkmn.mail.poke2[3])
        writer.bool(pkmn.mail.poke2[4])
        writer.bool(pkmn.mail.poke2[5])
      else
        writer.nil_or(:int,nil)
      end
      if pkmn.mail.poke3
        #[species,gender,shininess,form,shadowness,is egg]
        writer.int(pkmn.mail.poke3[0])
        writer.int(pkmn.mail.poke3[1])
        writer.bool(pkmn.mail.poke3[2])
        writer.int(pkmn.mail.poke3[3])
        writer.bool(pkmn.mail.poke3[4])
        writer.bool(pkmn.mail.poke3[5])
      else
        writer.nil_or(:int,nil)
      end
    end
    writer.bool(!!pkmn.fused)
    if pkmn.fused
      write_pkmn(writer, pkmn.fused)
    end
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      writer.bool(pkmn.shiny?)
      writer.str(pkmn.superHue.to_s)
      writer.nil_or(:bool,pkmn.superVariant)
    end
  end

  def self.parse_party(record)
    party = []
    record.int.times do
      party << parse_pkmn(record)
    end
    return party
  end

  def self.parse_pkmn(record)
    is_v18 = defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
    species = record.int
    level = record.int
    pkmn = PokeBattle_Pokemon.new(species, level, $Trainer)
    pkmn.personalID = record.int
    pkmn.trainerID = record.int
    pkmn.ot = record.str
    pkmn.otgender = record.int
    pkmn.language = record.int
    pkmn.exp = record.int
    form = record.int
    if is_v18
      pkmn.formSimple = form
    else
      pkmn.formNoCall = form
    end
    pkmn.setItem(record.int)
    pkmn.resetMoves
    for i in 0...record.int
      pkmn.moves[i] = PBMove.new(record.int)
      pkmn.moves[i].ppup = record.int
    end
    pkmn.firstmoves = []
    for i in 0...record.int
      pkmn.firstmoves.push(record.int)
    end
    pkmn.genderflag = record.nil_or(:int)
    pkmn.shinyflag = record.nil_or(:bool)
    pkmn.abilityflag = record.nil_or(:int)
    pkmn.natureflag = record.nil_or(:int)
    pkmn.natureOverride = record.nil_or(:int) if is_v18
    for i in 0...6
      pkmn.iv[i] = record.int
      pkmn.ivMaxed[i] = record.nil_or(:bool) if is_v18
      pkmn.ev[i] = record.int
    end
    if record.nil_or(:bool) == true
      pkmn.makeDelta
    end
    pkmn.happiness = record.int
    pkmn.name = record.str
    pkmn.ballused = record.int
    pkmn.eggsteps = record.int
    pkmn.pokerus = record.nil_or(:int)
    pkmn.obtainMap = record.int
    pkmn.obtainText = record.nil_or(:str)
    pkmn.obtainLevel = record.int
    pkmn.obtainMode = record.int
    pkmn.hatchedMap = record.int
    pkmn.cool = record.int
    pkmn.beauty = record.int
    pkmn.cute = record.int
    pkmn.smart = record.int
    pkmn.tough = record.int
    pkmn.sheen = record.int
    pkmn.clearAllRibbons
    for i in 0...record.int
      pkmn.giveRibbon(record.int)
    end
    if record.bool() # mail
      m_item = record.int()
      m_msg = record.str()
      m_sender = record.str()
      m_poke1 = []
      if m_species1 = record.nil_or(:int)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke1[0] = m_species1
        m_poke1[1] = record.int()
        m_poke1[2] = record.bool()
        m_poke1[3] = record.int()
        m_poke1[4] = record.bool()
        m_poke1[5] = record.bool()
      else
        m_poke1 = nil
      end
      m_poke2 = []
      if m_species2 = record.nil_or(:int)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke2[0] = m_species2
        m_poke2[1] = record.int()
        m_poke2[2] = record.bool()
        m_poke2[3] = record.int()
        m_poke2[4] = record.bool()
        m_poke2[5] = record.bool()
      else
        m_poke2 = nil
      end
      m_poke3 = []
      if m_species3 = record.nil_or(:int)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke3[0] = m_species3
        m_poke3[1] = record.int()
        m_poke3[2] = record.bool()
        m_poke3[3] = record.int()
        m_poke3[4] = record.bool()
        m_poke3[5] = record.bool()
      else
        m_poke3 = nil
      end
      pkmn.mail = PokemonMail.new(m_item,m_msg,m_sender,m_poke1,m_poke2,m_poke3)
    end
    if record.bool()# fused
      pkmn.fused = parse_pkmn(record)
    end
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      record.bool # shiny call.
      superhue = record.str
      if superhue == ""
        pkmn.superHue = nil
      elsif superhue=="false"
        pkmn.superHue = false
      else
        pkmn.superHue = superhue.to_i
      end
      pkmn.superVariant = record.nil_or(:bool)
    end
    pkmn.calcStats
    return pkmn
  end
end

class PokeBattle_Battle
  attr_reader :client_id
end

class PokeBattle_CableClub < PokeBattle_Battle
  
  #include PokeBattle_RecordedBattleModule

  def pbAbort
    yield if block_given?
    super
  end

  attr_reader :connection
  def initialize(connection, client_id, scene, opponent_party, opponent, uids, ui)
    @connection = connection
    @client_id = client_id
    @uid = uids[0]
    @partner_uid = uids[1]
    @disconnected = false
    @seedset=false
    @ui = ui
    @randomCounter = 0
    @randomHistory = []

    @timer = 0
    @timerMax = 60*300

    player = PokeBattle_Trainer.new($Trainer.username, $Trainer.trainertype)
    super(scene, $Trainer.party, opponent_party, player, opponent)
    @battleAI  = PokeBattle_CableClub_AI.new(self) if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
  end
  
  def pbStartBattle(canlose=false)
		PBDebug.log("******************************************")
		begin
			pbStartBattleCore(canlose)
		rescue BattleAbortedException
			@scene.pbEndBattle(@decision)
		end
		return @decision
	end

  def pbPriority(ignorequickclaw=false)
		if @usepriority
			# use stored priority if round isn't over yet
			return @priority
		end
    battlers = []
    choices = []
    if @client_id == 1
      battlers[0] = @battlers[1]
      battlers[1] = @battlers[0]
      battlers[2] = @battlers[3]
      battlers[3] = @battlers[2]
      choices[0] = @choices[1]
      choices[1] = @choices[0]
      choices[2] = @choices[3]
      choices[3] = @choices[2]
    else
      battlers = @battlers
      choices = @choices
    end



		@priorityTrickRoom = (@field.effects[PBEffects::TrickRoom]>0)
		speeds=[]
		quickclaw=[];lagging=[];
		priorities=[]
		temp=[]
		@priority.clear
		maxpri=0
		minpri=0
		# Random order used for ties
		randomOrder = Array.new(battlers.length) { |i| i }
		(randomOrder.length-1).times do |i|   # Can't use shuffle! here
			r = i+pbRandom(randomOrder.length-i)
			randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
		end

		# Calculate each Pokémon's speed
		for i in 0...4
			speeds[i]=battlers[i].pbSpeed * (@priorityTrickRoom ? -1 : 1)
			quickclaw[i]=false
			lagging[i]=false
			if !ignorequickclaw && choices[i][0]==1 # Chose to use a move
				if !quickclaw[i] && battlers[i].hasWorkingItem(:CUSTAPBERRY) &&
					!battlers[i].pbOpposing1.hasWorkingAbility(:UNNERVE) &&
					!battlers[i].pbOpposing2.hasWorkingAbility(:UNNERVE)
					if (battlers[i].hasWorkingAbility(:GLUTTONY) && battlers[i].hp<=(battlers[i].totalhp/2).floor) ||
						battlers[i].hp<=(battlers[i].totalhp/4).floor
						pbCommonAnimation("UseItem",battlers[i],nil)
						quickclaw[i]=true
						pbDisplayBrief(_INTL("{1}'s {2} let it move first!",
						battlers[i].pbThis,PBItems.getName(battlers[i].item)))
						battlers[i].pbConsumeItem
					end
				end
				if !quickclaw[i] && battlers[i].hasWorkingItem(:QUICKCLAW)
					if pbRandom(10)<2
						pbCommonAnimation("UseItem",battlers[i],nil)
						quickclaw[i]=true
						pbDisplayBrief(_INTL("{1}'s {2} let it move first!",
						battlers[i].pbThis,PBItems.getName(battlers[i].item)))
					end
				end
				if !quickclaw[i] &&
					(battlers[i].hasWorkingAbility(:STALL) ||
					battlers[i].hasWorkingItem(:LAGGINGTAIL) ||
					battlers[i].hasWorkingItem(:FULLINCENSE))
					lagging[i]=true
				end
			end
		end
		# Find the maximum and minimum priority
		for i in 0...4
			# For this function, switching and using items
			# is the same as using a move with a priority of 0
			pri=0
			if choices[i][0]==1 # Is a move
				printable = ""
				for t in choices[i]
					printable+=t.to_s + ","
				end
				echoln "PRIORITY ON #{i} -> #{printable}:#{choices[i][2]}"
				pri=choices[i][2].priority
				pri+=2 if battlers[i].hasWorkingAbility(:PRANKSTER) && choices[i][2].basedamage==0 # Is status move
				pri+=1 if isConst?(battlers[i].ability,PBAbilities,:GALEWINGS) && choices[i][2].type==2
        # I need to use my own client perspective for this
        singleTargetMove = choices[i][2].target == PBTargets::SingleNonUser || choices[i][2].target == PBTargets::RandomOpposing || choices[i][2].target == PBTargets::SingleOpposing 
				target = choices[i][3]==-1 ? battlers[i].pbOpposing1().index : choices[i][3]
				echoln "RAPTOR ON #{target} HP: #{battlers[target].hp}  TOTALHP: #{battlers[target].totalhp/4} WITH #{singleTargetMove}"
				echoln "RAPTOR? #{battlers[i].hasWorkingAbility(:RAPTOR) && battlers[target].hp <= battlers[target].totalhp/4}"
				
				pri+=1 if battlers[i].hasWorkingAbility(:RAPTOR) && singleTargetMove && battlers[target].hp <= battlers[target].totalhp/4 #I need to use my ow
        pri+=2 if battlers[i].effects[PBEffects::Cheering]
      end
			priorities[i]=pri
			if i==0
				maxpri=pri
				minpri=pri
			else
				maxpri=pri if maxpri<pri
				minpri=pri if minpri>pri
			end
		end
    echo "SPEEDS =>"
    echoln speeds
    echo "PRIORITIES =>"
    echoln priorities
		# Find and order all moves with the same priority
		curpri=maxpri
		loop do
			temp.clear
			for j in 0...4
				if priorities[j]==curpri
					temp[temp.length]=j
				end
			end
      echo "TEMP =>"
      echoln temp
			# Sort by speed
			if temp.length==1
				@priority[@priority.length]=battlers[temp[0]]
			else
				n=temp.length
				for m in 0..n-2
					for i in 1..n-1
						if quickclaw[temp[i]]
							cmp=(quickclaw[temp[i-1]]) ? 0 : -1 #Rank higher if without Quick Claw, or equal if with it
              echoln "i has quickclaw, cmp=#{cmp}"
						elsif quickclaw[temp[i-1]]
							cmp=1 # Rank lower
						elsif speeds[temp[i]]!=speeds[temp[i-1]]
              echoln "#{temp[i]} #{temp[i-1]}"
              echoln "different speeds brother, cmp=#{cmp} e #{speeds[temp[i]]} #{speeds[temp[i-1]]}"
							cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1 #Rank higher to higher-speed battler
						else
							cmp=0
              echoln "#{temp[i]} #{temp[i-1]}"
              echoln "equal speeds brother, cmp=#{cmp} e #{speeds[temp[i]]} #{speeds[temp[i-1]]}"
						end
						if cmp<0
							# put higher-speed Pokémon first
							swaptmp=temp[i]
							temp[i]=temp[i-1]
							temp[i-1]=swaptmp
						elsif cmp==0
							# swap at random if speeds are equal
							rnd = pbRandom(2)
							echoln "RANDOM VALUE FOR EQUAL SPEEDS: #{rnd}"
							if rnd==0
								swaptmp=temp[i]
								temp[i]=temp[i-1]
								temp[i-1]=swaptmp
							end
						end
					end
				end
				#Now add the temp array to priority
				for i in temp
					@priority[@priority.length]=battlers[i]
				end
			end
			curpri-=1
			break unless curpri>=minpri
		end

		@usepriority=true
		d="   Priority: #{@priority[0].index}"
		d+=", #{@priority[1].index}" if @priority[1]
		d+=", #{@priority[2].index}" if @priority[2]
		d+=", #{@priority[3].index}" if @priority[3]
		PBDebug.log(d)
		return @priority
	end

  def disconnected
    return @disconnected
  end

  def pbAwaitReadiness
    frame = 0.0
    if @ready == nil
      @ready = 0
    end
    @scene.pbShowWindow(PokeBattle_Scene::MESSAGEBOX)
    cw = @scene.sprites["messagewindow"]
    cw.letterbyletter = false
    #Here i should await for readiness
    sent = false
    gotready = false
    awaiting = true
    sent = 0
    echoln "AWAITING READINESS #{sent}"
    @connection.send do |writer|
      writer.sym(:ready) #Request type
      writer.str(@partner_uid)
      writer.str(@uid)
      @ready+=1
    end
    #@connection.flush
    while(awaiting && !gotready)
      Graphics.update
      Input.update
      cw.text = _INTL("Waiting for the other player") + "." * (1 + ((frame / 8) % 3))
      pbCheckForCE(@connection)
      @connection.updateExp([:checkProceed,:proceeding,:true,:false,:partnerDisconnected]) do |record|
        case (type = record.sym)
        when :checkProceed
          readycheck = record.int
          if @ready <= readycheck
            awaiting = false 
            echoln "READY! GO ON"
          else
            echoln "NOT READY YET!"
          end
        when :proceeding
          #the other player is already proceeding, so there's no need to keep waiting here
          #but first we need to make sure the other player has caught up with our readies
          if @ready == record.int
            awaiting = false
            echoln "READY! GO ON"
          end
        #when :true
        #  awaiting = false
        #  echoln "READY! GO ON"
        #when :false
        #  echoln "NOT READY YET!"
        when :partnerDisconnected
          awaiting = false
          pbSEPlay("Battle flee")
          pbDisplay(_INTL("{1} disconnected!", opponent.fullname))
          @decision = 1
          @disconnected = true
          pbAbort
        end
      end
      if (((frame / 60) % 2) == 0)
        @connection.send do |writer|
          writer.sym(:canProceed) #Request type
        end
        sent += 1
        echoln "AWAITING READINESS #{sent}"
      end
      frame+=1.0
    end
    @connection.send do |writer|
      writer.sym(:fwd)
      writer.str(@partner_uid)
      writer.sym(:proceeding)
      writer.int(@ready)
    end
  end

  def pbBattleWait(frames)
    frames.times do
      Graphics.update
      Input.update
      yield if block_given?
    end
  end

  def pbDisplayPaused(message)
    pbDisplayBrief(message)
    pbBattleWait(80) {
      yield if block_given?
    }
  end

  #Redefining pbStartBattleCore(canlose)
  #This one will await the readiness of each player

  def pbStartBattleCore(canlose)
    Graphics.frame_rate = 60
    
    echoln "SIIIIIIIIIIIIIIIIIIIIIIIIAA #{@opponent}"
    if !@fullparty1 && @party1.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    #$smAnim = false if ($smAnim && @doublebattle) || EBUISTYLE!=2
    $smAnim = true if $game_switches[85] && (containsNewBosses?(@party2) ? true : !@doublebattle)
    if !@opponent
    #========================
    # Initialize wild Pokémon
    #========================
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        if $game_switches[DRAGALISK_UNBEATABLE]==true
          @battlers[1].stages[PBStats::EVASION] = 500
        end
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        @scene.sendingOut=true
				###
				if wildpoke.boss
					pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!",wildpoke.name))
          # GRENINJAX END SENDOUT
          if NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false) #NEWBOSSES.include?($wildSpecies)
            @scene.newBossSequence.finish if @scene.newBossSequence
            @scene.newBossSequence.sendout if @scene.newBossSequence
          else
            @scene.vsBossSequence2_end
            @scene.vsBossSequence2_sendout
          end
        else
					pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
				end
				###
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        wildpoke=@party2[0]
        if wildpoke.boss
          if defined?($dittoxbattle) && $dittoxbattle
            pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!","Ditto X"))
					else
            pbDisplayPaused(_INTL("Prepare your anus! The Pokémon boss {1} wants to battle!",wildpoke.name))
          end
          # GRENINJAX END SENDOUT
          if NEWBOSSES.include?($wildSpecies) && (isBoss?() ? (defined?($furiousBattle) && $furiousBattle) : false) #NEWBOSSES.include?($wildSpecies)
            @scene.newBossSequence.finish if @scene.newBossSequence
            @scene.newBossSequence.sendout if @scene.newBossSequence
          else
            @scene.vsBossSequence2_end
            @scene.vsBossSequence2_sendout
          end
        else
          pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
            @party2[0].name,@party2[1].name))
        end
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
    #=======================================
    # Initialize opponents in double battles
    #=======================================
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      @scene.sendingOut=true
      echoln "SIIIIIIIIIIIIIIIIIIIIIIIIAA"
      if @opponent.is_a?(Array)
        pbDisplayPaused(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2 < 0
        @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        @scene.smTrainerSequence.finish if @scene.smTrainerSequence
        pbDisplayBrief(_INTL("{1} sent\r out {2}! {3} sent\r out {4}!",@opponent[0].fullname,getBattlerPokemon(@battlers[1]).name,@opponent[1].fullname,getBattlerPokemon(@battlers[3]).name))
        pbSendOutInitial(@doublebattle,1,@party2[sendout1],3,@party2[sendout2])
      else
        echoln "NOOOOOOOOOAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        pbDisplayPaused(_INTL("{1}\r\nvuole combattere!",@opponent.fullname)){
          @scene.smTrainerSequence.update if @scene.smTrainerSequence
        }
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        
        if @party2[sendout1].species == getID(PBSpecies,:PAWNIARDAB)
          @party2[sendout1].totalHp=9999999
          @party2[sendout1].hp=9999999
					@party2[sendout1].attack=90000
        end
        
        if @party2[sendout2].species == getID(PBSpecies,:PAWNIARDAB)
          @party2[sendout2].totalHp=9999999 
          @party2[sendout2].hp=9999999
					@party2[sendout2].attack=90000
        end
        
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        @scene.smTrainerSequence.finish if @scene.smTrainerSequence
        pbDisplayBrief(_INTL("{1} sent\r out {2} and {3}!",
           @opponent.fullname,getBattlerPokemon(@battlers[1]).name,getBattlerPokemon(@battlers[3]).name))
        pbSendOutInitial(@doublebattle,1,@party2[sendout1],3,@party2[sendout2])
      end
    else
    #======================================
    # Initialize opponent in single battles
    #======================================
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout < 0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[0]
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      @scene.pbStartBattle(self)
      @scene.sendingOut=true
      pbDisplayPaused(_INTL("{1}\r\nvuole combattere!",@opponent.fullname)){
        @scene.smTrainerSequence.update if @scene.smTrainerSequence
      }
      @scene.vsSequenceSM_end if $smAnim && !@scene.smTrainerSequence
      @scene.smTrainerSequence.finish if @scene.smTrainerSequence
      pbDisplayBrief(_INTL("{1} sent\r out {2}!",@opponent.fullname,getBattlerPokemon(@battlers[1]).name))
      pbSendOutInitial(@doublebattle,1,trainerpoke)
    end
    #=====================================
    # Initialize players in double battles
    #=====================================
    if @doublebattle
      @scene.sendingOut=true
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2 < 0
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
           @player[1].fullname,getBattlerPokemon(@battlers[2]).name,getBattlerPokemon(@battlers[0]).name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Player doesn't have two unfainted Pokémon")
        end
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("Go! {1} and {2}!",getBattlerPokemon(@battlers[0]).name,getBattlerPokemon(@battlers[2]).name))
      end
      pbSendOutInitial(@doublebattle,0,@party1[sendout1],2,@party1[sendout2])
    else
    #====================================
    # Initialize player in single battles
    #====================================
      @scene.sendingOut=true
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout < 0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbDisplayBrief(_INTL("Go! {1}!",getBattlerPokemon(@battlers[0]).name))
      pbSendOutInitial(@doublebattle,0,playerpoke)
    end
    #====================================
    # Displays a message for notifying stat increase
    #====================================
    if wildpoke != nil && wildpoke.boss
      pbDisplay(_INTL("Le statistiche del Pokémon nemico sono più elevate!"))
    end
    #==================
    # Initialize battle
    #==================
    if @weather==PBWeather::SUNNYDAY
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::SANDSTORM
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbDisplay(_INTL("Hail is falling."))
    elsif PBWeather.const_defined?(:HEAVYRAIN) && @weather==PBWeather::HEAVYRAIN
      pbDisplay(_INTL("It is raining heavily."))
    elsif PBWeather.const_defined?(:HARSHSUN) && @weather==PBWeather::HARSHSUN
      pbDisplay(_INTL("The sunlight is extremely harsh."))
    elsif PBWeather.const_defined?(:STRONGWINDS) && @weather==PBWeather::STRONGWINDS
      pbDisplay(_INTL("The wind is strong."))
    end

    #Qui viene chiamato random
    pbOnActiveAll   # Abilities
    @turncount=0
    pbAwaitReadiness

    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
      if @debug && @turncount >=100
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 100 rounds]")
        pbAbort
        break
      end
      pbAwaitReadiness
      PBDebug.logonerr{
         pbCommandPhase
      }
      break if @decision > 0
      PBDebug.logonerr{
         pbAttackPhase
      }
      break if @decision > 0
      @scene.clearMessageWindow
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision > 0
      @turncount+=1
			
			break if @turncount == DRAGALISK_BATTLE_MAXTURNS && $game_switches[DRAGALISK_UNBEATABLE]==true
    end
    return pbEndOfBattle(canlose)
  end

  def pbRandom(x)
    @connection.send do |writer|
      writer.sym(:random) #Request type
      writer.int(x) #Max range for random
      writer.int(@randomCounter) #Random counter
      writer.int(@client_id == 0 ? @uid + @partner_uid : @partner_uid + @uid)
    end
    @randomCounter += 1
    ret = nil
    while (ret==nil)
      Graphics.update
      Input.update
      raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
      @connection.updateExp([:random,:partnerDisconnected]) do |record|
        case (type = record.sym)
        when :random
          ret = record.int
          
        when :partnerDisconnected
          pbSEPlay("Battle flee")
          pbDisplay(_INTL("{1} disconnected!", opponent.fullname))
          @decision = 1
          @disconnected = true
          pbAbort
        else
          print "Unknown message: #{type}"
        end
      end
    end
    echoln "Called the fucking NET random! Counter at #{@randomCounter}, Rand is #{ret}"
    return ret
  end

  # Added optional args to not make v18 break.
  def pbSwitchInBetween(index, lax=false, cancancel=false)
    if pbOwnedByPlayer?(index)
      choice = super(index, lax, cancancel) {yield if block_given?}
      # bug fix for the unknown type :switch. cause: going into the pokemon menu then backing out and attacking, which sends the switch symbol regardless.
      if !cancancel # forced switches do not allow canceling, and both sides would expect a response.
        pbAwaitReadiness
        
        @connection.send do |writer|
          writer.sym(:fwd)
          writer.str(@partner_uid)
          writer.sym(:switch)
          writer.int(choice)
        end
      end
      return choice
    else
      frame = 0
      # So much renamed stuff...
      if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
        cbox = PokeBattle_Scene::MESSAGE_BOX
        hbox = "messageWindow"
        opponent = @opponent[0]
      else
        cbox = PokeBattle_Scene::MESSAGEBOX
        hbox = "messagewindow"
        opponent = @opponent
      end
      @scene.pbShowWindow(cbox)
      cw = @scene.sprites[hbox]
      cw.letterbyletter = false
      begin
        pbAwaitReadiness if !cancancel
        loop do
          frame += 1
          cw.text = _INTL("Waiting") + "." * (1 + ((frame / 8) % 3))
          @scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
          @connection.updateExp([:forfeit,:switch,:partnerDisconnected]) do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} forfeited the match!", opponent.fullname))
              @decision = 1
              pbAbort
            when :partnerDisconnected
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} disconnected!", opponent.fullname))
              @decision = 1
              pbAbort
            when :switch
              return record.int

            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = false
      end
    end
  end

  def pbRun(idxPokemon, duringBattle=false)
    ret = super(idxPokemon, duringBattle)
    if ret == 1
      @connection.send do |writer|
        writer.sym(:fwd)
        writer.str(@partner_uid)
        writer.sym(:forfeit)
      end
      @connection.discard(1)
    end
    return ret
  end

  def pbSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
    else
      return if @decision==5
    end
    pbJudge()
    return if @decision>0
    switched=[]
    for index in CableClub::pokemon_order(@client_id)
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && !@battlers[index].isFainted?
      next if !pbCanChooseNonActive?(index)
      if !pbOwnedByPlayer?(index)
        if !pbIsOpposing?(index) || (@opponent && pbIsOpposing?(index))
          newenemy=pbSwitchInBetween(index,false,false) {yield if block_given?}
          newenemyname=newenemy
          if newenemy>=0 && isConst?(pbParty(index)[newenemy].ability,PBAbilities,:ILLUSION)
            newenemyname=pbGetLastPokeInTeam(index)
          end
          opponent=pbGetOwner(index)
          pbRecallAndReplace(index,newenemy,newenemyname)
          switched.push(index)
        end
      else
        newpoke=pbSwitchInBetween(index,true,false) {yield if block_given?}
        newpokename=newpoke
        if isConst?(@party1[newpoke].ability,PBAbilities,:ILLUSION)
          newpokename=pbGetLastPokeInTeam(index)
        end
        echoln "SWITCHING newpoke: #{newpoke} and newpokename:#{newpokename}"
        pbRecallAndReplace(index,newpoke,newpokename)
        switched.push(index)
      end
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
  end
    
  # This is horrific. Basically, we need to force Essentials to look for
  # the RHS foe's move in all circumstances, otherwise we won't transmit
  # any moves for this turn and the battle will hang.
  def pbCanShowCommands?(index)
    super(index) || (index == 3 && Kernel.caller(1) =~ /pbCanShowCommands/)
  end
  
  def pbUpdateTurnTimer()
    @timer+=1
    @ui.updateTime("Time: #{(@timerMax-@timer)/60}")
  end

  def pbCommandPhase
		@scene.pbBeginCommandPhase
		@scene.pbResetCommandIndices
		for i in 0...4   # Reset choices if commands can be shown
			if pbCanShowCommands?(i) || @battlers[i].isFainted?
        echoln "Resetting choice for #{@battlers[i].species} #{i}"
				@choices[i][0]=0
				@choices[i][1]=0
				@choices[i][2]=nil
				@choices[i][3]=-1
			else
				battler=@battlers[i]
				unless !@doublebattle && pbIsDoubleBattler?(i)
					PBDebug.log("[Reusing commands for #{battler.pbThis(true)}]")
				end
			end
		end
		# Reset choices to perform Mega Evolution if it wasn't done somehow
		for i in 0..1
			for j in 0...@megaEvolution[i].length
				@megaEvolution[i][j]=-1 if @megaEvolution[i][j]>=0
			end
		end    
    our_indices = @doublebattle ? [0, 2] : [0]
    their_indices = @doublebattle ? [1, 3] : [1]
		for i in 0...4
      
      @timer=0
      @ui.updateTime("Time: #{(@timerMax-@timer)/60}")
			break if @decision!=0
      echoln "Battler #{i}:#{pbOwnedByPlayer?(i)}:#{PBSpecies.getName(@battlers[i].species)}:#{@choices[i][0]}"
=begin
      if i == their_indices.last && @choices[i][0]!=0
        target_order = CableClub::pokemon_target_order(@client_id)
        for our_index in our_indices
          echoln "SENT CHOICE #{@choices[our_index][0]}:#{@choices[our_index][1]}"
          @connection.send do |writer|
            pkmn = @battlers[our_index]
            writer.sym(:fwd)
            writer.str(@partner_uid)
            writer.sym(:choice)
            writer.int(@choices[our_index][0])
            writer.int(@choices[our_index][1])

            moveindex = pkmn.moves.select {|v| v.id == @choices[our_index][2].id}
            echoln ">>>>>>>>>>>>>>>>>>>>>>>MOVE INFO #{moveindex} - #{@choices[our_index][2]}"
            move = @choices[our_index][2] && pkmn.moves.index(moveindex[0])#pkmn.moves.index(@choices[our_index][2])
            #echoln "#{pkmn.moves} #{@choices[our_index][2].name} #{@choices[our_index][2].id}"
            #echoln "FORCE MOVE SEND INFO: #{move}  #{@choices[our_index][2]} #{pkmn.moves.index(@choices[our_index][2])}  #{@choices[our_index][2] && pkmn.moves.index(@choices[our_index][2])}"
            writer.nil_or(:int, move)
            # -1 invokes the RNG, out of order (somehow?!) which causes desync.
            # But this is a single battle, so the only possible choice is the foe.
            if !@doublebattle && @choices[our_index][3] == -1
              @choices[our_index][3] = their_indices[0]
            end
            # Target from their POV.
            our_target = @choices[our_index][3]
            their_target = target_order[our_target] rescue our_target
            writer.int(their_target)
            mega=@megaEvolution[0][0]
            mega^=1 if mega>=0
            writer.int(mega) # mega fix?
            Log.i("INFO","SENT BATTLE CHOICES for MONSTER AT INDEX #{i}")
          end
        end
      end
=end
			next if @choices[i][0]!=0 && pbOwnedByPlayer?(i)
      echoln "Evaluating action for #{PBSpecies.getName(@battlers[i].species)}"
			if !pbOwnedByPlayer?(i) || @controlPlayer
				#if !@battlers[i].isFainted? && pbCanShowCommands?(i)
				@scene.pbChooseEnemyCommand(i)
				#end
			else
				commandDone=false
				commandEnd=false
				if pbCanShowCommands?(i)
					loop do
						cmd=pbCommandMenu(i) {
              pbUpdateTurnTimer()
            }
						if cmd==0 # Fight
							if pbCanShowFightMenu?(i)
								commandDone=true if pbAutoFightMenu(i)
								until commandDone
									index=@scene.pbFightMenu(i) {
                    pbUpdateTurnTimer()
                  }
									if index<0
										side=(pbIsOpposing?(i)) ? 1 : 0
										owner=pbGetOwnerIndex(i)
										if @megaEvolution[side][owner]==i
											@megaEvolution[side][owner]=-1
										end
										break
									end
									next if !pbRegisterMove(i,index)
									if @doublebattle
										thismove=@battlers[i].moves[index]
										target=@battlers[i].pbTarget(thismove)
										if target==PBTargets::SingleNonUser # single non-user
											target=@scene.pbChooseTarget(i)
											next if target<0
											pbRegisterTarget(i,target)
										elsif target==PBTargets::UserOrPartner # Acupressure
											target=@scene.pbChooseTarget(i)
											next if target<0 || (target&1)==1
											pbRegisterTarget(i,target)
										end
									end
									commandDone=true
								end
							else
								pbAutoChooseMove(i)
								commandDone=true
							end
						elsif cmd==1 # Bag
							if !@internalbattle || $ISINTOURNAMENT
								if pbOwnedByPlayer?(i)
									pbDisplay(_INTL("Items can't be used here."))
								end
							elsif $trainerbossbattle
								pbDisplay(_INTL("La forte pressione non ti permette di usare strumenti!"))
							else
								item=pbItemMenu(i, @battlers[1]) {
                  pbUpdateTurnTimer()
                }
								if pbIsPokeBall?(item[0]) && !@opponent
									if item[0] == PBItems::XENOBALL && isXSpecies?(@battlers[1].species)
										pbConsumeItemInBattle($PokemonBag, item[0])
									elsif item[0] == PBItems::XENOBALL && !isXSpecies?(@battlers[1].species) ||
										item[0] != PBItems::XENOBALL && isXSpecies?(@battlers[1].species)
										pbDisplay(_INTL("Non puoi usare questa ball per catturare il\nPokémon!"))
										item[0]=-1
										#return
									elsif item[0] != PBItems::XENOBALL && !isXSpecies?(@battlers[1].species)
										pbConsumeItemInBattle($PokemonBag, item[0])
									elsif item[0] == PBItems::XENOBALL && isXSpecies?(@battlers[1].species) ||
										item[0] != PBItems::XENOBALL && isXSpecies?(@battlers[1].species)
										pbDisplay(_INTL("Non puoi usare questa ball per catturare il\nPokémon!"))
										item[0]=-1
										#return
									end
								end
								if item[0]>0
									if pbRegisterItem(i,item[0],item[1])
										commandDone=true
									end
								end
							end
						elsif cmd==2 # Pokémon
							pkmn=pbSwitchPlayer(i,false,true) {
                pbUpdateTurnTimer()
              }
							if pkmn>=0
								commandDone=true if pbRegisterSwitch(i,pkmn)
							end
						elsif cmd==3   # Run
							run=pbRun(i) 
							if run>0
								commandDone=true
								return
							elsif run<0
								commandDone=true
								side=(pbIsOpposing?(i)) ? 1 : 0
								owner=pbGetOwnerIndex(i)
								if @megaEvolution[side][owner]==i
									@megaEvolution[side][owner]=-1
								end
							end
						elsif cmd==4   # Call
							thispkmn=@battlers[i]
							@choices[i][0]=4   # "Call Pokémon"
							@choices[i][1]=0
							@choices[i][2]=nil
							side=(pbIsOpposing?(i)) ? 1 : 0
							owner=pbGetOwnerIndex(i)
							if @megaEvolution[side][owner]==i
								@megaEvolution[side][owner]=-1
							end
							commandDone=true
						elsif cmd==-1   # Go back to first battler's choice
							@megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
							@megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
							# Restore the item the player's first Pokémon was due to use
							if @choices[0][0]==3 && $PokemonBag && $PokemonBag.pbCanStore?(@choices[0][1])
								$PokemonBag.pbStoreItem(@choices[0][1])
							end
							pbCommandPhase
							return
						end
						break if commandDone
					end
				end
			end
		end
	end

  def pbDefaultChooseEnemyCommand(index)
    our_indices = @doublebattle ? [0, 2] : [0]
    their_indices = @doublebattle ? [1, 3] : [1]
    Log.i("FAINT INFORMATION", "0:#{@battlers[0].isFainted?} 1:#{@battlers[1].isFainted?} 2:#{@battlers[2].isFainted?} 3:#{@battlers[3].isFainted?}")
    # Sends our choices after they have all been locked in.
    if index == their_indices.last
      target_order = CableClub::pokemon_target_order(@client_id)
      for our_index in our_indices
        echoln "SENT CHOICE #{@choices[our_index][0]}:#{@choices[our_index][1]}"
        @connection.send do |writer|
          pkmn = @battlers[our_index]
          writer.sym(:fwd)
          writer.str(@partner_uid)
          writer.sym(:choice)
          writer.int(@choices[our_index][0])
          writer.int(@choices[our_index][1])
          moveindex = pkmn.moves.select {|v| v.id == @choices[our_index][2].id}
          echoln ">>>>>>>>>>>>>>>>>>>>>>>MOVE INFO #{moveindex} - #{@choices[our_index][2]}"
          move = @choices[our_index][2] && pkmn.moves.index(moveindex[0])#pkmn.moves.index(@choices[our_index][2])
          #echoln "#{pkmn.moves} #{@choices[our_index][2].name} #{@choices[our_index][2].id}"
          #echoln "MOVE SEND INFO: #{move}  #{@choices[our_index][2]} #{pkmn.moves.index(@choices[our_index][2])}  #{@choices[our_index][2] && pkmn.moves.index(@choices[our_index][2])}"
          writer.nil_or(:int, move)
          # -1 invokes the RNG, out of order (somehow?!) which causes desync.
          # But this is a single battle, so the only possible choice is the foe.
          if !@doublebattle && @choices[our_index][3] == -1
            @choices[our_index][3] = their_indices[0]
          end
          # Target from their POV.
          our_target = @choices[our_index][3]
          their_target = target_order[our_target] rescue our_target
          writer.int(their_target)
          mega=@megaEvolution[0][0]
          mega^=1 if mega>=0
          writer.int(mega) # mega fix?
          Log.i("INFO","SENT BATTLE CHOICES for MONSTER AT INDEX #{index}")
        end
      end
      frame = 0
      @scene.pbShowWindow(PokeBattle_Scene::MESSAGEBOX)
      cw = @scene.sprites["messagewindow"]
      cw.letterbyletter = false
      begin
        loop do
          frame += 1
          cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
          @scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          if (frame % 60*20 == 0)
            @connection.send do |writer|
              writer.sym(:ping)
            end
          end
          raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
          @connection.updateExp([:forfeit,:sneed,:seed,:choice,:partnerDisconnected],true,
            Proc.new {|time, max| @ui.updateTime("#{max - time}")}) do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} forfeited the match!", @opponent.fullname))
              @decision = 1
              pbAbort
            when :sneed
              print("MA CHE OOOOOOOO")
            
            when :seed
              seed=record.int()
              srand(seed) if @client_id==1

            when :choice
              their_index = their_indices.shift
              partner_pkmn = @battlers[their_index]

              rec1 = record.int
              rec2 = record.int
              recmove = record.nil_or(:int)
              rec3 = record.int
              recmega = record.int

              #case (command = rec1)
              #when 1
              #  pbRegisterMove(their_index,rec2,false)
              #  pbRegisterTarget(their_index,rec3)
              #when 2
              #  pbRegisterSwitch(their_index,rec2)
              #when 3
              #  pbRegisterItem(their_index,rec2,recmove)
              #end


              @choices[their_index][0] = rec1
              @choices[their_index][1] = rec2
              move = recmove
              echoln ">>>>>>>>>>>>>>>>>>>MOVE RECEIVE INFO: #{move}  #{move==nil ? nil : partner_pkmn.moves[move]}  #{move==nil ? nil : move && partner_pkmn.moves[move]}"
              @choices[their_index][2] = move && partner_pkmn.moves[move]
              @choices[their_index][3] = rec3
              @megaEvolution[1][0] = recmega # mega fix?
              return if their_indices.empty?
            
            when :partnerDisconnected
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} disconnected!", opponent.fullname))
              @decision = 1
              @disconnected = true
              pbAbort
            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = true
      end
    end
  end

  def pbDefaultChooseNewEnemy(index, party)
    raise "Expected this to be unused."
  end
end



class PokeBattle_SpectateCableClub < PokeBattle_CableClub

  def initialize(*args)
    @cmdCount = 0
    @randomList = []
    super(*args)
  end

  
  def pbDisplayPaused(message)
    pbDisplayBrief(message)
    pbBattleWait(40) {
      yield if block_given?
    }
  end
  def pbDisplayBrief(msg)
		@scene.pbDisplayMessage(msg,true)
    pbBattleWait(40)
	end

  def pbAwaitReadiness
    return false
  end

  def masterize(position)
    ret = -1
    case position
    when 0
      ret = 1
    when 1
      ret = 0
    when 2 
      ret = 3
    when 3
      ret = 2
    end
    return ret
  end

  def pbRandom(x)
    
    cw = @scene.sprites["messagewindow"]
    cw.letterbyletter = false
    frame = 0
    ret = nil
    while (ret==nil)
      Graphics.update
      Input.update
      @scene.pbFrameUpdate(cw)
      if frame % 60 == 0
        if @connection.can_send?
          @connection.send do |writer|
            writer.sym(:spectaterandom) #Request type
            writer.int($spectateUID) #Max range for random
            writer.int(@randomCounter) #Random counter
            writer.int(@cmdCount)
          end
        end
      end
      frame +=1
      raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
      @connection.updateExp([:srandom,:partnerDisconnected]) do |record|
        case (type = record.sym)
        when :srandom
          ret = record.nil_or(:int)
          
        when :partnerDisconnected
          pbSEPlay("Battle flee")
          isMaster = record.int == 0 
          pbDisplay(_INTL("{1} disconnected!", isMaster ? $Trainer.name : opponent.fullname))
          @decision = 1
          @disconnected = true
          pbAbort
        else
          print "Unknown message: #{type}"
        end
      end
    end
    @randomCounter += 1
    echoln "Called the fucking SPECTATE random! Counter at #{@randomCounter}, Rand is #{ret}"
    return ret
  end

  def canPlayTurn?(log=false)
    for i in 0...4
      echoln "Can play turn? #{i} #{@choices[i][0] == 0 && @battlers[i] != nil}" if log
      return false if @choices[i][0] == 0 && @battlers[i].pokemon != nil
    end
    return true
  end

  def pbCommandPhase
    @scene.pbBeginCommandPhase
		@scene.pbResetCommandIndices
		for i in 0...4   # Reset choices if commands can be shown
			if pbCanShowCommands?(i) || @battlers[i].isFainted?
        echoln "Resetting choice for #{@battlers[i].species} #{i}"
				@choices[i][0]=0
				@choices[i][1]=0
				@choices[i][2]=nil
				@choices[i][3]=-1
			else
				battler=@battlers[i]
				unless !@doublebattle && pbIsDoubleBattler?(i)
					PBDebug.log("[Reusing commands for #{battler.pbThis(true)}]")
				end
			end
		end
		# Reset choices to perform Mega Evolution if it wasn't done somehow
		for i in 0..1
			for j in 0...@megaEvolution[i].length
				@megaEvolution[i][j]=-1 if @megaEvolution[i][j]>=0
			end
		end    

    cw = @scene.sprites["messagewindow"]
    cw.letterbyletter = false
    our_indices = @doublebattle ? [0, 2] : [0]
    their_indices = @doublebattle ? [1, 3] : [1]

    frame = 0

    loop do
      break if canPlayTurn?(false)
      Graphics.update
      Input.update
      if (frame % 10 == 0)
        @connection.send do |writer|
          writer.sym(:getCommandAt)
          writer.int($spectateUID)
          writer.int(@cmdCount)
        end
      end
      frame += 1


      @scene.pbFrameUpdate(cw)
      raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
      @connection.updateExp([:spectateRecord,:forfeit,:random,:seed,:choice,:partnerDisconnected],true,
        Proc.new {|time, max| @ui.updateTime("#{max - time}")}) do |record|
        rec = record.sym
        cmdId = record.int
        isMaster = record.int == 0 
        if cmdId == @cmdCount
          @cmdCount += 1
          type = record.sym
          echoln "Received: #{type}"
          case (type)
          when :forfeit
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} forfeited the match!", @opponent.fullname))
            @decision = 1
            pbAbort
          when :random
            @randomList << record.int
          when :choice

            their_index = isMaster ? our_indices.shift : their_indices.shift
            partner_pkmn = @battlers[their_index]

            rec1 = record.int
            rec2 = record.int
            recmove = record.nil_or(:int)
            rec3 = record.int
            recmega = record.int

            @choices[their_index][0] = rec1
            @choices[their_index][1] = rec2
            move = recmove
            #echoln ">>>>>>>>>>>>>>>>>>>MOVE RECEIVE INFO: #{move}  #{move==nil ? nil : partner_pkmn.moves[move]}  #{move==nil ? nil : move && partner_pkmn.moves[move]}"
            @choices[their_index][2] = move && partner_pkmn.moves[move]
            @choices[their_index][3] = isMaster ? masterize(rec3) : rec3
            @megaEvolution[isMaster ? 0 : 1][0] = isMaster ? recmega ^ 1 : recmega # mega fix?
            
            echoln "RECEIVED CHOICE! #{@choices[their_index]}"
            return if canPlayTurn?(true) #isMaster ? our_indices.empty? : their_indices.empty? #their_indices.empty?
          
          when :partnerDisconnected
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} disconnected!", isMaster ? $Trainer.name : opponent.fullname))
            @decision = isMaster ? 2 : 1 
            @disconnected = true
            pbAbort
          else
            record.flush
          end
        else
          record.flush
        end
      end
    end
  end

  def pbSwitchInBetween(index, lax=false, cancancel=false)
    frame = 0

    cw = @scene.sprites["messagewindow"]
    cw.letterbyletter = false
    our_indices = @doublebattle ? [0, 2] : [0]
    their_indices = @doublebattle ? [1, 3] : [1]
    loop do
      break if @decision != 0
      Graphics.update
      Input.update
      if (frame % 10 == 0)
        @connection.send do |writer|
          writer.sym(:getCommandAt)
          writer.int($spectateUID)
          writer.int(@cmdCount)
        end
      end      
      frame +=1

      @scene.pbFrameUpdate(cw)
      raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::B) && Kernel.pbConfirmMessageSerious("Would you like to disconnect?")
      @connection.updateExp([:spectateRecord,:forfeit,:random,:seed,:choice,:partnerDisconnected],true,
        Proc.new {|time, max| @ui.updateTime("#{max - time}")}) do |record|
        rec = record.sym
        cmdId = record.int
        isMaster = record.int == 0 
        if cmdId == @cmdCount
          @cmdCount += 1
          type = record.sym
          echoln "Received: #{type}"
          case (type)
          when :forfeit
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} forfeited the match!", @opponent.fullname))
            @decision = 1
            pbAbort
          when :random
            @randomList << record.int
          when :switch
            return record.int
          when :partnerDisconnected
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} disconnected!", isMaster ? $Trainer.name : opponent.fullname))
            @decision = isMaster ? 2 : 1 
            @disconnected = true
            pbAbort
          else
            record.flush
          end
        else
          record.flush
        end
      end
    end
  end
end

class PokeBattle_RecordedCableClub < PokeBattle_CableClub
  include PokeBattle_RecordedBattleModule
end

class PokeBattle_BattlePlayerOnline < PokeBattle_CableClub
  include PokeBattle_BattlePlayerModule
end

class PokeBattle_Battler
  alias old_pbFindUser pbFindUser if !defined?(old_pbFindUser)

  # This ensures the targets are processed in the same order.
  def pbFindUser(choice, targets)
    ret = old_pbFindUser(choice, targets)
    if !@battle.client_id.nil?
      order = CableClub::pokemon_order(@battle.client_id)
      targets.sort! {|a, b| order[a.index] <=> order[b.index]}
    end
    return ret
  end
end

class Socket
  def recv_up_to(maxlen, flags = 0)
    retString=""
    buf = "\0" * maxlen
    retval=Winsock.recv(@fd, buf, buf.size, flags)
    SocketError.check if retval == -1
    lastError = Winsock.WSAGetLastError
    echoln "ERROR #{lastError}"
    if lastError == 10053
      retString = "error"
      return retString
    end
    retString+=buf[0,retval]
    return retString
  end

  def write_ready?
    SocketError.check if (ret = Winsock.select(1, 0, [1, @fd].pack("ll"), 0, [0, 0].pack("ll"))) == -1
    return ret != 0
  end
end

class Connection
  class Disconnected < Exception; end
  class ProtocolError < StandardError; end

  def self.open(host, port)
    # XXX: Non-blocking connect.
    TCPSocket.open(host, port) do |socket|
      connection = Connection.new(socket)
      yield connection
    end
  end

  def initialize(socket)
    @socket = socket
    @recv_parser = Parser.new
    @recv_records = []
    @discard_records = 0
  end

  def flush
    @recv_records = []
  end

  def update
    if @socket.ready?
      recvd = @socket.recv_up_to(4096, 0)
      raise Disconnected.new("server disconnected") if recvd.empty?
      @recv_parser.parse(recvd) {|record| @recv_records << record}
    end
    # Process at most one record so that any control flow in the block doesn't cause us to lose records.
    if !@recv_records.empty?
      echoln @recv_records
      record = @recv_records.shift
      if record.disconnect?
        reason = record.str() rescue "unknown error"
        raise Disconnected.new(reason)
      end
      if @discard_records == 0
        begin
          yield record
        else
          print ProtocolError.new("Unconsumed input: #{record}") if !record.empty?
        end
      else
        @discard_records -= 1
      end
    end
  end

  def updateExp(expected, timeoutCheck = false, counterProc = nil)
    if timeoutCheck
      CableClub.timeoutCounter += 1
      if (CableClub.timeoutCounter % 300 == 0)
        echoln "Increasing timeout timer... #{CableClub.timeoutCounter / 300}"
      end
      if counterProc != nil
        counterProc.call(CableClub.timeoutCounter,CableClub.maxTimeOut)
      end
    end
    if @socket.ready?
      recvd = @socket.recv_up_to(4096, 0)
      raise Disconnected.new("server disconnected") if recvd.empty?
      raise Disconnected.new("error") if recvd == "error"
      @recv_parser.parse(recvd) {|record| @recv_records << record}
    end
    # Process at most one record so that any control flow in the block doesn't cause us to lose records.
    if !@recv_records.empty?
      recv_clone = @recv_records.clone
      recv_clone = recv_clone.shift
      record = @recv_records.shift
      if record.disconnect?
        reason = record.str() rescue "unknown error"
        raise Disconnected.new(reason)
      end
      if @discard_records == 0
        ignored = false;
        begin
          if (!expected.include?(recv_clone.fields.last.to_sym))
            ignored = true
            Log.i("INFO-IGNORED","Ignored message with sym field #{record.fields.last.to_sym}")
          else 
            yield record
          end
        else
          print ProtocolError.new("Unconsumed input: #{record}") if !record.empty? && ignored == false
        end
      else
        @discard_records -= 1
      end
    end
  end

  def can_send?
    return @socket.write_ready?
  end

  def send
    # XXX: Non-blocking send.
    # but note we don't update often so we need some sort of drained?
    # for the send buffer so that we can delay starting the battle.
    writer = RecordWriter.new
    yield writer
    begin 
      @socket.send(writer.line!)
    rescue Errno::ECONNABORTED
      print "FUCK YOU BITCH"
    end
  end

  def discard(n)
    raise "Cannot discard #{n} messages." if n < 0
    @discard_records += n
  end
end

class Parser
  def initialize
    @buffer = ""
  end

  def parse(data)
    return if data.empty?
    lines = data.split("\n", -1)
    lines[0].insert(0, @buffer)
    @buffer = lines.pop
    lines.each do |line|
      yield RecordParser.new(line) if !line.empty?
    end
  end
end

class RecordParser
  attr_accessor :fields

  def initialize(data)
    @fields = []
    field = ""
    escape = false
    # each_char and chars don't exist.
    for i in (0...data.length)
      char = data[i].chr
      if char == "," && !escape
        @fields << field
        field = ""
      elsif char == "\\" && !escape
        escape = true
      else
        field += char
        escape = false
      end
    end
    @fields << field
    @fields.reverse!
  end

  def empty?; return @fields.empty? end

  def disconnect?
    if @fields.last == "disconnect"
      @fields.pop
      return true
    else
      return false
    end
  end

  def nil_or(t)
    raise Connection::ProtocolError.new("Expected nil or #{t}, got EOL") if @fields.empty?
    if @fields.last.empty?
      @fields.pop
      return nil
    else
      return self.send(t)
    end
  end

  def bool
    raise Connection::ProtocolError.new("Expected bool, got EOL") if @fields.empty?
    field = @fields.pop
    if field == "true"
      return true
    elsif field == "false"
      return false
    else
      raise Connection::ProtocolError.new("Expected bool, got #{field}")
    end
  end

  def int
    raise Connection::ProtocolError.new("Expected int, got EOL") if @fields.empty?
    field = @fields.pop
    begin
      return Integer(field)
    rescue
      raise Connection::ProtocolError.new("Expected int, got #{field}")
    end
  end

  def str
    raise Connection::ProtocolError.new("Expected str, got EOL") if @fields.empty?
    @fields.pop
  end

  def sym
    raise Connection::ProtocolError.new("Expected sym, got EOL") if @fields.empty?
    @fields.pop.to_sym
  end

  def to_s; @fields.reverse.join(", ") end

  def flush;while(@fields.length > 0);@fields.pop;end;end
end

class RecordWriter
  def initialize
    @fields = []
  end

  def line!
    line = @fields.map {|field| escape!(field)}.join(",")
    line += "\n"
    @fields = []
    return line
  end

  def escape!(s)
    s.gsub!("\\", "\\\\")
    s.gsub!(",", "\,")
    return s
  end

  def nil_or(t, o)
    if o.nil?
      @fields << ""
    else
      self.send(t, o)
    end
  end

  def bool(b); @fields << b.to_s end
  def int(i); @fields << i.to_s end
  def str(s) @fields << s end
  def sym(s); @fields << s.to_s end
end
