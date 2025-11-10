#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_gump;

karma_gump_init()
{
    level.uses_gumps = 1;
    waitforclient( 0 );
    waitforallclients();
    wait 0.05;

    // load the initial spawn gump
    thread load_gump_for_all_players( "karma_gump_checkin" );
    level waittill( "gump_loaded" );

    // start the threads for specific gump loading
    level thread pap_gump_think();
    level thread construction_gump_think();
}

construction_gump_think()
{
    for ( ;; )
    {
        level waittill( "karma_spawn_teleport" );
        load_gump_for_all_players( "karma_gump_construction" );
    }
}

pap_gump_think()
{
    for ( ;; )
    {
        level waittill( "karma_pap_teleport" ); // teleporting to pack-a-punch
        load_gump_for_all_players( "karma_gump_club" );

        level waittill( "karma_spawn_teleport" ); // going back to main area
        load_gump_for_all_players( "karma_gump_construction" );
    }
}

load_gump_for_all_players( gump_name )
{
    players = getlocalplayers();
    for ( i = 0; i < players.size; i++ )
    {
        clientscripts\mp\zombies\_zm_gump::load_gump_for_player( i, gump_name );
    }
}