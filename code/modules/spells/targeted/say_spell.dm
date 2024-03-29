/datum/spell/targeted/say
	name = "Say something"
	desc = "Say a phrase."
	charge_max = 40
	spell_flags = INCLUDEUSER
	max_targets = 0
	cast_delay = 0
	icon_state = "heal_minor"

	var/list/messagevoice

/datum/spell/targeted/say/cast(list/targets, mob/user)
	var/mob/H = holder
	var/message = pick(messagevoice)
	H.say(message)
	playsound(H, messagevoice[message], 75, FALSE)
	charge_counter = 0

/datum/spell/targeted/say/cast_check(skipcharge = 0,mob/user = usr, list/targets)
	if(!src.check_charge(skipcharge, user)) //sees if we can cast based on charges alone
		return FALSE
	return TRUE

/datum/spell/targeted/say/standart_medbot
	name = "Say standart medbot"
	messagevoice = list("Зафиксирована ненадетая маска!" = 'sound/voice/medbot/radar.ogg', "Всегда есть подвох, и это лучшее, что есть." = 'sound/voice/medbot/catch.ogg', "Я знал это, мне следовало стать пластическим хирургом." = 'sound/voice/medbot/surgeon.ogg', "Это инфекционный отдел? Все падают, как мухи мертвые." = 'sound/voice/medbot/flies.ogg', "Восхитительно!" = 'sound/voice/medbot/delicious.ogg')

/datum/spell/targeted/say/target_medbot
	name = "Say someone medbot"
	messagevoice = list("Эй! Оставайся на месте, я уже иду." = 'sound/voice/medbot/coming.ogg', "Эй! Подожди, я уже иду!" = 'sound/voice/medbot/help.ogg', "Похоже, ты ранен!" = 'sound/voice/medbot/injured.ogg')
	icon_state = "heal_major"

/datum/spell/targeted/say/after_heal_medbot
	name = "Say heal medbot"
	messagevoice= list("Всё залатано!" = 'sound/voice/medbot/patchedup.ogg', "По яблоку в день, и врач понадобится не скоро." = 'sound/voice/medbot/apple.ogg', "Скорее поправляйся!" = 'sound/voice/medbot/feelbetter.ogg')
	icon_state = "heal_area"

/datum/spell/targeted/say/dead_pacient_medbot
	name = "Say bad medbot"
	messagevoice = list("Нет! НЕТ!" = 'sound/voice/medbot/no.ogg', "Живи, чёрт возьми! Живи!" = 'sound/voice/medbot/live.ogg', "Я... Я никогда раньше не терял пациента... За сегодня, я имею в виду." = 'sound/voice/medbot/lost.ogg')
	icon_state = "wiz_raiseundead"
