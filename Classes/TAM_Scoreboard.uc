class TAM_Scoreboard extends ScoreBoardTeamDeathMatch;

#exec TEXTURE IMPORT NAME=Scoreboard FILE=Textures\Scoreboard.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Shield FILE=Textures\Shield.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=FlagDefault FILE=Textures\FlagDefault.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=FlagUS FILE=Textures\FlagUS.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=FlagDE FILE=Textures\FlagDE.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=FlagGB FILE=Textures\FlagGB.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=FlagEU FILE=Textures\FlagEU.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank1 FILE=Textures\Rank1.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank2 FILE=Textures\Rank2.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank3 FILE=Textures\Rank3.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank4 FILE=Textures\Rank4.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank5 FILE=Textures\Rank5.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank6 FILE=Textures\Rank6.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank7 FILE=Textures\Rank7.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank8 FILE=Textures\Rank8.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank9 FILE=Textures\Rank9.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank10 FILE=Textures\Rank10.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank11 FILE=Textures\Rank11.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank12 FILE=Textures\Rank12.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank13 FILE=Textures\Rank13.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank14 FILE=Textures\Rank14.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank15 FILE=Textures\Rank15.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank16 FILE=Textures\Rank16.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank17 FILE=Textures\Rank17.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank18 FILE=Textures\Rank18.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank19 FILE=Textures\Rank19.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank20 FILE=Textures\Rank20.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank21 FILE=Textures\Rank21.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank22 FILE=Textures\Rank22.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank23 FILE=Textures\Rank23.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank24 FILE=Textures\Rank24.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank25 FILE=Textures\Rank25.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank26 FILE=Textures\Rank26.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank27 FILE=Textures\Rank27.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank28 FILE=Textures\Rank28.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank29 FILE=Textures\Rank29.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Rank30 FILE=Textures\Rank30.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5

var int LastUpdateTime;

var Texture Box;
var Texture BaseTex;
var Texture ShieldTexture;
var Texture DefaultShieldTexture;
var Texture FlagTexture;
var Texture DefaultFlagTexture;
var Texture RankTex[30];

var byte  BaseAlpha;
var int   MaxTeamSize;
var int      MaxTeamPlayers;
var int      MaxSpectators;

var config bool bEnableColoredNamesOnScoreboard;
var config bool bEnableColoredNamesOnHUD;

var config int LocationNameMaxLength;

simulated function SetCustomBarColor(out Color C, PlayerReplicationInfo PRI, bool bOwner);
simulated function SetCustomLocationColor(out Color C, PlayerReplicationInfo PRI, bool bOwner);

simulated function DrawRank(Canvas C, int X, int Y, int W, int H, float Rank)
{
    local int i;
    
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;    

    i = FClamp(Rank,0,1) * (ArrayCount(RankTex)-1);
    C.SetPos(X, Y);
    C.DrawTile(RankTex[i], W,H, 0,0,64,64);
}

