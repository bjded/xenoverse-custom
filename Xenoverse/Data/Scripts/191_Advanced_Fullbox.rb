################################################################################
# FULLBOX
# Version: 1.0.2b (Build 4 Xenoverse)
# Date: 29/01/2017
# Developer: fuji97
# Designer: fuji97
#
# Scripts edited: Messages
# All rights reserved.
################################################################################
# Provide a new advanced textbox with Mugshots support
################################################################################

# SETTINGS
MUGSHOTHEIGHT = 250										# Mugshot height
MUGSHOTWIDTH = 250										# Mugshot width
MUGSHOT_DEFAULTONE = Tone.new(0,0,0)					# Mugshot activate tone (default)
MUGSHOT_DARKTONE = Tone.new(-50,-50,-50,-50)			# Mugshot no activate tone - if perfomance is slow, remove grey value
MUGNAMEHEIGHT = 282 + 40							# Name block height
MUGNAME_BGCENTER = 20									# Name block center bg width
MUGNAME_BGEXTREME = 22									# Name block extreme part
# Graphics.width = 300									# Name max size (pixels) -- Useless
MUGNAME_BGCOLOR = Color.new(20,20,20)					# Name block backgound color (centre)
MUGNAME_TEXTMARGIN = 8									# Text margin from center block
TEXTBOX_HEIGHT = 96										# Height of the Fullbox
FRAME_ANIMATION = 15									# The duration of the animations (frames)
FBTEXTCOLOR = "FFFFFFFF"								# The main color of the text (RRGGBBAA)
FBTEXTSHADOW = "FFFFFFFF"								# The secondary color of the text (RRGGBBAA)
# New constants
CHARS_IN_ROW = 62
CHARS_IN_ROW2 = 58
WINDOW_BG = "Graphics/Pictures/fullbox/text.png"
CURSOR = "Graphics/Pictures/fullbox/cursor.png"
OFFSET_TEXT_X = 26 #36
OFFSET_TEXT_Y = 24
TIME_TRANSITION = 6
CURSOR_X = Graphics.width - 68
CURSOR_Y = Graphics.height - 48
DEBUG = false											# Enable console debug messages

NEW_FONT_LINE_OFFSET = 6#$MKXP ? 4 : 6

# Font settings
TEXT_FONT = Font.new
TEXT_FONT.name = ["Barlow Condensed","Verdana"]
TEXT_FONT.size = $MKXP ? 25 : 28
TEXT_FONT.color.set(250,250,250,255)

# Log constants
FT_LOG = "Fullbox Text"
FC_LOG = "Fullbox Controller"
FB_LOG = "Fullbox Core"

# Global variables used to track the fullbox, please, don't touch it
$fullbox_visible = false
$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
$fullbox_bg = nil
$fullbox_window = nil
$fullbox_enabled = false

$fullbox_text = []
################################################################################
# DEBUG METHOD
################################################################################
def fbEcholn(text)
	echoln(text) if DEBUG
end

def fbEcho(text)
	echo(text) if DEBUG
end

################################################################################
# EVENT COMMANDS OVERRIDE
################################################################################
OPEN_COMMAND_CHAR = '['
CLOSE_COMMAND_CHAR = ']'
CLOSE_VARIABLE_CHAR = '|'
VAR_CHAR = '@'
SEX_CHAR = '|'
ESCAPE_CHAR = '\\'

def pbTestFullbox
	fbInitialize
	#text = "[new,Taiga Aisaka,taiga,happy,left][new,Ryuuji Takasu,ryuuji,default,right,false][enable,true][act,left]Ah, e quindi il tuo nome vorrebbe dire 'Drago'?[act,right]Si![act,left][mug,left,taiga,thug-life]...\n\n...\n\nPfui, piÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¹ che un dragomi sembri cane, ah ah ah[dispose]"
	text = "Nome: @pl\nSoldi: @pm - @1 [dispose]"
	Fullbox.executeText(text)
end

class String	# Needed to check if string is a number
    def is_i?
       /\A[-+]?\d+\z/ === self
	end
	
	def to_b
    return true if self =~ (/^(true|t|yes|y|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|0)$/i)

    raise ArgumentError.new "invalid value: #{self}"
  end
end

class FullboxWindow
	attr_accessor	:window
	attr_accessor	:text
	attr_accessor	:cursor
	attr_reader		:status
	attr_reader		:opacity
	attr_accessor	:empty
	
	def initialize
		Log.d(FT_LOG,"Initializing 'FullboxWindow'")
		viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewport.z = 100001
		@window = EAMSprite.new(viewport)
		@window.bitmap = Bitmap.new(WINDOW_BG)
		@width = @window.bitmap.width
		@height = @window.bitmap.height
		@text = EAMSprite.new(viewport)
		@window.x = (Graphics.width - @width) / 2
		@window.y = Graphics.height
		@text.x = @window.x + OFFSET_TEXT_X
		@text.y = @window.y + OFFSET_TEXT_Y
		@cursor = EAMSprite.new(viewport)
		@cursor.x = CURSOR_X
		@cursor.y = CURSOR_Y + @window.bitmap.height
		@cursor.bitmap = Bitmap.new(CURSOR)
		Log.d(FT_LOG,"@window = " + @window.to_s)
		@status = :hide
		@opacity = :full
		@empty = true
	end
	
	def show(wait=true,speak=true)
		# Reset opacity
		return if @empty
		fbEnable(true,false) if !$fullbox_enabled
		fbSpeaking(true) if speak
		@text.opacity = 255
		@cursor.opacity = 255
		@opacity = :full
		
		Log.d(FT_LOG,"Textbox 'show' called")
		@status = :show
		@window.move(@window.x,@window.y - @window.bitmap.height,TIME_TRANSITION)
		@text.move(@text.x,@text.y - @window.bitmap.height,TIME_TRANSITION)
		@cursor.move(@cursor.x,@cursor.y - @window.bitmap.height,TIME_TRANSITION)
		while @window.isAnimating?
			update
			Fullbox.graphicsUpdate
		end
		if wait
			Input.update
			#until Input.press?(Input::A) || Input.press?(Input::B) || 
			#	Input.press?(Input::C) || Input.press?(Input::X) || 
			#	Input.press?(Input::Y) || Input.press?(Input::Z) || ($mouse && $mouse.leftClick?)
			until Input.trigger?(Input::C)
        update
				Fullbox.graphicsUpdate
				Input.update
			end
			pbPlayDecisionSE()
		end
	end
	
	def hide(wait=true,speak=true)
		Log.d(FT_LOG,"Textbox 'hide' called")
		@status = :hide
		@window.move(@window.x,@window.y + @window.bitmap.height,TIME_TRANSITION)
		@text.move(@text.x,@text.y + @window.bitmap.height,TIME_TRANSITION)
		@cursor.move(@cursor.x,@cursor.y + @window.bitmap.height,TIME_TRANSITION)
		while @window.isAnimating?
			update
			Fullbox.graphicsUpdate
		end
		fbSpeaking(false) if speak
	end
	
	
	def transparent(val)
		Log.d(FT_LOG,"Textbox 'trasparent' called with '" + val.to_s + "'")
		return if @text.disposed?
		if val
			@text.opacity = 180
			@cursor.opacity = 0
			@opacity = :transparent
		else
			@text.opacity = 255
			@cursor.opacity = 2550
			@opacity = :full
		end
	end
	
	def update
		@window.update
		@text.update
		@cursor.update
	end
	
	def dispose
		hide if status == :show
		@window.dispose
		@text.dispose
		@cursor.dispose
	end
	
