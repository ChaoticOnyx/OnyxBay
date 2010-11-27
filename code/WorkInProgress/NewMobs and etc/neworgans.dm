/datum/organ
	var/name = "organ"
	var/mob/living/owner = null

/datum/organ/external
	name = "external"
	var/icon_name = null
	var/list/wounds = list()
	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/slash_dam = 0
	var/bandaged = 0
	var/max_damage = 0
	var/wound_size = 0
	var/max_size = 0
	var/critical = 0
	var/perma_dmg = 0
	var/bleeding = 0
	var/perma_injury = 0
	var/broken = 0
	var/destroyed = 0
	var/destspawn
	var/obj/item/weapon/implant/implant = null
	var/min_broken_damage = 30
	var/datum/organ/external/parent
	var/damage_msg = "\red You feel a intense pain"
	process()
		if(destroyed)
			if(destspawn)
				droplimb()
			return
		if(broken == 0)
			perma_dmg = 0
		if(parent)
			if(parent.destroyed)
				destroyed = 1
				owner:update_body()
				return
		if(brute_dam > min_broken_damage)
			if(broken == 0)
				var/dmgmsg = "[damage_msg] in your [display_name]"
				owner << dmgmsg
				owner.unlock_medal("Broke Yarrr Bones!", 0, "Break a bone.", "easy")
				for(var/mob/M in viewers(owner))
					if(M != owner)
						M.show_message("\red You hear a loud cracking sound coming from [owner.name].")
				broken = 1
				wound = "broken" //Randomise in future
				perma_injury = brute_dam
			return
		return

	var/open = 0
	var/display_name
	var/clean = 1
	var/stage = 0
	var/wound = 0
	var/split = 0

/datum/organ/external/proc/createwound(var/size = 1)
	if(ishuman(src.owner))
		var/datum/organ/external/wound/W = new(src)
		W.bleeding = 1
		src.owner:bloodloss += 10 * size
		W.wound_size = size
		W.owner = src.owner
		src.wounds += W

/datum/organ/external/wound
	name = "wound"
	wound_size = 1
	icon_name = "wound"
	display_name = "wound"
	parent = null

/datum/organ/external/wound/proc/stopbleeding()
	if(!src.bleeding)
		return
	var/t = 10 * src.wound_size
	src.owner:bloodloss -= t
	src.bleeding = 0
	del(src)

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
	icon_name = "arm_left"
	max_damage = 75
	min_broken_damage = 30
	display_name = "left arm"

/datum/organ/external/l_foot
	name = "l foot"
	icon_name = "foot_left"
	max_damage = 40
	min_broken_damage = 15
	display_name = "left foot"

/datum/organ/external/l_hand
	name = "l hand"
	icon_name = "hand_left"
	max_damage = 40
	min_broken_damage = 15
	display_name = "left hand"

/datum/organ/external/l_leg
	name = "l leg"
	icon_name = "leg_left"
	max_damage = 75
	min_broken_damage = 30
	display_name = "left leg"

/datum/organ/external/r_arm
	name = "r arm"
	icon_name = "arm_right"
	max_damage = 75
	min_broken_damage = 30
	display_name = "right arm"

/datum/organ/external/r_foot
	name = "r foot"
	icon_name = "foot_right"
	max_damage = 40
	min_broken_damage = 15
	display_name = "right foot"

/datum/organ/external/r_hand
	name = "r hand"
	icon_name = "hand_right"
	max_damage = 40
	min_broken_damage = 15
	display_name = "right hand"

/datum/organ/external/r_leg
	name = "r leg"
	icon_name = "leg_right"
	max_damage = 75
	min_broken_damage = 30
	display_name = "right leg"

/datum/organ/internal
	name = "internal"

/datum/organ/internal/blood_vessels
	name = "blood vessels"
	var/datum/reagents/reagents

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

/datum/organ/external/proc/droplimb()
	if(destroyed)
		if(destroyed)
			if(destroyed)
				owner.unlock_medal("Lost something?", 0, "Lose a limb.", "easy")
				if(name == "chest")
					owner.gib()
				if(name == "head")
					var/obj/item/weapon/organ/head/H = new(owner.loc)
					var/lol = pick(cardinal)
					step(H,lol)
					owner:update_face()
					owner:update_body()
					return
				if(name == "r arm")
					var/obj/item/weapon/organ/r_arm/H = new(owner.loc)
					if(owner:organs["l_hand"])
						var/datum/organ/external/S = owner:organs["l_hand"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/r_hand/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "l arm")
					var/obj/item/weapon/organ/l_arm/H = new(owner.loc)
					if(owner:organs["l_hand"])
						var/datum/organ/external/S = owner:organs["l_hand"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_hand/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off in arc.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "r leg")
					var/obj/item/weapon/organ/r_leg/H = new(owner.loc)
					if(owner:organs["r_foot"])
						var/datum/organ/external/S = owner:organs["r_foot"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_foot/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off flies off in arc.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return
				if(name == "l leg")
					var/obj/item/weapon/organ/l_leg/H = new(owner.loc)
					if(owner:organs["l_foot"])
						var/datum/organ/external/S = owner:organs["l_foot"]
						if(!S.destroyed)
							var/obj/item/weapon/organ/l_foot/X = new(owner.loc)
							for(var/mob/M in viewers(owner))
								M.show_message("\red [owner.name]'s [X.name] flies off.")
							var/lol2 = pick(cardinal)
							step(X,lol2)
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
					return