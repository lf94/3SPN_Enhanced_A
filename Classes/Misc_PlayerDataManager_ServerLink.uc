class Misc_PlayerDataManager_ServerLink extends Actor
	config;
	
var array<Misc_PlayerData> PlayerDataArray;

var string 	ServerLinkAddress;
var int 	ServerLinkPort;
var string 	ServerLinkAccount;
var string 	ServerLinkPassword;
var Misc_ServerLink ServerLink;

function ConfigureServerLink(string ServerLinkAddressIn, int ServerLinkPortIn, string ServerLinkAccountIn, string ServerLinkPasswordIn)
{
	ServerLinkAddress = ServerLinkAddressIn;
	ServerLinkPort = ServerLinkPortIn;
	ServerLinkAccount = ServerLinkAccountIn;
	ServerLinkPassword = ServerLinkPasswordIn;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(30, true);
}

function Destroyed()
{
    if(ServerLink != None)
    {
        ServerLink.Close();
        ServerLink = None;
    }

    Super.Destroyed();
}

function Misc_ServerLink GetServerLink()
{
	if(ServerLink != None)
		return ServerLink;

	ServerLink = spawn(class'Misc_ServerLink');
	if(ServerLink != None)
	{
		ServerLink.OnReceivedStats = self.ReceiveStats;
		ServerLink.OnReceivedListName = self.ReceiveListName;
		ServerLink.OnReceivedListIdx = self.ReceiveListIdx;
		ServerLink.Connect(ServerLinkAddress, ServerLinkPort, ServerLinkAccount, ServerLinkPassword);
	}

	return ServerLink;
}

function Misc_PlayerData PlayerJoined(Misc_Player P)
{
	local Misc_PlayerData PD;
	local Misc_ServerLink SL;
	local string StatsID;
	local int i;
	
	Log("PlayerJoined: "$P.PlayerReplicationInfo.PlayerName);

	StatsID = class'Misc_Util'.static.GetStatsID(P);
	if(StatsID == "")
	{
		Log("No stats ID for "$P.PlayerReplicationInfo.PlayerName);
		return None;
	}
	
	for(i=0; i<PlayerDataArray.Length; ++i)
	{
		PD = PlayerDataArray[i];
		if(PD==None)
			continue;
			
		if(PD.StatsID == StatsID)
		{
			Log("Existing player record found for "$P.PlayerReplicationInfo.PlayerName);
			class'Misc_PlayerData'.static.AttachPlayerRecord(P, PD);
			P.LoadPlayerData();
			return PD;
		}
	}

	PD = new class'Misc_PlayerData';
	class'Misc_PlayerData'.static.ResetTrackedData(PD.Current);
	class'Misc_PlayerData'.static.ResetStats(PD);
	class'Misc_PlayerData'.static.AttachPlayerRecord(P, PD);
	PD.StatsReceived = false;
	
	i = PlayerDataArray.Length;
	PlayerDataArray.Length = i+1;
	PlayerDataArray[i] = PD;

	SL = GetServerLink();
	if(SL != None)
	{
		Log("Requesting stats for player "$P.PlayerReplicationInfo.PlayerName);
		SL.RequestStats(i, PD.StatsID);
	}
	
	return None;
}

function PlayerLeft(Misc_Player P)
{
	Log("PlayerLeft: "$P.PlayerReplicationInfo.PlayerName);
	P.StorePlayerData();
	if(P.PlayerData!=None)
		class'Misc_PlayerData'.static.DetachPlayerRecord(P.PlayerData);
}

function PlayerChangedName(Misc_Player P)
{
	local string PlayerName;
	
	Log("PlayerChangedName: "$P.PlayerReplicationInfo.PlayerName);
	
	PlayerName = class'Misc_Util'.static.StripColor(P.PlayerReplicationInfo.PlayerName);
	ReplaceText(PlayerName, " ", "_");
	ReplaceText(PlayerName, "]", "_");
	
	if(P.PlayerData!=None)
		P.PlayerData.OwnerName = PlayerName;
}

