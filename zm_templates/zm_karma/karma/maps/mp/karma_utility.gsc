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

spawn_perk_collision( origin, angles )
{
    collision = spawn( "script_model", origin, 1 );
    collision.angles = angles;
    collision setmodel( "zm_collision_perks1" );
    collision.script_noteworthy = "clip";
    collision disconnectpaths();
}

is_insta_round( round_number )
{
    if ( !isdefined( level.insta_kill_rounds ) )
    {
        level.insta_kill_rounds = array( 163, 165, 167, 169, 171, 173, 175, 177, 179, 181, 183, 185, 188, 189, 191, 194, 196, 197, 199, 202, 204, 205, 207, 210, 211, 214, 216, 217, 219, 222, 224, 225, 228, 229, 231, 234, 236, 237, 239, 242, 243, 246, 248, 249, 252, 253, 255 );
    }

    for ( i = 0; i < level.insta_kill_rounds.size; i++ )
    {
        if ( round_number == level.insta_kill_rounds[i] )
        {
            return true;
        }
    }

    return false;
}

turn_on_perks()
{
    flag_wait( "start_zombie_round_logic" );
    wait 1;

    level notify( "revive_on" );
    wait_network_frame();
    level notify( "doubletap_on" );
    wait_network_frame();
    level notify( "marathon_on" );
    wait_network_frame();
    level notify( "juggernog_on" );
    wait_network_frame();
    level notify( "sleight_on" );
    wait_network_frame();
    level notify( "Pack_A_Punch_on" );
}