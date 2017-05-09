class TeamArenaMaster extends Team_GameBase
    config;

/* general and misc */
var config bool     bDisableTeamCombos;
var config bool     bChallengeMode;

var config bool     bRandomPickups;
var Misc_PickupBase Bases[3];           // random pickup bases

var config bool     bPureRFF;
/* general and misc */

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(TAM_GRI(GameReplicationInfo) == None)
        return;

    TAM_GRI(GameReplicationInfo).bChallengeMode = bChallengeMode;
    TAM_GRI(GameReplicationInfo).bDisableTeamCombos = bDisableTeamCombos;
    TAM_GRI(GameReplicationInfo).bRandomPickups = bRandomPickups;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
    Super.GetServerDetails(ServerState);

    AddServerDetail(ServerState, "Team Combos", !bDisableTeamCombos);
    AddServerDetail(ServerState, "Challenge Mode", bChallengeMode);
    AddServerDetail(ServerState, "Random Pickups", bRandomPickups);
}

static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    // weight is a byte value (max 127?)
    PI.AddSetting("3SPN", "bChallengeMode", "Challenge Mode", 0, 110, "Check");
    PI.AddSetting("3SPN", "bRandomPickups", "Random Pickups", 0, 111, "Check");
    PI.AddSetting("3SPN", "bDisableTeamCombos", "No Team Combos", 0, 112, "Check");
    PI.AddSetting("3SPN", "bPureRFF", "2.57 style RFF", 0, 113, "Check");
}

static event string GetDescriptionText(string PropName)
{ 
    switch(PropName)
    {
        case "bChallengeMode":      return "Round winners take a health/armor penalty.";
        case "bDisableTeamCombos":  return "Turns off team combos. Only the user gets the combo.";
        case "bRandomPickups":      return "Spawns three pickups which give random effect when picked up: Health +10/20, Shield +10/20 or Adren +10";
        case "bPureRFF":            return "All teammate damage is reflected back.";
    }

    return Super.GetDescriptionText(PropName);
}

function UnrealTeamInfo GetBlueTeam(int TeamBots)
{
    if(BlueTeamName != "")
        BlueTeamName = "3SPN_Enhanced_A.TAM_TeamInfoBlue";
    return Super.GetBlueTeam(TeamBots);
}

function UnrealTeamInfo GetRedTeam(int TeamBots)
{
    if(RedTeamName != "")
        RedTeamName = "3SPN_Enhanced_A.TAM_TeamInfoRed";
    return Super.GetRedTeam(TeamBots);
}

function ParseOptions(string Options)
{
    local string InOpt;

    Super.ParseOptions(Options);

    InOpt = ParseOption(Options, "ChallengeMode");
    if(InOpt != "")
        bChallengeMode = bool(InOpt);

    InOpt = ParseOption(Options, "DisableTeamCombos");
    if(InOpt != "")
        bDisableTeamCombos = bool(InOpt);

    InOpt = ParseOption(Options, "RandomPickups");
    if(InOpt != "")
        bRandomPickups = bool(InOpt);

    InOpt = ParseOption(Options, "PureRFF");
    if(InOpt != "")
        bPureRFF = bool(InOpt);
}

