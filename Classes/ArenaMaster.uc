class ArenaMaster extends xDeathmatch
    config;
	
/* general and misc */
var config int      StartingHealth;
var config int      StartingArmor;
var config float    MaxHealth;

var float           AdrenalinePerDamage;    // adrenaline per 10 damage

var config bool     bDisableSpeed;
var config bool     bDisableBooster;
var config bool     bDisableInvis;
var config bool     bDisableBerserk;
var array<string>   EnabledCombos;

var config bool     bChallengeMode;
var config bool     bForceRUP;
var config int      ForceRUPMinPlayers;

var config bool     bRandomPickups;
var Misc_PickupBase Bases[3];               // random pickup bases

var string          NextMapString;          // used to save mid-game admin changes in the menu

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

/* round related */
var bool            bEndOfRound;            // true if a round has just ended
var bool            bRespawning;            // true if we're respawning players
var int             RespawnTime;            // time left to respawn
var int             LockTime;               // time left until weapons get unlocked
var int             NextRoundTime;          // time left until the next round starts
var int             CurrentRound;           // the current round number (0 = game hasn't started)
var int             RoundStartTime;

var int             RoundsToWin;            // rounds needed to win
/* round related */

/* weapon related */
var config bool bModifyShieldGun;     // use the modified shield gun (higher shield jumps) 
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

/* newnet */
var config bool EnableNewNet;
var TAM_Mutator MutTAM;
/* newnet */

//var config bool ServerLinkEnabled;

var config String ShieldTextureName;
var config string FlagTextureName;
var config bool ShowServerName;
var config bool FlagTextureEnabled;
var config bool FlagTextureShowAcronym;

var Sound OvertimeSound;

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
				ServerState.PlayerInfo[i].Score		 = PRI.Score;
				ServerState.PlayerInfo[i].Ping		 = 4 * PRI.Ping;
				if (bTeamGame && PRI.Team != None)
					ServerState.PlayerInfo[i].StatsID = ServerState.PlayerInfo[i].StatsID | TeamFlag[PRI.Team.TeamIndex];
				i++;
            }
    }

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		M.GetServerPlayers(ServerState);
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    //SpawnProtectionTime = 1000.000000;
	SpawnProtectionTime = 0;

    if(TAM_GRI(GameReplicationInfo) == None)
        return;

    TAM_GRI(GameReplicationInfo).RoundTime = SecsPerRound;

    TAM_GRI(GameReplicationInfo).StartingHealth = StartingHealth;
    TAM_GRI(GameReplicationInfo).StartingArmor = StartingArmor;
    TAM_GRI(GameReplicationInfo).bChallengeMode = bChallengeMode;
    TAM_GRI(GameReplicationInfo).MaxHealth = MaxHealth;

    TAM_GRI(GameReplicationInfo).SecsPerRound = SecsPerRound;
    TAM_GRI(GameReplicationInfo).OTDamage = OTDamage;
    TAM_GRI(GameReplicationInfo).OTInterval = OTInterval;

    TAM_GRI(GameReplicationInfo).CampThreshold = CampThreshold;
    TAM_GRI(GameReplicationInfo).bKickExcessiveCampers = bKickExcessiveCampers;

    TAM_GRI(GameReplicationInfo).bDisableTeamCombos = true;
    TAM_GRI(GameReplicationInfo).bDisableSpeed = bDisableSpeed;
    TAM_GRI(GameReplicationInfo).bDisableInvis = bDisableInvis;
    TAM_GRI(GameReplicationInfo).bDisableBooster = bDisableBooster;
    TAM_GRI(GameReplicationInfo).bDisableBerserk = bDisableBerserk;

    TAM_GRI(GameReplicationInfo).bForceRUP = bForceRUP;
    TAM_GRI(GameReplicationInfo).ForceRUPMinPlayers = ForceRUPMinPlayers;
    TAM_GRI(GameReplicationInfo).bRandomPickups = bRandomPickups;

    TAM_GRI(GameReplicationInfo).GoalScore = RoundsToWin;

    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
	
	Misc_BaseGRI(GameReplicationInfo).Acronym = Acronym;
	Misc_BaseGRI(GameReplicationInfo).EnableNewNet = EnableNewNet;	
  
  Misc_BaseGRI(GameReplicationInfo).ShieldTextureName = ShieldTextureName;  
  Misc_BaseGRI(GameReplicationInfo).FlagTextureName = FlagTextureName;  
  Misc_BaseGRI(GameReplicationInfo).ShowServerName = ShowServerName;
  Misc_BaseGRI(GameReplicationInfo).FlagTextureEnabled = FlagTextureEnabled;
  Misc_BaseGRI(GameReplicationInfo).FlagTextureShowAcronym = FlagTextureShowAcronym;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
    Super.GetServerDetails(ServerState);

    AddServerDetail(ServerState, "3SPN Version", class'TAM_GRI'.default.Version);
    AddServerDetail(ServerState, "Challenge Mode", bChallengeMode);
    AddServerDetail(ServerState, "Random Pickups", bRandomPickups);
}

