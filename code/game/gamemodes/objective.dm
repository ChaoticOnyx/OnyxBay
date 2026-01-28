//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/datum/team/team 				//An alternative to 'owner': a team. Use this when writing new code.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/team_explanation_text 			//For when there are multiple owners.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.

/datum/objective/New(text)
	all_objectives |= src
	if(text)
		explanation_text = text
	..()

/datum/objective/Destroy()
	all_objectives -= src
	return ..()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/target_is_disallowed(mob/living/carbon/human/H)
	return FALSE

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && !(possible_target.current.loc?.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
			var/mob/living/carbon/human/H = possible_target.current
			if(target_is_disallowed(H))
				continue
			if(!(H.species.species_flags & SPECIES_FLAG_NO_ANTAG_TARGET))
				possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)


/datum/objective/proc/find_target_by_role(role, role_type = 0) // Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in SSticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role)  && !(possible_target.current.loc?.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
			var/mob/living/carbon/human/H = possible_target.current
			if(!(H.species.species_flags & SPECIES_FLAG_NO_ANTAG_TARGET))
				target = possible_target
			break

/datum/objective/proc/update()
	return


/datum/objective/assassinate

/datum/objective/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.is_ooc_dead() || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1


/datum/objective/anti_revolution

/datum/objective/anti_revolution/execute

/datum/objective/anti_revolution/execute/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/execute/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/execute/check_completion()
	if(target && target.current)
		if(target.current.is_ooc_dead() || !ishuman(target.current))
			return 1
		return 0
	return 1


/datum/objective/anti_revolution/brig
	var/already_completed = 0

/datum/objective/anti_revolution/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/brig/check_completion()
	return already_completed

/datum/objective/anti_revolution/brig/update()
	if(!already_completed && target && target.current && !target.current.is_ic_dead())
		if(target.is_brigged(10 MINUTES))
			already_completed = 1


/datum/objective/anti_revolution/demote

/datum/objective/anti_revolution/demote/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to [GLOB.using_map.company_name]'s goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to [GLOB.using_map.company_name]'s goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/check_completion()
	if(target && target.current && istype(target,/mob/living/carbon/human))
		var/obj/item/card/id/I = target.current:wear_id
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			I = P.id

		if(!istype(I)) return 1

		if(I.assignment == "Assistant")
			return 1
		else
			return 0
	return 1


/datum/objective/debrain//I want braaaainssss

/datum/objective/debrain/find_target()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/debrain/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return 1
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return 0
	if( !target.current || !isbrain(target.current) )
		return 0
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return 1
	return 0


/datum/objective/protect//The opposite of killing a dude.

/datum/objective/protect/find_target()
	..()
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/check_completion()
	if(!target)			//If it's a free objective.
		return 1
	if(target.current)
		if(target.current.is_ooc_dead() || issilicon(target.current) || isbrain(target.current))
			return 0
		return 1
	return 0