end

class Fullbox
  
	def self.graphicsUpdate
		pbUpdateSceneMap
		Graphics.update
	end
	
	def self.prepareString(text)
		return "" if text == "" or text == "\n"	# I'm not sure if this is a good idea...
		fbSpeaking(true)
		fbUpdate
		Log.d(FT_LOG,"Preparing string with text = " + text)
		lines = text.split("\n")
		# Can't use 'for' because the array's length is not updated after each cycle
		i = 0
		while i < lines.length
      #if lines.length==1
        if lines[i].length > CHARS_IN_ROW
          sliced = lines[i].slice!(0..CHARS_IN_ROW-1)
          Log.d(FT_LOG,"Sliced row: '" + sliced + "' '" + lines[i] + "'")
          begin
            splitted = sliced.split(/ ([^ ]*)$/,2)
            Log.d(FT_LOG,"Splitted slice: '" + splitted[0] + "' '" + splitted[1] + "'")
            lines[i] = splitted[1] + lines[i]
            lines.insert(i,splitted[0])
          rescue
            Log.d(FT_LOG,"Can't find whitespaces")
            lines.insert(i,sliced)
          end
        end
      #elsif lines.length==2
      #  if lines[i].length > CHARS_IN_ROW
      #    sliced = lines[i].slice!(0..CHARS_IN_ROW-1)
      #    Log.d(FT_LOG,"Sliced row: '" + sliced + "' '" + lines[i] + "'")
      #    begin
      #      splitted = sliced.split(/ ([^ ]*)$/,2)
      #      Log.d(FT_LOG,"Splitted slice: '" + splitted[0] + "' '" + splitted[1] + "'")
      #      lines[i] = splitted[1] + lines[i]
      #      lines.insert(i,splitted[0])
      #    rescue
      #      Log.d(FT_LOG,"Can't find whitespaces")
      #      lines.insert(i,sliced)
      #    end
      #  end
      if lines[i+1]
        if lines[i+1].length > CHARS_IN_ROW2
          sliced = lines[i+1].slice!(0..CHARS_IN_ROW2-1)
          Log.d(FT_LOG,"Sliced row: '" + sliced + "' '" + lines[i+1] + "'")
          begin
            splitted = sliced.split(/ ([^ ]*)$/,2)
            Log.d(FT_LOG,"Splitted slice: '" + splitted[1] + "' '" + splitted[2] + "'")
            lines[i+1] = splitted[1] + lines[i+1]
            lines.insert(i+1,splitted[0])
          rescue
            Log.d(FT_LOG,"Can't find whitespaces")
            lines.insert(i,sliced)
          end
        end
      end
      #end
			i += 1
		end
   # if lines[0].length > CHARS_IN_ROW2
   #     sliced = lines[1].slice!(0..CHARS_IN_ROW2-1)
   #     Log.d(FT_LOG,"Sliced row: '" + sliced + "' '" + lines[1] + "'")
	 #		begin
	#				splitted = sliced.split(/ ([^ ]*)$/,2)
	#				Log.d(FT_LOG,"Splitted slice: '" + splitted[0] + "' '" + splitted[1] + "'")
		#			lines[1] = splitted[1] + lines[1]
		#			lines.insert(1,splitted[0])
		#		rescue
		#			Log.d(FT_LOG,"Can't find whitespaces")
		#			lines.insert(1,sliced)
		#		end
		#	end
		#Log.d(FT_LOG," lines (" + lines.length.to_s + ") " + lines.to_s)
		
		# Remove empty rows
		lines.reject! { |c| c.empty? }
		
		# Start main loop
		loop do
			bitmap = nil
      if lines.length==1
        bitmap = Fullbox.makeSprite(lines.shift)
      elsif lines.length==0
        $fullbox_window.transparent(true)
				fbSpeaking(false)
				fbUpdate
				return ""
      else
        bitmap = Fullbox.makeSprite(lines.shift,lines.shift)
      end
=begin
			case lines.length
			when 1
				bitmap = Fullbox.makeSprite(lines.shift)
			when 0
				$fullbox_window.transparent(true)
				fbSpeaking(false)
				fbUpdate
				return ""
			else
				bitmap = Fullbox.makeSprite(lines.shift,lines.shift)
			end
