#===============================================================================
#  Persistent system preferences
#-------------------------------------------------------------------------------
#  The volume and Auto Run preferences are kept separately from the gameplay
#  save so changing them does not depend on saving the current story position
#  before closing.
#===============================================================================
MASTER_VOLUME_LEVELS = [100,90,80,70,60,50,40,30,20,10,0] unless defined?(MASTER_VOLUME_LEVELS)
MASTER_VOLUME_LABELS = ["100%","90%","80%","70%","60%","50%","40%","30%","20%","10%","Off"] unless defined?(MASTER_VOLUME_LABELS)
MASTER_VOLUME_SETTINGS_FILE = "GameSettings.rxdata" unless defined?(MASTER_VOLUME_SETTINGS_FILE)

def pbNormalizeMasterVolume(value)
  return 100 if !value.is_a?(Numeric)
  value=value.to_i
  value=0 if value<0
  value=100 if value>100
  return value
end

def pbCanonicalMasterVolume(value)
  value=pbNormalizeMasterVolume(value)
  return value if MASTER_VOLUME_LEVELS.include?(value)
  # The previous menu offered 75% and 25%. Snap unsupported saved values
  # downward so migrating a setting never makes the audio louder.
  return (value/10)*10
end

def pbMasterVolumeScale(volume)
  return volume if !volume.is_a?(Numeric)
  master=($PokemonSystem) ? $PokemonSystem.mastervolume : 100
  return volume if master>=100
  scaled=(volume.to_f*master/100.0).round
  scaled=0 if scaled<0
  scaled=100 if scaled>100
  return scaled
end

class PokemonSystem
  def mastervolume
    value=pbCanonicalMasterVolume(@mastervolume)
    # Also migrate a legacy value embedded in an older Game.rxdata save when
    # there is no separate GameSettings.rxdata file to rewrite.
    @mastervolume=value if @mastervolume.is_a?(Numeric) && @mastervolume!=value
    return value
  end

  def mastervolume=(value)
    @mastervolume=pbCanonicalMasterVolume(value)
  end
end

def pbMasterVolumeSettingsPath
  return RTP.getSaveFileName(MASTER_VOLUME_SETTINGS_FILE)
end

def pbMasterVolumeOptionIndex
  return 0 if !$PokemonSystem
  index=MASTER_VOLUME_LEVELS.index($PokemonSystem.mastervolume)
  return index || 0
end

def pbApplyMasterVolume
  return false if !$game_system || !$game_system.respond_to?(:getPlayingBGM)
  bgm=$game_system.getPlayingBGM
  if bgm && bgm.name && bgm.name!=""
    begin
      position=Audio.bgm_position
      $game_system.bgm_play_internal(bgm,position)
    rescue
      $game_system.bgm_play(bgm) rescue nil
    end
  end
  bgs=$game_system.getPlayingBGS
  $game_system.bgs_play(bgs) if bgs && bgs.name && bgs.name!=""
  return true
end

def pbPersistentSettingsHash
  settings={:mastervolume=>$PokemonSystem.mastervolume}
  if $PokemonSystem.respond_to?(:autorun)
    settings[:autorun]=$PokemonSystem.autorun
  else
    # 145_PSystem_System.rb loads this file before 228_NewOptions.rb adds the
    # Auto Run accessors. Preserve a value already loaded during that window.
    autorun=$PokemonSystem.instance_variable_get(:@autorun)
    settings[:autorun]=autorun if !autorun.nil?
  end
  return settings
end

def pbSavePersistentSettings
  return false if !$PokemonSystem
  path=pbMasterVolumeSettingsPath
  temp=path+".tmp"
  backup=path+".bak"
  begin
    File.open(temp,"wb"){|f|
      Marshal.dump(pbPersistentSettingsHash,f)
    }
    if safeExists?(path)
      File.delete(backup) rescue nil
      File.rename(path,backup)
    end
    File.rename(temp,path)
    return true
  rescue
    File.delete(temp) rescue nil
    return false
  end
end

def pbSavePersistentAudioSettings
  return pbSavePersistentSettings
end

def pbLoadPersistentAudioSettings(apply=true)
  return false if !$PokemonSystem
  for path in [pbMasterVolumeSettingsPath,pbMasterVolumeSettingsPath+".bak"]
    next if !safeExists?(path)
    begin
      value=nil
      File.open(path,"rb"){|f| value=Marshal.load(f) }
      mastervolume=value
      hasAutorun=false
      autorun=nil
      if value.is_a?(Hash)
        mastervolume=value[:mastervolume]
        if value.has_key?(:autorun)
          autorun=value[:autorun]
          hasAutorun=true
        end
      end
      loaded=false
      if mastervolume.is_a?(Numeric)
        original=pbNormalizeMasterVolume(mastervolume)
        canonical=pbCanonicalMasterVolume(mastervolume)
        $PokemonSystem.mastervolume=canonical
        loaded=true
      end
      if hasAutorun
        autorun=(autorun==1 || autorun==true) ? 1 : 0
        if $PokemonSystem.respond_to?(:autorun=)
          $PokemonSystem.autorun=autorun
        else
          # The settings file is loaded before 228_NewOptions.rb is evaluated.
          $PokemonSystem.instance_variable_set(:@autorun,autorun)
        end
        loaded=true
      end
      if loaded
        pbApplyMasterVolume if apply
        # Rewrite legacy volume values while retaining all persistent settings.
        pbSavePersistentSettings if mastervolume.is_a?(Numeric) && canonical!=original
        return true
      end
    rescue
    end
  end
  pbApplyMasterVolume if apply
  return false
end

def pbSetMasterVolumeOption(index)
  return if !$PokemonSystem
  $PokemonSystem.mastervolume=MASTER_VOLUME_LEVELS[index] || MASTER_VOLUME_LEVELS[0]
  pbApplyMasterVolume
  pbSavePersistentSettings
end

# Scale every RGSS audio channel, including title-screen playback that occurs
# before Game_System has been attached to the scene.
module Audio
  class << self
    alias master_volume_bgm_play bgm_play
    alias master_volume_bgs_play bgs_play
    alias master_volume_me_play me_play
    alias master_volume_se_play se_play

    def bgm_play(name,volume=80,pitch=100,position=nil)
      volume=pbMasterVolumeScale(volume)
      if position.nil?
        return master_volume_bgm_play(name,volume,pitch)
      end
      begin
        return master_volume_bgm_play(name,volume,pitch,position)
      rescue ArgumentError
        return master_volume_bgm_play(name,volume,pitch)
      end
    end

    def bgs_play(name,volume=80,pitch=100)
      return master_volume_bgs_play(name,pbMasterVolumeScale(volume),pitch)
    end

    def me_play(name,volume=80,pitch=100)
      return master_volume_me_play(name,pbMasterVolumeScale(volume),pitch)
    end

    def se_play(name,volume=80,pitch=100)
      return master_volume_se_play(name,pbMasterVolumeScale(volume),pitch)
    end
  end
end
