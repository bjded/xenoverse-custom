#===============================================================================
# => Fullbox multi-choice expansion
# Xenoverse Expansion
#
# Creator: Fuji97
# Version: 1.0 (Build 1)
# Date: 30/01/2017
# All right reserved.
#===============================================================================

FBC_TAG = "FULLBOX CHOICE"

CHOICE_FRAME_DURATION = 10

#===============================================================================
# => **
#===============================================================================
class Fullbox_Option
	attr_accessor	:text
	attr_accessor	:color
	attr_accessor	:callback

	def initialize(text,color=nil,callback=nil)
		@text = text
		@color = color
		@callback = callback
	end

	def self.createFromText(text)
		color = nil
		callback = nil
		if $PokemonSystem.language != 0 #0 italian, 1 english
			begin
				text=MessageTypes.getFromMapHash($game_map.map_id,text.gsub(/\n/,' '))#MessageTypes.getFromMapHash(0,message)
				echoln(text)
			rescue
				text=text	
			end
		end
		commands = text.scan(/(\[(\\|@|:)([0-9a-zA-Z]+)\])/)
		Log.d(FBC_TAG,commands.inspect)
		
		commands.each do |com|
			Log.d(FBC_TAG,"Command: #{com[0]}")
			if com[1] == "\\"
				color = com[2]
				text.gsub!(com[0],"")
			elsif com[1] == ":"
				callback = method(:com[2])
				text.gsub!(com[0],"")
			elsif com[1] == "@"
				case com[2]
				when "pl"
					text.gsub!(com[0],($Trainer ? $Trainer.name : ""))
				when "o"
					text.gsub!(com[0],($Trainer.isFemale? ? "a" : "o"))
				else
					text.gsub!(com[0],$game_variables[com[3].to_i]) if com[2].is_i?
				end
			end
			#comm = Fullbox_Option.new(text,color,callback)
			#Log.d(FBC_TAG,"Roba: #{comm.inspect}")
			#return comm
			Log.d(FBC_TAG,"Text: #{text}")
		end

		text.gsub!(/\\PN/,$Trainer.name)
		return Fullbox_Option.new(text,color,callback)
	end

	def self.createFromArray(array)
		optArray = []
		array.each do |text|
			optArray.push(self.createFromText(text))
		end
		return optArray
	end
end

#===============================================================================
# => **
#===============================================================================
class Fullbox_RealOption
	def initialize(pos,max,text,color,callback)
		Log.d(FBC_TAG,"Fullbox Real Option created with params: (#{pos.to_s},#{max.to_s},#{text},#{color.to_s},#{callback.to_s})")
		@pos = pos
		@max = max
		@color = color
		@callback = callback
		@viewport = newFullViewport(100001)
		posY = 185 / (max + 1) * (pos + 1) + 100

		# Get file name
		file = "fullbox/choice_option"
		file += "_#{color}" if color

		# Load option background
		@bg = EAMSprite.new(@viewport)
		@bg.bitmap = picture("#{file}")
		@bg.ox = @bg.bitmap.width / 2
		@bg.oy = @bg.bitmap.height / 2
		@bg.x = Graphics.width / 2
		@bg.y = posY
		@bg.opacity = 0

		# Load selected option background
		@bgSel = EAMSprite.new(@viewport)
		@bgSel.bitmap = picture("#{file}_sel")
		@bgSel.ox = @bg.bitmap.width / 2
		@bgSel.oy = @bg.bitmap.height / 2
		@bgSel.x = Graphics.width / 2
		@bgSel.y = posY
		@bgSel.opacity = 0

		# Load text
		@text = EAMSprite.new(@viewport)
		@text.bitmap = Bitmap.new(@bg.bitmap.width,@bg.bitmap.height)
		@text.ox = @text.bitmap.width / 2
		@text.oy = @text.bitmap.height / 2
		@text.x = Graphics.width / 2
		@text.y = posY
		@text.opacity = 0
		@text.bitmap.font = Font.new("Barlow Condensed")
		@text.bitmap.font.size = $MKXP ? 20 : 22
		@text.bitmap.font.color = Color.new(240,240,240)
		@text.bitmap.draw_text(0,0,@text.bitmap.width,@text.bitmap.height,text,1)
	end

	def click?
		return -1 if !$mouse
		if $mouse.leftClick?(@bg)
			return @pos
		else
			return -1
		end
	end

	def over?
		return -1 if !$mouse
		if $mouse.over?(@bg)
			return @pos
		else
			return -1
		end
	end

	def x; return @bg.x; end
	def y; return @bg.y; end

=begin
	def move(x,y,frame,ease=:linear_tween,callback=nil)
		@bg.move(x,y,frame,ease,callback)
		@text.move(x,y,frame,ease,callback)
	end

	def fade(opacity,frame,ease=:linear_tween,callback=nil)
		@bg.fade(opacity,frame,ease,callback)
		@text.fade(opacity,frame,ease,callback)
	end
