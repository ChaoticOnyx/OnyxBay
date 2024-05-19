/datum/deity_power/structure/devil_teleport

/datum/deity_power/phenomena/devils_ressurection
	expected_type = /atom/
	icon = 'icons/hud/actions.dmi'
	icon_state = "statue"
	manifest_on_select = TRUE
	anchored = TRUE

/datum/deity_power/phenomena/devils_ressurection/can_manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	var/datum/deity_form/devil/devil = D?.form
	if(!istype(devil))
		return FALSE

	if(devil.respawn_points <= 0)
		return FALSE

	return TRUE

/datum/deity_power/phenomena/devils_ressurection/manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	var/datum/deity_form/devil/devil = D.form
	var/choice = tgui_alert(D, "Your shell is dead. You have [devil.respawn_points] more chances. You may also choose to respawn later.", "Your shell is dead.", list("Respawn", "Cancel"))

	if(!choice || choice == "Wait")
		return

	devil.create_devils_shell(D)
	devil.respawn_points--
