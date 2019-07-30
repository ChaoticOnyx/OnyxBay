/client/verb/cmd_donations_panel()
	set name = "Donator Store"
	set desc = "Buy and receive items by donating."
	set category = "OOC"

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>Please wait until the game is set up!</span>")
		return

	GLOB.donations.ensure_init()

	if (!GLOB.donations.donators)
		to_chat(usr, "<span class='warning'>Cannot connect to the database!</span>")
		return

	if (!GLOB.donations.donators[src.ckey])
		// to_chat(usr, "<span class='warning'>You have not donated!</span>")
		var/datum/donator/D = new
		D.money = 0
		D.total = 0
		GLOB.donations.donators[src.ckey] = D
	GLOB.donations.donators[src.ckey].ui_interact(usr)