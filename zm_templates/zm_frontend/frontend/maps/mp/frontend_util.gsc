#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#define CLIENT_FLAG_HOLO_RED		14
#define CLIENT_FLAG_HOLO_VISIBLE	15

#define VEC_SET_Y(__vec, __y) \
    __vec = (__vec[0], __y, __vec[2]);

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
        //country ClearClientFlag( CLIENT_FLAG_HOLO_RED );
    }

    return globe;
}

process_globe_glow()
{
    if ( is_true( self.camera_facing ) )
        return;

    self.camera_facing = true;
    self endon( "death" );
    globe = GetEnt( "world_globe", "targetname" );
    self.angles = globe.angles;

    while ( true )
    {
        self.origin = globe.origin;

        players = get_players();

        cam_pos = players[0] GetPlayerCameraPos();
        self_to_camera = cam_pos - self.origin;
        newangles = VectorToAngles( self_to_camera );

        VEC_SET_Y(newangles, newangles[1] + 90 );
        self RotateTo( newangles, 0.05, 0, 0 );
        wait_network_frame();
    }
}

// Toggles visibility of the globe model.
show_globe( do_show = true, ambient_spin = false )
{	
    globe = GetEnt( "world_globe", "targetname" );

    if ( !isdefined( globe.glow_ring ) )
    {
        globe.glow_ring = GetEnt( "world_globe_ring", "targetname" );
        globe.glow_ring thread process_globe_glow();
    }

    if ( !ambient_spin )
    {
        globe notify( "stop_spinning" );
    }
    else
    {
        globe notify( "kill_globe_marker_fx" );
        globe thread rotate_indefinitely( 120 );
    }

    if ( !isdefined( level.m_globe_shown ) )
        level.m_globe_shown = !do_show;

    if ( do_show != level.m_globe_shown )
    {
        if ( do_show )
        {
            //globe SetClientFlag( CLIENT_FLAG_HOLO_VISIBLE );
            globe.glow_ring Show();
            globe play_fx( "globe_satellite_fx", globe.origin, globe.angles, "kill_globe_satellite_fx", true );
        }
        else
        {
            globe notify( "kill_globe_satellite_fx" );
            globe notify( "kill_globe_marker_fx" );
            //globe ClearClientFlag( CLIENT_FLAG_HOLO_VISIBLE );
            globe.glow_ring Hide();
        }
    }

    level.m_globe_shown = do_show;

    countries = GetEntArray( globe.target, "targetname" );
    foreach ( country in countries )
    {
        if ( do_show )
        {
            country Show();
        }
        else
        {
            country Hide();
        }
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