class Menu_PlayerLoginControlsTAM extends UT2K4Tab_PlayerLoginControls;

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;

	GRI = GetGRI();
	if (GRI != None)
	{
		if (bInit)
			InitGRI();

		if ( bTeamGame )
		{
			if ( GRI.Teams[0] != None )
				sb_Red.Caption = RedTeam@string(int(GRI.Teams[0].Score));

			if ( GRI.Teams[1] != None )
				sb_Blue.Caption = BlueTeam@string(int(GRI.Teams[1].Score));

			if (PlayerOwner().PlayerReplicationInfo.Team != None)
			{
				if (PlayerOwner().PlayerReplicationInfo.Team.TeamIndex == 0)
				{
					sb_Red.HeaderBase = texture'Display95';
					sb_Blue.HeaderBase = sb_blue.default.headerbase;
				}
				else
				{
					sb_Blue.HeaderBase = texture'Display95';
					sb_Red.HeaderBase = sb_blue.default.headerbase;
				}
			}
		}

		SetButtonPositions(C);
		UpdatePlayerLists();

		if ( ((PlayerOwner().myHUD == None) || !PlayerOwner().myHUD.IsInCinematic()) /*&& GRI.bMatchHasBegun*/ /*&& !PlayerOwner().IsInState('GameEnded')*/ && (GRI.MaxLives <= 0 || !PlayerOwner().PlayerReplicationInfo.bOnlySpectator) )
			EnableComponent(b_Spec);
		else
			DisableComponent(b_Spec);
	}

	return false;
}

defaultproperties
{
}