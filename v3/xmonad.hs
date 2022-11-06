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
    » #alacritty            favorite terminal                                                
    » #thunar               file manager                                         
    » #xpad                 stickypad
    » #flameshot            screenshot gui tool                             
    » #ffcast               quick full screenshot
    » #pamixer              adjust volume                                               
    » #dmenu                run program                                            
    » #rofi                 app launch with icons
    » #firefox              browser
    » #virtualbox           virtual machine                                                  
    » #qemu                 quick emulator
    » #slock                screen lock                                          
    » #dunst                notify tool
    » #peek                 gif tool(optional)                                             
    » #xdotool              make xmobar clickable
    » #mpv                  voice for script
    » #xclip                clipboard
    » #ydcv-rs-git          translate word
    » #crow-translate       translate sentense
    » #screenkey            show keypress
    » #feh                  set wallpaper
    » #nerd-fonts-iosevka   font setting, important. without it may not work normally
    » #xautolock            suspend system with specified time
    » #picom-jonaburg-git   window effect
    » #fcitx5               input method
    » #xorg-xsetroot        cursor style setting
    » #xcolor               simple color picker
    » #oneko                a cut cat chases cursor
    
 scripts:
    » #translate            translate words/sentenses                                           
    » #showkey              display key touch                                         
    » #wallpaper            change desktop wallpaper                                        

-}
--}}}

--{{{ IMPORT MODULES
import System.IO
import Control.Monad (forM_, join)

import XMonad ---hiding ( (|||) ) --layout split with |||

import Data.List (sortBy)
import Data.Function (on)
import Data.Maybe (fromJust)

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks  --toggle xmobar hidden
import XMonad.Hooks.InsertPosition  --choose new window position
import XMonad.Hooks.StatusBar.PP --new feature in 0.17
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.PositionStoreHooks --store float window position
import XMonad.Hooks.WindowSwallowing --window swallow with child window
import XMonad.Hooks.Modal --no need for modkey press

import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.NamedScratchpad --scratchpad
import XMonad.Util.Run -- run in term for workspace
import XMonad.Util.EZConfig  --set short keys
import XMonad.Util.SpawnOnce -- run startup app

import XMonad.Actions.WindowMenu -- optional window menu in center
import XMonad.Actions.MouseGestures -- mouse gesture setting
import XMonad.Actions.CopyWindow --copy window to all
import XMonad.Actions.DynamicProjects --goto workspace with apps open up
import XMonad.Actions.WithAll  --make effort for all windows
import XMonad.Actions.NoBorders   --used in all window
import XMonad.Actions.Submap  --create a sub-mapping of key bindings
import XMonad.Actions.CycleWS  --move/cycle windows between workspaces
import XMonad.Actions.FloatSnap --Move and resize floating windows using other windows and the edge of the screen as guidelines. amazing

import XMonad.Layout.Spacing   --set edge space of window
import XMonad.Layout.NoBorders    --used in fullscreen
import XMonad.Layout.Maximize  --toggle fullscreen
import XMonad.Layout.SubLayouts --sub layout
import XMonad.Layout.Tabbed --sub layout tab
import XMonad.Layout.Simplest --sub layout style
import XMonad.Layout.NoFrillsDecoration  --set windows titlebar
import XMonad.Layout.WindowNavigation  --redefine default cycle window keybinding
import XMonad.Layout.PerWorkspace --diff workspace has diff layout
import XMonad.Layout.BorderResize --float window with click border resize

import XMonad.Layout.MultiToggle --use keybinding to toggle layout
import XMonad.Layout.MultiToggle.Instances --base toggle layout such as mirror
import XMonad.Layout.IfMax --nice function for change layout when number of window changes
import XMonad.Layout.ResizeScreen --put one window in center with specified window space
import XMonad.Layout.ResizableTile  --allow adjust vertical height
import XMonad.Layout.Grid -- grid arrange
import XMonad.Layout.ThreeColumns -- three columns style
import XMonad.Layout.Accordion --put window as ribbon
import XMonad.Layout.Cross --cycle one master in center
import XMonad.Layout.PositionStoreFloat --float window
import XMonad.Layout.OneBig

import qualified XMonad.StackSet as W
import XMonad.Layout.Decoration
import XMonad.Util.Types
---}}}

