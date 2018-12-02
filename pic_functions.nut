function file_exist(fullpathfilename){
	try {file(fullpathfilename, "r" );return true;}catch(e){return false;}
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
