################################################################################
#Sprite utilities
################################################################################

class SliderSprite < Sprite
    include EAM_Sprite
    
    def initialize(viewport)
      super(viewport)
    end
end

class TournamentPlane < AnimatedPlane

  def sprite
    return @__sprite
  end

  def mask(mask = nil,xpush = 0,ypush = 0) # Draw sprite on a sprite/bitmap
    echoln "NO BITMAP!" if !self.bitmap
    return false if !self.bitmap
    bitmap = self.bitmap.clone
    if mask.is_a?(Bitmap)
      mbmp = mask
    elsif mask.is_a?(Sprite)
      mbmp = mask.bitmap
    elsif mask.is_a?(String)
      mbmp = BitmapCache.load_bitmap(mask)
    else
      return false
    end
    echoln "STARTING MASK PROCESS!"
    self.bitmap = Bitmap.new(mbmp.width, mbmp.height)
    mask = mbmp.clone
    ox = (bitmap.width - mbmp.width) / 2
    oy = (bitmap.height - mbmp.height) / 2
    width = mbmp.width + ox
    height = mbmp.height + oy
    for y in oy...height
      for x in ox...width
        pixel = mask.get_pixel(x - ox, y - oy)
        color = bitmap.get_pixel(x - xpush, y - ypush)
        alpha = pixel.alpha
        alpha = color.alpha if color.alpha < pixel.alpha
        self.bitmap.set_pixel(x - ox, y - oy, Color.new(color.red, color.green,
            color.blue, alpha))
      end
    end
    return self.bitmap
  end

end

class BracketSlot < Sprite
  attr_accessor (:trainer)

  def initialize(viewport)
    super(viewport)
    @trainerx = 0
    @trainery = 0
    @trainer = RainbowSprite.new(viewport)
  end

  def setTrainer(rightfacing = false,charid = "trey",hidden = false)
    bmp = pbBitmap("Graphics/Characters/#{charid}")
    @trainer.bitmap = Bitmap.new(bmp.width/4+2,bmp.height/4+2) #adding a 1 to show properly the outline
    @trainer.bitmap.blt(1,1,bmp,Rect.new(0,bmp.height/4*(rightfacing ? 1:2),bmp.width/4,bmp.height/4))
    
    @trainer.colorize(Color.new(0,0,0)) if hidden
    if $MKXP
      @trainer.add_outline(Color.new(255,255,255,150))
    else
      @trainer.bitmap.add_outline(Color.new(255,255,255,150),1)
    end
    @trainer.ox = @trainer.bitmap.width/2
    @trainer.oy = @trainer.bitmap.height/2
  end

  def positionTrainer(x,y)
    @trainerx = x
    @trainery = y
    @trainer.x = self.x + @trainerx
    @trainer.y = self.y + @trainery
  end

  def zoom_x=(value)
    super(value)
    @trainer.zoom_x=value
  end

  def zoom_y=(value)
    super(value)
    @trainer.zoom_y=value
  end

  def x=(value)
    super(value)
    @trainer.x = value + @trainerx
  end

  def y=(value)
    super(value)
    @trainer.y = value + @trainery
  end

  def opacity=(value)
    super(value)
    @trainer.opacity = value
  end
end

class Bracket < Sprite
  attr_accessor(:firstPool)
  attr_accessor(:curPool)

  SMALLRECTW = 70
  SMALLRECTH = 47

  def initialize(viewport,fp,cp)
    super(viewport)
    @firstPool = fp
    @curPool = cp
  end

  def actualize

    bmp = self.bitmap.clone
    #go by couples
    
    pool=@curPool
    tempPool = []
    for i in 0...pool.length
      tempPool.push([i,i+1]) if i%2==0
    end

    couple = -1
    included = []
    branch = -1
    branchIncluded = []
    #main cycle
    for i in 0...@firstPool.length
      rc = Color.new(rand(255),rand(255),rand(255))
      if i%2 == 0
        couple +=1 
        included = []
      end

      if branch == 3
        echoln "Branch reaced 3!"
        branch = -1
        branchIncluded = []
      end

      branch += 1

      

      #SINGLE CHECK
      if !@curPool.include?(@firstPool[i])
        x = i<@firstPool.length/2 ? 0 : bmp.width-70
        y = (i%2) * (5+46) + (couple % (@firstPool.length/4)) * 183 #- ((i%8)/4)*2 # TODO: Add next branch offset

        rect = Rect.new(x,y,SMALLRECTW,SMALLRECTH)

        for z in 0...rect.width
          for w in 0...rect.height
            p = bmp.get_pixel(rect.x+z,rect.y+w)
            bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
            #bmp.set_pixel(rect.x+z,rect.y+w,rc)
          end
        end
      else
        included.push(1)
        branchIncluded.push(1)
      end

      # COUPLE CHECK
      if i%2 == 1 #this is the last handled member of the couple

        if (included.length==0) #if no member was spared i need to remove this couple branching
          # small quad
          x = i < @firstPool.length/2 ? 64 : bmp.width-(64+6)
          y = 46 + (couple % (@firstPool.length/4)) * 183
          rect = Rect.new(x,y+1,6,4)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end

          # horizontal rect
          x = i < @firstPool.length/2 ? 70 : bmp.width-(64+82)
          rect = Rect.new(x,y,76,6)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end

          #vertical rect
          x = i < @firstPool.length/2 ? 133 : bmp.width-(133+8)
          y = 52 + (couple % (@firstPool.length/(@firstPool.length/2))) * 92 + (@firstPool.length>8 ? ((i%8)/4) * 366 : 0)
          rect = Rect.new(x,y,8,(couple % (@firstPool.length/(@firstPool.length/2))) > 0 ? 85 : 88)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end
        end
      end

      # Branch check
      if branch == 3 && @firstPool.length > 8
        if branchIncluded.length == 0
          echoln "Handling branch dimming"

          # small quad
          x = i < @firstPool.length/2 ? 135 : bmp.width-(135+6)
          y = 139 + ((i%8)/4) * 366#(couple % (@firstPool.length/(@firstPool.length/2))) * 366
          rect = Rect.new(x,y+1,6,4)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end

          echoln "Branch SmallQuad X: #{x} Y: #{y}"

          # horizontal rect
          x = i < @firstPool.length/2 ? 141 : bmp.width-(141+62)
          rect = Rect.new(x,y,62,6)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end

          #vertical rect
          x = i < @firstPool.length/2 ? 194 : bmp.width-(194+8)
          y = 145 + (@firstPool.length>8 ? ((i%8)/4) * 180 : 0) #(couple % (@firstPool.length/(@firstPool.length/2))) * 92 + (@firstPool.length>8 ? ((i%8)/4) * 366 : 0)
          rect = Rect.new(x,y,8,(((i%8)/4)) > 0 ? 180 : 176)
          for z in 0...rect.width
            for w in 0...rect.height
              p = bmp.get_pixel(rect.x+z,rect.y+w)
              bmp.set_pixel(rect.x+z,rect.y+w,Color.new(p.red/1.9,p.green/1.9,p.blue/1.9,p.alpha/2.5))
              #bmp.set_pixel(rect.x+z,rect.y+w,rc)
            end
          end

        end
      end
    end

    

    self.bitmap = bmp
  end

end

