/// Describes a point source of radiation.  Created either in response to a pulse of radiation, or over an irradiated atom.
/// Sources will decay over time, unless something is renewing their power!
/datum/radiation_source
	/// Location of the radiation source.
	var/atom/holder
	/// True for not affecting RAD_SHIELDED areas.
	var/respect_maint = FALSE
	/// True for power falloff with distance.
	var/flat = FALSE
	/// Cached maximum range, used for quick checks against mobs.
	var/range
	var/datum/radiation/info

/datum/radiation_source/New(datum/radiation/info, atom/holder = null)
	src.info = info
	src.holder = holder

	update_energy(info.energy)

/datum/radiation_source/Destroy()
	SSradiation.sources -= src
	holder = null
	. = ..()

/datum/radiation_source/proc/update_energy(new_energy = null)
	if(new_energy == null)
		return // No change
	else if(new_energy <= 0)
		qdel(src) // Decayed to nothing
	else
		info.energy = new_energy
		if(!flat)
			range = MAX_RADIATION_DIST

/datum/radiation_source/proc/travel(atom/target)
	var/datum/radiation/R = info.copy(GLOB.rad_instance)

	var/atom/source = flat ? get_turf(target) : holder
	R.travel(source, target)

	return R

/// Destroy self after specified time.
/datum/radiation_source/proc/schedule_decay(time)
	ASSERT(time > 0)

	addtimer(CALLBACK(src, .proc/Destroy), time, TIMER_UNIQUE)
