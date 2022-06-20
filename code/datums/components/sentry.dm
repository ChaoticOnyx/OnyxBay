/// A component to help react in optimized way on entering or/and exiting from/in an visible area.
/datum/component/sentry_view
	// The plan is to have the two type of turf lists:
	// - We can view
	// - We can not view
	// The first type of turfs free us from making "view" test for mobs there.
	// The second type is the turfs which can be visible some day (remember that the first type can be too).

	/// The turfs which we can see.
	var/list/turfs_in_view_range = list()
	/// The turfs which in range but we can't see for now.
	var/list/turfs_not_in_view_range = list()
	/// The range of the sentry.
	var/range = 0
	/// By default `source` is equals to `parent` but may be anything.
	var/source = null
	/// That will be called if watched thing enters the area. Arguments: `turf/new_turf, atom/thing, turf/old_turf`.
	var/on_entered = null
	/// That will be called if watched thing exits the area. Arguments: `turf/old_turf, atom/thing, turf/new_turf`.
	var/on_exited = null
	/// Everything in view (contains weakrefs).
	var/list/view = list()

/datum/component/sentry_view/Initialize(on_entered = null, on_exited = null, range = world.view, source = null)
	. = ..()

	src.on_entered = on_entered
	src.on_exited = on_exited
	src.range = range
	src.source = source || parent

	_recalculate_turfs()

/datum/component/sentry_view/proc/_unregister_all_turfs()
	for(var/turf/T in turfs_in_view_range)
		_unregister_visible_turf(T)

	for(var/turf/T in turfs_not_in_view_range)
		_unregister_not_visible_turf(T)

	turfs_in_view_range = list()
	turfs_not_in_view_range = list()

/datum/component/sentry_view/proc/_recalculate_turfs()
	_unregister_all_turfs()

	view = list()
	turfs_in_view_range = list()
	turfs_not_in_view_range = list()

	// Lummox says `view` has caching, anyway lets be sure).
	var/list/cached_view = view(range, source)

	for(var/A in range(range, source))
		var/turf/T = A

		if(istype(T))
			if(T in cached_view)
				_register_visible_turf(T)
				turfs_in_view_range += T
			else
				_register_not_visible_turf(T)
				turfs_not_in_view_range += T

		if(A in cached_view)
			view += weakref(A)

/datum/component/sentry_view/proc/_register_visible_turf(turf/T)
	register_signal(T, SIGNAL_ENTERED, .proc/_on_turf_entered)
	register_signal(T, SIGNAL_EXITED, .proc/_on_turf_exited)
	register_signal(T, SIGNAL_TURF_CHANGED, .proc/_turf_changed)
	register_signal(T, SIGNAL_OPACITY_SET, .proc/_turf_opacity_set)
	register_signal(T, SIGNAL_LIGHT_UPDATED, .proc/_light_updated)

/datum/component/sentry_view/proc/_register_not_visible_turf(turf/T)
	register_signal(T, SIGNAL_TURF_CHANGED, .proc/_turf_changed)
	register_signal(T, SIGNAL_OPACITY_SET, .proc/_turf_opacity_set)
	register_signal(T, SIGNAL_LIGHT_UPDATED, .proc/_light_updated)

/datum/component/sentry_view/proc/_unregister_visible_turf(turf/T)
	unregister_signal(T, SIGNAL_ENTERED)
	unregister_signal(T, SIGNAL_EXITED)
	unregister_signal(T, SIGNAL_TURF_CHANGED)
	unregister_signal(T, SIGNAL_OPACITY_SET)
	unregister_signal(T, SIGNAL_LIGHT_UPDATED)

/datum/component/sentry_view/proc/_unregister_not_visible_turf(turf/T)
	unregister_signal(T, SIGNAL_TURF_CHANGED)
	unregister_signal(T, SIGNAL_OPACITY_SET)
	unregister_signal(T, SIGNAL_LIGHT_UPDATED)

/datum/component/sentry_view/proc/_turf_changed(turf/T, old_density, density, old_opacity, opacity)
	if(old_opacity != opacity)
		_recalculate_turfs()

/datum/component/sentry_view/proc/_light_updated()
	_recalculate_turfs()

/datum/component/sentry_view/proc/_turf_opacity_set()
	_recalculate_turfs()

/datum/component/sentry_view/proc/_on_turf_entered(turf/new_turf, atom/enterer, turf/old_turf)
	if(!(old_turf in turfs_in_view_range))
		view += enterer

		if(!on_entered)
			return

		call(parent, on_entered)(new_turf, enterer, old_turf)

/datum/component/sentry_view/proc/_on_turf_exited(turf/old_turf, atom/exitee, turf/new_turf)
	if(!(new_turf in turfs_in_view_range))
		view -= exitee

		if(!on_exited)
			return

		call(parent, on_exited)(old_turf, exitee, new_turf)
