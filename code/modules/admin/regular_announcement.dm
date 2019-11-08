#define REGULAR_ANNOUNCEMENT_SAFEFILE "data/regular_announcement.sav"

var/join_regular_announcement = null

/proc/load_regular_announcement()
	var/savefile/F = new(REGULAR_ANNOUNCEMENT_SAFEFILE)
	if ("text" in F)
		F["text"] >> join_regular_announcement

/client/proc/change_regular_announcement()
	set name = "Change Regular Announcement"
	set hidden = TRUE
	if (!check_rights(0))	
		return
	join_regular_announcement = input_cp1251(src, "Change Regular Announcement:", "Change Regular Announcement", join_regular_announcement, "message", TRUE)

	var/savefile/F = new(REGULAR_ANNOUNCEMENT_SAFEFILE)
	if (F)
		F["text"] << join_regular_announcement

/client/verb/show_regular_announcement()
	set name = "Show Regular Announcement"
	set hidden = TRUE

	if(join_regular_announcement)
		to_chat(src, "[join_regular_announcement]")