-- define some variables
myTerminal              = "alacritty"
_M4                      = mod4Mask
_M1                      = mod1Mask
myBorderWidth           = 0
myNormalBorderColor     = "#2b3a46" 
myFocusdBorderColor     = "#445caf" 


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
    --, logHook = eventLogHook  --used for polybar
    , manageHook            = positionStoreManageHook Nothing <+> myManageHook <+> namedScratchpadManageHook myScratchPads
    , handleEventHook       = swallowEventHook (className =? "Alacritty"  <||> className =? "Xterm") (return True) 
    , logHook               = myLogHook xmproc
    } `additionalKeys` myKeys

-- define workspace
myWorkspaces = [ " " ++ x ++ " " | x <- map show [1..9] ]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..9] 
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-- filter out scratchpad workspace help us to toggle recent workspace without NSP
myLogHook xmproc = dynamicLogWithPP . filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
    { ppOutput          = hPutStrLn xmproc
    , ppCurrent         = xmobarColor "#171d35" "#8abeb7" . pad
    , ppHidden          = xmobarColor "#171d35" "#70788d" . pad . clickable
    , ppHiddenNoWindows = xmobarColor "#70788d" ""  . clickable
    , ppTitle           = xmobarColor "#171d35" "#c1c5c5" . shorten' " " 60 . wrap " " (take 60 $ cycle " ")
    , ppLayout          = xmobarColor "#c1c5c5" "" . shorten 10
    , ppSep             = " "
    , ppOrder           = \(ws:_:t:_) -> [t] ++ [ws]
    }

-- layout style
myLayoutHook = windowNavigation
            $  maximizeWithPadding 0
            $  borderResize
            $  onWorkspace " 9 " (spacingWithEdge 0 $ noBorders Full)
            $  noFrillsDeco shrinkText topBarTheme
            $  addTabs shrinkText myTabTheme
            -- $  myDecorate
            $  subLayout [0,1,2] (Simplest)
            $  spacingRaw False (Border 16 0 10 10) True (Border 4 0 12 12) True -- top bottom right left
            $  mkToggle (single MIRROR)
            $  mkToggle (single ACCORDION)
            $  mkToggle (single CROSS)
            $  mkToggle (single PST)
            $  mkToggle (single THREE)
            $  mkToggle (single ONE)
            $  mkToggle (single RT)
            -- $  IfMax 3 (IfMax 1 rh tiled) Grid  --- ||| tiled
            $  Accordion -- default when startup
            where 
            -- with smartBorder, it will render no border while there is only one window in a workspace
                rh          = resizeHorizontal 600 $ resizeHorizontalRight 600 $ smt_t
                smt_t       = smartBorders (ResizableTall 1 (1/100) 0.5 [])
                tiled       = ResizableTall 1 (1/100) 0.6 [] 
                three		= ThreeColMid 1 (3/100) (1/2)

-- startup app when xmonad starts
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "xmodmap .Xmodmap"
    spawnOnce "xsetroot -cursor_name left_ptr"
    spawnOnce "fcitx5 &"
    spawnOnce "xmobar &"
    spawnOnce "picom  --experimental-backends --config .config/picom/picom.conf -b"
    spawnOnce "dunst &"
    --spawnOnce "oneko -bg white -fg black -tofocus &"
    --spawnOnce "xautolock -time 180 -locker 'systemctl suspend' -detectsleep"


-- self define toggle layout transformer
data MyTransformer = ACCORDION
                | CROSS
                | PST
                | THREE
                | ONE
                | RT
            deriving (Read, Show, Eq)
instance Transformer MyTransformer Window where
    transform ACCORDION x k = k Accordion (const x)
    transform CROSS x k = k simpleCross (const x)
    transform PST x k = k positionStoreFloat (const x)
    transform THREE x k = k (ThreeColMid 1 (3/100) (1/2)) (const x)
    transform ONE x k = k (OneBig (3/4) (3/4)) (const x)
    transform RT x k = k (ResizableTall 1 (1/100) 0.6 []) (const x)

