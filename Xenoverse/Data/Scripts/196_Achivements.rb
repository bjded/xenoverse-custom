################################################################################
# ACHIEVEMENTS
# Version: 1.0
# Date: 01/02/2017
# Developer: Fuji
# All rights reserved.
################################################################################

# SETTINGS

# Don't delete achivement! If you want to not show it add the attribute
# "disabled = 1"
ACHIEVEMENT_DEBUG = false
ACHIEVEMENT_FONT_SIZE = 24
ACHIEVEMENT_FONT_SIZE_NOTSEL = 52
ACHIEVEMENT_FONT_NAME = "Barlow Condensed"
BASE_COLOR = Color.new(230,230,230)
SHADOW_COLOR = Color.new(148,148,165,170)
COMPLETED_COLOR = Color.new(76,175,80)
SHADOW_COMPLETED_COLOR = Color.new(0,0,0,30)
PROGRESS_WIDTH = 180
PROGRESS_HEIGHT = 14
PROGRESS_BORDER = 2

# From here, don't touch please
$notification = nil
$achtr={}

def pbCreateAchievementTranslation
	f = File.open("PBS/achtr.txt","w")
	for k in $achievements.keys
		f.write($achievements[k].title)
		f.write("\n")
		f.write($achievements[k].title)
		f.write("\n")
		f.write($achievements[k].description)
		f.write("\n")
		f.write($achievements[k].description)
		f.write("\n")
	end
	f.close
end

def pbLoadAchievementTranslation
	f = File.open("PBS/achtr.txt")
	l=0
	key=nil
	f.readlines.each do |line|
		
		if l%2==0
			$achtr[line.gsub("\n","")]=nil
			key=line.gsub("\n","")
		else
			$achtr[key]=line.gsub("\n","")
			key=nil
		end
		l+=1
	end
	f.close
end

