class Team_GameBase extends TeamGame
    abstract
    config;

#exec OBJ LOAD FILE=TeamSymbols.utx
#exec AUDIO IMPORT FILE="Sounds\Overtime.wav" GROUP=Sounds

/* general and misc */
var config int      StartingHealth;
var config int      StartingArmor;
var config float    MaxHealth;

var config float    AdrenalinePerDamage;     // adrenaline per 10 damage
var config float    ScoreAwardPer10Damage;   // score adjustment per 10 damage

var config bool     bDisableSpeed;
var config bool     bDisableBooster;
var config bool     bDisableInvis;
var config bool     bDisableBerserk;
var array<string>   EnabledCombos;

var config bool     bForceRUP;              // force players to ready up after...
var config int      ForceRUPMinPlayers;
var config int      ForceSeconds;           // this many seconds

var Controller      DarkHorse;              // last player on a team when the other team has 3+
var string          NextMapString;          // used to save mid-game admin changes in the menu

var byte            Deaths[2];              // set to true if someone on a given team has died (not a flawless)

var bool            bDefaultsReset;
/* general and misc */

/* overtime related */
var config int      SecsPerRound;           // the number of seconds before a round goes into OT
var int             RoundTime;              // number of seconds remaining before round-OT
var bool            bRoundOT;               // true if we're in round-OT
var int             RoundOTTime;            // how long we've been in round-OT
var config int      OTDamage;               // the amount of damage players take in round-OT every...
var config int      OTInterval;             // <OTInterval> seconds
/* overtime related */

/* camping related */
var config float    CampThreshold;          // area a player must stay in to be considered camping
var int             CampInterval;           // time between flagging the same player
var config bool     bKickExcessiveCampers;  // kick players that camp 4 consecutive times
/* camping related */

/* timeout related */
var config int      Timeouts;               // number of timeouts per team

var byte            TimeOutTeam;            // team that called timeout
var PlayerController TimeOutPlayer;            // player that called timeout
var int             TeamTimeOuts[2];        // number of timeouts remaining per team
var int               TimeOutCount;           // time remaining in timeout
var float            TimeOutRemainder;        // float remainder for timeout
var float           LastTimeOutUpdate;      // keep track of the last update so timeout requests aren't spammed
var config int        TimeOutDuration;
/* timeout related */

/* spawn related */
var bool            bFirstSpawn;            // first spawn of the round
/* spawn related */

/* round related */
var bool            bEndOfRound;            // true if a round has just ended
var bool            bRespawning;            // true if we're respawning players
var int             RespawnTime;            // time left to respawn
//var int             LockTime;               // time left until weapons get unlocked
var int             NextRoundTime;          // time left until the next round starts
var config int      NextRoundDelay;
var int             CurrentRound;           // the current round number (0 = game hasn't started)
/* round related */

/* weapon related */
var config bool    bModifyShieldGun;     // use the modified shield gun (higher shield jumps)
var config int  AssaultAmmo;
var config int  AssaultGrenades;
var config int  BioAmmo;
var config int  ShockAmmo;
var config int  LinkAmmo;
var config int  MiniAmmo;
var config int  FlakAmmo;
var config int  RocketAmmo;
var config int  LightningAmmo;
/* weapon related */

/* extended functionality */
var config int                EndOfRoundDelay;        // allows you to delay the end of round to give time for resurrection to register
var int                     EndOfRoundTime;         // time left until the end of round is registered
var PlayerReplicationInfo    EndOfRoundScorer;        // parameter to pass to EndRound() function

var config bool             RoundCanTie;              // can the game end in a tie if everyone is dead?

var bool                    EndGameCalled;
/* extended functionality */

/* newnet */
var config bool EnableNewNet;
var TAM_Mutator MutTAM;
/* newnet */

var int WinningTeamIndex;
var array<Controller> EndCeremonyRankings;
struct SEndCeremonyInfo
{
    var string PlayerName;
    var string CharacterName;
    var int PlayerTeam;
    var vector SpawnPos;
    var rotator SpawnRot;
};
var SEndCeremonyInfo ServerEndCeremonyInfo[10];
var int EndCeremonyPlayerCount;
var int EndCeremonySoundIdx;
var config array<string> EndCeremonySound;
var config bool EndCeremonyEnabled;
var config bool EndCeremonyStatsEnabled;
var int EndCeremonyTimer;
var int EndCeremonyStatsListDisplayTime;

var config bool AllowPersistentStatsWithBots;
var Misc_PlayerDataManager_ServerLink PlayerDataManager_ServerLink;
var bool DisablePersistentStatsForMatch;
var bool MatchStatsRegistered;

var config bool bSpawnProtectionOnRez;

var config bool AutoBalanceTeams;
var config int AutoBalanceSeconds;
var config float AutoBalanceRandomization;
var config float AutoBalanceAvgPPRWeight;
var config bool AutoBalanceOnJoins;
var config bool AllowForceAutoBalance;
var config int ForceAutoBalanceCooldown;
var int ForceAutoBalanceTimer;
var bool TeamsAutoBalanced;
var array<Controller> DontAutoBalanceList;
var bool ForceAutoBalance;

enum EServerLinkStatus
{
        SL_DISABLED,
        SL_READONLY,
        SL_ENABLED
};

var config EServerLinkStatus   ServerLinkStatus;
var config string              ServerLinkAddress;
var config int                 ServerLinkPort;
var config string              ServerLinkAccount;
var config string              ServerLinkPassword;

var config string ScoreboardCommunityName;
var config string ScoreboardRedTeamName;
var config string ScoreboardBlueTeamName;

var config string ShieldTextureName;
var config string FlagTextureName;
var config bool ShowServerName;
var config bool FlagTextureEnabled;
var config bool FlagTextureShowAcronym;

var config string SoundAloneName;
var config string SoundSpawnProtectionName;

var config bool AllowServerSaveSettings;

var config bool AlwaysRestartServerWhenEmpty;

var Sound OvertimeSound;
var config bool bOverkillMessage;

//var config bool UseZAxisRadar; // don't make a config option
var bool UseZAxisRadar;


struct ControllerArray
{
    var array<Controller> C;
};

var config bool EnforceMaxPlayers;

var TournamentModuleBase TournamentModule;
var config string TournamentModuleClass;

/*
struct RestartInfo
{
    var Controller C;
    var int Timer;
};
var array<RestartInfo> RestartQueue;
var config int RestartPlayerDelay;
*/
static function PrecacheGameTextures(LevelInfo MyLevel)
{
    class'xTeamGame'.static.PrecacheGameTextures(MyLevel);
}

static function PrecacheGameStaticMeshes(LevelInfo MyLevel)
{
    class'xDeathMatch'.static.PrecacheGameStaticMeshes(MyLevel);
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(Misc_BaseGRI(GameReplicationInfo) == None)
        return;

    Misc_BaseGRI(GameReplicationInfo).RoundTime = SecsPerRound;

    Misc_BaseGRI(GameReplicationInfo).StartingHealth = StartingHealth;
    Misc_BaseGRI(GameReplicationInfo).StartingArmor = StartingArmor;
    Misc_BaseGRI(GameReplicationInfo).MaxHealth = MaxHealth;

    Misc_BaseGRI(GameReplicationInfo).SecsPerRound = SecsPerRound;
    Misc_BaseGRI(GameReplicationInfo).OTDamage = OTDamage;
    Misc_BaseGRI(GameReplicationInfo).OTInterval = OTInterval;

    Misc_BaseGRI(GameReplicationInfo).CampThreshold = CampThreshold;
    Misc_BaseGRI(GameReplicationInfo).bKickExcessiveCampers = bKickExcessiveCampers;

    Misc_BaseGRI(GameReplicationInfo).bDisableSpeed = bDisableSpeed;
    Misc_BaseGRI(GameReplicationInfo).bDisableInvis = bDisableInvis;
    Misc_BaseGRI(GameReplicationInfo).bDisableBooster = bDisableBooster;
    Misc_BaseGRI(GameReplicationInfo).bDisableBerserk = bDisableBerserk;

    Misc_BaseGRI(GameReplicationInfo).bForceRUP = bForceRUP;
    Misc_BaseGRI(GameReplicationInfo).ForceRUPMinPlayers = ForceRUPMinPlayers;

    Misc_BaseGRI(GameReplicationInfo).Timeouts = Timeouts;

    Misc_BaseGRI(GameReplicationInfo).Acronym = Acronym;
    Misc_BaseGRI(GameReplicationInfo).EnableNewNet = EnableNewNet;

    Misc_BaseGRI(GameReplicationInfo).ShieldTextureName = ShieldTextureName;
    Misc_BaseGRI(GameReplicationInfo).FlagTextureName = FlagTextureName;
    Misc_BaseGRI(GameReplicationInfo).ShowServerName = ShowServerName;
    Misc_BaseGRI(GameReplicationInfo).FlagTextureEnabled = FlagTextureEnabled;
    Misc_BaseGRI(GameReplicationInfo).FlagTextureShowAcronym = FlagTextureShowAcronym;

    Misc_BaseGRI(GameReplicationInfo).SoundAloneName = SoundAloneName;
    Misc_BaseGRI(GameReplicationInfo).SoundSpawnProtectionName = SoundSpawnProtectionName;

    Misc_BaseGRI(GameReplicationInfo).ScoreboardCommunityName = ScoreboardCommunityName;
    Misc_BaseGRI(GameReplicationInfo).ScoreboardRedTeamName = ScoreboardRedTeamName;
    Misc_BaseGRI(GameReplicationInfo).ScoreboardBlueTeamName = ScoreboardBlueTeamName;

    Misc_BaseGRI(GameReplicationInfo).UseZAxisRadar = UseZAxisRadar;
	Misc_BaseGRI(GameReplicationInfo).bOverkillMessage = bOverkillMessage;
    Misc_BaseGRI(GameReplicationInfo).ServerLinkStatus = ServerLinkStatus;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
    Super.GetServerDetails(ServerState);

    AddServerDetail(ServerState, "3SPN Version", class'Misc_BaseGRI'.default.Version);  // Misc_BaseGRI defaultproperties is where the displayed version is changed 
}

function GetServerPlayers(out ServerResponseLine ServerState)
{
    local Mutator M;
    local Controller C;
    local PlayerReplicationInfo PRI;
    local int i, TeamFlag[2];

    i = ServerState.PlayerInfo.Length;
    TeamFlag[0] = 1 << 29;
    TeamFlag[1] = TeamFlag[0] << 1;

    for( C=Level.ControllerList;C!=None;C=C.NextController )
        {
            PRI = C.PlayerReplicationInfo;
            if( (PRI != None) && !PRI.bBot && MessagingSpectator(C) == None )
            {
                ServerState.PlayerInfo.Length = i+1;
                ServerState.PlayerInfo[i].PlayerNum  = C.PlayerNum;
                ServerState.PlayerInfo[i].PlayerName = Misc_PRI(PRI).GetColoredName();
                ServerState.PlayerInfo[i].Score         = PRI.Score;
                ServerState.PlayerInfo[i].Ping         = 4 * PRI.Ping;
                if (bTeamGame && PRI.Team != None)
                    ServerState.PlayerInfo[i].StatsID = ServerState.PlayerInfo[i].StatsID | TeamFlag[PRI.Team.TeamIndex];
                i++;
            }
    }

    // Ask the mutators if they have anything to add.
    for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
        M.GetServerPlayers(ServerState);

    if(Teams[0] == None || Teams[1] == None)
        return;

    i = ServerState.PlayerInfo.Length;
    ServerState.PlayerInfo.Length = i + 2;
    //ServerState.PlayerInfo[i].PlayerName = "Red Team";
    ServerState.PlayerInfo[i].PlayerName = ScoreboardRedTeamName;
    ServerState.PlayerInfo[i].Score = Teams[0].Score;
    //ServerState.PlayerInfo[i+1].PlayerName = "Blue Team";
    ServerState.PlayerInfo[i+1].PlayerName = ScoreboardBlueTeamName;
    ServerState.PlayerInfo[i+1].Score = Teams[1].Score;
}