-- limit windows force down, let pop window float in front of others.
myManageHook = composeOne 
            [ checkDock                                                 -?> doIgnore 
            , isDialog                                                  -?> doFloat
            , className =? "Gimp"                                       -?> doFloat
            , className =? "Peek"                                       -?> doFloat
            , className =? "Yad"                                        -?> doFloat
            , className =? "pentablet"                                  -?> doFloat
            , className =? "Note"                                       -?> doFloat
            , className =? "SpeedCrunch"                                -?> doFloat
            , className =? "firefox"                                    -?> doFocus
            , title     =? "About Mozilla Firefox"                      -?> doFloat
            , className =? "MPlayer"                                    -?> doF W.swapDown
            , className =? "VBoxSDL"                                    -?> doShift ( myWorkspaces !! 8 )
            , return True                                               -?> doF W.swapDown
            --, return True               -?> doF W.focusDown
            ]

-- key bending
-- use 0 instead modkey can let a single key press without modkey which is very useful
myKeys =
-- define function key
    [ ((0, xK_F1),  spawn "screen-brightness - 5") -- decrease screen brightness
    , ((0, xK_F2),  spawn "screen-brightness + 5") -- increase screen brightness
    , ((0, xK_F3),  spawn "dunstctl history-pop") -- show history notification
    , ((0, xK_F4),  spawn "dunstctl close-all") -- close all history notification
    , ((0, xK_F5),  spawn "change-transparency -")  -- decrease app transparency
    , ((0, xK_F6),  spawn "change-transparency +")  -- increase app transparency
    , ((0, xK_F8),  spawn "translate \"`xclip -sel clip -o`\"") -- fast translate 
    , ((0, xK_F9),  spawn "flameshot gui")  -- screen capture
    , ((0, xK_F11), spawn "pamixer --allow-boost -d 5") -- decrease volume
    , ((0, xK_F12), spawn "pamixer --allow-boost -i 5") -- increase volume
    , ((0, xK_Print), spawn "screen-capture")  -- full screen capture

-- trigger stick modkey press, when triggered, no modkey press needed, use Escape to stop this mode
    , ((_M4, xK_semicolon), setMode noModModeLabel)

-- window/workspace operation
    , ((_M4, xK_h), moveTo Prev $ anyWS :&: ignoringWSs [scratchpadWorkspaceTag]) -- jump to next workspace(filter out scratchpad workspace)
    , ((_M4, xK_l), moveTo Next $ anyWS :&: ignoringWSs [scratchpadWorkspaceTag]) -- jump to previous workspace(filter out scratchpad workspace)
    , ((_M4, xK_m), windows W.swapMaster) -- quick move window to master
    , ((_M4, xK_f), withFocused (sendMessage . maximizeRestore))  -- toggle full window
    , ((_M1, xK_Tab), toggleWS' ["NSP"])  -- toggle recent workspaces with NSP filtered
    , ((_M4 .|. _M1, xK_h), sendMessage Shrink) -- shrink master window space
    , ((_M4 .|. _M1, xK_l), sendMessage Expand) -- expand master window space
    , ((_M4 .|. shiftMask, xK_m), windowMenu) -- show pop up window menu
    , ((_M4 .|. shiftMask, xK_b), withFocused toggleBorder)  --toggle window border focused
    , ((_M4, xK_slash), dynamicNSPAction "dyn1") -- toggle newly created scratchpad 
    , ((_M4, xK_BackSpace), kill)  -- kill window
    , ((_M4, xK_x), sendMessage ToggleStruts) -- toggle status bar
    , ((_M4, xK_equal), decWindowSpacing 4) -- Decrease window spacing
    , ((_M4, xK_minus), incWindowSpacing 4) -- Increase window spacing

-- execute external command
    , ((_M4, xK_n), spawn myTerminal)  -- new terminal
    , ((_M4, xK_t), spawn "translate \"`xclip -sel clip -o`\"") -- translate copied word/sentence
    , ((_M4, xK_y), spawn "dm-translate") -- use dmenu to type what need to be translated
    , ((_M4 ,xK_r), spawn "~/.config/rofi/launchers/type-3/launcher.sh")  -- launcher rofi
    , ((_M4 ,xK_s), spawn "dm-rotate-screen")  -- use dmenu to choose screen rotation
    , ((_M4, xK_u), spawn "dm-search-in-firefox") -- use dmenu to search in browser
    , ((_M4, xK_e), spawn "dm-kvm") -- use dmenu to choose kvm image to start
    , ((_M4, xK_v), spawn "pamixer --toggle-mute && [ `pamixer --get-volume-human` == 'muted' ] && dunstify -u critical 'Notice: voice has been muted!'")  -- toggle pamixer mute
    , ((_M4, xK_c), spawn "xcolor |tr -d '\n' |xclip -sel clip && dunstify 'color stores in clipboard'") -- color picker

-- sub key "\"
    , ((_M4 , xK_backslash), submap . M.fromList $
       [ ((0 , xK_k), spawn "~/.local/bin/showkey") -- toggle screen key program on or off
       , ((0 , xK_l), spawn "slock & systemctl suspend")  -- lock screen
       , ((0 , xK_w), spawn "wallpaper dynamic &")  -- change wallpaper
       , ((0 , xK_s), toggleScreenSpacingEnabled >> toggleWindowSpacingEnabled) -- toggle space (put two functions in one line execute at the same time that's cool)
       , ((0 , xK_slash), withFocused $ toggleDynamicNSP "dyn1") -- toggle current window to a scratchpad
       , ((0 , xK_BackSpace), killAll) -- kill all windows in current workspace
       ])

--  sub key "g"  move window between workspaces/screen -- XMonad.Actions.CycleWS
    , ((_M4, xK_g), submap . M.fromList $
        [ ((0, xK_e), moveTo Next emptyWS) -- go to next empty workspace
        , ((0, xK_m), shiftTo Next emptyWS) -- shift window to next empty workspace
        , ((0, xK_n), nextScreen) -- go to next screen
        , ((0, xK_p), prevScreen) -- go to previous screen
        ])

-- sub key "w" multi windows management
    , ((_M4 , xK_w), submap . M.fromList $
       [ ((0 , xK_h), sendMessage $ pullGroup L)
       , ((0 , xK_l), sendMessage $ pullGroup R)
       , ((0 , xK_k), sendMessage $ pullGroup U)
       , ((0 , xK_j), sendMessage $ pullGroup D)
       , ((0 , xK_m), withFocused (sendMessage . MergeAll))
       , ((0 .|. shiftMask, xK_m), withFocused (sendMessage . UnMergeAll))
       , ((0 , xK_u), withFocused (sendMessage . UnMerge))
       , ((0 , xK_t), sinkAll)  -- unfloat all window
       , ((0,  xK_b), withAll toggleBorder)  -- toggle window border all (exist)
	   , ((0 , xK_y), windows copyToAll) -- copy window to all workspaces
	   , ((0 , xK_d), killAllOtherCopies) -- kill all copied windows
       ])

-- sub key "'" toggle layout
    , ((_M4 , xK_apostrophe), submap . M.fromList $
       [ ((0 , xK_m), sendMessage $ Toggle MIRROR)
       , ((0 , xK_a), sendMessage $ Toggle ACCORDION)
       , ((0 , xK_c), sendMessage $ Toggle CROSS)
       , ((0 , xK_p), sendMessage $ Toggle PST)
       , ((0 , xK_t), sendMessage $ Toggle THREE)
       , ((0 , xK_o), sendMessage $ Toggle ONE)
       , ((0 , xK_r), sendMessage $ Toggle RT)
       ])

-- scratchpad key
    , ((_M4, xK_p), namedScratchpadAction myScratchPads "xpad")
    , ((_M4, xK_o), namedScratchpadAction myScratchPads "pop-up-terminal" )
    ]

-- mouse binding + gesture
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask , button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove (Just 50) (Just 50) w))) -- mod key+left move window
    , ((modMask , button3), (\w -> focus w >> mouseResizeWindow w >> afterDrag (snapMagicResize [R,D] (Just 50) (Just 50) w)))  -- mod key+right resize window
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

