var/list/vampirepower_types = typesof(/datum/power/vampire) - /datum/power/vampire
var/list/datum/power/vampire/vampirepowers = list()

/datum/power/vampire
	var/blood_cost = 0
	var/legacy_handling = FALSE

/datum/power/vampire/alertness
	name = "Alertness"
	desc = "Toggle whether you wish for your victims to forget your deeds."
	helptext = "If active, victims will forget that you fed on them, instead remembering only a pleasant encounter."
	verbpath = /datum/vampire_power/toggled/alertness

/datum/power/vampire/drain_blood
	name = "Drain Blood"
	desc = "Feed on the blood of a humanoid creature in order to gain further power."
	verbpath = /datum/vampire_power/drain_blood

/datum/power/vampire/bloodheal
	name = "Blood Heal"
	desc = "At the cost of time and blood, heal any injuries you have sustained."
	helptext = "You must remain uninterrupted in order to heal yourself."
	verbpath = /datum/vampire_power/bloodheal

/datum/power/vampire/glare
	name = "Glare"
	desc = "Through blood magic, you stun those who are not wearing eye protection and are in your immediate proximity."
	verbpath = /datum/vampire_power/glare

/datum/power/vampire/hypnotise
	name = "Hypnotise"
	desc = "You overwhelm the mind of your victim, rendering them unable to act for a short period of time."
	helptext = "Requires that both you and your victim stay still for a short duration."
	verbpath = /datum/vampire_power/hypnotise

/datum/power/vampire/presence
	name = "Presence"
	desc = "Passively influence mortals around you, making them more open towards your presence."
	helptext = "While active, people around will receive social cues to be friendlier towards your character."
	blood_cost = 50
	verbpath = /datum/vampire_power/toggled/presence

/datum/power/vampire/revitalise
	name = "Revitalise"
	desc = "Allows you to hide among your prey."
	helptext = "Makes the vampire appear alive."
	verbpath = /datum/vampire_power/toggled/revitalise

/datum/power/vampire/touch_of_life
	name = "Touch of Life"
	desc = "You touch the target, transferring healing chemicals to them."
	blood_cost = 50
	verbpath = /datum/vampire_power/touch_of_life

/datum/power/vampire/veilstep
	name = "Veil Step"
	desc = "Enter the Veil for a moment, and skip to a shadow of your choosing."
	helptext = "Right click on any tile to activate. If the tile is covered in shadows to any measure, you will teleport there."
	blood_cost = 100
	legacy_handling = TRUE
	verbpath = /datum/vampire/proc/vampire_veilstep

/datum/power/vampire/bats
	name = "Summon Bats"
	desc = "Tear open the Veil for a moment, and summon forth familiars to assist you in abttle."
	blood_cost = 200
	verbpath = /datum/vampire_power/bats

/datum/power/vampire/screech
	name = "Chiropteran Screech"
	desc = "Emit a powerful screech which shatters glass within a large radius, and stuns those who hear it."
	blood_cost = 200
	verbpath = /datum/vampire_power/screech

/datum/power/vampire/veil_walk
	name = "Veil Walking"
	desc = "You can enter the Veil for a long duration of time, leaving behind only an incorporeal manifestation of yourself."
	helptext = "While veil walking, you can walk through all solid objects and people. Others can see you, but they cannot interact with you. As you stay in this form, you will keep draining your blood. To stop veil walking, activate the power again."
	blood_cost = 250
	verbpath = /datum/vampire_power/toggled/veilwalk

/datum/power/vampire/suggestion
	name = "Suggestion"
	desc = "Influence those weak of mind to follow your instructions."
	helptext = "You and your target must remain stationary for a short period of time for this to work. You can then issue a command to your victim that they must follow in the short term."
	blood_cost = 300
	verbpath = /datum/vampire_power/suggestion

/datum/power/vampire/order
	name = "Order"
	desc = "Influence those weak of mind to follow your order."
	helptext = "You and your target must remain stationary for a short period of time for this to work. You can then issue a single-word command to your victim that they must follow in the short term."
	blood_cost = 100
	verbpath = /datum/vampire_power/order

/datum/power/vampire/enthrall
	name = "Enthrall"
	desc = "Invoke a bloodbond between yourself and a mortal soul. They will then become your slave, required to execute your every command. They will be dependant on your blood."
	helptext = "This works similarly to feeding: you must have a victim pinned to the ground in order for you to enthrall them."
	blood_cost = 300
	verbpath = /datum/vampire_power/enthrall

/datum/power/vampire/embrace
	name = "The Embrace"
	desc = "Corrupt another innocent soul with the power of the Veil. They will become your kin: a vampire."
	blood_cost = 500
	verbpath = /datum/vampire_power/embrace

/datum/power/vampire/darkvision
	name = "Darkvision"
	desc = "Peek through the Veil to cast shadows away and see in the dark."
	verbpath = /datum/vampire_power/toggled/darkvision

/datum/power/vampire/grapple
	name = "Grapple"
	desc = "Lunge towards a target like an animal, and grapple them."
	verbpath = /datum/vampire_power/grapple
	blood_cost = 66666 // Can't gain via normal means... But if one actually manages to do this, he's one cool bloodsucking dude for sure.
