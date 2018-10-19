// Arcadeflow - v 2.8
// Attract Mode Theme by zpaolo11x
//
// Based on carrier.nut scrolling module by Radek Dutkiewicz (oomek)
// Including code from the KeyboardSearch plugin by Andrew Mickelson (mickelson)


fe.load_module("file")

function file_exist(fullpathfilename){
	try {file(fullpathfilename, "r" );return true;}catch(e){return false;}
}

local orderx = 0
local preliner = "     ○  "
local prelinerh = " ●  "
local postliner = "                                                                                                  "

class UserConfig </ help="" />{
	</ label=prelinerh + "GENERAL" + postliner, help=" ", options = " ", order=orderx++ /> paramx1 = " "
		</ label=preliner + "Context menu button" + postliner, help="Chose the button to open the game context menu", options="custom1, custom2, custom3, custom4, custom5, custom6", order=orderx++ /> overmenubutton="custom1"
		</ label=preliner + "Rows in horizontal layout" + postliner, help = "Number of rows to use in 'horizontal' mode", options="2, 3", order = orderx++ /> horizontalrows = "2"
		</ label=preliner + "Rows in vertical layout" + postliner, help = "Number of rows to use in 'vertical' mode", options="2, 3", order = orderx++ /> verticalrows = "3"
		</ label=preliner + "Screen rotation" + postliner, help = "Rotate screen", options="None, Left, Right, Flip", order = orderx++ /> baserotation = "None"
		</ label=preliner + "Frosted glass" + postliner, help = "Enable a frosted glass effect for overlay menus", options="Yes, No", order = orderx++ /> frostedglass = "Yes"
		</ label=preliner + "Custom resolution WIDTHxHEIGHT" + postliner, help = "Define a custom resolution for your layout independent of screen resolution. Format is WIDTHxHEIGHT, leave blank for default resolution", order = orderx++ /> customsize = ""
		
	</ label=prelinerh + "THUMBNAILS" + postliner, help=" ", options =" ", order=orderx++ /> paramx2 = " "
		</ label=preliner+"Aspect ratio" + postliner, help="Chose wether you want cropped, square snaps or horizontal and vertical snaps depending on game orientation", options ="Horizontal-Vertical, Square", order = orderx++ /> cropsnaps = "Horizontal-Vertical"
		</ label=preliner+"Glow effect" + postliner, help="Add a glowing halo around the selected game thumbnail", options="Yes, No", order=orderx++ /> snapglow ="No"
		</ label=preliner+"Video thumbs" + postliner, help="Enable video overlay on snapshot thumbnails", options="Yes, No", order=orderx++ /> thumbvideo ="Yes"
		</ label=preliner+"Color gradient" + postliner, help="Fades the artwork behind the game logo to its average color", options="Yes, No", order=orderx++ /> snapgradient="Yes"
		</ label=preliner+"New game indicator" + postliner, help="Games not played are marked with a glyph", options="Yes, No", order=orderx++ /> newgame = "Yes"

	</ label=prelinerh + "BACKDROP" + postliner, help=" ", options =" ", order=orderx++ /> paramx3 = " "
		</ label=preliner+"Overlay color" + postliner, help="Setup theme luminosity overlay, Basic is slightly muted, Dark is darker, Light has a white overlay and dark text, Pop keeps the colors unaltered", options="Basic, Dark, Light, Pop", order=orderx++ /> colortheme="Basic"
		</ label=preliner+"Custom background image" + postliner, help="Insert custom background art path", order=orderx++ /> bgblurred=""
		</ label=preliner+"Background snap" + postliner, help="Add a faded game snapshot to the background", options="Yes, No", order=orderx++ /> layersnap ="No"
		</ label=preliner+"Animate background snap" + postliner, help="Animate video on background", options="Yes, No", order=orderx++ /> layervideo ="No"

	</ label=prelinerh + "LOGO" + postliner, help=" ", options =" ", order=orderx++ /> paramx4 = " "
		</ label=preliner+"Enable splash logo" + postliner, help="Enable or disable the AF start logo", options="Yes, No",order = orderx++/> splashlogo = "Yes"
		</ label=preliner+"Custom splash logo" + postliner, help="Insert the path to a custom AF splash logo (or keep blank for default logo)", order = orderx++/> splashlogofile = ""

	</ label=prelinerh + "SEARCH" + postliner, help=" ", options =" ", order=orderx++ /> paramx5 = " "
		</ label=preliner+"Search string entry method" + postliner, help="Use keyboard or on-screen keys to enter search string", options="Keyboard, Screen keys", order=orderx++ /> searchmeth = "Screen keys"
		</ label=preliner+"Immediate search" + postliner, help="Live update results while searching", options="Yes, No", order=orderx++ /> livesearch = "Yes"

	</ label=prelinerh + "HISTORY" + postliner, help=" ", options =" ", order=orderx++ /> paramx6 = " "
		</ label=preliner+"History.dat" + postliner, help="History.dat location.", order=orderx++ /> dat_path="$HOME/mame/dats/history.dat"
		</ label=preliner+"Index clones" + postliner, help="Set whether entries for clones should be included in the index. Enabling this will make the index significantly larger", order=orderx++, options="Yes, No" /> index_clones="Yes"
		</ label=preliner+"Generate index" + postliner, help="Generate the history.dat index now (this can take some time)", is_function=true, order=orderx++ />generate="generate_index"

	</ label=prelinerh + "AUDIO" + postliner, help=" ", options =" ", order=orderx++ /> paramx7 = " "
		</ label=preliner+"Audio in videos (thumbs)" + postliner, help="Select wether you want to play audio in videos on thumbs", options="Yes, No", order=orderx++ /> audiovidsnaps="No"
		</ label=preliner+"Audio in videos (history)" + postliner, help="Select wether you want to play audio in videos on history detail page", options="Yes, No", order=orderx++ /> audiovidhistory="No"
}

/// Layout start  

// for debug purposes
local DEBUG = false
local transdata = ["StartLayout", "EndLayout", "ToNewSelection","FromOldSelection","ToGame","FromGame","ToNewList","EndNavigation","ShowOverlay","HideOverlay","NewSelOverlay"]

local bgvidsurf = null

local stacksize = 3
local varray = []
local bgpicarray = []
local bgvidarray = []
local alphapos = []


local my_dir = fe.script_dir
dofile( my_dir + "file_util.nut" )

local my_config = fe.get_config()

local prf = {
	CROPSNAPS = ( (my_config["cropsnaps"] == "Square") ? true : false),
	COLORTHEME = my_config["colortheme"],
	SNAPGRADIENT = ( (my_config["snapgradient"] == "Yes") ? true : false),
	NEWGAME = ( (my_config["newgame"] == "Yes") ? true : false),
	BGBLURRED = my_config["bgblurred"],
	KEYBOARD = ( (my_config["searchmeth"] == "Keyboard") ? true : false),
	LIVESEARCH = ( (my_config["livesearch"] == "Yes") ? true : false ),
	SPLASHON = ( (my_config["splashlogo"] == "Yes") ? true : false ),
	SPLASHLOGOFILE = ( my_config["splashlogofile"] == "" ? "AFLOGO.png" : my_config["splashlogofile"]),
	VERTICALROWS = ( (my_config["verticalrows"] == "2") ? 2 : 3 ),
	HORIZONTALROWS = ( (my_config["horizontalrows"] == "2") ? 2 : 3 ),
	OVERMENUBUTTON = my_config["overmenubutton"],
	AUDIOVIDSNAPS = ( (my_config["audiovidsnaps"] == "Yes") ? true : false),
	AUDIOVIDHISTORY = ( (my_config["audiovidhistory"] == "Yes") ? true : false),
	LAYERVIDEO = ( (my_config["layervideo"] == "Yes") ? true : false),
	THUMBVIDEO = ( (my_config["thumbvideo"] == "Yes") ? true : false),
	LAYERSNAP = ( (my_config["layersnap"] == "Yes") ? true : false),
	SNAPGLOW = ( (my_config["snapglow"] == "Yes") ? true : false),
	BASEROTATION = my_config["baserotation"],
	FROSTEDGLASS = ( (my_config["frostedglass"] == "Yes") ? true : false),
	CUSTOMSIZE = my_config["customsize"]
}



if (prf.BASEROTATION == "None")
		fe.layout.base_rotation = RotateScreen.None
else if (prf.BASEROTATION == "Left")
		fe.layout.base_rotation = RotateScreen.Left
else if (prf.BASEROTATION == "Right")
		fe.layout.base_rotation = RotateScreen.Right
else if (prf.BASEROTATION == "Flip")
		fe.layout.base_rotation = RotateScreen.Flip


// cleanup grabbed files
local dir0 = DirectoryListing( FeConfigDirectory )
local fpos01 = null
local fpos02 = null

foreach ( f in dir0.results )
{
	fpos01 = f.find(".png")
	fpos02 = f.find("grab")
	if ((fpos01 != null) && (fpos02 != null)){
		remove(f)
	}
}

// Initialize variables
local var = 0
local overmenuflow = 0
local historyflow = 0

local noshader = fe.add_shader( Shader.Empty )

local titleswitch = -1
local titlezero = 0
local titlezero2 = 0
local titlecrossfade = 0
local titlestart = true
local titleroll = false
local titlescroll = false
local scrollincrement = 0

local scrollwait = 2000
local scrollmove = 1000
local titlewait = scrollwait*2+scrollmove*2

local frost_surface = null
local frost_pic = null

// Search parameters
local search_base_rule = "Title"
local backindex = -1
local backcorrector = -1

local tagsmenu = false

local	colstop = 0
local	colstart = 0
local columnoffset = 0

local squarizer = true

// Apply color theme
local themeoverlaycolor = 255
local themeoverlayalpha = 80
local themetextcolor = 255
local themeshadow = 50
local shadeval = 255
local satinrate = 0.9

local vidsatin = 50

if (prf.COLORTHEME == "Basic"){
	themeoverlaycolor = 255
	themeoverlayalpha = 80
	themetextcolor = 255
	themeshadow = 50
}
if (prf.COLORTHEME == "Dark"){
	themeoverlaycolor = 0
	themeoverlayalpha = 110*0 + 140
	themetextcolor = 230
	themeshadow = 50
}
if (prf.COLORTHEME == "Light"){
	themeoverlaycolor = 255
	themeoverlayalpha = 190
	themetextcolor = 100
	themeshadow = 0
}
if (prf.COLORTHEME == "Pop"){
	themeoverlaycolor = 255
	themeoverlayalpha = 0
	themetextcolor = 255
	themeshadow = 50
}

function round(x, y) {
	return (x.tofloat()/y+(x>0?0.5:-0.5)).tointeger()*y
}

// UI sounds
local ticksound = fe.add_sound("mouse3.mp3")
local wooshsound = fe.add_sound("woosh4.mp3")

// parameters for slowing down key repeat on left-right scrolling
local rightcount = 0
local leftcount = 0
local movecount = 3

local globalposnew = 0
local	surfacePos = 0

// layout preferences
local rows = prf.HORIZONTALROWS
local vertical = false
local logoshow = 1

// font definition
local guifont ="Roboto-Allcaps.ttf"
local generalfont = "Roboto-Bold.ttf"

//screen layout definition

local scrw = ScreenWidth
local scrh = ScreenHeight

if (prf.CUSTOMSIZE != ""){
	try {
		scrw = split(prf.CUSTOMSIZE,"xX")[0]
		scrh = split(prf.CUSTOMSIZE,"xX")[1]
		scrw = scrw.tointeger()
		scrh = scrh.tointeger()
		//print ("\n\n\n"+xxx + " x " + yyy + "\n\n\n")
	}
	catch ( err ) { fe.overlay.splash_message("Wrong syntax in screen resolution");prf.CUSTOMSIZE = "";scrw = ScreenWidth; scrh = ScreenHeight }
}

local flw = scrw
local flh = scrh

local realrotation = ( fe.layout.base_rotation + fe.layout.toggle_rotation ) % 4
local rotate90 = ((realrotation % 2) != 0)

if (rotate90){
	flw = scrh
	flh = scrw
}

if (flh>flw) vertical = true

if (vertical) rows = prf.VERTICALROWS

fe.layout.width = flw
fe.layout.height = flh
fe.layout.preserve_aspect_ratio = true
fe.layout.page_size = rows
fe.layout.font = generalfont

local scalerate = (vertical ? flw : flh)/1200.0
local	tilesTotal = 0

local header_h = 200*scalerate
local footer_h = 100*scalerate

// multiplier of padding space (normally 1/6 of thumb area)
local padding_scaler = (prf.CROPSNAPS ? 100/440.0 : 1/6.0)

local height = (flh - header_h - footer_h)/(rows + rows*padding_scaler + padding_scaler)
local width = height

local padding = height * padding_scaler
local widthpadded = width + 2*padding
local heightpadded = height + 2*padding

local verticalshift = (prf.CROPSNAPS ? 0 : height*16.0/480.0)

//calculate number of columns
local cols = (1 + 2*(floor (( flw/2 + width/2 - padding) / (height + padding))))
// add safeguard tiles
cols += 2