CUSTOMIV = {
  [PBTrainers::LANCETOURNAMENT,"Lance"]=>{
    :iv=>{
      :DRAGONITE =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :EGORGEON =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :CHARIZARD =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      }
    },
    :ev=>{
      :DRAGONITE =>{
        :hp => 4,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :EGORGEON =>{
        :hp => 4,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :CHARIZARD =>{
        :hp => 4,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      }
    }
  },
  [PBTrainers::ERIKATOURNAMENT,"Erika"]=>{
    :iv=>{
      :TANGROWTH =>{
        :hp => 31,
        :attack => 31,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :ERBA3 =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :BELLOSSOM =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      }
    },
    :ev=>{
      :TANGROWTH =>{
        :hp => 252,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 4,
        :speed => 0
      },
      :ERBA3 =>{
        :hp => 4,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :BELLOSSOM =>{
        :hp => 128,
        :attack => 0,
        :defense => 124,
        :spatk => 252,
        :spdef => 4,
        :speed => 0
      }
    }
  },
  [PBTrainers::DANTETOURNAMENT,"Dante"]=>{
    :iv=>{
      :SKRAVROOM =>{
        :hp => 61,
        :attack => 61,
        :defense => 61,
        :spatk => 61,
        :spdef => 61,
        :speed => 61
      },
      :HYDREIGON =>{
        :hp => 61,
        :attack => 0,
        :defense => 61,
        :spatk => 61,
        :spdef => 61,
        :speed => 61
      },
      :SHIFTRY =>{
        :hp => 61,
        :attack => 0,
        :defense => 61,
        :spatk => 61,
        :spdef => 61,
        :speed => 61
      }
    },
    :ev=>{
      :SKRAVROOM =>{
        :hp => 4,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :HYDREIGON =>{
        :hp => 4,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :SHIFTRY =>{
        :hp => 164,
        :attack => 0,
        :defense => 44,
        :spatk => 252,
        :spdef => 48,
        :speed => 0
      }
    }
  },
  [PBTrainers::LEOTOURNAMENT,"Leo"]=>{
    :iv=>{
      :AUDINO =>{
        :hp => 31,
        :attack => 31,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 0
      },
      :URSARING =>{
        :hp => 31,
        :attack => 31,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 0
      },
      :TROGLOLITH =>{
        :hp => 31,
        :attack => 31,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 0
      }
    },
    :ev=>{
      :AUDINO =>{
        :hp => 252,
        :attack => 0,
        :defense => 148,
        :spatk => 0,
        :spdef => 108,
        :speed => 0
      },
      :URSARING =>{
        :hp => 228,
        :attack => 252,
        :defense => 16,
        :spatk => 0,
        :spdef => 12,
        :speed => 0
      },
      :TROGLOLITH =>{
        :hp => 220,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 36,
        :speed => 0
      }
    }
  },
  [PBTrainers::STELLATOURNAMENT,"Stella"]=>{
    :iv=>{
      :HARROWK =>{
        :hp => 301,
        :attack => 31,
        :defense => 31,
        :spatk => 301,
        :spdef => 31,
        :speed => 151
      },
      :BIRIGIRI =>{
        :hp => 151,
        :attack => 151,
        :defense => 71,
        :spatk => 31,
        :spdef => 71,
        :speed => 71
      },
      :LUXRAY =>{
        :hp => 301,
        :attack => 151,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 181
      }
    },
    :ev=>{
      :HARROWK =>{
        :hp => 6,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :BIRIGIRI =>{
        :hp => 0,
        :attack => 252,
        :defense => 148,
        :spatk => 0,
        :spdef => 110,
        :speed => 0
      },
      :LUXRAY =>{
        :hp => 0,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      }
    }
  },
  [PBTrainers::SOTISTOURNAMENT,"Sotis"]=>{
    :iv=>{
      :LEDIAN =>{
        :hp => 301,
        :attack => 301,
        :defense => 301,
        :spatk => 301,
        :spdef => 301,
        :speed => 151
      },
      :HERCURCULES =>{
        :hp => 151,
        :attack => 151,
        :defense => 71,
        :spatk => 31,
        :spdef => 71,
        :speed => 31
      },
      :SCIZOR =>{
        :hp => 301,
        :attack => 151,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 111
      }
    },
    :ev=>{
      :LEDIAN =>{
        :hp => 252,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 6
      },
      :HERCURCULES =>{
        :hp => 252,
        :attack => 252,
        :defense => 6,
        :spatk => 0,
        :spdef => 0,
        :speed => 0
      },
      :SCIZOR =>{
        :hp => 252,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 0
      }
    }
  },
  [PBTrainers::GRETATOURNAMENT,"Valentina"]=>{
    :iv=>{
      :BLAZIKEN =>{
        :hp => 151,
        :attack => 71,
        :defense => 151,
        :spatk => 71,
        :spdef => 151,
        :speed => 151
      },
      :BRELOOM =>{
        :hp => 71,
        :attack => 151,
        :defense => 71,
        :spatk => 31,
        :spdef => 71,
        :speed => 131
      },
      :MIENSHAO =>{
        :hp => 301,
        :attack => 71,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 301
      }
    },
    :ev=>{
      :BLAZIKEN =>{
        :hp => 6,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :BRELOOM =>{
        :hp => 0,
        :attack => 252,
        :defense => 6,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :MIENSHAO =>{
        :hp => 0,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      }
    }
  },
  [PBTrainers::GLADIONTOURNAMENT,"Iridio"]=>{
    :iv=>{
      :ZOROARKHISUI =>{
        :hp => 251,
        :attack => 0,
        :defense => 151,
        :spatk => 201,
        :spdef => 151,
        :speed => 151
      },
      :LUCARIO =>{
        :hp => 301,
        :attack => 301,
        :defense => 151,
        :spatk => 151,
        :spdef => 151,
        :speed => 131
      },
      :PORYGONZ =>{
        :hp => 301,
        :attack => 0,
        :defense => 31,
        :spatk => 301,
        :spdef => 31,
        :speed => 301
      }
    },
    :ev=>{
      :ZOROARKHISUI =>{
        :hp => 6,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :LUCARIO =>{
        :hp => 0,
        :attack => 252,
        :defense => 6,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :PORYGONZ =>{
        :hp => 252,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 6
      }
    }
  },
  [PBTrainers::VELIATOURNAMENT,"Velia"]=>{
    :iv=>{
      :GENGAR =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 181,
        :spdef => 31,
        :speed => 121
      },
      :MUK =>{
        :hp => 151,
        :attack => 151,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :SCOLIPEDE =>{
        :hp => 31,
        :attack => 301,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      }
    },
    :ev=>{
      :GENGAR =>{
        :hp => 6,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :MUK =>{
        :hp => 252,
        :attack => 252,
        :defense => 6,
        :spatk => 0,
        :spdef => 0,
        :speed => 0
      },
      :SCOLIPEDE =>{
        :hp => 6,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      }
    }
  },
  [PBTrainers::LINNEATOURNAMENT,"Lin & Nea"]=>{
    :iv=>{
      :RAMPARDOS =>{
        :hp => 31,
        :attack => 31,
        :defense => 151,
        :spatk => 31,
        :spdef => 151,
        :speed => 31
      },
      :GASTRODON =>{
        :hp => 151,
        :attack => 31,
        :defense => 31,
        :spatk => 151,
        :spdef => 31,
        :speed => 31
      },
      :ARCHEOPS =>{
        :hp => 31,
        :attack => 301,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      },
      :PALOSSAND =>{
        :hp => 31,
        :attack => 31,
        :defense => 151,
        :spatk => 151,
        :spdef => 151,
        :speed => 31
      }
    },
    :ev=>{
      :RAMPARDOS =>{
        :hp => 6,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :GASTRODON =>{
        :hp => 252,
        :attack => 0,
        :defense => 152,
        :spatk => 0,
        :spdef => 104,
        :speed => 0
      },
      :ARCHEOPS =>{
        :hp => 6,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 0,
        :speed => 252
      },
      :PALOSSAND =>{
        :hp => 252,
        :attack => 0,
        :defense => 6,
        :spatk => 252,
        :spdef => 0,
        :speed => 0
      }
    }
  },
  [PBTrainers::SOLETOURNAMENT,"Sole"]=>{
    :iv=>{
      :ARCANINE =>{
        :hp => 31,
        :attack => 0,
        :defense => 31,
        :spatk => 181,
        :spdef => 31,
        :speed => 121
      },
      :RAICHU =>{
        :hp => 31,
        :attack => 31,
        :defense => 31,
        :spatk => 151,
        :spdef => 31,
        :speed => 151
      },
      :HERCURCULES =>{
        :hp => 151,
        :attack => 151,
        :defense => 31,
        :spatk => 31,
        :spdef => 31,
        :speed => 31
      }
    },
    :ev=>{
      :ARCANINE =>{
        :hp => 6,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :RAICHU =>{
        :hp => 6,
        :attack => 0,
        :defense => 0,
        :spatk => 252,
        :spdef => 0,
        :speed => 252
      },
      :HERCURCULES =>{
        :hp => 252,
        :attack => 252,
        :defense => 0,
        :spatk => 0,
        :spdef => 6,
        :speed => 0
      }
    }
  }
}

ACHIEVEMENTREDIRECT ={
  "Stella"=>"StellaT"
}

################################################################################
#   PWT Trainer method
################################################################################
def pbLoadTrainerTournament(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid=getID(PBTrainers,trainerid)
  end
  success=false
  items=[]
  party=[]
  opponent=nil
  trainers=load_data("Data/tourtrainers.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      species=poke[TPSPECIES]
      level=poke[TPLEVEL]
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      if poke[TPFORM] == 100 && pokemon.hasDelta?
        pokemon.makeDelta
      else
        pokemon.form=poke[TPFORM]
      end
      pokemon.resetMoves
      pokemon.setItem(poke[TPITEM])
      if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
        for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move])
          k+=1
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[TPABILITY])
      pokemon.setGender(poke[TPGENDER])
      if poke[TPSHINY]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[TPNATURE])

      # CUSTOM IV AND EV HANDLING HANDLING
      if CUSTOMIV.keys.include?([trainerid,trainername]) && CUSTOMIV[[trainerid,trainername]] != nil
          ivhash = CUSTOMIV[[trainerid,trainername]][:iv]
          if (ivhash != nil)
            spfound = nil
            found = false
            ivhash.keys.each {|species| if isConst?(pokemon.species,PBSpecies,species);spfound=species;found=true;end;}
            echoln "Handling #{pokemon.name}"
            if found
              echoln "Detected Species IV!"
              ivs = ivhash[spfound]
              for stat in ivs.keys
                if [:hp,:attack,:defense,:spatk,:spdef,:speed].include?(stat)
                  case stat
                  when :hp
                    pokemon.iv[0]=ivs[:hp]
                  when :attack
                    pokemon.iv[1]=ivs[:attack]
                  when :defense
                    pokemon.iv[2]=ivs[:defense]
                  when :spatk
                    pokemon.iv[4]=ivs[:spatk]
                  when :spdef
                    pokemon.iv[5]=ivs[:spdef]
                  when :speed
                    pokemon.iv[3]=ivs[:speed]
                  end
                end
              end
            end
          end

          evhash = CUSTOMIV[[trainerid,trainername]][:ev]
          if (evhash != nil)
            spfound = nil
            found = false
            evhash.keys.each {|species| if isConst?(pokemon.species,PBSpecies,species);spfound=species;found=true;end;}
            echoln "Handling #{pokemon.name}"
            if found
              echoln "Detected Species EV!"
              evs = evhash[spfound]
              for stat in evs.keys
                if [:hp,:attack,:defense,:spatk,:spdef,:speed].include?(stat)
                  case stat
                  when :hp
                    pokemon.ev[0]=evs[:hp]
                  when :attack
                    pokemon.ev[1]=evs[:attack]
                  when :defense
                    pokemon.ev[2]=evs[:defense]
                  when :spatk
                    pokemon.ev[4]=evs[:spatk]
                  when :spdef
                    pokemon.ev[5]=evs[:spdef]
                  when :speed
                    pokemon.ev[3]=evs[:speed]
                  end
                end
              end
            end
          end
      else
        iv=poke[TPIV]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
      end
      pokemon.happiness=poke[TPHAPPINESS]
      pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused=poke[TPBALL]
      pokemon.calcStats
      party.push(pokemon)
    end
    success=true
    break
  end
  return success ? [opponent,items,party] : nil
end

def pbCompileTournament
  # Individual tournament trainers
  lines=[]
  linenos=[]
  lineno=1
  trainernames=[]
  File.open("PBS/tourtrainers.txt","rb"){|f|
     FileLineData.file="PBS/tourtrainers.txt"
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line!=""
          lines.push(line)
          linenos.push(lineno)
        end
        lineno+=1
     }
  }
  nameoffset=0
  trainers=[]
  trainernames.clear
  i=0; loop do break unless i<lines.length
    FileLineData.setLine(lines[i],linenos[i])
    trainername=parseTrainer(lines[i])
    FileLineData.setLine(lines[i+1],linenos[i+1])
    nameline=strsplit(lines[i+1],/\s*,\s*/)
    name=nameline[0]
    raise _INTL("Trainer name too long\r\n{1}",FileLineData.linereport) if name.length>=0x10000
    trainernames.push(name)
    partyid=0
    if nameline[1] && nameline[1]!=""
      raise _INTL("Expected a number for the trainer battle ID\r\n{1}",FileLineData.linereport) if !nameline[1][/^\d+$/]
      partyid=nameline[1].to_i
    end
    FileLineData.setLine(lines[i+2],linenos[i+2])
    items=strsplit(lines[i+2],/\s*,\s*/)
    items[0].gsub!(/^\s+/,"")   # Number of Pokémon
    raise _INTL("Expected a number for the number of Pokémon\r\n{1}",FileLineData.linereport) if !items[0][/^\d+$/]
    numpoke=items[0].to_i
    realitems=[]
    for j in 1...items.length   # Items held by Trainer
      realitems.push(parseItem(items[j])) if items[j] && items[j]!=""
    end
    pkmn=[]
    for j in 0...numpoke
      FileLineData.setLine(lines[i+j+3],linenos[i+j+3])
      poke=strsplit(lines[i+j+3],/\s*,\s*/)
      begin
        # Species
        poke[TPSPECIES]=parseSpecies(poke[TPSPECIES])
      rescue
        raise _INTL("Expected a species name: {1}\r\n{2}",poke[0],FileLineData.linereport)
      end
      # Level
      poke[TPLEVEL]=poke[TPLEVEL].to_i
      raise _INTL("Bad level: {1} (must be from 1-{2})\r\n{3}",poke[TPLEVEL],
        PBExperience::MAXLEVEL,FileLineData.linereport) if poke[TPLEVEL]<=0 || poke[TPLEVEL]>PBExperience::MAXLEVEL
      # Held item
      if !poke[TPITEM] || poke[TPITEM]==""
        poke[TPITEM]=TPDEFAULTS[TPITEM]
      else
        poke[TPITEM]=parseItem(poke[TPITEM])
      end
      # Moves
      moves=[]
      for j in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        moves.push(parseMove(poke[j])) if poke[j] && poke[j]!=""
      end
      for j in 0...4
        index=[TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4][j]
        if moves[j] && moves[j]!=0
          poke[index]=moves[j]
        else
          poke[index]=TPDEFAULTS[index]
        end
      end
      # Ability
      if !poke[TPABILITY] || poke[TPABILITY]==""
        poke[TPABILITY]=TPDEFAULTS[TPABILITY]
      else
        poke[TPABILITY]=poke[TPABILITY].to_i
        raise _INTL("Bad abilityflag: {1} (must be 0 or 1 or 2-5)\r\n{2}",poke[TPABILITY],FileLineData.linereport) if poke[TPABILITY]<0 || poke[TPABILITY]>5
      end
      # Gender
      if !poke[TPGENDER] || poke[TPGENDER]==""
        poke[TPGENDER]=TPDEFAULTS[TPGENDER]
      else
        if poke[TPGENDER]=="M"
          poke[TPGENDER]=0
        elsif poke[TPGENDER]=="F"
          poke[TPGENDER]=1
        else
          poke[TPGENDER]=poke[TPGENDER].to_i
          raise _INTL("Bad genderflag: {1} (must be M or F, or 0 or 1)\r\n{2}",poke[TPGENDER],FileLineData.linereport) if poke[TPGENDER]<0 || poke[TPGENDER]>1
        end
      end
      # Form
      if !poke[TPFORM] || poke[TPFORM]==""
        poke[TPFORM]=TPDEFAULTS[TPFORM]
      else
        poke[TPFORM]=poke[TPFORM].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\r\n{2}",poke[TPFORM],FileLineData.linereport) if poke[TPFORM]<0
      end
      # Shiny
      if !poke[TPSHINY] || poke[TPSHINY]==""
        poke[TPSHINY]=TPDEFAULTS[TPSHINY]
      elsif poke[TPSHINY]=="shiny"
        poke[TPSHINY]=true
      else
        poke[TPSHINY]=csvBoolean!(poke[TPSHINY].clone)
      end
      # Nature
      if !poke[TPNATURE] || poke[TPNATURE]==""
        poke[TPNATURE]=TPDEFAULTS[TPNATURE]
      else
        poke[TPNATURE]=parseNature(poke[TPNATURE])
      end
      # IVs
      if !poke[TPIV] || poke[TPIV]==""
        poke[TPIV]=TPDEFAULTS[TPIV]
      else
        poke[TPIV]=poke[TPIV].to_i
        raise _INTL("Bad IV: {1} (must be from 0-31)\r\n{2}",poke[TPIV],FileLineData.linereport) if poke[TPIV]<0 || poke[TPIV]>31
      end
      # Happiness
      if !poke[TPHAPPINESS] || poke[TPHAPPINESS]==""
        poke[TPHAPPINESS]=TPDEFAULTS[TPHAPPINESS]
      else
        poke[TPHAPPINESS]=poke[TPHAPPINESS].to_i
        raise _INTL("Bad happiness: {1} (must be from 0-255)\r\n{2}",poke[TPHAPPINESS],FileLineData.linereport) if poke[TPHAPPINESS]<0 || poke[TPHAPPINESS]>255
      end
      # Nickname
      if !poke[TPNAME] || poke[TPNAME]==""
        poke[TPNAME]=TPDEFAULTS[TPNAME]
      else
        poke[TPNAME]=poke[TPNAME].to_s
        raise _INTL("Bad nickname: {1} (must be 1-20 characters)\r\n{2}",poke[TPNAME],FileLineData.linereport) if (poke[TPNAME].to_s).length>20
      end
      # Shadow
      if !poke[TPSHADOW] || poke[TPSHADOW]==""
        poke[TPSHADOW]=TPDEFAULTS[TPSHADOW]
      else
        poke[TPSHADOW]=csvBoolean!(poke[TPSHADOW].clone)
      end
      # Ball
      if !poke[TPBALL] || poke[TPBALL]==""
        poke[TPBALL]=TPDEFAULTS[TPBALL]
      else
        poke[TPBALL]=poke[TPBALL].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\r\n{2}",poke[TPBALL],FileLineData.linereport) if poke[TPBALL]<0
      end
      pkmn.push(poke)
    end
    i+=3+numpoke
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
    trainers.push([trainername,name,realitems,pkmn,partyid])
    nameoffset+=name.length
  end
  save_data(trainers,"Data/tourtrainers.dat")
end

#-------------------------------------------------------------------------------
# PWT battle rules
#-------------------------------------------------------------------------------
class RestrictSpecies
  
  def initialize(banlist)
    @specieslist = []
    for species in banlist
      if species.is_a?(Numeric)
        @specieslist.push(species)
        next
      elsif species.is_a?(Symbol)
        @specieslist.push(getConst(PBSpecies,species))
      end
    end
  end
  
  def isSpecies?(species,specieslist)
    for s in specieslist
      return true if species == s
    end
    return false  
  end
  
  def isValid?(pokemon)
    count = 0
    egg = pokemon.respond_to?(:egg?) ? pokemon.egg? : pokemon.isEgg?
    if isSpecies?(pokemon.species,@specieslist) && !egg
      count += 1
    end
    return count == 0
  end
end
#-------------------------------------------------------------------------------
# Extra functionality added to the Trainer class
#-------------------------------------------------------------------------------
class PokeBattle_Trainer
  attr_accessor :lobby_trainer

  def battle_points
    @battle_points = 0 if @battle_points.nil?
    return @battle_points
  end
  def battle_points=(value)
    @battle_points = value
    return @battle_points
  end


  #beaten vips
  def vips
    @beaten_vips = [] if @beaten_vips == nil
    return @beaten_vips
  end

end

BATTLE_POINT_PRICES = {
  #effects in battle
  PBItems::CHOICEBAND => 20,
  PBItems::CHOICESPECS => 20,
  PBItems::CHOICESCARF => 20,
  PBItems::HEATROCK => 30,
  PBItems::DAMPROCK => 30,
  PBItems::SMOOTHROCK => 30,
  PBItems::ICYROCK => 30,
  PBItems::LIGHTCLAY => 30,
  PBItems::GRIPCLAW => 30,
  PBItems::WHITEHERB => 30,
  PBItems::POWERHERB => 30,
  PBItems::MENTALHERB => 30,
  PBItems::LEFTOVERS => 30,
  PBItems::SHELLBELL => 30,
  PBItems::BLACKSLUDGE => 30,
  PBItems::BIGROOT => 30,
  PBItems::EXPERTBELT => 30,
  PBItems::LIFEORB => 30,
  PBItems::ABSORBBULB => 30,
  PBItems::ASSAULTVEST => 30,
  PBItems::BLUNDERPOLICY => 30,
  PBItems::WEAKNESSPOLICY => 30,
  PBItems::METRONOME => 30,
  PBItems::MUSCLEBAND => 30,
  PBItems::WISEGLASSES => 30,
  PBItems::RAZORCLAW => 30,
  PBItems::SCOPELENS => 30,
  PBItems::WIDELENS => 30,
  PBItems::ZOOMLENS => 30,
  PBItems::RAZORFANG => 30,
  PBItems::LAGGINGTAIL => 30,
  PBItems::QUICKCLAW => 30,
  PBItems::FOCUSBAND => 30,
  PBItems::FOCUSSASH => 30,
  PBItems::FLAMEORB => 30,
  PBItems::TOXICORB => 30,
  PBItems::STICKYBARB => 30,
  PBItems::IRONBALL => 30,
  PBItems::RINGTARGET => 30,
  PBItems::CHARCOAL => 30,
  PBItems::MYSTICWATER => 30,
  PBItems::MAGNET => 30,
  PBItems::REDCARD => 30,
  PBItems::FLOATSTONE => 30,
  PBItems::EJECTBUTTON => 30,
  PBItems::SHEDSHELL => 30,
  PBItems::BRIGHTPOWDER => 30,
  PBItems::DESTINYKNOT => 30,
  PBItems::SNOWBALL => 30,
  PBItems::LUMINOUSMOSS => 30,
  PBItems::THROATSPRAY => 30,
  PBItems::ROOMSERVICE => 30,
  PBItems::PINKSTONE => 180,

  #Pokemon modification items
  PBItems::ABILITYCAPSULE => 30,
  PBItems::ABILITYPATCH => 60,
  PBItems::BOTTLECAP => 10,
  PBItems::GOLDBOTTLECAP => 50,
  PBItems::RARECANDY => 4,
  PBItems::SUPERRARECANDY => 16,
  PBItems::ULTRARARECANDY => 24,
  PBItems::ADAMANTMINT => 8,
  PBItems::BOLDMINT => 8,
  PBItems::BRAVEMINT => 8,
  PBItems::CALMMINT => 8,
  PBItems::CAREFULMINT => 8,
  PBItems::GENTLEMINT => 8,
  PBItems::HASTYMINT => 8,
  PBItems::IMPISHMINT => 8,
  PBItems::JOLLYMINT => 8,
  PBItems::LAXMINT => 8,
  PBItems::LONELYMINT => 8,
  PBItems::MILDMINT => 8,
  PBItems::MODESTMINT => 8,
  PBItems::NAIVEMINT => 8,
  PBItems::NAUGHTYMINT => 8,
  PBItems::QUIETMINT => 8,
  PBItems::RASHMINT => 8,
  PBItems::RELAXEDMINT => 8,
  PBItems::SASSYMINT => 8,
  PBItems::SERIOUSMINT => 8,
  PBItems::TIMIDMINT => 8,
  PBItems::IVHERBHP => 4,
  PBItems::IVHERBATK => 4,
  PBItems::IVHERBDEF => 4,
  PBItems::IVHERBSPA => 4,
  PBItems::IVHERBSPD => 4,
  PBItems::IVHERBSPE => 4,

  # 3 tornei 1 mega
  PBItems::VENUSAURITE => 50,
  PBItems::BLASTOISINITE => 50,
  PBItems::CHARIZARDITET => 50,
  PBItems::CHARIZARDITEX => 50,
  PBItems::WEAVILITE => 50,
  PBItems::SCEPTILITE => 50,
  PBItems::AUDINITE => 50,
  PBItems::BELLOSSOMITE => 50,
  PBItems::SHIFTRYITE => 50,
  PBItems::MAWILITE =>50,
  PBItems::ABSOLITE =>50,

  PBItems::ALAKAZITE => 50,
  PBItems::SCIZORITE => 50,
  PBItems::HERACRONITE => 50,
  PBItems::TYRANITARITE => 50,
  PBItems::BLAZIKENITE => 50,
  PBItems::SWAMPERTITE => 50,
  PBItems::GARCHOMPITE => 50,
  PBItems::LUCARITE => 50,
  PBItems::LUXRAYITE => 50,
  PBItems::MIENSHAOITE => 50,
  
  PBItems::RAMPARDITE => 50,
  PBItems::ARCANITE => 50,
  PBItems::GENGARITE => 50,
  PBItems::GARDEVOIRITE => 50,
  PBItems::ALTARIANITE => 50,
  PBItems::MEWTWONITEX => 50,
}
#Tutors:
#Tutor 1: :DRAGONENDURANCE,:VELVETSCALES,:ACIDRAIN,:TAILWIND,:OUTRAGE,:AIRCUTTER,:HURRICANE
#Tutor 2: :ZENHEADBUTT,:FIREPUNCH,:ICEPUNCH,:THUNDERPUNCH,:FOCUSPUNCH,:DRAGONPULSE,:IRONTAIL
#Tutor 3: :SNORE,:STEALTHROCK,:SUPERFANG,:SUPERPOWER,:WATERPULSE,:UPROAR,:SKYATTACK
def pbMoveTutor(movepool=[],name="") #remember to use max 7
  moves=movepool
  movecmd = []
  for m in moves
    echoln getConst(PBMoves,m)
    echoln PBMoves.getName(getConst(PBMoves,m))
    movecmd.push(PBMoves.getName(getConst(PBMoves,m)))
  end
  #Kernel.pbMessage(_INTL("Che mossa vuoi che insegni ai tuoi Pokémon?"))
  #Kernel.pbShowCommands(nil,movecmd,-1,0)
  rt = pbNewChoice(Fullbox_Option.createFromArray(movecmd),-1)

  if rt>-1
    fbNewMugshot(name,"allenatori/karateka","default",:left)
    fbEnable(true)
    fbText("A quale Pokémon vuoi che insegni questa mossa?")
    fbEnable(false)
    fbDispose()
    if pbMoveTutorChoose(getConst(PBMoves,moves[rt]))
      fbNewMugshot(name,"allenatori/karateka","default",:left)
      fbEnable(true)
      fbText("Se vuoi che insegni qualche altra mossa ad un tuo Pokémon, sai dove trovarmi.")
      fbEnable(false)
      fbDispose()
    else
      fbNewMugshot(name,"allenatori/karateka","default",:left)
      fbEnable(true)
      fbText("È un peccato. Torna se vuoi che insegni qualche mossa ad un tuo Pokémon.")
      fbEnable(false)
      fbDispose()
    end
  else
    fbNewMugshot(name,"allenatori/karateka","default",:left)
    fbEnable(true)
    fbText("È un peccato. Torna se vuoi che insegni qualche mossa ad un tuo Pokémon.")
    fbEnable(false)
    fbDispose()
  end

end

def pbGetMegaShopList()
  list = [:VENUSAURITE,:BLASTOISINITE,:CHARIZARDITET,:CHARIZARDITEX,:WEAVILITE,:ABSOLITE,:MAWILITE,:ALAKAZITE,
          :HERACRONITE,:TYRANITARITE,:BLAZIKENITE,:SWAMPERTITE,:GARCHOMPITE]
  list.push(:ALTARIANITE) if $game_switches[1448]==true
  list.push(:GARDEVOIRITE) if $game_switches[1449]==true
  list.push(:SCEPTILITE) if $game_switches[1176]==true
  list.push(:BELLOSSOMITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::ERIKATOURNAMENT,"Erika"]]]==true
  list.push(:AUDINITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::LEOTOURNAMENT,"Leo"]]]==true
  list.push(:SHIFTRYITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::DANTETOURNAMENT,"Dante"]]]==true
  
  list.push(:LUCARITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::GLADIONTOURNAMENT,"Iridio"]]]==true
  list.push(:SCIZORITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::SOTISTOURNAMENT,"Sotis"]]]==true
  list.push(:LUXRAYITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::STELLATOURNAMENT,"Stella"]]]==true
  list.push(:MIENSHAOITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::GRETATOURNAMENT,"Valentina"]]]==true
  
  list.push(:ARCANITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::SOLETOURNAMENT,"Sole"]]] == true
  list.push(:RAMPARDITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::LINNEATOURNAMENT,"Lin & Nea"]]] == true
  list.push(:GENGARITE) if $game_switches[VIPCUPSWITCH[[PBTrainers::VELIATOURNAMENT,"Velia"]]] == true
  list.push(:MEWTWONITEX) if $game_switches[1450]
  return list
