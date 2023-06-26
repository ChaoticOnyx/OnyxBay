// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

// Mutable appearances erase template vars on new, because they accept an appearance to copy as an arg
// If we have nothin to copy, we set the float plane
/mutable_appearance/New(mutable_appearance/to_copy)
	..()
	if(!to_copy)
		plane = FLOAT_PLANE

/** Helper similar to image()
 *
 * icon - Our appearance's icon
 * icon_state - Our appearance's icon state
 * layer - Our appearance's layer
 * atom/offset_spokesman - An atom to use as reference for the z position of this appearance.
 * 	Only required if a plane is passed in. If this is not passed in we accept offset_const as a substitute
 * plane - The plane to use for the appearance. If this is not FLOAT_PLANE we require context for the offset to use
 * alpha - Our appearance's alpha
 * appearance_flags - Our appearance's appearance_flags
 * offset_const - A constant to offset our plane by, so it renders on the right "z layer"
**/
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, atom/offset_spokesman, plane = FLOAT_PLANE, alpha = 255, appearance_flags = 0, offset_const)
	var/mutable_appearance/appearance = new()
	appearance.icon = icon
	appearance.icon_state = icon_state
	appearance.layer = layer
	appearance.alpha = alpha
	appearance.appearance_flags |= appearance_flags
	if(plane != FLOAT_PLANE)
		// You need to pass in some non null object to reference
		if(isatom(offset_spokesman))
			appearance.plane = plane+offset_spokesman.plane
		else if(!isnull(offset_const))
			appearance.plane = plane+offset_const
		// otherwise if you're setting plane you better have the guts to back it up
		else
			CRASH("No plane offset passed in as context for a non floating mutable appearance, things are gonna go to hell on multiz maps")
	else if(!isnull(offset_spokesman) && !isatom(offset_spokesman))
		CRASH("Why did you pass in offset_spokesman as [offset_spokesman]? We need an atom to properly offset planes")

	return appearance
