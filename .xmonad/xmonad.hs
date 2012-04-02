import XMonad
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "urxvt"
myModMask       = mod1Mask
myWorkspaces    = ["main","ext","tmp","tmp2"]
myBorderWidth   = 1
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#00aa00"

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask,               xK_p     ), spawn "dmenu_run")
--    , ((modMask .|. shiftMask, xK_p     ), spawn "gmrun")
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
    [ ((modMask             , xK_Escape), spawn "qiv -p ~/.xmonad/Xmbindings.png &")
    , ((modMask             , xK_i     ), spawn "zsh -c chrome &")
    , ((mod4Mask .|. shiftMask, xK_k), spawn "if [ \"`setxkbmap -print | grep -o pc+de`\" != \"pc+de\" ]; then setxkbmap -layout de; xmodmap ~/.Xmodmap.de; else setxkbmap -layout us,us,de -variant dvp,,nodeadkeys -option lv3:ralt_switch; xmodmap ~/.Xmodmap; fi &")
--    , ((modMask             , xK_c     ), spawn "rxvt -title cmus -e screen -x -R cmus cmus &")
--    , ((modMask             , xK_f     ), spawn "rxvt -title finch -e screen -x -R finch finch &")
--    , ((modMask             , xK_s     ), spawn "rxvt -title shell-fm -e screen -x -R shell-fm shell-fm &")
--    , ((0                    , 0x1008FF92), spawn "sudo /sbin/ctl music open > /dev/null &")
--    , ((modMask             , xK_F1    ), spawn "nvclock -S 15 > /dev/null &")
--    , ((modMask             , xK_F2    ), spawn "nvclock -S 100 > /dev/null &")
--    , ((modMask             , xK_F3    ), spawn "pgrep finch && screen -d -S finch || ( screen -ls | grep finch && rxvt -geometry 182x61+1680+0 -title finch -e screen -r finch finch ) > /dev/null &")
--    , ((modMask             , xK_F7    ), spawn "sudo /sbin/ctl music prev > /dev/null &")
--    , ((modMask             , xK_F8    ), spawn "sudo /sbin/ctl music toggle > /dev/null &")
--    , ((modMask             , xK_F9    ), spawn "sudo /sbin/ctl music next > /dev/null &")
--    , ((modMask             , xK_F10   ), spawn "sudo /sbin/ctl vol toggle > /dev/null &")
--    , ((modMask             , xK_F11   ), spawn "sudo /sbin/ctl vol 3%- > /dev/null &")
--    , ((modMask             , xK_F12   ), spawn "sudo /sbin/ctl vol 3%+ > /dev/null &")
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
     ratio   = 70/100
     delta   = 1/100

myManageHook = composeAll
    [ className =? "MPlayer"            --> doFloat
    , className =? "Gimp"               --> doFloat
--    , className =? "Operapluginwrapper" --> doFloat
--    , className =? "Skype"              --> doFloat
    , resource  =? "desktop_window"     --> doIgnore ]

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myLogHook = return ()
myStartupHook = spawn "qiv -z .xmonad/background.xpm"

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
