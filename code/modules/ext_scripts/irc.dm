/proc/send2irc(channel, msg)
	export2irc(list(type="msg", mesg=msg, chan=channel, pwd=config.external.comms_password))

/proc/export2irc(params)
	if(config.external.use_irc_bot && config.external.irc_bot_host)
		spawn(-1) // spawn here prevents hanging in the case that the bot isn't reachable
			world.Export("http://[config.external.irc_bot_host]:45678?[list2params(params)]")

/proc/runtimes2irc(runtimes, revision)
	export2irc(list(pwd=config.external.comms_password, type="runtime", runtimes=runtimes, revision=revision))

/proc/send2mainirc(msg)
	if(config.external.main_irc)
		send2irc(config.external.main_irc, msg)
	return

/proc/send2adminirc(msg)
	if(config.external.admin_irc)
		send2irc(config.external.admin_irc, msg)
	return

/proc/adminmsg2adminirc(client/source, client/target, msg)
	if(config.external.admin_irc)
		var/list/params[0]

		params["pwd"] = config.external.comms_password
		params["chan"] = config.external.admin_irc
		params["msg"] = msg
		params["src_key"] = source.key
		params["src_char"] = source.mob.real_name || source.mob.name
		if(!target)
			params["type"] = "adminhelp"
		else if(istext(target))
			params["type"] = "ircpm"
			params["target"] = target
			params["rank"] = source.holder ? source.holder.rank : "Player"
		else
			params["type"] = "adminpm"
			params["trg_key"] = target.key
			params["trg_char"] = target.mob.real_name || target.mob.name

		export2irc(params)

/hook/startup/proc/ircNotify()
	send2mainirc("Server starting up on byond://[config.external.server_url ? config.external.server_url : (config.external.server ? config.external.server : "[world.address]:[world.port]")]")
	return 1
