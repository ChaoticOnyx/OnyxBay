//as core click exists at the mob level
/mob/proc/trigger_aiming(trigger_type)
	return

/mob/living/trigger_aiming(trigger_type)
	if(!aimed.len)
		return
	for(var/obj/aiming_overlay/AO in aimed)
		if(AO.aiming_at == src)
			AO.update_aiming()
			if(AO.aiming_at == src)
				AO.trigger(trigger_type)
				AO.update_aiming_deferred()

/obj/aiming_overlay/proc/trigger(perm)
	if(!owner || !aiming_with || !aiming_at || !locked)
		return
	if(perm && (target_permissions & perm))
		return
	if(!owner.canClick())
		return
	owner.setClickCooldown(DEFAULT_QUICK_COOLDOWN) // Spam prevention, essentially.
	owner.visible_message("<span class='danger'>\The [owner] pulls the trigger reflexively!</span>")
	var/obj/item/gun/G = aiming_with
	if(istype(G))
		G.Fire(aiming_at, owner)
