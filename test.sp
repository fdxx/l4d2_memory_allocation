#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <l4d2_memory_allocation>

public void OnPluginStart()
{
	RegAdminCmd("sm_memory_test", Cmd_Test, ADMFLAG_ROOT);
}

Action Cmd_Test(int client, int args)
{
	Address pAdr;
	int value;

	pAdr = malloc(5);
	for (int i = 0; i < 5; i++)
	{
		value = LoadFromAddress(pAdr + view_as<Address>(i), NumberType_Int8);
		ReplyToCommand(client, "value = %i", value);
	}
	

	ReplyToCommand(client, "---------------");
	memset(pAdr, 1, 5);
	for (int i = 0; i < 5; i++)
	{
		value = LoadFromAddress(pAdr + view_as<Address>(i), NumberType_Int8);
		ReplyToCommand(client, "value = %i", value);
	}


	ReplyToCommand(client, "---------------");
	pAdr = realloc(pAdr, 10);
	for (int i = 0; i < 10; i++)
	{
		value = LoadFromAddress(pAdr + view_as<Address>(i), NumberType_Int8);
		ReplyToCommand(client, "value = %i", value);
	}

	ReplyToCommand(client, "---------------");
	free(pAdr);
	pAdr = calloc(1, 10);
	for (int i = 0; i < 10; i++)
	{
		value = LoadFromAddress(pAdr + view_as<Address>(i), NumberType_Int8);
		ReplyToCommand(client, "value = %i", value);
	}

	free(pAdr);
	return Plugin_Handled;
}
