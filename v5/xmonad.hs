{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses #-}
--{{{ COMMENT
{-
__  ___ __ ___   ___  _ __   __ _  __| |   ___ ___  _ __  / _(_) __ _ 
 \ \/ / '_ ` _ \ / _ \| '_ \ / _` |/ _` |  / __/ _ \| '_ \| |_| |/ _` |
  >  <| | | | | | (_) | | | | (_| | (_| | | (_| (_) | | | |  _| | (_| |
 /_/\_\_| |_| |_|\___/|_| |_|\__,_|\__,_|  \___\___/|_| |_|_| |_|\__, |

 1. the way to find window name : run `xprop` then click the window to find class name with it's output
 2. methords to find the key's name use:  xev | sed -ne '/^KeyPress/,/^$/p' then press the key

in order to make all keyboard shortcuts make effect, the software/scripts need to be installed/configed first
 software:
    » #xmobar               status bar
    » #xterm                default terminal                                                
    » #xterm                favorite terminal                                                
    » #xpad                 stickypad
    » #dmenu                run program                                            
    » #rofi                 app launch with icons
    » #xcolor               simple color picker
    » #screenkey            show keypress
    » #slock                lock screen
    » #peek                 gif tool(optional)                                             
    » #xdotool              make xmobar clickable
    » #xmodmap              exchange defaults key
    » #mpv                  voice for script
    » #xclip                clipboard
    » #feh                  set wallpaper
    » #nerd-fonts-iosevka   font setting, important. without it may not work normally
    » #xorg-xsetroot        cursor style setting
    » #ddcutil              adjust external monitor brightness
    » #dunst                notify tool
    » #picom-jonaburg-git   window effect
    » #ydcv-rs-git          translate word
    » #crow-translate       translate sentense
    » #flameshot            screenshot gui tool                             
    » #ffcast               quick full screenshot
    » #pamixer              adjust volume                                               
    » #firefox              browser
    » #virtualbox           virtual machine                                                  
    » #qemu                 quick emulator
    » #fcitx5               typing method for chinese
    
 scripts:
    » #screen-brightness    adjust screen brightness
    » #screen-capture       take fullscreen shot
    » #change-transparency  change window transparency
    » #translate            translate words/sentenses                                           
    » #showkey              display key touch                                         
    » #wallpaper            change desktop wallpaper                                        
    » #dm-translate         translate words/sentenses                                           
    » #dm-kvm               choose kvm image to start
    » #dm-rotate-screen     rotate screen
    » #dm-search-in-firefox search engine and bookmark
    » #dm-run               quick search history command and execute

-}
--}}}

--{{{ IMPORT MODULES
import System.IO                            -- 
import Control.Monad (forM_, join)          -- 
import XMonad                               -- 
import qualified XMonad.StackSet as W       -- 

import Data.List (sortBy)                   -- 
import Data.Function (on)                   -- 
import Data.Maybe (fromJust)                -- 
import qualified Data.Map as M              -- 

import XMonad.Hooks.ManageHelpers           -- 
import XMonad.Hooks.ManageDocks             -- toggle xmobar hidden
import XMonad.Hooks.InsertPosition          -- choose new window position
import XMonad.Hooks.StatusBar.PP            -- new feature in 0.17
import XMonad.Hooks.EwmhDesktops            -- 
import XMonad.Hooks.PositionStoreHooks      -- store float window position
import XMonad.Hooks.WindowSwallowing        -- window swallow with child window
import XMonad.Hooks.Modal                   -- no need for modkey press
import XMonad.Hooks.UrgencyHook		        -- show urgent window

import XMonad.Util.NamedScratchpad          -- scratchpad
import XMonad.Util.Run                      -- communicate with xmobar 
import XMonad.Util.EZConfig                 -- set short keys
import XMonad.Util.SpawnOnce                -- run startup app

import XMonad.Actions.MouseGestures         --  mouse gesture setting
import XMonad.Actions.CopyWindow            -- copy window to all
import XMonad.Actions.WithAll               -- make effort for all windows
import XMonad.Actions.NoBorders             -- toggle borders
import XMonad.Actions.Submap                -- create a sub-mapping of key bindings
import XMonad.Actions.CycleWS               -- move/cycle windows between workspaces
import XMonad.Actions.FloatSnap             -- snap window to other windows' edge
import XMonad.Actions.GroupNavigation       -- cycle though group of windows across WS
import qualified XMonad.Actions.FlexibleResize as Flex  -- resize floating window from any corner

import XMonad.Layout.LayoutCombinators      -- 
import XMonad.Layout.Decoration             -- 
import XMonad.Layout.Spacing                -- set edge space of window
import XMonad.Layout.NoBorders              -- used in fullscreen
import XMonad.Layout.Maximize               -- toggle fullscreen
import XMonad.Layout.SubLayouts             -- sub layout
import XMonad.Layout.WindowNavigation	    -- navigate winow for sublayout
import XMonad.Layout.Tabbed                 -- sub layout tab
import XMonad.Layout.Simplest               -- sub layout style
import XMonad.Layout.NoFrillsDecoration     -- set windows titlebar
import XMonad.Layout.PerWorkspace           -- diff workspace has diff layout
import XMonad.Layout.MultiToggle            -- use keybinding to toggle layout
import XMonad.Layout.MultiToggle.Instances  -- base toggle layout such as mirror
import XMonad.Layout.ResizableTile          -- allow adjust vertical height
import XMonad.Layout.ThreeColumns           --  three columns style
import XMonad.Layout.Accordion              -- put window as ribbon
import XMonad.Layout.Cross                  -- cycle one master in center
import XMonad.Layout.PositionStoreFloat     -- float window
import XMonad.Layout.OneBig                 --  master at left top
---}}}

--{{{ define variables
-- myTerminal              = "urxvtc"
myTerminal              = "kitty --single-instance"
_M4                     = mod4Mask
_M1                     = mod1Mask
myBorderWidth           = 2
myNormalBorderColor     = "#1a1b26" 
myFocusdBorderColor     = "#404b78" 
myTabActiveColor        = "#782929" -- "#445caf"
myTabInactiveColor      = "#010202" 
myTabFont               = "xft:Iosevka Nerd Font-16"
--}}}

--{{{ my configuration
myDef xmproc = def 
            { modMask               = _M4
            , borderWidth           = myBorderWidth
            , normalBorderColor     = myNormalBorderColor
            , focusedBorderColor    = myFocusdBorderColor
            , terminal              = myTerminal
            , clickJustFocuses      = False
            , focusFollowsMouse     = False
            , layoutHook            = avoidStruts $ myLayoutHook 
            , workspaces            = myWorkspaces
            , startupHook           = myStartupHook
            , mouseBindings         = myMouseBindings 
            , manageHook            = positionStoreManageHook Nothing <+> myManageHook <+> namedScratchpadManageHook myScratchPads
            , handleEventHook       = swallowEventHook (className =? "Kitty"  <||> className =? "XTerm") (return True) 
            , logHook               = myLogHook xmproc
            } `additionalKeys` myKeys
--}}}

--{{{ define workspace for xmobar
myWorkspaces = [ " " ++ x ++ " " | x <- map show [1..9] ]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..9] 
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-- filter out scratchpad workspace help us to toggle recent workspace without NSP
myLogHook xmproc = dynamicLogWithPP . filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
                { ppOutput          = hPutStrLn xmproc
                , ppCurrent         = xmobarColor "#e0e0e0" "#292e42" . pad -- #8abeb7
                , ppHidden          = xmobarColor "#e0e0e0" "#171a26" . pad . clickable
                , ppHiddenNoWindows = xmobarColor "#70788d" ""  . clickable
                , ppTitle           = xmobarColor "#b0b0b0" "#292e42" . shorten' " " 150 . wrap " " (take 150 $ cycle " ")
                , ppLayout          = xmobarColor "#c1c5c5" "" . shorten 10
                , ppUrgent          = xmobarColor "#171d35" "#54b530" . pad . clickable
                , ppSep             = " "
                , ppOrder           = \(ws:_:t:_) -> [ws] ++ [t] -- ++ [l]
                }
--- --}}}

--{{{ layout style
myLayoutHook = windowNavigation 
	        $ maximizeWithPadding 0
            $ onWorkspace " 9 " (spacingWithEdge 0 $ noBorders Full)
            $ mkToggle (single MYTAB)
            $ myborder
mytab = 
  noFrillsDeco shrinkText topBarTheme
  $ noBorders
  $ addTabs shrinkText myTabTheme
  $ subLayout [0,1,2] (Simplest)
  $ spacingRaw False (Border 6 6 6 6) True (Border 6 6 6 6) True -- top bottom right left
  $ mkToggle (single MIRROR)
  $ rst ||| three ||| Accordion ||| simpleCross ||| positionStoreFloat ||| oB
  where 
      rst         = ResizableTall 1 (1/100) 0.55 [] 
      three       = ThreeColMid 1 (3/100) (1/2)
      oB          = OneBig (3/4) (3/4)
myborder = 
  spacingRaw False (Border 6 6 6 6) True (Border 6 6 6 6) True -- top bottom right left
  $ mkToggle (single MIRROR)
  $ smt ||| three ||| Accordion ||| simpleCross ||| positionStoreFloat ||| oB
  where 
      smt         = ResizableTall 1 (1/100) 0.55 [] 
      three       = ThreeColMid 1 (3/100) (1/2)
      oB          = OneBig (3/4) (3/4)

data MYTAB = MYTAB deriving (Read, Show, Eq)
instance Transformer MYTAB Window where
    transform _ x k = k mytab (const x)
---}}}

--{{{ startup app when xmonad starts
myStartupHook :: X ()
myStartupHook = do
        spawnOnce "xsetroot -cursor_name left_ptr"
	    -- spawnOnce "sync-task &"
	    -- spawnOnce "urxvtd --quiet --opendisplay --fork"
--}}}

--{{{ define how window shows up
myManageHook = composeOne 
            [ checkDock                                                 -?> doIgnore 
            , isDialog                                                  -?> doFloat
            , className =? "Gimp"                                       -?> doFloat
            , className =? "Peek"                                       -?> doFloat
            , className =? "Yad"                                        -?> doFloat
            , className =? "pentablet"                                  -?> doFloat
            , className =? "Note"                                       -?> doFloat
            , className =? "SpeedCrunch"                                -?> doFloat
            , className =? "firefox-bin"                                -?> doFocus <+> shiftToSame' pid
            , className =? "firefox"	                                -?> shiftToSame' pid
            , title     =? "About Mozilla Firefox"                      -?> doFloat
            , className =? "MPlayer"                                    -?> doF W.swapDown
            , return True                                               -?> doF W.swapDown
            ]
--}}}

--{{{ key binding
-- use 0 instead modkey can let a single key press without modkey which is very useful
myKeys =
-- basic window/workspace operation
    [ ((_M4, xK_grave), setMode noModModeLabel)                                    -- toggle no mod key needed until press esc again
    , ((_M4, xK_Return), windows W.swapMaster)                                     -- move window to master(def)
    , ((_M4, xK_f), withFocused (sendMessage . maximizeRestore) >> withFocused toggleBorder)      -- toggle full window
    , ((_M1, xK_Tab), toggleWS' ["NSP"])                                           -- toggle recent workspaces with NSP filtered
    , ((_M4, xK_h), moveTo Prev $ anyWS :&: ignoringWSs [scratchpadWorkspaceTag])  -- go to next workspace exclude nsp
    , ((_M4, xK_l), moveTo Next $ anyWS :&: ignoringWSs [scratchpadWorkspaceTag])  -- go to previous workspace exclude nsp
    , ((_M4 .|. _M1, xK_h), sendMessage Shrink)                                    -- shrink master window space
    , ((_M4 .|. _M1, xK_l), sendMessage Expand)                                    -- expand master window space
    , ((_M4 .|. _M1, xK_j), sendMessage MirrorShrink)                              -- vertical shrink window
    , ((_M4 .|. _M1, xK_k), sendMessage MirrorExpand)                              -- vertical expand window
    , ((_M4, xK_equal), decWindowSpacing 4)                                        -- Decrease window spacing
    , ((_M4, xK_minus), incWindowSpacing 4)                                        -- Increase window spacing
    , ((_M4, xK_p), spawn "dmenu_run -fn 'monospace:size=15' -l 6")                -- launch application via dmenu
    , ((_M4, xK_BackSpace), kill)                                                  -- kill window
    , ((_M4 .|. shiftMask, xK_BackSpace), killAll)			           -- kill all windows in current WS
    , ((_M4, xK_v), dynamicNSPAction "dynamicScratch")                             -- toggle newly created scratchpad
    , ((_M4 .|. shiftMask, xK_v), withFocused $ toggleDynamicNSP "dynamicScratch") -- toggle window to a tmp scratchpad
    , ((_M4, xK_y), windows copyToAll)					           -- copy window to all WS
    , ((_M4 .|. shiftMask, xK_y), killAllOtherCopies)			           -- delete all other copy windows
    , ((_M4, xK_x), withFocused float)                                      	   -- float window
    , ((_M4 .|. shiftMask, xK_t), sinkAll)			                   -- unfloat all windows in current WS
    , ((_M4, xK_b), withFocused toggleBorder)                                      -- toggle window border
    , ((_M4 .|. shiftMask, xK_b), withAll toggleBorder)			           -- toggle all windows border in current WS
    , ((_M4, xK_semicolon), namedScratchpadAction myScratchPads "pop-up-terminal" )-- convenient scratchpad
    , ((_M4, xK_u), focusUrgent)					           -- focus urgent window
    , ((_M4 .|. shiftMask, xK_u), clearUrgents)					   -- clear urgent tag
    , ((_M4, xK_g), moveTo Next emptyWS)			                   -- go to next empty workspace
    , ((_M4 .|. shiftMask, xK_g), shiftTo Next emptyWS)			           -- shift window to next empty workspace
    , ((_M4 .|. controlMask, xK_j), nextMatchWithThis Forward  className)	   -- go to next matched group window
    , ((_M4 .|. controlMask, xK_k), nextMatchWithThis Backward className)	   -- go to prev matched group window
  
-- sub key "\"
    , ((_M4 , xK_backslash), submap . M.fromList $
       [ ((0 , xK_b), sendMessage ToggleStruts)                                    -- toggle status bar
       , ((0 , xK_s), toggleScreenSpacingEnabled >> toggleWindowSpacingEnabled)    -- toggle space (combine two functions)
       , ((0 , xK_c), namedScratchpadAction myScratchPads "speedCrunch")           -- toggle speedcrunch
       , ((0 , xK_p), namedScratchpadAction myScratchPads "scratchNote")           -- toggle notepad
       ])
-- sub key "z" sub group window
    , ((_M4 , xK_z), submap . M.fromList $                                         
       [ ((0 , xK_h), sendMessage $ pullGroup L)                                   -- group left window
       , ((0 , xK_l), sendMessage $ pullGroup R)                                   -- group right window
       , ((0 , xK_k), sendMessage $ pullGroup U)                                   -- group up window
       , ((0 , xK_j), sendMessage $ pullGroup D)                                   -- group down window
       , ((0 , xK_m), withFocused (sendMessage . MergeAll))                        -- group all windows
       , ((0 .|. shiftMask, xK_m), withFocused (sendMessage . UnMergeAll))         -- ungroup all windows
       , ((0 , xK_u), withFocused (sendMessage . UnMerge))                         -- ungroup focus window
       ])
-- sub key "a" toggle/jump layout
    , ((_M4 , xK_a), submap . M.fromList $
       [ ((0 , xK_m), sendMessage $ Toggle MIRROR)
       , ((0 , xK_b), sendMessage $ Toggle MYTAB)
       , ((0 , xK_a), sendMessage $ JumpToLayout "Accordion")
       , ((0 , xK_c), sendMessage $ JumpToLayout "Cross")
       , ((0 , xK_p), sendMessage $ JumpToLayout "PSF")
       , ((0 , xK_t), sendMessage $ JumpToLayout "ThreeCol")
       , ((0 , xK_o), sendMessage $ JumpToLayout "OneBig 0.75 0.75")
       , ((0 , xK_r), sendMessage $ JumpToLayout "ResizableTall")
       ])
    ]
--}}}

--{{{ mouse binding + gesture
myMouseBindings (XConfig {XMonad.modMask = _M4 }) = M.fromList $
    [ ((_M4 , button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove (Just 20) (Just 20) w)))           -- mod+button1 move window with edge snap
    , ((_M4 , button3), (\w -> focus w >> Flex.mouseResizeEdgeWindow 0.6 w >> afterDrag (snapMagicResize [R,D] (Just 20) (Just 20) w))) -- mod+button3 resize window from any corner or edge with edge snap
    , ((_M1, button3), mouseGesture gestures) -- mouse gesture support
    ]
    where --  mouse gesture
        gestures = M.fromList
                [ ([], focus)
                , ([U], \w -> focus w >> withFocused (sendMessage . maximizeRestore)) -- up
                , ([D], \w -> focus w >> namedScratchpadAction myScratchPads "pop-up-terminal") -- down
                , ([R], \w -> focus w >> prevWS)    -- right
                , ([L], \w -> focus w >> nextWS)    -- left
                , ([R, D], \_ -> sendMessage NextLayout)    -- right_down
                ]
--}}}

--{{{ scratch window
---scratchTerm = "xterm -name spnote -e sh -c 'nvim ~/.local/usr/data/content'"
---scratchTerm = "urxvtc -name spnote -e sh -c 'nvim ~/.local/usr/data/content'"
scratchTerm = "kitty -1 --class spnote nvim ~/.local/usr/data/content"
---popupTerminal = "xterm -s"
---popupTerminal = "urxvtc"
popupTerminal = "kitty -1 --class popTerm"
myScratchPads = [ NS "pop-up-terminal" spawnTerminal  findTerminal manageTerminal
                , NS "speedCrunch" spawnSpeedCh  findSpeedCh manageSpeedCh
		, NS "scratchNote" spawnNote  findNote manageNote
		]
                where
                    --spawnTerminal = popupTerminal ++ " -name popTerm"
                    spawnTerminal = popupTerminal
                    findTerminal = resource =? "popTerm"
                    manageTerminal = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.70, 0.80, 0.15, 0.10)
                    spawnSpeedCh = "speedcrunch" 
                    findSpeedCh = className =? "SpeedCrunch"
                    manageSpeedCh = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.50, 0.20, 0.20, 0.60)
		    spawnNote = scratchTerm 
                    findNote = resource =? "spnote"
                    manageNote = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.70, 0.80, 0.15, 0.10)
--}}}

--{{{ top bar theme
topBarTheme = def
    { activeColor           = myTabActiveColor 
    , activeBorderColor     = myTabActiveColor
    , activeTextColor       = myTabActiveColor
    , inactiveColor         = myTabInactiveColor
    , inactiveBorderColor   = myTabInactiveColor
    , inactiveTextColor     = myTabInactiveColor
    , decoHeight            = 5
    , fontName              = myTabFont
    }
myTabTheme = def
    { activeColor           =  myTabActiveColor  
    , activeBorderColor     =  myTabActiveColor  
    , activeTextColor       =  myTabActiveColor   
    , inactiveColor         =  myTabInactiveColor
    , inactiveBorderColor   =  myTabInactiveColor
    , inactiveTextColor     =  myTabInactiveColor
    , decoHeight            = 8
    , fontName              = myTabFont
    }
--}}}

-- main function
main :: IO ()
main = do
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc"
    xmonad 
        . modal [noModMode]
        $ docks 
	$ setEwmhActivateHook doAskUrgent . ewmh 
	-- $ withUrgencyHook NoUrgencyHook
        $ myDef xmproc
