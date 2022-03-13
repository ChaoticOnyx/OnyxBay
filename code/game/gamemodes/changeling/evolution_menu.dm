// READ: Don't use the apostrophe in name or desc. Causes script errors.

var/list/powers = typesof(/datum/power/changeling) - /datum/power/changeling	//needed for the badmin verb for now
var/list/datum/power/changeling/powerinstances = list()

/datum/power			//Could be used by other antags too
	var/name = "Power"
	var/desc = "Placeholder"
	var/helptext = ""
	var/enhancedtext = ""

	var/is_active = TRUE // Is it an active power, or passive?
	var/verbpath // Path to a verb that contains the effects. TODO: Get rid of it after rewriting vampires.
	var/power_path // Path to an actual power datum.

/datum/power/changeling
	var/allowduringlesserform = 0
	var/genomecost = 500000 // Cost for the changling to evolve this power.

/datum/power/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human. They become one with us, and we become stronger."
	genomecost = 0
	power_path = /datum/changeling_power/absorb

/datum/power/changeling/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	genomecost = 0
	power_path = /datum/changeling_power/transform

/datum/power/changeling/stasis
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	helptext = "Can be used before or after death. Spends all the chemicals we have. Duration depends on how many chemicals were spent."
	enhancedtext = "We regain some of our chemicals upon reviving."
	genomecost = 0
	power_path = /datum/changeling_power/toggled/stasis

// Hivemind
/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA we channel from the airwaves. Will not help them towards their absorb objectives."
	genomecost = 0
	power_path = /datum/changeling_power/passive/hive_upload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows us to absorb a single DNA and use it. Does not count towards our absorb objective."
	genomecost = 0
	power_path = /datum/changeling_power/passive/hive_download

// Biostructure and limb management
/datum/power/changeling/move_biostructure
	name = "Relocate Biostructure"
	desc = "We relocate our true self inside our host."
	helptext = "Takes time."
	enhancedtext = "Would relocate faster."
	genomecost = 0
	power_path = /datum/changeling_power/passive/move_biostructure

/datum/power/changeling/detach_limb
	name = "Detach Limb"
	desc = "We tear off our limb, turning it into an aggressive biomass."
	helptext = "It hurts."
	genomecost = 0
	power_path = /datum/changeling_power/detach_limb

// Other free abilities
/datum/power/changeling/self_respiration
	name = "Self Respiration"
	desc = "We evolve our body to no longer require drawing oxygen from the atmosphere."
	helptext = "We will no longer require internals, and we cannot inhale any gas, including harmful ones."
	genomecost = 0
	power_path = /datum/changeling_power/toggled/self_respiration

/*
/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 4
	verbpath = /mob/proc/changeling_lesser_form
*/

/datum/power/changeling/sting_deaf
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	genomecost = 1
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/sting/deaf

/datum/power/changeling/sting_blind
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/sting/blind

/datum/power/changeling/sting_silence
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they have been stung, until they try to speak and cannot."
	genomecost = 3
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/sting/silence

/datum/power/changeling/sting_vomit
	name = "Vomit Sting"
	desc = "We silently sting a human, urging them to throw up in one second."
	genomecost = 1
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/sting/vomit

/datum/power/changeling/sting_extract_dna
	name = "DNA Extraction Sting"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give us the DNA of our target, allowing us to transform into them. Does not count towards absorb objectives."
	genomecost = 4
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/sting/extract_dna


/datum/power/changeling/sting_hallucination
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallunicationary chemical."
	helptext = "The target does not notice they have been stung. The effect occurs after 30 to 60 seconds."
	genomecost = 3
	power_path = /datum/changeling_power/toggled/sting/hallucination

/datum/power/changeling/sting_fake_armblade
	name = "Fake Armblade Sting"
	desc = "We sting our victim, causing one of their arms to reform into a fake armblade."
	helptext = "The effect is irreversible."
	genomecost = 4
	power_path = /datum/changeling_power/toggled/sting/fake_armblade

/*
/datum/power/changeling/DeathSting
	name = "Death Sting"
	desc = "We sting a human, filling them with potent chemicals. Their rapid death is all but assured, but our crime will be obvious."
	helptext = "It will be clear to any surrounding witnesses if you use this power."
	genomecost = 10
	verbpath = /mob/proc/changeling_death_sting
*/

/datum/power/changeling/boost_range
	name = "Ranged Stinger"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	helptext = "While active, our sting-based abilities can be used against targets 2 squares away, but require additional 20 chemicals."
	genomecost = 3
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/boost_range

