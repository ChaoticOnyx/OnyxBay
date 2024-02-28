GLOBAL_LIST_INIT(fsm_states, list(); for(var/state in subtypesof(/datum/state)) fsm_states.Add(list(initial(state["type"]) = new state));)

// An individual state
// On a directed graph, these would be the nodes themselves, connected to each other by unidirectional arrows.
/datum/state
	// Transition datum types, which get turned into refs to those types.
	// Note that the order DOES matter, as datums earlier in the list have higher priority
	// if more than one becomes 'open'.
	var/list/transitions = null

/datum/state/New()
	..()
	for(var/i in 1 to LAZYLEN(transitions))
		var/datum/state_transition/T = transitions[i]
		transitions[i] = new T()
		T = transitions[i]
		LAZYADD(T.from, src)

// Returns a list of transitions that a FSM could switch to.
// Note that `holder` is NOT the FSM, but instead the thing the FSM is attached to.
/datum/state/proc/get_open_transitions(datum/holder)
	for(var/datum/state_transition/T in transitions)
		if(T.is_open(holder))
			LAZYADD(., T)

// Stub for child states to modify the holder when switched to.
// Again, `holder` is not the FSM.
/datum/state/proc/entered_state(datum/holder)
	return

// Another stub for when leaving a state.
/datum/state/proc/exited_state(datum/holder)
	return
