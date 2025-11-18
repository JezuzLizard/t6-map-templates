init()
{
    level waittill( "connected", player );

    level._debug_zones = [];
    level._current_zone = undefined;

    collect_current_zones();
    level thread draw_zones();
    level thread zone_commands();
}

collect_current_zones()
{
    player_volumes = GetEntArray( "player_volume", "script_noteworthy" );

    foreach ( vol in player_volumes )
    {
        name = vol.targetname;
        origin = vol.origin;
        angles = vol.angles;
        mins = vol GetMins();
        maxs = vol GetMaxs();

        struct              = SpawnStruct();
        struct.zone_name    = name;
        struct.origin       = origin;
        struct.angles       = angles;
        struct.mins         = mins;
        struct.maxs         = maxs;

        level._debug_zones[level._debug_zones.size] = struct;
    }
}

draw_zones()
{
    while ( true )
    {
        foreach ( zone in level._debug_zones )
        {
            name        = zone.zone_name;
            origin      = zone.origin;
            angles      = zone.angles;
            mins        = zone.mins;
            maxs        = zone.maxs;

            color = ( 1, 1, 1 );
            if ( IsDefined( level._current_zone ) && level._current_zone.zone_name == name )
            {
                color = ( 0, 1, 0 );
            }

            print3d( origin + ( 0, 0, 45 ), name );
            print3d( origin + ( 0, 0, 25 ), format_vec( origin ) );
            print3d( origin + ( 0, 0, 5 ), format_vec( angles ) );

            boxoriented( origin, mins, maxs, angles, color, 1.0 );
        }

        wait 0.05;
    }
}

zone_commands()
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
            user select_zone_f( tokens );
            break;
        
        case "!m":
            user adjust_origin_f( tokens );
            break;

        case "!a":
            user adjust_angles_f( tokens );
            break;
    }
}

select_zone_f( args )
{
    if ( args.size == 0 )
    {
        self iprintln( "Usage: !s <name>" );
        return;
    }

    zone_name = args[1];
    foreach ( zone in level._debug_zones )
    {
        if ( zone.zone_name == zone_name )
        {
            level._current_zone = zone;
            self iprintln( "Selected zone: " + zone.name );
            return;
        }
    }

    self IPrintLn( "Zone not found: " + zone_name );
}

adjust_origin_f( args )
{
    if ( args.size < 3 )
    {
        self iprintln( "Usage: !m <axis> <amount>" );
        return;
    }

    if ( !IsDefined( level._current_zone ) )
    {
        self iprintln( "No zone selected. Use !s <name> first." );
        return;
    }

    axis   = ToLower( args[1] );
    amount = Int( args[2] );
    origin = level._current_zone.origin;

    switch ( axis )
    {
        case "x": origin += ( amount, 0, 0 ); break;
        case "z": origin += ( 0, amount, 0 ); break;
        case "y": origin += ( 0, 0, amount ); break;
    }

    level._current_zone.origin = origin;
    self iprintln( "Adjusted " + level._current_zone.zone_name + " origin to " + origin );
}

adjust_angles_f( args )
{
    if ( args.size < 3 )
    {
        self iprintln( "Usage: !a <axis> <amount>" );
        return;
    }

    if ( !IsDefined( level._current_zone ) )
    {
        self iprintln( "No zone selected. Use !s <name> first." );
        return;
    }

    axis   = ToLower( args[1] );
    amount = Float( args[2] );
    angles = level._current_zone.angles;

    switch ( axis )
    {
        case "x": angles += ( amount, 0, 0 ); break;
        case "z": angles += ( 0, amount, 0 ); break;
        case "y": angles += ( 0, 0, amount ); break;
    }

    level._current_zone.angles = angles;
    self iprintln( "Adjusted " + level._current_zone.zone_name + " angles to " + angles );
}

format_vec( vec )
{
    return "(" + vec[0] + ", " + vec[1] + ", " + vec[2] + ")";
}