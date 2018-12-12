# Arcadeflow - Attract Mode theme by zpaolo11x - v 3.0 #

Arcadeflow is an horizontal scrolling, grid based theme for MAME, it doesn't support multiple systems and is based on snapshots and game titles, not on flyers or cartridge boxes. If you have video snaps they will appear over the selected thumbnail without sound, and you can open a larger video preview with sound.

The layout adapts to different aspect ratios (5:4, 4:3, 16:9 and 16:10) automatically and reasonably well (external snaps get partially cut but not completely obscured) and a different layout is enabled for vertical aspect ratio.

## What's new in v 3.0 ##

- Changed the way blurred fading backgrounds are layered
- Tweaked some graphics aspects
- Pop up letter now responds to the sort order of the game list
- Cleaned up some code
- Added an option to mute the theme "click" and "woosh" sounds
- Improved transparent PNGs for shadows and glows

## Custom controls ##

You can define a custom control to call the game context menu, from which you can activate the following functions:

- "UP" enters the "More of the same..." search function, filtering games with the same year, manufacturer, main category or sub-category of the current game
- "DOWN" enters the "History" page where you can see and scroll the game history and see a larger game preview
- "LEFT" to enter the Tags menu
- "RIGHT" to add/remove favorites

## Filters, Search and Layout options ##

You can access the "Filters" menu and the "Search" function by going "UP" from the first row of icons. In the same menu you'll get the "Layout options" access (in AM 2.4)

## Tags ##

You can add a "Completed" tag to games, that will ad a "Completed" stamp on them

## Sorting and scrolling ##

When your list is sorted by name a large preview letter will appear while scrolling through the list. 
If your list is sorted by year the year will appear instead of the letter.
You can go "DOWN" from the altest row to enter a "large jumps" scrolling mode.

## Game options ##

GENERAL

- "Context Menu Button" : Setup the button to use to recall game info and actions context menu
- "Rows in horizontal layout" : Number of rows to use in 'horizontal' mode
- "Rows in vertical layout" : Number of rows to use in 'vertical' mode
- "Smooth shadow" : Enable smooth shadow under game title and data in the GUI
- "Screen rotation" : Select a persistent screen rotation option
- "Frosted glass" : Add a frosted glass effect for menu backgrounds
- "Custom resolution WIDTHxHEIGHT" : Define a custom resolution for your layout independent of screen resolution

THUMBNAILS

- "Aspect ratio" : Chose wether you want cropped, square snaps or horizontal and vertical snaps
- "Glow effect" : Add a glowing halo around the selected game thumbnail
- "Video thumbs" : Enable video overlay on snapshot thumbnails
- "Color gradient" : Fades the artwork behind the game logo to its average color
- "New Game Indicator" : Games not played are marked with a glyph

BACKDROP

- "Overlay Color" : Setup theme luminosity overlay
- "Custom Background Image" : Insert custom background art path
- "Background snap" : Add a faded game snapshot to the background
- "Animate background snap" : Animate video on background

LOGO

- "Enable splash logo" : Enable or disable the AF start logo
- "Custom splash logo" : Chose a custom picture as splash logo

SEARCH

- "Search string entry method" : Use keyboard or on-screen keys to enter search string
- "Immediate search" : Live update results while searching

HISTORY

- "History.dat" : History.dat location
- "Index Clones" : Set whether entries for clones should be included in the index.
- "Generate Index" : Generate the history.dat index now (this can take some time)

AUDIO

- "Theme audio" : Enables or disables the "click" and "woosh" theme sounds
- "Audio in videos (thumbs)" : Select wether you want to play audio in videos on thumbs
- "Audio in videos (history)" : Select wether you want to play audio in videos on history detail page

## Previous versions history ##

*v 2.9*

- Redesigned the game data ribbon on top of the thumbnail grid
- Added category icons for game category
- Added manufacturer icons for game manufacturer
- Added a smooth drop shadow under game title, data and icons
- Streamlined the AF logo so it's just white 
- The technique used for background crossfade is used for game data crossfade too
- Frosted glass effect applied to the screen behind the logo

*v 2.8*

- Implemented a new, smoother system for background image crossfade
- Added a "look for the same..." + "Decade" search menu entry

*v 2.7*

- Fixed some bugs in screen rotation
- Added the possibility to define a layout resolution independent from screen resolution

*v 2.6*

- New "frosted glass" effect when you enter overlay menus
- Updated Readme.md with current options

*v 2.5*

- Added a new option to toggle screen rotation permanently

*v 2.4*

- Snapshots aspect ratio is now adapted to 4:3 or 3:4 automatically
- Some improvements to shaders, cleaned up the code
- Revamped the History page adding a CRT-like shader to the game preview
- Tweaked the appearance of themes (dark is now darker) and fixed some bugs in snapshots scaling

*v 2.3*

- Improved the overall speed by optimizing shaders and textures
- Added a new effect on the background where you can get a pixellated version of the snap or video
- Added a new glow effect around selected thumbs with the average thumb color
- Added the possibility to hear audio of the videos in the thumb and/or in the history page
- Revamped the options to make it more clear

*v 2.2*

- The thumbnail art fades to the average thumbnail color in the area behind the title logo, to improve readability
- Added an option "Smooth Gradient Snap" to enable/disable the fade effect
- In "Square" thumbs mode changed the position and aspect ratio of the logo so it's more on the top of the thumb

*v 2.1*

- Added some tweaks to make scrolling more fluid and correct slowdowns
- Fixed a bug in the background scaling blurred snap routine
- Changed the blur shader, now there are three layouts to chose from: layout, layout_noshader, layout_oldshader (with a lighter shader that is faster on some machines)

