#define HAS_TRANSFORMATION_MOVEMENT_HANDLER(X) X.HasMovementHandler(/datum/movement_handler/mob/transformation)
#define ADD_TRANSFORMATION_MOVEMENT_HANDLER(X) X.AddMovementHandler(/datum/movement_handler/mob/transformation)
#define DEL_TRANSFORMATION_MOVEMENT_HANDLER(X) X.RemoveMovementHandler(/datum/movement_handler/mob/transformation)

#define DELAY2GLIDESIZE(delay) (world.icon_size / max(Ceiling(delay / world.tick_lag), 1))

#define MOVESPEED_PRIORITY_HIGH    0
#define MOVESPEED_PRIORITY_NORMAL  1
#define MOVESPEED_PRIORITY_LAST    2

#define MOVESPEED_FLAG_OVERRIDING_SPEED (1<<0)
#define MOVESPEED_FLAG_SPACEMOVEMENT 	(1<<1)

#define MOVESPEED_ID_MOB_GRAB_STATE "mob_grab_state"
#define MOVESPEED_ID_MOB_WALK_RUN "mob_walk_run"
