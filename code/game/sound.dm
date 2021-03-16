//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define DIZZY 24
#define PSYCHOTIC 25

#define STANDARD_STATION STONEROOM
#define LARGE_ENCLOSED HANGAR
#define SMALL_ENCLOSED BATHROOM
#define TUNNEL_ENCLOSED CAVE
#define LARGE_SOFTFLOOR CARPETED_HALLWAY
#define MEDIUM_SOFTFLOOR LIVINGROOM
#define SMALL_SOFTFLOOR ROOM
#define ASTEROID CAVE
#define SPACE UNDERWATER

GLOBAL_LIST_INIT(far_shot_sound,list('sound/effects/weapons/gun/far_fire1.ogg','sound/effects/weapons/gun/far_fire2.ogg','sound/effects/weapons/gun/far_fire3.ogg'))

GLOBAL_LIST_INIT(f_cheavyb_sound,list('sound/effects/emotes/f_cheavyb1.ogg'))

GLOBAL_LIST_INIT(f_cough_sound,list('sound/effects/emotes/f_cough1.ogg','sound/effects/emotes/f_cough2.ogg','sound/effects/emotes/f_cough3.ogg',
									'sound/effects/emotes/f_cough4.ogg','sound/effects/emotes/f_cough5.ogg','sound/effects/emotes/f_cough6.ogg',
									'sound/effects/emotes/f_cough7.ogg'))

GLOBAL_LIST_INIT(f_sneeze_sound,list('sound/effects/emotes/f_sneeze1.ogg','sound/effects/emotes/f_sneeze2.ogg','sound/effects/emotes/f_sneeze3.ogg'))

GLOBAL_LIST_INIT(f_heavyb_sound,list('sound/effects/emotes/f_heavyb1.ogg','sound/effects/emotes/f_heavyb2.ogg','sound/effects/emotes/f_heavyb3.ogg',
									'sound/effects/emotes/f_heavyb4.ogg','sound/effects/emotes/f_heavyb5.ogg','sound/effects/emotes/f_heavyb6.ogg',
									'sound/effects/emotes/f_heavyb7.ogg','sound/effects/emotes/f_heavyb8.ogg','sound/effects/emotes/f_heavyb9.ogg'))

GLOBAL_LIST_INIT(f_pain_sound,list('sound/effects/emotes/f_pain1.ogg','sound/effects/emotes/f_pain2.ogg','sound/effects/emotes/f_pain3.ogg',
									'sound/effects/emotes/f_pain4.ogg','sound/effects/emotes/f_pain5.ogg','sound/effects/emotes/f_pain6.ogg',
									'sound/effects/emotes/f_pain7.ogg','sound/effects/emotes/f_pain8.ogg','sound/effects/emotes/f_pain9.ogg',
									'sound/effects/emotes/f_pain10.ogg','sound/effects/emotes/f_pain11.ogg','sound/effects/emotes/f_pain12.ogg',
									'sound/effects/emotes/f_pain13.ogg','sound/effects/emotes/f_pain14.ogg','sound/effects/emotes/f_pain15.ogg',
									'sound/effects/emotes/f_pain16.ogg','sound/effects/emotes/f_pain17.ogg','sound/effects/emotes/f_pain18.ogg'))

GLOBAL_LIST_INIT(f_long_scream_sound,list('sound/effects/emotes/f_long_scream1.ogg','sound/effects/emotes/f_long_scream2.ogg','sound/effects/emotes/f_long_scream3.ogg',
											'sound/effects/emotes/f_long_scream4.ogg','sound/effects/emotes/f_long_scream5.ogg','sound/effects/emotes/f_long_scream6.ogg',
											'sound/effects/emotes/f_long_scream7.ogg','sound/effects/emotes/f_long_scream8.ogg','sound/effects/emotes/f_long_scream9.ogg',
											'sound/effects/emotes/f_long_scream10.ogg','sound/effects/emotes/f_long_scream11.ogg','sound/effects/emotes/f_long_scream12.ogg',
											'sound/effects/emotes/f_long_scream13.ogg','sound/effects/emotes/f_long_scream14.ogg','sound/effects/emotes/f_long_scream15.ogg'))

GLOBAL_LIST_INIT(m_cheavyb_sound,list('sound/effects/emotes/m_cheavyb1.ogg','sound/effects/emotes/m_cheavyb2.ogg'))

GLOBAL_LIST_INIT(m_sneeze_sound,list('sound/effects/emotes/m_sneeze1.ogg'))

GLOBAL_LIST_INIT(m_cough_sound,list('sound/effects/emotes/m_cough1.ogg','sound/effects/emotes/m_cough2.ogg','sound/effects/emotes/m_cough3.ogg',
									'sound/effects/emotes/m_cough4.ogg','sound/effects/emotes/m_cough5.ogg','sound/effects/emotes/m_cough6.ogg',
									'sound/effects/emotes/m_cough7.ogg','sound/effects/emotes/m_cough8.ogg'))

GLOBAL_LIST_INIT(m_heavyb_sound,list('sound/effects/emotes/m_heavyb1.ogg','sound/effects/emotes/m_heavyb2.ogg','sound/effects/emotes/m_heavyb3.ogg',
									'sound/effects/emotes/m_heavyb4.ogg','sound/effects/emotes/m_heavyb5.ogg','sound/effects/emotes/m_heavyb6.ogg',
									'sound/effects/emotes/m_heavyb7.ogg','sound/effects/emotes/m_heavyb8.ogg','sound/effects/emotes/m_heavyb9.ogg',
									'sound/effects/emotes/m_heavyb10.ogg','sound/effects/emotes/m_heavyb11.ogg','sound/effects/emotes/m_heavyb12.ogg',
									'sound/effects/emotes/m_heavyb13.ogg','sound/effects/emotes/m_heavyb14.ogg'))

GLOBAL_LIST_INIT(m_pain_sound,list('sound/effects/emotes/m_pain1.ogg','sound/effects/emotes/m_pain2.ogg','sound/effects/emotes/m_pain3.ogg',
									'sound/effects/emotes/m_pain4.ogg','sound/effects/emotes/m_pain5.ogg','sound/effects/emotes/m_pain6.ogg',
									'sound/effects/emotes/m_pain7.ogg','sound/effects/emotes/m_pain8.ogg','sound/effects/emotes/m_pain9.ogg',
									'sound/effects/emotes/m_pain10.ogg','sound/effects/emotes/m_pain11.ogg','sound/effects/emotes/m_pain12.ogg',
									'sound/effects/emotes/m_pain13.ogg','sound/effects/emotes/m_pain14.ogg','sound/effects/emotes/m_pain15.ogg',
									'sound/effects/emotes/m_pain16.ogg','sound/effects/emotes/m_pain17.ogg','sound/effects/emotes/m_pain18.ogg',
									'sound/effects/emotes/m_pain19.ogg','sound/effects/emotes/m_pain20.ogg','sound/effects/emotes/m_pain21.ogg'))

GLOBAL_LIST_INIT(m_long_scream_sound,list('sound/effects/emotes/m_long_scream1.ogg','sound/effects/emotes/m_long_scream2.ogg','sound/effects/emotes/m_long_scream3.ogg',
											'sound/effects/emotes/m_long_scream4.ogg','sound/effects/emotes/m_long_scream5.ogg','sound/effects/emotes/m_long_scream6.ogg',
											'sound/effects/emotes/m_long_scream7.ogg','sound/effects/emotes/m_long_scream8.ogg','sound/effects/emotes/m_long_scream9.ogg',
											'sound/effects/emotes/m_long_scream10.ogg','sound/effects/emotes/m_long_scream11.ogg','sound/effects/emotes/m_long_scream12.ogg',
											'sound/effects/emotes/m_long_scream13.ogg','sound/effects/emotes/m_long_scream14.ogg'))

