class Misc_Player extends xPlayer dependson(Misc_PlayerSettings) dependson(TAM_Mutator);

#exec AUDIO IMPORT FILE=Sounds\alone.wav     	    GROUP=Sounds
#exec AUDIO IMPORT FILE=Sounds\hitsound.wav         GROUP=Sounds
#exec AUDIO IMPORT FILE=Sounds\Bleep.wav            GROUP=Sounds

/* Combo related */
var config bool bShowCombos;            // show combos on the HUD

var config bool bDisableSpeed;
var config bool bDisableInvis;
var config bool bDisableBooster;
var config bool bDisableBerserk;
var config bool bDisableRadar;
var config bool bDisableAmmoRegen;
/* Combo related */

/* HUD related */
var config bool bShowTeamInfo;          // show teams info on the HUD
var config bool bExtendedInfo;          // show extra teammate info

var config bool bMatchHUDToSkins;       // sets HUD color to brightskins color
/* HUD related */

/* brightskins related */
var config bool bUseBrightSkins;        // self-explanatory
var config bool bUseTeamColors;         // use red and blue for brightkins
var config Color RedOrEnemy;            // brightskin color for the red or enemy team
var config Color BlueOrAlly;            // brightskin color for the blue or own team
var config Color Yellow;                // brightskin color for spawn protection
/* brightskins related */

/* model related */
var config bool bForceRedEnemyModel;    // force a model for the red/enemy team
var config bool bForceBlueAllyModel;    // force a model for the blue/ally team
var config bool bUseTeamModels;         // force models by team color (opposed to enemy/ally)
var config string RedEnemyModel;        // character name for the red team's model
var config string BlueAllyModel;        // character name for the blue team's model
/* model related */

/* misc related */
var bool bAdminVisionInSpec;
var bool bDrawTargetingLineInSpec;
var bool bReportNewNetStats;

var int  Spree;                         // kill count at new round
var bool bFirstOpen;                    // used by the stat screen

var float NewFriendlyDamage;            // friendly damage done
var float NewEnemyDamage;               // enemy damage done

var int HitDamage;
var int LastDamage;

var config bool bDisableAnnouncement;
var config bool bAutoScreenShot;
var bool bShotTaken;

var bool bSeeInvis;

var Pawn OldPawn;
/* misc related */

/* sounds */
var config bool  bAnnounceOverkill;
var config bool  bUseHitsounds;

var config Sound SoundHit;
var config Sound SoundHitFriendly;
var config float SoundHitVolume;

var Sound ServerSoundAlone;
var config Sound SoundAlone;
var config float SoundAloneVolume;

var config Sound SoundTMDeath;

var config Sound SoundUnlock;

var Sound ServerSoundSpawnProtection;
var config Sound SoundSpawnProtection;
/* sounds */

/* newnet */
var config bool bEnableEnhancedNetCode;
/* newnet */

var config int ShowInitialMenu;
var config Interactions.EInputKey Menu3SPNKey;

var config bool bDisableEndCeremonySound;

var bool EndCeremonyStarted;
var float EndCeremonyTimer;
var int EndCeremonyPlayerIdx;
var array<name> EndCeremonyAnimNames;
var array<string> EndCeremonyWeaponNames;
var array<class> EndCeremonyWeaponClasses;
var bool WinnerAnnounced;
var int EndCeremonyWinningTeamIndex;
var int EndCeremonyPlayerCount;
var Team_GameBase.SEndCeremonyInfo EndCeremonyInfo[10];
var Pawn EndCeremonyPawns[10];

/* persistent stats */
var float LoginTime;
var Misc_PlayerData PlayerData;
var bool ActiveThisRound;
/* persistent stats */

var float NextRezTime;
var float LastRezTime;

/* colored names */
var bool PlayerInitialized;

var Color RedMessageColor;
var Color GreenMessageColor;
var Color BlueMessageColor;
var Color YellowMessageColor;
var Color WhiteMessageColor;
var Color WhiteColor;

var config bool bAllowColoredMessages;
var config bool bEnableColoredNamesInTalk;
var config bool bEnableColoredNamesOnEnemies;

var config int CurrentSelectedColoredName;
var config color ColorName[20];

struct ColoredNamePair
{
    var color SavedColor[20];
    var string SavedName;
};
var config array<ColoredNamePair> ColoredName;
/* colored names */

/* persistent settings */
var config bool AutoSyncSettings;
var float LastSettingsLoadTimeSeconds;
var float LastSettingsSaveTimeSeconds;
/* persistent settings */

/* persistent stats */
delegate OnPlayerDataReceivedCallback(string PlayerName, string OwnerID, int LastActiveTime, int Score, int Kills, int Thaws, int Deaths);
delegate OnPlayerDataRemovedCallback(string PlayerName);
/* persistent stats */

replication
{
    reliable if(Role == ROLE_Authority)
        ClientResetClock, ClientPlayAlone, ClientPlaySpawnProtection,
        ClientListBest, ClientAddCeremonyRanking, ClientStartCeremony, 
		ClientReceiveStatsListName, ClientReceiveStatsListIdx,
        /*ClientLockWeapons,*/ ClientKillBases, ClientSendAssaultStats,
        ClientSendBioStats, ClientSendShockStats, ClientSendLinkStats,
        ClientSendMiniStats, ClientSendFlakStats, ClientSendRocketStats,
        ClientSendSniperStats, ClientSendComboStats, ClientSendMiscStats;

    reliable if(bNetDirty && Role == ROLE_Authority)
        HitDamage, bSeeInvis;

    reliable if( Role==ROLE_Authority && !bDemoRecording )
        PlayCustomRewardAnnouncement, PlayStatusAnnouncementReliable;
        
    reliable if(Role < ROLE_Authority)
        ServerSetMapString, ServerCallTimeout,
		SetNetCodeDisabled, SetTeamScore,
		ServerLoadSettings, ServerSaveSettings, ServerReportNewNetStats;
		
	reliable if(Role == ROLE_Authority)
		ClientSettingsResult, ClientLoadSettings;
}

function SetNetCodeDisabled()
{
    local inventory inv;

	class'Misc_Player'.default.bEnableEnhancedNetCode = false;
	
    if(Pawn == none)
       return;

	for(inv = Pawn.Inventory; inv!=None; inv=inv.inventory)
	{
		if(Weapon(inv)!=None)
		{
			  if(NewNet_AssaultRifle(Inv)!=None)
				  NewNet_AssaultRifle(Inv).DisableNet();
			   else if( NewNet_BioRifle(Inv)!=None)
				  NewNet_BioRifle(Inv).DisableNet();
			   else if(NewNet_ShockRifle(Inv)!=None)
				  NewNet_ShockRifle(Inv).DisableNet();
			   else if(NewNet_MiniGun(Inv)!=None)
				  NewNet_MiniGun(Inv).DisableNet();
			   else if(NewNet_LinkGun(Inv)!=None)
				  NewNet_LinkGun(Inv).DisableNet();
			   else if(NewNet_RocketLauncher(Inv)!=None)
				  NewNet_RocketLauncher(inv).DisableNet();
			   else if(NewNet_FlakCannon(inv)!=None)
				  NewNet_FlakCannon(inv).DisableNet();
			   else if(NewNet_SniperRifle(inv)!=None)
				  NewNet_SniperRifle(inv).DisableNet();
			   else if(NewNet_ClassicSniperRifle(inv)!=None)
				  NewNet_ClassicSniperRifle(inv).DisableNet();
		}
	}
}

simulated static function bool UseNewNet()
{
    return class'Misc_Player'.default.bEnableEnhancedNetCode;
}

function Misc_PlayerDataManager_ServerLink GetPlayerDataManager_ServerLink()
{
	if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).PlayerDataManager_ServerLink!=None)
		return Team_GameBase(Level.Game).PlayerDataManager_ServerLink;
	/*else if(ArenaMaster(Level.Game)!=None && ArenaMaster(Level.Game).PlayerDataManager_ServerLink!=None)
		return ArenaMaster(Level.Game).PlayerDataManager_ServerLink*/
	return None;
}

function ResetPlayerData()
{
	local int CurrentRound;

	PlayerReplicationInfo.Score = 0;
	PlayerReplicationInfo.Kills = 0;
	PlayerReplicationInfo.Deaths = 0;
	Misc_PRI(PlayerReplicationInfo).Rank = 0;
	Misc_PRI(PlayerReplicationInfo).AvgPPR = 0;
	
	if(Freon_PRI(PlayerReplicationInfo)!=None) {
		Freon_PRI(PlayerReplicationInfo).Thaws = 0;
		Freon_PRI(PlayerReplicationInfo).Git = 0;
	}
	
	if(Team_GameBase(Level.Game)!=None)
		CurrentRound = Team_GameBase(Level.Game).CurrentRound;
	else if(ArenaMaster(Level.Game)!=None)
		CurrentRound = ArenaMaster(Level.Game).CurrentRound;
	Misc_PRI(PlayerReplicationInfo).PlayedRounds = 0;
}

function LoadPlayerDataStats()
{
	Misc_PRI(PlayerReplicationInfo).Rank = PlayerData.Rank;
	Misc_PRI(PlayerReplicationInfo).AvgPPR = PlayerData.AvgPPR;
}

