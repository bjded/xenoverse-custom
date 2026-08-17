class SecretReports
    attr_accessor :pages
    attr_accessor :no
    attr_accessor :unlocked

    DATA={}

    def self.register(hash)
        DATA[hash[:id]] = DATA[hash[:id_number]] = hash
    end

    def self.get(id)
        return DATA[id] if DATA.has_key?(id)
    end
end
#Additions to trainer class to save the page progress
class PokeBattle_Trainer
    attr_accessor :pages

    def pages
        @pages = {} if @pages==nil
        return @pages
    end

    def obtainPage(id, page)
        echoln "obtained #{id} #{page}"
        @pages={} if (@pages == nil)
        @pages[id]={} if @pages[id] == nil
        @pages[id][page]=true
        
    end
end

SecretReports.register({
    :id => :TamaraReports,
    :id_number => 0,
    :title => _INTL("Diario di ???"),
    :pageno => 11,
    :bg => "Graphics/Pictures/reportsbg",
    :pages =>[
        #0
        "???: Ho deciso di tenere un diario per ricordare le numerose esperienze che farò! "+
        "Proprio oggi mi sono unita al Team Dimension, e nonostante io sia solo una recluta, "+
        "mi sento già legata alla causa! Spero di poter aiutare il più possibile.",
        #1
        "???: C’è molto lavoro da fare qui! Sembra stiano progettando dei robot da utilizzare insieme alle altre reclute, "+ 
        "per smaltire più in fretta il lavoro. Nel frattempo, sono stata promossa a Sergente! "+
        "A quanto pare la mia motivazione ha fatto colpo sui ranghi alti e hanno deciso di promuovermi. Buon per me!",
        #2
        "???: Ormai è passato tantissimo tempo da quando mi sono unita al Team Dimension. " +
        "Sono stata addirittura promossa a Colonnello! Durante la promozione ho conosciuto il Generale, "+
        "che uomo affascinante! Credo di essermi innamorata! Mi è stata assegnata una missione "+
        "riguardante la cattura di una specie X nel Canyon Asteroide. Spero di non dover fargli del male, ma se fosse necessario...",
        #3
        "???: Anche se ho fallito nell’ultima missione, il Generale ha chiesto nuovamente di me! "+
        "Questa volta sono stata incaricata di rubare un treno, e farò in modo che la missione "+
        "abbia successo! Spero solo che non torni quella spina nel fianco...",
        #4
        "???: Alla fine la missione sul treno è andata a buon fine, ma non grazie a me... "+
        "ho perso contro quella sottospecie di Trubbish... "+
        "Il Generale ha preso le redini della situazione e ha portato a termine "+
        "la missione senza problemi. È proprio magnifico! Devo migliorare per poter " +
        "essere alla sua altezza, non posso assolutamente deluderlo!",
        #5
        "???: A quanto pare stiamo per partire per la luna, sono davvero nervosa... "+
        "Io e il mio Scovile X ci siamo allenati per essere ancora più forti! "+
        "Il Generale dice che lo scontro finale si avvicina, e quindi dobbiamo "+
        "prepararci al meglio! Mi assicurerò di essergli utile questa volta!",
        #6
        "???: Dopo intere settimane che vagavamo senza meta il mio Generale "+
        "decise all’improvviso di ricominciare con le ricerche. Parlava di "+
        "come fosse possibile interagire con altre dimensioni usando un certo "+
        "tipo di Energia. Io ero così emozionata! Finalmente vedevo tornare nel"+
        " mio adorato un po’ di forze, che non ero più nella pelle!",
        #7
        "???: Ero contenta di sentire il mio Generale pieno di energie, " +
        "ma ormai non fa altro che parlare di una certa Nives... Pare fosse una ricercatrice "+
        "del Team Dimension, quando erano ancora in corso gli esperimenti sullo Xenoverse. "+
        "Adesso ci stiamo dirigendo verso un nascondiglio situato nel Canyon Asteroide. "+
        "E io sento un senso di oppressione al petto.",
        #8
        "???: Ero certa che il Generale volesse venire qui per nascondersi, "+
        "invece pare che in questo posto ci siano i macchinari di cui ha bisogno per le sue ricerche!"+
        " È così pieno di energie ultimamente! Voglio supportarlo con tutta me stessa. "+
        "Diventerò la sua Tamara! Peccato che lui continui a parlare di questa Nives. "+
        "Il senso di oppressione si fa peggiore.",
        #9
        "???: Sembra che le ricerche non stiano portando ai risultati sperati. "+
        "Il mio adorato ora sembra disperato, come se dovesse riuscire a tutti i costi. "+
        "Quando gli ho detto di riposare, mi ha spinta via e mi ha detto di sparire, "+
        "visto che sono inutile. Mi fa male il petto.",
        #10
        "???: Ho scoperto che questo posto in realtà è dove il mio Generale "+
        "e quella Nives si sono conosciuti. Perchè continua a parlare di lei? "+
        "Perchè continuo ad essere ignorata? Mio Generale… quella è già morta da un pezzo! "+
        "Io invece posso ancora renderla felice... La prego, non mi ignori... Il dolore al petto è insopportabile..."
    ],
    :pagegraphics =>{
        0=>"Graphics/Pictures/Pages/page0",
        1=>"Graphics/Pictures/Pages/page1",
        2=>"Graphics/Pictures/Pages/page2",
        3=>"Graphics/Pictures/Pages/page3",
        4=>"Graphics/Pictures/Pages/page4",
        5=>"Graphics/Pictures/Pages/page5",
        6=>"Graphics/Pictures/Pages/page6",
        7=>"Graphics/Pictures/Pages/page7",
        8=>"Graphics/Pictures/Pages/page8",
        9=>"Graphics/Pictures/Pages/page9",
        10=>"Graphics/Pictures/Pages/page10",
    }
})

