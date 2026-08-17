class MysteryGiftHandler

    def initialize(scene)
        @gifts={}
        @scene=scene
        #self.evaluate()
    end

    def evaluate(key)
        req = Database.requestGift("getGifts",key)
        echoln req
        strings = req.split("\r\n")
        # parsing values and populating @gifts hash
        for string in strings
            # 0 IDC, 1 NAME, 2 LEVEL, 3 SHINY, 4 AO, 5 BALL, 6 ITEM, 7 IVS, 8 EVS, 9 MOVES
            params = string.split("</s>")
            # enabling params
            params = enableParams(params)
            poke = parsePokemon(params)
            @gifts[params[0]] = poke
        end
    end

    def parsePokemon(params)
        poke = pbGenerateWildPokemon(getConst(PBSpecies,params[1]),params[2])
        poke.makeShiny if params[3]
        poke.ot=params[4] if params[4] != "NIL"
        poke.ballused=params[5]
        if params[6] != 0
            poke.item = getConst(PBItems,params[6]) 
        else
            poke.item = params[6]
        end
        poke.iv = params[7]
        poke.ev = params[8]
        for v in 0...params[9].length
            poke.moves[v] = PBMove.new(getID(PBMoves,params[9][v])) if params[9][v] != "NIL"
        end
        poke.setAbility(params[10])
        poke.name = params[11] if params[11] != "NIL"
        poke.setGender(params[12]) if poke.gender!=2
        if params[13]!=0
            poke.form=params[13]
            poke.resetMoves
        end
        return poke
    end

    def enableParams(params)
        ret=[]
        ret[0]=params[0]
        ret[1]=params[1].to_sym
        ret[2]=params[2].to_i
        ret[3]=params[3]=="1" ? true : false
        ret[4]=params[4]
        ret[5]=params[5].to_i
        ret[6]= params[6]=="NIL" ? 0 : params[6].to_sym 
        ret[7]=params[7].split("|")
        for v in 0...ret[7].length
            ret[7][v] = ret[7][v].to_i
        end
        ret[8]=params[8].split("|")
        for v in 0...ret[8].length
            ret[8][v] = ret[8][v].to_i
        end
        ret[9]=params[9].split("|")
        for v in 0...ret[9].length
            ret[9][v] = ret[9][v].to_sym if ret[9][v]!="NIL"
        end
        ret[10]=params[10].to_i
        ret[11]=params[11]
        ret[12]=params[12].to_i
        ret[13]=params[13].to_i
        return ret
    end

    def retrieve(key)
        res = Database.exists("checkCode",key)
        echo "res: "
        echoln res
        if (res == "true")
            if ($Trainer.giftstaken.include?(key))
                Kernel.pbMessage(_INTL("You already received this gift."))
            else
                evaluate(key)
                @scene.changeToBoxScreen(@gifts[key])
                
                # here goes eventual animation
                pbAddPokemonToBox(@gifts[key]) if (@gifts.has_key?(key))
                $Trainer.giftstaken.push(key)
                pbSave
                Kernel.pbMessage(_INTL("You got {1} from the Mystery Gift!",@gifts[key].name)) {@scene.update}
                Kernel.pbMessage(_INTL("Go check your Pokémon boxes!")) {@scene.update}
                @scene.closeBoxScreen
            end
        else
            if res=="false"
                Kernel.pbMessage(_INTL("Given code is not valid."))
            else
                Kernel.pbMessage(_INTL("Connection error: please try again later."))
            end
        end
    end
end

