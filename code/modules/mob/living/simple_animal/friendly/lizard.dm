#define COURAGE_MODIFIER 5 //More = More chance to start attacking
#define MAX_ALLIES 8	//We don't need all legions of lizards to attack one person, that will be limit
#define POISON_AMOUNT 3	//How much poison will one lizard inject per one bite
#define BREEDING_COOLDOWN (10 MINUTES)	//How long will lizard be unable to breed after breeding or birth

/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon = 'icons/mob/animal.dmi'
	icon_state = "lizard"
	item_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	color = COLOR_GREEN
	var/image/face
	var/image/blood
	var/icon_face = "lizard_face"
	var/icon_blood = "lizard_blood"

	speak_emote = list("hisses")
	pass_flags = PASS_FLAG_TABLE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/reagent_containers/food/meat
	attacktext = "bitten"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	density = 0
	minbodytemp = -50 CELSIUS
	maxbodytemp = 50 CELSIUS
	universal_speak = 0
	universal_understand = 1
	holder_type = /obj/item/holder/lizard
	mob_size = MOB_MINISCULE
	possession_candidate = 1
	can_escape = 1
	shy_animal = 1
	controllable = TRUE
	bodyparts = /decl/simple_animal_bodyparts/quadruped

	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_SAME

	var/datum/reagent/poison
	var/last_breed = 0
	var/mob/aggressive_target = null

/mob/living/simple_animal/lizard/proc/isFertile()
	if(is_ooc_dead())
		return FALSE
	if(!last_breed || world.time - last_breed > BREEDING_COOLDOWN)
		return TRUE
	return FALSE

/mob/living/simple_animal/lizard/proc/Breed(mob/living/simple_animal/lizard/partner)
	if(is_ooc_dead())
		return
	var/place = pick(get_turf(src), get_turf(partner))
	var/datum/reagent/child_poison = pick(poison, partner.poison)
	var/mob/living/simple_animal/lizard/child = new /mob/living/simple_animal/lizard(place)
	child.setPoison(child_poison)

	child.last_breed = world.time
	partner.last_breed = world.time
	last_breed = world.time

/mob/living/simple_animal/lizard/proc/CountLizards()
	var/count = 0
	for(var/mob/living/simple_animal/lizard/L in view(vision_range, src))
		if(L.is_ooc_dead() || L == src)
			continue
		count += 1
	return count

/mob/living/simple_animal/lizard/proc/CallLizards(mob/target)
	var/called_number = 0
	var/list/Allies = list()
	for(var/mob/living/simple_animal/lizard/L in view(vision_range, src))
		if(L.is_ooc_dead() || L == src)
			continue
		Allies.Add(L)
	for(var/mob/living/simple_animal/lizard/ally in shuffle(Allies))
		if(prob(50))
			ally.SetAggressiveTarget(target)
			called_number += 1
		if(called_number >= MAX_ALLIES)
			break

/mob/living/simple_animal/lizard/UnarmedAttack(atom/A, proximity)
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	var/available_limbs = H.lying ? BP_ALL_LIMBS : BP_FEET | BP_L_LEG | BP_R_LEG | BP_L_HAND | BP_R_HAND | BP_GROIN
	var/obj/item/organ/external/limb
	for(var/l in shuffle(available_limbs))
		limb = H.get_organ(l)
		if(limb)
			break
	var/blocked = H.run_armor_check(limb.organ_tag, "melee")
	for(var/obj/item/clothing/clothes in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes))
		if(istype(clothes) && (clothes.body_parts_covered & limb.body_part) && ((clothes.item_flags & ITEM_FLAG_THICKMATERIAL)))
			visible_message(SPAN_NOTICE("[src] bites [H]'s [clothes] harmlessly."),
							SPAN_WARNING("You failed to bite through [H]'s [clothes]."))
			do_attack_animation(H)
			return
	if(H.apply_damage(rand(melee_damage_lower, melee_damage_upper), BRUTE, limb.organ_tag, blocked) && !BP_IS_ROBOTIC(limb) && prob(70 - blocked))
		H.reagents.add_reagent(poison, POISON_AMOUNT)
		visible_message(SPAN_DANGER("[src] bites [H]'s [organ_name_by_zone(H, limb.organ_tag)]!"),
						SPAN_WARNING("You bite [H]'s [organ_name_by_zone(H, limb.organ_tag)]!"))
		admin_attack_log(src, H, "Bit the victim", "Was bitten", "bite")
		setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		do_attack_animation(H)
		playsound(loc, attack_sound, 25, 1, 1)
		return

