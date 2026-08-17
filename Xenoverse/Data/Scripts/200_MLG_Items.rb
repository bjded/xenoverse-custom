MLG_ANIMATION_TIME = 20

#Input.afterUpdate += proc{|arg1, arg2| t97 if Input.trigger?(Input::F8)}

def show_MLG_Item(file, string=nil)
	# Valori iniziali
	viewport = newFullViewport(100010)
	image = EAMSprite.new(viewport)
	image.bitmap = picture("MLG_items/" + file)
	image.ox = image.bitmap.width / 2
	image.oy = image.bitmap.height / 2
	image.x = Graphics.width / 2
	image.y = Graphics.height / 2 - 40
	image.opacity = 0
	image.zoom_x = 0.7
	image.zoom_y = 0.7
	image.angle = 40
	
	# Fade in
	image.fade(255, MLG_ANIMATION_TIME, :ease_out_quad)
	image.rotate(0, MLG_ANIMATION_TIME, :ease_out_quad)
	image.zoom(1.0,1.0, MLG_ANIMATION_TIME, :ease_out_quad)
	while image.isAnimating?
		Graphics.update
		Input.update
		image.update
	end
	
	# Main loop
	if !string
		until Input.press?(Input::A) || Input.press?(Input::B) || 
			Input.press?(Input::C) || Input.press?(Input::X) || 
			Input.press?(Input::Y) || Input.press?(Input::Z) || ($mouse && $mouse.leftClick?)
			Graphics.update
			Input.update
		end
		pbPlayDecisionSE()
	else
		Kernel.pbMessage(_INTL("Hai ottenuto {1}!", string))
	end
	
	# Fade out
	image.fade(0, MLG_ANIMATION_TIME, :ease_out_quad)
	image.rotate(-30, MLG_ANIMATION_TIME, :ease_out_quad)
	image.zoom(1.5,1.5, MLG_ANIMATION_TIME, :ease_out_quad)
	while image.isAnimating?
		Graphics.update
		Input.update
		image.update
	end
	
	image.dispose
end