end

def pbGetFightShopList()
  return [
    PBItems::CHOICEBAND,
    PBItems::CHOICESPECS,
    PBItems::CHOICESCARF,
    PBItems::HEATROCK,
    PBItems::DAMPROCK,
    PBItems::SMOOTHROCK,
    PBItems::ICYROCK,
    PBItems::LIGHTCLAY,
    PBItems::GRIPCLAW,
    PBItems::WHITEHERB,
    PBItems::POWERHERB,
    PBItems::MENTALHERB,
    PBItems::LEFTOVERS,
    PBItems::SHELLBELL,
    PBItems::BLACKSLUDGE,
    PBItems::BIGROOT,
    PBItems::EXPERTBELT,
    PBItems::LIFEORB,
    PBItems::ABSORBBULB,
    PBItems::ASSAULTVEST,
    PBItems::BLUNDERPOLICY,
    PBItems::WEAKNESSPOLICY,
    PBItems::METRONOME,
    PBItems::MUSCLEBAND,
    PBItems::WISEGLASSES,
    PBItems::RAZORCLAW,
    PBItems::SCOPELENS,
    PBItems::WIDELENS,
    PBItems::ZOOMLENS,
    PBItems::RAZORFANG,
    PBItems::LAGGINGTAIL,
    PBItems::QUICKCLAW,
    PBItems::FOCUSBAND,
    PBItems::FOCUSSASH,
    PBItems::FLAMEORB,
    PBItems::TOXICORB,
    PBItems::STICKYBARB,
    PBItems::IRONBALL,
    PBItems::RINGTARGET,
    PBItems::CHARCOAL,
    PBItems::MYSTICWATER,
    PBItems::MAGNET,
    PBItems::REDCARD,
    PBItems::FLOATSTONE,
    PBItems::EJECTBUTTON,
    PBItems::SHEDSHELL,
    PBItems::BRIGHTPOWDER,
    PBItems::DESTINYKNOT,
    PBItems::SNOWBALL,
    PBItems::LUMINOUSMOSS,
    PBItems::THROATSPRAY,
    PBItems::ROOMSERVICE,
    PBItems::PINKSTONE]
end

def pbBottleCapChoice()
  commands = {}
  commands[_INTL("Tappi d'oro: {1}",$PokemonBag.pbQuantity(:GOLDBOTTLECAP))]=827 if $PokemonBag.pbQuantity(:GOLDBOTTLECAP)>0
  commands[_INTL("Tappi d'argento: {1}",$PokemonBag.pbQuantity(:BOTTLECAP))]=826 if $PokemonBag.pbQuantity(:BOTTLECAP)>0
  return false if commands.size<=0

  cmd = commands.keys
  rt = pbNewChoice(Fullbox_Option.createFromArray(cmd),-1)#Kernel.pbShowCommands(nil,cmd,-1)

  echoln "#{rt} #{rt <= -1} #{commands[cmd[rt]]}"
  pbSet(40,commands[cmd[rt]]) if !(rt <= -1)
  return rt > -1
end

def pbMTShopList()
  mts=[]
  for i in 1..95
    
    mt = "TM#{"%02d" % i}".to_sym
    #echoln "#{mt} #{getConst(PBItems,mt)}"
    mts.push(mt) if $PokemonBag.pbQuantity(mt)==0

  end
  echoln mts
  return mts
end

def pbChooseIVTrainingStat(poke)
  commands = {}
  cmd = []
  if poke.iv[0]<31
    cmd.push(_INTL("PS"))
    commands[_INTL("PS")] = 0
  end
  if poke.iv[1]<31
    cmd.push(_INTL("Attacco"))
    commands[_INTL("Attacco")] = 1 
  end
  if poke.iv[2]<31
    cmd.push(_INTL("Difesa"))
    commands[_INTL("Difesa")] = 2 
  end
  if poke.iv[4]<31
    cmd.push(_INTL("Attacco Speciale"))
    commands[_INTL("Attacco Speciale")] = 4 
  end
  if poke.iv[5]<31
    cmd.push(_INTL("Difesa Speciale"))
    commands[_INTL("Difesa Speciale")] = 5 
  end
  if poke.iv[3]<31
    cmd.push(_INTL("Velocità"))
    commands[_INTL("Velocità")] = 3 
  end

  ret = pbNewChoice(Fullbox_Option.createFromArray(cmd),-1) 
  #Setting the appropriate IV
  if ret>=0
    poke.iv[commands[cmd[ret]]] = 31
    poke.calcStats
  end
  return ret>=0
end

def pbPokemonTournamentMart(stock,speech=nil,cantsell=false)
  for i in 0...stock.length
    stock[i]=getID(PBItems,stock[i]) if !stock[i].is_a?(Integer)
    if !stock[i] || stock[i]==0 ||
       (pbIsImportantItem?(stock[i]) && $PokemonBag.pbQuantity(stock[i])>0)
      stock[i]=nil
    end
  end
  stock.compact!
  commands=[]
  cmdBuy=-1
  cmdSell=-1
  cmdQuit=-1
  commands[cmdBuy=commands.length]=_INTL("Buy")
  commands[cmdQuit=commands.length]=_INTL("Quit")
  cmd=Kernel.pbMessage(
     speech ? speech : _INTL("Welcome!\r\nHow may I serve you?"),
     commands,cmdQuit+1)
  loop do
    if cmdBuy>=0 && cmd==cmdBuy
      scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,stock,true)
      screen.pbBuyScreen
    else
      Kernel.pbMessage(_INTL("Please come again!"))
      break
    end
    cmd=Kernel.pbMessage(
       _INTL("Is there anything else I can help you with?"),commands,cmdQuit+1)
  end
  $game_temp.clear_mart_prices
end

#===============================================================================
#  Tournament Script by
#     xZekro51:.
#    v.1.0
#
#===============================================================================
$rivalBattleID=0
STANDARD_POOL = [
  #NORMALI
  ["Ranger femmina 1",PBTrainers::RANGERF,"Solana",_INTL("Per poco!"),0],
  ["montanaro",PBTrainers::MONTANARO,"Alfio",_INTL("Peccato! Avrei dovuto passare meno tempo a passeggiare..."),0],
  ["allenatore-campeggiatore",PBTrainers::CAMPEGGIATORE,"Girolamo",_INTL("A quanto pare non ho viaggiato abbastanza!"),0],
  ["arturo bidello",PBTrainers::BIDELLO,"Natale",_INTL("Che hai detto? Non ci sento molto!"),0],
  ["scagnozzo evan 1",PBTrainers::SCAGNOZZO1,"Tommaso",_INTL("Che botta..."),0],
  ["indianokid",PBTrainers::INDIANOKID,"Hakan",_INTL("Owch... Non sono ancora abbastanza forte..."),0],
  ["pescatore",PBTrainers::PESCATORE,"Ernesto",_INTL("C'ero quasi!"),0],
  ["allenatore-campeggiatore",PBTrainers::CAMPEGGIATORE,"Marco",_INTL("C'ero quasi!"),0],
  ["redneckm",PBTrainers::REDNECKM,"Fulvio",_INTL("C'ero quasi!"),0],
  ["allenatore-rugbista",PBTrainers::RUGBY,"Otto",_INTL("C'ero quasi!"),0],
  ["mascheragym",PBTrainers::CONSIGLIERE,"Oris",_INTL("C'ero quasi!"),0],
  ["karateka",PBTrainers::CINTURANERA,"Kenji",_INTL("C'ero quasi!"),0],
  ["montanaro",PBTrainers::MONTANARO,"Giuseppe",_INTL("C'ero quasi!"),0],
  ["archeologo",PBTrainers::ARCHEOLOGO,"Gustavo",_INTL("C'ero quasi!"),0],
  ["pokéfanatico",PBTrainers::POKEFAN,"Tullio",_INTL("C'ero quasi!"),0],
  ["pellerossaf",PBTrainers::INDIANA,"Awentia",_INTL("C'ero quasi!"),0],
  ["fashionbloggerm",PBTrainers::MANAGER,"Josh",_INTL("C'ero quasi!"),0],
  ["deejay",PBTrainers::DEEJAYM,"Zago",_INTL("C'ero quasi!"),0]
]

