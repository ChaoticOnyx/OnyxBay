//Level 1
/datum/deity_power/boon/create_air
	name = "Create Air"
	desc = "Allows your follower to generate a livable atmosphere in the area they are in."
	power_path = /datum/spell/hand/create_air

/datum/deity_power/boon/acid_spray
	name = "Acid Spray"
	desc = "The simplest form of aggressive conjuration: acid spray is quite effective in melting both man and object."
	power_path = /datum/spell/acid_spray

/datum/deity_power/boon/force_wall
	name = "Force Wall"
	desc = "A temporary invincible wall for followers to summon."
	power_path = /datum/spell/aoe_turf/conjure/forcewall/lesser

/datum/deity_power/boon/dimensional_locker
	name = "Phenomena: Dimensional Locker"
	desc = "Gain the ability to move a magical locker around. While it cannot move living things, you can move it around as you please, even disappearing it into the nether."
	power_path = /datum/spell/hand/dimensional_locker

//Level 2
/datum/deity_power/boon/wizard_armaments
	name = "Right to Bear Arms"
	desc = "Unlock spells related to the summoning of weapons and armor. These spells only last a short duration, but are extremely effective."

/datum/deity_power/boon/sword
	name = "Summon Sword"
	desc = "This spell allows your followers to summon a golden firey sword for a short duration."
	power_path = /datum/spell/targeted/equip_item/dyrnwyn

/datum/deity_power/boon/shield
	name = "Summon Shield"
	desc = "This spell allows your followers to summon a magical shield for a short duration."
	power_path = /datum/spell/targeted/equip_item/shield

//Level 3
/datum/deity_power/boon/force_portal
	name = "Force Portal"
	desc = "This spell allows a follower to summon a force portal. Anything that hits the portal gets sucked inside and is then thrown out when the portal explodes."
	power_path = /datum/spell/aoe_turf/conjure/force_portal