/datum/power/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn our voice into the name that we enter. We must constantly expend chemicals to maintain our form like this"
	genomecost = 3
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/mimic_voice

/datum/power/changeling/unstun
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Allows us to instantly recover from stuns. High chemical cost."
	genomecost = 3
	power_path = /datum/changeling_power/unstun

/datum/power/changeling/rapid_chem
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 4
	is_active = 0
	power_path = /datum/changeling_power/passive/rapid_chem
/*
/datum/power/changeling/AdvChemicalSynth
	name = "Advanced Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 8
	isVerb = 0
	verbpath = /mob/proc/changeling_fastchemical
*/
/datum/power/changeling/engorged_glands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store extra 50 units of chemicals."
	genomecost = 4
	is_active = 0
	power_path = /datum/changeling_power/passive/engorged_glands

/datum/power/changeling/digital_camouflage
	name = "Digital Camouflage"
	desc = "We evolve the ability to distort our form and proprtions, defeating common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by cameras while using this ability. However, humans looking at us will find us.. uncanny.  We must constantly expend chemicals to maintain our form like this."
	genomecost = 2
	allowduringlesserform = 1
	power_path = /datum/changeling_power/toggled/digital_camouflage

/datum/power/changeling/rapid_heal
	name = "Rapid Heal"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a considerable amount of damage every tick."
	genomecost = 8
	power_path = /datum/changeling_power/toggled/rapid_heal

/datum/power/changeling/visible_camouflage
	name = "Visible Camouflage"
	desc = "We rapidly shape the color of our skin and secrete easily reversible dye on our clothes, to blend in with our surroundings.  \
	We are undetectable, as long as we move slowly."
	helptext = "Toggleable. Running, and performing most acts will reveal us. Our chemical regeneration is halted while we are hidden."
	enhancedtext = "Can run while hidden."
	genomecost = 8
	power_path = /datum/changeling_power/toggled/visible_camouflage

// Changeling items
/datum/power/changeling/armblade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade."
	helptext = "We may retract our armblade by dropping it."
	enhancedtext = "The blade gets increased damage and a bit higher armor penetration."
	genomecost = 8
	power_path = /datum/changeling_power/item/armblade

/datum/power/changeling/claw
	name = "Claw"
	desc = "We reform one of our arms into a deadly claw."
	helptext = "We may retract our claw by dropping it."
	enhancedtext = "The claw gets increased armor penetration and a bit higher damage."
	genomecost = 6
	power_path = /datum/changeling_power/item/claw

/datum/power/changeling/lockpick
	name = "Bioelectric Lockpick"
	desc = "We discreetly evolve a finger to be able to send a small electric charge.  \
	We can open most electrical locks, but it will be obvious when we do so."
	helptext = "Use the ability, then touch something that utilizes an electrical locking system, to open it. Each use costs 10 chemicals."
	genomecost = 8
	power_path = /datum/changeling_power/item/lockpick

/datum/power/changeling/recursive_enhancement
	name = "Recursive Enhancement"
	desc = "We cause some of our abilities to have increased or additional effects."
	helptext = "To check the effects for each ability, check the blue text underneath the ability in the evolution menu."
	genomecost = 6
	power_path = /datum/changeling_power/passive/recursive_enhancement
/*
/datum/power/changeling/fake_blade
	name = "Fake armblade"
	desc = "We reform victims arm into a fake armblade."
	helptext = "The effect is irrevertable."
	enhancedtext = "Doing nothing"
	genomecost = 4
	verbpath = /mob/proc/changeling_fake_arm_blade_sting
*/

/datum/power/changeling/no_pain
	name = "Painless"
	desc = "We choose whether or not to fell pain."
	helptext = "Toggleable ability."
	genomecost = 5
	power_path = /datum/changeling_power/toggled/no_pain

/datum/power/changeling/disjunction
	name = "Body Disjunction"
	desc = "Tear apart our human disguise and become a hunting pack of lesser critters."
	helptext = "Takes time."
	genomecost = 8
	power_path = /datum/changeling_power/disjunction

/datum/power/changeling/division
	name = "Division"
	desc = "We infest a humanoid with a clone of our true body, making them the same as we are."
	helptext = "Dead bodies cannot be successfully infested."
	genomecost = 4
	power_path = /datum/changeling_power/division

