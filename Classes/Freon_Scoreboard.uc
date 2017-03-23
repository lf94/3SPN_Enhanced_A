class Freon_Scoreboard extends TAM_Scoreboard;

simulated function SetCustomBarColor(out Color C, PlayerReplicationInfo PRI, bool bOwner)
{
    if(!bOwner && Freon_PRI(PRI) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo).bFrozen)
    {
        C.R = 140;
        C.G = 180;
        C.B = 255;
        C.A = BaseAlpha * 0.65;
    }
}

simulated function SetCustomLocationColor(out Color C, PlayerReplicationInfo PRI, bool bOwner)
{
    if(Freon_PRI(PRI) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo).bFrozen)
        C = class'Freon_PRI'.default.FrozenColor;
}

simulated function DrawLabelsBar(Canvas C, int BarX, int BarY, int BarW, int BarH, Color BackgroundCol)
{
	local int NameX, NameY;
	local int StatX, StatY;
	local int RankX, RankY;
	local int AvgPPRX, AvgPPRY;
	local int ScoreX, ScoreY;
	local int PointsPerX, PointsPerY;
	local int KillsX, KillsY;
	local int DeathsX, DeathsY;
	local int ThawsX, ThawsY;
	local int GitX, GitY;
	local int PingX, PingY;
	local int PLX, PLY;
	local float XL, YL;
	local string name;
	
	NameX = BarW * 0.031;
	NameY = C.ClipY * 0.01;
	StatX = BarW * 0.051;
	StatY = C.ClipY * 0.035;
	ScoreX = BarW * 0.49;
	ScoreY = C.ClipY * 0.01;
	PointsPerX = BarW * 0.49;
	PointsPerY = C.ClipY * 0.035;
	KillsX = BarW * 0.60;
	KillsY = C.ClipY * 0.01;
	DeathsX = BarW * 0.60;
	DeathsY = C.ClipY * 0.035;
	ThawsX = BarW * 0.71;
	ThawsY = C.ClipY * 0.01;
	GitX = BarW * 0.71;
	GitY = C.ClipY * 0.035;
	PingX = BarW * 0.82;
	PingY = C.ClipY * 0.01;
	PLX = BarW * 0.82;
	PLY = C.CLipY * 0.035;
	RankX = BarW * 0.93;
	RankY = C.ClipY * 0.01;
	AvgPPRX = BarW * 0.93;
	AvgPPRY = C.ClipY * 0.035;

	// BACKGROUND
	
    C.DrawColor = BackgroundCol;
    C.DrawColor.A = BaseAlpha;
	
    C.SetPos(BarX, BarY);
    C.DrawTile(BaseTex, BarW,BarH, 17,31,751,71);

	// NAME
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	C.SetPos(BarX + NameX, BarY + NameY);
	C.DrawText("Name", true);

	// STATUS
	
	C.DrawColor = HUDClass.default.RedColor * 0.7;
	C.DrawColor.G = 130;
	name = "Location";
	C.SetPos(BarX + StatX, BarY + StatY);
	C.DrawText(name, true);
	
	// RANK

	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = "Rank";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + RankX - (XL * 0.5), BarY + RankY);
	C.DrawText(name, true);
	
	// AVG PPR
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	C.DrawColor = HUDClass.default.WhiteColor * 0.55;
	name = "Avg PPR";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + AvgPPRX - (XL * 0.5), BarY + AvgPPRY);
	C.DrawText(name, true);
	
	// SCORE
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = "Score";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + ScoreY);
	C.DrawText(name, true);

	// POINTS PER ROUND
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);

	C.DrawColor = HUDClass.default.WhiteColor * 0.55;
	name = "PPR";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PointsPerX - (XL * 0.5), BarY + PointsPerY);
	C.DrawText(name, true);
	
	// KILLS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = "Kills";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + KillsX -(XL * 0.5), BarY + KillsY);
	C.DrawText(name, true);

	// DEATHS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	C.DrawColor.R = 170;
	C.DrawColor.G = 20;
	C.DrawColor.B = 20;
	name = "Deaths";
	C.StrLen(name, xl, yl);
	C.SetPos(BarX + DeathsX - (XL * 0.5), BarY + DeathsY);
	C.DrawText(name, true);
	
	// THAWS

	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = "Thaws";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ThawsX -(XL * 0.5), BarY + ThawsY);
	C.DrawText(name, true);
	
	// GIT
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	C.DrawColor.R = 170;
	C.DrawColor.G = 20;
	C.DrawColor.B = 20;
	name = "Git";
	C.StrLen(name, xl, yl);
	C.SetPos(BarX + GitX - (XL * 0.5), BarY + GitY);
	C.DrawText(name, true);
	
	// PING
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.CyanColor * 0.5;
	C.DrawColor.B = 150;
	C.DrawColor.R = 20;
	name = "Ping";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PingX - (XL * 0.5), BarY + PingY);
	C.DrawText(name, true);

	// P/L
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	name = "P/L";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PLX - (XL * 0.5), BarY + PLY);
	C.DrawText(name, true);
}

