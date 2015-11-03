--
-- A basic copy of john goerzen's xmonad tutorial and xmobar setup, taken slowly
-- to my own version of XMonad bliss.  ;-)
--

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet as W

import XMonad.Actions.WindowGo
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Actions.Warp
import System.IO

-- for SQL Developer and other misbehaving Java applications
import XMonad.Hooks.SetWMName

-- from xmonad-contrib:
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise

import XMonad.Layout.Circle
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral

import Data.Ratio ((%))

term = "urxvt"

myManageHook = composeAll [
    className =? "Gimp-2.8" --> doFloat,
    className =? "Audacity" --> doFloat,
    className =? "LibreOffice" --> doFloat,
    className =? "Calculator" --> doFloat,
    className =? "Evince" --> doF (W.shift "reading")
    ]

myLayoutHook =
    avoidStruts $ Full
    ||| Grid
    ||| Tall 1 (3/100) (1/2)
    ||| (Mirror $ Tall 1 (3/100) (1/2))
    ||| Circle

myKeys =
    [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
    , ((mod4Mask .|. shiftMask, xK_e), runOrRaise "emacsclient ~/docs/org/personal/journal.org" (className =? "Emacs"))
    , ((0, xK_Print),                  spawn "scrot")
    , ((mod4Mask, xK_z),               banish LowerRight)
    , ((mod4Mask, xK_x),               banishScreen LowerRight)
    , ((mod4Mask, xK_r), runOrRaisePrompt defaultXPConfig)
    , ((mod4Mask, xK_p), shellPrompt defaultXPConfig)
    , ((mod4Mask .|. shiftMask, xK_n), spawn "mpc next")
    , ((mod4Mask .|. shiftMask, xK_b), spawn "mpc prev")
    , ((mod4Mask .|. controlMask, xK_p), spawn "mpc pause")
    , ((mod4Mask .|. controlMask .|. shiftMask, xK_p), spawn "mpc play")
    , ((0 , 0x1008ff12), spawn "amixer -q set Master toggle")     -- XF86AudioMute
    , ((0 , 0x1008ff11), spawn "amixer -q set Master 2- unmute")  -- XF86AudioLowerVolume (laptop volume slider)
    , ((0 , 0x1008ff13), spawn "amixer -q set Master 2+ unmute")  -- XF86AudioRaiseVolume (laptop volume slider)
    , ((mod4Mask, xK_Down), spawn "amixer -q set Master 2-  unmute")
    , ((mod4Mask, xK_Up), spawn "amixer -q set Master 2+ unmute")
    , ((mod4Mask, xK_p), spawn "dmenu_run -b -nb black")
    ]

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar /home/smd/.xmonad/xmobar"
  xmonad $ defaultConfig
       { modMask     = mod4Mask
       , borderWidth = 1
       , normalBorderColor = "#0f0f0f"
       , focusedBorderColor = "#463dc4"
       , workspaces  = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
       , terminal    = term
       , startupHook = setWMName "LG3D"
       , layoutHook  = myLayoutHook
       , manageHook  = manageDocks <+> myManageHook <+> manageHook defaultConfig
       , logHook     = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc
                                                   , ppTitle  = xmobarColor "cadetBlue" "" . shorten 60
                                                   }
       } `additionalKeys` myKeys
