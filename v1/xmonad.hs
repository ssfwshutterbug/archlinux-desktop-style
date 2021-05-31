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
    » #nautilus             gnome file manager                                         
    » #xpad                 stickypad
    » #flameshot            screenshot gui tool                             
    » #ffcast               quick full screenshot
    » #pamixer              adjust volume                                               
    » #dmenu                run program                                            
    » #firefox              firefox                                              
    » #virtualbox           virtual machine                                                  
    » #slock                screen lock                                          
    » #dunst                notify tool
    » #peek                 gif tool(optional)                                             
    » #xdotool              make xmobar clickable
    » #mplayer              voice for script
    » #xclip                disable touchpad                                         
    » #ydcv-rs-git          translate for script
    » #screenkey            display key for script
    » #feh                  set wallpaper for script
    » #nerd-fonts-iosevka   font setting, important. without it may not work normally
    » #xautolock            suspend system with specified time
    » #picom-jonaburg-git   window effect
    » #fcitx5               input method
    » #xorg-xsetroot        cursor style setting
    » #xcolor               simple color picker
    
 scripts:
    » #translate            translate words/sentenses                                           
    » #showkey              display key touch                                         
    » #wallpaper            change desktop wallpaper                                        

-}



-- import modules
import System.IO
import Control.Monad (forM_, join)

import Data.List (sortBy)
import Data.Function (on)
import Data.Maybe (fromJust)

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XMonad.Prompt.AppLauncher as AL --search app
import XMonad.Prompt.Window
import XMonad.Prompt

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks  --toggle xmobar hidden
import XMonad.Hooks.InsertPosition  --choose new window position
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..)) --send info to xmobar
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName

import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.NamedScratchpad --scratchpad
import XMonad.Util.Run -- runinterm for workspace
import XMonad.Util.EZConfig  --set shortkeys
import XMonad.Util.SpawnOnce -- run startup app

import XMonad.Actions.WindowMenu -- optional window menu in center
import XMonad.Actions.WindowBringer -- window boring
import XMonad.Actions.MouseGestures -- mouse gesture setting
import XMonad.Actions.CopyWindow --copy window to all
import XMonad.Actions.DynamicProjects --goto workspace with apps open up
import XMonad.Actions.WithAll  --make effort for all windows
import XMonad.Actions.NoBorders   --used in all window
import XMonad.Actions.Submap  --create a sub-mapping of key bindings
import XMonad.Actions.CycleWS  --move/cycle windows between workspaces

import XMonad.Layout.Spacing   --set edge space of window
import XMonad.Layout.NoBorders    --used in fullscreen
import XMonad.Layout.Maximize  --toggle fullscreen
import XMonad.Layout.Hidden  --hide window
import XMonad.Layout.SubLayouts --sub layout
import XMonad.Layout.Tabbed --sub layout tab
import XMonad.Layout.Simplest --sub layout style
import XMonad.Layout.NoFrillsDecoration  --set windows titlebar
import XMonad.Layout.WindowNavigation  --move or swap focus window between left and right
import XMonad.Layout.PerWorkspace --diff workspace has diff layout

import XMonad.Layout.ToggleLayouts --toggle layout
import XMonad.Layout.IfMax --nice function for change layout when number of window changes
import XMonad.Layout.ResizeScreen --put one window in center with specified window space
import XMonad.Layout.ResizableTile  --allow adjust vertical height
import XMonad.Layout.Grid -- grid arrange
import XMonad.Layout.Cross --put one master center window above other window
import XMonad hiding ( (|||) ) --layout split with |||

main :: IO ()
main = do
    -- used for polybar
    --forM_ [".xmonad-workspace-log", ".xmonad-title-log"] $ \file -> do --for polybar info
    --    safeSpawn "mkfifo" ["/tmp/.xmonad-title-log","/tmp/.xmonad-workspace-log"]
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc"
    xmonad $ docks $ewmh def
        { modMask               = mod4Mask
        , borderWidth           = 1
        , normalBorderColor     = "#3d5266" 
        , focusedBorderColor    = "#7e749d" 
        , terminal              = "xterm"
        , layoutHook            = avoidStruts $ myLayoutHook 
        , workspaces            = myWorkspaces
        , startupHook           = myStartupHook
        , focusFollowsMouse     = False
        , mouseBindings         = myMouseBindings 
        --, logHook = eventLogHook  --used for polybar
        , manageHook            = myManageHook <+> namedScratchpadManageHook myScratchPads
        , logHook               = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP -- need filterout the scratchpad, or it may lead statuebar stuck
                                { ppOutput          =  hPutStrLn xmproc                           -- xmobar on monitor 0
                                , ppCurrent         = xmobarColor "#000000" "#e68e85" . wrap " " " "           -- Current workspace
                                , ppVisible         = xmobarColor "#ffa500" "" . clickable              -- Visible but not current workspace
                                --, ppHidden          = xmobarColor "#000000" "#84C1ff" . wrap "\61552" "" . clickable -- Hidden workspaces
                                , ppHidden          = xmobarColor "#000000" "#7e749d" . wrap " " " " . clickable -- Hidden workspaces
                                , ppHiddenNoWindows = xmobarColor "#b3afc2" ""  . clickable     -- Hidden workspaces (no windows)
                                , ppTitle           = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window
                                , ppLayout          = xmobarColor "#98be65" "" . shorten 5
                                , ppSep             =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separator character
                                , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
                                , ppExtras          = [windowCount]                                     -- # of windows current workspace
                                , ppOrder           = \(ws:_:t:ex) -> [ws] ++ ex ++ [t] -- \(ws:l:t:ex) -> [ws,l]++ex++[t]  -- without l to ignore workspace layout
                                }
        }`additionalKeys` myKeys