=end
			$fullbox_window.empty = false
			$fullbox_window.hide if $fullbox_window.status == :show
			$fullbox_window.text.bitmap.dispose if $fullbox_window.text.bitmap
			$fullbox_window.text.bitmap = bitmap
			$fullbox_window.show
		end
	end
	
	def self.makeSprite(text1,text2=nil)
		Log.d(FT_LOG,"Make sprite with text1: " + text1 + (text2 ? " text2: " + text2 : ""))
		width = $fullbox_window.window.bitmap.width - OFFSET_TEXT_X * 2
		height = $fullbox_window.window.bitmap.height - OFFSET_TEXT_Y * 2
		bitmap = Bitmap.new(width,height + ($MKXP ? 4:0))
		writer = Bitmap.new(Graphics.width-30,80)
		writer.font = TEXT_FONT
    	writer.drawFormattedTextFullbox(writer,0,10,Graphics.width,text1,Color.new(255,255,255))
		#writer.draw_text(0,0,Graphics.width,60,text1)#drawFormattedTextEx(bitmap,0,0,Graphics.width-50,text1,Color.new(255,255,255),Color.new(44,44,44))#draw_text(0,0,Graphics.width,60,text1)
    	txtHeight = (60 - TEXT_FONT.size) / 2
		rect = Rect.new(0,txtHeight,Graphics.width-10,writer.height+8)
		bitmap.blt(0,0,writer,rect)
		if text2
			writer.clear
			#writer.draw_text(0,0,Graphics.width-80,60,text2)
			writer.drawFormattedTextFullbox(writer,0,10 + NEW_FONT_LINE_OFFSET,Graphics.width,text2,Color.new(255,255,255))
      		#Log.d(FT_LOG,"" + (bitmap.height - rect.height).to_s + "/" + bitmap.height.to_s)
			bitmap.blt(0,(bitmap.height - TEXT_FONT.size - ($MKXP ? 4:0)),writer,rect)
		end
		writer.dispose
		return bitmap
	end
	
  def self.executeText(string)
		echo "called for "
		echoln string
		# Fix for Xenoverse
		if !string.match(/^\[old\]/)
			string.gsub!(/(\\PN)|(\\PM)|\\v\[([0-9]*)\]/) { |com|
				case com
				when "\\PN"
					com = "@pl|"
				when "\\PM"
					com = "@pm|"
				else
					if match = com.match(/\\v\[([0-9]*)\]/)[1]
						com = "@#{match}|"
					end
				end
			}
			fbInitialize(true)
		end
		
		viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		viewport.z = 100010
   		buffer = ""
    	i = 0
		line = 1
    	while i < string.length do
      		if string[i].chr == OPEN_COMMAND_CHAR and (i < 1 or string[i-1].chr != ESCAPE_CHAR) then
        		command = "" 
        		i += 1
				while i < string.length and string[i].chr != CLOSE_COMMAND_CHAR do
					command += string[i].chr
					i+= 1
				end
				Log.d(FT_LOG,"Command found: #{command}")
				buffer = Fullbox.prepareString(buffer)
        		resPrep = Fullbox.prepare(command)
				if resPrep == 1
					Kernel.pbMessage(string.gsub(/^\[old\]/,""))
					return
				end
				buffer += resPrep
				
      		elsif string[i].chr == VAR_CHAR and (i < 1 or string[i-1].chr != ESCAPE_CHAR) then
				val = ""
				i += 1
        		while i < string.length and string[i].chr != " " and string[i].chr != "\n" and string[i].chr != "@" and string[i].chr != CLOSE_VARIABLE_CHAR do
          			val += string[i].chr
					i += 1
       			end 
				Log.d(FT_LOG,"Variable found: #{val.to_s}")
        		buffer += Fullbox.var(val)
        		i -= 1 if string[i].chr != CLOSE_VARIABLE_CHAR
			elsif string[i].chr == SEX_CHAR and (i < 1 or string[i-1].chr != ESCAPE_CHAR) then
				Log.d(FT_LOG,"Sex char found, using the #{$Trainer.isFemale? ? "female" : "male"} char")
				t = 0
				begin
					while string[i+t].chr == SEX_CHAR do
						t += 1
					end
				rescue => e
					raise _INTL("Invalid use of sex char in text '{1}'",string)
				end
				if $Trainer.isFemale?
					for y in 1..t
						buffer[buffer.length-t+y-1] = string[i+y+t-1].chr
					end 
				end
				
        		i += t * 2 - 1
      		elsif string[i].chr != ESCAPE_CHAR or (i > 0 and string[i-1].chr == ESCAPE_CHAR) then
        buffer += string[i].chr
      end
      i += 1
    end
	Fullbox.prepareString(buffer)
	Input.update
	#Log.d(FT_LOG,"Final buffer: " + buffer)
    return buffer
  end
  
  def self.var(val)
		if val.is_i?
			return $game_variables[val.to_i].to_s
		else
			case val
			when ""
				return "@"
			when "pl"
				return ($Trainer ? $Trainer.name : false)
			when "pm"
				return pbGetGoldString
			end
    end
		return "Error"
  end

  def self.prepare(command)
    ret = ""
    result = command.split(/&/)
    result.each do |comm|
      if comm.is_i?
        return Fullbox.var(comm.to_i)
      else
				vals = comm.split(/,/)
				param = []
				for i in 1..vals.length-1
					param.push(vals[i])
				end
        return 1 if Fullbox.execute(vals[0],param,ret) == 1
      end
    end
    return ret
  end
  
  def self.execute(command,param,string)
	echoln "Called Execute"
    echoln(command)
		Log.d(FC_LOG,"Command '" + command + "'  parameters (" + param.length.to_s + "): " + param.to_s)
    case command
    when "old"
      return 1
		when "init"
			param[0] = param[0] ? param[0].to_b : false
			fbInitialize(param[0])
		when "enable"
			param[0] = param[0] ? param[0].to_b : false
			param[1] = param[1] ? param[1].to_b : false
			fbEnable(param[0],param[1])
		when "new"
			param[3] = param[3].to_sym
			param[4] = param[4] ? param[4].to_b : false
			param[5] = param[5] ? param[5].to_i : 0
			param[6] = param[6] ? param[6].to_b : false
			fbNewMugshot(param[0],param[1],param[2],param[3],param[4],param[5],param[6])
		when "pos"
			param[0] = param[0].to_sym
			param[1] = param[1].to_sym
			param[2] = param[2] ? param[2].to_i : 0
			fbPosition(param[0],param[1],param[2])
		when "move"
			param[0] = param[0].to_sym
			param[1] = param[1].to_sym
			param[2] = param[2] ? param[2].to_i : 10	# Too bad, rescue doesn't work
			fbMove(param[0],param[1],param[2])
		when "op"
			param[0] = param[0].to_sym
			param[1] = param[1].to_sym
			param[2] = param[2] ? param[2] : 0
			fbOpacity(param[0],param[1],param[2])
		when "fade"
			param[0] = param[0].to_sym
			param[1] = param[1].to_sym
			param[2] = param[2] ? param[2] : 10
			fbFade(param[0],param[1],param[2])
		when "fadeMove"
			param[0] = param[0].to_sym
			param[1] = param[1].to_b
			param[2] = param[2].to_sym
			param[3] = param[3] ? param[3] : 10
			fbFadeMove(param[0],param[1],param[2],param[3])
		when "anim"
			fbAnimate
		when "makeMove"
			fbMakeMove
		when "mug"
			param[0] = param[0].to_sym
			fbMugshot(param[0],param[1],param[2])
		when "update"
			param[0] = param[0] ? param[0] : true
			fbUpdate(param[0])
		when "del"
			param[0] = param[0] ? param[0].to_sym : nil
			fbDeleteMugshot(param[0])
		when "act"
			param[0] = param[0] ? param[0].to_sym : nil
			fbActive(param[0])
		when "actAll"
			fbActiveAll
		when "speak"
			param[0] = param[0].to_sym
			fbSpeaking(param[0])
    	when "dispose"
			fbDispose
		end
		return ""
	end
end

################################################################################
# FULLBOX METHOD
################################################################################
def fbInitialize(fast=false)	# Called from other management method
	Log.d(FB_LOG,"fbInitialize(" + fast.to_s + ")")
	return false if fbInitialized?
	viewport = Viewport.new(0,Graphics.height - TEXTBOX_HEIGHT,Graphics.width,TEXTBOX_HEIGHT)
	viewport.z = 99997
	$fullbox_window = FullboxWindow.new
	$fullbox_bg = Sprite.new(viewport)
	$fullbox_bg.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	$fullbox_bg.visible = false
	if fast
		$fullbox_bg.visible = true
		fbEnable(true)
	end
end

def fbInitialized?
	if $fullbox_window.nil? || $fullbox_bg.nil?
		return false
	else
		return true
	end
end

def fbEnable(enable,showOld=false)
	Log.d(FB_LOG,"fbEnable(" + enable.to_s + ")")
	$fullbox_window.hide if !enable
	$fullbox_bg.visible = enable
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot
			next mugshot.each {|mugshot| mugshot.enabled = enable} if !mugshot.is_a?(Mugshot_Wrapper)	#Possible conflicts
			mugshot.enabled = enable
		end
	end
	$fullbox_enabled = enable
	$fullbox_window.show if enable && showOld
