#define SURGERY_FAILURE -1
#define SURGERY_BLOCKED -2
#define SURGERY_ORGAN_REMOVE 0
#define SURGERY_ORGAN_INSERT 1
#define SURGERY_ORGAN_HEAL 2
#define SURGERY_ORGAN_CONNECT 3
#define SURGERY_ORGAN_DISCONNECT 4
#define SURGERY_ORGAN_TREAT 5
#define SURGERY_BONEGEL 1
#define SURGERY_BONESET 2
#define SURGERY_BONESET_ULTRA 3
#define SURGERY_SAW 4
#define SURGERY_RETRACTOR 5
#define SURGERY_CAUTERY 6
#define SURGERY_DRILL 7
#define SURGERY_FAILED_STATE -1337

/obj/item/integrated_circuit/medical
	category_text = "Medical"

/obj/item/integrated_circuit/medical/surgery_device
	name = "surgical manipulator"
	desc = "This device is a manipulator compatible with most surgical instruments. While holding such an instrument, it can perform various surgical operations."
	extended_desc = "Takes a target ref to do operation on and bodypart of target to do operation on, pulse activation pin, have a happy operation!"
	ext_cooldown = 10
	complexity = 20
	size = 10
	// organ cases will not be fired
	inputs = list(
		"target"   = IC_PINTYPE_REF,
		"bodypart" = IC_PINTYPE_STRING
		)
	outputs = list(
		"instrument" = IC_PINTYPE_REF
	)
	activators = list(
		"use"        = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT
		)
	power_draw_per_use = 60
	demands_object_input = TRUE		// You can put stuff in once the circuit is in assembly,passed down from additem and handled by attackby()
	var/list/obj/item/surgery_items_type_list = list(
		/obj/item/bonegel, // SURGERY_BONEGEL
		/obj/item/bonesetter, // SURGERY_BONESET
		/obj/item/bonesetter/bone_mender, // SURGERY_BONESET_ULTRA
		/obj/item/circular_saw, // SURGERY_SAW
		/obj/item/scalpel, // SURGERY_ORGAN_DISCONNECT
		/obj/item/retractor, // SURGERY_RETRACTOR
		/obj/item/hemostat, // SURGERY_ORGAN_REMOVE
		/obj/item/cautery, // SURGERY_CAUTERY
		/obj/item/surgicaldrill, // SURGERY_DRILL
		/obj/item/FixOVein, // SURGERY_ORGAN_CONNECT
		/obj/item/organfixer/advanced, // SURGERY_ORGAN_HEAL
		/obj/item/organ, // SURGERY_ORGAN_INSERT
		/obj/item/reagent_containers/dropper, // SURGERY_ORGAN_TREAT
	)
	var/datum/surgery_step/internal/st
	var/selected_zone
	var/obj/item/instrument
	var/operation_intent
	var/bodyparts_hint = TRUE
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/medical/surgery_device/proc/on_item_insert(obj/item/I)
	QDEL_NULL(st)
	if(istype(I, /obj/item/organfixer/advanced))
		operation_intent = SURGERY_ORGAN_HEAL
		st = new /datum/surgery_step/internal/fix_organ_multiple()

/obj/item/integrated_circuit/medical/surgery_device/get_selected_zone()
	return selected_zone

/obj/item/integrated_circuit/medical/surgery_device/get_active_item()
	return instrument

/obj/item/integrated_circuit/medical/surgery_device/Initialize()
	. = ..()
	if(!bodyparts_hint)
		return
	extended_desc += "\nThe avaliable list of bodyparts: "
	extended_desc += jointext(BP_ALL_LIMBS, ", ")

/obj/item/integrated_circuit/medical/surgery_device/attack_self(mob/user)
	if(instrument)
		instrument.forceMove(get_turf(user))
		to_chat(user, SPAN("notice", "You slide \the [instrument] out of \the [src]."))
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		instrument = null
		st = null
		set_pin_data(IC_OUTPUT, 1, weakref(null))
		push_data()
	else
		to_chat(user, SPAN("notice", "There's no instrument to remove from the mechanism."))

