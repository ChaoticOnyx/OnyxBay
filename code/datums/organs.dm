/datum/organ
	var/name = "organ"
	var/mob/living/owner = null

/datum/organ/external
	name = "external"
	var/icon_name = null

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/bandaged = 0
	var/max_damage = 0
	var/wound_size = 0
	var/max_size = 0
	var/critical = 0
	var/perma_dmg = 0
	var/bleeding = 0
	var/perma_injury = 0
	var/broken = 0
	var/destroyed
	var/min_broken_damage = 30

	var/damage_msg = "\red You feel an intense pain"
	process()
		if(broken == 0)
			perma_dmg = 0
		if(brute_dam > min_broken_damage)
			if(broken == 0)
				var/dmgmsg = "[damage_msg] in your [display_name]"
				owner << dmgmsg
				for(var/mob/M in viewers(owner))
					if(M != owner)
						M.show_message("\red You hear a loud cracking sound coming from [owner.name]")
				broken = 1
				wound = "broken" //Randomise in future
			// Uncomment for broken bones to matter
		perma_injury = brute_dam + burn_dam
		//	brute_dam = 0
		//	burn_dam = 0
		return
		//return

	var/open = 0
	var/display_name
	var/clean = 1
	var/stage = 0
	var/wound = 0
	var/split = 0

/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	display_name = "chest"
	var/datum/organ/internal/heart
	var/datum/organ/internal/lung
	var/datum/organ/internal/intestines
/datum/organ/external/groin
	name = "groin"
	icon_name = "groin"
	max_damage = 115
	min_broken_damage = 70
	display_name = "groin"
/datum/organ/external/head
	name = "head"
	icon_name = "head"
	max_damage = 125
	min_broken_damage = 70
	display_name = "head"
	var/datum/organ/external/eye_r
	var/datum/organ/external/eye_l
	var/datum/organ/internal/brain
/datum/organ/external/l_arm
	name = "l arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 60
	display_name = "left arm"
/datum/organ/external/l_foot
	name = "l foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 40
	display_name = "left foot"
/datum/organ/external/l_hand
	name = "l hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 40
	display_name = "left hand"
/datum/organ/external/l_leg
	name = "l leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 60
	display_name = "left leg"
/datum/organ/external/r_arm
	name = "r arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 60
	display_name = "right arm"
/datum/organ/external/r_foot
	name = "r foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 40
	display_name = "right foot"
/datum/organ/external/r_hand
	name = "r hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 40
	display_name = "right hand"

/datum/organ/external/r_leg
	name = "r leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 60
	display_name = "right leg"

/datum/organ/internal
	name = "internal"

/datum/organ/internal/blood_vessels
	name = "blood vessels"
	var/heart = null
	var/lungs = null
	var/kidneys = null

/datum/organ/internal/brain
	name = "brain"
	var/head = null

/datum/organ/internal/excretory
	name = "excretory"
	var/excretory = 7.0
	var/blood_vessels = null

/datum/organ/internal/heart
	name = "heart"

/datum/organ/internal/immune_system
	name = "immune system"
	var/blood_vessels = null
	var/isys = null

/datum/organ/internal/intestines
	name = "intestines"
	var/intestines = 3.0
	var/blood_vessels = null

/datum/organ/internal/liver
	name = "liver"
	var/intestines = null
	var/blood_vessels = null

/datum/organ/internal/lungs
	name = "lungs"
	var/lungs = 3.0
	var/throat = null
	var/blood_vessels = null

/datum/organ/internal/stomach
	name = "stomach"
	var/intestines = null

/datum/organ/internal/throat
	name = "throat"
	var/lungs = null
	var/stomach = null