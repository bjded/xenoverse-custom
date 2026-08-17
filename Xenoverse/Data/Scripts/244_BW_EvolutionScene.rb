#===============================================================================
# € BW Evolution Scene by KleinStudio
#===============================================================================

class PokemonEvolutionScene
	private
	
	def pbGenerateMetafiles(s1x,s1y,s2x,s2y)
		sprite=SpriteMetafile.new
		sprite2=SpriteMetafile.new
		sprite.opacity=255
		sprite2.opacity=0
		sprite.ox=s1x
		sprite.oy=s1y
		sprite2.ox=s2x
		sprite2.oy=s2y
		for j in 0...26
			sprite.color.red=128
			sprite.color.green=0 
			sprite.color.blue=0
			sprite.color.alpha=j*10
			sprite.color=sprite.color
			sprite2.color=sprite.color
			sprite.update
			sprite2.update
		end
		anglechange=0
		sevenseconds=Graphics.frame_rate*7
		for j in 0...sevenseconds
			sprite.angle+=anglechange
			sprite.angle%=360
			anglechange+=1 if j%2==0
			if j>=sevenseconds-50
				sprite2.angle=sprite.angle
				sprite2.opacity+=6
			end
			sprite.update
			sprite2.update
		end
		sprite.angle=360-sprite.angle
		sprite2.angle=360-sprite2.angle
		for j in 0...sevenseconds
			sprite2.angle+=anglechange
			sprite2.angle%=360
			anglechange-=1 if j%2==0
			if j<50
				sprite.angle=sprite2.angle
				sprite.opacity-=6
			end
			sprite.update
			sprite2.update
		end
		for j in 0...26
			sprite2.color.red=128
			sprite2.color.green=0 
			sprite2.color.blue=0
			sprite2.color.alpha=(26-j)*10
			sprite2.color=sprite2.color
			sprite.color=sprite2.color
			sprite.update
			sprite2.update
		end
		@metafile1=sprite
		@metafile2=sprite2
	end
	
	# Starts the evolution screen with the given Pokemon and new Pokemon species.
	public
	
	def pbStartScreen(pokemon,newspecies,item=0)
		@sprites={}
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999
		
		@canCancel = true

		@viewports=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewports.z=999999
		
		@pokemon=pokemon
		@newspecies=newspecies
		@evoanimfinished=false
		addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
			Color.new(248,248,248),@viewport)
		
		if isConst?(pokemon.item,PBItems,:STRANGESOUVENIR)
			if (isConst?(@newspecies,PBSpecies,:MAROWAK) && PBDayNight.isNight?) ||
				isConst?(@newspecies,PBSpecies,:RAICHU) ||
				isConst?(@newspecies,PBSpecies,:EXEGGUTOR)
				@pokemon.makeDelta
			end
		end
		@sprites["bg"]=GifAnim.new(0,0,@viewport,true)
		@sprites["bg"].setBitmap("Graphics/Pictures/Evolution")
		@sprites["bg"].y=DEFAULTSCREENHEIGHT/2
		
		rsprite1=PokemonSprite.new(@viewport)
		rsprite2=PokemonSprite.new(@viewport)
		
		pk=PokeBattle_Pokemon.new(newspecies,1,$Trainer)
		pk.setGender(@pokemon.gender)
		pk.form = @pokemon.form
		pk.setNature(@pokemon.nature)
		pk.makeShiny if @pokemon.isShiny?
		pk.makeDelta if @pokemon.isDelta?
		pk.checkEvolutionForm(item)
		
		@sprites["pokemon1"]=PokemonSpriteBW.new(@viewport)
		@sprites["pokemon1"].setPokemonBitmap(@pokemon,false)
		@sprites["pokemon1"].lock
		@sprites["pokemon1"].x = DEFAULTSCREENWIDTH/2
		@sprites["pokemon1"].y = DEFAULTSCREENHEIGHT/2-48
		
		@sprites["pokemon2"]=PokemonSpriteBW.new(@viewport)
		@sprites["pokemon2"].setPokemonBitmap(pk,false)
		@sprites["pokemon2"].lock
		@sprites["pokemon2"].zoom_x=0
		@sprites["pokemon2"].zoom_y=0
		@sprites["pokemon2"].tone=Tone.new(255,255,255,0)
		@sprites["pokemon2"].x = DEFAULTSCREENWIDTH/2
		@sprites["pokemon2"].y = DEFAULTSCREENHEIGHT/2-48
		
		rsprite1.setPokemonBitmap(@pokemon,false)
		rsprite2.setPokemonBitmapSpecies(@pokemon,@newspecies,false)
		
		pbPositionPokemonSprite(rsprite1, 0, 0)
		pbPositionPokemonSprite(rsprite2, 180, 148)
		rsprite2.opacity=0
		rsprite1.opacity=0
		
		@sprites["rsprite1"]=rsprite1
		@sprites["rsprite2"]=rsprite2
		pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
		
		echo @sprites["pokemon1"]
		echo @sprites["pokemon2"]
		#@sprites["msgwindow"]=Kernel.pbCreateMessageWindowSystem(0,@viewport)
		$sprites=@sprites
		pbFadeInAndShow(@sprites)
		
	end
	
	def pbStartAstroScreen(pokemon,newspecies,canCancel = false)
		@sprites={}
		
		@canCancel = false

		@viewportd=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewportd.z=99999
		@viewport=Viewport.new(0,48,Graphics.width,DEFAULTSCREENHEIGHT-48*2)
		@viewport.z=99999
		
		@viewports=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewports.z=999999
		
		@pokemon=pokemon
		@newspecies=newspecies.species
		@evoanimfinished=false
		addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
			Color.new(248,248,248),@viewport)
		
		if isConst?(pokemon.item,PBItems,:STRANGESOUVENIR)
			if (isConst?(@newspecies,PBSpecies,:MAROWAK) && PBDayNight.isNight?) ||
				isConst?(@newspecies,PBSpecies,:RAICHU) ||
				isConst?(@newspecies,PBSpecies,:EXEGGUTOR)
				@pokemon.makeDelta
			end
		end
		@sprites["black"] = Sprite.new(@viewportd)
		@sprites["black"].bitmap = Bitmap.new(512,384)
		@sprites["black"].bitmap.fill_rect(0, 0, 512, 384, Color.new(0,0,0))
		@sprites["bg"]=GifAnim.new(0,0,@viewport,true)
		@sprites["bg"].setBitmap("Graphics/Pictures/Evolution_1")
		@sprites["bg"].y=DEFAULTSCREENHEIGHT/2
		
		rsprite1=PokemonSprite.new(@viewport)
		rsprite2=PokemonSprite.new(@viewport)
		
		pk=newspecies#PokeBattle_Pokemon.new(newspecies,1,$Trainer)
		pk.setGender(@pokemon.gender)
		pk.form = 2
		pk.makeShiny if @pokemon.isShiny?
		
		@sprites["pokemon1"]=PokemonSpriteBW.new(@viewport)
		@sprites["pokemon1"].setPokemonBitmap(@pokemon,false)
		@sprites["pokemon1"].lock
		@sprites["pokemon1"].x = DEFAULTSCREENWIDTH/2
		@sprites["pokemon1"].y = DEFAULTSCREENHEIGHT/2-48
		
		@sprites["pokemon2"]=PokemonSpriteBW.new(@viewport)
		@sprites["pokemon2"].setPokemonBitmap(newspecies,false)
		@sprites["pokemon2"].lock
		@sprites["pokemon2"].zoom_x=0
		@sprites["pokemon2"].zoom_y=0
		@sprites["pokemon2"].tone=Tone.new(255,255,255,0)
		@sprites["pokemon2"].x = DEFAULTSCREENWIDTH/2
		@sprites["pokemon2"].y = DEFAULTSCREENHEIGHT/2-48
		
		rsprite1.setPokemonBitmap(@pokemon,false)
		rsprite2.setPokemonBitmap(newspecies,false)
		
		pbPositionPokemonSprite(rsprite1, 0, 0)
		pbPositionPokemonSprite(rsprite2, 180, 148)
		rsprite2.opacity=0
		rsprite1.opacity=0
		
		@sprites["rsprite1"]=rsprite1
		@sprites["rsprite2"]=rsprite2
		pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
		
		#echo @sprites["pokemon1"]
		#echo @sprites["pokemon2"]
		#@sprites["msgwindow"]=Kernel.pbCreateMessageWindowSystem(0,@viewport)
		$sprites=@sprites
		pbFadeInAndShow(@sprites)
		
	end
	
	
	def evoAnimHelper(more, vel)
		return if @canceled
		poke1=@sprites["pokemon1"]
		poke2=@sprites["pokemon2"]
		if !more
			loop do
				if Input.trigger?(Input::B) && @canCancel
					@canceled = true
				end				
				pbUpdate
				poke1.zoom_x-=vel
				poke1.zoom_y-=vel
				poke1.zoom_x=0 if poke1.zoom_x<0
				poke1.zoom_y=0 if poke1.zoom_y<0
				
				poke2.zoom_x+=vel
				poke2.zoom_y+=vel
				poke2.zoom_x=1 if poke2.zoom_x>1
				poke2.zoom_y=1 if poke2.zoom_y>1
				break if poke2.zoom_x==1 && poke1.zoom_x==0
			end
		else
			loop do
				if Input.trigger?(Input::B) && @canCancel
					@canceled = true
				end	
				pbUpdate
				poke2.zoom_x-=vel
				poke2.zoom_y-=vel
				poke2.zoom_x=0 if poke2.zoom_x<0
				poke2.zoom_y=0 if poke2.zoom_y<0
				
				poke1.zoom_x+=vel
				poke1.zoom_y+=vel
				poke1.zoom_x=1 if poke1.zoom_x>1
				poke1.zoom_y=1 if poke1.zoom_y>1
				break if poke1.zoom_x==1 && poke2.zoom_x==0
			end
		end
	end
	
	def evoAnimation
		poke1=@sprites["pokemon1"]
		poke2=@sprites["pokemon2"]
		fcolor=0
		tonescreen=0
		
		echo @sprites["pokemon1"]
		
		loop do
			pbUpdate
			fcolor+=10 if fcolor < 255
			poke1.tone=Tone.new(fcolor,fcolor,fcolor,0)
			break if fcolor>=255
		end  
		evoAnimHelper(false,0.025)
		evoAnimHelper(true,0.025)
		evoAnimHelper(false,0.05)
		evoAnimHelper(true,0.05)
		evoAnimHelper(false,0.05)
		evoAnimHelper(true,0.1)
		evoAnimHelper(false,0.1)
		evoAnimHelper(true,0.1)
		evoAnimHelper(false,0.1)
		evoAnimHelper(true,0.1)
		evoAnimHelper(false,0.1)
		evoAnimHelper(true,0.1)
		evoAnimHelper(false,0.1)
		evoAnimHelper(true,0.1)
		evoAnimHelper(false,0.1)
		evoAnimHelper(true,0.2)
		evoAnimHelper(false,0.2)
		evoAnimHelper(true,0.2)
		evoAnimHelper(false,0.2)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.3)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.3)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.3)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.3)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.3)
		evoAnimHelper(true,0.3)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		evoAnimHelper(true,0.4)
		evoAnimHelper(false,0.4)
		
		#if evolution was canceled set old sprite state
		
		loop do
			pbUpdate
			tonescreen+=10 if tonescreen < 255
			@viewports.tone.set(tonescreen,tonescreen,tonescreen,0)
			break if tonescreen>=255
		end  
		#if evolution was canceled set old sprite state
		if @canceled
			poke1.zoom_x = 1
			poke1.zoom_y = 1
			poke1.tone = Tone.new(0,0,0,0)
			poke2.zoom_x = 0
			poke2.zoom_y = 0
		end
		pbWait(20)
		loop do
			pbUpdate
			poke2.tone=Tone.new(0,0,0,0)
			poke2.unlock
			tonescreen-=5 if tonescreen > 0
			@viewports.tone.set(tonescreen,tonescreen,tonescreen,0)
			break if tonescreen<=0
		end  
		
		@evoanimfinished=true
	end
	# Closes the evolution screen.
	def pbEndScreen
		#Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
		pbMEStop()
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		pbDisposeSpriteHash($sprites) if $sprites
		@viewport.dispose
	end
	
	def pbUpdate
		Graphics.update
		Input.update
		pbUpdateSpriteHash(@sprites)
	end
	
	def pbAstroEvolution(cancancel=false)
		metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
		metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
		metaplayer1.play
		metaplayer2.play
		pbBGMStop()
		pbPlayCry(@pokemon)
		#Kernel.pbMessageSystem(1,false,_INTL("Cosa?\n{1} si sta evolvendo!",@pokemon.name))
		Kernel.pbMessage(_INTL("Cosa succede?",@pokemon.name))
		pbPlayDecisionSE()
		oldstate=pbSaveSpriteState(@sprites["rsprite1"])
		oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
		pbBGMPlay("Starter Evolution 1")
		#pbBGMPlay("Evoluzione")
		canceled=false
		
		evoAnimation
		
		if @evoanimfinished
			if canceled
				pbBGMStop()
				pbPlayCancelSE()
				Kernel.pbMessage(_INTL("Huh?\r\n{1} hai fermato l'evoluzione!",@pokemon.name))
				#Kernel.pbMessageSystem(1,false,
				#   _INTL("Huh?\r\n{1} hai fermato l'evoluzione!",@pokemon.name))
			else
				pkmnwav=pbResolveAudioSE(sprintf("%03d",@newspecies)+"Cry"+"_#{3}")
				playtime=getPlayTime(pkmnwav) if pkmnwav
				frames=pkmnwav ? (playtime*Graphics.frame_rate).ceil+4 : 20#pbCryFrameLength(@newspecies)
				pbBGMStop()
				
				#pbPlayCry(@newspecies)
				pbSEPlay(sprintf("%03d",@newspecies)+"Cry"+"_#{3}")
				frames.times do
					pbUpdate
				end
				pbMEPlay("Starter Evolution 2")
				#pbMEPlay("Pokémon Evolution pt.2")
				newspeciesname=PBSpecies.getName(@newspecies)
				oldspeciesname=PBSpecies.getName(@pokemon.species)
				#Kernel.pbMessageSystem(1,false,
				#   _INTL("Congratulazioni!\nIl tuo {1} si è evoluto in {2}!",@pokemon.name,newspeciesname))
				Kernel.pbMessage(_INTL("{1} ha cambiato aspetto!",@pokemon.name))
				removeItem=false
				createSpecies=pbCheckEvolutionEx(@pokemon){|pokemon,evonib,level,poke|
					if evonib==PBEvolution::Shedinja
						if $PokemonBag.pbQuantity(getConst(PBItems,:POKEBALL))>0
							next poke
						end
						next -1
					elsif evonib==PBEvolution::TradeItem ||
						evonib==PBEvolution::DayHoldItem ||
						evonib==PBEvolution::NightHoldItem
						if poke==@newspecies
							removeItem=true  # Item is now consumed
						end
						next -1
					else
						next -1
					end
				}
				@pokemon.setItem(0) if removeItem
				@pokemon.species=@newspecies
				$Trainer.seen[@newspecies]=true
				$Trainer.owned[@newspecies]=true
				pbSeenForm(@pokemon)
				@pokemon.firstmoves=[]
				@pokemon.name=newspeciesname if @pokemon.name==oldspeciesname
				@pokemon.calcStats
				v=0
				v=:STARBURSTSHY if @pokemon.species==PBSpecies::SHYLEON
				v=:STARBURSTTRI if @pokemon.species==PBSpecies::TRISHOUT
				v=:STARBURSTSHU if @pokemon.species==PBSpecies::SHULONG
				@pkmn = $Trainer.party.select {|p| p.species==@pokemon.species}
				@pkmn[0].setAbility(2)
				@pkmn[0].forcedForm=3
				pbLearnMove(@pkmn[0],getConst(PBMoves,v),true,false)
				@pkmn[0].forcedForm=nil
				# Check moves for new species
				#movelist=@pokemon.getMoveList
				#for i in movelist
				#	if i[0]==@pokemon.level          # Learned a new move
				#		pbLearnMove(@pokemon,i[1],true,false)
				#	end
				#end
				if createSpecies>0 && $Trainer.party.length<6
					newpokemon=@pokemon.clone
					newpokemon.iv=@pokemon.iv.clone
					newpokemon.ev=@pokemon.ev.clone
					newpokemon.species=createSpecies
					newpokemon.name=PBSpecies.getName(createSpecies)
					newpokemon.setItem(0)
					newpokemon.clearAllRibbons
					newpokemon.markings=0
					newpokemon.ballused=0
					newpokemon.calcStats
					newpokemon.heal
					$Trainer.party.push(newpokemon)
					$Trainer.seen[createSpecies]=true
					$Trainer.owned[createSpecies]=true
					pbSeenForm(newpokemon)
					$PokemonBag.pbDeleteItem(getConst(PBItems,:POKEBALL))
				end
			end
		end
		
	end
	# Opens the evolution screen
	def pbEvolution(cancancel=true,item=0)
		metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
		metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
		metaplayer1.play
		metaplayer2.play
		pbBGMStop()
		pbPlayCry(@pokemon)
		#Kernel.pbMessageSystem(1,false,_INTL("Cosa?\n{1} si sta evolvendo!",@pokemon.name))
		Kernel.pbMessage(_INTL("Cosa?\n{1} si sta evolvendo!",@pokemon.name))
		pbPlayDecisionSE()
		oldstate=pbSaveSpriteState(@sprites["rsprite1"])
		oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
		pbBGMPlay("Evoluzione")
		@canceled=false
		
		evoAnimation
		
		
		
		if @evoanimfinished
			if @canceled
				pbBGMStop()
				pbPlayCancelSE()
				Kernel.pbMessage(_INTL("Hai fermato l'evoluzione!",@pokemon.name))
				return
			else
				frames=pbCryFrameLength(@newspecies)
				pbBGMStop()
				pbPlayCry(@newspecies)
				frames.times do
					pbUpdate
				end
				pbMEPlay("Pokemon Evolution pt.2")
				newspeciesname=PBSpecies.getName(@newspecies)
				newspeciesname="Persian" if newspeciesname == "Persage" && @pokemon.isDelta?
				oldspeciesname=PBSpecies.getName(@pokemon.species)
				Kernel.pbMessage(_INTL("Congratulazioni!\nIl tuo {1} si è evoluto in {2}!",@pokemon.name,newspeciesname))
				removeItem=false
				createSpecies=pbCheckEvolutionEx(@pokemon){|pokemon,evonib,level,poke|
					if evonib==PBEvolution::Shedinja
						if $PokemonBag.pbQuantity(getConst(PBItems,:POKEBALL))>0
							next poke
						end
						next -1
					elsif evonib==PBEvolution::TradeItem ||
						evonib==PBEvolution::DayHoldItem ||
						evonib==PBEvolution::NightHoldItem
						if poke==@newspecies
							removeItem=true  # Item is now consumed
						end
						next -1
					else
						next -1
					end
				}
				@pokemon.setItem(0) if removeItem
				@pokemon.species=@newspecies
				@pokemon.checkEvolutionForm(item)
				puts "I CHECKED THE CORRECT FORM"
				$Trainer.seen[@newspecies]=true
				$Trainer.owned[@newspecies]=true
				pbSeenForm(@pokemon)
				@pokemon.firstmoves=[]
				@pokemon.name=newspeciesname if @pokemon.name==oldspeciesname
				@pokemon.calcStats
				# Check moves for new species
				movelist=@pokemon.getMoveList
				for i in movelist
					if i[0]==@pokemon.level          # Learned a new move
						pbLearnMove(@pokemon,i[1],true,false)
					end
				end
				if createSpecies>0 && $Trainer.party.length<6
					newpokemon=@pokemon.clone
					newpokemon.iv=@pokemon.iv.clone
					newpokemon.ev=@pokemon.ev.clone
					newpokemon.species=createSpecies
					newpokemon.name=PBSpecies.getName(createSpecies)
					newpokemon.setItem(0)
					newpokemon.clearAllRibbons
					newpokemon.markings=0
					newpokemon.ballused=0
					newpokemon.calcStats
					newpokemon.heal
					$Trainer.party.push(newpokemon)
					$Trainer.seen[createSpecies]=true
					$Trainer.owned[createSpecies]=true
					pbSeenForm(newpokemon)
					$PokemonBag.pbDeleteItem(getConst(PBItems,:POKEBALL))
				end
			end
		end
		
	end
