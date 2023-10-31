//Brain Traumas are the new actual brain damage. Brain damage itself acts as a way to acquire traumas: every time brain damage is dealt, there's a chance of receiving a trauma.
//This chance gets higher the higher the mob's brainloss is. Removing traumas is a separate thing from removing brain damage: you can get restored to full brain operativity,
// but keep the quirks, until repaired by neurine, surgery, lobotomy or magic; depending on the resilience
// of the trauma.

/datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "A trauma caused by brain damage, which causes issues to the patient."
	var/scan_desc = "generic brain trauma" //description when detected by a health scanner
	var/mob/living/carbon/owner //the poor bastard
	var/obj/item/organ/internal/cerebrum/brain/brain //the poor bastard's brain
	var/gain_text = SPAN_NOTICE("You feel traumatized.")
	var/lose_text = SPAN_NOTICE("You no longer feel traumatized.")
	var/can_gain = TRUE
	var/random_gain = TRUE //can this be gained through random traumas?
	var/resilience = TRAUMA_RESILIENCE_BASIC //how hard is this to cure?

	/// Tracks abstract types of brain traumas, useful for determining traumas that should not exist
	var/abstract_type = /datum/brain_trauma

/datum/brain_trauma/Destroy()
	// Handles our references with our brain
	brain?.remove_trauma_from_traumas(src)
	if(owner)
		on_lose()
		owner = null
	return ..()

//Called on life ticks
/datum/brain_trauma/proc/on_life(seconds_per_tick, times_fired)
	return

//Called on death
/datum/brain_trauma/proc/on_death()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	if(gain_text)
		to_chat(owner, gain_text)
	register_signal(owner, SIGNAL_MOB_SAY, .proc/handle_speech)
	register_signal(owner, SIGNAL_MOVABLE_HEAR, .proc/handle_hearing)

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose(silent)
	if(!silent && lose_text)
		to_chat(owner, lose_text)
	unregister_signal(owner, SIGNAL_MOB_SAY)
	unregister_signal(owner, SIGNAL_MOVABLE_HEAR)

//Called when hearing a spoken message
/datum/brain_trauma/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	unregister_signal(owner, SIGNAL_MOVABLE_HEAR)

//Called when speaking
/datum/brain_trauma/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	unregister_signal(owner, SIGNAL_MOB_SAY)
