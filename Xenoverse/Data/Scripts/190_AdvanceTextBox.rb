################################################################################
# FULLBOX
# Version: 1.0.1b (Build 4)
# Date: 22/02/2016
# Developer: fuji97
# Designer: fuji97
# Picker: Pokémon Xenoverse
# All rights reserved.
# OLD VERSION
################################################################################
# Provide a new advanced textbox with Mugshots support
################################################################################
=begin
# SETTINGS
MUGSHOTHEIGHT = 250										# Mugshot height
MUGSHOTWIDTH = 250										# Mugshot width
MUGSHOT_DEFAULTONE = Tone.new(0,0,0)					# Mugshot activate tone (default)
MUGSHOT_DARKTONE = Tone.new(-50,-50,-50,-50)			# Mugshot no activate tone - if perfomance is slow, remove grey value
MUGNAMEHEIGHT = 282	+ 5									# Name block height
MUGNAME_BGCENTER = 20									# Name block center bg width
MUGNAME_BGEXTREME = 22									# Name block extreme part
# Graphics.width = 300									# Name max size (pixels) -- Useless
MUGNAME_BGCOLOR = Color.new(20,20,20)					# Name block backgound color (centre)
MUGNAME_TEXTMARGIN = 8									# Text margin from center block
TEXTBOX_HEIGHT = 96										# Height of the Fullbox
FRAME_ANIMATION = 15									# The duration of the animations (frames)
FBTEXTCOLOR = "FFFFFFFF"								# The main color of the text (RRGGBBAA)
FBTEXTSHADOW = "00000000"								# The secondary color of the text (RRGGBBAA)
DEBUG = false											# Enable console debug messages

# Global variables used to track the fullbox, please, don't touch it
$fullbox_visible = false
$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
$fullbox_bg = nil
$fullbox_enabled = false

################################################################################
# DEBUG METHOD
################################################################################
def fbEcholn(text)
	echoln(text) if DEBUG
end

def fbEcho(text)
	echo(text) if DEBUG
end

################################################################################
# FULLBOX METHOD
################################################################################
def fbInitialize(fast=false)	# Called from other management method
	fbEcholn("*******************************\r\nfbInitialize(" + fast.to_s + ")")
	viewport = Viewport.new(0,Graphics.height - TEXTBOX_HEIGHT,Graphics.width,TEXTBOX_HEIGHT)
	viewport.z = 99997
	$fullbox_bg = Sprite.new(viewport)
	$fullbox_bg.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	$fullbox_bg.visible = false
	if fast
		$fullbox_bg.visible = true
		fbEnable(true)
	end
end

def fbEnable(enable)
	fbEcholn("*******************************\r\nfbEnable(" + enable.to_s + ")")
	$fullbox_bg.visible = enable
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot
			next mugshot.each {|mugshot| mugshot.enabled = enable} if !mugshot.is_a?(Mugshot_Wrapper)	#Possible conflicts
			mugshot.enabled = enable
		end
	end
	$fullbox_enabled = enable
	
	if enable
		$fullbox_window.show
	else
		$fullbox_window.hide
	end
end

def fbNewMugshot(name,type,pose,position,active=true,fadeIn=0,fast=false)
	fbEcholn("*******************************\r\nfbNewMugshot(" + name + "," + type + "," + pose + "," + position.to_s + "," + active.to_s + "," + fadeIn.to_s + fast.to_s + ")")
	fbInitialize(fast) if !$fullbox_visible
	fbEnable(true) if fast && !$fullbox_enabled
	fadeIn > 1 ? visible = false : visible = true
	mugshot = Mugshot_Wrapper.new(name,type,pose,position,active,visible)
	if position == :out_left || position == :out_left
		$fullbox_mugshots[position.to_s].push(mugshot)
	else
		return if $fullbox_mugshots[position.to_s]
		$fullbox_mugshots[position.to_s] = mugshot
	end
	mugshot.setVisibility(true,fadeIn) if fadeIn > 1
	return mugshot
end