function SpawnRandomPickupBases()
{
    local int i;
    local float Score[3];
    local float eval;
    local NavigationPoint Best[3];
    local NavigationPoint N;

    for(i = 0; i < 100; i++)
        FRand();

    for(i = 0; i < 3; i++)
    {
        for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
        {
            if(InventorySpot(N) == None || InventorySpot(N).myPickupBase == None)
                continue;

            eval = 0;

            if(i == 0)
                eval = FRand() * 5000.0;
            else
            {
                if(Best[0] != None)
                    eval = VSize(Best[0].Location - N.Location) * (0.8 + FRand() * 1.2);

                if(i > 1 && Best[1] != None)
                    eval += VSize(Best[1].Location - N.Location) * (1.5 + FRand() * 0.5);
            }

            if(Best[0] == N)
                eval = 0;
            if(Best[1] == N)
                eval = 0;
            if(Best[2] == N)
                eval = 0;

            if(Score[i] < eval)
            {
                Score[i] = eval;
                Best[i] = N;
            }
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
    local Mutator mut;
    local bool bNoAdren;

    bAllowBehindView = true;

    Super.InitGame(Options, Error);

    if(bRandomPickups)
    {
        for(mut = BaseMutator; mut != None; mut = mut.NextMutator)
        {
            if(mut.IsA('MutNoAdrenaline'))
            {
                bNoAdren = true;   
                break;
            }
        }

        if(bNoAdren)
            class'Misc_PickupBase'.default.PickupClasses[4] = None;
        else
            class'Misc_PickupBase'.default.PickupClasses[4] = class'Misc_PickupAdren';
        SpawnRandomPickupBases();
    }

    // setup adren amounts
    AdrenalinePerDamage = 0.75;
    if(bRandomPickups)
        AdrenalinePerDamage -= 0.25;
    if(!bDisableTeamCombos)
        AdrenalinePerDamage += 0.25;
}

event PostLogin(PlayerController NewPlayer)
{
    Super.PostLogin(NewPlayer);

    if(bPureRFF && Misc_PRI(NewPlayer.PlayerReplicationInfo) != None)
        Misc_PRI(NewPlayer.PlayerReplicationInfo).ReverseFF = 1.0;
}

function RestartPlayer(Controller C)
{
    local int Team;

    Super.RestartPlayer(C);

    if(C == None)
        return;

    Team = C.GetTeamNum();
    if(Team == 255)
        return;

    if(TAM_TeamInfo(Teams[Team]) != None && TAM_TeamInfo(Teams[Team]).ComboManager != None)
        TAM_TeamInfo(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoRed(Teams[Team]) != None && TAM_TeamInfoRed(Teams[Team]).ComboManager != None)
        TAM_TeamInfoRed(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoBlue(Teams[Team]) != None && TAM_TeamInfoBlue(Teams[Team]).ComboManager != None)
        TAM_TeamInfoBlue(Teams[Team]).ComboManager.PlayerSpawned(C);
}

function SetupPlayer(Pawn P)
{
    local byte difference;
    local byte won;
    local int health;
    local int armor;
    local float formula;

    Super.SetupPlayer(P);

    if(bChallengeMode)
    {
        difference = Max(0, Teams[p.GetTeamNum()].Score - Teams[int(!bool(p.GetTeamNum()))].Score);
        difference += Max(0, Teams[p.GetTeamNum()].Size - Teams[int(!bool(p.GetTeamNum()))].Size) * 2;

        won = p.PlayerReplicationInfo.Team.Score;
        if(GoalScore > 0)
            formula = 0.25 / GoalScore;
        else
            formula = 0.0;

        health = StartingHealth - (((StartingHealth * formula) * difference) + ((StartingHealth * formula) * won));
        armor = StartingArmor - (((StartingArmor * formula) * difference) + ((StartingArmor * formula) * won));

        p.Health = Max(40, health);
        p.HealthMax = health;
        p.SuperHealthMax = int(health * MaxHealth);
        
        xPawn(p).ShieldStrengthMax = Max(0, int(armor * MaxHealth));
        p.AddShieldStrength(Max(0, armor));
    }
    else
        p.AddShieldStrength(StartingArmor);

    if(TAM_TeamInfo(p.PlayerReplicationInfo.Team) != None)
        TAM_TeamInfo(p.PlayerReplicationInfo.Team).StartingHealth = p.Health + p.ShieldStrength;
    else if(TAM_TeamInfoBlue(p.PlayerReplicationInfo.Team) != None)
        TAM_TeamInfoBlue(p.PlayerReplicationInfo.Team).StartingHealth = p.Health + p.ShieldStrength;
    else if(TAM_TeamInfoRed(p.PlayerReplicationInfo.Team) != None)
        TAM_TeamInfoRed(p.PlayerReplicationInfo.Team).StartingHealth = p.Health + p.ShieldStrength;
}

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPN_Enhanced_A.Misc_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPN_Enhanced_A.Misc_ComboBerserk";

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


function StartNewRound()
{
    if(TAM_TeamInfo(Teams[0]) != None && TAM_TeamInfo(Teams[0]).ComboManager != None)
        TAM_TeamInfo(Teams[0]).ComboManager.ClearData();
    else if(TAM_TeamInfoRed(Teams[0]) != None && TAM_TeamInfoRed(Teams[0]).ComboManager != None)
        TAM_TeamInfoRed(Teams[0]).ComboManager.ClearData();

    if(TAM_TeamInfo(Teams[1]) != None && TAM_TeamInfo(Teams[1]).ComboManager != None)
        TAM_TeamInfo(Teams[1]).ComboManager.ClearData();
    else if(TAM_TeamInfoBlue(Teams[1]) != None && TAM_TeamInfoBlue(Teams[1]).ComboManager != None)
        TAM_TeamInfoBlue(Teams[1]).ComboManager.ClearData();

    Super.StartNewRound();
}

defaultproperties
{
     bDisableTeamCombos=True
     bChallengeMode=False
     StartingArmor=100
     MaxHealth=1.250000
     bForceRespawn=True
     //SpawnProtectionTime=0.000000
     MaxLives=1
     GameReplicationInfoClass=Class'3SPN_Enhanced_A.TAM_GRI'
     GameName="Team ArenaMaster En_A"
     Acronym="TAM"
     MapListType="3SPN_Enhanced_A.MapListTeamArenaMaster";
}