GLOBAL_LIST_INIT(global_ambient_sound,list('sound/ambience/global/amb1.ogg','sound/ambience/global/amb2.ogg','sound/ambience/global/amb3.ogg',
										'sound/ambience/global/amb4.ogg','sound/ambience/global/amb5.ogg','sound/ambience/global/amb6.ogg',
										'sound/ambience/global/amb7.ogg','sound/ambience/global/amb8.ogg','sound/ambience/global/amb9.ogg',
										'sound/ambience/global/amb10.ogg','sound/ambience/global/amb11.ogg','sound/ambience/global/amb12.ogg',
										'sound/ambience/global/amb13.ogg','sound/ambience/global/amb14.ogg'))

GLOBAL_LIST_INIT(science_ambient_sound,list('sound/ambience/science/amb1.ogg','sound/ambience/science/amb2.ogg','sound/ambience/science/amb3.ogg',
										'sound/ambience/science/amb4.ogg','sound/ambience/science/amb5.ogg','sound/ambience/science/amb6.ogg',
										'sound/ambience/science/amb7.ogg','sound/ambience/science/amb8.ogg','sound/ambience/science/amb9.ogg',
										'sound/ambience/science/amb10.ogg','sound/ambience/science/amb11.ogg','sound/ambience/science/amb12.ogg'))

GLOBAL_LIST_INIT(ai_ambient_sound,list('sound/ambience/ai/amb1.ogg','sound/ambience/ai/amb2.ogg','sound/ambience/ai/amb3.ogg',
										'sound/ambience/ai/amb4.ogg','sound/ambience/ai/amb5.ogg','sound/ambience/ai/amb6.ogg',
										'sound/ambience/ai/amb7.ogg','sound/ambience/ai/amb8.ogg','sound/ambience/ai/amb9.ogg',
										'sound/ambience/ai/amb10.ogg','sound/ambience/ai/amb12.ogg','sound/ambience/ai/amb13.ogg',
										'sound/ambience/ai/amb14.ogg','sound/ambience/ai/amb15.ogg','sound/ambience/ai/amb16.ogg',
										'sound/ambience/ai/amb17.ogg','sound/ambience/ai/amb18.ogg','sound/ambience/ai/amb19.ogg',
										'sound/ambience/ai/amb20.ogg','sound/ambience/ai/amb21.ogg','sound/ambience/ai/amb22.ogg',
										'sound/ambience/ai/amb23.ogg'))

GLOBAL_LIST_INIT(comms_ambient_sound, list('sound/ambience/comms/amb1.ogg','sound/ambience/comms/amb2.ogg','sound/ambience/comms/amb3.ogg',
										'sound/ambience/comms/amb4.ogg','sound/ambience/comms/amb5.ogg','sound/ambience/comms/amb6.ogg',
										'sound/ambience/comms/amb7.ogg','sound/ambience/comms/amb8.ogg','sound/ambience/comms/amb9.ogg',
										'sound/ambience/comms/amb10.ogg','sound/ambience/comms/amb12.ogg','sound/ambience/comms/amb13.ogg',
										'sound/ambience/comms/amb14.ogg','sound/ambience/comms/amb15.ogg','sound/ambience/comms/amb16.ogg',
										'sound/ambience/comms/amb17.ogg','sound/ambience/comms/amb18.ogg'))

GLOBAL_LIST_INIT(maintenance_ambient_sound,list('sound/ambience/maintenance/amb1.ogg','sound/ambience/maintenance/amb2.ogg','sound/ambience/maintenance/amb3.ogg',
												'sound/ambience/maintenance/amb4.ogg','sound/ambience/maintenance/amb5.ogg','sound/ambience/maintenance/amb6.ogg',
												'sound/ambience/maintenance/amb7.ogg','sound/ambience/maintenance/amb8.ogg','sound/ambience/maintenance/amb9.ogg',
												'sound/ambience/maintenance/amb10.ogg','sound/ambience/maintenance/amb12.ogg','sound/ambience/maintenance/amb13.ogg',
												'sound/ambience/maintenance/amb14.ogg',
												'sound/ambience/maintenance/amb17.ogg','sound/ambience/maintenance/amb18.ogg','sound/ambience/maintenance/amb19.ogg',
												'sound/ambience/maintenance/amb20.ogg','sound/ambience/maintenance/amb21.ogg','sound/ambience/maintenance/amb22.ogg',
												'sound/ambience/maintenance/amb23.ogg','sound/ambience/maintenance/amb24.ogg','sound/ambience/maintenance/amb25.ogg',
												'sound/ambience/maintenance/amb26.ogg','sound/ambience/maintenance/amb27.ogg','sound/ambience/maintenance/amb28.ogg',
												'sound/ambience/maintenance/amb29.ogg','sound/ambience/maintenance/amb30.ogg','sound/ambience/maintenance/amb31.ogg',
												'sound/ambience/maintenance/amb32.ogg','sound/ambience/maintenance/amb33.ogg','sound/ambience/maintenance/amb34.ogg',
												'sound/ambience/maintenance/amb35.ogg','sound/ambience/maintenance/amb36.ogg','sound/ambience/maintenance/amb37.ogg',
												'sound/ambience/maintenance/amb38.ogg','sound/ambience/maintenance/amb39.ogg','sound/ambience/maintenance/amb40.ogg',
												'sound/ambience/maintenance/amb42.ogg','sound/ambience/maintenance/amb43.ogg','sound/ambience/maintenance/amb44.ogg',
												'sound/ambience/maintenance/amb45.ogg','sound/ambience/maintenance/amb46.ogg','sound/ambience/maintenance/amb47.ogg',
												'sound/ambience/maintenance/amb48.ogg','sound/ambience/maintenance/amb49.ogg','sound/ambience/maintenance/amb50.ogg',
												'sound/ambience/maintenance/amb51.ogg'))

GLOBAL_LIST_INIT(engineering_ambient_sound,list('sound/ambience/engineering/amb1.ogg','sound/ambience/engineering/amb2.ogg','sound/ambience/engineering/amb3.ogg',
												'sound/ambience/engineering/amb4.ogg','sound/ambience/engineering/amb5.ogg','sound/ambience/engineering/amb6.ogg',
												'sound/ambience/engineering/amb7.ogg','sound/ambience/engineering/amb8.ogg','sound/ambience/engineering/amb9.ogg',
												'sound/ambience/engineering/amb10.ogg','sound/ambience/engineering/amb12.ogg','sound/ambience/engineering/amb13.ogg',
												'sound/ambience/engineering/amb14.ogg','sound/ambience/engineering/amb15.ogg','sound/ambience/engineering/amb16.ogg',
												'sound/ambience/engineering/amb17.ogg','sound/ambience/engineering/amb18.ogg','sound/ambience/engineering/amb19.ogg',
												'sound/ambience/engineering/amb20.ogg','sound/ambience/engineering/amb21.ogg','sound/ambience/engineering/amb22.ogg',
												'sound/ambience/engineering/amb23.ogg','sound/ambience/engineering/amb24.ogg','sound/ambience/engineering/amb25.ogg',
												'sound/ambience/engineering/amb26.ogg','sound/ambience/engineering/amb27.ogg','sound/ambience/engineering/amb28.ogg',
												'sound/ambience/engineering/amb29.ogg','sound/ambience/engineering/amb30.ogg','sound/ambience/engineering/amb31.ogg',
												'sound/ambience/engineering/amb32.ogg','sound/ambience/engineering/amb33.ogg','sound/ambience/engineering/amb34.ogg'))