TRAINERPOOL_basic=[  #ALMENO 8 ALLENATORI
  #SPECIALI
  ["will",PBTrainers::WILLTOURNAMENT,"Will",_INTL("Devo allenarmi di più!"),3],
  ["alexandra",PBTrainers::VERBENATOURNAMENT,"Verbena",_INTL("Pare che la corrente mi abbia trascinato via!"),4],
  ["wallace",PBTrainers::WALLACETOURNAMENT,"Wallace Daddy",_INTL("Sono stato annientato dal tuo beat!"),4],
  ["reclutafside",PBTrainers::TEAMDIMENSIONF,"T3S",_INTL("Screanzato!"),1],
  ["minside",PBTrainers::MINTOURNAMENT,"Min",_INTL("Mun, ho fallito!"),2],
  ["Gennaro Bullo",PBTrainers::GENNAROTOURNAMENT,"Gennaro",_INTL("Non di nuovo!"),5],
  #PASS 4
  ["alisso",PBTrainers::ALISSOTOURNAMENT,"Alisso",_INTL("...!"),3],
  ["Munside",PBTrainers::MUNTOURNAMENT,"Mun",_INTL("Min, non ce l'ho fatta!"),4],
  ["silvia",PBTrainers::SILVIATOURNAMENT,"Silvia",_INTL("Caliente come sempre!"),4],
  ["S",PBTrainers::SIGMATOURNAMENT,"S",_INTL("Oh diamine!"),1],
  ["crisante_walk",PBTrainers::CRISANTETOURNAMENT,"Crisante",_INTL("Qual verso potrà mai calmare la mia frustrazione?"),2],
  #["trey",PBTrainers::TREYTOURNAMENT,"Trey",_INTL("Hmph! La prossima volta vincerò io!"),5],
]

for i in STANDARD_POOL
  TRAINERPOOL_basic << i if !TRAINERPOOL_basic.include?(i)
end

TRAINERPOOL_hard=[
  
]  #ALMENO 16 ALLENATORI

for i in TRAINERPOOL_basic
  TRAINERPOOL_hard.push(i) if !TRAINERPOOL_hard.include?(i)
end

TRAINERPOOL_expert=[]  #ALMENO 32 ALLENATORI

TRAINERPOOL_DREAM=[
  ["Looker",PBTrainers::BELLOCCHIOTOURNAMENT,"Bellocchio",_INTL("Devo allenarmi di più!"),3],
  ["Padre",PBTrainers::VERSIL,"Versil",_INTL("Devo allenarmi di più!"),4],
  ["Victor",PBTrainers::WILLTOURNAMENT,"Will",_INTL("Devo allenarmi di più!"),3],
  ["trey",PBTrainers::TREYTOURNAMENT,"Trey",_INTL("Hmph! La prossima volta vincerò io!"),5],
  ["Chua",PBTrainers::WILLTOURNAMENT,"Will",_INTL("Devo allenarmi di più!"),3],
  ["Aster",PBTrainers::WILLTOURNAMENT,"Will",_INTL("Devo allenarmi di più!"),4],
  ["Oleandro",PBTrainers::WILLTOURNAMENT,"Will",_INTL("Devo allenarmi di più!"),3],
]

LANCEPOOL=[
  ["lance",PBTrainers::LANCETOURNAMENT,"Lance",_INTL("Pare che il mio lungo allenamento non sia bastato..."),10],
]

DANTEPOOL=[
  ["Dante",PBTrainers::DANTETOURNAMENT,"Dante",_INTL("La prossima volta non andrà così!"),10],
]

LEOPOOL=[
  ["Leo",PBTrainers::LEOTOURNAMENT,"Leo",_INTL("Cavoli!"),10],
]

ERIKAPOOL=[
  ["Erika",PBTrainers::ERIKATOURNAMENT,"Erika",_INTL("Perbacco, chi l'avrebbe mai detto?"),10],
]

STELLAPOOL=[
  ["Stella",PBTrainers::STELLATOURNAMENT,"Stella",_INTL("Incredibile! Sei abbagliante!"),10],
]

SOTISPOOL=[
  ["clawman",PBTrainers::SOTISTOURNAMENT,"Sotis",_INTL("Devo impegnarmi di più se voglio sconfiggere Masquerman...!"),10],
]

GLADIONPOOL=[
  ["Iridio",PBTrainers::GLADIONTOURNAMENT,"Iridio",_INTL("Forse dovrei ricominciare ad allenarmi?"),10],
]

GRETAPOOL=[
  ["valentina",PBTrainers::GRETATOURNAMENT,"Valentina",_INTL("Ancora niente..."),10],
]

VELIAPOOL=[
  ["Roxie",PBTrainers::VELIATOURNAMENT,"Velia",_INTL("Che assolo fantastico!"),10],
]

LINNEAPOOL=[
  ["linnea",PBTrainers::LINNEATOURNAMENT,"Lin & Nea",_INTL("Lin: Che diamine fai, Nea!\nNea: Hah, come se fosse colpa mia!"),10],
]

SOLEPOOL=[
  ["lance",PBTrainers::LANCETOURNAMENT,"Lance",_INTL("Pare che il mio lungo allenamento non sia bastato..."),10],
  ["Dante",PBTrainers::DANTETOURNAMENT,"Dante",_INTL("La prossima volta non andrà così!"),10],
  ["Leo",PBTrainers::LEOTOURNAMENT,"Leo",_INTL("Cavoli!"),10],
  ["Erika",PBTrainers::ERIKATOURNAMENT,"Erika",_INTL("Perbacco, chi l'avrebbe mai detto?"),10],
  ["Stella",PBTrainers::STELLATOURNAMENT,"Stella",_INTL("Incredibile! Sei abbagliante!"),10],
  ["clawman",PBTrainers::SOTISTOURNAMENT,"Sotis",_INTL("Devo impegnarmi di più se voglio sconfiggere Masquerman...!"),10],
  ["Iridio",PBTrainers::GLADIONTOURNAMENT,"Iridio",_INTL("Forse dovrei ricominciare ad allenarmi?"),10],
  ["valentina",PBTrainers::GRETATOURNAMENT,"Valentina",_INTL("Ancora niente..."),10],
  ["Sun",PBTrainers::SOLETOURNAMENT,"Sole",_INTL("...!"),11],
]


#Implementing standard trainers in VIP-specific Pools
for i in STANDARD_POOL
  LANCEPOOL << i if !LANCEPOOL.include?(i)
  DANTEPOOL << i if !DANTEPOOL.include?(i)
  LEOPOOL << i if !LEOPOOL.include?(i)
  ERIKAPOOL << i if !ERIKAPOOL.include?(i)
  STELLAPOOL << i if !STELLAPOOL.include?(i)
  SOTISPOOL << i if !SOTISPOOL.include?(i)
  GLADIONPOOL << i if !GLADIONPOOL.include?(i)
  GRETAPOOL << i if !GRETAPOOL.include?(i)
  VELIAPOOL << i if !VELIAPOOL.include?(i)
  LINNEAPOOL << i if !LINNEAPOOL.include?(i)
end


VIPLIST =[
  [PBTrainers::LANCETOURNAMENT,"Lance"],
  [PBTrainers::ERIKATOURNAMENT,"Erika"],
  [PBTrainers::DANTETOURNAMENT,"Dante"],
  [PBTrainers::LEOTOURNAMENT,"Leo"],
  [PBTrainers::STELLATOURNAMENT,"Stella"],
  [PBTrainers::SOTISTOURNAMENT,"Sotis"],
  [PBTrainers::GRETATOURNAMENT,"Valentina"],
  [PBTrainers::GLADIONTOURNAMENT,"Iridio"],
  [PBTrainers::SOLETOURNAMENT,"Sole"],
  [PBTrainers::VELIATOURNAMENT,"Velia"],
  [PBTrainers::LINNEATOURNAMENT,"Lin & Nea"]
]

VIPCUPSWITCH = {
  [PBTrainers::LANCETOURNAMENT,"Lance"] => 1182,
  [PBTrainers::ERIKATOURNAMENT,"Erika"] => 1181,
  [PBTrainers::DANTETOURNAMENT,"Dante"] => 1183,
  [PBTrainers::LEOTOURNAMENT,"Leo"] => 1184,
  [PBTrainers::STELLATOURNAMENT,"Stella"] => 1344,
  [PBTrainers::SOTISTOURNAMENT,"Sotis"] => 1346,
  [PBTrainers::GRETATOURNAMENT,"Valentina"] => 1347,
  [PBTrainers::GLADIONTOURNAMENT,"Iridio"] => 1345,
  [PBTrainers::SOLETOURNAMENT,"Sole"] => 1445,
  [PBTrainers::VELIATOURNAMENT,"Velia"] => 1446,
  [PBTrainers::LINNEATOURNAMENT,"Lin & Nea"] => 1447
}

VIPSPEECH={
  [PBTrainers::LANCETOURNAMENT,"Lance"] => {
    :mugshot => "apollo/lance",
    :name => "Lance",
    :speech => "Mi sono allenato per anni nella Tana del Drago, e ora sono finalmente pronto per rimettermi in gioco. Fammi vedere di che pasta sei fatto|a!",
    :description => ["Dopo aver perso il titolo di Campione, ha deciso di ritirarsi per affinare ancora di più le sue abilità!","Ora è proprio qui con noi al Torneo Apollo...","L'unico e inimitabile, Lance!"]
  },
  [PBTrainers::DANTETOURNAMENT,"Dante"] => {
    :mugshot => "apollo/dante",
    :name => "Dante",
    :speech => "Ho saputo che sei amico|a di quel sapientone di Claudio! Se sei suo amico, vuol dire che sei un mio nemico|a, fatti sotto!",
    :description => ["È stato espulso dal Campus Ariepoli per la sua indole scontrosa!","Da quel giorno ha formato la sua gang, e ha dominato sui bassifondi di Eldiw!","Il fortissimo e inarrestabile, Dante!"]
  },
  [PBTrainers::ERIKATOURNAMENT,"Erika"] => {
    :mugshot => "apollo/erika",
    :name => "Erika",
    :speech => "Che tempo splendido! È il clima perfetto per una battaglia, preparati!",
    :description => ["La sua leggendaria sbadataggine va oltre i confini di Kanto!","È la maestra del tipo Erba, ma sa come gestire il fuoco!","La calma prima della tempesta, Erika!"]
  },
  [PBTrainers::LEOTOURNAMENT,"Leo"] => {
    :mugshot => "apollo/leo",
    :name => "Leo",
    :speech => "Voglio mettermi alla prova! Sembri anche tu un |'ottimo|a concorrente, quindi facciamoci valere! Che vinca il migliore!",
    :description => ["Porta sulle spalle l'eredità di un nome importante, ma il suo sogno è far capire quanto vale!","Proprio come la madre Chiara, è anche lui un maestro del tipo Normale!","Il fiero e valoroso, Leo!"]
  },
  [PBTrainers::STELLATOURNAMENT,"Stella"] => {
    :mugshot => "apollo/stella",
    :name => "Stella",
    :speech => "Sentivo che Unima mi stava stretta, quindi sono partita per un viaggio! Mostrami ciò che sai fare!",
    :description => ["Tanto bella quanto elettrizzante! La crème de la crème dello stile!","Ha seguito i passi di sua madre Camelia, ma è anche andata molto oltre... Fino a diventare una Superquattro di Unima!","La rapida e brillante, Stella!"]
  },
  [PBTrainers::SOTISTOURNAMENT,"Sotis"] => {
    :mugshot => "apollo/clawman",
    :name => "Sotis",
    :speech => "Sono in viaggio per prepararmi allo scontro finale con la mia nemesi, Masquerman... Aiutami a migliorare!",
    :description => ["Alcuni lo prendono per matto, ma le sue doti attoriali non scherzano!","Sogna di portare il sorriso sui volti delle persone come un Supereroe, per questo si fa chiamare Clawman!","Il possente e tenace, Sotis!"]
  },
  [PBTrainers::GRETATOURNAMENT,"Valentina"] => {
    :mugshot => "apollo/valentina",
    :name => _INTL("Valentina"),
    :speech => "Sento che le arti marziali mi possano aiutare a recuperare la memoria... Forse combattendo contro di te scoprirò qualcosa?",
    :description => ["Un giorno si è risvegliata senza sapere chi fosse...","Da quel momento ha deciso di intraprendere la via delle arti marziali per affinare la sua tecnica!","La misteriosa e calma, Valentina!"]
  },
  [PBTrainers::GLADIONTOURNAMENT,"Iridio"] => {
    :mugshot => "apollo/iridio",
    :name => _INTL("Iridio"),
    :speech => "Sono venuto in questa regione per affari, ma ogni tanto è bello rievocare i vecchi tempi! Sappi che sono molto forte, diamoci dentro!",
    :description => ["Dopo ciò che è accaduto a sua madre, ha preso le redini dell'Aether Paradise facendolo fiorire!","Il peso delle responsabilità lo ha reso un uomo imperturbabile!","L'abilissimo Iridio!"]
  },
  [PBTrainers::VELIATOURNAMENT,"Velia"] => {
    :mugshot => "apollo/roxie",
    :name => _INTL("Velia"),
    :speech => "Preferirei suonare la mia chitarra piuttosto di perdere tempo a lottare... ma per accedere a palchi del genere, non posso tirarmi indietro!",
    :description => ["Nonostante una volta fosse molto più accesa e vivace, il suo carattere ha cambiato genere musicale!","Preferisce rilassarsi e suonare la chitarra, ma con le sue strategie velenose atterra ogni nemico!","L'ingegnosa e astuta, Velia!"]
  },
  [PBTrainers::LINNEATOURNAMENT,"Lin & Nea"] => {
    :mugshot => "apollo/linnea",
    :name => _INTL("Lin & Nea"),
    :speech => "Ehi tu! Non credere di poterci fermare! Se c'è una cosa che accomuna noi due, è la perseveranza!",
    :description => ["Dalla lontana Sinnoh, i due incredibili archeologhi che scavarono il Tunnel Rovine in pochissimo tempo!","Questi due gemelli sono in continua competizione, e nonostante ciò si guardano le spalle l'un l'altro!","La coppia che scoppia, Lin e Nea!"]
  },
  [PBTrainers::SOLETOURNAMENT,"Sole"] => {
    :mugshot => "apollo/sole",
    :name => _INTL("Sole"),
    :speech => "Se c'è una regione che non conosco, devo assolutamente esplorarla! Dopo tutto, devo acchiapparli tutti! Mi sbaglio?",
    :description => ["Le sue gesta hanno fatto il giro del mondo! Ha vinto innumerevoli sfide delle palestre e sgominato bande criminali!","Nonostante la sua giovane età, è già un'allenatrice di Rango Campione!","La mitica e leggendaria, Sole!"]
  }
}

MUSTINCLUDE = {
  LANCEPOOL => [PBTrainers::LANCETOURNAMENT,"Lance"],
  DANTEPOOL => [PBTrainers::DANTETOURNAMENT,"Dante"],
  ERIKAPOOL => [PBTrainers::ERIKATOURNAMENT,"Erika"],
  LEOPOOL =>   [PBTrainers::LEOTOURNAMENT,"Leo"],
  STELLAPOOL => [PBTrainers::STELLATOURNAMENT,"Stella"],
  SOTISPOOL => [PBTrainers::SOTISTOURNAMENT,"Sotis"],
  GRETAPOOL => [PBTrainers::GRETATOURNAMENT,"Valentina"],
  GLADIONPOOL => [PBTrainers::GLADIONTOURNAMENT,"Iridio"],
  VELIAPOOL => [PBTrainers::VELIATOURNAMENT,"Velia"],
  LINNEAPOOL => [PBTrainers::LINNEATOURNAMENT,"Lin & Nea"],
  SOLEPOOL => [PBTrainers::SOLETOURNAMENT,"Sole"],
}