/obj/item/integrated_circuit/medical/surgery_device/attackby(obj/item/O, mob/user)
	if(instrument)
		to_chat(user, SPAN("warning", "There's already a instrument installed."))
		return

	for(var/itype in surgery_items_type_list)
		if(istype(O, itype))
			instrument = O
			user.drop_item(O)
			instrument.forceMove(src)
			break
	on_item_insert(instrument)
	set_pin_data(IC_OUTPUT, 1, weakref(instrument))
	push_data()
	..()

/obj/item/integrated_circuit/medical/surgery_device/do_work(ord)
	switch(ord)
		if(2)
			activate_pin(2)
		if(3)
			activate_pin(3)
	var/mob/living/carbon/H = get_pin_data(IC_INPUT, 1)
	if(!istype(H))
		activate_pin(3)
		return
	var/lying = FALSE
	var/turf/T = get_turf(H)
	if(locate(/obj/machinery/optable, T))
		lying = TRUE
	if(locate(/obj/structure/bed, T))
		lying = TRUE
	if(locate(/obj/structure/table, T))
		lying = TRUE
	if(locate(/obj/effect/rune, T))
		lying = TRUE
	if(!lying && get_dist(get_object(), H) > 1)
		activate_pin(3)
		return
	selected_zone = get_pin_data(IC_INPUT, 2)
	if(!selected_zone || !(selected_zone in BP_ALL_LIMBS))
		activate_pin(3)
		return
	if(selected_zone in H.op_stage.in_progress) //Can't operate on someone repeatedly.
		activate_pin(3)
		return

	var/status = do_int_surgery(H)
	if(status && !(status == SURGERY_FAILURE || status == SURGERY_BLOCKED))
		var/atom/A = get_object()
		A.investigate_log("made some operation on ([H]) with [src].", INVESTIGATE_CIRCUIT)
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/medical/surgery_device/proc/can_use(mob/living/carbon/human/target, obj/item/organ/internal/organ, target_zone)
	return TRUE

/obj/item/integrated_circuit/medical/surgery_device/proc/do_int_surgery(mob/living/carbon/M)
	for(var/datum/surgery_step/S in surgery_steps)
		if(istype(S, /datum/surgery_step/internal) && S.type != st?.type)
			continue
		var/status = do_real_surgery(M, S)
		if(status != SURGERY_FAILED_STATE)
			return status
	return FALSE

/obj/item/integrated_circuit/medical/surgery_device/proc/do_real_surgery(mob/living/carbon/M, datum/surgery_step/S, use_integrated_circuit_can_use_check = FALSE, obj/item/organ/organ)
	//check if tool is right or close enough and if this step is possible
	var/obj/item/user = get_object()
	if(S.tool_quality(instrument))
		var/step_is_valid
		if(use_integrated_circuit_can_use_check)
			step_is_valid = can_use(M, organ, selected_zone)
		else
			step_is_valid = S.can_use(user, M, selected_zone, instrument)
		if(step_is_valid && S.is_valid_target(M))
			return S.do_surgery_process(M, user, selected_zone, instrument, step_is_valid)
	return SURGERY_FAILED_STATE // for checks...
/*
	SUBTYPES.
*/

/obj/item/integrated_circuit/medical/surgery_device/internal
	name = "surgery internal organ device"
	inputs = list(
		"target"   = IC_PINTYPE_REF,
		"organ"    = IC_PINTYPE_REF,
		"bodypart" = IC_PINTYPE_STRING
		)
	surgery_items_type_list = list(
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/FixOVein,
		/obj/item/organfixer,
		/obj/item/organ/internal
	)
	spawn_flags = IC_SPAWN_RESEARCH
	var/obj/item/organ/organ

/obj/item/integrated_circuit/medical/surgery_device/internal/get_active_item()
	if(operation_intent == SURGERY_ORGAN_INSERT)
		return organ
	return instrument

