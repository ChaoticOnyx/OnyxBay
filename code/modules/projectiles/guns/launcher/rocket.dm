/obj/item/weapon/gun/launcher/rocket
	name = "rocket launcher"
	desc = "M12 rocket launcher, an old, but reliable tool for dealing with enemy infantry and light exosuits."
	icon_state = "rpg"
	item_state = "rpg"
	w_class = ITEM_SIZE_HUGE
	throw_speed = 2
	throw_range = 10
	force = 17.5
	mod_weight = 1.6
	mod_reach = 1.25
	mod_handy = 1.0
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	one_hand_penalty = 5
	slot_flags = SLOT_BACK
	wielded_item_state = "rpg-wielded"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 5)
	fire_sound = 'sound/weapons/rpg_fire.ogg'
	combustion = 1

	release_force = 20
	throw_distance = 30
	var/max_rockets = 1
	var/list/rockets = new /list()

/obj/item/weapon/gun/launcher/rocket/examine(mob/user)
	. = ..()
	if(get_dist(src, user) > 2)
		return
	. = to_chat_or_concat(., user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")

/obj/item/weapon/gun/launcher/rocket/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			user.drop_item()
			I.loc = src
			rockets += I
			to_chat(user, "<span class='notice'>You put the rocket in [src].</span>")
			playsound(usr.loc, 'sound/weapons/rpg_reload.ogg', 25, 1)
			to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")
		else
			to_chat(usr, "<span class='warning'>\The [src] cannot hold more rockets.</span>")

/obj/item/weapon/gun/launcher/rocket/consume_next_projectile()
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new (src)
		M.primed = 1
		rockets -= I
		return M
	return null

/obj/item/weapon/gun/launcher/rocket/handle_post_fire(mob/user, atom/target)
	log_and_message_admins("fired a rocket from a rocket launcher ([src.name]) at [target].")
	..()