function LoadPlayerData()
{
	local int CurrentRound;

	LoadPlayerDataStats();

	PlayerReplicationInfo.Score = PlayerData.Current.Score;
	PlayerReplicationInfo.Kills = PlayerData.Current.Kills;
	PlayerReplicationInfo.Deaths = PlayerData.Current.Deaths;
	
	if(Freon_PRI(PlayerReplicationInfo)!=None) {
		Freon_PRI(PlayerReplicationInfo).Thaws = PlayerData.Current.Thaws;
		Freon_PRI(PlayerReplicationInfo).Git = PlayerData.Current.Git;
	}
		
	if(Team_GameBase(Level.Game)!=None)
		CurrentRound = Team_GameBase(Level.Game).CurrentRound;
	else if(ArenaMaster(Level.Game)!=None)
		CurrentRound = ArenaMaster(Level.Game).CurrentRound;
		
	if(ActiveThisRound)
		Misc_PRI(PlayerReplicationInfo).PlayedRounds = PlayerData.Current.Rounds-1;
	else
		Misc_PRI(PlayerReplicationInfo).PlayedRounds = PlayerData.Current.Rounds;
}

function StorePlayerData()
{
	local int CurrentRound;

	if(PlayerData==None)
	{
		Log("No player data was being tracked for "$PlayerReplicationInfo.PlayerName);	
		return;
	}

	Log("Storing player data for "$PlayerReplicationInfo.PlayerName);	
	
	PlayerData.Current.Score = PlayerReplicationInfo.Score;
	PlayerData.Current.Kills = PlayerReplicationInfo.Kills;
	PlayerData.Current.Deaths = PlayerReplicationInfo.Deaths;	
	
	if(Freon_PRI(PlayerReplicationInfo)!=None) {
		PlayerData.Current.Thaws = Freon_PRI(PlayerReplicationInfo).Thaws;
		PlayerData.Current.Git = Freon_PRI(PlayerReplicationInfo).Git;
	}
	
	if(Team_GameBase(Level.Game)!=None)
		CurrentRound = Team_GameBase(Level.Game).CurrentRound;
	else if(ArenaMaster(Level.Game)!=None)
		CurrentRound = ArenaMaster(Level.Game).CurrentRound;
	
	if(ActiveThisRound)
		PlayerData.Current.Rounds = Misc_PRI(PlayerReplicationInfo).PlayedRounds+1;
	else
		PlayerData.Current.Rounds = Misc_PRI(PlayerReplicationInfo).PlayedRounds;
}

function SetTeamScore(int RedScore, int BlueScore)
{
	local TeamGame TeamGame;
	
    if((PlayerReplicationInfo==None || !PlayerReplicationInfo.bAdmin) && Level.NetMode!=NM_Standalone)
		return;

	TeamGame = TeamGame(Level.Game);
	if(TeamGame == None)
		return;
	
	if(TeamGame.Teams[0]!=None)
		TeamGame.Teams[0].Score = RedScore;
	if(TeamGame.Teams[1]!=None)
		TeamGame.Teams[1].Score = BlueScore;
}

function CheckInitialMenu()
{
	if(Level.NetMode!=NM_DedicatedServer && class'Misc_Player'.default.ShowInitialMenu==0)
	{
		if(PlayerReplicationInfo==None || PlayerReplicationInfo.PlayerName==class'GameInfo'.Default.DefaultPlayerName)
			return;
	
		class'Misc_Player'.default.ShowInitialMenu=1;
		LoadSettings();
		class'Misc_Player'.static.StaticSaveConfig();
	}
}

event PlayerTick(float DeltaTime)
{
    Super.PlayerTick(DeltaTime);

	CheckInitialMenu();
	
	if(Pawn!=None)
	{
		// if we have a pawn, we must be looking at it
		if(ViewTarget!=Pawn)
			SetViewTarget(Pawn);
	}
	
	if(!PlayerInitialized && PlayerReplicationInfo!=None)
	{	
    class'Misc_Player'.default.bAdminVisionInSpec = false;
    class'Misc_Player'.default.bDrawTargetingLineInSpec = false;
    class'Misc_Player'.default.bReportNewNetStats = false;
		SetInitialColoredName();
		PlayerInitialized = true;
	}

	if(EndCeremonyStarted)
	{
		UpdateEndCeremony(DeltaTime);
		return;
	}
	
    if(Pawn == None || !bUseHitSounds || HitDamage == LastDamage)
    {
        LastDamage = HitDamage;
        return;
    }

    if(HitDamage < LastDamage)
        Pawn.PlaySound(soundHitFriendly,, soundHitVolume,,,(48 / (LastDamage - HitDamage)), false);
    else
        Pawn.PlaySound(soundHit,, soundHitVolume,,,(48 / (HitDamage - LastDamage)), false);

    LastDamage = HitDamage;
}

simulated function ClientAddCeremonyRanking(int PlayerIndex, Team_GameBase.SEndCeremonyInfo InEndCeremonyInfo)
{
	if(Level.NetMode == NM_DedicatedServer)
		return;

	EndCeremonyInfo[PlayerIndex].PlayerName = InEndCeremonyInfo.PlayerName;
	EndCeremonyInfo[PlayerIndex].CharacterName = InEndCeremonyInfo.CharacterName;
	EndCeremonyInfo[PlayerIndex].PlayerTeam = InEndCeremonyInfo.PlayerTeam;
	EndCeremonyInfo[PlayerIndex].SpawnPos = InEndCeremonyInfo.SpawnPos;
	EndCeremonyInfo[PlayerIndex].SpawnRot = InEndCeremonyInfo.SpawnRot;
}

simulated function ClientStartCeremony(int PlayerCount, int WinningTeamIndex, string EndCeremonySound)
{
	local int i, i2;
	local Pawn P;
	local Sound LoadedEndCeremonySound;
	
	if(Level.NetMode == NM_DedicatedServer)
		return;
	
	EndCeremonyStarted = true;
	
	EndCeremonyPlayerCount = PlayerCount;
	EndCeremonyWinningTeamIndex = WinningTeamIndex;
	
	if(!class'Misc_Player'.default.bDisableEndCeremonySound)
	{
		LoadedEndCeremonySound = Sound(DynamicLoadObject(EndCeremonySound, class'Sound', True));
		class'Message_WinningTeam'.default.EndCeremonySound = LoadedEndCeremonySound;
	}
	
	for(i=0; i<PlayerCount; ++i)
	{
		P = Spawn(class'Misc_Pawn',,,EndCeremonyInfo[i].SpawnPos,EndCeremonyInfo[i].SpawnRot);
		if(P!=None)
		{		
			P.Role = ROLE_Authority;
			P.RemoteRole = ROLE_None;
			
			Misc_Pawn(P).Setup(class'xUtil'.static.FindPlayerRecord(EndCeremonyInfo[i].CharacterName), true);
			i2 = Rand(EndCeremonyWeaponNames.Length); 
			Misc_Pawn(P).GiveWeapon(EndCeremonyWeaponNames[i2]);
			Misc_Pawn(P).PendingWeapon = Weapon(Misc_Pawn(P).FindInventoryType(EndCeremonyWeaponClasses[i2]));
			Misc_Pawn(P).ChangedWeapon();			
			Misc_Pawn(P).SetBrightSkin(EndCeremonyInfo[i].PlayerTeam);
			Misc_Pawn(P).bNetNotify = false;
			Misc_Pawn(P).SetAnimAction('None');

			EndCeremonyPawns[i] = P;
		}
	}
	
	EndCeremonyTimer = 7.0;
	EndCeremonyPlayerIdx = -1;
	
	GotoState('GameEnded');
}

simulated function ClientReceiveStatsListName(string ListName)
{
	local Team_HUDBase TH;

	TH = Team_HUDBase(myHUD);
	if(TH != None)
	{
		TH.CurrentStatsList = (TH.CurrentStatsList+1)%ArrayCount(TH.StatsLists);
		TH.StatsLists[TH.CurrentStatsList].ListName = ListName;
		TH.StatsLists[TH.CurrentStatsList].RowNames.Length = 0;
		TH.StatsLists[TH.CurrentStatsList].RowValues.Length = 0;
	}
}

simulated function ClientReceiveStatsListIdx(int Index, string RowName, string RowValue)
{
	local Team_HUDBase TH;
	
	TH = Team_HUDBase(myHUD);
	if(TH != None)
	{
		TH.StatsLists[TH.CurrentStatsList].RowNames.Length = Index+1;
		TH.StatsLists[TH.CurrentStatsList].RowNames[Index] = RowName;

		TH.StatsLists[TH.CurrentStatsList].RowValues.Length = Index+1;
		TH.StatsLists[TH.CurrentStatsList].RowValues[Index] = RowValue;
	}
}

simulated function UpdateEndCeremony(float DeltaTime)
{
	local Pawn P;
	local rotator R;
	local int i;
	
	if(EndCeremonyPlayerCount==0)
		return;

	EndCeremonyTimer += DeltaTime;	
	if(EndCeremonyTimer>=7.0)
	{
		EndCeremonyTimer -= 7.0;
		++EndCeremonyPlayerIdx;
			
		if(EndCeremonyPlayerIdx>=EndCeremonyPlayerCount)
			EndCeremonyPlayerIdx = 0;

		P = EndCeremonyPawns[EndCeremonyPlayerIdx];
			
		if(EndCeremonyAnimNames.Length>0)
		{
			i = Rand(EndCeremonyAnimNames.Length); 
			if(P!=None)
			{
				P.PlayAnim(EndCeremonyAnimNames[i], 0.5, 0.0);
				P.bWaitForAnim = true;
				
				ClientSetViewTarget(P);
				SetViewTarget(P);
				ClientSetBehindView(true);
			}
			
			if(!WinnerAnnounced)
			{
				class'Message_WinningTeam'.static.ClientReceive(self, EndCeremonyWinningTeamIndex);
				WinnerAnnounced = true;
			}
		}

		if(P!=None)
		{
			class'Message_PlayerRanking'.default.PlayerName = EndCeremonyInfo[EndCeremonyPlayerIdx].PlayerName;
			class'Message_PlayerRanking'.static.ClientReceive(self, EndCeremonyPlayerIdx);
		}
	}
	
	P = EndCeremonyPawns[EndCeremonyPlayerIdx];
	if(P!=None)
	{
		R = P.Rotation;
		R.Yaw += 32768;
		R.Pitch = -2730;
		SetRotation(R);
	}
}

