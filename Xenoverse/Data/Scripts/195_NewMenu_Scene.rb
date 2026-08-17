# Grafica di background del menu'
class NewMenu_Bg < Sprite
  
	# Attributi
	include EAM_Sprite
	
  # Costruttore
  def initialize
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    super(viewport)
    self.bitmap = Bitmap.new("Graphics/Pictures/NewMenu/menuBg")
    self.opacity = 0
  end
  
end

class NewMenu_Text < Sprite
	
	# Attributi
	include EAM_Sprite
	
	# Costruttore
	def initialize
		viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		viewport.z = 99998
		super(viewport)
		self.bitmap = Bitmap.new(Graphics.width, 40)
    	@bgColor = Color.new(0, 0, 0, 150)
		self.bitmap.font.size = $MKXP ? 30 : 32
		#self.x = Graphics.width / 2 + 4
		self.y = Graphics.height / 2 + 60
		#self.ox = Graphics.width / 2
		self.oy = 40
		@updating = false
		@text = ""
	end
	
	def updateText(text)
		self.fade(0, 4)
		self.bitmap.clear
    self.bitmap.fill_rect(0, 0, Graphics.width, 50, @bgColor)
		@updating = true
		@text = text
	end
	
	def update
		super
		if !self.isAnimating? && @updating
			self.bitmap.draw_text(Graphics.width/2 - 75, 0, 150, 40, @text, 1)
			self.fade(255, 4)
			@updating = false
		end
	end
	
end

# Grafica del selettore per le icone del menu'
class NewMenu_Selector < Sprite
  
  # Attributi
  include EAM_Sprite
  
  # Costruttore
  def initialize(menu)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    super(viewport)
    self.bitmap = Bitmap.new("Graphics/Pictures/NewMenu/selector")
		self.opacity = 0
    @menu = menu
    @updating = false
    self.x = @menu.getIndexX
    self.y = @menu.getIndexY
    self.setCircPoint(Graphics.width / 2, Graphics.height / 2)
  end
  
  # Metodi
  def moveLeft(index)
    index = (index - 1) % @menu.noItems
    self.fade(0, 4)
    @updating = true
  end
  
  def moveRight(index)
    index = (index + 1) % @menu.noItems
    self.fade(0, 4)
    @updating = true
  end
	
	def animate
		self.fade(0, 4)
		@updating = true
	end
  
  def update
    super
    if !self.isAnimating? && @updating
      self.x = @menu.getIndexX
      self.y = @menu.getIndexY
      self.fade(255, 4)
      @updating = false
    end
  end
  
end

# Grafica e funzionalita' per ogni icona del menu'
class NewMenu_Item < Sprite
	
	# Attributi
	include EAM_Sprite
	attr_accessor :displayedName
  
  # Costruttore
  def initialize(itemName, displayedName)
		viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		viewport.z = 99999
		super(viewport)
		self.bitmap = Bitmap.new("Graphics/Pictures/NewMenu/" + itemName)
		@displayedName = displayedName
		self.opacity = 0
  end
  
  # Metodi
	def setPosition(x, y)
		self.x = x
		self.y = y
	end
	
	def function=(function)
		@function = function
	end
	
  def select
    @function.call
  end
  
end

