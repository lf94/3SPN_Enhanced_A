class AM_HUD extends HudCDeathMatch;

var Texture     TeamTex;
var Material    TrackedPlayer;
var int         OldRoundTime;
var Misc_Player myOwner;

function DisplayMessages(Canvas C)
{
    if(bShowScoreboard || bShowLocalStats)
        ConsoleMessagePosY = 0.995;
    else
        ConsoleMessagePosY = default.ConsoleMessagePosY;

    super.DisplayMessages(C);
}

exec function ShowStats()
{
    bShowLocalStats = !bShowLocalStats;
    Misc_Player(PlayerOwner).bFirstOpen = bShowLocalStats;
}

function Draw2DLocationDot(Canvas C, vector Loc, float OffsetX, float OffsetY, float ScaleX, float ScaleY)
{
	local rotator Dir;
	local float Angle, Scaling;
	local Actor Start;

	if(PlayerOwner.Pawn == None)
    {
        if(PlayerOwner.ViewTarget != None)
            Start = PlayerOwner.ViewTarget;
        else
		    Start = PlayerOwner;
    }
	else
		Start = PlayerOwner.Pawn;

	Dir = rotator(Loc - Start.Location);
	Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832 / 65536;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(OffsetX * C.ClipX + ScaleX * C.ClipX * sin(Angle),
			OffsetY * C.ClipY - ScaleY * C.ClipY * cos(Angle));

	Scaling = 24 * C.ClipX * (0.45 * HUDScale) / 1600;

	C.DrawTile(LocationDot, Scaling, Scaling, 340, 432, 78, 78);
}

simulated function UpdateRankAndSpread(Canvas C)
{
    local int i;
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int listy;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;
    local int enemies;
    local Misc_PRI PRI;

    if(myOwner == None)
        myOwner = Misc_Player(PlayerOwner);

    listy = 0.08 * HUDScale * C.ClipY;
    space = 0.005 * HUDScale * C.ClipY;
    scale = Fmax(HUDScale, 0.75);
    height = C.ClipY * 0.0255 * Scale;
    width = C.ClipX * 0.13 * Scale;
    namex = C.ClipX * 0.025 * Scale; 
    MaxNamePos = 0.99 * (width - namex);
    C.Font = GetFontSizeIndex(C, -3 + int(Scale * 1.25));
    C.StrLen("Test", xl, yl);
    namey = (height * 0.6) - (yl * 0.5);
    posx = C.ClipX * 0.99;

    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);
        if(PRI == None || PRI.bOutOfLives || PRI == PlayerOwner.PlayerReplicationInfo)
            continue;

        if(!class'Misc_Player'.default.bShowTeamInfo || enemies > 9)
            continue;

        posy = listy + ((height + space) * enemies);

        // draw background
        C.SetPos(posx - width, posy);
        C.DrawColor = default.BlackColor;
        C.DrawColor.A = 128;
        C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

        // draw disc
        C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
        C.DrawColor = default.WhiteColor;
        C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

        // draw name
		if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
			name = PRI.GetColoredName();
		else
			name = PRI.PlayerName;
        C.TextSize(name, xl, yl);
		xl = Min(xl, MaxNamePos);
        C.DrawColor = WhiteColor;
        C.SetPos(posx - xl - namex, posy + namey); 
		class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);	

        // draw health dot
        C.DrawColor = class'Misc_Player'.default.RedOrEnemy * 2.5;
        C.DrawColor.A = 255;
        C.SetPos(posx - (0.0165 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
        C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

        enemies++;
    }
}

