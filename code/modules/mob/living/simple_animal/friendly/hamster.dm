/mob/living/simple_animal/hamster
	name = "hamster"
	real_name = "hamster"
	desc = "It's a miniature version of a giant space hamster."
	icon = 'icons/mob/animal.dmi'
	icon_state = "hamster"
	item_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASS_FLAG_TABLE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/reagent_containers/food/meat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = 0
	minbodytemp = -50 CELSIUS
	maxbodytemp = 50 CELSIUS
	universal_speak = 0
	universal_understand = 1
	holder_type = /obj/item/holder/hamster
	mob_size = MOB_MINISCULE
	possession_candidate = 1
	can_escape = 1
	shy_animal = 1
	controllable = TRUE
	bodyparts = /decl/simple_animal_bodyparts/quadruped
	var/obj/item/holding_item = null

	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_SAME

/mob/living/simple_animal/hamster/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			sound_to(M, sound('sound/effects/mousesqueek.ogg'))

/mob/living/simple_animal/hamster/Initialize()
	. = ..()

	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

	if(name == initial(name))
		name = "[name] ([sequential_id(/mob/living/simple_animal/hamster)])"
	real_name = name

/mob/living/simple_animal/hamster/death(gibbed, deathmessage, show_dead_message)
	. = ..(gibbed, deathmessage, show_dead_message)
	if(. && holding_item)
		holding_item.dropInto(src)
		holding_item = null

/mob/living/simple_animal/hamster/Destroy()
	QDEL_NULL(holding_item)
	return ..()

/mob/living/simple_animal/hamster/ex_act(severity)
	if(holding_item && severity < 3)
		QDEL_NULL(holding_item)
	return ..()

/mob/living/simple_animal/hamster/examinate(atom/to_axamine)
	. = ..()

	if(holding_item)
		. += SPAN_NOTICE("You may notice that it has \a [holding_item] taped to its back.")

/mob/living/simple_animal/hamster/UnarmedAttack(atom/A, proximity)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		if(hiding)
			to_chat(src, SPAN("warning", "You can't bite while you are hiding!"))
			return

		var/available_limbs = H.lying ? BP_ALL_LIMBS : BP_FEET
		var/obj/item/organ/external/limb
		for(var/L in shuffle(available_limbs))
			limb = H.get_organ(L)
			if(limb)
				break

		var/blocked = H.get_flat_armor(limb.organ_tag, "melee")
		for(var/obj/item/clothing/clothes in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes))
			if(istype(clothes) && (clothes.body_parts_covered & limb.body_part) && ((clothes.item_flags & ITEM_FLAG_THICKMATERIAL) || (blocked >= 30)))
				visible_message(SPAN("notice",  "[src] bites [H]'s [clothes] harmlessly."),
								SPAN("warning", "You failed to bite through [H]'s [clothes]."))
				do_attack_animation(H)
				return

		H.apply_damage(rand(1, 2), BRUTE, limb.organ_tag, blocked)

		visible_message(SPAN("danger",  "[src] bites [H]'s [organ_name_by_zone(H, limb.organ_tag)]!"),
						SPAN("warning", "You bite [H]'s [organ_name_by_zone(H, limb.organ_tag)]!"))
		admin_attack_log(src, H, "Bit the victim", "Was bitten", "bite")
		setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		do_attack_animation(H)
		playsound(loc, attack_sound, 25, 1, 1)
		return
	return ..()

/mob/living/simple_animal/hamster/Crossed(atom/movable/AM)
	if(!client && ishuman(AM) && !stat)
		var/mob/M = AM
		to_chat(M, SPAN("warning", "\icon[src] Squeek!"))
		playsound(loc, 'sound/effects/mousesqueek.ogg', 40)
		if(prob(50))
			UnarmedAttack(M)
		set_panic_target(M)
	..()

/mob/living/simple_animal/hamster/attack_hand(mob/living/carbon/human/user)
	if(holding_item && user.a_intent == I_HELP)
		user.pick_or_drop(holding_item, loc)
		user.visible_message(SPAN("notice", "[user] removes \the [holding_item] from \the [name]."),
							 SPAN("notice", "You remove \the [holding_item] from \the [name]."))
		holding_item = null
		playsound(loc, 'sound/effects/duct_tape_peeling_off.ogg', 50, 1)
		update_icon()
	else
		return ..()

/mob/living/simple_animal/hamster/attackby(obj/item/O, mob/user)
	if(!holding_item && user.a_intent == I_HELP && istype(user.get_inactive_hand(), /obj/item/tape_roll) && O.w_class == ITEM_SIZE_TINY)
		user.visible_message(SPAN("notice", "[user] is trying to tape \a [O] to \the [name]."),
							 SPAN("notice", "You are trying to tape \a [O] to \the [name]."))
		if(do_after(user, 3 SECONDS, src))
			if(holding_item)
				return
			if(!user.drop(O, src))
				return
			holding_item = O
			user.visible_message(SPAN("notice", "[user] tapes \the [O] to \the [name]."),
								 SPAN("notice", "You tape \the [O] to \the [name]."))
			playsound(loc, 'sound/effects/duct_tape.ogg', 50, 1)
			update_icon()
	else
		return ..()

/mob/living/simple_animal/hamster/on_update_icon()
	ClearOverlays()
	if(holding_item)
		AddOverlays("holding_item[is_ic_dead() ? "_dead" : ""]")

// GO FOR THE EYES, B- Woo?
/mob/living/simple_animal/hamster/woo
	name = "Woo"
	desc = "Go for the eyes, Woo! Go for the eyes!"

/mob/living/simple_animal/hamster/woo/Initialize()
	. = ..()
	SetName(initial(name))
	real_name = name