=begin
def fbPosition(arr,position,frame=0,switch=false)
	fbEcholn("*******************************\r\nfbPosition(" + arr.to_s + "," + position.to_s + "," + frame.to_s + "," + switch.to_s + ")")
	fbEcholn("\tChange position: " + arr.to_s)
	if arr.is_a?(Mugshot_Wrapper)
		startMug = arr
		$fullbox_mugshots[arr.position.to_s] = nil
		$fullbox_mugshots["out_left"].delete(arr)
		$fullbox_mugshots["out_right"].delete(arr)
	elsif arr.is_a?(Symbol)
		return if arr == :out_left || arr == :out_right
		startMug = $fullbox_mugshots[arr.to_s]
		$fullbox_mugshots[arr.to_s] = nil
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbPosition(mugshot,position,frame)}
	end
	return if !startMug	# Exit if startMug isn't be setted (condition valid only if arr is an array)
	
	fbPosition($fullbox_mugshots[position.to_s],startMug.position,frame,true) if ($fullbox_mugshots[position.to_s].is_a?(Mugshot_Wrapper) && !switch)	# This will switch mugshots if destination position is occuped
	startMug.setPosition(position,frame)
	case position
	when :left, :right, :centre
		$fullbox_mugshots[position.to_s] = startMug
	when :out_left, :out_right
		$fullbox_mugshots[position.to_s].push(startMug)
	end
end
=end

=begin
def fbPosition(arr,position,frame=0)
	fbEcholn("*******************************\r\nfbPosition(" + arr.to_s + "," + position.to_s + "," + frame.to_s + ")")
	if arr.is_a?(Mugshot_Wrapper)
		arr.mPosition = position
		arr.mFrame = frame
	elsif arr.is_a?(Symbol)
		return if arr == :out_left || arr == :out_right
		$fullbox_mugshots[arr.to_s].mPosition = position
		$fullbox_mugshots[arr.to_s].mFrame = frame
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbPosition(mugshot,position,frame)}
	end
end

def fbMove(arr,position,frame=10)
	fbEcholn("*******************************\r\nfbMove(" + arr.to_s + "," + position.to_s + "," + frame.to_s + ")")
	fbPosition(arr,position,frame)
end

def fbOpacity(arr,active,frame=0)
	fbEcholn("*******************************\r\nfbOpacity(" + arr.to_s + "," + active.to_s + "," + frame.to_s + ")")
	if arr.is_a?(Mugshot_Wrapper)
		arr.setVisibility(active,frame)
	elsif arr.is_a?(Symbol)
		case arr
		when :left, :centre, :right
			$fullbox_mugshots[arr.to_s].setVisibility(active,frame)
		when :out_left, :out_right
			$fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.setVisibility(active,frame)}
		end
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbOpacity(mugshot,active,frame)}
	end
end

def fbFade(arr,active,frame=10)
	fbEcholn("*******************************\r\nfbFade(" + arr.to_s + "," + active.to_s + "," + frame.to_s + ")")
	fbOpacity(arr,active,frame)
end

def fbFadeMove(arr,active,position,frame=10)
	fbEcholn("*******************************\r\nfbFadeMove(" + arr.to_s + "," + active.to_s + "," + position.to_s + "," + frame.to_s + ")")
	fbFade(arr,active,frame)
	fbPosition(arr,position,frame)
end

def fbAnimate(condition=nil)	# Condition must be an array
	fbEcholn("*******************************\r\nfbAnimate(" + condition.to_s + ")")
	fbMakeMove
	if !condition
		loop do
			ret = true
			$fullbox_mugshots.each_value do |mugshot|
				if mugshot.is_a?(Mugshot_Wrapper)
					ret = false if mugshot.isAnimating?
				elsif mugshot.is_a?(Array)
					mugshot.each {|mugshot| ret = false if mugshot.isAnimating?}
				end
			end
			break if ret
			fbUpdate
		end
	else
		loop do
			ret = true
			condition.each {|mugshot| ret = false if mugshot.isAnimating?}
			break if ret
		end
		fbUpdate
	end
end

def fbMakeMove
	fbEcholn("\tMakeMove called")
	movedMug =[]
	$fullbox_mugshots.each do |key,mugshot|
		if mugshot.is_a?(Mugshot_Wrapper)
			if mugshot.position != mugshot.mPosition
				movedMug.push(mugshot)
				$fullbox_mugshots[key] = nil
			end
		elsif mugshot.is_a?(Array)
			mugshot.each_index do |index|
				mMugshot = $fullbox_mugshots[key][index]
				if mMugshot.position != mMugshot.mPosition
					movedMug.push(mMugshot)
					$fullbox_mugshots[key][index] = nil
				end
			end
		end
	end
	
	movedMug.each do |mugshot|
		mugshot.setPosition(mugshot.mPosition,mugshot.mFrame)
		case mugshot.mPosition
		when :left, :right, :centre
			!$fullbox_mugshots[mugshot.mPosition.to_s] ? $fullbox_mugshots[mugshot.mPosition.to_s] = mugshot : raise(_INTL("More than one mugshots are located in #{mugshot.mPosition.to_s} position"))
		when :out_left, :out_right
			$fullbox_mugshots[mugshot.mPosition.to_s].push(mugshot)
		end
	end