/obj/item/integrated_circuit/medical/surgery_device/internal/on_item_insert(obj/item/I)
	..()
	if(istype(st))
		return
	if(istype(I, /obj/item/scalpel))
		operation_intent = SURGERY_ORGAN_DISCONNECT
		st = new /datum/surgery_step/internal/detatch_organ()
	else if(istype(I, /obj/item/hemostat))
		operation_intent = SURGERY_ORGAN_REMOVE
		st = new /datum/surgery_step/internal/remove_organ()
	else if(istype(I, /obj/item/FixOVein))
		operation_intent = SURGERY_ORGAN_CONNECT
		st = new /datum/surgery_step/internal/attach_organ()
	else if(istype(I, /obj/item/organfixer))
		operation_intent = SURGERY_ORGAN_HEAL
		st = new /datum/surgery_step/internal/fix_organ()
	else if(istype(I, /obj/item/reagent_containers/dropper))
		operation_intent = SURGERY_ORGAN_TREAT
		st = new /datum/surgery_step/internal/treat_necrosis()
	else
		operation_intent = SURGERY_ORGAN_INSERT
		st = new /datum/surgery_step/internal/replace_organ()

/obj/item/integrated_circuit/medical/surgery_device/internal/do_work(ord)
	var/mob/living/carbon/human/H = get_pin_data(IC_INPUT, 1)
	var/obj/item/organ/internal/O = get_pin_data(IC_INPUT, 2)
	var/obj/item/organ/external/E
	if(!istype(H))
		activate_pin(3)
		return
	selected_zone = get_pin_data(IC_INPUT, 3)
	if(!istype(O))
		activate_pin(3)
		return
	organ = O
	if(!selected_zone || !(selected_zone in BP_ALL_LIMBS))
		activate_pin(3)
		return
	if(selected_zone in H.op_stage.in_progress) //Can't operate on someone repeatedly.
		activate_pin(3)
		return
	if(operation_intent == SURGERY_ORGAN_INSERT)
		E = H.organs_by_name[O.parent_organ]
	else
		E = H.organs_by_name[selected_zone]
	if(!istype(E))
		activate_pin(3)
		return

	var/status = do_int_surgery(H)
	if(status && !(status == SURGERY_FAILURE || status == SURGERY_BLOCKED))
		organ = null
		var/atom/A = get_object()
		A.investigate_log("made some operation on ([H]) with [src].", INVESTIGATE_CIRCUIT)
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/medical/surgery_device/internal/do_int_surgery(mob/living/carbon/M)
	var/status = do_real_surgery(M, st, TRUE, organ)
	if(status != SURGERY_FAILED_STATE)
		return status
	return FALSE

/obj/item/integrated_circuit/medical/surgery_device/internal/can_use(mob/living/carbon/human/target, obj/item/organ/internal/organ, target_zone)
	if(operation_intent == SURGERY_ORGAN_INSERT)
		return st.can_use(src, target, target_zone, organ)
	else
		st.ignore_tool = TRUE
		st.preselected_organ = organ
		return st.can_use(src, target, target_zone, instrument)

/obj/item/integrated_circuit/medical/surgery_device/face
	name = "plastic surgery device"
	desc = "This device is a manipulator compatible with surgical instruments used for plastic surgery. While holding such an instrument, it can perform the facial reconstructing operation."
	extended_desc = "Takes a target ref to do operation, pulse activation pin, have a happy operation!"
	inputs = list("target"   = IC_PINTYPE_REF)
	surgery_items_type_list = list(
		/obj/item/scalpel,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
	)
	spawn_flags = IC_SPAWN_RESEARCH
	bodyparts_hint = FALSE

