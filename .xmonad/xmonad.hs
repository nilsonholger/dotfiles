import XMonad
import XMonad.Config.Gnome
import XMonad.Config.Desktop (desktopLayoutModifiers)
import XMonad.Hooks.SetWMName
import XMonad.Util.EZConfig (additionalKeys)


import qualified XMonad.StackSet as W
import qualified Data.Map        as M

spaces         = ["main","ext","tmp","tmp2"]

main = xmonad $ gnomeConfig
    {
		borderWidth        = 1,
		normalBorderColor  = "#002200",
		focusedBorderColor = "#005500",
		workspaces         = spaces,
		modMask            = mod4Mask,
		manageHook = composeAll
			[ manageHook gnomeConfig
			, className =? "MPlayer"            --> doFloat
			, className =? "Gimp"               --> doFloat
			, resource  =? "desktop_window"     --> doIgnore ],
		startupHook        = do
			setWMName "LG3D"
    }
	`additionalKeys`
	[((m .|. mod4Mask, k), windows $ f i)
		| (i, k) <- zip (spaces) [xK_ampersand, xK_bracketleft, xK_braceleft, xK_braceright]
		, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
	`additionalKeys`
	[((m .|. mod4Mask, k), screenWorkspace s >>= flip whenJust (windows . f))
		 | (k, s) <- zip [xK_w, xK_e] [0,1]
		, (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
	`additionalKeys` [
	((mod4Mask              , xK_q     ), spawn "xmonad --recompile; xmonad --restart&"),
	((mod4Mask              , xK_Escape), spawn "display ~/.xmonad/Xmbindings.png &"),
	((mod4Mask .|. shiftMask, xK_i     ), spawn "firefox &"),
	((mod4Mask .|. shiftMask, xK_m     ), spawn "thunderbird &"),
	((mod4Mask .|. shiftMask, xK_l     ), spawn "if [ \"`setxkbmap -print | grep -o dvp`\" = \"dvp\" ]; then setxkbmap -layout us_intl -option 'grp:shifts_toggle'; else setxkbmap -layout us,us,de -variant dvp,,nodeadkeys -option lv3:ralt_switch; fi; xmodmap ~/.Xmodmap &")]
