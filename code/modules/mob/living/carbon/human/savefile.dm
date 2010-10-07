#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	2

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

/*datum/preferences/proc/savefile_save(mob/user)
	if (IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(savefile_path(user))

	F["version"] << SAVEFILE_VERSION_MAX

	F["real_name"] << real_name
	F["gender"] << gender
	F["age"] << age
	F["occupation_1"] << occupation1
	F["occupation_2"] << occupation2
	F["occupation_3"] << occupation3
	F["hair_red"] << r_hair
	F["hair_green"] << g_hair
	F["hair_blue"] << b_hair
	F["facial_red"] << r_facial
	F["facial_green"] << g_facial
	F["facial_blue"] << b_facial
	F["skin_tone"] << s_tone
	F["hair_style_name"] << h_style
	F["facial_style_name"] << f_style
	F["eyes_red"] << r_eyes
	F["eyes_green"] << g_eyes
	F["eyes_blue"] << b_eyes
	F["blood_type"] << b_type
	F["be_syndicate"] << be_syndicate
	F["underwear"] << underwear
	F["name_is_always_random"] << be_random_name
// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist
*/
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
			src << "Player Profile has been loaded"
			src << browse(null, "window=mob_occupation")
			return 1
	else
		//world.admin("[xquery.ErrorMsg()]")
		return 0
	return 1
	world.log << "Loaded Savefile for [user.ckey]"
	return 1