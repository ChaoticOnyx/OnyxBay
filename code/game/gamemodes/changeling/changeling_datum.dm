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

	var/chem_charges = 40
	var/chem_recharge_rate = 0.5
	var/chem_storage = 100

	var/genome_damage = 0 // use (set|apply)_genome_damage
	var/geneticpoints = 10

	var/list/purchasedpowers = list() // Purchased instances of /datum/power/changeling; not to be confused with available_powers.

	var/mimicing = ""
	var/lingabsorbedcount = 1

	var/recursive_enhancement = FALSE // Used to power up other abilities from the ling power with the same name.
	var/boost_sting_range = FALSE // Whether we have our Boost Range toggled on.

	var/using_proboscis = FALSE // Whether we are using proboscis-based (absorb/division) powers right now.
	var/true_dead = FALSE
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
	reset_my_mob(_M)
	set_next_think(world.time)

// Chemicals and genetic damage regeneration.
/datum/changeling/think()
	if(QDELETED(my_mob)) // Should never happen, but if it does happen we should make sure we don't prevent it from getting GCd.
		set_next_think(world.time + 1 SECOND)
		reset_my_mob(null)
		return
	if(!my_mob || my_mob.is_ooc_dead() || my_mob.InStasis())
		set_next_think(world.time + 1 SECOND)
		return

	chem_charges = min(max(0, chem_charges + chem_recharge_rate), chem_storage)
	apply_genome_damage(-1)

	set_next_think(world.time + 1 SECOND)

/datum/changeling/Destroy()
	die()
	purchasedpowers = null
	my_mob = null
	absorbed_languages.Cut()
	absorbed_dna.Cut()
	. = ..()


// Here we finally die and live no more.
/datum/changeling/proc/die()
	remove_all_changeling_powers() // Keeping purchases list, removing actual abilities.
	if(my_mob)
		to_chat(my_mob, SPAN("changeling", "That's it. We hunt no more."))
	true_dead = TRUE


/datum/changeling/proc/apply_genome_damage(damage)
	set_genome_damage(genome_damage + damage)

/datum/changeling/proc/set_genome_damage(new_damage)
	new_damage = clamp(new_damage, 0, 200)

	var/old_damage = genome_damage

	genome_damage = new_damage

	var/mob/living/carbon/human/H = my_mob
	if(new_damage == 0 && old_damage > 0 && istype(H)) // hide the biostructure if no gendamage
		biostructure_hide(H)

	if(new_damage > 0 && old_damage == 0 && istype(H)) // show the biostructure if we gain some gendamage
		biostructure_show(H)

/datum/changeling/proc/biostructure_hide(mob/living/carbon/human/H, silent=FALSE)
	if(!silent)
		to_chat(my_mob, SPAN("changeling", "We feel our genomes have assembled. Our biostructure cannot be easily seen now."))

	var/obj/item/organ/internal/biostructure/biostructure = H.internal_organs_by_name[BP_CHANG]
	if(biostructure)
		biostructure.hidden = TRUE

/datum/changeling/proc/biostructure_show(mob/living/carbon/human/H, silent=FALSE)
	if(!silent)
		to_chat(my_mob, SPAN("changeling", "You feel your genomes start to disassemble. Your special biostructure can now be easily spotted."))

	var/obj/item/organ/internal/biostructure/biostructure = H.internal_organs_by_name[BP_CHANG]
	if(biostructure)
		biostructure.hidden = FALSE

// Transfers us and our biostructure to another mob. Called by /datum/mind/transfer_to() and hopefully we will never need to call it manually.
/datum/changeling/proc/transfer_to(mob/living/L)
	if(!L.mind)
		return FALSE
	if(my_mob)
		remove_all_changeling_powers()
		my_mob.mind?.changeling = null
		my_mob.verbs -= /datum/changeling/proc/EvolutionMenu

		// Biostructural stuff
		var/obj/item/organ/internal/biostructure/BIO
		if(istype(my_mob, /mob/living/carbon/brain))
			BIO = my_mob.loc
		else
			BIO = locate() in my_mob.contents
		if(!BIO) // We lost our biostructure somewhere, everything's broken, let's just give up and fucking die.
			to_chat(my_mob, SPAN("changeling", "Strangely enough, we feel like dying right now. The only thing we know, it's not our fault."))
			die()
			return FALSE
		BIO.change_host(L) // Biostructure object gets moved here

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.is_ooc_dead()) // Resurrects dead bodies, yet doesn't heal damage
			H.setBrainLoss(0)
			H.SetParalysis(0)
			H.SetStunned(0)
			H.SetWeakened(0)
			H.shock_stage = 0
			H.timeofdeath = 0
			H.switch_from_dead_to_living_mob_list()
			var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
			heart.pulse = 1
			H.set_stat(CONSCIOUS)
			H.failed_last_breath = 0 // So mobs that died of oxyloss don't revive and have perpetual out of breath.
			H.reload_fullscreen()

	L.mind.changeling = src
	L.make_changeling()
	return TRUE


