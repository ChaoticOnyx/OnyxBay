
/*
 * Pill Bottles
 */
/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 14
	can_hold = list(/obj/item/reagent_containers/pill, /obj/item/dice, /obj/item/paper)
	allow_quick_gather = 1
	use_to_pickup = 1
	use_sound = 'sound/effects/using/bottles/use1.ogg'
	var/label_color = null
	var/spam_flag = FALSE
	var/starting_label = null
	var/true_desc = "It's an airtight container for storing medication."

	pickup_sound = SFX_PICKUP_PILLBOTTLE
	drop_sound = SFX_DROP_PILLBOTTLE

/obj/item/storage/pill_bottle/Initialize()
	. = ..()
	update_icon()
	if(starting_label)
		name = "pill bottle"
		AddComponent(/datum/component/label, starting_label) // So the name isn't hardcoded and the label can be removed for reusability

/obj/item/storage/pill_bottle/post_remove_label()
	..()
	desc = true_desc
	label_color = null
	update_icon()

/obj/item/storage/pill_bottle/on_update_icon()
	ClearOverlays()
	if(label_color)
		AddOverlays(OVERLAY(icon, "[icon_state]-overlay", alpha, RESET_COLOR, label_color))

/obj/item/storage/pill_bottle/attack_self(mob/user)
	if(user.get_inactive_hand())
		to_chat(user, SPAN_NOTICE("You need an empty hand to take something out."))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		if(!remove_from_storage(I, user))
			return
		if(user.put_in_inactive_hand(I))
			to_chat(user, SPAN_NOTICE("You take \the [I] out of \the [src]."))
			user.swap_hand()
		else
			remove_from_storage(I, get_turf(user.loc))
			to_chat(user, SPAN_WARNING("You fumble around with \the [src] and drop \the [I] on the floor."))
	else
		to_chat(user, SPAN_WARNING("\The [src] is empty."))

/obj/item/storage/pill_bottle/attack(mob/M, mob/user, def_zone)
	if(spam_flag)
		return FALSE
	var/obj/item/reagent_containers/pill/pill = locate(/obj/item/reagent_containers/pill) in shuffle(contents.Copy())
	if(!pill)
		to_chat(user, SPAN("notice", "\The [src] contains no pills!"))
		return FALSE

	spam_flag = TRUE
	if(M == user)
		if(!M.can_eat("pills"))
			return
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
		to_chat(M, SPAN("notice", "You swallow a pill from \the [src]."))
		remove_from_storage(pill, get_turf(M))
		if(pill.reagents.total_volume)
			pill.reagents.trans_to_mob(M, pill.reagents.total_volume, CHEM_INGEST)
		qdel(pill)
		spam_flag = FALSE
		return TRUE

	else if(istype(M, /mob/living/carbon/human))
		if(!M.can_force_feed(user, "pills"))
			spam_flag = FALSE
			return FALSE

		user.visible_message(SPAN("warning", "[user] attempts to force [M] to swallow pills from \the [src]."))
		if(!do_mob(user, M))
			spam_flag = FALSE
			return FALSE

		if(user.get_active_hand() != src)
			spam_flag = FALSE
			return FALSE

		if(pill?.loc != src)
			spam_flag = FALSE
			return FALSE

		remove_from_storage(pill, get_turf(M))
		user.visible_message(SPAN("warning", "[user] forces [M] to swallow pills from \the [src]."))
		var/contained = pill.reagentlist()
		admin_attack_log(user, M, "Fed the victim with [pill] (Reagents: [contained])", "Was fed with [pill] (Reagents: [contained])", "used [pill] (Reagents: [contained]) to feed")
		if(pill.reagents.total_volume)
			pill.reagents.trans_to_mob(M, pill.reagents.total_volume, CHEM_INGEST)
		qdel(pill)
		spam_flag = FALSE
		return TRUE

	spam_flag = FALSE
	return FALSE

