
#cs 
	  Witch Doctor Cellar Farming Bot - Version 0.4[1920x1080 AND 800x600]
	  Developed by Avatar88343 @ Ownedcore
	  Note: I rushed to put this online so the source is still very messy. I have snippets of code that is no longer used
	  and if statements that check for nothing. It will all be cleaned up in 0.4
	  
	  
	  What it does:
			*This bot will travel to the cellar in Act 1, kill the mobs, collect the gold and items, and repair your gear.
	  
	  
	  Newbiew Info:
	  This is a script that runs on AutoIt. You run this bot by Downloading AutoIt from the web (it's free) and installing it.
	  You then paste all this code into any text editor (such as notepad) and save it anywhere on your hard drive. Follow the Select
	  steps below to configure this bot before you run it.
	  
	   Special Instructions for 1920 x 1080:
	   1.) Set your game resolution to 1920x1080 (required)
	   2.) Set the display mode to Fullscreen Windowed (Don't forget!)
	   3.) Follow the Instructions (for all resolutions) section below
	   
	   Special Instructions for 800 x 600:

	   1.)Exit Diablo 3
	   2.)Go to your document folder and locate the Diablo III folder
	   3.)Open the D3Prefs file in any editor (such as notepad)
	   4.)Change the following settings to the ones listed below
	   "DisplayModeFlags "0"
	   DisplayModeWindowMode "1"
	   DisplayModeWinLeft "428"
	   DisplayModeWinTop "162"
	   DisplayModeWinWidth "800"
	   DisplayModeWinHeight "600"
	   DisplayModeUIOptWidth "800"
	   DisplayModeUIOptHeight "600"
	   DisplayModeWidth "800"
	   DisplayModeHeight "600"
	   DisplayModeRefreshRate "75"
	   DisplayModeBitDepth "32""
	   5.) Follow the Instructions (for all resolutions) section below
	   
	  
	  Instructions (for all resolutions)
			1.) Bind your middle mouse button to Move (found in Key Bindings Option)
			2.) Set your build to this http://us.battle.net/d3/en/calculator/witch-doctor#jaQPiU!VZW!babbZa
			3.) Start Act 1, Quest 6 - Talk to Alaric
			4.) Hire the Scoundrel
			5.) Teleport to The Old Ruins using the waypoint and run left until you reach a checkpoint
			6.) Log out of the game
			7.) Press Space to start the bot! Space is used to pause and resume the bot
			8.) Press Z to turn off the bot
	  
	  NOTE: 
			*Please make sure you are running the correct resolution settings!
			*You must be running the game in Fullscreen Windoed mode if you're using 1080P
			*You WILL need to edit the values below the comments for better results
	  
	  FEATURES:
			*Supports 1080P Fullscreen Windowed and 800x600 Windowed
			*Automatic looting of Rare, Legendary, and Set items
			*Repairs Items when damaged
			*Detects death and responds accordingly
			*Able to detect
			*Randomization for increased safety
			*Added ability to find Cellar during bad runs
			*Loots Gems (partly)
	  
	  IN DEVELOPMENT:
			*Multi-resolution support (very soon)
			*Inventory check and stash use
			*Improved combat
			*Speed improvements
			*Multiple routes to improve safety
			*45 min timeout bug
			*edit d3config
	  
	  
	  **Based on the code by notAres and mackus101. Special thanks to them!
#ce
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
;======THESE VALUES ARE NOW EDITED WITH THE GUI ===================================
$R				=  0			;Leave this as 0 if you are using 1080P. Change it to 1 if you're using 800 x 600
$ComputerLag	= 1000			;Increase this by 100-5000 if you have a slow PC.
$RunSpeed		= 10			;Enter your character's run speed here
$LootRares		= True			;Whether or not to loot rare and legendary items
$LootBlues		= True			;Whether or not to loot blue items
$Repair			= True			;Orders the bot to repair when items are damaged
$LootGems		= True			;A bit buggy but works sometimes
$UseStash 		= False			;Not currently supported
;======================================================================

Global $Resume[2][2]			;Location of the Resume Button			
Global $Leave[2][2]				;Location of the in-game leave button
Global $GameLobbyCode[2][3]		;Contains X, Y, and Hex color of Resume button so we can see if we're there
Global $GameScreenCode[2][3]	;Contains X, Y, and Hex color used to check if we are in an unpaused game
Global $Loc1[2][2]				;First movement
Global $Loc2[2][2]				;Second movement
Global $Loc3[2][2]				;Third movement	ttt

