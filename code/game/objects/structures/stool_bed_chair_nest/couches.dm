
/* ================================================= */
/* -------------------- Couches -------------------- */
/* ================================================= */

/obj/structure/bed/couch
	name = "couch"
	desc = "Made of steel, steel wool, and steeleather. At least, it's easily repairable and is comfier than sitting on the floor. Probably."
	icon_state = "armchair_preview_old"
	base_icon = "chair_couch-brown"
	material_alteration = MATERIAL_ALTERATION_NONE
	buckle_dir = 0
	buckle_lying = 0
	buckle_pixel_shift = "x=0;y=0"
	var/max_health = 100
	var/health = 100

/obj/structure/bed/couch/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		to_chat(user, SPAN("notice", "\The [src] doesn't look like it can be disassembled. Breaking it up is the only way to get rid of it."))
	else if(istype(W,/obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(!WT.isOn())
			return
		if(health == max_health)
			to_chat(user, SPAN("notice", "\The [src] is undamaged."))
			return
		if(!WT.remove_fuel(0,user))
			to_chat(user, SPAN("notice", "You need more welding fuel to complete this task."))
			return
		user.visible_message(SPAN("notice", "[user] is repairing the damage to \the [src]..."), \
				             SPAN("notice", "You start repairing the damage to \the [src]..."))
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(!do_after(user, max(5, health / 3), src) && WT && WT.isOn())
			return
		health = max_health
		user.visible_message(SPAN("notice", "[user] repairs \the [src]."), \
				             SPAN("notice", "You repair \the [src]."))
		update_icon()
	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		var/mob/living/affecting = G.affecting
		user.visible_message("<span class='notice'>[user] attempts to buckle [affecting] into \the [src]!</span>")
		if(do_after(user, 20, src))
			if(user_buckle_mob(affecting, user))
				qdel(W)
	else
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		obj_attack_sound(W)
		shake_animation(stime = 2)
		if(W.force >= 5)
			user.visible_message(SPAN("danger", "\The [src] has been [pick(W.attack_verb)] with [W] by [user]!"))
			health -= W.force
			update_icon()
			if(health <= 0)
				visible_message(SPAN("danger", "\The [src] falls apart!"))
				dismantle()
				qdel(src)
		else
			user.visible_message(SPAN("danger", "[user] hits \the [src] with \the [W], but it bounces off!"))

/obj/structure/bed/couch/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	return

/obj/structure/bed/couch/post_buckle_mob()
	update_icon()
	return ..()

/obj/structure/bed/couch/update_icon()
	..()

	var/cache_key = "[base_icon]-[material.name]-over"
	if(isnull(stool_cache[cache_key]))
		var/image/I = image('icons/obj/furniture.dmi', "[base_icon]_over")
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = material.icon_colour
		I.layer = ABOVE_HUMAN_LAYER
		stool_cache[cache_key] = I
	overlays |= stool_cache[cache_key]
	if(buckled_mob)
		cache_key = "[base_icon]_armrest"
		var/image/I = image('icons/obj/furniture.dmi', "[base_icon]_armrest")
		I.layer = ABOVE_HUMAN_LAYER
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = padding_material.icon_colour
		stool_cache[cache_key] = I
		overlays |= stool_cache[cache_key]

	if(health <= max_health*0.33)
		overlays += icon('icons/obj/furniture.dmi', "couch-tear")
	else if (health <= max_health*0.67)
		overlays += icon('icons/obj/furniture.dmi', "couch-rip")

/obj/structure/bed/couch/set_dir()
	..()
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/couch/blue
	name = "blue couch"

/obj/structure/bed/couch/blue/left
	icon_state = "chair_couch-blue_left"
	base_icon = "chair_couch-blue_left"

/obj/structure/bed/couch/blue/right
	icon_state = "chair_couch-blue_right"
	base_icon = "chair_couch-blue_right"

/obj/structure/bed/couch/brown
	name = "brown couch"

/obj/structure/bed/couch/brown/left
	icon_state = "chair_couch-brown_left"
	base_icon = "chair_couch-brown_left"

/obj/structure/bed/couch/brown/right
	icon_state = "chair_couch-brown_right"
	base_icon = "chair_couch-brown_right"

/obj/structure/bed/couch/red
	name = "red couch"

/obj/structure/bed/couch/red/left
	icon_state = "chair_couch-red_left"
	base_icon = "chair_couch-red_left"

/obj/structure/bed/couch/red/right
	icon_state = "chair_couch-red_right"
	base_icon = "chair_couch-red_right"

/obj/structure/bed/couch/green
	name = "green couch"

/obj/structure/bed/couch/green/left
	icon_state = "chair_couch-green_left"
	base_icon = "chair_couch-green_left"

/obj/structure/bed/couch/green/right
	icon_state = "chair_couch-green_right"
	base_icon = "chair_couch-green_right"

/obj/structure/bed/couch/purple
	name = "purple couch"

/obj/structure/bed/couch/purple/left
	icon_state = "chair_couch-purple_left"
	base_icon = "chair_couch-purple_left"

/obj/structure/bed/couch/purple/right
	icon_state = "chair_couch-purple_right"
	base_icon = "chair_couch-purple_right"

/obj/structure/bed/couch/sofa
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_middle_preview"
	base_icon = "sofa_middle"

/obj/structure/bed/couch/sofa/left
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_left_preview"
	base_icon = "sofa_left"

/obj/structure/bed/couch/sofa/right
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_right_preview"
	base_icon = "sofa_right"
