#define ICON_CRASH_LOG(text...) log_crash(##text, __FILE__, __LINE__)
#define ICON_CRASH_LOG_TRACELESS(text...) log_crash(##text, __FILE__, __LINE__, FALSE)
