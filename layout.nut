// Arcadeflow - v 1.6
// Attract Mode Theme by zpaolo11x
//
// Based on carrier.nut scrolling module by Radek Dutkiewicz (oomek)
// Including code from the KeyboardSearch plugin by Andrew Mickelson (mickelson)

class UserConfig </ help="" />{
	</ label="Theme Color", help="Setup theme color", options="Default, Dark, Light, Pop", order=1 /> colortheme="Default"
	</ label="Blurred Logo Shadow", help="Use blurred logo artwork shadow", options="Yes, No", order=2 /> logoblurred="Yes"
	</ label="Enable New Game Indicator", help="Games not played are marked with a glyph", options="Yes, No", order=3 /> newgame = "Yes"
	</ label="Custom Background Image", help="Insert custom background art path", order=4 /> bgblurred=""
	</ label="Search string entry method", help="Use keyboard or on-screen keys to enter search string", options="Keyboard, Screen keys", order=5 /> searchmeth = "Screen keys"
	</ label="Immediate search", help="Live update results while searching", options="Yes, No", order=6 /> livesearch = "Yes"
	</ label="Enable AF splash logo", help="Enable or disable the AF start logo", options="Yes, No",order = 7/> splashlogo = "Yes"
	</ label="Vertical rows", help = "Number of rows to use in 'vertical' mode", otions="2, 3", order = 8 /> verticalrows = "3"
}


local keyboard = false

local backindex = -1
local backcorrector = -1

local search_base_rule = "Title"

local my_config = fe.get_config()

local colortheme = my_config["colortheme"]
local logoblurred_in = my_config["logoblurred"]
local bgblurred = my_config["bgblurred"]
local newgame_in = my_config["newgame"]
local keyboard_in = my_config["searchmeth"]
local livesearch_in = my_config["livesearch"]
local splashlogo_in = my_config["splashlogo"]
local verticalrows_in = my_config["verticalrows"]

local LOGOBLURRED = true
local NEWGAME = true
local LIVESRC = false
local SPLASHON = true
local rows_vertical = 3

if (verticalrows_in == "2")
	rows_vertical = 2
else
	rows_vertical = 3

if (splashlogo_in == "Yes") 
	SPLASHON = true 
else 
	SPLASHON = false

if (livesearch_in == "Yes") 
	LIVESRC = true 
else 
	LIVESRC = false

if (logoblurred_in == "Yes") 
	LOGOBLURRED = true 
else 
	LOGOBLURRED = false

if (newgame_in == "Yes") 
	NEWGAME = true 
else 
	NEWGAME = false

if (keyboard_in == "Keyboard") 
	keyboard = true 
else 
	keyboard = false

local themeoverlaycolor = 255
local themeoverlayalpha = 80
local themetextcolor = 255
local themeshadow = 50

if (colortheme == "Default"){
	themeoverlaycolor = 255
	themeoverlayalpha = 80
	themetextcolor = 255
	themeshadow = 50
}
if (colortheme == "Dark"){
	themeoverlaycolor = 0
	themeoverlayalpha = 110
	themetextcolor = 220
	themeshadow = 50
}
if (colortheme == "Light"){
	themeoverlaycolor = 255
	themeoverlayalpha = 190
	themetextcolor = 100
	themeshadow = 0
}
if (colortheme == "Pop"){
	themeoverlaycolor = 255
	themeoverlayalpha = 0
	themetextcolor = 255
	themeshadow = 50
}


function round(x, y) {
	return (x.tofloat()/y+(x>0?0.5:-0.5)).tointeger()*y
}

local ticksound = fe.add_sound("mouse3.mp3")
local wooshsound = fe.add_sound("woosh4.mp3")

// parameters for slowing down key repeat on left-right scrolling
local rightcount = 0
local leftcount = 0
local movecount = 3

// layout preferences
local rows = 2
local vertical = false
local logoshow = 1

// customized parameters for Mac users
local MAC = 0
if (OS == "OSX") MAC = 1

local guifont ="Roboto-Allcaps.ttf"
local scrolltitle = 2
local scrollincrement = 0

local scrw = ScreenWidth
local scrh = ScreenHeight
//scrw = 240
//scrh = 320

//screen layout definition
local flw = scrw
local flh = scrh

if ((flw < flh) && (fe.layout.toggle_rotation == RotateScreen.None)) vertical = true
if ((flw > flh) && (fe.layout.toggle_rotation != RotateScreen.None)) {
	vertical = true
	flw = scrh
	flh = scrw
}

if (vertical) rows = rows_vertical

local shrinker = 1
if (vertical) shrinker = 1

fe.layout.width = flw
fe.layout.height = flh
fe.layout.preserve_aspect_ratio = true
fe.layout.page_size = rows
fe.layout.font ="Roboto-Bold.ttf"

local scalerate = flh/1200.0
if (vertical) scalerate = flw/1200.0

local header_h = 200*scalerate*shrinker
local footer_h = 100*scalerate*shrinker

// scaling factor for middle separation
local margin_scaler = 1.0

// multiplier of padding space (normally 1/6 of thumb area)
local padding_scaler = 1/6.0

local height = (flh-header_h-footer_h)/(rows+rows*padding_scaler+margin_scaler*padding_scaler)
local width = height

local padding = height*padding_scaler
local widthpadded = width + 2*padding
local heightpadded = height + 2*padding
local bottompadding = padding

local verticalshift = height*(16.0)/480.0

//calculate number of columns
local cols = (1+2*(floor((flw/2+width/2-padding)/(height+padding))))
// add safeguard tiles
cols +=2

// carrier sizing in general layout
local carrier_w = cols*(height+padding)+padding
local carrier_h = rows*height+(rows)*padding+padding*margin_scaler
local carrier_x = -(carrier_w-flw)/2
local carrier_y = header_h+0*(flh-carrier_h)/2

// selector and zooming data
local selectorscale = 1.5
local whitemargin = 0.15
local selectorwidth = selectorscale*widthpadded
local selectoroffseth = (selectorwidth - widthpadded)*0.5
local selectoroffsetv = (selectorwidth - widthpadded-verticalshift)*0.5

