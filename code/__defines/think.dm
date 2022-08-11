#define THINKER_GROUPS 5
#define ASSIGN_THINK_GROUP(group, time)          \
	if(time <= world.time + 1 SECONDS) {         \
		group = 1;                               \
	} else if(time <= world.time + 3 SECONDS) {  \
		group = 2;                               \
	} else if(time <= world.time + 5 SECONDS) {  \
		group = 3;                               \
	} else if(time <= world.time + 10 SECONDS) { \
		group = 4;                               \
	} else {                                     \
		group = 5;                               \
	}

#define CALC_NEXT_GROUP_RUN(ctx)                                                                   \
	if(SSthink.next_group_run[ctx.group] == 0) {                                                   \
		SSthink.next_group_run[ctx.group] = ctx.next_think;                                        \
	} else {                                                                                       \
		SSthink.next_group_run[ctx.group] = min(SSthink.next_group_run[ctx.group], ctx.next_think) \
	}

#define LAST_THINK _main_think_ctx.last_think
#define LAST_THINK_CTX(ctx) _think_ctxs[ctx].last_think
#define NEXT_THINK _main_think_ctx.next_think
#define NEXT_THINK_CTX(ctx) _think_ctxs[ctx].next_think
