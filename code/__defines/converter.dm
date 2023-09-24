#define TO_YAML(json) call_ext(GLOB.converter_dll, "to_yaml")(json)
#define FROM_YAML(yaml) json_decode(call_ext(GLOB.converter_dll, "from_yaml")(yaml))
#define TO_TOML(json) call_ext(GLOB.converter_dll, "to_toml")(json)
#define FROM_TOML(toml) json_decode(call_ext(GLOB.converter_dll, "from_toml")(toml))