class Achievement
	attr_accessor	:name
	attr_accessor	:title
	attr_accessor	:description
	attr_accessor	:image
	attr_accessor	:amount
	attr_reader		:progress
	attr_accessor	:hidden
	attr_accessor	:locked
	attr_accessor	:callback
	attr_accessor	:disabled
	
	def initialize(name)
		@name = name
		@title = ""
		@description = ""
		@image = "Graphics/Achievements/default.png"
		@amount = 1
		@progress = 0
		@hidden = true
		@locked = false
		@callback = nil
		@disabled = false
	end
	
	# Used for print all achievements
	def each
		yield "name", @name
		yield "title", @title
		yield "description", @description
		yield "image", @image
		yield "amount", @amount
		yield "progress", @progress
		yield "name", @hidden
		yield "locked", @locked
		yield "callback", @callback
		yield "disabled", @disabled
	end
	
	def silentProgress(val,mute = false)
		@progress = val
    Achievement_UI.onChangeProgress(self.clone) if @progress == @amount && !mute
	end
	
	# Change progress
	def progress=(val)
		
		#if val < 0
		#	@progress = 0
		#elsif val > @amount
		#	@progress = @amount + 1
		#else
		#	@progress += val
		#end
    
    
    
    if val < 0
      @progress = 0
    else
      @progress += val
    end
		
    @hidden = false if @progress>0
    
		# Check if quest is completed, if yes, call the callback method
		# with 'self' as argument
		if @progress <= @amount && @progress > 0
			#if callback != nil
			#	callback.call(self)
			#end
      Achievement_UI.onChangeProgress(self.clone)
		end
		pbCheckPlatinumAchi
		# Call UI event
    #Achievement_UI.onChangeProgress(self.clone)
	end
	
	# Return if the achievement is completed
	def completed
		return self.progress >= self.amount
	end
	
	# Used to set values from load
	def assign(iKey,iValue)
		case iKey
		when "title"
			self.title = iValue
		when "description"
			# 0 italian, 1 english ## $achtr[key] achievements translation
			self.description = iValue
		when "image"
			self.image = "Graphics/Achievements/" + iValue + ".png"
		when "amount"
			self.amount = iValue.to_i || 1
		when "hidden"
			self.hidden = (iValue == "1" ? true : false)
		when "locked"
			self.locked = (iValue == "1" ? true : false)
		when "callback"
			self.callback = method(iValue.to_sym)
		when "disabled"
			self.disabled = (iValue == "1" ? true : false)
		end
	end
	
	def export
		return {"progress" => @progress, "hidden" => @hidden, "locked" => @locked}
	end
	
	class << self
		# Re-import achievements from PBS (to call if new achievements is added)
		def importAchievements
			if !$achievements
				$achievements = {}
			end
			achievementsPBS = pbReadPBS("achievements")
			$orderedAchievements=Array.new(achievementsPBS.values.length)
			achievementsPBS.each do |key,value|
				if !$achievements.has_key?(key)
					$achievements[key] = Achievement.new(key)
					value.each do |iKey,iValue|
						achieve = $achievements[key]
						echoln(iKey + " => " + iValue)
						# List of prorieties imported
						case iKey
						when "title"
							achieve.title = iValue
						when "description"
							achieve.description = iValue
						when "image"
							id = iValue.scan(/\d+/)[0].to_i
							$orderedAchievements[id] = key
							achieve.image = "Graphics/Achievements/" + iValue + ".png"
						when "amount"
							achieve.amount = iValue.to_i || 1
						when "hidden"
							achieve.hidden = (iValue == "1" ? true : false)
						when "locked"
							achieve.locked = (iValue == "1" ? true : false)
						when "callback"
							achieve.callback = method(iValue.to_sym)
						when "disabled"
							achieve.disabled = (iValue == "1" ? true : false)
						end
					end
				end
			end
			# Save data after importing
			self.saveData
		end
		
		def load(newGame=false)
			# Create a new empty Hash to place achievements
			$achievements = {}
			# Load
			pbsData = pbReadPBS("achievements")
			if File.exist?(RTP.getSaveFileName("Achievements.rxdata")) && !newGame
				achieve_echoln("Achievement data found, loading...")
				File.open(RTP.getSaveFileName("Achievements.rxdata"), "rb") { |f|
					loadedData = Marshal.load(f)
					self.createObjects(pbsData)
					$achievements.each do |key,val|
						if $achievements.has_key?(key) && loadedData.has_key?(key)
							$achievements[key].silentProgress(loadedData[key][0],true)
							$achievements[key].hidden = loadedData[key][1]
							$achievements[key].locked = loadedData[key][2]
						end
					end
				}

				#loadedData = load_data(RTP.getSaveFileName("Achievements.rxdata"))
				#achieve_echoln(loadedData.inspect)
				#self.createObjects(pbsData)
				#$achievements.each do |key,val|
				#	if $achievements.has_key?(key) && loadedData.has_key?(key)
				#		$achievements[key].silentProgress(loadedData[key][0],true)
				#		$achievements[key].hidden = loadedData[key][1]
				#		$achievements[key].locked = loadedData[key][2]
				#	end
				#end
			else
				achieve_echoln("No data found, creating it...")
				self.createObjects(pbsData)
				# Save for a better useless operations
				#self.save
			end
      
      #Fix for hidden handling
      for i in $achievements.values
        i.hidden = true if i.progress==0
      end
      
		end
		
		def save
			echoln("Saving achievements")
			#dataToSave = {}
			#$achievements.each do |key,value|
			#	dataToSave[key] = value.export
			#end
			#save_data(dataToSave,RTP.getSaveFileName("Achievements.rxdata"))
			dataToSave = {}
			$achievements.each do |key,val|
				dataToSave[key] = [val.progress,val.hidden,val.locked]
			end
			save_data(dataToSave,RTP.getSaveFileName("Achievements.rxdata"))
		end
		
		def createObjects(pbs,load=nil)
			pbLoadAchievementTranslation
			$orderedAchievements=Array.new(pbs.values.length)
			pbs.each do |key,value|
				$achievements[key] = Achievement.new(key)
				value.each do |iKey,iValue|
					achieve_echoln(iKey + " => " + iValue)
						# Import value to the object
						$achievements[key].assign(iKey,iValue)
					if iKey=="image"	
						id = iValue.scan(/\d+/)[0].to_i
						$orderedAchievements[id] = key
					end
				end
				if load != nil
					load.each do |iKey,iValue|
						# Overwrite existing data to the object loaded from PBS
						$achievements[key].assign(iKey,iValue)
					end
				end
			end
			$orderedAchievements.compact!
		end
		
		