simulated function DrawPlayerBar(Canvas C, int BarX, int BarY, int BarW, int BarH, PlayerReplicationInfo PRI)
{
    local int NameX, NameY, NameW;
    local int StatX, StatY;
	local int RankX, RankY, RankW, RankH;
	local int AvgPPRX, AvgPPRY;
    local int ScoreX, ScoreY;
	local int PointsPerX, PointsPerY;
    local int KillsX, KillsY;
	local int DeathsX, DeathsY;
	local int ThawsX, ThawsY;
	local int GitX, GitY;
    local int PingX, PingY;
	local int PLX, PLY;
	local string name;
	local float XL, YL;
	local PlayerReplicationInfo OwnerPRI;
	local Freon_PRI xPRI;
	local int OwnerTeam;

	OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
	xPRI = Freon_PRI(PRI);
	
	if(OwnerPRI.Team != None)
		OwnerTeam = OwnerPRI.Team.TeamIndex;
	else
		OwnerTeam = 255;
	
	NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
    NameW = BarW * 0.47;
	StatX = BarW * 0.051;
    StatY = C.ClipY * 0.035;
	ScoreX = BarW * 0.49;
	ScoreY = C.ClipY * 0.0075;
	PointsPerX = BarW * 0.49;
	PointsPerY = C.ClipY * 0.035;
	KillsX = BarW * 0.60;
	KillsY = C.ClipY * 0.0075;
	DeathsX = BarW * 0.60;
	DeathsY = C.ClipY * 0.035;
	ThawsX = BarW * 0.71;
	ThawsY = C.ClipY * 0.0075;
	GitX = BarW * 0.71;
	GitY = C.ClipY * 0.035;
	PingX = BarW * 0.82;
	PingY = C.ClipY * 0.0075;
	PLX = BarW * 0.82;
	PLY = C.ClipY * 0.035;
	RankX = BarW * 0.93;
	RankY = C.ClipY * 0.0075;
	AvgPPRX = BarW * 0.93;
	AvgPPRY = C.ClipY * 0.035;
	
	RankW = C.ClipX * 32.0/1920.0;
	RankH = C.ClipY * 32.0/1080.0;

	// BACKGROUND	

	C.SetPos(BarX, BarY);
	C.DrawTile(BaseTex, BarW,BarH, 18,107,745,81);
	
	// NAME
	
	if(PRI.bOutOfLives)
	{
		name = PRI.PlayerName;
		C.DrawColor = HUDClass.default.WhiteColor * 0.4;
	}
	else 
	{
	    if(default.bEnableColoredNamesOnScoreBoard && Misc_PRI(PRI)!=None && Misc_PRI(PRI).GetColoredName() !="")
			name = Misc_PRI(PRI).GetColoredName();
		else
			name = PRI.PlayerName;
		C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	}
	if(len(class'Misc_Util'.static.StripColorCodes(name))<=18)
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	else
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	C.SetPos(BarX+NameX, BarY+NameY);
	class'Misc_Util'.static.DrawTextClipped(C, name, NameW);	
	
	// STATUS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
	
	if(!GRI.bMatchHasBegun)
	{
		if(PRI.bReadyToPlay)
			name = ReadyText;
		else
			name = NotReadyText;

		if(PRI.bAdmin)
		{
			name = "Admin -"@name;
			C.DrawColor.R = 170;
			C.DrawColor.G = 20;
			C.DrawColor.B = 20;
		}
		else
		{
			C.DrawColor = HUDClass.default.RedColor * 0.7;
			C.DrawColor.G = 130;
		}
	}
	else
	{
		if(!PRI.bAdmin /*&& !PRI.bOutOfLives*/)
		{
			if(!PRI.bOutOfLives)
			{
				C.DrawColor = HUDClass.default.RedColor * 0.7;
				C.DrawColor.G = 130;

				if(PRI.Team.TeamIndex==OwnerTeam || OwnerPRI.bOnlySpectator)
				{
					if(Freon_PRI(PRI)!=None)
						name = Freon_PRI(PRI).GetLocationNameTeam();
					else
						name = PRI.GetLocationName();
				}
				else
				{
					name = PRI.StringUnknown;
				}
			}
			else
			{
				C.DrawColor.R = 170;
				C.DrawColor.G = 20;
				C.DrawColor.B = 20;

				if((PRI.Team.TeamIndex==OwnerTeam || OwnerPRI.bOnlySpectator) && Freon_PRI(PRI)!=None)
					name = Freon_PRI(PRI).GetLocationNameTeam();
				else
					name = PRI.GetLocationName();
			}   

			SetCustomLocationColor(C.DrawColor, PRI, PRI == OwnerPRI);
		}
		else
		{
			C.DrawColor.R = 170;
			C.DrawColor.G = 20;
			C.DrawColor.B = 20;

			//if(PRI.bAdmin)
				name = "Admin";
			/*else if(PRI.bOutOfLives)
				name = "Dead";*/
		}
	}
	C.StrLen(name, XL, YL);
	if(XL > NameW)
		name = left(name, NameW / XL * len(name));
	C.SetPos(BarX + StatX, BarY + StatY);
	C.DrawText(name);

	// RANK

        DrawRank(C, BarX + RankX - RankW/2, BarY + RankY, RankW, RankH, Misc_PRI(PRI).Rank);


	// AVG PPR
        // hide avg ppr when read only
        if(Misc_PRI(PRI).AvgPPR!=0 && Misc_BaseGRI(GRI).ServerLinkStatus != SL_READONLY) 
	{
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
		C.DrawColor = HUDClass.default.WhiteColor * 0.55;
		name = class'Misc_PRI'.static.GetFormattedPPR(Misc_PRI(PRI).AvgPPR);	
		C.StrLen(name, XL, YL);
		C.SetPos(BarX + AvgPPRX - (XL * 0.5), BarY + AvgPPRY);
		C.DrawText(name);
	}
	
	// SCORE
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = string(int(PRI.Score));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + ScoreY);
	C.DrawText(name);

	// POINTS PER ROUND
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
	C.DrawColor = HUDClass.default.WhiteColor * 0.55;

	if(Misc_PRI(PRI).PlayedRounds > 0)
		XL = PRI.Score / Misc_PRI(PRI).PlayedRounds;
	else
		XL = PRI.Score;

	if(int((XL - int(XL)) * 10) < 0)
	{
		if(int(XL) == 0)
			name = "-"$string(int(XL));
		else
			name = string(int(XL));
		name = name$"."$-int((XL - int(XL)) * 10);
	}
	else
	{
		name = string(int(XL));
		name = name$"."$int((XL - int(XL)) * 10);
	}

	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PointsPerX - (XL * 0.5), BarY + PointsPerY);
	C.DrawText(name);

	// KILLS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = string(PRI.Kills);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + KillsX -(XL * 0.5), BarY + KillsY);
	C.DrawText(name);

	// DEATHS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
	C.DrawColor.R = 170;
	C.DrawColor.G = 20;
	C.DrawColor.B = 20;
	name = string(int(PRI.Deaths));
	C.StrLen(name, xl, yl);
	C.SetPos(BarX + DeathsX - (XL * 0.5), BarY + DeathsY);
	C.DrawText(name);
	
	// THAWS

	if(xPRI!=None)
	{
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
		C.DrawColor = HUDClass.default.WhiteColor * 0.7;
		name = string(int(xPRI.Thaws));
		C.StrLen(name, XL, YL);
		C.SetPos(BarX + ThawsX -(XL * 0.5), BarY + ThawsY);
		C.DrawText(name);
	}
	
	// GIT

	if(xPRI!=None)
	{
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
		C.DrawColor.R = 170;
		C.DrawColor.G = 20;
		C.DrawColor.B = 20;
		name = string(xPRI.Git);
		C.StrLen(name, xl, yl);
		C.SetPos(BarX + GitX - (XL * 0.5), BarY + GitY);
		C.DrawText(name);
	}
	
	// PING
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.CyanColor * 0.5;
	C.DrawColor.B = 150;
	C.DrawColor.R = 20;
	name = string(Min(999, PRI.Ping *4));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PingX - (XL * 0.5), BarY + PingY);
	C.DrawText(name);

	// PL
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
	//C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
	C.DrawColor = HUDClass.default.CyanColor * 0.5;
	C.DrawColor.B = 150;
	C.DrawColor.R = 20;
	name = string(PRI.PacketLoss);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PLX - (XL * 0.5), BarY + PLY);
	C.DrawText(name);
}