/datum/objective/hijack
	explanation_text = "Hijack a shuttle or pod by escaping alone."

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat)
		return 0
	if(!evacuation_controller.has_evacuated())
		return 0
	if(issilicon(owner.current))
		return 0

	var/area/shuttle/shuttle_area = get_area(owner.current)
	if(!istype(shuttle_area) || !(shuttle_area.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
		return 0

	for(var/mob/living/player in GLOB.player_list)
		if(is_type_in_list(player.type, list(/mob/living/silicon/ai, /mob/living/silicon/pai)))
			continue
		if (!player.mind || player.mind == owner)
			continue
		if(get_area(player) == shuttle_area)
			return 0
	return 1


/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."

/datum/objective/block/check_completion()
	if(!istype(owner.current, /mob/living/silicon))
		return 0
	if(!evacuation_controller.has_evacuated())
		return 0
	if(!owner.current)
		return 0
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
	for(var/mob/living/player in GLOB.player_list)
		if(player.type in protected_mobs)	continue
		if (player.mind)
			if (player.stat != 2)
				if (get_turf(player) in shuttle)
					return 0
	return 1


/datum/objective/silence
	explanation_text = "Do not allow anyone to escape.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

/datum/objective/silence/check_completion()
	if(!evacuation_controller.has_evacuated())
		return 0

	for(var/mob/living/player in GLOB.player_list)
		if(player == owner.current)
			continue
		if(player.mind)
			if(!player.is_ooc_dead())
				var/turf/T = get_turf(player)
				if(T && is_type_in_list(T.loc, GLOB.using_map.post_round_safe_areas))
					return 0
	return 1


/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return 0
	if(isbrain(owner.current))
		return 0
	if(!evacuation_controller.has_evacuated())
		return 0
	if(!owner.current || owner.current.stat ==2)
		return 0
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return 0

	//Fails traitors if they are in a shuttle but knocked out or cuffed.
	if(owner.current.incapacitated(INCAPACITATION_KNOCKOUT|INCAPACITATION_RESTRAINED))
		return 0

	var/area/check_area = location.loc
	return check_area && is_type_in_list(check_area, GLOB.using_map.post_round_safe_areas)


/datum/objective/escape/changeling

/datum/objective/escape/changeling/target_is_disallowed(mob/living/carbon/human/H)
	if(H.full_prosthetic)
		return TRUE

/datum/objective/escape/changeling/find_target()
	. = ..()

	if(target?.current)
		explanation_text = "Escape on the shuttle or an escape pod alive and free with the identity of [target.current.real_name], the [target.assigned_role]."
		target = target.current.real_name

/datum/objective/escape/changeling/check_completion()
	if(!..())
		return FALSE
	if(!target)
		return TRUE

	var/obj/item/card/id/id_card = owner.current.get_id_card()
	if(id_card?.registered_name == target && owner.current.real_name == target && owner.changeling?.last_transformation_at + 3 MINUTES <= world.time)
		return TRUE
	return FALSE


/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.is_ooc_dead() || isbrain(owner.current))
		return FALSE //Brains no longer win survive objectives. --NEO
	var/mob/living/original_mob = owner.original_mob?.resolve()
	if(issilicon(owner.current) && (istype(original_mob) && owner.current != original_mob))
		return FALSE
	return TRUE

/datum/objective/survive/changeling/check_completion()
	if(owner.changeling?.true_dead)
		return FALSE
	if(issilicon(owner.current))
		return FALSE
	return TRUE


// Similar to the anti-rev objective, but for traitors
/datum/objective/brig
	var/already_completed = 0

/datum/objective/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/brig/check_completion()
	return already_completed

/datum/objective/brig/update()
	if(!already_completed && target && target.current && !target.current.is_ic_dead())
		if(target.is_brigged(10 MINUTES))
			already_completed = 1


// Harm a crew member, making an example of them
/datum/objective/harm
	var/already_completed = 0

/datum/objective/harm/find_target()
	..()
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/harm/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/harm/check_completion()
	if(already_completed)
		return 1

	if(target && target.current && istype(target.current, /mob/living/carbon/human))
		if(target.current.is_ooc_dead())
			return 0

		var/mob/living/carbon/human/H = target.current
		for(var/obj/item/organ/external/E in H.organs)
			if(E.status & ORGAN_BROKEN)
				return 1
		for(var/limb_tag in H.species.has_limbs) //todo check prefs for robotic limbs and amputations.
			var/list/organ_data = H.species.has_limbs[limb_tag]
			var/limb_type = organ_data["path"]
			var/found
			for(var/obj/item/organ/external/E in H.organs)
				if(limb_type == E.type)
					found = 1
					break
			if(!found)
				return 1

		var/obj/item/organ/external/head/head = H.get_organ(BP_HEAD)
		if(!head || (head.status & ORGAN_DISFIGURED))
			return 1
	return 0


/datum/objective/contracts
	var/amount = 1

/datum/objective/contracts/New()
	amount = rand(3, 5)
	explanation_text = "Complete at least [amount] contracts."

/datum/objective/contracts/check_completion()
	if(owner.completed_contracts >= amount)
		return TRUE
	else
		return FALSE


/datum/objective/ert
	var/save_area_type = /area/rescue_base
/datum/objective/ert/extract_heads
	var/list/weakref/extract_heads = list() // for living one
	var/list/weakref/extract_heads_bodies = list() // for dead one

/datum/objective/ert/extract_heads/check_completion()
	for(var/weakref/ref in extract_heads)
		var/mob/living/carbon/human/head = ref.resolve()
		var/turf/T = get_turf(head)
		if(!head || head.is_ooc_dead() || !istype(T?.loc, save_area_type))
			return FALSE
	for(var/weakref/ref in extract_heads_bodies)
		var/mob/living/carbon/human/head = ref.resolve()
		var/turf/T = get_turf(head)
		if(!head || !istype(T?.loc, save_area_type))
			return FALSE
	return TRUE

/datum/objective/ert/extract_heads/New(text)
	..()
	var/list/dead_heads = list()
	var/list/heads = list()
	for(var/mob/living/carbon/human/possible_target in sortmobs())
		if(possible_target.species.species_flags & SPECIES_FLAG_NO_ANTAG_TARGET)
			continue
		if((possible_target.job in GLOB.commandjobs) && !(possible_target.loc?.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
			if(possible_target.is_ooc_dead())
				extract_heads_bodies.Add(weakref(possible_target))
				dead_heads.Add("[possible_target.real_name] ([possible_target.job])")
			else
				extract_heads.Add(weakref(possible_target))
				heads.Add("[possible_target.real_name] ([possible_target.job])")
	explanation_text = "[length(heads) ? "You need to evacuate these heads to the base: [english_list(heads)].\n " : ""]\
						[length(dead_heads) ? "According to our information the following heads are dead, take their bodies back to base: [english_list(dead_heads)]." : ""]"

/datum/objective/ert/resolve_conflict/check_completion()
	if(GLOB.revs.global_objectives.len > 0)
		var/completed = 0
		for(var/datum/objective/rev/task in GLOB.revs.global_objectives)
			if(task.check_completion())
				completed += 1
		if(completed == GLOB.revs.global_objectives.len)
			GLOB.ert.is_station_secure = FALSE

	return GLOB.ert.is_station_secure

/datum/objective/ert/resolve_conflict/New()
	..()
	explanation_text = "Resolve emergency situation you were called for and preserve any [GLOB.using_map.company_name]'s property from being lost."


/datum/objective/ert_custom
	completed = TRUE


/datum/objective/nuclear
	explanation_text = "Cause mass destruction with a nuclear device."

/datum/objective/nuclear/check_completion()
	return SSticker.mode.station_was_nuked


/datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/global/possible_items[] = list(
		"the captain's antique laser gun" = /obj/item/gun/energy/captain,
		"a bluespace rift generator in hand teleporter" = /obj/item/integrated_circuit/manipulation/bluespace_rift,
		"an RCD" = /obj/item/construction/rcd,
		"a jetpack" = /obj/item/tank/jetpack,
		"a captain's jumpsuit" = /obj/item/clothing/under/rank/captain,
		"a functional AI" = /obj/item/aicard,
		"a pair of magboots" = /obj/item/clothing/shoes/magboots,
		"the [station_name()] blueprints" = /obj/item/blueprints,
		"a nasa voidsuit" = /obj/item/clothing/suit/space/void,
		"28 moles of plasma (full tank)" = /obj/item/tank,
		"a sample of metroid extract" = /obj/item/metroid_extract,
		"a piece of corgi meat" = /obj/item/reagent_containers/food/meat/corgi,
		"a research director's jumpsuit" = /obj/item/clothing/under/rank/research_director,
		"a chief engineer's jumpsuit" = /obj/item/clothing/under/rank/chief_engineer,
		"a chief medical officer's jumpsuit" = /obj/item/clothing/under/rank/chief_medical_officer,
		"a head of security's jumpsuit" = /obj/item/clothing/under/rank/head_of_security,
		"a head of provisioning's jumpsuit" = /obj/item/clothing/under/rank/hop,
		"the hypospray" = /obj/item/reagent_containers/hypospray,
		"the captain's pinpointer" = /obj/item/pinpointer,
		"an ablative armor vest" = /obj/item/clothing/suit/armor/laserproof,
	)

	var/global/possible_items_special[] = list(
		/*"nuclear authentication disk" = /obj/item/disk/nuclear,*///Broken with the change to nuke disk making it respawn on z level change.
		"nuclear gun" = /obj/item/gun/energy/gun/nuclear,
		"diamond drill" = /obj/item/pickaxe/drill/diamonddrill,
		"bag of holding" = /obj/item/storage/backpack/holding,
		"hyper-capacity cell" = /obj/item/cell/hyper,
		"10 diamonds" = /obj/item/stack/material/diamond,
		"50 gold bars" = /obj/item/stack/material/gold,
		"25 refined uranium bars" = /obj/item/stack/material/uranium,
	)

/datum/objective/steal/proc/set_target(item_name)
	target_name = item_name
	steal_target = possible_items[target_name]
	if (!steal_target)
		steal_target = possible_items_special[target_name]
	explanation_text = "Steal [target_name]."
	return steal_target

/datum/objective/steal/find_target()
	return set_target(pick(possible_items))

/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = possible_items+possible_items_special+"custom"
	if(!(/mob/living/silicon/ai in SSmobs.mob_list))
		possible_items_all -= "a functional AI"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if(!new_target)
		return
	if(new_target == "custom")
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target)
			return
		var/tmp_obj = new custom_target
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		custom_name = sanitize(input("Enter target name:", "Objective target", custom_name) as text|null)
		if(!custom_name)
			return
		target_name = custom_name
		steal_target = custom_target
		explanation_text = "Steal [target_name]."
	else
		set_target(new_target)
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target || !owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	switch (target_name)
		if("28 moles of plasma (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
			var/target_amount = text2num(target_name)//Non-numbers are ignored.
			var/found_amount = 0.0//Always starts as zero.

			for(var/obj/item/I in all_items) //Check for plasma tanks
				if(istype(I, steal_target))
					found_amount += (target_name=="28 moles of plasma (full tank)" ? (I:air_contents:gas["plasma"]) : (I:amount))
			return found_amount>=target_amount

		if("a functional AI")
			for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
				if(ai.is_ooc_dead())
					continue
				var/turf/T = get_turf(ai)
				if(owner.current.contains(ai) || (T && is_type_in_list(T.loc, GLOB.using_map.post_round_safe_areas)))
					return 1
		else

			for(var/obj/I in all_items) //Check for items
				if(istype(I, steal_target))
					return 1
	return 0


/datum/objective/download

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research levels."
	return target_amount

/datum/objective/download/check_completion()
	if(!ishuman(owner.current))
		return 0
	if(!owner.current || owner.current.stat == 2)
		return 0

	var/current_amount
	var/obj/item/rig/S
	if(istype(owner.current,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		S = H.back

	if(!istype(S) || !S.installed_modules || !S.installed_modules.len)
		return 0

	var/obj/item/rig_module/datajack/stolen_data = locate() in S.installed_modules
	if(!istype(stolen_data))
		return 0

	for(var/datum/tech/current_data in stolen_data.stored_research)
		if(current_data.level > 1)
			current_amount += (current_data.level-1)

	return (current_amount<target_amount) ? 0 : 1


/datum/objective/capture

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = locate()

	for(var/mob/living/carbon/human/M in A) // Humans (and subtypes).
		var/worth = M.species.rarity_value
		if(M.stat==DEAD)//Dead folks are worth less.
			worth*=0.5
			continue
		captured_amount += worth

	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat==DEAD)
			captured_amount+=0.5
			continue
		captured_amount+=1

	if(captured_amount<target_amount)
		return 0
	return 1


/datum/objective/absorb

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	if (GAME_STATE == RUNLEVEL_SETUP)
		for(var/mob/new_player/P in GLOB.player_list)
			if(P.client && P.ready && P.mind!=owner)
				n_p ++
	else if (GAME_STATE == RUNLEVEL_GAME)
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(P.client && !(P.mind.changeling) && P.mind!=owner)
				n_p ++
	target_amount = min(target_amount, n_p)

	explanation_text = "Absorb [target_amount] compatible genomes."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return 1
	else
		return 0


// Heist objectives.
/datum/objective/heist

/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap

/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Chief Engineer","Research Director","Roboticist","Chemist","Engineer")
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && (!possible_target.special_role))
			possible_targets += possible_target
			for(var/role in roles)
				if(possible_target.assigned_role == role)
					priority_targets += possible_target
					continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "We can get a good price for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/kidnap/check_completion()
	if(target && target.current)
		if (target.current.stat == 2)
			return 0 // They're dead. Fail.
		//if (!target.current.restrained())
		//	return 0 // They're loose. Close but no cigar.

		var/area/target_area = get_area(target.current)
		if(is_type_in_list(target_area, GLOB.raiders.safe_areas))
			return 1
	else
		return 0


/datum/objective/heist/loot

/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1,8))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "a complete particle accelerator"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "a gravitational singularity generator"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "four emitters"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "a nuclear bomb"
		if(5)
			target = /obj/item/gun
			target_amount = 6
			loot = "six guns"
		if(6)
			target = /obj/item/gun/energy
			target_amount = 4
			loot = "four energy guns"
		if(7)
			target = /obj/item/gun/energy/laser
			target_amount = 2
			loot = "two laser guns"
		if(8)
			target = /obj/item/gun/energy/ionrifle
			target_amount = 1
			loot = "an ion gun"

	explanation_text = "It's a buyer's market out here. Steal [loot] for resale."

/datum/objective/heist/loot/check_completion()
	var/total_amount = 0
	var/list/objects_to_check = list()

	for(var/i in GLOB.raiders.safe_areas)
		var/area/A = locate(i)
		for(var/obj/O in A)
			objects_to_check |= O

	for(var/obj/O in objects_to_check)
		if(istype(O, target))
			total_amount++
		else
			for(var/obj/C in O.contents)
				if(istype(C, target))
					total_amount++

	for(var/datum/mind/raider in GLOB.raiders.current_antagonists)
		if(!raider.current)
			continue

		var/area/raider_area = get_area(raider.current)
		if(!is_type_in_list(raider_area, GLOB.raiders.safe_areas))
			continue

		for(var/obj/O in raider.current.get_contents())
			if(istype(O, target))
				total_amount++

	if(total_amount >= target_amount)
		return 1
	return 0


/datum/objective/heist/salvage

/datum/objective/heist/salvage/choose_target()
	switch(rand(1,8))
		if(1)
			target = MATERIAL_STEEL
			target_amount = 300
		if(2)
			target = MATERIAL_GLASS
			target_amount = 200
		if(3)
			target = MATERIAL_PLASTEEL
			target_amount = 100
		if(4)
			target = MATERIAL_PLASMA
			target_amount = 100
		if(5)
			target = MATERIAL_SILVER
			target_amount = 50
		if(6)
			target = MATERIAL_GOLD
			target_amount = 20
		if(7)
			target = MATERIAL_URANIUM
			target_amount = 20
		if(8)
			target = MATERIAL_DIAMOND
			target_amount = 20

	explanation_text = "Ransack the [station_name()] and escape with [target_amount] [target]."

/datum/objective/heist/salvage/check_completion()
	var/total_amount = 0
	var/list/objects_to_check = list()

	for(var/i in GLOB.raiders.safe_areas)
		var/area/A = locate(i)
		for(var/obj/O in A)
			objects_to_check |= O

	for(var/obj/O in objects_to_check)
		if(istype(O, /obj/item/stack/material))
			var/obj/item/stack/material/M = O
			if(M.material.name == target)
				total_amount += M.get_amount()
		else
			for(var/obj/item/stack/material/M in O.contents)
				if(M.material.name == target)
					total_amount += M.get_amount()

	for(var/datum/mind/raider in GLOB.raiders.current_antagonists)
		if(!raider.current)
			continue

		var/area/raider_area = get_area(raider.current)
		if(!is_type_in_list(raider_area, GLOB.raiders.safe_areas))
			continue

		for(var/obj/item/stack/material/M in raider.current.get_contents())
			if(M.material.name == target)
				total_amount += M.get_amount()

	if(total_amount >= target_amount)
		return 1
	return 0


/datum/objective/heist/preserve_crew
	explanation_text = "Do not leave anyone behind, alive or dead."

/datum/objective/heist/preserve_crew/check_completion()
	if(GLOB.raiders && GLOB.raiders.is_raider_crew_safe()) return 1
	return 0


// Borer objective(s).
/datum/objective/borer_survive
	explanation_text = "Survive in a host until the end of the round."

/datum/objective/borer_survive/check_completion()
	if(owner)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && !B.is_ooc_dead() && B.host && !B.host.is_ooc_dead())
			return 1
	return 0