static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    //weight is held in a byte (max 127?)

    PI.AddSetting("3SPN", "StartingHealth", "Starting Health", 0, 10, "Text", "3;0:999");
    PI.AddSetting("3SPN", "StartingArmor", "Starting Armor", 0, 11, "Text", "3;0:999");
    PI.AddSetting("3SPN", "MaxHealth", "Max Health", 0, 12, "Text", "8;0.0:2.0");
    PI.AddSetting("3SPN", "bChallengeMode", "Challenge Mode", 0, 13, "Check");

    PI.AddSetting("3SPN", "SecsPerRound", "How Many Seconds Per Round", 0, 20, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTDamage", "Overtime Damage", 0, 21, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTInterval", "Overtime Damage Interval", 0, 22, "Text", "3;0:999");

    PI.AddSetting("3SPN", "CampThreshold", "Camp Area", 0, 30, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "bKickExcessiveCampers", "Kick Excessive Campers", 0, 31, "Check",,, True);

    PI.AddSetting("3SPN", "bForceRUP", "Force Ready", 0, 40, "Check",,, True);
    PI.AddSetting("3SPN", "ForceRUPMinPlayers", "Force Ready Min Players", 0, 41, "Text", "3;0;999",, True);
    
    PI.AddSetting("3SPN", "bRandomPickups", "Random Pickups", 0, 50, "Check");
    PI.AddSetting("3SPN", "bDisableSpeed", "Disable Speed", 0, 51, "Check");
    PI.AddSetting("3SPN", "bDisableInvis", "Disable Invis", 0, 52, "Check");
    PI.AddSetting("3SPN", "bDisableBerserk", "Disable Berserk", 0, 53, "Check");
    PI.AddSetting("3SPN", "bDisableBooster", "Disable Booster", 0, 54, "Check");

    PI.AddSetting("3SPN", "bModifyShieldGun", "Use Modified Shield Gun", 0, 60, "Check",,, True);
    PI.AddSetting("3SPN", "AssaultAmmo", "Assault Ammunition", 0, 61, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "AssaultGrenades", "Assault Grenades", 0, 62, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "BioAmmo", "Bio Ammunition", 0, 63, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "ShockAmmo", "Shock Ammunition", 0, 64, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LinkAmmo", "Link Ammunition", 0, 65, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "MiniAmmo", "Mini Ammunition", 0, 66, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "FlakAmmo", "Flak Ammunition", 0, 67, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "RocketAmmo", "Rocket Ammunition", 0, 68, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LightningAmmo", "Lightning Ammunition", 0, 69, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "EnableNewNet", "Enable New Net", 0, 80, "Check");
}

