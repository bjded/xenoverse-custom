BAGITEMFONT = Font.new
BAGITEMFONT.name = [$MKXP ? "Kimberley" : "Kimberley Bl","Verdana"]
BAGITEMFONT.size = $MKXP ? 16 : 18
class NewBagScreen
	
	def pbStartScene(bag)
		@bag = bag
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@path = "Graphics/Pictures/BagNew/"
		@curPocket = @bag.pockets[@bag.lastpocket]
		@index = @bag.getChoice(@bag.lastpocket)>=@curPocket.length ? 0 : @bag.getChoice(@bag.lastpocket)
		#Defines the item icons rect
		@itemRect = Rect.new(228,70,234,1000)
		@viewport2 = Viewport.new(itemRect.x,itemRect.y,itemRect.width,itemRect.height)
		@viewport2.z = @viewport.z
		@viewport2_1 = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport2_1.z = @viewport2.z
		
		@pocketOrder = [1,2,6,4,0,3,7]
		@pocketNames = [_INTL("MEDICINES"),_INTL("POKEBALL"),_INTL("BT ITEMS"),
			_INTL("BERRIES"),_INTL("ITEMS"),_INTL("MACHINES"),_INTL("KEY ITEMS")]
		
		@curPocketIndex = @pocketOrder.index(@bag.lastpocket-1)
		
		@switching = false
		@swid = -1
		
		@icons={}
		
		@sprites={}
		@sprites["bg"] = Sprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(@path + "bg")
		@sprites["overbg"] = Sprite.new(@viewport)
		@sprites["overbg"].bitmap = pbBitmap(@path + "bagui")
		
		@sprites["pocketname"] = Sprite.new(@viewport)
		@sprites["pocketname"].bitmap = Bitmap.new(216,53)
		@sprites["pocketname"].y = 47
		@sprites["pocketname"].bitmap.font = BAGITEMFONT
		@sprites["pocketname"].bitmap.font.size = $MKXP ? 22 : 24
		pbDrawTextPositions(@sprites["pocketname"].bitmap,[[@pocketNames[@curPocketIndex],14,10,0,Color.new(24,24,24,100)]])
		
		@sprites["barbg"]=Sprite.new(@viewport)
		@sprites["barbg"].bitmap = pbBitmap(@path+"topbanner")
		
		@sprites["gradient"]=Sprite.new(@viewport2_1)
		@sprites["gradient"].bitmap = pbBitmap(@path + "gradient")
		@sprites["gradient"].z = 8
		
		@sprites["bar"]=Sprite.new(@viewport2_1)
		@sprites["bar"].bitmap = pbBitmap(@path+"#{@curPocketIndex}_items")
		@sprites["bar"].z = 10
		
		@sprites["lowerbar"]=Sprite.new(@viewport2_1)
		@sprites["lowerbar"].bitmap = pbBitmap(@path+"Lowerbar")
		@sprites["lowerbar"].y = 343
		@sprites["lowerbar"].bitmap.font = SUMMARYITEMFONT
		@sprites["lowerbar"].bitmap.font.size = $MKXP ? 24 : 26
		@sprites["lowerbar"].bitmap.font.bold = true
		@sprites["lowerbar"].z = 10
		
		@sprites["info"]=Sprite.new(@viewport)
		@sprites["info"].bitmap = Bitmap.new(512,384)
		@sprites["info"].bitmap.font = SUMMARYITEMFONT
		@sprites["info"].bitmap.font.size = $MKXP ? 18 :  22
		@sprites["info"].z = 10
		
		drawItemInfo if @curPocket.length>0
		
		pbDrawTextPositions(@sprites["lowerbar"].bitmap,[
				[_INTL("Order"),102,3,1,Color.new(248,248,248)],
				[_INTL("Sort"),252,3,1,Color.new(248,248,248)],
				[_INTL("Close"),465,3,1,Color.new(248,248,248)]])
		drawItems
	end
	
	def itemRect
		return @itemRect
	end
	
	def update
		for i in @icons.values
			i.update
		end
	end
	
	def drawItems
		pbDisposeSpriteHash(@icons)
		#echoln @curPocket
		for i in 0...@curPocket.length
			#next if i<@index - (3*4)
			#break if (i/4) > 6+(@index/4)
			filename=pbItemIconFile(@curPocket[i][0])
			@icons["i#{i}"]=EAMSprite.new(@viewport2)
			@icons["i#{i}"].bitmap = Bitmap.new(48,48)
			@icons["i#{i}"].bitmap.blt(0,0,pbBitmap(filename),Rect.new(0,0,48,48))
			bmp = Bitmap.new(48,48)
			bmp.font = BAGITEMFONT
			qty=_ISPRINTF("x{1:2d}",@curPocket[i][1])
			pbDrawTextPositions(bmp,[[qty,48-2,48-bmp.font.size-2,1,Color.new(248,248,248),Color.new(24,24,24),true]])
			@icons["i#{i}"].bitmap.blt(0,0,bmp,Rect.new(0,0,48,48))
			@icons["i#{i}"].bitmap.blt(48-25,0,pbBitmap(@path + "reg"),Rect.new(0,0,25,25)) if @bag.registeredItem==@curPocket[i][0]
			
			@icons["i#{i}"].ox = 24
			@icons["i#{i}"].oy = 24
			@icons["i#{i}"].x = 58*(i%4) + 24 #@itemRect.x + 50*(i%5)
			@icons["i#{i}"].y = 58*(i/4) + 24 #@itemRect.y + 50*(i/5)
			#@icons["i#{i}"].setZoomPoint(24,24)
			#@icons["i#{i}"].zoom(0.75,0.75,10,:ease_out_cubic)
			@icons["i#{i}"].color = Color.new(0,0,0,150)
		end
		
	end
	
	def drawItem(itemIndex)
		filename=pbItemIconFile(@curPocket[itemIndex][0])
		@icons["i#{itemIndex}"].bitmap.clear
		@icons["i#{itemIndex}"].bitmap.blt(0,0,pbBitmap(filename),Rect.new(0,0,48,48))
		bmp = Bitmap.new(48,48)
		bmp.font = BAGITEMFONT
		qty=_ISPRINTF("x{1:2d}",@curPocket[itemIndex][1])
		pbDrawTextPositions(bmp,[[qty,48-2,48-bmp.font.size-2,1,Color.new(248,248,248),Color.new(24,24,24),true]])
		@icons["i#{itemIndex}"].bitmap.blt(0,0,bmp,Rect.new(0,0,48,48))
		@icons["i#{itemIndex}"].bitmap.blt(48-25,0,pbBitmap(@path + "reg"),Rect.new(0,0,25,25)) if @bag.registeredItem==@curPocket[itemIndex][0]
		
		@icons["i#{itemIndex}"].ox = 24
		@icons["i#{itemIndex}"].oy = 24
		@icons["i#{itemIndex}"].x = 58*(itemIndex%4) + 24 
		@icons["i#{itemIndex}"].y = 58*(itemIndex/4) + 24 
		@icons["i#{itemIndex}"].color = Color.new(0,0,0,150)
	end
	
	
	def drawItemInfo
		@sprites["info"].bitmap.clear
		echoln @index
		echoln @curPocket
		item = @curPocket[@index][0] #the ID of the item
		@sprites["info"].bitmap.font.bold = true
		name = PBItems.getName(item)
		if pbIsMachine?(item)
			machine=$ItemData[item][ITEMMACHINE]
			name+=" " + PBMoves.getName(machine)
		end
		pbDrawTextPositions(@sprites["info"].bitmap,[[name,16,198,0,Color.new(248,248,248)]])
		
		@sprites["info"].bitmap.font.bold = false
		if defined?(drawTextExH)
			drawTextExH(@sprites["info"].bitmap,16,224,188,5,
				pbGetMessage(MessageTypes::ItemDescriptions,item),Color.new(48,48,48),Color.new(0,0,0,0),21)
		end
		
	end
	
	def pbDisplay(text)
		@viewport3 = Viewport.new(0,0,512,384)
		@viewport3.z = @viewport2.z+1
		@s={}
		
		@s["box"] = EAMSprite.new(@viewport3)
		@s["box"].z = 100
		@s["box"].bitmap = pbBitmap(@path + "SelectBox").clone
		@s["box"].bitmap.font = SUMMARYITEMFONT
		@s["box"].bitmap.font.size = $MKXP ? 22 : 24
		drawTextExH(@s["box"].bitmap,45,314,434,2,text,Color.new(24,24,24),Color.new(24,24,24,0),22)
		@s["box"].opacity = 0
		@s["box"].fade(255,10)
		loop do
			Graphics.update
			Input.update
			@s["box"].update
			if Input.trigger?(Input::C) || Input.trigger?(Input::B)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				break
			end
		end
	end
	
	def pbConfirm(text)
		@viewport3 = Viewport.new(0,0,512,384)
		@viewport3.z = @viewport2.z+1
		@s={}
		
		anchor = 496
		
		@s["box"] = EAMSprite.new(@viewport3)
		@s["box"].z = 100
		@s["box"].bitmap = pbBitmap(@path + "SelectBox").clone
		@s["box"].bitmap.font = SUMMARYITEMFONT
		@s["box"].bitmap.font.size = $MKXP ? 22 : 24
		
		drawTextExH(@s["box"].bitmap,45,314,434,2,text,Color.new(24,24,24),Color.new(24,24,24,0),22)
		@s["box"].opacity = 0
		b = pbBitmap(@path + "scoption")
		bmp = Bitmap.new(88,38)
		bmp.blt(0,0,b,Rect.new(0,0,22,38))
		bmp.blt(22,0,b,Rect.new(22,0,44,38))
		bmp.blt(88-22,0,b,Rect.new(148-22,0,22,38))
		bmp.font = SUMMARYITEMFONT
		bmp.font.size = $MKXP ? 24 : 26
		@s["yes"] = EAMSprite.new(@viewport3)
		@s["yes"].bitmap = bmp.clone
		@s["yes"].ox = @s["yes"].bitmap.width
		@s["yes"].x = anchor
		@s["yes"].y = 266-40
		@s["yes"].z = 102
		@s["yes"].opacity = 0
		@s["no"] = EAMSprite.new(@viewport3)
		@s["no"].bitmap = bmp.clone
		@s["no"].ox = @s["no"].bitmap.width
		@s["no"].x = anchor
		@s["no"].y = 266
		@s["no"].z = 102
		@s["no"].opacity = 0
		
		
		
		pbDrawTextPositions(@s["yes"].bitmap,[[_INTL("Yes"),44,5,2,Color.new(24,24,24)]])
		pbDrawTextPositions(@s["no"].bitmap,[[_INTL("No"),44,5,2,Color.new(24,24,24)]])
		id = true
		
		@s["box"].fade(255,10)
		@s["yes"].fade(255,10)
		@s["no"].fade(175,10)
		
		loop do
			Graphics.update
			Input.update
			@s.values.each{|s| s.update}
			@s["yes"].move(anchor,226,7,:ease_out_cubic) if @s["yes"].y<=216
			@s["no"].move(anchor,266,7,:ease_out_cubic) if @s["no"].y<=256
			if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
				id = !id
				if id==true
					@s["yes"].fade(255,10)
					@s["no"].fade(175,10)
					@s["yes"].move(anchor,216,3,:ease_out_cubic)
				else
					@s["yes"].fade(175,10)
					@s["no"].fade(255,10)
					@s["no"].move(anchor,256,3,:ease_out_cubic)
				end
			end
			
			if Input.trigger?(Input::C)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return id
			end
			
			if Input.trigger?(Input::B)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return false
			end
		end
	end
	
	def updateIconPosition
		if @icons["i#{@index}"].y>=250 || @icons["i#{@index}"].y < 0
			for i in 0...@icons.length
				#if @icons["i#{i}"]
				icon = @icons["i#{i}"]
				yval = 24 + 58 * (i/4)
				#Scroll to a point where s#{@dexlist[@selIndex]} is visible
				yval -= (@icons["i#{@index}"].y<0) ? (58*(@index/4)) : ((@icons["i#{@index}"].y>250) ? 58*(@index/4-3) : 0) 
				icon.move(icon.x,yval,14,:ease_out_quad)
				#end
			end
			#drawItems
		end
	end
	
	def updatePocket(p)
		echoln @pocketOrder[p]+1
		@curPocket = @bag.pockets[@pocketOrder[p]+1]
		@index = @bag.getChoice(@pocketOrder[p]+1)>=@curPocket.length ? 0 : @bag.getChoice(@pocketOrder[p]+1)
		@sprites["bar"].bitmap = pbBitmap(@path+"#{p}_items")
		@sprites["pocketname"].bitmap.clear
		pbDrawTextPositions(@sprites["pocketname"].bitmap,[[@pocketNames[@curPocketIndex],14,10,0,Color.new(24,24,24,100)]])
		drawItems
		@sprites["info"].bitmap.clear
		return if @curPocket.length<=0
    @icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
		drawItemInfo 
	end
	
	def setPocket(p, pocket)
		@bag.pockets[@pocketOrder[p]+1] = pocket
		updatePocket(@curPocketIndex)
		updateIconPosition if @curPocket.length>0
	end

	def pbChangeSelection
		oldi = @index
		return if @curPocket.length<=1
		if Input.trigger?(Input::LEFT)
			@icons["i#{@index}"].color = Color.new(0,0,0,150) if @swid != @index
			@index = @index-1<0 ? @curPocket.length-1 : @index-1
			@icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
			updateIconPosition
		elsif Input.trigger?(Input::RIGHT)
			@icons["i#{@index}"].color = Color.new(0,0,0,150) if @swid != @index
			@index = @index+1 >= @curPocket.length ? 0 : @index+1
			@icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
			updateIconPosition
		elsif Input.trigger?(Input::DOWN)	
			@icons["i#{@index}"].color = Color.new(0,0,0,150) if @swid != @index
			@index = @index+4 >= @curPocket.length ? 0 + @index%4 : @index+4
			@icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
			updateIconPosition
		elsif Input.trigger?(Input::UP)
			@icons["i#{@index}"].color = Color.new(0,0,0,150) if @swid != @index
			@index = @index-4 < 0 ? @curPocket.length-1 : @index-4
			@icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
			updateIconPosition
		end
		@bag.setChoice(@pocketOrder[@curPocketIndex]+1,@index)
		@icons["i#{@index}"].color = Color.new(0,0,0,0) if @swid != @index
		drawItemInfo if oldi != @index
	end
	
	def pbChooseItem
		#@icons["i#{@index}"].zoom(1,1,10,:ease_out_cubic)
		@icons["i#{@index}"].color = Color.new(0,0,0,0) if @index<@curPocket.length
		updateIconPosition if @curPocket.length>0
		loop do
			Graphics.update
			Input.update
			update
			
			if (Input.trigger?(Input::L))
				@curPocketIndex = @curPocketIndex-1 < 0 ? 6 : @curPocketIndex-1
				updatePocket(@curPocketIndex)
				@switching = false if @switching
				updateIconPosition if @curPocket.length>0
			elsif (Input.trigger?(Input::R))
				@curPocketIndex = @curPocketIndex+1 >= 7 ? 0 : @curPocketIndex+1
				updatePocket(@curPocketIndex)
				@switching = false if @switching
				updateIconPosition if @curPocket.length>0
			end