end

def fbMugshot(mug,type,pose)
	fbEcholn("*******************************\r\nfbMugshot(" + mug.to_s + "," + type + "," + pose + ")")
	if mug.is_a?(Mugshot_Wrapper)
		mug.setMugshot(type,pose)
	else
		$fullbox_mugshots[mug.to_s].setMugshot(type,pose) if (mug != :out_left && mug != :out_right)
	end
end

def fbUpdate(graphicsUpdate=true)
	fbEcho("+")
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot.is_a?(Array)
			mugshot.each {|mugshot| mugshot.update}
		elsif mugshot.is_a?(Mugshot_Wrapper)
			mugshot.update
		end
	end
	Graphics.update if graphicsUpdate
end

def fbDeleteMugshot(arr=nil)
	fbEcholn("*******************************\r\nfbDeleteMugshot(" + arr.to_s + ")")
	if !arr
		$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
		return
	elsif arr.is_a?(Mugshot_Wrapper)
		$fullbox_mugshots.each do |mugshot|
			mugshot.is_a?(Mugshot_Wrapper) ? (mugshot = nil if mugshot == arr) : mugshot.each {|mugshot| mugshot.delete(arr)}
		end
		arr.dispose
	elsif arr.is_a?(Symbol)
		if $fullbox_mugshots[arr.to_s].is_a?(Mugshot_Wrapper)
			$fullbox_mugshots[arr.to_s].dispose
			$fullbox_mugshots[arr.to_s] = nil
		else
			$fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.dispose}
			$fullbox_mugshots[arr.to_s] = []
		end
	else
		arr.each {|arr| fbDeleteMugshot(arr)}
	end
end

def fbActive(arr=nil)
	fbEcholn("*******************************\r\nfbActive(" + arr.to_s + ")")
	$fullbox_mugshots.each_value do |mugshot|
		next if !mugshot.is_a?(Mugshot_Wrapper)
		mugshot.setActive(false)
	end
	if arr.is_a?(Mugshot_Wrapper)
		arr.setActive(true)
	elsif arr.is_a?(Symbol)
		$fullbox_mugshots[arr.to_s].is_a?(Mugshot_Wrapper) ? $fullbox_mugshots[arr.to_s].setActive(true) : $fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.setActive(true)}
	elsif arr.is_a?(Array)
		arr.each {|mugshot| mugshot.setActive(true)}
	end
end

def fbSpeaking(speak)
	fbEcholn("*******************************\r\nfbSpeaking(" + speak.to_s + ")")
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot.is_a?(Mugshot_Wrapper)
		mugshot.speaking=speak
	elsif mugshot.is_a?(Array)
		mugshot.each {|mugshot| mugshot.speaking = speak}
		end
	end
end

def fbDispose
	fbEcholn("*******************************\r\nfbDispose")
	fbEnable(false) if $fullbox_enabled
	$fullbox_bg.dispose if $fullbox_bg
	$fullbox_bg = nil
	$fullbox_mugshots["left"].dispose if $fullbox_mugshots["left"]
	$fullbox_mugshots["centre"].dispose if $fullbox_mugshots["centre"]
	$fullbox_mugshots["right"].dispose if $fullbox_mugshots["right"]
	$fullbox_mugshots["out_left"].each do |mug|
		mug.dispose if mug
	end
	$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
	$fullbox_enabled = false
end

################################################################################
# FULLBOX WRAPPER
################################################################################

