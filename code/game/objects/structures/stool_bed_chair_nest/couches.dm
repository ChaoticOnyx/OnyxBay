
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
	else if(isWelder(W))
		var/obj/item/weldingtool/WT = W
		if(health == max_health)
			to_chat(user, SPAN("notice", "\The [src] is undamaged."))
			return

		user.visible_message(SPAN("notice", "[user] is repairing the damage to \the [src]..."), \
				            	SPAN("notice", "You start repairing the damage to \the [src]..."))
		if(!WT.use_tool(src, user, delay = max(5, health / 3), amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		health = max_health
		user.visible_message(SPAN("notice", "[user] repairs \the [src]."), \
				             SPAN("notice", "You repair \the [src]."))
		update_icon()

	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		var/mob/living/affecting = G.affecting
		user.visible_message("<span class='notice'>[user] attempts to buckle [affecting] into \the [src]!</span>")
		if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_COMBAT))
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

/obj/structure/bed/couch/on_update_icon()
	..()

	var/cache_key = "[base_icon]-[material.name]-over"
	if(isnull(stool_cache[cache_key]))
		var/image/I = image('icons/obj/furniture.dmi', "[base_icon]_over")
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = material.icon_colour
		I.layer = ABOVE_HUMAN_LAYER
		stool_cache[cache_key] = I
	AddOverlays(stool_cache[cache_key])
	if(buckled_mob)
		cache_key = "[base_icon]_armrest"
		var/image/I = image('icons/obj/furniture.dmi', "[base_icon]_armrest")
		I.layer = ABOVE_HUMAN_LAYER
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = padding_material.icon_colour
		stool_cache[cache_key] = I
		AddOverlays(stool_cache[cache_key])

	if(health <= max_health*0.33)
		AddOverlays(image('icons/obj/furniture.dmi', "couch-tear"))
	else if (health <= max_health*0.67)
		AddOverlays(image('icons/obj/furniture.dmi', "couch-rip"))

/obj/structure/bed/couch/set_dir()
	..()
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/couch/corner/set_dir()
	..()
	if (dir == SOUTH)
		buckle_dir = EAST
	else if (dir == NORTH)
		buckle_dir = WEST

/obj/structure/bed/couch/left/blue
	name = "blue couch"
	icon_state = "chair_couch-blue_left"
	base_icon = "chair_couch-blue_left"

/obj/structure/bed/couch/right/blue
	name = "blue couch"
	icon_state = "chair_couch-blue_right"
	base_icon = "chair_couch-blue_right"

/obj/structure/bed/couch/middle/blue
	name = "blue couch"
	icon_state = "chair_couch-blue_mid"
	base_icon = "chair_couch-blue_mid"

/obj/structure/bed/couch/corner/blue
	name = "blue couch"
	icon_state = "chair_couch-blue_corner"
	base_icon = "chair_couch-blue_corner"

/obj/structure/bed/couch/left/brown
	name = "brown couch"
	icon_state = "chair_couch-brown_left"
	base_icon = "chair_couch-brown_left"

/obj/structure/bed/couch/right/brown
	name = "brown couch"
	icon_state = "chair_couch-brown_right"
	base_icon = "chair_couch-brown_right"

/obj/structure/bed/couch/middle/brown
	name = "brown couch"
	icon_state = "chair_couch-brown_mid"
	base_icon = "chair_couch-brown_mid"

/obj/structure/bed/couch/corner/brown
	name = "brown couch"
	icon_state = "chair_couch-brown_corner"
	base_icon = "chair_couch-brown_corner"

/obj/structure/bed/couch/left/red
	name = "red couch"
	icon_state = "chair_couch-red_left"
	base_icon = "chair_couch-red_left"

/obj/structure/bed/couch/right/red
	name = "red couch"
	icon_state = "chair_couch-red_right"
	base_icon = "chair_couch-red_right"

/obj/structure/bed/couch/middle/red
	name = "red couch"
	icon_state = "chair_couch-red_mid"
	base_icon = "chair_couch-red_mid"

/obj/structure/bed/couch/corner/red
	name = "red couch"
	icon_state = "chair_couch-red_corner"
	base_icon = "chair_couch-red_corner"

/obj/structure/bed/couch/left/green
	name = "green couch"
	icon_state = "chair_couch-green_left"
	base_icon = "chair_couch-green_left"

/obj/structure/bed/couch/right/green
	name = "green couch"
	icon_state = "chair_couch-green_right"
	base_icon = "chair_couch-green_right"

/obj/structure/bed/couch/middle/green
	name = "green couch"
	icon_state = "chair_couch-green_mid"
	base_icon = "chair_couch-green_mid"

/obj/structure/bed/couch/corner/green
	name = "green couch"
	icon_state = "chair_couch-green_corner"
	base_icon = "chair_couch-green_corner"

/obj/structure/bed/couch/left/purple
	name = "purple couch"
	icon_state = "chair_couch-purple_left"
	base_icon = "chair_couch-purple_left"

/obj/structure/bed/couch/right/purple
	name = "purple couch"
	icon_state = "chair_couch-purple_right"
	base_icon = "chair_couch-purple_right"

/obj/structure/bed/couch/middle/purple
	name = "purple couch"
	icon_state = "chair_couch-purple_mid"
	base_icon = "chair_couch-purple_mid"

/obj/structure/bed/couch/corner/purple
	name = "purple couch"
	icon_state = "chair_couch-purple_corner"
	base_icon = "chair_couch-purple_corner"

/obj/structure/bed/couch/middle/sofa
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_middle_preview"
	base_icon = "sofa_middle"

/obj/structure/bed/couch/left/sofa
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_left_preview"
	base_icon = "sofa_left"

/obj/structure/bed/couch/right/sofa
	name = "comfy sofa"
	desc = "So lovely, uh."
	icon_state = "sofa_right_preview"
	base_icon = "sofa_right"
