#===============================================================================
#  S.J. Plugins
#    by Luka S.J.
# ----------------
#  Global Settings
# ----------------  
#  The main master system used to globally handle all scripts made by Luka S.J.
#  After the auto installation process, it keeps all the various plugins
#  collectively stored in one neat place.
#
#  Enjoy the scripts, and make sure to give credit when using them!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#
#  All your general System settings get configured here
#  Everything is commented in detail. Please be sure to read it!
#===============================================================================
#  Global Settings
#===============================================================================
# fixes the issues caused by F12 soft-resetting
SOFTRESETFIX = true
#===============================================================================                           
#  Ultimate Title Screen Resource (settings)
#===============================================================================                           
# Config value for selecting title screen style
SCREENSTYLE = 8
# 0 - A custom-styled screen (moves dynamically with the mouse [if present])
# 1 - FR/LG
# 2 - HG/SS
# 3 - R/S/E
# 4 - D/P/PT
# 5 - B/W
# 6 - X/Y    <- Definitely the best one
# 7 - S/M
# 8 - Xenoverse

# Species for the Pokemon cry being played
# Set as nil for no cry (not applicable with style 5)
SPECIES = PBSpecies::WEEDLE
#-------------------------------------------------------------------------------
# BGM configurations
#-------------------------------------------------------------------------------
# BGM names for the different styles
GEN_ONE_BGM = "title_frlg.ogg"
GEN_TWO_BGM = "title_hgss.ogg"
GEN_THREE_BGM = "title_rse.ogg"
GEN_FOUR_BGM = "title_dppt.mid"
GEN_FIVE_BGM = "title_bw.ogg"
GEN_SIX_BGM = "title_xy.ogg"
GEN_SEVEN_BGM = "title_sm.ogg"
GEN_CUSTOM_BGM = "title_origin.ogg"
# BGM names for the FR/LG intro scene (left one is for style 1, right is for 0)
CLASSIC_INTRO_BGM = (SCREENSTYLE==1) ? "intro_frlg.ogg" : "intro_origin.ogg"
# BGM name for the credits scene
CREDITS_BGM = "credits.ogg"
#-------------------------------------------------------------------------------
# Turns on the option for the game to restart after music has done playing
RESTART_TITLE = true
# Decides whether or not to play the title screen even if $DEBUG is on
PLAY_ON_DEBUG = false
#-------------------------------------------------------------------------------
# More detailed configurations:
#-------------------------------------------------------------------------------
# Decides whether or not, or which Intro scene to play
#   1 - FR/LG
PLAY_INTRO_SCENE = false
# Decides between the use of OR/AS or R/S/E styled opening for style 3
NEW_GENERATION = true
# Toggle EXPAND_STYLE to:
#   - colour the background in style 5
#   - show the Pokemon panorama in style 6
#   - give motion to style 7
EXPAND_STYLE = true
# Applies a form to the Pokemon sprite for style 5
SPECIES_FORM = 0
#-------------------------------------------------------------------------------
# The Following only applies if you're using the Gen 6 style + Elite Battle.
#-------------------------------------------------------------------------------
# Species of the Pokemon displayed in the demo 
EB_SPECIES = [PBSpecies::CHARMELEON,PBSpecies::IVYSAUR,PBSpecies::WARTORTLE]
# Battle backgrounds for different species
EB_BG = ["City","Field","Water"]
# Battle bases for different species
EB_BASE = ["Cave","FieldDirt","CityConcrete"]
# BGM name
EB_DEMO_BGM = "global_opening.ogg"
#===============================================================================                           
#  Fancy Badges (settings)
#===============================================================================                           
# Names for your gym badges
FANCY_BADGE_NAMES = [
    _INTL("Medaglia Radice"),
    _INTL("Medaglia Competizione"),
    _INTL("Medaglia Zucchero"),
    _INTL("Medaglia Marea"),
    _INTL("Medaglia Desolazione"),
    _INTL("Medaglia Ritmo"),
    _INTL("Medaglia Marchiatura"),
    _INTL("Medaglia Onore"),
]