class Mugshot_Wrapper
	attr_reader	:enabled
	attr_accessor	:mPosition
	attr_accessor	:mFrame
	
	def initialize(name,type,pose,position=:left,active=true,visible=true)
		@mugshot = Mugshot.new(type,pose,position)
		@mugname = Mugshot_Name.new(name,position)
		@mPosition = :position
		@mFrame = 0
		$fullbox_enabled ? @enabled = true : self.enabled = false
		setActive(active)
		setVisibility(visible)
		#@needUpdate = false
	end
	
	def update
		@mugshot.update
		# @needUpdate system - Deprecated and not finished
		#if @needUpdate && !isTransiting?
		#	@mugname.position = @mugshot.position 
		#	@needUpdate = false
		#end
		@mugname.update
	end
	
	def dispose
		@mugshot.dispose
		@mugname.dispose
	end
	
	def to_s
		return @mugname.name
	end
	
	def name=(name)
		fbEcholn "\tName changed: " + name
		@mugname = Mugshot_Name.new(name,@mugname.position)
	end
	
	def name
		return @mugname.name
	end
	
	def type=(type)
		fbEcholn "\tType changed: " + type
		@mugshot.type = type
	end
	
	def type
		return @mugshot.type
	end
	
	def pose=(pose)
		fbEcholn "\tPose changed: " + pose
		@mugshot.pose = pose
	end
	
	def pose
		return @mugshot.pose
	end
	
	def setMugshot(type=nil,pose=nil)
		fbEcholn "\tNew mugshot: " + type + "-" + pose
		@mugshot.setMugshot(type,pose)
	end
	
	def position=(pos)
		fbEcholn "\tPosition changed: " + pos.to_s
		@mugshot.position = pos
		@mugname.position = pos
	end
	
	def position
		return @mugshot.position
	end
	
	def setPosition(pos,frame=0)
		fbEcholn "\tSetPosition called: (" + pos.to_s + "," + frame.to_s + ")"
		@mugshot.setPosition(pos,frame)
		# @needUpdate = true
		@mugname.position = pos	# Substitute of @needUpdate system
	end
	
	def enabled=(enabled)
		fbEcholn "\tEnabled changed: " + enabled.to_s
		@enabled = enabled
		setVisibility(enabled)
	end
	
	def isAnimating?
		return @mugshot.isAnimating?
	end
	
	def isTransiting?
		return @mugshot.isTransiting?
	end
	
	def isFading?
		return @mugshot.isFading?
	end
	
	def isVisible?
		return @mugshot.visible
	end
	
	def isActive?
		return @mugshot.active
	end
	
	def setVisibility(visible,frames=0)
		fbEcholn "\tSetVisibility called (" + visible.to_s + "," + frames.to_s + ")" 
		return if (!@enabled && visible)	# || (@enabled && !visible) IDK i've writed this, but keep it just to remember
		@mugshot.setVisibility(visible,frames)
		# @needUpdate = true
		if isActive? && isVisible?
			@mugname.active = true	# Substitute of @needUpdate system
		else
			@mugname.active = false
		end
	end
	
	def setActive(active)
		fbEcholn "\tSetActive called: " + active.to_s
		@mugshot.active = active
		if isActive? && isVisible?
			@mugname.active = true	# Substitute of @needUpdate system
		else
			@mugname.active = false
		end
	end
	
	def speaking=(speak)
		@mugname.visible = speak
	end
end

################################################################################
# CLASS OVERRIDE AND METHOD REWRITE FOR ADAPTING ESSENTIALS' WINDOW MESSAGE
################################################################################

def Kernel.pbCreateFullboxWindow(viewport=nil)
	msgwindow=Window_AdvancedTextPokemon.new("")
	if !viewport
		msgwindow.z=99999
	else
		msgwindow.viewport=viewport
	end
	msgwindow.visible=true
	msgwindow.letterbyletter=true
	msgwindow.back_opacity=MessageConfig::WindowOpacity
	# msgwindow.lineHeight(32)
	pbBottomLeftLines(msgwindow,2)
	windowWidth = 500
	# msgwindow.resizeToFit("",windowWidth)
	msgwindow.x = (Graphics.width - windowWidth)/2
	msgwindow.width = windowWidth
	# msgwindow.y = Graphics.height - TEXTBOX_HEIGHT	# Y position is just right
	$game_temp.message_window_showing=true if $game_temp
	$game_message.visible=true if $game_message
	msgwindow.setSkin(pbResolveBitmap("Graphics/Windowskins/fullbox")||"")
	return msgwindow
end

def fbText(message,commands=nil,cmdIfCancel=0,defaultCmd=0,&block)
	ret=0
	fbEcholn("*******************************\r\nText: " + message)
	# @background = Sprite.new()
	# @background.y = Graphics.height - TEXTBOX_HEIGHT
	# @background.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	message = "<c3=" + FBTEXTCOLOR + "," + FBTEXTSHADOW + ">" + message + "</c3>";
	msgwindow=Kernel.pbCreateFullboxWindow(nil)
	fbSpeaking(true)
	fbUpdate
	if commands
		ret=Kernel.pbMessageDisplayFullbox(msgwindow,message,true,
			proc {|msgwindow|
				next Kernel.pbShowCommands(msgwindow,commands,cmdIfCancel,defaultCmd,&block)
			},&block)
	else
		Kernel.pbMessageDisplayFullbox(msgwindow,message,&block)
	end
	Kernel.pbDisposeMessageWindow(msgwindow)
	fbSpeaking(false)
	fbUpdate(false)
	# @background.dispose
	Input.update
	return ret
end

