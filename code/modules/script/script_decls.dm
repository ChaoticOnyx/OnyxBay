/datum/script_func_decl
	var/name
	var/callback
	var/list/args
	var/dynamic_src
	var/return_type
	var/doc

/datum/script_func_decl/New(name, callback, args, dynamic_src, doc)
	ASSERT(name != null)
	ASSERT(callback != null)
	ASSERT(args != null)
	ASSERT(dynamic_src != null)

	src.name = name
	src.callback = callback
	src.args = args
	src.dynamic_src = dynamic_src
	src.return_type = "void"
	src.doc = doc || ""

/datum/script_var_decl
	var/name
	var/value
	var/cast
	var/doc

/datum/script_var_decl/New(name, value, cast, doc)
	ASSERT(name != null)
	ASSERT(cast != null)

	src.name = name
	src.value = value
	src.cast = cast
	src.doc = doc || ""

/datum/script_var_decl/proc/get_var_value()
	return value

/datum/script_define
	var/name
	var/value

/datum/script_define/New(name, value)
	ASSERT(name != null)

	src.name = name
	src.value = value

/datum/script_define/proc/get_define_value()
	return value

/datum/script_file
	var/name
	var/doc
	var/list/datum/script_func_decl/func_decls
	var/list/datum/script_var_decl/var_decls
	var/list/datum/script_define/defines

/datum/script_file/New(name, doc, func_decls, var_decls, defines)
	ASSERT(name != null)

	src.name = name
	src.doc = doc || ""
	src.func_decls = func_decls || list()
	src.var_decls = var_decls || list()
	src.defines = defines || list()

/datum/script_decls
	var/list/datum/script_func_decl/func_decls
	var/list/datum/script_var_decl/var_decls
	var/list/datum/script_file/files
	var/list/datum/script_define/defines

	var/list/__cached = null

/datum/script_decls/New()
	func_decls = list()
	var_decls = list()
	files = list()
	defines = list()

/datum/script_decls/proc/typing_to_string(typing)
	if(typing & Z_SCRIPT_TYPING_VARARGS)
		return "..."

	if(typing == Z_SCRIPT_TYPING_ANY || typing == 0)
		return "any"

	var/list/parts = list()
	if(typing & Z_SCRIPT_TYPING_NULL)
		parts += "null"

	if(typing & Z_SCRIPT_TYPING_INT)
		parts += "int"

	if(typing & Z_SCRIPT_TYPING_FLOAT)
		parts += "float"

	if(typing & Z_SCRIPT_TYPING_STRING)
		parts += "string"

	if(typing & Z_SCRIPT_TYPING_SYMBOL)
		parts += "symbol"

	if(typing & Z_SCRIPT_TYPING_OBJECT)
		parts += "object"

	if(typing & Z_SCRIPT_TYPING_ADDRESS)
		parts += "address"

	if(!parts.len)
		return "any"

	return jointext(parts, "|")

/datum/script_decls/proc/cast_to_string(cast)
	switch(cast)
		if(Z_SCRIPT_VAR_CAST_NONE)
			return "any"

		if(Z_SCRIPT_VAR_CAST_INT)
			return "int"

		if(Z_SCRIPT_VAR_CAST_SYMBOL)
			return "symbol"

		if(Z_SCRIPT_VAR_CAST_OBJECT)
			return "object"

		if(Z_SCRIPT_VAR_CAST_ADDRESS)
			return "address"

	return "any"

/datum/script_decls/proc/register_functions(datum/script/script, dst, list/included_files)
	for(var/datum/script_func_decl/decl in func_decls)
		var/list/typings = list()

		for(var/list/arg in decl.args)
			typings += arg["type"]

		script.register_function(decl.name, decl.callback, decl.dynamic_src ? null : dst, typings)

	for(var/datum/script_file/file in files)
		if(!(file.name in included_files))
			continue

		for(var/datum/script_func_decl/decl in file.func_decls)
			var/list/typings = list()

			for(var/list/arg in decl.args)
				typings += arg["type"]

			script.register_function(decl.name, decl.callback, decl.dynamic_src ? null : dst, typings)

/datum/script_decls/proc/register_vars(datum/script/script, list/included_files)
	for(var/datum/script_var_decl/decl in var_decls)
		script.set_var(decl.name, decl.get_var_value(), decl.cast)

	for(var/datum/script_file/file in files)
		if(!(file.name in included_files))
			continue

		for(var/datum/script_var_decl/decl in file.var_decls)
			script.set_var(decl.name, decl.get_var_value(), decl.cast)

/datum/script_decls/proc/generate_completions()
	if(__cached != null)
		return __cached

	var/list/data = list(
		"functions" = list(),
		"variables" = list(),
		"files" = list(),
		"defines" = list(),
	)

	for(var/datum/script_func_decl/decl in func_decls)
		data["functions"] += list(__func_decl_to_data(decl))

	for(var/datum/script_var_decl/decl in var_decls)
		data["variables"] += list(__var_decl_to_data(decl))

	for(var/datum/script_file/file in files)
		var/list/file_data = list(
			"name" = file.name,
			"doc" = file.doc,
			"functions" = list(),
			"variables" = list(),
			"defines" = list(),
		)

		for(var/datum/script_func_decl/decl in file.func_decls)
			file_data["functions"] += list(__func_decl_to_data(decl))

		for(var/datum/script_var_decl/decl in file.var_decls)
			file_data["variables"] += list(__var_decl_to_data(decl))

		for(var/datum/script_define/define in file.defines)
			var/list/define_data = list(
				"name" = define.name,
				"value" = define.get_define_value(),
			)

			file_data["defines"] += list(define_data)


		data["files"] += list(file_data)

	for(var/datum/script_define/define in defines)
		var/list/define_data = list(
			"name" = define.name,
			"value" = define.get_define_value(),
		)

		data["defines"] += list(define_data)

	__cached = data

	return data

/datum/script_decls/proc/__func_decl_to_data(datum/script_func_decl/decl)
	var/list/args_data = list()

	for(var/list/arg in decl.args)
		args_data += list(list(
			"name" = arg["name"],
			"type" = typing_to_string(arg["type"]),
			"doc" = arg["doc"] || "",
		))

	return list(
		"name" = decl.name,
		"args" = args_data,
		"returnType" = "void",
		"doc" = decl.doc,
	)

/datum/script_decls/proc/__var_decl_to_data(datum/script_var_decl/decl)
	return list(
		"name" = decl.name,
		"type" = cast_to_string(decl.cast),
		"doc" = decl.doc,
	)