static event string GetDescriptionText(string PropName)
{ 
    switch(PropName)
    {
        case "StartingHealth":      return "Base health at round start.";
        case "StartingArmor":       return "Base armor at round start.";
        case "bChallengeMode":      return "Round winners take a health/armor penalty.";

        case "SecsPerRound":        return "Round time limit before overtime in seconds (default 120).";
        case "OTDamage":            return "The amount of damage all players while in OT.";
        case "OTInterval":          return "The interval at which OT damage is given.";
            
        case "MaxHealth":           return "The maximum amount of health and armor a player can have.";

        case "CampThreshold":       return "The area a player must stay in to be considered camping.";
        case "bKickExcessiveCampers": return "Kick players that camp 4 consecutive times.";
            
        case "bDisableSpeed":       return "Disable the Speed adrenaline combo.";
        case "bDisableInvis":       return "Disable the Invisibility adrenaline combo.";        
        case "bDisableBooster":     return "Disable the Booster adrenaline combo.";
        case "bDisableBerserk":     return "Disable the Berserk adrenaline combo.";

        case "bForceRUP":           return "Force players to ready up after 45 seconds.";
        case "ForceRUPMinPlayers":  return "Force players to ready only when at least this many players present.";
        
        case "bRandomPickups":      return "Spawns three pickups which give random effect when picked up: Health +15, Shield +15 or Adren +10";

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

		case "EnableNewNet":		return "Make enhanced netcode available for players.";		
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

    InOpt = ParseOption(Options, "ChallengeMode");
    if(InOpt != "")
        bChallengeMode = bool(InOpt);

    InOpt = ParseOption(Options, "MaxHealth");
    if(InOpt != "")
        MaxHealth = float(InOpt);

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

    InOpt = ParseOption(Options, "RandomPickups");
    if(InOpt != "")
        bRandomPickups = bool(InOpt);
}

function SpawnRandomPickupBases()
{
    local float Score[3];
    local float eval;
    local NavigationPoint Best[3];
    local NavigationPoint N;

    for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
    {
        if(InventorySpot(N) == None || InventorySpot(N).myPickupBase == None)
            continue;

        eval = FRand() * 5000.0;

        if(Best[0] != None)
            eval += VSize(Best[0].Location - N.Location) * (FRand() * 4.0 - 2.0);
        if(Best[1] != None)
            eval += VSize(Best[1].Location - N.Location) * (FRand() * 3.5 - 1.75);
        if(Best[2] != None)
            eval += VSize(Best[2].Location - N.Location) * (FRand() * 3.0 - 1.5);

        if(Best[0] == N)
            eval = 0;
        if(Best[1] == N)
            eval = 0;
        if(Best[2] == N)
            eval = 0;
            
        if(eval > Score[0])
        {
            Score[2] = Score[1];
            Score[1] = Score[0];
            Score[0] = eval;

            Best[2] = Best[1];
            Best[1] = Best[0];
            Best[0] = N;
        }
        else if(eval > Score[1])
        {
            Score[2] = Score[1];
            Score[1] = eval;

            Best[2] = Best[1];
            Best[1] = N;
        }
        else if(eval > Score[2])
        {
            Score[2] = eval;
            Best[2] = N;
        }
    }

    if(Best[0] != None)
    {
        Bases[0] = Spawn(class'Misc_PickupBase',,, Best[0].Location, Best[0].Rotation);
        Bases[0].MyMarker = InventorySpot(Best[0]);
    }
    if(Best[1] != None)
    {
        Bases[1] = Spawn(class'Misc_PickupBase',,, Best[1].Location, Best[1].Rotation);
        Bases[1].MyMarker = InventorySpot(Best[1]);
    }
    if(Best[2] != None)
    {
        Bases[2] = Spawn(class'Misc_PickupBase',,, Best[2].Location, Best[2].Rotation);
        Bases[2].MyMarker = InventorySpot(Best[2]);
    }
}

event InitGame(string Options, out string Error)
{
	class'TAM_Mutator'.default.EnableNewNet = EnableNewNet;
    bAllowBehindView = true;

    Super.InitGame(Options, Error);
    ParseOptions(Options);

	foreach DynamicActors(class'TAM_Mutator', MutTAM)
		break;
	
    class'xPawn'.Default.ControllerClass = class'Misc_Bot';

	//DisablePersistentStatsForMatch = false;	
	
    MaxLives = 1;
    bForceRespawn = true;
    bAllowWeaponThrowing = true;//false;

    if(bRandomPickups)
        SpawnRandomPickupBases();

	MutTAM.InitWeapons(AssaultAmmo,AssaultGrenades,BioAmmo,ShockAmmo,LinkAmmo,MiniAmmo,FlakAmmo,RocketAmmo,LightningAmmo);
	
    if(bModifyShieldGun)
	{
		class'XWeapons.ShieldFire'.default.SelfForceScale = 1.5;
		class'XWeapons.ShieldFire'.default.SelfDamageScale = 0.1;
		class'XWeapons.ShieldFire'.default.MinSelfDamage = 0;
        
        class'WeaponFire_Shield'.default.SelfForceScale= 1.5;
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

	/*if(ServerLinkEnabled)
	{
		ServerLink = spawn(class'Misc_ServerLink');
		if(ServerLink!=None)
			ServerLink.Connect();
	}*/
	
    SaveConfig();

    RoundsToWin = GoalScore;
    GoalScore = 0;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, 
                          out vector Momentum, class<DamageType> DamageType)
{
    local Misc_PRI PRI;
    local int OldDamage;
    local int NewDamage;
    local int RealDamage;
    local float Score;

    if(bEndOfRound /*|| LockTime > 0*/)
        return 0;

    if(DamageType == Class'DamTypeSuperShockBeam')
        return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(Misc_Pawn(instigatedBy) != None)
    {
        PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
        if(PRI == None)
            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

        /* self-injury */
        if(injured == instigatedBy)
        {
            OldDamage = Misc_PRI(instigatedBy.PlayerReplicationInfo).AllyDamage;
            
            RealDamage = OldDamage + Damage;

            if(class<DamType_Camping>(DamageType) != None || class<DamType_Overtime>(DamageType) != None)
                return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

            if(class<DamTypeShieldImpact>(DamageType) != None)
                NewDamage = OldDamage;
            else
                NewDamage = RealDamage;

            PRI.AllyDamage = NewDamage;
            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                // log event
                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewFriendlyDamage += Score * 0.01;
                    if(Misc_Player(instigatedBy.Controller).NewFriendlyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, -int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage), "FriendlyDamage");
                        Misc_Player(instigatedBy.Controller).NewFriendlyDamage -= int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage);
                    }
                }
                PRI.Score -= Score * 0.01;
                instigatedBy.Controller.AwardAdrenaline((-Score * 0.10) * AdrenalinePerDamage);
            }

            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        }
        else if(instigatedBy != injured)
        {
            PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
            if(PRI == None)
                return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

            OldDamage = PRI.EnemyDamage;
            NewDamage = OldDamage + Damage;
            PRI.EnemyDamage = NewDamage;

            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                // log event
                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewEnemyDamage += Score * 0.01;
                    if(Misc_Player(instigatedBy.Controller).NewEnemyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, int(Misc_Player(instigatedBy.Controller).NewEnemyDamage), "EnemyDamage");
                        Misc_Player(instigatedBy.Controller).NewEnemyDamage -= int(Misc_Player(instigatedBy.Controller).NewEnemyDamage);
                    }

                    if(instigatedBy.FastTrace(injured.Location))
                        Misc_Player(instigatedBy.Controller).HitDamage += Score;
                }
                PRI.Score += Score * 0.01;
                instigatedBy.Controller.AwardAdrenaline((Score * 0.10) * AdrenalinePerDamage);
            }

            if(Damage > (injured.Health + injured.ShieldStrength + 50) && 
                Damage / (injured.Health + injured.ShieldStrength) > 2)
            {
                PRI.OverkillCount++;
                SpecialEvent(PRI, "Overkill");

                if(Misc_Player(instigatedBy.Controller) != None)
                    Misc_Player(instigatedBy.Controller).ReceiveLocalizedMessage(class'Message_Overkill');
                // overkill
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

        // force ready after 90-ish seconds
        if(!bReady && bForceRUP && bPlayersMustBeReady && (ElapsedTime > 60))
                bReady = true;

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

function StartMatch()
{
    Super.StartMatch();

    CurrentRound = 1;
    TAM_GRI(GameReplicationInfo).CurrentRound = 1;
    GameEvent("NewRound", string(CurrentRound), none);

    RoundTime = SecsPerRound;
    TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;   
	RespawnTime = 2;
    LockTime = default.LockTime;

    RoundStartTime = Level.TimeSeconds;
}

function StartNewRound()
{
	RespawnTime = 4;
    LockTime = default.LockTime;

    bRoundOT = false;
    RoundOTTime = 0;
    RoundTime = SecsPerRound;
    RoundStartTime = Level.TimeSeconds;

    CurrentRound++;
    TAM_GRI(GameReplicationInfo).CurrentRound = CurrentRound;
    bEndOfRound = false;
    TAM_GRI(GameReplicationInfo).bEndOfRound = false;

    TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;
    TAM_GRI(GameReplicationInfo).RoundMinute = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

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
			Misc_Player(PC).LoginTime = Level.TimeSeconds;
	}
	
	return PC;
}