/*datum/power/changeling/chem_disp_sting
	name = "Biochemical Cauldron"
	desc = "We evolve our stinger glands to be able to synthesize a variety of chemicals."
	helptext = "Every sting would contain 10 units of the pre-chosen solution from our glands and would require 5 units of our chemicals per injection."
	enhancedtext = "20 units of the solution per sting and more reagents to synthesize from."
	genomecost = 10
	verbpath = /mob/proc/chem_disp_sting
*/
/*
/datum/power/changeling/changeling_chemical_sting
	name = "Chemical Sting"
	desc = "We inject synthesized chemicals to the victim."
	helptext = "Spends more chemicals on plasma synthesis. To use this, we need to have Synthesis of chemistry."
	genomecost = 3
	verbpath = /mob/proc/changeling_chemical_sting
*/
/datum/power/changeling/regeneration
	name = "Passive Regeneration"
	desc = "Allows us to passively regenerate when activated."
	helptext = "Spends chemicals."
	genomecost = 6
	power_path = /datum/changeling_power/toggled/regeneration

/datum/power/changeling/bioelectrogenesis
	name = "Bioelectrogenesis"
	desc = "We make adjustments to our mitochondria, allowing us to emmit rather powerful electromagnetic pulses at will."
	helptext = "EMP can disable electronic devices and cause severe damage to synthetic lifeforms. This ability has a strong effect in a 1 tile radius around us, and a weaker effect in a 2 tile radius."
	enhancedtext = "EMP has a strong effect in a 2 tile radius."
	genomecost = 5
	power_path = /datum/changeling_power/bioelectrogenesis

/datum/power/changeling/darksight
	name = "Dark Sight"
	desc = "We change the composition of our eyes, banishing the shadows from our vision."
	helptext = "We will be able to see in the dark."
	genomecost = 0
	power_path = /datum/changeling_power/toggled/darksight

/datum/changeling/proc/EvolutionMenu()
	set category = "Changeling"
	set name = "Evolution Menu"
	set desc = "Level up!"

	if(!usr?.mind?.changeling)
		return
	src = usr.mind.changeling

	if(usr != my_mob)
		return

	tgui_interact(usr)

/datum/changeling/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Changeling", "Evolution Menu")
		ui.open()

/datum/changeling/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/changeling/tgui_static_data(mob/user)
	var/static/icon/genom = new /icon('icons/mob/screen_spells.dmi', "genetics_closed")
	var/static/icon/spell_background = new /icon('icons/mob/screen_spells.dmi', "changeling_spell_base")
	var/static/icon/spell_unlocked_background = new /icon('icons/mob/screen_spells.dmi', "changeling_spell_ready")

	return list(
		"icons" = list(
			"genom" = icon2base64html(genom),
			"spell_background" = icon2base64html(spell_background),
			"spell_unlocked_background" = icon2base64html(spell_unlocked_background)
		)
	)

/datum/changeling/tgui_data(mob/user)
	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	var/list/data = list(
		"powers" = list(),
		"points" = geneticpoints
	)

	for(var/datum/power/changeling/P in powerinstances)
		var/list/power_data = list(
			"name" = P.name,
			"icon" = icon2base64html(P.power_path),
			"description" = P.desc,
			"help_text" = P.helptext,
			"enhanced_text" = P.enhancedtext,
			"cost" = P.genomecost
		)

		if(P in purchasedpowers)
			power_data["owned"] = TRUE

		data["powers"] += list(power_data)

	return data

/datum/changeling/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("buy")
			purchase_power(params["power_name"])
			return TRUE

/datum/changeling/tgui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/exocet),
		get_asset_datum(/datum/asset/simple/pelagiad)
	)

/datum/changeling/proc/purchase_power(power_name)
	var/datum/power/changeling/PC
	for(var/datum/power/changeling/P in powerinstances)
		if(P.name == power_name)
			PC = P
			break

	if(!PC)
		CRASH("Invalid power name [power_name]")

	if(PC in purchasedpowers)
		to_chat(my_mob, SPAN("changeling", "We have already evolved this ability!"))
		return

	if(geneticpoints < PC.genomecost)
		to_chat(my_mob, SPAN("changeling", "We cannot evolve this... yet. We must acquire more DNA."))
		return

	geneticpoints -= PC.genomecost
	purchasedpowers += PC

	add_changeling_power(PC)

// For debugging. Or for events and badminship, who knows.
/datum/changeling/proc/purchase_everything()
	for(var/datum/power/changeling/P in powerinstances)
		purchasedpowers += P
		add_changeling_power(P)
