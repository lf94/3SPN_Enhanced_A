class Freon extends TeamArenaMaster
      DependsOn(TAM_Mutator);

#exec AUDIO IMPORT FILE="Sounds\Teleport.wav"

var config float AutoThawTime;
var config float ThawSpeed;
var config float MinHealthOnThaw;
var config float ThawPointScale;

var bool  bTeamHeal;
var config bool bRoundOTCuddling;

var array<Freon_Pawn> FrozenPawns;

var config int NextRoundDelayFreon;
var config bool TeleportOnThaw;
var config bool bSpawnProtectionOnThaw;

var config bool KillGitters;
var config int MaxGitsAllowed;
var config color KillGitterMsgColour;
var config string KillGitterMsg;

var Sound TeleportSound;

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(Freon_GRI(GameReplicationInfo) == None)
        return;

    Freon_GRI(GameReplicationInfo).AutoThawTime = AutoThawTime;
    Freon_GRI(GameReplicationInfo).ThawSpeed = ThawSpeed;
    Freon_GRI(GameReplicationInfo).bTeamHeal = bTeamHeal;
	Freon_GRI(GameReplicationInfo).bRoundOTCuddling = bRoundOTCuddling;
    Freon_GRI(GameReplicationInfo).ThawPointScale = ThawPointScale;
}

function StartNewRound()
{
    FrozenPawns.Remove(0, FrozenPawns.Length);

    Super.StartNewRound();
}


static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    //weight is held in a byte (max value 127?)
    PI.AddSetting("3SPN Freon", "bSpawnProtectionOnThaw", "Enable Spawn Protection After Thawing", 0, 100, "Check");
    PI.AddSetting("3SPN Freon", "TeleportOnThaw", "Teleport After Thawing", 0, 101, "Check");
    PI.AddSetting("3SPN Freon", "AutoThawTime", "Automatic Thawing Time", 0, 102, "Text", "3;0:999");
    PI.AddSetting("3SPN Freon", "ThawSpeed", "Touch Thawing Time", 0, 103, "Text", "3;0:999");
    PI.AddSetting("3SPN Freon", "MinHealthOnThaw", "Minimum Health After Thawing", 0, 104, "Text", "3;0:999");
    PI.AddSetting("3SPN Freon", "ThawPointScale", "Thaw Points Scale", 0, 105, "Text", "8;0:999");
    PI.AddSetting("3SPN Freon", "KillGitters", "Kill Gitters", 0, 106, "Check");
    PI.AddSetting("3SPN Freon", "MaxGitsAllowed", "Max Gits Allowed", 0, 107, "Text", "3;0:999");
	PI.AddSetting("3SPN Freon", "bRoundOTCuddling", "Allow Over-time Cuddling", 0, 108, "Check");
}

static event string GetDescriptionText(string PropName)
{
    switch(PropName)
    {
        case "bSpawnProtectionOnThaw":  return "Enable Spawn Protection After Thawing";
        case "TeleportOnThaw":          return "Teleport After Thawing";
        case "AutoThawTime":            return "Automatic Thawing Time";
        case "ThawSpeed":               return "Touch Thawing Time";
        case "MinHealthOnThaw":         return "Minimum Health After Thawing";
        case "KillGitters":             return "Kill Gitters";
        case "MaxGitsAllowed":          return "Max Gits Allowed";
        case "ThawPointScale":          return "Thawing Points Scalez (default is 2.5)";
		case "bRoundOTCuddling":        return "Allow Cuddling in Over-time.";
    }

    return Super.GetDescriptionText(PropName);
}

function ParseOptions(string Options)
{
    local string InOpt;

    Super.ParseOptions(Options);

    InOpt = ParseOption(Options, "AutoThawTime");
    if(InOpt != "")
        AutoThawTime = float(InOpt);

    InOpt = ParseOption(Options, "ThawSpeed");
    if(InOpt != "")
        ThawSpeed = float(InOpt);

    InOpt = ParseOption(Options, "TeamHeal");
    if(InOpt != "")
        bTeamHeal = bool(InOpt);
	
	
	InOpt = ParseOption(Options, "bRoundOTCuddling");
    if(InOpt != "")
        bRoundOTCuddling = bool(InOpt);
	

    InOpt = ParseOption(Options, "ThawPointScale");
    if(InOpt != "")
       ThawPointScale = float(InOpt);
}

event InitGame(string options, out string error)
{
    Super.InitGame(Options, Error);

    class'xPawn'.Default.ControllerClass = class'Freon_Bot';

    NextRoundDelay = NextRoundDelayFreon;
}

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPN_Enhanced_A.Freon_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPN_Enhanced_A.Misc_ComboBerserk";

    return ComboName;
}

