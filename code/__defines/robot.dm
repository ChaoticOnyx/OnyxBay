/// Path to the file containing default panel `icon_state`s.
#define ROBOT_HULL_PANEL_ICON 'icons/mob/silicon/robot.dmi'

/// Runtime prefix based on the robot `icon_state` used to generate panel `icon_state`.
#define ROBOT_HULL_PANEL_CUSTOM "custom"
/// Static prefix for generating of the panel `icon_state`.
#define ROBOT_HULL_PANEL_DEFAULT "robot"

/// Determines whether to draw the robot's eye overlay.
#define ROBOT_HULL_FLAG_HAS_EYES (1<<0)
/// Determines whether to draw the robot's panel overlay.
#define ROBOT_HULL_FLAG_HAS_PANEL (1<<1)
/// Determines whether to play the robot's footstep sounds.
#define ROBOT_HULL_FLAG_HAS_FOOTSTEPS (1<<2)
/// Determines whether to animate the robot's incapacitated state.
#define ROBOT_HULL_FLAG_TILTABLE (1<<3)