// modify player logging in
event PostLogin(PlayerController NewPlayer)
{
	//local Misc_Player P;

	Super.PostLogin(NewPlayer);

    if(!bRespawning && CurrentRound > 0)
    {
        NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
        NewPlayer.PlayerReplicationInfo.NumLives = 0;
        NewPlayer.GotoState('Spectating');
    }
	else if(CurrentRound > 0)
		RestartPlayer(NewPlayer);

    if(Misc_Player(NewPlayer) != None)
        Misc_Player(NewPlayer).ClientKillBases();
		
    CheckMaxLives(None);
} // PostLogin()

function Logout(Controller Exiting)
{
    Super.Logout(Exiting);
    CheckMaxLives(none);

    if(NumPlayers <= 0 && !bWaitingToStartMatch && !bGameEnded && !bGameRestarted)
        RestartGame();
}

function bool BecomeSpectator(PlayerController P)
{
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
		RestartPlayer(NewBot);

    //NewBot.bAdrenalineEnabled = bAllowAdrenaline;

    CheckMaxLives(none);

	return true;
} // AddBot()

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPNv32232.Misc_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPNv32232.Misc_ComboBerserk";

    return ComboName;
}


function string RecommendCombo(string ComboName)
{
    local int i;
    local bool bEnabled;

/* //if no enabled combos don't do any more
    if(EnabledCombos.Length == 0)
        return Super.RecommendCombo(ComboName);
*/

    if(EnabledCombos.Length == 0)
        return "xGame.Combo";

    for(i = 0; i < EnabledCombos.Length; i++)
    {
        if(EnabledCombos[i] ~= ComboName)
        {
            bEnabled = true;
            break;
        }
    }

    if(!bEnabled)
        ComboName = EnabledCombos[Rand(EnabledCombos.Length)];

    return SwapDefaultCombo(ComboName);
}


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
    local byte won;
    local int health;
    local int armor;
    local float formula;

    if(bChallengeMode)
    {
        won = int(P.PlayerReplicationInfo.Score / 10000);
        
        if(RoundsToWin > 0)
            formula = (0.5 / RoundsToWin);
        else
            formula = 0.0;

        health = StartingHealth - ((StartingHealth * formula) * won);
        armor = StartingArmor - ((StartingArmor * formula) * won);

        p.Health = Max(40, health);
        p.HealthMax = Max(40, health);
        p.SuperHealthMax = int(health * MaxHealth);
        
        xPawn(p).ShieldStrengthMax = int(armor * MaxHealth);
        p.AddShieldStrength(Max(0, armor));
    }
    else
    {
        p.Health = StartingHealth;
        p.HealthMax = StartingHealth;
        p.SuperHealthMax = StartingHealth * MaxHealth;

        xPawn(p).ShieldStrengthMax = StartingArmor * MaxHealth;
        p.AddShieldStrength(StartingArmor);
    }

    if(Misc_Player(p.Controller) != None)
        xPawn(p).Spree = Misc_Player(p.Controller).Spree;
}
/*
function SendCountdownMessage(int time)
{
    local Controller c;

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(PlayerController(c) != None)
            PlayerController(c).ReceiveLocalizedMessage(class'Message_SpawnProtection', time);
            //PlayerController(c).ReceiveLocalizedMessage(class'Message_WeaponsLocked', time);
    }
}
*/
/*
function DisableSpawnProtection()
{
    local Controller C;

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(Misc_Pawn(C.Pawn) != None)
            Misc_Pawn(C.Pawn).DeactivateSpawnProtection();
}
*/
state MatchInProgress
{
    function Timer()
    {
		local Controller c;

		for(C=Level.ControllerList; C!=None; C=C.NextController)
		{
			if(Misc_Pawn(C.Pawn) == None)
				continue;
			
			Misc_Pawn(C.Pawn).UpdateSpawnProtection();			
		}
		
        /*if(LockTime>0)
        {
            LockTime--;
            if(LockTime <= 5)
            {
                SendCountDownMessage(LockTime);

                if(LockTime==0)
                    DisableSpawnProtection();
            }
        }*/

        if(NextRoundTime > 0)
        {
            GameReplicationInfo.bStopCountDown = true;
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
            GameReplicationInfo.bStopCountdown = false;
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
                LockWeapons(false);
                GameReplicationInfo.bStopCountdown = false;
            }
        }*/
        else if(RoundTime > 0)
        {
            GameReplicationInfo.bStopCountdown = false;
            RoundTime--;
            TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;
            if(RoundTime % 60 == 0)
                TAM_GRI(GameReplicationInfo).RoundMinute = RoundTime;
            if(RoundTime == 0) {
                bRoundOT = true;
                for(C=Level.ControllerList; C!=None; C=C.NextController)
                    if(PlayerController(C) != None)
                        PlayerController(C).ClientPlaySound(default.OvertimeSound);
            }
        }

        CheckForCampers();
        CleanUpPawns();
		
		if(RespawnTime > 0)
			RespawnTimer();

        Super.Timer();
    }    
}

