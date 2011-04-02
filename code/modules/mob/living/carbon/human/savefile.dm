#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	2

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

datum/preferences/proc/savefile_load(mob/user, var/silent = 1,var/slot = 1)
	if (IsGuestKey(user.key))
		return 0
	var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `players` WHERE ckey='[user.ckey]' AND slot='[slot]'")
	if(xquery.Execute())
		while(xquery.NextRow())
			var/list/column_data = xquery.GetRowData()
			real_name = column_data["real_name"]
			gender = column_data["gender"]
			occupation1 = column_data["occupation1"]
			occupation2 = column_data["occupation2"]
			occupation3 = column_data["occupation3"]
			r_hair = text2num(column_data["hair_red"])
			g_hair = text2num(column_data["hair_green"])
			b_hair = text2num(column_data["hair_blue"])
			age = text2num(column_data["ages"])
			r_facial = text2num(column_data["facial_red"])
			g_facial = text2num(column_data["facial_green"])
			b_facial = text2num(column_data["facial_blue"])
			s_tone = text2num(column_data["skin_tone"])
			h_style = column_data["hair_style_name"]
			f_style = column_data["facial_style_name"]
			r_eyes = text2num(column_data["eyes_red"])
			g_eyes = text2num(column_data["eyes_green"])
			b_eyes = text2num(column_data["eyes_blue"])
			b_type = column_data["blood_type"]
			be_syndicate = text2num(column_data["be_syndicate"])
			underwear = text2num(column_data["underwear"])
			be_random_name = text2num(column_data["name_is_always_random"])
			slotname = column_data["slotname"]
			bio = column_data["bios"]
			src << "Player Profile has been loaded"
			src << browse(null, "window=mob_occupation")
			return 1
	else
		//world.admin("[xquery.ErrorMsg()]")
		return 0
	return 1
	world.log << "Loaded Savefile for [user.ckey]"
	return 1