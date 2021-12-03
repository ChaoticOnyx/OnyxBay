// HIVE MIND UPLOAD/DOWNLOAD DNA
var/list/datum/absorbed_dna/hivemind_bank = list()

// For changeling names generation
var/global/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

// Changeling datum, belongs to one's mind
// Stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
/datum/changeling
	var/changelingID = "Changeling"

	var/list/datum/absorbed_dna/absorbed_dna = list()
	var/list/datum/changeling_power/available_powers = list()
	var/list/absorbed_languages = list()

	var/absorbedcount = 0

	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50

	var/geneticdamage = 0
	var/geneticpoints = 10

	var/list/purchasedpowers = list() // Purchased instances of /datum/power/changeling; not to be confused with available_powers.

	var/mimicing = ""
	var/lingabsorbedcount = 1

	var/recursive_enhancement = FALSE // Used to power up other abilities from the ling power with the same name.
	var/boost_sting_range = FALSE // Whether we have our Boost Range toggled on.

	var/using_proboscis = FALSE
	var/true_dead = FALSE
	var/damaged = FALSE
	var/heal = 0
	var/isdetachingnow = FALSE
	var/FLP_last_time_used = 0
	var/rapidregen_active = FALSE
	var/is_revive_ready = FALSE
	var/last_transformation_at = 0

	var/mob/my_mob = null


/datum/changeling/New(mob/_M)
	..()
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[changelingID]"
	else
		changelingID = "[rand(1,99)]"
	update_my_mob(_M)
	START_PROCESSING(SSmobs, src)


// Chemicals and genetic damage regeneration.
/datum/changeling/Process()
	if(!my_mob || my_mob.stat == DEAD || my_mob.InStasis())
		return
	chem_charges = min(max(0, chem_charges + chem_recharge_rate), chem_storage)
	geneticdamage = max(0, geneticdamage - 1)


/datum/changeling/Destroy()
	die()
	purchasedpowers = null
	my_mob = null
	absorbed_languages.Cut()
	absorbed_dna.Cut()
	. = ..()


// Here we finally die and live no more.
/datum/changeling/proc/die()
	remove_changeling_powers(FALSE) // Keeping purchases list, removing actual abilities.
	if(my_mob)
		to_chat(my_mob, SPAN("changeling", "That's it. We hunt no more."))
	true_dead = TRUE
	STOP_PROCESSING(SSmobs, src)


// Transfers us to another mob.
/datum/changeling/proc/transfer_to(mob/living/L)
	if(!L.mind)
		return FALSE
	L.mind.changeling = src
	L.make_changeling()
	return TRUE


// Sets new my_mob, updates changeling powers' my_mob as well.
/datum/changeling/proc/update_my_mob(mob/new_mob)
	if(my_mob != new_mob)
		my_mob = new_mob
	for(var/datum/changeling_power/CP in available_powers)
		CP.my_mob = my_mob


// Syncs my_mob's known languages with our languages.
/datum/changeling/proc/update_languages()
	my_mob.languages = list()
	for(var/language in absorbed_languages)
		my_mob.languages += language

	//This isn't strictly necessary but just to be safe...
	my_mob.add_language("Changeling")
	return


// Checks if we are using stasis right now.
/datum/changeling/proc/is_regenerating()
	if(my_mob.status_flags & FAKEDEATH)
		return TRUE
	else
		return FALSE


// Checks if we are in stasis or dead. Some abilities don't need all the checks performed by is_usable(), so we use this one.
/datum/changeling/proc/is_incapacitated(max_stat = CONSCIOUS, allow_stasis = FALSE, no_message = FALSE)
	if(!allow_stasis && (my_mob.status_flags & FAKEDEATH))
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "We cannot use our body while in stasis."))
		return TRUE

	if(my_mob.stat > max_stat)
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "We are incapacitated."))
		return TRUE

	return FALSE


/datum/changeling/proc/GetDNA(dna_owner)
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		if(dna_owner == DNA.name)
			return DNA


/datum/changeling/proc/absorbDNA(datum/absorbed_dna/newDNA)
	for(var/language in newDNA.languages)
		absorbed_languages |= language

	update_languages(absorbed_languages)

	if(!GetDNA(newDNA.name)) // Don't duplicate - I wonder if it's possible for it to still be a different DNA? DNA code could use a rewrite
		absorbed_dna += newDNA


///////////////////////////
// POWERS-RELATED PROCS ///
///////////////////////////
/datum/changeling/proc/add_changeling_power(datum/changeling_power/P)
	if(P in purchasedpowers)
		for(var/datum/changeling_power/CP in available_powers)
			if(CP.type == P.power_path)
				return
	var/datum/changeling_power/CP = new P.power_path(my_mob)
	if(!CP.desc)
		CP.desc = P.desc


// This one can accept both datum/power/changeling and /datum/changeling_power instances
/datum/changeling/proc/remove_changeling_power(target_power, remove_purchased = TRUE)
	if(istype(target_power, /datum/power/changeling))
		var/datum/power/changeling/P = target_power
		if(P in purchasedpowers)
			for(var/datum/changeling_power/CP in available_powers)
				if(CP.type == P.power_path)
					target_power = CP
			if(remove_purchased)
				purchasedpowers.Remove(P)

	if(istype(target_power, /datum/changeling_power))
		var/datum/changeling_power/CP = target_power
		if(CP in available_powers)
			qdel(CP)
		return

	CRASH("[src]'s remove_changeling_power() has recieved an invalid argument.")


// Removes all changeling powers.
/datum/changeling/proc/remove_changeling_powers(remove_purchased = TRUE)
	if(remove_purchased)
		purchasedpowers.Cut()
	for(var/CP in available_powers)
		remove_changeling_power(CP)
	available_powers.Cut()


// Auto-purchases free powers, updates things and yadda yadda
// Don't spam it too frequently.
/datum/changeling/proc/update_changeling_powers()
	if(!my_mob?.mind)
		return

	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost && !(P in purchasedpowers)) // Is it free? Do we not have it already?
			changeling.purchasePower(my_mob.mind, P.name, 0) // Purchase it.

	var/mob_in_lesser_form = !ishuman(my_mob)
	checking_purchased:
		for(var/datum/power/changeling/P in purchasedpowers)
			for(var/datum/changeling_power/CP in available_powers)
				if(CP.type == P.power_path)
					if(mob_in_lesser_form && !P.allowduringlesserform)
						remove_changeling_power(CP)
					continue checking_purchased
			if(mob_in_lesser_form && !P.allowduringlesserform)
				continue
			add_changeling_power(P)

	my_mob.ability_master.reskin_changeling()
	my_mob.ability_master.update_abilities()


// Deactivates all current stings to make sure my_mob doesn't have queued sting click handlers.
/datum/changeling/proc/deactivate_stings()
	for(var/datum/changeling_power/toggled/sting/S in available_powers)
		S.deactivate()
