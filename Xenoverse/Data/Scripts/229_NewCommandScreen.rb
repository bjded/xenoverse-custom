class CommandScreen
	
	def initialize()
		
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		
		@path = "Graphics/Pictures/NewCmd/"
		
		@sprites={}
		
		@sprites["bg"] = EAMSprite.new(@viewport)
		@sprites["bg"].bitmap = pbBitmap(@path + "bg")
		
		@sprites["page1"] = EAMSprite.new(@viewport)
		@sprites["page1"].bitmap = pbBitmap(@path + "page1")
		@sprites["page1"].src_rect=Rect.new(0,0,512,340)# if !$Trainer.pokewes
		@sprites["page1"].bitmap.font = Font.new
		@sprites["page1"].bitmap.font.name = "Barlow Condensed"
		@sprites["page1"].bitmap.font.size = $MKXP ? 22 : 24
		
		textpos = []
		textpos.push([_INTL("Move / Navigate"),360,67,2,Color.new(248,248,248)])
		textpos.push([_INTL("Interact / Confirm"),360,122,2,Color.new(248,248,248)])
		textpos.push([_INTL("Cancel / Close / Menù"),360,174,2,Color.new(248,248,248)])
		textpos.push([_INTL("Hold to Run"),360,225,2,Color.new(248,248,248)])
		textpos.push([_INTL("Registered Item"),360,276,2,Color.new(248,248,248)])
		
		pbDrawTextPositions(@sprites["page1"].bitmap,textpos)
		
		if $Trainer.pokewes
			@sprites["page2"] = EAMSprite.new(@viewport)
			@sprites["page2"].bitmap = pbBitmap(@path + "page2")
			@sprites["page2"].src_rect = Rect.new(0,0,512,340)
			@sprites["page2"].x = 512
			@sprites["page2"].bitmap.font = @sprites["page1"].bitmap.font
			
			textpos = []
			textpos.push([_INTL("Open MN Function"),360,84,2,Color.new(248,248,248)])
			textpos.push([_INTL("Open Achievement list"),360,140,2,Color.new(248,248,248)])
			textpos.push([_INTL("Open Pokédex"),360,194,2,Color.new(248,248,248)])
			textpos.push([_INTL("Open Region Map"),360,245,2,Color.new(248,248,248)])
			
			pbDrawTextPositions(@sprites["page2"].bitmap,textpos)
		end
		@page = 0
		@sprites["curpage"] = EAMSprite.new(@viewport)
		@sprites["curpage"].bitmap = Bitmap.new(512,44)
		@sprites["curpage"].bitmap.blt(0,0,pbBitmap(@path + "page1"),Rect.new(0,340,512,44)) if $Trainer.pokewes
		@sprites["curpage"].y = 340
		pbFadeInAndShow(@sprites)
		loop do
			Graphics.update
			Input.update
			@sprites.values.each {|s| s.update}
			if $Trainer.pokewes
				if Input.trigger?(Input::RIGHT) && @page==0
					@page = 1
					@sprites["page1"].move(-512,0,14,:ease_out_cubic)
					@sprites["page2"].move(0,0,14,:ease_out_cubic)
					@sprites["curpage"].bitmap.clear
					@sprites["curpage"].bitmap.blt(0,0,pbBitmap(@path + "page2"),Rect.new(0,340,512,44)) if $Trainer.pokewes
				elsif Input.trigger?(Input::LEFT) && @page==1
					@page = 0
					@sprites["page1"].move(0,0,14,:ease_out_cubic)
					@sprites["page2"].move(512,0,14,:ease_out_cubic)
					@sprites["curpage"].bitmap.clear
					@sprites["curpage"].bitmap.blt(0,0,pbBitmap(@path + "page1"),Rect.new(0,340,512,44)) if $Trainer.pokewes
				end
			end
			
			if Input.trigger?(Input::B)
				break
			end
		end
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
	
end