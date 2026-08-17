#======================================================================================
# * Pokemon Essentials Starter Selection
#
# * This Script will create a nice cutscene, where the player can choose his 
# * Pokemon. The Game Variable 7 will be 1,2, or 3, depends on the Pokémon you
# * choose. If you encounter any bugs, please let me know.
# *    Contact: Skype:imatrix.wt ; Deviantart: shiney570
#
# * To get this Script work put the Code above Main, and be sure to copy the 
# * Graphics for this scene into: Graphics\Pictures\StarterSelection
# 
# * - Script by shiney570 (Luka S.J helped me alot with it)
# * - Graphics by babydialga
#
# * To Call this Script use: 
#  PokemonStarterSelection.new(
#  1,4,7)
# 
# * You can change the Pokémon, if you edit the value in the clips.
# 
# * Please give credit if used.
#======================================================================================
class PokemonStarterSelection
  
  
  STARTERLEVEL = 5 # Feel free to change the value for the Level of your Starters.
  
  
  def initialize(pkmn1,pkmn2,pkmn3)
    
    @pkmn1=pkmn1; @pkmn2=pkmn2; @pkmn3=pkmn3
    
    @select=1
  
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    
    @sprites["black"]=IconSprite.new(0,0,@viewport)    
    @sprites["black"].setBitmap("Graphics/Pictures/StarterSelection/black")
    @sprites["black"].opacity=0
    
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/SceltaStarter/bg")
    @sprites["bg"].opacity = 0
    
    @sprites["ball_1"]=IconSprite.new(0,0,@viewport)
    @sprites["ball_1"].setBitmap("Graphics/Pictures/StarterSelection/ball1")
    @sprites["ball_1"].x=90
    @sprites["ball_1"].y=145
    @sprites["ball_1"].opacity=0
    
    @sprites["ball_2"]=IconSprite.new(0,0,@viewport)
    @sprites["ball_2"].setBitmap("Graphics/Pictures/StarterSelection/ball2")
    @sprites["ball_2"].x=206
    @sprites["ball_2"].y=145
    @sprites["ball_2"].opacity=0
        
    @sprites["ball_3"]=IconSprite.new(0,0,@viewport)
    @sprites["ball_3"].setBitmap("Graphics/Pictures/StarterSelection/ball3")
    @sprites["ball_3"].x=330
    @sprites["ball_3"].y=145
    @sprites["ball_3"].opacity=0
    
    @sprites["select"]=IconSprite.new(0,0,@viewport)
    @sprites["select"].setBitmap("Graphics/Pictures/StarterSelection/select")
    @sprites["select"].opacity=0
    @sprites["select"].x=5000
    
    @sprites["pkmn_1"]=IconSprite.new(0,0,@viewport)
    @sprites["pkmn_1"].bitmap=AnimatedBitmapWrapper.new(sprintf("Graphics/Battlers/%03d",@pkmn1)).bitmap
    @sprites["pkmn_1"].x=240
    @sprites["pkmn_1"].y=10
    @sprites["pkmn_1"].opacity=0
    @sprites["pkmn_1"].ox = 104/2
    @sprites["pkmn_1"].oy =  96/2
    @sprites["pkmn_1"].zoom_x=1.5
    @sprites["pkmn_1"].zoom_y=1.5

    @sprites["pkmn_2"]=IconSprite.new(0,0,@viewport)
    @sprites["pkmn_2"].bitmap=AnimatedBitmapWrapper.new(sprintf("Graphics/Battlers/%03d",@pkmn2)).bitmap
    @sprites["pkmn_2"].x=310
    @sprites["pkmn_2"].y=10
    @sprites["pkmn_2"].opacity=0
    @sprites["pkmn_2"].ox = 108/2
    @sprites["pkmn_2"].oy = 100/2
    @sprites["pkmn_2"].zoom_x=1.5
    @sprites["pkmn_2"].zoom_y=1.5
    
    @sprites["pkmn_3"]=IconSprite.new(0,0,@viewport)
    @sprites["pkmn_3"].bitmap=AnimatedBitmapWrapper.new(sprintf("Graphics/Battlers/%03d",@pkmn3)).bitmap
    @sprites["pkmn_3"].x=70
    @sprites["pkmn_3"].y=10
    @sprites["pkmn_3"].opacity=0
    @sprites["pkmn_3"].ox = 105/2
    @sprites["pkmn_3"].oy =  95/2
    @sprites["pkmn_3"].zoom_x=1.5
    @sprites["pkmn_3"].zoom_y=1.5
    
    @sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].opacity=0
    
    @data={}
    @data["pkmn_1"]=PokeBattle_Pokemon.new(@pkmn1,STARTERLEVEL)
    @data["pkmn_2"]=PokeBattle_Pokemon.new(@pkmn2,STARTERLEVEL)
    @data["pkmn_3"]=PokeBattle_Pokemon.new(@pkmn3,STARTERLEVEL)
    @pokemon=@data["pkmn_#{@select}"]    
    self.openscene
  end
  
  def openscene
    25.times do
      @sprites["black"].opacity+=10.2
      @sprites["bg"].opacity+=10.2
      @sprites["ball_1"].opacity+=10.2
      @sprites["ball_2"].opacity+=10.2
      @sprites["ball_3"].opacity+=10.2
      @sprites["select"].opacity+=10.2
      pbWait(1)
    end
    self.gettinginput
    self.input_action
  end
  
  def closescene
    25.times do
      @sprites["black"].opacity-=10.2
      @sprites["bg"].opacity-=10.2
      @sprites["ball_1"].opacity-=10.2
      @sprites["ball_2"].opacity-=10.2
      @sprites["ball_3"].opacity-=10.2
      @sprites["select"].opacity-=10.2
      @sprites["pkmn_1"].opacity-=10.2
      @sprites["pkmn_2"].opacity-=10.2
      @sprites["pkmn_3"].opacity-=10.2
      @sprite.opacity-=10.2
      @sprites["pkmn_#{@select}"].opacity-=10.2
      @sprites["overlay"].opacity-=10.2
      pbWait(1)
      end      
    end
  
  def gettinginput
    if Input.trigger?(Input::RIGHT)  && @select <3
      @select+=1
    end
    if Input.trigger?(Input::LEFT) && @select >1
      @select-=1
    end
    pokemon=[@pkmn1,@pkmn2,@pkmn3]
    if Input.trigger?(Input::C) 
      @sprites["select"].visible=false
      20.times do
        @sprites["pkmn_#{@select}"].opacity+=255/20
        @sprite.opacity+=255/20; @sprites["overlay"].opacity+=255/20
        @sprites["ball_#{@select}"].x-=4; @sprites["ball_#{@select}"].y-=4
        @sprites["ball_#{@select}"].zoom_x+=0.05; @sprites["ball_#{@select}"].zoom_y+=0.05
        for j in 1...4
          @sprites["ball_#{j}"].opacity-=10 if !(j==@select)
          if @select==2#
          @sprites["ball_1"].x-=1
          else#
          @sprites["ball_#{j}"].x-=2 if !(j==@select) && @select>1
        end#
      end      
      @sprites["bg"].opacity-=10
      pbWait(1)
      end
      @sprites["pkmn_#{@select}"].visible=true
      @sprite.visible=true
      pbSEPlay(sprintf("%03dCry",pokemon[@select-1]))
      pbWait(20)
      if Kernel.pbConfirmMessage("Do you want #{@pokemon.name}?")
        pbAddPokemon(pokemon[@select-1],STARTERLEVEL)
        $game_variables[7]=@select
        self.closescene
      else
        20.times do
          @sprites["pkmn_#{@select}"].opacity-=255/20
          @sprite.opacity-=255/20; @sprites["overlay"].opacity-=255/20
          @sprites["ball_#{@select}"].x+=4; @sprites["ball_#{@select}"].y+=4
          @sprites["ball_#{@select}"].zoom_x-=0.05; @sprites["ball_#{@select}"].zoom_y-=0.05
          for j in 1...4
            @sprites["ball_#{j}"].opacity+=10 if !(j==@select)
             if @select==2#
             @sprites["ball_1"].x+=1
             else#
             @sprites["ball_#{j}"].x+=2 if !(j==@select) && @select>1
           end#
          end   
          @sprites["bg"].opacity+=10
          pbWait(1)
        end
         @sprites["pkmn_#{@select}"].visible=false
         @sprite.visible=false
         @sprites["select"].visible=true
      end
    end
  end
  
  def input_action
    x=[5000,109,229,353]
    y=[5000,54 ,45 ,51 ]
    while $game_variables[7]==0
      Graphics.update
      Input.update
      @pokemon=@data["pkmn_#{@select}"]
      self.gettinginput
      @sprites["select"].x=x[@select]
      @sprites["select"].y=y[@select]
      self.text; self.typebitmap
    end
  end

  def text
    overlay= @sprites["overlay"].bitmap
    overlay.clear
    baseColor=Color.new(255, 255, 255)
    shadowColor=Color.new(0,0,0)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    name_x=[5000,273,343,103] # -70
    textos=[]
    textos.push([_INTL("{1}", @pokemon.name),name_x[@select],10,false,baseColor,shadowColor])
    pbDrawTextPositions(overlay,textos)
  end
 
  def typebitmap
    
    @sprite=Sprite.new(@viewport)
    @sprite.bitmap=Bitmap.new(194,28)
    @sprite.y=225
    
    @sprite.opacity=0
    @bitmap=BitmapCache.load_bitmap("Graphics/Pictures/types")
    
    @type1rect=Rect.new(0,@pokemon.type1*28,64,28)
    @type2rect=Rect.new(0,@pokemon.type2*28,64,28)
    
    typex=[5000,-120,-50,-285]
    
    if @pokemon.type1==@pokemon.type2
      @sprite.x=402+typex[@select]
      @sprite.bitmap.blt(0,0,@bitmap,@type1rect)
    else
      @sprite.x=370+typex[@select]
      @sprite.bitmap.blt(0,0,@bitmap,@type1rect)
      @sprite.bitmap.blt(66,0,@bitmap,@type2rect)
    end
  end
end