function PawnFroze(Freon_Pawn Frozen)
{
    local int i;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Frozen)
            return;
    }

    FrozenPawns[FrozenPawns.Length] = Frozen;
    Frozen.Spree = 0;

    if(Misc_Player(Frozen.Controller) != None)
        Misc_Player(Frozen.Controller).Spree = 0;
}

//
// Restart a thawing player. Same as RestartPlayer() just sans the spawn effects
//
function RestartFrozenPlayer(Controller aPlayer, vector Loc, rotator Rot, NavigationPoint Anchor)
{
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
    local Vehicle V, Best;
    local vector ViewDir;
    local float BestDist, Dist;
    local TeamInfo BotTeam, OtherTeam;

    if ( (!bPlayersVsBots || (Level.NetMode == NM_Standalone)) && bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
    {
        BotTeam = aPlayer.PlayerReplicationInfo.Team;
        if ( BotTeam == Teams[0] )
            OtherTeam = Teams[1];
        else
            OtherTeam = Teams[0];

        if ( OtherTeam.Size < BotTeam.Size - 1 )
        {
            aPlayer.Destroy();
            return;
        }
    }

    if ( bMustJoinBeforeStart && (UnrealPlayer(aPlayer) != None)
        && UnrealPlayer(aPlayer).bLatecomer )
        return;

    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

    if ( aPlayer.IsA('Bot') && TooManyBots(aPlayer) )
    {
        aPlayer.Destroy();
        return;
    }

    if( bRestartLevel && Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer )
        return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, Loc, Rot);

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,, Loc, Rot);
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$Location);
        aPlayer.GotoState('Dead');
        if ( PlayerController(aPlayer) != None )
            PlayerController(aPlayer).ClientGotoState('Dead','Begin');
        return;
    }
    if ( PlayerController(aPlayer) != None )
        PlayerController(aPlayer).TimeMargin = -0.1;
    if(Anchor != None)
        aPlayer.Pawn.Anchor = Anchor;
    aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    //aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
    {
        // tell bots not to get into nearby vehicles for a little while
        BestDist = 2000;
        ViewDir = vector(aPlayer.Pawn.Rotation);
        for ( V=VehicleList; V!=None; V=V.NextVehicle )
            if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
            {
                Dist = VSize(V.Location - aPlayer.Pawn.Location);
                if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
                    Dist *= 2;
                if ( Dist < BestDist )
                {
                    Best = V;
                    BestDist = Dist;
                }
            }

        if ( Best != None )
            Best.PlayerStartTime = Level.TimeSeconds + 8;
    }
}

