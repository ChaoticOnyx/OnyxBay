#define LOCALIZATION_FOLDER "localization/"
#define LOCALIZATION_FALLBACKS list(\
    LANG_RU = LANG_EN\
)

#define LANG_EN "en"
#define LANG_RU "ru"
#define LANG_DEFAULT LANG_EN

#define TR_SET_CODE(args, code) args["code"] = code
#define TR_CALL(args) call(GLOB.fluent_dll, "get")(json_encode(args))
#define TR_DATA(id, code, args) list("id" = id, "code" = code, "args" = args)
#define TR(args) TR_CALL(args)

#define CODE_FROM_CLIENT(client) (GLOB.lang_to_code_mapping[client.get_preference_value(/datum/client_preference/language)] || LANG_DEFAULT)
#define CODE_FROM_MOB(mob) ((CODE_FROM_CLIENT(mob.client)) || LANG_DEFAULT)

GLOBAL_VAR_INIT(fluent_dll, null)
GLOBAL_LIST_INIT(lang_to_code_mapping, list(
    "English" = "en",
    "русский" = "ru"
))