GLOBAL_LIST_INIT(space_ambient_sound,list('sound/ambience/space/exterior1.ogg','sound/ambience/space/exterior2.ogg','sound/ambience/space/exterior3.ogg',
										'sound/ambience/space/exterior4.ogg','sound/ambience/space/exterior5.ogg','sound/ambience/space/exterior6.ogg',
										'sound/ambience/space/exterior7.ogg','sound/ambience/space/exterior8.ogg','sound/ambience/space/exterior9.ogg',
										'sound/ambience/space/exterior10.ogg','sound/ambience/space/exterior11.ogg','sound/ambience/space/exterior12.ogg',
										'sound/ambience/space/exterior13.ogg','sound/ambience/space/exterior14.ogg','sound/ambience/space/exterior15.ogg',
										'sound/ambience/space/exterior16.ogg','sound/ambience/space/exterior17.ogg','sound/ambience/space/exterior18.ogg',
										'sound/ambience/space/exterior19.ogg','sound/ambience/space/exterior20.ogg','sound/ambience/space/exterior21.ogg'))

GLOBAL_LIST_INIT(handcuffs_sound,list('sound/effects/using/cuffs/use1.ogg','sound/effects/using/cuffs/use2.ogg'))

GLOBAL_LIST_INIT(cable_hcuffs_sound,list('sound/effects/using/cuffs/cable_use1.ogg'))

GLOBAL_LIST_INIT(far_fire_sound,list('sound/effects/weapons/gun/far_fire1.ogg','sound/effects/weapons/gun/far_fire2.ogg','sound/effects/weapons/gun/far_fire3.ogg'))

GLOBAL_LIST_INIT(magazine_insert_sound,list('sound/effects/weapons/gun/magazine_insert1.ogg','sound/effects/weapons/gun/magazine_insert2.ogg','sound/effects/weapons/gun/magazine_insert3.ogg'))

GLOBAL_LIST_INIT(shell_insert_sound,list('sound/effects/weapons/gun/shell_insert1.ogg','sound/effects/weapons/gun/shell_insert2.ogg'))

GLOBAL_LIST_INIT(bullet_insert_sound,list('sound/effects/weapons/gun/bullet_insert1.ogg','sound/effects/weapons/gun/bullet_insert2.ogg','sound/effects/weapons/gun/bullet_insert3.ogg',
										'sound/effects/weapons/gun/bullet_insert4.ogg','sound/effects/weapons/gun/bullet_insert5.ogg','sound/effects/weapons/gun/bullet_insert6.ogg',
										'sound/effects/weapons/gun/bullet_insert7.ogg','sound/effects/weapons/gun/bullet_insert8.ogg','sound/effects/weapons/gun/bullet_insert9.ogg',
										'sound/effects/weapons/gun/bullet_insert10.ogg','sound/effects/weapons/gun/bullet_insert11.ogg'))

GLOBAL_LIST_INIT(shotgun_pump_in_sound,list('sound/effects/weapons/gun/shotgun_pump_in1.ogg','sound/effects/weapons/gun/shotgun_pump_in2.ogg'))
GLOBAL_LIST_INIT(shotgun_pump_out_sound,list('sound/effects/weapons/gun/shotgun_pump_out1.ogg','sound/effects/weapons/gun/shotgun_pump_out2.ogg','sound/effects/weapons/gun/shotgun_pump_out3.ogg'))

GLOBAL_LIST_INIT(fire_silent_sound,list('sound/effects/weapons/gun/fire_silent1.ogg','sound/effects/weapons/gun/fire_silent2.ogg','sound/effects/weapons/gun/fire_silent3.ogg',
										'sound/effects/weapons/gun/fire_silent4.ogg','sound/effects/weapons/gun/fire_silent5.ogg','sound/effects/weapons/gun/fire_silent6.ogg',
										'sound/effects/weapons/gun/fire_silent7.ogg'))

GLOBAL_LIST_INIT(casing_drop_sound,list('sound/effects/weapons/gun/casing_drop1.ogg','sound/effects/weapons/gun/casing_drop2.ogg','sound/effects/weapons/gun/casing_drop3.ogg',
										'sound/effects/weapons/gun/casing_drop4.ogg'))

GLOBAL_LIST_INIT(pull_body_sound,list('sound/effects/pulling/pull_body1.ogg','sound/effects/pulling/pull_body2.ogg','sound/effects/pulling/pull_body3.ogg',
									'sound/effects/pulling/pull_body4.ogg','sound/effects/pulling/pull_body5.ogg','sound/effects/pulling/pull_body6.ogg',
									'sound/effects/pulling/pull_body7.ogg','sound/effects/pulling/pull_body8.ogg','sound/effects/pulling/pull_body9.ogg'))

GLOBAL_LIST_INIT(pull_box_sound,list('sound/effects/pulling/pull_box1.ogg','sound/effects/pulling/pull_box2.ogg','sound/effects/pulling/pull_box3.ogg',
									'sound/effects/pulling/pull_box4.ogg','sound/effects/pulling/pull_box5.ogg','sound/effects/pulling/pull_box6.ogg',
									'sound/effects/pulling/pull_box7.ogg','sound/effects/pulling/pull_box8.ogg','sound/effects/pulling/pull_box9.ogg',
									'sound/effects/pulling/pull_box10.ogg','sound/effects/pulling/pull_box11.ogg','sound/effects/pulling/pull_box12.ogg',
									'sound/effects/pulling/pull_box13.ogg','sound/effects/pulling/pull_box14.ogg','sound/effects/pulling/pull_box15.ogg',
									'sound/effects/pulling/pull_box16.ogg','sound/effects/pulling/pull_box17.ogg','sound/effects/pulling/pull_box18.ogg',
									'sound/effects/pulling/pull_box19.ogg','sound/effects/pulling/pull_box20.ogg','sound/effects/pulling/pull_box21.ogg'))

GLOBAL_LIST_INIT(pull_closet_sound,list('sound/effects/pulling/pull_closet1.ogg','sound/effects/pulling/pull_closet2.ogg','sound/effects/pulling/pull_closet3.ogg',
										'sound/effects/pulling/pull_closet4.ogg','sound/effects/pulling/pull_closet5.ogg','sound/effects/pulling/pull_closet6.ogg'))

GLOBAL_LIST_INIT(pull_glass_sound,list('sound/effects/pulling/pull_glass1.ogg','sound/effects/pulling/pull_glass2.ogg','sound/effects/pulling/pull_glass3.ogg',
										'sound/effects/pulling/pull_glass4.ogg','sound/effects/pulling/pull_glass5.ogg','sound/effects/pulling/pull_glass6.ogg',
										'sound/effects/pulling/pull_glass7.ogg','sound/effects/pulling/pull_glass8.ogg','sound/effects/pulling/pull_glass9.ogg',
										'sound/effects/pulling/pull_glass10.ogg'))

GLOBAL_LIST_INIT(pull_machine_sound,list('sound/effects/pulling/pull_machine1.ogg','sound/effects/pulling/pull_machine2.ogg','sound/effects/pulling/pull_machine3.ogg',
										'sound/effects/pulling/pull_machine4.ogg','sound/effects/pulling/pull_machine5.ogg','sound/effects/pulling/pull_machine6.ogg',
										'sound/effects/pulling/pull_machine7.ogg','sound/effects/pulling/pull_machine8.ogg','sound/effects/pulling/pull_machine9.ogg'))

