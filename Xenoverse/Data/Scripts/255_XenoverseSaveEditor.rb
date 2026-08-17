# Xenoverse in-game save editor.
#
# This exposes the existing debug editors while the game is running, so all
# changes go through the game's normal Ruby objects and save routines.

XENOVERSE_SAVE_EDITOR_ENABLED = true unless defined?(XENOVERSE_SAVE_EDITOR_ENABLED)
XENOVERSE_SAVE_EDITOR_HOTKEY = Input::F9 unless defined?(XENOVERSE_SAVE_EDITOR_HOTKEY)

def pbXenoversePartyEditor
  old_debug=$DEBUG
  begin
    $DEBUG=true
    scene=PokemonScreen_Scene.new
    screen=PokemonScreen.new(scene,$Trainer.party)
    screen.pbPokemonScreen
  ensure
    $DEBUG=old_debug
  end
end

def pbXenoverseBoxEditor
  old_debug=$DEBUG
  begin
    $DEBUG=true
    scene=PokemonStorageScene.new
    screen=PokemonStorageScreen.new(scene,$PokemonStorage)
    # Move mode permits editing party Pokemon, box Pokemon, and their location.
    screen.pbStartScreen(2)
  ensure
    $DEBUG=old_debug
  end
end

def pbXenoverseSaveEditor(menu_scene)
  commands=[
    _INTL("Party Pokemon"),
    _INTL("PC Boxes"),
    _INTL("Cancel")
  ]
  loop do
    command=menu_scene.pbShowCommands(commands)
    case command
    when 0
      pbFadeOutIn(99999) { pbXenoversePartyEditor }
    when 1
      pbFadeOutIn(99999) { pbXenoverseBoxEditor }
    else
      break
    end
  end
end

def pbXenoverseSaveEditorFromMap
  commands=[
    _INTL("Party Pokemon"),
    _INTL("PC Boxes"),
    _INTL("Cancel")
  ]
  help=[
    _INTL("Edit Pokemon in the current party."),
    _INTL("Edit boxed Pokemon and move them between boxes and the party."),
    _INTL("Return to the game.")
  ]
  command=Kernel.pbShowCommandsWithHelp(nil,commands,help,-1)
  case command
  when 0
    pbFadeOutIn(99999) { pbXenoversePartyEditor }
  when 1
    pbFadeOutIn(99999) { pbXenoverseBoxEditor }
  end
end
