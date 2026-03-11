/// Generates a subtype of `path` with the given flag appearance type and map-editor icon state.
#define FLAG_SUBTYPE(path, name, prefix, istate) \
path/##name {\
	flag_appearance_type = /datum/flag_appearance/##name;\
	icon_state = "bannerflag_" + #prefix + "_" + #istate;\
}

/// Generates all flag-related subtypes and the corresponding flag appearance datum.
#define FLAG_APPEARANCE_DEF(name, istate) \
FLAG_SUBTYPE(/obj/item/flagpole, name, table, istate)\
FLAG_SUBTYPE(/obj/item/flagpole/telescopic, name, pole, istate)\
FLAG_SUBTYPE(/obj/item/flagpole/telescopic/deployed, name, stem, istate)\
FLAG_SUBTYPE(/obj/item/flag, name, folded, istate)\
FLAG_SUBTYPE(/obj/structure/sign/flag, name, 21, istate)\
FLAG_SUBTYPE(/obj/structure/sign/flag/medium, name, 43, istate)\
FLAG_SUBTYPE(/obj/structure/sign/flag/large, name, great_64, istate)\
FLAG_SUBTYPE(/obj/structure/sign/flag/pennant, name, pennant, istate)\
/datum/flag_appearance/##name {\
	icon_state = #istate;\
}\
/datum/flag_appearance/##name

// Shorthand macro for attaching a preview element, specifically configured to preview flags.
#define ADD_FLAG_PREVIEW(icon_state) AddElement(/datum/element/preview, 'icons/obj/flags/flag_previews-128.dmi', "bannerflag_128_[icon_state]")
// Shorthand macro for detaching a preview element.
#define REMOVE_FLAG_PREVIEW RemoveElement(/datum/element/preview)