function RespawnTimer()
{
	local Controller C;
	local Actor Reset;

	RespawnTime--;
	bRespawning = RespawnTime > 0;

	if(RespawnTime == 3)
	{
		for(c = Level.ControllerList; c != None; c = c.NextController)
		{
			if(Misc_Player(c) != None)
			{
				Misc_Player(c).Spree = 0;
				//Misc_Player(c).ClientEnhancedTrackAllPlayers(false, true, false);
				Misc_Player(c).ClientResetClock(SecsPerRound);
			}

			if(c.PlayerReplicationInfo == None || c.PlayerReplicationInfo.bOnlySpectator)
				continue;
			
			if(xPawn(c.Pawn) != None)
			{
				c.Pawn.RemovePowerups();

				if(Misc_Player(c) != None)
					Misc_Player(c).Spree = xPawn(c.Pawn).Spree;

				c.Pawn.Destroy();
			}

			c.PlayerReplicationInfo.bOutOfLives = false;
			c.PlayerReplicationInfo.NumLives = 1;
			
			if(PlayerController(c) != None)
				PlayerController(c).ClientReset();
			c.Reset();
			if(PlayerController(c) != None)
				PlayerController(c).GotoState('Spectating');                     
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
		for(c = Level.ControllerList; c != None; c = c.NextController)
		{
			if(c == None || c.PlayerReplicationInfo == None || c.PlayerReplicationInfo.bOnlySpectator)
				continue;

			if(PlayerController(C) != None && (C.Pawn == None || C.Pawn.Weapon == None))
			{
				if(C.Pawn != None)
					C.Pawn.Destroy();
			
				c.PlayerReplicationInfo.bOutOfLives = false;
				c.PlayerReplicationInfo.NumLives = 1;
				
				PlayerController(C).ClientReset();
				C.Reset();
				PlayerController(C).GotoState('Spectating');
				
				RestartPlayer(c);
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

function RestartPlayer(Controller C)
{
	if(Misc_Player(C) != None)
		Misc_Player(C).ActiveThisRound = true;
	if(Misc_Bot(C) != None)
		Misc_Bot(C).ActiveThisRound = true;
		
	Super.RestartPlayer(C);
}

function bool DestroyActor(Actor A)
{
    if(Projectile(A) != None)
        return true;
    else if(Pawn(A) != None) // && (xPawn(A).Controller == None || xPawn(A).PlayerReplicationInfo == None))
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
            log("Kicking Camper (Possibly Idle): "$c.PlayerReplicationInfo.PlayerName);
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
        /*if(!class'Misc_Player'.default.bDisableRadar && Misc_PRI(Camper.PlayerReplicationInfo) != None && Misc_PRI(Camper.PlayerReplicationInfo).bWarned)
            Misc_Player(c).ClientTrackPlayer(Misc_PRI(Camper.PlayerReplicationInfo), true, true);*/
	}
} // SendCamperWarning()

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    if(Killed != None && Killed.PlayerReplicationInfo != None)
    {
		if(bRespawning)
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
    }
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
		
    if(bRespawning && (NextRoundTime <= 1 && bEndOfRound))
        return false;

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
    else
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None);
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if(bWaitingToStartMatch || bEndOfRound)
        return false;

	if((Scorer != None) && !Scorer.bOutOfLives)
		Living = Scorer;
    
    bNoneLeft = true;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if((C.PlayerReplicationInfo != None) && C.bIsPlayer
            && (!C.PlayerReplicationInfo.bOutOfLives)
            && !C.PlayerReplicationInfo.bOnlySpectator)
        {
			if(Living == None)
				Living = C.PlayerReplicationInfo;
			else if(C.PlayerReplicationInfo != Living)
			{
    	        bNoneLeft = false;
	            break;
			}
        }
    }

    if(bNoneLeft)
    {
		if(Living != None)
			EndRound(Living);
		else
			EndRound(Scorer);
		return true;
	}

    return false;
}

function EndRound(PlayerReplicationInfo Scorer)
{
    local Controller c;
    local PlayerController PC;

	for(C = Level.ControllerList; C != None; C = C.NextController)
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
		
		if(C.PlayerReplicationInfo==None || C.PlayerReplicationInfo.bOnlySpectator)
			continue;

		if(PlayerController(C) != None && C.PlayerReplicationInfo.bOutOfLives)
		{
			PlayerController(C).GotoState('PlayerWaiting');
			PlayerController(C).ClientReset();
		}
	}
	
    bEndOfRound = true;
    TAM_GRI(GameReplicationInfo).bEndOfRound = true;

    AnnounceBest();
	
    if(Scorer != None)
	{
		Scorer.Score += 10000;
		ScoreEvent(Scorer, 0, "ObjectiveScore");
	}

    if(Scorer == None)
    {
		NextRoundTime = 7;
        return;
    }
			
    if(int(Scorer.Score / 10000) >= RoundsToWin)
    {
        EndGame(Scorer, "LastMan");
    }
    else
    {
        for(c = Level.ControllerList; c != None; c = c.NextController)
        {
            PC = PlayerController(c);

            if(PC != None && PC.PlayerReplicationInfo != None)
            {
                if(PC.PlayerReplicationInfo == Scorer || (PC.PlayerReplicationInfo.bOnlySpectator && 
                    (xPawn(PC.ViewTarget) != None && xPawn(PC.ViewTarget).PlayerReplicationInfo == Scorer) || 
                    (Controller(PC.ViewTarget) != None && Controller(PC.ViewTarget).PlayerReplicationInfo == Scorer)))
                    PC.ReceiveLocalizedMessage(class'Message_YouveXTheRound', 1);
                else
                    PC.ReceiveLocalizedMessage(class'Message_YouveXTheRound', 0);
            }
        }

        NextRoundTime = 7;
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

    local string Text;
    local string Green;
    local Color  color;

    color.r = 100;
    color.g = 200;
    color.b = 100;
    Green = class'DMStatsScreen'.static.MakeColorCode(color);

    color.b = 210;
    color.r = 210;
    color.g = 210;
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		PRI = Misc_PRI(C.PlayerReplicationInfo);

		if(PRI == None || PRI.bOnlySpectator)
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
		if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
			acc = Text$"Most Accurate:"@Green$accuracy.GetColoredName()$Text$";"@accuracy.AveragePercent$"%";
		else
			acc = Text$"Most Accurate:"@Green$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
	}

    if(damage != None && damage.EnemyDamage > 0)
	{
		if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
			dam = Text$"Most Damage:"@Green$damage.GetColoredName()$Text$";"@damage.EnemyDamage;
		else
			dam = Text$"Most Damage:"@Green$damage.PlayerName$Text$";"@damage.EnemyDamage;
	}

    if(headshots != None && headshots.Headshots > 0)
	{
		if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
			hs =  Text$"Most Headshots:"@Green$headshots.GetColoredName()$Text$";"@headshots.Headshots;
		else
			hs =  Text$"Most Headshots:"@Green$headshots.PlayerName$Text$";"@headshots.Headshots;
	}

	for(C = Level.ControllerList; C != None; C = C.NextController)
		if(Misc_Player(c) != None)
			Misc_Player(c).ClientListBest(acc, dam, hs);
}