class MysteryGiftScene

    def initialize
        @oldfr = Graphics.frame_rate
        Graphics.frame_rate = 60
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @path = "Graphics/Pictures/MG/"
        @tones = [Tone.new(255,0,0),Tone.new(0,255,0),Tone.new(0,0,255),Tone.new(0,0,0)]
        @toneid = 0
        @frame = 360
        @framesForToneChange = 360

        @messages = [_INTL("Enter your code and get your Mystery Gift."),_INTL("Quit the Mystery Gift menu.")]
        #[_INTL("Inserisci qui il codice e ritira il tuo Dono Segreto."),_INTL("Esci dal menù del Dono Segreto.")]

        #Logic for displaying the msgbox with options information
        @msgwindow = Kernel.pbCreateMessageWindow(@viewport)
        @colortag=getSkinColor(@msgwindow.windowskin,0,true)
        @msgwindow.setText(@colortag + @messages[0])
        pbRepositionMessageWindow(@msgwindow,2)
        
        @pokeset = false
        @frameskip = false
        @pokeframe = 0

        @selIndex = 0

        @sprites={}
        @sprites["bg"] = EAMSprite.new(@viewport)
        @sprites["bg"].bitmap = pbBitmap(@path+"bg")
        @sprites["bg"].tone = @tones[0]

        @sprites["base"] = EAMSprite.new(@viewport)
        @sprites["base"].bitmap = pbBitmap(@path+"base")
        @sprites["base"].opacity = 0

        @sprites["box"] = EAMSprite.new(@viewport)
        @sprites["box"].bitmap = pbBitmap(@path+"box")
        @sprites["box"].opacity = 0
        @sprites["box"].y = -384

        @sprites["lid"] = EAMSprite.new(@viewport)
        @sprites["lid"].bitmap = pbBitmap(@path+"boxlid")
        @sprites["lid"].opacity = 0
        @sprites["lid"].ox = 322
        @sprites["lid"].oy = 186
        @sprites["lid"].x = 322
        @sprites["lid"].y = 186-384

        @sprites["flash"] = EAMSprite.new(@viewport)
        @sprites["flash"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
        @sprites["flash"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
        @sprites["flash"].opacity = 0
        @sprites["flash"].z = 20

        @sprites["gift"] = EAMSprite.new(@viewport)
        @sprites["gift"].x = 256
        @sprites["gift"].y = 162
        @sprites["gift"].z = 21
        @sprites["gift"].zoom_x = 2
        @sprites["gift"].zoom_y = 2

        @commands={}
        @commands["code"]=EAMSprite.new(@viewport)
        @commands["code"].bitmap = pbBitmap(@path + "button").clone
        @commands["code"].bitmap.font.name = "Barlow Condensed"
        @commands["code"].bitmap.font.size = $MKXP ? 24 : 26
        @commands["code"].x=256-283/2
        @commands["code"].y=74
        pbDrawTextPositions(@commands["code"].bitmap,[[_INTL("Get a Mystery Gift"),283/2,8,2,Color.new(24,24,24)]])
=begin
        @commands["retrieved"]=EAMSprite.new(@viewport)
        @commands["retrieved"].bitmap = pbBitmap(@path + "button").clone
        @commands["retrieved"].bitmap.font.name = "Barlow Condensed"
        @commands["retrieved"].bitmap.font.size = $MKXP ? 24 : 26
        @commands["retrieved"].x=256-283/2
        @commands["retrieved"].y=134
        pbDrawTextPositions(@commands["retrieved"].bitmap,[[_INTL("Retrieved Gifts"),283/2,8,2,Color.new(24,24,24)]])
=end
        
        @commands["exit"]=EAMSprite.new(@viewport)
        @commands["exit"].bitmap = pbBitmap(@path + "button").clone
        @commands["exit"].bitmap.font.name = "Barlow Condensed"
        @commands["exit"].bitmap.font.size = $MKXP ? 24 : 26
        @commands["exit"].x=256-283/2
        @commands["exit"].y=164
        pbDrawTextPositions(@commands["exit"].bitmap,[[_INTL("Quit"),283/2,8,2,Color.new(24,24,24)]])
        @merged = @sprites.merge(@commands)
        pbFadeInAndShow(@merged)
        $game_system.bgm_memorize
        pbBGMPlay("Dono Segreto")
        self.commands
    end

    def update
        @frame+=1
        if @frame>=@framesForToneChange
            @toneid=@toneid+1>=@tones.length ? 0 : @toneid+1 
            @sprites["bg"].toning(@tones[@toneid],360,:ease_in_out_quad)
            @frame=0
        end
        for v in @commands.values
            v.update
        end
        @sprites["bg"].update
        @msgwindow.update
        #updates pokemon sprite
        if @pokeset
            @frameskip = !@frameskip
            if !@frameskip 
                @pokeframe = @pokeframe + 1 >= @pbmp.width/@pbmp.height ? 0 : @pokeframe + 1
                @sprites["gift"].bitmap.clear
                @sprites["gift"].bitmap.blt(0,0,@pbmp,Rect.new(@pbmp.height * @pokeframe,0,@pbmp.height,@pbmp.height))
            end
        end
        @sprites["gift"].update
    end

    #main loop 
    def commands
        if @selIndex==0
            @commands["code"].fade(255,10)
            @commands["exit"].fade(120,10)
        else
            @commands["exit"].fade(255,10)
            @commands["code"].fade(120,10)
        end
        loop do
            Graphics.update
            Input.update
            update

            if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
                @selIndex = @selIndex == 0 ? 1 : 0
                @msgwindow.setText(@colortag + @messages[@selIndex])
                if @selIndex==0
                    @commands["code"].fade(255,10)
                    @commands["exit"].fade(120,10)
                else
                    @commands["exit"].fade(255,10)
                    @commands["code"].fade(120,10)
                end
            end

            if Input.trigger?(Input::C)
                if @selIndex == 0
                    mgh = MysteryGiftHandler.new(self)
                    #TODO: rimuovere lo skip del codice
                    if !$PokemonStorage.full?
                        code = pbEnterText(_INTL("Mystery Gift code."),0,32)
                        @msgwindow.visible=false
                        mgh.retrieve(code)
                    else
                        @msgwindow.visible=false
                        Kernel.pbMessage(_INTL("You don't have any space in the to store a gift."))
                    end
                    reEnableButtonScreen
                    @msgwindow.setText(@colortag + @messages[@selIndex])
                    if @selIndex==0
                        @commands["code"].fade(255,10)
                        @commands["exit"].fade(120,10)
                    else
                        @commands["exit"].fade(255,10)
                        @commands["code"].fade(120,10)
                    end
                else
                    break
                end
            end

            if Input.trigger?(Input::B)
                break
            end
        end
        @merged = @sprites.merge(@commands)
        Kernel.pbDisposeMessageWindow(@msgwindow)
        pbFadeOutAndHide(@merged)
        pbBGMStop()
        $game_system.bgm_restore
        Graphics.frame_rate = @oldfr
    end

    def reEnableButtonScreen
        for v in @commands.values
            v.opacity=255
        end
        @sprites["box"].y=-384
        @sprites["base"].opacity = 0
        @sprites["flash"].fade(0,20)
        20.times do
            Graphics.update
            update
            @sprites["flash"].update
        end
        @sprites["flash"].color = Color.new(255,255,255)
        @msgwindow.visible = true
    end

    def changeToBoxScreen(poke)
        @msgwindow.visible=true
        resetGiftSprites
        setGiftSprite(poke)
        @msgwindow.setText(@colortag + _INTL("You received a gift!"))
        
        for v in @commands.values
            v.fade(0,20)
        end
        20.times do
            Graphics.update
            update
            for v in @commands.values
                v.update
            end
        end

        @sprites["base"].fade(255,20)
        20.times do
            Graphics.update
            update
            @sprites["base"].update
        end
        pbWait(20)
        @sprites["box"].move(0,0,30,:ease_in_cubic)
        @sprites["lid"].move(322,186,30,:ease_in_cubic)
        @sprites["box"].fade(255,30)
        @sprites["lid"].fade(255,30)
        30.times do
            Graphics.update
            update
            @sprites["box"].update
            @sprites["lid"].update
        end
        pbSEPlay("Substitute")
        @msgwindow.visible=false
        @sprites["box"].move(0,-10,6,:ease_in_cubic)
        @sprites["lid"].move(322,156,6,:ease_in_cubic)
        6.times do
            Graphics.update
            update
            @sprites["box"].update
            @sprites["lid"].update
        end

        @sprites["box"].move(0,0,6,:ease_in_cubic)
        @sprites["lid"].move(322,186,6,:ease_in_cubic)
        6.times do
            Graphics.update
            update
            @sprites["box"].update
            @sprites["lid"].update
        end

        pbWait(60)
        pbSEPlay("flash")
        @sprites["lid"].rotate(-180,55,:ease_in_cubic)
        @sprites["lid"].fade(0,50)
        @sprites["flash"].fade(255,50)
        50.times do
            Graphics.update
            update
            @sprites["lid"].update
            @sprites["flash"].update
        end
        pbWait(60)
        @sprites["gift"].fade(255,10,:ease_out_cubic)
        pbPlayCry(poke.species)
        70.times do 
            Graphics.update
            update
        end
        
        #@pokeset = false
    end

    def closeBoxScreen
        @sprites["gift"].fade(0,10,:ease_out_cubic)
        @sprites["flash"].coloring(Color.new(0,0,0),20)
        30.times do 
            Graphics.update
            update
            @sprites["flash"].update
        end
        @pokeset = false
    end

    def setGiftSprite(poke)
        @pbmp = pbLoadPokemonBitmap(poke,false).ogBitmap
        @sprites["gift"].bitmap = Bitmap.new(@pbmp.height,@pbmp.height)
        @sprites["gift"].bitmap.blt(0,0,@pbmp,Rect.new(0,0,@pbmp.height,@pbmp.height))
        @sprites["gift"].ox = @pbmp.height/2
        @sprites["gift"].oy = @pbmp.height/2
        @sprites["gift"].opacity = 0
        @pokeset = true
        @pokeframe = 0
    end

    def resetGiftSprites
        @sprites["base"].opacity = 0

        @sprites["box"].opacity = 0
        @sprites["box"].y = -384

        @sprites["lid"].opacity = 0
        @sprites["lid"].ox = 322
        @sprites["lid"].oy = 186
        @sprites["lid"].x = 322
        @sprites["lid"].y = 186-384
        @sprites["lid"].rotate(0,1,:ease_in_cubic)
        
        Graphics.update
        update
        @sprites["lid"].update
        @sprites["flash"].update

        @sprites["flash"].opacity = 0
        @sprites["flash"].z = 20
    end

end

class PokeBattle_Trainer
    attr_accessor(:giftstaken)

    def giftstaken
        if @giftstaken==nil
            @giftstaken=[]
        end
        return @giftstaken
    end
end

class Database
    #weedleteam
    #@@url = "https://www.weedleteam.com/request.php"

    @@url = "http://xntst.altervista.org/request.php"

    def self.makeRequest(type, data = {})
        data["type"] = type
        return pbPostData(@@url,data)
    end


    def self.requestGift(type, code, data = {})
        data["type"] = type
        data["code"] = code
        return pbPostData(@@url,data)
    end

    def self.exists(type, code, data={})
        data["type"] = type
        data["code"] = code
        return pbPostData(@@url,data)
    end 
end

def pbMGH
    pbFadeOutIn(99999){
        MysteryGiftScene.new
    }
end