def Kernel.pbMessageDisplayFullbox(msgwindow,message,letterbyletter=true,commandProc=nil)
	return if !msgwindow
	oldletterbyletter=msgwindow.letterbyletter
	msgwindow.letterbyletter=(letterbyletter ? true : false)
	ret=nil
	count=0
	commands=nil
	facewindow=nil
	goldwindow=nil
	coinwindow=nil
	cmdvariable=0
	cmdIfCancel=0
	msgwindow.waitcount=0
	autoresume=false
	text=message.clone
	msgback=nil
	linecount=(Graphics.height>400) ? 3 : 2
	### Text replacement
	text.gsub!(/\\\\/,"\5")
	if $game_actors
		text.gsub!(/\\[Nn]\[([1-8])\]/){ 
			m=$1.to_i
			next $game_actors[m].name
		}
	end
	text.gsub!(/\\[Ss][Ii][Gg][Nn]\[([^\]]*)\]/){ 
		next "\\op\\cl\\ts[]\\w["+$1+"]"
	}
	text.gsub!(/\\[Pp][Nn]/,$Trainer.name) if $Trainer
	text.gsub!(/\\[Pp][Mm]/,_INTL("${1}",$Trainer.money)) if $Trainer
	text.gsub!(/\\[Nn]/,"\n")
	text.gsub!(/\\\[([0-9A-Fa-f]{8,8})\]/){ "<c2="+$1+">" }
	text.gsub!(/\\[Bb]/,"<c2=6546675A>")
	text.gsub!(/\\[Rr]/,"<c2=043C675A>")
	text.gsub!(/\\1/,"\1")
	colortag=""
	isDarkSkin=isDarkWindowskin(msgwindow.windowskin)
	if ($game_message && $game_message.background>0) ||
		($game_system && $game_system.respond_to?("message_frame") &&
			$game_system.message_frame != 0)
		colortag=getSkinColor(msgwindow.windowskin,0,true)
	else
		colortag=getSkinColor(msgwindow.windowskin,0,isDarkSkin)
	end
	text.gsub!(/\\[Cc]\[([0-9]+)\]/){ 
		m=$1.to_i
		next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
	}
	begin
		last_text = text.clone
		text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
	end until text == last_text
	begin
		last_text = text.clone
		text.gsub!(/\\[Ll]\[([0-9]+)\]/) { 
			linecount=[1,$1.to_i].max;
			next "" 
		}
	end until text == last_text
	text=colortag+text
	### Controls
	textchunks=[]
	controls=[]
	while text[/(?:\\([WwFf]|[Ff][Ff]|[Tt][Ss]|[Cc][Ll]|[Mm][Ee]|[Ss][Ee]|[Ww][Tt]|[Ww][Tt][Nn][Pp]|[Cc][Hh])\[([^\]]*)\]|\\([Gg]|[Cc][Nn]|[Ww][Dd]|[Ww][Mm]|[Oo][Pp]|[Cc][Ll]|[Ww][Uu]|[\.]|[\|]|[\!]|[\x5E])())/i]
		textchunks.push($~.pre_match)
		if $~[1]
			controls.push([$~[1].downcase,$~[2],-1])
		else
			controls.push([$~[3].downcase,"",-1])
		end
		text=$~.post_match
	end
	textchunks.push(text)
	for chunk in textchunks
		chunk.gsub!(/\005/,"\\")
	end
	textlen=0
	for i in 0...controls.length
		control=controls[i][0]
		if control=="wt" || control=="wtnp" || control=="." || control=="|"
			textchunks[i]+="\2"
		elsif control=="!"
			textchunks[i]+="\1"
		end
		textlen+=toUnformattedText(textchunks[i]).scan(/./m).length
		controls[i][2]=textlen
	end
	text=textchunks.join("")
	unformattedText=toUnformattedText(text)
	signWaitCount=0
	haveSpecialClose=false
	specialCloseSE=""
	for i in 0...controls.length
		control=controls[i][0]
		param=controls[i][1]
		if control=="f"
			facewindow.dispose if facewindow
			facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
		elsif control=="op"
			signWaitCount=21
		elsif control=="cl"
			text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
			haveSpecialClose=true
			specialCloseSE=param
		elsif control=="se" && controls[i][2]==0
			startSE=param
			controls[i]=nil
		elsif control=="ff"
			facewindow.dispose if facewindow
			facewindow=FaceWindowVX.new(param)
		elsif control=="ch"
			cmds=param.clone
			cmdvariable=pbCsvPosInt!(cmds)
			cmdIfCancel=pbCsvField!(cmds).to_i
			commands=[]
			while cmds.length>0
				commands.push(pbCsvField!(cmds))
			end
		elsif control=="wtnp" || control=="^"
			text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
		end
	end
	if startSE!=nil
		pbSEPlay(pbStringToAudioFile(startSE))
	elsif signWaitCount==0 && letterbyletter
		pbPlayDecisionSE()
	end
	########## Position message window  ##############
	msgwindow.text=text
	# pbRepositionMessageWindow(msgwindow,linecount)	We don't need reposition
	if $game_message && $game_message.background==1
		msgback=IconSprite.new(0,msgwindow.y,msgwindow.viewport)
		msgback.z=msgwindow.z-1
		msgback.setBitmap("Graphics/System/MessageBack")
	end
	if facewindow
		pbPositionNearMsgWindow(facewindow,msgwindow,:left)
		facewindow.viewport=msgwindow.viewport
		facewindow.z=msgwindow.z
	end
	atTop=(msgwindow.y==0)
	########## Show text #############################
	#msgwindow.text=text
	Graphics.frame_reset if Graphics.frame_rate>40
	begin
		if signWaitCount>0
			signWaitCount-=1
			if atTop
				msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
			else
				msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
			end
		end
		for i in 0...controls.length
			if controls[i] && controls[i][2]<=msgwindow.position && msgwindow.waitcount==0
				control=controls[i][0]
				param=controls[i][1]
				if control=="f"
					facewindow.dispose if facewindow
					facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					facewindow.viewport=msgwindow.viewport
					facewindow.z=msgwindow.z
				elsif control=="ts"
					if param==""
						msgwindow.textspeed=-999
					else
						msgwindow.textspeed=param.to_i
					end
				elsif control=="ff"
					facewindow.dispose if facewindow
					facewindow=FaceWindowVX.new(param)
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					facewindow.viewport=msgwindow.viewport
					facewindow.z=msgwindow.z
				elsif control=="g" # Display gold window
					goldwindow.dispose if goldwindow
					goldwindow=pbDisplayGoldWindow(msgwindow)
				elsif control=="cn" # Display coins window
					coinwindow.dispose if coinwindow
					coinwindow=pbDisplayCoinsWindow(msgwindow,goldwindow)
				elsif control=="wu"
					msgwindow.y=0
					atTop=true
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
				elsif control=="wm"
					atTop=false
					msgwindow.y=(Graphics.height/2)-(msgwindow.height/2)
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
				elsif control=="wd"
					atTop=false
					msgwindow.y=(Graphics.height)-(msgwindow.height)
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
				elsif control=="."
					msgwindow.waitcount+=Graphics.frame_rate/4
				elsif control=="|"
					msgwindow.waitcount+=Graphics.frame_rate
				elsif control=="wt" # Wait
					param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
					msgwindow.waitcount+=param.to_i*2
				elsif control=="w" # Windowskin
					if param==""
						msgwindow.windowskin=nil
					else
						msgwindow.setSkin("Graphics/Windowskins/#{param}")
					end
					msgwindow.width=msgwindow.width  # Necessary evil
				elsif control=="^" # Wait, no pause
					autoresume=true
				elsif control=="wtnp" # Wait, no pause
					param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
					msgwindow.waitcount=param.to_i*2
					autoresume=true
				elsif control=="se" # Play SE
					pbSEPlay(pbStringToAudioFile(param))
				elsif control=="me" # Play ME
					pbMEPlay(pbStringToAudioFile(param))
				end
				controls[i]=nil
			end
		end
		break if !letterbyletter
		Graphics.update
		Input.update
		facewindow.update if facewindow
		if $DEBUG && Input.trigger?(Input::F6)
			pbRecord(unformattedText)
		end
		if autoresume && msgwindow.waitcount==0
			msgwindow.resume if msgwindow.busy?
			break if !msgwindow.busy?
		end
		mouseClicked = ($mouse != nil ? $mouse.leftClick? : false)
		if (Input.trigger?(Input::C) || Input.trigger?(Input::B) || mouseClicked)
			if msgwindow.busy?
				pbPlayDecisionSE() if msgwindow.pausing?
				msgwindow.resume
			else
				break if signWaitCount==0
			end
		end
		pbUpdateSceneMap
		msgwindow.update
		yield if block_given?
	end until (!letterbyletter || commandProc || commands) && !msgwindow.busy?
	Input.update # Must call Input.update again to avoid extra triggers
	msgwindow.letterbyletter=oldletterbyletter
	if commands
		$game_variables[cmdvariable]=Kernel.pbShowCommands(
			msgwindow,commands,cmdIfCancel)
		$game_map.need_refresh = true if $game_map
	end
	if commandProc
		ret=commandProc.call(msgwindow)
	end
	msgback.dispose if msgback
	goldwindow.dispose if goldwindow
	coinwindow.dispose if coinwindow
	facewindow.dispose if facewindow
	if haveSpecialClose
		pbSEPlay(pbStringToAudioFile(specialCloseSE))
		atTop=(msgwindow.y==0)
		for i in 0..20
			if atTop
				msgwindow.y=-(msgwindow.height*(i)/20)
			else
				msgwindow.y=Graphics.height-(msgwindow.height*(20-i)/20)
			end
			Graphics.update
			Input.update
			pbUpdateSceneMap
			msgwindow.update
		end
	end
	return ret