static function FillPlayInfo(PlayInfo PI)
{
    local byte Weight; // weight must be a byte (max value 127?)

    Super.FillPlayInfo(PI);

    Weight = 1;
    PI.AddSetting("3SPN", "StartingHealth", "Starting Health", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN", "StartingArmor", "Starting Armor", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN", "MaxHealth", "Max Health", 0, Weight++, "Text", "8;1.0:2.0");
    PI.AddSetting("3SPN", "ScoreAwardPer10Damage", "Damage Score Award (per 10 damage)", 0, Weight++, "Text", "8;0.0:10.0");

    PI.AddSetting("3SPN", "SecsPerRound", "How Many Seconds Per Round", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTDamage", "Overtime Damage", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTInterval", "Overtime Damage Interval", 0, Weight++, "Text", "3;0:999");

    PI.AddSetting("3SPN", "CampThreshold", "Camp Area", 0, Weight++, "Text", "8;0:999",, True);
    PI.AddSetting("3SPN", "bKickExcessiveCampers", "Kick Excessive Campers", 0, Weight++, "Check",,, True);

    PI.AddSetting("3SPN", "bForceRUP", "Force Ready", 0, Weight++, "Check",,, True);
    PI.AddSetting("3SPN", "ForceRUPMinPlayers", "Force Ready Min Players", 0, Weight++, "Text", "3;0;999",, True);
    PI.AddSetting("3SPN", "ForceSeconds", "Force Time", 0, Weight++, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "bDisableSpeed", "Disable Speed", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "bDisableInvis", "Disable Invis", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "bDisableBerserk", "Disable Berserk", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "bDisableBooster", "Disable Booster", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "Timeouts", "TimeOuts Per Team", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "TimeOutDuration", "Time Out Duration", 0, Weight++, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "bModifyShieldGun", "Use Modified Shield Gun", 0, Weight++, "Check",,, True);
    PI.AddSetting("3SPN", "AssaultAmmo", "Assault Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "AssaultGrenades", "Assault Grenades", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "BioAmmo", "Bio Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "ShockAmmo", "Shock Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LinkAmmo", "Link Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "MiniAmmo", "Mini Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "FlakAmmo", "Flak Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "RocketAmmo", "Rocket Ammunition", 0, Weight++, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LightningAmmo", "Lightning Ammunition", 0, Weight++, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "EnableNewNet", "Enable New Net", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "EndCeremonyEnabled", "Enable End Ceremony", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "RoundCanTie", "Rounds Can Tie", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "bSpawnProtectionOnRez", "Enable Spawn Protection After Resurrection", 0, Weight++, "Check");

    PI.AddSetting("3SPN", "AutoBalanceTeams", "Auto Balance At Match Start", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "AutoBalanceSeconds", "Auto Balance Teams Time", 0, Weight++, "Text", "3;0:300",, True);
    PI.AddSetting("3SPN", "AutoBalanceOnJoins", "Auto Balance When New Players Join", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "AllowForceAutoBalance", "Auto Balance By Users Writing 'teams' Into Chat", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "ForceAutoBalanceCooldown", "Auto Balance Cooldown Timer In Seconds", 0, Weight++, "Text", "3;0:300",, True);
    PI.AddSetting("3SPN", "AutoBalanceRandomization", "Auto Balance Randomization Percentage", 0, Weight++, "Text", "8;0:100",, True);
    PI.AddSetting("3SPN", "AutoBalanceAvgPPRWeight", "Auto Balance Avg VS Current PPR Weight (Percent)", 0, Weight++, "Text", "8;0:100",, True);

    PI.AddSetting("3SPN", "EnforceMaxPlayers", "Enforce Maximum Number Of Players (Tournament)", 0, Weight++, "Check");

    PI.AddSetting("3SPN", "AllowServerSaveSettings", "Allow Caching Player's 3SPN Settings On The Server", 0, Weight++, "Check");
    PI.AddSetting("3SPN", "AlwaysRestartServerWhenEmpty", "Always Restart Server When The Last Player Leaves", 0, Weight++, "Check");

    PI.AddSetting("3SPN", "ScoreboardCommunityName", "Scoreboard Community Name", 0, Weight++, "Text", "80",, True);
    PI.AddSetting("3SPN", "ScoreboardRedTeamName", "Scoreboard Red Team Name", 0, Weight++, "Text", "80",, True);
    PI.AddSetting("3SPN", "ScoreboardBlueTeamName", "Scoreboard Blue Team Name", 0, Weight++, "Text", "80",, True);
//    PI.AddSetting("3SPN", "UseZAxisRadar", "Extended HUD Includes Z Axis", 0, Weight++, "Check");
     PI.AddSetting("3SPN", "bOverkillMessage", "Toggle Overkill notification", 0, Weight++, "Check");
	 PI.AddSetting("3SPN", "AdrenalinePerDamage", "Adrenaline Per Damage", 0, Weight++, "Text", "8;0.0:100.0");

    //serverlink menu entry
    Weight = 1;
    PI.AddSetting("3SPN ServerLink", "ServerLinkStatus", "ServerLink Status", 0, Weight++, "Select", "SL_DISABLED;Disabled;SL_READONLY;ReadOnly;SL_ENABLED;Enabled");
    PI.AddSetting("3SPN ServerLink", "ServerLinkAddress", "ServerLink IP", 0, Weight++, "Text", "60",, True);
    PI.AddSetting("3SPN ServerLink", "ServerLinkPort", "ServerLink Port", 0, Weight++, "Text", "60",, True);
    PI.AddSetting("3SPN ServerLink", "ServerLinkAccount", "ServerLink Account", 0, Weight++, "Text", "60",, True);
    PI.AddSetting("3SPN ServerLink", "ServerLinkPassword", "ServerLink Password", 0, Weight++, "Text", "60",, True);
    PI.AddSetting("3SPN ServerLink", "EndCeremonyStatsEnabled", "Enable End Ceremony Stats List (ServerLink)", 0, Weight++, "Check");
    PI.AddSetting("3SPN ServerLink", "AllowPersistentStatsWithBots", "Allow Persistent Stats With Bots", 0, Weight++, "Check");

}

static event string GetDescriptionText(string PropName)
{
    switch(PropName)
    {
      case "StartingHealth":         return "Base health at round start.";
      case "StartingArmor":          return "Base armor at round start.";
      case "MaxHealth":              return "The maximum amount of health and armor a player can have.";
      case "ScoreAwardPer10Damage":  return "Damage Score Award Per 10 damage (default is 0.1)";

      case "SecsPerRound":        return "Round time limit before overtime in seconds (default 120).";
      case "OTDamage":            return "The amount of damage all players while in OT.";
      case "OTInterval":          return "The interval at which OT damage is given.";

      case "CampThreshold":       return "The area a player must stay in to be considered camping.";
      case "bKickExcessiveCampers": return "Kick players that camp 4 consecutive times.";

      case "bDisableSpeed":       return "Disable the Speed adrenaline combo.";
      case "bDisableInvis":       return "Disable the Invisibility adrenaline combo.";
      case "bDisableBooster":     return "Disable the Booster adrenaline combo.";
      case "bDisableBerserk":     return "Disable the Berserk adrenaline combo.";

      case "bForceRUP":           return "Force players to ready up after a set amount of time";
      case "ForceRUPMinPlayers":  return "Force players to ready only when at least this many players present.";
      case "ForceSeconds":        return "The amount of time players have to ready up before the game starts automatically";

      case "Timeouts":            return "Number of Timeouts a team can call in one game.";
      case "TimeOutDuration":     return "Time Out Duration";

      case "bModifyShieldGun":    return "The Shield Gun will have more kick back for higher shield jumps";
      case "AssaultAmmo":         return "Amount of Assault Ammunition to give in a round.";
      case "AssaultGrenades":     return "Amount of Assault Grenades to give in a round.";
      case "BioAmmo":             return "Amount of Bio Rifle Ammunition to give in a round.";
      case "LinkAmmo":            return "Amount of Link Gun Ammunition to give in a round.";
      case "ShockAmmo":           return "Amount of Shock Ammunition to give in a round.";
      case "MiniAmmo":            return "Amount of Mini Ammunition to give in a round.";
      case "FlakAmmo":            return "Amount of Flak Ammunition to give in a round.";
      case "RocketAmmo":          return "Amount of Rocket Ammunition to give in a round.";
      case "LightningAmmo":       return "Amount of Lightning Ammunition to give in a round.";

      case "EnableNewNet":                  return "Make enhanced netcode available for players.";
      case "EndCeremonyEnabled":            return "Enable End Ceremony";
      case "AllowPersistentStatsWithBots":  return "Allow Persistent Stats With Bots";
      case "RoundCanTie":                   return "Rounds Can Tie";
      case "bSpawnProtectionOnRez":         return "Enable Spawn Protection After Resurrection";

      case "AutoBalanceTeams":              return "Automatically Balance Teams At Match Start";
      case "AutoBalanceSeconds":            return "Auto Balance Teams Time";
      case "AutoBalanceOnJoins":            return "Auto Balance Teams When New Players Join";
      case "AllowForceAutoBalance":         return "Saying 'teams' Forces Balance (admins can always do this)";
      case "ForceAutoBalanceCooldown":      return "Force Auto Balance Cooldown Timer In Seconds";
      case "AutoBalanceRandomization":      return "Randomization Percentage Used For Automatic Balancing";
      case "AutoBalanceAvgPPRWeight":       return "Auto Balance Avg VS Current PPR Weight (Percent)";
      case "EnforceMaxPlayers":             return "Enforce Maximum Number Of Players (Tournament)";

      case "ServerLinkStatus":         return "ServerLink State (ReadOnly retrieves AVG PPR for balancing)";
      case "ServerLinkAddress":        return "ServerLink IP";
      case "ServerLinkPort":           return "ServerLink Port";
      case "ServerLinkAccount":        return "ServerLink Account";
      case "ServerLinkPassword":       return "ServerLink Password";
      case "EndCeremonyStatsEnabled":  return "Enable End Ceremony Stats List (ServerLink)";

      case "AllowServerSaveSettings":       return "Allow Caching Player's 3SPN Settings On The Server";
      case "AlwaysRestartServerWhenEmpty":  return "Always Restart Server When The Last Player Leaves";

      case "ScoreboardCommunityName":  return "Scoreboard Community Name";
      case "ScoreboardRedTeamName":    return "Scoreboard Red Team Name";
      case "ScoreboardBlueTeamName":   return "Scoreboard Blue Team Name";

//      case "UseZAxisRadar":            return "Extended Player HUD Includes Z Axis For Allies";
      case "bOverkillMessage": return "Turn on/off the Overkill message and sound.";
	  case "AdrenalinePerDamage": return "Adrenaline Received Per Damage Given (Default: 1)";
    }

    return Super.GetDescriptionText(PropName);
}

function ParseOptions(string Options)
{
    local string InOpt;

    InOpt = ParseOption(Options, "StartingHealth");
    if(InOpt != "")
        StartingHealth = int(InOpt);

    InOpt = ParseOption(Options, "StartingArmor");
    if(InOpt != "")
        StartingArmor = int(InOpt);

    InOpt = ParseOption(Options, "MaxHealth");
    if(InOpt != "")
        MaxHealth = float(InOpt);

    InOpt = ParseOption(Options, "ScoreAwardPer10Damage");
    if(InOpt != "")
       ScoreAwardPer10Damage = float(InOpt);

    InOpt = ParseOption(Options, "SecsPerRound");
    if(InOpt != "")
        SecsPerRound = int(InOpt);

    InOpt = ParseOption(Options, "OTDamage");
    if(InOpt != "")
        OTDamage = int(InOpt);

    InOpt = ParseOption(Options, "OTInterval");
    if(InOpt != "")
        OTInterval = int(InOpt);

    InOpt = ParseOption(Options, "CampThreshold");
    if(InOpt != "")
        CampThreshold = float(InOpt);

    InOpt = ParseOption(Options, "ForceRUP");
    if(InOpt != "")
        bForceRUP = bool(InOpt);

    InOpt = ParseOption(Options, "ForceRUPMinPlayers");
    if(InOpt != "")
        ForceRUPMinPlayers = int(InOpt);

    InOpt = ParseOption(Options, "KickExcessiveCampers");
    if(InOpt != "")
        bKickExcessiveCampers = bool(InOpt);

    InOpt = ParseOption(Options, "DisableSpeed");
    if(InOpt != "")
        bDisableSpeed = bool(InOpt);

    InOpt = ParseOption(Options, "DisableInvis");
    if(InOpt != "")
        bDisableInvis = bool(InOpt);

    InOpt = ParseOption(Options, "DisableBerserk");
    if(InOpt != "")
        bDisableBerserk = bool(InOpt);

    InOpt = ParseOption(Options, "DisableBooster");
    if(InOpt != "")
        bDisableBooster = bool(InOpt);

    InOpt = ParseOption(Options, "Timeouts");
    if(InOpt != "")
        Timeouts = int(InOpt);
}

event InitGame(string Options, out string Error)
{
  local class<TournamentModuleBase> TMClass;

  if(ServerLinkStatus != SL_DISABLED)
  {
    // Must enable UT stats logging to get the StatsID
    bEnableStatLogging=true;
  }

  Super.InitGame(Options, Error);
  ParseOptions(Options);

  if(TournamentModuleClass!="")
  {
    TMClass = class<TournamentModuleBase>(DynamicLoadObject(TournamentModuleClass, class'Class'));
    if(TMClass != None)
      TournamentModule = Spawn(TMClass);
  }

  if(TournamentModule != None)
    TournamentModule.InitGame(Options, Error);

    foreach DynamicActors(class'TAM_Mutator', MutTAM)
        break;
    MutTAM.EnableNewNet = EnableNewNet;

    class'xPawn'.Default.ControllerClass = class'Misc_Bot';

    DisablePersistentStatsForMatch = false;

    //SpawnProtectionTime = 1000.000000;
    SpawnProtectionTime = 0;

    EndGameCalled = false;

    MaxLives = 1;
    bForceRespawn = true;
    bAllowWeaponThrowing = true;//false;

    TimeOutCount = 0;
    TeamTimeOuts[0] = TimeOuts;
    TeamTimeOuts[1] = TimeOuts;

    MutTAM.InitWeapons(AssaultAmmo,AssaultGrenades,BioAmmo,ShockAmmo,LinkAmmo,MiniAmmo,FlakAmmo,RocketAmmo,LightningAmmo);

    if(bModifyShieldGun)
    {
        class'XWeapons.ShieldFire'.default.SelfForceScale = 1.5;
        class'XWeapons.ShieldFire'.default.SelfDamageScale = 0.1;
        class'XWeapons.ShieldFire'.default.MinSelfDamage = 0;

        class'WeaponFire_Shield'.default.SelfForceScale = 1.5;
        class'WeaponFire_Shield'.default.SelfDamageScale = 0.1;
        class'WeaponFire_Shield'.default.MinSelfDamage = 0;
    }

    /* combo related */
    if(!bDisableSpeed)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboSpeed";

    if(!bDisableBooster)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboDefensive";

    if(!bDisableBerserk)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboBerserk";

    if(!bDisableInvis)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboInvis";
    /* combo related */

    if(ServerLinkStatus != SL_DISABLED)
    {
        PlayerDataManager_ServerLink = spawn(class'Misc_PlayerDataManager_ServerLink');
        if(PlayerDataManager_ServerLink!=None)
            PlayerDataManager_ServerLink.ConfigureServerLink(ServerLinkAddress, ServerLinkPort, ServerLinkAccount, ServerLinkPassword);
    }

    MatchStatsRegistered = false;

    SaveConfig();
}