end

def fbNewMugshot(name,type,pose,position,active=true,fadeIn=0,fast=false)
  begin
    name = MessageTypes.getFromMapHash($game_map.map_id,name.gsub(/\n/,' '))
  rescue
    name = name
  end
	Log.d(FB_LOG,"fbNewMugshot(" + name + "," + type + "," + pose + "," + position.to_s + "," + active.to_s + "," + fadeIn.to_s + fast.to_s + ")")
	fbInitialize(fast) if !$fullbox_visible
	fbEnable(true) if fast && !$fullbox_enabled
	fadeIn > 1 ? visible = false : visible = true
	mugshot = Mugshot_Wrapper.new(name,type,pose,position,active,visible)
	if position == :out_left || position == :out_left
		$fullbox_mugshots[position.to_s].push(mugshot)
	else
		return if $fullbox_mugshots[position.to_s]
		$fullbox_mugshots[position.to_s] = mugshot
	end
	mugshot.setVisibility(true,fadeIn) if fadeIn > 1
	return mugshot
end

=begin
def fbPosition(arr,position,frame=0,switch=false)
	fbEcholn("*******************************\r\nfbPosition(" + arr.to_s + "," + position.to_s + "," + frame.to_s + "," + switch.to_s + ")")
	fbEcholn("\tChange position: " + arr.to_s)
	if arr.is_a?(Mugshot_Wrapper)
		startMug = arr
		$fullbox_mugshots[arr.position.to_s] = nil
		$fullbox_mugshots["out_left"].delete(arr)
		$fullbox_mugshots["out_right"].delete(arr)
	elsif arr.is_a?(Symbol)
		return if arr == :out_left || arr == :out_right
		startMug = $fullbox_mugshots[arr.to_s]
		$fullbox_mugshots[arr.to_s] = nil
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbPosition(mugshot,position,frame)}
	end
	return if !startMug	# Exit if startMug isn't be setted (condition valid only if arr is an array)
	
	fbPosition($fullbox_mugshots[position.to_s],startMug.position,frame,true) if ($fullbox_mugshots[position.to_s].is_a?(Mugshot_Wrapper) && !switch)	# This will switch mugshots if destination position is occuped
	startMug.setPosition(position,frame)
	case position
	when :left, :right, :centre
		$fullbox_mugshots[position.to_s] = startMug
	when :out_left, :out_right
		$fullbox_mugshots[position.to_s].push(startMug)
	end
end
=end

def fbPosition(arr,position,frame=0)
	Log.d(FB_LOG,"fbPosition(" + arr.to_s + "," + position.to_s + "," + frame.to_s + ")")
	if arr.is_a?(Mugshot_Wrapper)
		arr.mPosition = position
		arr.mFrame = frame
	elsif arr.is_a?(Symbol)
		return if arr == :out_left || arr == :out_right
		$fullbox_mugshots[arr.to_s].mPosition = position
		$fullbox_mugshots[arr.to_s].mFrame = frame
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbPosition(mugshot,position,frame)}
	end
end

def fbMove(arr,position,frame=10)
	Log.d(FB_LOG,"fbMove(" + arr.to_s + "," + position.to_s + "," + frame.to_s + ")")
	fbPosition(arr,position,frame)
end

def fbOpacity(arr,active,frame=0)
	Log.d(FB_LOG,"fbOpacity(" + arr.to_s + "," + active.to_s + "," + frame.to_s + ")")
	if arr.is_a?(Mugshot_Wrapper)
		arr.setVisibility(active,frame)
	elsif arr.is_a?(Symbol)
		case arr
		when :left, :centre, :right
			$fullbox_mugshots[arr.to_s].setVisibility(active,frame)
		when :out_left, :out_right
			$fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.setVisibility(active,frame)}
		end
	elsif arr.is_a?(Array)
		arr.each {|mugshot| fbOpacity(mugshot,active,frame)}
	end
end

def fbFade(arr,active,frame=10)
	Log.d(FB_LOG,"fbFade(" + arr.to_s + "," + active.to_s + "," + frame.to_s + ")")
	fbOpacity(arr,active,frame)
end

def fbFadeMove(arr,active,position,frame=10)
	Log.d(FB_LOG,"fbFadeMove(" + arr.to_s + "," + active.to_s + "," + position.to_s + "," + frame.to_s + ")")
	fbFade(arr,active,frame)
	fbPosition(arr,position,frame)
end

def fbAnimate(condition=nil)	# Condition must be an array
	Log.d(FB_LOG,"fbAnimate(" + condition.to_s + ")")
	fbMakeMove
	if !condition
		loop do
			ret = true
			$fullbox_mugshots.each_value do |mugshot|
				if mugshot.is_a?(Mugshot_Wrapper)
					ret = false if mugshot.isAnimating?
				elsif mugshot.is_a?(Array)
					mugshot.each {|mugshot| ret = false if mugshot.isAnimating?}
				end
			end
			break if ret
			fbUpdate
		end
	else
		loop do
			ret = true
			condition.each {|mugshot| ret = false if mugshot.isAnimating?}
			break if ret
		end
		fbUpdate
	end
end

def fbMakeMove
	Log.d(FB_LOG,"MakeMove called")
	movedMug =[]
	$fullbox_mugshots.each do |key,mugshot|
		if mugshot.is_a?(Mugshot_Wrapper)
			if mugshot.position != mugshot.mPosition
				movedMug.push(mugshot)
				$fullbox_mugshots[key] = nil
			end
		elsif mugshot.is_a?(Array)
			mugshot.each_index do |index|
				mMugshot = $fullbox_mugshots[key][index]
				if mMugshot.position != mMugshot.mPosition
					movedMug.push(mMugshot)
					$fullbox_mugshots[key][index] = nil
				end
			end
		end
	end
	
	movedMug.each do |mugshot|
		mugshot.setPosition(mugshot.mPosition,mugshot.mFrame)
		case mugshot.mPosition
		when :left, :right, :centre
			!$fullbox_mugshots[mugshot.mPosition.to_s] ? $fullbox_mugshots[mugshot.mPosition.to_s] = mugshot : raise(_INTL("More than one mugshots are located in #{mugshot.mPosition.to_s} position"))
		when :out_left, :out_right
			$fullbox_mugshots[mugshot.mPosition.to_s].push(mugshot)
		end
	end
end

def fbMugshot(mug,type,pose)
	Log.d(FB_LOG,"fbMugshot(" + mug.to_s + "," + type + "," + pose + ")")
	if mug.is_a?(Mugshot_Wrapper)
		mug.setMugshot(type,pose)
	else
		$fullbox_mugshots[mug.to_s].setMugshot(type,pose) if (mug != :out_left && mug != :out_right)
	end
end