GLOBAL_LIST_INIT(pull_stone_sound,list('sound/effects/pulling/pull_stone1.ogg','sound/effects/pulling/pull_stone2.ogg','sound/effects/pulling/pull_stone3.ogg',
										'sound/effects/pulling/pull_stone4.ogg','sound/effects/pulling/pull_stone5.ogg','sound/effects/pulling/pull_stone6.ogg',
										'sound/effects/pulling/pull_stone7.ogg','sound/effects/pulling/pull_stone8.ogg','sound/effects/pulling/pull_stone9.ogg',
										'sound/effects/pulling/pull_stone10.ogg','sound/effects/pulling/pull_stone11.ogg','sound/effects/pulling/pull_stone12.ogg',
										'sound/effects/pulling/pull_stone13.ogg','sound/effects/pulling/pull_stone14.ogg','sound/effects/pulling/pull_stone15.ogg',
										'sound/effects/pulling/pull_stone16.ogg','sound/effects/pulling/pull_stone17.ogg','sound/effects/pulling/pull_stone18.ogg',
										'sound/effects/pulling/pull_stone19.ogg','sound/effects/pulling/pull_stone20.ogg','sound/effects/pulling/pull_stone21.ogg',
										'sound/effects/pulling/pull_stone22.ogg','sound/effects/pulling/pull_stone23.ogg','sound/effects/pulling/pull_stone24.ogg',
										'sound/effects/pulling/pull_stone25.ogg','sound/effects/pulling/pull_stone26.ogg','sound/effects/pulling/pull_stone27.ogg',
										'sound/effects/pulling/pull_stone28.ogg','sound/effects/pulling/pull_stone29.ogg','sound/effects/pulling/pull_stone30.ogg',
										'sound/effects/pulling/pull_stone31.ogg'))

GLOBAL_LIST_INIT(pull_wood_sound,list('sound/effects/pulling/pull_wood1.ogg','sound/effects/pulling/pull_wood2.ogg','sound/effects/pulling/pull_wood3.ogg',
										'sound/effects/pulling/pull_wood4.ogg','sound/effects/pulling/pull_wood5.ogg','sound/effects/pulling/pull_wood6.ogg',
										'sound/effects/pulling/pull_wood7.ogg','sound/effects/pulling/pull_wood8.ogg','sound/effects/pulling/pull_wood9.ogg',
										'sound/effects/pulling/pull_wood10.ogg','sound/effects/pulling/pull_wood11.ogg','sound/effects/pulling/pull_wood12.ogg',
										'sound/effects/pulling/pull_wood13.ogg','sound/effects/pulling/pull_wood14.ogg','sound/effects/pulling/pull_wood15.ogg',
										'sound/effects/pulling/pull_wood16.ogg','sound/effects/pulling/pull_wood17.ogg','sound/effects/pulling/pull_wood18.ogg',
										'sound/effects/pulling/pull_wood19.ogg','sound/effects/pulling/pull_wood20.ogg','sound/effects/pulling/pull_wood21.ogg',
										'sound/effects/pulling/pull_wood22.ogg','sound/effects/pulling/pull_wood23.ogg','sound/effects/pulling/pull_wood24.ogg',
										'sound/effects/pulling/pull_wood25.ogg','sound/effects/pulling/pull_wood26.ogg','sound/effects/pulling/pull_wood27.ogg',
										'sound/effects/pulling/pull_wood28.ogg','sound/effects/pulling/pull_wood29.ogg','sound/effects/pulling/pull_wood30.ogg',
										'sound/effects/pulling/pull_wood31.ogg','sound/effects/pulling/pull_wood32.ogg','sound/effects/pulling/pull_wood33.ogg',
										'sound/effects/pulling/pull_wood34.ogg','sound/effects/pulling/pull_wood35.ogg','sound/effects/pulling/pull_wood36.ogg',
										'sound/effects/pulling/pull_wood37.ogg'))

GLOBAL_LIST_INIT(drink_pickup_sound,list('sound/effects/using/bottles/pickup1.ogg','sound/effects/using/bottles/pickup2.ogg'))

GLOBAL_LIST_INIT(drink_sound,list('sound/effects/eating/drink1.ogg'))

GLOBAL_LIST_INIT(eat_sound,list('sound/effects/eating/eat1.ogg','sound/effects/eating/eat2.ogg','sound/effects/eating/eat3.ogg',
								'sound/effects/eating/eat4.ogg','sound/effects/eating/eat5.ogg'))

GLOBAL_LIST_INIT(closet_close_sound,list('sound/effects/using/closets/close1.ogg','sound/effects/using/closets/close2.ogg','sound/effects/using/closets/close3.ogg',
								'sound/effects/using/closets/close4.ogg','sound/effects/using/closets/close5.ogg','sound/effects/using/closets/close6.ogg',
								'sound/effects/using/closets/close7.ogg'))

GLOBAL_LIST_INIT(closet_open_sound,list('sound/effects/using/closets/open1.ogg','sound/effects/using/closets/open2.ogg','sound/effects/using/closets/open3.ogg',
				'sound/effects/using/closets/open4.ogg','sound/effects/using/closets/open5.ogg','sound/effects/using/closets/open6.ogg',
				'sound/effects/using/closets/open7.ogg'))

GLOBAL_LIST_INIT(disposal_sound,list('sound/effects/using/disposal/drop1.ogg','sound/effects/using/disposal/drop2.ogg','sound/effects/using/disposal/drop3.ogg',
									'sound/effects/using/disposal/drop4.ogg'))

GLOBAL_LIST_INIT(outfit_sound,list('sound/effects/using/outfit/use1.ogg','sound/effects/using/outfit/use2.ogg','sound/effects/using/outfit/use3.ogg',
								'sound/effects/using/outfit/use4.ogg','sound/effects/using/outfit/use5.ogg','sound/effects/using/outfit/use6.ogg',
								'sound/effects/using/outfit/use7.ogg','sound/effects/using/outfit/use8.ogg','sound/effects/using/outfit/use9.ogg',
								'sound/effects/using/outfit/use10.ogg','sound/effects/using/outfit/use11.ogg','sound/effects/using/outfit/use12.ogg',
								'sound/effects/using/outfit/use13.ogg','sound/effects/using/outfit/use14.ogg','sound/effects/using/outfit/use15.ogg',
								'sound/effects/using/outfit/use16.ogg','sound/effects/using/outfit/use17.ogg','sound/effects/using/outfit/use18.ogg',
								'sound/effects/using/outfit/use19.ogg','sound/effects/using/outfit/use20.ogg','sound/effects/using/outfit/use21.ogg',
								'sound/effects/using/outfit/use22.ogg','sound/effects/using/outfit/use23.ogg','sound/effects/using/outfit/use24.ogg',
								'sound/effects/using/outfit/use25.ogg','sound/effects/using/outfit/use26.ogg','sound/effects/using/outfit/use27.ogg',
								'sound/effects/using/outfit/use28.ogg','sound/effects/using/outfit/use29.ogg','sound/effects/using/outfit/use30.ogg',
								'sound/effects/using/outfit/use31.ogg','sound/effects/using/outfit/use32.ogg','sound/effects/using/outfit/use33.ogg',
								'sound/effects/using/outfit/use34.ogg','sound/effects/using/outfit/use35.ogg'))

GLOBAL_LIST_INIT(vent_sound,list('sound/effects/vent/vent1.ogg','sound/effects/vent/vent2.ogg','sound/effects/vent/vent3.ogg',
								'sound/effects/vent/vent4.ogg','sound/effects/vent/vent5.ogg','sound/effects/vent/vent6.ogg',
								'sound/effects/vent/vent7.ogg','sound/effects/vent/vent8.ogg','sound/effects/vent/vent9.ogg',
								'sound/effects/vent/vent10.ogg','sound/effects/vent/vent11.ogg','sound/effects/vent/vent12.ogg',
								'sound/effects/vent/vent13.ogg','sound/effects/vent/vent14.ogg','sound/effects/vent/vent15.ogg',
								'sound/effects/vent/vent16.ogg','sound/effects/vent/vent17.ogg','sound/effects/vent/vent18.ogg',
								'sound/effects/vent/vent19.ogg'))

