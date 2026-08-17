#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#  
#===============================================================================
class Scene_Map
  
  attr_accessor(:surfProc)
  
  def spriteset
    for i in @spritesets.values
      return i if i.map==$game_map
    end
    return @spritesets.values[0]
  end

  def disposeSpritesets
    return if !@spritesets
    for i in @spritesets.keys
      if @spritesets[i]
        @spritesets[i].dispose
        @spritesets[i]=nil
      end
    end
    @spritesets.clear
    @spritesets={}
  end

  def createSpritesets
    @spritesets={}
    for map in $MapFactory.maps
      @spritesets[map.map_id]=Spriteset_Map.new(map)
    end
    $MapFactory.setSceneStarted(self)
    updateSpritesets
  end

  def updateMaps
    for map in $MapFactory.maps
      map.update
    end
    $MapFactory.updateMaps(self)
  end

  def updateSpritesets
    @spritesets={} if !@spritesets
    keys=@spritesets.keys.clone
    for i in keys
     if !$MapFactory.hasMap?(i)
       @spritesets[i].dispose if @spritesets[i]
       @spritesets[i]=nil
       @spritesets.delete(i)
     else
       @spritesets[i].update
     end
    end
    for map in $MapFactory.maps
      if !@spritesets[map.map_id]
        @spritesets[map.map_id]=Spriteset_Map.new(map)
      end
    end
    Events.onMapUpdate.trigger(self)
  end

  def main
		$DEBUG=false
    @surfProc = nil
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
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

  def miniupdate
    $PokemonTemp.miniupdate=true if $PokemonTemp
    loop do
      updateMaps
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    $PokemonTemp.miniupdate=false if $PokemonTemp
  end

  def update
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
           $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end
    if Input.trigger?(Input::C)
      unless pbMapInterpreterRunning?
        $PokemonTemp.hiddenMoveEventCalling=true
      end
    end
    # SCELTA POKEMON CHE SEGUE
    '''
    if Input.trigger?(Input::X) && $Trainer.party.size > 1
      $Trainer.party.push($Trainer.party.delete_at(0))
      $PokemonTemp.dependentEvents.refresh_sprite(true) if $game_switches[Toggle_Following_Switch]==true
    end
    if Input.trigger?(Input::Z) && $Trainer.party.size > 1
      $Trainer.party.insert(0,$Trainer.party.pop)
      $PokemonTemp.dependentEvents.refresh_sprite(true) if $game_switches[Toggle_Following_Switch]==true
    end
    '''
    
    # FOLLOW UTILITIES
    #if $Trainer != nil
    #  if pbHasSpecies?(:TRISHOUT) || pbHasSpecies?(:SHULONG) || pbHasSpecies?(:SHYLEON)
    #    if $game_switches[204]==false && $game_switches[205]==false
    #      $PokemonTemp.dependentEvents.refresh_sprite(false)
    #    end
    #  else
    #    $PokemonTemp.dependentEvents.remove_sprite
    #  end
    #end
    # END FOLLOW UTILITIES
    
    # FINE
    if $Trainer
      if $starter==nil && $Trainer.storedStarter != nil
        $starter = $Trainer.storedStarter
      end
      
      if $starter != nil
        $Trainer.setStored($starter)
      end
    end
    
    if !$achievements["Fanatico"].completed
      names=0
      for p in 0...$Trainer.party.length
        break if $Trainer.party[p].species != PBSpecies::WEEDLE
        names+=1
      end
      if names==6
        $achievements["Fanatico"].progress+=1
      end
    end
    
    #if (Input.trigger?(Input::ALT))
    #  pbOnlineLobby
    #end
    
    if Input.trigger?(Input::B)
      unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $game_switches[802]
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
      if $game_switches[802]
        Kernel.pbMessage(_INTL("Non puoi usare il menù quando sei in un Nido Pokémon."))
      end
    end
    if ($MKXP ? Input.triggerex?(:R) : Input.triggerex?(0x52)) && $game_switches[943] #reset palestra ritmo
      pbCommonEvent(10)
    end
    #PokeWES shortcuts
    if !$game_switches[802] && !$game_switches[1351] && !$game_switches[997] && !(pbInSafari? || pbInBugContest?)
      #MN
      if Input.trigger?(Input::R)
        unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $Trainer.pokewes==false
          oldproc = @surfProc
          pbFadeOutIn(99999) {
              MNScene.new(false,self)
          }
          if @surfProc != nil && oldproc != @surfProc
            @surfProc.call
            @surfProc = Proc.new {echoln "emptyproc"}
          end
        end
      end
      # Achievements
      if Input.trigger?(Input::X)
        unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $Trainer.pokewes==false
          pbFadeOutIn(99999) {
              AchievementsScreen.new
          }
        end
      end
      #Pokedex
      if Input.trigger?(Input::Y) && $Trainer.pokedex
        unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $Trainer.pokewes==false
          pbFadeOutIn(99999) {
             scene=DexMain.new(0)
             scene.inputHandle
             #screen=PokemonPokedex.new(scene)
             #screen.pbStartScreen
          }
        end
      end
      #Map
      if Input.trigger?(Input::Z)
        unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $Trainer.pokewes==false
          pbFadeOutIn(99999) {
              pbShowMap(-1,false)
          }
        end
      end
    end
    if Input.trigger?(Input::F5)
      unless pbMapInterpreterRunning? or $game_player.moving?
        $PokemonTemp.keyItemCalling = true if $PokemonTemp
      end
    end
    if defined?(XENOVERSE_SAVE_EDITOR_ENABLED) && XENOVERSE_SAVE_EDITOR_ENABLED &&
       defined?(XENOVERSE_SAVE_EDITOR_HOTKEY) &&
       Input.trigger?(XENOVERSE_SAVE_EDITOR_HOTKEY)
      unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving? or $game_switches[802]
        pbXenoverseSaveEditorFromMap
      end
    end
    if $DEBUG and Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end
    unless $game_player.moving?
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      elsif $PokemonTemp && $PokemonTemp.keyItemCalling
        $PokemonTemp.keyItemCalling=false
        $game_player.straighten
        Kernel.pbUseKeyItem
      elsif $PokemonTemp && $PokemonTemp.hiddenMoveEventCalling
        $PokemonTemp.hiddenMoveEventCalling=false
        $game_player.straighten
        Events.onAction.trigger(self)
      end
    end
  end

  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    $game_map.update
  end

  def call_menu
    $game_temp.menu_calling = false
    $game_player.straighten
    $game_map.update
    sscene=PokemonMenu_Scene.new
    sscreen=PokemonMenu.new(sscene) 
    sscreen.pbStartPokemonMenu
  end

  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE()
    $game_player.straighten
    $scene = Scene_Debug.new
  end

  def autofade(mapid)
    playingBGM=$game_system.playing_bgm
    playingBGS=$game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map=pbLoadRxData(sprintf("Data/Map%03d", mapid))
    if playingBGM && map.autoplay_bgm
      if (PBDayNight.isNight?(pbGetTimeNow) rescue false)
        if playingBGM.name!=map.bgm.name && playingBGM.name!=map.bgm.name+"n"
          pbBGMFade(0.8)
        end
      else
        if playingBGM.name!=map.bgm.name
          pbBGMFade(0.8)
        end
      end
    end
    if playingBGS && map.autoplay_bgs
      if playingBGS.name!=map.bgs.name
        pbBGMFade(0.8)
      end
    end
    Graphics.frame_reset
  end

  def transfer_player(cancelVehicles=true)
    $game_temp.player_transferring = false
    if cancelVehicles
      Kernel.pbCancelVehicles($game_temp.player_new_map_id)
    end
    autofade($game_temp.player_new_map_id)
    pbBridgeOff
    if $game_map.map_id != $game_temp.player_new_map_id
      $MapFactory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
    when 2
      $game_player.turn_down
    when 4
      $game_player.turn_left
    when 6
      $game_player.turn_right
    when 8
      $game_player.turn_up
    end
    $game_player.straighten
    $game_map.update
    disposeSpritesets
    GC.start
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
end