end























class Window_Fullbox < Window_AdvancedTextPokemon
	
	alias initialize_old initialize
	alias dispose_old dispose
	
	def initialize(text="")
		initialize_old(text)
		self.contents_opacity = 0
		self.height = TEXTBOX_HEIGHT
		self.y = Graphics.height - @height
		@background = Sprite.new()
		@background.z = 100000
		@background.y = Graphics.height - @height
		@background.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	end
	
	def dispose
		dispose_old
		@background.dispose
	end
end

################################################################################
# FULLBOX CLASS
################################################################################

class Mugshot_Name		# NB: Viewport used have a Z = 9998
	attr_reader	:position
	attr_reader	:visible
	attr_reader	:name
	attr_accessor	:active
	
	def initialize(text,position)
		@name = text.gsub("@PN", ($Trainer ? $Trainer.name : ""))
		mHeight = Graphics.height - TEXTBOX_HEIGHT - 30
		@viewportRect = Rect.new(0,mHeight,Graphics.width+MUGNAME_BGEXTREME*2,35)
		@viewport = Viewport.new(@viewportRect)
		@viewport.z = 100000
		@sprites ={}
		@sprites["start"] = Sprite.new(@viewport)
		@sprites["centre"] = Sprite.new(@viewport)
		@sprites["end"] = Sprite.new(@viewport)
		@sprites["name"] = Sprite.new(@viewport)
		@sprites["name"].bitmap =Bitmap.new(Graphics.width,35)
		pbSetSystemFont(@sprites["name"].bitmap)
		length = @sprites["name"].bitmap.text_size(@name).width
		@rectWidth = length+MUGNAME_TEXTMARGIN*2
		rect = Rect.new(0,0,@rectWidth,35)
		@sprites["start"].bitmap = Bitmap.new("Graphics/Pictures/mugname-start.png")
		@sprites["centre"].bitmap = Bitmap.new(@rectWidth,35)
		@sprites["centre"].x = MUGNAME_BGEXTREME
		@sprites["centre"].bitmap.fill_rect(rect,MUGNAME_BGCOLOR)
		@sprites["end"].bitmap = Bitmap.new("Graphics/Pictures/mugname-end.png")
		@sprites["end"].x = MUGNAME_BGEXTREME + @rectWidth
		@sprites["name"].bitmap.draw_text(MUGNAME_TEXTMARGIN+MUGNAME_BGEXTREME,3,length,30,@name)
		@active = true
		self.visible = false
		setPosition(position)
	end
	
	def setPosition(position)
		case position
		when :left
			@viewportRect.x = -MUGNAME_BGEXTREME
			@position = :left
		when :centre
			@viewportRect.x = (Graphics.width - @rectWidth - MUGNAME_BGEXTREME*2) / 2
			@position = :centre
		when :right
			@viewportRect.x = Graphics.width - (@rectWidth + MUGNAME_BGEXTREME)
			@position = :right
		when :out_left, :out_right
			@viewportRect.x = Graphics.width	# Dropping out of screen
		else
			raise PositionNotValidError.new
		end
		@viewport.rect = @viewportRect
	end
	
	def position=(position)
		setPosition(position)
	end
	
	def visible=(visible)
		return if !@active
		fbEcholn("Name visible called with: " + visible.to_s + "," + @active.to_s)
		@sprites.each_value {|sprite| sprite.visible = visible}
		@visible = visible
	end
	
	def update
		pbUpdateSpriteHash(@sprites)
	end
	
	def dispose
		pbDisposeSpriteHash(@sprites)
	end
	