// carrier sizing in general layout
local carrierT = {
	x = -(cols*(height + padding) + padding - flw) * 0.5,
	y = header_h,
	w = cols*(height + padding) + padding,
	h = rows*height + rows*padding + padding
}

// selector and zooming data
local selectorscale = 1.5
local whitemargin = (prf.CROPSNAPS ? 0.12 : 0.15) 
local selectorwidth = selectorscale * widthpadded
local selectoroffseth = (selectorwidth - widthpadded)*0.5
local selectoroffsetv = (selectorwidth - widthpadded - verticalshift)*0.5

local deltacol = (cols -3)/2
local centercorrection0 = -deltacol*(width + padding) -(flw - (carrierT.w - 2*(width + padding))) / 2 - padding*(1 + selectorscale*0.5) - width/2 + selectorwidth/2
local centercorrection = 0
local centercorrectionshift = centercorrection0

local zorderscanner = 0
local zordertop = 0

// transitions speeds
local scrollspeed = 0.92
local zoomspeed = 0.87
local fadespeed = 0.88
local letterspeed = 0.85

// Video delay parameters to skip fade-in
local delayvid = 0.4
local fadevid = 0.2

// Fading letter and scroller sizes
local lettersize = 250 * scalerate
local footermargin = 200 * scalerate
local scrollersize = 30 * scalerate

// Blurred backdrop definition
local bgT = {
	x = 0
	y = (flh - flw) / 2.0
	w = flw
}

// Picture background definition
local bgpicT = {
	x = 0,
	y = 0,
	w = flw,
	h = flh,
	ar = 1
}

if (vertical){
	bgT.x = (flw - flh) / 2
	bgT.y = 0
	bgT.w = flh
}

// parameters for changing scroll jump spacing
local scrolljump = false
local scrollstep = rows

// keys definition for on screen keyboard 
local key_names = { "a": "a", "b": "b", "c": "c", "d": "d", "e": "e", "f": "f", "g": "g", "h": "h", "i": "i", "j": "j", "k": "k", "l": "l", "m": "m", "n": "n", "o": "o", "p": "p", "q": "q", "r": "r", "s": "s", "t": "t", "u": "u", "v": "v", "w": "w", "x": "x", "y": "y", "z": "z", "1": "Num1", "2": "Num2", "3": "Num3", "4": "Num4", "5": "Num5", "6": "Num6", "7": "Num7", "8": "Num8", "9": "Num9", "0": "Num0", "<": "Backspace", " ": "Space", "-": "Clear", "~": "Done","_":"Nope" }
local key_rows = ["abcdefghi123", "jklmnopqr456", "stuvwxyz_789", "- <0","~"]
if (vertical) key_rows = ["1234567890","abcdefghij","klmnopqrst","uvwxyz____","- <","~"]
local key_selected = [0,0]
local s_text = ""

// used in shaders
//local picalpha = fe.add_image("alpha.png",0,0,1,2)

// Frosted glass variables
local grabdither = 0
local grabticker = 0
local oldgrabnum = 0
local grabpath = ""
local grabpath0 = ""
local grabsignal = ""
local immediatesignal = false
local numgrabs = 0
local createdgrabs = []

/// Carrier Class Definition  
class Carrier {
	
	tilesTable = []
	snapzTable = []
	logozTable = []
	loshzTable = []
	favezTable = []
	donezTable = []
	nw_hzTable = []
	nw_vzTable = []
	sh_hzTable = []
	sh_vzTable = []
	bd_hzTable = []
	bd_vzTable = []
	vidszTable = []
	glohzTable = []
	glovzTable = []

	tilesTablePosX = []
	tilesTablePosY = []
	tilesTableOffset = 0
	surfacePosOffset = 0

	selector = null
	tilesOffscreen = 0
	corrector = 0	

	newfocusindex = 0
	oldfocusindex = 0
	scroller = null
	scroller2 = null
	scrollineglow = null
	searchdata = null
	
	tilesCount = 0
	changedfav = false

	alphapos = 0
	zoompos = 0
	zoomunpos = 0
	vidpos = 0
	fadeletter = 0
	sh_h = null
	sh_v = null
	nw_h = null
	nw_v = null
	letterobj = null
	searchtext = ""
		
	/// Carrier constructor  
	constructor() {
		
		tilesCount = cols * rows
		tilesOffscreen = (vertical ? 3 * rows : 4 * rows)
		
		tilesTotal = tilesCount + 2*tilesOffscreen
		surfacePosOffset = (tilesOffscreen/rows) * (width+padding)

		zorderscanner = 0

		// fading letter
		letterobj = fe.add_text("[!gameletter]",0,carrierT.y+carrierT.h*0.5-lettersize*0.5,flw,lettersize)
		letterobj.alpha = 0
		letterobj.charsize = lettersize
		letterobj.font = guifont
		letterobj.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		// scroller definition
		local scrolline = fe.add_image ("white.png",footermargin,flh-footer_h*0.5 - 1,flw-2*footermargin,2)
		scrolline.alpha = 200
		scrolline.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		scrollineglow = fe.add_image ("whitedisc2.png",footermargin, flh-footer_h*0.5 - 5,flw-2*footermargin, 10)
		scrollineglow.visible = false
		scrollineglow.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		scroller = fe.add_image ("whitedisc.png",footermargin - scrollersize*0.5,flh-footer_h*0.5-scrollersize*0.5,scrollersize,scrollersize)
		scroller.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		scroller2 = fe.add_image ("whitedisc2.png",scroller.x - scrollersize*0.5, scroller.y-scrollersize*0.5,scrollersize*2,scrollersize*2)
		scroller2.visible = false
		scroller2.alpha = 200
		scroller2.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		searchdata = fe.add_text (fe.list.search_rule,0,flh-footer_h*0.5,flw,footer_h*0.5)
		searchdata.align = Align.Centre
		searchdata.set_rgb( 255, 255, 255)
		searchdata.word_wrap = true
		searchdata.charsize = 25*scalerate
		searchdata.visible = true
		searchdata.font = guifont
		searchdata.set_rgb(themetextcolor,themetextcolor,themetextcolor)

		/// Tile creation loop  
		for ( local i = 0; i < tilesTotal; i++ ) {
			local loshz = null
			local logoz = null
			local logosurf1 = null
			local logosurf2 = null

			local logo_w = 240.0
			local logo_h = (prf.CROPSNAPS ? 105.0 : 120.0)
			local logomargin = 20.0
			local logosh_w = logo_w+2*logomargin
			local logosh_h = logo_h+2*logomargin

			local logoshscale = 0.5

			logosurf2 = fe.add_surface (logosh_w*logoshscale,logosh_h*logoshscale)
		
			loshz = logosurf2.add_artwork ("wheel",logomargin*logoshscale,logomargin*logoshscale,logo_w*logoshscale,logo_h*logoshscale)

			logosurf1 = fe.add_surface (logosh_w*logoshscale,logosh_h*logoshscale)
			

			local shaderV = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
			shaderV.set_texture_param( "texture")
			shaderV.set_param("kernelData", 7.0 , 2.5)
			shaderV.set_param("offsetFactor", 0.0000, 1.0/(logosh_h*logoshscale))
			logosurf2.shader = shaderV

			local shaderH = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
			shaderH.set_texture_param( "texture")
			shaderH.set_param("kernelData", 7.0 , 2.5)
			shaderH.set_param("offsetFactor", 1.0/(logosh_w*logoshscale), 0.0)
			logosurf1.shader = shaderH


			if (!prf.CROPSNAPS)
			logosurf1.set_pos (selectorscale*padding*0.5,selectorscale*(padding*0.4*0.5-verticalshift),selectorscale*(width+padding),selectorscale*(height*0.5+padding))
			else
			logosurf1.set_pos (selectorscale*padding,selectorscale*padding,selectorscale*width,selectorscale*width*logosh_h/logosh_w)

			local obj = fe.add_surface(widthpadded*selectorscale,heightpadded*selectorscale)
			
			if(i == 0) 
				zorderscanner = obj.zorder
			else
				obj.zorder = zorderscanner

			local sh_hz = obj.add_image ("sh_h_7.png",0,0,widthpadded*selectorscale,heightpadded*selectorscale)
			local sh_vz = obj.add_image ("sh_v_7.png",0,0,widthpadded*selectorscale,heightpadded*selectorscale)
			sh_hz.alpha = sh_vz.alpha = 230
			
			if (prf.CROPSNAPS) sh_hz.file_name = sh_vz.file_name = "sh_sq_7.png"

			local glohz =	obj.add_image ("glowx4.png",0,-selectorscale*verticalshift,widthpadded*selectorscale,selectorscale*heightpadded)
			local glovz =	obj.add_image ("glowx4.png",0,-selectorscale*verticalshift,widthpadded*selectorscale,selectorscale*heightpadded)
			
			if (prf.CROPSNAPS) glohz.file_name = glovz.file_name = "glow_sq.png"

			local bd_hz = obj.add_text ("",selectorscale*padding*(1.0-whitemargin),selectorscale*(-verticalshift + height/8.0 + padding*(1.0 - whitemargin)),selectorscale*(width + padding*2.0*whitemargin),selectorscale*(height*(3/4.0)+padding*2.0*whitemargin))
			bd_hz.set_bg_rgb (255,255,255)
			bd_hz.bg_alpha = 240
			bd_hz.visible = false

			local bd_vz = obj.add_text ("",selectorscale*(width/8.0 + padding*(1.0 - whitemargin)), selectorscale*(-verticalshift + padding*(1.0 - whitemargin)),selectorscale*(width*(3/4.0)+padding*2.0*whitemargin),selectorscale*(height + padding*2.0*whitemargin))
			bd_vz.set_bg_rgb (255,255,255)
			bd_vz.bg_alpha = 240
			bd_vz.visible = false

			if (prf.CROPSNAPS) {
				bd_hz.set_pos (selectorscale*padding*(1.0-whitemargin),selectorscale*(-verticalshift + padding*(1.0 - whitemargin)),selectorscale*(width + padding*2.0*whitemargin),selectorscale*(height + padding*2.0*whitemargin))
				bd_vz.set_pos (selectorscale*padding*(1.0-whitemargin),selectorscale*(-verticalshift + padding*(1.0 - whitemargin)),selectorscale*(width + padding*2.0*whitemargin),selectorscale*(height + padding*2.0*whitemargin))
			}
			else{
				bd_hz.set_pos (selectorscale*padding*(1.0-whitemargin),selectorscale*(-verticalshift + height/8.0 + padding*(1.0 - whitemargin)),selectorscale*(width + padding*2.0*whitemargin),selectorscale*(height*(3.0/4.0)+padding*2.0*whitemargin))
				bd_vz.set_pos (selectorscale*(width/8.0 + padding*(1.0 - whitemargin)), selectorscale*(-verticalshift + padding*(1.0 - whitemargin)),selectorscale*(width*(3.0/4.0)+padding*2.0*whitemargin),selectorscale*(height + padding*2.0*whitemargin))
			}


			local snapz = obj.add_artwork("snap",selectorscale*padding,selectorscale*(padding-verticalshift),selectorscale*width,selectorscale*height)
			
			snapz.preserve_aspect_ratio = false
			snapz.video_flags = Vid.ImagesOnly
			snapz.set_pos (selectorscale*padding,selectorscale*(padding-verticalshift),selectorscale*width,selectorscale*height)

			local snap_avg = null

			if (prf.SNAPGRADIENT){
				snap_avg = fe.add_shader( Shader.Fragment, "powersampler.glsl" )
				snap_avg.set_texture_param( "texture",snapz)
				snap_avg.set_param ("level",2.0)
				if (prf.CROPSNAPS) 
					snap_avg.set_param ("limits",0.2,0.7)
				else
					snap_avg.set_param ("limits",0.15,0.65)
				snapz.shader = snap_avg
			}
		
			local snap_glow_h = null
			local snap_glow_v = null

			if (prf.SNAPGLOW){
				snap_glow_h = fe.add_shader( Shader.Fragment, "powerglow.glsl" )
				snap_glow_h.set_texture_param( "texture",snapz)
				snap_glow_h.set_texture_param( "textureglow",glohz)
				snap_glow_h.set_param ("level",2.0)
				snap_glow_h.set_param ("vertical",0.0)
				glohz.shader = snap_glow_h

				snap_glow_v = fe.add_shader( Shader.Fragment, "powerglow.glsl" )
				snap_glow_v.set_texture_param( "texture",snapz)
				snap_glow_v.set_texture_param( "textureglow",glovz)
				snap_glow_v.set_param ("level",2.0)
				snap_glow_v.set_param ("vertical",1.0)
				glovz.shader = snap_glow_v
			}

			glohz.visible = false
			glovz.visible = false

			local vidsz = obj.add_image("transparent.png",selectorscale*padding,selectorscale*(padding-verticalshift),selectorscale*width,selectorscale*height)

			vidsz.preserve_aspect_ratio = true
			//vidsz.visible = false
			if (!prf.AUDIOVIDSNAPS) vidsz.video_flags = Vid.NoAudio

			local nw_hz = obj.add_image ("nw_1.png",selectorscale*padding,selectorscale*(padding-verticalshift+height*6.0/8.0),width*selectorscale/8.0,height*selectorscale/8.0)
			local nw_vz = obj.add_image ("nw_1.png",selectorscale*(padding+width/8.0),selectorscale*(padding-verticalshift+height*7.0/8.0),width*selectorscale/8.0,height*selectorscale/8.0)
			nw_hz.visible = nw_vz.visible = false
			nw_hz.alpha = nw_vz.alpha = ((prf.NEWGAME == true)? 220 : 0)

			if (prf.CROPSNAPS) {
				nw_hz.set_pos(selectorscale*padding,selectorscale*(padding-verticalshift+height*7.0/8.0),width*selectorscale/8.0,height*selectorscale/8.0)
				nw_vz.set_pos(selectorscale*padding,selectorscale*(padding-verticalshift+height*7.0/8.0),width*selectorscale/8.0,height*selectorscale/8.0)
			}

			local donez = obj.add_image("completed.png",selectorscale*padding,selectorscale*(padding-verticalshift),selectorscale*width*0.8,selectorscale*height*0.8)
			donez.visible = false
			donez.preserve_aspect_ratio = false

			local favez = obj.add_image("starred.png",selectorscale*(padding+width/2),selectorscale*(padding+height/2-verticalshift),selectorscale*width/2,selectorscale*height/2)
			favez.visible = false
			favez.preserve_aspect_ratio = false

			logosurf2.visible = false
			logosurf2 = logosurf1.add_clone (logosurf2)
			logosurf2.visible = true

			logosurf1.visible = false
			logosurf1 = obj.add_clone (logosurf1)
			logosurf1.visible = true

			logoz = obj.add_clone (loshz)
			logoz.preserve_aspect_ratio = true

			if (!prf.CROPSNAPS){
				logoz.set_pos (selectorscale*padding,selectorscale*(padding*0.6-verticalshift),selectorscale*width,selectorscale*height*0.5)
			}
			else {
				logoz.set_pos (selectorscale*(padding+width*logomargin/logosh_w),selectorscale*(padding+width*(15/20.0)*logomargin/logosh_w),selectorscale*width*logo_w/logosh_w,selectorscale*height*logo_h/logosh_w)
			}
			
			loshz.alpha = 150
			loshz.preserve_aspect_ratio = true
			loshz.set_rgb(0,0,0)

			tilesTablePosX.push((width+padding) * (i/rows) + padding)
			tilesTablePosY.push((width+padding) * (i%rows) + padding + carrierT.y + verticalshift)
			
			obj.preserve_aspect_ratio = false
			
			tilesTable.push (obj)
			snapzTable.push (snapz)
			logozTable.push (logoz)
			loshzTable.push (loshz)
			favezTable.push (favez)
			donezTable.push (donez)
			bd_hzTable.push (bd_hz)
			bd_vzTable.push (bd_vz)
			sh_hzTable.push (sh_hz)
			sh_vzTable.push (sh_vz)
			nw_hzTable.push (nw_hz)
			nw_vzTable.push (nw_vz)
			vidszTable.push (vidsz)
			glohzTable.push (glohz)
			glovzTable.push (glovz)
		}
		
		
		zordertop = zorderscanner + tilesTotal + 2

		//letterobj.zorder = scrolline.zorder = scrollineglow.zorder = scroller.zorder = scroller2.zorder = searchdata.zorder = zordertop

		// define initial carrier "surface" position
		surfacePos = 0.5

		::fe.add_signal_handler( this, "on_signal" )
		::fe.add_transition_callback( this, "on_transition" )
		::fe.add_ticks_callback( this, "tick" )
	}
	
	
	