/datum/objective/borer_reproduce
	explanation_text = "Reproduce at least once."

/datum/objective/borer_reproduce/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && B.has_reproduced)
			return 1
	return 0


/datum/objective/ninja_highlander
   explanation_text = "You aspire to be a Grand Master of the Spider Clan. Kill all of your fellow acolytes."

/datum/objective/ninja_highlander/check_completion()
	if(owner)
		for(var/datum/mind/ninja in get_antags("ninja"))
			if(ninja != owner)
				if(ninja.current.stat < 2) return 0
		return 1
	return 0

/datum/objective/cult/survive
	explanation_text = "Our knowledge must live on."
	target_amount = 5

/datum/objective/cult/survive/New()
	..()
	explanation_text = "Our knowledge must live on. Make sure at least [target_amount] acolytes escape on the shuttle to spread their work on an another station."

/datum/objective/cult/survive/check_completion()
	var/acolytes_survived = 0
	if(!GLOB.cult)
		return 0
	for(var/datum/mind/cult_mind in GLOB.cult.current_antagonists)
		if (cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if (is_type_in_list(A, GLOB.using_map.post_round_safe_areas))
				acolytes_survived++
	if(acolytes_survived >= target_amount)
		return 1
	return 0

/datum/objective/cult/eldergod
	explanation_text = "Summon Nar-Sie via the use of the Tear Reality rune. It will only work if five or more cultists stand on and around it. Use the Convert rune to recruit new cultists."

/datum/objective/cult/eldergod/check_completion()
	return GLOB.cult.narsie_summoned

/datum/objective/cult/sacrifice
	explanation_text = "Conduct a ritual sacrifice for the glory of Nar-Sie."

/datum/objective/cult/sacrifice/find_target()
	var/list/possible_targets = list()
	if(!possible_targets.len)
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !(player.mind in GLOB.cult.current_antagonists))
				possible_targets += player.mind
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	if(target) explanation_text = "Sacrifice [target.name], the [target.assigned_role]. You will need the Offering rune and three acolytes to do so."

/datum/objective/cult/sacrifice/check_completion()
	return (target && GLOB.cult && !GLOB.cult.sacrificed.Find(target))

/datum/objective/rev/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate, capture or convert [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/rev/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate, capture or convert [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/rev/check_completion()
	var/rval = 1
	if(target && target.current)
		var/mob/living/carbon/human/H = target.current
		if(!istype(H))
			return 1
		if(H.is_ooc_dead() || H.restrained())
			return 1
		// Check if they're converted
		if(target in GLOB.revs.current_antagonists)
			return 1
		var/turf/T = get_turf(H)
		if(T && !isStationLevel(T.z))			//If they leave the station they count as dead for this
			rval = 2
		return 0
	return rval
