/datum/vote/New()
	nextvotetime = world.timeofday // + 10*config.vote_delay

/datum/vote/proc/canvote()//marker1
	var/excess = world.timeofday - vote.nextvotetime

	if(excess < -10000)		// handle clock-wrapping problems - very long delay (>20 hrs) if wrapped
		vote.nextvotetime = world.timeofday
		return 1
	return (excess >= 0)

/datum/vote/proc/nextwait()
	return timetext( round( (nextvotetime - world.timeofday)/10) )

/datum/vote/proc/endwait()
	return timetext( round( (votetime - world.timeofday)/10) )

/datum/vote/proc/timetext(var/interval)
	var/minutes = round(interval / 60)
	var/seconds = round(interval % 60)

	var/tmin = "[minutes>0?num2text(minutes)+"min":null]"
	var/tsec = "[seconds>0?num2text(seconds)+"sec":null]"

	if(tmin && tsec)				// hack to skip inter-space if either field is blank
		return "[tmin] [tsec]"
	else
		if(!tmin && !tsec)		// return '0sec' if 0 time left
			return "0sec"
		return "[tmin][tsec]"

/datum/vote/proc/getvotes()
	var/list/L = list()
	for(var/client/C)
		if(C.inactivity < 1200)		// clients inactive for 2 minutes don't count
			L[C.vote] += 1

	return L


/datum/vote/proc/endvote()

	if(delay_start == 1)
		world << "<B>The game will start soon.</B>"
		delay_start = 0

	if(!voting)		// means that voting was aborted by an admin
		return

	world << "\red <B>***Voting has closed.</B>"

	log_vote("Voting closed, result was [winner]")
	voting = 0


	for(var/client/C)		// clear vote window from all clients
		C.mob << browse(null, "window=vote")
		C.showvote = 0

	calcwin()

	if(mode == 2)
		var/wintext = capitalize(winner)
		world << "Result is [wintext]"
		for(var/md in vote.choices)
			vote.choices -= md
		return

	nextvotetime = world.timeofday + 10*config.vote_delay

	if(mode == 1)

		var/wintext = capitalize(winner)

		if(winner=="default")
			if(!ticker.hide_mode)
				world << "Result is \red No change."
			else
				world << "Result is \red Hidden."
			return

		// otherwise change mode

		if(!ticker.hide_mode)
			world << "Result is change to \red [wintext]"
		else
			world << "Result is \red Hidden."
		world.save_mode(winner)

		if(ticker.current_state != 1)
			world <<"\red <B>World will reboot in 10 seconds</B>"

			sleep(100 )
			log_game("Rebooting due to mode vote")
			world.Reboot()
		else
			master_mode = winner

	else

		if(winner=="default")
			world << "Result is \red No restart."
			return

		world << "Result is \red Restart round."

		world <<"\red <B>World will reboot in 5 seconds</B>"

		sleep(50 )
		log_game("Rebooting due to restart vote")
		world.Reboot()
	return


/datum/vote/proc/calcwin()

	var/list/votes = getvotes()

	if(vote.mode)
		var/best = -1

		for(var/v in votes)
			if(v=="none")
				continue
			if(best < votes[v])
				best = votes[v]


		var/list/winners = list()

		for(var/v in votes)
			if(votes[v] == best)
				winners += v

		var/ret = ""


		for(var/w in winners)
			if(lentext(ret) > 0)
				ret += "/"
			if(w=="default")
				winners = list("default")
				ret = "No change"
				break
			else
				ret += capitalize(w)


		if(winners.len != 1)
			ret = "Tie: " + ret


		if(winners.len == 0)
			vote.winner = "default"
			ret = "No change"
		else
			vote.winner = pick(winners)

		return ret
	else

		if(votes["No"] < votes["restart"])

			vote.winner = "restart"
			return "Restart"
		else
			vote.winner = "default"
			return "No restart"


