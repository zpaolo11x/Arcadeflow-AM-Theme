**Arcadeflow - Attract Mode theme by zpaolo11x - v 1.6**

Arcadeflow is an horizontal scrolling, grid based theme for MAME, it doesn't support multiple systems and is based on snapshots and game titles, not on flyers or cartridge boxes. If you have video snaps they will appear over the selected thumbnail without sound, and you can open a larger video preview with sound.

The layout adapts to different aspect ratios (5:4, 4:3, 16:9 and 16:10) automatically and reasonably well (external snaps get partially cut but not completely obscured) and a different layout is enabled for vertical aspect ratio.


*What's new in v 1.6*

- Changed the way horizontal and vertical games are detected, this time it should work for all users and all games lists
- Changed the way the "vertical" mode is scaled and layed out, clearer and with larger thumbs 
- Search features that require tex input now also work with on-screen keys (embedded the KeyboardSearch plugin)
- New theme options included: 
  -	"Search string entry method" to chose if you want to use a keyboard or a joystick and on screen keys to enter text
	- "Immediate search" will live update results while you enter search text using the on screen keys
	- "Enable AF splash logo" enables/disables the fading splash Arcadeflow logo
  - "Vertical rows" allows to use 2 or 3 rows of icons in vertical mode
  
*Custom controls*

- custom2 is used for the "More of the same..." search function, filtering games with the same year, manufacturer, main category or sub-category of the current game
- custom3 is used to enable search on games titles, year, manufacturer or category
- custom4 is an alternative way to add favorites, in case the usual way doesn't work as expected
- custom6 enables/disables a larger video preview with sound

*Filters*

You can access the "Filters" menu by going "UP" from the first row of icons.

*Tags*

You can add a "Completed" tag to games, that will ad a "Completed" stamp on them

*Sorting and scrolling*

When your list is sorted by name a large preview letter will appear while scrolling through the list. 
If your list is sorted by year the year will appear instead of the letter.
You can go "DOWN" from the altest row to enter a "large jumps" scrolling mode.

*Snaps aspect ratio*

Arcadeflow requires that the aspect ratio of the snapshots is 4:3 or 3:4 depending on the game orientation, it will not correct the snapshot aspect ratio and won't look good otherwise. You can resize your snapshots using batch processing software like xnview, don't use bilinear or lanzcos scaling but just "nearest neighbor" if you want to keep the file size small.

*Blurred background*

The blurred background is not calculated from the snaps: you need to batch process your snapshots and create a custom art category in attract mode called  "blur". What I do is:

- resize the snaps to 640x480
- crop a 480x480 central portion
- resize to 32x32
- apply 1 gaussian blurs 9x9 pixels wide

This results in a very smooth yet fast to load blurred background. I prepared some xnview scripts you can use for the conversion.

*Blurred title shadows*

You can add a attract mode art category called "logoblur" and use the provided xnview script to generate new artworks for blurred shadows to be placed under the title

** Previous versions history **

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