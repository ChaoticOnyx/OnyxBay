/// Called on `/mob/proc/add_to_dead_mob_list` (/mob)
#define SIGNAL_MOB_DEATH "!mob_death"

/// Before a datum's Destroy() is called: (/datum, force), returning a nonzero value will cancel the qdel operation.
#define SIGNAL_PREQDELETING "!preqdeleted"

/// Just before a datum's Destroy() is called: (/datum, force), at this point none of the other components chose to interrupt qdel and Destroy will be called.
#define SIGNAL_QDELETING "!qdeleting"

/// Called on `/mob/Login` (/mob)
#define SIGNAL_LOGGED_IN "!logged_in"

/// Called on `/mob/Logout` (/mob, /client)
#define SIGNAL_LOGGED_OUT "!logged_out"

/// Called once upon roundstart
#define SIGNAL_ROUNDSTART "!roundstart"

#define SIGNAL_MOB_RESIST "!mob_resist"
#define SIGNAL_MOB_GRAB_SET_STATE "!mob_grab_set_state"

/// Called when an atom starts orbiting another atom (/atom)
#define SIGNAL_ORBIT_BEGIN "orbit_begin"
/// Called when an atom stops orbiting another atom (/atom)
#define SIGNAL_ORBIT_STOP "orbit_stop"