-- define workspace
myWorkspaces = [ " " ++ x ++ " " | x <- map show [1..9] ]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..9] 
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- startup app when xmonad starts
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "xmodmap .Xmodmap"
    spawnOnce "xmobar &"
    spawnOnce "xautolock -time 180 -locker 'systemctl suspend' -detectsleep"
    spawnOnce "picom  --experimental-backends --config .config/picom/picom.conf -b"
    spawnOnce "xsetroot -cursor_name left_ptr"
    spawnOnce "fcitx5 &"

-- layout style
myLayoutHook =  windowNavigation
            $  hiddenWindows
            $  maximizeWithPadding 0 --10
            $  noFrillsDeco shrinkText topBarTheme
            $  addTabs shrinkText myTabTheme
            $  spacingWithEdge 0 --5
			$  subLayout [0,1,2] (Simplest)
            -- $  onWorkspace " 9 " (noBorders Full)
            -- with smartBorder, it will render no border while there is only one window in a workspace
			$  toggleLayouts (IfMax 3 (IfMax 1 (resizeHorizontal 300 $ resizeHorizontalRight 300 $ smt_tiled) tiled) Grid) (smartBorders simpleCross)
            where 
                --tiled       = ResizableTall 1 (1/100) 0.6180 [] 
                tiled       = ResizableTall 1 (1/100) 0.5 [] 
                --smt_tiled   = smartBorders (ResizableTall 1 (1/100) 0.6180 [])
                smt_tiled   = smartBorders (ResizableTall 1 (1/100) 0.5 [])

--limit windows force down, let pop window float in front of others.
--note: app name should begin with captical letter
myManageHook = composeOne
            [ checkDock                 -?> doIgnore 
            , isDialog                  -?> doFloat
            , className =? "Gimp"       -?> doFloat
            , className =? "Peek"       -?> doFloat
            , className =? "MPlayer"    -?> doF W.swapDown
            , className =? "VBoxSDL"    -?> doShift ( myWorkspaces !! 8 )
            , return True               -?> doF W.swapDown
            ]

