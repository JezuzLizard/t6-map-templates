#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

// Attaches all the countries to the globe, then hides them.
build_globe()
{
    globe = GetEnt( "world_globe", "targetname" );
    countries = GetEntArray( globe.target, "targetname" );

    foreach ( country in countries )
    {
        country LinkTo( globe );
        country Hide();
        country IgnoreCheapEntityFlag( true );
    }

    return globe;
}

// Toggles visibility of the globe model.
show_globe()
{	
    globe = GetEnt( "world_globe", "targetname" );
    globe notify( "kill_globe_marker_fx" );

    globe thread rotate_indefinitely( 120 );
    globe play_fx( "globe_satellite_fx", globe.origin, globe.angles, "kill_globe_satellite_fx", true );

    countries = GetEntArray( globe.target, "targetname" );
    foreach ( country in countries )
    {
        country Show();
    }
}

rotate_indefinitely( rotate_time = 45, rotate_fwd = true )
{
    self endon( "stop_spinning" );
    self endon( "death" );
    self endon( "delete" );

    while ( true )
    {
        if ( rotate_fwd )
            self RotateYaw( 360, rotate_time, 0, 0 );
        else
            self RotateYaw( -360, rotate_time, 0, 0 );

        wait rotate_time - 0.1;
    }
}

play_fx( str_fx, v_origin, v_angles, time_to_delete_or_notify, b_link_to_self, str_tag, b_no_cull )
{
    if ( ( !isdefined( time_to_delete_or_notify ) || !isstring( time_to_delete_or_notify ) && time_to_delete_or_notify == -1 ) && ( isdefined( b_link_to_self ) && b_link_to_self ) && isdefined( str_tag ) )
    {
        playfxontag( getfx( str_fx ), self, str_tag );
        return self;
    }
    else
    {
        m_fx = spawn_model( "tag_origin", v_origin, v_angles );

        if ( isdefined( b_link_to_self ) && b_link_to_self )
        {
            if ( isdefined( str_tag ) )
                m_fx linkto( self, str_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
            else
                m_fx linkto( self );
        }

        if ( isdefined( b_no_cull ) && b_no_cull )
            m_fx setforcenocull();

        playfxontag( getfx( str_fx ), m_fx, "tag_origin" );
        m_fx thread _play_fx_delete( self, time_to_delete_or_notify );
        return m_fx;
    }
}

spawn_model( model_name, origin, angles, n_spawnflags )
{
    if ( !isdefined( n_spawnflags ) )
        n_spawnflags = 0;

    if ( !isdefined( origin ) )
        origin = ( 0, 0, 0 );

    model = spawn( "script_model", origin, n_spawnflags );
    model setmodel( model_name );

    if ( isdefined( angles ) )
        model.angles = angles;

    return model;
}

getfx( fx )
{
    assert( isdefined( level._effect[fx] ), "Fx " + fx + " is not defined in level._effect." );
    return level._effect[fx];
}

_play_fx_delete( ent, time_to_delete_or_notify )
{
    if ( !isdefined( time_to_delete_or_notify ) )
        time_to_delete_or_notify = -1;

    if ( isstring( time_to_delete_or_notify ) )
        ent waittill_either( "death", time_to_delete_or_notify );
    else if ( time_to_delete_or_notify > 0 )
        ent waittill_notify_or_timeout( "death", time_to_delete_or_notify );
    else
        ent waittill( "death" );

    if ( isdefined( self ) )
        self delete();
}