	/// On Transition  
	function on_transition( ttype, var0, ttime ) {
		
		//DEBUG print transition
		if (DEBUG) print ("Tr:" + transdata[ttype] +" var:" + var0 + "\n")

		//var = 0

		// cleanup frosted glass grabs
		if ((ttype == Transition.EndLayout) && (var0 == FromTo.Frontend)){
			for (local ig = 0; ig < numgrabs ; ig++){
				remove(createdgrabs[ig])
			}
		}

		if (ttype == Transition.ShowOverlay){
			if (var0 == Overlay.Tags) tagsmenu = true
			overlay_show() 
		}

		if (ttype == Transition.HideOverlay){
			overlay_hide() 
			if (tagsmenu) {
				tagsmenu = false
				zoompos = 1
			}
		}

		// var is updated only if we are going to a new selection
		if (ttype == Transition.ToNewSelection) var = var0
		
		// scroller is always updated		
		//	scroller.x = footermargin + (((fe.list.index + var)*1.0/rows)/((fe.list.size*1.0)/rows - 1))*(flw - 2.0*footermargin-scrollersize)
		
		scroller.x = footermargin + ((fe.list.index/rows)*rows*1.0/(fe.list.size - 1 ))*(flw - 2.0*footermargin-scrollersize)

		scroller2.x = scroller.x-scrollersize*0.5
		//		titlescroll = 2
		//		scrollincrement = 0

		// since the EndNavigation transition is fired many times I don't want the zoom/unzoom to take place in that case
		if ((ttype != Transition.FromOldSelection) && (ttype != Transition.EndNavigation) && (ttype != Transition.HideOverlay) && (ttype != Transition.ShowOverlay) && (ttype != Transition.NewSelOverlay) ) {
			if (DEBUG) print ("TRANSBLOCK 1 \n")
			zoompos = 1

			// If we are not transitioning to a new list, starting the layout or hiding the overlay old tile is faded out
			if ((ttype!=Transition.ToNewList) && (ttype!=Transition.StartLayout) && (ttype!=Transition.HideOverlay)) {
				if (DEBUG) print ("TRANSBLOCK 1.5 \n")
				tilesTable[oldfocusindex].width = widthpadded
				tilesTable[oldfocusindex].height = heightpadded
				tilesTable[oldfocusindex].zorder = zorderscanner
				glovzTable[oldfocusindex].visible = glohzTable[oldfocusindex].visible = bd_hzTable[oldfocusindex].visible = bd_vzTable[oldfocusindex].visible = false
				//vidszTable[oldfocusindex].visible = false
				//vidszTable[oldfocusindex].file_name = "transparent.png"
				
				zoomunpos = 1
			}
		}

		// cases when the tiles will be updated
		if ( ( ttype == Transition.ToNewList ) || ( ttype == Transition.ToNewSelection ) || (ttype == Transition.StartLayout)) {
			
			titlezero = fe.layout.time
			titleswitch = 0
			titlestart = true
			titlezero2 = titlezero

			if (DEBUG) print ("TRANSBLOCK 2 \n")
			//zoompos = 1
			vidpos = 1
						
			if (ttype == Transition.ToNewList) {
				var = 0
				tilesTableOffset = 0
				surfacePos = 0.5
				columnoffset = 0
				centercorrection = 0
				centercorrectionshift = centercorrection0
			}


			if (DEBUG) print ("flindex " + fe.list.index + "\n")

			corrector = -((fe.list.index + var) % rows)

			colstop = floor((fe.list.index + var)/rows)
			colstart = floor((fe.list.index)/rows)

			local index = - (floor(tilesTotal/2) -1) + corrector 
			//if (ttype == Transition.ToNewList) index = - (floor(tilesTotal/2) -1) - floor(fe.list.index % rows)
		
			columnoffset = (colstop - colstart)
			tilesTableOffset += columnoffset*rows

			// Determine center position correction when reaching beginning or end of list
			if ((colstop < deltacol) && (var < 0) ) {
				if (colstop == deltacol - 1 ) 
					centercorrectionshift = centercorrection0 + (deltacol - 1)*(width+padding)
				else 
					centercorrectionshift = - (width+padding)
			}
			else if ((colstart < deltacol) && (var > 0)) {
				if (colstart == deltacol - 1 ) 
					centercorrectionshift = -centercorrection0 - (deltacol - 1)* (width+padding)
				else 
					centercorrectionshift = (width+padding)
			}
			else {
				centercorrectionshift = 0	
			}
			
			if (fe.list.index + var > deltacol*rows -1){
				centercorrection = 0
			}
			else {
				centercorrection = centercorrection0 + ((fe.list.index + var)/rows)*(width+padding)
			}
			
			if (columnoffset == 0) centercorrectionshift = 0
			
			
			// updates all the tiles, (NOT unless we are changing favourites)
			//if (changedfav == false){
			if (DEBUG) print ("TRANSBLOCK 3 \n")	

			for ( local i = 0; i < tilesTotal ; i++ ) {
											
				local indexTemp = wrap( i + tilesTableOffset, tilesTotal )

				if ((ttype == Transition.ToNewList) || (ttype == Transition.StartLayout)){
					snapzTable[indexTemp].index_offset = index
					loshzTable[indexTemp].index_offset = index
				}
				else{
					snapzTable[indexTemp].rawset_index_offset(index )
					loshzTable[indexTemp].rawset_index_offset(index )
				}

				if (prf.CROPSNAPS){
					if (snapzTable[indexTemp].texture_width >= snapzTable[indexTemp].texture_height){
						snapzTable[indexTemp].subimg_x = snapzTable[indexTemp].texture_width/8.0
						snapzTable[indexTemp].subimg_width = snapzTable[indexTemp].texture_width*3.0/4.0
					}
					else{
						snapzTable[indexTemp].subimg_y = snapzTable[indexTemp].texture_height/8.0
						snapzTable[indexTemp].subimg_height = snapzTable[indexTemp].texture_height*3.0/4.0
					}
				}
				else{
					if (snapzTable[indexTemp].texture_width >= snapzTable[indexTemp].texture_height){
						snapzTable[indexTemp].set_pos (selectorscale*padding,selectorscale*(padding-verticalshift + height/8.0 ),selectorscale*width,selectorscale*height*3.0/4.0)
					}
					else{
						snapzTable[indexTemp].set_pos (selectorscale*(padding+width/8.0),selectorscale*(padding-verticalshift),selectorscale*width*3.0/4.0,selectorscale*height)
					}
				}

				tilesTable[indexTemp].zorder = zorderscanner

				favezTable[indexTemp].visible = (fe.game_info(Info.Favourite, snapzTable[indexTemp].index_offset + var) == "1")

				donezTable[indexTemp].visible = ((fe.game_info(Info.Tags, snapzTable[indexTemp].index_offset + var)).find("Completed") != null)
				
				//local m = fe.game_info(Info.Rotation, snapzTable[indexTemp].index_offset+var)
				local m = fe.game_info(Info.Rotation, snapzTable[indexTemp].index_offset+var)
				if ((m == "0") || (m == "180") || (m == "horizontal") || (m == "Horizontal")){
					sh_hzTable[indexTemp].visible = true
					sh_vzTable[indexTemp].visible = false
					
					nw_hzTable[indexTemp].visible = (fe.game_info(Info.PlayedCount, snapzTable[indexTemp].index_offset+var) == "0") 
					nw_vzTable[indexTemp].visible = false					
					
				}
				else {
					sh_hzTable[indexTemp].visible = false
					sh_vzTable[indexTemp].visible = true

					nw_hzTable[indexTemp].visible = false
					nw_vzTable[indexTemp].visible = (fe.game_info(Info.PlayedCount, snapzTable[indexTemp].index_offset+var) == "0") 

				}
				
				tilesTablePosX[indexTemp] = (i/rows) * (width+padding) + carrierT.x + centercorrection
				tilesTablePosY[indexTemp] = (i%rows) * (height + padding) + carrierT.y + verticalshift

				
				tilesTable[indexTemp].visible = (( (fe.list.index + var + index < 0) || (fe.list.index + var + index > fe.list.size-1) ) == false)
				
				// if tranisioning to a new list, reset position and size of all thumbnails, not needed in normal scroll
				if (ttype == Transition.ToNewList){
					//vidszTable[indexTemp].visible = false
					if (prf.THUMBVIDEO) vidszTable[indexTemp].file_name = "transparent.png"
					tilesTable[indexTemp].width = widthpadded
					tilesTable[indexTemp].height = heightpadded
					tilesTable[indexTemp].zorder = zorderscanner
					glovzTable[indexTemp].visible = glohzTable[indexTemp].visible = bd_hzTable[indexTemp].visible = bd_vzTable[indexTemp].visible = false
				}
				
				index++
			}
			//} CHANGEDFAV
			//else {
			//	changedfav = false
			//}
			
			// updates the size and features of the previously selected item and new selected item
			newfocusindex = wrap( floor(tilesTotal/2)-1-corrector + tilesTableOffset, tilesTotal )
			oldfocusindex = wrap( floor(tilesTotal/2)-1-corrector -var + tilesTableOffset, tilesTotal )
			
			tilesTable[oldfocusindex].width = widthpadded
			tilesTable[oldfocusindex].height = heightpadded
			tilesTable[oldfocusindex].zorder = zorderscanner
			bd_hzTable[oldfocusindex].visible = bd_vzTable[oldfocusindex].visible = false

			tilesTable[newfocusindex].zorder = zorderscanner + tilesTotal
			letterobj.zorder = zorderscanner + tilesTotal + 1

			//vidszTable[oldfocusindex].visible = false
			if (prf.THUMBVIDEO) vidszTable[oldfocusindex].file_name = "transparent.png"
			

			favezTable[newfocusindex].visible = (fe.game_info(Info.Favourite, snapzTable[newfocusindex].index_offset+var) == "1")		
			donezTable[newfocusindex].visible = ((fe.game_info(Info.Tags, snapzTable[newfocusindex].index_offset+var)).find("Completed") != null)
			
			//local m = fe.game_info(Info.Rotation, snapzTable[newfocusindex].index_offset+var)
			local m = fe.game_info(Info.Rotation, snapzTable[newfocusindex].index_offset+var)
			
			if ((m == "0") || (m == "180") || (m == "horizontal") || (m == "Horizontal")){
				glohzTable[newfocusindex].visible = prf.SNAPGLOW
				bd_hzTable[newfocusindex].visible = true
				glovzTable[newfocusindex].visible = bd_vzTable[newfocusindex].visible = false
				nw_hzTable[newfocusindex].visible = (fe.game_info(Info.PlayedCount, snapzTable[newfocusindex].index_offset+var) == "0")
				nw_vzTable[newfocusindex].visible = false

			}
			else {
				glohzTable[newfocusindex].visible = bd_hzTable[newfocusindex].visible = false
				glovzTable[newfocusindex].visible = prf.SNAPGLOW
				bd_vzTable[newfocusindex].visible = true
				nw_hzTable[newfocusindex].visible = false
				nw_vzTable[newfocusindex].visible = (fe.game_info(Info.PlayedCount, snapzTable[newfocusindex].index_offset+var) == "0")

			}

		}
		

		
		// if the transition is to a new selection initialize zooming, scrolling and surfacepos
		if( (ttype == Transition.ToNewSelection) )
		{
			
			if (DEBUG) print ("TRANSBLOCK 5 \n")
			//snapbg1.rawset_index_offset (-var)
			//if (prf.LAYERSNAP) bgvid1.rawset_index_offset (-var)

			local l1 = gameletter (0)
			local l2 = gameletter(var)
			
			if (l1 != l2){
				fadeletter = 1
			}
			
			for (local i = 0; i < stacksize - 2;i++){
				varray[i] = - var + varray[i+1]
			}
			varray [stacksize - 1] = 0
			varray [stacksize - 2] = - var

			for (local i = 0; i < stacksize-1;i++){
				bgpicarray[i].rawset_index_offset(varray[i])
				alphapos[i] = alphapos[i+1]
			}

			alphapos [stacksize - 1]= 255
			
			surfacePos += (columnoffset * (width + padding) ) - centercorrectionshift
			
		}

		if ((ttype == Transition.ToNewSelection) || (ttype == Transition.ToNewList)){
			squarizer = true
		}

		return false
	}
	
