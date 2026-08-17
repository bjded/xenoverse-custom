################################################################################
# Treasure Hook mini-game
# By AGSoldier
################################################################################

HOOKMON=[PBSpecies::MAGIKARP,
         PBSpecies::KIDOON,
         PBSpecies::MAGIKARP,
         PBSpecies::KIDOON,
         PBSpecies::MAGIKARP,
         PBSpecies::MAGIKARP,
         PBSpecies::MAGIKARP,
         PBSpecies::MAGIKARP,
         PBSpecies::MAGIKARP,
         PBSpecies::MAGIKARP,
        ]

# Classe per il background animato
class Background < BitmapSprite
  
  attr_accessor :image # Reference all'immagine
  attr_accessor :y # Y dello sfondo. Viene usata nell'update esterno
 
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(Graphics.width, Graphics.height, @viewport)
    @y = 0
    @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/bg"))
  end
 
  def update
    self.bitmap.clear
    self.bitmap.blt(0, @y, @image.bitmap, Rect.new(0, 0, @image.width, @image.height))
  end
 
end
 
# Classe sprite per il gancio
class Hook < BitmapSprite
 
  attr_accessor :hits # "Vita" del gancio. Quando arriva a 3 si rompe
  attr_accessor :position # Coordinate del gancio
  attr_accessor :depth # Profondita' attuale del gancio
  attr_accessor :velocity # Velocita' di discesa del gancio
  attr_accessor :image # Reference all'immagine
 
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(Graphics.width, Graphics.height, @viewport)
    @hits = 0
    @corsia = 3
    @position = [Graphics.width / 6 * @corsia - 24, 0]
    @depth = 0
    @velocity = 3
    @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/hook"))
    update
  end
 
  def update
    self.bitmap.clear
    self.bitmap.blt(@position[0], @position[1], @image.bitmap, Rect.new(0, 0, @image.width, @image.height))
  end
 
  def moveLeft
    if @corsia > 1
      @corsia -= 1
      @position[0] = Graphics.width / 6 * @corsia - @image.width / 2
    end
  end
 
  def moveRight
    if @corsia < 5
      @corsia += 1
      @position[0] = Graphics.width / 6 * @corsia - @image.width / 2
    end
  end
 
end
 
# Classe sprite per il tesoro.
class Treasure < BitmapSprite
 
  # Lista di reward fissi possibili da trovare nel tesoro. Sa sostituire con
  # un array di reward da aggiungere al costruttore, i quali cambieranno a 
  # seconda della mappa in cui ci si trova
  REWARDS = [ :POTION,     #OLD REWARDS
              :POKEBALL,
              :RARECANDY ]
              
  REWARDSCOMMON = [:PEARL,:DIVEBALL,:FLOATSTONE,:DAMPROCK,:SUPERPOTION]
  REWARDSUNCOMMON = [:BIGPEARL,:PPUP,:SHELLBELL,:HYPERPOTION]
  REWARDSRARE = [:RARECANDY,:PPMAX,:MAXPOTION]
              
  attr_accessor :reward # Reward contenuto nel tesoro
  attr_accessor :position # Posizione (x e y) dell tesoro
  attr_accessor :image # Reference all'immagine
 
  def initialize(hook, depth)
    @position = [Graphics.width / 6 * (1 + rand(5)) - 24, Graphics.height]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(Graphics.width, Graphics.height, @viewport)
    roll = rand(100)
    rewardpool = roll<=45 ? (roll <=10 ? REWARDSRARE : REWARDSUNCOMMON ) : REWARDSCOMMON
    @reward = getConst(PBItems, rewardpool[rand(rewardpool.length)])
    @hook = hook
    @depth = depth
    if $game_switches[170]==false
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/treasure"))
    else
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/cucchiaio d'oro"))
    end
    update
  end
 
  def update
    self.bitmap.clear
    if @hook.depth + 48 > @depth - Graphics.height + 60 &&
       @hook.depth < @depth - Graphics.height + 60
      @position[1] -= @hook.velocity
    end
    self.bitmap.blt(@position[0], @position[1], @image.bitmap, $game_switches[170] == false ? Rect.new(0, 0, 62, 62) : Rect.new(0, 0, 48, 48))
  end
 
end
 