Global $CellarLocation[2][2]	;Cellar door location
Global $CellarLocation2[2]		;Location of cellar during bad runs (ugly workaround for now)
Global $AltCellar = False

Global $Loc5[2][2]				;Cellar hallway
Global $Loc6[2][2]				;Cellar doorway
Global $MonsterLoc[2][2]		;Initial boss location
Global $MonsterSearch[2][4]		;Bounds of where we will find our monsters
Global $GoldLoot1[2][2]			;First place to run when looting
Global $GoldLoot2[2][2]			;Second place to run when looting
Global $GoldLoot3[2][2]			;Third place to run when looting
Global $LootingArea[2][4]		; looting bounds (TL X, TL Y, BR X, BR Y)
Global $CharHitBox[2][4]		; Hitbox around user's character
Global $DeathBounds[2][2]		; Used to detect the "You Have Died" text
Global $RepairCords[2][4][2]	; Four clicks needed to repair
Global $RepairCheck[2][2]		; Used to check for repair icon
Global $CellarOffset[2]			; Used to improve cellar clicking with 1080P/800x600		
Global $CellarIcon 				;Used to find the yellow cellar icon on the minimap (future use)
Global $CellarPixel				
GLobal $GemLootOffset[2]			;Distance between gem and its text
ActivateGUI()

;Check for people that can't read instructions
if int($R) < 0 OR int($R) > 1 Then
   MsgBox(4096, "A wild illiterate appears appears!" , "Aha! I caught you! You did not read the instructions. You need to configure the bot!")
   terminate()
EndIf
   

;Clculate run speed
Global $RunTime = 30 * (100 - $RunSpeed) + 2000	;Length of time to run in 800x600

;All locations are N dimensional arrays. [0][x] is for 1080P and [1][x] is for 800x600
;1080P

;1920x1080
$Resume[0][0] = 319
$Resume[0][1] = 416
$GameLobbyCode[0][0] = 319
$GameLobbyCode[0][1] = 416
$GameLobbyCode[0][2] = 4065536
$GameScreenCode[0][0] = 1119
$GameScreenCode[0][1] = 1044
$GameScreenCode[0][2] = 0xDEFDFE 

;800x600
$Resume[1][0] = 174
$Resume[1][1] = 232
$GameLobbyCode[1][0] = 174	
$GameLobbyCode[1][1] = 232
$GameLobbyCode[1][2] = 4262400
$GameScreenCode[1][0] = 486
$GameScreenCode[1][1] = 578
$GameScreenCode[1][2] = 0x6C9BFF

;1920x1080
$Leave[0][0] = 969
$Leave[0][1] = 582

;800x600
$Leave[1][0] = 397
$Leave[1][1] = 322

;1920x1080
$Loc1[0][0]		= 500		;First movement
$loc1[0][1]		= 250
$loc2[0][0]		= 1			;Second movement
$loc2[0][1]		= 370
$loc3[0][0]		= 400		;Third Movement
$loc3[0][1]		= 600		

;800x600
$Loc1[1][0]		= 8			;First movement
$loc1[1][1]		= 146
$loc2[1][0]		= 7			;Second movement
$loc2[1][1]		= 300
$loc3[1][0]		= 8			;Third Movement
$loc3[1][1]		= 300	

;1080P
$CellarLocation[0][0] = 307		;Cellar door location
$CellarLocation[0][1] = 74
;800x600
$CellarLocation[1][0] = 499		;Cellar door location
$CellarLocation[1][1] = 148
$CellarLocation2[0] = 439
$CellarLocation2[1] = 145 
$AltCellarLocation = False
 
;Cellar offset
$CellarOffset[0] = 33;
$CellarOffset[1] = 10;

;1080P
$loc5[0][0]		= 116		;Walk down hallway	
$loc5[0][1]		= 986			
$loc6[0][0]		= 776		;enter hallway
$loc6[0][1]		= 328
;800x600
$loc5[1][0]		= 3			;Walk down hallway	
$loc5[1][1]		= 504			
$loc6[1][0]		= 255		;enter hallway
$loc6[1][1]		= 190

;1080P
$MonsterLoc[0][0] =	577
$MonsterLoc[0][1] = 183
;800x600
$MonsterLoc[1][0] =	188
$MonsterLoc[1][1] = 111