GLOBAL_LIST_INIT(console_breaking_sound,list('sound/effects/breaking/console/break1.ogg','sound/effects/breaking/console/break2.ogg','sound/effects/breaking/console/break3.ogg'))

GLOBAL_LIST_INIT(window_breaking_sound,list('sound/effects/breaking/window/break1.ogg', 'sound/effects/breaking/window/break2.ogg', 'sound/effects/breaking/window/break3.ogg',
											'sound/effects/breaking/window/break4.ogg','sound/effects/breaking/window/break5.ogg','sound/effects/breaking/window/break6.ogg',
											'sound/effects/breaking/window/break7.ogg','sound/effects/breaking/window/break8.ogg','sound/effects/breaking/window/break9.ogg',
											'sound/effects/breaking/window/break10.ogg','sound/effects/breaking/window/break11.ogg','sound/effects/breaking/window/break12.ogg',
											'sound/effects/breaking/window/break13.ogg','sound/effects/breaking/window/break14.ogg','sound/effects/breaking/window/break15.ogg',
											'sound/effects/breaking/window/break16.ogg','sound/effects/breaking/window/break17.ogg','sound/effects/breaking/window/break18.ogg',
											'sound/effects/breaking/window/break19.ogg','sound/effects/breaking/window/break20.ogg','sound/effects/breaking/window/break21.ogg',
											'sound/effects/breaking/window/break22.ogg','sound/effects/breaking/window/break23.ogg'))

GLOBAL_LIST_INIT(glass_hit_sound,list('sound/effects/materials/glass/knock1.ogg', 'sound/effects/materials/glass/knock2.ogg', 'sound/effects/materials/glass/knock3.ogg',
										'sound/effects/materials/glass/knock4.ogg', 'sound/effects/materials/glass/knock5.ogg', 'sound/effects/materials/glass/knock6.ogg'))

GLOBAL_LIST_INIT(glass_knock_sound,list('sound/effects/materials/glass/glassknock.ogg'))
GLOBAL_LIST_INIT(electric_explosion_sound,list('sound/effects/explosions/electric1.ogg','sound/effects/explosions/electric2.ogg','sound/effects/explosions/electric3.ogg',
												'sound/effects/explosions/electric4.ogg','sound/effects/explosions/electric5.ogg','sound/effects/explosions/electric6.ogg',
												'sound/effects/explosions/electric7.ogg','sound/effects/explosions/electric8.ogg','sound/effects/explosions/electric9.ogg',
												'sound/effects/explosions/electric10.ogg','sound/effects/explosions/electric11.ogg'))

GLOBAL_LIST_INIT(explosion_sound,list('sound/effects/explosions/explosion1.ogg', 'sound/effects/explosions/explosion2.ogg', 'sound/effects/explosions/explosion3.ogg',
										'sound/effects/explosions/explosion4.ogg', 'sound/effects/explosions/explosion5.ogg', 'sound/effects/explosions/explosion6.ogg',
										'sound/effects/explosions/explosion7.ogg', 'sound/effects/explosions/explosion8.ogg', 'sound/effects/explosions/explosion9.ogg',
										'sound/effects/explosions/explosion10.ogg', 'sound/effects/explosions/explosion11.ogg', 'sound/effects/explosions/explosion12.ogg',
										'sound/effects/explosions/explosion13.ogg', 'sound/effects/explosions/explosion14.ogg', 'sound/effects/explosions/explosion15.ogg',
										'sound/effects/explosions/explosion16.ogg', 'sound/effects/explosions/explosion17.ogg', 'sound/effects/explosions/explosion18.ogg',
										'sound/effects/explosions/explosion19.ogg', 'sound/effects/explosions/explosion20.ogg', 'sound/effects/explosions/explosion21.ogg',
										'sound/effects/explosions/explosion22.ogg', 'sound/effects/explosions/explosion23.ogg', 'sound/effects/explosions/explosion24.ogg'))

GLOBAL_LIST_INIT(spark_small_sound,list('sound/effects/electric/small_spark1.ogg','sound/effects/electric/small_spark2.ogg','sound/effects/electric/small_spark3.ogg',
										'sound/effects/electric/small_spark4.ogg','sound/effects/electric/small_spark5.ogg','sound/effects/electric/small_spark6.ogg',
										'sound/effects/electric/small_spark7.ogg','sound/effects/electric/small_spark8.ogg'))

GLOBAL_LIST_INIT(spark_sound,list('sound/effects/electric/spark1.ogg','sound/effects/electric/spark2.ogg','sound/effects/electric/spark3.ogg',
									'sound/effects/electric/spark4.ogg','sound/effects/electric/spark5.ogg','sound/effects/electric/spark6.ogg',
									'sound/effects/electric/spark7.ogg'))

GLOBAL_LIST_INIT(spark_medium_sound,list('sound/effects/electric/medium_spark1.ogg','sound/effects/electric/medium_spark2.ogg'))

GLOBAL_LIST_INIT(spark_heavy_sound,list('sound/effects/electric/heavy_spark1.ogg','sound/effects/electric/heavy_spark2.ogg','sound/effects/electric/heavy_spark3.ogg',
									'sound/effects/electric/heavy_spark4.ogg'))

GLOBAL_LIST_INIT(searching_clothes_sound,list('sound/effects/using/clothing/use1.ogg','sound/effects/using/clothing/use2.ogg','sound/effects/using/clothing/use3.ogg',
												'sound/effects/using/clothing/use4.ogg','sound/effects/using/clothing/use5.ogg','sound/effects/using/clothing/use6.ogg'))

GLOBAL_LIST_INIT(searching_cabinet_sound,list('sound/effects/using/cabinet/use1.ogg','sound/effects/using/cabinet/use2.ogg','sound/effects/using/cabinet/use3.ogg',
												'sound/effects/using/cabinet/use4.ogg','sound/effects/using/cabinet/use5.ogg','sound/effects/using/cabinet/use6.ogg',
												'sound/effects/using/cabinet/use7.ogg','sound/effects/using/cabinet/use8.ogg','sound/effects/using/cabinet/use9.ogg',
												'sound/effects/using/cabinet/use10.ogg','sound/effects/using/cabinet/use11.ogg','sound/effects/using/cabinet/use12.ogg',
												'sound/effects/using/cabinet/use13.ogg'))

GLOBAL_LIST_INIT(searching_case_sound,list('sound/effects/using/case/use1.ogg','sound/effects/using/case/use2.ogg','sound/effects/using/case/use3.ogg',
											'sound/effects/using/case/use4.ogg','sound/effects/using/case/use5.ogg','sound/effects/using/case/use6.ogg',
											'sound/effects/using/case/use7.ogg','sound/effects/using/case/use8.ogg'))

GLOBAL_LIST_INIT(crunch_sound,list('sound/effects/fighting/crunch1.ogg','sound/effects/fighting/crunch2.ogg','sound/effects/fighting/crunch3.ogg',
									'sound/effects/fighting/crunch4.ogg','sound/effects/fighting/crunch5.ogg','sound/effects/fighting/crunch6.ogg',
									'sound/effects/fighting/crunch7.ogg','sound/effects/fighting/crunch8.ogg','sound/effects/fighting/crunch9.ogg',
									'sound/effects/fighting/crunch10.ogg','sound/effects/fighting/crunch11.ogg','sound/effects/fighting/crunch12.ogg'))