--key bending
myKeys =
    [ ((mod1Mask, xK_F2), spawn "pamixer -d 5")
    , ((mod1Mask, xK_F3), spawn "pamixer -i 5")
    , ((mod1Mask, xK_F4), spawn "xbacklight -dec 2")
    , ((mod1Mask, xK_F5), spawn "xbacklight -inc 2")
    , ((mod4Mask, xK_F6), spawn "xinput disable 14")
    --, ((mod4Mask, xK_r  ), spawn "rofi -lines 4  -show drun -show-icons -theme android_notification.rasi -eh 2")  --show date usr dzen2
-- navigate key
    -- redefine the default moveing key
    , ((mod4Mask, xK_j), sendMessage $ Go D)
    , ((mod4Mask, xK_k), sendMessage $ Go U)
    , ((mod4Mask, xK_l), sendMessage $ Go R)
    , ((mod4Mask, xK_h), sendMessage $ Go L)
    , ((mod4Mask, xK_i), prevWS) -- jump to previous workspace
    , ((mod4Mask, xK_o), nextWS) -- jump to next workspace
-- the key used for sublayout which compressed
    , ((mod4Mask, xK_bracketleft), onGroup W.focusUp') --keys [
    , ((mod4Mask, xK_bracketright), onGroup W.focusDown') --keys ]
    , ((mod4Mask .|. mod1Mask, xK_i  ), sendMessage MirrorShrink)  --vertical shrink window
    , ((mod4Mask .|. mod1Mask, xK_o  ), sendMessage MirrorExpand)  --vertical expand window
    , ((mod4Mask .|. mod1Mask, xK_h  ), sendMessage Shrink)
    , ((mod4Mask .|. mod1Mask, xK_l  ), sendMessage Expand)
    , ((mod4Mask .|. shiftMask, xK_m), windows W.swapMaster)  --move window to master
-- key for toggle
    , ((mod4Mask, xK_f), withFocused (sendMessage . maximizeRestore))  --toggle full window
    , ((mod4Mask .|. shiftMask, xK_b), withFocused toggleBorder)  --togger window border focused
    , ((mod4Mask, xK_space), sendMessage ToggleLayout) --toggle layout
    , ((mod1Mask, xK_Tab), toggleWS' ["NSP"])  --cycle workspace with NSP filter out(really nice)
    , ((mod4Mask, xK_t), spawn "translate \"`xclip -o`\"") -- faster translate 
-- others
    , ((mod4Mask, xK_n), spawn "xterm")  --new terminal
    , ((mod4Mask, xK_r), spawn "dmenu_run -i -fn 'Source Han Sans CN-12' -sb '#7e749d' -sf '#F0FFFF' -p 'healer@shell   ::    Command -> Dunst  ' -l 10 |xargs -I@ dunstify @")  --app launcher with dmenu
    , ((mod4Mask, xK_d), spawn "ffcast png ~/Pictures/capture/$(date +%Y%m%d%H%M%S).png && dunstify -t 3000 'screen capture in ~/Pictures/capture'")  --fullscreen capture
    , ((mod4Mask, xK_BackSpace), kill)  --kill window
    , ((mod4Mask, xK_0), withFocused hideWindow) --hide window
    , ((mod4Mask, xK_m), windowMenu) -- optional menu in center
    , ((mod4Mask, xK_g), gotoMenu)
    , ((mod4Mask, xK_b), bringMenu)
    , ((mod4Mask, xK_equal), decWindowSpacing 4)         -- Decrease window spacing
    , ((mod4Mask, xK_minus), incWindowSpacing 4)         -- Increase window spacing
    , ((mod4Mask .|. mod1Mask, xK_equal), decScreenSpacing 4)         -- Decrease screen spacing
    , ((mod4Mask .|. mod1Mask, xK_minus), incScreenSpacing 4)         -- Increase screen spacing

-- sub key w ----------------------------------------------------------------------------- used for sublayout
    , ((mod4Mask , xK_w), submap . M.fromList $
       [ ((0 , xK_h), sendMessage $ pullGroup L)
       , ((0 , xK_l), sendMessage $ pullGroup R)
       , ((0 , xK_k), sendMessage $ pullGroup U)
       , ((0 , xK_j), sendMessage $ pullGroup D)
       , ((0 , xK_m), withFocused (sendMessage . MergeAll))
       , ((0 , xK_u), withFocused (sendMessage . UnMerge))
       , ((0,  xK_b), withAll toggleBorder)  --togger window border all (exist)
       , ((0 , xK_t), sinkAll)  --unfloat all window
       ])
-- sub key s ----------------------------------------------------------------------------- used for screen rotation
    , ((mod4Mask , xK_s), submap . M.fromList $
       [ ((0 , xK_l), spawn "xrandr --output HDMI-A-0 --rotate left") -- rotation screen 90 degree
       , ((0 , xK_n), spawn "xrandr --output HDMI-A-0 --rotate normal") -- rotation screen normal
       ])
-- sub key \ ----------------------------------------------------------------------------- subkey \
    , ((mod4Mask , xK_backslash), submap . M.fromList $
       [ ((0 , xK_s), spawn "rofi -show ssh -show-icons -theme lb.rasi -terminal xterm")  --launch ssh connect window
       , ((0 , xK_k), spawn "~/.local/bin/showkey") --toggle screenkey program on or off
       --, ((0 , xK_r), spawn "~/.config/polybar/launch.sh") --restart polybar
       , ((0 , xK_m), spawn "amixer set Master toggle")  --toggle amixer mute
       , ((0 , xK_w), spawn "wallpaper dynamic &")  --change wallpaper
       , ((0 , xK_e), spawn "vboxsdl --startvm windows10 &")  --start windows10
       , ((0 , xK_l), spawn "slock & systemctl suspend")  --lock screen
       , ((0 , xK_f), spawn "firefox")  --lock firefox
       , ((0 , xK_p), spawn "flameshot gui")  --screen capture
       , ((0 , xK_c), spawn "xcolor |xclip -sel clip && dunstify 'color stores in clipboard'")  --color picker
       , ((0 , xK_b), sendMessage ToggleStruts) --toggle status bar
	   , ((0 , xK_y), windows copyToAll) --copy window to all desktop
	   , ((0 , xK_d), killAllOtherCopies) --kill all copy window
       , ((0 , xK_BackSpace), killAll)  --kill all window in one workspace
       , ((0 , xK_0), popOldestHiddenWindow) -- show hidden window
       , ((0 , xK_1), windows $ W.greedyView " 1 ")
       , ((0 , xK_2), windows $ W.greedyView " 2 ")
       , ((0 , xK_3), windows $ W.greedyView " 3 ")
       , ((0 , xK_4), windows $ W.greedyView " 4 ")
       , ((0 , xK_5), windows $ W.greedyView " 5 ")
       , ((0 , xK_6), windows $ W.greedyView " 6 ")
       , ((0 , xK_7), windows $ W.greedyView " 7 ")
       , ((0 , xK_8), windows $ W.greedyView " 8 ")
       , ((0 , xK_9), windows $ W.greedyView " 9 ")
       ])
-- scratchpad key
    , ((mod4Mask, xK_e), namedScratchpadAction myScratchPads "nautilus")
    , ((mod4Mask, xK_p), namedScratchpadAction myScratchPads "xpad")
    , ((mod4Mask, xK_u), namedScratchpadAction myScratchPads "midTerm" )
    , ((mod4Mask .|. shiftMask, xK_i), namedScratchpadAction myScratchPads "topTerm")
    , ((mod4Mask .|. shiftMask, xK_o), namedScratchpadAction myScratchPads "botTerm")
    ]

------------------------------------------------------------------------------------------ mouse bingding + gesture
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask .|. mod1Mask, button1), (\w -> focus w >> mouseMoveWindow w)) --modekey+left move window
    , ((modMask .|. mod1Mask, button3), (\w -> focus w >> mouseResizeWindow w))  --modekey+right resize window
    , ((mod4Mask, button3), mouseGesture gestures) --mouse gesture support
    ]
    where -- mouse gesture
        gestures = M.fromList
                [ ([], focus)
                , ([U], \w -> focus w >> withFocused (sendMessage . maximizeRestore)) --up
                , ([D], \w -> focus w >> namedScratchpadAction myScratchPads "topTerm") --down
                , ([R], \w -> focus w >> prevWS)    --right
                , ([L], \w -> focus w >> nextWS)    --left
                , ([R, D], \_ -> sendMessage NextLayout)    --right_down
                ]

