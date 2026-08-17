class PokemonMartScene
  def update
    pbUpdateSpriteHash(@sprites)
    @subscene.update if @subscene
  end

  def pbChooseNumber(helptext,item,maximum)
    curnumber=1
    ret=0
    helpwindow=@sprites["helpwindow"]
    itemprice=@bpmode ? @adapter.getBattlePrice(item) : @adapter.getPrice(item,!@buying)
    itemprice/=2 if !@buying
    pbDisplay(helptext,true)
    using(numwindow=Window_AdvancedTextPokemon.new("")){ # Showing number of items
       qty=@adapter.getQuantity(item)
       using(inbagwindow=Window_AdvancedTextPokemon.new("")){ # Showing quantity in bag
          pbPrepareWindow(numwindow)
          pbPrepareWindow(inbagwindow)
          numwindow.viewport=@viewport
          numwindow.width=224
          numwindow.height=64
          numwindow.baseColor=Color.new(88,88,80)
          numwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.visible=@buying
          inbagwindow.viewport=@viewport
          inbagwindow.width=190
          inbagwindow.height=64
          inbagwindow.baseColor=Color.new(88,88,80)
          inbagwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.text=_ISPRINTF("In Bag:<r>{1:d}  ",qty)
          if @bpmode
            numwindow.text=_ISPRINTF("x{1:d}<r> {2:d}P",curnumber,curnumber*itemprice)
          else
            numwindow.text=_ISPRINTF("x{1:d}<r>$ {2:d}",curnumber,curnumber*itemprice)
          end
          pbBottomRight(numwindow)
          numwindow.y-=helpwindow.height
          pbBottomLeft(inbagwindow)
          inbagwindow.y-=helpwindow.height
          loop do
            Graphics.update
            Input.update
            numwindow.update
            inbagwindow.update
            self.update
            if Input.repeat?(Input::LEFT)
              pbPlayCursorSE()
              curnumber-=10
              curnumber=1 if curnumber<1
              if @bpmode
                numwindow.text=_ISPRINTF("x{1:d}<r> {2:d}P",curnumber,curnumber*itemprice)
              else
                numwindow.text=_ISPRINTF("x{1:d}<r>$ {2:d}",curnumber,curnumber*itemprice)
              end
            elsif Input.repeat?(Input::RIGHT)
              pbPlayCursorSE()
              curnumber+=10
              curnumber=maximum if curnumber>maximum
              if @bpmode
                numwindow.text=_ISPRINTF("x{1:d}<r> {2:d}P",curnumber,curnumber*itemprice)
              else
                numwindow.text=_ISPRINTF("x{1:d}<r>$ {2:d}",curnumber,curnumber*itemprice)
              end
            elsif Input.repeat?(Input::UP)
              pbPlayCursorSE()
              curnumber+=1
              curnumber=1 if curnumber>maximum
              if @bpmode
                numwindow.text=_ISPRINTF("x{1:d}<r> {2:d}P",curnumber,curnumber*itemprice)
              else
                numwindow.text=_ISPRINTF("x{1:d}<r>$ {2:d}",curnumber,curnumber*itemprice)
              end
            elsif Input.repeat?(Input::DOWN)
              pbPlayCursorSE()
              curnumber-=1
              curnumber=maximum if curnumber<1
              if @bpmode
                numwindow.text=_ISPRINTF("x{1:d}<r> {2:d}P",curnumber,curnumber*itemprice)
              else
                numwindow.text=_ISPRINTF("x{1:d}<r>$ {2:d}",curnumber,curnumber*itemprice)
              end
            elsif Input.trigger?(Input::C)
              pbPlayDecisionSE()
              ret=curnumber
              break
            elsif Input.trigger?(Input::B)
              pbPlayCancelSE()
              ret=0
              break
            end     
          end
       }
    }
    helpwindow.visible=false
    return ret
  end

  def pbPrepareWindow(window)
    window.visible=true
    window.letterbyletter=false
  end

  def pbStartBuyOrSellScene(buying,stock,adapter,bpmode=false)
    # Scroll right before showing screen
    pbScrollMap(6,5,5)
    @bpmode = bpmode
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
		@view=Viewport.new(0,0,Graphics.width,Graphics.height)
    @view.z=99998
    @stock=stock
    @adapter=adapter
    @sprites={}
    @sprites["bg"]=EAMSprite.new(@view)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Pictures/marketnew")
    @sprites["marketarrows"]=EAMSprite.new(@view)
    @sprites["marketarrows"].bitmap = pbBitmap("Graphics/Pictures/Marketarrows")
    
    @sprites["overlay"]=BitmapSprite.new(512,384,@view)
		@sprites["overlay"].bitmap.font = SUMMARYITEMFONT
		@sprites["overlay"].bitmap.font.size = $MKXP ? 22 : 24
		@sprites["itemoverlay"]=BitmapSprite.new(512,384,@view)
		@sprites["itemoverlay"].bitmap.font = SUMMARYITEMFONT
		@sprites["itemoverlay"].bitmap.font.size = $MKXP ? 22 : 24
    @viewitem=Viewport.new(270,26,218,326)
    @viewitem.z=@view.z
    
    @itemkeys=[]
		pbDrawItems
    #==========OLD
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    #@sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    @sprites["icon"]=IconSprite.new(12,Graphics.height-74,@viewport)
		@sprites["icon"].visible = false
    winAdapter=buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"]=Window_PokemonMart.new(stock,winAdapter,
       Graphics.width-316-16,12,330+16,Graphics.height-126,nil,bpmode)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].index=0
		@sprites["itemwindow"].visible=false
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.new("")
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].x=64
    @sprites["itemtextwindow"].y=Graphics.height-96-16
    @sprites["itemtextwindow"].width=Graphics.width-64
    @sprites["itemtextwindow"].height=128
    @sprites["itemtextwindow"].baseColor=Color.new(248,248,248)
    @sprites["itemtextwindow"].shadowColor=Color.new(0,0,0)
    @sprites["itemtextwindow"].visible=false
    @sprites["itemtextwindow"].viewport=@viewport
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    @sprites["moneywindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible=false
	  @sprites["moneywindow"].viewport=@viewport
    @sprites["moneywindow"].x=0
    @sprites["moneywindow"].y=0
    @sprites["moneywindow"].width=190
    @sprites["moneywindow"].height=96
    @sprites["moneywindow"].baseColor=Color.new(88,88,80)
    @sprites["moneywindow"].shadowColor=Color.new(168,184,184)
    pbDeactivateWindows(@sprites)
    @buying=buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbDrawItems
    for k in @itemkeys
      @sprites[k].dispose if @sprites[k]
    end
    @itemkeys=[]
    for item in @stock
			@itemkeys.push("it#{item}")
			i = @stock.index(item)
			filename=pbItemIconFile(item)
			@sprites["it#{item}"]=EAMSprite.new(@viewitem)
			@sprites["it#{item}"].bitmap = Bitmap.new(48,48)
			@sprites["it#{item}"].bitmap.blt(0,0,pbBitmap(filename),Rect.new(0,0,48,48))
			bmp = Bitmap.new(48,48)
			bmp.font = BAGITEMFONT
			price = @bpmode ? @adapter.getBattlePrice(item) : @adapter.getPrice(item)
			qty= @bpmode == false ? _ISPRINTF("${1:2d}",price) : _ISPRINTF("{1:2d}P",price)
			pbDrawTextPositions(bmp,[[qty,48-2,48-bmp.font.size-2,1,Color.new(248,248,248),Color.new(24,24,24),true]])
			@sprites["it#{item}"].bitmap.blt(0,0,bmp,Rect.new(0,0,48,48))
			@sprites["it#{item}"].x = 0 + 54*(i%4)
			@sprites["it#{item}"].y = 0 + 54*(i/4)
		end
  end
  
  def scrollIcons(index)
    if @sprites["it#{@stock[index]}"].y>=54*6
      for item in @stock
        i = @stock.index(item)
        ypos = 54*(i/4)-54*((index/4)-5)
        @sprites["it#{item}"].move(@sprites["it#{item}"].x,ypos,4,:ease_out_cubic)
      end
    elsif @sprites["it#{@stock[index]}"].y<0
      for item in @stock
        i = @stock.index(item)
        ypos = 54*(i/4)-54*((index/4))
        @sprites["it#{item}"].move(@sprites["it#{item}"].x,ypos,4,:ease_out_cubic)
      end
    end
  end
  
	def setSelected(index)
		for k in @itemkeys
			@sprites[k].fade(125,6,:ease_out_cubic) if k!= @itemkeys[index]
			@sprites[k].fade(255,6,:ease_out_cubic) if k== @itemkeys[index]
		end
	end
	
  def pbStartBuyScene(stock,adapter,bpmode=false)
    pbStartBuyOrSellScene(true,stock,adapter,bpmode)
  end
  
  def pbStartSellScene(bag,adapter)
    if $PokemonBag
      pbStartSellScene2(bag,adapter)
    else
      pbStartBuyOrSellScene(false,bag,adapter)
    end
  end
  
  def pbStartSellScene2(bag,adapter)
    @subscene=NewBagScreen.new#PokemonBag_Scene.new
    @adapter=adapter
    @viewport2=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z=99999
    for j in 0..17
      col=Color.new(0,0,0,j*15)
      @viewport2.color=col
      Graphics.update
      Input.update
    end
    @subscene.pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    @sprites["moneywindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible=false
    @sprites["moneywindow"].viewport=@viewport
    @sprites["moneywindow"].x=0
    @sprites["moneywindow"].y=0
    @sprites["moneywindow"].width=186
    @sprites["moneywindow"].height=96
    @sprites["moneywindow"].baseColor=Color.new(88,88,80)
    @sprites["moneywindow"].shadowColor=Color.new(168,184,184)
    pbDeactivateWindows(@sprites)
    @buying=false
    pbRefresh
  end

  def pbShowMoney
    pbRefresh
    @sprites["moneywindow"].visible=false#true
  end

  def pbHideMoney
    pbRefresh
    @sprites["moneywindow"].visible=false
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
		@view.dispose
		@viewitem.dispose
    # Scroll left after showing screen
    pbScrollMap(4,5,5)
  end
	
	def drawMoney
		@sprites["overlay"].bitmap.clear
		textpos=[]
		textpos.push([(@bpmode ? _INTL("Points") : _INTL("Money")),24,16,0,Color.new(48,48,48)])
		textpos.push([(@bpmode ? $Trainer.battle_points.to_s : "$"+$Trainer.money.to_s),225,16,1,Color.new(48,48,48)])
		pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
	end
	
	def drawItemInfo(index)
		@sprites["itemoverlay"].bitmap.clear
		@sprites["itemoverlay"].bitmap.font.size = $MKXP ? 22 : 24
		@sprites["itemoverlay"].bitmap.font.bold = true
		textpos=[]
		name = PBItems.getName(@stock[index])
		if pbIsMachine?(@stock[index])
			machine=$ItemData[@stock[index]][ITEMMACHINE]
			name+=" " + PBMoves.getName(machine)
		end
		textpos.push([name,15,238,0,Color.new(248,248,248)])
		pbDrawTextPositions(@sprites["itemoverlay"].bitmap,textpos)
		@sprites["itemoverlay"].bitmap.font.bold = false
		@sprites["itemoverlay"].bitmap.font.size = $MKXP ? 18 : 20
		if defined?(NewBagScreen.drawTextExH)
			NewBagScreen.drawTextExH(@sprites["itemoverlay"].bitmap,15,266,225,5,
				pbGetMessage(MessageTypes::ItemDescriptions,@stock[index]),Color.new(48,48,48),Color.new(0,0,0,0),21)
		end
	end
	
  def pbEndSellScene
    if @subscene
      @subscene.pbEndScene
    end
    pbDisposeSpriteHash(@sprites)
    if @viewport2
      for j in 0..17
        col=Color.new(0,0,0,(17-j)*15)
        @viewport2.color=col
        Graphics.update
        Input.update
      end
      @viewport2.dispose
    end
    @viewport.dispose
    if !@subscene
      pbScrollMap(4,5,5)
    end
  end

  def pbDisplay(msg,brief=false)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if brief && !cw.busy?
        return
      end
      if i==0 && !cw.busy?
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.busy?
        cw.resume
      end
      if i==60
        return
      end
      i+=1 if !cw.busy?
    end
  end

  def pbDisplayPaused(msg)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      wasbusy=cw.busy?
      self.update
      if !cw.busy? && wasbusy
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.resume && !cw.busy?
        @sprites["helpwindow"].visible=false
        return
      end
    end
  end

  def pbConfirm(msg)
    dw=@sprites["helpwindow"]
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("Yes"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=@viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    pbPlayDecisionSE()
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return false
      end
      if Input.trigger?(Input::C) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return (cw.index==0)?true:false
      end
    end
  end

  def pbRefresh
    if !@subscene
      itemwindow=@sprites["itemwindow"]
      filename=@adapter.getItemIcon(itemwindow.item)
      @sprites["icon"].setBitmap(filename)
      @sprites["icon"].src_rect=@adapter.getItemIconRect(itemwindow.item)   
      @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Quit shopping.") :
         @adapter.getDescription(itemwindow.item)
      itemwindow.refresh
    end
    @subscene.pbRefresh if @subscene != nil
    @sprites["moneywindow"].text=@bpmode ? _INTL("Points:\n<r>${1}",$Trainer.battle_points) : _INTL("Money:\n<r>${1}",@adapter.getMoney())
  end

  def pbChooseBuyItem
		index = 0
		maxindex = @stock.length-1
		setSelected(index)
		drawItemInfo(index)
		drawMoney
		loop do
			Graphics.update
			Input.update
			update
      if index/4==0
				@sprites["marketarrows"].src_rect=Rect.new(0,192,512,192)  #only lower arrow
				@sprites["marketarrows"].y = 192
			elsif index/4==maxindex/4
				@sprites["marketarrows"].src_rect=Rect.new(0,0,512,192)  #only upper arrow
				@sprites["marketarrows"].y = 0
			else
				@sprites["marketarrows"].src_rect=Rect.new(0,0,512,384)  #both arrows
				@sprites["marketarrows"].y = 0
			end
      
			if Input.trigger?(Input::UP)
				index=index-4<0 ? index : index-4
				setSelected(index)
				drawItemInfo(index)
        scrollIcons(index)
			end
			if Input.trigger?(Input::DOWN)
				index=index+4>maxindex ? index : index+4
				setSelected(index)
				drawItemInfo(index)
        scrollIcons(index)
			end
			
			if Input.trigger?(Input::LEFT)
				index=index-1<0 ? index : index-1
				setSelected(index)
				drawItemInfo(index)
        scrollIcons(index)
			end
			if Input.trigger?(Input::RIGHT)
				index=index+1>maxindex ? index : index+1
				setSelected(index)
				drawItemInfo(index)
        scrollIcons(index)
			end
			
			if Input.trigger?(Input::C)
				return @stock[index]
			end
			if Input.trigger?(Input::B)
				return 0
			end
		end
  end

  def pbChooseSellItem
    if @subscene
      return @subscene.pbChooseItem
    else
      return pbChooseBuyItem
    end
  end
end


class PokemonMartScreen
  def pbBuyScreen
    if @stock.length==0 
      Kernel.pbMessage(_INTL("Siamo spiacenti, non abbiamo più scorte in magazzino."))
      return
    end
    @scene.pbStartBuyScene(@stock,@adapter,@bpmode)
    item=0
    loop do
      item=@scene.pbChooseBuyItem
      quantity=0
      break if item==0
      itemname=@adapter.getDisplayName(item)
      if (!@bpmode)
        price=@adapter.getPrice(item)
        if @adapter.getMoney()<price
          pbDisplayPaused(_INTL("You don't have enough money."))
          next
        end
        if pbIsImportantItem?(item)
          if !pbConfirm(_INTL("Certainly.  You want {1}.\r\nThat will be ${2}.  OK?",itemname,price))
            next
          end
          quantity=1
        else
          maxafford=(price<=0) ? BAGMAXPERSLOT : @adapter.getMoney()/price
          maxafford=BAGMAXPERSLOT if maxafford>BAGMAXPERSLOT
          quantity=@scene.pbChooseNumber(
            _INTL("{1}?  Certainly.\r\nHow many would you like?",itemname),item,maxafford)
          if quantity==0
            next
          end
          price*=quantity
          if !pbConfirm(_INTL("{1}, and you want {2}.\r\nThat will be ${3}.  OK?",itemname,quantity,price))
            next
          end
        end
        if @adapter.getMoney()<price
          pbDisplayPaused(_INTL("You don't have enough money."))
          next
        end
        added=0
        quantity.times do
          if !@adapter.addItem(item)
            break
          end
          added+=1
        end
        if added!=quantity
          added.times do
            if !@adapter.removeItem(item)
              raise _INTL("Failed to delete stored items")
            end
          end
          pbDisplayPaused(_INTL("You have no more room in the Bag."))  
        else
          @adapter.setMoney(@adapter.getMoney()-price)
          for i in 0...@stock.length
            if pbIsImportantItem?(@stock[i]) && $PokemonBag.pbQuantity(@stock[i])>0
              @stock[i]=nil
            end
          end
          @stock.compact!
          pbDisplayPaused(_INTL("Here you are!\r\nThank you!"))
          if @stock.length==0 
            break
          end
          #update scene with new stock
          @scene.pbDrawItems
          if $PokemonBag
            if quantity>=10 && isConst?(item,PBItems,:POKEBALL) && 
              hasConst?(PBItems,:PREMIERBALL)
              if @adapter.addItem(getConst(PBItems,:PREMIERBALL))
                pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too.")) 
              end
            end
          end
        end
      else # Buying with Battle Points
        price=@adapter.getBattlePrice(item)
        if $Trainer.battle_points<price
          pbDisplayPaused(_INTL("You don't have enough points."))
          next
        end
        if pbIsImportantItem?(item)
          if !pbConfirm(_INTL("Certainly.  You want {1}.\r\nThat will be {2}BP.  OK?",itemname,price))
            next
          end
          quantity=1
        else
          maxafford=(price<=0) ? BAGMAXPERSLOT : $Trainer.battle_points/price
          maxafford=BAGMAXPERSLOT if maxafford>BAGMAXPERSLOT
          quantity=@scene.pbChooseNumber(
            _INTL("{1}?  Certainly.\r\nHow many would you like?",itemname),item,maxafford)
          if quantity==0
            next
          end
          price*=quantity
          if !pbConfirm(_INTL("{1}, and you want {2}.\r\nThat will be {3}BP.  OK?",itemname,quantity,price))
            next
          end
        end
        if $Trainer.battle_points<price
          pbDisplayPaused(_INTL("You don't have enough points."))
          next
        end
        added=0
        quantity.times do
          if !@adapter.addItem(item)
            break
          end
          added+=1
        end
        if added!=quantity
          added.times do
            if !@adapter.removeItem(item)
              raise _INTL("Failed to delete stored items")
            end
          end
          pbDisplayPaused(_INTL("You have no more room in the Bag."))  
        else
          $Trainer.battle_points-=price
          for i in 0...@stock.length
            if pbIsImportantItem?(@stock[i]) && $PokemonBag.pbQuantity(@stock[i])>0
              @stock[i]=nil
            end
          end
          @stock.compact!
          pbDisplayPaused(_INTL("Here you are!\r\nThank you!"))
          if @stock.length==0 
            break
          end
          #update scene with new stock
          @scene.pbDrawItems
          if $PokemonBag
            if quantity>=10 && isConst?(item,PBItems,:POKEBALL) && 
              hasConst?(PBItems,:PREMIERBALL)
              if @adapter.addItem(getConst(PBItems,:PREMIERBALL))
                pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too.")) 
              end
            end
          end
        end
      end
    end
    @scene.pbEndBuyScene
  end
end