def fbUpdate(graphicsUpdate=true)
	#fbEcho("+")
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot.is_a?(Array)
			mugshot.each {|mugshot| mugshot.update}
		elsif mugshot.is_a?(Mugshot_Wrapper)
			mugshot.update
		end
	end
	Fullbox.graphicsUpdate if graphicsUpdate
end

def fbDeleteMugshot(arr=nil)
	Log.d(FB_LOG,"fbDeleteMugshot(" + arr.to_s + ")")
	if !arr
		$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
		return
	elsif arr.is_a?(Mugshot_Wrapper)
		$fullbox_mugshots.each do |mugshot|
			mugshot.is_a?(Mugshot_Wrapper) ? (mugshot = nil if mugshot == arr) : mugshot.each {|mugshot| mugshot.delete(arr)}
		end
		arr.dispose
	elsif arr.is_a?(Symbol)
		if $fullbox_mugshots[arr.to_s].is_a?(Mugshot_Wrapper)
			$fullbox_mugshots[arr.to_s].dispose
			$fullbox_mugshots[arr.to_s] = nil
		else
			$fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.dispose}
			$fullbox_mugshots[arr.to_s] = []
		end
	else
		arr.each {|arr| fbDeleteMugshot(arr)}
	end
end

def fbActive(arr=nil)
	Log.d(FB_LOG,"fbActive(" + arr.inspect + ")")
	$fullbox_mugshots.each_value do |mugshot|
		next if !mugshot.is_a?(Mugshot_Wrapper)
		mugshot.setActive(false)
	end
	if arr.is_a?(Mugshot_Wrapper)
		arr.setActive(true)
	elsif arr.is_a?(Symbol)
		$fullbox_mugshots[arr.to_s].is_a?(Mugshot_Wrapper) ? $fullbox_mugshots[arr.to_s].setActive(true) : $fullbox_mugshots[arr.to_s].each {|mugshot| mugshot.setActive(true)}
	elsif arr.is_a?(Array)
		arr.each {|mugshot| mugshot.setActive(true)}
	end
end

def fbActiveAll
	mugs = []
	$fullbox_mugshots.each_value do |mugshot|
		next if !mugshot.is_a?(Mugshot_Wrapper)
		mugs.push(mugshot)
	end
	fbActive(mugs)
end

def fbSpeaking(speak)
	Log.d(FB_LOG,"fbSpeaking(" + speak.to_s + ")")
	$fullbox_mugshots.each_value do |mugshot|
		if mugshot.is_a?(Mugshot_Wrapper)
		mugshot.speaking=speak
	elsif mugshot.is_a?(Array)
		mugshot.each {|mugshot| mugshot.speaking = speak}
		end
	end
end

def fbDispose
	Log.d(FB_LOG,"fbDispose")
	fbEnable(false) if $fullbox_enabled
	$fullbox_window.dispose if !$fullbox_window.nil?
	$fullbox_bg = nil
	$fullbox_mugshots = {"left" => nil, "centre" => nil, "right" => nil, "out_left" => [], "out_right" => []}
	$fullbox_enabled = false
end

################################################################################
# FULLBOX WRAPPER
################################################################################

class Mugshot_Wrapper
	attr_reader	:enabled
	attr_accessor	:mPosition
	attr_accessor	:mFrame
	
	def initialize(name,type,pose,position=:left,active=true,visible=true)
		@mugshot = Mugshot.new(type,pose,position)
		@mugname = Mugshot_Name.new(name,position)
		@mPosition = :position
		@mFrame = 0
		$fullbox_enabled ? @enabled = true : self.enabled = false
		setActive(active)
		setVisibility(visible)
		#@needUpdate = false
	end
	
	def update
		@mugshot.update
		# @needUpdate system - Deprecated and not finished
		#if @needUpdate && !isTransiting?
		#	@mugname.position = @mugshot.position 
		#	@needUpdate = false
		#end
		@mugname.update
	end
	
	def dispose
		@mugshot.dispose
		@mugname.dispose
	end
	
	def to_s
		return @mugname.name
	end
	
	def name=(name)
		#fbEcholn "\tName changed: " + name
		@mugname = Mugshot_Name.new(name,@mugname.position)
	end
	
	def name
		return @mugname.name
	end
	
	def type=(type)
		#fbEcholn "\tType changed: " + type
		@mugshot.type = type
	end
	
	def type
		return @mugshot.type
	end
	
	def pose=(pose)
		#fbEcholn "\tPose changed: " + pose
		@mugshot.pose = pose
	end
	
	def pose
		return @mugshot.pose
	end
	
	def setMugshot(type=nil,pose=nil)
		#fbEcholn "\tNew mugshot: " + type + "-" + pose
		@mugshot.setMugshot(type,pose)
	end
	
	def position=(pos)
		#fbEcholn "\tPosition changed: " + pos.to_s
		@mugshot.position = pos
		@mugname.position = pos
	end
	
	def position
		return @mugshot.position
	end
	
	def setPosition(pos,frame=0)
		Log.d(FB_LOG,"SetPosition called: (" + pos.to_s + "," + frame.to_s + ")")
		@mugshot.setPosition(pos,frame)
		# @needUpdate = true
		@mugname.position = pos	# Substitute of @needUpdate system
	end
	
	def enabled=(enabled)
		#fbEcholn "\tEnabled changed: " + enabled.to_s
		@enabled = enabled
		setVisibility(enabled)
	end
	
	def isAnimating?
		return @mugshot.isAnimating?
	end
	
	def isTransiting?
		return @mugshot.isTransiting?
	end
	
	def isFading?
		return @mugshot.isFading?
	end
	
	def isVisible?
		return @mugshot.visible
	end
	
	def isActive?
		return @mugshot.active
	end
	
	def setVisibility(visible,frames=0)
		Log.d(FB_LOG,"SetVisibility called (" + visible.to_s + "," + frames.to_s + ")")
		return if (!@enabled && visible)	# || (@enabled && !visible) IDK i've writed this, but keep it just to remember
		@mugshot.setVisibility(visible,frames)
		# @needUpdate = true
		if isActive? && isVisible?
			@mugname.active = true	# Substitute of @needUpdate system
		else
			@mugname.active = false
		end
	end
	
	def setActive(active)
		Log.d(FB_LOG,"SetActive called: " + active.to_s)
		@mugshot.active = active
		if isActive? && isVisible?
			@mugname.active = true	# Substitute of @needUpdate system
		else
			@mugname.active = false
		end
	end
	
	def speaking=(speak)
		@mugname.visible = speak
	end
end

################################################################################
# CLASS OVERRIDE AND METHOD REWRITE TO ADAPTING ESSENTIALS' WINDOW MESSAGE
################################################################################