static function bool AllowMutator(string MutatorClassName)
{
    if(MutatorClassName == "" || InStr(MutatorClassName, "UTComp") != -1)
        return false;

    return Super.AllowMutator(MutatorClassName);
}

event PreLogin
(
    string Options,
    string Address,
    string PlayerID,
    out string Error,
    out string FailCode
)
{
  if(TournamentModule != None)
    TournamentModule.PreLogin(Options, Address, PlayerID, Error, FailCode);

  Super.PreLogin(Options, Address, PlayerID, Error, FailCode);
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local string oldName;
    local Misc_Player P;

    oldName = Other.PlayerReplicationInfo.PlayerName;

    Super.ChangeName(Other, S, bNameChange);
    Log("Changed name to "$S);

    if(!bNameChange)
        return;

    if (Other.PlayerReplicationInfo.PlayerName==oldName)
        return;

    P = Misc_Player(Other);
    if(P == None)
        return;

    PlayerChangedName(P);
}

auto state PendingMatch
{
    function Timer()
    {
        local Controller P;
        local bool bReady;

        Global.Timer();

        // first check if there are enough net players, and enough time has elapsed to give people
        // a chance to join
        if ( NumPlayers == 0 )
          bWaitForNetPlayers = true;

        if ( bWaitForNetPlayers && (Level.NetMode != NM_Standalone) )
        {
            if ( NumPlayers >= MinNetPlayers )
                ElapsedTime++;
            else
                ElapsedTime = 0;

            if ( (NumPlayers == MaxPlayers) || (ElapsedTime > NetWait) )
            {
                bWaitForNetPlayers = false;
                CountDown = Default.CountDown;
            }
        }
        else if(bForceRUP && bPlayersMustBeReady)
        {
            if(NumPlayers >= ForceRUPMinPlayers)
              ElapsedTime++;
            else
              ElapsedTime = 0;
        }

        if ( (Level.NetMode != NM_Standalone) && (bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers))) )
        {
               PlayStartupMessage();
            return;
        }

        // check if players are ready
        bReady = true;
        StartupStage = 1;
        if ( !bStartedCountDown && (bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone)) )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.bIsPlayer && P.PlayerReplicationInfo.bWaitingPlayer
                    && !P.PlayerReplicationInfo.bReadyToPlay )
                    bReady = false;
        }

        // force ready after 60-ish seconds
        if(!bReady && bForceRUP && bPlayersMustBeReady && (ElapsedTime >= ForceSeconds))
                bReady = true;

        if(AutoBalanceTeams && !TeamsAutoBalanced && (bReady || ElapsedTime >= AutoBalanceSeconds))
        {
            BalanceTeamsMatchStart();
            TeamsAutoBalanced = true;
        }

        if ( bReady && !bReviewingJumpspots )
        {
            bStartedCountDown = true;
            CountDown--;
            if ( CountDown <= 0 )
                StartMatch();
            else
                StartupStage = 5 - CountDown;
        }
        PlayStartupMessage();
    }
}

/* timeouts */
// get the state of timeouts (-1 = N/A, 0 = none pending, 1 = one pending on same team, 2 = one pending on other team, 3 = timeouts disabled, 4 = out of timeouts)
function int GetTimeoutState(PlayerController caller)
{
    if(bWaitingToStartMatch)
        return -1;

    if(caller == None || caller.PlayerReplicationInfo == None)
        return -1;

    if(caller.PlayerReplicationInfo.bAdmin) // admins can always call timeouts
        return 0;

    if(Level.TimeSeconds - LastTimeOutUpdate < 3.0)
        return -1;

    if(caller.PlayerReplicationInfo.Team == None)
        return -1;

    if(caller.PlayerReplicationInfo.bOnlySpectator)
        return -1;

    // check if timeouts are even enabled
    if(TimeOuts == 0)
        return 3;

    if(TimeOutTeam == caller.PlayerReplicationInfo.Team.TeamIndex)
        return 1;

    if(TimeOutCount == -1 || TimeOutCount > 0 || TimeOutTeam != 255)
        return 2;

    if(TeamTimeOuts[caller.PlayerReplicationInfo.Team.TeamIndex] <= 0)
        return 4;

    return 0;
}


// check if a team has timeouts left, and if so, pause the game at the end of the current round
function CallTimeout(PlayerController caller)
{
    local Controller C;
    local int toState;

    toState = GetTimeoutState(caller);

    if(toState == -1)
        return;

    LastTimeOutUpdate = Level.TimeSeconds;

    if(caller.PlayerReplicationInfo == None || (caller.PlayerReplicationInfo.Team == None && !caller.PlayerReplicationInfo.bAdmin))
        return;
    else if(toState == 3)
    {
        caller.ClientMessage("Timeouts are disabled on this server");
        return;
    }
    else if(toState == 1)
    {
        if(TimeOutCount > 0)
        {
            caller.ClientMessage("You can not cancel a Timeout once it takes effect.");
        }
        else
        {
            EndTimeout();

            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(C != None && C.IsA('PlayerController'))
                {
                    if(caller.PlayerReplicationInfo.Team.TeamIndex == 0)
                        PlayerController(C).ClientMessage("Red Team canceled the Timeout");
                    else
                        PlayerController(C).ClientMessage("Blue Team canceled the Timeout");
                }
            }
        }

        return;
    }
    else if(toState == 2)
    {
        caller.ClientMessage("A Timeout is already pending");
        return;
    }
    else if(toState == 4)
    {
        caller.ClientMessage("Your team has no Timeouts remaining");
        return;
    }

    if(caller.PlayerReplicationInfo.bAdmin)
    {
        if(TimeOutCount == -1 || TimeOutCount > 0)
        {
            EndTimeout();

            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(C != None && C.IsA('PlayerController'))
                {
                    PlayerController(C).ClientMessage("Admin canceled the Timeout");
                }
            }
        }
        else
        {
            TimeOutTeam = 3;
            TimeOutPlayer = caller;

            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(C != None && C.IsA('PlayerController'))
                {
                    PlayerController(C).ClientMessage("Admin called a Timeout");
                }
            }
        }
    }
    else
    {
        TimeOutTeam = caller.PlayerReplicationInfo.Team.TeamIndex;
        TimeOutPlayer = caller;

        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C != None && C.IsA('PlayerController'))
            {
                if(TimeOutTeam == 0)
                    PlayerController(C).ClientMessage("Red Team called a Timeout");
                else
                    PlayerController(C).ClientMessage("Blue Team called a Timeout");
            }
        }
    }
}

// end el timeouto
function EndTimeOut()
{
    Misc_BaseGRI(GameReplicationInfo).bGamePaused = false;
    GameReplicationInfo.bStopCountDown = false;
    TimeOutCount = 0;
    TimeOutTeam = default.TimeOutTeam;
    TimeOutPlayer = None;
    Level.Pauser = None;
}
/* timeouts */

