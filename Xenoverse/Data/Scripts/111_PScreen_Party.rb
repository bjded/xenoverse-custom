# Data structure representing mail that the Pokémon can hold
class PokemonMail
  attr_accessor :item,:message,:sender,:poke1,:poke2,:poke3

  def initialize(item,message,sender,poke1=nil,poke2=nil,poke3=nil)
    @item=item   # Item represented by this mail
    @message=message   # Message text
    @sender=sender   # Name of the message's sender
    @poke1=poke1   # [species,gender,shininess,form,shadowness,is egg]
    @poke2=poke2
    @poke3=poke3
  end
end



def pbMoveToMailbox(pokemon)
  $PokemonGlobal.mailbox=[] if !$PokemonGlobal.mailbox
  return false if $PokemonGlobal.mailbox.length>=10
  return false if !pokemon.mail
  $PokemonGlobal.mailbox.push(pokemon.mail)
  pokemon.mail=nil
  return true
end

def pbStoreMail(pkmn,item,message,poke1=nil,poke2=nil,poke3=nil)
  raise _INTL("Pokémon already has mail") if pkmn.mail
  pkmn.mail=PokemonMail.new(item,message,$Trainer.name,poke1,poke2,poke3)
end

def pbDisplayMail(mail,bearer=nil)
  sprites={}
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
	#viewport.z=100000
  addBackgroundPlane(sprites,"background","mailbg",viewport)
  sprites["card"]=IconSprite.new(0,0,viewport)
  sprites["card"].setBitmap(pbMailBackFile(mail.item))
  sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,viewport)
  overlay=sprites["overlay"].bitmap
  pbSetSystemFont(overlay)
  if $ItemData[mail.item][ITEMTYPE]==2
    if mail.poke1
      sprites["bearer"]=IconSprite.new(64,238,viewport)
      bitmapFileName=pbCheckPokemonIconFiles(mail.poke1,mail.poke1[5])
      sprites["bearer"].setBitmap(bitmapFileName)
      sprites["bearer"].src_rect.set(0,0,64,64)
    end
    if mail.poke2
      sprites["bearer2"]=IconSprite.new(144,238,viewport)
      bitmapFileName=pbCheckPokemonIconFiles(mail.poke2,mail.poke2[5])
      sprites["bearer2"].setBitmap(bitmapFileName)
      sprites["bearer2"].src_rect.set(0,0,64,64)
    end
    if mail.poke3
      sprites["bearer3"]=IconSprite.new(224,238,viewport)
      bitmapFileName=pbCheckPokemonIconFiles(mail.poke3,mail.poke3[5])
      sprites["bearer3"].setBitmap(bitmapFileName)
      sprites["bearer3"].src_rect.set(0,0,64,64)
    end
  end
  baseForDarkBG=Color.new(248,248,248)
  shadowForDarkBG=Color.new(72,80,88)
  baseForLightBG=Color.new(80,80,88)
  shadowForLightBG=Color.new(168,168,176)
  if mail.message && mail.message!=""
    isDark=isDarkBackground(sprites["card"].bitmap,Rect.new(48,48,Graphics.width-96,32*7))
    drawTextEx(overlay,48,48,Graphics.width-96,7,mail.message,
       isDark ? baseForDarkBG : baseForLightBG,
       isDark ? shadowForDarkBG : shadowForLightBG)
  end
  if mail.sender && mail.sender!=""
    isDark=isDarkBackground(sprites["card"].bitmap,Rect.new(336,322,144,32*1))
    drawTextEx(overlay,336,322,144,1,_INTL("{1}",mail.sender),
       isDark ? baseForDarkBG : baseForLightBG,
       isDark ? shadowForDarkBG : shadowForLightBG)
  end
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      break
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end


###########################


class PokeSelectionPlaceholderSprite < SpriteWrapper
  attr_accessor :text

  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    xvalues=[0,231,0,231,0,231]
    yvalues=[20,26,116,122,212,218]
    if index != 0 && index != 2 && index != 4
      @pbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/dx")
    else
      @pbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/sx")
    end
    self.bitmap=@pbitmap.bitmap
    self.x=xvalues[index]
    self.y=yvalues[index]
    @text=nil
  end

  def update
    super
    @pbitmap.update
    self.bitmap=@pbitmap.bitmap
  end

  def selected
    return false
  end

  def selected=(value)
  end

  def preselected
    return false
  end

  def preselected=(value)
  end

  def switching
    return false
  end

  def switching=(value)
  end

  def refresh
  end

  def dispose
    @pbitmap.dispose
    super
  end
end



class PokeSelectionConfirmCancelSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,narrowbox=false,viewport=nil)
    super(viewport)
    @refreshBitmap=true
    @bgsprite=ChangelingSprite.new(0,0,viewport)
    if narrowbox
      @bgsprite.addBitmap("deselbitmap","Graphics/Pictures/Party/back")
      @bgsprite.addBitmap("selbitmap","Graphics/Pictures/Party/back_sel")
    else
      @bgsprite.addBitmap("deselbitmap","Graphics/Pictures/Party/back")
      @bgsprite.addBitmap("selbitmap","Graphics/Pictures/Party/back_sel")
    end
    @bgsprite.changeBitmap("deselbitmap")
    @overlaysprite=BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @yoffset=8
    ynarrow=narrowbox ? -6 : 0
    #pbSetSystemFont(@overlaysprite.bitmap)
    pbSetFont(@overlaysprite.bitmap,"Concielian Jet Condensed",20)
    textpos=[[text,48,20+ynarrow,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    @overlaysprite.z=self.z+1 # For compatibility with RGSS2
    self.x=x
    self.y=y
  end

  def dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @bgsprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def selected=(value)
    @selected=value
    refresh
  end

  def refresh
    @bgsprite.changeBitmap((@selected) ? "selbitmap" : "deselbitmap")
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.x=self.x
      @bgsprite.y=self.y
      @overlaysprite.x=self.x
      @overlaysprite.y=self.y
      @bgsprite.color=self.color
      @overlaysprite.color=self.color
    end
  end
end



class PokeSelectionCancelSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CHIUDI"),398,310,false,viewport)
  end
end



class PokeSelectionConfirmSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CONFERMA"),398,308,true,viewport)
  end
end



class PokeSelectionCancelSprite2 < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CHIUDI"),398,346,true,viewport)
  end
end



class ChangelingSprite < SpriteWrapper
  def initialize(x=0,y=0,viewport=nil)
    super(viewport)
    self.x=x
    self.y=y
    @bitmaps={}
    @currentBitmap=nil
  end

  def addBitmap(key,path)
    if @bitmaps[key]
      @bitmaps[key].dispose
    end
    @bitmaps[key]=AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap=@bitmaps[key]
    self.bitmap=@currentBitmap ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    for bm in @bitmaps.values; bm.dispose; end
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    for bm in @bitmaps.values; bm.update; end
    self.bitmap=@currentBitmap ? @currentBitmap.bitmap : nil
  end
end



class PokeSelectionSprite < SpriteWrapper
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :pokemon
  attr_reader :active
  attr_accessor :text

  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    @index=index
    @pokemon=pokemon
    active=(index==0)
    @active=active
    if active # Rounded panel
      @deselbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRound")
      @selbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRoundSel")
      @deselfntbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRoundFnt")
      @selfntbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRoundSelFnt")
      @deselswapbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRoundSwap")
      @selswapbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRoundSelSwap")
    else # Rectangular panel
      @deselbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRect")
      @selbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRectSel")
      @deselfntbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRectFnt")
      @selfntbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRectSelFnt")
      @deselswapbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRectSwap")
      @selswapbitmap=AnimatedBitmap.new("Graphics/Pictures/partyPanelRectSelSwap")
    end
    @dir=["Graphics/Pictures/Party/",
          "Graphics/Pictures/Party/dx",
          "Graphics/Pictures/Party/sx",]
    #LEFT SIDE
    @sxnorm=PartyPanel.new(@dir[2])
    @sxsel=PartyPanel.new(@dir[2]+"_sel")
    @sxfaint=PartyPanel.new(@dir[2])
    @sxfaintsel=PartyPanel.new(@dir[2]+"_ex")
    @sxswitch=PartyPanel.new(@dir[2])
    @sxswitchsel=PartyPanel.new(@dir[2]+"switch_sel")
    
    #RIGHT SIDE
    @dxnorm=PartyPanel.new(@dir[1])
    @dxsel=PartyPanel.new(@dir[1]+"_sel")
    @dxfaint=PartyPanel.new(@dir[1])
    @dxfaintsel=PartyPanel.new(@dir[1]+"_ex")
    @dxswitch=PartyPanel.new(@dir[1])
    @dxswitchsel=PartyPanel.new(@dir[1]+"switch_sel")
    
    #VARIOUS
    @bar=PartyPanel.new(@dir[0]+"bar")
    @barsel=PartyPanel.new(@dir[0]+"bar_sel")
    @healthbar=PartyPanel.new(@dir[0]+"hpbar")
    @male=PartyPanel.new("Graphics/Pictures/male")
    @female=PartyPanel.new("Graphics/Pictures/female")
    
    @spriteXOffset=10
    @spriteYOffset=-14
    @pokeballXOffset=10
    @pokeballYOffset=0
    @pokenameX=236                         #RIGHT ALIGNED
    @pokenameY=6
    @levelX=15
    @levelY=54
    @statusX=80
    @statusY=55
    @genderX=224
    @genderY=32
    @hpX=184                               #CENTER ALIGNED
    @hpY=54
    @hpbarX=136
    @hpbarY=38
    @gaugeX=128
    @gaugeY=52
    @itemXOffset=62
    @itemYOffset=38
    @annotX=96
    @annotY=58
    #Right side alignment
    if index != 0 && index != 2 && index != 4
      @hpX+=30
      @gaugeX+=30
      @annotX+=30
      @pokenameX+=30
      @levelX+=30
      @hpbarX+=30
      @genderX+=30
      @statusX+=30
      @spriteXOffset+=30
      @itemXOffset+=30
    end
    
    xvalues=[0,231,0,231,0,231]
    yvalues=[20,26,116,122,212,218]
    @text=nil
    @statuses=AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @hpbar=AnimatedBitmap.new("Graphics/Pictures/partyHP")
    @hpbarfnt=AnimatedBitmap.new("Graphics/Pictures/partyHPfnt")
    @hpbarswap=AnimatedBitmap.new("Graphics/Pictures/partyHPswap")
    @pokeballsprite=ChangelingSprite.new(0,0,viewport)
    @pokeballsprite.addBitmap("pokeballdesel","Graphics/Pictures/partyBall")
    @pokeballsprite.addBitmap("pokeballsel","Graphics/Pictures/partyBallSel")
    @pkmnsprite=PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.active=active
    @itemsprite=ChangelingSprite.new(0,0,viewport)
    @itemsprite.addBitmap("itembitmap","Graphics/Pictures/item")
    @itemsprite.addBitmap("mailbitmap","Graphics/Pictures/mail")
    @spriteX=xvalues[index]
    @spriteY=yvalues[index]
    @refreshBitmap=true
    @refreshing=false 
    @preselected=false
    @switching=false
    @pkmnsprite.z=self.z+2 # For compatibility with RGSS2
    @itemsprite.z=self.z+3 # For compatibility with RGSS2
    @pokeballsprite.z=self.z+1 # For compatibility with RGSS2
    self.selected=false
    self.x=@spriteX
    self.y=@spriteY
    refresh
  end

  def dispose
    #LEFT SIDE
    @sxnorm.dispose
    @sxsel.dispose
    @sxfaint.dispose
    @sxfaintsel.dispose
    @sxswitch.dispose
    @sxswitchsel.dispose
    
    #RIGHT SIDE
    @dxnorm.dispose
    @dxsel.dispose
    @dxfaint.dispose
    @dxfaintsel.dispose
    @dxswitch.dispose
    @dxswitchsel.dispose
    
    #VARIOUS
    @male.dispose
    @female.dispose
    @bar.dispose
    @barsel.dispose
    @healthbar.dispose
    @selbitmap.dispose
    @statuses.dispose
    @hpbar.dispose
    @deselbitmap.dispose
    @itemsprite.dispose
    @pkmnsprite.dispose
    @pokeballsprite.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    @selected=value
    @refreshBitmap=true
    refresh
  end

  def text=(value)
    @text=value
    @refreshBitmap=true
    refresh
  end

  def pokemon=(value)
    @pokemon=value
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.pokemon=value
    end
    @refreshBitmap=true
    refresh
  end

  def preselected=(value)
    if value!=@preselected
      @preselected=value
      refresh
    end
  end

  def switching=(value)
    if value!=@switching
      @switching=value
      refresh
    end
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def hp
    return @pokemon.hp
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing=true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(@dxnorm.width,@dxnorm.height)
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x=self.x+@spriteXOffset
      @pkmnsprite.y=self.y+@spriteYOffset
      @pkmnsprite.color=pbSrcOver(@pkmnsprite.color,self.color)
      @pkmnsprite.selected=self.selected
    end
    if @pokeballsprite && !@pokeballsprite.disposed?
      @pokeballsprite.x=self.x+@pokeballXOffset
      @pokeballsprite.y=self.y+@pokeballYOffset
      @pokeballsprite.color=self.color
      @pokeballsprite.changeBitmap(self.selected ? "pokeballsel" : "pokeballdesel")
    end
    if @itemsprite && !@itemsprite.disposed?
      @itemsprite.visible=(@pokemon.item>0)
      if @itemsprite.visible
        @itemsprite.changeBitmap(@pokemon.mail ? "mailbitmap" : "itembitmap")
        @itemsprite.x=self.x+@itemXOffset
        @itemsprite.y=self.y+@itemYOffset
        @itemsprite.color=self.color
      end
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear if self.bitmap
      if self.selected
        if self.preselected
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxswitch.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(0,0,@dxswitchsel.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxswitch.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(0,0,@sxswitchsel.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        elsif @switching
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxswitchsel.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxswitchsel.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        elsif @pokemon.hp<=0 && !@pokemon.isEgg?
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxfaintsel.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxfaintsel.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        else
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxsel.bitmap,Rect.new(0,0,@dxsel.width,@dxsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxsel.bitmap,Rect.new(0,0,@sxsel.width+200,@sxsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        end
      else
        if self.preselected
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxswitch.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(0,0,@dxswitchsel.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxswitch.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(0,0,@sxswitchsel.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
          #self.bitmap.blt(0,0,@deselswapbitmap.bitmap,Rect.new(0,0,@deselswapbitmap.width,@deselswapbitmap.height))
        elsif @pokemon.hp<=0 && !@pokemon.isEgg?
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxfaint.bitmap,Rect.new(0,0,@dxswitchsel.width,@dxswitchsel.height))
            self.bitmap.blt(35,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxfaint.bitmap,Rect.new(0,0,@sxswitchsel.width,@sxswitchsel.height))
            self.bitmap.blt(5,30,@barsel.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        else
          if @index != 0 && @index != 2 && @index != 4
            self.bitmap.blt(0,0,@dxnorm.bitmap,Rect.new(0,0,@dxnorm.width,@dxnorm.height))
            self.bitmap.blt(35,30,@bar.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          else
            self.bitmap.blt(0,0,@sxnorm.bitmap,Rect.new(0,0,@sxnorm.width,@sxnorm.height))
            self.bitmap.blt(5,30,@bar.bitmap,Rect.new(0,0,@barsel.width,@barsel.height))
          end
        end
      end
      base=Color.new(248,248,248)
      shadow=Color.new(40,40,40)
      #pbSetSystemFont(self.bitmap)
      pbSetFont(self.bitmap,"Concielian Jet Condensed",25)
      pokename=@pokemon.name
      textpos=[[pokename,@pokenameX,@pokenameY,1,base,shadow]]
      if !@pokemon.isEgg?
        if !@text || @text.length==0
          tothp=@pokemon.totalhp
          textpos2=[[_ISPRINTF("{1: 3d}/{2: 3d}",@pokemon.hp,tothp),
             @hpX,@hpY,2,base,shadow]]
          percentage=@pokemon.hp/100
          barbg=(@pokemon.hp<=0) ? @hpbarfnt : @hpbar
          barbg=(self.preselected || (self.selected && @switching)) ? @hpbarswap : barbg
          self.bitmap.blt(@hpbarX,@hpbarY,@healthbar.bitmap,Rect.new(0,0,(self.hp*@healthbar.width/@pokemon.totalhp),@healthbar.height))
          hpgauge=@pokemon.totalhp==0 ? 0 : (self.hp*96/@pokemon.totalhp)
          hpgauge=1 if hpgauge==0 && self.hp>0
          hpzone=0
          hpzone=1 if self.hp<=(@pokemon.totalhp/2).floor
          hpzone=2 if self.hp<=(@pokemon.totalhp/4).floor
          hpcolors=[
             Color.new(24,192,32),Color.new(96,248,96),   # Green
             Color.new(232,168,0),Color.new(248,216,0),   # Orange
             Color.new(248,72,56),Color.new(248,152,152)  # Red
          ]
          # fill with HP color
          #self.bitmap.fill_rect(@gaugeX,@gaugeY,hpgauge,2,hpcolors[hpzone*2])
          #self.bitmap.fill_rect(@gaugeX,@gaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
          #self.bitmap.fill_rect(@gaugeX,@gaugeY+6,hpgauge,2,hpcolors[hpzone*2])
          if @pokemon.hp==0 || @pokemon.status>0
            status=(@pokemon.hp==0) ? 5 : @pokemon.status-1
            statusrect=Rect.new(0,16*status,44,16)
            self.bitmap.blt(@statusX,@statusY,@statuses.bitmap,statusrect)
          end
        end
        
        if @pokemon.isMale?
          self.bitmap.blt(@genderX,@genderY,@male.bitmap,Rect.new(0,0,@dxnorm.width,@dxnorm.height))
        elsif @pokemon.isFemale?
          self.bitmap.blt(@genderX,@genderY,@female.bitmap,Rect.new(0,0,@dxnorm.width,@dxnorm.height))
        end
      end
      self.bitmap.blt(@hpbarX,@hpbarY,@healthbar.bitmap,Rect.new(0,0,(self.hp*@healthbar.width/@pokemon.totalhp),@healthbar.height)) if @pokemon
      pbDrawTextPositions(self.bitmap,textpos)
      pbSetFont(self.bitmap,"Concielian Bold Semi-Italic",18)
      pbDrawTextPositions(self.bitmap,textpos2) if textpos2
      if !@pokemon.isEgg?
        pbSetFont(self.bitmap,"Concielian Bold Semi-Italic",18)
        leveltext=[([_INTL("Lv.{1}",@pokemon.level),@levelX,@levelY,0,base,shadow])]
        pbDrawTextPositions(self.bitmap,leveltext)
      end
      if @text && @text.length>0
        pbSetSystemFont(self.bitmap)
        annotation=[[@text,@annotX,@annotY,0,base,shadow]]
        pbDrawTextPositions(self.bitmap,annotation)
      end
    end
    @refreshing=false
  end

  def update
    super
    @pokeballsprite.update if @pokeballsprite && !@pokeballsprite.disposed?
    @itemsprite.update if @itemsprite && !@itemsprite.disposed?
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.update
    end
  end
end


##############################


class PokemonScreen_Scene
  def pbShowCommands(helptext,commands,y=nil,index=0)
    ret=-1
    helpwindow=@sprites["helpwindow"]
    helpwindow.y=y if y != nil
    helpwindow.x+=14
    helpwindow.y-=10
    helpwindow.visible=true
    using(cmdwindow=Window_CommandPokemon.new(commands)) {
       cmdwindow.z=@viewport.z+1
       cmdwindow.index=index
       pbBottomRight(cmdwindow)
       helpwindow.text=""
       helpwindow.windowskin=nil
       helpwindow.resizeHeightToFit(helptext,Graphics.width-cmdwindow.width)
       helpwindow.text=helptext
       pbBottomLeft(helpwindow)
       helpwindow.x+=14
       helpwindow.y-=10
       helpwindow.y=y if y != nil
       loop do
         Graphics.update
         Input.update
         cmdwindow.update
         self.update
         if Input.trigger?(Input::B)
           pbPlayCancelSE()
           ret=-1
           break
         end
         if Input.trigger?(Input::C)
           pbPlayDecisionSE()
           ret=cmdwindow.index
           break
         end
       end
    }
    return ret
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbSetHelpText(helptext)
    helpwindow=@sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.y-=10
    helpwindow.x+=14
    helpwindow.text=helptext
    helpwindow.windowskin=nil
    helpwindow.width=398
    helpwindow.visible=true
  end

  def pbStartScene(party,starthelptext,annotations=nil,multiselect=false)
    @sprites={}
    @party=party
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
		#@viewport.z=100000
    @multiselect=multiselect
    #addBackgroundPlane(@sprites,"partybg","partybg",@viewport)
    @sprites["bg"]=Sprite.new(@viewport)
    @sprites["bg"].bitmap=pbBitmap("Graphics/Pictures/Party/BG")
    @sprites["box"]=Sprite.new(@viewport)
    @sprites["box"].bitmap=pbBitmap("Graphics/Pictures/Party/choosepooke")
    @sprites["box"].x=6
    @sprites["box"].y=Graphics.height-@sprites["box"].bitmap.height-8
    @sprites["messagebox"]=Window_AdvancedTextPokemon.new("")
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["messagebox"].viewport=@viewport
    @sprites["messagebox"].visible=false
    @sprites["messagebox"].letterbyletter=true
    @sprites["helpwindow"].viewport=@viewport
    @sprites["helpwindow"].visible=true
    @sprites["helpwindow"].baseColor=Color.new(240,240,240)
    @sprites["helpwindow"].shadowColor=Color.new(40,40,40)
    @sprites["helpwindow"].windowskin=nil
    pbBottomLeftLines(@sprites["messagebox"],2)
    pbBottomLeftLines(@sprites["helpwindow"],1)
    @sprites["helpwindow"].y-=10
    pbSetHelpText(starthelptext)
    # Add party Pokémon sprites
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
           @party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
           @party[i],i,@viewport)
      end
      if annotations
        @sprites["pokemon#{i}"].text=annotations[i]
      end
    end
    if @multiselect
      @sprites["pokemon6"]=PokeSelectionConfirmSprite.new(@viewport)
      @sprites["pokemon7"]=PokeSelectionCancelSprite2.new(@viewport)
    else
      @sprites["pokemon6"]=PokeSelectionCancelSprite.new(@viewport)
    end
    # Select first Pokémon
    @activecmd=0
    @sprites["pokemon0"].selected=true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChangeSelection(key,currentsel)
    numsprites=(@multiselect) ? 8 : 7 
    case key
    when Input::LEFT
      begin
        currentsel-=1
      end while currentsel>0 && currentsel<@party.length && !@party[currentsel]
      if currentsel>=@party.length && currentsel<6
        currentsel=@party.length-1
      end
      currentsel=numsprites-1 if currentsel<0
    when Input::RIGHT
      begin
        currentsel+=1
      end while currentsel<@party.length && !@party[currentsel]
      if currentsel==@party.length
        currentsel=6
      elsif currentsel==numsprites
        currentsel=0
      end
    when Input::UP
      if currentsel>=6
        begin
          currentsel-=1
        end while currentsel>0 && !@party[currentsel]
      else
        begin
          currentsel-=2
        end while currentsel>0 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<6
        currentsel=@party.length-1
      end
      currentsel=numsprites-1 if currentsel<0
    when Input::DOWN
      if currentsel>=5
        currentsel+=1
      else
        currentsel+=2
        currentsel=6 if currentsel<6 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<6
        currentsel=6
      elsif currentsel>=numsprites
        currentsel=0
      end
    end
    return currentsel
  end

  def pbRefresh
    for i in 0...6
      sprite=@sprites["pokemon#{i}"]
      if sprite 
        if sprite.is_a?(PokeSelectionSprite)
          sprite.pokemon=sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  end

  def pbRefreshSingle(i)
    sprite=@sprites["pokemon#{i}"]
    if sprite 
      if sprite.is_a?(PokeSelectionSprite)
        sprite.pokemon=sprite.pokemon
      else
        sprite.refresh
      end
    end
  end
  
  ###########
  '''def pbStartFormChange(i)
    pbFadeOutIn(99999) {
      pbRefreshSingle(i)
    }
    pbDisplay(_INTL("{1} ha cambiato forma!", @party[i].name))
  end
  
  def prova(x, y)
    pbDisplay(_INTL("X: #{x}   Y: #{y}"))
    yield
  end'''
  ############

  def pbHardRefresh
    oldtext=[]
    lastselected=-1
    for i in 0...6
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected=i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected=@party.length-1 if lastselected>=@party.length
    lastselected=0 if lastselected<0
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
        @party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
        @party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text=oldtext[i]
    end
    pbSelect(lastselected)
  end

  def pbPreSelect(pkmn)
    @activecmd=pkmn
  end

  def pbChoosePokemon(switching=false)
    for i in 0...6
      @sprites["pokemon#{i}"].preselected=(switching&&i==@activecmd)
      @sprites["pokemon#{i}"].switching=switching
    end
    pbRefresh
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel=@activecmd
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        @activecmd=pbChangeSelection(key,@activecmd)
      end
      if @activecmd!=oldsel # Changing selection
        pbPlayCursorSE()
        numsprites=(@multiselect) ? 8 : 7
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected=(i==@activecmd)
        end
      end
      if Input.trigger?(Input::B)
        return -1
      end
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        cancelsprite=(@multiselect) ? 7 : 6
        return (@activecmd==cancelsprite) ? -1 : @activecmd
      end
    end
  end

  def pbSelect(item)
    @activecmd=item
    numsprites=(@multiselect) ? 8 : 7
    for i in 0...numsprites
      @sprites["pokemon#{i}"].selected=(i==@activecmd)
    end
  end

  def pbDisplay(text)
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy? && Input.trigger?(Input::C)
        pbPlayDecisionSE() if @sprites["messagebox"].pausing?
        @sprites["messagebox"].resume
      end
      if !@sprites["messagebox"].busy? &&
         (Input.trigger?(Input::C) || Input.trigger?(Input::B))
        break
      end
    end
    @sprites["messagebox"].visible=false
    @sprites["helpwindow"].visible=true
  end

  def pbSwitchBegin(oldid,newid)
    oldsprite=@sprites["pokemon#{oldid}"]
    newsprite=@sprites["pokemon#{newid}"]
    22.times do
      oldsprite.x+=(oldid&1)==0 ? -12 : 12
      newsprite.x+=(newid&1)==0 ? -12 : 12
      Graphics.update
      Input.update
      self.update
    end
  end
  
  def pbSwitchEnd(oldid,newid)
    oldsprite=@sprites["pokemon#{oldid}"]
    newsprite=@sprites["pokemon#{newid}"]
    oldsprite.pokemon=@party[oldid]
    newsprite.pokemon=@party[newid]
    22.times do
      oldsprite.x-=(oldid&1)==0 ? -12 : 12
      newsprite.x-=(newid&1)==0 ? -12 : 12
      Graphics.update
      Input.update
      self.update
    end
    for i in 0...6
      @sprites["pokemon#{i}"].preselected=false
      @sprites["pokemon#{i}"].switching=false
    end
    pbRefresh
  end

  def pbDisplayConfirm(text)
    ret=-1
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    using(cmdwindow=Window_CommandPokemon.new([_INTL("Si"),_INTL("No")])){
       cmdwindow.z=@viewport.z+1
       cmdwindow.visible=false
       pbBottomRight(cmdwindow)
       cmdwindow.y-=@sprites["messagebox"].height
       loop do
         Graphics.update
         Input.update
         cmdwindow.visible=true if !@sprites["messagebox"].busy?
         cmdwindow.update
         self.update
         if Input.trigger?(Input::B) && !@sprites["messagebox"].busy?
           ret=false
           break
         end
         if Input.trigger?(Input::C) && @sprites["messagebox"].resume && !@sprites["messagebox"].busy?
           ret=(cmdwindow.index==0)
           break
         end
       end
    }
    @sprites["messagebox"].visible=false
    @sprites["helpwindow"].visible=true
    return ret
  end

  def pbAnnotate(annot)
    for i in 0...6
      if annot
        @sprites["pokemon#{i}"].text=annot[i]
      end
    end
  end

  def pbSummary(pkmnid)
    oldsprites=pbFadeOutAndHide(@sprites)
    scene=PokemonSummaryScene.new
    screen=PokemonSummary.new(scene)
    screen.pbStartScreen(@party,pkmnid)
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbChooseItem(bag)
    oldsprites=pbFadeOutAndHide(@sprites)
    @sprites["helpwindow"].visible=false
    @sprites["messagebox"].visible=false
    scene=PokemonBag_Scene.new
    screen=PokemonBagScreen.new(scene,bag)
    ret=screen.pbGiveItemScreen
    pbFadeInAndShow(@sprites,oldsprites)
    return ret
  end

  def pbMessageFreeText(text,startMsg,maxlength)
    return Kernel.pbMessageFreeText(
       _INTL("Please enter a message (max. {1} characters).",maxlength),
       _INTL("{1}",startMsg),false,maxlength,Graphics.width) { update }
  end
end


######################################


class PokemonScreen
  def initialize(scene,party)
    @party=party
    @scene=scene
  end

  def pbHardRefresh
    @scene.pbHardRefresh
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbRefreshSingle(i)
    @scene.pbRefreshSingle(i)
  end
  
  def pbStartFormChange(i)
    @scene.pbStartFormChange(i)
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end

  def pbSwitch(oldid,newid)
    if oldid!=newid
      @scene.pbSwitchBegin(oldid,newid)
      tmp=@party[oldid]
      @party[oldid]=@party[newid]
      @party[newid]=tmp
      @scene.pbSwitchEnd(oldid,newid)
    end
  end

  def pbMailScreen(item,pkmn,pkmnid)
    message=""
    loop do
      message=@scene.pbMessageFreeText(
         _INTL("Please enter a message (max. 256 characters)."),"",256)
      if message!=""
        # Store mail if a message was written
        poke1=poke2=poke3=nil
        if $Trainer.party[pkmnid+2]
          p=$Trainer.party[pkmnid+2]
          poke1=[p.species,p.gender,p.isShiny?,(p.form rescue 0),(p.isShadow? rescue false)]
          poke1.push(true) if p.isEgg?
        end
        if $Trainer.party[pkmnid+1]
          p=$Trainer.party[pkmnid+1]
          poke2=[p.species,p.gender,p.isShiny?,(p.form rescue 0),(p.isShadow? rescue false)]
          poke2.push(true) if p.isEgg?
        end
        poke3=[pkmn.species,pkmn.gender,pkmn.isShiny?,(pkmn.form rescue 0),(pkmn.isShadow? rescue false)]
        poke3.push(true) if pkmn.isEgg?
        pbStoreMail(pkmn,item,message,poke1,poke2,poke3)
        return true
      else
        return false if pbConfirm(_INTL("Stop giving the Pokémon Mail?"))
      end
    end
  end

  def pbTakeMail(pkmn)
    if !pkmn.hasItem?
      pbDisplay(_INTL("{1} isn't holding anything.",pkmn.name))
    elsif !$PokemonBag.pbCanStore?(pkmn.item)
      pbDisplay(_INTL("The Bag is full.  The Pokémon's item could not be removed."))
    elsif pkmn.mail
      if pbConfirm(_INTL("Send the removed mail to your PC?"))
        if !pbMoveToMailbox(pkmn)
          pbDisplay(_INTL("Your PC's Mailbox is full."))
        else
          pbDisplay(_INTL("The mail was sent to your PC."))
          pkmn.setItem(0)
        end
      elsif pbConfirm(_INTL("If the mail is removed, the message will be lost.  OK?"))
        pbDisplay(_INTL("Mail was taken from the Pokémon."))
        $PokemonBag.pbStoreItem(pkmn.item)
        pkmn.setItem(0)
        pkmn.mail=nil
      end
    else
      $PokemonBag.pbStoreItem(pkmn.item)
      itemname=PBItems.getName(pkmn.item)
      pbDisplay(_INTL("Ricevuto {1} da {2}.",itemname,pkmn.name))
      pkmn.setItem(0)
    end
  end

  def pbGiveMail(item,pkmn,pkmnid=0)
    thisitemname=PBItems.getName(item)
    if pkmn.isEgg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return false
    end
    if pkmn.mail
      pbDisplay(_INTL("Mail must be removed before holding an item."))
      return false
    end
    if pkmn.item!=0
      itemname=PBItems.getName(pkmn.item)
      pbDisplay(_INTL("{1} is already holding one {2}.\1",pkmn.name,itemname))
      if pbConfirm(_INTL("Would you like to switch the two items?"))
        $PokemonBag.pbDeleteItem(item)
        if !$PokemonBag.pbStoreItem(pkmn.item)
          if !$PokemonBag.pbStoreItem(item) # Compensate
            raise _INTL("Can't re-store deleted item in bag")
          end
          pbDisplay(_INTL("The Bag is full.  The Pokémon's item could not be removed."))
        else
          if pbIsMail?(item)
            if pbMailScreen(item,pkmn,pkmnid)
              pkmn.setItem(item)
              pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,thisitemname))
              return true
            else
              if !$PokemonBag.pbStoreItem(item) # Compensate
                raise _INTL("Can't re-store deleted item in bag")
              end
            end
          else
            pkmn.setItem(item)
            pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,thisitemname))
            return true
          end
        end
      end
    else
      if !pbIsMail?(item) || pbMailScreen(item,pkmn,pkmnid) # Open the mail screen if necessary
        $PokemonBag.pbDeleteItem(item)
        pkmn.setItem(item)
        pbDisplay(_INTL("A {1} viene dato {2} da tenere.",pkmn.name,thisitemname))
        return true
      end
    end
    return false
  end

  def pbPokemonGiveScreen(item)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid=@scene.pbChoosePokemon
    ret=false
    form = @party[pkmnid].form
    if pkmnid>=0
      ret=pbGiveMail(item,@party[pkmnid],pkmnid)
    end
    if form != @party[pkmnid].form
      pbStartFormChange(pkmnid)
    else
      pbRefreshSingle(pkmnid)
    end
    pbRefreshSingle(pkmnid)
    $PokemonTemp.dependentEvents.refresh_sprite(true)
    @scene.pbEndScene
    return ret
  end

  def pbPokemonGiveMailScreen(mailIndex)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid=@scene.pbChoosePokemon
    if pkmnid>=0
      pkmn=@party[pkmnid]
      if pkmn.item!=0 || pkmn.mail
        pbDisplay(_INTL("This Pokémon is holding an item.  It can't hold mail."))
      elsif pkmn.isEgg?
        pbDisplay(_INTL("Eggs can't hold mail."))
      else
        pbDisplay(_INTL("Mail was transferred from the Mailbox."))
        pkmn.mail=$PokemonGlobal.mailbox[mailIndex]
        pkmn.setItem(pkmn.mail.item)
        $PokemonGlobal.mailbox.delete_at(mailIndex)
        pbRefreshSingle(pkmnid)
      end
    end
    @scene.pbEndScene
  end

  def pbStartScene(helptext,doublebattle,annotations=nil)
    @scene.pbStartScene(@party,helptext,annotations)
  end

  def pbChoosePokemon(helptext=nil)
    @scene.pbSetHelpText(helptext) if helptext
    return @scene.pbChoosePokemon
  end

  def pbChooseMove(pokemon,helptext)
    movenames=[]
    for i in pokemon.moves
      break if i.id==0
      if i.totalpp==0
        movenames.push(_INTL("{1} (PP: ---)",PBMoves.getName(i.id),i.pp,i.totalpp))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",PBMoves.getName(i.id),i.pp,i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames)
  end

  def pbEndScene
    @scene.pbEndScene
  end

  # Checks for identical species
  def pbCheckSpecies(array)
    for i in 0...array.length
      for j in i+1...array.length
        return false if array[i].species==array[j].species
      end
    end
    return true
  end

# Checks for identical held items
  def pbCheckItems(array)
    for i in 0...array.length
      next if !array[i].hasItem?
      for j in i+1...array.length
        return false if array[i].item==array[j].item
      end
    end
    return true
  end

  def pbPokemonMultipleEntryScreenEx(ruleset)
    annot=[]
    statuses=[]
    ordinals=[
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH")
    ]
    if !ruleset.hasValidTeam?(@party)
      return nil
    end
    ret=nil
    addedEntry=false
    for i in 0...@party.length
      if ruleset.isPokemonValid?(@party[i])
        statuses[i]=1
      else
        statuses[i]=2
      end  
    end
    for i in 0...@party.length
      annot[i]=ordinals[statuses[i]]
    end
    @scene.pbStartScene(@party,_INTL("Choose Pokémon and confirm."),annot,true)
    loop do
      realorder=[]
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]]=i+3
      end
      for i in 0...@party.length
        annot[i]=ordinals[statuses[i]]
      end
      @scene.pbAnnotate(annot)
      if realorder.length==ruleset.number && addedEntry
        @scene.pbSelect(6)
      end
      @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      pkmnid=@scene.pbChoosePokemon
      addedEntry=false
      if pkmnid==6 # Confirm was chosen
        ret=[]
        for i in realorder
          ret.push(@party[i])
        end
        error=[]
        if !ruleset.isValid?(ret,error)
          pbDisplay(error[0])
          ret=nil
        else
          break
        end
      end
      if pkmnid<0 # Canceled
        break
      end
      cmdEntry=-1
      cmdNoEntry=-1
      cmdSummary=-1
      commands=[]
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry=commands.length]=_INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry=commands.length]=_INTL("No Entry")
      end
      pkmn=@party[pkmnid]
      commands[cmdSummary=commands.length]=_INTL("Info")
      commands[commands.length]=_INTL("Chiudi")
      command=@scene.pbShowCommands(_INTL("Che fare con {1}?",pkmn.name),commands) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=ruleset.number && ruleset.number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",ruleset.number))
        else
          statuses[pkmnid]=realorder.length+3
          addedEntry=true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid]=1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbChooseAblePokemon(ableProc,allowIneligible=false)
    annot=[]
    eligibility=[]
    for pkmn in @party
      elig=ableProc.call(pkmn)
      eligibility.push(elig)
      annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret=-1
    @scene.pbStartScene(@party,
       @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid=@scene.pbChoosePokemon
      if pkmnid<0
        break
      elsif !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret=pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
    annot=[]
    for pkmn in @party
      elig=ableProc.call(pkmn)
      annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    @scene.pbAnnotate(annot)
  end

  def pbPokemonDebug(pkmn,pkmnid)
    command=0
    loop do
      command=@scene.pbShowCommands(_INTL("Che fare con {1}?",pkmn.name),[
         _INTL("HP/Status"),
         _INTL("Livello"),
         _INTL("Species"),
         _INTL("Mosse"),
         _INTL("Genere"),
         _INTL("Abilità"),
         _INTL("Nature"),
         _INTL("Shininess"),
         _INTL("Form"),
         _INTL("Happiness"),
         _INTL("EV/IV/pID"),
         _INTL("Pokérus"),
         _INTL("Ownership"),
         _INTL("Nickname"),
         _INTL("Poké Ball"),
         _INTL("Ribbons"),
         _INTL("Egg"),
         _INTL("Shadow Pokémon"),
         _INTL("Make Mystery Gift"),
         _INTL("Duplicate"),
         _INTL("Delete"),
         _INTL("Chiudi")
      ],command)
      case command
      ### Cancel ###
      when -1, 21
        break
      ### HP/Status ###
      when 0
        $scene=nil
      ### Level ###
      when 1
        $scene=nil
      ### Species ###
      when 2
        $scene=nil
      ### Moves ###
      when 3
        $scene=nil
      ### Gender ###
      when 4
        $scene=nil
      ### Ability ###
      when 5
        $scene=nil
      ### Nature ###
      when 6
        $scene=nil
      ### Shininess ###
      when 7
        $scene=nil
      ### Form ###
      when 8
        $scene=nil
      ### Happiness ###
      when 9
        $scene=nil
      ### EV/IV/pID ###
      when 10
        $scene=nil
      ### Pokérus ###
      when 11
        $scene=nil
      ### Ownership ###
      when 12
        $scene=nil
      ### Nickname ###
      when 13
        $scene=nil
      ### Poké Ball ###
      when 14
        $scene=nil
      ### Ribbons ###
      when 15
        $scene=nil
      ### Egg ###
      when 16
        $scene=nil
      ### Shadow Pokémon ###
      when 17
        $scene=nil
      ### Make Mystery Gift ###
      when 18
        $scene=nil
      ### Duplicate ###
      when 19
        $scene=nil
      ### Delete ###
      when 20
        $scene=nil
      end
    end
  end

  def pbPokemonScreen
    @scene.pbStartScene(@party,
       @party.length>1 ? _INTL("Scegli un Pokémon.") : _INTL("Scegli un Pokémon o esci."),nil)
    loop do
      @scene.pbSetHelpText(
         @party.length>1 ? _INTL("Scegli un Pokémon.") : _INTL("Scegli un Pokémon o esci."))
      pkmnid=@scene.pbChoosePokemon
      if pkmnid<0
        break
      end
      pkmn=@party[pkmnid]
      commands=[]
      cmdSummary=-1
      cmdSwitch=-1
      cmdItem=-1
      cmdDebug=-1
      cmdMail=-1
      # Build the commands
      commands[cmdSummary=commands.length]=_INTL("Statistiche")
      if $DEBUG
        # Commands for debug mode only
        commands[cmdDebug=commands.length]=_INTL("Debug")
      end
      cmdMoves=[-1,-1,-1,-1]
      for i in 0...pkmn.moves.length
        move=pkmn.moves[i]
        # Check for hidden moves and add any that were found
        if !pkmn.isEgg? && (
           isConst?(move.id,PBMoves,:MILKDRINK) ||
           isConst?(move.id,PBMoves,:SOFTBOILED) ||
           HiddenMoveHandlers.hasHandler(move.id)
           )
          commands[cmdMoves[i]=commands.length]=PBMoves.getName(move.id)
        end
      end
      commands[cmdSwitch=commands.length]=_INTL("Ordina") if @party.length>1
      if !pkmn.isEgg?
        if pkmn.mail
          commands[cmdMail=commands.length]=_INTL("Mail")
        else
          commands[cmdItem=commands.length]=_INTL("Oggetti")
        end
      end
      commands[commands.length]=_INTL("Chiudi")
      command=@scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand=false
      for i in 0...4
        if cmdMoves[i]>=0 && command==cmdMoves[i]
          havecommand=true
          if isConst?(pkmn.moves[i].id,PBMoves,:SOFTBOILED) ||
             isConst?(pkmn.moves[i].id,PBMoves,:MILKDRINK)
            if pkmn.hp<=pkmn.totalhp/5
              pbDisplay(_INTL("Not enough HP..."))
              break
            end
            @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if newpkmn.isEgg? || newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp || pkmnid==oldpkmnid
                pbDisplay(_INTL("This item can't be used on that Pokémon."))
              else
                pkmn.hp-=pkmn.totalhp/5
                hpgain=pbItemRestoreHP(newpkmn,pkmn.totalhp/5)
                @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
                pbRefresh
              end
            end
            break
          elsif Kernel.pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
            @scene.pbEndScene
            if isConst?(pkmn.moves[i].id,PBMoves,:FLY)
              scene=PokemonRegionMapScene.new(-1,false)
              screen=PokemonRegionMap.new(scene)
              ret=screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
                return [pkmn,pkmn.moves[i].id]
              end
              @scene.pbStartScene(@party,
                 @party.length>1 ? _INTL("Scegli un Pokémon.") : _INTL("Scegli un Pokémon."))
              break
            end
            return [pkmn,pkmn.moves[i].id]
          else
            break
          end
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid=pkmnid
        pkmnid=@scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
          $PokemonTemp.dependentEvents.refresh_sprite(true)
        end
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdMail>=0 && command==cmdMail
        command=@scene.pbShowCommands(_INTL("Do what with the mail?"),[_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0 # Read
          pbFadeOutIn(99999){
             pbDisplayMail(pkmn.mail,pkmn)
          }
        when 1 # Take
          pbTakeMail(pkmn)
          pbRefreshSingle(pkmnid)
        end
      elsif cmdItem>=0 && command==cmdItem
        commands=[_INTL("Dai"),_INTL("Prendi"),_INTL("Chiudi")]
        command=@scene.pbShowCommands(_INTL("Cosa devi fare con questo oggetto?"),commands,296)
        case command
        when 0 # Give
          item=@scene.pbChooseItem($PokemonBag)
          if item>0
            form = pkmn.form
            pbGiveMail(item,pkmn,pkmnid)
            if form != pkmn.form
              pbStartFormChange(pkmnid)
              $PokemonTemp.dependentEvents.refresh_sprite(true)
            else
              pbRefreshSingle(pkmnid)
              $PokemonTemp.dependentEvents.refresh_sprite(true)
            end
          end
        when 1 # Take
          form = pkmn.form
          pbTakeMail(pkmn)
          if form != pkmn.form
            pbStartFormChange(pkmnid)
            $PokemonTemp.dependentEvents.refresh_sprite(true)
          else
            pbRefreshSingle(pkmnid)
            $PokemonTemp.dependentEvents.refresh_sprite(true)
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end  
end