function SetMapString(Misc_Player Sender, string s)
{
    if(Level.NetMode == NM_Standalone || Sender.PlayerReplicationInfo.bAdmin)
        NextMapString = s;
}

function EndGame(PlayerReplicationInfo PRI, string Reason)
{
    Super.EndGame(PRI, Reason);		
    ResetDefaults();
}

function RestartGame()
{
    ResetDefaults();
    Super.RestartGame();
}

function ProcessServerTravel(string URL, bool bItems)
{
	/*if(ServerLink!=None)
		ServerLink.Close();*/
	
    ResetDefaults();
	
    Super.ProcessServerTravel(URL, bItems);
}

function ResetDefaults()
{
    if(bDefaultsReset)
        return;
    bDefaultsReset = true;

    // set all defaults back to their original values
    Class'xPawn'.Default.ControllerClass = class'XGame.xBot';
    Class'XGame.ComboSpeed'.default.Duration = 16;
	
    GoalScore = RoundsToWin;

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
	StartingArmor=100
	MaxHealth=1.250000
	AdrenalinePerDamage=1.000000
	bChallengeMode=False
	bForceRUP=True
	ForceRUPMinPlayers=0
	SecsPerRound=120
	OTDamage=5
	OTInterval=3
	CampThreshold=400.000000
	CampInterval=5
	bKickExcessiveCampers=True
	AssaultAmmo=999
	AssaultGrenades=5
	BioAmmo=20
	ShockAmmo=20
	LinkAmmo=100
	MiniAmmo=75
	FlakAmmo=12
	RocketAmmo=12
	LightningAmmo=10
	ADR_MinorError=-5.000000
	LocalStatsScreenClass=Class'3SPNv32232.Misc_StatBoard'
	DefaultPlayerClassName="3SPNv32232.Misc_Pawn"
	ScoreBoardType="3SPNv32232.AM_Scoreboard"
	HUDType="3SPNv32232.AM_HUD"
	GoalScore=5
	MaxLives=1
	TimeLimit=0
	MutatorClass="3SPNv32232.TAM_Mutator"
	PlayerControllerClassName="3SPNv32232.Misc_Player"
	GameReplicationInfoClass=Class'3SPNv32232.TAM_GRI'
	GameName="ArenaMaster v3"
	Description="One life per round. Don't waste it"
	Acronym="AM"
	LockTime=4
	EnableNewNet=True
	//SpawnProtectionTime=0.000000
	DeathMessageClass=class'3SPNv32232.Misc_DeathMessage';
	LoginMenuClass="3SPNv32232.Menu_TAMLoginMenu"
	//ServerLinkEnabled=False
	OvertimeSound=Sound'3SPNv32232.Sounds.Overtime'
	ShowServerName=True
	FlagTextureEnabled=True
	FlagTextureShowAcronym=True
	MapListType="3SPNv32232.MapListArenaMaster";
}
