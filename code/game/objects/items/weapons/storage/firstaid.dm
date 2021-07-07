/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/weapon/storage/firstaid/empty
	icon_state = "firstaid"
	name = "First-Aid (empty)"

/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/ointment,
		/obj/item/weapon/storage/pill_bottle/kelotane,
		/obj/item/weapon/storage/pill_bottle/paracetamol
		)

/obj/item/weapon/storage/firstaid/fire/New()
	..()
	icon_state = pick("ointment","firefirstaid")

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

	startswith = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/weapon/storage/pill_bottle/antidexafen,
		/obj/item/weapon/storage/pill_bottle/paracetamol
		)

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

	startswith = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin/packaged = 3,
		/obj/item/weapon/storage/pill_bottle/dylovene,
		/obj/item/device/healthanalyzer,
		)

/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

	startswith = list(
		/obj/item/weapon/storage/pill_bottle/dexalin,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/weapon/reagent_containers/syringe/inaprovaline/packaged,
		/obj/item/device/healthanalyzer,
		)

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint
		)

/obj/item/weapon/storage/firstaid/combat
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/storage/pill_bottle/bicaridine,
		/obj/item/weapon/storage/pill_bottle/dermaline,
		/obj/item/weapon/storage/pill_bottle/dexalin_plus,
		/obj/item/weapon/storage/pill_bottle/dylovene,
		/obj/item/weapon/storage/pill_bottle/tramadol,
		/obj/item/weapon/storage/pill_bottle/spaceacillin,
		/obj/item/stack/medical/splint,
		)

/obj/item/weapon/storage/firstaid/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport and automatically sterilizes the content between uses."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"

	storage_slots = 14
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = null

	can_hold = list(
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/cautery,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/weapon/organfixer,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste
		)

	startswith = list(
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/cautery,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/weapon/organfixer/standard,
		/obj/item/stack/medical/advanced/bruise_pack,
		)

/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 14
	can_hold = list(/obj/item/weapon/reagent_containers/pill, /obj/item/weapon/dice, /obj/item/weapon/paper)
	allow_quick_gather = 1
	use_to_pickup = 1
	use_sound = 'sound/effects/using/bottles/use1.ogg'
	var/label_color = null
	var/spam_flag = FALSE
	var/starting_label = null

/obj/item/weapon/storage/pill_bottle/Initialize()
	. = ..()
	update_icon()
	if(starting_label)
		name = "pill bottle"
		attach_label(null, null, starting_label) // So the name isn't hardcoded and the label can be removed for reusability

/obj/item/weapon/storage/pill_bottle/update_icon()
	overlays.Cut()
	if(label_color)
		var/image/label_over = overlay_image(icon, "[icon_state]-overlay")
		label_over.color = label_color
		overlays += label_over

/obj/item/weapon/storage/pill_bottle/attack_self(mob/user)
	if(user.get_inactive_hand())
		to_chat(user, SPAN("notice", "You need an empty hand to take something out."))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		if(!remove_from_storage(I, user))
			return
		if(user.put_in_inactive_hand(I))
			to_chat(user, SPAN("notice", "You take \the [I] out of \the [src]."))
			user.swap_hand()
		else
			I.dropInto(loc)
			to_chat(user, SPAN("warning", "You fumble around with \the [src] and drop \the [I] on the floor."))
	else
		to_chat(user, SPAN("warning", "\The [src] is empty."))

/obj/item/weapon/storage/pill_bottle/attack(mob/M, mob/user, def_zone)
	if(spam_flag)
		return FALSE
	var/obj/item/weapon/reagent_containers/pill/pill = locate(/obj/item/weapon/reagent_containers/pill) in shuffle(contents.Copy())
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

/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "pill bottle (bicaridine)" // Keeping these for mapping
	desc = "Contains pills used to stabilize the severely injured."
	label_color = "#bf0000"
	starting_label = "bicaridine"

	startswith = list(/obj/item/weapon/reagent_containers/pill/bicaridine = 14)

/obj/item/weapon/storage/pill_bottle/dexalin
	name = "pill bottle (dexalin)"
	desc = "Contains pills used to treat oxygen deprivation."
	label_color = "#0080ff"
	starting_label = "dexalin"

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin = 14)

/obj/item/weapon/storage/pill_bottle/dexalin_plus
	name = "pill bottle (dexalin plus)"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."
	label_color = "#0040ff"
	starting_label = "dexalin plus"

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin_plus = 14)