	/// On Tick  
	function tick( tick_time ) {


		if (squarizer){
			squarizer = false
			squarebg()
		}

		if ((rightcount != 0) && (fe.get_input_state("right")==false)){
			rightcount = 0
		}
		
		if ((leftcount != 0) && (fe.get_input_state("left")==false)){
			leftcount = 0
		}
		
		// crossfade of the blurred background
		for (local i = 0 ; i < stacksize ; i++){
	
			if (alphapos[i] !=0){
				if (alphapos[i] < 1 && alphapos[i] > -1 ) alphapos[i] = 0
				alphapos[i] = alphapos[i] * fadespeed
				bgpicarray[i].alpha = 255-alphapos[i]
				if (prf.LAYERSNAP) bgvidarray[i].alpha = 255-alphapos[i] 
			}
		}

		// fading of the initial letter of the name
		if (fadeletter != 0){
			if(fadeletter < 0.01) fadeletter = 0
			fadeletter = fadeletter * letterspeed
			letterobj.alpha = 255*(1-4.0*pow((0.5-fadeletter),2))
		}
		
		
		// contemporary scrolling of tiles and zooming of selected tile
		if ((surfacePos != 0)||(zoompos !=0)||(zoomunpos!=0)) {
			if (zoompos == 1){
				newfocusindex = wrap( floor(tilesTotal/2)-1 - corrector + tilesTableOffset, tilesTotal )
				oldfocusindex = wrap( floor(tilesTotal/2)-1 - corrector - var + tilesTableOffset, tilesTotal )

				// Useful check to update "Completed" tag when changing tags
				local m = fe.game_info(Info.Tags, snapzTable[newfocusindex].index_offset)
				if (m.find("Completed") != null)
				donezTable[newfocusindex].visible = true
				else
				donezTable[newfocusindex].visible = false
				
			}
			if ((surfacePos < 0.1) && (surfacePos > -0.1)) surfacePos = 0
			if ((zoompos < 0.01) && (zoompos > -0.01 )) zoompos = 0
			if ((zoomunpos < 0.01) && (zoomunpos > -0.01 )) {
				zoomunpos = 0
				if (oldfocusindex != newfocusindex){
					glohzTable[oldfocusindex].visible = glovzTable[oldfocusindex].visible = false
				}
			}
			
			surfacePos = surfacePos * scrollspeed
			zoompos = zoompos * zoomspeed
			zoomunpos = zoomunpos * zoomspeed*zoomspeed
			
			if (surfacePos > surfacePosOffset) surfacePos = surfacePosOffset
			if (surfacePos < -surfacePosOffset) surfacePos = -surfacePosOffset
			
			// repositioning of tiles		
			for ( local i = 0; i < tilesTotal; i++ ) {
				tilesTable[i].x = surfacePos - surfacePosOffset + tilesTablePosX[i]
				tilesTable[i].y = tilesTablePosY[i]
			}
			
			// scaling of current tile
			tilesTable[newfocusindex].x = surfacePos - surfacePosOffset + tilesTablePosX[newfocusindex] - (selectoroffseth*(1-zoompos))
			tilesTable[newfocusindex].y = tilesTablePosY[newfocusindex] - ((selectoroffsetv)*(1-zoompos)) 
			tilesTable[newfocusindex].width = widthpadded + (selectorwidth-widthpadded)*(1.0-zoompos)
			tilesTable[newfocusindex].height = heightpadded + (selectorwidth-heightpadded)*(1.0-zoompos)
			glohzTable[newfocusindex].alpha = 255*(1-zoompos)
			glovzTable[newfocusindex].alpha = 255*(1-zoompos)
			globalposnew = tilesTable[newfocusindex].x

			if (oldfocusindex != newfocusindex){
				tilesTable[oldfocusindex].x = surfacePos - surfacePosOffset + tilesTablePosX[oldfocusindex] - (selectoroffseth*(zoomunpos))
				tilesTable[oldfocusindex].y = tilesTablePosY[oldfocusindex] - ((selectoroffsetv)*(zoomunpos)) 
				tilesTable[oldfocusindex].width = widthpadded + (selectorwidth-widthpadded)*(zoomunpos)
				tilesTable[oldfocusindex].height = heightpadded + (selectorwidth-heightpadded)*(zoomunpos)
				glohzTable[oldfocusindex].alpha = 255*(zoomunpos)
				glovzTable[oldfocusindex].alpha = 255*(zoomunpos)
			}
		}
		
		// crossfade of video snaps, tailored to skip initial fade in
		if (( vidpos != 0 )) {
			
			vidpos = vidpos - 0.01
			if (vidpos < 0.01) vidpos = 0
			// newfocusindex = wrap( tilesTotal/2-1-corrector + tilesTableOffset, tilesTotal )

			if ((vidpos < delayvid) && (vidpos > delayvid - 0.01)){
				//vidszTable[newfocusindex].visible = true
				if (prf.THUMBVIDEO) vidszTable[newfocusindex].file_name = fe.get_art("snap")
				vidszTable[newfocusindex].alpha = 0		
				if (prf.CROPSNAPS){
					if (snapzTable[newfocusindex].texture_width >= snapzTable[newfocusindex].texture_height){
						vidszTable[newfocusindex].subimg_x = vidszTable[newfocusindex].texture_width/8.0
						vidszTable[newfocusindex].subimg_width = vidszTable[newfocusindex].texture_width*3/4.0
					}
					else{
						vidszTable[newfocusindex].subimg_y = vidszTable[newfocusindex].texture_height/8.0
						vidszTable[newfocusindex].subimg_height = vidszTable[newfocusindex].texture_height*3/4.0	
					}
				}

			}
			
			if (vidpos <= fadevid)
			vidszTable[newfocusindex].alpha = 255.0*(1-vidpos*(1/fadevid))
			else
			vidszTable[newfocusindex].alpha = 0
		}
		
	}
	
	
	// wrap around value witin range 0 - N
	function wrap( i, N ) {
		while ( i < 0 ) { i += N }
		while ( i >= N ) { i -= N }
		return i
	}

	function updatescreen(){
		local path = FeConfigDirectory
		local dir = DirectoryListing( path )
		local picname = ""
		local fpos1 = null
		local fpos2 = null
		local picnum = 0
		local picout = 0

		foreach ( f in dir.results ){
			fpos1 = f.find(".png")
			fpos2 = f.find("screen")
			if ((fpos1 != null) && (fpos2 != null)){
				picnum = f.slice(fpos2+6,fpos1)
				// print (picnum+"\n")
				if (picnum == "") picnum = "0"
				picnum = picnum.tointeger()
				if (picout < picnum ) picout = picnum
			}
		}
		picname = FeConfigDirectory + "screen" + picout +".png"
		return picout
	}

	function getsnap(signalin){
		frostshaders(true)

		oldgrabnum = updatescreen()
		fe.signal("screenshot")
		oldgrabnum ++
		grabpath0 = FeConfigDirectory + "screen" + oldgrabnum +".png"
		numgrabs ++
		grabpath = FeConfigDirectory + "grab" + numgrabs +".png"
		createdgrabs.push (grabpath)
		grabticker = 1
		grabsignal = signalin

	}

