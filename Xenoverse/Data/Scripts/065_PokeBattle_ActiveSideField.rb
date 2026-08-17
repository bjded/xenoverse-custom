begin
  class PokeBattle_ActiveSide
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::Switch]      = {}
      @effects[PBEffects::LightScreen] = 0
      @effects[PBEffects::LuckyChant]  = 0
      @effects[PBEffects::Mist]        = 0
      @effects[PBEffects::Reflect]     = 0
      @effects[PBEffects::Safeguard]   = 0
      @effects[PBEffects::Spikes]      = 0
      @effects[PBEffects::StealthRock] = false
			@effects[PBEffects::StickyWeb]   = false
      @effects[PBEffects::Tailwind]    = 0
      @effects[PBEffects::ToxicSpikes] = 0
      @effects[PBEffects::VelvetScales] = false
      @effects[PBEffects::Hawthorns] = false
      @effects[PBEffects::ScorchedAshes] = false
      @effects[PBEffects::Benevolence] = 0
      @effects[PBEffects::SupremeOverlord] = 0
    end
  end



  class PokeBattle_ActiveField
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::Gravity]     = 0
      @effects[PBEffects::MagicRoom]   = 0
			@effects[PBEffects::IonDeluge]   = false
      @effects[PBEffects::TrickRoom]   = 0
      @effects[PBEffects::AcidRain]   = false
#     @effects[PBEffects::WonderRoom]  = 0
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end