-- scratch window
myScratchPads = [ NS "pop-up-terminal" spawnTerminal  findTerminal manageTerminal
                , NS "xpad" spawnStickypad  findStickypad manageStickypad
		        ]
                where
                    spawnStickypad = "xpad" 
                    findStickypad = className =? "xpad"
                    manageStickypad = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.98, 0.40, 0.02, 0.60)
                    spawnTerminal = "alacritty --class dropdown"
                    findTerminal = className =? "dropdown"
                    manageTerminal = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.50, 0.80, 0.30, 0.10)

-- top bar theme
topBarTheme = def
    { activeColor          = "#445caf"
    , activeBorderColor     = "#445caf"
    , activeTextColor       = "#445caf"
    , inactiveColor         = "#010202"
    , inactiveBorderColor   = "#010202"
    , inactiveTextColor     = "#010202"
    , decoHeight            = 5
    , fontName              = "xft:Source Han Sans CN-16"
    }
myTabTheme = def
    { activeColor           = "#445caf"
    , activeBorderColor     = "#445caf"
    , activeTextColor       = "#445caf" 
    , inactiveColor         = "#010202"
    , inactiveBorderColor   = "#010202"
    , inactiveTextColor     = "#010202"
    , decoHeight            = 8
    , fontName              = "xft:Iosevka Nerd Font-16"
    }
