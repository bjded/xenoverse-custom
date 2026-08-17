#===============================================================================
# ■ Speed up script by KleinStudio
#   Press F key during debug mode and fly!
# http://kleinstudio.deviantart.com
#===============================================================================
Speed_Up_Framerate=300

module Input
  if !defined?(kleinfast_update)
    class << self
      alias kleinfast_update update
    end
  end

  def self.update
    if $DEBUG
      #if self.triggerex?(0x47)
      #  $achievements["Acchiappali"].progress=1
      #  $achievements["Ultraball"].progress=1 if !$achievements["Ultraball"].completed
      #  $achievements["Hipster"].progress=1 if !$achievements["Hipster"].completed
      #  $achievements["Spettri"].progress=1 if !$achievements["Spettri"].completed
      #  $achievements["Nemici"].progress=1 if !$achievements["Nemici"].completed
      #end
      
      if self.pressex?(0x46)
        Graphics.frame_rate=Speed_Up_Framerate if !@setFast
        @setFast=true
      else
        Graphics.frame_rate=40 if @setFast
        @setFast=false
      end
    end
    kleinfast_update
  end
end
