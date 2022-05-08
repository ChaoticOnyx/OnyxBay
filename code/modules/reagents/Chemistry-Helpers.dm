#define DRINK_ICON_FILE 'icons/obj/reagent_containers/glasses.dmi'
#define DRINK_COCKTAILICON_FILE 'icons/obj/reagent_containers/cocktails.dmi'

#define DRINK_FIZZ "fizz"
#define DRINK_ICE "ice"
#define DRINK_VAPOR "vapor"
#define DRINK_ICON_DEFAULT ""
#define DRINK_ICON_NOISY "_noise"

/atom/movable/proc/can_be_injected_by(atom/injector)
	if(!Adjacent(get_turf(injector)))
		return FALSE
	if(!reagents)
		return FALSE
	if(!reagents.get_free_space())
		return FALSE
	return TRUE

/obj/can_be_injected_by(atom/injector)
	return is_open_container() && ..()

/mob/living/can_be_injected_by(atom/injector)
	return ..() && (can_inject(null, 0, BP_CHEST) || can_inject(null, 0, BP_GROIN))
