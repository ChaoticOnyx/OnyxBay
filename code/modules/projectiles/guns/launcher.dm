/obj/item/gun/launcher
	name = "launcher"
	desc = "A device that launches things."
	w_class = ITEM_SIZE_HUGE
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	mod_weight = 0.6
	mod_reach = 0.5
	mod_handy = 1.0

	var/release_force = 1
	var/throw_distance = 10
	fire_sound_text = "a launcher firing"
	combustion = FALSE

//This normally uses a proc on projectiles and our ammo is not strictly speaking a projectile.
/obj/item/gun/launcher/can_hit(mob/living/target as mob, mob/living/user as mob)
	return 1

//Override this to avoid a runtime with suicide handling.
/obj/item/gun/launcher/handle_suicide(mob/living/user)
	to_chat(user, SPAN("warning", "Shooting yourself with \a [src] is pretty tricky. You can't seem to manage it."))
	return

/obj/item/gun/launcher/handle_war_crime(mob/living/carbon/human/user, mob/living/carbon/human/target)
	to_chat(user, SPAN("warning", "Shooting \the [target] with \a [src] is pretty tricky. You can't seem to manage it."))
	return

/obj/item/gun/launcher/proc/update_release_force(obj/item/projectile)
	return 0

/obj/item/gun/launcher/process_projectile(obj/item/projectile, mob/user, atom/target, target_zone, params=null, pointblank=0, reflex=0)
	update_release_force(projectile)
	projectile.loc = get_turf(user)
	projectile.dir = user.dir // It's dumb, but it works. Kinda.
	projectile.throw_at(target, throw_distance, 1, user, src, user.zone_sel.selecting, release_force)
	play_fire_sound(user,projectile)
	return 1
