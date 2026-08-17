class PokemonScreen_Scene
	def pbStartFormChange(i)
		viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewport.z = 100010
		anim = AnimatedSprite.new("Graphics/Icons/AnimForm.png",99,86,79,1,viewport)
		#anim.bitmap = AnimatedBitmap.new("Graphics/Icons/AnimForm.png")
    anim.x = @sprites["pokemon#{i}"].x + 10
		anim.y = @sprites["pokemon#{i}"].y + 5
		anim.play
    time = 40
    pbSEPlay("anello",80)
    for n in 0..time do
      anim.update if n % 4 == 0
      update
			pbRefreshSingle(i) if n == (time / 2)
			Graphics.update
		end
		anim.dispose
		Input.update
    pbDisplay(_INTL("{1} ha cambiato forma!", @party[i].name))
  end
end