function ScoreKill(Controller Killer, Controller Other)
{
    if(Killer==None)
        return;

    Super.ScoreKill(Killer, Other);
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation,
                          out vector Momentum, class<DamageType> DamageType)
{
    local Misc_PRI PRI;
    local int OldDamage;
    local int NewDamage;
    local int RealDamage;
    local int Result;
    local float DamageChange;
    local float RFF;
    local float FF;

    local vector EyeHeight;

    /*if(LockTime > 0)
        return 0;*/

    if(bEndOfRound)
    {
        Momentum *= 2.0;
        return 0;
    }

    if(DamageType == Class'DamTypeSuperShockBeam')
        return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(Misc_Pawn(instigatedBy) != None && instigatedBy.Controller != None && injured.GetTeamNum() != 255 && instigatedBy.GetTeamNum() != 255)
    {
        PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
        if(PRI == None)
            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

        /* same teams */
        if(injured.GetTeamNum() == instigatedBy.GetTeamNum() && FriendlyFireScale > 0.0)
        {
            RFF = PRI.ReverseFF;

            if(RFF > 0.0 && injured != instigatedBy)
            {
                instigatedBy.TakeDamage(Damage * RFF * FriendlyFireScale, instigatedBy, HitLocation, Momentum, DamageType);
                Damage -= (Damage * RFF * FriendlyFireScale);
            }

            OldDamage = PRI.AllyDamage;

            RealDamage = OldDamage + Damage;
            if(injured == instigatedBy)
            {
                if(class<DamType_Camping>(DamageType) != None || class<DamType_Overtime>(DamageType) != None)
                    return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

                if(class<DamTypeShieldImpact>(DamageType) != None)
                    NewDamage = OldDamage;
                else
                    NewDamage = RealDamage;
            }
            else
                NewDamage = OldDamage + (Damage * (FriendlyFireScale - (FriendlyFireScale * RFF)));


            PRI.AllyDamage = NewDamage;
            DamageChange = NewDamage - OldDamage;
            //log("player ["$ PRI.PlayerName $"] NewDamage ["$ NewDamage $"] OldDamage [" $ OldDamage $"] DamageChange [" $ DamageChange $"]");

            if(DamageChange > 0.0)
            {
                if(injured != instigatedBy)
                {
                    if(RFF < 1.0)
                    {
                        RFF = FMin(RFF + (Damage * 0.0015), 1.0);
                        GameEvent("RFFChange", string(RFF - PRI.ReverseFF), PRI);
                        PRI.ReverseFF = RFF;
                    }

                    EyeHeight.z = instigatedBy.EyeHeight;
                    if(Misc_Player(instigatedBy.Controller) != None && FastTrace(injured.Location, instigatedBy.Location + EyeHeight))
                        Misc_Player(instigatedBy.Controller).HitDamage -= DamageChange;
                }

                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewFriendlyDamage += DamageChange * 0.01;

                    if(Misc_Player(instigatedBy.Controller).NewFriendlyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, -int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage), "FriendlyDamage");
                        Misc_Player(instigatedBy.Controller).NewFriendlyDamage -= int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage);
                    }
                }

                PRI.Score -= (DamageChange * 0.10) * ScoreAwardPer10Damage;
                instigatedBy.Controller.AwardAdrenaline((-DamageChange * 0.10) * AdrenalinePerDamage);
            }

            FF = FriendlyFireScale;
            FriendlyFireScale -= (FriendlyFireScale * RFF);
            Result = Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
            FriendlyFireScale = FF;
            return Result;
        }
        else if(injured.GetTeamNum() != instigatedBy.GetTeamNum()) // different teams
        {
            //if(Level.TimeSeconds-injured.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
            if(Misc_Pawn(injured).IsSpawnProtectionEnabled())
                return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

            OldDamage = PRI.EnemyDamage;
            NewDamage = OldDamage + Damage;
            PRI.EnemyDamage = NewDamage;
            DamageChange = NewDamage - OldDamage;

            if(DamageChange > 0.0)
            {
                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewEnemyDamage += DamageChange * 0.01;
                    if(Misc_Player(instigatedBy.Controller).NewEnemyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, int(Misc_Player(instigatedBy.Controller).NewEnemyDamage), "EnemyDamage");
                        Misc_Player(instigatedBy.Controller).NewEnemyDamage -= int(Misc_Player(instigatedBy.Controller).NewEnemyDamage);
                    }

                    EyeHeight.z = instigatedBy.EyeHeight;
                    if(FastTrace(injured.Location, instigatedBy.Location + EyeHeight))
                        Misc_Player(instigatedBy.Controller).HitDamage += DamageChange;
                }


                PRI.Score += (DamageChange * 0.10) * ScoreAwardPer10Damage;
                instigatedBy.Controller.AwardAdrenaline((DamageChange * 0.10) * AdrenalinePerDamage);
            }

            if(Damage > (injured.Health + injured.ShieldStrength + 50) &&
                Damage / (injured.Health + injured.ShieldStrength) > 2)
            {
			
			    /* 
				    Even though the Overkill message is off,
					we still want the event to propagate throughout
					the system. Other parts could use it for whatever reason.
				*/
                PRI.OverkillCount++;
                SpecialEvent(PRI, "Overkill");
				
				if(bOverkillMessage == true) { 

                    if(Misc_Player(instigatedBy.Controller) != None)
                        Misc_Player(instigatedBy.Controller).ReceiveLocalizedMessage(class'Message_Overkill');
                // overkill
				}
            }

            /* hitstats */
            // in order of most common
            if(DamageType == class'DamType_FlakChunk')
            {
                PRI.Flak.Primary.Hit++;
                PRI.Flak.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamType_FlakShell')
            {
                PRI.Flak.Secondary.Hit++;
                PRI.Flak.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamType_Rocket')
            {
                PRI.Rockets.Hit++;
                PRI.Rockets.Damage += Damage;
            }
            else if(DamageType == class'DamTypeSniperShot')
            {
                PRI.Sniper.Hit++;
                PRI.Sniper.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShockBeam')
            {
                PRI.Shock.Primary.Hit++;
                PRI.Shock.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShockBall')
            {
                PRI.Shock.Secondary.Hit++;
                PRI.Shock.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamType_ShockCombo')
            {
                PRI.Combo.Hit++;
                PRI.Combo.Damage += Damage;
            }
            else if(DamageType == class'DamTypeMinigunBullet')
            {
                PRI.Mini.Primary.Hit++;
                PRI.Mini.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeMinigunAlt')
            {
                PRI.Mini.Secondary.Hit++;
                PRI.Mini.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeLinkPlasma')
            {
                PRI.Link.Secondary.Hit++;
                PRI.Link.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeLinkShaft')
            {
                PRI.Link.Primary.Hit++;
                PRI.Link.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamType_HeadShot')
            {
                PRI.HeadShots++;
                PRI.Sniper.Hit++;
                PRI.Sniper.Damage += Damage;
            }
            else if(DamageType == class'DamType_BioGlob')
            {
                PRI.Bio.Hit++;
                PRI.Bio.Damage += Damage;
            }
            else if(DamageType == class'DamTypeAssaultBullet')
            {
                PRI.Assault.Primary.Hit++;
                PRI.Assault.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeAssaultGrenade')
            {
                PRI.Assault.Secondary.Hit++;
                PRI.Assault.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamType_RocketHoming')
            {
                PRI.Rockets.Hit++;
                PRI.Rockets.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShieldImpact')
                PRI.SGDamage += Damage;
            /* hitstats */
        }
    }

    return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

    if((Player != None) && (Player.StartSpot != None))
        LastPlayerStartSpot = Player.StartSpot;

    // always pick StartSpot at start of match
    if(Level.NetMode == NM_Standalone && bWaitingToStartMatch && Player != None && Player.StartSpot != None)
    {
        return Player.StartSpot;
    }

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player, InTeam, incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel;

    // use InTeam if player doesn't have a team yet
    if((Player != None) && (Player.PlayerReplicationInfo != None))
    {
        if(Player.PlayerReplicationInfo.Team != None)
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
        else
            Team = InTeam;
    }
    else
        Team = InTeam;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        if(N.IsA('PathNode') || N.IsA('PlayerStart') || N.IsA('JumpSpot'))
            NewRating = RatePlayerStart(N, Team, Player);
	else if(N.IsA('LiftCenter'))
            NewRating = 0;
	    log("Didn't spawn on a LiftCenter!");
        else
            NewRating = 1;
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if (BestStart == None)
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
        BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )
        {
            NewRating = RatePlayerStart(N,0,Player);
            if ( InventorySpot(N) != None )
                NewRating -= 50;
            NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

    LastStartSpot = BestStart;
    if(Player != None)
        Player.StartSpot = BestStart;

    if(!bWaitingToStartMatch)
        bFirstSpawn = false;

    return BestStart;
} // FindPlayerStart()


// rate whether player should spawn at the chosen navigationPoint or not
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local NavigationPoint P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    P = N;

    if ((P == None) || P.PhysicsVolume.bWaterVolume || Player == None)
        return -10000000;

    /*if(bFirstSpawn && Player != None && Player.bIsPlayer)
        return(FMax(4000000.0 * FRand(), 5));*/

    Score = 1000000.0;

    if(bFirstSpawn && LastPlayerStartSpot != None)
    {
        NextDist = VSize(N.Location - LastPlayerStartSpot.Location);
        Score += (NextDist * (0.25 + 0.75 * FRand()));

        if(N == LastStartSpot || N == LastPlayerStartSpot)
            Score -= 100000000.0;
        else if(FastTrace(N.Location, LastPlayerStartSpot.Location))
            Score -= 1000000.0;
    }

    //Score += (N.Location.Z * 10) * FRand();

    for(OtherPlayer = Level.ControllerList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextController)
    {
        if(OtherPlayer != None && OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None))
        {
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);

            if(NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight)
                return 0.0;
            else
            {
                // same team
                if(OtherPlayer.GetTeamNum() == Player.GetTeamNum() && OtherPlayer != Player)
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score += 10000.0;

                    if(NextDist > 1500)
                        Score -= (NextDist * 10);
                    else if (NextDist < 1000)
                        Score += (NextDist * 10);
                    else
                        Score += (NextDist * 20);
                }
                // different team
                else if(OtherPlayer.GetTeamNum() != Player.GetTeamNum())
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score -= 20000.0;       // strongly discourage spawning in line-of-sight of an enemy

                    Score += (NextDist * 10);
                }
            }
        }
    }

    return FMax(Score, 5);
} // RatePlayerStart()

function StartMatch()
{
    Super.StartMatch();

    CurrentRound = 1;
    Misc_BaseGRI(GameReplicationInfo).CurrentRound = 1;
    GameEvent("NewRound", string(CurrentRound), none);

    RoundTime = SecsPerRound;
    Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
    RespawnTime = 2;
//    LockTime = default.LockTime;

    EndOfRoundTime = 0;
    EndOfRoundScorer = None;

    NextRoundTime = 0;

    GameReplicationInfo.bStopCountdown = false;
}

function StartNewRound()
{
    local Controller C;

    RespawnTime = 4;
//    LockTime = default.LockTime;

    bRoundOT = false;
    RoundOTTime = 0;
    RoundTime = SecsPerRound;
    bFirstSpawn = true;

    EndOfRoundTime = 0;
    EndOfRoundScorer = None;

    NextRoundTime = 0;

    GameReplicationInfo.bStopCountdown = false;

    Deaths[0] = 0;
    Deaths[1] = 0;

    CurrentRound++;
    Misc_BaseGRI(GameReplicationInfo).CurrentRound = CurrentRound;
    bEndOfRound = false;
    Misc_BaseGRI(GameReplicationInfo).bEndOfRound = false;

    DarkHorse = none;

    Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).RoundMinute = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(PlayerController(C) != None)
            PlayerController(C).UnpressButtons();

    GameEvent("NewRound", string(CurrentRound), none);
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local string InName;
    local PlayerController PC;

  Options = class'Misc_Util'.static.SanitizeLoginOptions(Options);

  if(TournamentModule != None)
    Options = TournamentModule.ModifyLogin(Options);

    // kind of a hack to preserve the colored name without having to
    // derive the whole function from base
    InName = Left(ParseOption( Options, "Name"), 20);
    ReplaceText(InName, " ", "_");
    ReplaceText(InName, "|", "I");

    PC = Super.Login( Portal, Options, Error );

    // if the name wasn't changed otherwise, restore the colored version
    if(PC!=None)
    {
        if(Misc_PRI(PC.PlayerReplicationInfo)!=None)
            Misc_PRI(PC.PlayerReplicationInfo).ColoredName = InName;

        if(Misc_Player(PC)!=None)
        {
            Misc_Player(PC).NextRezTime = Level.TimeSeconds+5; // don't allow resurrecting for 5 seconds after joining the server
            Misc_Player(PC).LoginTime = Level.TimeSeconds;
        }
    }

    return PC;
}

// modify player logging in
event PostLogin(PlayerController NewPlayer)
{
    local Misc_Player P;

    Super.PostLogin(NewPlayer);

    P = Misc_Player(NewPlayer);

    if(IsInState('MatchOver') && P!=None)
    {
        NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
        NewPlayer.PlayerReplicationInfo.NumLives = 0;
        StartCeremonyForPlayer(P);
    }
  else if(!bRespawning && CurrentRound > 0)
  {
      NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
      NewPlayer.PlayerReplicationInfo.NumLives = 0;
      NewPlayer.GotoState('Spectating');
  }
  else
    {
      NewPlayer.PlayerReplicationInfo.bOutOfLives = false;
      NewPlayer.PlayerReplicationInfo.NumLives = 1;

      RestartPlayer(NewPlayer);
  }

    if(!NewPlayer.PlayerReplicationInfo.bOnlySpectator && AutoBalanceOnJoins)
    ForceAutoBalance = true;

  if(Misc_Player(NewPlayer) != None)
      Misc_Player(NewPlayer).ClientKillBases();

    PlayerJoined(P);

    CheckMaxLives(None);
} // PostLogin()

function PlayerJoined(PlayerController C)
{
    local Misc_Player P;

    P = Misc_Player(C);
    if(P == None)
        return;

    if(PlayerDataManager_ServerLink!=None)
        PlayerDataManager_ServerLink.PlayerJoined(P);
}

function PlayerLeft(PlayerController C)
{
    local Misc_Player P;

    P = Misc_Player(C);
    if(P == None)
        return;

    if(PlayerDataManager_ServerLink!=None)
        PlayerDataManager_ServerLink.PlayerLeft(P);
}

function PlayerChangedName(PlayerController C)
{
    local Misc_Player P;

    P = Misc_Player(C);
    if(P == None)
        return;

    if(PlayerDataManager_ServerLink!=None)
        PlayerDataManager_ServerLink.PlayerChangedName(P);
}

function Logout(Controller Exiting)
{
    if(PlayerController(Exiting)!=None)
        PlayerLeft(PlayerController(Exiting));

    Super.Logout(Exiting);

    CheckMaxLives(none);

    if(NumPlayers <= 0 && (!bWaitingToStartMatch || AlwaysRestartServerWhenEmpty) && !bGameEnded && !bGameRestarted)
        RestartGame();
}

function bool BecomeSpectator(PlayerController P)
{
  if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).TournamentModule!=None)
    if(!Team_GameBase(Level.Game).TournamentModule.AllowBecomeSpectator(P))
      return false;

    if ( (P.PlayerReplicationInfo == None) /*|| !GameReplicationInfo.bMatchHasBegun*/
         || (NumSpectators >= MaxSpectators) /*|| P.IsInState('GameEnded') || P.IsInState('RoundEnded')*/ )
    {
        P.ReceiveLocalizedMessage(GameMessageClass, 12);
        return false;
    }

    if (GameStats != None)
    {
        GameStats.DisconnectEvent(P.PlayerReplicationInfo);
    }

    P.PlayerReplicationInfo.bOnlySpectator = true;
    NumSpectators++;
    NumPlayers--;

    if ( !bKillBots )
        RemainingBots++;
    if ( !NeedPlayers() || AddBot() )
        RemainingBots--;
    return true;
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
    local bool b;

    b = true;

  if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).TournamentModule!=None)
    if(!Team_GameBase(Level.Game).TournamentModule.AllowBecomeActivePlayer(P))
      return false;

   if(TournamentModule != None)
    return false;

    if(P.PlayerReplicationInfo == None || (NumPlayers >= MaxPlayers) /*|| P.IsInState('GameEnded')*/)
    {
        P.ReceiveLocalizedMessage(GameMessageClass, 13);
        b = false;
    }

    if(b && Level.NetMode == NM_Standalone && NumBots > InitialBots)
    {
        RemainingBots--;
        bPlayerBecameActive = true;
    }

    return b;
}

// add bot to the game
function bool AddBot(optional string botName)
{
    local Bot NewBot;

    NewBot = SpawnBot(botName);
    if ( NewBot == None )
    {
        warn("Failed to spawn bot.");
        return false;
    }

    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;

    if(!bRespawning && CurrentRound > 0)
    {
        NewBot.PlayerReplicationInfo.bOutOfLives = true;
        NewBot.PlayerReplicationInfo.numLives = 0;

        if ( Level.NetMode == NM_Standalone )
            RestartPlayer(NewBot);
        else
            NewBot.GotoState('Dead','MPStart');
    }
    else
  {
        NewBot.PlayerReplicationInfo.bOutOfLives = false;
        NewBot.PlayerReplicationInfo.numLives = 1;

        RestartPlayer(NewBot);
  }

    CheckMaxLives(none);

    if( PlayerDataManager_ServerLink != None   &&
        ServerLinkStatus != SL_READONLY        &&
        !AllowPersistentStatsWithBots          && 
        !DisablePersistentStatsForMatch)
    {
        BroadcastLocalizedMessage(class'Message_StatsRecordingDisabled');
        DisablePersistentStatsForMatch = true;
    }

    return true;
} // AddBot()

function AddGameSpecificInventory(Pawn P)
{
    Super.AddGameSpecificInventory(P);

    if(p == None || p.Controller == None || p.Controller.PlayerReplicationInfo == None)
        return;

    SetupPlayer(P);
}

function AddDefaultInventory(Pawn P)
{
    Super.AddDefaultInventory(P);
    MutTAM.GiveAmmo(P);
}

function SetupPlayer(Pawn P)
{
    p.Health = StartingHealth;
    p.HealthMax = StartingHealth;
    p.SuperHealthMax = StartingHealth * MaxHealth;
    xPawn(p).ShieldStrengthMax = StartingArmor * MaxHealth;

    if(Misc_Player(p.Controller) != None)
        xPawn(p).Spree = Misc_Player(p.Controller).Spree;
}

function UpdateTimeOut(float DeltaTime)
{
    if(TimeOutTeam == 4 && TimeOutCount == -1)
    {
        if(NumPlayers >= MaxPlayers)
        {
            TimeOutCount = 30;
            BroadcastLocalizedMessage( class'Message_MaxPlayers', 30 );
        }
    }

    if(TimeOutCount > 0 && TimeOutCount != -1)
    {
        TimeOutRemainder += DeltaTime;
        if(TimeOutRemainder >= 1.0)
        {
            TimeOutRemainder -= 1.0;
            TimeOutCount--;

            if(TimeOutCount%10==0 || TimeOutCount<=5)
                SendTimeOutCountText();

            if(TimeOutCount <= 0)
            {
                TimeOutCount = 0;
                TimeOutRemainder = 0;
                EndTimeOut();
            }
        }
    }
}

// DEBUG {
/*function Rez()
{
    local Controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(xPawn(C.Pawn)!=None && Rand(100)<50)
            xPawn(C.Pawn).DoCombo(class'NecroCombo');
    }
}*/
//DEBUG }

