#===============================================================================
#  Persistent master volume
#-------------------------------------------------------------------------------
#  The volume preference is kept separately from the gameplay save so changing
#  it does not depend on saving the current story position before closing.
#===============================================================================
MASTER_VOLUME_LEVELS = [100,75,50,25,0] unless defined?(MASTER_VOLUME_LEVELS)
MASTER_VOLUME_LABELS = ["100%","75%","50%","25%","Off"] unless defined?(MASTER_VOLUME_LABELS)
MASTER_VOLUME_SETTINGS_FILE = "GameSettings.rxdata" unless defined?(MASTER_VOLUME_SETTINGS_FILE)

def pbNormalizeMasterVolume(value)
  return 100 if !value.is_a?(Numeric)
  value=value.to_i
  value=0 if value<0
  value=100 if value>100
  return value
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
    return pbNormalizeMasterVolume(@mastervolume)
  end

  def mastervolume=(value)
    @mastervolume=pbNormalizeMasterVolume(value)
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

def pbSavePersistentAudioSettings
  return false if !$PokemonSystem
  path=pbMasterVolumeSettingsPath
  temp=path+".tmp"
  backup=path+".bak"
  begin
    File.open(temp,"wb"){|f|
      Marshal.dump({:mastervolume=>$PokemonSystem.mastervolume},f)
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

def pbLoadPersistentAudioSettings(apply=true)
  return false if !$PokemonSystem
  for path in [pbMasterVolumeSettingsPath,pbMasterVolumeSettingsPath+".bak"]
    next if !safeExists?(path)
    begin
      value=nil
      File.open(path,"rb"){|f| value=Marshal.load(f) }
      value=value[:mastervolume] if value.is_a?(Hash)
      if value.is_a?(Numeric)
        $PokemonSystem.mastervolume=value
        pbApplyMasterVolume if apply
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
  pbSavePersistentAudioSettings
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
