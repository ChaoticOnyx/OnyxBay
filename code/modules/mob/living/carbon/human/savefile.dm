#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	2

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

/*datum/preferences/proc/savefile_save(mob/user)
	if (IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(src.savefile_path(user))

	F["version"] << SAVEFILE_VERSION_MAX

	F["real_name"] << src.real_name
	F["gender"] << src.gender
	F["age"] << src.age
	F["occupation_1"] << src.occupation1
	F["occupation_2"] << src.occupation2
	F["occupation_3"] << src.occupation3
	F["hair_red"] << src.r_hair
	F["hair_green"] << src.g_hair
	F["hair_blue"] << src.b_hair
	F["facial_red"] << src.r_facial
	F["facial_green"] << src.g_facial
	F["facial_blue"] << src.b_facial
	F["skin_tone"] << src.s_tone
	F["hair_style_name"] << src.h_style
	F["facial_style_name"] << src.f_style
	F["eyes_red"] << src.r_eyes
	F["eyes_green"] << src.g_eyes
	F["eyes_blue"] << src.b_eyes
	F["blood_type"] << src.b_type
	F["be_syndicate"] << src.be_syndicate
	F["underwear"] << src.underwear
	F["name_is_always_random"] << src.be_random_name
// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist
*/
datum/preferences/proc/savefile_load(mob/user, var/silent = 1)
	if (IsGuestKey(user.key))
		return 0
	var/DBQuery/xquery = dbcon.NewQuery("SELECT * FROM `players` WHERE ckey='[user.ckey]'")
	if(xquery.Execute())
		while(xquery.NextRow())
			var/list/column_data = xquery.GetRowData()
			src.real_name = column_data["real_name"]
			src.gender = column_data["gender"]
			src.occupation1 = column_data["occupation1"]
			src.occupation2 = column_data["occupation2"]
			src.occupation3 = column_data["occupation3"]
			src.r_hair = text2num(column_data["hair_red"])
			src.g_hair = text2num(column_data["hair_green"])
			src.b_hair = text2num(column_data["hair_blue"])
			src.age = text2num(column_data["ages"])
			src.r_facial = text2num(column_data["facial_red"])
			src.g_facial = text2num(column_data["facial_green"])
			src.b_facial = text2num(column_data["facial_blue"])
			src.s_tone = text2num(column_data["skin_tone"])
			src.h_style = column_data["hair_style_name"]
			src.f_style = column_data["facial_style_name"]
			src.r_eyes = text2num(column_data["eyes_red"])
			src.g_eyes = text2num(column_data["eyes_green"])
			src.b_eyes = text2num(column_data["eyes_blue"])
			src.b_type = column_data["blood_type"]
			src.be_syndicate = text2num(column_data["be_syndicate"])
			src.underwear = text2num(column_data["underwear"])
			src.be_random_name = text2num(column_data["name_is_always_random"])
			src << "Player Profile has been loaded"
			src << browse(null, "window=mob_occupation")
			return 1
	else
		//world.admin("[xquery.ErrorMsg()]")
		return 0
	return 1
	world.log << "Loaded Savefile for [user.ckey]"
	return 1