/*simulated function DrawTrackedPlayer(Canvas C, Misc_PawnReplicationInfo P, Misc_PRI PRI)
{
    local float	SizeScale, SizeX, SizeY;
    local vector ScreenPos;

    if(DrawPlayerTracking(C, P, false, ScreenPos) && (!p.bInvis || MyOwner.bEnhancedRadar) && PRI != PawnOwner.PlayerReplicationInfo)
    {
        C.DrawColor = WhiteColor * 0.8;
        C.DrawColor.A = 175;
        C.Style = ERenderStyle.STY_Alpha;

	    SizeScale	= 0.2;
	    SizeX		= 32 * SizeScale * ResScaleX;
	    SizeY		= 32 * SizeScale * ResScaleY;

	    C.SetPos(ScreenPos.X - SizeX * 0.5, ScreenPos.Y - SizeY * 0.5);
	    C.DrawTile(TrackedPlayer, SizeX, SizeY, 0, 0, 64, 64);
    }
}

simulated function bool DrawPlayerTracking( Canvas C, Actor P, bool bOptionalIndicator, out vector ScreenPos )
{
	local Vector	CamLoc;
	local Rotator	CamRot;

	C.GetCameraLocation(CamLoc, CamRot);

	if(IsTargetInFrontOfPlayer(C, P, ScreenPos, CamLoc, CamRot) && !FastTrace(Misc_PawnReplicationInfo(P).Position, CamLoc))
		return true;

	return false;
}

static function bool IsTargetInFrontOfPlayer( Canvas C, Actor Target, out Vector ScreenPos,
											 Vector CamLoc, Rotator CamRot )
{
	// Is Target located behind camera ?
	if((Misc_PawnReplicationInfo(Target).Position - CamLoc) Dot vector(CamRot) < 0)
		return false;

	// Is Target on visible canvas area ?
	ScreenPos = C.WorldToScreen(Misc_PawnReplicationInfo(Target).Position);
	if(ScreenPos.X <= 0 || ScreenPos.X >= C.ClipX)
        return false;
	if(ScreenPos.Y <= 0 || ScreenPos.Y >= C.ClipY)
        return false;

	return true;
}*/

function CheckCountdown(GameReplicationInfo GRI)
{
    local TAM_GRI G;

    G = TAM_GRI(GRI);
    if(G == None || G.SecsPerRound == 0 || G.RoundTime == 0 || G.RoundTime == OldRoundTime || GRI.Winner != None)
    {
        Super.CheckCountdown(GRI);
        return;
    }

    OldRoundTime = G.RoundTime;

    if(OldRoundTime == 60)
    {
        if(G.SecsPerRound >= 120)
          PlayerOwner.PlayStatusAnnouncement(LongCountName[3], 1, true);
    }
    else if(OldRoundTime == 30)
    {
        if(G.SecsPerRound >= 90)
          PlayerOwner.PlayStatusAnnouncement(LongCountName[4], 1, true);
    }
    else if(OldRoundTime == 20)
    {
        if(G.SecsPerRound >= 60)
            PlayerOwner.PlayStatusAnnouncement(LongCountName[5], 1, true);
    }
    else if(OldRoundTime <= 5 && OldRoundTime > 0)
    {
        //always play the last 5 count down
        PlayerOwner.PlayStatusAnnouncement(CountDownName[OldRoundTime - 1], 1, true);
    }
}

simulated function DrawTimer(Canvas C)
{
	local TAM_GRI GRI;
	local int Minutes, Hours, Seconds;

	GRI = TAM_GRI(PlayerOwner.GameReplicationInfo);

    if(GRI == None)
        return;

	if(GRI.SecsPerRound > 0)
    {
        Seconds = GRI.RoundTime;
        if(GRI.TimeLimit > 0 && GRI.RoundTime > GRI.RemainingTime)
            Seconds = GRI.RemainingTime;
    }
    else if(GRI.TimeLimit > 0)
        Seconds = GRI.RemainingTime;
	else
		Seconds = GRI.ElapsedTime;

	TimerBackground.Tints[TeamIndex] = HudColorBlack;
    TimerBackground.Tints[TeamIndex].A = 150;

	DrawSpriteWidget(C, TimerBackground);
	DrawSpriteWidget(C, TimerBackgroundDisc);
	DrawSpriteWidget(C, TimerIcon);

	TimerMinutes.OffsetX = default.TimerMinutes.OffsetX - 80;
	TimerSeconds.OffsetX = default.TimerSeconds.OffsetX - 80;
	TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX;
	TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX;

	if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

		DrawNumericWidget( C, TimerHours, DigitsBig);
        TimerHours.Value = Hours;

		if(Hours>9)
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX;
		}
		else
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX -40;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX -40;
			TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX - 32;
			TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX - 32;
		}
		DrawSpriteWidget( C, TimerDigitSpacer[0]);
	}
	DrawSpriteWidget( C, TimerDigitSpacer[1]);

	Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    TimerMinutes.Value = Min(Minutes, 60);
	TimerSeconds.Value = Min(Seconds, 60);

	DrawNumericWidget( C, TimerMinutes, DigitsBig);
	DrawNumericWidget( C, TimerSeconds, DigitsBig);
}

defaultproperties
{
     TeamTex=Texture'HUDContent.Generic.HUD'
     TrackedPlayer=Texture'3SPNv32232.textures.chair'
}