=end

	def select(val)
		if val
			@bgSel.fade(255,10,:ease_out_cubic)
			@bgSel.zoom(1.05,1.05,10,:ease_out_cubic)
			@bg.zoom(1.05,1.05,10,:ease_out_cubic)
			#@text.zoom(1.2,1.2,10,:ease_out_cubic)
		else
			@bgSel.fade(0,10,:ease_out_cubic)
			@bgSel.zoom(1,1,10,:ease_out_cubic)
			@bg.zoom(1,1,10,:ease_out_cubic)
			#@text.zoom(1,1,10,:ease_out_cubic)
		end
	end

	def fadeIn
		@bg.move(@bg.x,@bg.y-20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bg.fade(255,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bgSel.move(@bg.x,@bg.y-20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.move(@text.x,@text.y-20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.fade(255,CHOICE_FRAME_DURATION,:ease_out_cubic)
	end

	def fadeOut
		@bg.move(@bg.x,@bg.y+20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bg.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bgSel.move(@bg.x,@bg.y+20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bgSel.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.move(@text.x,@text.y+20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
	end

	def fadeOutSelected
		@bg.zoom(1.3,1.3,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bg.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bgSel.zoom(1.3,1.3,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bgSel.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.zoom(1.3,1.3,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@text.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
	end

	def update
		@bg.update
		@bgSel.update
		@text.update
	end

#===============================================================================
# => **
#===============================================================================
	def dispose
		@bg.dispose
		@bgSel.dispose
		@text.dispose
	end
end

#===============================================================================
# => **
#===============================================================================
class Fullbox_Choice
#===============================================================================
# => **
#===============================================================================
	def initialize(options,default)
		Log.i(FBC_TAG,"Fullbox Choice called")
		Log.d(FBC_TAG,"Options: #{options.inspect}")
		@viewport = newFullViewport(100000)
		@cursor = 0
		@default = default

		# Create choice bg
		@bg = EAMSprite.new(@viewport)
		@bg.bitmap = picture("fullbox/choice_bg")
		@bg.ox = @bg.bitmap.width / 2
		@bg.x = Graphics.width / 2
		@bg.y = 100
		@bg.opacity = 0

		# Generate options
		@options = []
		for i in 0...options.length
			Log.d(FBC_TAG,"#{@options[i].inspect} - #{i.to_s} - #{options.length}")
			@options[i] = Fullbox_RealOption.new(i,options.length,options[i].text,options[i].color,options[i].callback)
		end
		@options[0].select(true)

		# Starts fade in animation
		@bg.move(@bg.x,@bg.y-20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bg.fade(255,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@options.each {|opt| opt.fadeIn}

		# Aniamtion loop
		while @bg.isAnimating?
			@bg.update
			@options.each {|opt| opt.update}
			Graphics.update
			Input.update
		end

		# Start main loop
		loop
	end
	
	def default?
		if @default != 0
			return true
		else
			return false
		end
	end

	def select(option=@cursor)
		@bg.move(@bg.x,@bg.y+20,CHOICE_FRAME_DURATION,:ease_out_cubic)
		@bg.fade(0,CHOICE_FRAME_DURATION,:ease_out_cubic)
		for i in 0...@options.length
			if i == option
				@options[i].fadeOutSelected
			else
				@options[i].fadeOut
			end
		end

		while @bg.isAnimating?
			@bg.update
			@options.each {|opt| opt.update}
			Graphics.update
			Input.update
		end
		return option
	end

	def setSelection(val)
		Log.v(FBC_TAG,"Called setSelection with cursor: #{@cursor.to_s}")
		return if val == @cursor

		# De-select old option
		@options[@cursor].select(false) if @cursor != -1

		# Loop selection
		@cursor = val
		if @cursor >= @options.length
			@cursor = 0
		elsif @cursor < 0
			@cursor = @options.length - 1
		end

		# Select new option
		@options[@cursor].select(true)

		# Play the select SE
		pbSEPlay("SE_Select1")
	end

	def incrementSelection(val)
		setSelection(@cursor+val)
	end

	def loop
		# Debug function
		exit_loop = false
		returned = false
		until (@cursor != -1 && Input.trigger?(Input::A) || @cursor != -1 && Input.trigger?(Input::C)) || exit_loop
			Log.d(FBC_TAG,"Exit = #{exit_loop.to_s}")
			if Input.trigger?(Input::B)
				if default?
					exit_loop = true
					returned = true
					break
				end
			elsif Input.trigger?(Input::UP)
				incrementSelection(-1)
			elsif Input.trigger?(Input::DOWN)
				incrementSelection(1)
			end
			@options.each do |opt|
				pos = opt.click?
				if pos > -1
					setSelection(pos)
					Log.d(FBC_TAG,"Click detected from #{pos.to_s}")
					exit_loop = true
					break
				end
				pos = opt.over?
				if pos > -1
					setSelection(pos)
				end
			end
			
			@options.each {|opt| opt.update}
			Graphics.update
			Input.update
		end
		return !returned
	end

#===============================================================================
# => **
#===============================================================================
	def dispose
		@bg.dispose
		@options.each {|opt| opt.dispose}
	end
end

#===============================================================================
# => **
#===============================================================================
def pbNewChoice(options,default=0)
	choice = Fullbox_Choice.new(options,default)
	ret = choice.loop
	pbSEPlay("Select")
	if ret
		res = choice.select
	else
		res = choice.select(default-1)
	end
	choice.dispose
	Log.i(FBC_TAG,"Multi-choice result: #{res.to_s}")
	return res
end

class Game_Interpreter
	def command_102
    command = pbNewChoice(Fullbox_Option.createFromArray(@list[@index].parameters[0]))
    @branch[@list[@index].indent] = command
    Input.update # Must call Input.update again to avoid extra triggers
    return true
  end
end

# DEBUG
def fbcDebug
	Log.d(FBC_TAG,"Debuggin Fullbox Multi-choice")
	options = [Fullbox_Option.new("Emh, ciao?..."),Fullbox_Option.new("Ma chi sei!?"),Fullbox_Option.new("Ryuu Ga Waga Teki Wo Kurau!!!","red")]
	o = pbNewChoice(options)
	Input.update
	echoln o
	#choice.loop
end