function ReceiveStats(int PlayerIndex, float Rank, float AvgPPR)
{
	local Misc_PlayerData PD;
	
	if(PlayerIndex >= PlayerDataArray.Length)
		return;

	PD = PlayerDataArray[PlayerIndex];
	PD.Rank = Rank;
	PD.AvgPPR = AvgPPR;
	PD.StatsReceived = true;
	
	if(PD.Owner != None)
		PD.Owner.LoadPlayerDataStats();
}

function ReceiveListName(string ListName)
{
	if(Team_GameBase(Level.Game)!=None)
		Team_GameBase(Level.Game).SendStatsListNameToPlayers(ListName);
}

function ReceiveListIdx(int PlayerIndex, string PlayerName, string PlayerStat)
{
	if(Team_GameBase(Level.Game)!=None)
		Team_GameBase(Level.Game).SendStatsListIdxToPlayers(PlayerIndex, PlayerName, PlayerStat);
}

function FinishMatch()
{
	local Misc_PlayerData PD;
	local Misc_ServerLink SL;
	local int i, PlayerCnt;
	local string TimeString, TeamScoreStr, MapName;
	local Team_GameBase TGB;
	
	SL = GetServerLink();
	if(SL == None)
		return;

	TGB = Team_GameBase(Level.Game);
	if(TGB != None && TGB.Teams[0] != None && TGB.Teams[1] != None)
	{
		if(TGB.Teams[0].Score == 0 && TGB.Teams[1].Score == 0)
			return;
		TeamScoreStr = int(TGB.Teams[0].Score)$","$int(TGB.Teams[1].Score);
	}
		
	Log("Registering match stats...");

	TimeString = class'Misc_Util'.static.GetTimeStringFromLevel(Level);	
	if(TimeString == "")
	{
		Log("Error: Unable to get match time");
		return;
	}

	// count number of active players to make sure we have at least 1
	PlayerCnt = 0;
	for(i=0; i<PlayerDataArray.Length; ++i)
	{
		PD = PlayerDataArray[i];
		if(PD==None)
			continue;

		if(PD.Owner!=None)
			PD.Owner.StorePlayerData();
			
		if(PD.Current.Score == 0 && PD.Current.Kills == 0 && PD.Current.Deaths == 0 && PD.Current.Thaws == 0 && PD.Current.Git == 0)
			continue;

		++PlayerCnt;
	}

	if(PlayerCnt == 0)
	{
		Log("No active players in match");
		return;
	}
	
	MapName = class'Misc_Util'.static.GetMapName(Level);
	Log("Registering match with time: "$TimeString$", map: "$MapName$", team scores: "$TeamScoreStr);
	
	SL.RegisterGame(TimeString, MapName, TeamScoreStr);
	
	for(i=0; i<PlayerDataArray.Length; ++i)
	{
		PD = PlayerDataArray[i];
		if(PD==None)
			continue;

		// Already stored above
		//if(PD.Owner!=None)
			//PD.Owner.StorePlayerData();
			
		if(PD.Current.Score == 0 && PD.Current.Kills == 0 && PD.Current.Deaths == 0 && PD.Current.Thaws == 0 && PD.Current.Git == 0)
			continue;

		Log("Sending results for "$PD.OwnerID$" - "$PD.OwnerName$" (index:"$PD.StatsIndex$")");
		SL.RegisterStats(TimeString, PD.OwnerName, PD.StatsID, PD.TeamIdx, PD.Current.Rounds, PD.Current.Score, PD.Current.Kills, PD.Current.Deaths, PD.Current.Thaws, PD.Current.Git);
	}
}

function GetRandomStats()
{
	local Misc_ServerLink SL;
	
	SL = GetServerLink();
	if(SL == None)
		return;
		
	SL.RequestStatsList();
}

function Timer()
{
	local Misc_PlayerData PD;
	local Misc_ServerLink SL;
	local int i;
	
	SL = GetServerLink();
	if(SL != None)
	{	
		for(i=0; i<PlayerDataArray.Length; ++i)
		{
			PD = PlayerDataArray[i];
			if(PD==None)
				continue;
				
			if(PD.StatsReceived == false)
			{
				SL.RequestStats(i, PD.StatsID);
			}
		}
	}
	
	Super.Timer();
}

defaultproperties
{
	RemoteRole=ROLE_None
	bHidden=True
	bOnlyDirtyReplication=True
	bSkipActorPropertyReplication=True
}