def Kernel.pbCreateFullboxWindow(viewport=nil)
	msgwindow=Window_AdvancedTextPokemon.new("")
	if !viewport
		msgwindow.z=99999
	else
		msgwindow.viewport=viewport
	end
	msgwindow.visible=true
	msgwindow.letterbyletter=true
	msgwindow.back_opacity=MessageConfig::WindowOpacity
	# msgwindow.lineHeight(32)
	pbBottomLeftLines(msgwindow,2)
	windowWidth = 608
	# msgwindow.resizeToFit("",windowWidth)
	msgwindow.x = (Graphics.width - windowWidth)/2
	msgwindow.width = windowWidth
	# msgwindow.y = Graphics.height - TEXTBOX_HEIGHT	# Y position is just right
	$game_temp.message_window_showing=true if $game_temp
	$game_message.visible=true if $game_message
	msgwindow.setSkin(pbResolveBitmap("Graphics/Windowskins/fullbox")||"")
	return msgwindow
end

def fbText(message,commands=nil,cmdIfCancel=0,defaultCmd=0,&block)
  echoln(message)
  echoln(message.gsub(/\n/,' '))
  echoln("Checking for translation")
	if $PokemonSystem.language != 0 #0 italian, 1 english
		begin
			message=MessageTypes.getFromMapHash($game_map.map_id,message.gsub(/\n/,' ').gsub(/’/,"'"))#MessageTypes.getFromMapHash(0,message)
			echoln(message)
		rescue
			message=message	
		end
	end
	Fullbox.executeText(message)
	return
	
	# From here, the following code is useless :)
	ret=0
	fbEcholn("*******************************\r\nText: " + message)
	# @background = Sprite.new()
	# @background.y = Graphics.height - TEXTBOX_HEIGHT
	# @background.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	message = "<c3=" + FBTEXTCOLOR + "," + FBTEXTSHADOW + ">" + message + "</c3>";
	msgwindow=Kernel.pbCreateFullboxWindow(nil)
	fbSpeaking(true)
	fbUpdate
	if commands
		ret=Kernel.pbMessageDisplayFullbox(msgwindow,message,true,
			proc {|msgwindow|
				next Kernel.pbShowCommands(msgwindow,commands,cmdIfCancel,defaultCmd,&block)
			},&block)
	else
		Kernel.pbMessageDisplayFullbox(msgwindow,message,&block)
	end
	Kernel.pbDisposeMessageWindow(msgwindow)
	fbSpeaking(false)
	fbUpdate(false)
	# @background.dispose
	Input.update
	return ret
end

