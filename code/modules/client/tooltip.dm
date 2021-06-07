/client/var/tooltip_text = ""

/proc/update_tooltip(mob/user, text)
	if(user.client?.tooltip_text == text)
		return
	user.client.tooltip_text = text
	winset(user.client, "mapwindow.tooltip", "text=[url_encode(text)]&is-visible=[!!text]")