function ClientListBest(string acc, string dam, string hs)
{
    if(class'Misc_Player'.default.bDisableAnnouncement)
        return;

    if(acc != "")
        ClientMessage(acc);
    if(dam != "")
        ClientMessage(dam);
    if(hs != "")
        ClientMessage(hs);
}

function ServerSetMapString(string s)
{
    if(TeamArenaMaster(Level.Game) != None)
        TeamArenaMaster(Level.Game).SetMapString(self, s);
    else if(ArenaMaster(Level.Game) != None)
        ArenaMaster(Level.Game).SetMapString(self, s);
}

function ServerThrowWeapon()
{
    local int ammo[2];
    local Inventory inv;
    local class<Weapon> WeaponClass;

    if(Misc_Pawn(Pawn) == None || Pawn.Weapon == None)
        return;

    ammo[0] = Pawn.Weapon.AmmoCharge[0];
    ammo[1] = Pawn.Weapon.AmmoCharge[1];
    WeaponClass = Pawn.Weapon.Class;

    Super.ServerThrowWeapon();

    Misc_Pawn(Pawn).GiveWeaponClass(WeaponClass);

    for(inv = Pawn.Inventory; inv != None; inv = inv.Inventory)
    {
        if(inv.Class == WeaponClass)
        {
            Weapon(inv).AmmoCharge[0] = ammo[0];
            Weapon(inv).AmmoCharge[1] = ammo[1];
            break;
        }
    }
}

function AwardAdrenaline(float amount)
{
    if(bAdrenalineEnabled)
    {
        if((TAM_GRI(GameReplicationInfo) == None || TAM_GRI(GameReplicationInfo).bDisableTeamCombos) && (Pawn != None && Pawn.InCurrentCombo()))
            return;

        if((Adrenaline < AdrenalineMax) && (Adrenaline + amount >= AdrenalineMax))
			ClientDelayedAnnouncementNamed('Adrenalin', 15);
        Adrenaline = FClamp(Adrenaline + amount, 0.1, AdrenalineMax);
    }
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Level.GRI != None)
        Level.GRI.MaxLives = 0;	
}

simulated function InitInputSystem()
{
	local PlayerController C;

	Super.InitInputSystem();
	
	C = Level.GetLocalPlayerController();
	if(C != None)
	{
		C.Player.InteractionMaster.AddInteraction("3SPN_Enhanced_A.Menu_Interaction", C.Player);
	}
}

function ClientKillBases()
{
    local xPickupBase p;

    ForEach AllActors(class'xPickupBase', p)
    {
        if(P.IsA('Misc_PickupBase'))
            continue;

        p.bHidden = true;
        if(p.myEmitter != None)
            p.myEmitter.Destroy();
    }
}

function Reset()
{
    local NavigationPoint P;
    local float Adren;
	
    Adren = Adrenaline;

    P = StartSpot;
    Super.Reset();
    StartSpot = P;

    if(Pawn == None || !Pawn.InCurrentCombo())
        Adrenaline = Adren;
    else
        Adrenaline = 0.1;

    WaitDelay = 0;
}

/*function ClientLockWeapons(bool bLock)
{
    if(xPawn(Pawn) != None)
        xPawn(Pawn).bNoWeaponFiring = bLock;
}*/

function ClientPlayAlone()
{
  if(ServerSoundAlone==None && Len(Misc_BaseGRI(GameReplicationInfo).SoundAloneName)>0) {
    ServerSoundAlone = Sound(DynamicLoadObject(Misc_BaseGRI(GameReplicationInfo).SoundAloneName, class'Sound', True));
  }
  if(ServerSoundAlone!=None)
    ClientPlaySound(ServerSoundAlone, true, class'Misc_Player'.default.SoundAloneVolume);
  else
    ClientPlaySound(class'Misc_Player'.default.SoundAlone, true, class'Misc_Player'.default.SoundAloneVolume);
}

function ClientPlaySpawnProtection()
{
  if(ServerSoundSpawnProtection==None && Len(Misc_BaseGRI(GameReplicationInfo).SoundSpawnProtectionName)>0) {
    ServerSoundSpawnProtection = Sound(DynamicLoadObject(Misc_BaseGRI(GameReplicationInfo).SoundSpawnProtectionName, class'Sound', True));
  }
  if(ServerSoundSpawnProtection!=None)
    ClientPlaySound(ServerSoundSpawnProtection);
  else
    ClientPlaySound(class'Misc_Player'.default.SoundSpawnProtection);
}

simulated function PlayCustomRewardAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if(Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None)
		return;

	if((AnnouncementLevel > AnnouncerLevel) || (RewardAnnouncer == None))
		return;
	if(!bForce && (Level.TimeSeconds - LastPlaySound < 1))
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume) * 0.225, 0.2, 1.0);
	if(ASound != None)
		ClientPlaySound(ASound, true, Atten, SLOT_Talk);
}

function BroadcastAnnouncement(class<LocalMessage> message)
{
	local Controller C;
	for(C = Level.ControllerList; C != None; C = C.NextController)
		if(Misc_Player(C)!=None)
			Misc_Player(C).ReceiveLocalizedMessage(message, int(C==self), PlayerReplicationInfo);
}

simulated function PlayStatusAnnouncementReliable(name AName, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;
	local sound ASound;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if ( (AnnouncementLevel > AnnouncerLevel) || (StatusAnnouncer == None) )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
	ASound = StatusAnnouncer.GetSound(AName);
	if ( ASound != None )
		ClientPlaySound(ASound,true,Atten,SLOT_Talk);
}

function ClientResetClock(int seconds)
{
    Misc_BaseGRI(GameReplicationInfo).RoundTime = seconds;
}

function AcknowledgePossession(Pawn P)
{
    Super.AcknowledgePossession(P);

    SetupCombos();
	
	if(P!=None && PlayerReplicationInfo!=None)
		P.OwnerName = PlayerReplicationInfo.PlayerName;
	
//    if(xPawn(P) != None && Misc_BaseGRI(GameReplicationInfo) != None)
//        xPawn(P).bNoWeaponFiring = Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked;
}

function ClientReceiveCombo(string ComboName)
{
    Super.ClientReceiveCombo(ComboName);

    SetupCombos();
}

function SetupCombos()
{
    local int i;
    local Misc_BaseGRI GRI;
    local bool bDisable;
    local string ComboName;

    GRI = Misc_BaseGRI(Level.GRI);
    if(GRI == None)
        return;

    for(i = 0; i < ArrayCount(ComboList); i++)
    {
        ComboName = ComboNameList[i];
        if(ComboName ~= "")
            continue;

		bDisable = false;
			
        if(ComboName ~= "xGame.ComboDefensive")
            bDisable = (class'Misc_Player'.default.bDisableBooster || GRI.bDisableBooster);
        else if(ComboName ~= "xGame.ComboSpeed")
            bDisable = (class'Misc_Player'.default.bDisableSpeed || GRI.bDisableSpeed);
        else if(ComboName ~= "xGame.ComboBerserk")
            bDisable = (class'Misc_Player'.default.bDisableBerserk || GRI.bDisableBerserk);
        else if(ComboName ~= "xGame.ComboInvis")
            bDisable = (class'Misc_Player'.default.bDisableInvis || GRI.bDisableInvis);

        if(bDisable)
            ComboName = "xGame.Combo";

        ComboList[i] = class<Combo>(DynamicLoadObject(ComboName, class'Class'));
        if(ComboList[i] == None)
            log("Could not find combo:"@ComboName, '3SPN');
    }
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
			PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
        if ( Level.Game.CanSpectate(self,bRealSpec,C) )
        {
            if ( Pick == None )
                Pick = C;
            if ( bFound )
            {
                Pick = C;
                break;
            }
            else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
        }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);

    if(!bWasSpec)
        bBehindView = false;

    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}
/*
state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
	}
}
*/

state Spectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
    	if(bFrozen)
	    {
		    if((TimerRate <= 0.0) || (TimerRate > 1.0))
			    bFrozen = false;
		    return;
	    }
		
        ServerViewNextPlayer();
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
	    if(!PlayerReplicationInfo.bOnlySpectator && !PlayerReplicationInfo.bAdmin && Level.NetMode != NM_Standalone && GameReplicationInfo.bTeamGame)
        {
            if(ViewTarget == None)
                Fire();
            else
		        ToggleBehindView();
        }
	    else
	    {
        	bBehindView = false;
        	ServerViewSelf();
	    }
    }

	function Timer()
	{
    	bFrozen = false;
	}
	
    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
		
	    bCollideWorld = true;
	    CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