SKILL_LEVELS={
  #VIP
  PBTrainers::LANCETOURNAMENT=>127,
  PBTrainers::DANTETOURNAMENT=>127,
  PBTrainers::ERIKATOURNAMENT=>127,
  PBTrainers::LEOTOURNAMENT=>127,
  PBTrainers::STELLATOURNAMENT=>127,
  PBTrainers::SOTISTOURNAMENT=>127,
  PBTrainers::GRETATOURNAMENT=>127,
  PBTrainers::GLADIONTOURNAMENT=>127,
  PBTrainers::VELIATOURNAMENT=>127,
  PBTrainers::LINNEATOURNAMENT=>127,
  PBTrainers::SOLETOURNAMENT=>127,

  #SPECIAL
  PBTrainers::WILLTOURNAMENT=>127,
  PBTrainers::VERBENATOURNAMENT=>127,
  PBTrainers::WALLACETOURNAMENT=>127,
  PBTrainers::TEAMDIMENSIONF=>127,
  PBTrainers::MINTOURNAMENT=>127,
  PBTrainers::GENNARO=>127,

  PBTrainers::ALISSOTOURNAMENT=>127,
  PBTrainers::MUNTOURNAMENT=>127,
  PBTrainers::TREYTOURNAMENT=>127,
  PBTrainers::SIGMATOURNAMENT=>127,
  PBTrainers::CRISANTETOURNAMENT=>127,
  PBTrainers::SILVIATOURNAMENT=>127,

  #NORMAL

  PBTrainers::RANGERF=>100,
  PBTrainers::MONTANARO=>100,
  PBTrainers::CAMPEGGIATORE=>100,
  PBTrainers::BIDELLO=>100,
  PBTrainers::SCAGNOZZO1=>100,
  PBTrainers::INDIANOKID=>100,
  PBTrainers::PESCATORE=>100,
  PBTrainers::REDNECKM=>100,
  PBTrainers::RUGBY=>100,
  PBTrainers::CONSIGLIERE=>100,
  PBTrainers::CINTURANERA=>100,
  PBTrainers::ARCHEOLOGO=>100,
  PBTrainers::POKEFAN=>100,
  PBTrainers::INDIANA=>100,
  PBTrainers::MANAGER=>100,
}

BAN_LIST=[:LUXFLON,:GENESECT,:MEW,:MEWTWOX,:LUGIA,:HOOH,:DEOXYS,
          :MEWVINTAGE,:LUGIAVINTAGE,:HOOHVINTAGE,:MEWTWO,:DRAGALISKFURIA,
          :REGIROCK,:REGICE,:REGISTEEL,:REGINALOUS,:REGIGIGAS]

REWARDPOOL=[:BOTTLECAP,:RARECANDY,:ADAMANTMINT,:BOLDMINT,:BRAVEMINT,:CALMMINT,:CAREFULMINT,:GENTLEMINT,
  :HASTYMINT,:IMPISHMINT,:JOLLYMINT,:LAXMINT,:LONELYMINT,:MILDMINT,:MODESTMINT,:NAIVEMINT,:NAUGHTYMINT,
  :QUIETMINT,:RASHMINT,:RELAXEDMINT,:SASSYMINT,:SERIOUSMINT,:TIMIDMINT]
REWARDLOSINGPOOL=[:FULLHEAL,:FULLRESTORE,:POMEGBERRY,:KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABARRY,:TAMATOBERRY]

TOURNAMENT_OPPONENT_EVENT_ID = 54
TOURNAMENT_EVENT_ID = 56
TOURNAMENT_DREAM_PRE = 57
TOURNAMENT_DREAM_POST = 58

TOURNAMENT_LOCKER_MAP_ID = 622
TOURNAMENT_STADIUM_MAP_ID = 623

def pbGetPlayerWalkingChar
  meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
  return pbGetPlayerCharset(meta,1)
end


################################################################################
# Extra function to Trainer class
################################################################################
class PokeBattle_Trainer
  #attr_accessor :battle_points
  attr_accessor :lobby_trainer
  attr_accessor :pw
end

$DEBUG = true

def moveStars(leftStar,rightStar)
  rightStar.oy+=2
  rightStar.borderX=-(512-310)
  rightStar.borderY=100

  leftStar.oy-=2
  leftStar.borderX=-(512-310)
  leftStar.borderY=100
end

def pbTestMas

  #Initializing graphics element as well as starting animation
  v=Viewport.new(0,0,Graphics.width,Graphics.height)
  v.z=99999

  @v=v
  @sprites={}

  Graphics.frame_rate=60

  @sprites["darken"] = EAMSprite.new(v)
  @sprites["darken"].bitmap = Bitmap.new(512,384)
  @sprites["darken"].bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
  @sprites["darken"].opacity = 0


  @sprites["leftbg"]=EAMSprite.new(v)
  @sprites["leftbg"].bitmap=pbBitmap("Graphics/Pictures/STour/leftGradient")
  @sprites["leftbg"].x=-512#512/4

  @sprites["leftStar"]=TournamentPlane.new(v)
  @sprites["leftStar"].bitmap = pbBitmap("Graphics/Pictures/STour/StarAnimBG")
  @sprites["leftStar"].sprite.angle=-17
  @sprites["leftStar"].sprite.y=-210
  
  @sprites["leftStar"].sprite.x=20
  #@sprites["leftStar"].borderX=-(512-320)
  @sprites["leftStar"].borderY=200
  @sprites["leftStar"].sprite.opacity = 0
  
  @sprites["left"]=EAMSprite.new(v)
  @sprites["left"].bitmap=pbBitmap("Graphics/Transitions/smSpecial153")
  #@sprites["left"].x=@sprites["left"].bitmap.width/4
  #@sprites["left"].ox = @sprites["left"].bitmap.width/4
  echoln "#{-@sprites["left"].bitmap.width/5} #{-@sprites["left"].bitmap.width/4}"
  @sprites["left"].mask("Graphics/Pictures/STour/leftGradient", -40)
  @sprites["left"].x=-512

  @sprites["rightbg"]=EAMSprite.new(v)
  @sprites["rightbg"].bitmap=pbBitmap("Graphics/Pictures/STour/rightGradient")
  @sprites["rightbg"].x=512+512
  @sprites["rightbg"].ox = @sprites["rightbg"].bitmap.width

  @sprites["rightStar"]=TournamentPlane.new(v)
  @sprites["rightStar"].bitmap = pbBitmap("Graphics/Pictures/STour/StarAnimBG")
  @sprites["rightStar"].sprite.angle=-17
  @sprites["rightStar"].sprite.y=-170

  @sprites["rightStar"].sprite.x=370
  #@sprites["leftStar"].borderX=-(512-320)
  @sprites["rightStar"].borderY=200
  @sprites["rightStar"].sprite.opacity = 0

  @sprites["right"]=EAMSprite.new(v)
  @sprites["right"].bitmap=pbBitmap("Graphics/Transitions/smSpecial169")
  @sprites["right"].x=512
  @sprites["right"].x=512+512
  @sprites["right"].mask("Graphics/Pictures/STour/rightGradient",40)
  @sprites["right"].ox = @sprites["right"].bitmap.width
  
  @sprites["sep"]=EAMSprite.new(v)
  @sprites["sep"].bitmap=pbBitmap("Graphics/Pictures/STour/Sep")
  @sprites["sep"].ox = @sprites["sep"].bitmap.width/2
  @sprites["sep"].oy = @sprites["sep"].bitmap.height/2
  @sprites["sep"].x = 512/2
  @sprites["sep"].y = 384/2
  @sprites["sep"].zoom_x = 2
  @sprites["sep"].zoom_y = 2
  @sprites["sep"].opacity = 0

  @sprites["versus"]=EAMSprite.new(v)
  @sprites["versus"].bitmap=pbBitmap("Graphics/VS/vs")
  @sprites["versus"].ox = @sprites["versus"].bitmap.width/2
  @sprites["versus"].oy = @sprites["versus"].bitmap.height/2
  @sprites["versus"].x = 512/2
  @sprites["versus"].y = 384/2
  @sprites["versus"].zoom_x = 2
  @sprites["versus"].zoom_y = 2
  @sprites["versus"].opacity = 0

  for i in 0...2
    @sprites["bar#{i}"] = EAMSprite.new(v)
    @sprites["bar#{i}"].bitmap=pbBitmap("Graphics/Pictures/STour/blackBar")
    @sprites["bar#{i}"].oy = i % 2 == 0 ? 0 : @sprites["bar#{i}"].bitmap.height
    @sprites["bar#{i}"].y = i % 2 == 0 ? -@sprites["bar#{i}"].bitmap.height : 384 + @sprites["bar#{i}"].bitmap.height
  end

  val=1


  @sprites["darken"].fade(150,30,:ease_in_cubic)
  20.times do 
    Graphics.update
    Input.update
    @sprites["darken"].update
    
  end

  @sprites["bar0"].move(0,0,20,:ease_in_cubic)
  @sprites["bar1"].move(0,384,20,:ease_in_cubic)
  20.times do
    Graphics.update
    Input.update
    @sprites["darken"].update
    @sprites["bar0"].update
    @sprites["bar1"].update

  end

  @sprites["sep"].fade(255,30,:ease_in_cubic)
  @sprites["sep"].zoom(1,1,30,:ease_in_cubic)

  Kernel.pbMessage("Here we go! The Sunshine Tournament is finally starting!")

  Kernel.pbMessage("Let's take a look at our contestants!")
  
  @sprites["sep"].fade(255,30,:ease_in_cubic)
  @sprites["sep"].zoom(1,1,30,:ease_in_cubic)

  @sprites["right"].move(512,0,20,:ease_in_cubic)
  @sprites["rightbg"].move(512,0,20,:ease_in_cubic)
  30.times do
    Graphics.update
    Input.update
    @sprites["right"].update
    @sprites["rightbg"].update

    @sprites["sep"].update
  end

  @sprites["right"].move(512+10,0,2)
  @sprites["rightbg"].move(512+10,0,2)
  2.times do
    Graphics.update
    Input.update
    @sprites["right"].update
    @sprites["rightbg"].update
  end
  
  @sprites["right"].move(512,0,2)
  @sprites["rightbg"].move(512,0,2)
  2.times do
    Graphics.update
    Input.update
    @sprites["right"].update
    @sprites["rightbg"].update
  end      

  Kernel.pbMessage("On the right! Our most beloved Gym leader, Enzo!")

  @sprites["left"].move(0,0,20,:ease_in_cubic)
  @sprites["leftbg"].move(0,0,20,:ease_in_cubic)
  20.times do
    Graphics.update
    Input.update
    @sprites["left"].update
    @sprites["leftbg"].update
    
  end

  @sprites["left"].move(0-10,0,2)
  @sprites["leftbg"].move(0-10,0,2)
  2.times do
    Graphics.update
    Input.update
    @sprites["left"].update
    @sprites["leftbg"].update
  end
  
  @sprites["left"].move(0,0,2)
  @sprites["leftbg"].move(0,0,2)
  2.times do
    Graphics.update
    Input.update
    @sprites["left"].update
    @sprites["leftbg"].update
  end
  

  Kernel.pbMessage("On the left! Who the hell is he?")

  Kernel.pbMessage("Well, who cares! Now, duke it out!")

  @sprites["versus"].fade(255,20,:ease_in_cubic)
  @sprites["versus"].zoom(1,1,20,:ease_in_cubic)
  20.times do
    Graphics.update
    Input.update
    @sprites["versus"].update
    @sprites["leftStar"].sprite.opacity+=120/20
    @sprites["rightStar"].sprite.opacity+=120/20
    moveStars(@sprites["leftStar"],@sprites["rightStar"])
  end

  loop do 
    Graphics.update
    Input.update

    if (Input.press?(Input::A))
      #@sprites["leftStar"].ox+=2
      @sprites["leftStar"].oy-=2
      @sprites["leftStar"].borderX=-(512-310)
      @sprites["leftStar"].borderY=100
      #@sprites["leftStar"].sprite.mask("Graphics/Pictures/STour/leftGradient")
    elsif (Input.trigger?(Input::C))
      #@sprites["left"].mask("Graphics/Transitions/rightmask")

      #Fade
      

    end

    moveStars(@sprites["leftStar"],@sprites["rightStar"])

    @sprites["versus"].x+=val
    @sprites["versus"].y-=val
    val=1 if @sprites["versus"].x<=(v.rect.width/2)-1
    val=-1 if @sprites["versus"].x>=(v.rect.width/2)+1

    if (Input.press?(Input::RIGHT))
      @sprites["left"].x+=2
      @sprites["leftbg"].x+=2
    elsif (Input.press?(Input::LEFT))
      @sprites["left"].x-=2
      @sprites["leftbg"].x-=2
    end

    if (Input.trigger?(Input::B))
      break
    end
  end
end


