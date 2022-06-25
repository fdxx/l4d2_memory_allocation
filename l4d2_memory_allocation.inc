#if defined _l4d2_memory_allocation_included
 #endinput
#endif
#define _l4d2_memory_allocation_included

// https://cplusplus.com/reference/cstdlib/malloc/
native Address malloc(int size);
native void free(Address ptr);
native void memset(Address ptr, int value, int num);
native Address realloc(Address ptr, int size);
native Address calloc(int num, int size);


public SharedPlugin __pl_l4d2_memory_allocation = 
{
	name = "l4d2_memory_allocation",
	file = "l4d2_memory_allocation.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_memory_allocation_SetNTVOptional()
{
	MarkNativeAsOptional("malloc");
	MarkNativeAsOptional("free");
	MarkNativeAsOptional("memset");
	MarkNativeAsOptional("realloc");
	MarkNativeAsOptional("calloc");
}
#endif
