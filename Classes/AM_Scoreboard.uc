class AM_Scoreboard extends TAM_Scoreboard;

simulated function DrawLabelsBar(Canvas C, int BarX, int BarY, int BarW, int BarH, Color BackgroundCol)
{
	local int NameX, NameY;
	local int StatX, StatY;
	local int ScoreX, ScoreY;
	local int PointsPerX, PointsPerY;
	local int WinsX, WinsY;
	local int DeathsX, DeathsY;
	local int PingX, PingY;
	local int PLX, PLY;
	local float XL, YL;
	local string name;
	
	NameX = BarW * 0.031;
	NameY = C.ClipY * 0.01;
	StatX = BarW * 0.051;
	StatY = C.ClipY * 0.035;
	ScoreX = BarW * 0.66;
	ScoreY = C.ClipY * 0.01;
	PointsPerX = BarW * 0.66;
	PointsPerY = C.ClipY * 0.035;
	WinsX = BarW * 0.80;
	WinsY = C.ClipY * 0.01;
	DeathsX = BarW * 0.80;
	DeathsY = C.ClipY * 0.035;
	PingX = BarW * 0.92;
	PingY = C.ClipY * 0.01;
	PLX = BarW * 0.92;
	PLY = C.CLipY * 0.035;

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
	
	// WINS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = "Wins";
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + WinsX -(XL * 0.5), BarY + WinsY);
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
    local int ScoreX, ScoreY;
	local int PointsPerX, PointsPerY;
    local int WinsX, WinsY;
	local int DeathsX, DeathsY;
    local int PingX, PingY;
	local int PLX, PLY;
	local string name;
	local float XL, YL;
	local Misc_PRI OwnerPRI;
	local float Score;

    OwnerPRI = Misc_PRI(PlayerController(Owner).PlayerReplicationInfo);
	
	NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
    NameW = BarW * 0.47;
	StatX = BarW * 0.051;
    StatY = C.ClipY * 0.035;
	ScoreX = BarW * 0.66;
	ScoreY = C.ClipY * 0.0075;
	PointsPerX = BarW * 0.66;
	PointsPerY = C.ClipY * 0.035;
	WinsX = BarW * 0.80;
	WinsY = C.ClipY * 0.0075;
	DeathsX = BarW * 0.80;
	DeathsY = C.ClipY * 0.035;
	PingX = BarW * 0.92;
	PingY = C.ClipY * 0.0075;
	PLX = BarW * 0.92;
	PLY = C.ClipY * 0.035;

	// BACKGROUND

	C.SetPos(BarX, BarY);
	C.DrawTile(BaseTex, BarW,BarH, 18,107,745,81);
	
	// NAME
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	if(PRI.bOutOfLives || Misc_PRI(PRI)==None)
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

				if(OwnerPRI.bOnlySpectator)
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

				if(OwnerPRI.bOnlySpectator && Freon_PRI(PRI)!=None)
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
	
	// SCORE
	
	Score = PRI.Score % 10000;
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = string(int(Score));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + ScoreY);
	C.DrawText(name);

	// POINTS PER ROUND
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
	C.DrawColor = HUDClass.default.WhiteColor * 0.55;

	if(Misc_PRI(PRI).PlayedRounds > 0)
		XL = Score / Misc_PRI(PRI).PlayedRounds;
	else
		XL = Score;

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

	// WINS
	
	C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
	C.DrawColor = HUDClass.default.WhiteColor * 0.7;
	name = string(int(PRI.Score / 10000));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + WinsX -(XL * 0.5), BarY + WinsY);
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

simulated function DrawPlayerTotalsBar(Canvas C, int BarX, int BarY, int BarW, int BarH, string TeamName, Color backgroundCol, int Score, int Kills, int Ping, float PPR)
{
	local int NameX, NameY;
	local int ScoreX, ScoreY;
	local int WinsX, WinsY;
	local int PingX, PingY;
	local string name;
	local float XL, YL;
	
	NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
	ScoreX = BarW * 0.66;
	ScoreY = C.ClipY * 0.0075;
	WinsX = BarW * 0.80;
	WinsY = C.ClipY * 0.0075;
	PingX = BarW * 0.92;
	PingY = C.ClipY * 0.0075;
	
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
	
	name = string(int(Score%10000));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + ScoreX - XL * 0.5, BarY + ScoreY);
	C.DrawText(name);

	// WINS
	
	name = string(Score/10000);
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + WinsX - XL * 0.5, BarY + WinsY);
	C.DrawText(name);

	// PING
	
	C.DrawColor = HUDClass.default.CyanColor * 0.5;
	C.DrawColor.B = 150;
	C.DrawColor.R = 20;

	name = string(Min(999, Ping*4));
	C.StrLen(name, XL, YL);
	C.SetPos(BarX + PingX - XL * 0.5, BarY + PingY);
	C.DrawText(name);
}

simulated event UpdateScoreBoard(Canvas C)
{
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i;
	
	local array<PlayerReplicationInfo> Players;
    local array<PlayerReplicationInfo> Specs;

	local int HeaderX;
	local int HeaderY;
	local int HeaderW;
	local int HeaderH;

	local int ScoreBoardX;
	local int ScoreBoardY;
	local int ScoreBoardW;
	
	local int SpecBoxX;
	local int SpecBoxY;
	local int SpecBoxW;
	
	local Color BackgroundCol;
	
	Players.Length = 0;
	Specs.Length = 0;
	
	BackgroundCol.R = 120;
	BackgroundCol.G = 120;
	BackgroundCol.B = 120;
	BackgroundCol.A = BaseAlpha * 0.5;
	
	// GET PLAYER INFORMATION

    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
	
    for(i = 0; i < GRI.PRIArray.Length; i++)
    {
        PRI = GRI.PRIArray[i];

        if(PRI.bOnlySpectator)
        {
			Specs.Insert(Specs.Length,1);
			Specs[Specs.Length-1] = PRI;
			continue;
        }
		
        if(Level.TimeSeconds - LastUpdateTime > 4)
            Misc_Player(Owner).ServerUpdateStats(TeamPlayerReplicationInfo(PRI));
		
		if(Players.Length < MaxTeamSize)
		{
			Players.Insert(Players.Length,1);
			Players[Players.Length-1] = PRI;
		}
		else if(PRI == OwnerPRI)
		{
			Players[Players.Length-1] = PRI;
		}
	}

	MaxTeamPlayers = Max(MaxTeamPlayers,Players.Length);
	
	HeaderX = 0.00;
	HeaderY = 0.00;
	HeaderW = C.ClipX;
	HeaderH = C.ClipY * 0.08;

	ScoreBoardX = C.ClipX * 0.30;
	ScoreBoardY = C.ClipY * 0.23;
	ScoreBoardW = C.ClipX * 0.40;
	
	SpecBoxX = C.ClipX * 0.80;
	SpecBoxY = C.ClipY * 0.915;
	SpecBoxW = C.ClipX * 0.16;
	
    C.Style = ERenderStyle.STY_Alpha;
	
	DrawHeader(C, HeaderX, HeaderY, HeaderW, HeaderH);
		
	DrawTeamBoard(C, ScoreBoardX, ScoreBoardY, ScoreBoardW, "Total", BackgroundCol, Players, MaxTeamPlayers);

	// SPECTATORS
	
	if(Specs.Length>0)
	{	
		DrawSpecList(C, SpecBoxX, SpecBoxY, SpecBoxW, Specs);
	}

    if(Level.TimeSeconds - LastUpdateTime > 4)
		LastUpdateTime = Level.TimeSeconds;

    bDisplayMessages = true;
}

defaultproperties
{
}
