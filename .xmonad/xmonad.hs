import XMonad
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "~/bin/urxvtc"
myModMask       = mod1Mask
myWorkspaces    = ["main","ext","tmp","tmp2"]
myBorderWidth   = 1
myNormalBorderColor  = "#002200"
myFocusedBorderColor = "#005500"

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask,               xK_p     ), spawn "zsh -i -c dmenu_run")
    , ((modMask .|. shiftMask, xK_c     ), kill)
    , ((modMask,               xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modMask,               xK_n     ), refresh)
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    , ((modMask,               xK_j     ), windows W.focusDown)
    , ((modMask,               xK_k     ), windows W.focusUp  )
    , ((modMask,               xK_m     ), windows W.focusMaster  )
    , ((modMask,               xK_Return), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modMask,               xK_h     ), sendMessage Shrink)
    , ((modMask,               xK_l     ), sendMessage Expand)
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modMask              , xK_q     ), spawn "xmonad --recompile; xmonad --restart&")
    ]
    ++
    [ ((modMask              , xK_Escape), spawn "display ~/.xmonad/Xmbindings.png &")
    , ((modMask              , xK_i     ), spawn "zsh -c chromium-browser &")
    , ((modMask .|. shiftMask, xK_l     ), spawn "gnome-screensaver-command -l")
    , ((mod4Mask .|. shiftMask, xK_k), spawn "if [ \"`setxkbmap -print | grep -o dvp`\" = \"dvp\" ]; then setxkbmap -layout us_intl -option 'grp:shifts_toggle'; xmodmap ~/.Xmodmap.de; else setxkbmap -layout us,us,de -variant dvp,,nodeadkeys -option lv3:ralt_switch; xmodmap ~/.Xmodmap; fi &")
    ]
    ++
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_ampersand, xK_bracketleft, xK_braceleft, xK_braceright]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [1,0]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    ]

myLayout = Full ||| tiled ||| Mirror tiled
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 80/100
     delta   = 1/100

myManageHook = composeAll
    [ className =? "MPlayer"            --> doFloat
    , className =? "Gimp"               --> doFloat
    , resource  =? "desktop_window"     --> doIgnore ]

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myLogHook = return ()
myStartupHook = do
    spawn "display -window root ~/.xmonad/background.xpm"
    spawn "~/bin/urxvtd -q -f -o"

main = xmonad defaults

defaults = defaultConfig {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