-------------------------------------------------------------------------------------------- scratch window
popupTerminal = "xterm -sb"
myScratchPads = [ NS "midTerm" spawnTerm0  findTerm0 manageTerm0
                , NS "topTerm" spawnTerm1  findTerm1 manageTerm1
                , NS "botTerm" spawnTerm2  findTerm2 manageTerm2
                , NS "nautilus" spawnNautilus  findNautilus manageNautilus
                , NS "xpad" spawnStickypad  findStickypad manageStickypad
		        ]
                where
                    spawnNautilus = "nautilus"  --without anyother can call it directily
                    findNautilus = className =? "Org.gnome.Nautilus"
                    manageNautilus = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.50, 0.60, 0.10, 0.20)
                    spawnStickypad = "xpad" 
                    findStickypad = className =? "xpad"
                    manageStickypad = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.20, 0.30, 0.03, 0.35)
                    spawnTerm0 = popupTerminal ++  " -name midterm" 
                    findTerm0 = resource =? "midterm"
                    manageTerm0 = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.60, 0.80, 0.10, 0.10)
                    spawnTerm1 = popupTerminal ++  " -name topterm"
                    findTerm1 = resource =? "topterm"
                    manageTerm1 = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.40, 0.98, 0.04, 0.01)
                    spawnTerm2 = popupTerminal ++  " -name botterm" 
                    findTerm2 = resource =? "botterm"
                    manageTerm2 = customFloating $ W.RationalRect l t w h
                        where (h, w, t, l) = (0.40, 0.98, 0.60, 0.01)


-------------------------------------------------------------------------------------------- top bar theme
topBarTheme = def
     { activeColor 	        = "#7e749d"
    , activeBorderColor     = "#7e749d"
    , activeTextColor	    = "#7e749d"
    , inactiveColor	        = "#4c4660"
    , inactiveBorderColor   = "#4c4660"
    , inactiveTextColor     = "#4c4660"
    , decoHeight 	        = 5
    , fontName		        = "xft:Source Han Sans CN-10"
    }
myTabTheme = def
    { activeColor           = "#7e749d"
    , activeBorderColor     = "#7e749d"
    , activeTextColor       = "#7e749d" 
    , inactiveColor         = "#4c4660"
    , inactiveBorderColor   = "#4c4660"
    , inactiveTextColor     = "#4c4660"
    , decoHeight	        = 5
    , fontName		        = "xft:Iosevka Nerd Font"
    }


-------------------------------------------------------------------------------------------- polybar info support
{-  used for polybar
eventLogHook = do
  winset <- gets windowset
  title <- maybe (return "") (fmap show . getName) . W.peek $ winset
  let currWs = W.currentTag winset

  io $ appendFile "/tmp/.xmonad-title-log" (title ++ "\n")
  io $ appendFile "/tmp/.xmonad-workspace-log" (currWs ++ "\n")
-}
