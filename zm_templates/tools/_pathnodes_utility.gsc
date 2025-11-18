init()
{
    level waittill( "connected", player );

    SetDvar( "node_utility", 1 );

    level.nodes = [];
    nodes = getallnodes();
    
    foreach ( node in nodes )
    {
        level.nodes[ level.nodes.size ] = node.origin;
    }
    
    while ( true )
    {
        wait 0.05;
        
        if ( !isdefined( player ) )
        {
            break;
        }
        
        foreach ( node in level.nodes )
        {
            print3d( node, "*" );
        }

        if ( getdvarint( "node_utility" ) == 0 )
        {
            continue;
        }
        
        if ( !player usebuttonpressed() && !player meleebuttonpressed() )
        {
            continue;
        }
        
        if ( player meleebuttonpressed() )
        {
            level.nodes[ level.nodes.size ] = player.origin;
            player iprintlnbold( "Total Nodes: " + level.nodes.size );

            while ( isdefined( player ) && player meleebuttonpressed() )
            {
                wait 0.05;
            }
        }
        else if ( player usebuttonpressed() )
        {
            player iprintlnbold( "Dumping Nodes." );
            
            i = 0;
            
            foreach ( node in level.nodes )
            {
                printf( "{\n\"classname\" \"node_pathnode\"\n\"origin\" \"" + node[ 0 ] + " " + node[ 1 ] + " " + node[ 2 ] + "\"\n}" );
                
                i++;
                
                if ( i > 50 )
                {
                    i = 0;
                    wait 0.05;
                }
            }
            
            while ( isdefined( player ) && player usebuttonpressed() )
            {
                wait 0.05;
            }
        }
    }
}