simulated function DrawHeader(Canvas C, int BarX, int BarY, int BarW, int BarH)
{
    local float XL, YL;
    local string name;
    local int TitleX, TitleY;
    local int SubTitleX, SubTitleY;
    local int URLX, URLY;
    local int DateTimeX, DateTimeY;
    
    TitleX = C.ClipX * 0.01;
    TitleY = C.ClipY * 0.01;
    SubTitleX = C.ClipX * 0.01;
    SubTitleY = C.ClipY * 0.04;
    URLX = C.ClipX * 0.99;
    URLY = C.ClipY * 0.01;
    DateTimeX = C.ClipX * 0.99;
    DateTimeY = C.ClipY * 0.04;
    
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -1);

    // BACKGROUND
    
    C.DrawColor = HUDClass.default.BlackColor;
    C.DrawColor.A = BaseAlpha;

    C.SetPos(BarX, BarY);
    C.DrawTile(Box, BarW,BarH, 0,0,16,16);

    // TITLE
    
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    name = GRI.GameName$MapName$Level.Title;
    C.StrLen(name, XL, YL);
    C.SetPos(BarX + TitleX, BarY + TitleY);
    C.DrawText(name);

    // SUBTITLE
    
    if(UnrealPlayer(Owner).bDisplayLoser)
        name = class'HUDBase'.default.YouveLostTheMatch;
    else if(UnrealPlayer(Owner).bDisplayWinner)
        name = class'HUDBase'.default.YouveWonTheMatch;
    else
    {
        name = FragLimit@GRI.GoalScore;
        if(GRI.TimeLimit != 0)
            name = name@spacer@TimeLimit@FormatTime(GRI.RemainingTime);
        else
            name = name@spacer@FooterText@FormatTime(GRI.ElapsedTime);
    }

    C.DrawColor = HUDClass.default.RedColor * 0.7;
    C.DrawColor.G = 130;
    C.StrLen(name, XL, YL);
    C.SetPos(BarX + SubTitleX, BarY + SubTitleY);
    C.DrawText(name);
    
    // URL
    
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    name = "An Unreal Community";
    if(Misc_BaseGRI(GRI) != None)
    {
        if(Misc_BaseGRI(GRI).ScoreboardCommunityName != "")
            name = Misc_BaseGRI(GRI).ScoreboardCommunityName;
    }
    C.StrLen(name, XL, YL);
    C.SetPos(BarX + URLX - XL, BarY + URLY);
    C.DrawText(name);
    
    // DATE TIME
    
    name = "";
    if(Level.Month < 10)
        name = "0";
    name = name$Level.Month$"/";
    if(Level.Day < 10)
        name = name$"0";
    name = name$Level.Day$"/"$Level.Year@"- ";
    if(Level.Hour < 10)
        name = name$"0";
    name = name$Level.Hour$":";
    if(Level.Minute < 10)
        name = name$"0";
    name = name$Level.Minute$":";
    if(Level.Second < 10)
        name = name$"0";
    name = name$Level.Second;

    C.DrawColor = HUDClass.default.RedColor * 0.7;
    C.DrawColor.G = 130;
    C.StrLen(name, XL, YL);
    C.SetPos(BarX + DateTimeX - XL, BarY + DateTimeY);
    C.DrawText(name);    
}

simulated function DrawRoundTime(Canvas C, int BoxX, int BoxY)
{
    local string name;
    local float XL, YL;
    
    if(Misc_BaseGRI(GRI).SecsPerRound==0)
        return;
    
    // ROUND TIME
    
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;    
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, 0);
    
    name = FormatTime(Misc_BaseGRI(GRI).RoundTime);
    C.StrLen(name, XL, YL);
    C.SetPos(BoxX - (XL * 0.5), BoxY - (YL * 0.5));
    C.DrawText(name);
}

