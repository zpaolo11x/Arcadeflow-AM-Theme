**Arcadeflow - Attract Mode theme by zpaolo11x - v 1.0**

Arcadeflow is an horizontal scrolling, grid based theme for MAME, it doesn't support multiple systems and is based on snapshots and game titles, not on flyers or cartridge boxes. If you have video snaps they will appear over the selected thumbnail without sound, and you can open a larger video preview with sound.

The layout adapts to different aspect ratios (5:4, 4:3, 16:9 and 16:10) automatically and reasonably well (external snaps get partially cut but not completely obscured) and a different layout is enabled for vertical aspect ratio (still not completely tested but should work)

*Custom controls*

- custom3 is used to enable title search on games, instead of using the search plugin
- custom4 is an alternative way to add favorites, in case the usual way doesn't work as expected
- custom6 enables/disables a larger video preview with sound

*Tags*

You can add a "Completed" tag to games, that will ad a "Completed" stamp on them

*Sorting and scrolling*

When your list is sorted by name a large preview letter will appear while scrolling through the list. 
If your list is sorted by year the year will appear instead of the letter.

*Snaps aspect ratio*

Arcadeflow requires that the aspect ratio of the snapshots is 4:3 or 3:4 depending on the game orientation, it will not correct the snapshot aspect ratio and won't look good otherwise. You can resize your snapshots using batch processing software like xnview, don't use bilinear or lanzcos scaling but just "nearest neighbor" if you want to keep the file size small.

*Blurred background*

The blurred background is not calculated from the snaps: you need to batch process your snapshots and create a custom art category in attract mode called  "blur". What I do is:

- resize the snaps to 640x480
- crop a 480x480 central portion
- resize to 64x64
- apply 5 gaussian blurs 13x13 pixels wide
- resize to 128x128
- apply 5 gaussian blurs 13x13 pixels wide

This results in a very smooth yet fast to load blurred background. I prepared some xnview scripts you can use for the conversion.
