#pragma semicolon 1
#pragma newdecls required

#define VERSION "0.1"

#include <sourcemod>
#include <sdktools>

Handle
	g_hSDK_malloc,
	g_hSDK_free,
	g_hSDK_memset,
	g_hSDK_realloc,
	g_hSDK_calloc;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead2) 
		LogError("Plugin only supports L4D2");
	
	CreateNative("malloc", Native_malloc);
	CreateNative("free", Native_free);
	CreateNative("memset", Native_memset);
	CreateNative("realloc", Native_realloc);
	CreateNative("calloc", Native_calloc);

	RegPluginLibrary("l4d2_memory_allocation");

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "L4D2 Memory Allocation",
	author = "fdxx",
	description = "Provide some memory allocation functions",
	version = VERSION,
	url = "https://github.com/fdxx/l4d2_memory_allocation"
}

public void OnPluginStart()
{
	Init();
	CreateConVar("l4d2_memory_allocation_version", VERSION, "version", FCVAR_NONE | FCVAR_DONTRECORD);
}

// native Address malloc(int size);
any Native_malloc(Handle plugin, int numParams)
{
	return SDKCall(g_hSDK_malloc, GetNativeCell(1));
}

// native void free(Address ptr);
any Native_free(Handle plugin, int numParams)
{
	SDKCall(g_hSDK_free, GetNativeCell(1));
	return 0;
}

// native void memset(Address ptr, int value, int num);
any Native_memset(Handle plugin, int numParams)
{
	SDKCall(g_hSDK_memset, GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
	return 0;
}

// native Address realloc(Address ptr, int size);
any Native_realloc(Handle plugin, int numParams)
{
	return SDKCall(g_hSDK_realloc, GetNativeCell(1), GetNativeCell(2));
}

// native Address calloc(int num, int size);
any Native_calloc(Handle plugin, int numParams)
{
	return SDKCall(g_hSDK_calloc, GetNativeCell(1), GetNativeCell(2));
}

void Init()
{
	GameData hGameData = new GameData("l4d2_memory_allocation");
	if (hGameData == null)
		SetFailState("Failed to load \"l4d2_memory_allocation.txt\" file");

	Address pCallFunc, pRelativeOffset, pAdr;
	int iOffset;

	// ------- malloc ------- 

	// malloc is indirectly called in this function.
	pCallFunc = hGameData.GetMemSig("CHintSystem::Init"); 
	if (pCallFunc == Address_Null)
		SetFailState("Failed to get signature address: \"CHintSystem::Init\"");

	// Get call malloc's offset.
	iOffset = hGameData.GetOffset("malloc");
	if (iOffset == -1)
		SetFailState("Failed to get offset: \"malloc\"");

	// Get the relative offset of the malloc function. (+1: skip call's opcode E8).
	pRelativeOffset = LoadFromAddress(pCallFunc + view_as<Address>(iOffset + 1), NumberType_Int32);

	// next instruction + relative offset. (+5: call instruction is 5 bytes long).
	pAdr = pCallFunc + view_as<Address>(iOffset + 5) + pRelativeOffset; 

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pAdr);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDK_malloc = EndPrepSDKCall();

	// ------- free ------- 
	pCallFunc = hGameData.GetMemSig("CHintSystem::Init");
	iOffset = hGameData.GetOffset("free");
	pRelativeOffset = LoadFromAddress(pCallFunc + view_as<Address>(iOffset + 1), NumberType_Int32);
	pAdr = pCallFunc + view_as<Address>(iOffset + 5) + pRelativeOffset;

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pAdr);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDK_free = EndPrepSDKCall();

	// ------- memset ------- 
	pCallFunc = hGameData.GetMemSig("CHintSystem::Init");
	iOffset = hGameData.GetOffset("memset");
	pRelativeOffset = LoadFromAddress(pCallFunc + view_as<Address>(iOffset + 1), NumberType_Int32);
	pAdr = pCallFunc + view_as<Address>(iOffset + 5) + pRelativeOffset;

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pAdr);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDK_memset = EndPrepSDKCall();

	// ------- realloc ------- 
	pCallFunc = hGameData.GetMemSig("CHintSystem::Init");
	iOffset = hGameData.GetOffset("realloc");
	pRelativeOffset = LoadFromAddress(pCallFunc + view_as<Address>(iOffset + 1), NumberType_Int32);
	pAdr = pCallFunc + view_as<Address>(iOffset + 5) + pRelativeOffset;

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pAdr);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDK_realloc = EndPrepSDKCall();

	// ------- calloc ------- 
	pCallFunc = hGameData.GetMemSig("CBaseEntity::operator_new");
	iOffset = hGameData.GetOffset("calloc");
	pRelativeOffset = LoadFromAddress(pCallFunc + view_as<Address>(iOffset + 1), NumberType_Int32);
	pAdr = pCallFunc + view_as<Address>(iOffset + 5) + pRelativeOffset;

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pAdr);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDK_calloc = EndPrepSDKCall();
}
