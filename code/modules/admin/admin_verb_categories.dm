
var/list/admin_verb_categories = list(
	"Editing" = list(
		/client/proc/loadmap,
		/client/proc/loadmaphere,
		/client/proc/modifytemperature,
		/client/proc/SDQL_query,
		/client/proc/SDQL2_query,
		/client/proc/cmd_debug_del_all,
		/client/proc/cmd_modify_object_variables,
		/client/proc/cmd_modify_ticker_variables,
		/client/proc/cmd_admin_delete,
		/client/proc/cmd_admin_remove_plasma,
		/proc/togglebuildmode,
		/client/proc/CarbonCopy,
		/client/proc/debug_variables,
		/client/proc/callprocgen,
		/client/proc/callprocobj,
		/client/proc/qsowtoggle,
	),

	"Chat" = list(
		/client/proc/dsay,
		/client/proc/cmd_admin_say,
		/client/proc/cmd_admin_pm,
	),

	"Communication" = list(
		/client/proc/cmd_admin_subtle_message,
		/obj/admins/proc/announce,				//global announce
		/client/proc/cmd_admin_create_centcom_report,
		/client/proc/radioalert,
		/client/proc/general_report,
	),

	"Events" = list(
		/client/proc/Force_Event,
		/client/proc/zombify,
		/client/proc/cmd_admin_drop_everything,
		/client/proc/cmd_admin_rejuvenate,
		/client/proc/cmd_admin_robotize,
		/client/proc/cmd_admin_godmode,
		/client/proc/cmd_admin_alienize,
		/client/proc/cmd_admin_changelinginize,
		/client/proc/cmd_admin_add_freeform_ai_law,
		/client/proc/play_sound,
		/client/proc/createofficial,
		/client/proc/nanoshuttle,
		/client/proc/returnadminshuttle,
		/client/proc/cmd_admin_add_random_ai_law,
		/client/proc/givedisease,
		/client/proc/givedisease_deadly,
	),

	"Teleportation" = list(
		/client/proc/Getmob,
		/client/proc/Jump,
		/client/proc/jumptokey,
		/client/proc/jumptomob,
		/client/proc/jumptoturf,
		/client/proc/sendmob,
	),

	"You Probably Wouldn't Use These Anyway" = list(
		/client/proc/cmd_admin_gib_self,
		/client/proc/cmd_explode_turf,
		/client/proc/funbutton,
		/client/proc/clearmap,
	),

	"Punishment" = list(
		/client/proc/warn,
		/client/proc/jobban_panel,
		/obj/admins/proc/unprison,
		/client/proc/cmd_admin_prison,
		/client/proc/cmd_admin_mute,
	),

	"Toggle" = list(
		/obj/admins/proc/toggleAI,				//Toggle the AI
		/obj/admins/proc/toggleooc,				//toggle ooc
		/obj/admins/proc/toggleenter,			//Toggle enterting
		/client/proc/deadchat,					//toggles deadchat
		/client/proc/Debug2,					//debug toggle switch
		/obj/admins/proc/adjump,				//toggle admin jumping
		/obj/admins/proc/adrev,					//toggle admin revives
		/obj/admins/proc/adspawn,				//toggle admin item spawning
		/client/proc/toggleinvite,
		/client/proc/toggle_view_range,
		/client/proc/toggleadminsectordoors,
		/client/proc/toggleadminshuttledoors,
		/client/proc/toggleevents,
		/obj/admins/proc/toggletraitorscaling,
		/obj/admins/proc/voteres, 				//toggle votes
		/client/proc/hubvis,
		/obj/admins/proc/toggleaban,			//abandon mob
		/obj/admins/proc/toggle_aliens,
		/client/proc/cmd_debug_tog_aliens,
	),

	"Panels" = list(
		/client/proc/game_panel,
		/client/proc/unban_panel,
		/client/proc/invite_panel,
		/client/proc/player_panel,
		/client/proc/secrets,
	),

	"Other" = list(
		/obj/admins/proc/startnow,				//start now bitch
		/obj/admins/proc/immreboot,				//immediate reboot
		/obj/admins/proc/restart,				//restart
		/client/proc/hidemode,
		/obj/admins/proc/vmode,   				//start vote
		/obj/admins/proc/votekill, 				//abort vote
		/client/proc/delay,
		/client/proc/switchtowindow,
		/client/proc/checkticker,
		/client/proc/cmd_admin_check_contents,
		/client/proc/cmd_admin_reset_id,
		/client/proc/editappear,
		/client/proc/LSD_effect,
		/client/proc/addchange,
		/client/proc/fix_next_move,
		/proc/possess,
		/client/proc/Cell,
		/client/proc/cmd_admin_list_occ,
		/client/proc/get_admin_state,
		/client/proc/ticklag,
		/mob/living/proc/CheckHandcuff,
		/proc/release,
		/client/proc/stealth,
		/client/proc/admin_invis,
		/client/proc/admin_play,
		/client/proc/admin_observe,
		/client/proc/voting,
		/client/proc/ChangeMap,
		/client/proc/Zone_Info,
		/client/proc/testjson,
	),
)

//Still probably missing some. Probably need a bit more organization, too.
