class Misc_PlayerData extends Object;

var Misc_Player Owner;
var string OwnerName;
var string OwnerID; // unique PlayerID of person who owns this name
var int LastActiveTime; // time when player was last seen (HOURS)
var string StatsID;
var int StatsIndex; // which stats index to use for this match (based on join time)
var int TeamIdx;
var bool StatsReceived;
var float Rank;
var float AvgPPR;

struct TrackedData
{
	var int Rounds;
	var float Score;
	var int Kills;
	var int Deaths;
	var int Thaws;
	var int Git;
};
var config TrackedData Current;

static function AttachPlayerRecord(Misc_Player P, Misc_PlayerData PD)
{
	local string PlayerName;
	
	PlayerName = class'Misc_Util'.static.StripColor(P.PlayerReplicationInfo.PlayerName);
	ReplaceText(PlayerName, " ", "_");
	ReplaceText(PlayerName, "]", "_");

	if(P.PlayerReplicationInfo.Team != None)
		PD.TeamIdx = P.PlayerReplicationInfo.Team.TeamIndex;
	
	PD.OwnerName = PlayerName;
	PD.OwnerID = P.GetPlayerIDHash();
	PD.StatsID = class'Misc_Util'.static.GetStatsID(P);
	PD.Owner = P;
	P.PlayerData = PD;
}

static function DetachPlayerRecord(Misc_PlayerData PD)
{
	if(PD.Owner!=None)
		PD.Owner.PlayerData = None;
	PD.Owner = None;
}

// returns true if the stats were migrated to the new name
static function PlayerChangeName(Misc_Player P)
{
	local string PlayerName;
	
	if(P.PlayerData==None || P.PlayerReplicationInfo==None)
		return;
		
	PlayerName = class'Misc_Util'.static.StripColor(P.PlayerReplicationInfo.PlayerName);
	ReplaceText(PlayerName, " ", "_");
	ReplaceText(PlayerName, "]", "_");

	P.PlayerData.OwnerName = PlayerName;
}

static function ResetStats(Misc_PlayerData PD)
{
	PD.Rank = 0;
	PD.AvgPPR = 0;
}

static function ResetTrackedData(out TrackedData d)
{
	d.Rounds = 0;
	d.Score = 0;
	d.Kills = 0;
	d.Deaths = 0;
	d.Thaws = 0;
	d.Git = 0;
}

static function AddTrackedData(out TrackedData d1, TrackedData d2)
{
	d1.Rounds += d2.Rounds;
	d1.Score += d2.Score;
	d1.Kills += d2.Kills;
	d1.Deaths += d2.Deaths;
	d1.Thaws += d2.Thaws;
	d1.Git += d2.Git;
}

defaultproperties
{
}