class PWT
  
  
  def initialize(player,difficulty,trainerpool=nil,doublebattle=false,testpool=false)
    
    @difficulty = difficulty
    @player = player
    @trainerpool = trainerpool

    @doublebattle = doublebattle

    if $game_switches[1350] && trainerpool != TRAINERPOOL_DREAM
      $game_switches[1350] = false
    end

    if testpool
      @pool = defineChart(player, difficulty, trainerpool)
      @firstPool = @pool
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          @pool = redefineChart(@pool)
        end
        if (Input.trigger?(Input::A))
          showChart()
        end
      end
      return
    end
    @ended = false
    @levels = []
    @party_bak = []
    @battle_type = @doublebattle ? 1 : 0
    #$rivalBattleID=pbRivalStarter
    #player.pw = 0 if !player.pw
    
    player.tournament_wins=0 if player.tournament_wins.nil?
    player.battle_points = 0 if player.battle_points.nil?
    player.winstreak_count=0 if player.winstreak_count.nil?
    player.winstreak = false if player.winstreak.nil?
    @player = player
    # Backing up Party
    self.backupParty
    @newparty = self.choosePokemon
    if @newparty != "notEligible"
      if @newparty != nil
        $Trainer.party = @newparty
        #pbTransferWithTransition(9,16,10,:DIRECTED,6)
        echo $game_player.direction
        event = $game_map.events[4]        
        
        #Initializing the viewport
        @v=Viewport.new(0,0,Graphics.width,Graphics.height)
        @v.z=99990
      else
        Kernel.pbMessage(_INTL("Mi spiace, sarà per la prossima volta!"))
        @ended = true
      end
    else
      Kernel.pbMessage(_INTL("Mi spiace, sarà per la prossima volta!"))
      @ended = true
    end
  end

  def ended?
    echoln "ended? #{@ended}"
    return @ended
  end

  def start
    # Tournament Intro
    pbIntroTournament()
    self.startTournament(@player,@difficulty,@trainerpool)
  end
  
  def pbIntroTournament
    #v=Viewport.new(0,0,Graphics.width,Graphics.height)
    #v.z=99999
    #@sprites={}
    #Initializing graphics element as well as starting animation
    v = @v
    @sprites={}
    @sprites["greybgleft"]=EAMSprite.new(v)
    @sprites["greybgleft"].bitmap=Bitmap.new(256,512)
    @sprites["greybgleft"].bitmap.fill_rect(0,0,256,512,Color.new(16,16,16))
    @sprites["greybgleft"].x=-256
    
    @sprites["greybgright"]=EAMSprite.new(v)
    @sprites["greybgright"].bitmap=Bitmap.new(256,512)
    @sprites["greybgright"].bitmap.fill_rect(0,0,256,512,Color.new(16,16,16))
    @sprites["greybgright"].x=512+256
    
    @sprites["greybgright"].move(256,0,20,:ease_in_cubic)
    @sprites["greybgleft"].move(0,0,20,:ease_in_cubic)

    20.times do 
      @sprites["greybgleft"].update
      @sprites["greybgright"].update
      Graphics.update
      Input.update
    end

    @sprites["greybgright"].move(256+14,0,4)
    @sprites["greybgleft"].move(0-14,0,4)

    4.times do 
      Graphics.update
      Input.update
      @sprites["greybgleft"].update
      @sprites["greybgright"].update
    end

    @sprites["greybgright"].move(256,0,4)
    @sprites["greybgleft"].move(0,0,4)

    4.times do 
      Graphics.update
      Input.update
      @sprites["greybgleft"].update
      @sprites["greybgright"].update
    end


  end
  
  def gengarVipDescription()
    if isOpponentVip?()
      key = [@opponent[1],@opponent[2]]
      for text in VIPSPEECH[key][:description]
        Kernel.pbMessage(_INTL(text))
      end
    end
  end

  def isOpponentVip?
    return false if !@opponent
    return true if VIPLIST.include?([@opponent[1],@opponent[2]])
  end

  def playOpponentIntro
    if $DEBUG==true && Input.press?(Input::CTRL)
      if Kernel.pbConfirmMessage("Skip tournament?")
        @playerwon=true
        endTournament(@playerwon)
        return
      end
    end
    if isOpponentVip?()
      key = [@opponent[1],@opponent[2]]
      fbNewMugshot(VIPSPEECH[key][:name],VIPSPEECH[key][:mugshot],"default",goLeft?() ? :right : :left)
      fbEnable(true)
      fbText(VIPSPEECH[key][:speech])
      fbEnable(false)
      fbDispose()
    end
    
    if $game_switches[1350]
      echoln "running pre dream event"
      $game_map.events[TOURNAMENT_DREAM_PRE].interpreter=Interpreter.new
      $game_map.events[TOURNAMENT_DREAM_PRE].simpleRun
    end

    opponentIntro(@opponent)
    #Starting the battle
    startBattle(@pool)

    #If player won the round but not the tournament
    if @win == true && @playerwon == false
      # Continue the tournament
      @pool = redefineChart(@pool)

      @opponent = @pool[@oppIndex]
      betRounds(@pool)
      
      

      pbTransferWithTransition(TOURNAMENT_LOCKER_MAP_ID,26,18,:DIRECTED,2) {
        pbFadeOutAndHide(@transition)
        pbDisposeSpriteHash(@transition)
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
      }
      #play the event
      #$game_map.events[19].character_name = @opponent[0]
      #$game_map.events[19].turn_left
      #$game_map.events[18].start
    else
      # End the tournament
      endTournament(@playerwon)
    end
  end

  def trainerTypeName(type)   # Name of this trainer type (localized)
    return PBTrainers.getName(type) rescue _INTL("PkMn Trainer")
  end

  def opponentIntro(opponent)
    t_ext = pbResolveBitmap("Graphics/Transitions/smSpecial#{opponent[1]}") ? "Special" : "Trainer"
    bmp = pbBitmap("Graphics/Transitions/sm#{t_ext}#{opponent[1]}")

    echoln opponent


    #Initializing graphics element as well as starting animation
    v=Viewport.new(0,0,Graphics.width,Graphics.height)
    v.z=99995
  
    @v=v
    @transition={}
  
    Graphics.frame_rate=60
  
    @transition["darken"] = EAMSprite.new(v)
    @transition["darken"].bitmap = Bitmap.new(512,384)
    @transition["darken"].bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
    @transition["darken"].opacity = 0
  
  
    @transition["leftbg"]=EAMSprite.new(v)
    @transition["leftbg"].bitmap=pbBitmap("Graphics/Pictures/STour/leftGradient")
    @transition["leftbg"].x=-512#512/4
  
    @transition["leftStar"]=TournamentPlane.new(v)
    @transition["leftStar"].bitmap = pbBitmap("Graphics/Pictures/STour/StarAnimBG")
    @transition["leftStar"].sprite.angle=-17
    @transition["leftStar"].sprite.y=-210
    
    @transition["leftStar"].sprite.x=20
    @transition["leftStar"].borderY=200
    @transition["leftStar"].sprite.opacity = 0
    
    @transition["left"]=EAMSprite.new(v)
    @transition["left"].bitmap=pbBitmap($Trainer.gender == 0 ? "Graphics/Transitions/smSpecial153" : "Graphics/Transitions/smSpecial154")
    @transition["left"].mask("Graphics/Pictures/STour/leftGradient", -40)
    @transition["left"].x=-512
  
    @transition["rightbg"]=EAMSprite.new(v)
    @transition["rightbg"].bitmap=pbBitmap("Graphics/Pictures/STour/rightGradient")
    @transition["rightbg"].x=512+512
    @transition["rightbg"].ox = @transition["rightbg"].bitmap.width
  
    @transition["rightStar"]=TournamentPlane.new(v)
    @transition["rightStar"].bitmap = pbBitmap("Graphics/Pictures/STour/StarAnimBG")
    @transition["rightStar"].sprite.angle=-17
    @transition["rightStar"].sprite.y=-170
  
    @transition["rightStar"].sprite.x=370
    @transition["rightStar"].borderY=200
    @transition["rightStar"].sprite.opacity = 0
  
    @transition["right"]=EAMSprite.new(v)
    @transition["right"].bitmap=bmp#pbBitmap("Graphics/Transitions/smSpecial169")
    @transition["right"].x=512
    @transition["right"].x=512+512
    @transition["right"].mask("Graphics/Pictures/STour/rightGradient",40)
    @transition["right"].ox = @transition["right"].bitmap.width
    
    @transition["sep"]=EAMSprite.new(v)
    @transition["sep"].bitmap=pbBitmap("Graphics/Pictures/STour/Sep")
    @transition["sep"].ox = @transition["sep"].bitmap.width/2
    @transition["sep"].oy = @transition["sep"].bitmap.height/2
    @transition["sep"].x = 512/2
    @transition["sep"].y = 384/2
    @transition["sep"].zoom_x = 2
    @transition["sep"].zoom_y = 2
    @transition["sep"].opacity = 0
  
    @transition["versus"]=EAMSprite.new(v)
    @transition["versus"].bitmap=pbBitmap("Graphics/VS/vs_gym")
    @transition["versus"].ox = @transition["versus"].bitmap.width/2
    @transition["versus"].oy = @transition["versus"].bitmap.height/2
    @transition["versus"].x = 512/2
    @transition["versus"].y = 384/2
    @transition["versus"].zoom_x = 2
    @transition["versus"].zoom_y = 2
    @transition["versus"].opacity = 0
  
    for i in 0...2
      @transition["bar#{i}"] = EAMSprite.new(v)
      @transition["bar#{i}"].bitmap=pbBitmap("Graphics/Pictures/STour/blackBar")
      @transition["bar#{i}"].oy = i % 2 == 0 ? 0 : @transition["bar#{i}"].bitmap.height
      @transition["bar#{i}"].y = i % 2 == 0 ? -@transition["bar#{i}"].bitmap.height : 384 + @transition["bar#{i}"].bitmap.height
    end
  
    val=1

    #HERE STARTS THE ANIMATION
  
    @transition["darken"].fade(150,30,:ease_in_cubic)
    20.times do 
      Graphics.update
      Input.update
      @transition["darken"].update
      
    end
  
    @transition["bar0"].move(0,0,20,:ease_in_cubic)
    @transition["bar1"].move(0,384,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      @transition["darken"].update
      @transition["bar0"].update
      @transition["bar1"].update
  
    end
  
    @transition["sep"].fade(255,30,:ease_in_cubic)
    @transition["sep"].zoom(1,1,30,:ease_in_cubic)
  
    if @pool.length<3
      Kernel.pbMessage(_INTL("Congratulazioni agli allenatori che hanno raggiunto la finale! Siete stati bravi! Gengah ah ah!"))
    end

    Kernel.pbMessage(_INTL("Diamo un'occhiata agli sfidanti!"))
    
    @transition["sep"].fade(255,30,:ease_in_cubic)
    @transition["sep"].zoom(1,1,30,:ease_in_cubic)
  
    @transition["right"].move(512,0,20,:ease_in_cubic)
    @transition["rightbg"].move(512,0,20,:ease_in_cubic)
    30.times do
      Graphics.update
      Input.update
      @transition["right"].update
      @transition["rightbg"].update
  
      @transition["sep"].update
    end
  
    @transition["right"].move(512+10,0,2)
    @transition["rightbg"].move(512+10,0,2)
    2.times do
      Graphics.update
      Input.update
      @transition["right"].update
      @transition["rightbg"].update
    end
    
    @transition["right"].move(512,0,2)
    @transition["rightbg"].move(512,0,2)
    2.times do
      Graphics.update
      Input.update
      @transition["right"].update
      @transition["rightbg"].update
    end      
  
    oppname = pbGetMessageFromHash(MessageTypes::TrainerNames,opponent[2])

    Kernel.pbMessage(_INTL("Sulla destra! {1}, {2}!", trainerTypeName(opponent[1]), oppname))
  
    @transition["left"].move(0,0,20,:ease_in_cubic)
    @transition["leftbg"].move(0,0,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      @transition["left"].update
      @transition["leftbg"].update
    end
  
    @transition["left"].move(0-10,0,2)
    @transition["leftbg"].move(0-10,0,2)
    2.times do
      Graphics.update
      Input.update
      @transition["left"].update
      @transition["leftbg"].update
    end
    
    @transition["left"].move(0,0,2)
    @transition["leftbg"].move(0,0,2)
    2.times do
      Graphics.update
      Input.update
      @transition["left"].update
      @transition["leftbg"].update
    end
    
  
    Kernel.pbMessage(_INTL("Sulla sinistra, il solo e unico prescelto!"))
  
    Kernel.pbMessage(_INTL("È ora di lottare! Gengah ah ah!"))
  
    @transition["versus"].fade(255,20,:ease_in_cubic)
    @transition["versus"].zoom(1,1,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      @transition["versus"].update
      @transition["leftStar"].sprite.opacity+=120/20
      @transition["rightStar"].sprite.opacity+=120/20
      moveStars(@transition["leftStar"],@transition["rightStar"])
    end
    
    60.times do 
      Graphics.update
      Input.update
      moveStars(@transition["leftStar"],@transition["rightStar"])
    end
  end
  
  #Graphical methods
  
  def loadGraphics
    v=@v
    #Loading all graphical resources
    
    pwt = "Graphics/Pictures/STour/"
    #@sprites={}
    #@sprites["bg"]=Sprite.new(v)
    #@sprites["bg"].bitmap=pbBitmap(pwt+"pwt_interscreen")
    #@sprites["bg"].bitmap=pbBitmap(pwt+"bg")
    #@sprites["bg"].x=330
    #@sprites["bg"].blur_sprite(1)
    
    @sprites["anibg"]=AnimatedPlane.new(v)
    @sprites["anibg"].bitmap=pbBitmap(pwt+"anibgPwt")
    #@sprites["anibg"].borderX=990
    @sprites["anibg"].opacity=0

    @sprites["light"]= EAMSprite.new(v)
    @sprites["light"].bitmap=pbBitmap(pwt+"Light")
    @sprites["light"].opacity = 0

    @sprites["gengar"]=EAMSprite.new(v)
    @sprites["gengar"].bitmap = pbBitmap(pwt+"GPresenter")
    @sprites["gengar"].opacity = 0
    @sprites["gengar"].y = 384

  end
  
  def drawInfoBoxes(trainer,pool,oppIndex)
    
    w=Color.new(255,255,255)
    b=Color.new(44,44,44)
    pwt = "Graphics/Pictures/PWT/"
    
   # echo pool[oppIndex][0]
    
    @sprites["oleft"].bitmap.clear
    @sprites["oright"].bitmap.clear
    
    @sprites["leftBox"].bitmap=pbBitmap(pwt+"pwtLeftBox")
    @sprites["rightBox"].bitmap=pbBitmap(pwt+"pwtRightBox")
    
    @sprites["trainer"]=Sprite.new(@v)
    @sprites["trainer"].bitmap=AnimatedBitmapWrapper.new(pbPlayerSpriteFile($Trainer.trainertype)).bitmap
    @sprites["trainer"].x=12+@sprites["leftBox"].x
    @sprites["trainer"].y=278
    @sprites["trainer"].src_rect.set(0,0,196,@sprites["trainer"].bitmap.height/2)
    @sprites["overLeft"].x=@sprites["trainer"].x+12
    if oppIndex != nil
      @sprites["opp"]=Sprite.new(@v)
      @sprites["opp"].bitmap=AnimatedBitmapWrapper.new(pbTrainerSpriteFile(pool[oppIndex][0])).bitmap
      @sprites["opp"].x=542+@sprites["rightBox"].x
      @sprites["opp"].y=396
      @sprites["opp"].src_rect.set(0,0,196,@sprites["opp"].bitmap.height/2)
      @sprites["overRight"].x=@sprites["opp"].x+12
    end
    
    textpos=[[trainer.name,60,232,0,w]]
    textpos2=[[pool[oppIndex][1],444+28,498,0,w]]
    
    pbSetSystemFont(@sprites["oright"].bitmap)
    pbSetSystemFont(@sprites["oleft"].bitmap)
    pbDrawTextPositions(@sprites["oleft"].bitmap,textpos)
    pbDrawTextPositions(@sprites["oright"].bitmap,textpos2)
  end
   
  def closeGraphics
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
  end
  
  #Logical Methods start from here
  def defineChart(player,difficulty,trainerpool=nil) #Calculate the chart inside a pool of trainers
    
    if trainerpool==nil
       case difficulty
       when 0
         trainerpool=TRAINERPOOL_basic
         
         #push trey if pass 4 is over
         trainerpool << ["trey",PBTrainers::TREYTOURNAMENT,"Trey",_INTL("Hmph! La prossima volta vincerò io!"),5] if $game_switches[1330]==true && $game_switches[1394]==false

         @rounds=3
       when 1
         trainerpool=TRAINERPOOL_hard
         
         #push trey if pass 4 is over
         trainerpool << ["trey",PBTrainers::TREYTOURNAMENT,"Trey",_INTL("Hmph! La prossima volta vincerò io!"),5] if $game_switches[1330]==true && $game_switches[1394]==false
         
         @rounds=4
       when 2
         trainerpool=TRAINERPOOL_expert
         @rounds=5
       end
    end
    #defining the number of slots in the tournament
    #player will take a random spot in between
    
    if difficulty==0
      branches = 7
    elsif difficulty==1
      branches = 15
    elsif difficulty==2
      branches = 31
    else
      branches = 7
    end
    
    pool=[]
    added=[]
    
    miAdded = nil

    echoln "look for MUSTINCLUDE"

    if trainerpool != nil && MUSTINCLUDE.keys.include?(trainerpool)
      tr = MUSTINCLUDE[trainerpool]
      found = nil
      trainerpool.each do |trainer|
        if trainer[1]==tr[0] && trainer[2]==tr[1]
          found = trainer
          break
        end
      end
      if found != nil
        echoln "DETECTED MUSTINCLUDE! MUST INCLUDE #{tr[1]}"
        added.push(found)
        #pool.push(found)
        branches-=1
        miAdded = found
      end
    end

    echoln "generating Pool"

    if (trainerpool != TRAINERPOOL_DREAM)
      for i in 0...branches
        randTrainer = trainerpool[rand(trainerpool.length)]
        #This ensures diversity between trainers
        while (added.include?(randTrainer))
          randTrainer = trainerpool[rand(trainerpool.length)]
        end
        added.push(randTrainer)
        pool.push(randTrainer)
      end
    else
      for i in 0...branches        
        pool.push(trainerpool[i])
      end
    end
    
    echoln "randomizing brances"

    if trainerpool != TRAINERPOOL_DREAM
      m = rand(pool.length-1)    
      pool.insert(m,$Trainer)
      i = 0
      if m > branches/2
        i = rand(branches/2+1)
      else
        i = pool.length-rand(branches/2)
      end
    else
      pool.insert(0,$Trainer)
      i = 0
    end

    echoln "quando rileggerai questa parte dirai kek"

    if miAdded != nil
      echoln "adding Mustinclude"
      pool.insert(i,miAdded)
    end


    pool.each do |entry|
      id = pool.index(entry)
      echoln "Contestant #{id+1}: #{entry == $Trainer ? $Trainer.name : entry[2]}"
    end
    
    getBattlesList(pool)
    
    echo _INTL("Player is contestant number {1} and the chart is long {2} \n",@trainerIndex,pool.length)
    
    return pool
  end

  def tGraphicsUpdate
    if @sprites["anibg"]!=nil
      @sprites["anibg"].ox+=2
      @sprites["anibg"].oy+=2
    end
      
  end
  
  def nextOpponent
    echoln "#{@pool[@oppIndex][0]}-#{@pool[@oppIndex][1]}-#{@pool[@oppIndex][2]}"
    return @pool[@oppIndex]
  end

  def startTournament(player,difficulty,trainerpool=nil) #Starts the tournament
        
    @trainerIndex=nil
    @oppIndex=nil
    
    #Global variable for checking the exp giving if the player is in a tournament
    $ISINTOURNAMENT=true
    echoln "defining chart"
    @pool = defineChart(player,difficulty,trainerpool)
    echoln "chart defined"
    @firstPool = @pool
    pool = @pool

    @opponent = pool[@oppIndex]

    #opponentIntro(opponent)

    rounds=@rounds
    
    @playerwon=false
    
    loadGraphics()
    pbBGMPlay("pwt ost")
    #$game_system.message_position = 4
    
    # Setting party level to 50
    self.setLevel

    10.times do
      @sprites["anibg"].opacity +=15
      Graphics.update
      Input.update
      tGraphicsUpdate()
    end

    @sprites["light"].fade(150,10)
    @sprites["gengar"].fade(255,20)
    @sprites["gengar"].move(0,-10,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
      @sprites["light"].update
    end

    @sprites["gengar"].move(0,0,4,:ease_in_cubic)
    4.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
    end
    
    Kernel.pbMessage(_INTL("Salve a tutti e benvenuti al Torneo Apollo! Gengah ah ah!")) {tGraphicsUpdate()}
    
    pbSEPlay("Applause")
    pbSEPlay("CrowdSound")
    
    60.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
    end
    
    #drawInfoBoxes($Trainer,pool,@oppIndex)
    
    #Kernel.pbMessage(_INTL("A huge thanks goes to our sponsor! The Pokémon Center Co.!")) {tGraphicsUpdate()}
    Kernel.pbMessage(_INTL("Oggi ne vedremo delle belle! I contendenti sono pronti a far scintille!")) {tGraphicsUpdate()}
    
    Kernel.pbMessage(_INTL("Spero che siate pronti anche voi! Gengah ah ah!")) {tGraphicsUpdate()}
    
    Kernel.pbMessage(_INTL("Adesso, iniziamo!")) {tGraphicsUpdate()}
    
    #Teleport to Circo Sirio (324,9,15)

    pbTransferWithTransition(TOURNAMENT_LOCKER_MAP_ID,26,18,:DIRECTED,2) {
      pbDisposeSpriteHash(@sprites)
    }
  end

  def showChart
    echoln "Showing the tournament chart"
    chart = @firstPool
    curPool = @pool

    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999

    @s = {}

    @s["bg"] = AnimatedPlane.new(viewport)
    @s["bg"].bitmap = pbBitmap("Graphics/Pictures/STour/BracketBG")

    @s["bgmask"] = AnimatedPlane.new(viewport)
    @s["bgmask"].bitmap = pbBitmap("Graphics/Pictures/STour/BracketBGMask")

    append = ""
    if @difficulty > 0
      if @difficulty == 1
        append = "XL"
      else
        append = "XXL"
      end
    end

    # draw the bracket
    @s["bracket"] = Bracket.new(viewport,chart,curPool)
    @s["bracket"].bitmap = pbBitmap("Graphics/Pictures/STour/Bracket"+append)
    #@s["bracket"].ox = @s["bracket"].bitmap.width/2
    #@s["bracket"].oy = @s["bracket"].bitmap.height/2
    @s["bracket"].x = 71#viewport.rect.width/2
    @s["bracket"].y = 52#viewport.rect.height/2
    @s["bracket"].actualize


    @s["crown"] = Sprite.new(viewport)
    @s["crown"].bitmap = pbBitmap("Graphics/Pictures/STour/crown")
    @s["crown"].ox = @s["crown"].bitmap.width/2
    @s["crown"].oy = @s["crown"].bitmap.height/2
    @s["crown"].x = @s["bracket"].x + @s["bracket"].bitmap.width/2
    @s["crown"].y = @s["bracket"].y + @s["bracket"].bitmap.height/2

    # draw the slots
    for i in 0...@firstPool.length
      cur = @firstPool[i]
      @s["bracketSlot#{i}"] = BracketSlot.new(viewport)
      @s["bracketSlot#{i}"].bitmap = pbBitmap("Graphics/Pictures/STour/BracketSlot"+(i>@firstPool.length/2-1 ? "r" : ""))
      if cur != $Trainer
        hiddenvip = VIPLIST.rassoc(cur[2]) != nil && !$Trainer.vips.include?(VIPLIST.rassoc(cur[2]))
      else
        hiddenvip = false
      end
      @s["bracketSlot#{i}"].setTrainer(i>@firstPool.length/2-1,cur == $Trainer ? pbGetPlayerWalkingChar() : cur[0], hiddenvip)
      @s["bracketSlot#{i}"].positionTrainer(34+(i>@firstPool.length/2-1 ? 8 : 0),36)
      @s["bracketSlot#{i}"].y = 14 + (i % (@firstPool.length/2)) * (9+@s["bracketSlot#{i}"].bitmap.height)
      if i>@firstPool.length/2-1
        @s["bracketSlot#{i}"].x=@s["bracket"].x + @s["bracket"].bitmap.width - 6#-@s["bracketSlot#{i}"].bitmap.width
      end
    end 

    
    maxMoveX = (@s["bracket"].bitmap.width + @s["bracketSlot0"].bitmap.width*2 - 12) - viewport.rect.width
    maxMoveX = 0 if maxMoveX<0
    maxMoveY = 14*2+37*2+@s["bracket"].bitmap.height - viewport.rect.height 
    curMoveX = 0
    curMoveY = 0

    movSpeed = 2

    pbFadeInAndShow(@s)
    loop do 
      Graphics.update
      Input.update
      @s["bg"].ox-=2.5
      @s["bg"].oy-=2.5

      if Input.press?(Input::UP) && curMoveY-movSpeed>=0
        curMoveY -=movSpeed
        @s["bracket"].y +=movSpeed
        @s["crown"].y +=movSpeed

        for i in 0...@firstPool.length
          @s["bracketSlot#{i}"].y += movSpeed
        end
      end

      if Input.press?(Input::DOWN) && curMoveY+movSpeed<maxMoveY
        curMoveY +=movSpeed
        @s["bracket"].y -=movSpeed
        @s["crown"].y -=movSpeed

        for i in 0...@firstPool.length
          @s["bracketSlot#{i}"].y -= movSpeed
        end
      end

      if Input.press?(Input::LEFT) && curMoveX-movSpeed>=0
        curMoveX -=movSpeed
        @s["bracket"].x +=movSpeed
        @s["crown"].x +=movSpeed

        for i in 0...@firstPool.length
          @s["bracketSlot#{i}"].x += movSpeed
        end
      end

      if Input.press?(Input::RIGHT) && curMoveX+movSpeed<=maxMoveX
        curMoveX +=movSpeed
        @s["bracket"].x -=movSpeed
        @s["crown"].x -=movSpeed

        for i in 0...@firstPool.length
          @s["bracketSlot#{i}"].x -= movSpeed
        end
      end


      break if (Input.trigger?(Input::B))


    end
    pbFadeOutAndHide(@s)
    pbDisposeSpriteHash(@s)
    viewport.dispose

  end

  def goLeft?
    return false if !@pool
    i = 0

    @pool.each_index do |t|
      if @pool[t] == $Trainer
        i = t
      end
    end
    return i%2 == 0
  end

  def final?
    return false if !@pool
    return @pool.length<=2
  end

  def startRound
    if $pwt.final?
      if goLeft?() #player goes left, enemy is right
      
        $game_switches[1201]=true
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].moveto(62,22)
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].character_name = @opponent[0]
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].turn_left

      else #player goes right, enemy is left

        $game_switches[1201]=true
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].moveto(10,22)
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].character_name = @opponent[0]
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].turn_right

      end
    else
      if goLeft?() #player goes left, enemy is right
      
        $game_switches[1201]=true
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].moveto(39,43)
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].character_name = @opponent[0]
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].turn_left

      else #player goes right, enemy is left

        $game_switches[1201]=true
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].moveto(33,43)
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].character_name = @opponent[0]
        $game_map.events[TOURNAMENT_OPPONENT_EVENT_ID].turn_right

      end
    end

    $game_map.events[TOURNAMENT_EVENT_ID].start
  end

  
  def nextRound
    @trainerIndex=nil
    @oppIndex=nil
    
    #Global variable for checking the exp giving if the player is in a tournament
    $ISINTOURNAMENT=true
    
    @pool = redefineChart(@pool)
    pool = @pool

    @opponent = pool[@oppIndex]

    #opponentIntro(opponent)

    rounds=@rounds
    
    @playerwon=false
    
    loadGraphics()
    pbBGMPlay("pwt ost")
    #$game_system.message_position = 4
    
    # Setting party level to 50
    self.setLevel

    10.times do
      @sprites["anibg"].opacity +=15
      Graphics.update
      Input.update
      tGraphicsUpdate()
    end

    @sprites["light"].fade(150,10)
    @sprites["gengar"].fade(255,20)
    @sprites["gengar"].move(0,-10,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
      @sprites["light"].update
    end

    @sprites["gengar"].move(0,0,4,:ease_in_cubic)
    4.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
    end
    
    Kernel.pbMessage(_INTL("Salve a tutti e benvenuti al Torneo Apollo! Gengah-ah-ah!")) {tGraphicsUpdate()}
    
    pbSEPlay("Applause")
    pbSEPlay("CrowdSound")
    
    60.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
    end
    
    #drawInfoBoxes($Trainer,pool,@oppIndex)
    
    #Kernel.pbMessage(_INTL("A huge thanks goes to our sponsor! The Pokémon Center Co.!")) {tGraphicsUpdate()}
    Kernel.pbMessage(_INTL("Oggi ne vedremo delle belle! I contendenti sono pronti a far scintille!")) {tGraphicsUpdate()}
    
    Kernel.pbMessage(_INTL("Spero che siate pronti anche voi! Gengah-ah-ah!")) {tGraphicsUpdate()}
    
    Kernel.pbMessage(_INTL("Adesso, iniziamo!")) {tGraphicsUpdate()}
    
    #Teleport to Circo Sirio (324,9,15)

    pbTransferWithTransition(324,9,15,:DIRECTED,6) {
      pbDisposeSpriteHash(@sprites)
    }

    $game_switches[1201]=true

    $game_map.events[19].character_name = @opponent[0]
    $game_map.events[19].turn_left
    $game_map.events[18].start
  end

  
  def betRounds(pool) #Between rounds
    pbIntroTournament()

    #Gengar reappears
    loadGraphics()
    pbBGMPlay("pwt ost")

    10.times do
      @sprites["anibg"].opacity +=15
      Graphics.update
      Input.update
      tGraphicsUpdate()
    end

    @sprites["light"].fade(150,10)
    @sprites["gengar"].fade(255,20)
    @sprites["gengar"].move(0,-10,20,:ease_in_cubic)
    20.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
      @sprites["light"].update
    end

    @sprites["gengar"].move(0,0,4,:ease_in_cubic)
    4.times do
      Graphics.update
      Input.update
      tGraphicsUpdate()
      @sprites["gengar"].update
    end

    Kernel.pbMessage(_INTL("Che battaglia incredibile! La vittoria va a {1}! Congratulazioni!", $Trainer.name)) {tGraphicsUpdate()}
    #self.exitParticipants
    #self.drawInfoBoxes($Trainer,pool,@oppIndex)
    #Kernel.pbMessage(_INTL("And now, let's see who got to the next round!")) {tGraphicsUpdate()}
    #for c in 0...pool.length
    #  if pool[c]==$Trainer
    #     Kernel.pbMessage(_INTL("Contestant N°{1}, {2}!",@trainerIndex+1,$Trainer.name)) {tGraphicsUpdate()}
    #  else
    #     Kernel.pbMessage(_INTL("Contestant N°{1}, {2}!",c+1,pool[c][2])) {tGraphicsUpdate()}
    #  end
    #end
    #Kernel.pbMessage(_INTL("They were the winners from the last round!")) {tGraphicsUpdate()}
    
    Kernel.pbMessage(_INTL("Ora, è il momento di passare alla prossima!")) {tGraphicsUpdate()}
    #self.enterParticipants
    #Kernel.pbMessage(_INTL("Contestant N°{1}, {2}! Contestant N°{3}, {4}! Time to show what's your value!",@trainerIndex+1,$Trainer.name,@oppIndex+1,pool[@oppIndex][2])) {tGraphicsUpdate()}
  end
  
  
  def redefineChart(pool) #Recalculate the tournament chart
    #player Won
    newPool=[]
    #echoln pool
    if pool.length>2
      if @trainerIndex%2==0
        newtrIndex = @trainerIndex/2
      else
        newtrIndex = (@trainerIndex-1)/2
      end

      #Temporary Pool for splitting the pool two by two
      tempPool = []
      for i in 0...pool.length
        tempPool.push([pool[i],pool[i+1]]) if i%2==0
      end
      
      echoln "p:#{pool.length} tp:#{tempPool.length}"

      for c in 0...tempPool.length
        pair = tempPool[c]
        echoln "handling pair: #{pair[0] == $Trainer ? $Trainer.name : pair[0][2]} #{pair[1] == $Trainer ? $Trainer.name : pair[1][2]}"
        #if the pair contains the player
        if pair[0] == $Trainer || pair[1] == $Trainer
          newPool.push($Trainer)
        else #if it doesn't contain the player
          #echoln pair
          if pair[0][4]>pair[1][4]
            newPool.push(pair[0])
          elsif pair[0][4]<pair[1][4] # i+1's win priority is greater than i's
            newPool.push(pair[1])
          else #they have the same win priority
            r=rand(2)
            newPool.push(pair[r])
          end
        end
      end
    end
    
    while newPool.include?(nil)
      #newPool.delete_at(newPool.length-1)
      newPool.delete(nil)
    end
    #echoln newPool
    
    
    for t in 0...newPool.length#.each do |entry|
      #id = newPool.index(entry)
      echoln "Contestant #{t+1}: #{newPool[t] == $Trainer ? $Trainer.name : newPool[t][2]}"
    end

    getBattlesList(newPool)
    
    echo _INTL("Player is contestant number {1} and the chart is long {2} \n",@trainerIndex,newPool.length)
    
    return newPool
  end
  
  
  def getBattlesList(pool) #Gets the list of battles in order
    if pool != nil
      trainerIndex=nil
      opponentIndex=nil
      
      #while trainerIndex==nil
      #  for i in 0...pool.length
      #    if pool[i]==$Trainer
      #      trainerIndex = i
      #    end
      #  end
      #end
      if @trainerIndex !=nil
        trainerIndex=@trainerIndex
      end
      
      for i in 0...pool.length
        if pool[i]==$Trainer
          trainerIndex = i
        end
      end
      
      if trainerIndex%2==0 
        opponentIndex=trainerIndex+1
      else
        opponentIndex=trainerIndex-1
      end
      
      
      @trainerIndex=trainerIndex
      @oppIndex=opponentIndex
    end
    
  end
  
  
  def startBattle(pool)
    if pool.length>3
      $PokemonGlobal.nextBattleBack = "Apollo"
      #Kernel.pbMessage(_INTL("You were matched against trainer n°{1}",@oppIndex))
      if pbTournamentBattle(pool[@oppIndex][1],pool[@oppIndex][2],pool[@oppIndex][3],@doublebattle,0,true)
        key = [pool[@oppIndex][1],pool[@oppIndex][2]]
        if VIPLIST.include?(key)
          $game_switches[VIPCUPSWITCH[key]]=true if final?()
          if !$Trainer.vips.include?(key)
            $Trainer.vips.push(key)
            $achievements[key[1]].progress=1
          end
        end
        @win=true
      else
        @win=false
        Kernel.pbMessage(_INTL("{1} ha perso! Che peccato!",$Trainer.name))
      end
      healParty
    else
      $PokemonGlobal.nextBattleBack = "ApolloFinal"
      if pbTournamentBattle(pool[@oppIndex][1],pool[@oppIndex][2],pool[@oppIndex][3],@doublebattle,0,true)
        if $game_switches[1350]
          #Dream tournament          
          pbFadeOutAndHide(@transition)
          pbDisposeSpriteHash(@transition)
          $game_map.events[TOURNAMENT_DREAM_POST].interpreter=$game_system.map_interpreter#Interpreter.new(0,true)
          $game_map.events[TOURNAMENT_DREAM_POST].simpleRun(false)
          @playerwon=true
        else        
          pbFadeOutAndHide(@transition)
          Kernel.pbMessage(_INTL("Congratulazione a {1} per la vittoria! Veramente una performance eccezionale, Gengah ah ah!", $Trainer.name))
          Kernel.pbMessage(_INTL("Ricorda di passare alla reception per riscattare i tuoi premi!"))
          @playerwon=true
          key = [pool[@oppIndex][1],pool[@oppIndex][2]]
          if VIPLIST.include?(key)
            pbSEPlay("Victory VIP")
            $game_switches[VIPCUPSWITCH[key]]=true if final?()
            if !$Trainer.vips.include?(key)
              $Trainer.vips.push(key) 
              if ACHIEVEMENTREDIRECT.keys.include?(key[1])
                $achievements[ACHIEVEMENTREDIRECT[key[1]]].progress=1
              else
                $achievements[key[1]].progress=1
              end
            end
          end
        end
        @win=true
      else
        Kernel.pbMessage(_INTL("{1} ha perso! Che peccato!",$Trainer.name))
        @win=false
      end
      healParty
    end
  end
  
  #End tournament section
  def endTournament(win)
    #What to do if player won    
    closeGraphics if @sprites
    restoreParty
    $game_system.message_position = 2
    $ISINTOURNAMENT=false
    if $game_switches[1350] && win
      echoln "Win in event"
      return
    end
    pbTransferWithTransition(621,17,22,:DIRECTED,8) {
      pbFadeOutAndHide(@transition) if @transition
      pbDisposeSpriteHash(@transition) if @transition
    }
    
    if win==true
      @player.tournament_wins+=1
      #pbTransferWithTransition(4,6,15,:DIRECTED,8)
      #pbCallBubStart(3)
      if @player.tournament_wins > 1
        Kernel.pbMessage(_INTL("Congratulazioni per la vittoria! Ora come ora, hai vinto ben {1} tornei!",@player.tournament_wins))
      else
        Kernel.pbMessage(_INTL("Congratulazioni per la vittoria! Ora come ora, hai vinto {1} torneo!",@player.tournament_wins))
      end
      
      Kernel.pbMessage(_INTL("Ecco la ricompensa per la tua vittoria."))
      qt = 12 + @firstPool.length/16*3      
      if !@player.winstreak
        @player.winstreak = true
      end
      
      @player.winstreak_count +=1 if @player.winstreak && @player.winstreak_count <= 2
      qt *= @player.winstreak_count
      @player.battle_points+=qt #12 base points for winning + 2 for each bigger stage
      reward = REWARDPOOL[rand(REWARDPOOL.length)]
      rewardname = getID(PBItems,reward)
     # pbCallBubStart(0)
      Kernel.pbMessage(_INTL("{1} ha ottenuto {2} Punti Lotta!",@player.name,qt))
      Kernel.pbMessage(_INTL("Inoltre..."))
      Kernel.pbMessage(_INTL("Per aver mostrato una performance incredibile..."))
      Kernel.pbMessage(_INTL("...{1} riceve {2}!",@player.name,PBItems.getName(rewardname)))
      Kernel.pbReceiveItem(reward)
     # pbCallBubStart(3)
      Kernel.pbMessage(_INTL("Ci vediamo!"))
    else #what to do if player lose
      if @player.winstreak
        @player.winstreak = false
        @player.winstreak_count = 0
      end
     # pbTransferWithTransition(4,6,15,:DIRECTED,8)
     # pbCallBubStart(3)
      Kernel.pbMessage(_INTL("Mi dispiace per la tua sconfitta! Ma hai combattuto bene, sono certa che vincerai la prossima volta!"))
      Kernel.pbMessage(_INTL("Hai perso, ma hai comunque ottenuto delle ricompense."))
      qt = 3 + (@firstPool.length/@pool.length * 0.65).to_i
      @player.battle_points+=qt
      reward = REWARDLOSINGPOOL[rand(REWARDLOSINGPOOL.length)]
      rewardname = getID(PBItems,reward)
     # pbCallBubStart(0)
      Kernel.pbMessage(_INTL("{1} ottiene {3} Punti Lotta e {2}.",@player.name,PBItems.getName(rewardname),qt))
      Kernel.pbReceiveItem(reward)
     # pbCallBubStart(3)
      Kernel.pbMessage(_INTL("Ci vediamo!"))
    end
    
    
  end
  
  #Heal Party
  def healParty
    for poke in $Trainer.party
      poke.heal
    end
  end

  def choosePokemon
    ret = false
    return "notEligible" if !self.partyEligible?
    length = [3,4,6,1][@battle_type]
    Kernel.pbMessage(_INTL("Per favore, scegli i Pokémon che vuoi far partecipare."))#Please choose the Pokemon you would like to participate.
    banlist = BAN_LIST
    banlist = BAN_LIST[@tournament_type] if BAN_LIST.is_a?(Hash)
    ruleset = PokemonRuleSet.new
    ruleset.addPokemonRule(RestrictSpecies.new(banlist))
    ruleset.setNumberRange(length,length)
    echoln "MAX LENGTH: #{@battle_type}-#{length}"
    pbFadeOutIn(99999){
      if defined?(PokemonParty_Scene)
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene,$Trainer.party)
      else
        scene = PokemonScreen_Scene.new
        screen = PokemonScreen.new(scene,$Trainer.party)
      end
      #ret = screen.pbPokemonMultipleEntryScreenEx(ruleset)
      ret=screen.pbChooseMultiplePokemon(@doublebattle ? 4 : 3,proc{|p|
          return ruleset.isPokemonValid?(p)
      })
    }
    return ret
  end
  
  def partyEligible?
    length = [3,4,6,1][@battle_type]
    count = 0
    banlist = BAN_LIST
    banlist = BAN_LIST[@tournament_type] if BAN_LIST.is_a?(Hash)
    return false if $Trainer.party.length < length
    echo "Checking on Party"
    for i in 0...$Trainer.party.length
      for species in banlist
        if species.is_a?(Numeric)
        elsif species.is_a?(Symbol)
          species = getConst(PBSpecies,species)
        else
          next
        end
        egg = $Trainer.party[i].respond_to?(:egg?) ? $Trainer.party[i].egg? : $Trainer.party[i].isEgg?
        count += 1 if species != $Trainer.party[i].species && !egg
      end
    end
    echo count
    echo length
    return true if count >= length
    return false
  end
  
  # Sets all Pokemon to lv 50
  def setLevel
    for poke in $Trainer.party
      poke.level = 50
      poke.calcStats
      poke.heal
      poke.item = @partyItems[poke] if @partyItems != nil && @partyItems.keys.include?(poke)
    end
  end
  
  # Backs up your current party
  def backupParty
    @party_bak.clear
    @levels.clear
    @partyItems = {}
    for poke in $Trainer.party
      @party_bak.push(poke)
      @levels.push(poke.level)
      @partyItems[poke]=poke.item
    end
  end
  
  # Restores your party from an existing backup
  def restoreParty
    $Trainer.party.clear
    for i in 0...@party_bak.length
      poke = @party_bak[i]
      poke.level = @levels[i]
      poke.calcStats
      poke.heal
      poke.item = @partyItems[poke]
      $Trainer.party.push(poke)
    end
  end
  