/mob/living/simple_animal/lizard/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == I_HURT)
		if(prob(2*CountLizards()*COURAGE_MODIFIER))
			SetAggressiveTarget(user)
			say(pick(GLOB.lizard_noises))
	..()

/mob/living/simple_animal/lizard/attackby(obj/item/O, mob/user)
	if(user.a_intent == I_HURT)
		if(prob(2*CountLizards()*COURAGE_MODIFIER))
			SetAggressiveTarget(user)
			say(pick(GLOB.lizard_noises))
	..()

/mob/living/simple_animal/lizard/proc/HandleAggressiveTarget()
	//see if we should stop being aggressive
	if(is_ooc_dead())
		aggressive_target = null
		return
	if(aggressive_target)
		set_panic_target(null) //Do not panic when you aggressive
		if (!(aggressive_target.loc in view(src)))
			aggressive_target = null
			stop_automated_movement = 0
		else
			stop_automated_movement = 1
			walk_towards(src, aggressive_target, 7, 4)
			if(aggressive_target.loc in view(1, src))
				UnarmedAttack(aggressive_target)	//Bite once
				CallLizards(aggressive_target)	//Call friends
				set_panic_target(aggressive_target)	//And run away
				aggressive_target = null


/mob/living/simple_animal/lizard/proc/SetAggressiveTarget(mob/M)
	if(M && !ckey)
		aggressive_target = M
		turns_since_scan = 5

/mob/living/simple_animal/lizard/proc/setPoison(datum/reagent/P)
	if(poison)
		poison = P
		color = GLOB.lizard_colors[poison]
	else
		poison = null
		color = GLOB.lizard_colors["notoxin"]

/mob/living/simple_animal/lizard/proc/setRandomPoison()
	var/datum/reagent/P = pick(POSSIBLE_LIZARD_TOXINS)
	setPoison(P)

/mob/living/simple_animal/lizard/death(gibbed, deathmessage, show_dead_message)
	. = ..()
	CutOverlays(face)
	AddOverlays(blood)

/mob/living/simple_animal/lizard/Initialize()
	. = ..()
	setPoison(poison) //To make sure we paint lizard
	blood = image(icon, icon_state = icon_blood, layer = FLOAT_LAYER+1)
	blood.color = null	//We don't want to paint it
	face = image(icon, icon_state = icon_face, layer = FLOAT_LAYER+1)
	face.color = null	//We don't want to paint it
	AddOverlays(face)

/mob/living/simple_animal/lizard/Life()
	. = ..()
	HandleAggressiveTarget()

	if(panic_target == null && aggressive_target == null && isFertile()) //Find someone to breed
		for(var/mob/living/simple_animal/lizard/L in view(1, src))
			if(L == src)
				continue
			if(L && !L.is_ooc_dead() && L.panic_target == null && L.aggressive_target == null && L.isFertile())
				Breed(L)
				break

/mob/living/simple_animal/lizard/Crossed(AM as mob|obj)
	if(ishuman(AM) && !stat)
		var/mob/M = AM
		if(prob(CountLizards()*COURAGE_MODIFIER))
			SetAggressiveTarget(M)
			say(pick(GLOB.lizard_noises))
		else
			set_panic_target(M)
			if(prob(25)) say(pick(GLOB.lizard_noises))
	..()

#undef COURAGE_MODIFIER
#undef MAX_ALLIES
#undef POISON_AMOUNT
#undef BREEDING_COOLDOWN