state MatchInProgress
{
    function Timer()
    {
        local Controller c;

        // DEBUG {
        //Rez();
        // DEBUG }

        //RestartQueuedPlayers();

        if(EnforceMaxPlayers)
        {
            if(NumPlayers<MaxPlayers)
            {
                if(Level.Pauser==None && TimeOutPlayer==None)
                {
                    for(C=Level.ControllerList; C!=None; C=C.NextController)
                    {
                        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None)
                        {
                            TimeOutPlayer = PlayerController(C);
                            break;
                        }
                    }

                    if(TimeOutPlayer!=None)
                    {
                        TimeOutTeam = 4;
                        BroadcastLocalizedMessage( class'Message_MaxPlayers', 0 );
                    }
                }
            }
        }

        for(C=Level.ControllerList; C!=None; C=C.NextController)
        {
            if(Misc_Pawn(C.Pawn) == None)
                continue;

            Misc_Pawn(C.Pawn).UpdateSpawnProtection();
        }

    if(ForceAutoBalanceTimer > 0)
      --ForceAutoBalanceTimer;

        if(EndOfRoundTime > 0)
        {
            GameReplicationInfo.bStopCountDown = true;

            EndOfRoundTime--;

            if(EndOfRoundTime <= 0)
            {
                if(CheckMaxLives(EndOfRoundScorer))
                    EndRound(EndOfRoundScorer);

                EndOfRoundTime = 0;
            }

            Super.Timer();
            return;
        }

        if(TimeOutCount == 0 && TimeOutTeam != default.TimeOutTeam)
        {
            if(TimeOutTeam==3 || TimeOutTeam==4)
            {
                TimeOutCount = -1;
            }
            else
            {
                TeamTimeOuts[TimeOutTeam]--;
                TimeOutCount = default.TimeOutDuration;
            }

            TimeOutRemainder = 0;
            GameReplicationInfo.bStopCountDown = true;
            Level.Pauser = TimeOutPlayer.PlayerReplicationInfo;
            SendTimeoutStartText();
            if(TimeOutCount!=-1)
                SendTimeoutCountText();
            Super.Timer();
            return;
        }

        if(NextRoundTime > 0 || bEndOfRound)
        {
            if(NextRoundTime == NextRoundDelay)
            {
                if(AutoBalanceTeams)
                    BalanceTeamsRoundStart();
            }

            GameReplicationInfo.bStopCountDown = true;

            if(NextRoundTime > 0)
                NextRoundTime--;

            if(NextRoundTime == 0)
                StartNewRound();
            else
            {
                Super.Timer();
                return;
            }
        }
        else if(bRoundOT)
        {
            GameReplicationInfo.bStopCountDown = true;

            RoundOTTime++;

            if(RoundOTTime % OTInterval == 0)
            {
                for(c = Level.ControllerList; c != None; c = c.NextController)
                {
                    if(c.Pawn == None)
                        continue;

                    if(c.Pawn.Health <= OTDamage && c.Pawn.ShieldStrength <= 0)
                        c.Pawn.TakeDamage(1000, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Overtime');
                    else
                    {
                        if(int(c.Pawn.ShieldStrength) > 0)
                            c.Pawn.ShieldStrength = int(c.Pawn.ShieldStrength) - Min(c.Pawn.ShieldStrength, OTDamage);
                        else
                            c.Pawn.Health -= OTDamage;
                        c.Pawn.TakeDamage(0.01, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Overtime');
                    }
                }
            }
        }
        /*else if(LockTime > 0)
        {
            LockTime--;
            SendCountdownMessage(LockTime);

            if(LockTime == 0)
            {
                //LockWeapons(false);
                GameReplicationInfo.bStopCountdown = false;
            }
        }*/
        else if(RoundTime > 0)
        {
            GameReplicationInfo.bStopCountDown = false;
            RoundTime--;
            Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
            if(RoundTime % 60 == 0)
                Misc_BaseGRI(GameReplicationInfo).RoundMinute = RoundTime;

            if(RoundTime == 0) {
                bRoundOT = true;
                for(C=Level.ControllerList; C!=None; C=C.NextController)
                    if(PlayerController(C) != None)
                        PlayerController(C).ClientPlaySound(OvertimeSound);
            }
        }

        if(RespawnTime > 0)
            RespawnTimer();

        CheckForCampers();
        CleanUpPawns();

        Super.Timer();
    }
}

function RespawnTimer()
{
    local Actor Reset;
    local Controller C;

    RespawnTime--;
    bRespawning = RespawnTime > 0;

    if(RespawnTime == 3)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(Misc_Player(C) != None)
            {
                Misc_Player(C).Spree = 0;
                //Misc_Player(c).ClientEnhancedTrackAllPlayers(false, true, false);
                Misc_Player(C).ClientResetClock(SecsPerRound);
            }

            if(C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.bOnlySpectator)
                continue;

            if(xPawn(C.Pawn) != None)
            {
                C.Pawn.RemovePowerups();

                if(Misc_Player(C) != None)
                    Misc_Player(C).Spree = xPawn(C.Pawn).Spree;

                C.Pawn.Destroy();
            }

            c.PlayerReplicationInfo.bOutOfLives = false;
            c.PlayerReplicationInfo.NumLives = 1;

            if(PlayerController(C) != None)
                PlayerController(C).ClientReset();
            C.Reset();
            if(PlayerController(C) != None)
                PlayerController(C).GotoState('Spectating');
        }

        ForEach AllActors(class'Actor', Reset)
        {
            if(DestroyActor(Reset))
                Reset.Destroy();
            else if(ResetActor(Reset))
                Reset.Reset();
        }
    }

    if(RespawnTime <= 3)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C == None || C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.bOnlySpectator)
                continue;

            if(PlayerController(C) != None && (C.Pawn == None || C.Pawn.Weapon == None))
            {
                if(C.Pawn != None)
                    C.Pawn.Destroy();

                C.PlayerReplicationInfo.bOutOfLives = false;
                C.PlayerReplicationInfo.NumLives = 1;

                PlayerController(C).ClientReset();
                C.Reset();
                PlayerController(C).GotoState('Spectating');

                RestartPlayer(C);
            }

            /*if(Bot(c) != None && bMoveAlive)
            {
                if(c.Pawn != None)
                    c.Pawn.Destroy();

                c.PlayerReplicationInfo.bOutOfLives = false;
                c.PlayerReplicationInfo.NumLives = 1;
                RestartPlayer(c);
            }*/
        }
    }
}

function CalcEndCeremonyRankings()
{
    local Controller C;
    local PlayerReplicationInfo PRI;
    local int i;

    EndCeremonyRankings.Length = 0;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C==None || C.PlayerReplicationInfo==None)
            continue;

        PRI = C.PlayerReplicationInfo;

        if(PRI.bOnlySpectator || PRI.Score==0)
            continue;

        for(i=0; i<EndCeremonyRankings.length; ++i)
        {
            if(PRI.Score >= EndCeremonyRankings[i].PlayerReplicationInfo.Score)
                break;
        }

        EndCeremonyRankings.Insert(i,1);
        EndCeremonyRankings[i] = C;
    }

    EndCeremonyTimer = 0;
}

function StartCeremonyForPlayer(Misc_Player C)
{
    local int i;
    local string soundName;

    for(i=0; i<EndCeremonyPlayerCount; ++i)
        C.ClientAddCeremonyRanking(i, ServerEndCeremonyInfo[i]);

    if(EndCeremonySoundIdx<EndCeremonySound.Length)
        soundName = EndCeremonySound[EndCeremonySoundIdx];

    C.ClientStartCeremony(EndCeremonyPlayerCount, WinningTeamIndex, soundName);
}

function SendStatsListNameToPlayers(string ListName)
{
    local Controller C;

    if(!IsInState('MatchOver'))
        return;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(Misc_Player(C)!=None)
            Misc_Player(C).ClientReceiveStatsListName(ListName);
    }
}

function SendStatsListIdxToPlayers(int PlayerIndex, string PlayerName, string PlayerStat)
{
    local Controller C;

    if(!IsInState('MatchOver'))
        return;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(Misc_Player(C)!=None) {
            Misc_Player(C).ClientReceiveStatsListIdx(PlayerIndex, class'Misc_Util'.static.FixUnicodeString(PlayerName), PlayerStat);
    }
    }
}

state MatchOver
{
    function BeginState()
    {
        local Controller C;
        local Misc_PRI PRI;
        local int i, j;
        local Pawn P;
        local Projectile Proj;
        local vector HitLocation, HitNormal;
        local actor HitResult;
        local vector TraceStart, TraceEnd;
        local vector axisX, axisY, axisZ;
        local float dist[4], backDist, frontDist;
        local rotator Rot[4];
        local int bestIdx;

        Super.BeginState();

        RegisterMatchStats();

        if(!EndCeremonyEnabled)
            return;

        CalcEndCeremonyRankings();

        EndCeremonyPlayerCount = Min(EndCeremonyRankings.Length,10);

    if(EndCeremonyPlayerCount==0)
      return;

    if(EndCeremonySound.Length>0)
    EndCeremonySoundIdx = Rand(EndCeremonySound.Length);

        ForEach AllActors(class'Pawn', P)
            P.Destroy();

        ForEach AllActors(class'Projectile', Proj)
            Proj.Destroy();

        for(i=0; i<EndCeremonyPlayerCount; ++i)
        {
            C = EndCeremonyRankings[i];
            PRI = Misc_PRI(C.PlayerReplicationInfo);
            if(PRI==None || C.StartSpot==None)
                continue;

            ServerEndCeremonyInfo[i].PlayerName = PRI.PlayerName;
            ServerEndCeremonyInfo[i].CharacterName = PRI.CharacterName;

            if(PRI.Team!=None)
                ServerEndCeremonyInfo[i].PlayerTeam = PRI.Team.TeamIndex;
            else
                ServerEndCeremonyInfo[i].PlayerTeam = 255;

            for(j=0; j<4; ++j)
            {
                Rot[j] = C.StartSpot.Rotation;
                Rot[j].Pitch = 0;
                Rot[j].Yaw += j*(65536/4);

                TraceStart = C.StartSpot.Location + vect(0,0,25);
                GetAxes(Rot[j], axisX, axisY, axisZ);
                TraceEnd = TraceStart + axisX*200;
                HitResult = C.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

                if(HitResult == None)
                {
                    dist[j] = 200;
                }
                else
                {
                    dist[j] = VSize(HitLocation-TraceStart);
                }
            }

            bestIdx = 0;

            // if default direction is obstructed, try to find a direction that has wall in the back
            // but is open in the front
            if(dist[0]<=200)
            {
                backDist = 10000;
                frontDist = 200;

                for(j=1; j<4; ++j)
                {
                    if(dist[j]>=frontDist && dist[(j+2)%4]<=backDist)
                    {
                        frontDist = dist[j];
                        backDist = dist[(j+2)%4];
                        bestIdx = j;
                    }
                }
            }

            ServerEndCeremonyInfo[i].SpawnPos = C.StartSpot.Location;
            ServerEndCeremonyInfo[i].SpawnRot = Rot[bestIdx];
        }

        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(Misc_Player(C)!=None)
                StartCeremonyForPlayer(Misc_Player(C));
        }
    }

    function Timer()
    {
        if(EndCeremonyStatsEnabled)
        {
            if(EndCeremonyTimer%EndCeremonyStatsListDisplayTime == 0)
            {
                if(PlayerDataManager_ServerLink != None)
                {
                    PlayerDataManager_ServerLink.GetRandomStats();
                    PlayerDataManager_ServerLink.GetRandomStats();
                }
            }

            EndCeremonyTimer++;
        }

        Super.Timer();
    }

    function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
    {
        local UnrealTeamInfo NewTeam;

        if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
            return false;    // only allow team changes before match starts

        if (CurrentGameProfile != none)
        {
            if (!CurrentGameProfile.CanChangeTeam(Other, num)) return false;
        }

        if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
        {
            Other.PlayerReplicationInfo.Team = None;
            return true;
        }

        NewTeam = Teams[PickTeam(num,Other)];

        // check if already on this team
        if ( Other.PlayerReplicationInfo.Team == NewTeam )
            return false;

        Other.StartSpot = None;

        if ( Other.PlayerReplicationInfo.Team != None )
            Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

        if ( NewTeam.AddToTeam(Other) )
        {
            BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );

            if ( bNewTeam && PlayerController(Other)!=None )
                GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
        }

        return true;
    }
}

function CleanUpPawns()
{
    local Pawn P;

    ForEach AllActors(class'Pawn', P)
    {
        if(P.Controller != None)
            continue;
        if(Level.TimeSeconds - P.LastStartTime > 3)
            P.Destroy();
    }
}

/*
function RestartLevel()
{
    local Actor Reset;
    local Controller C;

    ForEach AllActors(class'Actor', Reset)
    {
        if(DestroyActor(Reset))
            Reset.Destroy();
        else if(ResetActor(Reset))
            Reset.Reset();
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.bOnlySpectator)
            continue;

        if(PlayerController(C) == None && Bot(C) == None)
            continue;

        C.PlayerReplicationInfo.bOutOfLives = false;
        C.PlayerReplicationInfo.NumLives = 1;

        RestartPlayer(C);
    }
}
*/

function RestartPlayer(Controller C)
{
    local Misc_Player MP;

//    RestartPlayerDelayed(C, 0);

    MP = Misc_Player(C);
    if(MP != None)
    {
        MP.ActiveThisRound = true;

        if(MP.PlayerData != None && MP.PlayerReplicationInfo.Team != None)
            MP.PlayerData.TeamIdx = MP.PlayerReplicationInfo.Team.TeamIndex;
    }

    if(Misc_Bot(C) != None)
        Misc_Bot(C).ActiveThisRound = true;

    Super.RestartPlayer(C);
}

