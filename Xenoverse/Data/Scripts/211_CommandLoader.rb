DEBUGGER_MAX_LINES = 14
DEBUGGER_LINE_HEIGHT = 23
LOG_FONT = Font.new(["Roboto Mono Regular", "Lucida Console"], 18)
LOG_FONT.color = Color.new(12,12,12)
LOG_COMMAND_COLOR = Color.new(80,80,80)

class Debugger_Log
	attr_accessor	:texts
	
	def initialize(viewport)
		@viewport = viewport
		@texts = Array.new()
		
		# Calculating char font size
		bitmap = Bitmap.new(100,100)
		@charSize = bitmap.text_size("A").width
		bitmap.dispose
		@maxChars = (Graphics.width-20) / @charSize
		Log.i("DEBUGGER_LOG", "Initialized Debugger_Log with charSize #{@charSize.to_s} and maxChars #{@maxChars.to_s}")
	end
	
	def splitLines(text)
		rows = []
		#Log.d("DEBUGGER_LOG", text)
		text.each_line {|row| rows += splitRecursive(row)}
		
		# Yield or return array
		if block_given?
			rows.each {|row| yield row}
		else
			return rows
		end
	end
	
	def splitRecursive(text)
		if (text.length > @maxChars)
			index = @maxChars-1
			while index >= 0 do
				break if text[index] == " "
				index -= 1
			end
			if index >= 0
				nextText = text[index+1..-1]
				text = text[0..index-1]
			else
				nextText = text[@maxChars..-1]
				text = text[0..@maxChars-1]
			end
			#Log.d("DEBUGGER_LOG", "text: #{text.class} - recursive: #{nextText.class}")
			return [text] + splitRecursive(nextText)
		else
			return [text]
		end
	end
	
	def addText(text, command=false)
		splitLines(text) {|text|
			@texts.push(generateText(text,command))
			@texts.shift.dispose if @texts.length >= DEBUGGER_MAX_LINES
		}
		moveTexts
	end
	
	def generateText(text, command)
		sprite = Sprite.new(@viewport)
		sprite.x = 10
		sprite.bitmap = Bitmap.new(Graphics.width-10-10,DEBUGGER_LINE_HEIGHT)
		sprite.bitmap.font = LOG_FONT
		sprite.bitmap.font.color = LOG_COMMAND_COLOR if command
		sprite.bitmap.draw_text(0,0,sprite.bitmap.width,sprite.bitmap.height,text)
		return sprite
	end
	
	def moveTexts
		@texts.each_index { |index|
			@texts[index].y = DEBUGGER_LINE_HEIGHT * index
			@texts[index].update
		}
	end
	
	def dispose
		@texts.each {|sprite| sprite.dispose}
	end
end

class Debugger
	attr_accessor	:log
	attr_accessor	:pendingLine
	attr_accessor	:cursor
	
	def initialize
		Log.d("DEBUGGER", "Debugger inizializzato")
		@viewport = newFullViewport(100010)
		@log = Array.new()
		viewport_log = Viewport.new(0,70,Graphics.width,Graphics.height-70)
		viewport_log.z = 100011
		@debuggerLog = Debugger_Log.new(viewport_log)
		@pendingLine = 0
		@bg = coloredRect(0,0,Graphics.width,Graphics.height,@viewport,Color.new(255,255,255))
		#@bg2 = Sprite.new(@viewport)
		#@bg2.bitmap = Bitmap.new(Graphics.width,Graphics.height)
		#@bg2.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
		@inputWindow = Window_TextEntry_Keyboard.new("",0,0,Graphics.width,65)
		@inputWindow.z = 100012
		@inputWindow.update
		@inputWindow.text = "" #blank
		@cursor = 0
		@exit = false
	end
	
	def run
		Log.d("DEBUGGER", "Esecuzione del Debugger")
		while !@exit do
			Graphics.update
			Input.update
			@bg.update
			@inputWindow.update
			if Input.triggerex?(0x1B)
				break
			end
			
			if Input.trigger?(Input::UP)
				if (@cursor > 0)
					@cursor -= 1
					@inputWindow.text = @log[@cursor]
				end
			end
			
			if Input.trigger?(Input::DOWN)
				if (@cursor < @log.length)
					@cursor += 1
					if @cursor == @log.length
						@inputWindow.text = ""
					else
						@inputWindow.text = @log[@cursor]
					end
				end
			end
			
			if Input.triggerex?(0x0D)
				if Input.pressex?(0x10)
					#Log.d("DEBUGGER", "Holding shift, setting as pending")
					@debuggerLog.addText(@inputWindow.text, true)
					@log.push(@inputWindow.text)
					@pendingLine += 1
					@inputWindow.text = ""
				else
					#Log.d("DEBUGGER", "Evaluating values - log elements: #{@log.length.to_s}")
					ret = @inputWindow.text
					@inputWindow.text = ""
					@debuggerLog.addText(ret, true)
					if @pendingLine > 0
						(1..@pendingLine).each {
							ret = @log.pop + "\n" + ret}
						@pendingLine = 0
					end
					
					@log.push(ret)
					Log.i("DEBUGGER",ret)
					if Input.pressex?(0x1E)
						return ret2
					end
					begin
						ret2 = eval(ret).to_s
					rescue Exception => e
						ret2 = e.to_s
					end
					Log.i("DEBUGGER","=> " + ret2)
					@debuggerLog.addText("=> "+ ret2)
				end
				@cursor = @log.length
			end
			
			
		end
	end
	
	def dispose
		Log.d("DEBUGGER", "Dispose del Debugger")
		@bg.dispose
		@inputWindow.dispose
		@debuggerLog.dispose
	end
end
		
if $DEBUG
	Input.afterUpdate += Proc.new do |sender|
		if Input.trigger? (Input::F6)
			#begin
				cmd = pbEnterBoxName("Type a command", 0, 200, initialText="")
				begin
				ret = eval cmd
					Log.i("COMMAND","=> " + cmd.to_s)
				rescue
					Log.i("COMMAND","=> nil")
				end
			#rescue Exception => e
			#  Kernel.pbMessage("Comando errato")
			#end
		end
	end
	
	Input.afterUpdate += Proc.new do |sender|
		if Input.trigger? (Input::F7)
			#begin
			debugger = Debugger.new
			ret = debugger.run
			debugger.dispose
			unless ret.nil?
				begin
					ret2 = eval(ret).to_s
				rescue Exception => e
					ret2 = e.to_s
				end
				Log.i("DEBUGGER","=> " + ret2)
			end
			
			#rescue Exception => e
			#  Kernel.pbMessage("Comando errato")
			#end
		end
	end
end