simulated function DrawPlayerTotalsBarFreon(Canvas C, int BarX, int BarY, int BarW, int BarH, string TeamName, Color backgroundCol, int Score, int Kills, int Thaws, int Ping, float PPR)
{
	local int NameX, NameY;
	local int ScoreX, ScoreY;
	local int KillsX, KillsY;
	local int ThawsX, ThawsY;
	local int PingX, PingY;
	local int PPRX, PPRY;
	local string name;
	local float XL, YL;
	
	NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
	ScoreX = BarW * 0.49;
	ScoreY = C.ClipY * 0.0075;
	KillsX = BarW * 0.60;
	KillsY = C.ClipY * 0.0075;
	ThawsX = BarW * 0.71;
	ThawsY = C.ClipY * 0.0075;
	PingX = BarW * 0.82;
	PingY = C.ClipY * 0.0075;
	PPRX = BarW * 0.93;
	PPRY = C.ClipY * 0.0075;
	
	// BACKGROUND
	
	C.DrawColor = backgroundCol;
	C.DrawColor.A = 200;
	C.SetPos(BarX, BarY);
	C.DrawTile(BaseTex, BarW,BarH, 18,107,745,81);

	// TEAM NAME

	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;

	C.SetPos(BarX + NameX, BarY + NameY);
	C.DrawText(TeamName);

	// SCORE
	
	name = string(Score);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ScoreX - XL * 0.5, BarY + ScoreY);
	C.DrawText(name);

	// KILLS
	
	name = string(Kills);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + KillsX - XL * 0.5, BarY + KillsY);
	C.DrawText(name);

	// THAWS

	name = string(Thaws);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ThawsX - XL * 0.5, BarY + ThawsY);
	C.DrawText(name);
	
	// PING
	
	C.DrawColor = HUDClass.default.CyanColor * 0.5;
	C.DrawColor.B = 150;
	C.DrawColor.R = 20;

	name = string(Min(999, Ping*4));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PingX - XL * 0.5, BarY + PingY);
	C.DrawText(name);
	
	// PPR

	if(PPR!=0)
	{
		C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
		C.DrawColor = HUDClass.default.WhiteColor * 0.55;
		name = string(PPR);
		C.StrLen(name, XL, YL);
		C.SetPos(BarX + PPRX - XL * 0.5, BarY + PPRY + YL * 0.25);
		C.DrawText(name);	
	}
}