end

#===============================================================================
# Additional Methods for the tournament
#
#===============================================================================
#Modification to Pokebattle_trainer module to add won tournaments counter
class PokeBattle_Trainer
  attr_accessor :tournament_wins
  attr_accessor :winstreak_count
  attr_accessor :winstreak
end

#TOURNAMENT BATTLE METHOD
def pbTournamentBattle(trainerid,trainername,endspeech,
                    doublebattle=false,trainerparty=0,canlose=false,variable=nil)
  if $Trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    return false
  end
  if !$PokemonTemp.waitingTrainer && $Trainer.ablePokemonCount>1 &&
     pbMapInterpreterRunning?
    thisEvent=pbMapInterpreter.get_character(0)
    triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent=[]
    for i in triggeredEvents
      if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
        otherEvent.push(i)
      end
    end
    if otherEvent.length==1
      trainer=pbLoadTrainerTournament(trainerid,trainername,trainerparty)
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      if !trainer
        pbMissingTrainer(trainerid,trainername,trainerparty)
        return false
      end
      if trainer[2].length<=6 # 3
        $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech]
        return false
      end
    end
  end
  trainer=pbLoadTrainerTournament(trainerid,trainername,trainerparty)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    return false
  else
    if !doublebattle && trainer[2].length>3
      trainer[2]=trainer[2][0..2]
    end
  end
  
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  if $PokemonTemp.waitingTrainer
    combinedParty=[]
    fullparty2=false
    if false
      if $PokemonTemp.waitingTrainer[0][2].length>3
        raise _INTL("Opponent 1's party has more than three Pokémon, which is not allowed")
      end
      if trainer[2].length>3
        raise _INTL("Opponent 2's party has more than three Pokémon, which is not allowed")
      end
    elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[6+i]=trainer[2][i]
      end
      fullparty2=true
    else
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[3+i]=trainer[2][i]
      end
      fullparty2=false
    end
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.doublebattle=battle.pbDoubleBattleAllowed?()
    battle.endspeech=$PokemonTemp.waitingTrainer[2]
    battle.endspeech2=endspeech
    battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
  else
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
    battle.fullparty1=fullparty1
    battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
    battle.items=trainer[1]
    trainerbgm=pbGetTrainerBattleBGM(trainer[0])
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
      $PokemonTemp.waitingTrainer=nil
    end
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     for i in $Trainer.party; (i.makeUnmega rescue nil); end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
         i.makeUnmega rescue nil
       end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     else
       Events.onEndBattle.trigger(nil,decision)
       if decision==1
         if $PokemonTemp.waitingTrainer
           pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
         end
       end
     end
  }
  Input.update
  pbSet(variable,decision)
  $PokemonTemp.waitingTrainer=nil
  return (decision==1)