def Kernel.pbMessageDisplayFullbox(msgwindow,message,letterbyletter=true,commandProc=nil)
	return if !msgwindow
	oldletterbyletter=msgwindow.letterbyletter
	msgwindow.letterbyletter=(letterbyletter ? true : false)
	ret=nil
	count=0
	commands=nil
	facewindow=nil
	goldwindow=nil
	coinwindow=nil
	cmdvariable=0
	cmdIfCancel=0
	msgwindow.waitcount=0
	autoresume=false
	text=message.clone
	msgback=nil
	linecount=(Graphics.height>400) ? 3 : 2
	### Text replacement
	text.gsub!(/\\\\/,"\5")
	if $game_actors
		text.gsub!(/\\[Nn]\[([1-8])\]/){ 
			m=$1.to_i
			next $game_actors[m].name
		}
	end
	text.gsub!(/\\[Ss][Ii][Gg][Nn]\[([^\]]*)\]/){ 
		next "\\op\\cl\\ts[]\\w["+$1+"]"
	}
	text.gsub!(/\\[Pp][Nn]/,$Trainer.name) if $Trainer
	text.gsub!(/\\[Pp][Mm]/,_INTL("${1}",$Trainer.money)) if $Trainer
	text.gsub!(/\\[Nn]/,"\n")
	text.gsub!(/\\\[([0-9A-Fa-f]{8,8})\]/){ "<c2="+$1+">" }
	text.gsub!(/\\[Bb]/,"<c2=6546675A>")
	text.gsub!(/\\[Rr]/,"<c2=043C675A>")
	text.gsub!(/\\1/,"\1")
	colortag=""
	isDarkSkin=isDarkWindowskin(msgwindow.windowskin)
	if ($game_message && $game_message.background>0) ||
		($game_system && $game_system.respond_to?("message_frame") &&
			$game_system.message_frame != 0)
		colortag=getSkinColor(msgwindow.windowskin,0,true)
	else
		colortag=getSkinColor(msgwindow.windowskin,0,isDarkSkin)
	end
	text.gsub!(/\\[Cc]\[([0-9]+)\]/){ 
		m=$1.to_i
		next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
	}
	begin
		last_text = text.clone
		text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
	end until text == last_text
	begin
		last_text = text.clone
		text.gsub!(/\\[Ll]\[([0-9]+)\]/) { 
			linecount=[1,$1.to_i].max;
			next "" 
		}
	end until text == last_text
	text=colortag+text
	### Controls
	textchunks=[]
	controls=[]
	while text[/(?:\\([WwFf]|[Ff][Ff]|[Tt][Ss]|[Cc][Ll]|[Mm][Ee]|[Ss][Ee]|[Ww][Tt]|[Ww][Tt][Nn][Pp]|[Cc][Hh])\[([^\]]*)\]|\\([Gg]|[Cc][Nn]|[Ww][Dd]|[Ww][Mm]|[Oo][Pp]|[Cc][Ll]|[Ww][Uu]|[\.]|[\|]|[\!]|[\x5E])())/i]
		textchunks.push($~.pre_match)
		if $~[1]
			controls.push([$~[1].downcase,$~[2],-1])
		else
			controls.push([$~[3].downcase,"",-1])
		end
		text=$~.post_match
	end
	textchunks.push(text)
	for chunk in textchunks
		chunk.gsub!(/\005/,"\\")
	end
	textlen=0
	for i in 0...controls.length
		control=controls[i][0]
		if control=="wt" || control=="wtnp" || control=="." || control=="|"
			textchunks[i]+="\2"
		elsif control=="!"
			textchunks[i]+="\1"
		end
		textlen+=toUnformattedText(textchunks[i]).scan(/./m).length
		controls[i][2]=textlen
	end
	text=textchunks.join("")
	unformattedText=toUnformattedText(text)
	signWaitCount=0
	haveSpecialClose=false
	specialCloseSE=""
	for i in 0...controls.length
		control=controls[i][0]
		param=controls[i][1]
		if control=="f"
			facewindow.dispose if facewindow
			facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
		elsif control=="op"
			signWaitCount=21
		elsif control=="cl"
			text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
			haveSpecialClose=true
			specialCloseSE=param
		elsif control=="se" && controls[i][2]==0
			startSE=param
			controls[i]=nil
		elsif control=="ff"
			facewindow.dispose if facewindow
			facewindow=FaceWindowVX.new(param)
		elsif control=="ch"
			cmds=param.clone
			cmdvariable=pbCsvPosInt!(cmds)
			cmdIfCancel=pbCsvField!(cmds).to_i
			commands=[]
			while cmds.length>0
				commands.push(pbCsvField!(cmds))
			end
		elsif control=="wtnp" || control=="^"
			text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
		end
	end
	if startSE!=nil
		pbSEPlay(pbStringToAudioFile(startSE))
	elsif signWaitCount==0 && letterbyletter
		pbPlayDecisionSE()
	end
	########## Position message window  ##############
	msgwindow.text=text
	# pbRepositionMessageWindow(msgwindow,linecount)	We don't need reposition
	if $game_message && $game_message.background==1
		msgback=IconSprite.new(0,msgwindow.y,msgwindow.viewport)
		msgback.z=msgwindow.z-1
		msgback.setBitmap("Graphics/System/MessageBack")
	end
	if facewindow
		pbPositionNearMsgWindow(facewindow,msgwindow,:left)
		facewindow.viewport=msgwindow.viewport
		facewindow.z=msgwindow.z
	end
	atTop=(msgwindow.y==0)
	########## Show text #############################
	#msgwindow.text=text
	Graphics.frame_reset if Graphics.frame_rate>40
	begin
		if signWaitCount>0
			signWaitCount-=1
			if atTop
				msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
			else
				msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
			end
		end
		for i in 0...controls.length
			if controls[i] && controls[i][2]<=msgwindow.position && msgwindow.waitcount==0
				control=controls[i][0]
				param=controls[i][1]
				if control=="f"
					facewindow.dispose if facewindow
					facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					facewindow.viewport=msgwindow.viewport
					facewindow.z=msgwindow.z
				elsif control=="ts"
					if param==""
						msgwindow.textspeed=-999
					else
						msgwindow.textspeed=param.to_i
					end
				elsif control=="ff"
					facewindow.dispose if facewindow
					facewindow=FaceWindowVX.new(param)
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					facewindow.viewport=msgwindow.viewport
					facewindow.z=msgwindow.z
				elsif control=="g" # Display gold window
					goldwindow.dispose if goldwindow
					goldwindow=pbDisplayGoldWindow(msgwindow)
				elsif control=="cn" # Display coins window
					coinwindow.dispose if coinwindow
					coinwindow=pbDisplayCoinsWindow(msgwindow,goldwindow)
				elsif control=="wu"
					msgwindow.y=0
					atTop=true
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
				elsif control=="wm"
					atTop=false
					msgwindow.y=(Graphics.height/2)-(msgwindow.height/2)
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
				elsif control=="wd"
					atTop=false
					msgwindow.y=(Graphics.height)-(msgwindow.height)
					msgback.y=msgwindow.y if msgback
					pbPositionNearMsgWindow(facewindow,msgwindow,:left)
					msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
				elsif control=="."
					msgwindow.waitcount+=Graphics.frame_rate/4
				elsif control=="|"
					msgwindow.waitcount+=Graphics.frame_rate
				elsif control=="wt" # Wait
					param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
					msgwindow.waitcount+=param.to_i*2
				elsif control=="w" # Windowskin
					if param==""
						msgwindow.windowskin=nil
					else
						msgwindow.setSkin("Graphics/Windowskins/#{param}")
					end
					msgwindow.width=msgwindow.width  # Necessary evil
				elsif control=="^" # Wait, no pause
					autoresume=true
				elsif control=="wtnp" # Wait, no pause
					param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
					msgwindow.waitcount=param.to_i*2
					autoresume=true
				elsif control=="se" # Play SE
					pbSEPlay(pbStringToAudioFile(param))
				elsif control=="me" # Play ME
					pbMEPlay(pbStringToAudioFile(param))
				end
				controls[i]=nil
			end
		end
		break if !letterbyletter
		Fullbox.graphicsUpdate
		Input.update
		facewindow.update if facewindow
		if $DEBUG && Input.trigger?(Input::F6)
			pbRecord(unformattedText)
		end
		if autoresume && msgwindow.waitcount==0
			msgwindow.resume if msgwindow.busy?
			break if !msgwindow.busy?
		end
		mouseClicked = ($mouse != nil ? $mouse.leftClick? : false)
		if (Input.trigger?(Input::C) || Input.trigger?(Input::B) || mouseClicked)
			if msgwindow.busy?
				pbPlayDecisionSE() if msgwindow.pausing?
				msgwindow.resume
			else
				break if signWaitCount==0
			end
		end
		pbUpdateSceneMap
		msgwindow.update
		yield if block_given?
	end until (!letterbyletter || commandProc || commands) && !msgwindow.busy?
	Input.update # Must call Input.update again to avoid extra triggers
	msgwindow.letterbyletter=oldletterbyletter
	if commands
		$game_variables[cmdvariable]=Kernel.pbShowCommands(
			msgwindow,commands,cmdIfCancel)
		$game_map.need_refresh = true if $game_map
	end
	if commandProc
		ret=commandProc.call(msgwindow)
	end
	msgback.dispose if msgback
	goldwindow.dispose if goldwindow
	coinwindow.dispose if coinwindow
	facewindow.dispose if facewindow
	if haveSpecialClose
		pbSEPlay(pbStringToAudioFile(specialCloseSE))
		atTop=(msgwindow.y==0)
		for i in 0..20
			if atTop
				msgwindow.y=-(msgwindow.height*(i)/20)
			else
				msgwindow.y=Graphics.height-(msgwindow.height*(20-i)/20)
			end
			Fullbox.graphicsUpdate
			Input.update
			pbUpdateSceneMap
			msgwindow.update
		end
	end
	return ret
end

class Window_Fullbox < Window_AdvancedTextPokemon
	
	alias initialize_old initialize
	alias dispose_old dispose
	
	def initialize(text="")
		initialize_old(text)
		self.contents_opacity = 0
		self.height = TEXTBOX_HEIGHT
		self.y = Graphics.height - @height
		@background = Sprite.new()
		@background.z = 100000
		@background.y = Graphics.height - @height
		@background.bitmap = Bitmap.new("Graphics/Pictures/textbox.png")
	end
	
	def dispose
		dispose_old
		@background.dispose
	end
end

################################################################################
# FULLBOX CLASS
################################################################################

