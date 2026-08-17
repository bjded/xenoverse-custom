class PokemonGenderSelectScene
	
	def update
		pbUpdateSpriteHash(@sprites)
	end
	
	def pbStartScene
		
		@sprites={}
		@select=0
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999
		@sprites["card"]=IconSprite.new(0,0,@viewport)
		@sprites["card"].setBitmap("Graphics/Pictures/charaselectbg")
		@sprites["card"].bitmap.font.name = "Barlow Condensed ExtraBold"
		@sprites["card"].bitmap.font.size = $MKXP ? 26 : 28
		pbDrawTextPositions(@sprites["card"].bitmap,[[_INTL("È un maschietto o una femminuccia?"),256,16,2,Color.new(48,48,48)]])			
		
		@sprites["boy"]=IconSprite.new(0,0,@viewport)
		@sprites["boy"].setBitmap("Graphics/Pictures/charaselect_boy")
		@sprites["boy"].opacity=180
		
		@sprites["girl"]=IconSprite.new(0,0,@viewport)
		@sprites["girl"].setBitmap("Graphics/Pictures/charaselect_girl")
		@sprites["girl"].opacity=180
		
		pbFadeInAndShow(@sprites) { update }
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { update }
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
	
	
	
	def pbGenderSelect
		loop do
			Graphics.update
			Input.update
			self.update
			
			case @select
			when 0
				@sprites["boy"].opacity=255
				@sprites["girl"].opacity=50
			when 1
				@sprites["boy"].opacity=50
				@sprites["girl"].opacity=255
			end
			
			if Input.trigger?(Input::RIGHT) and @select==0
				@select=1
			end
			
			if Input.trigger?(Input::LEFT) and @select==1
				@select=0
			end
			
			if Input.trigger?(Input::C)
				case @select
				when 0
					pbChangePlayer(0)
					#$game_variables[51]=0 #This is just if you want to activate a switch when you have other things for story
					$game_switches[37]=true #This is just if you want to activate a switch when you have other things for story
					break
				when 1
					pbChangePlayer(1)
					#$game_variables[51]=1 #This is just if you want to activate a switch when you have other things for story
					$game_switches[38]=true #This is just if you want to activate a switch when you have other things for story
					break
				end
			end
		end 
	end
	
end

class PokemonGenderSelect
	
	def initialize(scene)
		@scene=scene
	end
	
	def pbStartScreen
		@scene.pbStartScene
		@scene.pbGenderSelect
		@scene.pbEndScene
	end
	
end

def pbCallGenderSelect
	scene=PokemonGenderSelectScene.new
	screen=PokemonGenderSelect.new(scene)
	screen.pbStartScreen
end