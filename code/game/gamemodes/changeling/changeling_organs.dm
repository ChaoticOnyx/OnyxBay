
/obj/item/organ/internal/biostructure
	name = "strange biostructure"
	desc = "Strange abhorrent biostructure of unknown origins. Is that an alien organ, a xenoparasite or some sort of space cancer? Is that normal to bear things like that inside you?"
	organ_tag = BP_CHANG
	parent_organ = BP_CHEST
	vital = TRUE
	icon_state = "Strange_biostructure"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 10, TECH_ILLEGAL = 5)
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 10
	foreign = TRUE
	var/mob/living/carbon/brain/brainchan = null 	//notice me, biostructure-kun~ (✿˵•́ ‸ •̀˵)
	var/const/damage_threshold_count = 10
	var/last_regen_time = 0
	var/damage_threshold_value
	var/healing_threshold = 1
	var/moving = FALSE
	var/datum/reagents/chem_cauldron // Reagent holder used by the Biochemical Cauldron ability. It's safe to leave it be even if the ability is removed/disabled.

// Called upon creation of a biostructure. TODO: Replace with Initialize(), requires replacing all /organ/New()'s with Initialize()s.
/obj/item/organ/internal/biostructure/New(mob/living/holder)
	..()
	max_damage = 600
	min_bruised_damage = max_damage * 0.25
	min_broken_damage = max_damage * 0.75

	damage_threshold_value = round(max_damage / damage_threshold_count)

	brainchan = new(src)
	brainchan.container = src

	spawn(5)
		if(brainchan?.client)
			brainchan.client.screen.len = null //clear the hud
	reagents.maximum_volume += 5
	reagents.add_reagent(/datum/reagent/toxin/cyanide/change_toxin, 5)
	chem_cauldron = new /datum/reagents(120, src)

/obj/item/organ/internal/biostructure/Destroy()
	QDEL_NULL(brainchan)
	QDEL_NULL(chem_cauldron)
	. = ..()

// Does some magical shit checking /datum/changeling damage
/obj/item/organ/internal/biostructure/proc/check_damage()
	if(owner)
		if(owner.has_damaged_organ())
			owner.mind.changeling.damaged = TRUE
		else
			owner.mind.changeling.damaged = FALSE
	else
		if(brainchan)
			brainchan.mind.changeling.damaged = FALSE

// Transfers mind from M into the brainchan located inside the biostructure
/obj/item/organ/internal/biostructure/proc/mind_into_biostructure(mob/living/M)
	if(status & ORGAN_DEAD)
		return
	if(M?.mind && brainchan)
		M.mind.transfer_to(brainchan)
		to_chat(brainchan, SPAN("changeling", "We feel slightly disoriented."))

// Called when biostructure is taken out of a mob
/obj/item/organ/internal/biostructure/removed(mob/living/user)
	if(vital)
		if(owner)
			mind_into_biostructure(owner)
		else if(istype(loc, /mob/living))
			mind_into_biostructure(loc)

		spawn()
			if(brainchan)
				if(istype(loc, /obj/item/organ/external))
					brainchan.verbs += /mob/proc/transform_into_little_changeling
				else
					brainchan.verbs += /mob/proc/headcrab_runaway
	..()

// Called when biostructure is placed inside a mob
/obj/item/organ/internal/biostructure/replaced(mob/living/target)
	if(!..())
		return FALSE

	if(target.key)
		target.ghostize()

	if(brainchan)
		if(brainchan.mind)
			brainchan.mind.transfer_to(target)
		else
			target.key = brainchan.key

	return TRUE

// Biostructure processing
/obj/item/organ/internal/biostructure/Process()
	. = ..()
	if(damage > max_damage / 2 && healing_threshold)
		if(owner)
			alert(owner, "We have taken massive core damage! We need regeneration.", "Core Damaged")
		else
			alert(brainchan, "We have taken massive core damage! We need host and regeneration.", "Core Damaged")
		healing_threshold = 0
	else if (damage <= max_damage / 2 && !healing_threshold)
		healing_threshold = 1
	if(owner)
		check_damage()
		if(damage <= max_damage / 2 && healing_threshold && world.time < last_regen_time + 40)
			owner.mind.changeling.chem_charges = max(owner.mind.changeling.chem_charges - 0.5, 0)
			damage--
			last_regen_time = world.time


// Kills the biostructure
/obj/item/organ/internal/biostructure/die()
	if(brainchan)
		if(brainchan.mind)
			brainchan.mind.changeling.true_dead = TRUE
			brainchan.mind.current = null
		brainchan.death()
	else
		var/mob/host = loc
		if(istype(host))
			host.mind.changeling.true_dead = TRUE
			host.death()
	dead_icon = "Strange_biostructure_dead"
	QDEL_NULL(brainchan)
	return ..()


// After-creation thingy. Called by /human/revive(). Fuck if I know why since the biostructure, marked as 'foreign', doesn't get deleted during revive(). TODO: Find out what the fuck this piece of rotten spaghetti is.
/obj/item/organ/internal/biostructure/after_organ_creation()
	. = ..()
	change_host(owner)


// Transfers a biostructure from src.loc to atom/destination (physically)
/obj/item/organ/internal/biostructure/proc/change_host(atom/destination)
	var/atom/source = loc
	//deleteing biostructure from external organ so when that organ is deleted biostructure wont be deleted
	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E)
			E.internal_organs -= src
		H.internal_organs_by_name.Remove(BP_CHANG)
		H.internal_organs_by_name -= BP_CHANG
		H.internal_organs_by_name -= null
		H.internal_organs -= src
	else if(istype(source, /obj/item/organ/external))
		var/obj/item/organ/external/E = source
		if(E)
			E.internal_organs -= src

	forceMove(destination)

	//connecting organ
	if(istype(destination, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = destination
		owner = H
		H.internal_organs_by_name[BP_CHANG] = src

		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E)	//wont happen but just in case
			E.internal_organs |= src
			if(E.status & ORGAN_CUT_AWAY)
				E.status &= ~ORGAN_CUT_AWAY

		var/obj/item/organ/internal/brain/B = H.internal_organs_by_name[BP_BRAIN]
		if(B)
			B.vital = FALSE
	else
		owner = null


// Makes a new biostructure OR connects an existing one inside a mob
/mob/living/proc/insert_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
	faction = "biomass"
	log_debug("The changeling biostructure appears in [real_name] ([key]).")

/mob/living/carbon/insert_biostructure()
	var/obj/item/organ/internal/brain/brain = internal_organs_by_name[BP_BRAIN]
	var/obj/item/organ/internal/biostructure/BIO = internal_organs_by_name[BP_CHANG]

	if(brain)
		brain.vital = FALSE
	if(!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
		internal_organs_by_name[BP_CHANG] = BIO
	else
		internal_organs |= BIO
	..()
