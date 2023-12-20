//XENOMORPH ORGANS
/obj/item/organ/internal/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."
	override_species_icon = TRUE
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
	relative_size = 15

/obj/item/organ/internal/xenos/resinspinner
	name = "resin spinner"
	parent_organ = BP_HEAD
	icon_state = "xgibmid2"
	organ_tag = BP_RESIN
	associated_power = /mob/living/carbon/human/proc/resin
	relative_size = 20

/obj/item/organ/internal/xenos/ganglion
	name = "spinal ganglion"
	desc = "It reminds both a dead cuttlefish and a wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	parent_organ = BP_CHEST
	icon_state = "weed_extract" // For now it looks... acceptable
	organ_tag = BP_GANGLION
	vital = TRUE
	relative_size = 30

/obj/item/organ/internal/xenos/ganglion/New(mob/living/carbon/holder)
	..()
	max_damage = 100
	if(species)
		max_damage = species.total_health
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
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_HEALS_OVERKILL
	max_damage = 125
	skull_path = null // The head itself is a skull. Exoskeleton, eh?

/obj/item/organ/external/head/xeno/disfigure(type)
	return // Lets just dont, kay?

// Xenolimbs.
/obj/item/organ/external/chest/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_HEALS_OVERKILL
	max_damage = 150

/obj/item/organ/external/groin/xeno
	dislocated = -1
	arterial_bleed_severity = 0
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_HEALS_OVERKILL
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
