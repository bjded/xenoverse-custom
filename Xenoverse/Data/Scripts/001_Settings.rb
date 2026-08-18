#===============================================================================
# * The maximum level Pokémon can reach.
# * The level of newly hatched Pokémon.
# * The odds of a newly generated Pokémon being shiny (out of 65536).
# * The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
#===============================================================================
MAXIMUMLEVEL       = 100
EGGINITIALLEVEL    = 1
# Natural shiny threshold out of 65536: floor(65536 / 100) = 655, approximately 1 / 100.
SHINYPOKEMONCHANCE = 655
POKERUSCHANCE      = 3
BOARDSPEED         = 6.0    
UNCATCHABLE_POKEMON= 230
STAFF_NAMES=["Starkey",
             "ZioCricco",
             "Doc",
             "Sasso",
             "Cydonia",
             "Zekro",
             "Nalkio",
             "Fuji",
             "Makly",
             "Barbie",
             "Lollo",
             "Blaze",
             "Bada",
             "Mike",
             "Shino",
             "Alberto",
             "Ivan",
             "Gordo",
             "Numb",
             "Zeppho",
             "Paco"
             ]
UNLOCKMGSWITCH = 108
#===============================================================================
# * The default screen width (at a zoom of 1.0; size is half this at zoom 0.5).
# * The default screen height (at a zoom of 1.0).
# * The default screen zoom. (1.0 means each tile is 32x32 pixels, 0.5 means
#      each tile is 16x16 pixels, 2.0 means each tile is 64x64 pixels.)
# * Map view mode (0=original, 1=custom, 2=perspective).
#===============================================================================
DEFAULTSCREENWIDTH  = 512
DEFAULTSCREENHEIGHT = 384
DEFAULTSCREENZOOM   = 1.0
MAPVIEWMODE         = 1
# To forbid the player from changing the screen size themselves, quote out or
# delete the relevant bit of code in the PokemonOptions script section.

#===============================================================================
# * Whether poisoned Pokémon will lose HP while walking around in the field.
# * Whether poisoned Pokémon will faint while walking around in the field
#      (true), or survive the poisoning with 1HP (false).
# * Whether fishing automatically hooks the Pokémon (if false, there is a
#      reaction test first).
# * Whether TMs can be used infinitely as in Gen 5 (true), or are one-use-only
#      as in older Gens (false).
# * Whether the player can surface from anywhere while diving (true), or only in
#      spots where they could dive down from above (false).
# * Whether a move's physical/special category depends on the move itself as in
#      newer Gens (true), or on its type as in older Gens (false).
# * Whether the Exp gained from beating a Pokémon should be scaled depending on
#      the gainer's level as in Gen 5 (true), or not as in older Gens (false).
# * Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
#      mechanics (false).
#===============================================================================
POISONINFIELD         = true
POISONFAINTINFIELD    = false
FISHINGAUTOHOOK       = false
INFINITETMS           = true
DIVINGSURFACEANYWHERE = false
USEMOVECATEGORY       = true
USENEWEXPFORMULA      = true
NEWBERRYPLANTS        = true
NOSPLITEXP            = false
USESCALEDEXPFORMULA 	= true
#===============================================================================
# * Pairs of map IDs, where the location signpost isn't shown when moving from
#      one of the maps in a pair to the other (and vice versa).  Useful for
#      single long routes/towns that are spread over multiple maps.
# e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
#   Moving between two maps that have the exact same name won't show the
#      location signpost anyway, so you don't need to list those maps here.
#===============================================================================
NOSIGNPOSTS = []

#===============================================================================
# * Whether outdoor maps should be shaded according to the time of day.
#===============================================================================
ENABLESHADING = true