# OLD SYSTEM
=begin
		def loadData
			if File.exists?(RTP.getSaveFileName("Achievements.rxdata"))
				achieve_echoln("Existing Achievements data found, loading")
				$achievements = load_data(RTP.getSaveFileName("Achievements.rxdata"))
			else
				achieve_echoln("No data found, creating it")
				self.importAchievements
			end
		end
			
		def saveData
			achieve_echoln("Saving achievements data")
			save_data($achievements,RTP.getSaveFileName("Achievements.rxdata"))
		end
=end
	end
	
	# DEPRECATED
=begin
	def setProgress(achivKey,val,save=true)
		achive = $achievements[achivKey]
		if val < 0
			achive.progress = 0
		elsif val > achive.amount
			achiveprogress = achive.amount
		else
			achive.progress = val
		end
		Achivement_UI.onChangeProgress(achive)
		if achive.progress == achive.amount
			
		end
		self.saveData if save
	end

	def isCompleted?(achiveKey)
		if $achievements[achivKey]["progress"] >= $achievements[achivKey]["amount"]
			return true
		else
			return false
		end
	end
	
	def isHidden?(achiveKey)
		if $achivements[achiveKey]["hidden"] != nil && $achivements[achiveKey]["hidden"] == 1
			return true
		else
			return false
		end
	end
	
	def isLocked?(achiveKey)
		if $achivements[achiveKey]["locked"] != nil && $achivements[achiveKey]["locked"] == 1
			return true
		else
			return false
		end
	end
	
	def addProgress(achiv,val,save=true)
		$achievements[achiv]["progress"] += val
		Achivement_UI.onChangeProgress($achievements[achiv])
		self.saveData if save
end
=end
end

module Achievement_Var
	@time = 0
	@queue = []
	@achievement = nil
	def self.time; @time; end
	def self.time=(val); @time = val; end
	def self.push(element); @queue.push(element); end
	def self.pull; @queue.delete_at(0); end
	def self.empty; @queue.empty?; end
	def achievement; @achievement; end
	def achievement=(achive); @achievement = achive; end
end