local deltacol = (cols -3)/2
local centercorrection0 = -deltacol*(width+padding) -(flw - (carrier_w-2*(width+padding)))/2 -padding *(1+selectorscale*0.5) - width/2 + selectorwidth/2
local centercorrection = 0
local centercorrectionshift = centercorrection0


// transitions speeds
local scrollspeed = 0.9
local zoomspeed = 0.7
local fadespeed = 0.8
local letterspeed = 0.75

if (MAC == 1){
	scrollspeed = 0.92
	zoomspeed = 0.87
	fadespeed = 0.88
	letterspeed = 0.85
}

// Letter and scroller sizes
local lettersize = 250*scalerate

local footermargin = 200*scalerate
local scrollersize = 30*scalerate

// Blurred backdrop definition
local bgx = 0
local bgy = (flh-flw)/2
local bgw = flw

if (vertical){
	bgx = (flw-flh)/2
	bgy = 0
	bgw = flh
}

// parameters for changing scroll jump spacing
local scrolljump = false
local scrollstep = rows


local key_names = { "a": "a", "b": "b", "c": "c", "d": "d", "e": "e", "f": "f", "g": "g", "h": "h", "i": "i", "j": "j", "k": "k", "l": "l", "m": "m", "n": "n", "o": "o", "p": "p", "q": "q", "r": "r", "s": "s", "t": "t", "u": "u", "v": "v", "w": "w", "x": "x", "y": "y", "z": "z", "1": "Num1", "2": "Num2", "3": "Num3", "4": "Num4", "5": "Num5", "6": "Num6", "7": "Num7", "8": "Num8", "9": "Num9", "0": "Num0", "<": "Backspace", " ": "Space", "-": "Clear", "~": "Done","_":"Nope" }
local key_rows =  ["abcdefghi123", "jklmnopqr456", "stuvwxyz_789", "- <0","~"]
if (vertical)
	key_rows = ["1234567890","abcdefghij","klmnopqrst","uvwxyz____","- <","~"]
