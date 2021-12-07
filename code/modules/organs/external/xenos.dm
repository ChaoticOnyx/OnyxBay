//XENOMORPH ORGANS
/obj/item/organ/internal/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."
	var/associated_power = /mob/living/carbon/human/proc/resin

/obj/item/organ/internal/xenos/replaced(mob/living/carbon/human/target,obj/item/organ/external/affected)
	. = ..()
	if(ishuman(owner) && associated_power)
		owner.verbs |= associated_power

/obj/item/organ/internal/xenos/removed(mob/living/user)
	. = ..()
	if(ishuman(owner) && associated_power && !(associated_power in owner.species.inherent_verbs))
		owner.verbs -= associated_power

/obj/item/organ/internal/xenos/eggsac
	name = "egg sac"
	parent_organ = BP_GROIN
	icon_state = "xgibmid1"
	organ_tag = BP_EGG
	associated_power = /mob/living/carbon/human/proc/lay_egg

/obj/item/organ/internal/xenos/plasmavessel
	name = "plasma vessel"
	parent_organ = BP_CHEST
	icon_state = "xgibdown1"
	organ_tag = BP_PLASMA
	var/stored_plasma = 0
	var/max_plasma = 500

/obj/item/organ/internal/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	stored_plasma = 200
	max_plasma = 500
	associated_power = /mob/living/carbon/human/proc/toggle_neurotoxin

/obj/item/organ/internal/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/obj/item/organ/internal/xenos/plasmavessel/hunter
	name = "tiny plasma vessel"
	stored_plasma = 100
	max_plasma = 150

/obj/item/organ/internal/xenos/acidgland
	name = "acid gland"
	parent_organ = BP_HEAD
	icon_state = "xgibtorso"
	organ_tag = BP_ACID
	associated_power = /mob/living/carbon/human/proc/corrosive_acid

/obj/item/organ/internal/xenos/hivenode
	name = "hive node"
	parent_organ = BP_CHEST
	icon_state = "xgibmid2"
	organ_tag = BP_HIVE

/obj/item/organ/internal/xenos/resinspinner
	name = "resin spinner"
	parent_organ = BP_HEAD
	icon_state = "xgibmid2"
	organ_tag = BP_RESIN
	associated_power = /mob/living/carbon/human/proc/resin

/obj/item/organ/internal/xenos/ganglion
	name = "spinal ganglion"
	desc = "It reminds both a dead cuttlefish and a wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	parent_organ = BP_CHEST
	icon_state = "weed_extract" // For now it looks... acceptable
	organ_tag = BP_GANGLION
	vital = 1

/obj/item/organ/internal/xenos/ganglion/New(mob/living/carbon/holder)
	..()
	max_damage = 100
	if(species)
		max_damage = species.total_health*1.5
	min_bruised_damage = max_damage*0.25
	min_broken_damage = max_damage*0.75

/obj/item/organ/internal/eyes/xenos/update_colour()
	if(!owner)
		return
	owner.r_eyes = 153
	owner.g_eyes = 0
	owner.b_eyes = 153
	..()

/obj/item/organ/internal/xenos/hivenode/removed(mob/living/user)
	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		to_chat(H, "<span class='alium'>I feel my connection to the hivemind fray and fade away...</span>")
		H.remove_language("Hivemind")
		if(H.mind && H.species.name != "Xenomorph")
			GLOB.xenomorphs.remove_antagonist(H.mind)
	..(user)

/obj/item/organ/internal/xenos/hivenode/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	if(!..())
		return FALSE

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.add_language("Hivemind")
		if(H.mind && H.species.name != "Xenomorph")
			to_chat(H, "<span class='alium'>You feel a sense of pressure as a vast intelligence meshes with your thoughts...</span>")
			GLOB.xenomorphs.add_antagonist_mind(H.mind, 1, GLOB.xenomorphs.faction_role_text, GLOB.xenomorphs.faction_welcome)

	return TRUE

/obj/item/organ/external/head/xeno
	eye_icon = "blank_eyes"
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_HEALS_OVERKILL
	max_damage = 100
	skull_path = null // The head itself is a skull. Exoskeleton, eh?

/obj/item/organ/external/head/xeno/disfigure(type)
	return // Lets just dont, kay?

// Xenolimbs.
/obj/item/organ/external/chest/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_HEALS_OVERKILL
	max_damage = 175

/obj/item/organ/external/groin/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE
	max_damage = 125

/obj/item/organ/external/arm/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP
	max_damage = 75

/obj/item/organ/external/arm/right/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP
	max_damage = 75

/obj/item/organ/external/leg/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND
	max_damage = 85

/obj/item/organ/external/leg/right/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND
	max_damage = 85

/obj/item/organ/external/foot/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND
	max_damage = 65

/obj/item/organ/external/foot/right/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND
	max_damage = 65

/obj/item/organ/external/hand/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP
	max_damage = 55

/obj/item/organ/external/hand/right/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP
	max_damage = 55

// RIP /datum/disease/alien_embryo, no more shall you be cured with gargle blaster
/obj/item/organ/internal/alien_embryo
	name = "alien embryo"
	desc = "A small worm-like creature caged in a half-transparent caviar-like thingy. Whatever this thing is, it doesn't look like it should be found in a living being by default."
	icon = 'icons/mob/alien.dmi'
	organ_tag = BP_EMBRYO
	parent_organ = BP_CHEST
	vital = 0
	icon_state = "embryo"
	dead_icon = "embryo_dead"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 8, TECH_ILLEGAL = 2)
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 10
	foreign = TRUE
	max_damage = 66
	var/growth = 0
	var/growth_max = 240

/obj/item/organ/internal/alien_embryo/Process()
	if(owner && !(status & ORGAN_DEAD))
		growth++
		BITSET(owner.hud_updateflag, XENO_HUD)
		if(growth > growth_max)
			var/larva_path = null
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if(H.species)
					larva_path = H.species.xenomorph_type
			if(!larva_path) // Something went very wrong, the host cannot give birth
				die()
				return PROCESS_KILL
			var/birth_loc = loc
			spawn(1 SECOND) // So the newborn larvae won't get shredded by flying limbs
				var/mob/living/carbon/alien/larva/L = new larva_path(get_turf(birth_loc))
				L.larva_announce_to_ghosts()
			die()
			owner.gib()
			QDEL_NULL(src)
			return PROCESS_KILL
		else if(owner.can_feel_pain())
			var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
			switch(growth)
				if(230 to INFINITY)
					if(prob(50))
						owner.custom_pain("Something is just about to burst through your chest!", 60, affecting = parent)
					owner.Weaken(10)
					owner.Stun(10)
					owner.make_jittery(100)
				if(200 to 229)
					if(prob(20))
						owner.custom_pain("You feel like your chest is ripping apart!", 45, affecting = parent)
				if(140 to 199)
					if(prob(10))
						owner.custom_pain("You feel a stabbing pain in your chest!", 15, affecting = parent)
				if(70 to 139)
					if(prob(5))
						owner.custom_pain("You feel a stinging pain in your chest!", 5, affecting = parent)
		else if(growth == 235)
			to_chat(owner, SPAN("danger", "You feel like something is massacring your chest from the inside!"))
			owner.Weaken(10)
			owner.Stun(10)
	..()