end

################################################################################
# Additional utilities
################################################################################
class GifAnim
	attr_accessor :selected
	attr_accessor :shadow
	attr_accessor :sprite
	attr_accessor :src_rect
	attr_accessor :showshadow
	attr_accessor :status
	attr_reader :loaded
	
	def initialize(x,y,viewport=nil,repeat=false)
		@viewport=viewport
		@metrics=load_data("Data/metrics.dat")
		@selected=0
		@status=0
		@loaded=false
		@repeat=repeat
		@showshadow=false
		@altitude=0
		@yposition=0
		@sprite=Sprite.new(@viewport)
		@sprite.x=x
		@sprite.y=y
		
		@overlay=Sprite.new(@viewport)
		@lock=false
	end
	
	def x; @sprite.x; end
	def y; @sprite.y; end
	def z; @sprite.z; end
	def ox; @sprite.ox; end
	def oy; @sprite.oy; end
	def ox=(val);;end
	def oy=(val);;end
	def zoom_x; @sprite.zoom_x; end
	def zoom_y; @sprite.zoom_y; end
	def visible; @sprite.visible; end
	def opacity; @sprite.opacity; end
	def width; @bitmap.width; end
	def height; @bitmap.height; end
	def tone; @sprite.tone; end
	def bitmap; @bitmap.bitmap; end
	def actualBitmap; @bitmap; end
	def disposed?; @sprite.disposed?; end
	def color; @sprite.color; end
	def src_rect; @sprite.src_rect; end
	def blend_type; @sprite.blend_type; end
	def angle; @sprite.angle; end
	def mirror; @sprite.mirror; end
	def lock
		@lock=true
	end
	def unlock
		@lock=false
	end
	def bitmap=(val)
		@bitmap.bitmap=val
	end
	
	def finished?
		return @bitmap.finished?
	end
	
	def middle?
		return @bitmap.middle?
	end
	
	def x=(val)
		@sprite.x=val
	end
	def ox=(val)
		@sprite.ox=val
	end
	def oy=(val)
		@sprite.oy=val
	end
	def y=(val)
		@sprite.y=val
	end
	def zoom_x=(val)
		@sprite.zoom_x=val
	end
	def zoom_y=(val)
		@sprite.zoom_y=val
	end
	def visible=(val)
		@sprite.visible=val
	end
	def opacity=(val)
		@sprite.opacity=val
	end
	def tone=(val)
		@sprite.tone=val
	end
	def color=(val)
		@sprite.color=val
	end
	def blend_type=(val)
		@sprite.blend_type=val
	end
	def angle=(val)
		@sprite.angle=(val)
	end
	def mirror=(val)
		@sprite.mirror=(val)
	end
	def dispose
		@sprite.dispose
	end
	def z=(val)
		@sprite.z=val
	end
	
	def totalFrames; @bitmap.animationFrames; end
	def toLastFrame; @bitmap.toFrame("last"); end
	def selected; end
	
	def setBitmap(file)
		if !@repeat
			@bitmap=AnimatedBitmapWrapperAnim.new(file)
			@sprite.ox=@bitmap.width/2
			@sprite.oy=@bitmap.height/2
		else
			@bitmap=AnimatedBitmapWrapper.new(file)
			@bitmap.setSpeed(2)
			@sprite.oy=@bitmap.height/2
		end
		@sprite.bitmap=@bitmap.bitmap.clone
	end
	
	
	def update
		return if @lock
		if @bitmap
			@bitmap.update
			@sprite.bitmap=@bitmap.bitmap.clone
		end
	end  
