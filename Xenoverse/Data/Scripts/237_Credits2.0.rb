CREDITS_SCROLLSPEED = 1
MAXCHARPERLINE = 50
CreditList = []
for i in 0..40
  CreditList[i]="credits#{i+1}"
end

if $DEBUG
  def draw_text_outline(credit_bitmap,xpos,ypos,linewidth,lineheight,line,basecolor,darkcolor,align = 1)
    #credit_bitmap.font.color = basecolor
    #credit_bitmap.draw_text(xpos,ypos + 8,linewidth,32,line[j],align)
    if darkcolor
      credit_bitmap.font.color = darkcolor
      credit_bitmap.draw_text(xpos + 2,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos+ 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos+ 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos+ 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos + 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos + 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos + 2,linewidth,lineheight,line,align)
    end
    credit_bitmap.font.color = basecolor
    credit_bitmap.draw_text(xpos,ypos,linewidth,lineheight,line,align)
  end

  def exportCredits
    
    @credits = File.open("PBS/credits.txt").read.split("\n")
    @creditsBitmap = Bitmap.new(512,(30*@credits.length))
    pbSetSystemFont(@creditsBitmap)
    @creditsBitmap.font.size = $MKXP ? 20 : 22
    Console::setup_console
    for i in 0...@credits.length
      Graphics.update
      line = @credits[i]
      if line.length>MAXCHARPERLINE
        @creditsBitmap.font.size = $MKXP ? 16 : 18
        #Drawing the shadow first, then the text on top
        #draw_text_outline(@creditsBitmap,0,8+30*i,512,30,line,@shadowColor,nil,1)
        #Drawing the shadow first, then the text on top
        draw_text_outline(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      else
        @creditsBitmap.font.size = $MKXP ? 20 : 22
        #Drawing the shadow first, then the text on top
        #pbDrawOutlineText(@creditsBitmap,0,8+30*i,512,30,line,@shadowColor,nil,1)
        #Drawing the shadow first, then the text on top
        pbDrawOutlineText(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      end
    end
    echoln "DRAWN BITMAP, EXPORTING..."
    @creditsBitmap.export("Credits")
    echoln "SUCCESSFULLY EXPORTED CREDITS"
  end
end

class Credits
  
  def initialize(strange = false, alternative = false)
    @random = false
    @frame = 0
    @bgframe = 0
    @fullduration = 14600
    @changebgtime =  @fullduration/41#600
    @fadebgtime = 40
    
    @strange = strange

    @thanksforplaying = true
    
    Console::setup_console if $DEBUG
    @credits = File.open("PBS/credits.txt").read.split("\n")
    #echoln credits if $DEBUG
    @viewport = Viewport.new(0,0,Graphics.width,384+30*@credits.length)
    @viewport.z = 9999999
    @viewport.tone = Tone.new(0,0,0,255)
    @sprites = {}
    
    @currentBG = 0
    
    @shadowColor = Color.new(28,28,28,60)
    
    @sprites["blackBG"] = Sprite.new(@viewport)
    @sprites["blackBG"].bitmap = Bitmap.new(512,384)
    @sprites["blackBG"].bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
    
    if @strange
      Kernel.pbSetPokemonCenterSpecific(389,25,16,2)
      @sprites["whites"] = EAMSprite.new(@viewport)
      @sprites["whites"].bitmap = Bitmap.new(512,384)
      @sprites["whites"].bitmap.fill_rect(0,0,512,384,Color.new(255,255,255))
      @sprites["whites"].opacity = 0
      @sprites["whites"].fade(255,6000,:ease_in_cubic)
      @sprites["whites"].z = 100
    end

    pathAddition = ""

    if alternative
      pathAddition = "Credits DLC/"
    end
    
    for img in CreditList#CreditsBackgroundList
      id = "bg#{CreditList.index(img)}"
      @sprites[id] = Sprite.new(@viewport)
      @sprites[id].bitmap = pbBitmap("Graphics/Titles/"+pathAddition+img)
      @sprites[id].opacity = 0
    end
    
    @sprites["tfp"] = Sprite.new(@viewport)
    @sprites["tfp"].bitmap = Bitmap.new(512,384)
    pbSetSystemFont(@sprites["tfp"].bitmap)
    @sprites["tfp"].bitmap.font.size = $MKXP ? 30 : 32
    pbDrawOutlineText(@sprites["tfp"].bitmap,0,0,512,384,_INTL("Thanks for playing!"),CREDITS_FILL,Color.new(120,120,120),1)
    @sprites["tfp"].opacity = 0
    
		@ranges=(0...@credits.length).to_a
		tmpR = []
		id=0
		for t in 0...@ranges.length/3+1
			break if id>=@ranges.length
			tmpR.push([])
			for i in 0...3
				break if id>=@ranges.length
				tmpR.last.push(@ranges[id])
				id+=1
				
			end
		end
		@ranges = tmpR
		echoln @ranges
		echoln tmpR
    @sprites["credits"] = Sprite.new(@viewport)
    @sprites["credits"].bitmap = pbBitmap("Graphics/Titles/Credits")#Bitmap.new(512,384+30*@credits.length)
    #@sprites["credits"].bitmap.fill_rect(0,0,512,384+30*credits.length,Color.new(255,255,255))
    @sprites["credits"].y = 0#384
    @sprites["credits"].oy = -384
    @creditsBitmap = @sprites["credits"].bitmap
    pbSetSystemFont(@creditsBitmap)
    @creditsBitmap.font.size = $MKXP ? 20 : 22
    #pbDrawOutlineText(bitmap,x,y,width,height,string,baseColor,shadowColor=nil,align=0)
=begin
    for i in 0...@credits.length
      line = @credits[i]
      if line.length>MAXCHARPERLINE
        @creditsBitmap.font.size = 18
        #Drawing the shadow first, then the text on top
        #draw_text_outline(@creditsBitmap,0,8+30*i,512,30,line,@shadowColor,nil,1)
        #Drawing the shadow first, then the text on top
        draw_text_outline(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      else
        @creditsBitmap.font.size = 22
        #Drawing the shadow first, then the text on top
        #pbDrawOutlineText(@creditsBitmap,0,8+30*i,512,30,line,@shadowColor,nil,1)
        #Drawing the shadow first, then the text on top
        pbDrawOutlineText(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      end
    end
=end
		#@creditsBitmap.export("Credits")
    echoln @sprites["credits"].bitmap.height
    pbBGMPlay(alternative ? "creditsdlc" : CreditsMusic)
    self.showCredits
  end
  
	def drawRange()
		return if @id>=@ranges.length
		for i in @ranges[@id]
      line = @credits[i]
      if line.length>MAXCHARPERLINE
        @creditsBitmap.font.size = $MKXP ? 16 : 18
        draw_text_outline(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      else
        @creditsBitmap.font.size = $MKXP ? 20 : 22
        pbDrawOutlineText(@creditsBitmap,0,30*i,512,30,line,CREDITS_FILL,CREDITS_OUTLINE,1)
      end
    end
		@id+=1
	end
	
  def draw_text_outline(credit_bitmap,xpos,ypos,linewidth,lineheight,line,basecolor,darkcolor,align = 1)
    #credit_bitmap.font.color = basecolor
    #credit_bitmap.draw_text(xpos,ypos + 8,linewidth,32,line[j],align)
    if darkcolor
      credit_bitmap.font.color = darkcolor
      credit_bitmap.draw_text(xpos + 2,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos - 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos - 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos+ 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 2,ypos+ 1,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos + 1,ypos+ 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos,ypos + 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 2,ypos + 2,linewidth,lineheight,line,align)
      credit_bitmap.draw_text(xpos - 1,ypos + 2,linewidth,lineheight,line,align)
    end
    credit_bitmap.font.color = basecolor
    credit_bitmap.draw_text(xpos,ypos,linewidth,lineheight,line,align)
  end
  
  def updateBG
    if @bgframe >= @changebgtime+1
      if @random
        @currentBG = rand(CreditList.length)
      else
        @currentBG = @currentBG+1 >= CreditList.length ? 0 : @currentBG+1
      end
      @bgframe = 0
    end
    
    if @bgframe<=@fadebgtime
      @sprites["bg#{@currentBG}"].opacity+=255/(@fadebgtime-1)
    end
    
    if @bgframe>=@changebgtime-@fadebgtime
      @sprites["bg#{@currentBG}"].opacity-=255/(@fadebgtime-1)
    end
    
    
  end
  
  def showCredits
    #opening here
    r = 255
		@id = 0
    if @strange
      frame = 0
    end
		#drawRange()
    loop do
      Graphics.update
      Input.update
      updateBG
			#drawRange() if @frame%20==0
      @frame+=1
      if @strange
        frame +=1
        if frame > 6050
          break
        end
      end
      @bgframe+=1
      r -= 255/20
      @viewport.tone = Tone.new(0,0,0,r)
      
      #update
      @sprites["whites"].update if @strange

      @sprites["credits"].oy+=CREDITS_SCROLLSPEED# if @sprites["credits"].y>-6700
      #if @sprites["credits"].y==-6700 && @frame >35
      #  @frame = 0
      #end
      #break if @frame >=35 && @sprites["credits"].y<=-6700
      break if @sprites["credits"].oy>= @sprites["credits"].bitmap.height+384 || @frame>=@fullduration
      #echoln @sprites["credits"].y if $DEBUG
      
    end
    r = 255
    20.times do
      r -=255/19
      @sprites["bg#{@currentBG}"].opacity = r
      @sprites["credits"].opacity = r
      Graphics.update
    end
    pbWait(12)
    if @thanksforplaying
      20.times do
        @sprites["tfp"].opacity+=255/19
        Graphics.update
      end
      pbWait(60)
      20.times do
        @sprites["tfp"].opacity-=255/19
        Graphics.update
      end
    end
    self.endscene
  end
  
  def endscene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
		$PokemonGlobal.creditsPlayed=true
  end
  
end