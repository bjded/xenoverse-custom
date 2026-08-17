################################################################################
# CRAFTING ENHANCE
# Version: 1.0
# Date: 05/09/2017
# Developer: Fuji
# All right reserved.
################################################################################

class CS_Arrow < Sprite
	@@TAG = "CS_Arrow"
	@@MAX_POSITION = 5
	@@PIXELS_PER_FRAME = 0.5
	
	attr_accessor	:frame
	attr_accessor	:direction
	attr_accessor	:isGrowing
	
	def initialize(viewport=nil, directionRight=true)
		super(viewport)
		@frame = 0
		@base_x = self.x
		@directionRight = directionRight
		@isGrowing = true
		self.bitmap = directionRight ? Bitmap.new("Graphics/Pictures/ItemCrafter/right_arrow.png") : Bitmap.new("Graphics/Pictures/ItemCrafter/left_arrow.png")
	end
	
	def update
		calculateFrame
		calculatePosition
		super
	end
	
	def setX(x)
		@base_x = x
		calculatePosition
	end
	
	def getX
		return @base_x
	end
	
	def calculatePosition
		
		if @directionRight
			self.x = @base_x + @frame * @@PIXELS_PER_FRAME
		else
			self.x = @base_x - @frame * @@PIXELS_PER_FRAME
		end
	end
	
	def calculateFrame
		if @isGrowing
			if @frame * @@PIXELS_PER_FRAME >= @@MAX_POSITION
				@isGrowing = false
				@frame -= 1
			else
				@frame += 1
			end
		else
			if @frame <= 0
				@isGrowing = true
				@frame += 1
			else
				@frame -= 1
			end
		end
	end
end

