
/obj/item/organ/internal/biostructure
	name = "strange biostructure"
	desc = "Strange abhorrent biological structure of unknown origins. Is that an alien organ, a xenoparasite or some sort of space cancer? Is it normal to bear things like that inside you?"
	organ_tag = BP_CHANG
	parent_organ = BP_CHEST
	vital = TRUE
	icon_state = "strange-biostructure"
	dead_icon = "strange-biostructure-dead"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 10, TECH_ILLEGAL = 5)
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 10
	foreign = TRUE
	max_damage = 600

	var/mob/living/carbon/brain/brainchan = null 	//notice me, biostructure-kun~ (✿˵•́ ‸ •̀˵)
	var/const/damage_threshold_count = 10
	var/last_regen_time = 0
	var/damage_threshold_value
	var/healing_threshold = 1
	var/moving = FALSE

// Called upon creation of a biostructure. TODO: Replace with Initialize(), requires replacing all /organ/New()'s with Initialize()s.
/obj/item/organ/internal/biostructure/New(mob/living/holder)
	..()
	min_bruised_damage = max_damage * 0.25
	min_broken_damage = max_damage * 0.75

	damage_threshold_value = round(max_damage / damage_threshold_count)

	brainchan = new(src)
	brainchan.container = src

	spawn(5)
		brainchan?.client?.screen.len = null //clear the hud

	reagents.maximum_volume += 5
	reagents.add_reagent(/datum/reagent/toxin/cyanide/change_toxin, 5)


/obj/item/organ/internal/biostructure/Destroy()
	die()
	QDEL_NULL(brainchan)
	. = ..()


// Biostructure processing
/obj/item/organ/internal/biostructure/Process()
	. = ..()
	if((damage > (max_damage / 2)) && healing_threshold)
		if(owner)
			alert(owner, "We have taken massive core damage! We need regeneration.", "Core Damaged")
		else
			alert(brainchan, "We have taken massive core damage! We need host and regeneration.", "Core Damaged")
		healing_threshold = FALSE
	else if((damage <= (max_damage / 2)) && !healing_threshold)
		healing_threshold = TRUE
	if(owner)
		check_damage()
		if((damage <= (max_damage / 2)) && healing_threshold && (world.time < (last_regen_time + 40)))
			owner.mind.changeling.chem_charges = max(owner.mind.changeling.chem_charges - 0.5, 0)
			damage--
			last_regen_time = world.time


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
/obj/item/organ/internal/biostructure/proc/take_mind_from(mob/living/M)
	if(status & ORGAN_DEAD)
		return
	if(M?.mind && brainchan)
		to_chat(M, SPAN("changeling", "We feel slightly disoriented."))
		M.mind.transfer_to(brainchan)


// Called when biostructure is taken out of a mob
/obj/item/organ/internal/biostructure/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	//var/already_removed = FALSE
	//var/drop_loc = null
	//if(drop_organ && owner)
	//	drop_loc = owner.loc
	//	log_debug("Called removed() and found drop_loc: [drop_loc]")

	if(vital)
		if(owner)
				// A lil bit of explaination here. The owner var may get nullified during take_mind_from(), preventing parential /removed() from being executed properly.
				// On the other hand, parential /removed() also nullifies the owner, breaking take_mind_from(). Thus, we save our old owner, call parential /removed() and then take mind from our old saved owner. God bless spaghetti.
				//var/mob/living/carbon/human/H = owner
				//..()
			log_debug("Called removed() with owner provided (owner: [owner])")
			take_mind_from(owner)
				//already_removed = TRUE
		else if(isliving(loc))
			log_debug("Called removed() without owner provided (loc: [loc])")
			take_mind_from(loc)

		spawn()
			if(brainchan)
				if(istype(loc, /obj/item/organ/external))
					brainchan.verbs += /mob/living/carbon/brain/proc/transform_into_little_changeling
				else
					brainchan.verbs += /mob/living/carbon/brain/proc/headcrab_runaway

	//if(drop_loc)
	//	dropInto(drop_loc)
	//if(!already_removed)
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
			log_debug("Changeling Shenanigans: [src] had no brainchain during replaced() call. [target] ([target.key]) may get bugged.")
			target.key = brainchan.key

	return TRUE


// Kills the biostructure
/obj/item/organ/internal/biostructure/die()
	if(brainchan)
		if(brainchan.mind)
			brainchan.mind.changeling.die()
			brainchan.mind.current = null
		brainchan.death()
	else
		if(owner)
			owner.mind?.changeling.die()
			owner.death()
	QDEL_NULL(brainchan)
	return ..()


// Makes us reconnect to our owner when we get revived, implanted or something.
/obj/item/organ/internal/biostructure/handle_foreign()
	..()
	change_host(owner)


// Transfers a biostructure from src.loc to atom/destination (physically)
/obj/item/organ/internal/biostructure/proc/change_host(atom/destination)
	if(QDELETED(destination))
		log_debug("Changeling Shenanigans: [src] ([loc]) tried to call change_host() with destination ([destination]) being GCd.")
		return // Something wrong, no need to throw ourselves into a garbage crusher.

	var/atom/source = loc
	//deleteing biostructure from external organ so when that organ is deleted biostructure wont be deleted
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		if(H == owner)
			H.internal_organs_by_name.Remove(BP_CHANG)
			H.internal_organs_by_name -= BP_CHANG // Yes this is intended, even after the previous line. Everything will get broken if you remove this.
			H.internal_organs -= src

			var/obj/item/organ/external/affected = H.get_organ(parent_organ)
			if(affected)
				affected.internal_organs -= src
				status |= ORGAN_CUT_AWAY
		else
			H.drop_from_inventory(src)

	else if(istype(source, /obj/item/organ/external))
		var/obj/item/organ/external/E = source
		E.internal_organs.Remove(src)

	forceMove(destination)

	// Connecting biostructure as an organ.
	if(ishuman(destination))
		var/mob/living/carbon/human/H = destination
		owner = H
		H.internal_organs_by_name[BP_CHANG] = src
		H.internal_organs |= src

		var/obj/item/organ/external/affected = H.get_organ(parent_organ)
		if(affected)	//wont happen but just in case
			affected.internal_organs |= src
			if(status & ORGAN_CUT_AWAY)
				status &= ~ORGAN_CUT_AWAY

		var/obj/item/organ/internal/brain/B = H.internal_organs_by_name[BP_BRAIN]
		B?.vital = FALSE
	else
		owner = null


// Makes a new biostructure OR connects an existing one inside a mob
/mob/proc/setup_changeling_biostructure()
	return

/mob/living/setup_changeling_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
		log_debug("New changeling biostructure spawned in [name] / [real_name] ([key]).")
	BIO.change_host(src)
	faction = "changeling"

/mob/living/carbon/brain/setup_changeling_biostructure()
	return // Nothing is needed here. Deriving brain from carbons and naming it BRAIN was the shittiest move ever.