/*
function RestartPlayerDelayed(Controller C, int Delay)
{
    local int i;

    if(C== None || C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.bOutOfLives)
        return;

    for(i=0; i<RestartQueue.Length; ++i)
        if(RestartQueue[i].C == C)
            return;

    i = RestartQueue.Length;
    RestartQueue.Length = i+1;
    RestartQueue[i].C = C;
    RestartQueue[i].Timer = RestartPlayerDelay;

    if(C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator)
    {
        if(PlayerController(C)!=None)
            PlayerController(C).ClientReset();
        C.Reset();
        if(PlayerController(C)!=None)
            PlayerController(C).GotoState('PlayerWaiting');
    }
}

function RestartQueuedPlayers()
{
    local int i;

    for(i=0; i<RestartQueue.Length; ++i)
    {
        if(RestartQueue[i].Timer>0)
        {
            --RestartQueue[i].Timer;
            continue;
        }

        if(RestartQueue[i].C!=None)
            Super.RestartPlayer(RestartQueue[i].C);

        RestartQueue.Remove(i,1);
        --i;
    }
}
*/
function bool DestroyActor(Actor A)
{
    if(Projectile(A) != None)
        return true;
    else if(Pawn(A) != None && (xPawn(A).Controller == None || xPawn(A).PlayerReplicationInfo == None))
        return true;
    else if(Inventory(A) != None)
        return true;

    return false;
}

function bool ResetActor(Actor A)
{
    if(Mover(A) != None || DECO_ExplodingBarrel(A) != None)
        return true;

    return false;
}

function SortByAvgPPR(out array<Controller> Players)
{
    local int i, j;
    local float PPRi, PPRj;
    local Controller C;

    for(i=0; i<Players.Length; ++i)
    {
        for(j=i+1; j<Players.Length; ++j)
        {
            PPRi = 0;
            if(Misc_PRI(Players[i].PlayerReplicationInfo)!=None)
                PPRi = Misc_PRI(Players[i].PlayerReplicationInfo).AvgPPR;

            PPRj = 0;
            if(Misc_PRI(Players[j].PlayerReplicationInfo)!=None)
                PPRj = Misc_PRI(Players[j].PlayerReplicationInfo).AvgPPR;

            if(PPRj < PPRi)
            {
                C = Players[i];
                Players[i] = Players[j];
                Players[j] = C;
            }
        }
    }
}

function BalanceTeamsMatchStart()
{
    local array<Controller> Players;
    local ControllerArray TeamPlayers[2];
    local float TeamPPR[2];
    local Controller C;
    local int TeamIdx, i, j;
  local bool TeamsAreOdd;

    // Not sure if this is necessary but maybe...
    for(i=0; i<2; ++i)
    {
        TeamPlayers[i].C.Length = 0;
        TeamPPR[i] = 0;
    }

    // first build a list of controllers for each team
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)==None || C.PlayerReplicationInfo==None || C.PlayerReplicationInfo.Team==None)
            continue;

        i = Players.Length;
        Players.Length = i+1;
        Players[i] = C;
    }

  if(Players.Length<=2)
    return;

    // sort players so that highest PPR are at the end (we will be removing from there)
    SortByAvgPPR(Players);

    // while more players left, try to insert players in an order that balances out the PPR for each team
    // insert PPR 0 players randomly at the end
    while(Players.Length>0)
    {
        i = Players.Length;

        // choose which team we insert to first, since that team gets the higher PPR player
        if(TeamPPR[0] < TeamPPR[1])
            TeamIdx = 0;
        else if(TeamPPR[0] > TeamPPR[1])
            TeamIdx = 1;
        else
        {
            TeamIdx = Players[i-1].PlayerReplicationInfo.Team.TeamIndex;
            if(TeamIdx >= 2)
                TeamIdx = rand(2);
        }

        // flip order randomly to create a bit of variation
        if(rand(100)<AutoBalanceRandomization)
            TeamIdx = 1-TeamIdx;

        j = TeamPlayers[TeamIdx].C.Length;
        TeamPlayers[TeamIdx].C.Insert(j,1);
        TeamPlayers[TeamIdx].C[j] = Players[i-1];
        if(Misc_PRI(Players[i-1].PlayerReplicationInfo)!=None)
            TeamPPR[TeamIdx] += Misc_PRI(Players[i-1].PlayerReplicationInfo).AvgPPR;
        --i;

        if(i>=1)
        {
            j = TeamPlayers[1-TeamIdx].C.Length;
            TeamPlayers[1-TeamIdx].C.Insert(j,1);
            TeamPlayers[1-TeamIdx].C[j] = Players[i-1];
            if(Misc_PRI(Players[i-1].PlayerReplicationInfo)!=None)
                TeamPPR[1-TeamIdx] += Misc_PRI(Players[i-1].PlayerReplicationInfo).AvgPPR;
            --i;
        }
    else
    {
      TeamsAreOdd = true;
    }

        Players.Length = i;
    }
/*
  // If we have odd teams, trade highest PPR from larger team with a smallest PPR from smaller team
  if(TeamsAreOdd) {
    // TeamIdx = smaller team
    if(TeamPlayers[0].C.Length < TeamPlayers[1].C.Length) {
      TeamIdx = 0;
    } else {
      TeamIdx = 1;
    }

    j = TeamPlayers[TeamIdx].C.Length;
    C = TeamPlayers[TeamIdx].C[j-1]; // take smallest PPR player from smaller team
    TeamPlayers[TeamIdx].C[j-1] = TeamPlayers[1-TeamIdx].C[0]; // Insert highest PPR player into smaller team
    TeamPlayers[1-TeamIdx].C[0] = C; // insert smallest PPR player into bigger team
  }
*/
    for(i=0; i<2; ++i)
        AssignTeams(TeamPlayers[i], i);

    BroadcastLocalizedMessage( class'Message_TeamsBalanced' );

  ForceAutoBalance = false;
  DontAutoBalanceList.Length = 0;
}

function float GetPlayerAutoBalancingPPR(Controller C)
{
  local Misc_PRI PRI;
  local float PPR;

  PRI = Misc_PRI(C.PlayerReplicationInfo);
  if(PRI==None)
    return 0;

  if(PRI.PlayedRounds > 0)
    PPR = PRI.Score / PRI.PlayedRounds;
  else
    PPR = PRI.Score;

  return Lerp(AutoBalanceAvgPPRWeight/100.0, PPR, PRI.AvgPPR);
}

function Controller FindBestAutoBalanceCandidate(int TeamIdx, float PPRNeeded)
{
  local float PPR, BestPPR;
  local Controller C,BestMatch;
  local int i;

  // make sure tha auto balance list doesn't grow too big to prevent balancing
  while(DontAutoBalanceList.Length>NumPlayers/2) {
    DontAutoBalanceList.Remove(0,1);
  }

  // move player that closest matches the required PPR gap / number of players needed
  for(C=Level.ControllerList; C!=None; C=C.NextController)
  {
    // Skip players who are on the don't switch list
    for(i=0; i<DontAutoBalanceList.Length; ++i) {
      if(DontAutoBalanceList[i] == C)
        continue;
    }

    if(    PlayerController(C)!=None &&
      C.PlayerReplicationInfo!=None &&
      C.PlayerReplicationInfo.Team!=None &&
      C.PlayerReplicationInfo.Team.TeamIndex==TeamIdx &&
      Misc_PRI(C.PlayerReplicationInfo)!=None)
    {
      PPR = abs(PPRNeeded - GetPlayerAutoBalancingPPR(C));
      if(BestMatch==None || PPR<BestPPR)
      {
        BestMatch = C;
        BestPPR = PPR;
      }
    }
  }

  return BestMatch;
}

function AutoBalanceSwitchPlayer(Controller C)
{
  local int TeamIdx;
  local int i;

  i = DontAutoBalanceList.Length;
  DontAutoBalanceList.Insert(i, 1);
  DontAutoBalanceList[i] = C;

  TeamIdx = C.PlayerReplicationInfo.Team.TeamIndex;
  Teams[TeamIdx].RemoveFromTeam(C);
  Teams[1-TeamIdx].AddToTeam(C);
}

function BalanceTeamsRoundStart()
{
    local float TeamPPR[2];
    local int TeamSize[2];
  local int TeamScore[2];
    local Controller C, BestMatch, BestMatch2;
    local int TeamIdx, PlayersNeeded, PlayersMoved, i;
    local float PPRNeeded;
  local bool SwapPlayers;

    for(i=0; i<2; ++i)
    {
        TeamPPR[i] = 0;
        TeamSize[i] = 0;
    }

    // calculate total PPR for each team
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.PlayerReplicationInfo==None || C.PlayerReplicationInfo.Team==None)
            continue;

    TeamScore[C.PlayerReplicationInfo.Team.TeamIndex] += Teams[C.PlayerReplicationInfo.Team.TeamIndex].Score;
    TeamPPR[C.PlayerReplicationInfo.Team.TeamIndex] += GetPlayerAutoBalancingPPR(C);
        ++TeamSize[C.PlayerReplicationInfo.Team.TeamIndex];
    }

  if(TeamSize[0]==TeamSize[1] && !ForceAutoBalance)
    return;

    // Choose the team that is going to give players
    if(TeamSize[0]>TeamSize[1])
        TeamIdx = 0;
    else
        TeamIdx = 1;

    // See how many players we need to move, and what PPR they should add up to
    PlayersNeeded = (TeamSize[TeamIdx] - TeamSize[1-TeamIdx])/2;
    PPRNeeded = (TeamPPR[TeamIdx] - TeamPPR[1-TeamIdx])/2;

  if(PlayersNeeded==0 && ForceAutoBalance)
  {
    if(TeamScore[0]>TeamScore[1])
      TeamIdx = 0;
    else if(TeamScore[1]>TeamScore[0])
      TeamIdx = 1;
    else if(TeamPPR[0]>TeamPPR[1])
      TeamIdx = 0;
    else if(TeamPPR[1]>TeamPPR[0])
      TeamIdx = 1;
    else {
      ForceAutoBalance = false;
      return;
    }

    if(TeamSize[TeamIdx] >= TeamSize[1-TeamIdx]) {
      PlayersNeeded = 1;
      PPRNeeded = (TeamPPR[TeamIdx] - TeamPPR[1-TeamIdx])/2;
      if(TeamSize[TeamIdx] == TeamSize[1-TeamIdx]) // Cannot give players, so swap
        SwapPlayers = true;
    }
  }

    PlayersMoved = 0;

  // Calculate ppr needed for each move
  if(PlayersNeeded>0)
    PPRNeeded /= PlayersNeeded;

    while(PlayersNeeded>0)
    {
        // move player that closest matches the required PPR gap / number of players needed
    if(SwapPlayers) {
      BestMatch = FindBestAutoBalanceCandidate(TeamIdx, PPRNeeded*2);
      BestMatch2 = FindBestAutoBalanceCandidate(1-TeamIdx, PPRNeeded);

      if(BestMatch!=None && BestMatch2!=None) {
        AutoBalanceSwitchPlayer(BestMatch);
        AutoBalanceSwitchPlayer(BestMatch2);
      }
    } else {
      BestMatch = FindBestAutoBalanceCandidate(TeamIdx, PPRNeeded);

      if(BestMatch!=None)
        AutoBalanceSwitchPlayer(BestMatch);
    }

    --PlayersNeeded;
        ++PlayersMoved;
    }

    if(PlayersMoved>0)
        BroadcastLocalizedMessage( class'Message_TeamsBalanced' );

  ForceAutoBalance = false;
}

function QueueAutoBalance(bool bAdminUser)
{
  if(!bAdminUser)
    if(!AutoBalanceTeams || !AllowForceAutoBalance)
      return;

  if(ForceAutoBalanceTimer>0)
  {
    BroadcastLocalizedMessage( class'Message_ForceAutoBalanceCooldown', ForceAutoBalanceTimer );
    return;
  }

  ForceAutoBalance = true;
  ForceAutoBalanceTimer = ForceAutoBalanceCooldown;
  BroadcastLocalizedMessage( class'Message_ForceAutoBalance' );
}