simulated function DrawTeamBoard(Canvas C, int BoxX, int BoxY, int BoxW, string TeamName, Color TeamCol, array<PlayerReplicationInfo> Players, int MaxPlayers)
{
	local int i;
	local PlayerReplicationInfo PRI, OwnerPRI;
	local Freon_PRI xPRI;
	local int BarX, BarY, BoxH;
	
	local int LabelsBarX;
	local int LabelsBarY;
	local int LabelsBarW;
	local int LabelsBarH;
	
	local int PlayerBoxX;
	local int PlayerBoxy;
	local int PlayerBoxW;
	local int PlayerBoxH;
	local int PlayerBoxSeparatorH;
	
	local int PlayerTotalsW;
	local int playerTotalsH;
	
	local int TeamScore;
	local int TeamKills;
	local int TeamThaws;
	local int TeamPing;
	
	local float TeamAvgPPR;
	local int NumPPR;
	
    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
	
	LabelsBarX = 0;
	LabelsBarY = 0;
	LabelsBarW = BoxW;
	LabelsBarH = C.ClipY * 0.07;

    PlayerBoxX = 0;
    PlayerBoxY = LabelsBarY + LabelsBarH;
    PlayerBoxW = BoxW;
    PlayerBoxH = C.ClipY * 0.06;
	PlayerBoxSeparatorH = C.ClipY * 0.00;

	PlayerTotalsW = BoxW;
	PlayerTotalsH = C.ClipY * 0.04;

	BoxH = PlayerBoxY + (PlayerBoxH+PlayerBoxSeparatorH)*MaxPlayers;
	if(MaxPlayers >= 2)
		BoxH += PlayerTotalsH;
	BoxY = C.ClipY * 0.5 - BoxH * 0.5;
	
	NumPPR = 0;
	
	// LABELS
	
	DrawLabelsBar(C, BoxX+LabelsBarX, BoxY+LabelsBarY, LabelsBarW, LabelsBarH, TeamCol);

	// PLAYERS
	
	for(i=0; i<Players.Length; ++i)
	{
		PRI = Players[i];
		xPRI = Freon_PRI(PRI);

		TeamPing += PRI.Ping;
		TeamScore += PRI.Score;		
		TeamKills += PRI.Kills;
		
		if(xPRI!=None)
		{
			TeamThaws += xPRI.Thaws;
			
			if(xPRI.AvgPPR!=0)
			{
				TeamAvgPPR += xPRI.AvgPPR;
				++NumPPR;
			}
		}
		
		if(PRI == OwnerPRI)
		{
			C.DrawColor = TeamCol;
			C.DrawColor.A = BaseAlpha;
		}
		else
		{
			C.DrawColor = HUDClass.default.WhiteColor;
			C.DrawColor.A = BaseAlpha * 0.5;
		}

		SetCustomBarColor(C.DrawColor, PRI, PRI == OwnerPRI);
	
		BarX = BoxX+PlayerBoxX;
		BarY = BoxY+PlayerBoxY+(PlayerBoxH+PlayerBoxSeparatorH)*i;
		
		DrawPlayerBar(C, BarX, BarY, PlayerBoxW, PlayerBoxH, PRI);
	}
	
	// TEAM TOTAL
	
    if(Players.Length >= 2)
    {
        TeamPing /= Players.Length;
		
		if(NumPPR>1)
			TeamAvgPPR /= NumPPR;

		BarX = BoxX + PlayerBoxX;
		BarY = BoxY + PlayerBoxY + (PlayerBoxH+PlayerBoxSeparatorH)*Players.Length;
	
		DrawPlayerTotalsBarFreon(C, BarX, BarY, PlayerTotalsW, PlayerTotalsH, TeamName, TeamCol, TeamScore, TeamKills, TeamThaws, TeamPing, TeamAvgPPR);
    }
}

defaultproperties
{
}
