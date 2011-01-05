/proc/timestamp()
	return "([time2text(world.timeofday, "hh:mm:ss")])"

/proc/log_admin(text)
	check_diary()
	admin_log.Add(text)
	if (config.log_admin)
		diary << "[timestamp()]ADMIN: [text]"

/proc/log_game(text)
	check_diary()
	if (config.log_game)
		diary << "[timestamp()]GAME: [text]"
/proc/log_vote(text)
	check_diary()
	if (config.log_vote)
		diary << "[timestamp()]VOTE: [text]"
/proc/log_access(text)
	check_diary()
	if (config.log_access)
		diary << "[timestamp()]ACCESS: [text]"

/proc/log_say(text)
	check_diary()
	if (config.log_say)
		diary << "[timestamp()]SAY: [text]"


/proc/log_ooc(text)
	check_diary()
	if (config.log_ooc)
		diary << "[timestamp()]OOC: [text]"
		//FINDOOCLATER
/proc/log_whisper(text)
	check_diary()
	if (config.log_whisper)
		diary << "[timestamp()]WHISPER: [text]"

/proc/log_attack(text)
	check_diary()
	diary << "[timestamp()]ATTACK:[text]"
	message_admins(text)

/proc/check_diary()
	if (time2text(world.realtime, "YYYYMMDD") > current_date)
		diary << "---------------------"
		diary << "Day Ended, see next log"
		diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
		current_date = time2text(world.realtime, "YYYYMMDD")
		diary << "New Day, continuing from previous"
		diary << "---------------------"

/*
#define ACTION_MESSAGE 	"Message"
#define ACTION_ERROR	"Error"
#define ACTION_STARTUP	"Startup"
#define ACTION_SHUTDOWN "Shutdown"
#define ACTION_BAN		"Ban"
#define ACTION_KICK		"Kick"
#define ACTION_MUTE		"Mute"
#define ACTION_SAY		"Say"
#define ACTION_OOC "OOC"
#define ACTION_ATTACK "Attack"
#define ACTION_ADMIN "Admin"*/