def pbTestReport
    $Trainer.obtainPage(:TamaraReports,3)
    SecretReportScreen.new(SecretReports.get(:TamaraReports))
end

class SecretReportScreen

    def initialize(reports)
        @reports = reports
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @viewport2 = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport2.z = @viewport.z + 1
        @sprites={}

        setUpScreen()

        pbFadeInAndShow(@sprites)
        #input handling
        inputLoop()
    end

    def setUpScreen
        @sprites["bg"] = Sprite.new(@viewport)
        @sprites["bg"].bitmap = pbBitmap(@reports[:bg] == nil ? "Graphics/Pictures/reportsbg" : @reports[:bg])#Bitmap.new(512,384)
        #@sprites["bg"].bitmap.fill_rect(0,0,512,384,Color.new(40,40,80))
        
        id = @reports[:id]
        commands=CommandList.new
        for i in 0...@reports[:pageno]
            pageno = "%03d" % (i+1)
            commands.add("page#{i}", $Trainer.pages.has_key?(id) && $Trainer.pages[id].has_key?(i) ? _INTL("{1}: Pagina Numero {2}",pageno, i+1) : "#{pageno}: ???")
        end

        @sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
        cmdwindow=@sprites["cmdwindow"]
        cmdwindow.viewport=@viewport
        cmdwindow.resizeToFit(cmdwindow.commands)
        cmdwindow.height=250
        cmdwindow.x=12
        cmdwindow.y=48
        cmdwindow.windowskin=nil
        cmdwindow.visible=true
        cmdwindow.baseColor = Color.new(48,48,48)
        cmdwindow.shadowColor = nil
        

        @sprites["rightOverlay"] = BitmapSprite.new(256,Graphics.height, @viewport)
        @sprites["rightOverlay"].x = 256
        @sprites["rightOverlay"].bitmap.clear
        pbSetFont(@sprites["rightOverlay"].bitmap,"Barlow Condensed",27)

        textpos = [[_INTL(@reports[:title]),128,80,2,Color.new(48,48,48)],
                   [_INTL("Pagine Raccolte: {1}",$Trainer.pages.has_key?(id) ? "#{$Trainer.pages[id].keys.length}" : "0"),128,110,2,Color.new(48,48,48)],
                   [_INTL("Pagine Totali: {1}", @reports[:pageno]),128,140,2,Color.new(48,48,48)]]

        pbDrawTextPositions(@sprites["rightOverlay"].bitmap,textpos)

        @sprites["page"] = Sprite.new(@viewport2)
        @sprites["page"].visible = false
        @sprites["page"].z = 9

        @sprites["fadeout"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport2)
        @sprites["fadeout"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
        @sprites["fadeout"].z = 10
        @sprites["fadeout"].opacity = 0
    end


    def inputLoop
        loop do
            Graphics.update
            Input.update
            #this handles basic page selection
            @sprites["cmdwindow"].update

            if Input.trigger?(Input::C) && $Trainer.pages[@reports[:id]]!=nil && $Trainer.pages[@reports[:id]][@sprites["cmdwindow"].index]
                readPage(@sprites["cmdwindow"].index)
            end


            if (Input.trigger?(Input::B))
                break
            end
        end
        endScreen()
    end

    def readPage(id)
        14.times do
            Graphics.update
            Input.update
            @sprites["fadeout"].opacity += 255/14
        end

        if @reports[:pagegraphics][id]
            @sprites["page"].bitmap = pbBitmap(@reports[:pagegraphics][id])
            @sprites["page"].visible = true
        end

        14.times do
            Graphics.update
            Input.update
            @sprites["fadeout"].opacity -= 255/14
        end
        Kernel.pbMessage(_INTL(@reports[:pages][id]))

        14.times do
            Graphics.update
            Input.update
            @sprites["fadeout"].opacity += 255/14
        end
        
        @sprites["page"].visible = false

        14.times do
            Graphics.update
            Input.update
            @sprites["fadeout"].opacity -= 255/14
        end
    end

    def endScreen()
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @viewport2.dispose
        @viewport.dispose
    end
end