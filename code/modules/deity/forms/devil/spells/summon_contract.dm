/datum/action/cooldown/spell/summon_contract
	name = "Summon Contract"
	desc = "Summon Contract"
	button_icon_state = "devil_contract"
	click_to_activate = TRUE

	cooldown_time = 1 MINUTE

	cast_range = 1
	var/instructions = "Server your master!"
	var/watchers_name = null
	var/static/list/power_prefabs = list(
		"Gluttony" = /datum/evolution_holder/gluttony,
		"Greed" = /datum/evolution_holder/greed,
		"Lust" = /datum/evolution_holder/lust,
		"Sloth" = /datum/evolution_holder/sloth,
		"Wrath" = /datum/evolution_holder/wrath,
	)

/datum/action/cooldown/spell/summon_contract/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/summon_contract/cast(mob/living/carbon/human/cast_on)
	var/mob/living/deity/deity = owner.mind?.deity
	ASSERT(deity)

	var/prefab = tgui_input_list(owner, "Select your client's sin.", "Summon Contract", power_prefabs)
	if(!prefab)
		return

	var/turf/target_turf = get_turf(cast_on)
	var/obj/item/paper/infernal_contract/contract = new /obj/item/paper/infernal_contract(target_turf, deity, prefab)
	cast_on.pick_or_drop(contract, target_turf)

/obj/item/paper/infernal_contract
	var/mob/living/deity/owner
	var/watchers_name
	var/prefab

/obj/item/paper/infernal_contract/attack_hand(mob/user)
	. = ..()
	watchers_name = user.name

/obj/item/paper/infernal_contract/Initialize(mapload, owner, prefab)
	. = ..()

	src.owner = owner
	src.prefab = prefab

	info += "<center><large><b>Договор продажи души</b></large></center>"
	info += "<small>Договор заключается между дьяволом и/или лицом, исполняющим его обязанности по генеральной доверенности (далее - представитель Аверно) и [watchers_name].<br>"
	info += "Дата заключения договора купли-продажи: [station_date]</small><br>."
	info += "<center><b>Условия договора:</center></b>"
	info += "1. Продавец не вправе вернуть свою душу после вступления настоящего договора в силу.<br>"
	info += "2. Продавец после вступления настоящего договора в силу уступает право на нанесение вреда представителю Аверно своим действием и/или бездействием.<br>"
	info += "2.1. В случае нарушения пункта 2 настоящего договора душа продавца может быть аннигилирована по усмотрению представителя Аверно.<br>"
	info += "3. Представитель Аверно обязан предоставить оплату незамедлительно после подписания настоящего договора.<br>"
	info += "Подпись продавца: <I><A href='?src=\ref[src];soulsale=$1'>подписывать здесь</A></I><br>"
	info += "<small>Настоящий договор может быть подписан любыми средствами для постановки знаков на бумагу, кровь не является обязательной.</small>"

/obj/item/paper/infernal_contract/Topic(href, href_list)
	if(href_list["soulsale"])
		var/mob/living/user = usr
		ASSERT(user)
		var/datum/deity_power/phenomena/conversion/convert_spell = locate(/datum/deity_power/phenomena/conversion) in owner.form.phenomena
		if(!convert_spell?.manifest(user, owner, prefab))
			return

		var/datum/deity_form/devil/devil_form = owner.form
		user.add_modifier(/datum/modifier/noattack, origin = owner, additional_params = devil_form.current_devil_shell)
		return qdel_self()

	return ..()