;1920x1080
$MonsterSearch[0][0] = 162
$MonsterSearch[0][1] = 29
$MonsterSearch[0][2] = 1248
$MonsterSearch[0][3] = 446
;800x600
$MonsterSearch[1][0] = 40
$MonsterSearch[1][1] = 53
$MonsterSearch[1][2] = 650
$MonsterSearch[1][3] = 400

;1920x1080
$GoldLoot1[0][0] = 402
$GoldLoot1[0][1] = 306
$GoldLoot2[0][0] = 1260
$GoldLoot2[0][1] = 351
$GoldLoot3[0][0] = 911
$GoldLoot3[0][1] = 694
;800x600
$GoldLoot1[1][0] = 96
$GoldLoot1[1][1] = 181
$GoldLoot2[1][0] = 560
$GoldLoot2[1][1] = 191
$GoldLoot3[1][0] = 349
$GoldLoot3[1][1] = 418

;1080P
$LootingArea[0][0] = 318;550
$LootingArea[0][1] = 150;300
$LootingArea[0][2] = 1507;1100
$LootingArea[0][3] = 736;600
;800x600
$LootingArea[1][0] = 75
$LootingArea[1][1] = 90
$LootingArea[1][2] = 630
$LootingArea[1][3] = 400

;1080P
$CharHitBox[0][0] = 790
$CharHitBox[0][1] = 315
$CharHitBox[0][2] = 1200
$CharHitBox[0][3] = 730
;800x600
$CharHitBox[1][0] = 304
$CharHitBox[1][1] = 190
$CharHitBox[1][2] = 468
$CharHitBox[1][3] = 323

;1080P
$DeathBounds[0][0] = 538
$DeathBounds[0][1] = 335
;800x600
$DeathBounds[1][0] = 210
$DeathBounds[1][1] = 180

;1080P
$RepairCords[0][0][0] = 1690
$RepairCords[0][0][1] = 102
$RepairCords[0][1][0] = 930
$RepairCords[0][1][1] = 136
$RepairCords[0][2][0] = 517
$RepairCords[0][2][1] = 483
$RepairCords[0][3][0] = 223
$RepairCords[0][3][1] = 592
;800x600
$RepairCords[1][0][0] = 691
$RepairCords[1][0][1] = 88
$RepairCords[1][1][0] = 505
$RepairCords[1][1][1] = 52
$RepairCords[1][2][0] = 282
$RepairCords[1][2][1] = 261
$RepairCords[1][3][0] = 157
$RepairCords[1][3][1] = 329

;1080P
$RepairCheck[0][0] = 1507
$RepairCheck[0][1] = 36
;800x600
$RepairCheck[1][0] = 573
$RepairCheck[1][1] = 21

;Gem stuff
$Amethyst = 0xAC7FFF
$Ruby = 0xB01D2D
$Emerald = 0x58EE33
$Topaz = 0xFFFF59

$GemLootOffset[0] = 100
$GemLootOffset[1] = 40


HotKeySet("z", "Terminate")


Func Terminate()
    Exit 0
 EndFunc
 
Opt('MouseCoordMode', 2)
Opt('PixelCoordMode', 2)
HotKeySet('{END}', 'Quit')
HotKeySet('{SPACE}', 'Pause')
Global $Paused

;bot starts paused. press space to start.
Pause()

;Finding loot takes time. We don't want to overdo it
$LootAttempts = 0
$GemLootAttempts = 0