#===============================================================================
# * The minimum number of badges required to boost each stat of a player's
#      Pokémon by 1.1x, while using moves in battle only.
# * Whether the badge restriction on using certain hidden moves is either owning
#      at least a certain number of badges (true), or owning a particular badge
#      (false).
# * Depending on HIDDENMOVESCOUNTBADGES, either the number of badges required to
#      use each hidden move, or the specific badge number required to use each
#      move.  Remember that badge 0 is the first badge, badge 1 is the second
#      badge, etc.
# e.g. To require the second badge, put false and 1.
#      To require at least 2 badges, put true and 2.
#===============================================================================
BADGESBOOSTATTACK      = 1
BADGESBOOSTDEFENSE     = 5
BADGESBOOSTSPEED       = 3
BADGESBOOSTSPATK       = 7
BADGESBOOSTSPDEF       = 7
HIDDENMOVESCOUNTBADGES = false
BADGEFORCUT            = 1
BADGEFORFLASH          = 2
BADGEFORROCKSMASH      = 3
BADGEFORSURF           = 4
BADGEFORFLY            = 5
BADGEFORSTRENGTH       = 6
BADGEFORDIVE           = 7
BADGEFORWATERFALL      = 8
BADGEFORLAVASURFING    = 89

#===============================================================================
# * The names of each pocket of the Bag.  Leave the first entry blank.
# * The maximum number of slots per pocket (-1 means infinite number).  Ignore
#      the first number (0).
# * The maximum number of items each slot in the Bag can hold.
# * Whether each pocket in turn auto-sorts itself by item ID number.  Ignore
#      the first entry (the 0).
# * The pocket number containing all berries.  Is opened when choosing one to
#      plant, and cannot view a different pocket while doing so.
#===============================================================================
# BROKEN
=begin
def pbPocketNames; return ["",
   _INTL("Items"),
   _INTL("Medicine"),
   _INTL("Poké Balls"),
   _INTL("TMs & HMs"),
   _INTL("Berries"),
   _INTL("Key Items"),
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 99
POCKETAUTOSORT = [0,false,false,false,true,true,false]
BERRYPOCKET    = 5
=end

# WORKING
def pbPocketNames; return ["",
   _INTL("Items"),
   _INTL("Medicine"),
   _INTL("Poké Balls"),
   _INTL("TMs & HMs"),
   _INTL("Berries"),
   _INTL("Mail"),
   _INTL("Battle Items"),
   _INTL("Key Items")
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 999
POCKETAUTOSORT = [0,false,false,false,true,true,false,false,false]
BERRYPOCKET    = 5

#===============================================================================
# * The name of the person who created the Pokémon storage system.
# * The number of boxes in Pokémon storage.
#===============================================================================
def pbStorageCreator
  return _INTL("Esteban")
end
STORAGEBOXES = 120#70#24

#===============================================================================
# * Whether the Pokédex list shown is the one for the player's current region
#      (true), or whether a menu pops up for the player to manually choose which
#      Dex list to view when appropriate (false).
# * The names of each Dex list in the game, in order and with National Dex at
#      the end.  This is also the order that $PokemonGlobal.pokedexUnlocked is
#      in, which records which Dexes have been unlocked (first is unlocked by
#      default).
#      You can define which region a particular Dex list is linked to.  This
#      means the area map shown while viewing that Dex list will ALWAYS be that
#      of the defined region, rather than whichever region the player is
#      currently in.  To define this, put the Dex name and the region number in
#      an array, like the Kanto and Johto Dexes are.  The National Dex isn't in
#      an array with a region number, therefore its area map is whichever region
#      the player is currently in.
# * Whether all forms of a given species will be immediately available to view
#      in the Pokédex so long as that species has been seen at all (true), or
#      whether each form needs to be seen specifically before that form appears
#      in the Pokédex (false).
# * An array of numbers, where each number is that of a Dex list (National Dex
#      is -1).  All Dex lists included here have the species numbers in them
#      reduced by 1, thus making the first listed species have a species number
#      of 0 (e.g. Victini).
#===============================================================================
DEXDEPENDSONLOCATION = false
def pbDexNames; return [
   [_INTL("Pokédex Regionale"),0],
   [_INTL("Xenodex"),1],
   _INTL("Pokédex Nazionale")
]; end
ALWAYSSHOWALLFORMS = false
DEXINDEXOFFSETS    = []

#===============================================================================
# * The amount of money the player starts the game with.
# * The maximum amount of money the player can have.
# * The maximum number of Game Corner coins the player can have.
#===============================================================================
INITIALMONEY = 3000
MAXMONEY     = 9999999
MAXCOINS     = 99999

#===============================================================================
# * A set of arrays each containing a trainer type followed by a Global Variable
#      number.  If the variable isn't set to 0, then all trainers with the
#      associated trainer type will be named as whatever is in that variable.
#===============================================================================
RIVALNAMES = [
   [:RIVAL1,12],
   [:RIVAL2,12],
   [:CHAMPION,12]
]

#===============================================================================
# * A list of maps used by roaming Pokémon.  Each map has an array of other maps
#      it can lead to.
# * A set of arrays each containing the details of a roaming Pokémon.  The
#      information within is as follows:
#      - Species.
#      - Level.
#      - Global Switch; the Pokémon roams while this is ON.
#      - Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
#           4=surfing/fishing).  See bottom of PokemonRoaming for lists.
#      - Name of BGM to play for that encounter (optional).
#      - Roaming areas specifically for this Pokémon (optional).
#      - Pokémon Held Item (optional).
#===============================================================================
RoamingAreas = {
   5  => [21,28,31,39,41,44,47,66,69],
   21 => [5,28,31,39,41,44,47,66,69],
   28 => [5,21,31,39,41,44,47,66,69],
   31 => [5,21,28,39,41,44,47,66,69],
   39 => [5,21,28,31,41,44,47,66,69],
   41 => [5,21,28,31,39,44,47,66,69],
   44 => [5,21,28,31,39,41,47,66,69],
   47 => [5,21,28,31,39,41,44,66,69],
   66 => [5,21,28,31,39,41,44,47,69],
   69 => [5,21,28,31,39,41,44,47,66]
}
SWITCH_DIELEBI = 992
SWITCH_ALL_LEGE = 1395
AllMaps = {
   38=>[40,23,26,27,68,92,96,75,42,454,117,108,220,264,280,247],
   40=>[38,23,26,27,68,92,96,75,42,454,117,108,220,264,280,247],
   23=>[38,40,26,27,68,92,96,75,42,454,117,108,220,264,280,247],
   26=>[38,40,23,27,68,92,96,75,42,454,117,108,220,264,280,247],
   27=>[38,40,23,26,68,92,96,75,42,454,117,108,220,264,280,247],
   68=>[38,40,23,26,27,92,96,75,42,454,117,108,220,264,280,247],
   92=>[38,40,23,26,27,68,96,75,42,454,117,108,220,264,280,247],
   96=>[38,40,23,26,27,68,92,75,42,454,117,108,220,264,280,247],
   75=>[38,40,23,26,27,68,92,96,42,454,117,108,220,264,280,247],
   42=>[38,40,23,26,27,68,92,96,75,454,117,108,220,264,280,247],
   454=>[38,40,23,26,27,68,92,96,75,42,117,108,220,264,280,247],
   117=>[38,40,23,26,27,68,92,96,75,42,454,108,220,264,280,247],
   108=>[38,40,23,26,27,68,92,96,75,42,454,117,220,264,280,247],
   220=>[38,40,23,26,27,68,92,96,75,42,454,117,108,264,280,247],
   264=>[38,40,23,26,27,68,92,96,75,42,454,117,108,220,280,247],
   280=>[38,40,23,26,27,68,92,96,75,42,454,117,108,220,264,247],
   247=>[38,40,23,26,27,68,92,96,75,42,454,117,108,220,264,280],
}

RoamingSpecies = [
    [:DIELEBI, 50, SWITCH_DIELEBI,0,"vs. dielebi",AllMaps],
    #MEW, HOOH, LUGIA, CELEBI, DEOXYS, HEATRAN, REGIGIGAS,
    #CRESSELIA, DARKRAI, GENESECT
    [:HOOH,80,SWITCH_ALL_LEGE,0,"VS. Lugiahooh",AllMaps],
    [:LUGIA,80,SWITCH_ALL_LEGE,0,"VS. Lugiahooh",AllMaps],
    [:REGIGIGAS,80,SWITCH_ALL_LEGE,0,"VS.Regi",AllMaps,:COLOSSTELE],
    [:DARKRAI,80,SWITCH_ALL_LEGE,0,"VS. LegendaryDP",AllMaps],
    [:CRESSELIA,80,SWITCH_ALL_LEGE,0,"VS. LegendaryDP",AllMaps],
    [:MEW,80,SWITCH_ALL_LEGE,0,"vs. Legendary RedBlue",AllMaps],
    [:CELEBI,80,SWITCH_ALL_LEGE,0,"VS. Lugiahooh",AllMaps],
    [:DEOXYS,80,SWITCH_ALL_LEGE,0,"VS.Deoxys",AllMaps],
    [:HEATRAN,80,SWITCH_ALL_LEGE,0,"VS. LegendaryDP",AllMaps],
    [:GENESECT,80,SWITCH_ALL_LEGE,0,"VS.Genesect",AllMaps],
   #[:LATIAS, 30, 53, 0, "002-Battle02x"],
   #[:LATIOS, 30, 53, 0, "002-Battle02x"],
   #[:KYOGRE, 40, 54, 2, nil,{
   #    2  => [21,31],
   #    21 => [2,31,69],
   #    31 => [2,21,69],
   #    69 => [21,31] }],
   #[:ENTEI, 40, 55, 1, nil]
]

#===============================================================================
# * A set of arrays each containing details of a wild encounter that can only
#      occur via using the Poké Radar.  The information within is as follows:
#      - Map ID on which this encounter can occur.
#      - Probability that this encounter will occur (as a percentage).
#      - Species.
#      - Minimum possible level.
#      - Maximum possible level (optional).
#===============================================================================
POKERADAREXCLUSIVES=[
   [5,  20, :STARLY,     12, 15],
   [21, 10, :STANTLER,   14],
   [28, 20, :BUTTERFREE, 15, 18],
   [28, 20, :BEEDRILL,   15, 18]
]

#===============================================================================
# * A set of arrays each containing details of a graphic to be shown on the
#      region map if appropriate.  The values for each array are as follows:
#      - Region number.
#      - Global Switch; the graphic is shown if this is ON (non-wall maps only).
#      - X coordinate of the graphic on the map, in squares.
#      - Y coordinate of the graphic on the map, in squares.
#      - Name of the graphic, found in the Graphics/Pictures folder.
#  - The graphic will always (true) or never (false) be shown on a wall map.
# CI STA LAVORANDO PIETRO, NON TOCCARE
#===============================================================================
REGIONMAPEXTRAS = [
=begin
   [0,54,6,12,"mapCittàPiccola",false],     #Ranch Liopigro
   [0,55,5,8,"mapCittàOrizzontale",false],  #Ludopoli
   [0,56,2,9,"mapCittàPiccola",false],      #Isola Bonita
   [0,57,2,6,"mapCittàPiccola",false],      #Arcipelago Voodoo
   [0,58,7,1,"mapCittàPiccola",false],      #Monte Pico
   [0,59,7,2,"mapGrottaPiccola",false],     #Grotta Ghiacciolo
   [0,60,13,4,"mapCittàGrande",false],      #Campus Acero
   [0,61,16,4,"mapCittàOrizzontale",false], #Borgo Mela
   [0,62,17,5,"mapGrottaVerticale",false],  #Bosco Filante
   [0,63,18,7,"mapCittàVerticale",false],   #Regno Caramello
   [0,64,21,4,"mapCittàOrizzontale",false], #OasiCocente
   [0,65,21,1,"mapCittàPiccola",false],     #Rocca Draconica
   [0,66,17,1,"mapGrottaPiccola",false],    #Vulcano Decibel
   [0,67,17,0,"mapGrottaPiccola",false],    #Grotta dell'Epilogo
=end
]

#===============================================================================
# * The number of steps allowed before a Safari Zone game is over (0=infinite).
# * The number of seconds a Bug Catching Contest lasts for (0=infinite).
#===============================================================================
SAFARISTEPS    = 600
BUGCONTESTTIME = 1200

#===============================================================================
# * The Global Switch that is set to ON when the player whites out.
# * The Global Switch that is set to ON when the player has seen Pokérus in the
#      Poké Center, and doesn't need to be told about it again.
# * The Global Switch which, while ON, makes all wild Pokémon created be
#      shiny.
# * The Global Switch which, while ON, makes all Pokémon created considered to
#      be met via a fateful encounter.
# * The Global Switch which determines whether the player will lose money if
#      they lose a battle (they can still gain money from trainers for winning).
# * The Global Switch which, while ON, prevents all Pokémon in battle from Mega
#      Evolving even if they otherwise could.
# * The ID of the common event that runs when the player starts fishing (runs
#      instead of showing the casting animation).
# * The ID of the common event that runs when the player stops fishing (runs
#      instead of showing the reeling in animation).
#===============================================================================
STARTING_OVER_SWITCH      = 5
SEEN_POKERUS_SWITCH       = 2
SHINY_WILD_POKEMON_SWITCH = 31
FATEFUL_ENCOUNTER_SWITCH  = 206
NO_MONEY_LOSS             = 33
NO_MEGA_EVOLUTION         = 34
FISHINGBEGINCOMMONEVENT   = -1
FISHINGENDCOMMONEVENT     = -1

#===============================================================================
# * The ID of the animation played when the player steps on grass (shows grass
#      rustling).
# * The ID of the animation played when a trainer notices the player (an
#      exclamation bubble).
# * The ID of the animation played when a patch of grass rustles due to using
#      the Poké Radar.
# * The ID of the animation played when a patch of grass rustles vigorously due
#      to using the Poké Radar. (Rarer species)
# * The ID of the animation played when a patch of grass rustles and shines due
#      to using the Poké Radar. (Shiny encounter)
# * The ID of the animation played when a berry tree grows a stage while the
#      player is on the map (for new plant growth mechanics only).
#===============================================================================
GRASS_ANIMATION_ID           = 1
DUST_ANIMATION_ID            = 2
EXCLAMATION_ANIMATION_ID     = 3
RUSTLE_NORMAL_ANIMATION_ID   = 1
RUSTLE_VIGOROUS_ANIMATION_ID = 5
RUSTLE_SHINY_ANIMATION_ID    = 6
PLANT_SPARKLE_ANIMATION_ID   = 7

#===============================================================================
# * An array of available languages in the game, and their corresponding
#      message file in the Data folder.  Edit only if you have 2 or more
#      languages to choose from.
#===============================================================================
LANGUAGES = [
  ["Italiano","italian.dat"],
  ["English","english.dat"],
#  ["Deutsch","deutsch.dat"],
  
]

#===============================================================================
# * Whether names can be typed using the keyboard (true) or chosen letter by
#      letter as in the official games (false).
#===============================================================================
USEKEYBOARDTEXTENTRY = true

VS_BAR_SWITCH=90

#===============================================================================
# * Config Script For Your Game Here. Change the emo_ to what ever number is 
#        the cell holding the animation.
#===============================================================================
Following_Activated_Switch = 126      # Switch should be reserved
Toggle_Following_Switch = 193         # Switch should be reserved
Current_Following_Variable = 94       # Variable should be reserved
CommonEvent = 4                       # Common Event space needed
ItemWalk=26                           # Variable should be reserved
Walking_Time_Variable = 27            # Variable should be reserved
Walking_Item_Variable = 28            # Variable should be reserved
Animation_Come_Out = 93               
Animation_Come_In = 94
Emo_Happy = 95
Emo_Normal = 96
Emo_Hate = 97
Emo_Poison= 98
Emo_sing= 99
Emo_love= 100


#===============================================================================
# * Cambio forma leggendari
# * lista leggendari
#===============================================================================
CF_LEGENDARIES = [:MEW,
                  :HOOH,
                  :LUGIA,
                  :CELEBI,
                  :DEOXYS,
                  :CRESSELIA,
                  :HEATRAN,
                  :DARKRAI,
                  :ENTEI,
                  :SUICUNE,
                  :RAIKOU,
                  :MEWTWO] #TODO to be updated


class Version < Array
   def initialize(ver)
      super(ver.split('.').map{|e| e.to_i})
   end

   def < x
      (self <=> x) < 0
   end
   def > x
      (self <=> x) > 0
   end

   def <= x
      (self <=> x) <= 0
   end

   def >= x
      (self <=> x) >= 0
   end

   def is x
      (self <=> x) == 0
   end
end

GAME_VERSION = Version.new("1.5.6")


def pbTestVersions
   echoln Version.new('1.2') >= Version.new('1.2.1')
   echoln Version.new('1.2') < Version.new('1.10.1')
   echoln Version.new('1.2') < Version.new('1.1.9')
   echoln Version.new('1.3.10') < Version.new('1.3.9')
end
