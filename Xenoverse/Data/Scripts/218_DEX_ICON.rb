class DexIcon < Sprite
	include EAM_Sprite
	
	def initialize(viewport,species)
		super(viewport)
		if $Trainer.seen[species]
      #getting the earliest form seen of all
      formseen = 9999
      for g in 0...2
        for f in 0...$Trainer.formseen[species][g].length
          if $Trainer.formseen[species][g][f]
            formseen = formseen < f ? formseen : f
            break if g==1
          end
        end
      end
      formseen = formseen == 9999 ? 0 : formseen
      echoln $Trainer.formseen[species] if species == PBSpecies::BREMAND
      echoln formseen if species == PBSpecies::BREMAND
			fseen = (formseen==1 && pbResolveBitmap(Dex::PATH + "Icon/#{species}d") ? "d" : "_#{formseen}")
			self.bitmap = pbBitmap(Dex::PATH + "Icon/" + species.to_s + (formseen > 0 ? "#{fseen}" : ""))
			self.tone = Tone.new(0,0,0,200) if !$Trainer.owned[species]
			self.color = Color.new(0,0,0,100) if !$Trainer.owned[species]
			self.opacity = 175 if !$Trainer.owned[species]
		else
			self.bitmap = pbBitmap(Dex::UNSEEN)
			self.opacity = 175
		end
		
	end
	
end