simulated function DrawTeamScores(Canvas C, int BoxX, int BoxY, int BoxW, int BoxH, string GameName, string Acronym, int RedScore, int BlueScore)
{
    local int RedScoreX;
    local int RedScoreY;
    local int BlueScoreX;
    local int BlueScoreY;
    local int SeparatorX;
    local int SeparatorY;
    local int GameNameX;
    local int GameNameW;
    local int GameNameY;
    local int AcronymX;
    local int AcronymW;
    local int AcronymY;
    local string name;
    local float XL, YL, W, H;

    RedScoreX = BoxW * 0.30;
    RedScoreY = BoxH * 0.47;
    BlueScoreX = BoxW * 0.70;
    BlueScoreY = BoxH * 0.47;
    SeparatorX = BoxW * 0.50;
    SeparatorY = BoxH * 0.47;
    GameNameX = BoxW * 0.50;
    GameNameW = BoxW * 0.71;
    GameNameY = BoxH * 0.205;
    AcronymX = BoxW * 0.50;
    AcronymW = BoxW * 0.576;
    AcronymY = BoxH * 0.835;
    
    // DRAW SHIELD
  
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;

  if(Misc_BaseGRI(GRI).FlagTextureEnabled) {
    if(FlagTexture == None) {
      if(Len(Misc_BaseGRI(GRI).FlagTextureName)>0) {
        FlagTexture = Texture(DynamicLoadObject(Misc_BaseGRI(GRI).FlagTextureName, class'Texture', True));
      }
      if(FlagTexture == None) {
        FlagTexture = DefaultFlagTexture;
      }
    }
    
    XL = BoxX + BoxW*207/512;
    YL = BoxY + BoxH*350/512;
    W = BoxW*100/512;
    H = BoxH*127/512;
    C.SetPos(XL, YL);
    C.DrawTile(FlagTexture, W, H, 0,0,128,128);
  }
    
  if(ShieldTexture == None) {
    if(Len(Misc_BaseGRI(GRI).ShieldTextureName)>0) {
      ShieldTexture = Texture(DynamicLoadObject(Misc_BaseGRI(GRI).ShieldTextureName, class'Texture', True));
    }
    if(ShieldTexture == None) {
      ShieldTexture = DefaultShieldTexture;
    }
  }
  
    C.SetPos(BoxX, BoxY);
    C.DrawTile(ShieldTexture, BoxW, BoxH, 0,0,512,512);

    // GAME NAME

  if(Misc_BaseGRI(GRI).ShowServerName) {
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -4);
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;
    
    name = GameName;
    C.StrLen(name, XL, YL);
    if(XL > GameNameW)
    {
      name = Left(name, GameNameW / XL * len(name));
      C.StrLen(name, XL, YL);
    }
    C.SetPos(BoxX + GameNameX - (XL * 0.5), BoxY + GameNameY - (YL * 0.5));
      C.DrawText(name);
  }
  
    // ACRONYM
  if(Misc_BaseGRI(GRI).FlagTextureShowAcronym) {
      C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -5);
    C.DrawColor = HUDClass.default.RedColor;
    C.DrawColor.A = BaseAlpha;
    
    name = Acronym;
    C.StrLen(name, XL, YL);
    if(XL > AcronymW)
    {
      name = Left(name, AcronymW / XL * len(name));
      C.StrLen(name, XL, YL);
    }
    C.SetPos(BoxX + AcronymX - (XL * 0.5), BoxY + AcronymY - (YL * 0.5));
      C.DrawText(name);
  }
  
    
    // TEAM SCORE RED
    
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, 1);
    C.DrawColor = HUDClass.default.RedColor * 0.7;
    name = string(RedScore);
    C.StrLen(name, XL, YL);
    C.SetPos(BoxX + RedScoreX - (XL * 0.5), BoxY + RedScoreY - (YL * 0.5));
    C.DrawText(name);

    // TEAM SCORE BLUE
    
    C.DrawColor = HUDClass.default.TurqColor * 0.7;
    name = string(BlueScore);
    C.StrLen(name, XL, YL);
    C.SetPos(BoxX + BlueScoreX - (XL * 0.5), BoxY + BlueScoreY - (YL * 0.5));
    C.DrawText(name);
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
    local int PingX, PingY;
    local int PLX, PLY;
    local float XL, YL;
    local string name;
    
    NameX = BarW * 0.031;
    NameY = C.ClipY * 0.01;
    StatX = BarW * 0.051;
    StatY = C.ClipY * 0.035;
    ScoreX = BarW * 0.59;
    ScoreY = C.ClipY * 0.01;
    PointsPerX = BarW * 0.59;
    PointsPerY = C.ClipY * 0.035;
    KillsX = BarW * 0.71;
    KillsY = C.ClipY * 0.01;
    DeathsX = BarW * 0.71;
    DeathsY = C.ClipY * 0.035;
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
    local int PingX, PingY;
    local int PLX, PLY;
    local string name;
    local float XL, YL;
    local Misc_PRI OwnerPRI;
    local int OwnerTeam;

    OwnerPRI = Misc_PRI(PlayerController(Owner).PlayerReplicationInfo);
    
    if(OwnerPRI.Team != None)
        OwnerTeam = OwnerPRI.Team.TeamIndex;
    else
        OwnerTeam = 255;
    
    NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
    NameW = BarW * 0.47;
    StatX = BarW * 0.051;
    StatY = C.ClipY * 0.035;
    ScoreX = BarW * 0.59;
    ScoreY = C.ClipY * 0.0075;
    PointsPerX = BarW * 0.59;
    PointsPerY = C.ClipY * 0.035;
    KillsX = BarW * 0.71;
    KillsY = C.ClipY * 0.0075;
    DeathsX = BarW * 0.71;
    DeathsY = C.ClipY * 0.035;
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
    
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);
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
	
	name = class'TAM_HUD'.static.TruncStr(name, LocationNameMaxLength, "...");
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

    name = class'Misc_PRI'.static.GetFormattedPPR(XL);
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
    local int KillsX, KillsY;
    local int PingX, PingY;
    local int PPRX, PPRY;
    local string name;
    local float XL, YL;
    
    NameX = BarW * 0.031;
    NameY = C.ClipY * 0.0075;
    ScoreX = BarW * 0.59;
    ScoreY = C.ClipY * 0.0075;
    KillsX = BarW * 0.71;
    KillsY = C.ClipY * 0.0075;
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

