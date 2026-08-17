# ############################################################################ #
#                                                                              #
#   Tutor Move Cards                                                           #
#   Version: 0.0.1                                                             #
#   Author: Dr. Aghs                                                           #
#                                                                              #
# ############################################################################ #
class TutorMoveCard
	
	attr_accessor :name
	attr_accessor :image
	attr_accessor :rarity
	attr_accessor :move
	attr_accessor :quantity
	
	class << self
		
		def load()
			$tmCards = {}
			
			pbsData = pbReadPBS("tutormovecards")
			if File.exist?(RTP.getSaveFileName("Game.rxdata"))
			else
			end
			
			pbsData = pbReadPBS("tutormovecards")
			if File.exist?(RTP.getSaveFileName("TutorMoveCards.rxdata"))
				achieve_echoln("Achievement data found, loading...")
				loadedData = load_data(RTP.getSaveFileName("Achievements.rxdata"))
				#achieve_echoln(loadedData.inspect)
				self.createObjects(pbsData)
				$achievements.each do |key,val|
					$achievements[key].silentProgress(loadedData[key][0])
					$achievements[key].hidden = loadedData[key][1]
					$achievements[key].locked = loadedData[key][2]
				end
			else
				achieve_echoln("No data found, creating it...")
				self.createObjects(pbsData)
				# Save for a better useless operations
				#self.save
			end
		end
		
		def save()
		end
		
	end
	
end