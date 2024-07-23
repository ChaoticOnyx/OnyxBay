/obj/item/gun/launcher/rocket
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
	fire_sound = 'sound/effects/weapons/gun/fire_rpg.ogg'
	combustion = 1

	release_force = 2
	throw_distance = 30
	var/max_rockets = 1
	var/list/rockets = new /list()

/obj/item/gun/launcher/rocket/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 2)
		return

	. += SPAN_NOTICE("[rockets.len] / [max_rockets] rockets.")

/obj/item/gun/launcher/rocket/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			if(!user.drop(I, src))
				return
			rockets += I
			to_chat(user, "<span class='notice'>You put the rocket in [src].</span>")
			playsound(usr.loc, 'sound/effects/weapons/gun/rpg_reload.ogg', 25, 1)
			to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")
		else
			to_chat(usr, "<span class='warning'>\The [src] cannot hold more rockets.</span>")

/obj/item/gun/launcher/rocket/consume_next_projectile()
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new (src)
		M.primed = 1
		rockets -= I
		return M
	return null

/obj/item/gun/launcher/rocket/handle_post_fire(mob/user, atom/target)
	log_and_message_admins("fired a rocket from a rocket launcher ([src.name]) at [target].")
	..()

/obj/item/gun/launcher/rocket/handle_war_crime(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/grab/G = user.get_inactive_hand()
	if(G?.affecting != target || !G?.current_grab?.can_absorb)
		to_chat(user, SPAN_NOTICE("You need a better grab for this."))
		return

	var/obj/item/organ/external/head/head = target.organs_by_name[BP_HEAD]
	if(!istype(head))
		to_chat(user, SPAN_NOTICE("You can't shoot in [target]'s mouth because you can't find their head."))
		return

	var/obj/item/clothing/head/helmet = target.get_equipped_item(slot_head)
	var/obj/item/clothing/mask/mask = target.get_equipped_item(slot_wear_mask)
	if((istype(helmet) && (helmet.body_parts_covered & HEAD)) || (istype(mask) && (mask.body_parts_covered & FACE)))
		to_chat(user, SPAN_NOTICE("You can't shoot in [target]'s mouth because their face is covered."))
		return

	weapon_in_mouth = TRUE
	target.visible_message(SPAN_DANGER("[user] sticks their gun in [target]'s mouth, ready to pull the trigger..."))
	if(!do_after(user, 2 SECONDS, progress=0, luck_check_type = LUCK_CHECK_COMBAT))
		target.visible_message(SPAN_NOTICE("[user] decided [target]'s life was worth living."))
		weapon_in_mouth = FALSE
		return
	var/obj/item/missile/in_chamber = consume_next_projectile()
	if(istype(in_chamber) && process_projectile(in_chamber, user, target, BP_MOUTH))
		playsound(user, fire_sound, 50, 1)
		in_chamber.throw_impact(target)
		log_and_message_admins("[key_name(user)] killed [target] using \a [src]. KABOOM!")
		target.gib() // KABOOM!
		qdel(in_chamber)
		weapon_in_mouth = FALSE
	else
		handle_click_empty(user)
		weapon_in_mouth = FALSE
		return
