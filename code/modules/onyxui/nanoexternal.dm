 // This file contains all Nano procs/definitions for external classes/objects

 /**
  * Called when a Onyx UI window is closed
  * This is how Nano handles closed windows
  * It must be a verb so that it can be called using winset
  *
  * @return nothing
  */
/client/verb/onyxuiclose(uiref as text)
	set hidden = 1	// hide this verb from the user's panel
	set name = "onyxuiclose"

	var/datum/onyxui/ui = locate(uiref)

	if (istype(ui))
		ui.close()

		if(ui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)	// this will direct to the atom's Topic() proc via client.Topic()
		else if (ui.on_close_logic)
			// no atomref specified (or not found)
			// so just reset the user mob's machine var
			if(src && src.mob)
				src.mob.unset_machine()

 /**
  * The ui_interact proc is used to open and update Onyx UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/onyxui This parameter is passed by the onyxui process() proc when updating an open ui
  * @param force_open boolean Force the UI to (re)open, even if it's already open
  *
  * @return nothing
  */
/datum/proc/ui_interact(mob/user, ui_key = "main", datum/onyxui/ui = null, force_open = 1, datum/onyxui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	return

// Used by SSonyxui (/datum/controller/subsystem/processing/onyxui) to track UIs opened by this mob
/mob/var/list/open_uis