// Sets new my_mob, updates changeling powers' my_mob as well.
/datum/changeling/proc/reset_my_mob(mob/new_mob)
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
	my_mob.add_language(LANGUAGE_LING)
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


// Absorbing another changeling, stealing their DNA and powers, but not killing them.
/datum/changeling/proc/consume_changeling(datum/changeling/victim)
	if(!victim)
		return

	if(victim.absorbed_dna)
		for(var/datum/absorbed_dna/victim_dna_data in victim.absorbed_dna) // steal all their loot
			if(GetDNA(victim_dna_data.name))
				continue
			absorbDNA(victim_dna_data)
			absorbedcount++
		victim.absorbed_dna.len = 1

	if(victim.purchasedpowers)
		for(var/datum/power/changeling/victim_power in victim.purchasedpowers)
			if(victim_power in purchasedpowers)
				continue
			purchasedpowers += victim_power
			add_changeling_power(victim_power)

	chem_charges += victim.chem_charges
	geneticpoints += victim.geneticpoints

	victim.chem_charges = 0
	victim.geneticpoints = 0
	victim.absorbedcount = 0


///////////////////////////
// POWERS-RELATED PROCS ///
///////////////////////////
/datum/changeling/proc/add_changeling_power(datum/power/changeling/P)
	if(P in purchasedpowers)
		for(var/datum/changeling_power/CP in available_powers)
			if(CP.type == P.power_path)
				return
	if(!ishuman(my_mob) && !P.allowduringlesserform)
		return

	var/datum/changeling_power/CP = new P.power_path(my_mob)
	if(!CP.desc)
		CP.desc = P.desc
	CP.allow_lesser = P.allowduringlesserform


// This one can accept both datum/power/changeling and /datum/changeling_power instances
/datum/changeling/proc/remove_changeling_power(target_power, remove_purchased = TRUE)
	if(istype(target_power, /datum/power/changeling))
		var/datum/power/changeling/P = target_power
		if(P in purchasedpowers)
			for(var/datum/changeling_power/CP in available_powers)
				if(CP.type == P.power_path)
					target_power = CP
					break
			if(remove_purchased)
				purchasedpowers.Remove(P)

	if(istype(target_power, /datum/changeling_power))
		var/datum/changeling_power/CP = target_power
		if(CP in available_powers)
			available_powers.Remove(CP)
			qdel(CP)
		return

	CRASH("[src]'s remove_changeling_power() has recieved an invalid argument.")


// Removes all changeling powers.
/datum/changeling/proc/remove_all_changeling_powers(remove_purchased = FALSE)
	if(remove_purchased)
		purchasedpowers.Cut()
	for(var/CP in available_powers)
		remove_changeling_power(CP, remove_purchased)
	available_powers.Cut()
	my_mob?.ability_master?.remove_all_changeling_powers()


// Auto-purchases free powers, updates things and yadda yadda
// Don't spam it too frequently.
/datum/changeling/proc/update_changeling_powers()
	if(!my_mob?.mind)
		return

	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost && !(P in purchasedpowers)) // Is it free? Do we not have it already?
			purchase_power(P.name) // Purchase it.

	var/mob_in_lesser_form = !ishuman(my_mob)
	checking_purchased:
		for(var/datum/power/changeling/P in purchasedpowers)
			for(var/datum/changeling_power/CP in available_powers)
				if(CP.type == P.power_path)
					if(mob_in_lesser_form && !CP.allow_lesser)
						remove_changeling_power(CP, FALSE)
					else
						CP.update()
					continue checking_purchased
			add_changeling_power(P)

	my_mob.ability_master.reskin_changeling()
	my_mob.ability_master.update_abilities()


// Returns a power with given name from available_powers. This proc bad, try to avoid using it unless it's really necessary.
/datum/changeling/proc/get_changeling_power_by_name(_name)
	if(!_name)
		return null
	for(var/datum/changeling_power/CP in available_powers)
		if(CP.name == _name)
			return CP
	return null

// Deactivates all current stings to make sure my_mob doesn't have queued sting click handlers.
/datum/changeling/proc/deactivate_stings()
	for(var/datum/changeling_power/toggled/sting/S in available_powers)
		S.deactivate()