simulated function DrawSpecList(Canvas C, int BoxX, int BoxY, int BoxW, array<PlayerReplicationInfo> Specs)
{
    local float XL, YL, YL2;
    local int TitleX, TitleY;
    local int PingX, PingY;
    local int TitleSeparatorH, EndSeparatorH;
    local int NameX, NameY;
    local int BoxH;
    local string name;
    local int i;
    local PlayerReplicationInfo PRI;
    local string NameColor;
    local string PingColor;
    
    TitleX = BoxW * 0.031;
    TitleY = C.ClipY * 0.005;
    PingX = BoxW * 0.85;
    PingY = C.ClipY * 0.005;
    NameX = BoxW * 0.093;
    TitleSeparatorH = C.ClipY * 0.0025;
    EndSeparatorH = C.ClipY * 0.005;
    
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -5);
    name = "Spectator";
    C.StrLen(name, XL, YL);
    
    BoxH = YL * (Min(MaxSpectators, Specs.Length) + 1) + TitleY + TitleSeparatorH*2 + EndSeparatorH;
    BoxY -= BoxH;

    // TITLE BACKGROUND

    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;
    C.SetPos(BoxX, BoxY);
    C.DrawTile(BaseTex, BoxW, TitleY+YL+TitleSeparatorH, 17,31,751,71);
    
    // LIST BACKGROUND
    
    C.DrawColor = HUDClass.default.BlackColor;
    C.DrawColor.A = BaseAlpha * 0.5;
    C.SetPos(BoxX, BoxY+TitleY+YL+TitleSeparatorH);
    C.DrawTile(Box, BoxW, BoxH-(TitleY+YL+TitleSeparatorH), 0,0,16,16);
    
    // NAME
    
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    C.SetPos(BoxX+TitleX, BoxY+TitleY);
    C.DrawText(name);
    
    // PING
    
    name = "Ping";
    C.StrLen(name, XL, YL2);
    C.SetPos(BoxX + PingX - (XL * 0.5), BoxY + PingY);
    C.DrawText(name);

    // SPECTATOR LIST
    
    NameColor = class'DMStatsScreen'.static.MakeColorCode(class'Canvas'.static.MakeColor(178, 130, 0));
    PingColor = class'DMStatsScreen'.static.MakeColorCode(class'Canvas'.static.MakeColor(20, 127, 150));

    NameY = TitleY + YL + TitleSeparatorH*2;
    
    for(i=0; i<Specs.Length; ++i)
    {
        PRI = Specs[i];
    
        if(default.bEnableColoredNamesOnScoreBoard && Misc_PRI(PRI)!=None && Misc_PRI(PRI).GetColoredName() !="")
            name = NameColor $ Misc_PRI(PRI).GetColoredName();
        else
            name = NameColor $ PRI.PlayerName;
        
        C.SetPos(BoxX + NameX, BoxY + NameY);
        class'Misc_Util'.static.DrawTextClipped(C, name, PingX-(BoxW-PingX)-NameX);
        
        name = PingColor $ "[" $ PRI.Ping *4 $ "]";
        C.StrLen(name, XL, YL2);
        C.SetPos(BoxX + PingX - (XL*0.5), BoxY + NameY);
        C.DrawText(name);
        
        NameY += YL;
    }
}

simulated function DrawTeamBoard(Canvas C, int BoxX, int BoxY, int BoxW, string TeamName, Color TeamCol, array<PlayerReplicationInfo> Players, int MaxPlayers)
{
    local int i;
    local PlayerReplicationInfo PRI, OwnerPRI;
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

        TeamPing += PRI.Ping;
        TeamScore += PRI.Score;
        TeamKills += PRI.Kills;
        
        if(Misc_PRI(PRI)!=None && Misc_PRI(PRI).AvgPPR!=0)
        {
            TeamAvgPPR += Misc_PRI(PRI).AvgPPR;
            ++NumPPR;
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
    
        DrawPlayerTotalsBar(C, BarX, BarY, PlayerTotalsW, PlayerTotalsH, TeamName, TeamCol, TeamScore, TeamKills, TeamPing, TeamAvgPPR);
    }
}

