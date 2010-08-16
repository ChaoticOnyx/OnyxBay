/proc/log_admin(text)
	check_diary()
	admin_log.Add(text)
	if (config.log_admin)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])ADMIN: [text]"

/proc/log_game(text)
	check_diary()
	if (config.log_game)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])GAME: [text]"

/proc/log_vote(text)
	check_diary()
	if (config.log_vote)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])VOTE: [text]"

/proc/log_access(text)
	check_diary()
	if (config.log_access)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])ACCESS: [text]"

/proc/log_say(text)
	check_diary()
	if (config.log_say)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])SAY: [text]"

/proc/log_ooc(text)
	check_diary()
	if (config.log_ooc)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])OOC: [text]"

/proc/log_whisper(text)
	check_diary()
	if (config.log_whisper)
		diary << "([time2text(world.timeofday, "hh:mm:ss")])WHISPER: [text]"

/proc/log_attack(text)
	check_diary()
	diary << "([time2text(world.timeofday, "hh:mm:ss")])A:[text]"
	message_admins(text)

/proc/check_diary()
	if (time2text(world.realtime, "YYYYMMDD") > current_date)
		diary << "---------------------"
		diary << "Day Ended, see next log"
		diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
		current_date = time2text(world.realtime, "YYYYMMDD")
		diary << "New Day, continuing from previous"
		diary << "---------------------"