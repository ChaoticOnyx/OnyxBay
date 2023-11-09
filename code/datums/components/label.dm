/datum/component/label
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/label_name

/datum/component/label/Initialize(label_name)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.label_name = label_name
	apply_label()

/// Applies a label to the name of the parent in the format of: "parent_name (label)".
/datum/component/label/proc/apply_label()
	var/atom/owner = parent
	owner.name += " ([label_name])"
	owner.verbs += /atom/proc/RemoveLabel
	owner.post_attach_label(src)

/// Removes the label from the parent's name.
/datum/component/label/proc/remove_label()
	var/atom/owner = parent
	owner.name = replacetext(owner.name, "([label_name])", "")
	owner.name = trim(owner.name)
	owner.post_remove_label(src)
	qdel(src)

/atom/proc/RemoveLabel()
	set name = "Remove Label"
	set desc = "Used to remove labels"
	set category = "Object"
	set src in view(1)

	var/list/labels = list()

	for(var/datum/component/label/label in get_components(/datum/component/label))
		labels += list(label.label_name = label)

	var/target_label = input(usr, "Select a label to remove") in labels | null

	if(target_label && CanPhysicallyInteract(usr))
		var/datum/component/label/label = labels[target_label]
		usr.visible_message(SPAN("notice", "[usr] removes a label, '[target_label]', from \the [src]."),
			SPAN("notice", "You remove a label, '[target_label]', from \the [src]."))
		label.remove_label()

		if(!length(get_components(/datum/component/label)))
			verbs -= /atom/proc/RemoveLabel