function ServerChangeTeam(int Team)
{ 
  local int Adren;

  if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).TournamentModule!=None)
    if(!Team_GameBase(Level.Game).TournamentModule.AllowChangeTeam(self, Team))
      return;
    
  Adren = Adrenaline;
    Super.ServerChangeTeam(Team);
  Adrenaline = Adren;

    if(Team_GameBase(Level.Game) != None && Team_GameBase(Level.Game).bRespawning)
    {
        PlayerReplicationInfo.bOutOfLives = false;
        PlayerReplicationInfo.NumLives = 1;
    }
}
//spectating player wants to become active and join the game
function BecomeActivePlayer()
{
   local bool bRespawning;
   local int TeamIdx;

	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.AllowBecomeActivePlayer(self) )
		return;

	if(!IsInState('GameEnded'))
	{
		bBehindView = false;
		FixFOV();
		ServerViewSelf();
	}
	
	PlayerReplicationInfo.bOnlySpectator = false;
	Level.Game.NumSpectators--;
	Level.Game.NumPlayers++;
	if (Level.Game.GameStats != None)
	{
		Level.Game.GameStats.ConnectEvent(PlayerReplicationInfo);
	}
	PlayerReplicationInfo.Reset();
	Adrenaline = 0;
	LastRezTime = Level.TimeSeconds;
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 1, PlayerReplicationInfo);

	if (Level.Game.bTeamGame)
	{
		if( Team_GameBase(Level.Game)==None || !Team_GameBase(Level.Game).AutoBalanceTeams)
			TeamIdx = int(GetURLOption("Team"));
		else
			TeamIdx = 255;
		Level.Game.ChangeTeam(self, Level.Game.PickTeam(TeamIdx, None), false);
    
    if( Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).AutoBalanceOnJoins )
      Team_GameBase(Level.Game).ForceAutoBalance = true;
	}
	
	if(!IsInState('GameEnded'))
	{
		if (!Level.Game.bDelayedStart)
		{
			// start match, or let player enter, immediately
			Level.Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
			if (Level.Game.bWaitingToStartMatch)
				Level.Game.StartMatch();
			else
				Level.Game.RestartPlayer(PlayerController(Owner));
			Level.Game.bRestartLevel = Level.Game.Default.bRestartLevel;
		}
		else
			GotoState('PlayerWaiting');
	}
	
    ClientBecameActivePlayer();

    if(Role == Role_Authority)
    {		
		NextRezTime = Level.TimeSeconds+2; // 2 seconds before can be resurrected

		if(!IsInState('GameEnded'))
		{
			if(Level.Game.bWaitingToStartMatch)
			{
				PlayerReplicationInfo.bOutOfLives = false;
				PlayerReplicationInfo.NumLives = 1;
			}
			else
			{
				if(Team_GameBase(Level.Game) != None)
					bRespawning = Team_GameBase(Level.Game).bRespawning;
				else if(ArenaMaster(Level.Game) != None)
					bRespawning = ArenaMaster(Level.Game).bRespawning;
				else
					return;

				PlayerReplicationInfo.bOutOfLives = !bRespawning;
				PlayerReplicationInfo.NumLives = int(bRespawning);
			}

			if(!bRespawning)
				GotoState('Spectating');
			else
				GotoState('PlayerWaiting');
		}
    }
}