# Classe sprite per gli ostacoli. Questi possono essere di tre tipi: Poke'mon,
# rocce o alghe. Quando il gancio colpisce un Poke'mon, partira' una battaglia;
# quando il gancio colpisce una roccia il gioco terminera'; quando il gancio
# si incaglia su delle alghe, la sua utilita' scendera', se si colpisce 3 volte
# un alga il gioco terminera'
class Obstacle < BitmapSprite
 
  attr_accessor :position # Posizione (x e y) del ostacolo
  attr_accessor :type # Tipo di ostacolo (0: Pokémon, 1: scoglio, 2: alga, 3: doppia alga)
  attr_accessor :image # Reference all'immagine
  attr_accessor :hit # Flag per sapere se l'alga è già stata colpita
 
  def initialize(hook, depth, x, y, type)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(Graphics.width, Graphics.height, @viewport)
    @hook = hook
    @depth = depth
    @type = type
    @direction = rand(2)
    @velocity = 1 + rand(3)
    if @direction == 0
      @direction  = -1
    end
    @hit = false
    if @type == 0 && $game_switches[170]==false
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/pokemon"))
    elsif @type == 0 && $game_switches[170]==true #Grafica Honchen per prova
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/honcen")) #HONCHEN
    elsif @type == 1
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/scoglio"))
    elsif type == 2
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/alga"))
    else 
      @image = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/alga2"))
    end
    @position = [Graphics.width / 6 * x - @image.width / 2, y]
    update
  end
 
  def update
    self.bitmap.clear
    if @hook.depth < @depth - Graphics.height + 60
    @position[1] -= @hook.velocity
    end
    if @type == 0
      if @position[0] <= 0 || @position[0] >= Graphics.width - image.width
        @direction *= -1
      end
      @position[0] += @direction * @velocity
    end
    self.bitmap.blt(@position[0], @position[1], image.bitmap, Rect.new(0, 0, image.width, image.height))
  end
 
end
 
# Classe principale dove si svolge l'azione di gioco
class TreasureHookScene
 
  # Aggiorna tutti gli sprite presenti sul video
  def update
    pbUpdateBackground
    pbUpdateSpriteHash(@sprites)
  end
 
  def pbStartScene
    # Definisco le variabili del gioco
    @depth = 2500 + rand(2500)
   
    # Preparo gli elementi a schermo
    @sprites = {}
    @sprites["bg"] = Background.new
    @sprites["hook"] = Hook.new
    #@sprites["fondale"] = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/fondale"))
    #@sprites["amo"] = AnimatedBitmap.new(_INTL("Graphics/Pictures/TreasureHook/amo"))
   
    # Creo gli ostacoli
    distance = Graphics.height
    id = 1
    pokemon = rand(2)
    while distance < @depth - Graphics.height / 2 do
      if pokemon == 0
        pattern = Array.new(5) {rand(2)}
        if !pattern.include? 0
          pattern[rand(5)] = 0
        end
        for i in 0..pattern.length
          if pattern[i] == 1
            @sprites["obs#{id}"] = Obstacle.new(@sprites["hook"], @depth, i + 1,
                                    distance, 1 + rand(3))
            id += 1
          end
        end
      else
        @sprites["obs#{id}"] = Obstacle.new(@sprites["hook"], @depth, 1 + rand(5),
                                distance, 0)
        id += 1
      end
      distance += 150 + rand(50)
      pokemon = rand(2)
    end
    
    @sprites["obs#{id}"] = Treasure.new(@sprites["hook"], @depth)
    update
    $game_system.bgm_memorize
    pbBGMPlay("SURF_PESCA",70)
    pbFadeInAndShow(@sprites)
  end
   
  # Metodo principale della classe. Contiene il loop di gioco e verra'
  # richiamato per far partire il mini-gioco
  def pbMain
    loop do
      update
      Graphics.update
      Input.update
     
      # Controllo le collisioni
      # Se il gancio tocca il fondo della mappa esco dal gioco...
      if @sprites["hook"].depth + @sprites["hook"].image.height >= @depth
        $game_system.bgm_restore
        #pbBGMFade
        return [-1, @sprites["hook"].depth]
      end
     
      # ... altrimenti ritorno il codice d'uscita.
      # Nel caso il gancio tocchi il tesoro, ritorno quest'ultimo
      for i in 1...@sprites.length - 1
        obs = pbCheckCollision(@sprites["hook"], @sprites["obs#{i}"])
				depthLevel = 0
				if @sprites["hook"].depth > 0
					depthLevel = @sprites["hook"].depth / (@depth / 3)
				end
        if obs != nil
          if obs.instance_of? Treasure
            $game_system.bgm_restore
            #pbBGMFade
            return [obs, depthLevel]
          end
          if obs.type == 2 || obs.type == 3
            if !@sprites["obs#{i}"].hit
            @sprites["obs#{i}"].hit = true
            @sprites["hook"].hits += obs.type - 1
              if @sprites["hook"].hits >= 3
                $game_system.bgm_restore
                #pbBGMFade
                return [-2, depthLevel]
              end
            end
          else
            $game_system.bgm_restore
            #pbBGMFade
            return [obs.type, depthLevel]
          end
        end
      end
     
      # Aggiorno i movimenti del gancio
      @sprites["hook"].depth += @sprites["hook"].velocity
      pbCalculateHookYPosition
      if Input.repeat?(Input::LEFT)
        @sprites["hook"].moveLeft
      elsif Input.repeat?(Input::RIGHT)
        @sprites["hook"].moveRight
      end
    end
  end
 
  # Controlla le collisioni fra il gancio e gli altri oggetti e ritorna l'oggetto
  # contro cui e' avvenuta la collisione
  def pbCheckCollision(hook, obj)
    if ((obj.position[0] + obj.image.width >= hook.position[0]) &&
        (obj.position[0] <= hook.position[0] + hook.image.width)) &&
        ((obj.position[1] + obj.image.height >= hook.position[1]) &&
        (obj.position[1] <= hook.position[1] + hook.image.height))
      return obj
    end
  end
   
  # Calcola ed aggiorna la posizione sull'asse Y del gancio al variare della
  # sua profondita'
  def pbCalculateHookYPosition
    depth = @sprites["hook"].depth
     
    if depth < 60 || depth > @depth - Graphics.height + 60
      @sprites["hook"].position[1] += @sprites["hook"].velocity
    end
  end
   
  # Aggiorna il background in base alla profondità del gancio
  def pbUpdateBackground
    if @sprites["hook"].position[1] <= 60
      @sprites["bg"].y = (@sprites["hook"].depth * 
      (@sprites["bg"].image.height - Graphics.height) / (@depth - Graphics.height + 60)) * -1
    end
  end
  
  # Termina la scena quando il gioco finisce
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    $treasureHook = false
  end
   