	/// On Signal  
	function on_signal( sig ){


		if (DEBUG) print ("\n Si:" + sig )

		//if (sig == "exit") wooshsound.playing = true

		if (prf.FROSTEDGLASS){

			if (sig == "exit"){
				if (immediatesignal){
					immediatesignal = false
					return false
				}
				else{
					getsnap("exit")
					return true
				}
			}

			if (sig == "filters_menu"){
				if (immediatesignal){
					immediatesignal = false
					return false
				}
				else{
					getsnap("filters_menu")
					return true
				}
			}

			if (sig == "add_favourite"){
				if (immediatesignal){
					immediatesignal = false
					return false
				}
				else{
					getsnap("add_favourite")
					return true
				}
			}

			if (sig == "add_tags"){
				if (immediatesignal){
					immediatesignal = false
					return false
				}
				else{
					getsnap("add_tags")
					return true
				}
			}
		}

		// Rotation controls
		if(sig == "toggle_rotate_right"){
			if (fe.layout.toggle_rotation == RotateScreen.None)
			{
				fe.layout.toggle_rotation = RotateScreen.Right
				fe.signal ("reload")
			}
			else{
				fe.layout.toggle_rotation = RotateScreen.None
				fe.signal ("reload")
			}
			return true
		}

		if(sig == "toggle_rotate_left"){
			if (fe.layout.toggle_rotation == RotateScreen.None)
			{
				fe.layout.toggle_rotation = RotateScreen.Left
				fe.signal ("reload")
			}
			else{
				fe.layout.toggle_rotation = RotateScreen.None
				fe.signal ("reload")
			}
			return true
		}

		if(sig == "next_game"){
			fe.list.index ++
		}

		if(sig == "prev_game"){
			fe.list.index --
		}

		if (overmenu_visible())
		{
			if (DEBUG) print (" OVERMENU \n")


			if (sig == "up"){
				
				if (prf.FROSTEDGLASS){
					if (immediatesignal){
						wooshsound.playing=true
						immediatesignal = false
					}
					else{
						getsnap("up")
						return true
					}
				}

				overmenu_hide(true)
				//wooshsound.playing=true
				local searchtext =""
				local switcharray = [
					"Year",
					"Decade",
					"Manufacturer",
					"Main Category",
					"Sub Category",
					"RESET"
				]
				local result = fe.overlay.list_dialog(switcharray,"More of the same...")
				
				if(result==5){
					//fe.list.index += corrector + rows 
					fe.list.search_rule =""
					searchdata.msg = ""
					if (backindex != -1){
						fe.list.index = backindex
						//corrector = backcorrector
						backindex = -1
					}					 
				}
				
				if (result == 0) {
					searchtext = "Year contains "+ fe.game_info(Info.Year)
				}

				if (result == 1) {
					searchtext = "Year contains "+ fe.game_info(Info.Year).slice(0,3)
				}

				if (result == 2) {
					searchtext = "Manufacturer contains "+fe.game_info(Info.Manufacturer)
				}

				if (result == 3) {
					searchtext = (fe.game_info(Info.Category))
					local s = split( searchtext, "/" )
					searchtext = "Category contains "+s[0]
				}

				if (result == 4) {	
					searchtext = "Category contains "+fe.game_info(Info.Category)		
				}
				
				if ((result !=5) && (result != -1)) {
					if (backindex == -1) {
						backindex = fe.list.index
						//backcorrector = corrector
					}
					//fe.list.index += corrector + tilesTotal 
					fe.list.index ++
					fe.list.search_rule = searchtext
					//fe.list.index = 0
					corrector = 0
					searchdata.msg = searchtext
				}
				return true
			}

			else if (sig == "down") {
				overmenu_hide(false)
				//try {
					history_show()
				//} catch ( err ) { print( "History Error\n" ); }

				return true
			}

			else if (sig == "left") {
				// add tags
				overmenu_hide(true)
				wooshsound.playing = true
				fe.signal ("add_tags")
				return true
			}

			else if (sig == "right") {
				// add current game to favorites
				overmenu_hide(true)
				//changedfav = true
				wooshsound.playing = true
				fe.signal("add_favourite")
				return true
			}

			else if (sig == "back") {
				overmenu_hide(false)
				return true
			}

			else if (sig == prf.OVERMENUBUTTON) {
				overmenu_hide(false)
				return true
			}
			
			return false 
		}
		
		else if (history_visible())
		{
			if (DEBUG) print (" HISTORY \n")

			if (sig == "up") {
				on_scroll_up()
				return true
			}

			else if (sig == "down") {
				on_scroll_down()
				return true
			}

			else if (sig == "left") {
				fe.list.index--
				history_show()
				return true
			}

			else if (sig == "right") {
				fe.list.index++
				history_show()
				return true
			}

			else if (sig == "back") {
				history_exit()
				return true
			}

			return false 
		}

		else if (search_visible())
		{
			if (DEBUG) print (" SEARCH \n")

			if ( sig == "up" ) {
				search_select_relative( 0, -1 )
				while (key_rows[key_selected[1]][key_selected[0]].tochar()=="_") search_select_relative( 0, -1 )
			}

			else if ( sig == "down" ) {
				search_select_relative( 0, 1 )
				while (key_rows[key_selected[1]][key_selected[0]].tochar()=="_") search_select_relative( 0, 1 )
			}

			else if ( sig == "left" ) {
				search_select_relative( -1, 0 )
				while (key_rows[key_selected[1]][key_selected[0]].tochar()=="_") search_select_relative( -1, 0 )
			}

			else if ( sig == "right" ) {
				search_select_relative( 1, 0 )
				while (key_rows[key_selected[1]][key_selected[0]].tochar()=="_") search_select_relative( 1, 0 )
			}

			else if ( sig == "select" ) search_type( key_rows[key_selected[1]][key_selected[0]].tochar() )
			//else if ( sig == "back" ) search_type("<")
			//else if ( sig == "exit" ) search_toggle()
			else if ( sig == "back" ) search_toggle()
		
			else if (sig == "screenshot"){
				return false
			}

			return true
		}
		
		// normal signal response
		else {
			if (DEBUG) print (" NORMAL \n")
			switch ( sig ){			

				case prf.OVERMENUBUTTON:
				overmenu_show()
				return true

				case "left":
				if (fe.list.index > scrollstep - 1) {
					if (leftcount == 0) {
						fe.list.index -= scrollstep
						ticksound.playing=true
						leftcount ++
					}
					else {
						leftcount ++
						if (leftcount == movecount)	leftcount = 0			
					}
				}
				else zoompos = 1
				return true
				
				case "right":
				if ((fe.list.index < fe.list.size - scrollstep)){
					if (rightcount == 0) {
						fe.list.index += scrollstep
						ticksound.playing=true
						rightcount ++
					}
					else {
						rightcount ++
						if (rightcount == movecount)	rightcount = 0			
					}
				}
				else zoompos = 1
				return true
				
				case "up":
				if ((fe.list.index % rows > 0) && (scrolljump == false)) {
					fe.list.index --
					ticksound.playing = true
				}
				else if (scrolljump == true){
					wooshsound.playing=true
					scrolljump = false
					scrollstep = rows
					scroller2.visible = scrollineglow.visible = false
				}
				else {
					if (prf.FROSTEDGLASS){
						if (immediatesignal){
						//wooshsound.playing=true	
						immediatesignal = false
						}
						else{
						getsnap("up")
						return true
						}
					}
					else wooshsound.playing = true

					local switcharray1 = [
						"Filters",
						"Search for...",
						"Layout options"
					]

					local result1 = fe.overlay.list_dialog(switcharray1,"Utility Menu")

					if (result1 == 0){
						//	wooshsound.playing=true
						immediatesignal = true
						fe.signal("filters_menu")
						wooshsound.playing=true
					}

					if (result1 == 2){
						//	wooshsound.playing=true
						fe.signal("layout_options")
						wooshsound.playing=true
					}	

					if (result1 == 1){
						wooshsound.playing=true

					local searchtext =""
					local switcharray = [
						"Title",
						"Manufacturer",
						"Year",
						"Category",
						"RESET"
					]
					local result = fe.overlay.list_dialog(switcharray,"Search for...")
					
					if(result==4){
						//fe.list.index += corrector + rows 
						fe.list.search_rule =""
						searchdata.msg = ""
						if (backindex != -1){
							fe.list.index = backindex
							//corrector = backcorrector
							backindex = -1
						}
						//return
					}

					if ((result != 4)&&(result !=-1)){
						if (prf.KEYBOARD) 
							searchtext = fe.overlay.edit_dialog("Search "+switcharray[result]+": ",searchtext)
						else
							search_base_rule = switcharray[result]
						
						if (backindex == -1){
							backindex = fe.list.index
							//backcorrector = corrector
						}
						
						if (prf.KEYBOARD)
						{
							fe.list.index ++
							fe.list.search_rule = switcharray[result]+" contains "+ recalculate(searchtext)
							fe.list.index = 0
							corrector = 0
							if(fe.list.search_rule == ""){
								searchdata.msg = ""
								if (backindex != -1){
									fe.list.index = backindex
									//corrector = backcorrector
									backindex = -1
								}
							}
							else
							searchdata.msg = fe.list.search_rule
						}
						else{
							search_toggle()
						}
						
						return true
						
					}
					return true
					}
				}
				return true
				
				case "down":
				if ((fe.list.index % rows < rows -1) && ( ! ( (fe.list.index / rows == fe.list.size / rows)&&(fe.list.index%rows + 1 > (fe.list.size -1)%rows) ))) {
					if ((corrector == 0) && (fe.list.index == fe.list.size-1)) return true
					fe.list.index ++
					ticksound.playing=true
				}

				else if (scrolljump == false){
					wooshsound.playing=true
					scrolljump = true
					scrollstep = rows*(cols-2)
					scroller2.visible = scrollineglow.visible = true		
				}

				return true
				/*
				// add favorites 
				case "add_favourite":
				//changedfav = true
				wooshsound.playing=true
				break
				*/				
				// All other cases
				default:
				wooshsound.playing=true
				
			}// END OF SWITCH SIGNAL LOOP 
		}// CLOSE ELSE GROUP
		return false
	}
}

/// Misc functions  

function recalculate( str ) {
	if ( str.len() == 0 ) return ""
	str = str.tolower()
	local words = split( str, " " )
	local temp=""
	foreach ( idx, w in words ) {
		//print("searching: " + w )
		//if ( idx > 0 ) temp += " "
		//foreach( c in w )
		//  if ( c != " " ) temp += ( "1234567890".find(c.tochar()) != null ) ? c.tochar() : "[" + c.tochar().toupper() + c.tochar().tolower() + "]"
		if ( temp.len() > 0 )
		temp += " "
		local f = w.slice( 0, 1 )
		temp += ( "1234567890".find(f) != null ) ? "[" + f + "]" + w.slice(1) : "[" + f.toupper() + f.tolower() + "]" + w.slice(1)
	}
	return temp
}

// gets the first letter of the game name, # if it's a number
function gameletter( offset ) {
	if (fe.filters[fe.list.filter_index].sort_by == Info.Year){
		local s = fe.game_info( Info.Year, offset )
		return s
	}
	else {
		local s = fe.game_info( Info.Title, offset )
		local s2 = s.slice(0,1)
		if ("1234567890".find (s2) != null ){
			s2="#"
		}
		return s2
	}
}

// gets the first part of the game name
function gamename( offset ) {
	local s = split( fe.game_info( Info.Title, offset ), "(" )	
	if ( s.len() > 0 ) {
		return s[0]
	}
	return ""
}

function gamenames(offset){
	local s1 = split( fe.game_info( Info.Title, offset ), "(" )
	local s2 = split (s1[0], "/")
	local s2len = s2.len()
	if ( s2len > 0 ){
		return s2len
	}

	return 0

}

function gamenamex(offset , index){
	local s1 = split( fe.game_info( Info.Title, offset ), "(" )
	local s2 = split (s1[0], "/")
	local s2len = s2.len()
	if (index == -1) index = s2len-1
	local s2index = index % s2len
	if ( s2len > 0 ){
		local s2string = rstrip(lstrip(s2[s2index]))
		return s2string.toupper() + (s2len > 1 ? " ···" : "")
	}
	return ""
}

function gameplaycount( offset ) {
	local s = fe.game_info( Info.PlayedCount, offset )
	if ( s.len() > 0 ) {
		return s[0]
	}
	return ""
}

// gets the second part of the game name, after the "("
function gamesubname( offset ) {
	local s = split( fe.game_info( Info.Title, offset ), "(" )
	if ( s.len() > 1 ) {
		return "("+s[1]
	}
	return ""
}

function maincategory( offset ) {
	local s = split( fe.game_info( Info.Category, offset ), "/" )
	if ( s.len() > 1 ) {
		return " "+s[0]+"\n"+s[1]+" "
	}
	return ""
}



/// Display construction (BACKGROUND)  


local commonground = fe.add_image("gridbg.png",0,0,flw,flh)

local xsurf1 = null
local xsurf2 = null
local bg_surface = null
local whitebg = null
local smallsize = 26
local blursize = 1/26.0

xsurf1 = fe.add_surface(smallsize,smallsize)

for (local i = 0; i < stacksize; i++){
	varray.push (0)
	alphapos.push (0)
	local bgpic = xsurf1.add_artwork("snap",0,0,smallsize,smallsize)
	bgpic.set_rgb (shadeval,shadeval,shadeval)
	bgpic.alpha = 255
	bgpic.trigger = Transition.EndNavigation
	bgpic.video_flags = Vid.ImagesOnly
	bgpic.smooth = true
	bgpic.preserve_aspect_ratio = false
	bgpicarray.push(bgpic)
}

xsurf2 = fe.add_surface(smallsize,smallsize)

bg_surface = fe.add_surface(flw,flh)
bg_surface.alpha=255

local shaderH1 = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
shaderH1.set_texture_param( "texture")
shaderH1.set_param("kernelData", 9.0, 2.2)
shaderH1.set_param("offsetFactor", blursize, 0.0)
xsurf1.shader = shaderH1

local shaderV1 = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
shaderV1.set_texture_param( "texture")
shaderV1.set_param("kernelData", 9.0, 2.2)
shaderV1.set_param("offsetFactor", 0.0, blursize)
xsurf2.shader = shaderV1

xsurf2.visible = false
xsurf2 = bg_surface.add_clone(xsurf2)
xsurf2.visible = true

xsurf1.visible = false
xsurf1 = xsurf2.add_clone(xsurf1)
xsurf1.visible = true

xsurf2.set_pos(bgT.x,bgT.y,bgT.w,bgT.w)

local pixelgrid = null
local bgvidsize = 90.0

function squarebg(){
	for (local i = 0; i < stacksize ; i++){
		if (bgpicarray[i].texture_width >= bgpicarray[i].texture_height){
			bgpicarray[i].subimg_x = bgpicarray[i].texture_width * 1/8.0
			bgpicarray[i].subimg_width = bgpicarray[i].texture_width * 3/4.0
		}
		else
		{
			bgpicarray[i].subimg_y = bgpicarray[i].texture_height * 1/8.0
			bgpicarray[i].subimg_height = bgpicarray[i].texture_height * 3/4.0
		}
		if (prf.LAYERSNAP){
			bgvidarray[i].subimg_x = bgpicarray[i].subimg_x
			bgvidarray[i].subimg_y = bgpicarray[i].subimg_y
			bgvidarray[i].subimg_width = bgpicarray[i].subimg_width
			bgvidarray[i].subimg_height = bgpicarray[i].subimg_height
		}
	}
}