class Achievement_UI
	class << self
		def onChangeProgress(achiv)
			achieve_echoln(achiv.name + " changed")
			# Ignore locked or hidden achievements
			if achiv.locked == true || (achiv.hidden == true && !achiv.completed)
				achieve_echoln("Notification hidden")
				return
			end
			if $notification != nil
				achieve_echoln("Another notification in progress, wait...")
				Achievement_Var.push(achiv)
				return
			end
			
			# Construct the graphics
			$notification = EAMSprite.new
			$notification.z = 1000100
			$notification.x = 10
			$notification.y = -98
			$notification.zoom_x = 0.8
			$notification.zoom_y = 0.8
			$notification.opacity = 0
			$notification.bitmap = Bitmap.new(380,94)
			bitmap = Bitmap.new("Graphics/Pictures/Achievements/body.png")
			$notification.bitmap.blt(47,16,bitmap,bitmap.rect)
			bitmap = Bitmap.new("Graphics/Pictures/Achievements/image_bg.png")
			$notification.bitmap.blt(6,3,bitmap,bitmap.rect)
			bitmap = Bitmap.new(achiv.image)
			$notification.bitmap.blt(6,3,bitmap,bitmap.rect)
			bitmap = Bitmap.new("Graphics/Pictures/Achievements/image_border.png")
			$notification.bitmap.blt(0,0,bitmap,bitmap.rect)
			pbSetSmallFont($notification.bitmap)
			pbDrawShadowText($notification.bitmap,88,18,262,24,$PokemonSystem.language==0 ? achiv.title : $achtr[achiv.title],BASE_COLOR,SHADOW_COLOR,1)
			graphicProgress($notification.bitmap,achiv)
			$notification.move(10,8,20,:ease_out_quad)
			$notification.fade(255,20,:ease_out_quad)
			$notification.zoom(1,1,20,:ease_out_quad,Proc.new{ |sender,value| Achievement_UI.setTimer})
			pbSEPlay("achievement_ring.mp3")
			
			# Hook to Graphics.update
			achieve_echoln("Showing notification")
			@@code = Proc.new{ |sender| $notification.update }
			Graphics.onUpdate += @@code
		end
		
		def setTimer
			# Wait until hide
			echoln("Setting timer")
			Achievement_Var.time = 0
			Graphics.onUpdate -= @@code
			@@code = Proc.new do |sender|
				Achievement_Var.time += 1
				Achievement_UI.startHide if Achievement_Var.time == 120
			end
			Graphics.onUpdate += @@code
		end	
		
		def startHide
			# Hide notification
			achieve_echoln("Hiding notification")
			Graphics.onUpdate -= @@code
			$notification.move(10,-98,20,:ease_out_quad)
			$notification.fade(0,20,:ease_out_quad)
			$notification.zoom(0.8,0.8,20,:ease_out_quad,Proc.new{ |sender,value| Achievement_UI.deleteNotification})
			@@code = Proc.new do |sender|
				$notification.update
			end
			Graphics.onUpdate += @@code
		end

		
		def deleteNotification
			# Delete notification and call the next (if exist)
			achieve_echoln("Deleting notification and calling the next")
			Graphics.onUpdate -= @@code
			$notification.dispose
			$notification = nil
			if !Achievement_Var.empty
				Achievement_UI.onChangeProgress(Achievement_Var.pull)
			end
		end
		
		def graphicProgress(bitmap,achiv)
			# Build the progress
			pbSetSmallFont(bitmap)
			if achiv.progress == 0
				# If Progress = 0 print "New Achievement"
				pbDrawShadowText(bitmap,88,40,262,28,_INTL("New Achivement!"),BASE_COLOR,SHADOW_COLOR,1)
			elsif achiv.progress >= achiv.amount
				# If Progress > Amount print "Completed"
				pbDrawShadowText(bitmap,88,40,262,28,_INTL("Completed!"),COMPLETED_COLOR,SHADOW_COMPLETED_COLOR,1)
			else
				# Else Show Progress/Amount and build the progress bar
				pbDrawShadowText(bitmap,88,40,70,28,achiv.progress.to_s + "/" + achiv.amount.to_s,BASE_COLOR,SHADOW_COLOR,2)
				bitmap.fill_rect(162,48,PROGRESS_WIDTH,PROGRESS_HEIGHT,Color.new(30,36,40))
				internalX = 162 + PROGRESS_BORDER
				internalY = 48 + PROGRESS_BORDER
				internalWidth = PROGRESS_WIDTH - PROGRESS_BORDER * 2
				internalHeight = PROGRESS_HEIGHT - PROGRESS_BORDER * 2
				bitmap.fill_rect(internalX,internalY,internalWidth,internalHeight,Color.new(25,27,29))
				progressWidth = (achiv.progress.to_f / achiv.amount) * internalWidth
				bitmap.fill_rect(internalX,internalY,progressWidth,internalHeight,Color.new(40,57,61))
			end
		end
    
    def progressBar(x, y, bitmap, achiv)
      # Build the progress
      color = Color.new(0,0,0)
			#pbSetSystemFont(bitmap)
      pbSetFont(bitmap,"Concielian Jet Condensed",18)
			if achiv.progress == 0
				# If Progress = 0 print "New Achievement"
        pbDrawTextPositions(bitmap, [[_INTL("???"), x, y, false, color]])
				#pbDrawShadowText(bitmap,88,40,262,28,_INTL("New Achivement!"),BASE_COLOR,SHADOW_COLOR,1)
			else
				# Else Show Progress/Amount and build the progress bar
				pbDrawTextPositions(bitmap,[[achiv.progress.to_s + "/" + achiv.amount.to_s,x,y,false,color]])
				bitmap.fill_rect(x + 50,y + 6,PROGRESS_WIDTH,PROGRESS_HEIGHT,Color.new(30,36,40))
				internalX = x + 50 + PROGRESS_BORDER
				internalY = y + 6 + PROGRESS_BORDER
				internalWidth = PROGRESS_WIDTH - PROGRESS_BORDER * 2
				internalHeight = PROGRESS_HEIGHT - PROGRESS_BORDER * 2
				bitmap.fill_rect(internalX,internalY,internalWidth,internalHeight,Color.new(25,27,29))
				progressWidth = (achiv.progress.to_f / achiv.amount) * internalWidth
				bitmap.fill_rect(internalX,internalY,progressWidth,internalHeight,Color.new(40,57,61))
			end
    end
		
    def screenProgressBar(x, y, bitmap, achiv,onbar=false)
      # Build the progress
      color = Color.new(0,0,0)
			#pbSetSystemFont(bitmap)
      oldsize = bitmap.font.size
      oldname = bitmap.font.name
      pbSetFont(bitmap,ACHIEVEMENT_FONT_NAME,ACHIEVEMENT_FONT_SIZE)
			if achiv.progress == 0
				# If Progress = 0 print "New Achievement"
        pbDrawTextPositions(bitmap, [[_INTL("???"), x, y, false, color]])
				#pbDrawShadowText(bitmap,88,40,262,28,_INTL("New Achivement!"),BASE_COLOR,SHADOW_COLOR,1)
			else
				# Else Show Progress/Amount and build the progress bar
        if !onbar
          pbDrawTextPositions(bitmap,[[achiv.progress.to_s + "/" + achiv.amount.to_s,x,y,false,color]])
				end
        bitmap.fill_rect(x + 120,y + 6,PROGRESS_WIDTH,PROGRESS_HEIGHT,Color.new(30,36,40))
				internalX = x + 120 + PROGRESS_BORDER
				internalY = y + 6 + PROGRESS_BORDER
				internalWidth = PROGRESS_WIDTH - PROGRESS_BORDER * 2
				internalHeight = PROGRESS_HEIGHT - PROGRESS_BORDER * 2
				bitmap.fill_rect(internalX,internalY,internalWidth,internalHeight,Color.new(25,27,29))
				progressWidth = (achiv.progress.to_f / achiv.amount) * internalWidth
				bitmap.fill_rect(internalX,internalY,progressWidth,internalHeight,Color.new(40,57,61))
        if onbar
          pbSetSmallFont(bitmap)
          bitmap.font.size = $MKXP ? 12 : 12
          color = Color.new(240,240,240)
          pbDrawTextPositions(bitmap,[[achiv.progress.to_s + "/" + achiv.amount.to_s,x+120+PROGRESS_BORDER+($MKXP ? 2 : 0),y+6+($MKXP ? 2 : 0),false,color]])
        else
        end
      end
      bitmap.font.size = oldsize
      bitmap.font.name = oldname
    end
    
		def onPageOpening
			# TODO
		end
	end
