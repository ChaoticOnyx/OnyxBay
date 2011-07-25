// This requires a list variable (powers) on all groups of mobs you want to be able to have them
// Then, code for each power is written into relevant sections (for instance electric resistance being written into all
// electric shock procs)

/datum/power
	var/name = "power"
	var/sprite = null
	var/mob/affected_mob = null
	var/variant = 1 // for powers with more than one "mode" as such
	var/timeleft = 1 // set this when the power is given
	var/removeondeath = 1
	var/catchtext = null // Does it give the user a message when they gain the power?
	var/removetext = null // As above but for removal

/datum/power/proc/stage_act()
	if(timeleft > 0) timeleft--
	if(timeleft == 0)
		if (affected_mob.client && src.removetext) src << "[src.removetext]"
		affected_mob.powers -= src
	if(affected_mob.stat == 2 && removeondeath) affected_mob.powers -= src
	return

/mob/proc/give_power(var/datum/power/am, var/time, var/powvar = 1, var/silent = 0)
	if(src.stat == 2) return
	if(!istype(src,/mob/living/carbon/human)) return
	for(var/datum/power/A in src.powers)
		if(istype(A, am)) return
	src.powers += am
	am.affected_mob = src
	am.timeleft = time
	am.variant = powvar
	if (!silent && src.client && am.catchtext) src << "[am.catchtext]"
	// Sprite overlay dealt with on Line 902 of
	// code\modules\mob\living\carbon\human\human.dm

/client/proc/cmd_give_power(var/mob/living/carbon/human/mob in world)
	set name = "Give Power"
	set desc = "Add a Power to this mob."
	set category = "Special Verbs"
	set popup_menu = 0
	var/thepow = input("Select a power","Powers",null) as null|anything in typesof(/datum/power)
	if (!thepow) return
	var/powtime = input("How many seconds?","Powers",null) as num
	if (!powtime) return
	var/powervar = input("Which variant?","Powers",null) as num
	if (!powervar) return
	mob.give_power(new thepow, powtime, powervar)

///
/// Powers list starts here
///
/// if (locate(/datum/power/INSERT POWER HERE) in src.powers)
/// ^ works for power detection

/datum/power/resist_electric
	name = "Electric Resistance"
	sprite = "elec"
	catchtext = "\blue Your hair stands on end."
	removetext = "\red The tingling in your skin fades."
	// Variant 1 = Resistance, Variant 2 = Absorption
	// Invoked on:
	// code\game\machinery\singularity.dm
	// code\game\machinery\vending.dm
	// code\game\machinery\doors\airlock.dm
	// code\game\objects\items\weapons\guns_ammo.dm
	// code\modules\power\apc.dm
	// code\modules\power\cable.dm
	// code\modules\power\cell.dm
	// code\game\objects\items\weapons\swords_axes_etc.dm

/datum/power/resist_alcohol
	name = "Hard Drinker"
	// Line 2457 of code\WorkInProgress\Chemistry-Reagents.dm

/datum/power/darkcloak
	name = "Cloak of Darkness"
	catchtext = "\blue You begin to fade into the shadows."
	removetext = "\red You become fully visible."
	// Line 1264 of code\modules\mob\living\carbon\human\human.dm

/datum/power/accent_swedish
	name = "Swedish Accent"
	catchtext = "\blue You feel Swedish... somehow."
	removetext = "\blue The feeling of Swedishness passes."
	// Line 20 of code\modules\mob\living\carbon\human\say.dm