end

class PokemonSpriteBW
	attr_accessor :selected
	attr_accessor :shadow
	attr_accessor :sprite
	attr_accessor :src_rect
	attr_accessor :showshadow
	attr_accessor :status
	attr_reader :loaded
	
	def initialize(viewport=nil)
		@viewport=viewport
		@metrics=load_data("Data/metrics.dat")
		@selected=0
		
		@status=0
		@loaded=false
		@showshadow=true
		@altitude=0
		@yposition=0
		@sprite=Sprite.new(@viewport)
		@overlay=Sprite.new(@viewport)
		@lock=false
	end
	
	def x; @sprite.x; end
	def y; @sprite.y; end
	def z; @sprite.z; end
	def ox; @sprite.ox; end
	def oy; @sprite.oy; end
	def ox=(val);;end
	def oy=(val);;end
	def zoom_x; @sprite.zoom_x; end
	def zoom_y; @sprite.zoom_y; end
	def visible; @sprite.visible; end
	def opacity; @sprite.opacity; end
	def width; @bitmap.width; end
	def height; @bitmap.height; end
	def tone; @sprite.tone; end
	def bitmap; @bitmap.bitmap; end
	def actualBitmap; @bitmap; end
	def disposed?; @sprite.disposed?; end
	def color; @sprite.color; end
	def src_rect; @sprite.src_rect; end
	def blend_type; @sprite.blend_type; end
	def angle; @sprite.angle; end
	def mirror; @sprite.mirror; end
	def lock
		@lock=true
	end
	def unlock
		@lock=false
	end
	def bitmap=(val)
		@bitmap.bitmap=val
	end
	def x=(val)
		@sprite.x=val
	end
	def ox=(val)
		@sprite.ox=val
	end
	def oy=(val)
		@sprite.oy=val
	end
	def y=(val)
		@sprite.y=val
	end
	def z=(val)
		@sprite.z=val
	end
	def zoom_x=(val)
		@sprite.zoom_x=val
	end
	def zoom_y=(val)
		@sprite.zoom_y=val
	end
	def visible=(val)
		@sprite.visible=val
	end
	def opacity=(val)
		@sprite.opacity=val
	end
	def tone=(val)
		@sprite.tone=val
	end
	def color=(val)
		@sprite.color=val
	end
	def blend_type=(val)
		@sprite.blend_type=val
	end
	def angle=(val)
		@sprite.angle=(val)
	end
	def mirror=(val)
		@sprite.mirror=(val)
	end
	def dispose
		@sprite.dispose
	end
	
	def setPokemonBitmap(pokemon,back=false)
		@bitmap=pbLoadPokemonBitmap(pokemon,back)
		@sprite.bitmap=@bitmap.bitmap.clone
		@sprite.ox=@bitmap.width/2
		@sprite.oy=@bitmap.height/2
		@loaded=true
	end
	
	def update
		return if @lock
		if @bitmap
			@bitmap.update
			@sprite.bitmap=@bitmap.bitmap.clone
		end
	end  
	
end