if (prf.LAYERSNAP){
	bgvidsurf = fe.add_surface(bgvidsize,bgvidsize)
	//bgvid1 = bgvidsurf.add_artwork("snap",0,0,bgvidsize,bgvidsize)

	for (local i = 0; i < stacksize; i++){
		local bgvid = null

		if (!prf.LAYERVIDEO) {
			bgvid = bgvidsurf.add_clone(bgpicarray[i])
			bgvid.video_flags = Vid.ImagesOnly
		}
		else if (i == stacksize - 1 ){
			bgvid = bgvidsurf.add_artwork("snap",0,0,bgvidsize,bgvidsize)
			bgvid.video_flags = Vid.NoAudio
		}
		else{
			bgvid = bgvidsurf.add_clone(bgpicarray[i])
			bgvid.video_flags = Vid.ImagesOnly
			bgvid.visible = false
		}
		
		bgvid.set_pos(0,0,bgvidsize,bgvidsize)
		bgvid.preserve_aspect_ratio = false
		bgvid.trigger = Transition.EndNavigation
		bgvid.smooth = true
		bgvidarray.push(bgvid)
	}


	bgvidsurf.smooth = false

	bgvidsurf.alpha = vidsatin

	bgvidsurf.set_pos(bgT.x,bgT.y,bgT.w,bgT.w)

	pixelgrid = fe.add_image("grid128x.png",bgT.x,bgT.y,bgT.w,bgT.w*128.0/bgvidsize)
	pixelgrid.alpha = 50
}

local bgpicture = null

if (prf.BGBLURRED != "")	{
	bgpicture = bg_surface.add_image(prf.BGBLURRED,0,0,flw,flh)
	bgpicture.visible = false
	bgpicT.ar = (bgpicture.texture_width*1.0) / bgpicture.texture_height

	if (bgpicT.ar >= flw/(flh*1.0)){
		bgpicT.h = flh
		bgpicT.w = bgpicT.h * bgpicT.ar
		bgpicT.y = 0
		bgpicT.x = - (bgpicT.w - flw)*0.5
	}
	else {
		bgpicT.w = flw
		bgpicT.h = bgpicT.w / bgpicT.ar*1.0
		bgpicT.y = - (bgpicT.h - flh)*0.5
		bgpicT.x = 0
	}
	bgpicture=bg_surface.add_image (prf.BGBLURRED,bgpicT.x,bgpicT.y,bgpicT.w,bgpicT.h)
	bgpicture.visible=true
}

whitebg = bg_surface.add_text("",0,0,flw,flh)
whitebg.set_bg_rgb(themeoverlaycolor,themeoverlaycolor,themeoverlaycolor)
whitebg.bg_alpha = themeoverlayalpha


/// Display construction (CARRIER) 

// scrolling carrier call

local carrier = Carrier()


/// Foreground panel surface  

local fg_surface = fe.add_clone(bg_surface)
fg_surface.zorder = zordertop + 2

//fg_surface.alpha = 120
//fg_surface.set_pos(bgT.x,bgT.y,bgT.w,bgT.w)

/// Display construction (DATA)  

local rightdata = 400*scalerate
//local namesurf = fe.add_surface (flw-rightdata,header_h)

local name_surf = fe.add_surface (flw - rightdata, header_h*2/3)

// game name shadow
local namesh_x = name_surf.add_text( "[!gamename]", 3, 3, flw*2, header_h*2/3 )
namesh_x.align = Align.Left
namesh_x.word_wrap = false
namesh_x.set_rgb( 0, 0, 0)
namesh_x.charsize = 60*scalerate
namesh_x.alpha=themeshadow
//namesh_x.bg_alpha = 128
//namesh_x.bg_red = 255
namesh_x.font = guifont
namesh_x.alpha = 0

// game name
local name_x = name_surf.add_text( "[!gamename]", 0, 0, flw*2, header_h*2/3 )
name_x.align = Align.Left
name_x.word_wrap = false
name_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)
name_x.charsize = 60*scalerate
//name_x.bg_alpha = 128
//name_x.bg_red = 255
name_x.font = guifont
name_x.alpha = 0

// game name shadow
local namesh_x2 = name_surf.add_text( "[!gamename]", 3, 3, flw*2, header_h*2/3 )
namesh_x2.align = Align.Left
namesh_x2.word_wrap = false
namesh_x2.set_rgb( 0, 0, 0)
namesh_x2.charsize = 60*scalerate
namesh_x2.alpha=themeshadow
//namesh_x.bg_alpha = 128
//namesh_x.bg_red = 255
namesh_x2.font = guifont

// game name
local name_x2 = name_surf.add_text( "[!gamename]", 0, 0, flw*2, header_h*2/3 )
name_x2.align = Align.Left
name_x2.word_wrap = false
name_x2.set_rgb(themetextcolor,themetextcolor,themetextcolor)
name_x2.charsize = 60*scalerate
//name_x.bg_alpha = 128
//name_x.bg_red = 255
name_x2.font = guifont

local data_surface = fe.add_surface (flw,flh)

name_surf.visible = false
name_surf = data_surface.add_clone (name_surf)
name_surf.visible = true

// game name second part (revision, details etc)
local subname_x = data_surface.add_text( " [!gamesubname]", 0, header_h*1/3+60*scalerate/2, flw - rightdata, header_h*1/3 )
subname_x.align = Align.Left
subname_x.word_wrap = true
subname_x.set_rgb( 255, 255, 255)
subname_x.charsize = 40*scalerate
//subname_x.bg_alpha = 128
//subname_x.bg_green = 255
subname_x.font = guifont
subname_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

// game year and some data
local year_x = data_surface.add_text( "© [Year] [Manufacturer]", flw-rightdata, 10*scalerate, rightdata, header_h/2)
//local year_x = fe.add_text( "© [Year] [Manufacturer]", flw-rightdata*2, header_h/2-10*scalerate, rightdata, header_h/2)
year_x.align = Align.Centre
year_x.set_rgb( 255, 255, 255)
year_x.word_wrap = true
year_x.charsize = 30*scalerate
year_x.visible = true
//year_x.bg_alpha = 128
//year_x.bg_green = 155
year_x.font = guifont
year_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

// game category and some data
local year2_x = data_surface.add_text( "[!maincategory]", flw-rightdata, header_h/2-10*scalerate, rightdata, header_h/2)
year2_x.align = Align.Centre
year2_x.set_rgb( 255, 255, 255)
year2_x.word_wrap = true
year2_x.charsize = 30*scalerate
year2_x.visible = true
//year2_x.bg_alpha = 128
//year2_x.bg_red = 155
year2_x.font = guifont
year2_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

local filterdata = data_surface.add_text ("[FilterName]",0,flh-footer_h,footermargin,footer_h)
filterdata.align = Align.Centre
filterdata.set_rgb( 255, 255, 255)
filterdata.word_wrap = true
filterdata.charsize = 25*scalerate
filterdata.visible = true
filterdata.font = guifont
filterdata.set_rgb(themetextcolor,themetextcolor,themetextcolor)

local filternumbers = data_surface.add_text ("[ListEntry]/[ListSize]",flw-footermargin,flh-footer_h,footermargin,footer_h)
filternumbers.align = Align.Centre
filternumbers.set_rgb( 255, 255, 255)
filternumbers.word_wrap = true
filternumbers.charsize = 25*scalerate
filternumbers.visible = true
filternumbers.font = guifont
filternumbers.set_rgb(themetextcolor,themetextcolor,themetextcolor)

data_surface.zorder = zordertop + 3
//name_surf.zorder = subname_x.zorder = year_x.zorder = year2_x.zorder = filterdata.zorder = filternumbers.zorder = zordertop + 1

/// Frosted glass surface  

local frost_picsize = 96.0
local frost_picw = null
local frost_pich = null

if (!vertical){
	frost_picw = frost_picsize
	frost_pich = frost_picsize * flh/flw
}
else {
	frost_picw = frost_picsize * flw/flh
	frost_pich = frost_picsize
}

local displayAR = ScreenWidth*1.0/ScreenHeight
local screenAR = scrw*1.0/scrh
local layoutAR = flw*1.0/flh
if (rotate90) displayAR = 1.0/displayAR

local frost_picT = {
	x = null,
	y = null,
	w = null,
	h = null
}

if (displayAR > layoutAR){
	frost_picT.h = frost_pich
	frost_picT.w = frost_pich*displayAR
	frost_picT.x = (frost_picw - frost_picT.w)*0.5
	frost_picT.y = 0
}
else{
	frost_picT.w = frost_picw
	frost_picT.h = frost_picw/displayAR
	frost_picT.x = 0
	frost_picT.y = (frost_pich - frost_picT.h)*0.5

}

local frost_surf1 = null
local flipshader = null
local frost_surf2 = null
local frost_pic = null
local frostshader1 = null
local frostshader2 = null
local frost_surface = null


if (prf.FROSTEDGLASS){
	 frost_surf1 = fe.add_surface(frost_picw,frost_pich)

	frost_pic = frost_surf1.add_image("transparent.png",frost_picT.x,frost_picT.y,frost_picT.w,frost_picT.h)

	flipshader = fe.add_shader( Shader.Fragment, "flipper.glsl" )
	flipshader.set_texture_param( "texture")
	flipshader.set_param("rotation",realrotation)

	frost_surf2 = fe.add_surface(frost_picw,frost_pich)

	frost_surface = fe.add_surface(flw,flh-header_h-footer_h)

	frostshader1 = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
	frostshader1.set_texture_param( "texture")
	frostshader1.set_param("kernelData", 13.0, 2.5)
	frostshader1.set_param("offsetFactor", 0.0000, 1.0/frost_pich)

	frostshader2 = fe.add_shader( Shader.Fragment, "gauss_kernsigma_o.glsl" )
	frostshader2.set_texture_param( "texture")
	frostshader2.set_param("kernelData", 13.0, 2.5)
	frostshader2.set_param("offsetFactor", 1.0/frost_picw, 0.000)



	frost_surf2.visible = false
	frost_surf2 = frost_surface.add_clone(frost_surf2)
	frost_surf2.visible = true

	frost_surf1.visible = false
	frost_surf1 = frost_surf2.add_clone(frost_surf1)
	frost_surf1.visible = true

	frost_surf2.set_pos(0,-header_h,flw,flh)

	frost_surface.set_pos(0,header_h,flw,flh-header_h-footer_h)

	frost_surface.alpha = 0

	//frost_pic.smooth = frost_surf1.smooth = frost_surf2.smooth = frost_surface.smooth = false
	

	//frost_surface = fe.add_clone(frost_surf1)
	frost_surface.zorder = zordertop + 4

	//frost_surface.alpha = 120
	//frost_surface.set_pos(bgT.x,bgT.y,bgT.w,bgT.w)
}

/// Side/top blanker for custom resolution  

local blank_1 = null
local blank_2 = null

if (prf.CUSTOMSIZE != ""){

	if (displayAR > layoutAR){
		blank_1 = fe.add_image("black.png",(flh/frost_pich)*frost_picT.x,0,-(flh/frost_pich)*frost_picT.x,flh)
		blank_2 = fe.add_image("black.png",flw,0,-(flh/frost_pich)*frost_picT.x,flh)
	}
	else{
		blank_1 = fe.add_image("black.png",0,(flw/frost_picw)*frost_picT.y,flw,-(flw/frost_picw)*frost_picT.y)
		blank_2 = fe.add_image("black.png",0,flh,flw,-(flw/frost_picw)*frost_picT.y)
	}

	//blank_1.set_rgb(128,128,128)
	//blank_2.set_rgb(128,128,128)

	blank_1.zorder=blank_2.zorder = 500
}

/// Controls Overlays (Listbox)  

local overlay_charsize = floor( 50*scalerate )
local overlay_rowsize = (overlay_charsize*3)
local overlay_labelsize = (overlay_rowsize * 1)
local overlay_labelcharsize = overlay_charsize * 1

local overlay_rows = floor((flh-header_h-footer_h - overlay_labelsize)/overlay_rowsize)

// sfondo dell'area con le scritte
local overlay_background = fe.add_text ("", 0 , header_h, flw, flh-header_h-footer_h)
overlay_background.set_bg_rgb(200,200,200)
overlay_background.bg_alpha = 15

local overlay_listbox = fe.add_listbox( 0, header_h+overlay_labelsize, flw, flh-header_h-footer_h-overlay_labelsize )
overlay_listbox.rows = overlay_rows
overlay_listbox.charsize = overlay_charsize
overlay_listbox.bg_alpha = 0
overlay_listbox.set_rgb(themetextcolor-5,themetextcolor-5,themetextcolor-5)
overlay_listbox.set_bg_rgb( 0, 0, 0 )
overlay_listbox.set_sel_rgb( 50, 50, 50 )
overlay_listbox.set_selbg_rgb( 250,250,250 )
overlay_listbox.selbg_alpha = 255
overlay_listbox.font = guifont

local overlay_label = fe.add_text( "dummy", 0, header_h, flw, overlay_labelsize )
overlay_label.charsize = overlay_labelcharsize
overlay_label.set_rgb(themetextcolor-5,themetextcolor-5,themetextcolor-5)
overlay_label.align = Align.Centre
overlay_label.font = guifont

local shader1 = fe.add_image ("wgradient.png",0,flh-footer_h,flw,50*scalerate)

local shader2 = fe.add_image ("white.png",padding,header_h+overlay_labelsize-2,flw-2*padding,2)

local shader3 = fe.add_image ("wgradient2.png",0,header_h-50*scalerate,flw,50*scalerate)