local key_selected = [0,0]
local s_text = ""


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
	namezTable = []
	
	tilesTablePosX = []
	tilesTablePosY = []
	tilesTableOffset = 0
	surfacePosOffset = 0
	
	surfacePos = 0
	surface = null
	selector = null
	tilesTotal = 0
	tilesOffscreen = 0
	favorite = null
	completed = null
	corrector = 0
	newfocusindex = 0
	oldfocusindex = 0
	scroller = null
	scroller2 = null
	scrollineglow = null
	searchdata = null

	tilesCount = 0
	surfaceVertOffset = 0
	surfaceHoriOffset = 0
	changedfav = false
	changedtag = false
	launchgame = false
	startupper = true
	selectorsnap = null
	selectorgrad = null
	selectorlogo = null
	selectorfave = null
	selectordone = null
	snapbg1 = null
	snapbg2 = null
	snapbg3 = null
	snapbg4 = null
	alphapos = 0
	zoompos = 0
	zoomunpos = 0
	vidpos = 0
	fadeletter = 0
	sh_h = null
	sh_v = null
	nw_h = null
	nw_v = null
	letter1 = null
	letter2 = null
	searchtext = ""
	videosnap = null
	videosnapsurf = null
	videoshadow = null
	bgpicture2 = null
	bgpicture = null

	constructor() {
		
		tilesCount = cols * rows
		tilesOffscreen = 4 * rows
		if (vertical) tilesOffscreen = 3 * rows
		
		tilesTotal = tilesCount + 2*tilesOffscreen
		surfacePosOffset = (tilesOffscreen/rows) * (height+padding)
		surfaceVertOffset = carrier_y
		surfaceHoriOffset = carrier_x
		
		local shadeval = 255
		
		snapbg1 = fe.add_artwork("blur",bgx,bgy,bgw,bgw)
		snapbg1.set_rgb (shadeval,shadeval,shadeval)
		snapbg1.alpha = 255
		snapbg1.trigger = Transition.EndNavigation
		snapbg1.zorder = 10
		
		snapbg2 = fe.add_artwork("blur",bgx,bgy,bgw,bgw)
		snapbg2.set_rgb (shadeval,shadeval,shadeval)
		snapbg2.alpha = 255
		snapbg2.trigger = Transition.EndNavigation
		snapbg2.zorder = 11

		if (bgblurred != ""){
			bgpicture = fe.add_image(bgblurred,0,0,flw,flh)
			bgpicture.zorder=12
		}

		local whitebg = fe.add_text("",0,0,flw,flh)
		whitebg.set_bg_rgb(themeoverlaycolor,themeoverlaycolor,themeoverlaycolor)
		whitebg.bg_alpha = themeoverlayalpha
		whitebg.zorder = 13


		local prescaler = selectorscale
		
		for ( local i = 0; i < tilesTotal; i++ ) {
			local obj = fe.add_surface(widthpadded*prescaler,heightpadded*prescaler)
			local sh_hz = obj.add_image ("sh_h_4.png",0,0,widthpadded*prescaler,heightpadded*prescaler)
			local sh_vz = obj.add_image ("sh_v_4.png",0,0,widthpadded*prescaler,heightpadded*prescaler)
			sh_hz.alpha = sh_vz.alpha = 240
			local bd_hz = obj.add_text ("",prescaler*padding*(1.0-whitemargin),prescaler*(-verticalshift + height/8.0 + padding*(1.0 - whitemargin)),prescaler*(width + padding*2*whitemargin),prescaler*(height*(3/4.0)+padding*2*whitemargin))
			bd_hz.set_bg_rgb (255,255,255)
			bd_hz.bg_alpha = 240
			bd_hz.visible = false
			local bd_vz = obj.add_text ("",prescaler*(width/8.0 + padding*(1.0 - whitemargin)), prescaler*(-verticalshift + padding*(1.0 - whitemargin)),prescaler*(width*(3/4.0)+padding*2*whitemargin),prescaler*(height + padding*2*whitemargin))
			bd_vz.set_bg_rgb (255,255,255)
			bd_vz.bg_alpha = 240
			bd_vz.visible = false
			local snapz = obj.add_artwork("snap",prescaler*padding,prescaler*(padding-verticalshift),prescaler*width,prescaler*height)
			snapz.preserve_aspect_ratio = true
			snapz.video_flags = Vid.ImagesOnly
			
			local vidsz = obj.add_image("transparent.png",prescaler*padding,prescaler*(padding-verticalshift),prescaler*width,prescaler*height)
			vidsz.preserve_aspect_ratio = true
			vidsz.visible = false
			vidsz.video_flags = Vid.NoAudio
			
			local nw_hz = obj.add_image ("nw_h.png",prescaler*padding,prescaler*(padding-verticalshift),width*prescaler,height*prescaler)
			local nw_vz = obj.add_image ("nw_v.png",prescaler*padding,prescaler*(padding-verticalshift),width*prescaler,height*prescaler)
			nw_hz.visible = false
			nw_vz.visible = false
			
			if (NEWGAME == true) {
				nw_hz.alpha = 220
				nw_vz.alpha = 220
			}
			else{
				nw_hz.alpha = 0
				nw_vz.alpha = 0				
			}

			local namez = obj.add_text("",padding*prescaler,prescaler*(padding-verticalshift),width*prescaler,height*prescaler)
			namez.set_bg_rgb (0,0,0)
			namez.set_rgb (255,255,255)
			namez.bg_alpha = 255*0
			namez.charsize = height*1/12.0
			namez.word_wrap = true
			namez.alpha = 255*0
			
			local donez = obj.add_image("completed.png",prescaler*padding,prescaler*(padding-verticalshift),prescaler*width*0.8,prescaler*height*0.8)
			donez.visible = false
			donez.preserve_aspect_ratio = false
			local favez = obj.add_image("starred.png",prescaler*(padding+width/2),prescaler*(padding+height/2-verticalshift),prescaler*width/2,prescaler*height/2)

			local loshz = null
			local logoz = null

			if (LOGOBLURRED == true){
				loshz = obj.add_artwork ("logoblur",prescaler*padding*0.5,prescaler*(padding*0.4*0.5-verticalshift),prescaler*(width+padding),prescaler*(height*0.5+padding))
				loshz.alpha = 150

				logoz = obj.add_artwork ("wheel",prescaler*padding,prescaler*(padding*0.6-verticalshift),prescaler*width,prescaler*height*0.5)
				logoz.preserve_aspect_ratio = true
			}
			else if (LOGOBLURRED == false){
				loshz = obj.add_artwork ("wheel",prescaler*padding,prescaler*(padding*0.6-verticalshift),prescaler*width,prescaler*height*0.5)
				loshz.preserve_aspect_ratio = true

				logoz = obj.add_clone (loshz)	
				loshz.set_rgb(0,0,0)

				loshz.set_pos(loshz.x+prescaler*3*scalerate,loshz.y+prescaler*6*scalerate)			
				loshz.alpha = 120

			}
				
			tilesTablePosX.push((width+padding) * (i/rows)  + padding)
			tilesTablePosY.push((width+padding) * (i%rows)  + padding*margin_scaler + surfaceVertOffset + verticalshift)
			
			favez.visible = false
			favez.preserve_aspect_ratio = false
			
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
			namezTable.push (namez)
		}
		
		// fading letter
		letter2 = fe.add_text("[!gameletter]",0,carrier_y+carrier_h*0.5-lettersize*0.5,flw,lettersize)
		letter2.alpha = 0
		letter2.charsize = lettersize
		letter2.font = guifont
		letter2.set_rgb(themetextcolor,themetextcolor,themetextcolor)
		
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

		// large video preview definition		
		local vid_w = (flh - header_h - footer_h)*1.1
		local vid_h = vid_w
		
		if (vertical){
			vid_w = (flw)*0.9
			vid_h = vid_w	
		}
		
		local vid_x = (flw-vid_w)*0.5
		local vid_y = (flh-vid_h)*0.5
		local padratio = 1/6.0
		
		
		
		videosnapsurf = fe.add_surface(flw,flh)
		videoshadow = videosnapsurf.add_image("transparent.png",vid_x-vid_w*padratio,vid_y-vid_h*padratio,vid_w*(1+2*padratio),vid_h*(1+2*padratio))
		videosnap = videosnapsurf.add_image("transparent.png",vid_x,vid_y,vid_w,vid_h)
		videosnap.preserve_aspect_ratio = true
		videosnapsurf.visible = false
		
		// menu smooth background generation
		local satinrate = 0.9

		if (bgblurred == ""){
			snapbg3 = fe.add_clone (snapbg2)
		}
		else{
			snapbg3 = fe.add_image(bgblurred,0,0,flw,flh)
		}

		snapbg3.alpha = 255*satinrate
		snapbg4 = fe.add_text("",0,0,flw,flh)
		snapbg4.set_bg_rgb(themeoverlaycolor,themeoverlaycolor,themeoverlaycolor)
		snapbg4.bg_alpha = themeoverlayalpha*satinrate
		snapbg4.visible = false
		snapbg3.visible = false



		surfacePos = 0.5
		
		::fe.add_transition_callback( this, "on_transition" )
		::fe.add_ticks_callback( this, "tick" )
		::fe.add_signal_handler( this, "on_signal" )
		
	}
	
	function recalculate( str )
    {
        if ( str.len() == 0 ) return ""
        str = str.tolower()
        local words = split( str, " " )

        local temp=""
        foreach ( idx, w in words )
        {
            //print("searching: " + w )
            //if ( idx > 0 ) temp += " "
            //foreach( c in w )
            //    if ( c != " " ) temp += ( "1234567890".find(c.tochar()) != null ) ? c.tochar() : "[" + c.tochar().toupper() + c.tochar().tolower() + "]"
            if ( temp.len() > 0 )
                temp += " "
            local f = w.slice( 0, 1 )
            temp += ( "1234567890".find(f) != null ) ? "[" + f + "]" + w.slice(1) : "[" + f.toupper() + f.tolower() + "]" + w.slice(1)
        }

        return temp
    }
	
	function on_transition( ttype, var, ttime ) {

		// scroller is always updated		
		if ((ttype == Transition.ToNewSelection) || (ttype == Transition.StartLayout)) {
			scroller.x = footermargin + (((fe.list.index+var)/rows)/((fe.list.size*1.0)/rows-1))*(flw-2*footermargin-scrollersize)
			scroller2.x = scroller.x-scrollersize*0.5
			scrolltitle = 2
			scrollincrement = 0
		}
		

		// since the EndNavigation transition is fired many times I don't want the zoom/unzoom to take place in that case
		if ((ttype != Transition.EndNavigation) && (ttype != Transition.NewSelOverlay) ) {
			zoompos = 1
			
			// If we are not transitioning to a new list, starting the layout or hiding the overlay old tile is faded out
			if ((ttype!=Transition.ToNewList)&&(ttype!=Transition.StartLayout)&&(ttype!=Transition.HideOverlay)) {
				tilesTable[oldfocusindex].width = widthpadded
				tilesTable[oldfocusindex].height = heightpadded
				tilesTable[oldfocusindex].zorder = 7
				bd_hzTable[oldfocusindex].visible = bd_vzTable[oldfocusindex].visible = false
				vidszTable[oldfocusindex].visible = false
				//vidszTable[oldfocusindex].file_name = "transparent.png"
				
				zoomunpos = 1
			}
		}
		
		if ( ( ttype == Transition.ToNewList ) || ( ttype == Transition.ToNewSelection ) || (ttype == Transition.FromGame) || (ttype == Transition.StartLayout))
		{
			//zoompos = 1
			vidpos = 1


			// calculate wether the selector is on the first or second row, var is not zero
			if (ttype == Transition.ToNewSelection){
				corrector = -((fe.list.index + var) % rows)
			}
			
			// when transitioning to a new list, move to the first item of the list,
			// unless we are changing favourites or we are starting the layout
			
			/*
			if ((ttype == Transition.ToNewList) && (changedfav == false) && (startupper == false)){
				//fe.list.index = 0
				//corrector = 0
				
			}
			//else if ((ttype == Transition.ToNewList) && ((changedfav == true) || (startupper == true)))
			else {
				//changedfav = false
				startupper = false
			}
			*/

			// correction of the row position when starting the layout or going to a new list (when var is undefined)
			if ((ttype == Transition.StartLayout) || (ttype == Transition.ToNewList) ) {
				corrector = -((fe.list.index) % rows)
				var = 0
			}

			local index = - (floor(tilesTotal/2) -1) + corrector
			
			if ((ttype == Transition.ToNewSelection)||(ttype==Transition.StartLayout)||(ttype == Transition.ToNewList)) {
				//if (ttype == Transition.ToNewSelection) 
			   	tilesTableOffset += (var/rows)*rows
				//else
				//	tilesTableOffset = 0

				
				
				if ((fe.list.index + var < deltacol*rows) && (var < 0) ) {
					if ((fe.list.index+var)/rows == deltacol - 1 ) centercorrectionshift = centercorrection0 + (deltacol - 1)*(width+padding)
					else  centercorrectionshift = - (width+padding)
				}
				else if ((fe.list.index  < deltacol*rows) && (var > 0))  {
					if ((fe.list.index)/rows == deltacol - 1 ) centercorrectionshift = -centercorrection0 - (deltacol - 1)* (width+padding)
					else  centercorrectionshift =  (width+padding)
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
				
				if ((var == 1) || (var == -1) || (var == 0)) centercorrectionshift = 0
				
				
			}
			
			// updates all the tiles, unless we are changing favourites
			if (changedfav == false){
				
				for ( local i = 0; i < tilesTotal ; i++ ) {
					
					local indexTemp = wrap( i + tilesTableOffset, tilesTotal )
					
					snapzTable[indexTemp].rawset_index_offset(index)
					loshzTable[indexTemp].rawset_index_offset(index)
					logozTable[indexTemp].rawset_index_offset(index)
				
					namezTable[indexTemp].msg = gamename(index + var )
					//namezTable[indexTemp].msg = (snapzTable[indexTemp].texture_width > snapzTable[indexTemp].texture_height)

					tilesTable[indexTemp].zorder = 7
					
					local m = fe.game_info(Info.Favourite, snapzTable[indexTemp].index_offset+var)
					if (m == "1")
						favezTable[indexTemp].visible = true
					else
						favezTable[indexTemp].visible = false
					
					local m = fe.game_info(Info.Tags, snapzTable[indexTemp].index_offset+var)
					if (m.find("Completed") != null)
						donezTable[indexTemp].visible = true
					else
						donezTable[indexTemp].visible = false
					


					//local m = fe.game_info(Info.Rotation, snapzTable[indexTemp].index_offset+var)
					local m = (snapzTable[indexTemp].texture_width > snapzTable[indexTemp].texture_height)
					local m2 = fe.game_info(Info.PlayedCount,  snapzTable[indexTemp].index_offset+var)
					if (m){
						sh_hzTable[indexTemp].visible = true
						sh_vzTable[indexTemp].visible = false
						nw_vzTable[indexTemp].visible = false
						if (m2 == "0") 
							nw_hzTable[indexTemp].visible = true
						else
							nw_hzTable[indexTemp].visible = false
						
					}
					else {
						sh_hzTable[indexTemp].visible = false
						sh_vzTable[indexTemp].visible = true
						nw_hzTable[indexTemp].visible = false
						if (m2 == "0") 
							nw_vzTable[indexTemp].visible = true
						else
							nw_vzTable[indexTemp].visible = false
					}
					
					tilesTablePosX[indexTemp] = (i/rows) * (width+padding) + carrier_x + centercorrection
					tilesTablePosY[indexTemp] = (i%rows) * (height + padding * margin_scaler) + surfaceVertOffset + verticalshift
					
					if( (fe.list.index + var + index < 0) || (fe.list.index + var + index > fe.list.size-1) ){
						tilesTable[indexTemp].visible = false
					}
					else {
						tilesTable[indexTemp].visible = true
					}
					
					// if tranisioning to a new list, reset position and size of all thumbnails, not needed in normal scroll
					if (ttype == Transition.ToNewList){
						//fe.overlay.splash_message("P")
						vidszTable[indexTemp].visible = false
						vidszTable[indexTemp].file_name = "transparent.png"
						tilesTable[indexTemp].width = widthpadded
						tilesTable[indexTemp].height = heightpadded
						tilesTable[indexTemp].zorder = 7
						bd_hzTable[indexTemp].visible = bd_vzTable[indexTemp].visible = false
					}
					
					index++
				}
			}
			else {
				changedfav = false
			}
			
			// updates the size and features of the previously selected item and new selected item
			newfocusindex = wrap( tilesTotal/2-1-corrector + tilesTableOffset, tilesTotal )
			oldfocusindex = wrap( tilesTotal/2-1-corrector -var + tilesTableOffset, tilesTotal )
			
			tilesTable[oldfocusindex].width = widthpadded
			tilesTable[oldfocusindex].height = heightpadded
			tilesTable[oldfocusindex].zorder = 7
			bd_hzTable[oldfocusindex].visible = bd_vzTable[oldfocusindex].visible = false
			
			tilesTable[newfocusindex].zorder = 25

			vidszTable[oldfocusindex].visible = false
			vidszTable[oldfocusindex].file_name = "transparent.png"
			
			
			local m = fe.game_info(Info.Favourite, snapzTable[newfocusindex].index_offset+var)
			if (m == "1")
				favezTable[newfocusindex].visible = true
			else
				favezTable[newfocusindex].visible = false
			
			local m = fe.game_info(Info.Tags, snapzTable[newfocusindex].index_offset+var)
			if (m.find("Completed") != null)
				donezTable[newfocusindex].visible = true
			else
				donezTable[newfocusindex].visible = false
			
			
			//local m = fe.game_info(Info.Rotation, snapzTable[newfocusindex].index_offset+var)
			local m = (snapzTable[newfocusindex].texture_width > snapzTable[newfocusindex].texture_height)
			local m2 = fe.game_info(Info.PlayedCount,  snapzTable[newfocusindex].index_offset+var)

			if (m){
				bd_hzTable[newfocusindex].visible = true
				bd_vzTable[newfocusindex].visible = false
				nw_vzTable[newfocusindex].visible = false
						if (m2 == "0") 
							nw_hzTable[newfocusindex].visible = true
						else
							nw_hzTable[newfocusindex].visible = false
			}
			else {
				bd_hzTable[newfocusindex].visible = false
				bd_vzTable[newfocusindex].visible = true
				nw_hzTable[newfocusindex].visible = false
						if (m2 == "0") 
							nw_vzTable[newfocusindex].visible = true
						else
							nw_vzTable[newfocusindex].visible = false
			}
			
		}
		
		
		if (ttype == Transition.ToNewList){
			surfacePos = 0.5
		}

		// if the transition is to a new selection initialize zooming, scrolling and surfacepos
		if( ttype == Transition.ToNewSelection )
		{
			snapbg1.rawset_index_offset (-var)
			
			local l1 = gameletter (0)
			local l2 = gameletter(var)
			
			if (l1 != l2){
				fadeletter = 1
			}
			alphapos=255
			
			surfacePos += ((var/rows) * (width + padding) ) - centercorrectionshift
			
			//if ((var == 1) && (corrector == 0)) surfacePos += (width + padding)
			//if ((var == -1) && (corrector == 1-rows)) surfacePos -= (width + padding)
			
			//return false
			
		}
		
		return false
	}
	
	function tick( tick_time ) {
		
		if ((rightcount != 0) && (fe.get_input_state("right")==false)){
			rightcount = 0
		}
		
		if ((leftcount != 0) && (fe.get_input_state("left")==false)){
			leftcount = 0
		}
		
		// crossfade of the blurred background
		if (alphapos !=0){
			if (alphapos < 0.1 && alphapos > -0.1 ) alphapos = 0
			alphapos = alphapos * fadespeed
			snapbg2.alpha = 255-alphapos
		}
		
		// fading of the initial letter of the name
		if (fadeletter != 0){
			if(fadeletter < 0.01) fadeletter = 0
			fadeletter = fadeletter * letterspeed
			letter2.alpha = 255*(1-4.0*pow((0.5-fadeletter),2))
		}
		
		
		
		// contemporary scrolling of tiles and zooming of selected tile
		if ((surfacePos != 0)||(zoompos !=0)||(zoomunpos!=0)) {
			if (zoompos == 1){
				newfocusindex = wrap( tilesTotal/2-1-corrector + tilesTableOffset, tilesTotal )
				
				// Useful check to update "Completed" tag when changing tags
				local m = fe.game_info(Info.Tags, snapzTable[newfocusindex].index_offset)
				if (m.find("Completed") != null)
					donezTable[newfocusindex].visible = true
				else
					donezTable[newfocusindex].visible = false
				
			}
			if ((surfacePos < 0.1) && (surfacePos > -0.1)) surfacePos = 0
			if ((zoompos < 0.01) && (zoompos > -0.01 )) zoompos = 0
			if ((zoomunpos < 0.01) && (zoomunpos > -0.01 )) zoomunpos = 0
			
			
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
			tilesTable[newfocusindex].y =  tilesTablePosY[newfocusindex] - ((selectoroffsetv)*(1-zoompos)) 
			tilesTable[newfocusindex].width = widthpadded + (selectorwidth-widthpadded)*(1.0-zoompos)
			tilesTable[newfocusindex].height = heightpadded + (selectorwidth-heightpadded)*(1.0-zoompos)
			//tilesTable[newfocusindex].zorder = 25
			
			if (oldfocusindex != newfocusindex){
				tilesTable[oldfocusindex].x = surfacePos - surfacePosOffset + tilesTablePosX[oldfocusindex] - (selectoroffseth*(zoomunpos))
				tilesTable[oldfocusindex].y =  tilesTablePosY[oldfocusindex] - ((selectoroffsetv)*(zoomunpos)) 
				tilesTable[oldfocusindex].width = widthpadded + (selectorwidth-widthpadded)*(zoomunpos)
				tilesTable[oldfocusindex].height = heightpadded + (selectorwidth-heightpadded)*(zoomunpos)
			}
		}
		
		// crossfade of video snaps, tailored to skip initian fade in
		if (( vidpos != 0 )) {
			
			vidpos = vidpos - 0.01
			if (vidpos < 0.01) vidpos = 0
			newfocusindex = wrap( tilesTotal/2-1-corrector + tilesTableOffset, tilesTotal )
			local delayvid = 0.4
			local fadevid = 0.2
			if ((vidpos < delayvid) && (vidpos > delayvid - 0.01)){
				vidszTable[newfocusindex].visible = true
				vidszTable[newfocusindex].file_name = fe.get_art("snap")
				vidszTable[newfocusindex].alpha = 0		
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
	
	// updates the video preview surface according to orientation
	function updatesurf(){
		
		local m = (snapzTable[newfocusindex].texture_width > snapzTable[newfocusindex].texture_height)
		videosnap.file_name = fe.get_art("snap")
		if (m) {
			videoshadow.file_name = "sh_h.png"
		}
		else  {
			videoshadow.file_name = "sh_v.png"
		}
	}
	
	function on_signal( sig )
	{
		

		if (search_visible())
		{
			if (sig == "custom3")
				search_toggle()
			else if ( sig == "up" ) {
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
			else if ( sig == "back" ) if ( text.len() == 0 ) toggle() else search_type("<")
			else if ( sig == "exit" ) toggle()
			return true
		}

		else {

		switch ( sig )
		{
			
			case "left":
			if (fe.list.index  > scrollstep - 1) {
				if (leftcount == 0) {
					fe.list.index -= scrollstep
					ticksound.playing=true
					if (videosnapsurf.visible == true) updatesurf()
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
			if ((fe.list.index < fe.list.size - scrollstep  )){
				if (rightcount == 0) {
					fe.list.index += scrollstep
					 ticksound.playing=true
					if (videosnapsurf.visible == true) updatesurf()
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
				if (videosnapsurf.visible == true) updatesurf()
			}
			else if (scrolljump == true){
				wooshsound.playing=true
				scrolljump = false
				scrollstep = rows
				scroller2.visible = scrollineglow.visible = false
			}
			else {
			//	wooshsound.playing=true
				fe.signal("filters_menu")
				wooshsound.playing=true

			}
			return true
			
			case "down":
			
			if ((fe.list.index % rows <  rows -1) && ( ! ( (fe.list.index / rows == fe.list.size / rows)&&(fe.list.index%rows + 1 > (fe.list.size -1)%rows) ))) {
				if ((corrector == 0) && (fe.list.index == fe.list.size-1)) return true
				fe.list.index ++
				ticksound.playing=true
				if (videosnapsurf.visible == true) updatesurf()
			}
			else if (scrolljump == false){
				wooshsound.playing=true
				scrolljump = true
				scrollstep = rows*(cols-2)
				scroller2.visible = scrollineglow.visible = true		
			}
			return true
			
			

			// enable - disable the video preview surface
			case "custom6":
			wooshsound.playing=true
			if (videosnapsurf.visible == false){
				videosnapsurf.visible = true
				updatesurf()
			}
			else {
				videosnap.file_name="transparent.png"
				videosnapsurf.visible = false
			}
			return true
			
			// add favorites through custom4 or the AM control
			case "add_favourite":
			changedfav = true
			wooshsound.playing=true
			break
			
			case "custom4":
			changedfav = true
			fe.signal("add_favourite")
			break
			
			
			// use custom3 to enable search
			/*	
			case "custom2":
			wooshsound.playing=true
			searchtext = fe.overlay.edit_dialog( "Search title:", searchtext )
			fe.list.index += corrector + rows 
			fe.list.search_rule ="Title contains "+searchtext
			fe.list.index = 0
			corrector = 0
			return true
			*/
			case "custom3":
			wooshsound.playing=true
			local searchtext =""
			local switcharray = array(5)
			switcharray[0]="Title"
			switcharray[1]="Manufacturer"
			switcharray[2]="Year"
			switcharray[3]="Category"
			switcharray[4]="RESET"
			local result = fe.overlay.list_dialog(switcharray,"Search for...")

			if(result==4){
				//fe.list.index += corrector + rows 
				fe.list.search_rule =""
				searchdata.msg = ""
				if (backindex != -1){
					fe.list.index = backindex
					corrector = backcorrector
					backindex = -1
				}
				return
			}
			if ((result != 4)&&(result !=-1)){
				if (keyboard) 
					searchtext = fe.overlay.edit_dialog("Search "+switcharray[result]+": ",searchtext)
				else
					search_base_rule = switcharray[result]
				
				if (backindex == -1){
					backindex = fe.list.index
					backcorrector = corrector
				}
				
				if (keyboard)
					{
				fe.list.index += corrector + rows 
				fe.list.search_rule = switcharray[result]+" contains "+ recalculate(searchtext)
				fe.list.index = 0
				corrector = 0
				searchdata.msg = fe.list.search_rule
					}
				else{
					search_toggle()
				}

				return true

			}
			return true

			// use custom3 to enable search
			/*			
			case "custom3":
			wooshsound.playing=true
			searchtext = fe.overlay.edit_dialog( "Search manufacturer:", searchtext )
			fe.list.index += corrector + rows 
			fe.list.search_rule ="Manufacturer contains "+searchtext
			fe.list.index = 0
			corrector = 0
			return true
			*/

			case "toggle_rotate_right":
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

			case "toggle_rotate_left":
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

			// use custom2 to enable "more of the same" search
			case "custom2":
			wooshsound.playing=true
			local searchtext =""
			local switcharray = array(5)
			switcharray[0]="Year"
			switcharray[1]="Manufacturer"
			switcharray[2]="Main Category"
			switcharray[3]="Sub Category"
			switcharray[4]="RESET"
			local result = fe.overlay.list_dialog(switcharray,"More of the same...")

			if(result==4){
				//fe.list.index += corrector + rows 
				fe.list.search_rule =""
				searchdata.msg = ""
				if (backindex != -1){
					fe.list.index = backindex
					corrector = backcorrector
					backindex = -1
				}
				return
			}

			if (result == 0){
				searchtext = "Year contains "+ fe.game_info(Info.Year)
			}
			if (result == 1){
				searchtext = "Manufacturer contains "+fe.game_info(Info.Manufacturer)
			}
			if (result == 2){
				searchtext = (fe.game_info(Info.Category))
				local s = split( searchtext, "/" )
				searchtext = "Category contains "+s[0]
			}
			if (result == 3){	
				searchtext = "Category contains "+fe.game_info(Info.Category)		
			}
			
			if ((result !=4) && (result != -1)){
				if (backindex == -1){
					backindex = fe.list.index
					backcorrector = corrector
				}
				fe.list.index += corrector + rows 
				fe.list.search_rule = searchtext
				fe.list.index = 0
				corrector = 0
				searchdata.msg = searchtext
				return true
			}
			return true
			//			searchtext = fe.overlay.edit_dialog( "Search title:", searchtext )
			//			fe.list.search_rule ="Category contains "+searchtext


			default:
			wooshsound.playing=true
			
		} // END OF SWITCH SIGNAL LOOP 
		} // CLOSE ELSE GROUP
		return false
	}
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

function gameplaycount( offset ) {
	local s =  fe.game_info( Info.PlayedCount, offset )
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




// scrolling carrier call

local carrier = Carrier()

local rightdata = 400*scalerate*shrinker
//local namesurf = fe.add_surface (flw-rightdata,header_h)

// game name shadow
local namesh_x =  fe.add_text( "[!gamename]", 3, 3, flw*2, header_h*2/3 )
namesh_x.align = Align.Left
namesh_x.word_wrap = false
namesh_x.set_rgb( 0, 0, 0)
namesh_x.charsize = 60*scalerate*shrinker
namesh_x.alpha=themeshadow
//namesh_x.bg_alpha = 128
//namesh_x.bg_red = 255
namesh_x.font = guifont

// game name
local name_x =  fe.add_text( "[!gamename]", 0, 0, flw*2, header_h*2/3 )
name_x.align = Align.Left
name_x.word_wrap = false
name_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)
name_x.charsize = 60*scalerate*shrinker
//name_x.bg_alpha = 128
//name_x.bg_red = 255
name_x.font = guifont


/*
// game name
local nametest_x =  fe.add_text( "[!gamename]", 0, 0, flw-rightdata, header_h*1/3 + 60*scalerate/2  )
nametest_x.align = Align.Left
nametest_x.word_wrap = true
nametest_x.set_rgb( 255, 255, 255)
nametest_x.charsize = (header_h*1/3 + 60*scalerate/2)*0.5/1.25
nametest_x.bg_alpha = 128
nametest_x.bg_red = 255
nametest_x.font = guifont
*/

// game name second part (revision, details etc)
local subname_x =  fe.add_text( " [!gamesubname]", 0, header_h*1/3+60*scalerate/2, flw, header_h*1/3 )
subname_x.align = Align.Left
subname_x.word_wrap = true
subname_x.set_rgb( 255, 255, 255)
subname_x.charsize = 40*scalerate*shrinker
//subname_x.bg_alpha = 128
//subname_x.bg_green = 255
subname_x.font = guifont
subname_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

// game year and some data
local year_x =  fe.add_text( "© [Year] [Manufacturer]", flw-rightdata, 10*scalerate, rightdata, header_h/2)
year_x.align = Align.Centre
year_x.set_rgb( 255, 255, 255)
year_x.word_wrap = true
year_x.charsize = 30*scalerate*shrinker
year_x.visible = true
//year_x.bg_alpha = 128
//year_x.bg_green = 155
year_x.font = guifont
year_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

// game category and some data
local year_x =  fe.add_text( "[!maincategory]", flw-rightdata, header_h/2-10*scalerate, rightdata, header_h/2)
year_x.align = Align.Centre
year_x.set_rgb( 255, 255, 255)
year_x.word_wrap = true
year_x.charsize = 30*scalerate*shrinker
year_x.visible = true
//year_x.bg_alpha = 128
//year_x.bg_green = 155
year_x.font = guifont
year_x.set_rgb(themetextcolor,themetextcolor,themetextcolor)

local filterdata = fe.add_text ("[FilterName]",0,flh-footer_h,footermargin,footer_h)
filterdata.align = Align.Centre
filterdata.set_rgb( 255, 255, 255)
filterdata.word_wrap = true
filterdata.charsize = 25*scalerate*shrinker
filterdata.visible = true
filterdata.font = guifont
filterdata.set_rgb(themetextcolor,themetextcolor,themetextcolor)

local filternumbers = fe.add_text ("[ListEntry]/[ListSize]",flw-footermargin,flh-footer_h,footermargin,footer_h)
filternumbers.align = Align.Centre
filternumbers.set_rgb( 255, 255, 255)
filternumbers.word_wrap = true
filternumbers.charsize = 25*scalerate*shrinker
filternumbers.visible = true
filternumbers.font = guifont
filternumbers.set_rgb(themetextcolor,themetextcolor,themetextcolor)



// LOGO SPLASH SCREEN

// carica l'immagine sfumata del gioco attuale 
local afsplash = null

if (bgblurred == ""){
	afsplash = fe.add_image("white.png",bgx,bgy,bgw,bgw)
	afsplash.file_name = fe.get_art("blur")
}
else{
	afsplash = fe.add_image(bgblurred,0,0,flw,flh)
}


// aggiunge l'overlay bianco trasparente
local afwhitebg = fe.add_text("",0,0,flw,flh)
afwhitebg.set_bg_rgb(themeoverlaycolor,themeoverlaycolor,themeoverlaycolor)
afwhitebg.bg_alpha = themeoverlayalpha


// aggiunge l'immagine del logo
local aflogo = fe.add_image ("AFLOGO3b.png",0,(flh-(flw*1000/1600))/2,flw,flw*1000/1600)



// OVERLAY PER CONTROLLI CUSTOM (LISTBOX)

local overlay_charsize = floor( 50*scalerate )
local overlay_rows = floor((flh-header_h-footer_h)/(overlay_charsize*3))
local overlay_labelsize = floor ((flh-header_h-footer_h)/overlay_rows)

// sfondo dell'area con le scritte
local overlay_background = fe.add_text ("", 0 , header_h, flw, flh-header_h-footer_h)
overlay_background.set_bg_rgb(200,200,200)
overlay_background.bg_alpha = 64
overlay_background.zorder=999

local overlay_listbox = fe.add_listbox( 0, header_h+overlay_labelsize, flw, flh-header_h-footer_h-overlay_labelsize )
overlay_listbox.rows = overlay_rows - 1
overlay_listbox.charsize = overlay_charsize
overlay_listbox.bg_alpha = 0
overlay_listbox.set_rgb(themetextcolor-5,themetextcolor-5,themetextcolor-5)
overlay_listbox.set_bg_rgb( 0, 0, 0 )
overlay_listbox.set_sel_rgb( 50, 50, 50 )
overlay_listbox.set_selbg_rgb( 250,250,250 )
overlay_listbox.selbg_alpha = 255
overlay_listbox.zorder=999
overlay_listbox.font = guifont

local overlay_label = fe.add_text( "dummy", 0, header_h, flw, overlay_labelsize )
overlay_label.charsize = overlay_charsize
overlay_label.set_rgb(themetextcolor-5,themetextcolor-5,themetextcolor-5)
overlay_label.align = Align.Centre
overlay_label.zorder=999
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

fe.overlay.set_custom_controls( overlay_label, overlay_listbox )

fe.add_transition_callback( "overlay_transition" )

function overlay_transition( ttype, var, ttime )
{
	switch ( ttype )
	{
		case Transition.ShowOverlay:
		carrier.snapbg3.visible = carrier.snapbg4.visible =  true
		overlay_listbox.visible = overlay_label.visible = overlay_background.visible = shader1.visible = shader2.visible = shader3.visible = true
		break
		
		case Transition.HideOverlay:
		carrier.snapbg3.visible = carrier.snapbg4.visible = false
		overlay_listbox.visible = overlay_label.visible = overlay_background.visible = shader1.visible = shader2.visible = shader3.visible = false
		break
	}
	return false
}

// SEARCH MODULE


if (SPLASHON == false) afsplash.visible = afwhitebg.visible = aflogo.visible = false



local search_surface = fe.add_surface(fe.layout.width, fe.layout.height)
local keys = null
keys = {}
local search_text = null
search_surface.zorder = 999999

search_surface.preserve_aspect_ratio = true
search_surface.alpha = 255*0


//select( config.keys.selected[0], config.keys.selected[1] )


function search_toggle() {
	search_surface.alpha = ( search_surface.alpha == 0 ) ? 255: 0
	if (search_text.msg = "") search_text.msg = search_base_rule + ": "
	//clear text when shown
	if ( search_visible() ) search_clear()
	
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
	
	//fe.overlay.splash_message(rel_col+" "+rel_row)
	search_select( key_selected[0] + rel_col, key_selected[1] + rel_row )
}

function search_select( col, row )
{
	row = ( row < 0 ) ? key_rows.len() - 1 : ( row > key_rows.len() - 1 ) ? 0 : row
	col = ( col < 0 ) ? key_rows[row].len() - 1 : ( col > key_rows[row].len() - 1 ) ? 0 : col
	local previous = key_rows[key_selected[1]][key_selected[0]].tochar()
	local selected = key_rows[row][col].tochar()
	//print( "selected: " + selected + "(" + col + "," + row + ") previous: " + previous + "(" + config.keys.selected[0] + "," + config.keys.selected[1] + ")" )
	keys[previous].set_rgb( 180,180,180 )
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
				search_update_rule ()
				search_toggle()
			}
	else if (c != "_")
		s_text = s_text + c
	search_text.msg = search_base_rule + " = " + s_text 
	if (LIVESRC) search_update_rule()
}
	 
function search_update_rule(){
	try
	{
		local rule = search_base_rule + " contains " + recalculate (s_text)
		//fe.list.search_rule = "Title contains mario"
		//fe.list.search_rule = ""
		
			fe.list.index += corrector + rows
			fe.list.search_rule = ( s_text.len() > 0 ) ? rule : ""
			fe.list.index = 0
			corrector = 0
			searchdata.msg = fe.list.search_rule
		

	} catch ( err ) { print( "Unable to apply filter: " + err ); }
	}

function draw_osd() {

	//draw the search surface bg
	local bg = search_surface.add_image("kbg.png", 0, 0, search_surface.width, search_surface.height)
	bg.alpha = 210
				

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
				
		local key_name = (key == "_") ? " " : ( key == "-" ) ? "CLR" : ( key == " " ) ? "SPC" : ( key == "<" )  ? "DEL" : ( key == "~" ) ? "DONE" : key.toupper()
		
		local textkey = search_surface.add_text( key_name, -1, -1, 1, 1 )
		textkey.font = guifont
		textkey.charsize = 80*scalerate

		textkey.set_rgb( 180,180,180)
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


fe.add_ticks_callback( this, "tick2" )

local timerscan = 300.0

function tick2( tick_time ) {
	

	
	if (logoshow !=0){
		logoshow = logoshow - 0.018	
		if (logoshow < 0.01) {
			logoshow = 0
			afsplash.visible = aflogo.visible = afwhitebg.visible = false
		}
		afsplash.alpha = 255*(1-pow((1-logoshow),3))
		aflogo.alpha = 255*(1-pow((1-logoshow),3))
		afwhitebg.bg_alpha = themeoverlayalpha*(1-pow((1-logoshow),3))
	}
	
	
	if (scrolltitle == 2){
		name_x.x =0
		namesh_x.x =3
		scrolltitle = 0
	}
	
	if (name_x.msg_width < flw -rightdata){
		if (scrolltitle == 1){
			name_x.x =0
			namesh_x.x =3
		}
		scrolltitle = 0
		scrollincrement = 0
	}
	else {
		scrolltitle = 1
	}
	
	local deltastep = (name_x.msg_width - flw+rightdata)*1.1
	
	if (scrolltitle == 1){
		scrollincrement ++
		if (scrollincrement == 22*timerscan) scrollincrement = 0
		if ((scrollincrement > 5*timerscan) && (scrollincrement < (5+1)*timerscan))
		{
			name_x.x = - deltastep * (scrollincrement - timerscan*5)/timerscan
			namesh_x.x = 3 + name_x.x
		}
		if ((scrollincrement > (5+1+5)*timerscan) && (scrollincrement < (5+1+5+1)*timerscan))
		{
			name_x.x = - deltastep * ((5+1+5+1)*timerscan - scrollincrement)/timerscan
			namesh_x.x = 3 + name_x.x
		}
	}
	
}