GLOBAL_LIST_INIT(gib_sound,list('sound/effects/fighting/gib1.ogg','sound/effects/fighting/gib2.ogg','sound/effects/fighting/gib3.ogg',
								'sound/effects/fighting/gib4.ogg','sound/effects/fighting/gib5.ogg','sound/effects/fighting/gib6.ogg',
								'sound/effects/fighting/gib7.ogg','sound/effects/fighting/gib8.ogg','sound/effects/fighting/gib9.ogg',
								'sound/effects/fighting/gib10.ogg'))

GLOBAL_LIST_INIT(punch_sound,list('sound/effects/fighting/punch1.ogg','sound/effects/fighting/punch2.ogg','sound/effects/fighting/punch3.ogg','sound/effects/fighting/punch4.ogg'))
GLOBAL_LIST_INIT(clown_sound,list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'))
GLOBAL_LIST_INIT(swing_hit_sound,list('sound/effects/fighting/genhit1.ogg', 'sound/effects/fighting/genhit2.ogg', 'sound/effects/fighting/genhit3.ogg'))

GLOBAL_LIST_INIT(hiss_sound,list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg'))
GLOBAL_LIST_INIT(page_sound,list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'))
GLOBAL_LIST_INIT(fracture_sound,list('sound/effects/bonebreak1.ogg','sound/effects/bonebreak2.ogg','sound/effects/bonebreak3.ogg','sound/effects/bonebreak4.ogg'))
GLOBAL_LIST_INIT(lighter_sound,list('sound/items/lighter1.ogg','sound/items/lighter2.ogg','sound/items/lighter3.ogg'))

GLOBAL_LIST_INIT(switch_small_sound,list('sound/effects/using/switch/small1.ogg','sound/effects/using/switch/small2.ogg'))

GLOBAL_LIST_INIT(switch_large_sound,list('sound/effects/using/switch/large1.ogg','sound/effects/using/switch/large2.ogg','sound/effects/using/switch/large3.ogg',
									'sound/effects/using/switch/large4.ogg'))

GLOBAL_LIST_INIT(button_sound,list('sound/machines/button1.ogg','sound/machines/button2.ogg','sound/machines/button3.ogg','sound/machines/button4.ogg'))
GLOBAL_LIST_INIT(chop_sound,list('sound/effects/fighting/chop1.ogg','sound/effects/fighting/chop2.ogg','sound/effects/fighting/chop3.ogg'))

GLOBAL_LIST_INIT(far_explosion_sound,list('sound/effects/explosions/far_explosion1.ogg', 'sound/effects/explosions/far_explosion2.ogg', 'sound/effects/explosions/far_explosion3.ogg',
										'sound/effects/explosions/far_explosion4.ogg', 'sound/effects/explosions/far_explosion5.ogg', 'sound/effects/explosions/far_explosion6.ogg',
										'sound/effects/explosions/far_explosion7.ogg', 'sound/effects/explosions/far_explosion8.ogg', 'sound/effects/explosions/far_explosion9.ogg',
										'sound/effects/explosions/far_explosion10.ogg', 'sound/effects/explosions/far_explosion11.ogg', 'sound/effects/explosions/far_explosion12.ogg',
										'sound/effects/explosions/far_explosion13.ogg', 'sound/effects/explosions/far_explosion14.ogg', 'sound/effects/explosions/far_explosion15.ogg',
										'sound/effects/explosions/far_explosion16.ogg', 'sound/effects/explosions/far_explosion17.ogg', 'sound/effects/explosions/far_explosion18.ogg',
										'sound/effects/explosions/far_explosion19.ogg', 'sound/effects/explosions/far_explosion20.ogg', 'sound/effects/explosions/far_explosion21.ogg',
										'sound/effects/explosions/far_explosion22.ogg', 'sound/effects/explosions/far_explosion23.ogg', 'sound/effects/explosions/far_explosion24.ogg',
										'sound/effects/explosions/far_explosion25.ogg', 'sound/effects/explosions/far_explosion26.ogg', 'sound/effects/explosions/far_explosion27.ogg',
										'sound/effects/explosions/far_explosion28.ogg', 'sound/effects/explosions/far_explosion29.ogg', 'sound/effects/explosions/far_explosion30.ogg',
										'sound/effects/explosions/far_explosion31.ogg', 'sound/effects/explosions/far_explosion32.ogg', 'sound/effects/explosions/far_explosion33.ogg',
										'sound/effects/explosions/far_explosion34.ogg', 'sound/effects/explosions/far_explosion35.ogg', 'sound/effects/explosions/far_explosion36.ogg',
										'sound/effects/explosions/far_explosion37.ogg', 'sound/effects/explosions/far_explosion38.ogg', 'sound/effects/explosions/far_explosion39.ogg',
										'sound/effects/explosions/far_explosion40.ogg', 'sound/effects/explosions/far_explosion41.ogg', 'sound/effects/explosions/far_explosion42.ogg',
										'sound/effects/explosions/far_explosion43.ogg', 'sound/effects/explosions/far_explosion44.ogg', 'sound/effects/explosions/far_explosion45.ogg',
										'sound/effects/explosions/far_explosion46.ogg', 'sound/effects/explosions/far_explosion47.ogg', 'sound/effects/explosions/far_explosion48.ogg',
										'sound/effects/explosions/far_explosion49.ogg', 'sound/effects/explosions/far_explosion50.ogg','sound/effects/explosions/far_explosion51.ogg',
										'sound/effects/explosions/far_explosion52.ogg','sound/effects/explosions/far_explosion53.ogg','sound/effects/explosions/far_explosion54.ogg',
										'sound/effects/explosions/far_explosion55.ogg','sound/effects/explosions/far_explosion56.ogg','sound/effects/explosions/far_explosion57.ogg',
										'sound/effects/explosions/far_explosion58.ogg','sound/effects/explosions/far_explosion59.ogg','sound/effects/explosions/far_explosion60.ogg',
										'sound/effects/explosions/far_explosion61.ogg','sound/effects/explosions/far_explosion62.ogg','sound/effects/explosions/far_explosion63.ogg',
										'sound/effects/explosions/far_explosion64.ogg','sound/effects/explosions/far_explosion65.ogg','sound/effects/explosions/far_explosion66.ogg',
										'sound/effects/explosions/far_explosion67.ogg','sound/effects/explosions/far_explosion68.ogg','sound/effects/explosions/far_explosion69.ogg',
										'sound/effects/explosions/far_explosion70.ogg','sound/effects/explosions/far_explosion71.ogg','sound/effects/explosions/far_explosion72.ogg',
										'sound/effects/explosions/far_explosion73.ogg','sound/effects/explosions/far_explosion74.ogg','sound/effects/explosions/far_explosion75.ogg',
										'sound/effects/explosions/far_explosion76.ogg','sound/effects/explosions/far_explosion77.ogg','sound/effects/explosions/far_explosion78.ogg',
										'sound/effects/explosions/far_explosion79.ogg'))
GLOBAL_LIST_INIT(chisel_sound,list('sound/weapons/chisel1.ogg','sound/weapons/chisel2.ogg','sound/weapons/chisel3.ogg',
								'sound/weapons/chisel4.ogg','sound/weapons/chisel5.ogg','sound/weapons/chisel6.ogg'))

GLOBAL_LIST_INIT(fuel_explosion_sound,list('sound/effects/explosions/fuel_explosion1.ogg','sound/effects/explosions/fuel_explosion2.ogg','sound/effects/explosions/fuel_explosion3.ogg',
											'sound/effects/explosions/fuel_explosion4.ogg','sound/effects/explosions/fuel_explosion5.ogg','sound/effects/explosions/fuel_explosion6.ogg'))

GLOBAL_LIST_INIT(device_trr_sound,list('sound/signals/trr1.ogg','sound/signals/trr2.ogg','sound/signals/trr3.ogg',
										'sound/signals/trr4.ogg','sound/signals/trr5.ogg','sound/signals/trr6.ogg',
										'sound/signals/trr7.ogg','sound/signals/trr8.ogg','sound/signals/trr9.ogg',
										'sound/signals/trr10.ogg','sound/signals/trr11.ogg','sound/signals/trr12.ogg',
										'sound/signals/trr13.ogg'))

GLOBAL_LIST_INIT(compbeep_sound,list('sound/effects/compbeep1.ogg','sound/effects/compbeep2.ogg','sound/effects/compbeep3.ogg',
									'sound/effects/compbeep4.ogg','sound/effects/compbeep5.ogg'))

GLOBAL_LIST_INIT(radio_sound,list('sound/signals/radio1.ogg','sound/signals/radio2.ogg','sound/signals/radio3.ogg',
									'sound/signals/radio4.ogg','sound/signals/radio5.ogg'))

GLOBAL_LIST_INIT(distant_movement_sound,list('sound/effects/footstep/distant/distant1.ogg','sound/effects/footstep/distant/distant2.ogg','sound/effects/footstep/distant/distant3.ogg',
											'sound/effects/footstep/distant/distant4.ogg','sound/effects/footstep/distant/distant5.ogg','sound/effects/footstep/distant/distant6.ogg',
											'sound/effects/footstep/distant/distant7.ogg','sound/effects/footstep/distant/distant8.ogg','sound/effects/footstep/distant/distant9.ogg',
											'sound/effects/footstep/distant/distant10.ogg','sound/effects/footstep/distant/distant11.ogg','sound/effects/footstep/distant/distant12.ogg',
											'sound/effects/footstep/distant/distant13.ogg','sound/effects/footstep/distant/distant14.ogg','sound/effects/footstep/distant/distant15.ogg',
											'sound/effects/footstep/distant/distant16.ogg','sound/effects/footstep/distant/distant17.ogg','sound/effects/footstep/distant/distant18.ogg',
											'sound/effects/footstep/distant/distant19.ogg','sound/effects/footstep/distant/distant20.ogg'))

GLOBAL_LIST_INIT(medical_beep_sound,list('sound/effects/machinery/medical/beep1.ogg','sound/effects/machinery/medical/beep2.ogg','sound/effects/machinery/medical/beep3.ogg',
										'sound/effects/machinery/medical/beep4.ogg','sound/effects/machinery/medical/beep5.ogg','sound/effects/machinery/medical/beep6.ogg'))

GLOBAL_LIST_INIT(outpost_ambient_sound,list('sound/ambience/outpost/amb1.ogg','sound/ambience/outpost/amb2.ogg','sound/ambience/outpost/amb3.ogg'))

GLOBAL_LIST_INIT(f_fall_alive_sound,list('sound/effects/damage/falling/f_fall_alive1.ogg','sound/effects/damage/falling/f_fall_alive2.ogg','sound/effects/damage/falling/f_fall_alive3.ogg',
										'sound/effects/damage/falling/f_fall_alive4.ogg','sound/effects/damage/falling/f_fall_alive5.ogg','sound/effects/damage/falling/f_fall_alive6.ogg',
										'sound/effects/damage/falling/f_fall_alive7.ogg','sound/effects/damage/falling/f_fall_alive8.ogg','sound/effects/damage/falling/f_fall_alive9.ogg',
										'sound/effects/damage/falling/f_fall_alive10.ogg','sound/effects/damage/falling/f_fall_alive11.ogg','sound/effects/damage/falling/f_fall_alive12.ogg',
										'sound/effects/damage/falling/f_fall_alive13.ogg','sound/effects/damage/falling/f_fall_alive14.ogg'))

GLOBAL_LIST_INIT(f_fall_dead_sound,list('sound/effects/damage/falling/f_fall_dead1.ogg','sound/effects/damage/falling/f_fall_dead2.ogg','sound/effects/damage/falling/f_fall_dead3.ogg',
										'sound/effects/damage/falling/f_fall_dead4.ogg','sound/effects/damage/falling/f_fall_dead5.ogg','sound/effects/damage/falling/f_fall_dead6.ogg',
										'sound/effects/damage/falling/f_fall_dead7.ogg','sound/effects/damage/falling/f_fall_dead8.ogg','sound/effects/damage/falling/f_fall_dead9.ogg',
										'sound/effects/damage/falling/f_fall_dead10.ogg','sound/effects/damage/falling/f_fall_dead11.ogg'))

GLOBAL_LIST_INIT(m_fall_alive_sound,list('sound/effects/damage/falling/m_fall_alive1.ogg','sound/effects/damage/falling/m_fall_alive2.ogg','sound/effects/damage/falling/m_fall_alive3.ogg',
										'sound/effects/damage/falling/m_fall_alive4.ogg','sound/effects/damage/falling/m_fall_alive5.ogg','sound/effects/damage/falling/m_fall_alive6.ogg',
										'sound/effects/damage/falling/m_fall_alive7.ogg','sound/effects/damage/falling/m_fall_alive8.ogg','sound/effects/damage/falling/m_fall_alive9.ogg',
										'sound/effects/damage/falling/m_fall_alive10.ogg','sound/effects/damage/falling/m_fall_alive11.ogg','sound/effects/damage/falling/m_fall_alive12.ogg',
										'sound/effects/damage/falling/m_fall_alive13.ogg','sound/effects/damage/falling/m_fall_alive14.ogg','sound/effects/damage/falling/m_fall_alive15.ogg',
										'sound/effects/damage/falling/m_fall_alive16.ogg','sound/effects/damage/falling/m_fall_alive17.ogg','sound/effects/damage/falling/m_fall_alive18.ogg',
										'sound/effects/damage/falling/m_fall_alive19.ogg','sound/effects/damage/falling/m_fall_alive20.ogg','sound/effects/damage/falling/m_fall_alive21.ogg',
										'sound/effects/damage/falling/m_fall_alive22.ogg'))

GLOBAL_LIST_INIT(m_fall_dead_sound,list('sound/effects/damage/falling/m_fall_dead1.ogg','sound/effects/damage/falling/m_fall_dead2.ogg','sound/effects/damage/falling/m_fall_dead3.ogg',
										'sound/effects/damage/falling/m_fall_dead4.ogg','sound/effects/damage/falling/m_fall_dead5.ogg','sound/effects/damage/falling/m_fall_dead6.ogg',
										'sound/effects/damage/falling/m_fall_dead7.ogg','sound/effects/damage/falling/m_fall_dead8.ogg','sound/effects/damage/falling/m_fall_dead9.ogg',
										'sound/effects/damage/falling/m_fall_dead10.ogg','sound/effects/damage/falling/m_fall_dead11.ogg'))

/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff, is_global, frequency, is_ambiance = 0)

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return
	frequency = vary && isnull(frequency) ? get_rand_frequency() : frequency // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in GLOB.player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= (world.view + extrarange) * 2)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z && (!is_ambiance || M.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES))
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, extrarange)

var/const/FALLOFF_SOUNDS = 0.5

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global, extrarange)
	if(!src.client || ear_deaf > 0)
		return
	var/sound/S = soundin
	if(!istype(S))
		soundin = get_sfx(soundin)
		S = sound(soundin)
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = vol
		S.environment = -1
		if(frequency)
			S.frequency = frequency
		else if (vary)
			S.frequency = get_rand_frequency()

	//sound volume falloff with pressure
	var/pressure_factor = 1.0

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - (world.view + extrarange), 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor

		if (S.volume <= 0)
			return	//no volume means no sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	if(!is_global)

		if(istype(src,/mob/living/))
			var/mob/living/carbon/M = src
			if (istype(M) && M.hallucination_power > 50 && M.chem_effects[CE_MIND] < 1)
				S.environment = PSYCHOTIC
			else if (M.druggy)
				S.environment = DRUGGED
			else if (M.drowsyness)
				S.environment = DIZZY
			else if (M.confused)
				S.environment = DIZZY
			else if (M.stat == UNCONSCIOUS)
				S.environment = UNDERWATER
			else if (pressure_factor < 0.5)
				S.environment = SPACE
			else
				var/area/A = get_area(src)
				S.environment = A.sound_env

		else if (pressure_factor < 0.5)
			S.environment = SPACE
		else if(!get_area(src) == null)
			var/area/A = get_area(src)
			S.environment = A.sound_env

	src << S

