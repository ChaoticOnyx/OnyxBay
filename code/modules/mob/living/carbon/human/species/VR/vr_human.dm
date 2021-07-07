#define SPAWN_PROTECTION_TIME 20
#define DEAD_DELETE_COUNTDOWN 20
#define BRAINLOSS_PER_DEATH 20
#define POINTS_FOR_CHEATER 10
#define CLEANUP_COOLDOWN 600
/mob/living/carbon/human/vrhuman
	var/obj/screen/vrhuman_shop
	var/obj/screen/vrhuman_exit
	var/obj/screen/vrhuman_main
	var/obj/screen/vrhuman_cleanup
	var/datum/mind/vr_mind
	var/died = FALSE
	var/obj/item/device/uplink/vr_uplink/vr_shop
	var/global/last_cleanup_time
	alpha = 127

/mob/living/carbon/human/vrhuman/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/carbon/human/vrhuman/LateInitialize()
	. = ..()
	generate_random_body()
	equip_mob()
	give_spawn_protection()
	vr_shop = new(src)

/mob/living/carbon/human/vrhuman/proc/generate_random_body()
	gender = pick(MALE, FEMALE)
	if(gender == MALE)
		name = pick(GLOB.first_names_male)
	else
		name = pick(GLOB.first_names_female)
	name += " [pick(GLOB.last_names)]"
	real_name = name

	randomize_skin_color()

/mob/living/carbon/human/vrhuman/proc/equip_mob()
	equip_to_slot_or_del(new /obj/item/clothing/under/color/grey, slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/black, slot_shoes)
	equip_to_slot_or_del(new /obj/item/weapon/extinguisher, slot_l_hand)
	equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack, slot_r_store)

/mob/living/carbon/human/vrhuman/proc/give_spawn_protection()
	status_flags ^= GODMODE
	animate(src, alpha = 255, time = SPAWN_PROTECTION_TIME)
	addtimer(CALLBACK(src, .proc/lift_spawn_protection), SPAWN_PROTECTION_TIME)

/mob/living/carbon/human/vrhuman/proc/lift_spawn_protection()
	status_flags ^= GODMODE
	revive()
	if(!vr_mind)
		return
	to_chat(src, SPAN("danger", "You are respawned! Respawns left: [vr_mind.thunder_respawns]."))

/mob/living/carbon/human/vrhuman/updatehealth()
	..()
	if((getBruteLoss() + getFireLoss() + getOxyLoss()) >= 200)
		death()

/mob/living/carbon/human/vrhuman/death()
	if(died)
		return
	died = TRUE
	var/obj/item/VR_reward/coin/C = new /obj/item/VR_reward/coin/(loc)
	if(!vr_mind)
		hide_body()
		return ..()
	if(vr_mind.thunder_points == 0)
		C.points = 1
	else
		C.points = vr_mind.thunder_points
	C = null
	vr_mind.thunder_points = 0
	if(vr_mind.thunder_respawns == 0)
		vr_mind.transfer_to(vr_mind.thunderfield_owner)
		death_actions()
		return ..()
	var/obj/effect/landmark/spawnpoint = pick(GLOB.thunderfield_spawns_list)
	var/mob/living/carbon/human/vrhuman/vrbody = new /mob/living/carbon/human/vrhuman(spawnpoint.loc)
	vrbody.vr_mind = vr_mind
	vr_mind.transfer_to(vrbody)
	death_actions()
	if(vr_mind.thunderfield_cheater)
		vr_mind.thunder_points = POINTS_FOR_CHEATER
	return ..()

/mob/living/carbon/human/vrhuman/proc/death_actions()
	vr_mind.thunder_respawns--
	if(vr_mind.thunderfield_cheater)
		vr_mind.thunderfield_owner.adjustBrainLoss(BRAINLOSS_PER_DEATH)
	hide_body()

/mob/living/carbon/human/vrhuman/proc/hide_body()
	animate(src, alpha = 0, time = DEAD_DELETE_COUNTDOWN)
	QDEL_IN(src, DEAD_DELETE_COUNTDOWN)

/mob/living/carbon/human/vrhuman/Destroy()
	vr_mind = null
	return ..()

/mob/living/carbon/human/vrhuman/proc/exit_body()
	var/answer = alert(src, "Would you like to exit VR?", "Alert", "Yes", "No")
	if(answer == "Yes")
		vr_mind.thunder_respawns = 0
		death()
	else
		return

/mob/living/carbon/human/vrhuman/verb/quit()
	set name = "Leave VR"
	set category = "IC"

	exit_body()

/mob/living/carbon/human/vrhuman/ghost()
	return

/mob/living/carbon/human/vrhuman/verb/OpenShopMenu()
	set name = "Open Shop"
	set category = "IC"

	vr_shop.trigger(src)

/mob/living/carbon/human/vrhuman/verb/try_cleanup() //to do
	if(world.time < (last_cleanup_time + CLEANUP_COOLDOWN))
		to_chat(src, SPAN("danger", "Please wait!"))
		return
	last_cleanup_time = world.time
	for(var/turf/unsimulated/floor/self_cleaning/sc in GLOB.self_cleaning_list)
		sc.cleaner()

#undef SPAWN_PROTECTION_TIME
#undef DEAD_DELETE_COUNTDOWN
#undef BRAINLOSS_PER_DEATH
#undef POINTS_FOR_CHEATER
#undef CLEANUP_COOLDOWN