=begin
			if Input.trigger?(Input::F5) && pbIsKeyItem?(@curPocket[@index][0])
				if @bag.registeredItem==@curPocket[@index][0] #deregister
					@bag.pbRegisterKeyItem(0)
					drawItem(@index)
				else #register
					@bag.pbRegisterKeyItem(@curPocket[@index][0])
					drawItem(@index)
				end
			end
=end
			if Input.trigger?(Input::A) && @curPocket.length>1
				if !@switching
					@switching = true
					@swid = @index
					@icons["i#{@swid}"].color = Color.new(255,160,40,50)
				else #cancel switching
					@switching = false
					@icons["i#{@swid}"].color = (@swid==@index ? Color.new(0,0,0,0) : Color.new(0,0,0,150))
					@swid=-1
				end
			end
			
			if Input.trigger?(Input::ALT) && @curPocket.length>1 && !@switching
				echoln @curPocket
				echoln @curPocket[@index]
				setPocket(@curPocketIndex, @curPocket.sort {|x,y| PBItems.getName(x[0])<=>PBItems.getName(y[0])})
				
			end

			if Input.trigger?(Input::C) && @curPocket.length>0
				if @switching
					@switching = false
					tmpitem = @curPocket[@swid]
					@curPocket[@swid] = @curPocket[@index]
					@curPocket[@index] = tmpitem
					tmpbmp = @icons["i#{@index}"].bitmap
					@icons["i#{@index}"].bitmap = @icons["i#{@swid}"].bitmap
					@icons["i#{@swid}"].bitmap = tmpbmp
					@icons["i#{@swid}"].color = (@swid==@index ? Color.new(0,0,0,0) : Color.new(0,0,0,150))
					@icons["i#{@index}"].color = Color.new(0,0,0,0)
					@swid=-1
					drawItemInfo
					#pbRefresh
				else
					return @curPocket[@index][0]#@bag.getChoice(@pocketOrder[@curPocketIndex]+1)
				end
			end
			
			if Input.trigger?(Input::B)
				break
			end
			
			pbChangeSelection
		end
		return 0
	end
	
	def pbEndScene
    @bag.lastpocket = @pocketOrder[@curPocketIndex]+1
		merged = @sprites.merge(@icons)
		pbFadeOutAndHide(merged){update}
		pbDisposeSpriteHash(merged)
		@viewport.dispose
		@viewport2.dispose
		@viewport2_1.dispose
		@viewport3.dispose if @viewport3
	end
	
	def cmdUpdate
		if @s
			for cmd in @s.values
				cmd.update
			end
		end
	end
	
	def fadeOut(s)
		if s
			for cmd in s.values
				cmd.fade(0,15) if defined?(cmd.fade)
			end
			15.times do
				for cmd in s.values
					cmd.update
				end
				Graphics.update
			end
		end
	end
	
	def pbRefresh
		drawItems
		@index = 0 if @curPocket[@index] == nil
		if @curPocket[@index] != nil
			drawItemInfo
		else
			@sprites["info"].bitmap.clear
		end
	end
	
	def pbChooseNumber(helptext,qty)
		@viewport3 = Viewport.new(0,0,512,384)
		@viewport3.z = @viewport2.z+1
		@s={}
		
		anchor = 496
		
		@s["box"] = EAMSprite.new(@viewport3)
		@s["box"].z = 1
		@s["box"].bitmap = pbBitmap(@path + "SelectBox").clone
		@s["box"].bitmap.font = SUMMARYITEMFONT
		@s["box"].bitmap.font.size = $MKXP ? 22 : 24
		
		drawTextExH(@s["box"].bitmap,45,314,434,2,helptext,Color.new(24,24,24),Color.new(24,24,24,0),22)
		maxqty = qty
		minqty = 0
		qt = 0
		bmp = pbBitmap(@path + "qtyoption")
		bmp.font = SUMMARYITEMFONT
		bmp.font.size = $MKXP ? 24 : 26
		@s["qtbg"] = EAMSprite.new(@viewport3)
		@s["qtbg"].bitmap = bmp.clone
		@s["qtbg"].ox = @s["qtbg"].bitmap.width
		@s["qtbg"].x = anchor
		@s["qtbg"].y = 266
		@s["qtbg"].z = 102
		pbDrawTextPositions(@s["qtbg"].bitmap,[["x"+sprintf("%03d",qt),130,5,1,Color.new(24,24,24)]])
		
		loop do
			Graphics.update
			Input.update
			@s.values.each {|s| s.update}
			@s["qtbg"].move(anchor,266,7,:ease_out_quad) if @s["qtbg"].y <= 256
			
			if Input.trigger?(Input::UP)
				qt = qt+1 > maxqty ? minqty : qt+1
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[["x"+sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::DOWN)
				qt = qt-1 < minqty ? maxqty : qt-1
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[["x"+sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::L)
				qt = qt-10 < minqty ? maxqty : qt-10
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[["x"+sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			elsif Input.trigger?(Input::R)
				qt = qt+10 > maxqty ? minqty : qt+10
				@s["qtbg"].move(anchor,256,3,:ease_out_quad)
				@s["qtbg"].bitmap = bmp.clone
				pbDrawTextPositions(@s["qtbg"].bitmap,[["x"+sprintf("%03d",qt),130,6,1,Color.new(24,24,24)]])
			end
			
			if Input.trigger?(Input::C)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return qt
			end
			if Input.trigger?(Input::B)
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				return 0
			end
		end
		
	end
	
	def pbShowCommands(helptext,commands)
		@viewport3 = Viewport.new(0,0,512,384)
		@viewport3.z = @viewport2.z+1
		
		@s = {}
		@s["dark"]=EAMSprite.new(@viewport3)
		@s["dark"].opacity = 0
		@s["dark"].bitmap = pbBitmap(@path+"scbg")
		@s["dark"].fade(160,10)
		@s["icon"]= EAMSprite.new(@viewport3)
		@s["icon"].zoom_x = 2
		@s["icon"].zoom_y = 2
		@s["icon"].opacity = 0
		@s["icon"].bitmap = pbBitmap(pbItemIconFile(@curPocket[@index][0]))
		@s["icon"].ox = 24
		@s["icon"].oy = 24
		@s["icon"].x = 124
		@s["icon"].y = 204
		@s["icon"].fade(255,10)
		@s["box"] = EAMSprite.new(@viewport3)
		@s["box"].z = 101
		@s["box"].bitmap = pbBitmap(@path + "SelectBox").clone
		@s["box"].bitmap.font = SUMMARYITEMFONT
		@s["box"].bitmap.font.size = $MKXP ? 22 : 24
		anchor = 496
		@cmdid = 0
		for cmd in 0...commands.length
			@s["#{cmd}"] = EAMSprite.new(@viewport3)
			@s["#{cmd}"].bitmap = pbBitmap(@path + "SCOption").clone
			@s["#{cmd}"].ox = @s["#{cmd}"].bitmap.width
			@s["#{cmd}"].x = anchor
			@s["#{cmd}"].y = 270 - 38*(commands.length-1) + 38*cmd
			@s["#{cmd}"].bitmap.font = SUMMARYITEMFONT
			@s["#{cmd}"].bitmap.font.size = $MKXP ? 22 : 24
			@s["#{cmd}"].z = 102
			pbDrawTextPositions(@s["#{cmd}"].bitmap,[[commands[cmd],74,6,2,Color.new(24,24,24)]])
			
			@s["#{cmd}"].fade(175,10) if cmd != @cmdid
		end
		drawTextExH(@s["box"].bitmap,45,314,434,2,helptext,Color.new(24,24,24),Color.new(24,24,24,0),22)
		
		loop do 
			Graphics.update
			Input.update
			cmdUpdate
			
			if Input.trigger?(Input::DOWN)
				@s["#{@cmdid}"].fade(175,10)
				@cmdid = @cmdid+1>=commands.length ? 0 : @cmdid+1
				@s["#{@cmdid}"].fade(255,10)
			elsif Input.trigger?(Input::UP)
				@s["#{@cmdid}"].fade(175,10)
				@cmdid = @cmdid-1<0 ? commands.length-1 : @cmdid-1
				@s["#{@cmdid}"].fade(255,10)
			end
			
			
			
			if Input.trigger?(Input::C)
				#pbFadeOutAndHide(@s){cmdUpdate}
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				
				@viewport3.dispose
				return @cmdid
			end
			if Input.trigger?(Input::B)
				#pbFadeOutAndHide(@s){cmdUpdate}
				fadeOut(@s)
				pbDisposeSpriteHash(@s)
				
				@viewport3.dispose
				return commands.length-1
			end
		end
		
		
	end
end

class PokemonBagScreen
	def initialize(scene,bag)
		@bag=bag
		if scene.is_a?(NewBagScreen)
			@scene=scene
		else
			@scene=NewBagScreen.new
		end
	end
	
	def pbDisplay(text)
		@scene.pbDisplay(text)
	end
	
	def pbConfirm(text)
		return @scene.pbConfirm(text)
	end
	
	# UI logic for the item screen when an item is to be held by a Pokémon.
	def pbGiveItemScreen
		@scene.pbStartScene(@bag)
		item=0
		loop do
			item=@scene.pbChooseItem
			break if item==0
			itemname=PBItems.getName(item)
			# Key items and hidden machines can't be held
			if pbIsImportantItem?(item)
				@scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
				next
			else
				break
			end
		end
		@scene.pbEndScene
		return item
	end
	
	# UI logic for the item screen for choosing an item
	def pbChooseItemScreen
		oldlastpocket=@bag.lastpocket
		@scene.pbStartScene(@bag)
		item=@scene.pbChooseItem
		@scene.pbEndScene
		@bag.lastpocket=oldlastpocket
		return item
	end
	
	# UI logic for the item screen for choosing a Berry
	def pbChooseBerryScreen
		oldlastpocket=@bag.lastpocket
		@bag.lastpocket=BERRYPOCKET
		@scene.pbStartScene(@bag)
		item=0
		loop do
			item=@scene.pbChooseItem
			break if item==0
			itemname=PBItems.getName(item)
			if !pbIsBerry?(item)
				@scene.pbDisplay(_INTL("That's not a Berry.",itemname))
				next
			else
				break
			end
		end
		@scene.pbEndScene
		@bag.lastpocket=oldlastpocket
		return item
	end
	
	# UI logic for tossing an item in the item screen.
	def pbTossItemScreen
		if !$PokemonGlobal.pcItemStorage
			$PokemonGlobal.pcItemStorage=PCItemStorage.new
		end
		storage=$PokemonGlobal.pcItemStorage
		@scene.pbStartScene(storage)
		loop do
			item=@scene.pbChooseItem
			break if item==0
			if pbIsImportantItem?(item)
				@scene.pbDisplay(_INTL("That's too important to toss out!"))
				next
			end
			qty=storage.pbQuantity(item)
			itemname=PBItems.getName(item)
			if qty>1
				qty=@scene.pbChooseNumber(_INTL("Toss out how many {1}(s)?",itemname),qty)
			end
			if qty>0
				if pbConfirm(_INTL("Is it OK to throw away {1} {2}(s)?",qty,itemname))
					if !storage.pbDeleteItem(item,qty)
						raise "Can't delete items from storage"
					end
					pbDisplay(_INTL("Threw away {1} {2}(s).",qty,itemname))
				end
			end
		end
		@scene.pbEndScene
	end
	
	# UI logic for withdrawing an item in the item screen.
	def pbWithdrawItemScreen
		if !$PokemonGlobal.pcItemStorage
			$PokemonGlobal.pcItemStorage=PCItemStorage.new
		end
		storage=$PokemonGlobal.pcItemStorage
		@scene.pbStartScene(storage)
		loop do
			item=@scene.pbChooseItem
			break if item==0
			commands=[_INTL("Withdraw"),_INTL("Give"),_INTL("Cancel")]
			itemname=PBItems.getName(item)
			command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
			if command==0
				qty=storage.pbQuantity(item)
				if qty>1
					qty=@scene.pbChooseNumber(_INTL("How many do you want to withdraw?"),qty)
				end
				if qty>0
					if !@bag.pbCanStore?(item,qty)
						pbDisplay(_INTL("There's no more room in the Bag."))
					else
						pbDisplay(_INTL("Withdrew {1} {2}(s).",qty,itemname))
						if !storage.pbDeleteItem(item,qty)
							raise "Can't delete items from storage"
						end
						if !@bag.pbStoreItem(item,qty)
							raise "Can't withdraw items from storage"
						end
					end
				end
			elsif command==1 # Give
				if $Trainer.pokemonCount==0
					@scene.pbDisplay(_INTL("There is no Pokémon."))
					return 0
				elsif pbIsImportantItem?(item)
					@scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
				else
					pbFadeOutIn(99999){
						sscene=PokemonScreen_Scene.new
						sscreen=PokemonScreen.new(sscene,$Trainer.party)
						if sscreen.pbPokemonGiveScreen(item)
							# If the item was held, delete the item from storage
							if !storage.pbDeleteItem(item,1)
								raise "Can't delete item from storage"
							end
						end
						@scene.pbRefresh
					}
				end
			end
		end
		@scene.pbEndScene
	end
	
	# UI logic for depositing an item in the item screen.
	def pbDepositItemScreen
		@scene.pbStartScene(@bag)
		if !$PokemonGlobal.pcItemStorage
			$PokemonGlobal.pcItemStorage=PCItemStorage.new
		end
		storage=$PokemonGlobal.pcItemStorage
		item=0
		loop do
			item=@scene.pbChooseItem
			break if item==0
			qty=@bag.pbQuantity(item)
			if qty>1
				qty=@scene.pbChooseNumber(_INTL("How many do you want to deposit?"),qty)
			end
			if qty>0
				itemname=PBItems.getName(item)
				if !storage.pbCanStore?(item,qty)
					pbDisplay(_INTL("There's no room to store items."))
				else
					pbDisplay(_INTL("Deposited {1} {2}(s).",qty,itemname))
					if !@bag.pbDeleteItem(item,qty)
						raise "Can't delete items from bag"
					end
					if !storage.pbStoreItem(item,qty)
						raise "Can't deposit items to storage"
					end
				end
			end
		end
		@scene.pbEndScene
	end
	
	def pbStartScreen
		@scene.pbStartScene(@bag)
		item=0
		loop do
			item=@scene.pbChooseItem
			break if item==0
			cmdUse=-1
			cmdRegister=-1
			cmdGive=-1
			cmdToss=-1
			cmdRead=-1
			cmdMysteryGift=-1
			commands=[]
			# Generate command list
			commands[cmdRead=commands.length]=_INTL("Read") if pbIsMail?(item)
			commands[cmdUse=commands.length]=_INTL("Use") if ItemHandlers.hasOutHandler(item) || (pbIsMachine?(item) && $Trainer.party.length>0)
			commands[cmdGive=commands.length]=_INTL("Give") if ($Trainer.party.length>0 && !pbIsImportantItem?(item)) && !$ISINTOURNAMENT
			commands[cmdToss=commands.length]=_INTL("Toss") if (!pbIsImportantItem?(item) && !isConst?(item,PBItems,:ANELLOT) && !isConst?(item,PBItems,:ANELLOX)) || $DEBUG
			if @bag.registeredItem==item
				commands[cmdRegister=commands.length]=_INTL("Deselect")
			elsif pbIsKeyItem?(item) && ItemHandlers.hasKeyItemHandler(item)
				commands[cmdRegister=commands.length]=_INTL("Register")
			end
			commands[cmdMysteryGift=commands.length]=_INTL("Make Mystery Gift") if $DEBUG
			commands[commands.length]=_INTL("Cancel")
			# Show commands generated above
			itemname=PBItems.getName(item) # Get item name
			command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
			if cmdUse>=0 && command==cmdUse # Use item
				ret=pbUseItem(@bag,item,@scene)
				# 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
				break if ret==2 # End screen
				@scene.pbRefresh
				next
			elsif cmdRead>=0 && command==cmdRead # Read mail
				pbFadeOutIn(9999){
					pbDisplayMail(PokemonMail.new(item,"",""))
				}
			elsif cmdRegister>=0 && command==cmdRegister # Register key item
				@bag.pbRegisterKeyItem(item)
				@scene.pbRefresh
			elsif cmdGive>=0 && command==cmdGive # Give item to Pokémon
				if $Trainer.pokemonCount==0
					@scene.pbDisplay(_INTL("There is no Pokémon."))
				elsif pbIsImportantItem?(item)
					@scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
				else
					# Give item to a Pokémon
					pbFadeOutIn(99999){
						sscene=PokemonScreen_Scene.new
						sscreen=PokemonScreen.new(sscene,$Trainer.party)
						sscreen.pbPokemonGiveScreen(item)
						@scene.pbRefresh
					}
				end
			elsif cmdToss>=0 && command==cmdToss # Toss item
				qty=@bag.pbQuantity(item)
				helptext=_INTL("Toss out how many {1}(s)?",itemname)
				qty=@scene.pbChooseNumber(helptext,qty)
				if qty>0
					if @scene.pbConfirm(_INTL("Is it OK to throw away {1} {2}(s)?",qty,itemname))
						@scene.pbDisplay(_INTL("Threw away {1} {2}(s).",qty,itemname))
						qty.times { @bag.pbDeleteItem(item) }      
					end
					@scene.pbRefresh
				end   
			elsif cmdMysteryGift>=0 && command==cmdMysteryGift   # Export to Mystery Gift
				pbCreateMysteryGift(1,item)
			end
		end
		@scene.pbEndScene
		return item
	end
end

################################################################################
#msgwindow fix
################################################################################
def Kernel.pbCreateMessageWindow(viewport=nil,skin=nil)
	msgwindow=Window_AdvancedTextPokemon.new("")
	if !viewport
		msgwindow.z=999999
	else
		msgwindow.viewport=viewport
	end
	msgwindow.visible=true
	msgwindow.letterbyletter=true
	msgwindow.back_opacity=MessageConfig::WindowOpacity
	pbBottomLeftLines(msgwindow,2)
	$game_temp.message_window_showing=true if $game_temp
	$game_message.visible=true if $game_message
	skin=MessageConfig.pbGetSpeechFrame() if !skin
	msgwindow.setSkin(skin)
	return msgwindow
end