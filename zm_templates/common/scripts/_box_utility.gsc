#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

init()
{
    level waittill( "connected", player );

    level._debug_chests = [];
    level._current_chest = undefined;

    collect_current_chests();
    level thread draw_chests();
    level thread chest_commands();
}

collect_current_chests()
{
    foreach ( chest in level.chests )
    {
        struct              = SpawnStruct();
        struct.chest_name   = chest.script_noteworthy;
        struct.origin       = chest.unitrigger_stub.origin;
        struct.angles       = chest.unitrigger_stub.angles;
        struct.width        = chest.unitrigger_stub.script_width;
        struct.height       = chest.unitrigger_stub.script_height;
        struct.length       = chest.unitrigger_stub.script_length;

        level._debug_chests[level._debug_chests.size] = struct;
    }
}

draw_chests()
{
    while ( true )
    {
        foreach ( chest in level._debug_chests )
        {
            name   = chest.chest_name;
            origin = chest.origin;
            angles = chest.angles;

            color = ( 1, 1, 1 );
            if ( IsDefined( level._current_chest ) && level._current_chest.chest_name == name )
            {
                color = ( 0, 1, 0 );
            }

            print3d( origin + ( 0, 0, 45 ), name );
            print3d( origin + ( 0, 0, 25 ), format_vec( origin ) );
            print3d( origin + ( 0, 0, 5 ), format_vec( angles ) );

            mins = ( -chest.width / 2, -chest.length / 2, 0 );
            maxs = (  chest.width / 2,  chest.length / 2, chest.height );

            boxoriented( origin, mins, maxs, angles, color, 1.0 );
        }

        wait 0.05;
    }
}

chest_commands()
{
	for ( ;; )
	{
		level waittill( "say", message, user, is_hidden, is_team_chat );
		user thread cmd_execute_internal( message, user );
	}
}

cmd_execute_internal( message, user )
{
    tokens = StrTok( message, " " );
    if ( tokens.size < 0 )
    {
        return;
    }

    cmd = ToLower( tokens[0] );
    switch ( cmd )
    {
        case "!s":
            user select_chest_f( tokens );
            break;
        
        case "!m":
            user adjust_origin_f( tokens );
            break;

        case "!a":
            user adjust_angles_f( tokens );
            break;
    }
}

select_chest_f( args )
{
    if ( args.size == 0 )
    {
        self iprintln( "Usage: !s <name>" );
        return;
    }

    chest_name = args[1];
    foreach ( chest in level._debug_chests )
    {
        if ( chest.chest_name == chest_name )
        {
            level._current_chest = chest;
            self iprintln( "Selected chest: " + chest.chest_name );
            return;
        }
    }

    self IPrintLn( "Chest not found: " + chest_name );
}

adjust_origin_f( args )
{
    if ( args.size < 3 )
    {
        self iprintln( "Usage: !m <axis> <amount>" );
        return;
    }

    if ( !IsDefined( level._current_chest ) )
    {
        self iprintln( "No chest selected. Use !s <name> first." );
        return;
    }

    axis   = ToLower( args[1] );
    amount = Int( args[2] );
    origin = level._current_chest.origin;

    switch ( axis )
    {
        case "x": origin += ( amount, 0, 0 ); break;
        case "z": origin += ( 0, amount, 0 ); break;
        case "y": origin += ( 0, 0, amount ); break;
    }

    level._current_chest.origin = origin;
    level._current_chest.unitrigger_stub.origin = origin;
    self iprintln( "Adjusted " + level._current_chest.chest_name + " origin to " + origin );
}

adjust_angles_f( args )
{
    if ( args.size < 3 )
    {
        self iprintln( "Usage: !a <axis> <amount>" );
        return;
    }

    if ( !IsDefined( level._current_chest ) )
    {
        self iprintln( "No chest selected. Use !s <name> first." );
        return;
    }

    axis   = ToLower( args[1] );
    amount = Float( args[2] );
    angles = level._current_chest.angles;

    switch ( axis )
    {
        case "x": angles += ( amount, 0, 0 ); break;
        case "z": angles += ( 0, amount, 0 ); break;
        case "y": angles += ( 0, 0, amount ); break;
    }

    level._current_chest.angles = angles;
    level._current_chest.unitrigger_stub.angles = angles;
    self iprintln( "Adjusted " + level._current_chest.chest_name + " angles to " + angles );
}

format_vec( vec )
{
    return "(" + vec[0] + ", " + vec[1] + ", " + vec[2] + ")";
}