end
 
# Classe per far partire il mini-gioco
class TreasureHook
 
  def initialize(scene)
    @scene=scene
  end
 
  def pbStartScreen
    @scene.pbStartScene
    ret=@scene.pbMain
    @scene.pbEndScene
    return ret
  end
 
end
 
$fishing=false
# Metodo per iniziare il mini-gioco. Viene usato dall'oggetto TREADUREHOOK nel
# file 'PItem_ItemEffects' quando lo strumento associato viene usato.
def pbTreasureHook(code = nil)
  $fishing=true
  $treasureHook = true
  scene = TreasureHookScene.new
  screen = TreasureHook.new(scene)
  pbFadeOutIn(99999) {
    ret = screen.pbStartScreen
    if ret[0].instance_of?(Treasure)
      if code == "event_001"
        $game_switches[45] = false
      else
        if $game_switches[170]==true
          Kernel.pbMessage(_INTL("La prova è conclusa!"))
          $fishing=false
          return true
        else
          if $PokemonBag.pbStoreItem(ret[0].reward)
            Kernel.pbMessage(_INTL("Hai ottenuto {1}.",
              PBItems.getName(ret[0].reward)))
            $fishing=false
            #if ret.reward == :RARECANDY && $achievements["pescaFortunata"].progress < 1
            #  $achievements["pescaFortunata"].progress+=1
            #end
            return true
          else
            Kernel.pbMessage(_INTL("Hai trovato {1}, ma non hai abbastanza spazio...",
              PBItems.getName(ret[0].reward)))
            $fishing=false
            #if ret.reward == :RARECANDY && $achievements["pescaFortunata"].progress < 1
            #  $achievements["pescaFortunata"].progress+=1
            #end
            return true
          end
        end
      end
    elsif ret[0] == -2
      Kernel.pbMessage(_INTL("Il gancio e' inutilizzabile"))
      $fishing=false
      return false if $game_switches[170]==true
    elsif ret[0] == -1
      Kernel.pbMessage(_INTL("Recupero fallito"))
      $fishing=false
      return false if $game_switches[170]==true
    elsif ret[0] == 0 && $game_switches[170]==false
      Kernel.pbMessage(_INTL("Un Pokémon ha abboccato!"))
			case ret[1]
			when 0
				pbEncounter(EncounterTypes::OldRod)
			when 1
				pbEncounter(EncounterTypes::GoodRod)
			when 2
				pbEncounter(EncounterTypes::SuperRod)
			end
      #pbHookBattle(HOOKMON[rand(10)],10 + rand(10))
    elsif ret[0] == 0 && $game_switches[170]==true
      Kernel.pbMessage(_INTL("Honchen ha mangiato l'amo!"))
      $fishing=false
      return false
    elsif ret[0] == 1
      Kernel.pbMessage(_INTL("Hai sbattuto contro qualcosa"))
      $fishing=false
      return false if $game_switches[170]==true
    end
  }
  $treasureHook = false
	$fishing=false
end

def pbHookBattle(species,level,variable=nil,canescape=true,canlose=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  handled=[nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  if handled[0]!=nil
    return handled[0]
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke=pbGenerateWildPokemon(species,level)
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  $PokemonGlobal.nextBattleBGM="vs.Trainer"
  $PokemonGlobal.nextBattleME=nil
  $PokemonGlobal.nextBattleBack="Fish"
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil);i.busted=false if i.busted; end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
				i.makeUnmega rescue nil
				i.busted=false if i.busted
       end
     end
     if decision==2 || decision==5 # if loss or draw
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
     $PokemonGlobal.nextBattleBGM=nil
     $PokemonGlobal.nextBattleME=nil
     $PokemonGlobal.nextBattleBack=nil
  }
  Input.update
  pbSet(variable,decision)
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  $fishing=false
  $PokemonGlobal.nextBattleBGM=nil
  $PokemonGlobal.nextBattleME=nil
  $PokemonGlobal.nextBattleBack=nil
  return (decision!=2)
end