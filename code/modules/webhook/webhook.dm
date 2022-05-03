/proc/webhook_send_roundstatus(status, extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_asay(ckey, message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(ckey, message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("oocmessage", query)

/proc/webhook_send_me(ckey, message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("memessage", query)

/proc/webhook_send_ahelp(ckey, message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("ahelpmessage", query)

/proc/webhook_send_garbage(ckey, message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("garbage", query)

/proc/webhook_send_token(ckey, token)
	var/list/query = list("ckey" = ckey, "token" = token) //token is eng anyway
	webhook_send("token", query)

/proc/webhook_send(method, data)
	if(!config.external.webhook_address || !config.external.webhook_key)
		return
	var/query = "[config.external.webhook_address]?key=[config.external.webhook_key]&method=[method]&data=[url_encode(list2json(data))]"
	spawn(-1)
		world.Export(query)
