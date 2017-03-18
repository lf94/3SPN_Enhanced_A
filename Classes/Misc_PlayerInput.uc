class Misc_PlayerInput extends PlayerInput;

event PlayerInput( float DeltaTime )
{
	return;
	
	if( Misc_BaseGRI(GameReplicationInfo).bGamePaused )
		return;
		
	Super.PlayerInput( DeltaTime );
}