end

def pbTT
    $pwt = PWT.new($Trainer,0,LANCEPOOL,false,true)
end

def pbt
  #Temporary Pool for splitting the pool two by two
  pool=TRAINERPOOL_basic[0...8]
  tempPool = []
  for i in 0...pool.length
    tempPool.push([i,i+1]) if i%2==0
  end
  echoln tempPool

  newPool=[]
  for j in 0...tempPool.length
    newPool.push(tempPool[j][rand(2)])
  end
  echoln newPool
end

def pbTestTreyEvent
  $pwt = 1 
  $game_map.events[TOURNAMENT_DREAM_POST].interpreter=$game_system.map_interpreter#Interpreter.new(1,false)
  $game_map.events[TOURNAMENT_DREAM_POST].simpleRun(false)
end

def pbLeo
  $ISINTOURNAMENT = true
  @opponent = DANTEPOOL[0]
  key = [@opponent[1],@opponent[2]]
  fbNewMugshot(VIPSPEECH[key][:name],VIPSPEECH[key][:mugshot],"default",:left)
  fbEnable(true)
  fbText(VIPSPEECH[key][:speech])
  fbEnable(false)
  fbDispose()
  for i in $Trainer.party
    i.level = 50
    i.calcStats
  end
  pbTournamentBattle(@opponent[1],@opponent[2],@opponent[3])
  $ISINTOURNAMENT = false
end