/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "Freezer"
	icon = 'Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1

	anchored = 1.0

	current_heat_capacity = 1000

	var/safety_off = 0
	var/maximum_temperature = T0C + 90
	var/safe_maximum_temperature = T0C + 90
	var/minimum_temperature = T0C - 200
	var/safe_minimum_temperature = T0C - 200

	New()
		..()
		initialize_directions = NORTH

	initialize()
		if(node) return

		var/node_connect = NORTH

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		update_icon()


	update_icon()
		if(src.node)
			if(src.on)
				icon_state = "freezer_1"
			else
				icon_state = "freezer"
		else
			icon_state = "freezer_0"
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.machine = src
		var/temp_text = ""
		if(air_contents.temperature > (T0C - 20))
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"

		var/dat = {"<B>Cryo gas cooling system</B><BR>
		Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current gas temperature: [temp_text]<BR>
		Current air pressure: [air_contents.return_pressure()]<BR>
		Target gas temperature: [safety_off?"<A href='?src=\ref[src];temp=min'>min</A> <A href='?src=\ref[src];temp=-100'>-</A>":"min -"] <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> [safety_off?"<A href='?src=\ref[src];temp=100'>+</A> <A href='?src=\ref[src];temp=max'>max</A>":"+ max"]<BR>
		[safety_off?"":"<A href='?src=\ref[src];safety-off=1'>disable safety limits</a><br>"]
		"}

		user << browse(dat, "window=freezer;size=400x500")
		onclose(user, "freezer")

	Topic(href, href_list)
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.machine = src
			if (href_list["start"])
				src.on = !src.on
				update_icon()

			if(href_list["temp"])
				var/old = current_temperature
				if(href_list["temp"] == "min")
					src.current_temperature = minimum_temperature
				else if(href_list["temp"] == "max")
					src.current_temperature = maximum_temperature
				else
					var/amount = text2num(href_list["temp"])
					if(amount > 0)
						src.current_temperature = min(maximum_temperature, src.current_temperature+amount)
					else
						src.current_temperature = max(minimum_temperature, src.current_temperature+amount)
				var/change = abs(old - current_temperature)

				if(change > 10)
					safety_off = safety_off //Avoid 'if statement has no effect'. Remove once real code is added
					//Todo: A chance of something bad happening here.

				if(current_temperature < safe_minimum_temperature || current_temperature > safe_maximum_temperature)
					safety_off = safety_off //Avoid 'if statement has no effect'. Remove once real code is added
					//Todo: Here, as well

			if(href_list["safety-off"])
				var/message =	"Warning! The limits are there for a reason, and bypassing them may damage the equipment. Without them, it is possible to change the temperature too quickly, or to values outside of the safe operating range, risking equipment damage.<br><br>"
				message +=		"<A href='?src=\ref[src];safety-off-confirm=1'>Disable limits</A> (Note: requires officer ID)"
				usr << browse(message, "window=freezerlimits")

			if(href_list["safety-off-confirm"])
				if(usr.has_access(list(access_heads)))
					safety_off = 1
					minimum_temperature = safe_minimum_temperature - 50
					maximum_temperature = safe_maximum_temperature + 50
					usr << browse(null, "window=freezerlimits")
				else
					var/message =	"Warning! The limits are there for a reason, and bypassing them may damage the equipment. Without them, it is possible to change the temperature too quickly, or to values outside of the safe operating range, risking equipment damage.<br><br>"
					message +=		"<A href='?src=\ref[src];safety-off-confirm=1'>Disable limits</A> (Note: requires officer ID)<br>"
					message +=		"<FONT COLOR=red>Inadequate ID!</FONT>"
					usr << browse(message, "window=freezerlimits")


		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return

	process()
		..()
		src.updateUsrDialog()