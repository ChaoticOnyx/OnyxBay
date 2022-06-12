/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = ITEM_SIZE_HUGE
	force = 0.0
	mod_weight = 0.25
	mod_reach = 0.5
	mod_handy = 0.25
	throwforce = 0.0
	throw_speed = 2
	throw_range = 20
	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/item/beach_ball/afterattack(atom/target, mob/user)
	user.drop_item()
	throw_at(target, throw_range, throw_speed, user)