/client/proc/playtitlemusic()
	if(get_preference_value(/datum/client_preference/play_lobby_music) == GLOB.PREF_YES)
		GLOB.lobby_music.play_to(src)

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("far_fire")				soundin = pick(GLOB.far_fire_sound)
			if ("female_closed_breath")	soundin = pick(GLOB.f_cheavyb_sound)
			if ("female_cough")			soundin = pick(GLOB.f_cough_sound)
			if ("female_sneeze")		soundin = pick(GLOB.f_sneeze_sound)
			if ("female_breath")		soundin = pick(GLOB.f_heavyb_sound)
			if ("female_pain")			soundin = pick(GLOB.f_pain_sound)
			if ("female_long_scream")	soundin = pick(GLOB.f_long_scream_sound)
			if ("male_closed_breath")	soundin = pick(GLOB.m_cheavyb_sound)
			if ("male_cough")			soundin = pick(GLOB.m_cough_sound)
			if ("male_sneeze")			soundin = pick(GLOB.m_sneeze_sound)
			if ("male_breath")			soundin = pick(GLOB.m_heavyb_sound)
			if ("male_pain")			soundin = pick(GLOB.m_pain_sound)
			if ("male_long_scream")		soundin = pick(GLOB.m_long_scream_sound)
			if ("ai_ambient")			soundin = pick(GLOB.ai_ambient_sound)
			if ("comms_ambient")		soundin = pick(GLOB.comms_ambient_sound)
			if ("science_ambient")		soundin = pick(GLOB.science_ambient_sound)
			if ("maintenance_ambient")	soundin = pick(GLOB.maintenance_ambient_sound)
			if ("engineering_ambient")	soundin = pick(GLOB.engineering_ambient_sound)
			if ("global_ambient")		soundin = pick(GLOB.global_ambient_sound)
			if ("space_ambient")		soundin = pick(GLOB.space_ambient_sound)
			if ("handcuffs")			soundin = pick(GLOB.handcuffs_sound)
			if ("cable_handcuffs")		soundin = pick(GLOB.cable_hcuffs_sound)
			if ("far_fire")				soundin = pick(GLOB.far_fire_sound)
			if ("magazine_insert")		soundin = pick(GLOB.magazine_insert_sound)
			if ("shell_insert")			soundin = pick(GLOB.shell_insert_sound)
			if ("bullet_insert")		soundin = pick(GLOB.bullet_insert_sound)
			if ("shotgun_pump_in")		soundin = pick(GLOB.shotgun_pump_in_sound)
			if ("shotgun_pump_out")		soundin = pick(GLOB.shotgun_pump_out_sound)
			if ("fire_silent")			soundin = pick(GLOB.fire_silent_sound)
			if ("casing_drop")			soundin = pick(GLOB.casing_drop_sound)
			if ("pull_body")			soundin = pick(GLOB.pull_body_sound)
			if ("pull_box")				soundin = pick(GLOB.pull_box_sound)
			if ("pull_closet")			soundin = pick(GLOB.pull_closet_sound)
			if ("pull_glass")			soundin = pick(GLOB.pull_glass_sound)
			if ("pull_machine")			soundin = pick(GLOB.pull_machine_sound)
			if ("pull_stone")			soundin = pick(GLOB.pull_stone_sound)
			if ("pull_wood")			soundin = pick(GLOB.pull_wood_sound)
			if ("drink_pickup")			soundin = pick(GLOB.drink_pickup_sound)
			if ("eat")					soundin = pick(GLOB.eat_sound)
			if ("drink")				soundin = pick(GLOB.drink_sound)
			if ("closet_close")			soundin = pick(GLOB.closet_close_sound)
			if ("closet_open")			soundin = pick(GLOB.closet_open_sound)
			if ("disposal")				soundin = pick(GLOB.disposal_sound)
			if ("vent") 				soundin = pick(GLOB.vent_sound)
			if ("outfit")				soundin = pick(GLOB.outfit_sound)
			if ("console_breaking")		soundin = pick(GLOB.console_breaking_sound)
			if ("window_breaking") 		soundin = pick(GLOB.window_breaking_sound)
			if ("glass_hit") 			soundin = pick(GLOB.glass_hit_sound)
			if ("glass_knock")			soundin = pick(GLOB.glass_knock_sound)
			if ("electric_explosion")	soundin = pick(GLOB.electric_explosion_sound)
			if ("explosion") 			soundin = pick(GLOB.explosion_sound)
			if ("spark") 				soundin = pick(GLOB.spark_sound)
			if ("spark_medium") 		soundin = pick(GLOB.spark_medium_sound)
			if ("spark_heavy") 			soundin = pick(GLOB.spark_heavy_sound)
			if ("searching_clothes") 	soundin = pick(GLOB.searching_clothes_sound)
			if ("searching_cabinet") 	soundin = pick(GLOB.searching_cabinet_sound)
			if ("searching_case") 		soundin = pick(GLOB.searching_case_sound)
			if ("crunch")				soundin = pick(GLOB.crunch_sound)
			if ("gib")					soundin = pick(GLOB.gib_sound)
			if ("punch") 				soundin = pick(GLOB.punch_sound)
			if ("clownstep") 			soundin = pick(GLOB.clown_sound)
			if ("swing_hit") 			soundin = pick(GLOB.swing_hit_sound)
			if ("hiss") 				soundin = pick(GLOB.hiss_sound)
			if ("pageturn") 			soundin = pick(GLOB.page_sound)
			if ("fracture") 			soundin = pick(GLOB.fracture_sound)
			if ("light_bic") 			soundin = pick(GLOB.lighter_sound)
			if ("switch_small") 		soundin = pick(GLOB.switch_small_sound)
			if ("switch_large") 		soundin = pick(GLOB.switch_large_sound)
			if ("button") 				soundin = pick(GLOB.button_sound)
			if ("chop") 				soundin = pick(GLOB.chop_sound)
			if ("far_explosion") 		soundin = pick(GLOB.far_explosion_sound)
			if ("chisel")				soundin = pick(GLOB.chisel_sound)
			if ("fuel_explosion")		soundin = pick(GLOB.fuel_explosion_sound)
			if ("device_trr")			soundin = pick(GLOB.device_trr_sound)
			if ("compbeep")				soundin = pick(GLOB.compbeep_sound)
			if ("radio")				soundin = pick(GLOB.radio_sound)
			if ("distant_movement")		soundin = pick(GLOB.distant_movement_sound)
			if ("medical_beep")			soundin = pick(GLOB.medical_beep_sound)
			if ("outpost_ambient")		soundin = pick(GLOB.outpost_ambient_sound)
			if ("female_fall_alive")	soundin = pick(GLOB.f_fall_alive_sound)
			if ("female_fall_dead")		soundin = pick(GLOB.f_fall_dead_sound)
			if ("male_fall_alive")		soundin = pick(GLOB.m_fall_alive_sound)
			if ("male_fall_dead")		soundin = pick(GLOB.m_fall_dead_sound)
			else crash_with("Unknown sound: [soundin]")

	return soundin
