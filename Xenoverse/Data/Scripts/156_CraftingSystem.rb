class Formula
	
	# Attributi
	@@item = nil
	@@ingredients = []
	
	# Costruttore
	def initialize(item, ingredients)
		@@item = item
		@@ingredients = ingredients
	end
	
	# Metodi
	def getItem
		return @@item
	end
		
	def getIngredients
		return @@ingredients
	end
	
end

class ItemWrapper < Sprite
  
  # Costruttore
  def initialize(viewport)
    super(viewport)
    self.bitmap = Bitmap.new(230, 48)
    self.bitmap.fill_rect(0, 0, 230, 48, Color.new(255, 255, 255, 150))
  end
  
  # Metodi
  
end

class CraftingSystem
	
	# Costruttore
  def initialize
		@running = true
		@index = 0
		@recipies = readPBS
    @recipies.each do |r|
      echoln(r.getIngredients)
    end
    
    @itemsvp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @itemsvp.z = 99999
    
    @items = []
    for i in 0...(@recipies.length < 7 ? @recipies.length : 7)
      item = ItemWrapper.new(@itemsvp)
      item.x = 15
      item.y = 20 + 49 * i
      @items.push(item)
    end
    
    @ingredients = []
    updateIngredients
		
    @sprites = {}
		
		bgvp = Viewport.new(0, 0, Graphics.width, Graphics.height)
		bgvp.z = 99997
		@sprites["bg"] = IconSprite.new(0, 0, bgvp)
		@sprites["bg"].setBitmap("Graphics/Pictures/CraftingSystem/bg")
    
    overlayvp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    overlayvp.z = 99998
    @sprites["ricette"] = IconSprite.new(0, 0, overlayvp)
    @sprites["ricette"].setBitmap("Graphics/Pictures/CraftingSystem/ricette")
    @sprites["ricette"].x = 10
    @sprites["ricette"].y = 15
    @sprites["ricette"].opacity = 200
    
    @sprites["materiali"] = IconSprite.new(0, 0, overlayvp)
    @sprites["materiali"].setBitmap("Graphics/Pictures/CraftingSystem/materiali")
    @sprites["materiali"].x = 260
    @sprites["materiali"].y = 15
    @sprites["materiali"].opacity = 200
		
		mainLoop
  end
  
  # Metodi
	def readPBS
		result = []
		path = "PBS" + File::SEPARATOR + "craftingsystem.txt"
		if !File.exists?(path)
			raise _INTL("File 'craftingsystem.txt' doesn't exist")
		else
			File.open(path,"r") do |f|
				section = ""
				lineno = 0
				f.each_line do |line|
					lineno += 1
					line = line.chomp
          line = line.tr(' ','')
					
					item = getConst(PBItems, line[0...line.index('(')])
					
					ingredients = []
          line[(line.index('(') + 1)...(line.index(')'))].split(',').each do |i|
            ingredients.push(getConst(PBItems, i))
          end
					
					result.push(Formula.new(item, ingredients))
        end
      end
    end
	
    return result
  end
	
	def mainLoop
		openScene
		while @running
			update
			handleInputs
		end
		closeScene
	end
	
	def openScene
		pbFadeInAndShow(@sprites)
	end
	
	def update
		Graphics.update
	end
  
  def updateIngredients
    @ingredients.clear
    yIndex = 0
    @recipies[@index].getIngredients.each do |i|
      item = ItemWrapper.new(@itemsvp)
      item.x = 266
      item.y = 20 + 59 * yIndex
      @ingredients.push(item)
      yIndex += 1
    end
  end
	
	def handleInputs
		Input.update
		if Input.trigger?(Input::B)
			@running = false
		end
	end
	
	def closeScene
		pbFadeOutAndHide(@sprites)
	end

end

def craftingSystem
		CraftingSystem.new
end