/// Called on `/mob/set_see_in_dark` (/mob, old_see_in_dark, new_see_in_dark)
#define SIGNAL_SEE_IN_DARK_SET "see_in_dark_set"

/// Called on `/mob/proc/set_see_invisible` (/mob, old_see_invisible, new_see_invisible)
#define SIGNAL_SEE_INVISIBLE_SET "see_invisible_set"

/// Called on `/mob/proc/set_sight` (/mob, old_sight, new_sight)
#define SIGNAL_SIGHT_SET "set_sight"

/// Called on `/mob/living/set_stat` (/mob/living, old_stat, new_stat)
#define SIGNAL_STAT_SET "set_stat"

/// Called on `/mob/proc/shift_view` (/mob, old_stat, new_stat)
#define SIGNAL_VIEW_SHIFTED_SET "view_shift_set"

/// Called on `/mob/proc/ghostize` (/mob, can_reenter_corpse)
#define SIGNAL_MOB_GHOSTIZED "mob_ghostized"

/// from turf ShiftClickOn(): (/mob)
#define SIGNAL_MOB_SHIFT_CLICK "mob_shift_click"

/// from turf CtrlClickOn(): (/mob)
#define SIGNAL_MOB_CTRL_CLICK "mob_ctrl_click"

/// Called on '/mob/proc/update_movespeed()' (/mob)
#define SIGNAL_MOB_MOVESPEED_UPDATED "mob_movespeed_updated"
