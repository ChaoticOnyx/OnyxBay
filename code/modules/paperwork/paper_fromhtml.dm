/obj/item/weapon/paper/fromhtml
	var/html_path

/obj/item/weapon/paper/fromhtml/New()
	info = russian_to_utf8(file2text(html_path), prepare_to_browser = TRUE)

/obj/item/weapon/paper/fromhtml/tradelicense
	name = "NT Trade License"
	html_path = "resources/documents/trade_license.html"
	desc = "This is NT Trade License"
