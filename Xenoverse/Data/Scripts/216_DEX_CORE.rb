module Dex
	PATH = "Graphics/Pictures/DexNew/"
	UNSEEN = PATH + "unknown"#"Graphics/Pictures/DexNew/unknown"
	
	#Here are the icons displaying constants
	LINE = 6
	SPACING = 0
	LEFTBORDER = 10
	LINESPACING = 2
	ANIMBGSCROLLX = 0.5
	ANIMBGSCROLLY = -0.5
	
	#Icon scroll utilities
	LINEHEIGHT = 76
	ICONSCROLLSPEED = 10 #The smaller it is, the faster it is
	BOTTOMTHRESHOLD = 340
	
	#TextUtilities
	NUMBERFONTNAME = "Barlow Condensed"
	NUMBERFONTSIZE = $MKXP ? 18 : 20
	TEXTFONTNAME = $MKXP ? "Barlow Condensed" : "Barlow Condensed ExtraBold"
	TEXTFONTSIZE = $MKXP ? 23 : 25
	FONTBOLD = true
	
	MAINCOLOR = Color.new(248,248,248)
	
	#Slider utilities
	MAXSLIDERSIZE = 200
	
	SPRITESIZE = 2
	
  	STANDARDFONT = Font.new
	STANDARDFONT.name = ["Barlow Condensed","Verdana"]
	STANDARDFONT.size = $MKXP ? 26 : 28
	STANDARDFONT.color.set(250,250,250,255)
  
end
#===============================================================================
# Core Dex class
#  Handles every non-UI dex related calculation and filtering
#===============================================================================
class DexCore
	
	def self.countSeen(list)
		ret = 0
		for species in list
			ret +=1 if $Trainer.seen[species]
		end
		return ret
	end
	
	def self.getLastSeen(list)
		lastspecies = 0
		if list
			for species in list
				lastspecies = species if $Trainer.seen[species]
			end
		end
		return lastspecies
	end
	
	def self.countOwned(list)
		ret = 0
		for species in list
			ret +=1 if $Trainer.owned[species]
		end
		return ret
	end
	
	def self.seenList(list)
		ret = []
		for species in list
			ret.push(species) if $Trainer.seen[species]
		end
		return ret
	end
	
	def self.filterList(list)
	end
	
end
#===============================================================================
# FormInfos
#===============================================================================
class FormInfos
	attr_accessor(:description)
	attr_accessor(:type1)
	attr_accessor(:type2)
	attr_accessor(:height)
	attr_accessor(:weight)
	attr_accessor(:kind)
	
	def initialize(description,type1,type2,height,weight,kind = nil)
		@description = description
		@type1 = type1
		@type2 = type2
		@height = height
		@weight = weight
		@kind = kind
	end

	def kind
		return @kind if $PokemonSystem.language==0
		return $fdtr[@kind] if $PokemonSystem.language!=0
	end

	def description
		return @description if $PokemonSystem.language==0
		return $fdtr[@description] if $PokemonSystem.language!=0
	end
end

def pbLoadFormInfos
	ret = {}
	File.open("PBS/formdesc.txt","r") do |f|
		curform = ""
		f.each_line do |line|
			l = line.chomp
			
			if l.include?("[") && l.include?("]")
				curform = l[1,(l.index("]")-1)]
				ret[curform] = FormInfos.new("",nil,nil,nil,nil)
				next
			end
			if l.include?("DESCRIPTION=")
				ret[curform].description = l[l.index("=")+1,l.length-1]
				next
			end
			if l.include?("TYPE1=")
				ret[curform].type1 = l[l.index("=")+1,l.length-1].to_i
				ret[curform].type2 = l[l.index("=")+1,l.length-1].to_i
				next
			end
			if l.include?("TYPE2=")
				ret[curform].type2 = l[l.index("=")+1,l.length-1].to_i
				next
			end
			if l.include?("KIND=")
				ret[curform].kind = l[l.index("=")+1,l.length-1]
				next
			end
			if l.include?("HEIGHT=")
				ret[curform].height = l[l.index("=")+1,l.length-1].to_f
				echoln ret[curform].height if curform.include?("1022")
				next
			end
			if l.include?("WEIGHT=")
				ret[curform].weight = l[l.index("=")+1,l.length-1].to_f
				echoln ret[curform].height if curform.include?("1022")
				next
			end
		end
	end
	return ret
end