function AssignTeams(ControllerArray TeamPlayers, int TeamIdx)
{
    local int i;
    local Controller C;

    for(i=0; i<TeamPlayers.C.Length; ++i)
    {
        C = TeamPlayers.C[i];

        if(C.PlayerReplicationInfo.Team != None)
        {
            if(C.PlayerReplicationInfo.Team == Teams[TeamIdx])
                continue;

            C.PlayerReplicationInfo.Team.RemoveFromTeam(C);
        }

        Teams[TeamIdx].AddToTeam(C);

        if(PlayerController(C)!=None)
            GameEvent("TeamChange",""$TeamIdx,C.PlayerReplicationInfo);
    }
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
    local UnrealTeamInfo SmallTeam, BigTeam, NewTeam;
    local Controller B;
    local int BigTeamBots, SmallTeamBots;

    if ( bPlayersVsBots && (Level.NetMode != NM_Standalone) )
    {
        if ( PlayerController(C) != None )
            return 1;
        return 0;
    }

    SmallTeam = Teams[0];
    BigTeam = Teams[1];

    if( SmallTeam.Size > BigTeam.Size || (SmallTeam.Size == BigTeam.Size && SmallTeam.Score > BigTeam.Score) )
    {
        SmallTeam = Teams[1];
        BigTeam = Teams[0];
    }

    if ( num < 2 ) {
        NewTeam = Teams[num];
  }

    if ( NewTeam == None )
        NewTeam = SmallTeam;
    else if ( bPlayersBalanceTeams && Level.NetMode != NM_Standalone && PlayerController(C) != None )
    {
        if ( SmallTeam.Size < BigTeam.Size)
            NewTeam = SmallTeam;
        else
        {
            // count number of bots on each team
            for ( B=Level.ControllerList; B!=None; B=B.NextController )
            {
                if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot )
                {
                    if ( B.PlayerReplicationInfo.Team == BigTeam )
                        BigTeamBots++;
                    else if ( B.PlayerReplicationInfo.Team == SmallTeam )
                        SmallTeamBots++;
                }
            }

            if ( BigTeamBots > 0 )
            {
                // balance the number of players on each team
                if ( SmallTeam.Size - SmallTeamBots < BigTeam.Size - BigTeamBots )
                    NewTeam = SmallTeam;
                else if ( BigTeam.Size - BigTeamBots < SmallTeam.Size - SmallTeamBots )
                    NewTeam = BigTeam;
                else if ( SmallTeamBots == 0 )
                    NewTeam = BigTeam;
            }
            else if ( SmallTeamBots > 0 )
                NewTeam = SmallTeam;
            else if ( UnrealTeamInfo(C.PlayerReplicationInfo.Team) != None )
                NewTeam = UnrealTeamInfo(C.PlayerReplicationInfo.Team);
        }
    }

    return NewTeam.TeamIndex;
}

function CheckForCampers()
{
    local Controller c;
    local Misc_Pawn p;
    local Misc_PRI pri;
    local Box HistoryBox;
    local float MaxDim;
    local int i;

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(Misc_PRI(c.PlayerReplicationInfo) == None || Misc_Pawn(c.Pawn) == None ||
            c.PlayerReplicationInfo.bOnlySpectator || c.PlayerReplicationInfo.bOutOfLives)
            continue;

        P = Misc_Pawn(c.Pawn);
        pri = Misc_PRI(c.PlayerReplicationInfo);

        p.LocationHistory[p.NextLocHistSlot] = p.Location;
        p.NextLocHistSlot++;

        if(p.NextLocHistSlot == 10)
        {
            p.NextLocHistSlot = 0;
            p.bWarmedUp = true;
        }

        if(p.bWarmedUp)
        {
            HistoryBox.Min.X = p.LocationHistory[0].X;
            HistoryBox.Min.Y = p.LocationHistory[0].Y;
            HistoryBox.Min.Z = p.LocationHistory[0].Z;

            HistoryBox.Max.X = p.LocationHistory[0].X;
            HistoryBox.Max.Y = p.LocationHistory[0].Y;
            HistoryBox.Max.Z = p.LocationHistory[0].Z;

            for(i = 1; i < 10; i++)
            {
                HistoryBox.Min.X = FMin(HistoryBox.Min.X, p.LocationHistory[i].X);
                HistoryBox.Min.Y = FMin(HistoryBox.Min.Y, p.LocationHistory[i].Y);
                HistoryBox.Min.Z = FMin(HistoryBox.Min.Z, p.LocationHistory[i].Z);

                HistoryBox.Max.X = FMax(HistoryBox.Max.X, p.LocationHistory[i].X);
                HistoryBox.Max.Y = FMax(HistoryBox.Max.Y, p.LocationHistory[i].Y);
                HistoryBox.Max.Z = FMax(HistoryBox.Max.Z, p.LocationHistory[i].Z);
            }

            MaxDim = FMax(FMax(HistoryBox.Max.X - HistoryBox.Min.X, HistoryBox.Max.Y - HistoryBox.Min.Y), HistoryBox.Max.Z - HistoryBox.Min.Z);

            if(MaxDim < CampThreshold && p.ReWarnTime == 0)
            {
                PunishCamper(c, p, pri);
                p.ReWarnTime = CampInterval;
            }
            else if(MaxDim > CampThreshold)
            {
                pri.bWarned = false;
                pri.ConsecutiveCampCount = 0;
            }
            else if(p.ReWarnTime > 0)
                p.ReWarnTime--;
        }
    }
}

// dish out the appropriate punishment to a camper
function PunishCamper(Controller C, Misc_Pawn P, Misc_PRI PRI)
{
    SendCamperWarning(C);

    if(c.Pawn.Health <= (10 * (pri.CampCount + 1)) && c.Pawn.ShieldStrength <= 0)
        c.Pawn.TakeDamage(1000, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Camping');
    else
    {
        if(int(c.Pawn.ShieldStrength) > 0)
            c.Pawn.ShieldStrength = Max(0, P.ShieldStrength - (10 * (pri.CampCount + 1)));
        else
            c.Pawn.Health -= 10 * (pri.CampCount + 1);
        c.Pawn.TakeDamage(0.01, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Camping');
    }

    if(!pri.bWarned)
    {
        pri.bWarned = true;
        return;
    }

    if(Level.NetMode == NM_DedicatedServer && pri.Ping * 4 < 999)
    {
        pri.CampCount++;
        pri.ConsecutiveCampCount++;

        if(bKickExcessiveCampers && pri.ConsecutiveCampCount >= 4)
        {
            //log("Kicking Camper (Possibly Idle): "$c.PlayerReplicationInfo.PlayerName);
            AccessControl.DefaultKickReason = AccessControl.IdleKickReason;
            AccessControl.KickPlayer(PlayerController(c));
            AccessControl.DefaultKickReason = AccessControl.Default.DefaultKickReason;
        }
    }
}

// tell players about the camper
function SendCamperWarning(Controller Camper)
{
    local Controller c;

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(Misc_Player(c) == None)
            continue;

        Misc_Player(c).ReceiveLocalizedMessage(class'Message_Camper', int(c != Camper), Camper.PlayerReplicationInfo);
        /*if(!bDisableRadar && Misc_PRI(Camper.PlayerReplicationInfo) != None && Misc_PRI(Camper.PlayerReplicationInfo).bWarned)
            Misc_Player(c).ClientTrackPlayer(Misc_PRI(Camper.PlayerReplicationInfo), true, true);*/
    }
} // SendCamperWarning()

function SendTimeoutStartText()
{
    local Controller C;

    for(C = Level.ControllerList; C != None; C = C.nextController)
        if(PlayerController(C) != None)
            PlayerController(C).ReceiveLocalizedMessage(class'Message_Timeout', default.TimeOutDuration);
} // SendTimeoutCountText()

function SendTimeoutCountText()
{
    local Color color;
    local string Yellow;
    local string TimeOutMsg;

    color = class'Canvas'.static.MakeColor(210, 210, 0);
    Yellow = class'DMStatsScreen'.static.MakeColorCode(color);
    TimeOutMsg = Yellow$"Time Out ends in "$TimeOutCount$" seconds...";

    Broadcast(self, TimeOutMsg);

} // SendTimeoutCountText()

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    if(Killed != None && Killed.PlayerReplicationInfo != None)
    {
        if(bRespawning && Freon(Level.Game)==None)
        {
      Killed.PlayerReplicationInfo.bOutOfLives = false;
      Killed.PlayerReplicationInfo.NumLives = 1;

      if(PlayerController(Killed)!=None)
        PlayerController(Killed).ClientReset();
      Killed.Reset();
      if(PlayerController(Killed)!=None)
        PlayerController(Killed).GotoState('Spectating');

      RestartPlayer(Killed);
            return;
        }
        else
        {
            Killed.PlayerReplicationInfo.bOutOfLives = true;
            Killed.PlayerReplicationInfo.NumLives = 0;
        }

        if(Killed.GetTeamNum() != 255)
        {
            Deaths[Killed.GetTeamNum()]++;
            CheckForAlone(Killed, Killed.GetTeamNum());
        }
    }
}

// check if a team only has one player left
function CheckForAlone(Controller Died, int TeamIndex)
{
    local Controller c;
    local Controller last;
    local int alive[2];

    if(DarkHorse == Died)
    {
        DarkHorse = None;
        return;
    }

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(c == Died || c.Pawn == None || c.GetTeamNum() == 255)
            continue;

        alive[c.GetTeamNum()]++;
        if(alive[TeamIndex] > 1)
            return;

        if(c.GetTeamNum() == TeamIndex)
        {
            if(alive[TeamIndex] != 1)
                last = None;
            else
                last = c;
        }
    }

    if(alive[TeamIndex] != 1 || last == None)
        return;

    if(Misc_Player(last) != None)
        Misc_Player(last).ClientPlayAlone();

    if(DarkHorse == None && (alive[int(!bool(TeamIndex))] >= 3 && NumPlayers + NumBots >= 4))
        DarkHorse = last;
}

// used to show 'player is out' message
function NotifyKilled(Controller Killer, Controller Other, Pawn OtherPawn)
{
    Super.NotifyKilled(Killer, Other, OtherPawn);
    SendPlayerIsOutText(Other);
} // NotifyKilled()

// shows 'player is out' message
function SendPlayerIsOutText(Controller Out)
{
    local Controller c;

    if(Out == None)
        return;

    for(c = Level.ControllerList; c != None; c = c.nextController)
        if(PlayerController(c) != None)
            PlayerController(c).ReceiveLocalizedMessage(class'Message_PlayerIsOut', int(PlayerController(c) != PlayerController(Out)), Out.PlayerReplicationInfo);
} // SendPlayerIsOutText()

function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, actor ViewTarget)
{
    if(xPawn(ViewTarget) == None && (Controller(ViewTarget) == None || xPawn(Controller(ViewTarget).Pawn) == None))
        return false;

    if(bOnlySpectator)
    {
        if(Controller(ViewTarget) != None)
            return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
        else
            return (xPawn(ViewTarget).IsPlayerPawn());
    }

    if(Viewer.Pawn != None)
        return false;

    if(bRespawning || (NextRoundTime <= 1 && bEndOfRound))
        return false;

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer &&
                (bEndOfRound || (Controller(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    else
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None &&
                (bEndOfRound || (xPawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if(bWaitingToStartMatch || bEndOfRound /*|| bWeaponsLocked*/ || EndOfRoundTime>0)
        return false;

    if(!RoundCanTie && (Scorer != None) && !Scorer.bOutOfLives)
        Living = Scorer;

    bNoneLeft = true;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if((C.PlayerReplicationInfo != None) && C.bIsPlayer
            && !C.PlayerReplicationInfo.bOutOfLives
            && C.PlayerReplicationInfo.NumLives > 0
            && !C.PlayerReplicationInfo.bOnlySpectator)
        {
          if(Living == None)
            Living = C.PlayerReplicationInfo;
          else if((C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team))
          {
                  bNoneLeft = false;
                  break;
          }
        }
    }

    if(bNoneLeft)
    {
        if(Living != None)
            QueueEndRound(Living);
        else
        {
            if(!RoundCanTie)
                QueueEndRound(Scorer);
            else
                QueueEndRound(None);
        }
        return true;
    }

    return false;
}

function QueueEndRound(PlayerReplicationInfo Scorer)
{
    if(EndOfRoundDelay>0)
    {
        EndOfRoundScorer = Scorer;
        EndOfRoundTime = EndOfRoundDelay;
    }
    else
    {
        EndRound(Scorer);
    }
}

function EndRound(PlayerReplicationInfo Scorer)
{
    local Controller c;

    EndTimeOut();

    bEndOfRound = true;
    Misc_BaseGRI(GameReplicationInfo).bEndOfRound = true;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    AnnounceBest();
    AnnounceSurvivors();

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(Misc_Player(C)!=None && Misc_Player(C).ActiveThisRound)
        {
            if(Misc_PRI(C.PlayerReplicationInfo)!=None)
                ++Misc_PRI(C.PlayerReplicationInfo).PlayedRounds;
            Misc_Player(C).ActiveThisRound = false;
        }

        if(Misc_Bot(C)!=None && Misc_Bot(C).ActiveThisRound)
        {
            if(Misc_PRI(C.PlayerReplicationInfo)!=None)
                ++Misc_PRI(C.PlayerReplicationInfo).PlayedRounds;
            Misc_Bot(C).ActiveThisRound = false;
        }
    }

    if(Scorer == None)
    {
        for(c = Level.ControllerList; c != None; c = c.NextController)
            if(PlayerController(c) != None)
                PlayerController(c).ReceiveLocalizedMessage(class'Message_RoundTied');

        NextRoundTime = NextRoundDelay;
        return;
    }

    WinningTeamIndex = Scorer.Team.TeamIndex;
    IncrementGoalsScored(Scorer);
    ScoreEvent(Scorer, 0, "ObjectiveScore");
    TeamScoreEvent(WinningTeamIndex, 1, "tdm_frag");
    Teams[WinningTeamIndex].Score += 1;
    AnnounceScoreReliable(WinningTeamIndex);

    // check for darkhorse
    if(DarkHorse != None && DarkHorse.PlayerReplicationInfo != None && DarkHorse.PlayerReplicationInfo == Scorer)
    {
        if(Misc_Player(DarkHorse)!=None)
            Misc_Player(DarkHorse).BroadcastAnnouncement(class'Message_DarkHorse');

        DarkHorse.AwardAdrenaline(10);
        Misc_PRI(DarkHorse.PlayerReplicationInfo).DarkHorseCount++;
        SpecialEvent(DarkHorse.PlayerReplicationInfo, "DarkHorse");
    }

    // check for flawless victory
    else if(Scorer.Team.Score < GoalScore && (NumPlayers + NumBots) >= 4)
    {
        if(Deaths[WinningTeamIndex] == 0)
        {
            for(c = Level.ControllerList; c != None; c = c.NextController)
            {
                if(c.PlayerReplicationInfo != None && (c.PlayerReplicationInfo.bOnlySpectator || (c.GetTeamNum() != 255 && c.GetTeamNum() == WinningTeamIndex)))
                {
                    if(UnrealPlayer(C) != None)
                        UnrealPlayer(C).ClientDelayedAnnouncementNamed('Flawless_victory', 18);

                    if(!c.PlayerReplicationInfo.bOnlySpectator)
                    {
                        Misc_PRI(C.PlayerReplicationInfo).FlawlessCount++;
                        SpecialEvent(C.PlayerReplicationInfo, "Flawless");
                        C.AwardAdrenaline(5);
                    }
                }
                else
                {
                    if(UnrealPlayer(C) != None)
                        UnrealPlayer(C).ClientDelayedAnnouncementNamed('Humiliating_defeat', 18);
                }
            }
        }
    }

    if(Scorer.Team.Score == GoalScore)
    {
        WinningTeamIndex = Scorer.Team.TeamIndex;
        EndGame(Scorer, "teamscorelimit");
    }
    else
    {
        if(NextRoundDelay>0)
            NextRoundTime = NextRoundDelay;
    }
}

function AnnounceScoreReliable(int ScoringTeam)
{
    local Controller C;
    local name ScoreSound;
    local int OtherTeam;

    if ( ScoringTeam == 1 )
        OtherTeam = 0;
    else
        OtherTeam = 1;

    if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 1 )
        ScoreSound = TakeLeadName[ScoringTeam];
    else if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 2 )
        ScoreSound = IncreaseLeadName[ScoringTeam];
    else
        ScoreSound = CaptureSoundName[ScoringTeam];

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if ( Misc_Player(C)!=None )
            Misc_Player(C).PlayStatusAnnouncementReliable(ScoreSound,1,true);
    }
}

