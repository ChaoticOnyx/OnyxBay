/mob/living/simple_animal/hostile/explosive_plant
	name = "explosive plant"
	desc = "Aww, man."
	icon_state = "explosive_plant"
	icon_living = "explosive_plant"
	icon_dead = "explosive_plant_death"
	speak_emote = list("hisses")
	turns_per_move = 2
	meat_type = /obj/item/reagent_containers/food/meat/xeno
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 50
	health = 50
	universal_speak = 0
	universal_understand = 1

	bodyparts = /decl/simple_animal_bodyparts/explosive_plant

	faction = "floral"

	var/angry = FALSE
	var/booming = FALSE
	var/hurt_sound = list('sound/weapons/gunshot/flamethrower/ignite_flamethrower1.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower2.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower3.ogg')

/mob/living/simple_animal/hostile/explosive_plant/Initialize()
	. = ..()
	add_think_ctx("creeper_boom_context", CALLBACK(src, nameof(.proc/finalize_boom)), 0)
	spawn(5 SECONDS)
		angry = TRUE

/mob/living/simple_animal/hostile/explosive_plant/Destroy()
	remove_think_ctx("creeper_boom_context")
	return ..()

/mob/living/simple_animal/hostile/explosive_plant/death(gibbed, deathmessage = "dies!", show_dead_message)
	. = ..()
	if(.)
		abort_boom()
		new /obj/effect/decal/cleanable/ash(loc)
		QDEL_IN(src, 1 SECOND)

/mob/living/simple_animal/hostile/explosive_plant/find_target()
	return (angry && !booming) ? ..() : null

/mob/living/simple_animal/hostile/explosive_plant/AttackingTarget()
	setClickCooldown(attack_delay)
	if(!Adjacent(target_mob))
		return
	if(isliving(target_mob))
		initiate_boom()

/mob/living/simple_animal/hostile/explosive_plant/adjustBruteLoss(damage)
	. = ..(damage)
	if(!stat)
		playsound(loc, pick(hurt_sound), 100, 1)

/mob/living/simple_animal/hostile/explosive_plant/proc/update_booming_icon()
	ClearOverlays()
	set_light(0)
	if(booming)
		AddOverlays(image(icon, "explosive_plant-blinking"))
		set_light(0.5, 0.1, 2, 2, "#ffffff")

/mob/living/simple_animal/hostile/explosive_plant/proc/initiate_boom()
	if(stat)
		return

	if(booming)
		return

	LoseTarget()
	booming = TRUE
	update_booming_icon()
	set_next_think_ctx("creeper_boom_context", world.time + 1.5 SECONDS)

/mob/living/simple_animal/hostile/explosive_plant/proc/abort_boom()
	set_next_think_ctx("creeper_boom_context", 0)
	booming = FALSE
	update_booming_icon()

/mob/living/simple_animal/hostile/explosive_plant/proc/finalize_boom()
	if(stat)
		return

	var/turf/T = loc
	if(!istype(T))
		abort_boom()
		return

	var/list/L = list()
	for(var/mob/living/M in view(src, 3))
		if(!ishuman(M) && !isrobot(M))
			continue
		if(M.stat)
			continue
		L += M

	if(!length(L))
		abort_boom()
		return

	visible_message("<b>\The [src]</b> explodes violently!")
	qdel_self()
	explosion(T, -1, 1, 4, 1)
	return

/decl/simple_animal_bodyparts/explosive_plant
	hit_zones = list("body", "tendrils", "maw", "uncanny eyes")
