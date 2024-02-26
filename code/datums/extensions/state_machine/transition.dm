// Used to connect `/datum/state`s together so the FSM knows what state to switch to, and on what conditions.
// On a directed graph, these would be the arrows connecting the nodes representing states.
/datum/state_transition
	var/list/from = null
	var/datum/state/target = null

// Called by one or more state decls acting as nodes in a directed graph.

// Tells the FSM if it should or should not be allowed to transfer to the target state.
/datum/state_transition/proc/is_open(datum/holder)
	return FALSE
