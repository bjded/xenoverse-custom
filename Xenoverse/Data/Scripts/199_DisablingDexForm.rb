=begin
class PokedexFormScene
  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @bg = Sprite.new(@viewport)
		@bg.bitmap = Bitmap.new(pbResolveBitmap("Graphics/Pictures/Dex/formecoming"))
  end
	
	def pbControls
    Graphics.transition
    ret = 1
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::LEFT)
        ret=4
        break
      elsif Input.trigger?(Input::UP) # If not at top of list
        ret=8
        break
      elsif Input.trigger?(Input::DOWN) # If not at end of list
        ret=2
        break
      elsif Input.trigger?(Input::B)
        ret=1
        pbPlayCancelSE()
        $dexentry=false
        #pbFadeOutAndHide(@sprites)
        break
      end
    end
    return ret
  end

  def pbEndScene
    @bg.dispose
    @viewport.dispose
  end
end
	
class PokedexForm
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(species,listlimits)
    @scene.pbStartScene
    ret=@scene.pbControls
    @scene.pbEndScene
    return ret
  end
end
=end