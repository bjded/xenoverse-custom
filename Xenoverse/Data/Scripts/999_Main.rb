
class Scene_DebugIntro
  def main
		$DEBUG=true
    Graphics.transition(0)
    if File.exists?("Data/LastSave.dat")
      lastsave=pbGetLastPlayed
      if lastsave[1].to_s=="true"
        if lastsave[0]==0 || lastsave[0]==1
          savefile=RTP.getSaveFileName("Game_autosave.rxdata")
        else  
          savefile = RTP.getSaveFileName("Game_#{lastsave[0]}_autosave.rxdata")
        end 
      elsif lastsave[0]==0 || lastsave[0]==1
        savefile=RTP.getSaveFileName("Game.rxdata")
      else
        savefile = RTP.getSaveFileName("Game_#{lastsave[0]}.rxdata")
      end
      lastsave[1]=nil if lastsave[1]!="true"
      if safeExists?(savefile)
        sscene=PokemonLoadScene.new
        sscreen=PokemonLoad.new(sscene)
        sscreen.pbStartLoadScreen(lastsave[0].to_i,lastsave[1],"Save File #{lastsave[0]}")
      else
        sscene=PokemonLoadScene.new
        sscreen=PokemonLoad.new(sscene)
        sscreen.pbStartLoadScreen
      end
    else
      sscene=PokemonLoadScene.new
      sscreen=PokemonLoad.new(sscene)
      sscreen.pbStartLoadScreen
    end
    Graphics.freeze
  end
end



def pbCallTitle #:nodoc:
  $DEBUG=false
  if $MKXP
    System.set_window_title("Xenoverse - Per Aspera Ad Astra")
  end
  Graphics.transition(0)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  weedleLogo = Sprite.new(viewport)
  weedleLogo.bitmap = pbBitmap("Graphics/Titles/intro1.png")
  weedleLogo.opacity = 0
  25.times do
    Graphics.update
    weedleLogo.opacity+=255/25
  end
  pbWait(18)
  25.times do
    Graphics.update
    weedleLogo.opacity-=255/25
  end
  weedleLogo.dispose
  Graphics.transition(20)
  pbWait(18)
  Graphics.play_movie("Graphics/Movies/intro.avi") unless defined?($MKXP)#for joiplay compatibility
	if $DEBUG
    return Scene_DebugIntro.new
  else
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    return Scene_Intro.new(['intro1'], 'splash') 
  end
end

def mainFunction #:nodoc:
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug #:nodoc:
  begin
    getCurrentProcess=Win32API.new("kernel32.dll","GetCurrentProcess","","l")
    setPriorityClass=Win32API.new("kernel32.dll","SetPriorityClass",%w(l i),"")
    setPriorityClass.call(getCurrentProcess.call(),32768) # "Above normal" priority class
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $game_system        = Game_System.new
    setScreenBorderName("border") # Sets image file for the border
    Graphics.update
    #Win32API.new('NoDeactivate.dll', 'BeginMonitor', '', '').call
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(20)
  rescue Hangup
    pbEmergencySave
    raise
  ensure 
    #Win32API.new('NoDeactivate.dll', 'EndMonitor', '', '').call
  end
end

loop do
  retval=mainFunction
  if retval==0 # failed
    loop do
      Graphics.update
    end
  elsif retval==1 # ended successfully
    break
  end
end