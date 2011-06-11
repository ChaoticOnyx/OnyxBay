
/client/var/afkSince = 0


/mob/verb/go_afk()
	if(client)
		client.afkSince = world.time


/mob/proc/is_afk()
	if(!client)
		return 1

	if(client.inactivity >= (60 * 10) * 5) // 5 minutes, probably needs adjustment, but good initial guess
		return 1

	if(client.afkSince)
		if((world.time - client.inactivity - 5) <= client.afkSince)
			return 1
		else
			client.afkSince = 0

	return 0