function DoCombo(class<Combo> ComboClass)
{
    if(TAM_GRI(GameReplicationInfo) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
    {
        Super.DoCombo(ComboClass);
        return;
    }

    ServerDoCombo(ComboClass);
}

function bool CanDoCombo(class<Combo> ComboClass)
{
    if(TAM_GRI(GameReplicationInfo) == None)
        return true;

    if(class<ComboSpeed>(ComboClass) != None)
        return (!TAM_GRI(GameReplicationInfo).bDisableSpeed);
    if(class<ComboDefensive>(ComboClass) != None)
        return (!TAM_GRI(GameReplicationInfo).bDisableBooster);
    if(class<ComboInvis>(ComboClass) != None)
        return (!TAM_GRI(GameReplicationInfo).bDisableInvis);
    if(class<ComboBerserk>(ComboClass) != None)
        return (!TAM_GRI(GameReplicationInfo).bDisableBerserk);

    return true;
}

function bool IsLastmanStandingAndAllowedCombo() {
    local TAM_GRI T;
	local TeamInfo TI;
	
	if(Pawn == None) { return false; }
	
	T  = TAM_GRI(Level.GRI);
	TI = Pawn.GetTeam();
	
    if (T == None || TI == None) { return false; }
	return (T.TeamLastPlayer[Pawn.GetTeamNum()] != None || TI.Size <= 1) && T.bEnableLMSCombos;	
}

function ServerDoCombo(class<Combo> ComboClass)
{
    if(class<ComboBerserk>(ComboClass) != None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPN_Enhanced_A.Misc_ComboBerserk", class'Class'));
    else if(class<ComboSpeed>(ComboClass) != None && class<Misc_ComboSpeed>(ComboClass) == None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPN_Enhanced_A.Misc_ComboSpeed", class'Class'));

    if(Adrenaline < ComboClass.default.AdrenalineCost)
        return;

    if(!CanDoCombo(ComboClass))
        return;
		
	if(IsLastmanStandingAndAllowedCombo()) {
	    Super.ServerDoCombo(ComboClass);
        return;
	}

    if(TAM_GRI(GameReplicationInfo) == None 
	&&(TAM_GRI(Level.GRI).bDisableTeamCombos 
	|| ComboClass.default.Duration<=1))
    {
        Super.ServerDoCombo(ComboClass);
        return;
    }

    if(xPawn(Pawn) != None)
    {
        if(TAM_TeamInfo(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfo(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else if(TAM_TeamInfoRed(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfoRed(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else if(TAM_TeamInfoBlue(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfoBlue(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else
            log("Could not get TeamInfo for player:"@PlayerReplicationInfo.PlayerName, '3SPN');
    }
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
    local Misc_PRI P;

	if(PRI!=None)
		Super.ServerUpdateStatArrays(PRI);

    P = Misc_PRI(PRI);
    if(P == None)
        return;

    ClientSendAssaultStats(P, P.Assault);
    ClientSendBioStats(P, P.Bio);
    ClientSendShockStats(P, P.Shock);
    ClientSendLinkStats(P, P.Link);
    ClientSendMiniStats(P, P.Mini);
    ClientSendFlakStats(P, P.Flak);
    ClientSendRocketStats(P, P.Rockets);
    ClientSendSniperStats(P, P.Sniper);
    ClientSendComboStats(P, P.Combo);
    ClientSendMiscStats(P, P.HeadShots, P.EnemyDamage, P.ReverseFF, P.AveragePercent, 
        P.FlawlessCount, P.OverkillCount, P.DarkHorseCount, P.SGDamage, P.RoxCount);
}

function ClientSendMiscStats(Misc_PRI P, int HS, int ED, float RFF, float AP, int FC, int OC, int DHC, int SGD, int RoxCount)
{
    P.HeadShots = HS;
	P.EnemyDamage = ED;
	P.ReverseFF = RFF;
	P.AveragePercent = AP;
    P.FlawlessCount = FC;
	P.OverkillCount = OC;
	P.DarkHorseCount = DHC;
	P.SGDamage = SGD;
	P.RoxCount = RoxCount;
}

function ClientSendAssaultStats(Misc_PRI P, Misc_PRI.HitStats Assault)
{
    P.Assault.Primary.Fired     = Assault.Primary.Fired;
    P.Assault.Primary.Hit       = Assault.Primary.Hit;
    P.Assault.Primary.Damage    = Assault.Primary.Damage;
    P.Assault.Secondary.Fired   = Assault.Secondary.Fired;
    P.Assault.Secondary.Hit     = Assault.Secondary.Hit;
    P.Assault.Secondary.Damage  = Assault.Secondary.Damage;
}

function ClientSendShockStats(Misc_PRI P, Misc_PRI.HitStats Shock)
{
    P.Shock.Primary.Fired     = Shock.Primary.Fired;
    P.Shock.Primary.Hit       = Shock.Primary.Hit;
    P.Shock.Primary.Damage    = Shock.Primary.Damage;
    P.Shock.Secondary.Fired   = Shock.Secondary.Fired;
    P.Shock.Secondary.Hit     = Shock.Secondary.Hit;
    P.Shock.Secondary.Damage  = Shock.Secondary.Damage;
}

function ClientSendLinkStats(Misc_PRI P, Misc_PRI.HitStats Link)
{
    P.Link.Primary.Fired     = Link.Primary.Fired;
    P.Link.Primary.Hit       = Link.Primary.Hit;
    P.Link.Primary.Damage    = Link.Primary.Damage;
    P.Link.Secondary.Fired   = Link.Secondary.Fired;
    P.Link.Secondary.Hit     = Link.Secondary.Hit;
    P.Link.Secondary.Damage  = Link.Secondary.Damage;
}

function ClientSendMiniStats(Misc_PRI P, Misc_PRI.HitStats Mini)
{
    P.Mini.Primary.Fired     = Mini.Primary.Fired;
    P.Mini.Primary.Hit       = Mini.Primary.Hit;
    P.Mini.Primary.Damage    = Mini.Primary.Damage;
    P.Mini.Secondary.Fired   = Mini.Secondary.Fired;
    P.Mini.Secondary.Hit     = Mini.Secondary.Hit;
    P.Mini.Secondary.Damage  = Mini.Secondary.Damage;
}

function ClientSendFlakStats(Misc_PRI P, Misc_PRI.HitStats Flak)
{
    P.Flak.Primary.Fired     = Flak.Primary.Fired;
    P.Flak.Primary.Hit       = Flak.Primary.Hit;
    P.Flak.Primary.Damage    = Flak.Primary.Damage;
    P.Flak.Secondary.Fired   = Flak.Secondary.Fired;
    P.Flak.Secondary.Hit     = Flak.Secondary.Hit;
    P.Flak.Secondary.Damage  = Flak.Secondary.Damage;
}

function ClientSendRocketStats(Misc_PRI P, Misc_PRI.HitStat Rockets)
{
    P.Rockets.Fired = Rockets.Fired;
    P.Rockets.Hit = Rockets.Hit;
    P.Rockets.Damage = Rockets.Damage;
}

function ClientSendSniperStats(Misc_PRI P, Misc_PRI.HitStat Sniper)
{
    P.Sniper.Fired = Sniper.Fired;
    P.Sniper.Hit = Sniper.Hit;
    P.Sniper.Damage = Sniper.Damage;
}

function ClientSendBioStats(Misc_PRI P, Misc_PRI.HitStat Bio)
{
    P.Bio.Fired = Bio.Fired;
    P.Bio.Hit = Bio.Hit;
    P.Bio.Damage = Bio.Damage;
}

function ClientSendComboStats(Misc_PRI P, Misc_PRI.HitStat Combo)
{
    P.Combo.Fired = Combo.Fired;
    P.Combo.Hit = Combo.Hit;
    P.Combo.Damage = Combo.Damage;
}

state GameEnded
{
    function BeginState()
    {
        Super.BeginState();

        if(Level.NetMode == NM_DedicatedServer)
            return;

        if(MyHUD != None)
        {
            MyHUD.bShowScoreBoard = false;
            MyHUD.bShowLocalStats = false;
        }

		bBehindView = true;
		ClientSetBehindView(true);
		
        SetTimer(1.0, false);
    }

    function Timer()
    {
		if(class'Misc_Player'.default.bAutoScreenShot && !bShotTaken)
            TakeShot();

        Super.Timer();
	}			
}

function BecomeSpectator()
{
	local Misc_PlayerDataManager_ServerLink PlayerDataManager_ServerLink;
	
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.BecomeSpectator(self) )
		return;

	if ( Pawn != None )
		Pawn.Died(self, class'DamageType', Pawn.Location);

	if ( PlayerReplicationInfo.Team != None )
		PlayerReplicationInfo.Team.RemoveFromTeam(self);
	PlayerReplicationInfo.Team = None;

	PlayerDataManager_ServerLink = GetPlayerDataManager_ServerLink();
	if(PlayerDataManager_ServerLink!=None)
		PlayerDataManager_ServerLink.PlayerLeft(self);
		
	ServerSpectate();
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);

	ClientBecameSpectator();
}

function ServerSpectate()
{
	// Proper fix for phantom pawns

	if (Pawn != none && !Pawn.bDeleteMe)
	{
		Pawn.Died(self, class'DamageType', Pawn.Location);
	}

	if(!IsInState('GameEnded'))
	{
		GotoState('Spectating');
		bBehindView = true;	
		ServerViewNextPlayer();
	}
}

function ClientSetWeapon( class<Weapon> WeaponClass )
{
	Log("ClientSetWeapon "$string(WeaponClass.name));
	Super.ClientSetWeapon(WeaponClass);
}

/* exec functions */
exec function Suicide()
{
    if(Pawn != None)
        Pawn.Suicide();
}

function TakeShot()
{
    if(GameReplicationInfo.bTeamGame)
        ConsoleCommand("shot TAM-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    else
        ConsoleCommand("shot AM-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    bShotTaken = true;
}

exec function SetSkins(byte r1, byte g1, byte b1, byte r2, byte g2, byte b2, byte r3, byte g3, byte b3)
{
    class'Misc_Player'.default.RedOrEnemy.R = Clamp(r1, 0, 100);
    class'Misc_Player'.default.RedOrEnemy.G = Clamp(g1, 0, 100);
    class'Misc_Player'.default.RedOrEnemy.B = Clamp(b1, 0, 100);

    class'Misc_Player'.default.BlueOrAlly.R = Clamp(r2, 0, 100);
    class'Misc_Player'.default.BlueOrAlly.G = Clamp(g2, 0, 100);
    class'Misc_Player'.default.BlueOrAlly.B = Clamp(b2, 0, 100);

    class'Misc_Player'.default.Yellow.R = Clamp(r3, 0, 100);
    class'Misc_Player'.default.Yellow.G = Clamp(g3, 0, 100);
    class'Misc_Player'.default.Yellow.B = Clamp(b3, 0, 100);

    class'Misc_Player'.static.StaticSaveConfig();
}

exec function Menu3SPN()
{
	local Rotator r;

	r = GetViewRotation();
	r.Pitch = 0;
	SetRotation(r);

	ClientOpenMenu("3SPN_Enhanced_A.Menu_Menu3SPN");
}

exec function ToggleTeamInfo()
{
    class'Misc_Player'.default.bShowTeamInfo = !class'Misc_Player'.default.bShowTeamInfo;
    class'Misc_Player'.static.StaticSaveConfig();
}

exec function BehindView(bool b)
{
	if(PlayerReplicationInfo.bOnlySpectator || (Pawn == None && !Misc_BaseGRI(GameReplicationInfo).bEndOfRound) 
        || PlayerReplicationInfo.bAdmin || Level.NetMode == NM_Standalone)
		Super.BehindView(b);
	else
		Super.BehindView(false);
}

exec function ToggleBehindView()
{
	if(PlayerReplicationInfo.bOnlySpectator || (Pawn == None && !Misc_BaseGRI(GameReplicationInfo).bEndOfRound) 
        || PlayerReplicationInfo.bAdmin || Level.NetMode == NM_Standalone)
		Super.ToggleBehindView();
	else
		Super.BehindView(false);
}

exec function DisableCombos(bool s, bool b, bool be, bool i, optional bool r, optional bool a)
{
    class'Misc_Player'.default.bDisableSpeed = s;
    class'Misc_Player'.default.bDisableBooster = b;
    class'Misc_Player'.default.bDisableBerserk = be;
    class'Misc_Player'.default.bDisableInvis = i;
    class'Misc_Player'.default.bDisableRadar = r;
    class'Misc_Player'.default.bDisableAmmoRegen = a;

    SetupCombos();
}

exec function UseSpeed()
{
    if(Adrenaline < class'ComboSpeed'.default.AdrenalineCost)
        return;

    DoCombo(class'ComboSpeed');
}

exec function UseBooster()
{
    if(Adrenaline < class'ComboDefensive'.default.AdrenalineCost)
        return;

    DoCombo(class'ComboDefensive');
}

exec function UseInvis()
{
    if(Adrenaline < class'ComboInvis'.default.AdrenalineCost)
        return;

    DoCombo(class'ComboInvis');
}

exec function UseBerserk()
{
    if(Adrenaline < class'ComboBerserk'.default.AdrenalineCost)
        return;

    DoCombo(class'ComboBerserk');
}

exec function UseNecro()
{
    if(Adrenaline < class'NecroCombo'.default.AdrenalineCost)
        return;

    DoCombo(class'NecroCombo');
}

exec function CallTimeout()
{
    ServerCallTimeout();
}

function ServerCallTimeout()
{
    if(Team_GameBase(Level.Game) != None)
        Team_GameBase(Level.Game).CallTimeout(self);
}
/* exec functions */

/* colored names */

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local Class<LocalMessage> LocalMessageClass2;

	switch( MsgType )
	{
		case 'Say':
			if ( PRI == None )
				return;

            if(Misc_PRI(PRI)==None || Misc_PRI(PRI).GetColoredName()=="")
               Msg = PRI.PlayerName$": "$Msg;
            else if(!PRI.bOnlySpectator && PRI.Team!=None && PRI.Team.TeamIndex == 0)
               Msg = Misc_PRI(PRI).GetColoredName()$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.RedMessageColor)$": "$Msg;
			else if(!PRI.bOnlySpectator && PRI.Team!=None && PRI.Team.TeamIndex == 1)
			   Msg = Misc_PRI(PRI).GetColoredName()$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.BlueMessageColor)$": "$Msg;
			else
               Msg = Misc_PRI(PRI).GetColoredName()$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.YellowMessageColor)$": "$Msg;
			LocalMessageClass2 = class'SayMessagePlus';
            break;

		case 'TeamSay':
            if ( PRI == None )
				return;
			if(Misc_PRI(PRI)==None || Misc_PRI(PRI).GetColoredName()=="")
               Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
			else
			   Msg = Misc_PRI(PRI).GetColoredName()$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.GreenMessageColor)$"("$PRI.GetLocationName()$"): "$Msg;
			LocalMessageClass2 = class'TeamSayMessagePlus';
            break;
			
		case 'CriticalEvent':
			LocalMessageClass2 = class'CriticalEventPlus';
			myHud.LocalizedMessage( LocalMessageClass2, 0, None, None, None, Msg );
			return;
			
		case 'DeathMessage':
			LocalMessageClass2 = class'xDeathMessage';
			break;
			
		default:
			LocalMessageClass2 = class'StringMessagePlus';
			break;
	}
	
    if(myHud!=None)
		myHud.AddTextMessage(Msg,LocalMessageClass2,PRI);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
	local string c;
    local int k;
	
	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	if( AllowTextToSpeech(PRI, Type) )
		TextToSpeech( S, TextToSpeechVoiceVolume );
	if ( Type == 'TeamSayQuiet' )
		Type = 'TeamSay';

    //replace the color codes
    if(class'Misc_Player'.default.bAllowColoredMessages)
    {
       for(k=7; k>=0; k--)
       {
          S=Repl(S, "^"$k, class'Misc_Util'.static.ColorReplace(k));
       }
       S=Repl(S, "^r", class'Misc_Util'.static.RandomColor());
    }
    else
    {
       for(k=7; k>=0; k--)
       {
          S=Repl(S, "^"$k, "");
       }
       S=Repl(S, "^r", "");
    }
    if ( myHUD != None )
	{   if (class'Misc_Player'.default.bEnableColoredNamesInTalk)
    	   Message( PRI, c$S, Type );
    	else 
			myHud.Message( PRI, c$S, Type );
    }
	if ( (Player != None) && (Player.Console != None) )
	{
		if ( PRI!=None )
		{
			if ( PRI.Team!=None && GameReplicationInfo.bTeamGame)
			{
    			if (PRI.Team.TeamIndex==0)
					c = chr(27)$chr(200)$chr(1)$chr(1);
    			else if (PRI.Team.TeamIndex==1)
        			c = chr(27)$chr(125)$chr(200)$chr(253);
			}
            S = PRI.PlayerName$": "$S;
		}
		Player.Console.Chat( c$s, 6.0, PRI );
	}
}

function ServerSay(string Msg)
{
  local bool isAdmin; //pass player admin status if they say 'teams'
  
  Super.ServerSay(Msg);
  
  if(Msg ~= "teams")
  {
      isAdmin = False;

      if(PlayerReplicationInfo != None)
          isAdmin = PlayerReplicationInfo.bAdmin;

      if(Team_GameBase(Level.Game) != None)
         Team_GameBase(Level.Game).QueueAutoBalance(isAdmin);
  }
}

simulated function SetColoredNameOldStyle(optional string S2, optional bool bShouldSave)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return;

    if(S2=="")
       S2=PlayerReplicationInfo.PlayerName;
	
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'Misc_Player'.default.ColorName[k-1] == class'Misc_Player'.default.ColorName[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
		if(numdoatonce!=Len(S2) || class'Misc_Player'.default.ColorName[k-1]!=WhiteColor)
			S=S$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.ColorName[k-1])$Right(Left(S2, k), numdoatonce);
    }	
	
    if(Misc_PRI(PlayerReplicationInfo)!=None)
        Misc_PRI(PlayerReplicationInfo).SetColoredName(S);
}

simulated function SetColoredNameOldStyleCustom(optional string S2, optional int CustomColors)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return;

    if(S2=="")
		S2=class'Misc_Player'.default.ColoredName[CustomColors].SavedName;

    SetNameNoReset(S2);
  //  Log(class'Misc_Player'.default.ColoredName[CustomColors].SavedName);
 //   Log(class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].R@class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].G@class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].B);
    for(k=0; k<20; k++)
        class'Misc_Player'.default.ColorName[k]=class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k];
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k-1] == class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
        S=S$class'Misc_Util'.Static.MakeColorCode(class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
	
    if(Misc_PRI(PlayerReplicationInfo)!=None)
        Misc_PRI(PlayerReplicationInfo).SetColoredName(S);
}

exec function SetName(coerce string S)
{
	S=class'Misc_Util'.static.StripColorCodes(S);
	ReplaceText(S, " ", "_");
	ReplaceText(S, "\"", ""); // "
	SetColoredNameOldStyle(Left(S, 20));
	class'Misc_Player'.default.CurrentSelectedColoredName=255;
	CurrentSelectedColoredName=255;
	StaticSaveConfig();
	Super.SetName(S);
}

exec function SetNameNoReset(coerce string S)
{
	S=class'Misc_Util'.static.StripColorCodes(S);
	ReplaceText(S, " ", "_");
	ReplaceText(S, "\"", ""); // "
	SetColoredNameOldStyle(S);
	Super.SetName(S);
}

simulated function string FindColoredName(int CustomColors)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;
    local string S2;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return "";

    if(S2=="")
    {
       S2=class'Misc_Player'.default.ColoredName[CustomColors].SavedName;
    }
    //SetNameNoReset(S2);
 //   Log(class'Misc_Player'.default.ColoredName[CustomColors].SavedName);
 //   Log(class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].R@class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].G@class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[0].B);
    //for(k=0; k<20; k++)
        //class'Misc_Player'.default.ColorName[k]=class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k];
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k-1] == class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
        S=S$class'Misc_Util'.static.MakeColorCode(class'Misc_Player'.default.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
    return S;
}

simulated function SaveNewColoredName()
{
    local int i;
    local int n;
    local int l;

    n=class'Misc_Player'.default.ColoredName.Length+1;
    class'Misc_Player'.default.ColoredName.Length=n;

 //   Log(class'Misc_Player'.default.ColoredName.Length);

    class'Misc_Player'.default.ColoredName[n-1].SavedName=PlayerReplicationInfo.PlayerName;

    for(l=0; l<20; l++)
         class'Misc_Player'.default.ColoredName[n-1].SavedColor[l]=class'Misc_Player'.default.ColorName[l];

    ColoredName.Length=class'Misc_Player'.default.ColoredName.Length;
    for(i=0; i<class'Misc_Player'.default.ColoredName.Length; i++)
        ColoredName[i]=class'Misc_Player'.default.ColoredName[i];
    for(i=0; i<ArrayCount(ColorName); i++)
        ColorName[i]=class'Misc_Player'.default.ColorName[i];
}

simulated function SetInitialColoredName()
{
    if(class'Misc_Player'.default.CurrentSelectedColoredName!=255 && class'Misc_Player'.default.CurrentSelectedColoredName<class'Misc_Player'.default.ColoredName.Length)
        SetColoredNameOldStyleCustom(,class'Misc_Player'.default.CurrentSelectedColoredName);
    else
        SetColoredNameOldStyle();
}

/* server travel */

event PreClientTravel()
{
	//local int i;	
	/*(i=0; i<10; ++i)
	{
		if(EndCeremonyPawns[i]!=None)
			EndCeremonyPawns[i].Destroy();
	}*/
	
	Super.PreClientTravel();
}

/* server travel */

/* colored names */

simulated function ReloadDefaults()
{
	local int i;
	
	bShowCombos = class'Misc_Player'.default.bShowCombos;
	bDisableSpeed = class'Misc_Player'.default.bDisableSpeed;
	bDisableInvis = class'Misc_Player'.default.bDisableInvis;
	bDisableBooster = class'Misc_Player'.default.bDisableBooster;
	bDisableBerserk = class'Misc_Player'.default.bDisableBerserk;
	bDisableRadar = class'Misc_Player'.default.bDisableRadar;
	bDisableAmmoRegen = class'Misc_Player'.default.bDisableAmmoRegen;
	
	bShowTeamInfo = class'Misc_Player'.default.bShowTeamInfo;
	bExtendedInfo = class'Misc_Player'.default.bExtendedInfo;	
	bMatchHUDToSkins = class'Misc_Player'.default.bMatchHUDToSkins;
	
	bUseBrightSkins = class'Misc_Player'.default.bUseBrightSkins;
	bUseTeamColors = class'Misc_Player'.default.bUseTeamColors;
	RedOrEnemy = class'Misc_Player'.default.RedOrEnemy;
	BlueOrAlly = class'Misc_Player'.default.BlueOrAlly;
	Yellow = class'Misc_Player'.default.Yellow;
	
	bForceRedEnemyModel = class'Misc_Player'.default.bForceRedEnemyModel;
	bForceBlueAllyModel = class'Misc_Player'.default.bForceBlueAllyModel;
	bUseTeamModels = class'Misc_Player'.default.bUseTeamModels;
	RedEnemyModel = class'Misc_Player'.default.RedEnemyModel;
	BlueAllyModel = class'Misc_Player'.default.BlueAllyModel;
	
	bDisableAnnouncement = class'Misc_Player'.default.bDisableAnnouncement;
	bAutoScreenShot = class'Misc_Player'.default.bAutoScreenShot;
	
	bAnnounceOverkill = class'Misc_Player'.default.bAnnounceOverkill;
	bUseHitsounds = class'Misc_Player'.default.bUseHitsounds;
	SoundHit = class'Misc_Player'.default.SoundHit;
	SoundHitFriendly = class'Misc_Player'.default.SoundHitFriendly;
	SoundHitVolume = class'Misc_Player'.default.SoundHitVolume;
	SoundAlone = class'Misc_Player'.default.SoundAlone; 
	SoundAloneVolume = class'Misc_Player'.default.SoundAloneVolume;
  SoundSpawnProtection = class'Misc_Player'.default.SoundSpawnProtection;
	SoundTMDeath = class'Misc_Player'.default.SoundTMDeath;
	SoundUnlock = class'Misc_Player'.default.SoundUnlock;
	
	bEnableEnhancedNetCode = class'Misc_Player'.default.bEnableEnhancedNetCode;
	ShowInitialMenu = class'Misc_Player'.default.ShowInitialMenu;
	Menu3SPNKey = class'Misc_Player'.default.Menu3SPNKey;
	bDisableEndCeremonySound = class'Misc_Player'.default.bDisableEndCeremonySound;
	
	bAllowColoredMessages = class'Misc_Player'.default.bAllowColoredMessages;
	bEnableColoredNamesInTalk = class'Misc_Player'.default.bEnableColoredNamesInTalk;
	bEnableColoredNamesOnEnemies = class'Misc_Player'.default.bEnableColoredNamesOnEnemies;

	CurrentSelectedColoredName = class'Misc_Player'.default.CurrentSelectedColoredName;
	for(i=0; i<ArrayCount(ColorName); ++i)
		ColorName[i] = class'Misc_Player'.default.ColorName[i];
	ColoredName =  class'Misc_Player'.default.ColoredName;
	
	AutoSyncSettings = class'Misc_Player'.default.AutoSyncSettings;
}

/* settings */

function ClientSettingsResult(int result, string PlayerName)
{
	class'Message_PlayerSettingsResult'.default.PlayerName = PlayerName;
	class'Message_PlayerSettingsResult'.static.ClientReceive(self, result);

	if(Level.NetMode!=NM_DedicatedServer && class'Misc_Player'.default.ShowInitialMenu==1)
	{
		class'Menu_Menu3SPN'.default.DefaultToInfoTab=True;
		Menu3SPN();
		class'Menu_Menu3SPN'.default.DefaultToInfoTab=False;
		class'Misc_Player'.default.ShowInitialMenu = 2;
		class'Misc_Player'.static.StaticSaveConfig();
	}
}

function ClientLoadSettings(string PlayerName, Misc_PlayerSettings.BrightSkinsSettings BrightSkins, Misc_PlayerSettings.ColoredNamesSettings ColoredNames, Misc_PlayerSettings.MiscSettings Misc)
{
	local int i;
	
	class'Misc_Player'.default.bUseBrightSkins = BrightSkins.bUseBrightSkins;
	class'Misc_Player'.default.bUseTeamColors = BrightSkins.bUseTeamColors;
	class'Misc_Player'.default.RedOrEnemy = BrightSkins.RedOrEnemy;
	class'Misc_Player'.default.BlueOrAlly = BrightSkins.BlueOrAlly;
	class'Misc_Player'.default.Yellow = BrightSkins.Yellow;
	class'Misc_Player'.default.bUseTeamModels = BrightSkins.bUseTeamModels;
	class'Misc_Player'.default.bForceRedEnemyModel = BrightSkins.bForceRedEnemyModel;
	class'Misc_Player'.default.bForceBlueAllyModel = BrightSkins.bForceBlueAllyModel;
	class'Misc_Player'.default.RedEnemyModel = BrightSkins.RedEnemyModel;
	class'Misc_Player'.default.BlueAllyModel = BrightSkins.BlueAllyModel;

	class'Misc_Player'.default.bAllowColoredMessages = ColoredNames.bAllowColoredMessages;
	class'Misc_Player'.default.bEnableColoredNamesInTalk = ColoredNames.bEnableColoredNamesInTalk;
	class'Misc_Player'.default.bEnableColoredNamesOnEnemies = ColoredNames.bEnableColoredNamesOnEnemies;
	for(i=0; i<20; ++i)
		class'Misc_Player'.default.ColorName[i] = ColoredNames.ColorName[i];
	class'Misc_DeathMessage'.default.bEnableTeamColoredDeaths = ColoredNames.bEnableTeamColoredDeaths;
	class'Misc_DeathMessage'.default.bDrawColoredNamesInDeathMessages = ColoredNames.bDrawColoredNamesInDeathMessages;
	class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD = ColoredNames.bEnableColoredNamesOnHUD;
	class'TAM_ScoreBoard'.default.bEnableColoredNamesOnScoreboard = ColoredNames.bEnableColoredNamesOnScoreboard;
	class'Misc_Player'.default.ColoredName.Length = 1;
	for(i=0; i<20; ++i)
		class'Misc_Player'.default.ColoredName[0].SavedColor[i] = ColoredNames.ColorName[i];
	class'Misc_Player'.default.ColoredName[0].SavedName = PlayerReplicationInfo.PlayerName;
	class'Misc_Player'.default.CurrentSelectedColoredName = 0;
	
	class'Misc_Player'.default.bDisableSpeed = Misc.bDisableSpeed;
	class'Misc_Player'.default.bDisableBooster = Misc.bDisableBooster;
	class'Misc_Player'.default.bDisableBerserk = Misc.bDisableBerserk;
	class'Misc_Player'.default.bDisableInvis = Misc.bDisableInvis;
	class'Misc_Player'.default.bMatchHUDToSkins = Misc.bMatchHUDToSkins;
	class'Misc_Player'.default.bShowTeamInfo = Misc.bShowTeamInfo;
	class'Misc_Player'.default.bShowCombos = Misc.bShowCombos;
	class'Misc_Player'.default.bExtendedInfo = Misc.bExtendedInfo;
	class'Misc_Pawn'.default.bPlayOwnFootsteps = Misc.bPlayOwnFootsteps;
	class'Misc_Player'.default.bAutoScreenShot = Misc.bAutoScreenShot;
	class'Misc_Player'.default.bUseHitSounds = Misc.bUseHitSounds;
	class'Misc_Player'.default.bEnableEnhancedNetCode = Misc.bEnableEnhancedNetCode;
	class'Misc_Player'.default.bDisableEndCeremonySound = Misc.bDisableEndCeremonySound;
	class'Misc_Player'.default.SoundHitVolume = Misc.SoundHitVolume;
	class'Misc_Player'.default.SoundAloneVolume = Misc.SoundAloneVolume;
	class'Misc_Player'.default.AutoSyncSettings = Misc.AutoSyncSettings;

	ReloadDefaults();
	SetupCombos();
	SetColoredNameOldStyleCustom(,0);
	class'Misc_Player'.static.StaticSaveConfig();
	class'TAM_ScoreBoard'.static.StaticSaveConfig();
	class'Misc_DeathMessage'.static.StaticSaveConfig();

	ClientSettingsResult(2, PlayerName);
}

function ServerLoadSettings()
{
	local Misc_PlayerSettings PlayerSettings;  
  local Team_GameBase TeamGame;
  
	foreach DynamicActors(class'Team_GameBase', TeamGame)
		break; 
    
  if(!TeamGame.AllowServerSaveSettings)
  {
		Log("Loading settings disabled for player "$PlayerReplicationInfo.PlayerName);
		ClientSettingsResult(6, PlayerReplicationInfo.PlayerName);
    return;
  }
    
  PlayerSettings = class'Misc_PlayerSettings'.static.LoadPlayerSettings(self);
	if(PlayerSettings != None && PlayerSettings.Existing == True)
	{
		Log("Loading settings for player "$PlayerReplicationInfo.PlayerName);		
		ClientLoadSettings(PlayerReplicationInfo.PlayerName, PlayerSettings.BrightSkins, PlayerSettings.ColoredNames, PlayerSettings.Misc);
	}
	else
	{
		Log("Unable to load settings for player "$PlayerReplicationInfo.PlayerName);
		ClientSettingsResult(0, PlayerReplicationInfo.PlayerName);
	}
}

function ServerSaveSettings(Misc_PlayerSettings.BrightSkinsSettings BrightSkins, Misc_PlayerSettings.ColoredNamesSettings ColoredNames, Misc_PlayerSettings.MiscSettings Misc)
{
	local Misc_PlayerSettings PlayerSettings;
  local Team_GameBase TeamGame; 
  
	foreach DynamicActors(class'Team_GameBase', TeamGame)
		break; 
    
  if(!TeamGame.AllowServerSaveSettings)
  {
		Log("Loading settings disabled for player "$PlayerReplicationInfo.PlayerName);
		ClientSettingsResult(6, PlayerReplicationInfo.PlayerName);
    return;
  }
    
  PlayerSettings = class'Misc_PlayerSettings'.static.LoadPlayerSettings(self);   
	if(PlayerSettings != None)
	{
		Log("Saving settings for player "$PlayerReplicationInfo.PlayerName);		
		PlayerSettings.BrightSkins = BrightSkins;
		PlayerSettings.ColoredNames = ColoredNames;
		PlayerSettings.Misc = Misc;
		class'Misc_PlayerSettings'.static.SavePlayerSettings(PlayerSettings);
		ClientSettingsResult(3, PlayerReplicationInfo.PlayerName);
	}
	else
	{
		Log("Unable to save settings for player "$PlayerReplicationInfo.PlayerName);
		ClientSettingsResult(1, PlayerReplicationInfo.PlayerName);
	}
}

function LoadSettings()
{
	local float TimeStampSeconds;
	
	TimeStampSeconds = Level.TimeSeconds;
	if(TimeStampSeconds-LastSettingsLoadTimeSeconds < 5)
	{
		class'Message_PlayerSettingsResult'.static.ClientReceive(self, 4);
		return;
	}	
	LastSettingsLoadTimeSeconds = TimeStampSeconds;

	ServerLoadSettings();
}

function SaveSettings()
{
	local Misc_PlayerSettings.BrightSkinsSettings BrightSkins;
	local Misc_PlayerSettings.ColoredNamesSettings ColoredNames;
	local Misc_PlayerSettings.MiscSettings Misc;
	local int i;
	local float TimeStampSeconds;
	
	TimeStampSeconds = Level.TimeSeconds;
	if(TimeStampSeconds-LastSettingsSaveTimeSeconds < 5)
	{
		class'Message_PlayerSettingsResult'.static.ClientReceive(self, 5);
		return;
	}
	LastSettingsSaveTimeSeconds = TimeStampSeconds;
			
	BrightSkins.bUseBrightSkins = class'Misc_Player'.default.bUseBrightSkins;
	BrightSkins.bUseTeamColors = class'Misc_Player'.default.bUseTeamColors;
	BrightSkins.RedOrEnemy = class'Misc_Player'.default.RedOrEnemy;
	BrightSkins.BlueOrAlly = class'Misc_Player'.default.BlueOrAlly;
	BrightSkins.Yellow = class'Misc_Player'.default.Yellow;
	BrightSkins.bUseTeamModels = class'Misc_Player'.default.bUseTeamModels;
	BrightSkins.bForceRedEnemyModel = class'Misc_Player'.default.bForceRedEnemyModel;
	BrightSkins.bForceBlueAllyModel = class'Misc_Player'.default.bForceBlueAllyModel;
	BrightSkins.RedEnemyModel = class'Misc_Player'.default.RedEnemyModel;
	BrightSkins.BlueAllyModel = class'Misc_Player'.default.BlueAllyModel;

	ColoredNames.bAllowColoredMessages = class'Misc_Player'.default.bAllowColoredMessages;
	ColoredNames.bEnableColoredNamesInTalk = class'Misc_Player'.default.bEnableColoredNamesInTalk;
	ColoredNames.bEnableColoredNamesOnEnemies = class'Misc_Player'.default.bEnableColoredNamesOnEnemies;
	for(i=0; i<20; ++i)
		ColoredNames.ColorName[i] = class'Misc_Player'.default.ColorName[i];
	ColoredNames.bEnableTeamColoredDeaths = class'Misc_DeathMessage'.default.bEnableTeamColoredDeaths;
	ColoredNames.bDrawColoredNamesInDeathMessages = class'Misc_DeathMessage'.default.bDrawColoredNamesInDeathMessages;
	ColoredNames.bEnableColoredNamesOnHUD = class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD;
	ColoredNames.bEnableColoredNamesOnScoreboard = class'TAM_ScoreBoard'.default.bEnableColoredNamesOnScoreboard;
	
	Misc.bDisableSpeed = class'Misc_Player'.default.bDisableSpeed;
	Misc.bDisableBooster = class'Misc_Player'.default.bDisableBooster;
	Misc.bDisableBerserk = class'Misc_Player'.default.bDisableBerserk;
	Misc.bDisableInvis = class'Misc_Player'.default.bDisableInvis;
	Misc.bMatchHUDToSkins = class'Misc_Player'.default.bMatchHUDToSkins;
	Misc.bShowTeamInfo = class'Misc_Player'.default.bShowTeamInfo;
	Misc.bShowCombos = class'Misc_Player'.default.bShowCombos;
	Misc.bExtendedInfo = class'Misc_Player'.default.bExtendedInfo;
	Misc.bPlayOwnFootsteps = class'Misc_Pawn'.default.bPlayOwnFootsteps;
	Misc.bAutoScreenShot = class'Misc_Player'.default.bAutoScreenShot;
	Misc.bUseHitSounds = class'Misc_Player'.default.bUseHitSounds;
	Misc.bEnableEnhancedNetCode = class'Misc_Player'.default.bEnableEnhancedNetCode;
	Misc.bDisableEndCeremonySound = class'Misc_Player'.default.bDisableEndCeremonySound;
	Misc.SoundHitVolume = class'Misc_Player'.default.SoundHitVolume;
	Misc.SoundAloneVolume = class'Misc_Player'.default.SoundAloneVolume;
	Misc.AutoSyncSettings = class'Misc_Player'.default.AutoSyncSettings;
	
	ServerSaveSettings(BrightSkins, ColoredNames, Misc);
}

function ServerReportNewNetStats(bool enable)
{
  bReportNewNetStats = enable;
}

function NotifyServerStartFire(float ClientTimeStamp, float ServerTimeStamp, float AverDT)
{
  local Color  color;
  local string Text, Number;
  
  color = class'Canvas'.static.MakeColor(100, 100, 210);
  Text = class'DMStatsScreen'.static.MakeColorCode(color);

  color = class'Canvas'.static.MakeColor(210, 0, 0);
  Number = class'DMStatsScreen'.static.MakeColorCode(color);
  
  if(!bReportNewNetStats)
    return;
    
  ClientMessage("StartFire: "$Text$"Delta="$Number$ClientTimeStamp-ServerTimeStamp$Text$" ClientTS="$Number$ClientTimeStamp$Text$" ServerTS="$Number$ServerTimeStamp$Text$" AverDT="$Number$AverDT$Text);
}

/* settings */

defaultproperties
{
	bShowCombos=True
	bShowTeamInfo=True
	bExtendedInfo=True
	bMatchHUDToSkins=False
	bUseBrightSkins=True
	bUseTeamColors=True
	bUseTeamModels=True
	bEnableEnhancedNetCode=True
	RedOrEnemy=(R=100,A=128)
	BlueOrAlly=(B=100,G=25,A=128)
	Yellow=(G=100,A=128)
	RedMessageColor=(R=255,G=64,B=64,A=200)
	GreenMessageColor=(R=128,G=200,B=128,A=200)
	BlueMessageColor=(R=125,G=200,B=253,A=200)
	YellowMessageColor=(R=200,G=200,B=1,A=200)
	WhiteMessageColor=(R=200,G=200,B=200,A=200)
	WhiteColor=(R=255,G=255,B=255,A=255)
	RedEnemyModel="Gorge"
	BlueAllyModel="Jakob"
	bAnnounceOverkill=True
	bUseHitsounds=True
	SoundHit=Sound'3SPN_Enhanced_A.Sounds.HitSound'
	SoundHitFriendly=Sound'MenuSounds.denied1'
	SoundHitVolume=0.600000
	SoundAlone=Sound'3SPN_Enhanced_A.Sounds.alone'
	SoundAloneVolume=1.000000
  SoundSpawnProtection=Sound'3SPN_Enhanced_A.Sounds.Bleep'
	SoundUnlock=Sound'NewWeaponSounds.Newclickgrenade'
	PlayerReplicationInfoClass=Class'3SPN_Enhanced_A.Misc_PRI'
	Adrenaline=0.100000
	ShowInitialMenu=1 /* disabling initial menu so that the popup does not interfere with agreement dialogs */
	Menu3SPNKey=IK_F7
	 
	EndCeremonyAnimNames(0)=gesture_point
	EndCeremonyAnimNames(1)=gesture_beckon
	EndCeremonyAnimNames(2)=gesture_halt
	EndCeremonyAnimNames(3)=gesture_cheer
	EndCeremonyAnimNames(4)=PThrust
	EndCeremonyAnimNames(5)=AssSmack
	EndCeremonyAnimNames(6)=ThroatCut
	EndCeremonyAnimNames(7)=Specific_1
	EndCeremonyAnimNames(8)=Gesture_Taunt01
	
	EndCeremonyWeaponNames(0)="xWeapons.ShockRifle"
	EndCeremonyWeaponNames(1)="xWeapons.LinkGun"
	EndCeremonyWeaponNames(2)="xWeapons.MiniGun"
	EndCeremonyWeaponNames(3)="xWeapons.FlakCannon"
	EndCeremonyWeaponNames(4)="xWeapons.RocketLauncher"
	EndCeremonyWeaponNames(5)="xWeapons.SniperRifle"
	EndCeremonyWeaponNames(6)="xWeapons.BioRifle"
	EndCeremonyWeaponClasses(0)=class'xWeapons.ShockRifle'
	EndCeremonyWeaponClasses(1)=class'xWeapons.LinkGun'
	EndCeremonyWeaponClasses(2)=class'xWeapons.MiniGun'
	EndCeremonyWeaponClasses(3)=class'xWeapons.FlakCannon'
	EndCeremonyWeaponClasses(4)=class'xWeapons.RocketLauncher'
	EndCeremonyWeaponClasses(5)=class'xWeapons.SniperRifle'
	EndCeremonyWeaponClasses(6)=class'xWeapons.BioRifle'
	
    bAllowColoredMessages=True
    bEnableColoredNamesInTalk=True

    CurrentSelectedColoredName=255
    ColorName(0)=(R=255,G=255,B=255,A=255)
    ColorName(1)=(R=255,G=255,B=255,A=255)
    ColorName(2)=(R=255,G=255,B=255,A=255)
    ColorName(3)=(R=255,G=255,B=255,A=255)
    ColorName(4)=(R=255,G=255,B=255,A=255)
    ColorName(5)=(R=255,G=255,B=255,A=255)
    ColorName(6)=(R=255,G=255,B=255,A=255)
    ColorName(7)=(R=255,G=255,B=255,A=255)
    ColorName(8)=(R=255,G=255,B=255,A=255)
    ColorName(9)=(R=255,G=255,B=255,A=255)
    ColorName(10)=(R=255,G=255,B=255,A=255)
    ColorName(11)=(R=255,G=255,B=255,A=255)
    ColorName(12)=(R=255,G=255,B=255,A=255)
    ColorName(13)=(R=255,G=255,B=255,A=255)
    ColorName(14)=(R=255,G=255,B=255,A=255)
    ColorName(15)=(R=255,G=255,B=255,A=255)
    ColorName(16)=(R=255,G=255,B=255,A=255)
    ColorName(17)=(R=255,G=255,B=255,A=255)
    ColorName(18)=(R=255,G=255,B=255,A=255)
    ColorName(19)=(R=255,G=255,B=255,A=255)
	
	AutoSyncSettings=True
	LastSettingsLoadTimeSeconds=-100
	LastSettingsSaveTimeSeconds=-100	
}
