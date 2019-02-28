var/global/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/datum/absorbed_dna/absorbed_dna = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 13
	var/purchasedpowers = list()
	var/mimicing = ""
	var/lingabsorbedcount = 1
	var/cloaked = 0
	var/armor_deployed = 0 //This is only used for changeling_generic_equip_all_slots() at the moment.
	var/recursive_enhancement = 0 //Used to power up other abilities from the ling power with the same name.
	var/list/purchased_powers_history = list() //Used for round-end report, includes respec uses too.
	var/last_shriek = null // world.time when the ling last used a shriek.
	var/next_escape = 0	// world.time when the ling can next use Escape Restraints
	var/readapts = 1
	var/max_readapts = 2
	var/true_dead = FALSE
	var/damaged = FALSE
	var/heal = 0
	var/datum/reagents/pick_chemistry = new

/datum/changeling/New()
	..()
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[changelingID]"
	else
		changelingID = "[rand(1,999)]"

/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges+chem_recharge_rate), chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/changeling/proc/GetDNA(var/dna_owner)
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		if(dna_owner == DNA.name)
			return DNA

/mob/proc/absorbDNA(var/datum/absorbed_dna/newDNA)
	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return

	for(var/language in newDNA.languages)
		changeling.absorbed_languages |= language

	changeling_update_languages(changeling.absorbed_languages)

	if(!changeling.GetDNA(newDNA.name)) // Don't duplicate - I wonder if it's possible for it to still be a different DNA? DNA code could use a rewrite
		changeling.absorbed_dna += newDNA

//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()

	if(!mind)				return
	if(!mind.changeling)	mind.changeling = new /datum/changeling(gender)

	verbs += /datum/changeling/proc/EvolutionMenu
	add_language("Changeling")

	var/lesser_form = !ishuman(src)

	var/mob/living/carbon/Z = src
	var/obj/item/organ/internal/biostructure/BIO = locate() in Z.contents
	if(istype(Z) && !BIO && !istype(Z,/mob/living/carbon/brain))
		Z.insert_biostructure()
	else if (istype(Z))
		// make our brain not vital
		var/obj/item/organ/internal/brain/brain = Z.internal_organs_by_name[BP_BRAIN]
		if (brain)
			brain.vital = 0

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)	continue
			if(!(P in src.verbs))
				src.verbs += P.verbpath

	for(var/language in languages)
		mind.changeling.absorbed_languages |= language

	var/mob/living/carbon/human/H = src
	if(istype(H))
		var/datum/absorbed_dna/newDNA = new(H.real_name, H.dna, H.species.name, H.languages, H.mind.traits)
		absorbDNA(newDNA)

	return 1

