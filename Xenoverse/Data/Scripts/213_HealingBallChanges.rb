=begin
class MakeHealingBallGraphics
  def initialize
		saveFolder = RTP.getSaveFolder().gsub(/[\/\\]$/,"") + "/temp"
		Dir.mkdir(saveFolder) unless File.exists?(saveFolder)
		saveFolder += "/healingBalls"
		Dir.mkdir(saveFolder) unless File.exists?(saveFolder)
		saveFolder += "/"
    balls=[]
    for poke in $Trainer.party
      balls.push(poke.ballused) if !poke.isEgg?
    end
    return false if balls.length==0
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=999999
    for i in 0...balls.length
      @sprites["ball#{i}"]=Sprite.new(@viewport)
      if pbResolveBitmap("#{saveFolder}ball_#{balls[i]}.png")
        @sprites["ball#{i}"].bitmap=Bitmap.new("#{saveFolder}ball_#{balls[i]}.png")
      else
        @sprites["ball#{i}"].bitmap=Bitmap.new("#{saveFolder}ball_0.png")
      end
      @sprites["ball#{i}"].visible=false
    end
    bitmap1=Bitmap.new(128,192)
    bitmap2=Bitmap.new(128,192)
    rect1=Rect.new(0,0,128,192/4)
    rect2=Rect.new(0,0,128,192/4)
    for i in 0...balls.length
      case i
      when 0
        bitmap1.blt(20,50,@sprites["ball#{i}"].bitmap,rect1)
        bitmap1.blt(20,98,@sprites["ball#{i}"].bitmap,rect1)
        bitmap1.blt(20,146,@sprites["ball#{i}"].bitmap,rect1)
      when 1
        bitmap2.blt(0,50,@sprites["ball#{i}"].bitmap,rect2)
        bitmap2.blt(0,98,@sprites["ball#{i}"].bitmap,rect2)
        bitmap2.blt(0,146,@sprites["ball#{i}"].bitmap,rect2)
      when 2
        bitmap1.blt(20,106,@sprites["ball#{i}"].bitmap,rect1)
        bitmap1.blt(20,154,@sprites["ball#{i}"].bitmap,rect1)
      when 3
        bitmap2.blt(0,106,@sprites["ball#{i}"].bitmap,rect2)
        bitmap2.blt(0,154,@sprites["ball#{i}"].bitmap,rect2)
      when 4
        bitmap1.blt(20,162,@sprites["ball#{i}"].bitmap,rect1)
      when 5
        bitmap2.blt(0,162,@sprites["ball#{i}"].bitmap,rect2)
      end
      Graphics.update
    end
    if RTP.exists?("#{saveFolder}Healing balls left.png")
      File.delete("#{saveFolder}Healing balls left.png")
    end
    if RTP.exists?("#{saveFolder}Healing balls right")
      File.delete("#{saveFolder}Healing balls right")
    end
    bitmap1.saveToPng("#{saveFolder}Healing balls left.png")
    bitmap2.saveToPng("#{saveFolder}Healing balls right.png")
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    bitmap1.dispose
    bitmap2.dispose
  end
end
=end

class MakeHealingBallGraphics
	# Metodo che non fa niente
  def initialize
		return
  end
end