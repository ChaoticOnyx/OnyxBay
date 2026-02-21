/// A holder for simple behaviour that can be attached to many different types.
///
/// Only one element of each type is instanced during game init.
/// Otherwise acts basically like a lightweight component.
/datum/element
	/// Option flags for element behaviour.
	var/element_flags = 0

	/// The index of the first attach argument to consider for duplicate elements.
	/// Is only used when flags contains `ELEMENT_BESPOKE`.
	/// This is infinity so you must explicitly set this.
	var/id_arg_index = INFINITY

/// Activates the functionality defined by the element on the given target datum.
/datum/element/proc/attach(datum/target)
	SHOULD_CALL_PARENT(TRUE)

	if(type == /datum/element)
		return ELEMENT_INCOMPATIBLE

	SEND_SIGNAL(target, SIGNAL_ELEMENT_ATTACH, src)

	if(element_flags & ELEMENT_DETACH)
		register_signal(target, SIGNAL_QDELETING, nameof(.proc/on_target_delete), override = TRUE)

/datum/element/proc/on_target_delete(datum/source, force)
	detach(source)

/// Deactivates the functionality defines by the element on the given datum.
/datum/element/proc/detach(datum/source, ...)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(source, SIGNAL_ELEMENT_DETACH, src)
	unregister_signal(source, SIGNAL_QDELETING)

/datum/element/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE

	SSelements.elements_by_type -= type
	return ..()

/// Finds the singleton for the element type given and attaches it to src.
/datum/proc/_add_element(list/arguments)
	if(QDELING(src))
		CRASH("We just tried to add an element to a qdeleted datum, something is fucked")

	var/datum/element/ele = SSelements.GetElement(arguments)
	arguments[1] = src

	if(ele.attach(arglist(arguments)) == ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible [arguments[1]] assigned to a [type]! args: [json_encode(args)]")

/**
 * Finds the singleton for the element type given and detaches it from src.
 * You only need additional arguments beyond the type if you're using `ELEMENT_BESPOKE`.
 */
/datum/proc/_remove_element(list/arguments)
	var/datum/element/ele = SSelements.GetElement(arguments)

	if(ele.element_flags & ELEMENT_COMPLEX_DETACH)
		arguments[1] = src
		ele.detach(arglist(arguments))
	else
		ele.detach(src)