simulated event UpdateScoreBoard(Canvas C)
{
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i;
    
    local array<PlayerReplicationInfo> Reds;
    local array<PlayerReplicationInfo> Blues;
    local array<PlayerReplicationInfo> Specs;

    local int HeaderX;
    local int HeaderY;
    local int HeaderW;
    local int HeaderH;

    local int RoundTimeX;
    local int RoundTimeY;
    
    local int RedScoreBoardX;
    local int BlueScoreBoardX;
    local int ScoreBoardY;
    local int ScoreBoardW;
    
    local int TeamScoreX;
    local int TeamScoreY;
    local int TeamScoreW;
    local int TeamScoreH;

    local int SpecBoxX;
    local int SpecBoxY;
    local int SpecBoxW;
    
    local Color RedBackgroundCol;
    local Color BlueBackgroundCol;

    local string RedTeamLabel;
    local string BlueTeamLabel;
    
    RedBackgroundCol.R = 255;
    RedBackgroundCol.G = 50;
    RedBackgroundCol.B = 0;
    RedBackgroundCol.A = BaseAlpha * 0.75;
    
    BlueBackgroundCol.R = 50;
    BlueBackgroundCol.G = 178;
    BlueBackgroundCol.B = 255;
    BlueBackgroundCol.A = BaseAlpha * 0.75;
        
    if(GRI==None)
        return;
        
    // GET PLAYER INFORMATION

    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
    if(OwnerPRI==None)
        return;
    
    Reds.Length = 0;
    Blues.Length = 0;
    Specs.Length = 0;
    
    for(i = 0; i < GRI.PRIArray.Length; i++)
    {
        PRI = GRI.PRIArray[i];
        if(PRI == None)
            continue;

        if(PRI.Team==None)
        {
            if(!PRI.bOnlySpectator)
                continue;
                
            if(Specs.Length < MaxSpectators)
            {
                Specs.Insert(Specs.Length,1);
                Specs[Specs.Length-1] = PRI;
            }
            else if(PRI == OwnerPRI)
            {
                Specs[Specs.Length-1] = PRI;
            }
            continue;
        }
        
        if(Level.TimeSeconds - LastUpdateTime > 4)
            Misc_Player(Owner).ServerUpdateStats(TeamPlayerReplicationInfo(PRI));
        
        if(PRI.Team.TeamIndex == 0)
        {
            if(Reds.Length < MaxTeamSize)
            {
                Reds.Insert(Reds.Length,1);
                Reds[Reds.Length-1] = PRI;
            }
            else if(PRI == OwnerPRI)
            {
                Reds[Reds.Length-1] = PRI;
            }
        }
        else if(PRI.Team.TeamIndex == 1)
        {
            if(Blues.Length < MaxTeamSize)
            {
                Blues.Insert(Blues.Length,1);
                Blues[Blues.Length-1] = PRI;
            }
            else if(PRI == OwnerPRI)
            {
                Blues[Blues.Length-1] = PRI;
            }
        }
    }    
    
    MaxTeamPlayers = Max(MaxTeamPlayers,Max(Reds.Length, Blues.Length));
    
    HeaderX = 0.00;
    HeaderY = 0.00;
    HeaderW = C.ClipX;
    HeaderH = C.ClipY * 0.08;

    RoundTimeX = C.ClipX * 0.50;
    RoundTimeY = C.ClipY * 0.35;
    
    RedScoreBoardX = C.ClipX * 0.01;
    BlueScoreBoardX = C.ClipX * 0.59;
    ScoreBoardY = C.ClipY * 0.23;
    ScoreBoardW = C.ClipX * 0.40;
    
    TeamScoreX = C.ClipX * 0.4;
    TeamScoreY = C.ClipY * 0.4;
    TeamScoreW = C.ClipX * 0.2;
    TeamScoreH = C.ClipY * 0.2;

    SpecBoxX = C.ClipX * 0.42;
    SpecBoxY = C.ClipY * 0.915;
    SpecBoxW = C.ClipX * 0.16;
    
    C.Style = ERenderStyle.STY_Alpha;
    
    DrawHeader(C, HeaderX, HeaderY, HeaderW, HeaderH);
    DrawRoundTime(C, RoundTimeX, RoundTimeY);
    DrawTeamScores(C, TeamScoreX, TeamScoreY, TeamScoreW, TeamScoreH, GRI.ShortName, Misc_BaseGRI(GRI).Acronym, GRI.Teams[0].Score, GRI.Teams[1].Score);        
    
    if(MaxTeamPlayers>0)
    {
        RedTeamLabel = "Red Team";
        BlueTeamLabel= "Blue Team";
        if(Misc_BaseGRI(GRI) != None)
        {
            if(Misc_BaseGRI(GRI).ScoreboardRedTeamName != "")
                RedTeamLabel= Misc_BaseGRI(GRI).ScoreboardRedTeamName;

            if(Misc_BaseGRI(GRI).ScoreboardBlueTeamName != "")
                BlueTeamLabel= Misc_BaseGRI(GRI).ScoreboardBlueTeamName;
        }

        DrawTeamBoard(C, RedScoreBoardX, ScoreBoardY, ScoreBoardW, RedTeamLabel, RedBackgroundCol, Reds, MaxTeamPlayers);
        DrawTeamBoard(C, BlueScoreBoardX, ScoreBoardY, ScoreBoardW, BlueTeamLabel, BlueBackgroundCol, Blues, MaxTeamPlayers);
    }
    
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
    Box=Texture'Engine.WhiteSquareTexture'
	LocationNameMaxLength=28
    BaseTex=Texture'3SPN_Enhanced_A.Textures.ScoreBoard'
    DefaultShieldTexture=Texture'3SPN_Enhanced_A.Textures.Shield'
    DefaultFlagTexture=Texture'3SPN_Enhanced_A.Textures.FlagDefault'
    RankTex(0)=Texture'3SPN_Enhanced_A.Textures.Rank1'
    RankTex(1)=Texture'3SPN_Enhanced_A.Textures.Rank2'
    RankTex(2)=Texture'3SPN_Enhanced_A.Textures.Rank3'
    RankTex(3)=Texture'3SPN_Enhanced_A.Textures.Rank4'
    RankTex(4)=Texture'3SPN_Enhanced_A.Textures.Rank5'
    RankTex(5)=Texture'3SPN_Enhanced_A.Textures.Rank6'
    RankTex(6)=Texture'3SPN_Enhanced_A.Textures.Rank7'
    RankTex(7)=Texture'3SPN_Enhanced_A.Textures.Rank8'
    RankTex(8)=Texture'3SPN_Enhanced_A.Textures.Rank9'
    RankTex(9)=Texture'3SPN_Enhanced_A.Textures.Rank10'
    RankTex(10)=Texture'3SPN_Enhanced_A.Textures.Rank11'
    RankTex(11)=Texture'3SPN_Enhanced_A.Textures.Rank12'
    RankTex(12)=Texture'3SPN_Enhanced_A.Textures.Rank13'
    RankTex(13)=Texture'3SPN_Enhanced_A.Textures.Rank14'
    RankTex(14)=Texture'3SPN_Enhanced_A.Textures.Rank15'
    RankTex(15)=Texture'3SPN_Enhanced_A.Textures.Rank16'
    RankTex(16)=Texture'3SPN_Enhanced_A.Textures.Rank17'
    RankTex(17)=Texture'3SPN_Enhanced_A.Textures.Rank18'
    RankTex(18)=Texture'3SPN_Enhanced_A.Textures.Rank19'
    RankTex(19)=Texture'3SPN_Enhanced_A.Textures.Rank20'
    RankTex(20)=Texture'3SPN_Enhanced_A.Textures.Rank21'
    RankTex(21)=Texture'3SPN_Enhanced_A.Textures.Rank22'
    RankTex(22)=Texture'3SPN_Enhanced_A.Textures.Rank23'
    RankTex(23)=Texture'3SPN_Enhanced_A.Textures.Rank24'
    RankTex(24)=Texture'3SPN_Enhanced_A.Textures.Rank25'
    RankTex(25)=Texture'3SPN_Enhanced_A.Textures.Rank26'
    RankTex(26)=Texture'3SPN_Enhanced_A.Textures.Rank27'
    RankTex(27)=Texture'3SPN_Enhanced_A.Textures.Rank28'
    RankTex(28)=Texture'3SPN_Enhanced_A.Textures.Rank29'
    RankTex(29)=Texture'3SPN_Enhanced_A.Textures.Rank30'
    BaseAlpha=200
    MaxTeamSize=12
    MaxSpectators=19
    bEnableColoredNamesOnScoreboard=True
    bEnableColoredNamesOnHUD=True
}