/obj/item/integrated_circuit/medical/surgery_device/face/do_work(ord)
	switch(ord)
		if(2)
			activate_pin(2)
		if(3)
			activate_pin(3)
	var/mob/living/carbon/human/H = get_pin_data(IC_INPUT, 1)
	selected_zone = BP_MOUTH

	var/status = do_int_surgery(H)
	if(status && !(status == SURGERY_FAILURE || status == SURGERY_BLOCKED))
		var/atom/A = get_object()
		A.investigate_log("made some operation on ([H]) with [src].", INVESTIGATE_CIRCUIT)
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/medical/med_scanner
	name = "integrated medical analyser"
	desc = "A miniaturized version of a common medical analyzer. This allows the machine to track some vital statistics."
	icon_state = "medscan"
	complexity = 4
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"brain activity" = IC_PINTYPE_BOOLEAN,
		"pulse" = IC_PINTYPE_NUMBER,
		"is conscious" = IC_PINTYPE_BOOLEAN
		)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/medical/med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		set_pin_data(IC_OUTPUT, 1, (brain && H.stat != DEAD))
		set_pin_data(IC_OUTPUT, 2, H.get_pulse_as_number())
		set_pin_data(IC_OUTPUT, 3, (H.stat == 0))

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/adv_med_scanner
	name = "integrated adv. medical analyser"
	desc = "A miniaturized version of an advanced medical analyzer. This allows the machine to know how healthy someone is. \
	This type is much more precise, allowing the machine to know much more about the target than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"brain activity"		= IC_PINTYPE_BOOLEAN,
		"is conscious"	        = IC_PINTYPE_BOOLEAN,
		"brute damage"			= IC_PINTYPE_NUMBER,
		"burn damage"			= IC_PINTYPE_NUMBER,
		"tox damage"			= IC_PINTYPE_NUMBER,
		"oxy damage"			= IC_PINTYPE_NUMBER,
		"clone damage"			= IC_PINTYPE_NUMBER,
		"pulse"                 = IC_PINTYPE_NUMBER,
		"oxygenation level"     = IC_PINTYPE_NUMBER,
		"pain level"            = IC_PINTYPE_NUMBER,
		"radiation"             = IC_PINTYPE_NUMBER,
		"name"                  = IC_PINTYPE_STRING,
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/adv_med_scanner/proc/damage_to_severity(value)
	if(value < 1)
		return 0
	if(value < 25)
		return 1
	if(value < 50)
		return 2
	if(value < 75)
		return 3
	if(value < 100)
		return 4
	return 5