/obj/item/weapon/storage/pill_bottle/dermaline
	name = "pill bottle (dermaline)"
	desc = "Contains pills used to treat burn wounds."
	label_color = "#ff8000"
	starting_label = "dermaline"

	startswith = list(/obj/item/weapon/reagent_containers/pill/dermaline = 14)

/obj/item/weapon/storage/pill_bottle/dylovene
	name = "pill bottle (dylovene)"
	desc = "Contains pills used to treat toxic substances in the blood."
	label_color = "#00a000"
	starting_label = "dylovene"

	startswith = list(/obj/item/weapon/reagent_containers/pill/dylovene = 14)

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "pill bottle (inaprovaline)"
	desc = "Contains pills used to stabilize patients."
	label_color = "#00bfff"
	starting_label = "inaprovaline"

	startswith = list(/obj/item/weapon/reagent_containers/pill/inaprovaline = 14)

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "pill bottle (kelotane)"
	desc = "Contains pills used to treat burns."
	label_color = "#ffa800"
	starting_label = "kelotane"

	startswith = list(/obj/item/weapon/reagent_containers/pill/kelotane = 14)

/obj/item/weapon/storage/pill_bottle/spaceacillin
	name = "pill bottle (spaceacillin)"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."
	label_color = "#c1c1c1"
	starting_label = "spaceacillin"

	startswith = list(/obj/item/weapon/reagent_containers/pill/spaceacillin = 14)

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "pill bottle (tramadol)"
	desc = "Contains pills used to relieve pain."
	label_color = "#cb68fc"
	starting_label = "tramadol"

	startswith = list(/obj/item/weapon/reagent_containers/pill/tramadol = 14)

//Baycode specific Psychiatry pills.
/obj/item/weapon/storage/pill_bottle/citalopram
	name = "pill bottle (citalopram)"
	desc = "Mild antidepressant. For use in individuals suffering from depression or anxiety. 15u dose per pill."
	label_color = "#ff80ff"
	starting_label = "citalopram"

	startswith = list(/obj/item/weapon/reagent_containers/pill/citalopram = 14)

/obj/item/weapon/storage/pill_bottle/methylphenidate
	name = "pill bottle (methylphenidate)"
	desc = "Mental stimulant. For use in individuals suffering from ADHD, or general concentration issues. 15u dose per pill."
	label_color = "#bf80bf"
	starting_label = "methylphenidate"

	startswith = list(/obj/item/weapon/reagent_containers/pill/methylphenidate = 14)

/obj/item/weapon/storage/pill_bottle/paroxetine
	name = "pill bottle (paroxetine)"
	desc = "High-strength antidepressant. Only for use in severe depression. 10u dose per pill. <span class='warning'>WARNING: side-effects may include hallucinations.</span>"
	label_color = "#ff80bf"
	starting_label = "paroxetine"

	startswith = list(/obj/item/weapon/reagent_containers/pill/paroxetine = 14)

/obj/item/weapon/storage/pill_bottle/antidexafen
	name = "pill bottle (cold medicine)"
	desc = "All-in-one cold medicine. 15u dose per pill. Safe for babies like you!"
	label_color = "#c8a5dc"
	starting_label = "cold medicine"

	startswith = list(/obj/item/weapon/reagent_containers/pill/antidexafen = 14)

/obj/item/weapon/storage/pill_bottle/paracetamol
	name = "pill bottle (paracetamol)"
	desc = "Mild painkiller, also known as Tylenol. Won't fix the cause of your headache (unlike cyanide), but might make it bearable."
	label_color = "#c8a5dc"
	starting_label = "paracetamol"

	startswith = list(/obj/item/weapon/reagent_containers/pill/paracetamol = 14)

/obj/item/weapon/storage/pill_bottle/hyronalin
	name = "pill bottle (hyronalin)"
	desc = "Effective anti radiation drug, best to use with Dylovene. 10u dose per pill"
	label_color = "#408000"
	starting_label = "hyronalin"

	startswith = list(/obj/item/weapon/reagent_containers/pill/hyronalin = 14)

/obj/item/weapon/storage/pill_bottle/glucose
	name = "pill bottle (glucose)"
	desc = "These pills contain lots of nutriments, much needed for natural blood regeneration. 20u doseper pill"
	label_color = "#ffffff"
	starting_label = "glucose"

	startswith = list(/obj/item/weapon/reagent_containers/pill/glucose = 14)
