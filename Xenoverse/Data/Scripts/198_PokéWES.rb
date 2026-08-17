#===============================================================================
# Script: PokéWES Script
# Game: Pokémon Xenoverse
# Date: 10/04/2017
# Scripter: xZekro51
#===============================================================================
class WES_Sprite < Sprite
	include EAM_Sprite
	
	def initialize(app,viewport=nil)
		super(viewport)
		#viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		#viewport.z=99999
		#super(viewport)
		self.bitmap=Bitmap.new("Graphics/Pictures/PokeWES/" + app)
	end
end  
#===============================================================================
# Main Body
#===============================================================================
class PokeWES
	
	include EAM_Sprite
	
	def initialize(scene=false)
		#Inizializzazione
		@scene=scene
		@sprites={}
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999
		@distance=100+30
		@index=0
		@easein=:ease_in_sine
		@easeout=:ease_out_sine
		@ycord=310
		@basecolor=Color.new(255,255,255)
		
		#Creazione Sprite
		@sprites["BG"]=Sprite.new(@viewport)
		@sprites["BG"].bitmap=pbBitmap($PokemonGlobal.megaRing ? "Graphics/Pictures/PokeWES/bgMega" : "Graphics/Pictures/PokeWES/Bg")
		@sprites["BG"].z=-10
		
		@sprites["animbg"]=AnimatedPlane.new(@viewport)
		@sprites["animbg"].bitmap=pbBitmap("Graphics/Pictures/PokeWES/animbg")
		@sprites["animbg"].z=-7

		@sprites["megabg"]=AnimatedPlane.new(@viewport)
		@sprites["megabg"].bitmap=pbBitmap("Graphics/Pictures/PokeWES/megabg")
		@sprites["megabg"].z=-8
		@sprites["megabg"].visible = $PokemonGlobal.megaRing
		@sprites["megabg"].opacity = 150

		@sprites["megatoggle"] = Sprite.new(@viewport)
		@sprites["megatoggle"].bitmap = pbBitmap("Graphics/Pictures/PokeWES/megatoggle")
		@sprites["megatoggle"].zoom_x = 0.24
		@sprites["megatoggle"].zoom_y = 0.24
		@sprites["megatoggle"].x = Graphics.width-60
		@sprites["megatoggle"].y = Graphics.height-60
		@sprites["megatoggle"].visible = $PokemonGlobal.megaRing
		
		@sprites["interface"]=Sprite.new(@viewport)
		@sprites["interface"].bitmap=pbBitmap("Graphics/Pictures/PokeWES/interface")
		@sprites["interface"].z=-5
		
		@sprites["Mn"]=WES_Sprite.new("mn",@viewport)#WES_Sprite.new("mn")
		#@sprites["Mn"].bitmap=Bitmap.new("Graphics/Pictures/PokeWES/mn")
		@sprites["Mn"].y=192
		@sprites["Mn"].x=256+@distance
		@sprites["Mn"].zoom_x=0.5
		@sprites["Mn"].zoom_y=0.5
		@sprites["Mn"].opacity=200
		@sprites["Mn"].z=1
		
		@sprites["Ach"]=WES_Sprite.new("achi",@viewport)#WES_Sprite.new("achi")
		#@sprites["Ach"].bitmap=Bitmap.new("Graphics/Pictures/PokeWES/achi")
		@sprites["Ach"].y=192
		@sprites["Ach"].x=256-@distance
		@sprites["Ach"].zoom_x=0.5
		@sprites["Ach"].zoom_y=0.5
		@sprites["Ach"].opacity=200
		@sprites["Ach"].z=1
		
		@sprites["Map"]=WES_Sprite.new("map",@viewport)#WES_Sprite.new("map")
		#@sprites["Map"].bitmap=Bitmap.new("Graphics/Pictures/PokeWES/map")
		@sprites["Map"].y=192
		@sprites["Map"].x=256
		@sprites["Map"].zoom_x=0.3
		@sprites["Map"].zoom_y=0.3
		@sprites["Map"].opacity=150
		@sprites["Map"].z=0
		
		@sprites["Dex"]=WES_Sprite.new("dex",@viewport)#WES_Sprite.new("dex")
		#@sprites["Dex"].bitmap=Bitmap.new("Graphics/Pictures/PokeWES/dex")
		@sprites["Dex"].y=192
		@sprites["Dex"].x=256
		@sprites["Dex"].zoom_x=1
		@sprites["Dex"].zoom_y=1
		@sprites["Dex"].opacity=255
		@sprites["Dex"].z=2
		
		@sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay"].z=20
		@overlay=@sprites["overlay"].bitmap
		@overlay.clear
		@sprites["overlay1"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay1"].z=20
		@overlay1=@sprites["overlay1"].bitmap
		@overlay1.clear
		@sprites["overlay2"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay2"].z=20
		@overlay2=@sprites["overlay2"].bitmap
		@overlay2.clear
		@sprites["overlay3"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay3"].z=20
		@overlay3=@sprites["overlay3"].bitmap
		@overlay3.clear
		pbSetFont(@overlay,$MKXP ? "Kimberley" : "Kimberley Bl",40)
		pbSetFont(@overlay1,$MKXP ? "Kimberley" : "Kimberley Bl",40)
		pbSetFont(@overlay2,$MKXP ? "Kimberley" : "Kimberley Bl",40)
		pbSetFont(@overlay3,$MKXP ? "Kimberley" : "Kimberley Bl",40)
		
		if $game_switches[RETROMONSWITCH]
			@sprites["rd"] = BitmapSprite.new(300,200,@viewport)
			@sprites["rd"].x = 145-16#-50
			@sprites["rd"].y = 360
			
			@sprites["rd"].bitmap.font = Font.new
			@sprites["rd"].bitmap.font.name = "M42_FLIGHT 721"
			@sprites["rd"].bitmap.font.size = $MKXP ? 8 : 10
			
			pbDrawTextPositions(@sprites["rd"].bitmap,[[_INTL("Press Z to open the Retrodex"),10,4,0,Color.new(248,248,248),Color.new(48,48,48,48),true]])
		end
		@text=[
			[_INTL("PokeDex"),Graphics.width/2,@ycord,2,@basecolor,nil]
		]
		@text1=[
			[_INTL("MN"),Graphics.width/2,@ycord,2,@basecolor,nil]
		]
		@text2=[
			[_INTL("Mappa"),Graphics.width/2,@ycord,2,@basecolor,nil]
		]
		@text3=[
			[_INTL("Achievements"),Graphics.width/2,@ycord,2,@basecolor,nil]
		]
		
		
		#OYs e OXs
		@oy=@sprites["Dex"].bitmap.height/2
		@ox=@sprites["Dex"].bitmap.width/2
		
		#Coordinate centralizzate
		@sprites["Dex"].oy=@oy
		@sprites["Dex"].ox=@ox
		@sprites["Mn"].oy=@oy
		@sprites["Mn"].ox=@ox
		@sprites["Ach"].oy=@oy
		@sprites["Ach"].ox=@ox
		@sprites["Map"].oy=@oy
		@sprites["Map"].ox=@ox
		
		#Zooms
		@sprites["Dex"].setZoomPoint(@ox,@oy)
		@sprites["Mn"].setZoomPoint(@ox,@oy)
		@sprites["Ach"].setZoomPoint(@ox,@oy)
		@sprites["Map"].setZoomPoint(@ox,@oy)
		
		@sprites["overlay"].visible=true
		@sprites["overlay1"].visible=false
		@sprites["overlay2"].visible=false
		@sprites["overlay3"].visible=false
		
		pbDrawTextPositions(@overlay,@text)
		pbDrawTextPositions(@overlay1,@text1)
		pbDrawTextPositions(@overlay2,@text2)
		pbDrawTextPositions(@overlay3,@text3)
		pbFadeInAndShow(@sprites)
		self.commands
	end
	
	def commands
		loop do
			if $fly==1
				break
			end
			Graphics.update
			Input.update
			pbUpdateSpriteHash(@sprites)
			update
			
			if Input.trigger?(Input::A) && $game_switches[RETROMONSWITCH]
				pbPlayDecisionSE()
				pbFadeOutIn(99999) {
					screen = DexMain.new(1)
					screen.inputHandle
				}
			end
			
			if Input.trigger?(Input::RIGHT) && @index==0
				pbSEPlay("BW2MenuChoose",70)
				@index+=1
				@sprites["Dex"].z-=1
				@sprites["Ach"].z-=1
				@sprites["Map"].z+=1
				@sprites["Mn"].z+=1
				@sprites["Dex"].zoom(0.5,0.5,15,@easein)
				@sprites["Dex"].move(256-@distance,192,15,@easeout)
				@sprites["Mn"].zoom(1,1,15,@easeout)
				@sprites["Mn"].move(256,192,15,@easein)
				@sprites["Ach"].zoom(0.3,0.3,15,@easeout)
				@sprites["Ach"].move(256,192,15,@easein)
				@sprites["Map"].zoom(0.5,0.5,15,@easein)
				@sprites["Map"].move(256+@distance,192,15,@easeout)
				15.times do
					@sprites["Dex"].opacity-=3.7
					@sprites["Mn"].opacity+=5
					@sprites["Ach"].opacity-=3.3
					@sprites["Map"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Mn"].opacity=255
				@sprites["Dex"].opacity=200
				@sprites["Map"].opacity=200
				@sprites["Ach"].opacity=150
			elsif Input.trigger?(Input::RIGHT) && @index==1
				pbSEPlay("BW2MenuChoose",70)
				@index+=1
				@sprites["Dex"].z-=1
				@sprites["Ach"].z+=1
				@sprites["Map"].z+=1
				@sprites["Mn"].z-=1
				@sprites["Mn"].zoom(0.5,0.5,15,@easein)
				@sprites["Mn"].move(256-@distance,192,15,@easeout)
				@sprites["Map"].zoom(1,1,15,@easeout)
				@sprites["Map"].move(256,192,15,@easein)
				@sprites["Dex"].zoom(0.3,0.3,15,@easeout)
				@sprites["Dex"].move(256,192,15,@easein)
				@sprites["Ach"].zoom(0.5,0.5,15,@easein)
				@sprites["Ach"].move(256+@distance,192,15,@easeout)
				15.times do
					@sprites["Mn"].opacity-=3.7
					@sprites["Map"].opacity+=5
					@sprites["Dex"].opacity-=3.3
					@sprites["Ach"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Map"].opacity=255
				@sprites["Ach"].opacity=200
				@sprites["Mn"].opacity=200
				@sprites["Dex"].opacity=150
			elsif Input.trigger?(Input::RIGHT) && @index==2
				pbSEPlay("BW2MenuChoose",70)
				@index+=1
				@sprites["Dex"].z+=1
				@sprites["Ach"].z+=1
				@sprites["Map"].z-=1
				@sprites["Mn"].z-=1
				@sprites["Map"].zoom(0.5,0.5,15,@easein)
				@sprites["Map"].move(256-@distance,192,15,@easeout)
				@sprites["Ach"].zoom(1,1,15,@easeout)
				@sprites["Ach"].move(256,192,15,@easein)
				@sprites["Mn"].zoom(0.3,0.3,15,@easeout)
				@sprites["Mn"].move(256,192,15,@easein)
				@sprites["Dex"].zoom(0.5,0.5,15,@easein)
				@sprites["Dex"].move(256+@distance,192,15,@easeout)
				15.times do
					@sprites["Mn"].opacity-=3.7
					@sprites["Ach"].opacity+=5
					@sprites["Map"].opacity-=3.3
					@sprites["Dex"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Ach"].opacity=255
				@sprites["Dex"].opacity=200
				@sprites["Map"].opacity=200
				@sprites["Mn"].opacity=150
			elsif Input.trigger?(Input::RIGHT) && @index==3
				pbSEPlay("BW2MenuChoose",70)
				@index+=1
				@sprites["Dex"].z+=1
				@sprites["Ach"].z-=1
				@sprites["Map"].z-=1
				@sprites["Mn"].z+=1
				@sprites["Ach"].zoom(0.5,0.5,15,@easein)
				@sprites["Ach"].move(256-@distance,192,15,@easeout)
				@sprites["Dex"].zoom(1,1,15,@easeout)
				@sprites["Dex"].move(256,192,15,@easein)
				@sprites["Map"].zoom(0.3,0.3,15,@easeout)
				@sprites["Map"].move(256,192,15,@easein)
				@sprites["Mn"].zoom(0.5,0.5,15,@easein)
				@sprites["Mn"].move(256+@distance,192,15,@easeout)
				15.times do
					@sprites["Ach"].opacity-=3.7
					@sprites["Dex"].opacity+=5
					@sprites["Map"].opacity-=3.3
					@sprites["Mn"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Dex"].opacity=255
				@sprites["Mn"].opacity=200
				@sprites["Ach"].opacity=200
				@sprites["Map"].opacity=150
			end
			
			if Input.trigger?(Input::LEFT) && @index==0
				pbSEPlay("BW2MenuChoose",70)
				@index-=1
				@sprites["Dex"].z-=1
				@sprites["Ach"].z+=1
				@sprites["Map"].z+=1
				@sprites["Mn"].z-=1
				@sprites["Dex"].zoom(0.5,0.5,15,@easein)
				@sprites["Dex"].move(256+@distance,192,15,@easeout)
				@sprites["Mn"].zoom(0.3,0.3,15,@easein)
				@sprites["Mn"].move(256,192,15,@easeout)
				@sprites["Ach"].zoom(1,1,15,@easeout)
				@sprites["Ach"].move(256,192,15,@easein)
				@sprites["Map"].zoom(0.5,0.5,15,@easein)
				@sprites["Map"].move(256-@distance,192,15,@easeout)
				15.times do
					@sprites["Dex"].opacity-=3.7
					@sprites["Ach"].opacity+=5
					@sprites["Mn"].opacity-=3.3
					@sprites["Map"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Ach"].opacity=255
				@sprites["Dex"].opacity=200
				@sprites["Map"].opacity=200
				@sprites["Mn"].opacity=150
			elsif Input.trigger?(Input::LEFT) && @index==1
				pbSEPlay("BW2MenuChoose",70)
				@index-=1
				@sprites["Dex"].z+=1
				@sprites["Ach"].z+=1
				@sprites["Map"].z-=1
				@sprites["Mn"].z-=1
				@sprites["Mn"].zoom(0.5,0.5,15,@easein)
				@sprites["Mn"].move(256+@distance,192,15,@easeout)
				@sprites["Map"].zoom(0.3,0.3,15,@easeout)
				@sprites["Map"].move(256,192,15,@easein)
				@sprites["Dex"].zoom(1,1,15,@easeout)
				@sprites["Dex"].move(256,192,15,@easein)
				@sprites["Ach"].zoom(0.5,0.5,15,@easein)
				@sprites["Ach"].move(256-@distance,192,15,@easeout)
				15.times do
					@sprites["Map"].opacity-=3.7
					@sprites["Dex"].opacity+=5
					@sprites["Mn"].opacity-=3.3
					@sprites["Ach"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Dex"].opacity=255
				@sprites["Ach"].opacity=200
				@sprites["Mn"].opacity=200
				@sprites["Map"].opacity=150
			elsif Input.trigger?(Input::LEFT) && @index==2
				pbSEPlay("BW2MenuChoose",70)
				@index-=1
				@sprites["Dex"].z+=1
				@sprites["Ach"].z-=1
				@sprites["Map"].z-=1
				@sprites["Mn"].z+=1
				@sprites["Map"].zoom(0.5,0.5,15,@easein)
				@sprites["Map"].move(256+@distance,192,15,@easeout)
				@sprites["Ach"].zoom(0.3,0.3,15,@easeout)
				@sprites["Ach"].move(256,192,15,@easein)
				@sprites["Mn"].zoom(1,1,15,@easeout)
				@sprites["Mn"].move(256,192,15,@easein)
				@sprites["Dex"].zoom(0.5,0.5,15,@easein)
				@sprites["Dex"].move(256-@distance,192,15,@easeout)
				15.times do
					@sprites["Ach"].opacity-=3.7
					@sprites["Mn"].opacity+=5
					@sprites["Map"].opacity-=3.3
					@sprites["Dex"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Mn"].opacity=255
				@sprites["Dex"].opacity=200
				@sprites["Map"].opacity=200
				@sprites["Ach"].opacity=150
			elsif Input.trigger?(Input::LEFT) && @index==3
				pbSEPlay("BW2MenuChoose",70)
				@index-=1
				@sprites["Dex"].z-=1
				@sprites["Ach"].z-=1
				@sprites["Map"].z+=1
				@sprites["Mn"].z+=1
				@sprites["Ach"].zoom(0.5,0.5,15,@easein)
				@sprites["Ach"].move(256+@distance,192,15,@easeout)
				@sprites["Dex"].zoom(0.3,0.3,15,@easeout)
				@sprites["Dex"].move(256,192,15,@easein)
				@sprites["Map"].zoom(1,1,15,@easeout)
				@sprites["Map"].move(256,192,15,@easein)
				@sprites["Mn"].zoom(0.5,0.5,15,@easein)
				@sprites["Mn"].move(256-@distance,192,15,@easeout)
				15.times do
					@sprites["Dex"].opacity-=3.7
					@sprites["Map"].opacity+=5
					@sprites["Ach"].opacity-=3.3
					@sprites["Mn"].opacity+=3.3
					@sprites["Dex"].update()
					@sprites["Mn"].update()
					@sprites["Ach"].update()
					@sprites["Map"].update()
					Graphics.update
					update
				end
				@sprites["Map"].opacity=255
				@sprites["Mn"].opacity=200
				@sprites["Ach"].opacity=200
				@sprites["Dex"].opacity=150
			end
			
			if Input.trigger?(Input::C) && @index==0
				pbPlayDecisionSE()
				pbFadeOutIn(99999) {
					screen = DexMain.new(0)
					screen.inputHandle
				}
				
			elsif Input.trigger?(Input::C) && @index==1
				pbPlayDecisionSE()
				MNScene.new(self)
			elsif Input.trigger?(Input::C) && @index==2
				pbPlayDecisionSE()
				pbFadeOutIn(99999) {
					pbShowMap(-1,false)
				}
			elsif Input.trigger?(Input::C) && @index==3
				pbPlayDecisionSE()
				pbFadeOutIn(99999) {
					AchievementsScreen.new
				}
			end
			
			if Input.trigger?(Input::B)
				break
			end
		end
		self.endscene if $fly!=1
	end
	
	def update
		@sprites["animbg"].oy+=1.5
		
		@sprites["megabg"].oy+=1.5

		if @index==0
			@sprites["overlay"].visible=true
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
		elsif @index==1
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=true
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
		elsif @index==2
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=true
			@sprites["overlay3"].visible=false
		elsif @index==3
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=true
		end
		
		if @index==4
			@index=0
		elsif @index==-1
			@index=3
		end
	end
	
	def mendscene
		@scene.close
		$fly=1
	end
	
	def fendscene
		#pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
	
	def endscene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
end
#===============================================================================
# MN Scene
# version 1.00
#
# by xZekro51
#===============================================================================
class MNScene
	
	include EAM_Sprite
	
	def initialize(scene=false,scenemap = nil)
		#Inizializzazione
		@scene=scene
		@scenemap = scenemap
		@sprites={}
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999
		@index=0
		@frames=0
		@zoom=true
		@y=284
		@basecolor=Color.new(255,255,255)
		@shadowcolor=Color.new(65,113,155)
		
		@gemnames=[_INTL("Kaiserium N"),_INTL("Ikarium N"),_INTL("Odysseum N"),_INTL("Heraclium N"),_INTL("Perseum N")]
		
		@kaiserium=["Un arbusto fastidioso ti","blocca il cammino? Fallo a","brandelli grazie al potere","dell'Holo-Schyter"," contenuto in questa gemma!"]
		@icarium=["Il potente Scaleon di","Oleandro, evocato dal","PokeWES,ti portera in volo","nei cieli di Eldiw,","permettendoti di ritornare","in citta gia visitate","precedentemente."]
		@odysseum=["Il potere dell'Odysseum N,","amplificato dal PokeWES,","richiama il Lapras soccorso","sull'Isola Voodoo. Salendo","sul suo dorso, potrai","navigare anche nelle","acque piu profonde."]
		@heraclium=["La forza sovrumana di","Holo-Hercurcules incanalata","nell'Heraclium N, permette","di spostare enormi macigni","che ti sbarrano la strada."]
		@perseum=["Un affamatissimo","Holo-Trapinch farà piazza","pulita di tutti i massi","che gli capitano a tiro,","sbloccando il passaggio a","zone ancora inesplorate."]
		
		kaiserium=_INTL("Un arbusto fastidioso ti blocca il cammino? Fallo a brandelli grazie al potere dell'Holo-Scyther contenuto in questa gemma!")
		icarium=_INTL("Il potente Scaleon di Oleandro, evocato dal PokéWES, ti porterà in volo nei cieli di Eldiw, permettendoti di ritornare in città già visitate precedentemente.")
		odysseum=_INTL("Il potere dell’Odysseum N, amplificato dal PokéWES, richiama il Lapras soccorso sull’Isola Buconero. Col suo aiuto, potrai navigare anche nelle acque più profonde.")
		heraclium=_INTL("La forza sovrumana di Holo-Hercurcules incanalata nell'Heraclium N, permette di spostare enormi macigni che ti sbarrano la strada.")
		perseum=_INTL("Un affamatissimo Holo-Trapinch farà piazza pulita di tutti i massi che gli capitano a tiro, sbloccando il passaggio a zone ancora inesplorate.")
		
		#Switch gemme: 186-190
		
		#Creazione immagini
		@sprites["bg"]=BSprite.new(@viewport,"Graphics/Pictures/MN/bg")
		@sprites["animbg"]=AnimatedPlane.new(@viewport)
		@sprites["animbg"].bitmap=pbBitmap("Graphics/Pictures/Dex/animbg")
		@sprites["interface"]=BSprite.new(@viewport,"Graphics/Pictures/MN/interface")
		@sprites["interface"].bitmap.font.name="Barlow Condensed"
		@sprites["interface"].bitmap.font.size = $MKXP ? 22 : 24
		@sprites["interface"].bitmap.font.bold = true
		pbDrawTextPositions(@sprites["interface"].bitmap,[[_INTL("Chiudi"),474,346,1,Color.new(248,248,248)],
																											[_INTL("PokéWES - Funzione MN "),12,346,0,Color.new(248,248,248)]])
		
		@sprites["schyter"]=BitmapWrapperSprite.new(@viewport)
		@sprites["schyter"].setBitmap("Graphics/Pictures/MN/Scyther")
		@sprites["schyter"].play
		@sprites["schyter"].x=60
		@sprites["schyter"].y=50
		@sprites["schyter"].visible=false
		
		@sprites["scaleon"]=BitmapWrapperSprite.new(@viewport)
		@sprites["scaleon"].setBitmap("Graphics/Battlers/Front/1081_holo")
		@sprites["scaleon"].play
		@sprites["scaleon"].x=60
		@sprites["scaleon"].y=-10
		@sprites["scaleon"].visible=false
		#@sprites["scaleon"].setSpeed(10)
		
		@sprites["lapras"]=BitmapWrapperSprite.new(@viewport)
		@sprites["lapras"].setBitmap("Graphics/Battlers/Front/131")
		@sprites["lapras"].play
		@sprites["lapras"].x=60
		@sprites["lapras"].y=40
		@sprites["lapras"].visible=false
		
		@sprites["hariyama"]=BitmapWrapperSprite.new(@viewport)
		@sprites["hariyama"].setBitmap("Graphics/Battlers/Front/1046_holo")
		@sprites["hariyama"].play
		@sprites["hariyama"].x=20
		@sprites["hariyama"].y=-60
		@sprites["hariyama"].visible=false
		
		@sprites["trapinch"]=BitmapWrapperSprite.new(@viewport)
		@sprites["trapinch"].setBitmap("Graphics/Pictures/MN/trapinch")
		@sprites["trapinch"].play
		@sprites["trapinch"].x=60
		@sprites["trapinch"].y=78
		@sprites["trapinch"].visible=false
		
		if $game_switches[186]==true
			@sprites["taglio"]=BSprite.new(@viewport,"Graphics/Pictures/MN/taglio")
		else
			@sprites["taglio"]=BSprite.new(@viewport,"Graphics/Pictures/MN/taglioU")
		end
		if $game_switches[187]==true
			@sprites["volo"]=BSprite.new(@viewport,"Graphics/Pictures/MN/volo")
		else
			@sprites["volo"]=BSprite.new(@viewport,"Graphics/Pictures/MN/voloU")
		end
		if $game_switches[188]==true
			@sprites["surf"]=BSprite.new(@viewport,"Graphics/Pictures/MN/surf")
		else
			@sprites["surf"]=BSprite.new(@viewport,"Graphics/Pictures/MN/surfU")
		end
		if $game_switches[189]==true
			@sprites["forza"]=BSprite.new(@viewport,"Graphics/Pictures/MN/forza")
		else
			@sprites["forza"]=BSprite.new(@viewport,"Graphics/Pictures/MN/forzaU")
		end
		if $game_switches[190]==true
			@sprites["spacca"]=BSprite.new(@viewport,"Graphics/Pictures/MN/spac")
		else
			@sprites["spacca"]=BSprite.new(@viewport,"Graphics/Pictures/MN/spacU")
		end
		
		@sprites["taglio"].oy=@sprites["taglio"].bitmap.height/2
		@sprites["volo"].oy=@sprites["volo"].bitmap.height/2
		@sprites["surf"].oy=@sprites["surf"].bitmap.height/2
		@sprites["forza"].oy=@sprites["forza"].bitmap.height/2
		@sprites["spacca"].oy=@sprites["spacca"].bitmap.height/2
		
		@sprites["taglio"].ox=@sprites["taglio"].bitmap.width/2
		@sprites["volo"].ox=@sprites["volo"].bitmap.width/2
		@sprites["surf"].ox=@sprites["surf"].bitmap.width/2
		@sprites["forza"].ox=@sprites["forza"].bitmap.width/2
		@sprites["spacca"].ox=@sprites["spacca"].bitmap.width/2
		
		@sprites["taglio"].y=@y
		@sprites["volo"].y=@y
		@sprites["surf"].y=@y
		@sprites["forza"].y=@y
		@sprites["spacca"].y=@y
		
		@sprites["taglio"].x=83
		@sprites["volo"].x=83+87
		@sprites["surf"].x=83+87*2
		@sprites["forza"].x=83+87*3
		@sprites["spacca"].x=83+87*4
		
		#######
		#TESTI#
		#######
		
		@sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay"].z=20
		@overlay=@sprites["overlay"].bitmap
		@overlay.clear
		@sprites["overlay1"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay1"].z=20
		@overlay1=@sprites["overlay1"].bitmap
		@overlay1.clear
		@sprites["overlay2"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay2"].z=20
		@overlay2=@sprites["overlay2"].bitmap
		@overlay2.clear
		@sprites["overlay3"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay3"].z=20
		@overlay3=@sprites["overlay3"].bitmap
		@overlay3.clear
		@sprites["overlay4"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["overlay4"].z=20
		@overlay4=@sprites["overlay4"].bitmap
		@overlay4.clear
		pbSetFont(@overlay,"Barlow Condensed",21)
		pbSetFont(@overlay1,"Barlow Condensed",21)
		pbSetFont(@overlay2,"Barlow Condensed",21)
		pbSetFont(@overlay3,"Barlow Condensed",21)
		pbSetFont(@overlay4,"Barlow Condensed",21)
		
		@name=[[_INTL(@gemnames[0]),348,31,2,@basecolor,nil]]
		@name1=[[_INTL(@gemnames[1]),348,31,2,@basecolor,nil]]
		@name2=[[_INTL(@gemnames[2]),348,31,2,@basecolor,nil]]
		@name3=[[_INTL(@gemnames[3]),348,31,2,@basecolor,nil]]
		@name4=[[_INTL(@gemnames[4]),348,31,2,@basecolor,nil]]
		
		
=begin
		@text=[[_INTL(@kaiserium[0]),480,174-20*4,1,@basecolor,@shadowcolor],
			[_INTL(@kaiserium[1]),480,174-20*3,1,@basecolor,@shadowcolor],
			[_INTL(@kaiserium[2]),480,174-20*2,1,@basecolor,@shadowcolor],
			[_INTL(@kaiserium[3]),480,174-20,1,@basecolor,@shadowcolor],
			[_INTL(@kaiserium[4]),480,174,1,@basecolor,@shadowcolor],]
		
		@text1=[[_INTL(@icarium[0]),480,174-20*6,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[1]),480,174-20*5,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[2]),480,174-20*4,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[3]),480,174-20*3,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[4]),480,174-20*2,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[5]),480,174-20,1,@basecolor,@shadowcolor],
			[_INTL(@icarium[6]),480,174,1,@basecolor,@shadowcolor],]
		
		@text2=[[_INTL(@odysseum[0]),480,174-20*6,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[1]),480,174-20*5,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[2]),480,174-20*4,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[3]),480,174-20*3,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[4]),480,174-20*2,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[5]),480,174-20,1,@basecolor,@shadowcolor],
			[_INTL(@odysseum[6]),480,174,1,@basecolor,@shadowcolor],]
		
		@text3=[[_INTL(@heraclium[0]),480,174-20*4,1,@basecolor,@shadowcolor],
			[_INTL(@heraclium[1]),480,174-20*3,1,@basecolor,@shadowcolor],
			[_INTL(@heraclium[2]),480,174-20*2,1,@basecolor,@shadowcolor],
			[_INTL(@heraclium[3]),480,174-20,1,@basecolor,@shadowcolor],
			[_INTL(@heraclium[4]),480,174,1,@basecolor,@shadowcolor],]
		
		@text4=[[_INTL(@perseum[0]),480,174-20*5,1,@basecolor,@shadowcolor],
			[_INTL(@perseum[1]),480,174-20*4,1,@basecolor,@shadowcolor],
			[_INTL(@perseum[2]),480,174-20*3,1,@basecolor,@shadowcolor],
			[_INTL(@perseum[3]),480,174-20*2,1,@basecolor,@shadowcolor],
			[_INTL(@perseum[4]),480,174-20,1,@basecolor,@shadowcolor],
			[_INTL(@perseum[5]),480,174,1,@basecolor,@shadowcolor],]
=end
		#########
		#Cursore#
		#########
		@sprites["cursor"]=BSprite.new(@viewport,"Graphics/Pictures/MN/cursor")
		@sprites["cursor"].x=83
		@sprites["cursor"].y=285
		@sprites["cursor"].ox=@sprites["cursor"].bitmap.width/2
		@sprites["cursor"].oy=@sprites["cursor"].bitmap.height/2
		@sprites["cursor"].zoom_x=1
		@sprites["cursor"].zoom_y=1
		
		drawTextExH(@overlay,268,65,218,6,kaiserium,Color.new(24,24,24),Color.new(0,0,0,0),19)
		drawTextExH(@overlay1,268,65,218,6,icarium,Color.new(24,24,24),Color.new(0,0,0,0),19)
		drawTextExH(@overlay2,268,65,218,6,odysseum,Color.new(24,24,24),Color.new(0,0,0,0),19)
		drawTextExH(@overlay3,268,65,218,6,heraclium,Color.new(24,24,24),Color.new(0,0,0,0),19)
		drawTextExH(@overlay4,268,65,218,6,perseum,Color.new(24,24,24),Color.new(0,0,0,0),19)
		#pbDrawTextPositions(@overlay,@text)
		#pbDrawTextPositions(@overlay1,@text1)
		#pbDrawTextPositions(@overlay2,@text2)
		#pbDrawTextPositions(@overlay3,@text3)
		#pbDrawTextPositions(@overlay4,@text4)
		
		pbSetFont(@overlay,$MKXP ? "Kimberley" : "Kimberley Bl",25)
		pbSetFont(@overlay1,$MKXP ? "Kimberley" : "Kimberley Bl",25)
		pbSetFont(@overlay2,$MKXP ? "Kimberley" : "Kimberley Bl",25)
		pbSetFont(@overlay3,$MKXP ? "Kimberley" : "Kimberley Bl",25)
		pbSetFont(@overlay4,$MKXP ? "Kimberley" : "Kimberley Bl",25)
		
		pbDrawTextPositions(@overlay,@name)
		pbDrawTextPositions(@overlay1,@name1)
		pbDrawTextPositions(@overlay2,@name2)
		pbDrawTextPositions(@overlay3,@name3)
		pbDrawTextPositions(@overlay4,@name4)
		
		##########
		#Visibles#
		##########
		@sprites["overlay"].visible=false
		@sprites["overlay1"].visible=false
		@sprites["overlay2"].visible=false
		@sprites["overlay3"].visible=false
		@sprites["overlay4"].visible=false
		pbFadeInAndShow(@sprites)
		#Inizializzazione comandi    
		self.comandi
	end
	
	def comandi
		val=pbGetMetadata($game_map.map_id,MetadataOutdoor)
		loop do
			if $fly==1
				break
			end
			Graphics.update
			Input.update
			update

			#CHECK FOR MAP OUTDOOR			
			if Input.trigger?(Input::RIGHT) && @index<4
				pbPlayDecisionSE()
				@index+=1
				@sprites["cursor"].x+=87
			elsif Input.trigger?(Input::RIGHT) && @index==4
				pbPlayDecisionSE()
				@index=0
				@sprites["cursor"].x=83
			end
			if Input.trigger?(Input::LEFT) && @index>0
				pbPlayDecisionSE()
				@index-=1
				@sprites["cursor"].x-=87
			elsif Input.trigger?(Input::LEFT) && @index==0
				pbPlayDecisionSE()
				@index=4
				@sprites["cursor"].x=431
			end
			if Input.trigger?(Input::C)				
				regi = false
				if @index==0
					if $game_switches[186]==true
						#func cut
						pbPlayDecisionSE()
						movefinder=PokeBattle_Pokemon.new(123,5)
						if !Kernel.pbCanUseHiddenMove?(movefinder,:CUT)
						else
							if @scene						
								regi = handleRegi(REGIELEKI_SWITCH){	
									r = 0
									26.times do
										r += 255/25
										Graphics.update
										@viewport.color = Color.new(0,0,0,r)
									end									
									Kernel.pbUseHiddenMove(movefinder,:CUT)
								}
								fendscene
							else
								r = 0
								26.times do
									r += 255/25
									Graphics.update
									@viewport.color = Color.new(0,0,0,r)
								end
								regi = handleRegi(REGIELEKI_SWITCH){										
									Kernel.pbUseHiddenMove(movefinder,:CUT)
								}
							end
							Kernel.pbUseHiddenMove(movefinder,:CUT) if !regi
							break if !@scene
						end
					else
						pbSEPlay("buzzer",80)
					end
				elsif @index==1
					if $game_switches[187]==true
						movefinder=PokeBattle_Pokemon.new(PBSpecies::SCALEON,5)
						if Kernel.pbCanUseHiddenMove?(movefinder,:FLY)
							if defined?($regiSpecial) && $regiSpecial
								pbPlayDecisionSE()
								movefinder=PokeBattle_Pokemon.new(2005,5)
								if @scene
									regi = handleRegi(REGIDRAGO_SWITCH){	
										r = 0
										26.times do
											r += 255/25
											Graphics.update
											@viewport.color = Color.new(0,0,0,r)
										end									
										pbHiddenMoveAnimation(movefinder)
									}
									fendscene
								else
									r = 0
									26.times do
										r += 255/25
										Graphics.update
										@viewport.color = Color.new(0,0,0,r)
									end
									regi = handleRegi(REGIDRAGO_SWITCH){										
										pbHiddenMoveAnimation(movefinder)
									}
								end								
								break if !@scene
							elsif !([335,564,565,566,614,615,616,617,618].include?($game_map.map_id)) && $game_switches[990]==false
								if !val
									Kernel.pbMessage(_INTL("Non puoi usare volo in ambienti chiusi!"))
								else
									#func fly
									pbPlayDecisionSE()
									movefinder=PokeBattle_Pokemon.new(2005,5)
									if @scene
										fendscene
									else
										r = 0
										25.times do
											r += 255/25
											Graphics.update
											@viewport.color = Color.new(0,0,0,r)
										end
									end
									scene=PokemonRegionMapScene.new(-1,false)
									screen=PokemonRegionMap.new(scene)
									ret=screen.pbStartFlyScreen
									if ret
										$PokemonTemp.flydata=ret
										Kernel.pbUseHiddenMove(movefinder,:FLY)
										break
									else
										if @viewport!=nil && !@scene
											r=255
											25.times do
												r -= 255/25
												Graphics.update
												@viewport.color = Color.new(0,0,0,r)
											end
										end
									end
								end
							end
						else
							Kernel.pbMessage(_INTL("Non puoi usare volo qui."))
						end
					else
						pbSEPlay("buzzer",80)
					end
				elsif @index==2
					if $game_switches[188]==true
						#func surf
						pbPlayDecisionSE()
						movefinder=PokeBattle_Pokemon.new(PBSpecies::LAPRAS,5)
						if Kernel.pbCanUseHiddenMove?(movefinder,:SURF)
							if @scene
								regi = handleRegi(REGICE_SWITCH){	
									r = 0
									26.times do
										r += 255/25
										Graphics.update
										@viewport.color = Color.new(0,0,0,r)
									end											
									pbHiddenMoveAnimation(movefinder)
								}
								fendscene
							else
								r = 0
								26.times do
									r += 255/25
									Graphics.update
									@viewport.color = Color.new(0,0,0,r)
								end							
								regi = handleRegi(REGICE_SWITCH){									
									pbHiddenMoveAnimation(movefinder)
								}
							end
							#echoln Kernel.pbCanUseHiddenMove?(movefinder,:SURF)
							#Fix for surf from shortcut
							if !regi
								@scenemap.surfProc = Proc.new { Kernel.pbUseHiddenMove(movefinder,:SURF) if Kernel.pbCanUseHiddenMove?(movefinder,:SURF)} if @scenemap
							end							
							break if !@scene
						end
					else
						pbSEPlay("buzzer",80)
					end
				elsif @index==3
					if $game_switches[189]==true
						#func strength
						pbPlayDecisionSE()
						movefinder=PokeBattle_Pokemon.new(297,5)
						if !Kernel.pbCanUseHiddenMove?(movefinder,:STRENGTH)
						else
							if @scene
								regi = handleRegi(REGISTEEL_SWITCH){
									r = 0
									26.times do
										r += 255/25
										Graphics.update
										@viewport.color = Color.new(0,0,0,r)
									end									
									Kernel.pbUseHiddenMove(movefinder,:STRENGTH)
								}
								fendscene
							else
								r = 0
								26.times do
									r += 255/25
									Graphics.update
									@viewport.color = Color.new(0,0,0,r)
								end
								regi = handleRegi(REGISTEEL_SWITCH){									
									Kernel.pbUseHiddenMove(movefinder,:STRENGTH)
								}

							end
							Kernel.pbUseHiddenMove(movefinder,:STRENGTH) if !regi
							break if !@scene
						end
					else
						pbSEPlay("buzzer",80)
					end
				elsif @index==4
					if $game_switches[190]==true
						#func rock smash
						pbPlayDecisionSE()
						movefinder=PokeBattle_Pokemon.new(328,5)
						if !Kernel.pbCanUseHiddenMove?(movefinder,:ROCKSMASH)
						else
							if @scene
								regi = handleRegi(REGIROCK_SWITCH){
									r = 0
									26.times do
										r += 255/25
										Graphics.update
										@viewport.color = Color.new(0,0,0,r)
									end					
									Kernel.pbUseHiddenMove(movefinder,:ROCKSMASH)
								}
								fendscene
							else
								r = 0
								26.times do
									r += 255/25
									Graphics.update
									@viewport.color = Color.new(0,0,0,r)
								end
								regi = handleRegi(REGIROCK_SWITCH){									
									Kernel.pbUseHiddenMove(movefinder,:ROCKSMASH)
								}
							end
							Kernel.pbUseHiddenMove(movefinder,:ROCKSMASH) if !regi
							
							break if !@scene
						end
					else
						pbSEPlay("buzzer",80)
					end
				end
			end
			
			if Input.trigger?(Input::B)
				break      
			end
		end
		self.endscene
	end
	
	def handleRegi(var)
		if defined?($regiSpecial) && $regiSpecial
			yield
			pbSEPlay("Explosion1")
			Kernel.pbMessage(_INTL("You can hear a crumbling sound."))
			$game_switches[var] = true
			$game_map.refresh
			$regiSpecial=false
			return true
		end
		return false
	end

	def update
		@frames+=1
		@sprites["scaleon"].update
		@sprites["schyter"].update
		@sprites["lapras"].update
		@sprites["hariyama"].update
		@sprites["trapinch"].update
		@sprites["animbg"].oy+=1.5
		if @sprites["cursor"].zoom_x==1 || @sprites["cursor"].zoom_x<1
			@zoom=true
		elsif @sprites["cursor"].zoom_x==1.2 || @sprites["cursor"].zoom_x>1.2
			@zoom=false
		end
		if @sprites["cursor"].zoom_x<1 && @zoom==true || @sprites["cursor"].zoom_x>1 && @zoom==true || @sprites["cursor"].zoom_x==1 && @zoom==true
			@sprites["cursor"].zoom_x+=0.025
			@sprites["cursor"].zoom_y+=0.025
			#wait(1)
		elsif @sprites["cursor"].zoom_x<1.2 && @zoom==false || @sprites["cursor"].zoom_x>1.2 && @zoom==false || @sprites["cursor"].zoom_x==1.2 && @zoom==false
			@sprites["cursor"].zoom_x-=0.025
			@sprites["cursor"].zoom_y-=0.025
			#wait(1)
		end
		
		if @index==0 && $game_switches[186]==true
			@sprites["overlay"].visible=true
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
			@sprites["overlay4"].visible=false
			@sprites["scaleon"].visible=false
			@sprites["schyter"].visible=true
			@sprites["lapras"].visible=false
			@sprites["hariyama"].visible=false
			@sprites["trapinch"].visible=false
		elsif @index==1 && $game_switches[187]==true
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=true
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
			@sprites["overlay4"].visible=false
			@sprites["scaleon"].visible=true
			@sprites["schyter"].visible=false
			@sprites["lapras"].visible=false
			@sprites["hariyama"].visible=false
			@sprites["trapinch"].visible=false
		elsif @index==2 && $game_switches[188]==true
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=true
			@sprites["overlay3"].visible=false
			@sprites["overlay4"].visible=false
			@sprites["scaleon"].visible=false
			@sprites["schyter"].visible=false
			@sprites["lapras"].visible=true
			@sprites["hariyama"].visible=false
			@sprites["trapinch"].visible=false
		elsif @index==3 && $game_switches[189]==true
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=true
			@sprites["overlay4"].visible=false
			@sprites["scaleon"].visible=false
			@sprites["schyter"].visible=false
			@sprites["lapras"].visible=false
			@sprites["hariyama"].visible=true
			@sprites["trapinch"].visible=false
		elsif @index==4 && $game_switches[190]==true
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
			@sprites["overlay4"].visible=true
			@sprites["scaleon"].visible=false
			@sprites["schyter"].visible=false
			@sprites["lapras"].visible=false
			@sprites["hariyama"].visible=false
			@sprites["trapinch"].visible=true
		else
			@sprites["overlay"].visible=false
			@sprites["overlay1"].visible=false
			@sprites["overlay2"].visible=false
			@sprites["overlay3"].visible=false
			@sprites["overlay4"].visible=false
			@sprites["scaleon"].visible=false
			@sprites["schyter"].visible=false
			@sprites["lapras"].visible=false
			@sprites["hariyama"].visible=false
			@sprites["trapinch"].visible=false
		end
	end
	
	def wait(frames,advance=true)
		frames.times do
			Graphics.update
			Input.update
		end
		return true
	end
	
	def fendscene
		if @scene
			@scene.fendscene 
			@scene.mendscene
		end
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
	
	def endscene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
end


#===============================================================================
# xZekro51's utilities
#===============================================================================
class BSprite < Sprite
	
	include EAM_Sprite
	
	def initialize(viewport,bitmap)
		super(viewport)
		self.bitmap=pbBitmap(bitmap)
	end
end

class PartyPanel < Sprite
	
	include EAM_Sprite
	
	def initialize(bitmap,viewport=nil)
		super(viewport)
		self.bitmap=pbBitmap(bitmap)
	end
	
	def width
		return self.bitmap.width
	end
	
	def height
		return self.bitmap.height
	end
	
end

def pbSetFont(bitmap,fontname,size)
	bitmap.font.name=[fontname, "Verdana"]
	bitmap.font.size=size
end

class CardSprite < Sprite
	
	include EAM_Sprite
	
	def initialize(viewport,bitmap,x,y,ox)
		super(viewport)
		self.bitmap=pbBitmap(bitmap)
		self.x=x
		self.y=y
		self.ox=ox
	end
end


class TrainerCardSelector < Sprite
	
	include EAM_Sprite
	
	def initialize(viewport,x,y)
		super(viewport)
		self.bitmap=pbBitmap("Graphics/Pictures/Card/selector")
		self.x=x
		self.y=y
	end
end

def pbPokemonCount(party)
	count=0
	for i in party
		next if !i
		count+=1 if i.hp>0 && !i.isEgg?
	end
	return count
end
#===============================================================================
# MN methods
#===============================================================================
def pbKaiseriumN
	if $game_switches[186]==true
		movefinder=PokeBattle_Pokemon.new(123,5)
		Kernel.pbMessage(_INTL("Questo albero sembra abbattibile."))
		if Kernel.pbConfirmMessage(_INTL("Vuoi che Holo-Scyther tagli l'albero?"))
			speciesname=!movefinder ? $Trainer.name : movefinder.name
			Kernel.pbMessage(_INTL("Holo-Scyther usa Taglio!",speciesname))
			pbHiddenMoveHoloAnimation("Graphics/Battlers/Front/123",movefinder)
			return true
		end
	else
		Kernel.pbMessage(_INTL("Questo albero blocca la strada."))
	end
end

def pbOdysseumN
	if $game_switches[188]==true
		if $game_player.pbHasDependentEvents? && !$PokemonTemp.dependentEvents.getEventByName("Dependent")
			return false
		end
		if $DEBUG ||
			(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
			movefinder=PokeBattle_Pokemon.new(131,5)
			if $DEBUG || movefinder
				if Kernel.pbConfirmMessage(_INTL("L'acqua è di un blu intenso...\nVuoi chiamare Lapras per usare Surf?"))
					speciesname=!movefinder ? $Trainer.name : movefinder.name
					Kernel.pbMessage(_INTL("Lapras usa Surf!",speciesname))
					pbHiddenMoveAnimation(movefinder)
					surfbgm=pbGetMetadata(0,MetadataSurfBGM)
					if surfbgm
						pbCueBGM(surfbgm,0.5)
					end
					$PokemonGlobal.surfing=true
					pbStartSurfing()
					return true
				end
			end
		end
		return false
	end
end

def pbHeracliumN
	if $game_switches[189]==true
		if $PokemonMap.strengthUsed
			Kernel.pbMessage(_INTL("Forza ha reso possibile lo spostamento dei massi."))
		elsif !$PokemonMap.strengthUsed
			movefinder=PokeBattle_Pokemon.new(1046,5)
			if $DEBUG || movefinder
				Kernel.pbMessage(_INTL("E' un gran masso, ma un Pokémon dovrebbe poterlo spostare."))
				if Kernel.pbConfirmMessage(_INTL("Vuoi usare Forza?"))
					speciesname=!movefinder ? $Trainer.name : movefinder.name
					Kernel.pbMessage(_INTL("Holo-Hercurcules usa Forza!\1",speciesname))
					pbHiddenMoveHoloAnimation("Graphics/Battlers/Front/1046",movefinder)
					Kernel.pbMessage(_INTL("La forza di Holo-Hercurcules ti permette di spostare i massi!",speciesname))
					$PokemonMap.strengthUsed=true
					return true
				end
			else
				Kernel.pbMessage(_INTL("E' un gran masso, ma un Pokémon dovrebbe poterlo spostare."))
			end
		else
			Kernel.pbMessage(_INTL("E' un gran masso, ma un Pokémon dovrebbe poterlo spostare."))
		end
		return false
	end
end

def pbPerseumN
	if $game_map.id == 680 && $game_player.x == 20 && $game_player.y == 21
		Kernel.pbMessage(_INTL("Senti un rumore da qualche parte.[dispose]"))
		$game_switches[1419] = true
		return false
	end
	if $DEBUG || $game_switches[190]==true
		movefinder=PokeBattle_Pokemon.new(328,5)
		if $DEBUG || movefinder
			if Kernel.pbConfirmMessage(_INTL("Questa roccia si può rompere.  Vuoi usare Spaccaroccia?"))
				speciesname=!movefinder ? $Trainer.name : movefinder.name
				Kernel.pbMessage(_INTL("Holo-Trapinch usa Spaccaroccia!",speciesname))
				pbHiddenMoveHoloAnimation("Graphics/Battlers/Front/328",movefinder)
				return true
			end
		else
			Kernel.pbMessage(_INTL("E' una roccia crepata, un Pokémon dovrebbe essere in grado di romperla.[dispose]"))
		end
	else
		Kernel.pbMessage(_INTL("E' una roccia crepata, un Pokémon dovrebbe essere in grado di romperla.[dispose]"))
	end
	return false
end

#===============================================================================
# Script: PokéWES Script plug-and-play implementations
# Game: Pokémon Xenoverse
# Date: 23/05/2017
# Scripter: Fuji97
#===============================================================================
class PokeBattle_Trainer
	attr_accessor	:pokewes
	
	alias :initialize_wes :initialize
	def initialize(name,trainertype)
		initialize_wes(name,trainertype)	# Chiamo l'initialize originale
		@pokedex = true										# Forzo il Dex fin da subito
		@pokewes = false									# Inizializzo il PokeWES a falso
	end
end