class Mugshot_Name		# NB: Viewport used have a Z = 9998
	attr_reader	:position
	attr_reader	:visible
	attr_reader	:name
	attr_accessor	:active
	
	def initialize(text,position)
		@name = text
		mHeight = Graphics.height - TEXTBOX_HEIGHT - 35
		@viewportRect = Rect.new(0,mHeight,Graphics.width+MUGNAME_BGEXTREME*2,35)
		@viewport = Viewport.new(@viewportRect)
		@viewport.z = 100000
		@sprites ={}
		@sprites["start"] = Sprite.new(@viewport)
		@sprites["centre"] = Sprite.new(@viewport)
		@sprites["end"] = Sprite.new(@viewport)
		@sprites["name"] = Sprite.new(@viewport)
		@sprites["name"].bitmap =Bitmap.new(Graphics.width,35)
		@sprites["name"].bitmap.font = TEXT_FONT
		length = @sprites["name"].bitmap.text_size(@name).width
		@rectWidth = length+MUGNAME_TEXTMARGIN*2
		rect = Rect.new(0,0,@rectWidth,35)
		@sprites["start"].bitmap = Bitmap.new("Graphics/Pictures/mugname-start.png")
		@sprites["centre"].bitmap = Bitmap.new(@rectWidth,35)
		@sprites["centre"].x = MUGNAME_BGEXTREME
		@sprites["centre"].bitmap.fill_rect(rect,MUGNAME_BGCOLOR)
		@sprites["end"].bitmap = Bitmap.new("Graphics/Pictures/mugname-end.png")
		@sprites["end"].x = MUGNAME_BGEXTREME + @rectWidth
		@sprites["name"].bitmap.draw_text(MUGNAME_TEXTMARGIN+MUGNAME_BGEXTREME,3,length,30,@name)
		#@rectWidth = @sprites["centre"].bitmap.width + @sprites["start"].bitmap.width + @sprites["end"].bitmap.width
		@active = true
		self.visible = false
		setPosition(position)
	end
	
	def setPosition(position)
		case position
		when :left
			@viewportRect.x = -MUGNAME_BGEXTREME
			@position = :left
		when :centre
			@viewportRect.x = (Graphics.width - @rectWidth - MUGNAME_BGEXTREME*2) / 2
			@position = :centre
		when :right
			@viewportRect.x = Graphics.width - (@rectWidth + MUGNAME_BGEXTREME)
			@position = :right
		when :out_left, :out_right
			@viewportRect.x = Graphics.width	# Dropping out of screen
		else
			raise PositionNotValidError.new
		end
		@viewport.rect = @viewportRect
	end
	
	def position=(position)
		setPosition(position)
	end
	
	def visible=(visible)
		return if !@active
		#fbEcholn("Name visible called with: " + visible.to_s + "," + @active.to_s)
		@sprites.each_value {|sprite| sprite.visible = visible}
		@visible = visible
	end
	
	def update
		pbUpdateSpriteHash(@sprites)
	end
	
	def dispose
		pbDisposeSpriteHash(@sprites)
	end
	
end

class Mugshot < Sprite
	attr_reader		:active
	attr_reader		:current_active
	attr_accessor	:type
	attr_accessor	:pose
	attr_accessor	:position
	
	def initialize(type,pose,position)
		@viewportRect = Rect.new(0,Graphics.height - TEXTBOX_HEIGHT - MUGSHOTHEIGHT,MUGSHOTWIDTH,MUGSHOTHEIGHT)
		@viewport = Viewport.new(@viewportRect)
		@viewport.z = 100000
		super(@viewport)
		@active = true
		@current_active = true
		@type = type
		@pose = pose
		@animations = {"transition" => {"active" => false,"frameCount" => 0,"frameNum" => 0,"ppf" => 0.0,"realPosition" => 0.0},
			"fading" => {"active" => false,"opf" => 0.0,"realOpacity" => 0.0}}
		@animating = false
		setPosition(position)
		setMugshot
	end
	
	def update
		super
		if isTransiting?
			@animations["transition"]["realPosition"] += @animations["transition"]["ppf"]
			@viewportRect.x = @animations["transition"]["realPosition"].round if @animations["transition"]["frameCounter"] < @animations["transition"]["frameNum"]
			@viewport.rect = @viewportRect
			@animations["transition"]["frameCounter"] += 1
			# Kernel.fbEcholn(@animations["transition"]["frameCounter"].to_s + "/" + @animations["transition"]["frameNum"].to_s + " - Real position = " + @animations["transition"]["realPosition"].to_s)
			if @animations["transition"]["frameCounter"] >= @animations["transition"]["frameNum"]
				setPosition(@position)
				@animations["transition"]["realPosition"] = 0
				@animations["transition"]["frameCounter"] = 0
				@animations["transition"]["frameNum"] = 0
				@animations["transition"]["ppf"] = 0
				@animations["transition"]["active"] = false
				@animating = false if !@animations["fading"]["active"]
			end
		end
		if isFading?
			@animations["fading"]["realPosition"] += @animations["fading"]["opf"]
			self.opacity = @animations["fading"]["realPosition"].round
			if self.opacity >= 255 || self.opacity <= 0
				@animations["fading"]["realPosition"] = 0
				@animations["fading"]["opf"] = 0
				@animations["fading"]["active"] = false
				@animating = false if !@animations["transition"]["active"]
				if self.opacity <= 0
					self.visible = false
					self.opacity = 255
				else
					self.visible = true
				end
			end
		end
		if @active != @current_active
			@active ? self.tone = MUGSHOT_DEFAULTONE : self.tone = MUGSHOT_DARKTONE
			@current_active = @active
		end
	end
	
	def isAnimating?
		return @animating
	end
	
	def isTransiting?
		return @animations["transition"]["active"]
	end
	
	def isFading?
		return @animations["fading"]["active"]
	end
	
	def x=(x)
		@viewport = x
	end
	
	def setMugshot(type=nil,pose=nil)
		@type = type if type
		@pose = pose if pose
		path = "Graphics/Mugshots/" + @type + "-" + @pose
		self.bitmap.dispose if self.bitmap
		self.bitmap = Bitmap.new(path)
		end
		
		def position=(pos)
			setPosition(pos)
		end
	
	def setPosition(position, frames=0)	# Can be :left :right or :centre
		if frames < 2
			@viewportRect.x = pixelPosition(position)
			@position = position
			@viewport.rect = @viewportRect
		else
			# Debug
			Kernel.fbEcholn("Called setPosition")
			@animations["transition"]["ppf"] = incrementPerFrame(pixelPosition(@position),pixelPosition(position),frames)
			@animations["transition"]["frameCounter"] = 0
			@animations["transition"]["frameNum"] = frames
			@animating = true
			@animations["transition"]["active"] = true
			@animations["transition"]["realPosition"] = @viewportRect.x
			@position = position
		end
	end
	
	def pixelPosition(position)
		position = position.to_sym if position.is_a?(String)
		case position
		when :left
			self.mirror = false
			ret = 0																		# Left align
		when :centre
			ret = (Graphics.width - MUGSHOTWIDTH) / 2	# Center align	
		when :right
			self.mirror = true
			ret = Graphics.width - MUGSHOTWIDTH				# Right align
		when :out_left
			ret = -MUGSHOTWIDTH												# Out on left side
		when :out_right
			ret = Graphics.width											# Out on right side
		else
			raise PositionNotValidError.new(position)
		end
		return ret
	end
	
	def incrementPerFrame(startPos,endPos,frames)
		space = endPos - startPos
		ipf = space.to_f/frames
		return ipf
	end
	
	def active=(active)
		@active = active
	end
	
	def setVisibility(visible,frames=0)
		if frames < 2
			self.visible = visible
		else
			visible ? newOpacity = 255 : newOpacity = 0
			@animations["fading"]["opf"] = incrementPerFrame(self.opacity,newOpacity,frames)
			@animating = true
			@animations["fading"]["active"] = true
			@animations["fading"]["realPosition"] = self.opacity
		end
	end
end

class PositionNotValidError < Exception
	def initialize(position)
		@pos = position
	end
	
	def to_s
		return "Position " + @pos.to_s + " not valid"
	end
end