end

class Mugshot < Sprite
	attr_reader		:active
	attr_reader		:current_active
	attr_accessor	:type
	attr_accessor	:pose
	attr_accessor	:position
	
	def initialize(type,pose,position)
		@viewportRect = Rect.new(0,Graphics.height - TEXTBOX_HEIGHT - MUGSHOTHEIGHT,MUGSHOTWIDTH,MUGSHOTHEIGHT)
		@viewport = Viewport.new(@viewportRect)
		@viewport.z = 100000
		super(@viewport)
		@active = true
		@current_active = true
		@type = type
		@pose = pose
		@animations = {"transition" => {"active" => false,"frameCount" => 0,"frameNum" => 0,"ppf" => 0.0,"realPosition" => 0.0},
			"fading" => {"active" => false,"opf" => 0.0,"realOpacity" => 0.0}}
		@animating = false
		setPosition(position)
		setMugshot
	end
	
	def update
		super
		if isTransiting?
			@animations["transition"]["realPosition"] += @animations["transition"]["ppf"]
			@viewportRect.x = @animations["transition"]["realPosition"].round if @animations["transition"]["frameCounter"] < @animations["transition"]["frameNum"]
			@viewport.rect = @viewportRect
			@animations["transition"]["frameCounter"] += 1
			# Kernel.fbEcholn(@animations["transition"]["frameCounter"].to_s + "/" + @animations["transition"]["frameNum"].to_s + " - Real position = " + @animations["transition"]["realPosition"].to_s)
			if @animations["transition"]["frameCounter"] >= @animations["transition"]["frameNum"]
				setPosition(@position)
				@animations["transition"]["realPosition"] = 0
				@animations["transition"]["frameCounter"] = 0
				@animations["transition"]["frameNum"] = 0
				@animations["transition"]["ppf"] = 0
				@animations["transition"]["active"] = false
				@animating = false if !@animations["fading"]["active"]
			end
		end
		if isFading?
			@animations["fading"]["realPosition"] += @animations["fading"]["opf"]
			self.opacity = @animations["fading"]["realPosition"].round
			if self.opacity >= 255 || self.opacity <= 0
				@animations["fading"]["realPosition"] = 0
				@animations["fading"]["opf"] = 0
				@animations["fading"]["active"] = false
				@animating = false if !@animations["transition"]["active"]
				if self.opacity <= 0
					self.visible = false
					self.opacity = 255
				else
					self.visible = true
				end
			end
		end
		if @active != @current_active
			@active ? self.tone = MUGSHOT_DEFAULTONE : self.tone = MUGSHOT_DARKTONE
			@current_active = @active
		end
	end
	
	def isAnimating?
		return @animating
	end
	
	def isTransiting?
		return @animations["transition"]["active"]
	end
	
	def isFading?
		return @animations["fading"]["active"]
	end
	
	def x=(x)
		@viewport = x
	end
	
	def setMugshot(type=nil,pose=nil)
		@type = type if type
		@pose = pose if pose
		path = "Graphics/Mugshots/" + @type + "-" + @pose
		self.bitmap.dispose if self.bitmap
		self.bitmap = Bitmap.new(path)
		end
		
		def position=(pos)
			setPosition(pos)
		end
	
	def setPosition(position, frames=0)	# Can be :left :right or :centre
		if frames < 2
			@viewportRect.x = pixelPosition(position)
			@position = position
			@viewport.rect = @viewportRect
		else
			# Debug
			Kernel.fbEcholn("Called setPosition")
			@animations["transition"]["ppf"] = incrementPerFrame(pixelPosition(@position),pixelPosition(position),frames)
			@animations["transition"]["frameCounter"] = 0
			@animations["transition"]["frameNum"] = frames
			@animating = true
			@animations["transition"]["active"] = true
			@animations["transition"]["realPosition"] = @viewportRect.x
			@position = position
		end
	end
	
	def pixelPosition(position)
		case position
		when :left
			ret = -38														# Left align
		when :centre
			ret = (Graphics.width - MUGSHOTWIDTH) / 2						# Center align	
		when :right
			ret = Graphics.width - MUGSHOTWIDTH + 30						# Right align
		when :out_left
			ret = -MUGSHOTWIDTH												# Out on left side
		when :out_right
			ret = Graphics.width											# Out on right side
		else
			raise PositionNotValid.new
		end
		return ret
	end
	
	def incrementPerFrame(startPos,endPos,frames)
		space = endPos - startPos
		ipf = space.to_f/frames
		return ipf
	end
	
	def active=(active)
		@active = active
	end
	
	def setVisibility(visible,frames=0)
		if frames < 2
			self.visible = visible
		else
			visible ? newOpacity = 255 : newOpacity = 0
			@animations["fading"]["opf"] = incrementPerFrame(self.opacity,newOpacity,frames)
			@animating = true
			@animations["fading"]["active"] = true
			@animations["fading"]["realPosition"] = self.opacity
		end
	end
end

class PositionNotValidError < Exception
	def to_s
		return "Position not valid"
	end
end
=end