end

# An echo that depends on the state of ACHIEVEMENT_DEBUG constant
def achieve_echo(text)
	echo(text) if ACHIEVEMENT_DEBUG
end

def achieve_echoln(text)
	echoln(text) if ACHIEVEMENT_DEBUG
end

################################################################################
# DEBUG FUNCTIONS
# In the release, this functions will be commented
################################################################################

# Print all achievements
def printAchievements
	$achievements.each do |key,value|
		achieve_echoln("[" + key + "]")
		value.each do |iKey,iValue|
			achieve_echoln(iKey + " = " + iValue.to_s)
		end
	end
end


# Delete Achievements data with F6
def testPbReadPBS(*args)
	if Input.press?(Input::F6)
		if File.exists?(RTP.getSaveFileName("Achievements.rxdata"))
			File.delete(RTP.getSaveFileName("Achievements.rxdata"))
			achieve_echoln("Achievements data deleted")
		end
	end
end

# Overwrite saving method
def pbSave(safesave=false)
  $Trainer.metaID=$PokemonGlobal.playerID
  if $Trainer.lastGameVersion == nil || $Trainer.lastGameVersion < GAME_VERSION
	#Makes a backup any times there's a new version
	File.open(RTP.getSaveFileName("Game.rxdata"),  'rb') {|r|
		ver = $Trainer.lastGameVersion != nil ? $Trainer.lastGameVersion : ["n","n","n"]
		File.open(RTP.getSaveFileName("Game-#{ver[0]}-#{ver[1]}-#{ver[2]}.rxdata.bak"), 'wb') {|w|
		   while s = r.read(4096)
			 w.write s
		   end
		}
	 }

    $Trainer.lastGameVersion = GAME_VERSION unless $DEBUG == true


	

  end
  begin
    File.open(RTP.getSaveFileName("Game.rxdata"),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
    }
		# Saving achievements
		#Achievement.save()
		
    Graphics.frame_reset
  rescue
    return false
  end
  return true
end

# Simulate load, value change and save with F7 (also open the console)
=begin
Input.afterUpdate += Proc.new do |sender|
	if Input.trigger?(Input::F7)
		Console::setup_console
		Achievement.load
		printAchievements
		$achievements["nuovaAvventura"].progress = 0
		$achievements["nuovaAvventura"].progress += 1
		$achievements["nuovaAvventura"].progress += 1
		$achievements["nuovaAvventura"].progress += 1
		$achievements["nuovaAvventura"].progress += 1
		Achievement.save
	end
end
=end
# LOAD ACHIEVEMENTS DATA
#Achievement.load(true)

#printAchievements