shader1.alpha = 50
shader2.alpha = 255
shader3.alpha = 50
shader1.set_rgb(0,0,0)
shader3.set_rgb(0,0,0)

overlay_listbox.visible = overlay_label.visible = overlay_background.visible = shader1.visible = shader2.visible = shader3.visible = false

overlay_listbox.zorder = overlay_label.zorder = overlay_background.zorder = shader1.zorder = shader2.zorder = shader3.zorder = zordertop + 5

fe.overlay.set_custom_controls( overlay_label, overlay_listbox )

function overlay_show(){
	if (prf.FROSTEDGLASS) 
		frost_surface.alpha = 255 
	else
		fg_surface.alpha = 255*satinrate

	if (logoshow != 0 ) cutlogo()

	overlay_listbox.visible = overlay_label.visible = overlay_background.visible = shader1.visible = shader2.visible = shader3.visible = true
}

function overlay_hide(){
	if (prf.FROSTEDGLASS) {
		frost_surface.alpha = 0
		frostshaders(false) 
	}
	else
		fg_surface.alpha = 0
	if (prf.FROSTEDGLASS) grabdither = 2
	overlay_listbox.visible = overlay_label.visible = overlay_background.visible = shader1.visible = shader2.visible = shader3.visible = false		
}



/// Splash Screen  

// carica l'immagine sfumata del gioco attuale 

local aflogo_surface = fe.add_surface(flw,flh)

local afsplash = null


// aggiunge l'immagine del logo
local aflogo = aflogo_surface.add_image (prf.SPLASHLOGOFILE,0,0,flw,flh)
aflogo.visible = false

local aflogoT = {
	w = flw,
	h = flh,
	x = 0,
	y = 0,
	ar = aflogo.texture_width*1.0 / aflogo.texture_height
}

if (aflogoT.ar >= flw/(flh*1.0)){
	aflogoT.w = flw
	aflogoT.h = aflogoT.w / aflogoT.ar*1.0
	aflogoT.y = - (aflogoT.h - flh)*0.5
	aflogoT.x = 0
}
else {
	aflogoT.h = flh
	aflogoT.w = aflogoT.h * aflogoT.ar
	aflogoT.y = 0
	aflogoT.x = - (aflogoT.w - flw)*0.5
}

local aflogo2 = aflogo_surface.add_image (prf.SPLASHLOGOFILE,aflogoT.x,aflogoT.y,aflogoT.w,aflogoT.h)

//aflogo = aflogo_surface.add_image ("AFLOGO3b.png",0,(flh-(flw*1000/1600))/2,flw,flw*1000/1600)

if (!prf.SPLASHON) aflogo_surface.visible = false

aflogo_surface.zorder = zordertop + 100
//afsplash.zorder = zordertop + 100
//afwhitebg.zorder = zordertop + 101
//aflogo.zorder = zordertop + 102

/// Context Menu  

//local overmenuwidth = (vertical ? flw * 0.7 : flh * 0.7)
local overmenuwidth = selectorwidth * 0.9
local overmenu = fe.add_image("overmenu2.png",flw*0.5-overmenuwidth*0.5,flh*0.5-overmenuwidth*0.5,overmenuwidth,overmenuwidth)
overmenu.visible = false
overmenu.alpha = 0

function overmenu_visible(){
	return ((overmenu.visible) && (overmenuflow != -1))
}

function overmenu_show(){
	overmenu.y = flh*0.5*0 + header_h + heightpadded*0.5 -overmenuwidth*0.5 - corrector * (heightpadded - padding)
	overmenu.x = flw*0.5 - overmenuwidth*0.5 + centercorrection
	wooshsound.playing=true
	overmenu.visible = true
	overmenuflow = 1
}

function overmenu_hide(strict){
	wooshsound.playing=true
	if(strict) overmenu.visible = false
	overmenuflow = -1
}

overmenu.zorder = zordertop + 200

/// Search Module  

local search_surface = fe.add_surface(flw, flh)
local keys = null
keys = {}
local search_text = null
local key_low = 100

search_surface.preserve_aspect_ratio = true
search_surface.alpha = 255*0

//select( config.keys.selected[0], config.keys.selected[1] )

function search_toggle() {
	search_surface.alpha = ( search_surface.alpha == 0 ) ? 255: 0

	//clear text when shown
	if ( search_visible() ){ 
		if (search_text.msg == "") search_text.msg = search_base_rule + ": "
		search_clear()
	}
	
	if ((search_visible() == false) && (fe.list.search_rule == "")) {
		if (backindex != -1) {
			fe.list.search_rule == ""
			fe.list.index = backindex
			//corrector = backcorrector
			backindex = -1
		}
	}
	
}

function search_clear()
{
	s_text = ""
	search_text.msg = search_base_rule + ": "
	search_update_rule()
}

//get current visibility
function search_visible() {
	return (search_surface.alpha == 255)
}

function search_select_relative( rel_col, rel_row )
{
	search_select( key_selected[0] + rel_col, key_selected[1] + rel_row )
}

function search_select( col, row )
{
	row = ( row < 0 ) ? key_rows.len() - 1 : ( row > key_rows.len() - 1 ) ? 0 : row
	col = ( col < 0 ) ? key_rows[row].len() - 1 : ( col > key_rows[row].len() - 1 ) ? 0 : col
	local previous = key_rows[key_selected[1]][key_selected[0]].tochar()
	local selected = key_rows[row][col].tochar()
	//print( "selected: " + selected + "(" + col + "," + row + ") previous: " + previous + "(" + config.keys.selected[0] + "," + config.keys.selected[1] + ")" )
	keys[previous].set_rgb( key_low,key_low,key_low )
	keys[previous].alpha = 255
	keys[selected].set_rgb( 255,255,255 )
	keys[selected].alpha = 255
	key_selected = [ col, row ]
}

function search_type( c )
{
	if ( c == "<" )
		s_text = ( s_text.len() > 0 ) ? s_text.slice( 0, s_text.len() - 1 ) : ""
	else if ( c == "-" )
		search_clear()
	else if ( c == "~" )
	{
		//search_update_rule ()
		//backindex = -1
		if (!prf.LIVESEARCH) search_update_rule()
		search_toggle()
		return
	}
	else if (c != "_")
		s_text = s_text + c
	search_text.msg = search_base_rule + ": " + s_text 
	if (prf.LIVESEARCH) search_update_rule()
}

function search_update_rule(){
	try
	{
		local rule = search_base_rule + " contains " + recalculate (s_text)
		//fe.list.search_rule = "Title contains mario"
		//fe.list.search_rule = ""
		//fe.list.index += corrector + tilesTotal
		fe.list.index ++
		fe.list.search_rule = ( s_text.len() > 0 ) ? rule : ""
		//fe.list.index = 0
		corrector = 0
		if(fe.list.search_rule == ""){
			searchdata.msg = ""
			//if (backindex != -1){
				fe.list.index = backindex
				//corrector = backcorrector
			//	backindex = -1
			//}
		}
		else
		searchdata.msg = fe.list.search_rule
		
		
	} catch ( err ) { print( "Unable to apply filter: " + err ); }
}

function draw_osd() {
	
	//draw the search surface bg
	local bg = search_surface.add_image("kbg2.png", 0, 0, search_surface.width, search_surface.height)
	bg.alpha = 230
	
	//draw the search text object
	local osd_search = {
		x = ( search_surface.width * 0 ) * 1.0,
		y = ( search_surface.height * 0.2 ) * 1.0,
		width = ( search_surface.width * 1 ) * 1.0,
		height = ( search_surface.height * 0.1 ) * 1.0
	}
	
	search_text = search_surface.add_text(s_text, osd_search.x, osd_search.y, osd_search.width, osd_search.height)
	search_text.align = Align.Left
	search_text.font = guifont
	search_text.set_rgb( 255, 255, 255 )
	search_text.alpha = 255
	search_text.charsize = 80*scalerate
	
	
	//draw the search key objects
	foreach( key,val in key_names ) {
		
		local key_name = (key == "_") ? " " : ( key == "-" ) ? "CLR" : ( key == " " ) ? "SPC" : ( key == "<" ) ? "DEL" : ( key == "~" ) ? "DONE" : key.toupper()
		
		local textkey = search_surface.add_text( key_name, -1, -1, 1, 1 )
		textkey.font = guifont
		textkey.charsize = 80*scalerate
		
		textkey.set_rgb( key_low,key_low,key_low)
		textkey.alpha = 255
		
		keys[ key.tolower() ] <- textkey
		
	}
	
	
	//set search key positions
	local row_count = 0
	foreach ( row in key_rows )
	{
		local col_count = 0
		local osd = {
			x = ( search_surface.width * 0.1 ) * 1.0,
			y = ( search_surface.height * 0.4 ) * 1.0,
			width = ( search_surface.width * 0.8 ) * 1.0,
			height = ( search_surface.height * 0.5 ) * 1.0
		}
		//local keynumcol = (row == "- <~") ? 4 : 10
		local key_width = ( osd.width / row.len() ) * 1.0
		local key_height = ( osd.height / key_rows.len() ) * 1.0
		foreach ( char in row )
		{
			//local key_image = keys[ iii ]
			local key_image = keys[ char.tochar() ]
			local pos = {
				x = osd.x + ( key_width * col_count ),
				y = osd.y + key_height * row_count,
				w = key_width,
				h = key_height
			}
			key_image.set_pos( pos.x, pos.y, pos.w, pos.h )
			//print( "Key " + col_count + ": " + pos.x + "," + pos.y + " " + pos.w + "x" + pos.h );
			col_count++
		}
		row_count++
	}
}

draw_osd()
search_select (key_selected[0],key_selected[1])

search_surface.zorder = zordertop + 300

/// History Page  

local hist_split_h = 0.55

local hist_titleT = {
	x = flw*hist_split_h + 15*scalerate,
	y = 0+15*scalerate,
	w = flw*(1.0 - hist_split_h)-30*scalerate,
	h = flh*0.25-30*scalerate
}

local hist_screenT = {
	x = 0,
	y = (flh-flw*hist_split_h)*0.5,
	w = flw*hist_split_h,
	h = flw*hist_split_h
}

hist_screenT.y += hist_screenT.y % 2.0
hist_screenT.w += hist_screenT.w % 2.0
hist_screenT.h += hist_screenT.h % 2.0

if (hist_screenT.h > flh){
	hist_screenT.x = (flw*hist_split_h-flh)*0.5
	hist_screenT.y = 0
	hist_screenT.x += hist_screenT.x % 2.0
	hist_screenT.w = flh
	hist_screenT.w += hist_screenT.w % 2.0
	hist_screenT.h = flh
	hist_screenT.h += hist_screenT.h % 2.0
}

local hist_textT = {
	x = flw*hist_split_h,
	y = flh*0.25,
	w = flw*(1.0-hist_split_h),
	h = flh*0.75
}

if (vertical){
	hist_titleT.x = 0
	hist_titleT.y = flh*hist_split_h
	hist_titleT.w = flw
	hist_titleT.h = flh*(1.0 - hist_split_h)*0.3

	hist_screenT.x = (flw-flh*hist_split_h)*0.5
	hist_screenT.x += hist_screenT.x % 2.0
	hist_screenT.y = 0
	hist_screenT.w = flh*hist_split_h
	hist_screenT.w += hist_screenT.w % 2.0
	hist_screenT.h = flh*hist_split_h
	hist_screenT.h += hist_screenT.h % 2.0

	if (hist_screenT.w > flw){
		hist_screenT.x = 0
		hist_screenT.y = (hist_screenT.w - flw)*0.5
		hist_screenT.y += hist_screenT.y % 2.0
		hist_screenT.w = flw
		hist_screenT.w += hist_screenT.w % 2.0
		hist_screenT.h = flw
		hist_screenT.h += hist_screenT.h % 2.0
	}

	hist_textT.x = 0
	hist_textT.y = flh*hist_split_h + flh*(1.0 - hist_split_h)*0.3
	hist_textT.w = flw
	hist_textT.h = flh*(1.0 - hist_split_h)*0.7
}

local historypadding = (hist_screenT.w * 0.025)
historypadding += historypadding % 2.0

local hist_curr_rom = ""
local history_surface = fe.add_surface(flw,flh)
 
local hist_bg = history_surface.add_text ("",0,0,flw,flh)
hist_bg.set_bg_rgb(0,0,0)
hist_bg.bg_alpha = 120*0

local hist_title = history_surface.add_image ("transparent.png",hist_titleT.x,hist_titleT.y,hist_titleT.w,hist_titleT.h)
hist_title.preserve_aspect_ratio = true

local hist_black = null
local hist_g1 = null
local hist_g2 = null



