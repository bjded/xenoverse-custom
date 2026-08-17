#require 'net/http'

#uri = URI('https://www.weedleteam.com/request.php')
#res = Net::HTTP.post_form(uri, 'type' => 'getGifts', 'code' => 'lMvKh4HwLJeeRltm0r4jaPlac3lciIR1')
#font = Font.new
#font.name = "Barlow Condensed"

# Use system to spawn new exes, exec will replace main process
#a = Thread.new{system("Game.exe")

=begin
Graphics.frame_rate = 60
b = Bitmap.new(512*14, 200)
Input.text_input=true
@text = ""
b.font.name = "Barlow Condensed"
b.font.size = 30
b.font.color = Color.new(255,255,255)
#defined?(Shader).to_s
#Font.instance_methods[0].to_s
b.draw_text(b.rect, @text, 0)
s = Sprite.new
s.bitmap = b
loop { Graphics.update; Input.update 
    if (Input.press?(Input::RIGHT))
        s.x-=3
    end
    if (Input.press?(Input::LEFT))
        s.x+=3
    end

    if Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
        Input.clipboard = text if Input.triggerex?(:C)
        @text += Input.clipboard if Input.triggerex?(:V)
    else
        @text += Input.gets
    end

    b.clear
    b.draw_text(b.rect, @text, 0)
}
=end
#require 'json'

Graphics.frame_rate = 60
b = Bitmap.new(512*14, 200)
@text = ""
file = File.open("mkxp.json")
file.readlines.each do |l|
    @text+=l# + "\n"
end

b.font.name = "Barlow Condensed"
b.font.size = 30
b.font.color = Color.new(255,255,255)
#defined?(Shader).to_s
#Font.instance_methods[0].to_s
b.draw_text(b.rect, @text, 0)
s = Sprite.new
s.bitmap = b
loop { Graphics.update; Input.update 
    if (Input.press?(Input::RIGHT))
        s.x-=3
    end
    if (Input.press?(Input::LEFT))
        s.x+=3
    end
}