// if in health is 0, find the 'ambient' temperature of the map (the average of all player's health)
function PlayerThawed(Freon_Pawn Thawed, optional float Health, optional float Shield, optional bool dying)
{
    local vector Pos;
    local vector Vel;
    local rotator Rot;
    local Controller C;
    local array<TAM_Mutator.WeaponData> WD;
    local Inventory inv;
    local int i;
    local NavigationPoint N;
    local Controller LastHitBy;
    local int Team;
    local bool bGivesGit;
    local int TeamNum;
    local NavigationPoint startSpot;

    if(bEndOfRound)
        return;

    if(!dying && Health == 0.0)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C.Pawn != None)
            {
                Health += C.Pawn.Health;
                i++;
            }
        }

        if(i > 0)
            Health /= i;
    }

    if(!dying && TeleportOnThaw)
    {
        C = Thawed.Controller;

        if(C.PlayerReplicationInfo==None || C.PlayerReplicationInfo.Team==None)
            TeamNum = 255;
        else
            TeamNum = C.PlayerReplicationInfo.Team.TeamIndex;

        startSpot = Level.Game.FindPlayerStart(C, TeamNum);
    }

    if(startSpot != None)
    {
        Pos = startSpot.Location;
        Rot = startSpot.Rotation;
        Vel = vect(0,0,0);

        Thawed.PlaySound(TeleportSound, SLOT_None, 300.0);
        Thawed.PlayTeleportEffect(true, false);
    }
    else
    {
        Pos = Thawed.Location;
        Rot = Thawed.Rotation;
        Vel = Thawed.Velocity;
    }

    C = Thawed.Controller;
    N = Thawed.Anchor;
    LastHitBy = Thawed.LastHitBy;
    bGivesGit = Thawed.bGivesGit;

    if(C.PlayerReplicationInfo == None)
        return;

    // store ammo amounts
    WD = Thawed.MyWD;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Thawed)
            FrozenPawns.Remove(i, 1);
    }

    Thawed.Destroy();

    C.PlayerReplicationInfo.bOutOfLives = false;
    C.PlayerReplicationInfo.NumLives = 1;

    if(PlayerController(C) != None)
        PlayerController(C).ClientReset();

    RestartFrozenPlayer(C, Pos, Rot, N);

    if(C.Pawn != None)
    {
        C.Pawn.SetLocation(Pos);
        C.Pawn.SetRotation(Rot);
        C.Pawn.AddVelocity(Vel);
        C.Pawn.LastHitBy = LastHitBy;

        if(!dying)
        {
            // redistribute ammo
            for(inv = C.Pawn.Inventory; inv != None; inv = inv.Inventory)
            {
                if(Weapon(inv) == None)
                    return;

                for(i = 0; i < WD.Length; i++)
                {
                    if(WD[i].WeaponName ~= string(inv.Class))
                    {
                        Weapon(inv).AmmoCharge[0] = WD[i].Ammo[0];
                        Weapon(inv).AmmoCharge[1] = WD[i].Ammo[1];
						
						// Special shield gun alt fire fix...
						// This happens because there are client side timers that need to be reactived.
						// Only stop/start fire sets the timers.
						if(Weapon(inv).IsA('ShieldGun')) {
						    Weapon(inv).StopFire(1);
						}
                        break;
                    }
                }
            }

            if(Health != 0.0)
            {
                C.Pawn.Health = Max(MinHealthOnThaw,Health);
            }
            else
            {
                C.Pawn.Health = MinHealthOnThaw;
            }
            C.Pawn.ShieldStrength = Shield;
        }

        if(Freon_Pawn(C.Pawn)!=None)
            Freon_Pawn(C.Pawn).bGivesGit = bGivesGit;

        if(dying || bSpawnProtectionOnThaw==False && Misc_Pawn(C.Pawn)!=None)
            Misc_Pawn(C.Pawn).DeactivateSpawnProtection();
    }

    if(PlayerController(C) != None)
        PlayerController(C).ClientSetRotation(Rot);

    Team = C.GetTeamNum();
    if(Team == 255)
        return;

    if(TAM_TeamInfo(Teams[Team]) != None && TAM_TeamInfo(Teams[Team]).ComboManager != None)
        TAM_TeamInfo(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoRed(Teams[Team]) != None && TAM_TeamInfoRed(Teams[Team]).ComboManager != None)
        TAM_TeamInfoRed(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoBlue(Teams[Team]) != None && TAM_TeamInfoBlue(Teams[Team]).ComboManager != None)
        TAM_TeamInfoBlue(Teams[Team]).ComboManager.PlayerSpawned(C);

    if(!dying)
    {
        BroadcastLocalizedMessage(class'Freon_ThawMessage', 255, C.Pawn.PlayerReplicationInfo);
    }
}

