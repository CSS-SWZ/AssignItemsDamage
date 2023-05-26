#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <entWatch>
#define REQUIRE_PLUGIN

#pragma newdecls required

int LastTick;
int Tick[2048];
int Owner[2048];
int Parent[2048];

public Plugin myinfo =
{
    name = "AssignItemsDamage",
    author = "hEl",
    description = "Assigning item damage to item owner",
    version = "1.0",
    url = "https://github.com/CSS-SWZ/AssignItemsDamage"
};

public void OnPluginStart()
{
    HookEntityOutput("env_entity_maker", "OnEntitySpawned", EntityMaker_OnEntitySpawned);

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
            OnClientPutInServer(i);
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage)
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if(attacker <= MaxClients)
        return Plugin_Continue;

    int newAttacker = Owner[attacker];
    if(!newAttacker)
    {
        if(!Parent[attacker])
            Parent[attacker] = GetEntityParent(attacker);

        if(Parent[attacker] == INVALID_ENT_REFERENCE)
            return Plugin_Continue;

        newAttacker = Owner[Parent[attacker]];
    }

    if(newAttacker <= 0 || newAttacker > MaxClients)
        return Plugin_Continue;

    if(!IsClientInGame(newAttacker))
    {
        Owner[newAttacker] = 0;
        return Plugin_Continue;
    }

    attacker = newAttacker;
    return Plugin_Changed;
}

int GetEntityParent(int entity)
{
    int parent = GetEntPropEnt(entity, Prop_Data, "m_pParent");

    if(parent == INVALID_ENT_REFERENCE)
        return INVALID_ENT_REFERENCE;

    if(0 < Owner[parent] <= MaxClients)
        return parent;

    return GetEntityParent(parent);
}

public void EntityMaker_OnEntitySpawned(const char[] output, int caller, int activator, float delay)
{
    static int tick;

    tick = GetGameTickCount();

    if(tick != LastTick)
        return;

    int parent = GetEntPropEnt(caller, Prop_Data, "m_pParent");

    if(parent == INVALID_ENT_REFERENCE)
        return;

    if(Owner[parent] <= 0 || Owner[parent] > MaxClients)
        return;

    if(!IsClientInGame(Owner[parent]))
    {
        Owner[parent] = 0;
        return;
    }

    for(int i = MaxClients; i < 2048; i++)
    {
        if(Tick[i] == tick)
            Owner[i] = Owner[parent];
    }
}

public void OnEntitySpawned(int entity, const char[] classname)
{
    if(MaxClients < entity < 2048)
    {
        LastTick = GetGameTickCount();
        Tick[entity] = LastTick;
    }
}

public void OnEntityDestroyed(int entity)
{
    if(MaxClients < entity < 2048)
    {
        Owner[entity] = 0;
        Parent[entity] = 0;
    }
}

public void entWatch_OnClientItemPickup(int client, int itemIndex)
{
    Item item;

    if(!entWatch_GetItem(itemIndex, item, sizeof(Item)))
        return;

    Owner[item.Weapon] = client;
}