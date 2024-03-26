/datum/deity_form
	var/name = "God form"
	var/desc = "God form desc"
	var/form_state = ""
	var/list/buildables = list()
	var/list/phenomena = list()
	var/list/boons = list()

	var/list/buildables_radial = list()
	var/list/phenomena_radial = list()
	var/list/boons_radial = list()

	var/list/evolution_categories = list()

	var/join_message
	var/leave_message

	var/conversion_text

	var/mob/living/deity/deity

/datum/deity_form/proc/setup_form(mob/living/deity/D)
	deity = D
	//D.icon_state = form_state
	D.desc = desc
	D.invisibility = 0
	D.density = TRUE
	D.forceMove(get_turf(D.eyeobj))
	var/datum/hud/deity/deityhud = D.hud_used
	deityhud.update_resources(resources)

	for(var/path in buildables)
		var/datum/deity_power/power = new path
		buildables -= path
		buildables += power
		buildables[power] = power._get_image()

	for(var/path in phenomena)
		var/datum/deity_power/power = new path
		phenomena -= path
		phenomena += power
		phenomena[power] = power._get_image()

	for(var/path in boons)
		var/datum/deity_power/power = new path
		boons -= path
		boons += power
		boons[power] = power._get_image()

	for(var/path in evolution_categories)
		var/datum/evolution_package/evo = new path()
		evolution_categories -= path
		evolution_categories += evo

/// Followers can take charge using this proc, usually it damages them.
/datum/deity_form/proc/take_charge(mob/living/user, charge)
	return