WinActivate('Diablo III')
While 1
   If WinActive('Diablo III') Then 
	  ConsoleWrite("IN D#")
	  
	  $AltCellarLocation = False
	  $LootAttempts = 0
	  $GemLootAttempts = 0
	  
	  ;Make sure that we are in the character selection screen ( we are looking at a spot in the Resume game button)
	  for $i = 15 To 0 step -1
		 if InGameLobby() Then
			ExitLoop
		 EndIf
		 
		 sleep(600)
		 if $i == 1 Then
			MsgBox(4096, "Error Resuming Game", "You don't seem to be in the lobby. Did you properly configure the bot? Bot will now exit", 50)
			Terminate()
		 EndIf
	  Next
	  
	   ;Resume the game
      Click($Resume[$R][0], $Resume[$R][1])
      
	   ;Make sure that we are in the game 
	  for $i = 12 To 0 step -1
		 if InGameplayScreen() Then
			ExitLoop
		 EndIf
		 
		 sleep(1000)
		 if $i == 1 Then
			MsgBox(4096, "Error Starting the Game", "The game did not properly load...Are you using English language? Do not use custom themes!", 50)
			Terminate()
		 EndIf
	  Next
	  
	   
	  Rest(200)
	  Send("{2}")				
	  Rest(400)
	  
	  ;Custom running for the 800x600. Sometimes I wonder if it's faster to just buy everyone a 1080P monitor...
	  if Int($R) == 1 Then
		 MouseMove(11, 220)
		 Sleep(400)
		 Send("{4}")
		 MouseDown("middle")
		 Sleep($RunTime)
		 
		 MouseUp("middle")
		 Sleep(2000)
		 
		 #cs $CellarIcon = PixelSearch(630, 70, 741, 149, 0x71341A, 5)
		 if not @error then
			ConsoleWrite("Foundtheseller" & @LF)
			
		 EndIf
		 #ce
		 
	 Else
		 Move($Loc1[$R][0], $Loc1[$R][1])
		 Sleep(200)
		 Send("{4}")
		 Sleep(700)
		 Move($Loc2[$R][0], $Loc2[$R][1]) 
		 Sleep(1100)
		 Move($Loc3[$R][0], $Loc3[$R][1])
	  EndIf
	  
	  
	  ;Check to see if the cellar is there ```````
	  MouseMove($CellarLocation[$R][0], $CellarLocation[$R][1])
	  Sleep(400)
	  if Int($R) = 1 then
		  $CellarPixel = PixelSearch($CellarLocation[$R][0]-30, $CellarLocation[$R][1]-30,$CellarLocation[$R][0]+20,$CellarLocation[$R][1]+20, 0x93D7F9,8)
		  
		  if @error Then
			 MouseMove($CellarLocation2[0], $CellarLocation2[1])
			 Sleep(300)
			 $CellarPixel = PixelSearch($CellarLocation2[0]-30, $CellarLocation2[1]-30,$CellarLocation2[0]+20,$CellarLocation2[1]+20, 0x93D7F9,8)
			 if not @error Then
				$AltCellarLocation = True
			 EndIf
		 EndIf
	  Else
		  $CellarPixel = PixelSearch($CellarLocation[$R][0]-$CellarOffset[$R], $CellarLocation[$R][1]-$CellarOffset[$R],$CellarLocation[$R][0]+4,$CellarLocation[$R][1]+4, 0x334FB7,6)
	  EndIf
   
	  ;Leave the game if the Cellar is not there
	  if @error Then
		 ConsoleWrite("Did not find the cellar " & @LF)
		 Send("{SHIFTDOWN}")
		 sleep(10)
		 click(300,300)
		 sleep(100)
		 Send("{SHIFTUP}")
		 leaveGame()
		 Sleep(10000)
		 ContinueLoop
	  EndIf
	  
	  ;Enter the cellar
	  ConsoleWrite("Entering the Cellar..." & @LF)
	  if $R > 0 AND $AltCellar Then
		 Click($CellarLocation2[$R][0] - 4, $CellarLocation2[$R][1] - 4)
	  Else
		 if not $AltCellarLocation Then
			Click($CellarLocation[$R][0], $CellarLocation[$R][1])
		 Else
			Click($CellarLocation2[0], $CellarLocation2[1])
		 EndIf
	  endif
	  
	  if Int($R) == 1 Then
		 sleep(500+$ComputerLag)
	  Else
		 Sleep(2500 + $ComputerLag)
	  EndIf
	  
	   ;Check to see if we died
	  if CheckForDeath() Then
		 ContinueLoop
	  EndIf
	   
	  ;Inside the celler now - Move to the doorway
	  Move($Loc5[$R][0], $Loc5[$R][1])
	  Sleep(1500)
	  Move($Loc6[$R][0], $Loc6[$R][1])
	  sleep(10)
	  MouseMove($MonsterLoc[$R][0],$MonsterLoc[$R][1])
	  Sleep(300)

	  ;Cast spell some spells on them
	  Send("{3}")
	  Sleep(350)
	  send("{1}")
	  sleep(350)
	  

	  ;Kill all the enemies inside
	  while 1
		 
		 $MonsterBar =  PixelSearch($MonsterSearch[$R][0], $MonsterSearch[$R][1], $MonsterSearch[$R][2], $MonsterSearch[$R][3], 0xEE0000, 10)
		 if @error Then
			ConsoleWrite("Didn't find any, attacking to discover potential enemies" & @LF)
			Attack($MonsterLoc[$R][0],$MonsterLoc[$R][1])
			sleep(500)
			$MonsterBar =  PixelSearch($MonsterSearch[$R][0], $MonsterSearch[$R][1], $MonsterSearch[$R][2], $MonsterSearch[$R][3], 0xEE0000, 10)
			if @error Then
			   ConsoleWrite("No monsters found - Moving on")
			   ExitLoop
			EndIf
		 EndIf
		 
		 ;if CheckForNearbyMonsters() Then
			;send("{4}")
		 ;EndIf
		 
		 for $i = 7 To 0 step -1
			Attack($MonsterBar[0], $MonsterBar[1])
			Sleep(100)
		  Next
	  WEnd
	  
	  
	  ;Loot the gold and attack anything we missed
	  Move($GoldLoot1[$R][0], $GoldLoot1[$R][1])
	  Sleep(Random(800, 900))
	  AttackNearbyMonsters()
	  Move($GoldLoot2[$R][0], $GoldLoot2[$R][1])
	  Sleep(Random(400,500))
	  AttackNearbyMonsters()
	  Move($GoldLoot3[$R][0], $GoldLoot3[$R][1])
	  sleep(Random(400,500))
	  AttackNearbyMonsters()
	  
	  ;Loot items
	  if $LootRares then
		 LootRares()
		 $LootAttempts = 0
		 LootLegendaries()
		 $LootAttempts  = 0
	  EndIf
	  
	  if $LootBlues Then
		 $LootAttempts  = 0
		 LootMagic()
	  EndIf
	  
	  if $LootGems Then
		 LootGems()
	  EndIf
		 
	  
	  ;Check to see if we died
	  if CheckForDeath() Then
		 ContinueLoop
	  EndIf


	  ;Teleport to town
	  send("{t}")
	  sleep(8000)
	  
	  ;Repair if needed
	  if $Repair then
		 RepairItems()
	  EndIf
	  
	  ;Leave the game
	  LeaveGame()
	  Sleep(1000)

   EndIf
WEnd

Func CheckForRepair()
   $RepairNeeded = PixelSearch($RepairCheck[$R][0],$RepairCheck[$R][1], $RepairCheck[$R][0]+5, $RepairCheck[$R][1]+5, 0xFFE801,10)
   
   if Not @error Then
	  return True
   Else
	  return False
   EndIf
EndFunc
   
   
Func RepairItems()
   if not CheckForRepair() Then
	  Return
   EndIf
   
   Move($RepairCords[$R][0][0] , $RepairCords[$R][0][1])
   Sleep(2700+$ComputerLag)
   MouseMove($RepairCords[$R][1][0] , $RepairCords[$R][1][1])
   Sleep(400)
   Click($RepairCords[$R][1][0] , $RepairCords[$R][1][1])
   sleep(2200+$ComputerLag)
   click($RepairCords[$R][2][0] , $RepairCords[$R][2][1])
   Sleep(Random(700-900))
   Click($RepairCords[$R][3][0] , $RepairCords[$R][3][1])
   Sleep(500)
   send("{esc}")
   
EndFunc


Func LeaveGame()
   send("{esc}")
   Sleep(400)
   Click($Leave[$R][0], $Leave[$R][1])
EndFunc

Func Pause()
   $Paused = Not $Paused
   While $Paused
      Sleep(100)
      ToolTip('Paused... (Press Space to run it)', 0, 0)
   WEnd
   ToolTip("")
EndFunc   ;

Func Click($x, $y)
   MouseClick('left', Random($x - 3, $x + 3), Random($y - 3, $y + 3), 1, Random(0, 1))
   Sleep(Random(1000, 1500))
EndFunc 

Func Move($x, $y)
   MouseClick('middle', Random($x - 3, $x + 3), Random($y - 3, $y + 3), 1, Random(0, 1))
   Sleep(Random(1000, 1500))
EndFunc  

Func Attack($x, $y)
   MouseClick('right', Random($x - 3, $x + 3), Random($y - 3, $y + 3), 1, Random(0, 1))
EndFunc		

Func Rest($z)
   Sleep(Random($z, $z+25))
EndFunc

Func CheckForDeath()
   ConsoleWrite("Checking to see if we died")
   $Death = PixelSearch($DeathBounds[$R][0], $DeathBounds[$R][0], $DeathBounds[$R][0]+4, $DeathBounds[$R][0]+4, 0xFFFFFF) 
   if not @error Then
	  ConsoleWrite("Died" & @LF)
	  LeaveGame()
	  Sleep(12000)
	  return True
   Else
	  return False
   EndIf
EndFunc


Func LootMagic()
   $Magic = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3], 0x6969FF, 4) ; 
   If not @error Then
	  ConsoleWrite("Found a blue")
	  Click($Magic[0]+5, $Magic[1]+2)
	  Sleep(Random(800,1000))
   EndIf
   $LootAttempts+=1
   if($LootAttempts > 5) then 
	  Return
   Else
	  LootMagic()
   EndIf
EndFunc
   

Func LootRares()
   $Rare = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3], 0xBBBB00, 4) ; 
   If not @error Then
	   ConsoleWrite("Found a rare")
	  Click($Rare[0]+5, $Rare[1]+2)
	  Sleep(Random(800,1000))
   EndIf
   
   $LootAttempts+=1
   if($LootAttempts > 5) then 
	  Return
   Else
	  LootRares()
   EndIf
EndFunc
   


Func LootLegendaries()
    ConsoleWrite("Found a legendary")
   $Legendary = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3],0xBF642F, 2) ; 
   If not @error Then
	  Click($Legendary[0]+5, $Legendary[1]+2)
	  Sleep(Random(800,1000))
   EndIf
   
    $set = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][2], 0x02CE01, 2) ; 
	 ConsoleWrite("Found a set")
	If not @error Then
	  Click($set[0]+5, $set[1]+2)
	  Sleep(Random(800,1000))
   EndIf
	  
   $LootAttempts+=1
   if($LootAttempts > 3) then 
	  Return
   Else
	  LootRares()
   EndIf
EndFunc

#CS
$Amethyst = 0xAC7FFF
$Ruby = 0xB01D2D
$Emerald = 0x58EE33
$Topaz = 0xFFFF59
#ce
Func LootGems()
   $Gem = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3],$Ruby,6) ; 
   If not @error Then
	  ConsoleWrite("Found a Ruby!" & @LF)
	  $Gem = PixelSearch($Gem[0] - 20, $Gem[1], $Gem[0] + 20, $Gem[1] - $GemLootOffset[$R], 0xFFFFFF)
	  If not @error Then
		 Click($Gem[0], $Gem[1])
		 Sleep(Random(400,600))
	  EndIf
   EndIf
   
   $Gem = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3],$Amethyst,8) ; 
   If not @error Then
	  ConsoleWrite("Found an $Amethyst!" & @LF)
	 $Gem = PixelSearch($Gem[0] - 20, $Gem[1], $Gem[0] + 20, $Gem[1] - $GemLootOffset[$R], 0xFFFFFF)
	  If not @error Then
		 Click($Gem[0], $Gem[1])
		 Sleep(Random(400,600))
	  EndIf
	  
   EndIf
   
   $Gem = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3],$Emerald,11) ; 
   If not @error Then
	  ConsoleWrite("Found am Emerald!" & @LF)
	 $Gem = PixelSearch($Gem[0] - 20, $Gem[1], $Gem[0] + 20, $Gem[1] - $GemLootOffset[$R], 0xFFFFFF)
	  If not @error Then
		 Click($Gem[0], $Gem[1])
		 Sleep(Random(400,600))
	  EndIf
   EndIf
   
   $Gem = PixelSearch($LootingArea[$R][0], $LootingArea[$R][1], $LootingArea[$R][2], $LootingArea[$R][3],$Topaz,2) ; 
   If not @error Then
	  ConsoleWrite("Found a Topaz!" & @LF)
	 $Gem = PixelSearch($Gem[0] - 20, $Gem[1], $Gem[0] + 20, $Gem[1] - $GemLootOffset[$R], 0xFFFFFF)
	  If not @error Then
		 Click($Gem[0], $Gem[1])
		 Sleep(Random(400,600))
	  EndIf
   EndIf

	  
   $GemLootAttempts+=1
   if($GemLootAttempts > 3) then 
	  Return
   Else
	  LootGems()
   EndIf
EndFunc



Func AttackNearbyMonsters()
   while 1
	  $MonsterData =  PixelSearch($CharHitBox[$R][0],$CharHitBox[$R][1],$CharHitBox[$R][2],$CharHitBox[$R][3], 0xEE0000, 10)
		 if @error Then
			ExitLoop
		 EndIf
	  
	  send("{4}")
	  sleep(300)
	  for $i = 10 To 0 step -1
		 Attack($MonsterData[0], $MonsterData[1])
		 Sleep(100)
	  Next
   WEnd
EndFunc

Func CheckForNearbyMonsters()
   $MonsterData =  PixelSearch($CharHitBox[$R][0],$CharHitBox[$R][1],$CharHitBox[$R][2],$CharHitBox[$R][3], 0xEE0000, 10)
   if @error Then
	  return False
   Else
	   return True
	EndIf
 EndFunc


Func SnareNearbyEnemies()
   $MonsterData =  PixelSearch($CharHitBox[$R][0],$CharHitBox[$R][1],$CharHitBox[$R][2],$CharHitBox[$R][3], 0xEE0000, 10)
   if not @error Then
	   MouseMove($MonsterData[0], $MonsterData[1])
	   Sleep(350)
	   Send("{3}")
	   sleep(250)
	EndIf
 EndFunc
 
 
 Func InGameLobby()
	MouseMove($GameLobbyCode[$R][0],$GameLobbyCode[$R][1])
	Sleep(300)
	PixelSearch($GameLobbyCode[$R][0],$GameLobbyCode[$R][1],$GameLobbyCode[$R][0]+10,$GameLobbyCode[$R][1]+10, $GameLobbyCode[$R][2], 10)
    if not @error Then
	   return True
	Else
	   return False
   EndIf
EndFunc

 Func InGameplayScreen()
	PixelSearch($GameScreenCode[$R][0],$GameScreenCode[$R][1],$GameScreenCode[$R][0]+4,$GameScreenCode[$R][1]+3, $GameScreenCode[$R][2], 10)
	if not @error Then
	   return True
	Else
	   return False
   EndIf
EndFunc


Func ActivateGUI()

   ;setup the UI
   $Waiting = True

   $Form1 = GUICreate("D3 Witch Doctor bot by Avatar88343", 400, 200, -1, -1)
   
   $ResLabel = GUICtrlCreateLabel("Game Resolution", 100, 30, 100, -1)
   $ResCombo = GUICtrlCreateCombo("", 100, 45, 200, -1)
   GUICtrlSetData($ResCombo, "1920 x 1080|800 x 600", "Select your Res")
   
   $Runabel = GUICtrlCreateLabel("Character run speed (for 800x600)", 100, 75, 200, -1)
   $RunInput = GUICtrlCreateInput("0" , 100, 90, 200, -1)
   
   $LootRareCheck = GUICtrlCreateCheckbox("Loot Rares",25,130,100,20)
   GUICtrlSetState($LootRareCheck, $GUI_CHECKED)
   
   $LootBluesCheck = GUICtrlCreateCheckbox("Loot Blues",125,130,100,20)
   GUICtrlSetState($LootRareCheck, $GUI_CHECKED)
   
   $LootGemsCheck = GUICtrlCreateCheckbox("Loot Gems (beta)",225,130,100,20)
   
   $RepairCheckbox = GUICtrlCreateCheckbox("Repair",325,130,100,20)
   GUICtrlSetState($RepairCheckbox, $GUI_CHECKED)
   
   $StartButton = GUICtrlCreateButton("Start", 125, 160, 150, 33)
	
   GUISetState(@SW_SHOW)
   
   ;Wait for them to press start
   while $Waiting
	  $Action = GUIGetMsg()
	  
	  if $Action = $GUI_EVENT_CLOSE then Terminate()
	  if $Action = $StartButton then ExitLoop
	  
	  sleep(50)
   WEnd
   
   ;Get the values
   $SelectedRes = GUICtrlRead($ResCombo)
   if $SelectedRes = "1920 x 1080" Then
	  $R = 0
   ElseIf $SelectedRes = "800 x 600" Then
	  $R = 1
   Else
	  msgbox(0,"Error","You did not select a resolution! Try again")
	  Terminate()
   EndIf
   
   $Runspeed = int(GUICtrlRead($RunInput))
   $LootRares = GuiCtrlRead($LootRareCheck) = $GUI_CHECKED
   $LootBlues = GuiCtrlRead($LootBluesCheck) = $GUI_CHECKED
   $Repair = GuiCtrlRead($RepairCheckbox) = $GUI_CHECKED
   $LootGems = GuiCtrlRead($LootGemsCheck) = $GUI_CHECKED
   
    GUISetState(@SW_HIDE)
EndFunc   