//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	if(!mind || !mind.changeling)	return
	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			verbs -= P.verbpath


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/changeling_power(var/required_chems=0, var/required_dna=0, var/max_genetic_damage=100, var/max_stat=0)

	if(!src.mind)		return
	if(!iscarbon(src))	return

	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)
		world.log << "[src] has the changeling_transform() verb but is not a changeling."
		return

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>We are incapacitated.</span>")
		return

	if(changeling.absorbed_dna.len < required_dna)
		to_chat(src, "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>")
		return

	if(changeling.chem_charges < required_chems)
		to_chat(src, "<span class='warning'>We require at least [required_chems] units of chemicals to do that!</span>")
		return

	if(changeling.geneticdamage > max_genetic_damage)
		to_chat(src, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return

	return changeling


//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(var/updated_languages)

	languages = list()
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")

	return

//Absorbs the victim's DNA making them uncloneable. Requires a strong grip on the victim.
//Doesn't cost anything as it's the most basic ability.
/mob/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/grab/G = src.get_active_hand()
	if(!istype(G))
		to_chat(src, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || isMonkey(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, "<span class='warning'>We cannot extract DNA from this creature!</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(!G.can_absorb())
		to_chat(src, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already absorbing!</span>")
		return

	var/obj/item/organ/external/affecting = T.get_organ(src.zone_sel.selecting)
	if(!affecting)
		to_chat(src, "<span class='warning'>They are missing that body part!</span>")

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(src, "<span class='notice'>We extend a proboscis.</span>")
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
			if(3)
				to_chat(src, "<span class='notice'>We stab [T] with the proboscis.</span>")
				src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				affecting.take_damage(39, 0, DAM_SHARP, "large organic needle")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our absorption of [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(src, "<span class='notice'>We have absorbed [T]!</span>")
	src.visible_message("<span class='danger'>[src] sucks the fluids from [T]!</span>")
	to_chat(T, "<span class='danger'>You have been absorbed by the changeling!</span>")
	changeling.chem_charges += 10
	changeling.geneticpoints += 2

	//Steal all of their languages!
	for(var/language in T.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	changeling_update_languages(changeling.absorbed_languages)

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages, T.mind.traits)
	absorbDNA(newDNA)
	if(mind && T.mind)
		mind.store_memory("[T.real_name]'s memories:")
		mind.store_memory(T.mind.memory)
		mind.store_memory("<hr>")

	if(T.mind && T.mind.changeling)
		if(T.mind.changeling.absorbed_dna)
			for(var/datum/absorbed_dna/dna_data in T.mind.changeling.absorbed_dna)	//steal all their loot
				if(changeling.GetDNA(dna_data.name))
					continue
				absorbDNA(dna_data)
				changeling.absorbedcount++
			T.mind.changeling.absorbed_dna.len = 1

		if(T.mind.changeling.purchasedpowers)
			for(var/datum/power/changeling/Tp in T.mind.changeling.purchasedpowers)
				if(Tp in changeling.purchasedpowers)
					continue
				else
					changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()
					else
						src.make_changeling()

		changeling.chem_charges += T.mind.changeling.chem_charges
		changeling.geneticpoints += T.mind.changeling.geneticpoints
		T.mind.changeling.chem_charges = 0
		T.mind.changeling.geneticpoints = 0
		T.mind.changeling.absorbedcount = 0

	changeling.absorbedcount++
	changeling.isabsorbing = 0

	T.death(0)
	T.Drain()
	return 1


//Change our DNA to that of somebody we've absorbed.
/mob/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	var/datum/changeling/changeling = changeling_power(5,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		names += "[DNA.name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 5
	changeling.geneticdamage = 30

	var/S_name = chosen_dna.speciesName
	var/datum/species/S_dat = all_species[S_name]
	var/changeTime = 2 SECONDS
	if(mob_size != S_dat.mob_size)
		src.visible_message("<span class='warning'>[src]'s body begins to twist, their mass changing rapidly!</span>")
		changeTime = 8 SECONDS
	else
		src.visible_message("<span class='warning'>[src]'s body begins to twist, changing rapidly!</span>")

	if(!do_after(src, changeTime))
		to_chat(src, "<span class='notice'>You fail to change shape.</span>")
		return
	handle_changeling_transform(chosen_dna)

	src.verbs -= /mob/proc/changeling_transform
	spawn(10)
		src.verbs += /mob/proc/changeling_transform

	changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","TR")
	return 1

/mob/proc/handle_changeling_transform(var/datum/absorbed_dna/chosen_dna)
	src.visible_message("<span class='warning'>[src] transforms!</span>")

	src.dna = chosen_dna.dna
	src.real_name = chosen_dna.name
	src.flavor_text = ""
	src.mind.traits = chosen_dna.traits
	src.apply_traits()

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/newSpecies = chosen_dna.speciesName
		H.set_species(newSpecies,1)
		H.b_type = chosen_dna.dna.b_type
		H.sync_organ_dna()
		H.insert_biostructure()
	domutcheck(src, null)
	src.UpdateAppearance()


//Transform into a monkey.
/mob/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	var/datum/changeling/changeling = changeling_power(1,0,0)
	if(!changeling)	return

	if(src.has_brain_worms())
		to_chat(src, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return

	var/mob/living/carbon/human/H = src

	if(!istype(H) || !H.species.primitive_form)
		to_chat(src, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	changeling.chem_charges--
	H.visible_message("<span class='warning'>[H] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H = H.monkeyize()
	if(istype(H))
		H.insert_biostructure()
	feedback_add_details("changeling_powers","LF")
	return 1

//Transform into a human
/mob/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	var/datum/changeling/changeling = changeling_power(1,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/human/C = src

	changeling.chem_charges--
	C.remove_changeling_powers()
	C.visible_message("<span class='warning'>[C] transforms!</span>")
	C.dna = chosen_dna.Clone()

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in C) //Still preserving implants
		implants += I

	C.transforming = 1
	C.canmove = 0
	C.icon = null
	C.overlays.Cut()
	C.set_invisibility(101)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	qdel(animation)

	for(var/obj/item/W in src)
		C.drop_from_inventory(W)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (C.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = C.dna.Clone()
	C.dna = null
	O.real_name = chosen_dna.real_name

	for(var/obj/T in C)
		qdel(T)

	O.loc = C.loc

	O.UpdateAppearance()
	domutcheck(O, null)
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.set_stat(C.stat)
	for (var/obj/item/weapon/implant/I in implants)
		I.forceMove(O)
		I.implanted = O

	C.mind.transfer_to(O)
	O.make_changeling()
	O.changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","LFT")
	qdel(C)
	return 1


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/mob/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (20)"

	var/datum/changeling/changeling = changeling_power(20,1,100,DEAD)
	if(!changeling)	return

	if(src.mind.changeling.true_dead)
		to_chat(src, "<span class='notice'>We can not do this. We are really dead.</span>")
		return

	if(!src.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
		return
	to_chat(src, "<span class='notice'>We have relocated our core organ into chest and will attempt to regenerate our form.</span>")

	var/mob/living/carbon/C = src

	C.status_flags |= FAKEDEATH		//play dead
	C.update_canmove()
	C.remove_changeling_powers()

	C.emote("gasp")

	spawn(rand(800,2000))
		if(changeling_power(20,1,100,DEAD))
			// charge the changeling chemical cost for stasis
			changeling.chem_charges -= 20

			to_chat(C, "<span class='notice'><font size='5'>We are ready to rise.  Use the <b>Revive</b> verb when you are ready.</font></span>")
			C.verbs += /mob/proc/changeling_revive
			spawn(10 SECONDS)
				C.changeling_revive()

	feedback_add_details("changeling_powers","FD")
	return 1

/mob/proc/changeling_revive()
	set category = "Changeling"
	set name = "Revive"

	var/mob/living/carbon/C = src

	if(C.mind.changeling.true_dead)
		to_chat(C, "<span class='notice'>We can not do this. We are really dead.</span>")
		return

	// restore us to health
	C.revive()
	// remove our fake death flag
	C.status_flags &= ~(FAKEDEATH)
	// let us move again
	C.update_canmove()
	// re-add out changeling powers
	C.make_changeling()
	// sending display messages
	to_chat(C, "<span class='notice'>We have regenerated.</span>")
	C.verbs -= /mob/proc/changeling_revive


//Boosts the range of your next sting attack by 1
/mob/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	var/datum/changeling/changeling = changeling_power(10,0,100)
	if(!changeling)	return 0
	changeling.chem_charges -= 10
	to_chat(src, "<span class='notice'>Your throat adjusts to launch the sting.</span>")
	changeling.sting_range = 2
	src.verbs -= /mob/proc/changeling_boost_range
	spawn(5)	src.verbs += /mob/proc/changeling_boost_range
	feedback_add_details("changeling_powers","RS")
	return 1


//Recover from stuns.
/mob/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Sacs (45)"
	set desc = "Removes all stuns"

	var/datum/changeling/changeling = changeling_power(45,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	changeling.chem_charges -= 45

	var/mob/living/carbon/human/C = src
	if(C.reagents)
		C.reagents.clear_reagents()
	C.set_stat(CONSCIOUS)
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.lying = 0
	C.update_canmove()

	src.verbs -= /mob/proc/changeling_unstun
	spawn(5)	src.verbs += /mob/proc/changeling_unstun
	feedback_add_details("changeling_powers","UNS")
	return 1


//Speeds up chemical regeneration
/mob/proc/changeling_fastchemical()
	src.mind.changeling.chem_recharge_rate *= 2
	return 1

//Increases macimum chemical storage
/mob/proc/changeling_engorgedglands()
	src.mind.changeling.chem_storage += 25
	return 1


//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return 0

	var/mob/living/carbon/human/C = src
	if(C.digitalcamo)	to_chat(C, "<span class='notice'>We return to normal.</span>")
	else				to_chat(C, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	C.digitalcamo = !C.digitalcamo

	spawn(0)
		while(C && C.digitalcamo && C.mind && C.mind.changeling)
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 1, 0)
			sleep(40)

	src.verbs -= /mob/proc/changeling_digitalcamo
	spawn(5)	src.verbs += /mob/proc/changeling_digitalcamo
	feedback_add_details("changeling_powers","CAM")
	return 1


//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = src
	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)

	src.verbs -= /mob/proc/changeling_rapidregen
	spawn(5)	src.verbs += /mob/proc/changeling_rapidregen
	feedback_add_details("changeling_powers","RR")
	return 1

// HIVE MIND UPLOAD/DOWNLOAD DNA

var/list/datum/absorbed_dna/hivemind_bank = list()

/mob/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows you to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/changeling/changeling = changeling_power(10,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		var/valid = 1
		for(var/datum/absorbed_dna/DNB in hivemind_bank)
			if(DNA.name == DNB.name)
				valid = 0
				break
		if(valid)
			names += DNA.name

	if(names.len <= 0)
		to_chat(src, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)	return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/datum/species/spec = all_species[chosen_dna.speciesName]

	if(spec && spec.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB)
		to_chat(src, "<span class='notice'>That species must be absorbed directly.</span>")
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	to_chat(src, "<span class='notice'>We channel the DNA of [S] to the air.</span>")
	feedback_add_details("changeling_powers","HU")
	return 1

/mob/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (20)"
	set desc = "Allows you to absorb DNA that is being channeled in the airwaves."

	var/datum/changeling/changeling = changeling_power(20,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in hivemind_bank)
		if(!(changeling.GetDNA(DNA.name)))
			names[DNA.name] = DNA

	if(names.len <= 0)
		to_chat(src, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)	return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.chem_charges -= 20
	absorbDNA(chosen_dna)
	to_chat(src, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	feedback_add_details("changeling_powers","HD")
	return 1

// Fake Voice

/mob/proc/changeling_mimicvoice()
	set category = "Changeling"
	set name = "Mimic Voice"
	set desc = "Shape our vocal glands to form a voice of someone we choose. We cannot regenerate chemicals when mimicing."


	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return

	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(src, "<span class='notice'>We return our vocal glands to their original form.</span>")
		return

	var/mimic_voice = sanitize(input(usr, "Enter a name to mimic.", "Mimic Voice", null), MAX_NAME_LEN)
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice

	to_chat(src, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>")
	to_chat(src, "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>")
	feedback_add_details("changeling_powers","MV")

	spawn(0)
		while(src && src.mind && src.mind.changeling && src.mind.changeling.mimicing)
			src.mind.changeling.chem_charges = max(src.mind.changeling.chem_charges - 1, 0)
			sleep(40)
		if(src && src.mind && src.mind.changeling)
			src.mind.changeling.mimicing = ""
	//////////
	//STINGS//	//They get a pretty header because there's just so fucking many of them ;_;
	//////////

/mob/proc/sting_can_reach(mob/M as mob, sting_range = 1)
	if(M.loc == src.loc)
		return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc))
		to_chat(src, "<span class='warning'>We cannot reach \the [M] with a sting!</span>")
		return 0 //One is inside, the other is outside something.
	// Maximum queued turfs set to 25; I don't *think* anything raises sting_range above 2, but if it does the 25 may need raising
	if(!AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes=25, max_node_depth=sting_range)) //If we can't find a path, fail
		to_chat(src, "<span class='warning'>We cannot find a path to sting \the [M] by!</span>")
		return 0
	return 1

//Handles the general sting code to reduce on copypasta (seeming as somebody decided to make SO MANY dumb abilities)
/mob/proc/changeling_sting(var/required_chems=0, var/verb_path, var/loud)
	var/datum/changeling/changeling = changeling_power(required_chems)
	if(!changeling)								return

	var/list/victims = list()
	for(var/mob/living/carbon/human/C in oview(changeling.sting_range))
		victims += C
	var/mob/living/carbon/human/T = input(src, "Who will we sting?") as null|anything in victims

	if(!T) return
	if(!(T in view(changeling.sting_range))) return
	if(!sting_can_reach(T, changeling.sting_range)) return
	if(!changeling_power(required_chems)) return
	var/obj/item/organ/external/target_limb = T.get_organ(src.zone_sel.selecting)
	if (!target_limb)
		to_chat(src, "<span class='warning'>[T] is missing that limb.</span>")
		return
	changeling.chem_charges -= required_chems
	changeling.sting_range = 1
	src.verbs -= verb_path
	spawn(10)	src.verbs += verb_path
	if(!loud)
		to_chat(src, "<span class='notice'>We stealthily sting [T].</span>")
	else
		visible_message("<span class='danger'>[src] fires an organic shard into [T]!</span>")

	for(var/obj/item/clothing/clothes in list(T.head, T.wear_mask, T.wear_suit, T.w_uniform, T.gloves, T.shoes))
		if(istype(clothes) && (clothes.body_parts_covered & target_limb.body_part) && (clothes.item_flags & ITEM_FLAG_THICKMATERIAL))
			to_chat(src, "<span class='warning'>[T]'s armor has protected them.</span>")
			return //thick clothes will protect from the sting

	if(T.isSynthetic() || target_limb.isrobotic()) return
	if(!T.mind || !T.mind.changeling) return T	//T will be affected by the sting
	T.flash_pain(75)
	to_chat(T, "<span class='danger'>Your [target_limb.name] hurts.</span>")
	return


/mob/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	var/mob/living/carbon/human/T = changeling_sting(15,/mob/proc/changeling_lsdsting)
	if(!T)	return 0
	spawn(rand(300,600))
		if(T)	T.hallucination(400, 80)
	feedback_add_details("changeling_powers","HS")
	return 1

/mob/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	var/mob/living/carbon/human/T = changeling_sting(10,/mob/proc/changeling_silence_sting)
	if(!T)	return 0
	T.silent += 30
	feedback_add_details("changeling_powers","SS")
	return 1

/mob/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	var/mob/living/carbon/human/T = changeling_sting(20,/mob/proc/changeling_blind_sting)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your eyes burn horrificly!</span>")
	T.disabilities |= NEARSIGHTED
	spawn(300)	T.disabilities &= ~NEARSIGHTED
	T.eye_blind = 10
	T.eye_blurry = 20
	feedback_add_details("changeling_powers","BS")
	return 1

/mob/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	var/mob/living/carbon/human/T = changeling_sting(5,/mob/proc/changeling_deaf_sting)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your ears pop and begin ringing loudly!</span>")
	T.sdisabilities |= DEAF
	spawn(300)	T.sdisabilities &= ~DEAF
	feedback_add_details("changeling_powers","DS")
	return 1

/mob/proc/changeling_vomit_sting()
	set category = "Changeling"
	set name = "Vomit Sting (15)"
	set desc = "Urges target to vomit."

	var/mob/living/carbon/human/T = changeling_sting(15,/mob/proc/changeling_vomit_sting)
	if(!T || T.stat == DEAD || !T.check_has_mouth())	return 0
	sleep(10) //Небольшая задержка перед тем, как жертву стошнит
	T.visible_message("<span class='warning'>[T] throws up!</span>","<span class='warning'>You throw up!</span>")
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/turf/location = T.loc
	if (istype(location, /turf/simulated))
		location.add_vomit_floor(T, 1)
	var/datum/reagents/ingested = T.get_ingested_reagents()
	ingested.remove_any(5)
	T.nutrition -= 30
	feedback_add_details("changeling_powers","VS")
	return 1

/mob/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms to death."
	var/loud = 1

	var/mob/living/carbon/human/T = changeling_sting(40,/mob/proc/changeling_DEATHsting,loud)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>You feel a small prick and your chest becomes tight.</span>")
	T.make_jittery(400)
	if(T.reagents)
		spawn(10 SECONDS)
			T.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(20 SECONDS)
			T.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(30 SECONDS)
			T.reagents.add_reagent(/datum/reagent/toxin/cyanide, 3)
	feedback_add_details("changeling_powers","DTHS")
	return 1

/mob/proc/changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (40)"
	set desc="Stealthily sting a target to extract their DNA."

	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return 0

	var/mob/living/carbon/human/T = changeling_sting(40, /mob/proc/changeling_extract_dna_sting)
	if(!T)	return 0
	if((HUSK in T.mutations) || (T.species.species_flags & SPECIES_FLAG_NO_SCAN))
		to_chat(src, "<span class='warning'>We cannot extract DNA from this creature!</span>")
		return 0

	if(T.species.species_flags & SPECIES_FLAG_NEED_DIRECT_ABSORB)
		to_chat(src, "<span class='notice'>That species must be absorbed directly.</span>")
		return

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages)
	absorbDNA(newDNA)

	feedback_add_details("changeling_powers","ED")
	return 1

//No breathing required
/mob/proc/changeling_self_respiration()
	set category = "Changeling"
	set name = "Toggle Breathing"
	set desc = "We choose whether or not to breathe."

	var/datum/changeling/changeling = changeling_power(0,0,100,UNCONSCIOUS)
	if(!changeling)
		return 0

	if(istype(src,/mob/living/carbon))
		var/mob/living/carbon/C = src
		if(C.does_not_breathe == 0)
			C.does_not_breathe = 1
			to_chat(src, "<span class='notice'>We stop breathing, as we no longer need to.</span>")
			return 1
		else
			C.does_not_breathe = 0
			to_chat(src, "<span class='notice'>We resume breathing, as we now need to again.</span>")
	return 0



/mob/proc/changeling_generic_weapon(var/weapon_type, var/make_sound = 1, var/cost = 20)
	var/datum/changeling/changeling = changeling_power(cost,1,100,CONSCIOUS)
	if(!changeling)
		return

	if(!ishuman(src))
		return 0

	..()

	var/mob/living/M = src

	if(M.l_hand && M.r_hand)
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		return


	var/obj/item/weapon/W = new weapon_type(src)
	src.put_in_hands(W)

	src.mind.changeling.chem_charges -= cost
	if(make_sound)
		playsound(src, 'sound/effects/blobattack.ogg', 30, 1)
	return 1


//Hide us from anyone who would do us harm.
/mob/proc/changeling_visible_camouflage()
	set category = "Changeling"
	set name = "Visible Camouflage (10)"
	set desc = "Turns yourself almost invisible, as long as you move slowly."


	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		if(H.mind.changeling.cloaked)
			H.mind.changeling.cloaked = 0
			return 1

		//We delay the check, so that people can uncloak without needing 10 chemicals to do so.
		var/datum/changeling/changeling = changeling_power(10,0,100,CONSCIOUS)

		if(!changeling)
			return 0
		changeling.chem_charges -= 10
		var/old_regen_rate = H.mind.changeling.chem_recharge_rate

		to_chat(H, "<span class='notice'>We vanish from sight, and will remain hidden, so long as we move carefully.</span>")
		H.mind.changeling.cloaked = 1
		H.mind.changeling.chem_recharge_rate = 0
		animate(src,alpha = 255, alpha = 10, time = 10)

		var/must_walk = TRUE
		if(src.mind.changeling.recursive_enhancement)
			must_walk = FALSE
			to_chat(src, "<span class='notice'>We may move at our normal speed while hidden.</span>")

		if(must_walk)
			H.set_m_intent("walk")

		var/remain_cloaked = TRUE
		while(remain_cloaked) //This loop will keep going until the player uncloaks.
			sleep(1 SECOND) // Sleep at the start so that if something invalidates a cloak, it will drop immediately after the check and not in one second.

			if(H.m_intent != "walk" && must_walk) // Moving too fast uncloaks you.
				remain_cloaked = 0
			if(!H.mind.changeling.cloaked)
				remain_cloaked = 0
			if(H.stat) // Dead or unconscious lings can't stay cloaked.
				remain_cloaked = 0
			if(H.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings also can't stay cloaked.
				remain_cloaked = 0

			if(mind.changeling.chem_recharge_rate != 0) //Without this, there is an exploit that can be done, if one buys engorged chem sacks while cloaked.
				old_regen_rate += mind.changeling.chem_recharge_rate //Unfortunately, it has to occupy this part of the proc.  This fixes it while at the same time
				mind.changeling.chem_recharge_rate = 0 //making sure nobody loses out on their bonus regeneration after they're done hiding.



		H.invisibility = initial(invisibility)
		visible_message("<span class='warning'>[src] suddenly fades in, seemingly from nowhere!</span>",
		"<span class='notice'>We revert our camouflage, revealing ourselves.</span>")
		H.set_m_intent("run")
		H.mind.changeling.cloaked = 0
		H.mind.changeling.chem_recharge_rate = old_regen_rate

		animate(src,alpha = 10, alpha = 255, time = 10)



//Emag-lite
/mob/proc/changeling_electric_lockpick()
	set category = "Changeling"
	set name = "Electric Lockpick (5 + 10/use)"
	set desc = "Bruteforces open most electrical locking systems, at 10 chemicals per use."

	var/datum/changeling/changeling = changeling_power(5,0,100,CONSCIOUS)

	var/obj/held_item = get_active_hand()

	if(!changeling)
		return 0

	if(held_item == null)
		if(changeling_generic_weapon(/obj/item/weapon/finger_lockpick,0,5))  //Chemical cost is handled in the equip proc.
			return 1
		return 0

/obj/item/weapon/finger_lockpick
	name = "finger lockpick"
	desc = "This finger appears to be an organic datajack."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "electric_hand"

/obj/item/weapon/finger_lockpick/New()
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>We shape our finger to fit inside electronics, and are ready to force them open.</span>")

/obj/item/weapon/finger_lockpick/dropped(mob/user)
	to_chat(user, "<span class='notice'>We discreetly shape our finger back to a less suspicious form.</span>")
	spawn(1)
		if(src)
			qdel(src)

/obj/item/weapon/finger_lockpick/afterattack(var/atom/target, var/mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(!user.mind.changeling)
		return

	var/datum/changeling/ling_datum = user.mind.changeling

	if(ling_datum.chem_charges < 10)
		to_chat(user, "<span class='warning'>We require more chemicals to do that.</span>")
		return

	//Airlocks require an ugly block of code, but we don't want to just call emag_act(), since we don't want to break airlocks forever.
	if(istype(target,/obj/machinery/door))
		var/obj/machinery/door/door = target
		to_chat(user, "<span class='notice'>We send an electrical pulse up our finger, and into \the [target], attempting to open it.</span>")

		if(door.density && door.operable())
			door.do_animate("spark")
			sleep(6)
			//More typechecks, because windoors can't be locked.  Fun.
			if(istype(target,/obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/airlock = target

				if(airlock.locked) //Check if we're bolted.
					airlock.unlock()
					to_chat(user, "<span class='notice'>We've unlocked \the [airlock].  Another pulse is requried to open it.</span>")
				else	//We're not bolted, so open the door already.
					airlock.open()
					to_chat(user, "<span class='notice'>We've opened \the [airlock].</span>")
			else
				door.open() //If we're a windoor, open the windoor.
				to_chat(user, "<span class='notice'>We've opened \the [door].</span>")
		else //Probably broken or no power.
			to_chat(user, "<span class='warning'>The door does not respond to the pulse.</span>")
		door.add_fingerprint(user)
		log_and_message_admins("finger-lockpicked \an [door].")
		ling_datum.chem_charges -= 10
		return 1

	else if(istype(target,/obj/)) //This should catch everything else we might miss, without a million typechecks.
		var/obj/O = target
		to_chat(user, "<span class='notice'>We send an electrical pulse up our finger, and into \the [O].</span>")
		O.add_fingerprint(user)
		O.emag_act(1,user,src)
		log_and_message_admins("finger-lockpicked \an [O].")
		ling_datum.chem_charges -= 10

		return 1
	return 0


//Grows a scary, and powerful arm blade.
/mob/proc/changeling_claw()
	set category = "Changeling"
	set name = "Claw (15)"

	if(src.mind.changeling.recursive_enhancement)
		if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw/greater, 1, 15))
			to_chat(src, "<span class='notice'>We prepare an extra sharp claw.</span>")
			return 1

	else
		if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw, 1, 15))
			return 1
		return 0

/obj/item/weapon/melee/changeling
	name = "arm weapon"
	desc = "A grotesque weapon made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	w_class = ITEM_SIZE_HUGE
	force = 5
	anchored = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	var/mob/living/creator //This is just like ninja swords, needed to make sure dumb shit that removes the sword doesn't make it stay around.
	var/weapType = "weapon"
	var/weapLocation = "arm"

/obj/item/weapon/melee/changeling/New(location)
	..()
	if(ismob(loc))
		visible_message("<span class='warning'>A grotesque weapon forms around [loc.name]\'s arm!</span>",
		"<span class='warning'>Our arm twists and mutates, transforming it into a deadly weapon.</span>",
		"<span class='italics'>You hear organic matter ripping and tearing!</span>")
		src.creator = loc

/obj/item/weapon/melee/changeling/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/melee/changeling/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [creator] reforms their arm!</span>",
	"<span class='notice'>We assimilate the weapon back into our body.</span>",
	"<span class='italics'>You hear organic matter ripping and tearing!</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 30, 1)
	spawn(1)
		if(src)
			qdel(src)

/obj/item/weapon/melee/changeling/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/weapon/melee/changeling/Process()  //Stolen from ninja swords.
	if(!creator || loc != creator ||(creator.l_hand != src && creator.r_hand != src))
		// Tidy up a bit.
		if(istype(loc,/mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		spawn(1)
			if(src)
				qdel(src)

/obj/item/weapon/melee/changeling/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "arm_blade"
	force = 25
	armor_penetration = 15
	sharp = 1
	edge = 1
	anchored = 1
	canremove = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/changeling/arm_blade/greater
	name = "arm greatblade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people and armor as a hot knife through butter."
	force = 30
	armor_penetration = 30

/obj/item/weapon/melee/changeling/claw
	name = "hand claw"
	desc = "A grotesque claw made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "ling_claw"
	force = 15
	sharp = 1
	edge = 1
	canremove = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/changeling/claw/greater
	name = "hand greatclaw"
	force = 20
	armor_penetration = 20
	anchored = 1

/mob/proc/changeling_arm_blade()
	set category = "Changeling"
	set name = "Arm Blade (20)"
	visible_message("<span class='warning'>The flesh is torn around the [src.name]\'s arm!</span>",
		"<span class='warning'>The flesh of our hand is transforming.</span>",
		"<span class='italics'>You hear organic matter ripping and tearing!</span>")
	spawn(4 SECONDS)
		playsound(src, 'sound/effects/blobattack.ogg', 30, 1)
		if(src.mind.changeling.recursive_enhancement)
			if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade/greater))
				to_chat(src, "<span class='notice'>We prepare an extra sharp blade.</span>")

				return 1

		else
			if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade))
				return 1
			return 0

//Increases macimum chemical storage
/mob/proc/changeling_recursive_enhancement()
	set category = "Changeling"
	set name = "Recursive Enhancement"
	set desc = "Empowers our abilities."
	var/datum/changeling/changeling = changeling_power(0,0,100,UNCONSCIOUS)
	if(!changeling)
		return 0
	if(src.mind.changeling.recursive_enhancement)
		to_chat(src, "<span class='warning'>We will no longer empower our abilities.</span>")
		src.mind.changeling.recursive_enhancement = 0
		return 0
	else
		to_chat(src, "<span class='notice'>We empower ourselves. Our abilities will now be extra potent.</span>")
		src.mind.changeling.recursive_enhancement = 1
	feedback_add_details("changeling_powers","RE")
	return 1

/////////////////////////New Ability////////////////////////////////////////////////



/mob/proc/changeling_division()
	set category = "Changeling"
	set name = "Division (20)"
	set desc = "You will be like us."

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/grab/G = src.get_active_hand()
	if(!istype(G))
		to_chat(src, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting

	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	var/obj/item/organ/internal/brain/B = T.internal_organs_by_name[BP_BRAIN]
	if(B && B.status == DEAD)
		to_chat(src, "<span class='warning'>[T] is dead. We can not create a new life.</span>")
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined!</span>")
		return

	if(!G.can_absorb())
		to_chat(src, "<span class='warning'>We must have a tighter grip to create a new changelling.</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already transforming!</span>")
		return

	var/obj/item/organ/external/affecting = T.get_organ(src.zone_sel.selecting)
	if(!affecting)
		to_chat(src, "<span class='warning'>They are missing that body part!</span>")

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(src, "<span class='notice'>We extend a proboscis.</span>")
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
			if(3)
				to_chat(src, "<span class='notice'>We stab [T] with the proboscis.</span>")
				src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				affecting.take_damage(39, 0, DAM_SHARP, "large organic needle")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our transfused new core into [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(src, "<span class='notice'>We successfully transfused new core into [T]!</span>")
	src.visible_message("<span class='danger'>[src] transfused something into [T] through their proboscis!</span>")
	to_chat(T, "<span class='danger'>You feel like you're dying...</span>")
	if(changeling.geneticpoints <= 2)
		to_chat(src, "<span class='notice'>Not enough DNA.</span>")
		return
	if(changeling.chem_charges <= 20)
		to_chat(src, "<span class='notice'>Not enough chemicals.</span>")
		return

	changeling.chem_charges -= 20
	changeling.geneticpoints -= 2

	changeling.isabsorbing = 0
	var/datum/antagonist/changeling/a = new
	a.add_antagonist(T.mind, ignore_role = 1, do_not_equip = 1)
//	T.make_changeling()
	to_chat(T, "<span class='danger'>We have become!</span>") //Фраза довольно уебская, но пафосная
	T.mind.changeling.geneticpoints = 7
	T.mind.changeling.chem_charges = 40

	T.death(0)
	return 1

/mob/proc/changeling_detach_limb()
	set category = "Changeling"
	set name = "Detach Limb (10)"
	set desc = "We tear off our limb, turning it into an aggressive biomass."


	var/datum/changeling/changeling = changeling_power(10,0,100,DEAD)
	if(!changeling)	return
	var/mob/living/carbon/T = src
	T.faction = "biomass"
	var/list/detachable_limbs = T.organs.Copy()
	for (var/obj/item/organ/external/E in detachable_limbs)
		if (E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.organ_tag == BP_CHEST || E.organ_tag == BP_GROIN || E.is_stump())
			detachable_limbs -= E
	var/obj/item/organ/external/organ_to_remove = input(T, "Which organ do you want to detach?") as null|anything in detachable_limbs
	if(!organ_to_remove)
		return 0
	if(!T.organs.Find(organ_to_remove))
		to_chat(T,"<span class='notice'>We don't have this limb!</span>")
		return 0

	src.visible_message("<span class='danger'>\the [organ_to_remove] ripping off from [src].</span>", \
					"<span class='danger'>We begin ripping our \the [organ_to_remove].</span>")
	if(!do_after(src,10,can_move = 1,needhand = 0,incapacitation_flags = INCAPACITATION_NONE))
		src.visible_message("<span class='notice'>\the [organ_to_remove] connecting back to [src].</span>", \
					"<span class='danger'>We were interrupted.</span>")
		return 0
	playsound(loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	T.mind.changeling.chem_charges -= 10
	var/mob/living/L

	if(organ_to_remove.organ_tag == BP_L_LEG || organ_to_remove.organ_tag == BP_R_LEG)
		L = new /mob/living/simple_animal/hostile/little_changeling/leg_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_L_ARM || organ_to_remove.organ_tag == BP_R_ARM)
		L = new /mob/living/simple_animal/hostile/little_changeling/arm_chan(get_turf(T))
	else if(organ_to_remove.organ_tag == BP_HEAD)
		L = new /mob/living/simple_animal/hostile/little_changeling/head_chan(get_turf(T))

	var/obj/item/organ/internal/biostructure/BIO = T.internal_organs_by_name[BP_CHANG]
	if (organ_to_remove.organ_tag == BIO.parent_organ)
		changeling_transfer_mind(L)

	organ_to_remove.droplimb(1)
	qdel(organ_to_remove)

	var/mob/living/carbon/human/H = T
	if(istype(H))
		H.regenerate_icons()


/mob/proc/changeling_gib_self()
	set category = "Changeling"
	set name = "Body Disjunction (40)"
	set desc = "Tear apart your human disguise, revealing your little form."

	var/datum/changeling/changeling = changeling_power(40,0,0,DEAD)
	if(!changeling)	return 0


	var/mob/living/carbon/M = src

	M.visible_message("<span class='danger'>You hear a loud cracking sound coming from \the [M].</span>", \
						"<span class='danger'>We begin disjunction of our body to form a pack of autonomous organisms.</span>")

	if(!do_after(src,60,needhand = 0,incapacitation_flags = INCAPACITATION_NONE))
		M.visible_message("<span class='danger'>[M]'s transformation abruptly reverts itself!</span>", \
							"<span class='danger'>Our transformation has been interrupted!</span>")
		return 0
	src.mind.changeling.chem_charges -= 40
	M.visible_message("<span class='danger'>[M] falls apart, their limbs formed a gross monstrosities!</span>")
	playsound(loc, 'sound/hallucinations/far_noise.ogg', 100, 1)
	spawn(8)
		playsound(loc, 'sound/effects/bonebreak1.ogg', 100, 1)
	spawn(5)
		playsound(loc, 'sound/effects/bonebreak3.ogg', 100, 1)
	playsound(loc, 'sound/effects/bonebreak4.ogg', 100, 1)
	var/obj/item/organ/internal/biostructure/BIO = M.internal_organs_by_name[BP_CHANG]
	var/organ_chang_type = BIO.parent_organ

	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling
	var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling2
	var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling2
	var/mob/living/simple_animal/hostile/little_changeling/head_chan/head_ling
	if (M.has_limb(BP_L_LEG))
		leg_ling = new (get_turf(M))
		if(organ_chang_type == BP_L_LEG)
			changeling_transfer_mind(leg_ling)
	if (M.has_limb(BP_R_LEG))
		leg_ling2 = new (get_turf(M))
		if(organ_chang_type == BP_R_LEG)
			changeling_transfer_mind(leg_ling2)
	if (M.has_limb(BP_L_ARM))
		arm_ling = new (get_turf(M))
		if(organ_chang_type == BP_L_ARM)
			changeling_transfer_mind(arm_ling)
	if (M.has_limb(BP_R_ARM))
		arm_ling2 = new (get_turf(M))
		if(organ_chang_type == BP_R_ARM)
			changeling_transfer_mind(arm_ling2)
	if (M.has_limb(BP_HEAD))
		head_ling = new (get_turf(M))
		if(organ_chang_type == BP_HEAD)
			changeling_transfer_mind(head_ling)
	var/mob/living/simple_animal/hostile/little_changeling/chest_chan/chest_ling = new (get_turf(M))
	if(organ_chang_type == BP_CHEST || organ_chang_type == BP_GROIN)
		changeling_transfer_mind(chest_ling)

	gibs(loc, dna)
	if(istype(M,/mob/living/carbon/human))
		for(var/obj/item/I in M.contents)
			if(isorgan(I))
				continue
			M.drop_from_inventory(I)

	var/atom/movable/overlay/effect = new /atom/movable/overlay(get_turf(M))

	effect.density = 0
	effect.anchored = 1
	effect.icon = 'icons/effects/effects.dmi'
	effect.layer = 3
	flick("summoning",effect)
	QDEL_IN(effect, 10)

	qdel(M)

/mob/proc/aggressive()
	set category = "Changeling"
	set name = "Runaway form"
	set desc = "We take our weakest form."

	var/mob/living/simple_animal/hostile/little_changeling/headcrab/HC = new (get_turf(src))
	var/obj/item/organ/internal/biostructure/BIO = src.loc

	changeling_transfer_mind(HC)

	HC.visible_message("<span class='warning'>[BIO] suddenly grows tiny eyes and reforms it's appendages into legs!</span>",
		"<span class='danger'><font size='2'><b>We are in our weakest form! WE HAVE TO SURVIVE!</b></font></span>")


/mob/proc/changeling_fake_arm_blade()
	set category = "Changeling"
	set name = "Fake arm Blade (30)"
	set desc = "We reform victims arm into a fake armblade."

	var/mob/living/carbon/human/T = changeling_sting(30,/mob/proc/changeling_fake_arm_blade)
	if(!T)	return 0
	spawn(10 SECONDS)
		to_chat(T, "<span class='danger'>You feel strange spasms in your hand.</span>")
		spawn(15 SECONDS)
			playsound(T.loc, 'sound/effects/blobattack.ogg', 30, 1)
			var/hand = pick(list(BP_R_HAND,BP_L_HAND))
			var/failed
			switch(hand)
				if(BP_R_HAND)
					if(!isProsthetic(T.r_hand))
						T.drop_r_hand()
					else if(!isProsthetic(T.l_hand))
						T.drop_l_hand()
						hand = BP_L_HAND
					else
						failed = TRUE

				if(BP_L_HAND)
					if(!isProsthetic(T.l_hand))
						T.drop_l_hand()
					else if(!isProsthetic(T.r_hand))
						T.drop_r_hand()
						hand = BP_R_HAND
					else
						failed = TRUE
			if (!failed)
				T.visible_message("<span class='warning'>The flesh is torn around the [T.name]\'s arm!</span>",
									"<span class='warning'>We are transforming [T.name]\'s arm into fake armblade.</span>",
									"<span class='italics'>You hear organic matter ripping and tearing!</span>")
				new /obj/item/weapon/melee/prosthetic/bio/fake_arm_blade(T,T.organs_by_name[hand])

//No breathing required
/mob/proc/changeling_no_pain()
	set category = "Changeling"
	set name = "Toggle feel pain"
	set desc = "We choose whether or not to fell pain."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return 0

	var/mob/living/carbon/human/C = src
	C.no_pain = !C.no_pain

	if(C.can_feel_pain())
		to_chat(C, "<span class='notice'>We are able to feel pain now.</span>")
	else
		to_chat(C, "<span class='notice'>We are unable to feel pain anymore.</span>")

	spawn(0)
		while(C && !C.can_feel_pain() && C.mind && C.mind.changeling)
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 3, 0)
			if (C.mind.changeling.chem_charges == 0)
				C.no_pain = !C.no_pain
			sleep(40)
	return 1

/mob/proc/changeling_rapid_heal()
	set category = "Changeling"
	set name = "Passive Regeneration(10)"
	set desc = "Allows you to passively regenerate when activated."

	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.mind.changeling.heal)
			H.mind.changeling.heal = !H.mind.changeling.heal
			to_chat(H, "<span class='notice'>We inactivate our stemocyte pool and stop intensive fleshmending.</span>")
			return

		var/datum/changeling/changeling = changeling_power(10,0,100,CONSCIOUS)
		if(!changeling)
			return

		H.mind.changeling.heal = !H.mind.changeling.heal
		to_chat(H, "<span class='notice'>We activate our stemocyte pool and begin intensive fleshmending.</span>")

		spawn(0)
			while(H && H.mind && H.mind.changeling.heal && H.mind.changeling.damaged)
				H.mind.changeling.chem_charges = max(H.mind.changeling.chem_charges - 1, 0)
				if(H.getBruteLoss())
					H.adjustBruteLoss(-15 * config.organ_regeneration_multiplier)	//Heal brute better than other ouchies.
				if(H.getFireLoss())
					H.adjustFireLoss(-10 * config.organ_regeneration_multiplier)
				if(H.getToxLoss())
					H.adjustToxLoss(-15 * config.organ_regeneration_multiplier)
				if(prob(5) && !H.getBruteLoss() && !H.getFireLoss())
					var/obj/item/organ/external/head/D = H.organs_by_name[BP_HEAD]
					if (D.disfigured)
						D.disfigured = 0
				for(var/bpart in shuffle(H.internal_organs_by_name))
					var/obj/item/organ/internal/regen_organ = H.internal_organs_by_name[bpart]
					if(regen_organ.robotic >= ORGAN_ROBOT)
						continue
					if(istype(regen_organ))
						if(regen_organ.damage > 0 && !(regen_organ.status & ORGAN_DEAD))
							regen_organ.damage = max(regen_organ.damage - 5, 0)
							if(prob(5))
								to_chat(H, "<span class='warning'>You feel a soothing sensation as your [regen_organ] mends...</span>")
						if(regen_organ.status & ORGAN_DEAD)
							regen_organ.status &= ~ORGAN_DEAD
				if(prob(2))
					for(var/limb_type in H.species.has_limbs)
						if (H.restore_limb(limb_type,1))
							break
				if(H.mind.changeling.chem_charges == 0)
					H.mind.changeling.heal = !H.mind.changeling.heal
					to_chat(H, "<span class='warning'>We inactivate our stemocyte pool and stop intensive fleshmending because we run out of chemicals.</span>")
				sleep(40)


/mob/proc/changeling_move_biostructure()
	set category = "Changeling"
	set name = "Move Biostructure"
	set desc = "We relocate our precious organ."

	var/mob/living/carbon/T = src
	if(T)
		T.move_biostructure()

/mob/proc/changeling_transfer_mind(var/atom/A)
	var/obj/item/organ/internal/biostructure/BIO
	if (istype(src,/mob/living/carbon/brain))
		BIO = src.loc
	else
		BIO = locate() in src.contents

	if(!BIO)
		return
	var/mob/M = A

	BIO.change_host(A)

	if (src.mind)	//basicaly if its mob then mind transfers to mob otherwise creating brain inside of biostucture
		if(istype(M) && !istype(M,/mob/living/carbon/brain))
			src.mind.transfer_to(M)
		else
			BIO.mind_into_biostructure(src)
	else
		if(istype(M))
			M.key = src.key
		return

	var/mob/living/carbon/human/H = A
	if (istype(H))
		if(H.stat == DEAD)
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
			H.failed_last_breath = 0 //So mobs that died of oxyloss don't revive and have perpetual out of breath.
			H.reload_fullscreen()


/mob/proc/chem_disp_sting()
	set category = "Changeling"
	set name = "Biochemical Cauldron"
	set desc = "Our stinger glands are able to synthesize a variety of chemicals."



	var/datum/changeling/changeling = changeling_power(10,0,100)
	if(!changeling)	return

	var/list/chemistry = list(
	/datum/reagent/hydrazine,
	/datum/reagent/lithium,
	/datum/reagent/carbon,
	/datum/reagent/ammonia,
	/datum/reagent/acetone,
	/datum/reagent/sodium,
	/datum/reagent/aluminum,
	/datum/reagent/silicon,
	/datum/reagent/phosphorus,
	/datum/reagent/sulfur,
	/datum/reagent/potassium,
	/datum/reagent/iron,
	/datum/reagent/copper,
	/datum/reagent/ethanol,
	/datum/reagent/acid,
	/datum/reagent/tungsten,
	/datum/reagent/water
	)
	var/mob/living/carbon/human/T = src
	if(src.mind.changeling.recursive_enhancement == TRUE)
		chemistry += list(
		/datum/reagent/mercury,
		/datum/reagent/radium,
		/datum/reagent/acid/hydrochloric,
		/datum/reagent/toxin/phoron
		)

//	var/obj/item/organ/internal/biostructure/BIO = T.internal_organs_by_name[BP_CHANG]
	var/datum/reagent/target_chem = input(T, "Choose reagent:") as null|anything in chemistry
//	T.mind.changeling.pick_chemistry.reagent_list += input(T, "Choose reagent:") as null|anything in chemistry
	var/amount = input(T,"How much reagent do we want to synthesize?", "Amount", 1) as num|null
	if(src.mind.changeling.chem_charges < amount)
		to_chat(src, "<span class='notice'>Not enough chemicals.</span>")
		return
	if(target_chem == /datum/reagent/toxin/phoron)
		if(src.mind.changeling.chem_charges < 2*amount)
			to_chat(src, "<span class='notice'>Not enough chemicals.</span>")
			return
	T.mind.changeling.pick_chemistry.add_reagent(target_chem, amount)
//	pick_chemistry.trans_to_obj(BIO, amount/*, var/multiplier = 1*/, 1)
	if(target_chem == /datum/reagent/toxin/phoron)
		amount *= 2
	src.mind.changeling.chem_charges -= amount
	if(!(/mob/proc/chem_sting in src.verbs))
		src.verbs += /mob/proc/chem_sting

/mob/proc/chem_sting()
	set category = "Changeling"
	set name = "Chemical Sting (5)"
	set desc = "We inject synthesized chemicals into the victim."


//	var/datum/changeling/changeling = changeling_power(10,0,100)
	var/mob/living/carbon/human/C = src
//	var/obj/item/organ/internal/biostructure/BIO = C.internal_organs_by_name[BP_CHANG]


	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return 0

	if(src.status_flags & FAKEDEATH)	//Тупа проверка на лежание в стазисе
		to_chat(src, "<span class='warning'>We can't sting until our stasis ends successfully.</span>")
		return 0

	var/mob/living/carbon/human/T = changeling_sting(5, /mob/proc/chem_sting)
	if(!T)	return 0
	var/N = 10
	if(src.mind.changeling.recursive_enhancement == TRUE)
		N = 20
	C.mind.changeling.pick_chemistry.trans_to_mob(T, N)
	feedback_add_details("changeling_powers","CS")
	src.verbs -= /mob/proc/chem_sting
	return 1