/obj/item/storage/pill_bottle/bicaridine
	name = "pill bottle (bicaridine)" // Keeping these for mapping or merchants
	desc = "Contains pills used to stabilize the severely injured."
	label_color = "#bf0000"
	starting_label = "bicaridine"

	startswith = list(/obj/item/reagent_containers/pill/bicaridine = 14)

/obj/item/storage/pill_bottle/dexalin
	name = "pill bottle (dexalin)"
	desc = "Contains pills used to treat oxygen deprivation."
	label_color = "#0080ff"
	starting_label = "dexalin"

	startswith = list(/obj/item/reagent_containers/pill/dexalin = 14)

/obj/item/storage/pill_bottle/dexalin_plus
	name = "pill bottle (dexalin plus)"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."
	label_color = "#0040ff"
	starting_label = "dexalin plus"

	startswith = list(/obj/item/reagent_containers/pill/dexalin_plus = 14)

/obj/item/storage/pill_bottle/dermaline
	name = "pill bottle (dermaline)"
	desc = "Contains pills used to treat burn wounds."
	label_color = "#ff8000"
	starting_label = "dermaline"

	startswith = list(/obj/item/reagent_containers/pill/dermaline = 14)

/obj/item/storage/pill_bottle/dylovene
	name = "pill bottle (dylovene)"
	desc = "Contains pills used to treat toxic substances in the blood."
	label_color = "#00a000"
	starting_label = "dylovene"

	startswith = list(/obj/item/reagent_containers/pill/dylovene = 14)

/obj/item/storage/pill_bottle/inaprovaline
	name = "pill bottle (inaprovaline)"
	desc = "Contains pills used to stabilize patients."
	label_color = "#00bfff"
	starting_label = "inaprovaline"

	startswith = list(/obj/item/reagent_containers/pill/inaprovaline = 14)

/obj/item/storage/pill_bottle/kelotane
	name = "pill bottle (kelotane)"
	desc = "Contains pills used to treat burns."
	label_color = "#ffa800"
	starting_label = "kelotane"

	startswith = list(/obj/item/reagent_containers/pill/kelotane = 14)

/obj/item/storage/pill_bottle/spaceacillin
	name = "pill bottle (spaceacillin)"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."
	label_color = "#c1c1c1"
	starting_label = "spaceacillin"

	startswith = list(/obj/item/reagent_containers/pill/spaceacillin = 14)

/obj/item/storage/pill_bottle/tramadol
	name = "pill bottle (tramadol)"
	desc = "Contains pills used to relieve pain."
	label_color = "#cb68fc"
	starting_label = "tramadol"

	startswith = list(/obj/item/reagent_containers/pill/tramadol = 14)

/obj/item/storage/pill_bottle/oxycodone
	name = "pill bottle (oxycodone)"
	desc = "Contains pills of complex painkillers."
	label_color = "#800080"
	starting_label = "oxycodone"

	startswith = list(/obj/item/reagent_containers/pill/oxycodone = 14)

/obj/item/storage/pill_bottle/metazine
	name = "pill bottle (metazine)"
	desc = "Contains pills of combat painkillers."
	label_color = "#b5af80"
	starting_label = "metazine"

	startswith = list(/obj/item/reagent_containers/pill/metazine = 14)

/obj/item/storage/pill_bottle/tricordrazine
	name = "pill bottle (tricordrazine)"
	desc = "Contains pills of treat a wide range of injuries."
	label_color = "#8040ff"
	starting_label = "tricordrazine"

	startswith = list(/obj/item/reagent_containers/pill/tricordrazine = 14)

/obj/item/storage/pill_bottle/alkysine
	name = "pill bottle (alkysine)"
	desc = "Contains pills of aid in healing brain tissue."
	label_color = "#ffff66"
	starting_label = "alkysine"

	startswith = list(/obj/item/reagent_containers/pill/alkysine = 14)