# Scena del menu'
class NewMenu
  
  # Attributi
  attr_accessor :noItems
	attr_reader :index
	
  # Metodi
  def open
    pbSEPlay("BW2OpenMenu")
    
    #Ordine Poke  t.c  wes  save quit opt bag
	@xPos = [213, 316, 340, 269, 156, 85, 110]
    #Ordine Poke t.c wes  save  quit opt  bag 
    @yPos = [28, 79, 189, 280, 276, 188, 77]
	@index = 0 if $Trainer.party.length>0
    @index = 1 if $Trainer.party.length==0
		
	@items = []
	initItems
	@noItems = @items.length
	for i in 0...@noItems
		if @items[i] != nil
			@items[i].setPosition(@xPos[i], @yPos[i])
			@items[i].fade(255, 4)
		end
	end
	
	@looping = true
		
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99996
    
	@sprites = {}
    @bg=Sprite.new(viewport)
    #@bg.snapScreen
	#@bg.blur_sprite(4)
	#@bg.bitmap.blt(0,0,pbBitmap("Graphics/Pictures/newMenu/TestBlur"),Rect.new(0,0,512,384))
	@bg.bitmap=pbBitmap("Graphics/Pictures/newMenu/TestBlur")
    #@bg.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    #@bg.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @bg.blur_sprite(2)
    @bg.opacity=0
	@sprites["bg"] = NewMenu_Bg.new
	@sprites["selector"] = NewMenu_Selector.new(self)
	@sprites["text"] = NewMenu_Text.new
	@sprites["text"].bitmap.font.name = $MKXP ? "Kimberley" : "Kimberley Bl"
	@sprites["text"].updateText(@items[@index].displayedName) if @items[@index] != nil
	if !(pbInSafari? || pbInBugContest?) && $Trainer.party.length>0
		@sprites["mg"] = EAMSprite.new(viewport)
		@sprites["mg"].bitmap = pbBitmap("Graphics/Pictures/newMenu/MysteryGift")
		@sprites["mg"].x = 10
		@sprites["mg"].y = 320
	end
	10.times do
      @bg.opacity+=15.5
    end
    
	@index = (@index) % @items.length

    @sprites.each do |k, s|
		s.fade(255, 10)
	end
    
    update
  end
	
	def initItems
		# POKÉMON
		pokemon = NewMenu_Item.new("pokemon", _INTL("Pokémon"))
		pokemon.function = lambda {
			sscene=PokemonScreen_Scene.new
			sscreen=PokemonScreen.new(sscene,$Trainer.party)
			hiddenmove=nil
			pbFadeOutIn(99999) { 
				hiddenmove=sscreen.pbPokemonScreen
				if hiddenmove && !@scene.nil?
					@scene.pbEndScene
				end
			}
			if hiddenmove
				Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
				return
			end
		}
		
    # NO POKEMON
    #nopoke = NewMenu_Item.new("nowes","")
    
		# POKÉWES
	
		pokewes = NewMenu_Item.new("pokewes", _INTL("PokéWES"))
		pokewes.function = lambda {
			#pbFadeOutIn(99999) {
			if pbInSafari?
				Kernel.pbMessage(_INTL("Can't use this while you're taking the Hero trial."))
			elsif $game_switches[997]==true
				Kernel.pbMessage(_INTL("Can't use the PokeWES right now."))
			else  
				PokeWES.new(self)
			end
			#}
		}
    
    # NO POKÉWES
    #nowes = NewMenu_Item.new("nowes","")
		
		# ZAINO
		bag = NewMenu_Item.new("bag", _INTL("Zaino"))
		bag.function = lambda {
			item=0
			scene=PokemonBag_Scene.new
			screen=PokemonBagScreen.new(scene,$PokemonBag)
			pbFadeOutIn(99999) { 
				item=screen.pbStartScreen 
				if item>0
					self.close
				end
			}
			if item>0
				Kernel.pbUseKeyItemInField(item)
				return
			end
		}
		
		# TRAINER
		trainer = NewMenu_Item.new("trainer", $Trainer.name)
		trainer.function = lambda {
			scene=PokemonTrainerCardScene.new
			screen=PokemonTrainerCard.new(scene)
			pbFadeOutIn(99999) { 
				screen.pbStartScreen
			}
		}
		
		# SAVE
		if pbInSafari? || pbInBugContest?
			left = NewMenu_Item.new("resa", _INTL("Abbandona"))
			left.function = lambda {
				if Kernel.pbConfirmMessage(_INTL("Are you sure you wanna leave the Hero trial?"))
          close
          pbSafariState.pbGoToStart
          $safariScene.pbRestoreOldParty
          pbSafariState.pbEnd
          
          
        end
			}
		else
			save = NewMenu_Item.new("save", _INTL("Salva"))
			save.function = lambda {
				if $ISINTOURNAMENT
					Kernel.pbMessage(_INTL("Non puoi mentre c'è un torneo in corso."))
				elsif $game_switches[2000] == true
					Kernel.pbMessage(_INTL("Non puoi salvare adesso."))
				else
					scene=PokemonSaveScene.new
					screen=PokemonSave.new(scene)
					screen.pbSaveScreen
				end
			}
		end
		
		# OPTIONS
		options = NewMenu_Item.new("options", _INTL("Opzioni"))
		options.function = lambda {
			scene=PokemonOptionScene.new
			screen=PokemonOption.new(scene)
			pbFadeOutIn(99999) {
				screen.pbStartScreen
				pbUpdateSceneMap
			}
		}
		
		# EXIT
		exit = NewMenu_Item.new("exit", _INTL("Comandi"))
		exit.function = lambda {
			#close
			pbFadeOutIn(99999){
				CommandScreen.new
				}
    }
    
    # PUSH ORDER
    if $Trainer.party.length>0
      @items.push(pokemon)
    else
      #@items.push(nopoke)
      @items.push(nil)
    end
    @items.push(trainer) if !$game_switches[1351]
    if $Trainer.pokewes && !$game_switches[1351]
      @items.push(pokewes) 
    else
      #@items.push(nowes)
      @items.push(nil)
    end
    if pbInSafari? || pbInBugContest?
      @items.push(left)
    else
      @items.push(save)
    end
    @items.push(exit)
    @items.push(options)
    @items.push(bag)
    
	end
  
  def update
    while @looping
      if $fly==1
        break
      end
      Graphics.update
      handleInput
			@items.each {|i| i.update if i != nil}
      pbUpdateSpriteHash(@sprites)
    end
    $fly=0
  end
	
	def handleInput
		Input.update
		if Input.trigger?(Input::LEFT)
			return if @items.length == 0
			@index = (@index - 1) % @items.length
			if @items[@index] == nil
				while @items[index] == nil
					@index = (@index - 1) % @items.length
				end	
			end
			@sprites["selector"].animate
			@sprites["text"].updateText(@items[@index].displayedName)
			pbSEPlay("Select")
		elsif Input.trigger?(Input::RIGHT)
			return if @items.length == 0
			@index = (@index + 1) % @items.length
			if @items[@index] == nil
				while @items[index] == nil
					@index = (@index + 1) % @items.length
				end	
			end
			@sprites["selector"].animate
			@sprites["text"].updateText(@items[@index].displayedName)# if @items[@index] != nil
			pbSEPlay("Select")
		elsif Input.trigger?(Input::C) && @items[@index] != nil
			@items[@index].select
			pbSEPlay("Select")
		elsif Input.trigger?(Input::Y) && !(pbInSafari? || pbInBugContest?) && $Trainer.party.length>0 && $game_switches[UNLOCKMGSWITCH]
			pbSEPlay("Select")
			pbMGH
		elsif Input.trigger?(Input::B)
			pbSEPlay("menu")
			close
		elsif Input.trigger?(Input::X) && $DEBUG
			pbFadeOutIn(99999) { 
				pbDebugMenu
			}
			pbSEPlay("Select")
		end
	end
  
  def close
    1.times do
		@items.each {|i| i.fade(0, 4) if i != nil}
		@sprites.each do |k, s|
			s.fade(0, 10)
		end
    10.times do
      @bg.opacity-=15.5
    end
		while @sprites.values[0].isAnimating?
			Graphics.update
			@items.each {|i| i.update if i != nil}
			pbUpdateSpriteHash(@sprites)
		end
    @bg.dispose
    @items.each {|i| i.dispose if i != nil}
    pbDisposeSpriteHash(@sprites)
		@looping = false
    $fly=0
    end
  end
	
	def getIndexX
		return @xPos[@index]
	end
	
	def getIndexY
		return @yPos[@index]
	end
  
end

# Metodo di richiamo del menu'
class Scene_Map
	def call_menu
		$game_temp.menu_calling = false
    $game_player.straighten
    $game_map.update
		menu = NewMenu.new
		menu.open
	end
end