/mob/verb/vote()
	set name = "Vote"
	usr.client.showvote = 1


	var/text = "<HTML><HEAD><TITLE>Voting</TITLE></HEAD><BODY scroll=no>"

	var/footer = "<HR><A href='?src=\ref[vote];voter=\ref[src];vclose=1'>Close</A></BODY></HTML>"


	if(config.vote_no_dead && usr.stat == 2)
		text += "Voting while dead has been disallowed."
		text += footer
		usr << browse(text, "window=vote")
		usr.client.showvote = 0
		usr.client.vote = "none"
		return

	if(vote.voting)
		// vote in progress

		if(vote.mode == 2)

			text += "A custom vote is in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"

			var/list/votes = vote.getvotes()

			text += "[vote.customname]"

			for(var/md in vote.choices)
				var/disp = capitalize(md)
				if(md=="default")
					disp = "No change"

				//world << "[md]|[disp]|[src.client.vote]|[votes[md]]"

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];voter=\ref[src];vote=[md]'>[disp]</A>"

				text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"

			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"

			text += footer

			usr << browse(text, "window=vote")

		else if(vote.mode == 1)		// true if changing mode

			text += "A vote to change the mode is in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"

			var/list/votes = vote.getvotes()
			if(!ticker.hide_mode)
				text += "Current game mode is: <B>[master_mode]</B>.<BR>Select the mode to change to:<UL>"
			else
				text += "<BR>Select the mode to change to:<UL>"

			for(var/md in config.votable_modes)
				var/disp = capitalize(md)
				if(md=="default")
					disp = "No change"

				//world << "[md]|[disp]|[src.client.vote]|[votes[md]]"

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];voter=\ref[src];vote=[md]'>[disp]</A>"
				if(!ticker.hide_mode)
					text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"
			if(!ticker.hide_mode)
				text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"
			else
				text +="<p>Current winner: <B>Poll results are secret</B><BR>"

			text += footer

			usr << browse(text, "window=vote")

		else	// voting to restart

			text += "A vote to restart is in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"

			var/list/votes = vote.getvotes()

			text += "Restart the world?<BR><UL>"

			var/list/VL = list("No","restart")

			for(var/md in VL)
				var/disp = (md=="No"? "No":"Yes")

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];voter=\ref[src];vote=[md]'>[disp]</A>"

				text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"

			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"

			text += footer

			usr << browse(text, "window=vote")


	else		//no vote in progress

		/*if(shuttlecoming == 1)
			usr << "\blue Cannot start Vote - Shuttle has been called."
			return*/

		if(!config.allow_vote_restart && !config.allow_vote_mode)
			text += "<P>Player voting is disabled.</BODY></HTML>"

			usr << browse(text, "window=vote")
			usr.client.showvote = 0
			return

		if(!vote.canvote())		// not time to vote yet
			if(config.allow_vote_restart) text+="Voting to restart is enabled.<BR>"
			if(config.allow_vote_mode) text+="Voting to change mode is enabled.<BR>"

			text+="<BR><P>Next vote can begin in [vote.nextwait()]."
			text+=footer

			usr << browse(text, "window=vote")

		else			// voting can begin
			if(config.allow_vote_restart)
				text += "<A href='?src=\ref[vote];voter=\ref[src];vmode=0'>Begin restart vote.</A><BR>"
			if(config.allow_vote_mode && ticker.current_state == 1) //stop people from starting game mode votes during rounds, since they always restart the game if there is a winner
				text += "<A href='?src=\ref[vote];voter=\ref[src];vmode=1'>Begin change mode vote.</A><BR>"
			if(src.client.holder)			//Strumpetplaya Add - Custom Votes for Admins
				text += "<A href='?src=\ref[vote];voter=\ref[src];vmode=2'>Begin custom vote.</A><BR>"
			text += footer
			usr << browse(text, "window=vote")

	spawn(20 )
		if(usr.client && usr.client.showvote && !vote.enteringchoices)
			usr.vote()
		else
			usr << browse(null, "window=vote")

		return


/datum/vote/Topic(href, href_list)
	..()

	var/mob/M = locate(href_list["voter"])			// mob of player that clicked link

	if(href_list["vclose"])							// close the voting window
		if(M)
			M << browse(null, "window=vote")
			M.client.showvote = 0
		return

	if(href_list["vmode"])							// begin a new vote
		if(vote.voting)
			return

		vote.mode = text2num(href_list["vmode"])

		if(vote.mode == 2)
			vote.enteringchoices = 1
			vote.voting = 1
			vote.customname = input(usr, "What are you voting for?", "Custom Vote") as text
			if(!vote.customname)
				vote.enteringchoices = 0
				vote.voting = 0
				return

			var/N = input(usr, "How many options does this vote have?", "Custom Vote", 0) as num
			if(!N)
				vote.enteringchoices = 0
				vote.voting = 0
				return
			//world << "You're voting for [N] options!"
			var/i
			for(i=1; i<=N; i++)
				var/addvote = input(usr, "What is option #[i]?", "Enter Option #[i]") as text
				vote.choices += addvote
			//for(var/O in vote.choices)
				//world << "[O]"
			vote.enteringchoices = 0
			vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

			spawn(config.vote_period * 10)
				vote.endvote()

			world << "\red<B>*** A custom vote has been initiated by [M.key].</B>"
			world << "\red     You have [vote.timetext(config.vote_period)] to vote."

			//log_vote("Voting to [vote.mode ? "change mode" : "restart round"] started by [M.name]/[M.key]")

			for(var/client/C)
				if(config.vote_no_default || (config.vote_no_dead && C.mob.stat == 2))
					C.vote = "none"
				else
					C.vote = "default"

			if(M) M.vote()
			return


		if(!ticker && vote.mode == 1)
			if(delay_start == 0)
				world << "<B>The game start has been delayed.</B>"
				delay_start = 1

		vote.voting = 1						// now voting
		vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

		spawn(config.vote_period * 10)
			vote.endvote()

		world << "\red<B>*** A vote to [vote.mode?"change game mode":"restart"] has been initiated by [M.key].</B>"
		world << "\red     You have [vote.timetext(config.vote_period)] to vote."

		log_vote("Voting to [vote.mode ? "change mode" : "restart round"] started by [M.name]/[M.key]")

		for(var/client/C)
			if(config.vote_no_default || (config.vote_no_dead && C.mob.stat == 2))
				C.vote = "none"
			else
				C.vote = "default"

		if(M)
			M.vote()

		return

	if(href_list["vote"] && vote.voting)
		if(M && M.client)
			M.client.vote = href_list["vote"]

			M.vote()
		return


/client/proc/cmd_admin_custom_vote(mob/M as mob in world)
	set category = "Admin"
	set name = "Custom Vote"
