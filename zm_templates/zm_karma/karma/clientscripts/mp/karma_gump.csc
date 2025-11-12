#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_gump;

karma_gump_init()
{
    level.uses_gumps = 1;
    waitforclient( 0 );
    waitforallclients();
    wait 0.05;

    players = getlocalplayers();
    slots = players.size - 1;
    thread clientscripts\mp\zombies\_zm_gump::load_gump_for_player( slots, "karma_gump_construction" );
}