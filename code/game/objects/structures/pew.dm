/* ============================================== */
/* -------------------- Pews -------------------- */
/* ============================================== */

/obj/structure/bed/pew // pew pew
	name = "pew"
	desc = "It's like a bench, but more holy. No, not <i>holey</i>, <b>holy</b>. Like, godly, divine. That kinda thing.<br>Okay, it's actually kind of holey, too, now that you look at it closer."
	icon_state = "armchair_preview"
	base_icon = "chair_pewchapel"
	material_alteration = MATERIAL_ALTERATION_NONE
	buckle_dir = 0
	buckle_lying = 0
	buckle_pixel_shift = "x=0;y=0"
	var/max_health = 100
	var/health = 100

/obj/structure/bed/pew/New(newloc)
	..(newloc, MATERIAL_WOOD)

/obj/structure/bed/pew/attackby(obj/item/W, mob/user)
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

/obj/structure/bed/pew/attack_tk(mob/user as mob)
	if(buckled_mob)
		..()
	return

/obj/structure/bed/pew/post_buckle_mob()
	update_icon()
	return ..()

/obj/structure/bed/pew/update_icon()
	..()

	var/cache_key = "[base_icon]-over"
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

/obj/structure/bed/pew/pewchapel
	name = "pew"

/obj/structure/bed/pew/pewchapel/left
	icon_state = "chair_pewchapel_left"
	base_icon = "chair_pewchapel_left"

/obj/structure/bed/pew/pewchapel/right
	icon_state = "chair_pewchapel_right"
	base_icon = "chair_pewchapel_right"

/obj/structure/bed/pew/pewchapel/middle
	icon_state = "chair_pewchapel_middle"
	base_icon = "chair_pewchapel_middle"
