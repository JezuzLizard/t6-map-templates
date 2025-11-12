#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud;

init()
{
    level thread spawn_teleporter();
    level thread pap_teleporter();
}

spawn_teleporter()
{
    level endon( "end_game" );

    trigger = GetEnt( "use_spawn_teleporter", "targetname" );
    trigger SetHintString( &"KARMA_TELEPORTER" );
    trigger SetVisibleToAll();
    
    trigger waittill( "trigger", user );
    trigger SetInvisibleToAll();
    trigger Delete();
    
    teleport_all_players_to_location( "karma_spawn_teleport" );
}

pap_teleporter()
{
    level endon( "end_game" );

    trigger = GetEnt( "use_pap_teleporter", "targetname" );
    trigger SetHintString( &"KARMA_TELEPORTER" );

    while ( true )
    {
        trigger SetVisibleToAll();
        trigger waittill( "trigger", user );
        trigger SetInvisibleToAll();
        
        teleport_all_players_to_location( "karma_pap_teleport" );
    }
}

teleport_all_players_to_location( location )
{
    level notify( location );
    clientnotify( location );

    if ( location == "karma_spawn_teleport" )
    {
        spawn_zone = level.zones["checkin_volume"];
        if ( isdefined( spawn_zone ) && spawn_zone.is_enabled )
        {
            maps\mp\karma_util::disable_zone( "checkin_volume", true );
            maps\mp\zombies\_zm_zonemgr::enable_zone( "construction_volume" );
        }

        players = GetPlayers();
        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( i == 0 )
            {
                player teleport_player( ( 4580.8, -6080.03, -3575.88 ), ( 0, -90, 0 ) );
            }
        }
    }
    else if ( location == "karma_pap_teleport" )
    {
        players = GetPlayers();
        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( i == 0 )
            {
                player teleport_player( ( 5936.55, -6721.97, -5106.88 ), ( 0, 0, 0 ) );
            }
        }

        // wait a minute and then teleport back to spawn
        wait 60;
        teleport_all_players_to_location( "karma_spawn_teleport" );
    }
}

teleport_player( teleport_origin, teleport_angles )
{
    self.teleporting = 1;

    prone_offset = vectorscale( ( 0, 0, 1 ), 49.0 );
    crouch_offset = vectorscale( ( 0, 0, 1 ), 20.0 );
    stand_offset = ( 0, 0, 0 );

    // have to account for prone and crouch positions
    if ( self getstance() == "prone" )
    {
        desired_origin = teleport_origin + prone_offset;
    }
    else if ( self getstance() == "crouch" )
    {
        desired_origin = teleport_origin + crouch_offset;
    }
    else
    {
        desired_origin = teleport_origin + stand_offset;
    }

    // fade in, teleport, fade out
    wait_network_frame();

    playfx( level._effect[ "teleport_3p" ], desired_origin, ( 1, 0, 0 ), ( 0, 0, 1 ) );
    self playsoundtoplayer( "zmb_teleporter_tele_2d", self );

    self thread fadetoblackforxsec( 0, 2, 0.3, 0.3, "black" );

    wait 2;
    self setorigin( desired_origin );
    self setplayerangles( teleport_angles );

    playfx( level._effect[ "teleport_3p" ], desired_origin, ( 1, 0, 0 ), ( 0, 0, 1 ) );
    self playsoundtoplayer( "zmb_teleporter_tele_3d", self );

    self.teleporting = 0;
}