class ItemCrafterScene
	@@NAME_OFFSET_Y = 10
	
	def initialize
    $game_variables[496]=0
    @select=3
    @item=0
    @mat1=0
    @mat2=-1
    
    #LISTA DEI PRODOTTI DEL CRAFT
    
    @items = [PBItems::GREATBALL,         #0
              PBItems::ULTRABALL,         #1
              PBItems::NESTBALL,          #2
              PBItems::REPEATBALL,        #3
              PBItems::TIMERBALL,         #4
              PBItems::NETBALL,           #5
              PBItems::LUXURYBALL,        #6
              PBItems::HEALBALL,          #7
              PBItems::QUICKBALL,         #8
              PBItems::DUSKBALL,          #9
              PBItems::SILVABALL,         #10
              PBItems::TERRORBALL,        #11
              PBItems::GEOBALL,           #12
              PBItems::XENOBALL,          #13
              PBItems::POTION,            #14
              PBItems::SUPERPOTION,       #15
              PBItems::HYPERPOTION,       #16
              PBItems::MAXPOTION,         #17
              PBItems::FULLRESTORE,       #18
              PBItems::REVIVE,            #19
              PBItems::MAXREVIVE,         #20
              PBItems::MAXETHER,          #21
              PBItems::ELIXIR,            #22
              PBItems::MAXELIXIR,         #23
              PBItems::SUPERREPEL,        #24
              PBItems::MAXREPEL,          #25
              PBItems::HEARTSCALE         #26
              ]           
          
    #LISTA DEI MATERIALI DEL CRAFT          
    
    @materials = [PBItems::POKEBALL,            #0
                  PBItems::CHESTOBERRY,         #1
                  PBItems::WIKIBERRY,           #2
                  PBItems::LEPPABERRY,          #3
                  PBItems::IAPAPABERRY,         #4
                  PBItems::MAGOBERRY,           #5
                  PBItems::PASSHOBERRY,         #6
                  PBItems::FIGYBERRY,           #7
                  PBItems::SITRUSBERRY,         #8
                  PBItems::TAMATOBERRY,         #9
                  PBItems::RINDOBERRY,          #10
                  PBItems::COLBURBERRY,         #11
                  PBItems::OCCABERRY,           #12
                  PBItems::EDENBERRY,           #13
                  PBItems::ORANBERRY,           #14
                  PBItems::LUMBERRY,            #15
                  PBItems::POTION,              #16
                  PBItems::SUPERPOTION,         #17
                  PBItems::HYPERPOTION,         #18
                  PBItems::MAXPOTION,           #19
                  PBItems::FULLRESTORE,         #20
                  PBItems::FULLHEAL,            #21
                  PBItems::HONEY,               #22
                  PBItems::REVIVE,              #23
                  PBItems::ETHER,               #24
                  PBItems::ELIXIR,              #25
                  PBItems::REPEL,               #26
                  PBItems::SUPERREPEL,          #27
                  PBItems::PEARL,               #28
                  PBItems::QUALOTBERRY          #29
                  ]
    
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}

    @sprites["bg"]=IconSprite.new(0,0,@viewport)    
    @sprites["bg"].setBitmap("Graphics/Pictures/ItemCrafter/BG")
		
		@sprites["name_bg"] = Sprite.new(@viewport)
		@sprites["name_bg"].bitmap = Bitmap.new("Graphics/Pictures/ItemCrafter/Item_Name.png")
		@sprites["name_bg"].ox = @sprites["name_bg"].bitmap.width / 2
		@sprites["name_bg"].x = Graphics.width / 2
		@sprites["name_bg"].y = 10
    
    @sprites["Item"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item"].setBitmap("Graphics/Pictures/ItemCrafter/Item_BG")
    @sprites["Item"].x=210+10
    @sprites["Item"].y=30+24
		
		@sprites["left_arrow"]=CS_Arrow.new(@viewport, false)
		@sprites["left_arrow"].setX(130)
		@sprites["left_arrow"].y = 40+24
		
		@sprites["right_arrow"]=CS_Arrow.new(@viewport)
		@sprites["right_arrow"].setX(310)
		@sprites["right_arrow"].y = 40+24
    
    @sprites["Item_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/ItemHov_BG")
    @sprites["Item_Hov"].x=210+10
    @sprites["Item_Hov"].y=30+24
    @sprites["Item_Hov"].opacity=0
    
    @sprites["Item_icon"]=IconSprite.new(0,0,@viewport)   
    @sprites["Item_icon"].setBitmap(pbItemIconFile(@items[@item]))
    @sprites["Item_icon"].x=220+10
    @sprites["Item_icon"].y=40+24
    
    @sprites["Item_1"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1"].setBitmap("Graphics/Pictures/ItemCrafter/ItemR_BG")
    @sprites["Item_1"].x=65
    @sprites["Item_1"].y=100+19
    
    @sprites["Item_1_icon"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
    @sprites["Item_1_icon"].x=65+10
    @sprites["Item_1_icon"].y=100+10+19
    
    @sprites["Item_1_name"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_1_name"].setBitmap("Graphics/Pictures/ItemCrafter/Item_Name")
    @sprites["Item_1_name"].x=140
    @sprites["Item_1_name"].y=110+19
    
    @sprites["Item_2"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2"].setBitmap("Graphics/Pictures/ItemCrafter/ItemR_BG")
    @sprites["Item_2"].x=65
    @sprites["Item_2"].y=185+14
    
    @sprites["Item_2_icon"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[0]))
    @sprites["Item_2_icon"].x=65+10
    @sprites["Item_2_icon"].y=185+10+14
    @sprites["Item_2_icon"].opacity=255
    
    @sprites["Item_2_name"]=IconSprite.new(0,0,@viewport)    
    @sprites["Item_2_name"].setBitmap("Graphics/Pictures/ItemCrafter/Item_Name")
    @sprites["Item_2_name"].x=140
    @sprites["Item_2_name"].y=198+14
    
    @sprites["Confirm"]=IconSprite.new(0,0,@viewport)    
    @sprites["Confirm"].setBitmap("Graphics/Pictures/ItemCrafter/Selection")
    @sprites["Confirm"].x=115
    @sprites["Confirm"].y=280
    
    @sprites["Confirm_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Confirm_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/Selection_1")
    @sprites["Confirm_Hov"].x=115
    @sprites["Confirm_Hov"].y=280
    @sprites["Confirm_Hov"].opacity=0
    
    @sprites["Cancel"]=IconSprite.new(0,0,@viewport)    
    @sprites["Cancel"].setBitmap("Graphics/Pictures/ItemCrafter/Selection")
    @sprites["Cancel"].x=115
    @sprites["Cancel"].y=330
    
    @sprites["Cancel_Hov"]=IconSprite.new(0,0,@viewport)    
    @sprites["Cancel_Hov"].setBitmap("Graphics/Pictures/ItemCrafter/Selection_1")
    @sprites["Cancel_Hov"].x=115
    @sprites["Cancel_Hov"].y=330
        
    @sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    
    self.openItemCrafterscene
  end
	
	def text
    overlay= @sprites["overlay"].bitmap
    overlay.clear
    baseColor=Color.new(255, 255, 255)
    shadowColor=Color.new(0,0,0)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textos=[]
    @text1=_INTL("{1}/1 ,  {2}", $PokemonBag.pbQuantity(@materials[@mat1]), PBItems.getName(@materials[@mat1]))
    if @mat2 < 0
      @text2=_INTL("")
    else
      @text2=_INTL("{1}/1 ,  {2}", $PokemonBag.pbQuantity(@materials[@mat2]), PBItems.getName(@materials[@mat2]))
    end
		textos.push([PBItems.getName(@items[@item]),Graphics.width/2,20,2,baseColor,shadowColor])
    textos.push([@text1,175,115+24,false,baseColor,shadowColor])
    textos.push([@text2,175,198+5+19,false,baseColor,shadowColor])
    textos.push(["Crea",Graphics.width/2,280+5+5,2,baseColor,shadowColor])
    textos.push(["Esci",Graphics.width/2,330+5+5,2,baseColor,shadowColor])
    pbDrawTextPositions(overlay,textos)
  end
	
	def action
    while $game_variables[496]==0
			pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      self.input
    end
  end
	
	def input
		case @select
		when 1
			@sprites["Confirm"].opacity=255
			@sprites["Confirm_Hov"].opacity=0
			@sprites["Cancel"].opacity=0
			@sprites["Cancel_Hov"].opacity=255
			@sprites["Item"].opacity=255
			@sprites["Item_Hov"].opacity=0
		when 2
			@sprites["Confirm"].opacity=0
			@sprites["Confirm_Hov"].opacity=255
			@sprites["Cancel"].opacity=255
			@sprites["Cancel_Hov"].opacity=0
			@sprites["Item"].opacity=255
			@sprites["Item_Hov"].opacity=0
		when 3
			@sprites["Confirm"].opacity=255
			@sprites["Confirm_Hov"].opacity=0
			@sprites["Cancel"].opacity=255
			@sprites["Cancel_Hov"].opacity=0
			@sprites["Item"].opacity=0
			@sprites["Item_Hov"].opacity=255
			@sprites["Item_icon"].setBitmap(pbItemIconFile(@items[@item]))
			case @item
			when 0
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[1]))
				@sprites["Item_2_icon"].opacity=255
				@mat1=0
				@mat2=1
				self.text
			when 1
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[2]))
				@sprites["Item_2_icon"].opacity=255
				@mat1=0
				@mat2=2
				self.text
			when 2
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[3]))
				@sprites["Item_2_icon"].opacity=255
				@mat1=0
				@mat2=3
				self.text
			when 3
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[4]))
				@mat1=0
				@mat2=4
				self.text
			when 4
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[5]))
				@mat1=0
				@mat2=5
				self.text
			when 5
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[6]))
				@mat1=0
				@mat2=6
				self.text
			when 6
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[7]))
				@mat1=0
				@mat2=7
				self.text
			when 7
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[8]))
				@mat1=0
				@mat2=8
				self.text
			when 8
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[9]))
				@mat1=0
				@mat2=9
				self.text
			when 9
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[11]))
				@mat1=0
				@mat2=11
				self.text
			when 10
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[10]))
				@mat1=0
				@mat2=10
				self.text
			when 11
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[11]))
				@mat1=0
				@mat2=11
				self.text
			when 12
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[12]))
				@mat1=0
				@mat2=12
				self.text
			when 13
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[0]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[13]))
				@mat1=0
				@mat2=13
				self.text
			when 14
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[14]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[14]))
				@mat1=14
				@mat2=14
				self.text
			when 15
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[16]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[22]))
				@mat1=16
				@mat2=21
				self.text
			when 16
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[17]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[8]))
				@mat1=17
				@mat2=8
				self.text
			when 17
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[18]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[8]))
				@mat1=18
				@mat2=8
				self.text
			when 18
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[19]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[21]))
				@mat1=19
				@mat2=21
				self.text
			when 19
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[8]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[15]))
				@mat1=8
				@mat2=15
				self.text
			when 20
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[23]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[20]))
				@mat1=23
				@mat2=20
				self.text
			when 21
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[24]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[22]))
				@mat1=24
				@mat2=22
				self.text
			when 22
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[24]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[21]))
				@mat1=24
				@mat2=21
				self.text
			when 23
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[25]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[22]))
				@mat1=25
				@mat2=22
				self.text
			when 24
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[26]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[22]))
				@mat1=26
				@mat2=22
				self.text
			when 25
				@sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[27]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[22]))
				@mat1=27
				@mat2=22
				self.text
      when 26
        @sprites["Item_1_icon"].setBitmap(pbItemIconFile(@materials[28]))
				@sprites["Item_2_icon"].setBitmap(pbItemIconFile(@materials[29]))
				@mat1=28
				@mat2=29
				self.text
			end
			if Input.trigger?(Input::RIGHT)  && @item <26
				@item+=1
				pbPlayDecisionSE()
			end
			if Input.trigger?(Input::LEFT) && @item >0
				@item-=1
				pbPlayDecisionSE()
			end
			
			if @item == 0
				@sprites["left_arrow"].visible = false
			else
				@sprites["left_arrow"].visible = true
			end
			if @item >= 26
				@sprites["right_arrow"].visible = false
			else
				@sprites["right_arrow"].visible = true
			end
		end    
		
		if Input.trigger?(Input::UP)  && @select <3
			@select+=1
			pbPlayDecisionSE()
		end
		if Input.trigger?(Input::DOWN) && @select >1
			@select-=1
			pbPlayDecisionSE()
		end
		
		if Input.trigger?(Input::C) 
			case @select
			when 2
				if @materials[@mat2]==@materials[@mat1]
					if $PokemonBag.pbQuantity(@materials[@mat2])<2 || $PokemonBag.pbQuantity(@materials[@mat1]) <2
						Kernel.pbMessage(_INTL("Non è possibile creare l'oggetto. Non possiedi i materiali richiesti."))
					else
						$PokemonBag.pbStoreItem(@items[@item],1)
						$PokemonBag.pbDeleteItem(@materials[@mat1],1)
						if @mat2!=-1
							$PokemonBag.pbDeleteItem(@materials[@mat2],1)
						end
						self.text
						Kernel.pbMessage(_INTL("Una {1} è stata creata", PBItems.getName(@items[@item])))
					end
				else
					if $PokemonBag.pbQuantity(@materials[@mat2])<1 || $PokemonBag.pbQuantity(@materials[@mat1]) <1
						Kernel.pbMessage(_INTL("Non è possibile creare l'oggetto. Non possiedi i materiali richiesti."))
					else
						$PokemonBag.pbStoreItem(@items[@item],1)
						$PokemonBag.pbDeleteItem(@materials[@mat1],1)
						if @mat2!=-1
							$PokemonBag.pbDeleteItem(@materials[@mat2],1)
						end
						self.text
						Kernel.pbMessage(_INTL("Una {1} è stata creata", PBItems.getName(@items[@item])))
					end
				end
			when 1
				$game_variables[496]=@select
				self.closeItemCrafterscene
			end       
		end
		
		if Input.trigger?(Input::B)
			$game_variables[496]=@select
			self.closeItemCrafterscene  
		end
		
	end
end


def cazzo
	ItemCrafterScene.new
end