--sideBarTheme = def
--    { activeColor          = "#8978bc"
--    , activeBorderColor     = "#8978bc"
--    , activeTextColor       = "#8978bc"
--    , inactiveColor         = "#2b2a33"
--    , inactiveBorderColor   = "#2b2a33"
--    , inactiveTextColor     = "#2b2a33"
--    , decoWidth             = 6
--    , fontName              = "xft:Iosevka Nerd Font-2"
--    }

-- polybar info support
--{-  used for polybar
--eventLogHook = do
--  winset <- gets windowset
--  title <- maybe (return "") (fmap show . getName) . W.peek $ winset
--  let currWs = W.currentTag winset
--
--  io $ appendFile "/tmp/.xmonad-title-log" (title ++ "\n")
--  io $ appendFile "/tmp/.xmonad-workspace-log" (currWs ++ "\n")
---}


-- side bar decoration
--data SideDecoration a = SideDecoration Direction2D
--  deriving (Show, Read)
--instance Eq a => DecorationStyle SideDecoration a where
--  shrink b (Rectangle _ _ dw dh) (Rectangle x y w h)
--    | SideDecoration U <- b = Rectangle x (y + fi dh) w (h - dh)
--    | SideDecoration R <- b = Rectangle x y (w - dw) h
--    | SideDecoration D <- b = Rectangle x y w (h - dh)
--    | SideDecoration L <- b = Rectangle (x + fi dw) y (w - dw) h
--  pureDecoration b dw dh _ st _ (win, Rectangle x y w h)
--    | win `elem` W.integrate st && dw < w && dh < h = Just $ case b of
--      SideDecoration U -> Rectangle x y w dh
--      SideDecoration R -> Rectangle (x + fi (w - dw)) y dw h
--      SideDecoration D -> Rectangle x (y + fi (h - dh)) w dh
--      SideDecoration L -> Rectangle x y dw h
--    | otherwise = Nothing
--myDecorate :: Eq a => l a -> ModifiedLayout (Decoration SideDecoration DefaultShrinker) l a
--myDecorate = decoration shrinkText sideBarTheme (SideDecoration L)


main :: IO ()
main = do
    -- used for polybar
    --forM_ [".xmonad-workspace-log", ".xmonad-title-log"] $ \file -> do --for polybar info
    --    safeSpawn "mkfifo" ["/tmp/.xmonad-title-log","/tmp/.xmonad-workspace-log"]
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc"
    xmonad 
        . modal [noModMode]
        $ docks 
        $ ewmh 
        $ myDef xmproc
