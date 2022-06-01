#define LAZY_GET(owner, value) (owner.value.is_dirty ? owner.value.calculate(owner) : owner.value.__value)
#define LAZY_SET_DIRTY(value) value.is_dirty = TRUE
