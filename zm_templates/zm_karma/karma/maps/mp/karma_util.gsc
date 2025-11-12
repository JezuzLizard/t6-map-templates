#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_zonemgr;

disable_zone( zone_name, respawn_zombies )
{
    assert( isdefined( level.zones ) && isdefined( level.zones[zone_name] ), "disable_zone: zone has not been initialized" );

    level.zones[zone_name].is_enabled = 0;
    level.zones[zone_name].is_spawning_allowed = 0;
    level notify( zone_name );
    spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

    for ( i = 0; i < spawn_points.size; i++ )
    {
        if ( spawn_points[i].script_noteworthy == zone_name )
            spawn_points[i].locked = 1;
    }

    entry_points = getstructarray( zone_name + "_barriers", "script_noteworthy" );

    for ( i = 0; i < entry_points.size; i++ )
    {
        entry_points[i].is_active = 0;
        entry_points[i] trigger_off();
    }

    // kill the zombies in the zone
    if ( !isdefined( respawn_zombies ) || !is_true( respawn_zombies ) )
    {
        return;
    }

    zombies = getaiarray( level.zombie_team );
    foreach ( zombie in zombies )
    {
        zombie dodamage( zombie.health + 100, ( 0, 0, 0 ) );
        level.zombie_total++;
        level.zombie_total_subtract++;
    }
}