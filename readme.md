# AssignItemsDamage
Assigns the item damage dealt by trigger_entities to the player that owns the item

## Requirements
[entWatch](https://github.com/CSS-SWZ/entWatch)

## Important
It is necessary to modify plugins that handle damage to the player. (zombiereloaded, hlstats, etc)

Add a check to see if the weapon is a trigger_hurt.

This way you will avoid problems with Zombie:Reloaded (ghost boost zm), TopDefenders, HLstatsX (farm damage, points).

```ini
// Checking trigger_hurt in player_hurt callback
if(weapon[1] == 'r') return;
```