/obj/item/integrated_circuit/medical/adv_med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H in view(get_turf(src))) // Like medbot's analyzer it can be used in range..
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		set_pin_data(IC_OUTPUT, 1, (brain && H.stat != DEAD))
		set_pin_data(IC_OUTPUT, 2, (H.stat == 0))
		set_pin_data(IC_OUTPUT, 3, damage_to_severity(100 * H.getBruteLoss() / H.maxHealth))
		set_pin_data(IC_OUTPUT, 4, damage_to_severity(100 * H.getFireLoss() / H.maxHealth))
		set_pin_data(IC_OUTPUT, 5, damage_to_severity(100 * H.getToxLoss() / H.maxHealth))
		set_pin_data(IC_OUTPUT, 6, damage_to_severity(100 * H.getOxyLoss() / H.maxHealth))
		set_pin_data(IC_OUTPUT, 7, damage_to_severity(100 * H.getCloneLoss() / H.maxHealth))
		set_pin_data(IC_OUTPUT, 8, H.get_pulse_as_number())
		set_pin_data(IC_OUTPUT, 9, H.get_blood_oxygenation())
		set_pin_data(IC_OUTPUT, 10, damage_to_severity(H.get_shock()))
		set_pin_data(IC_OUTPUT, 11, H.radiation)
		set_pin_data(IC_OUTPUT, 12, H.name)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/damaged_organs
	name = "X-Ray scanner"
	desc = "A miniaturized version of a stationary x-ray scanner, utilizing neural networks to precisely identify damaged internal organs."
	icon_state = "medscan_adv"
	complexity = 8
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list("damaged organs" = IC_PINTYPE_LIST)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/damaged_organs/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	var/list/obj/item/organ/internal/weakref_list = list()
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		for(var/obj/item/organ/internal/I in H.internal_organs)
			if(I?.damage > 0)
				weakref_list.Add(weakref(I))
	set_pin_data(IC_OUTPUT, 1, weakref_list)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/organ_info
	name = "X-ray organ analyzer"
	desc = "A miniaturized version of a stationary x-ray scanner, utilizing neural networks to receive information about internal organs inside a living (or not much living) body."
	icon_state = "medscan_adv"
	complexity = 8
	inputs = list("organ" = IC_PINTYPE_REF)
	outputs = list(
		"is necrotic"           = IC_PINTYPE_BOOLEAN,
		"is vital"              = IC_PINTYPE_BOOLEAN,
		"is rejecting"          = IC_PINTYPE_BOOLEAN,
		"is bruised"            = IC_PINTYPE_BOOLEAN,
		"is surface accessible" = IC_PINTYPE_BOOLEAN,
		"damage"                = IC_PINTYPE_NUMBER,
		"max damage"            = IC_PINTYPE_NUMBER,
		"bodypart location"     = IC_PINTYPE_STRING,
		"organ owner"           = IC_PINTYPE_REF,
		"name"                  = IC_PINTYPE_STRING
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/organ_info/do_work()
	var/obj/item/organ/internal/I = get_pin_data_as_type(IC_INPUT, 1, /obj/item/organ/internal)
	if(!istype(I)) // invalid input
		return
	var/mob/living/carbon/human/H = I.owner
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		set_pin_data(IC_OUTPUT, 1, I.status & ORGAN_DEAD)
		set_pin_data(IC_OUTPUT, 2, I.vital)
		set_pin_data(IC_OUTPUT, 3, I.rejecting)
		set_pin_data(IC_OUTPUT, 4, I.damage > I.min_bruised_damage)
		set_pin_data(IC_OUTPUT, 5, I.surface_accessible)
		set_pin_data(IC_OUTPUT, 6, I.damage)
		set_pin_data(IC_OUTPUT, 7, I.max_damage)
		set_pin_data(IC_OUTPUT, 8, I.parent_organ)
		set_pin_data(IC_OUTPUT, 9, weakref(H))
		set_pin_data(IC_OUTPUT, 10, H.name)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/bodypart_info
	name = "body part analyzer"
	desc = "A miniaturized version of a specific medical analyzer. It is capable of receiving detailed information about one's bodyparts. \
	This type is much more precise, allowing the machine to know much more about the target's bodypart than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 8
	inputs = list("target" = IC_PINTYPE_REF, "bodypart tag" = IC_PINTYPE_STRING)
	outputs = list(
		"name"                  = IC_PINTYPE_STRING,
		"damage"                = IC_PINTYPE_NUMBER,
		"max damage"            = IC_PINTYPE_NUMBER,
		"organ owner"           = IC_PINTYPE_REF,
		"is wounded"            = IC_PINTYPE_BOOLEAN,
		"is wound clamped"      = IC_PINTYPE_BOOLEAN,
		"has bones"             = IC_PINTYPE_BOOLEAN,
		"bones broken"          = IC_PINTYPE_BOOLEAN,
		"is wound open"         = IC_PINTYPE_BOOLEAN
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/bodypart_info/Initialize()
	. = ..()
	extended_desc += "The avaliable list of bodyparts: "
	extended_desc += jointext(BP_ALL_LIMBS, ", ")

/obj/item/integrated_circuit/medical/bodypart_info/do_work(ord)
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	var/selected_zone = get_pin_data(IC_INPUT, 2)
	if(!selected_zone)
		return
	var/obj/item/organ/external/E = H.organs_by_name[selected_zone]
	if(!istype(E)) // invalid input
		return
	if(H in view(get_turf(src))) // Like medbot's analyzer it can be used in range..
		var/datum/wound/cut/wound = E.get_incision()
		set_pin_data(IC_OUTPUT, 1, E.name)
		set_pin_data(IC_OUTPUT, 2, E.damage)
		set_pin_data(IC_OUTPUT, 3, E.max_damage)
		set_pin_data(IC_OUTPUT, 4, weakref(H))
		set_pin_data(IC_OUTPUT, 5, wound?.is_surgical())
		set_pin_data(IC_OUTPUT, 6, E.clamped())
		set_pin_data(IC_OUTPUT, 7, E.encased != null)
		set_pin_data(IC_OUTPUT, 8, E.open() == SURGERY_ENCASED)
		set_pin_data(IC_OUTPUT, 9, E.open() == SURGERY_RETRACTED)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/get_organs
	name = "Organ locator"
	desc = "A miniaturized version of a specific medical analyzer. It is capable of identifying internal organs contained in the target's body. \
	This type is much more precise, allowing the machine to know much more about the target's organs than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"eyes" = IC_PINTYPE_REF,
		"heart" = IC_PINTYPE_REF,
		"lungs" = IC_PINTYPE_REF,
		"brain" = IC_PINTYPE_REF,
		"liver" = IC_PINTYPE_REF,
		"kidneys" = IC_PINTYPE_REF,
		"stomach" = IC_PINTYPE_REF,
		"appendix" = IC_PINTYPE_REF,
		"cell" = IC_PINTYPE_REF,
		"neural lace" = IC_PINTYPE_REF
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/get_organs/do_work(ord)
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		set_pin_data(IC_OUTPUT, 1, H.internal_organs_by_name[BP_EYES])
		set_pin_data(IC_OUTPUT, 2, H.internal_organs_by_name[BP_HEART])
		set_pin_data(IC_OUTPUT, 3, H.internal_organs_by_name[BP_LUNGS])
		set_pin_data(IC_OUTPUT, 4, H.internal_organs_by_name[BP_BRAIN])
		set_pin_data(IC_OUTPUT, 5, H.internal_organs_by_name[BP_LIVER])
		set_pin_data(IC_OUTPUT, 6, H.internal_organs_by_name[BP_KIDNEYS])
		set_pin_data(IC_OUTPUT, 7, H.internal_organs_by_name[BP_STOMACH])
		set_pin_data(IC_OUTPUT, 8, H.internal_organs_by_name[BP_APPENDIX])
		set_pin_data(IC_OUTPUT, 9, H.internal_organs_by_name[BP_CELL])
		set_pin_data(IC_OUTPUT, 10, H.internal_organs_by_name[BP_STACK])

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/medical/refiller
	name = "Medical refiller"
	desc = "A device used to refill medical gel tubes and organ fixers' storage located inside or in direct reach of the circuit."
	complexity = 8
	inputs = list(
		"target" = IC_PINTYPE_REF,
		"source" = IC_PINTYPE_REF
	)
	outputs = list(
		"amount of gel left" = IC_PINTYPE_NUMBER
	)
	activators = list("refill" = IC_PINTYPE_PULSE_IN, "refilled" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/medical/refiller/do_work(ord)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/source = get_pin_data_as_type(IC_INPUT, 2, /obj)

	// Check for invalid input.
	if(!check_target(source) || !check_target(target))
		return

	if(istype(target, /obj/item/organfixer))
		var/obj/item/organfixer/OF = target
		if(istype(source, /obj/item/stack/medical/advanced/bruise_pack))
			var/obj/item/stack/medical/advanced/bruise_pack/OF2 = source
			OF.attackby(OF2, src)
		else if(istype(source, /obj/structure/geltank))
			var/obj/structure/geltank/G = source
			G.attackby(OF, src)
		else
			return
		set_pin_data(IC_OUTPUT, 1, OF.gel_amt)
	else if(istype(target, /obj/item/stack/medical/advanced))
		var/obj/item/stack/medical/advanced/A = target
		if(istype(source, /obj/item/stack/medical/advanced))
			var/obj/item/stack/medical/advanced/A2 = source
			A2.refill_from_same(A)
		else if(istype(source, /obj/structure/geltank))
			var/obj/structure/geltank/G = source
			G.attackby(A, src)
		else
			return
		set_pin_data(IC_OUTPUT, 1, A.amount)

	push_data()
	activate_pin(2)

#undef SURGERY_FAILURE
#undef SURGERY_BLOCKED
#undef SURGERY_ORGAN_REMOVE
#undef SURGERY_ORGAN_INSERT
#undef SURGERY_ORGAN_HEAL
#undef SURGERY_ORGAN_CONNECT
#undef SURGERY_ORGAN_DISCONNECT
#undef SURGERY_FAILED_STATE
#undef SURGERY_BONEGEL
#undef SURGERY_BONESET
#undef SURGERY_BONESET_ULTRA
#undef SURGERY_SAW
#undef SURGERY_RETRACTOR
#undef SURGERY_CAUTERY
#undef SURGERY_DRILL