/obj/item/storage/pill_bottle/imidazoline
	name = "pill bottle (imidazoline)"
	desc = "Contains pills of heals eye damage."
	label_color = "#c8a5dc"
	starting_label = "imidazoline"

	startswith = list(/obj/item/reagent_containers/pill/imidazoline = 14)

/obj/item/storage/pill_bottle/ryetalyn
	name = "pill bottle (ryetalyn)"
	desc = "Contains pills of cure all genetic abnomalities."
	label_color = "#004000"
	starting_label = "ryetalyn"

	startswith = list(/obj/item/reagent_containers/pill/ryetalyn = 14)

/obj/item/storage/pill_bottle/peridaxon
	name = "pill bottle (peridaxon)"
	desc = "Contains pills of encourage recovery of internal organs and nervous systems."
	label_color = "#561ec3"
	starting_label = "peridaxon"

	startswith = list(/obj/item/reagent_containers/pill/peridaxon = 14)

/obj/item/storage/pill_bottle/albumin
	name = "pill bottle (albumin)"
	desc = "Contains pills of improve blood regeneration rate."
	label_color = "#803835"
	starting_label = "albumin"

	startswith = list(/obj/item/reagent_containers/pill/albumin = 14)

//Baycode specific Psychiatry pills.
/obj/item/storage/pill_bottle/citalopram
	name = "pill bottle (citalopram)"
	desc = "Mild antidepressant. For use in individuals suffering from depression or anxiety. 15u dose per pill."
	label_color = "#ff80ff"
	starting_label = "citalopram"

	startswith = list(/obj/item/reagent_containers/pill/citalopram = 14)

/obj/item/storage/pill_bottle/methylphenidate
	name = "pill bottle (methylphenidate)"
	desc = "Mental stimulant. For use in individuals suffering from ADHD, or general concentration issues. 15u dose per pill."
	label_color = "#bf80bf"
	starting_label = "methylphenidate"

	startswith = list(/obj/item/reagent_containers/pill/methylphenidate = 14)

/obj/item/storage/pill_bottle/paroxetine
	name = "pill bottle (paroxetine)"
	desc = "High-strength antidepressant. Only for use in severe depression. 10u dose per pill. <span class='warning'>WARNING: side-effects may include hallucinations.</span>"
	label_color = "#ff80bf"
	starting_label = "paroxetine"

	startswith = list(/obj/item/reagent_containers/pill/paroxetine = 14)

/obj/item/storage/pill_bottle/antidexafen
	name = "pill bottle (cold medicine)"
	desc = "All-in-one cold medicine. 15u dose per pill. Safe for babies like you!"
	label_color = "#c8a5dc"
	starting_label = "cold medicine"

	startswith = list(/obj/item/reagent_containers/pill/antidexafen = 14)

/obj/item/storage/pill_bottle/paracetamol
	name = "pill bottle (paracetamol)"
	desc = "Mild painkiller, also known as Tylenol. Won't fix the cause of your headache (unlike cyanide), but might make it bearable."
	label_color = "#c8a5dc"
	starting_label = "paracetamol"

	startswith = list(/obj/item/reagent_containers/pill/paracetamol = 14)

/obj/item/storage/pill_bottle/hyronalin
	name = "pill bottle (hyronalin)"
	desc = "Effective anti radiation drug, best to use with Dylovene. 10u dose per pill"
	label_color = "#408000"
	starting_label = "hyronalin"

	startswith = list(/obj/item/reagent_containers/pill/hyronalin = 14)

/obj/item/storage/pill_bottle/glucose
	name = "pill bottle (glucose)"
	desc = "These pills contain lots of nutriments, much needed for natural blood regeneration. 20u doseper pill"
	label_color = "#ffffff"
	starting_label = "glucose"

	startswith = list(/obj/item/reagent_containers/pill/glucose = 14)

/obj/item/storage/pill_bottle/sugar_cubes
	name = "sugar box"
	desc = "A small box containing some precious cubes of sweetness."
	icon_state = "sugar_bottle"

	startswith = list(/obj/item/reagent_containers/pill/sugar_cube = 14)