*v 2.0*

- New feature: you can now change the splash logo
- New feature: background artwork can be a semi-transparent PNG and will show the blurred background behind it
- Under the hood changes: version 2.0 is a huge rewrite of AF, no need to generate blurred backgrounds or blurred logo shadows with xnview, the theme can generate on the fly shadows and backgrounds from your snapshots and wheel artwork. The theme may be a bit slower on your system depending on the size of artworks which is generally larger than xnview generated blurred pictures.
- If you have issues with the new way "blur" is generated you can use the layout_noshader.nut file instead, just chose it from the layout options menu (AM 2.4) or rename it to layout.nut (AM 2.3). This layout file has all the features of the new one, but in a standard framework using xnview generated artwork

*v 1.9*

- AM 2.4 was released while coding AF 1.9, adapted the code so it works both in 2.3 and 2.4:
  - Fixed the zorder management 
  - Implemented a new way to crop thumbnails for "square" thumbs layout 
  - 2.4 users can access the "Layout Options" menu directly from the "General" menu accessible going "Up" from the game grid
  - Rewritten the scrolling title routine with proper timing
- Custom background picture is not stretched but scaled/cropped to fit the theme aspect ratio
- Thoroughly rewritten the transition response routine, it's cleaner and works much better now.
- Thanks to the above rewrite you can now use "left" and "right" on the History screen to go to the previous/next game, the layout should now respond correctly even to "jump to letter" calls and page jumps.
- "Square" thumbnails layout now responds to the "Blurred Logo Shadow" option, if you enable it you'll get game name overlay with drop shadow, otherwise plain game name with gradient background.
- When a game has a multi-language title separated by "/" (e.g. Fatal Fury / Garou Densetsu) the theme will crossfade the titles so that title scrolling is needed less often.

*v 1.8*

- Introduced a new layout style where game snaps are not horizontal or vertical depending on game orientation, but cropped square. You can chose it in the options menu.

*v 1.7*

- Overhauled the menu and functions system, now it works like this:
  - When going "UP" from the tiles list you get to a "main menu" where you can select Filters Menu or Global Search
  - When on a game using the configurable control button you get a "context menu" overlay with 4 game-specific functions you chose by using your joystick/keys:
    - "UP" enters the "More of the same..." search menu
    - "DOWN" enters the "History" page where you can see and scroll the game history and see a larger game preview
    - "LEFT" to enter the Tags menu
    - "RIGHT" to add/remove favorites
- Implemented a version of the History.dat plugin so you can see history without the need to enable the plugin (see options)
- Rolled back the way horizontal and vertical games are detected, the "new" one had some issues in many circumstances
- Tweaked and updated search with on-screen keys
- Added a workaround when invoking filters through the filters menu button to fix some tiles update

- New theme options included: 
  -	"History.dat" is the location of the History.dat file (no need to enable or configure the )
  - "Index Clones" works like the same option in the History.dat plugin.
  - "Generate Index" a one-time function to generate the history index

*v 1.6*

- Changed the way horizontal and vertical games are detected, this time it should work for all users and all games lists
- Changed the way the "vertical" mode is scaled and layed out, clearer and with larger thumbs 
- Search features that require tex input now also work with on-screen keys (embedded the KeyboardSearch plugin)
- New theme options included: 
  -	"Search string entry method" to chose if you want to use a keyboard or a joystick and on screen keys to enter text
	- "Immediate search" will live update results while you enter search text using the on screen keys
	- "Enable AF splash logo" enables/disables the fading splash Arcadeflow logo
  - "Vertical rows" allows to use 2 or 3 rows of icons in vertical mode

*v 1.5*

- New shadows graphics, smoother and more modern-looking 
- New and improved search features:
  - use "Custom 2" to filter games with the same year, manufacturer, main category and sub-category of the current game (e.g. shooters, or horizontal shooters)
  - use "Custom 3" to open a menu and search in games titles, years, manufacturers or categories
- When toggling screen rotation using AttractMode hotkeys the screen updates to the vertical layout if needed.

*v 1.4*

- Changed (again) splash screen graphics at startup (new AF logo) 
- Introducing theme options:
  - You can chose the theme's... theme :D There are 4 choices: "Default" (greyed blurred background), "Dark", "Light" (dark and light blurred background), "Pop" (blurred background colors unaltered)
  - You can chose whether you want "hard edged" game title shadows or "smooth" game title shadows, the latter requires new artwork (see below)
  - You can chose whether you want to place a marker on unplayed games
  - You can place a background image, this will be affected by the theme choice and will override the blurred background
- Minor tweaks and speedups, now each sections retaines the latest selected game

*v 1.3*

- Key repeat rate limited to allow more fluid scrolling of tiles 
- Added selection sound
- Changed splash screen graphics at startup

*v 1.2*

- Scrolling game title when the title size is too big to fit the screen 
- If you go "up" from the first row you enter the "Filters" menu
- If you go "down" from the second row the scrollbar highlights and you can jump screens faster
- Improved scrolling speed on some systems
- Added a splash screen at startup

*v 1.1*

- The games list is not repeating
- Tweaked scrolling at the beginning of the list so the first game column is not centered
- Changed the timing so that when the video snapshot is loaded the scrolling doesn't stutter
- Number of columns automatically calculated
- Better support for vertical displays

*v 1.0*

- First release

![AF Image](http://www.mixandmatch.it/AF/AF_1280_2.jpg)