function AnnounceBest()
{
    local Controller C;

    local string acc;
    local string dam;
    local string hs;

    local Misc_PRI PRI;
    local Misc_PRI accuracy;
    local Misc_PRI damage;
    local Misc_PRI headshots;

    local string Red;
    local string Blue;
    local string Text;
    local Color  color;

    Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
    Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);

    color = class'Canvas'.static.MakeColor(210, 210, 210);
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        PRI = Misc_PRI(C.PlayerReplicationInfo);

        if(PRI == None || PRI.Team == None || PRI.bOnlySpectator)
            continue;

        PRI.ProcessHitStats();

        if(accuracy == None || (accuracy.AveragePercent < PRI.AveragePercent))
            accuracy = PRI;

        if(damage == None || (damage.EnemyDamage < PRI.EnemyDamage))
            damage = PRI;

        if(headshots == None || (headshots.Headshots < PRI.Headshots))
            headshots = PRI;
    }

    if(accuracy != None && accuracy.AveragePercent > 0.0)
    {
        if(accuracy.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                acc = Text$"Most Accurate:"@Red$accuracy.GetColoredName()$Text$";"@accuracy.AveragePercent$"%";
            else
                acc = Text$"Most Accurate:"@Red$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                acc = Text$"Most Accurate:"@Blue$accuracy.GetColoredName()$Text$";"@accuracy.AveragePercent$"%";
            else
                acc = Text$"Most Accurate:"@Blue$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
        }
    }

    if(damage != None && damage.EnemyDamage > 0)
    {
        if(damage.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                dam = Text$"Most Damage:"@Red$damage.GetColoredName()$Text$";"@damage.EnemyDamage;
            else
                dam = Text$"Most Damage:"@Red$damage.PlayerName$Text$";"@damage.EnemyDamage;
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                dam = Text$"Most Damage:"@Blue$damage.GetColoredName()$Text$";"@damage.EnemyDamage;
            else
                dam = Text$"Most Damage:"@Blue$damage.PlayerName$Text$";"@damage.EnemyDamage;
        }
    }

    if(headshots != None && headshots.Headshots > 0)
    {
        if(headshots.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                hs =  Text$"Most Headshots:"@Red$headshots.GetColoredName()$Text$";"@headshots.Headshots;
            else
                hs =  Text$"Most Headshots:"@Red$headshots.PlayerName$Text$";"@headshots.Headshots;
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                hs =  Text$"Most Headshots:"@Blue$headshots.GetColoredName()$Text$";"@headshots.Headshots;
            else
                hs =  Text$"Most Headshots:"@Blue$headshots.PlayerName$Text$";"@headshots.Headshots;
        }
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(Misc_Player(c) != None)
            Misc_Player(c).ClientListBest(acc, dam, hs);
}

function AnnounceSurvivors()
{
    local array<Controller> lowPlayers;
    local Controller C;
    local int i;
    local Misc_PRI PRI;
    local string Red;
    local string Blue;
    local string HealthCol;
    local string Text;
    local string Result;
    local Color  color;
    local int health;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.PlayerReplicationInfo==None
            || !C.bIsPlayer
            || C.PlayerReplicationInfo.bOutOfLives
            || C.PlayerReplicationInfo.bOnlySpectator)
            continue;

        if(C.Pawn == None)
            continue;

        for(i=0; i<lowPlayers.Length; ++i)
        {
          if(lowPlayers[i].Pawn.Health+lowPlayers[i].Pawn.ShieldStrength > C.Pawn.Health+C.Pawn.ShieldStrength) {
            lowPlayers.Insert(i,1);
            lowPlayers[i] = C;
            break;
          }
        }

        if(i==lowPlayers.Length) {
          lowPlayers.Insert(i,1);
          lowPlayers[i] = C;
        }
    }

    if(lowPlayers.length==0)
        return;

    Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
    Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);

    color = class'Canvas'.static.MakeColor(210, 210, 210);
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    Result = "Survivors: ";

    for(i=0; i<Min(5,lowPlayers.length); ++i)
    {
        PRI = Misc_PRI(lowPlayers[i].PlayerReplicationInfo);
        if(PRI == None)
          continue;

        health = Max(0,PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield);
        color = class'Team_HUDBase'.static.GetHealthRampColor(PRI);
        HealthCol = class'Misc_Util'.static.MakeColorCode(color);

        if(i>0)
          Result = Result$" ";

        if(PRI.Team.TeamIndex==0) {
            Result = Result $ Red$PRI.PlayerName$" "$HealthCol$health;
        } else {
            Result = Result $ Blue$PRI.PlayerName$" "$HealthCol$health;
        }
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(PlayerController(C) != None)
            PlayerController(C).ClientMessage(Result);
}

function AnnounceWinners()
{
    local Controller C;
    local PlayerReplicationInfo PRI;
    local array<Controller> PlayerRankings;
    local int i;
    local string Red;
    local string Blue;
    local string Yellow;
    local string Text;
    local Color color;
    local string RankingMsg;
    local int rank;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.PlayerReplicationInfo == None)
            continue;

        PRI = C.PlayerReplicationInfo;

        if(PRI.bOnlySpectator || PRI.Score==0)
            continue;

        for(i=0; i<PlayerRankings.length; ++i)
        {
            if(PRI.Score >= PlayerRankings[i].PlayerReplicationInfo.Score)
                break;
        }

        PlayerRankings.Insert(i,1);
        PlayerRankings[i] = C;
    }

    if(PlayerRankings.length>0)
    {
        Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
        Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);

        color = class'Canvas'.static.MakeColor(210, 210, 0);
        Yellow = class'DMStatsScreen'.static.MakeColorCode(color);

        color = class'Canvas'.static.MakeColor(210, 210, 210);
        Text = class'DMStatsScreen'.static.MakeColorCode(color);

        rank = 0;

        RankingMsg = Text$"Most valuable players";
        for(i=0; i<PlayerRankings.length && rank<5; ++i)
        {
            PRI = PlayerRankings[i].PlayerReplicationInfo;
            if(i==0 || PRI.Score<PlayerRankings[i-1].PlayerReplicationInfo.Score)
            {
                ++rank;
                if(PRI.Team.TeamIndex==0)
                    RankingMsg @= Yellow$"["$rank$"]"@Red$PlayerRankings[i].PlayerReplicationInfo.PlayerName;
                else
                    RankingMsg @= Yellow$"["$rank$"]"@Blue$PlayerRankings[i].PlayerReplicationInfo.PlayerName;
            }
            else
            {
                if(PRI.Team.TeamIndex==0)
                    RankingMsg @= Text$"&"@Red$PlayerRankings[i].PlayerReplicationInfo.PlayerName;
                else
                    RankingMsg @= Text$"&"@Blue$PlayerRankings[i].PlayerReplicationInfo.PlayerName;
            }
        }

        Broadcast(self, RankingMsg);
    }
}

function SetMapString(Misc_Player Sender, string s)
{
    if(Level.NetMode == NM_Standalone || Sender.PlayerReplicationInfo.bAdmin)
        NextMapString = s;
}

function EndGame(PlayerReplicationInfo PRI, string Reason)
{
    if(EndGameCalled)
        return;
    EndGameCalled = true;

    Super.EndGame(PRI, Reason);
    AnnounceWinners();
    ResetDefaults();
}

function RestartGame()
{
    ResetDefaults();
    Super.RestartGame();
}

function ProcessServerTravel(string URL, bool bItems)
{
    RegisterMatchStats();

    if(PlayerDataManager_ServerLink!=None)
        PlayerDataManager_ServerLink.Destroy();

    ResetDefaults();

    Super.ProcessServerTravel(URL, bItems);
}

function RegisterMatchStats()
{
    if(MatchStatsRegistered)
        return;

    if( PlayerDataManager_ServerLink != None )
    {
        if(ServerLinkStatus != SL_READONLY && !DisablePersistentStatsForMatch)
            PlayerDataManager_ServerLink.FinishMatch();
    }

    MatchStatsRegistered = true;
}

function ResetDefaults()
{
    if(bDefaultsReset)
        return;
    bDefaultsReset = true;

    // set all defaults back to their original values
    Class'xPawn'.Default.ControllerClass = class'XGame.xBot';

    MutTAM.ResetWeaponsToDefaults(bModifyShieldGun);

    // apply changes made by an admin
    if(NextMapString != "")
    {
        ParseOptions(NextMapString);
        saveconfig();
        NextMapString = "";
    }
}

defaultproperties
{
    StartingHealth=100
    MaxHealth=1.000000
    AdrenalinePerDamage=1.000000
    ScoreAwardPer10Damage=0.1
    bForceRUP=True
	bOverkillMessage=True
    ForceRUPMinPlayers=0
    ForceSeconds=60
    SecsPerRound=120
    OTDamage=5
    OTInterval=3
    CampThreshold=400.000000
    CampInterval=5
    bKickExcessiveCampers=True
    TimeOutTeam=255
    TimeOutCount=60
    TimeOutDuration=60
    TimeOutRemainder=0
    bFirstSpawn=True
//     LockTime=4
    NextRoundDelay=1
    AssaultAmmo=999
    AssaultGrenades=5
    BioAmmo=20
    ShockAmmo=20
    LinkAmmo=100
    MiniAmmo=75
    FlakAmmo=12
    RocketAmmo=12
    LightningAmmo=10
    bScoreTeamKills=False
    FriendlyFireScale=0.500000
    DefaultEnemyRosterClass="3SPN_Enhanced_A.TAM_TeamInfo"
    ADR_MinorError=-5.000000
    LocalStatsScreenClass=Class'3SPN_Enhanced_A.Misc_StatBoard'
    DefaultPlayerClassName="3SPN_Enhanced_A.Misc_Pawn"
    ScoreBoardType="3SPN_Enhanced_A.TAM_Scoreboard"
    HUDType="3SPN_Enhanced_A.TAM_HUD"
    GoalScore=10
    TimeLimit=0
    DeathMessageClass=Class'3SPN_Enhanced_A.Misc_DeathMessage'
    MutatorClass="3SPN_Enhanced_A.TAM_Mutator"
    PlayerControllerClassName="3SPN_Enhanced_A.Misc_Player"
    GameReplicationInfoClass=Class'3SPN_Enhanced_A.Misc_BaseGRI'
    GameName="BASE"
    Description="One life per round. Don't waste it."
    ScreenShotName="UT2004Thumbnails.TDMShots"
    DecoTextName="XGame.TeamGame"
    Acronym="BASE"
    EndOfRoundDelay=4
    RoundCanTie=True
    EnableNewNet=True
    EndCeremonyEnabled=True
    EndCeremonyStatsListDisplayTime=15
    LoginMenuClass="3SPN_Enhanced_A.Menu_TAMLoginMenu"
    AllowPersistentStatsWithBots=False
    bSpawnProtectionOnRez=True
    AutoBalanceTeams=True
    AutoBalanceSeconds=20
    AutoBalanceOnJoins=True
    AllowForceAutoBalance=True
    ForceAutoBalanceCooldown=120
    AutoBalanceRandomization=50
    AutoBalanceAvgPPRWeight=100
    EnforceMaxPlayers=False
    //RestartPlayerDelay=2
    ServerLinkStatus=SL_DISABLED
    EndCeremonyStatsEnabled=True
    OvertimeSound=Sound'3SPN_Enhanced_A.Sounds.Overtime'
    ShowServerName=True
    FlagTextureEnabled=True
    FlagTextureShowAcronym=True
    AllowServerSaveSettings=True
    AlwaysRestartServerWhenEmpty=False
    TournamentModuleClass=""
    ScoreboardCommunityName="An Unreal Community"
    ScoreboardRedTeamName="Red Team"
    ScoreboardBlueTeamName="Blue Team"
    UseZAxisRadar=True
}

