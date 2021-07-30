// These symbol in range of unicode's privae user area U+E000—U+F8FF.
// With these symbols we can add some semantics to any part of a message.
#define SYMBOL_CKEY_START "" // U+E000
#define SYMBOL_CKEY_END   "" // U+E001

#define SYMBOL_CHARACTER_NAME_START "" // U+E002
#define SYMBOL_CHARACTER_NAME_END   "" // U+E003

#define SYMBOL_COMPUTER_ID_START "" // U+E004
#define SYMBOL_COMPUTER_ID_END   "" // U+E005

#define SYMBOL_IP_START "" // U+E006
#define SYMBOL_IP_END   "" // U+E007

#define MARK_CKEY(ckey) SYMBOL_CKEY_START + ckey + SYMBOL_CKEY_END
#define MARK_CHARACTER_NAME(name) SYMBOL_CHARACTER_NAME_START + name + SYMBOL_CHARACTER_NAME_END
#define MARK_COMPUTER_ID(id) SYMBOL_COMPUTER_ID_START + id + SYMBOL_COMPUTER_ID_END
#define MARK_IP(ip) SYMBOL_IP_START + ip + SYMBOL_IP_END

#define REMOVE_PUA(message) var/static/regex/pua = new("\[\uE000-\uF8FF]", "g"); message = replacetext(message, pua, "");
