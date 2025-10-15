/*
 * Created by ScriptDevelop.
 * User: mslone
 * Date: 4/11/2012
 * Time: 4:24 PM
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
#include common_scripts\utility;
#include maps\mp\_utility;

autoexec main()
{
	level.tweakfile = true;
	
	//////rimlighting////////
    SetDvar( "r_rimIntensity_debug", 1 );
    SetDvar( "r_rimIntensity", 15 );	
    
//    n_near_start = 8;
//	n_near_end = 24;
//	n_far_start = 128;
//	n_far_end = 768;
//	n_near_blur = 4;
//	n_far_blur = 1.5;
//	n_time = 0.05;
	
	level.do_not_use_dof = true; //-- turn off default dof settings from _art.gsc
//	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

//////////DOF////////////////

dof_frontend()
{
//	n_near_start = 8;
//	n_near_end = 24;
//	n_far_start = 128;
//	n_far_end = 768;
//	n_near_blur = 4;
//	n_far_blur = 1.5;
//	n_time = 0.05;
//	
//	level.player thread depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

new_timer()
{
	s_timer = SpawnStruct();
	s_timer.n_time_created = GetTime();
	return s_timer;
}

get_time()
{
	t_now = GetTime();
	return t_now - self.n_time_created;
}

get_time_in_seconds()
{
	return get_time() / 1000;
}

timer_wait( n_wait )
{
	wait n_wait;
	return get_time_in_seconds();
}

lerp_dvar( str_dvar, n_val, n_lerp_time, b_saved_dvar, b_client_dvar )
{
	n_start_val = GetDvarFloat( str_dvar );
	s_timer = new_timer();
	
	do
	{
		n_time_delta = s_timer timer_wait( .05 );
		n_curr_val = LerpFloat( n_start_val, n_val, n_time_delta / n_lerp_time );
		
		if ( IS_TRUE( b_saved_dvar ) )
		{
			//SetSavedDvar( str_dvar, n_curr_val );
		}
		else if ( IS_TRUE( b_client_dvar ) )
		{
			self SetClientDvar( str_dvar, n_curr_val );
		}
		else
		{
			SetDvar( str_dvar, n_curr_val );
		}
	}
	while ( n_time_delta < n_lerp_time );
}

run_war_room_mixers()
{
	ClientNotify( "dim_cic_lights" );
	ClientNotify( "holo_table_flicker" );
	SetDvar( "r_exposureTweak", 1 );
	level thread lerp_dvar( "r_exposureValue", 3.75, 0.1 );

	level waittill( "frontend_reset_mixers" );
	
	level thread lerp_dvar( "r_exposureValue", 2.5, 0.1 );
	SetDvar( "r_exposureTweak", 0 );
	ClientNotify( "dim_cic_lights" );
	ClientNotify( "holo_table_flicker" );
}