if (!vertical){
	hist_black = history_surface.add_image("black.png",hist_screenT.x+historypadding,0,hist_screenT.w-2.0*historypadding,flh)
	hist_g1 = history_surface.add_image("wgradient2.png",hist_screenT.x+historypadding,0,hist_screenT.w-2.0*historypadding,flh*0.5) 
	hist_g2 = history_surface.add_image("wgradient.png",hist_screenT.x+historypadding,flh*0.5,hist_screenT.w-2.0*historypadding,flh*0.5)
}
else{
	hist_black = history_surface.add_image("black.png",0,hist_screenT.y+historypadding,flw,hist_screenT.h-2.0*historypadding)
	hist_g1 = history_surface.add_image("wgradient3.png",0,hist_screenT.y+historypadding,flw*0.5,hist_screenT.h-2.0*historypadding)
	hist_g2 = history_surface.add_image("wgradient4.png",flw*0.5,hist_screenT.y+historypadding,flw*0.5,hist_screenT.h-2.0*historypadding)
}

hist_black.set_rgb (0,0,0)
hist_g1.set_rgb (0,0,0)
hist_g2.set_rgb (0,0,0)

hist_g1.alpha = hist_g2.alpha = 200*0+150
hist_black.alpha = 80*0+50

local shader_cgwg = null;
shader_cgwg=fe.add_shader(Shader.VertexAndFragment,"CRT-geom_vsh.glsl","CRT-geom_fsh.glsl");
shader_cgwg.set_param("CRTgamma", 2.4);			// gamma of simulated CRT
shader_cgwg.set_param("monitorgamma", 2.2);		// gamma of display monitor (typically 2.2 is correct)
shader_cgwg.set_param("overscan", 1.0, 1.0);		// overscan (e.g. 1.02 for 2% overscan)
shader_cgwg.set_param("aspect", 1.0, 1.0);		// aspect ratio
shader_cgwg.set_param("d", 1.3);						// distance from viewer
shader_cgwg.set_param("R", 2.5);						// radius of curvature - 2.0 to 3.0?
shader_cgwg.set_param("cornersize", 0.05);		// size of curved corners
shader_cgwg.set_param("cornersmooth", 60);		// border smoothness parameter
shader_cgwg.set_param("brightmult", 1.25);
shader_cgwg.set_texture_param("texture");

local hist_screen_ar = hist_screenT.w * 1.0 / hist_screenT.h 

local hist_screensurf = history_surface.add_surface (hist_screenT.w-2.0*historypadding,hist_screenT.h-2.0*historypadding)
hist_screensurf.set_pos(hist_screenT.x+historypadding,hist_screenT.y+historypadding)

local hist_screen = hist_screensurf.add_image ("transparent.png",0,0,hist_screenT.w-2.0*historypadding,hist_screenT.h-2.0*historypadding)
hist_screen.preserve_aspect_ratio = true
if (!prf.AUDIOVIDHISTORY) hist_screen.video_flags = Vid.NoAudio
hist_screen.shader = shader_cgwg

local hist_text = history_surface.add_text( "", hist_textT.x, hist_textT.y, hist_textT.w, hist_textT.h )
hist_text.first_line_hint = 0
hist_text.charsize = 30*scalerate
hist_text.visible=true
hist_text.set_rgb(themetextcolor,themetextcolor,themetextcolor)

//local hist_temp = history_surface.add_image("black.png",hist_screenT.x+historypadding,hist_screenT.y+historypadding,hist_screenT.w-2.0*historypadding,hist_screenT.h-2.0*historypadding)
//hist_temp.alpha = 128

history_surface.visible = false
history_surface.alpha = 0
history_surface.zorder = zordertop + 400

function history_show()
{
	//if (prf.BGBLURRED == "") hist_bgblur.file_name = fe.get_art("blur")

	hist_title.file_name = fe.get_art ("wheel")
	hist_screen.file_name = fe.get_art ("snap")
	hist_screen.shader = shader_cgwg


	hist_screen.width = hist_screensurf.subimg_width;
	hist_screen.height = hist_screensurf.subimg_height;
	// Play with these settings to get a good final image
	hist_screen.shader.set_param("inputSize", hist_screensurf.width, hist_screensurf.height); // size of input
	hist_screen.shader.set_param("outputSize", hist_screensurf.width, hist_screensurf.height); // size of mask
	hist_screen.shader.set_param("textureSize", hist_screensurf.width, hist_screensurf.height);// size drawing to



	//shaderCRT.set_param("subimgsize", hist_screen.subimg_width, hist_screen.subimg_height)
	//shaderCRT.set_param("snapdimensions", width, width)


	local sys = split( fe.game_info( Info.System ), ";" )
	local rom = fe.game_info( Info.Name )

	//
	// we only go to the trouble of loading the entry if
	// it is not already currently loaded
	//
	if ( hist_curr_rom != rom )
	{
		hist_curr_rom = rom
		local alt = fe.game_info( Info.AltRomname )
		local cloneof = fe.game_info( Info.CloneOf )

		local lookup = get_history_offset( sys, rom, alt, cloneof )
		
		if ( lookup >= 0 )
		{
			//fe.overlay.splash_message(lookup + " " + my_config)
			hist_text.first_line_hint = 0
			try {
				hist_text.msg = get_history_entry( lookup, my_config )
				} catch ( err ) { hist_text.msg = "There was an error loading game data, please check history.dat preferences in the layout options"; }
		}
		else
		{
			if ( lookup == -2 )
				hist_text.msg = "Index file not found. Try generating an index from the history.dat plug-in configuration menu."
			else	
				hist_text.msg = "Unable to locate: "
					+ rom
		}
	}


	history_surface.visible=true
	historyflow = 1

}


function history_hide() {
	//history_surface.visible = false
	historyflow = -1
}

function history_visible() {
	return ((history_surface.visible) && (historyflow >= 0))
}

function on_scroll_up()
{
	hist_text.first_line_hint--
}

function on_scroll_down()
{
	hist_text.first_line_hint++
}

function history_exit (){
//	hist_title.file_name = "transparent.png"
//	hist_screen.file_name = "transparent.png"
	history_hide()
}


function cutlogo() {
	logoshow = 0
	fg_surface.alpha = 0
	data_surface.alpha = 255
	aflogo_surface.alpha = 0
}

function frostshaders (turnon){
		if (turnon){
			frost_pic.shader = flipshader
			frost_surf1.shader = frostshader1
			frost_surf2.shader = frostshader2
		}
		else{
			frost_pic.shader = noshader
			frost_surf1.shader = noshader
			frost_surf2.shader = noshader			
		}
}


/// FPS MONITOR  

/*
local monitor = fe.add_text ("",0,0,fe.layout.width,100)
monitor.set_bg_rgb (255,0,0)
monitor.charsize = 50
monitor.zorder = 20000

local monitor2 = fe.add_text ("",0,0,100,100)
monitor2.set_bg_rgb (255,0,0)

local tick000 = 0
local x0 = 0

fe.add_ticks_callback(this,"monitortick")

function monitortick(tick_time){

	monitor2.x ++
	if (monitor2.x - x0 == 10) {
		monitor.msg = 10000/(tick_time - tick000)
		tick000 = tick_time
		x0 = monitor2.x
	}
	if (monitor2.x >= fe.layout.width) {
		monitor2.x = 0
		x0 = 0
		tick000=0
	}
}
*/
fe.add_ticks_callback( this, "tick2" )

local timerscan = 10.0
local timerstep = 3

local flowspeed = 25

/// On Tick (2)  
function tick2( tick_time ) {


	if (grabdither != 0) {
		grabdither --
		frost_surface.x = grabdither
	}

	if (grabticker != 0)
	{
		grabticker --
		if (grabticker == 0){
		rename (grabpath0,grabpath)
		frost_pic.file_name = grabpath
		if (rotate90){
				
		}
		immediatesignal = true
		fe.signal(grabsignal)
		}

	}

	if ((overmenu.visible) && (overmenuflow >= 0) && (surfacePos != 0)) {
		overmenu.x = globalposnew + selectorwidth * 0.5 - overmenuwidth*0.5 
	}

	if (titlestart){
		name_x.msg = gamenamex ( name_x.index_offset,titleswitch - 1)
		namesh_x.msg = gamenamex ( name_x.index_offset,titleswitch - 1)
		name_x2.msg = gamenamex ( name_x.index_offset,titleswitch)
		namesh_x2.msg = gamenamex ( name_x.index_offset,titleswitch)
		
		name_x2.x = 0
		namesh_x2.x = 3
		scrollincrement = 0

		titlecrossfade = 0
		name_x.alpha = 0
		namesh_x.alpha = 0
		name_x2.alpha = 255
		namesh_x2.alpha = themeshadow
		titlestart = false

		if (gamenames (name_x.index_offset) > 1) 
			titleroll = true
		else
			titleroll = false

		if (name_x2.msg_width > flw - rightdata) 
			titlescroll = true
		else
			titlescroll = false
	}

	if ((titleroll) && (tick_time - titlezero >= titlewait)) {
		//print("tick time:" + tick_time + " title zero:" + titlezero + " \n")	
		titleswitch ++
		name_x.msg = gamenamex ( name_x.index_offset,titleswitch - 1)
		namesh_x.msg = gamenamex ( name_x.index_offset,titleswitch - 1)
		name_x2.msg = gamenamex ( name_x.index_offset,titleswitch)
		namesh_x2.msg = gamenamex ( name_x.index_offset,titleswitch)
		
		name_x2.x =0
		namesh_x2.x =3

		if (name_x2.msg_width > flw - rightdata) 
			titlescroll = true
		else
			titlescroll = false

		scrollincrement = 0
		titlezero = tick_time
		titlezero2 = tick_time
		titlecrossfade = 1
	}


	if (titlecrossfade >= 0){
		name_x.alpha = titlecrossfade * 255
		namesh_x.alpha = titlecrossfade * themeshadow
		name_x2.alpha = (1 - titlecrossfade) * 255
		namesh_x2.alpha = (1 - titlecrossfade)*themeshadow
		titlecrossfade -= 0.05
	}

	local deltastep = floor((name_x2.msg_width - flw + rightdata + 50*scalerate)*1.1)

	if (titlescroll){
		
		scrollincrement = tick_time - titlezero2

		if (scrollincrement > (scrollwait*2+scrollmove*2)) titlezero2 = tick_time

		if ((scrollincrement >= scrollwait) && (scrollincrement <= (scrollwait + scrollmove)))
		{
			name_x2.x = - deltastep * (scrollincrement - scrollwait)/scrollmove
			namesh_x2.x = 3 + name_x2.x
		}
		if ((scrollincrement >= (scrollwait+scrollmove+scrollwait)) && (scrollincrement <= (scrollwait+scrollmove+scrollwait+scrollmove)))
		{
			name_x2.x = - deltastep * ((scrollwait+scrollmove+scrollwait+scrollmove) - scrollincrement)/scrollmove
			namesh_x2.x = 3 + name_x2.x
		}
	}


	if (overmenuflow > 0) {
		if (overmenu.alpha < 255-flowspeed) overmenu.alpha = overmenu.alpha + flowspeed
		else {
			overmenu.alpha = 255
			overmenuflow = 0
			}
	}

	if (overmenuflow < 0) {
		if (overmenu.alpha > flowspeed) overmenu.alpha = overmenu.alpha - flowspeed
		else {
			overmenuflow = 0
			overmenu.alpha = 0
			overmenu.visible = false
		}
	}

	if (historyflow > 0) {
		if (history_surface.alpha < 255-flowspeed) {
			history_surface.alpha = history_surface.alpha + flowspeed
			fg_surface.alpha = history_surface.alpha
			data_surface.alpha = 255-fg_surface.alpha
		}
		else {
			history_surface.alpha = 255
			fg_surface.alpha = 255
			data_surface.alpha = 255-fg_surface.alpha
			historyflow = 0
			}
	}
	if (historyflow < 0) {
		if (history_surface.alpha > flowspeed) {
			history_surface.alpha = history_surface.alpha - flowspeed
			if(!overlay_listbox.visible) fg_surface.alpha = history_surface.alpha
			data_surface.alpha = 255-history_surface.alpha
		}
		else {
			historyflow = 0
			hist_title.file_name = "transparent.png"
			hist_screen.file_name = "transparent.png"
			hist_screen.shader = noshader
			history_surface.alpha = 0
			if(!overlay_listbox.visible) fg_surface.alpha = 0
			data_surface.alpha = 255-history_surface.alpha
			history_surface.visible = false
		}
	}


	if (logoshow !=0){
		logoshow = logoshow - 0.018	
		if (logoshow < 0.01) {
			logoshow = 0
			aflogo_surface.visible = false
		}
		/*afsplash.alpha = 255*(1-pow((1-logoshow),3))
		aflogo.alpha = 255*(1-pow((1-logoshow),3))
		afwhitebg.bg_alpha = themeoverlayalpha*(1-pow((1-logoshow),3))*/
		if (prf.SPLASHON) {
			aflogo_surface.alpha = 255*(1-pow((1-logoshow),3))
			if((!overlay_listbox.visible) && (!history_visible())) fg_surface.alpha = aflogo_surface.alpha
			data_surface.alpha = 255-aflogo_surface.alpha
		}
		else
		{
			aflogo_surface.alpha = 0
			if((!overlay_listbox.visible) && (!history_visible())) fg_surface.alpha = aflogo_surface.alpha
			data_surface.alpha = 255-aflogo_surface.alpha			
		}
	}
	
}
