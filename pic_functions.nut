function file_exist(fullpathfilename){
	try {file(fullpathfilename, "r" );return true;}catch(e){return false;}
}


function controller_pic(offset){
   local s = fe.game_info( Info.Control, offset )
   
   switch (s) {
      case "joystick (8-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),joystick (8-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),joystick (8-way),joystick (8-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),joystick (8-way),joystick (8-way),joystick (8-way)": return ("controller_images/control_joystick_8way.png")

      case "joystick (8-way),dial": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),dial,joystick (8-way),dial": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),dial,joystick (8-way),dial,joystick (8-way),dial": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),dial,joystick (8-way),dial,joystick (8-way),joystick (8-way)": return ("controller_images/control_joystick_8way.png")

      case "joystick (8-way),joystick (analog)": return ("controller_images/control_joystick_8analog.png")
      case "joystick (8-way),joystick (analog),joystick (8-way),joystick (analog)": return ("controller_images/control_joystick_8analog.png")
      case "joystick (2-way),joystick (analog)": return ("controller_images/control_joystick_2analog.png")


      case "joystick (8-way),trackball": return ("controller_images/control_joystick_8trackball.png")
      case "joystick (8-way),trackball,joystick (8-way),trackball": return ("controller_images/control_joystick_8trackball.png")

      case "joystick (8-way),positional": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),positional,joystick (8-way),positional": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),positional,joystick (8-way),positional,joystick (8-way),positional": return ("controller_images/control_joystick_8way.png")
      case "joystick (8-way),positional,joystick (8-way),positional,joystick (8-way)positional,joystick (8-way)positional": return ("controller_images/control_joystick_8way.png")
      case "joystick (5 (half8)-way),joystick (5 (half8)-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (5 (half8)-way)": return ("controller_images/control_joystick_8way.png")

      case "joystick (4-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (4-way),joystick (4-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (4-way),joystick (4-way),joystick (4-way),joystick (4-way)": return ("controller_images/control_joystick_4way.png")
      case "joystick (3 (half4)-way),joystick (3 (half4)-way)": return ("controller_images/control_joystick_4way.png")
      case "joystick (3 (half4)-way)": return ("controller_images/control_joystick_4way.png")

      case "joystick (2-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (vertical2-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (2-way),joystick (2-way)": return ("controller_images/control_joystick_8way.png")
      case "joystick (2-way),joystick (2-way),joystick (2-way),joystick (2-way)": return ("controller_images/control_joystick_2way.png")

      case "paddle,pedal": return ("controller_images/control_paddle_pedal.png")
      case "paddle,pedal,paddle,pedal": return ("controller_images/control_paddle_pedal.png")

      case "dial,pedal": return ("controller_images/control_paddle_pedal.png")
      case "dial,pedal,dial,pedal": return ("controller_images/control_paddle_pedal.png")
      case "dial,pedal,dial,pedal,dial,pedal": return ("controller_images/control_paddle_pedal.png")
      case "dial,pedal,dial,pedal,dial,pedal,dial,pedal": return ("controller_images/control_paddle_pedal.png")

      case "dial,paddle,pedal": return ("controller_images/control_paddle_pedal.png")
 
      case "joystick (analog)": return ("controller_images/control_joystick_analog.png")
      case "joystick (analog),joystick (analog)": return ("controller_images/control_joystick_analog.png")

      case "trackball": return ("controller_images/control_trackball.png")
      case "trackball,trackball": return ("controller_images/control_trackball.png")
      case "trackball,trackball,trackball": return ("controller_images/control_trackball.png")

      case "paddle": return ("controller_images/control_paddle.png")
      case "paddle,paddle": return ("controller_images/control_paddle.png")

      case "dial": return ("controller_images/control_paddle.png")
      case "dial,dial": return ("controller_images/control_paddle.png")

      case "only_buttons": return ("controller_images/control_buttons.png")
      case "only_buttons,only_buttons": return ("controller_images/control_buttons.png")
      case "only_buttons,only_buttons,only_buttons,only_buttons": return ("controller_images/control_buttons.png")

      case "double joystick": return ("controller_images/control_double_joystick.png")
      case "double joystick,double joystick": return ("controller_images/control_double_joystick.png")

      case "lightgun": return ("controller_images/control_lightgun.png")
      case "lightgun,lightgun": return ("controller_images/control_lightgun.png")
   }
   
}


function manufacturer_pic(offset){
   local s = fe.game_info( Info.Manufacturer, offset )
	local t = fe.game_info( Info.Title, offset )	
	
   local s2 = split( s, "*_/: .()-,<>?&+" )
	local sout =""
	if ( s2.len() > 1 ) {
		for (local i=0;i<s2.len();i++){
		if (s2[i] != "license")sout = sout + s2[i]
		}
		sout = sout.tolower()
	}
	else sout = strip(s).tolower()
	return "manufacturer_images/" + sout + ".png"
}

function maincategory(offset){
   local s = fe.game_info( Info.Category, offset )
	local s1 = split(s,"/")
   if (s1.len()>1) s = s1[0]

   local sout = strip(s).toupper()
   return sout
}

function category_pic(offset){
   local s = fe.game_info( Info.Category, offset )
//	local s1 = split(s,"/")
//   if (s1.len()>1) s = s1[0]

   local s2 = split( s, "*_/: .()-,<>?&+" )
	local sout =""
	if ( s2.len() > 1 ) {
		for (local i=0;i<s2.len();i++){
		 if (s2[i] != "Mature")  sout = sout + s2[i]
		}
		sout = sout.tolower()
	}
	else sout = strip(s).tolower()
	return "category_images/"+sout+".png"
}

function manufacturer_list(){
   local zout = ""
   local indexer = 0
   local s = ""
   local t = ""
   for (local i = 0; i<fe.list.size; i++){
      zout = manufacturer_pic(i)
      s = fe.game_info( Info.Manufacturer, i )
	   t = fe.game_info( Info.Title, i )	

      if (!(file_exist(fe.script_dir + zout))){
         indexer ++
         print(  indexer + " *** " + s + " *** " + t + "\n")
      }
   }
}

function category_list(){
   local zout = ""
   local indexer = 0
   local s = ""
   local t = ""
   for (local i = 0; i<fe.list.size; i++){
      zout = category_pic(i)
      s = fe.game_info( Info.Category, i )
	   t = fe.game_info( Info.Title, i )	

      if (!(file_exist(fe.script_dir + zout ))){
         indexer ++
         print(  indexer + " *** " + s + " *** " + t + " " + zout + "\n")
      }
   }
}

//listbrand()
//listcategory ()