function PlayerThawedByTouch(Freon_Pawn Thawed, array<Freon_Pawn> Thawers, optional float Health, optional float Shield)
{
    local Controller C;
    local int i;
    local Freon_PRI xPRI;
    local class<LocalMessage> Message;

    if(bEndOfRound)
        return;

    C = Thawed.Controller;
    PlayerThawed(Thawed, Health, Shield);

    if(PlayerController(C) != None)
        PlayerController(C).ReceiveLocalizedMessage(class'Freon_ThawMessage', 0, Thawers[0].PlayerReplicationInfo);

    if(C.PlayerReplicationInfo == None)
        return;

    for(i = 0; i < Thawers.Length; i++)
    {
        if(Thawers[i].Controller != None)
            Thawers[i].Controller.AwardAdrenaline(5.0);

        xPRI = Freon_PRI(Thawers[i].PlayerReplicationInfo);
        if (xPRI != None)
        {
			xPRI.Thaws += 1;
            Message = None;
            switch(xPRI.Thaws)
            {
            case 10: Message = class'Message_Thaw_Flamer';      break;
            case 20: Message = class'Message_Thaw_Scorcher';    break;
            case 30: Message = class'Message_Thaw_Thawsome';    break;
            case 40: Message = class'Message_Thaw_Incinerator'; break;
            case 50: Message = class'Message_Thaw_GodOfThaw';   break;
            }

            if(Message!=None)
            {
               if(Misc_Player(Thawers[i].Controller)!=None)
                   Misc_Player(Thawers[i].Controller).BroadcastAnnouncement(Message);
            }
        }

        if(PlayerController(Thawers[i].Controller) != None)
            PlayerController(Thawers[i].Controller).ReceiveLocalizedMessage(class'Freon_ThawMessage', 1, C.PlayerReplicationInfo);
    }
}

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
    {
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None &&
                (bEndOfRound || (xPawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    }
}

function bool DestroyActor(Actor A)
{
    if(Freon_Pawn(A) != None && Freon_Pawn(A).bFrozen)
        return true;

    return Super.DestroyActor(A);
}

/*function QueueEndRound(PlayerReplicationInfo Scorer)
{
    EndRound(Scorer);
}*/

function EndRound(PlayerReplicationInfo Scorer)
{
    local Freon_Trigger FT;

    foreach DynamicActors(class'Freon_Trigger', FT)
        FT.Destroy();

    Super.EndRound(Scorer);
}

function AnnounceBest()
{
    local Controller C;

    local string acc;
    local string dam;
    local string hs;
    local string th;
    local string gt;

    local Freon_PRI PRI;
    local Misc_PRI accuracy;
    local Misc_PRI damage;
    local Misc_PRI headshots;
    local Freon_PRI thaws;
    local Freon_PRI git;

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
        PRI = Freon_PRI(C.PlayerReplicationInfo);

        if(PRI == None || PRI.Team == None || PRI.bOnlySpectator)
            continue;

        PRI.ProcessHitStats();

        if(accuracy == None || (accuracy.AveragePercent < PRI.AveragePercent))
            accuracy = PRI;

        if(damage == None || (damage.EnemyDamage < PRI.EnemyDamage))
            damage = PRI;

        if(headshots == None || (headshots.Headshots < PRI.Headshots))
            headshots = PRI;

        if(thaws == None || (thaws.Thaws < PRI.Thaws))
            thaws = PRI;

        if(git == None || (git.Git < PRI.Git))
            git = PRI;
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

    if(thaws != None && thaws.Thaws > 0)
    {
        if(thaws.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                th =  Text$"Most Thaws:"@Red$thaws.GetColoredName()$Text$";"@int(thaws.Thaws)@" ";
            else
                th =  Text$"Most Thaws:"@Red$thaws.PlayerName$Text$";"@int(thaws.Thaws)@" ";
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                th =  Text$"Most Thaws:"@Blue$thaws.GetColoredName()$Text$";"@int(thaws.Thaws)@" ";
            else
                th =  Text$"Most Thaws:"@Blue$thaws.PlayerName$Text$";"@int(thaws.Thaws)@" ";
        }
    }

    if(git != None && git.Git > 0)
    {
        if(git.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                gt =  Text$"Biggest Git:"@Red$git.GetColoredName()$Text$";"@git.Git@" ";
            else
                gt =  Text$"Biggest Git:"@Red$git.PlayerName$Text$";"@git.Git@" ";
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                gt =  Text$"Biggest Git:"@Blue$git.GetColoredName()$Text$";"@git.Git@" ";
            else
                gt =  Text$"Biggest Git:"@Blue$git.PlayerName$Text$";"@git.Git@" ";
        }
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(Freon_Player(c) != None)
            Freon_Player(c).ClientListBestFreon(acc, dam, hs, th, gt);
}

defaultproperties
{
     AutoThawTime=90.000000
     ThawSpeed=5.000000
     MinHealthOnThaw=25
     bTeamHeal=True
     bRoundOTCuddling=True
     bDisableTeamCombos=False
     TeamAIType(0)=Class'3SPN_Enhanced_A.Freon_TeamAI'
     TeamAIType(1)=Class'3SPN_Enhanced_A.Freon_TeamAI'
     DefaultPlayerClassName="3SPN_Enhanced_A.Freon_Pawn"
     ScoreBoardType="3SPN_Enhanced_A.Freon_Scoreboard"
     HUDType="3SPN_Enhanced_A.Freon_HUD"
     PlayerControllerClassName="3SPN_Enhanced_A.Freon_Player"
     GameReplicationInfoClass=Class'3SPN_Enhanced_A.Freon_GRI'
     GameName="Freon"
     Description="Freeze the other team, score a point. Chill well and serve."
     Acronym="Freon"
     NextRoundDelayFreon=1
     TeleportOnThaw=True
     bSpawnProtectionOnThaw=True
     TeleportSound=Sound'Teleport'
     KillGitters=False
     MaxGitsAllowed=1
     KillGitterMsg="You will die on Gits from now on."
     KillGitterMsgColour=(R=226,G=2,B=232,A=0)
     MapListType="3SPN_Enhanced_A.MapListFreon"
     ThawPointScale=2.5
}
