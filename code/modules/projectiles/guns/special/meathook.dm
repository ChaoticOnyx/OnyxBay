
/obj/item/gun/meathook
	name = "meat hook"
	desc = "A symbolic nightmare, its curved blade a frightening reminder of its owner's slaughterous intent. Or, maybe, you're overthinking it and this is just a regular meat hook."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "pudgehook"
	item_state = "pudgehook"
	fire_sound = 'sound/weapons/meathook.ogg'
	fire_sound_text = "clanging chains"
	clumsy_unaffected = TRUE
	fire_delay = 40

	var/projectile_type = /obj/item/projectile/meathook

/obj/item/gun/meathook/consume_next_projectile()
	return new /obj/item/projectile/meathook(src)

/obj/item/projectile/meathook
	name = "meat hook"
	icon_state = null
	damage_type = BRUTE
	damage = 36.0 // 360 would be too much, I guess
	armor_penetration = 100 // pure damage is scary
	poisedamage = 25.0
	embed = FALSE
	sharp = TRUE
	hitscan = TRUE
	impact_on_original = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/meathook
	tracer_type = /obj/effect/projectile/tracer/meathook
	impact_type = /obj/effect/projectile/impact/meathook
	kill_count = 1000
	projectile_light = FALSE

/obj/item/projectile/meathook/on_hit(atom/target, blocked, def_zone)
	if(isturf(target))
		return

	var/atom/movable/T = target

	var/grab_chance = 100
	if(iscarbon(T))
		if(def_zone != BP_CHEST && def_zone != BP_GROIN && def_zone != BP_HEAD) // Limbs are small
			grab_chance = 50

	if(!T.anchored && prob(grab_chance))
		T.throw_at(firer, get_dist(firer, T) - 1, 1)
		var/success_msg = pick(\
			"Reel 'em in!",\
			"Hooked 'em!",\
			"Come to the chef!",\
			"Get over here!",\
			"Look who's coming for dinner!",\
			"Time for a little butchery!")
		to_chat(firer, SPAN("notice", "<b>[success_msg]</b>"))
		if(isliving(T))
			var/mob/living/L = T
			to_chat(L, "<b>[firer]'s</b> thought echoes in your mind, \"<b>[success_msg]</b>\"")
	else
		var/fail_msg = pick(\
			"I meant to do that...",\
			"Blast yeh!",\
			"Raah!",\
			"Gah!",\
			"Yahh!")
		to_chat(firer, SPAN("warning", "<b>[fail_msg]</b>"))

	return ..()

/obj/effect/projectile/muzzle/meathook
	icon_state = "muzzle_meathook"
	light_max_bright = 0

/obj/effect/projectile/tracer/meathook
	icon_state = "tracer_meathook"
	light_max_bright = 0

/obj/effect/projectile/impact/meathook
	icon_state = "impact_meathook"
	light_max_bright = 0