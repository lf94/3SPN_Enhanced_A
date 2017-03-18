//----------------------------------------------------------------------------------------------
// NecroCombo [ComboWhore Ed] | ComboWhore Tweak based on original code by Shaun Goeppinger 2013
// www.combowhore.com
//----------------------------------------------------------------------------------------------
class NecroCombo extends Combo;

var() config float NecroScoreAward;
var() config float ShieldOnResurrect;
var() config float SacrificePercentage;

var() config int HealthOnResurrect;

var() config bool bSacrificeHealth;
var() config bool bShareHealth;

var() localized string PropsDisplayText[6];
var() localized string PropsDescText[6];

var Controller Resurrectee;

function Controller PickWhoToRes()
{
    //local array<float> MyDistanceList;
    //local Pawn P;
    //local float distance;
	local array<Controller> MyControllerList;
	local Controller C, Necromancer;
	local int i;
	local float BestRezTime;

	i = 0;
	BestRezTime = 100000;
	Necromancer = Pawn(Owner).Controller;

	if(Necromancer == None || Necromancer.PlayerReplicationInfo == None)
	{
		return None;
	}

	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
        if(C == Necromancer)
            continue;

        if(C.PlayerReplicationInfo==None)
            continue;

        if(C.PlayerReplicationInfo.bOnlySpectator || !C.PlayerReplicationInfo.bOutOfLives)
            continue;
			
		if(Misc_Player(C)!=None && Level.TimeSeconds<Misc_Player(C).NextRezTime)
			continue;

        if((!C.IsA('PlayerController') && !C.PlayerReplicationInfo.bBot) || C.Pawn!=None)
            continue;

        if(C.PlayerReplicationInfo.Team != Necromancer.PlayerReplicationInfo.Team)
            continue;

        if((C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None) ||
           (C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None))
        {
			/*if(Freon_Player(C)!=None)
				P = Freon_Player(C).FrozenPawn;
			else if(Freon_Bot(C)!=None)
				P = Freon_Bot(C).FrozenPawn;
			else
				P = None;

			if(P!=None)
			{
				distance = VSize(P.Location-Necromancer.Pawn.Location);
				
				for(i=0; i<MyDistanceList.Length; i++)
					if(distance<MyDistanceList[i])
						break;

				MyDistanceList.Insert(i,1);
				MyDistanceList[i] = distance;

				MyControllerList.Insert(i,1);
				MyControllerList[i] = C;
			}*/

			// always prefer a player who hasn't been resurrected in the longest time
			if(Misc_Player(C)!=None)
			{			
				if(Misc_Player(C).LastRezTime<BestRezTime)
					MyControllerList.Length = 0;

				BestRezTime = Misc_Player(C).LastRezTime;
			}
			
			i = MyControllerList.Length;
			MyControllerList.Length = i+1;
			MyControllerList[i] = C;			
        }
        else
        {
            if(C.PlayerReplicationInfo.bBot || PlayerController(C)!=None)
            {
				// always prefer a player who hasn't been resurrected in the longest time
				if(Misc_Player(C)!=None)
				{
					if(Misc_Player(C).LastRezTime<BestRezTime)
						MyControllerList.Length = 0;
						
					BestRezTime = Misc_Player(C).LastRezTime;
				}
				
                i = MyControllerList.Length;
				MyControllerList.Length = i+1;
                MyControllerList[i] = C;
            }
        }   
	}

	if(MyControllerList.Length == 0)
		return None;

    /*if(Level.Game.IsA('Freon'))
    {
        return MyControllerList[0];
    }*/
	
    return MyControllerList[Rand(MyControllerList.Length)];
}

function StopEffect(xPawn P)
{
}

function StartEffect(xPawn P)
{
	if(P.Controller == None || P.PlayerReplicationInfo == None)
    {
        Destroy(); 
        return;
    }

	Resurrectee = PickWhoToRes();
    DoResurrection();
}

function Abort()
{
    local Controller Necromancer;
    local Pawn P;

    P = Pawn(Owner);
    if(P != None)
        Necromancer = Pawn(Owner).Controller;

    if(Necromancer != None)
        TeamPlayerReplicationInfo(Necromancer.PlayerReplicationInfo).Combos[4]--;

    if(PlayerController(NecroMancer) != None)
        PlayerController(NecroMancer).ClientPlaySound(Sound'ShortCircuit');

    if(Level.Game.IsA('Freon'))
    {
        if(P != None)
            Pawn(Owner).ReceiveLocalizedMessage(class'NecroMessages', 3, None, None);
    }
    else
    {
        if(P != None)
            Pawn(Owner).ReceiveLocalizedMessage(class'NecroMessages', 1, None, None);
    }

    Destroy();
}

function DoResurrection()
{
    local int ResurrecteeHealth;
    local float ResurrecteeShield;
	local float SacrificedHealth;
	local float SacrificedShield;
	local Inventory LeechInv;
    local Controller Necromancer;
    local Pawn P;
	local NavigationPoint startSpot;
	local int TeamNum;
	local Freon_Pawn xPawn;

    if(Resurrectee == None)
    {
        Abort();
        return;
    }

    P = Pawn(Owner);
    if(P == None)
    {
        Abort();
        return;
    }

    Necromancer = P.Controller;
    if(Necromancer == None)
    {
        Abort();
        return;
    }

	if(Freon_Player(Resurrectee)!=None)
		xPawn = Freon_Player(Resurrectee).FrozenPawn;
	else if(Freon_Bot(Resurrectee)!=None)
		xPawn = Freon_Bot(Resurrectee).FrozenPawn;

	if(xPawn != None)
	{
		if(Freon(Level.Game)==None || Freon(Level.Game).TeleportOnThaw==False)
		{
			// First teleport frozen pawn to a new spawn and then thaw
			if(Resurrectee.PlayerReplicationInfo==None || Resurrectee.PlayerReplicationInfo.Team==None)
				TeamNum = 255;
			else
				TeamNum = Resurrectee.PlayerReplicationInfo.Team.TeamIndex;
				
			startSpot = Level.Game.FindPlayerStart(Resurrectee, TeamNum);
			if(startSpot != None)
			{
				xPawn.SetLocation(startSpot.Location);
				xPawn.SetRotation(startSpot.Rotation);
				xPawn.Velocity = vect(0,0,0);
			}
		}
		
		xPawn.Thaw();

        PlaySound(Sound'Thaw', SLOT_None, 300.0);
        BroadcastLocalizedMessage(class'NecroMessages', 2, Necromancer.PlayerReplicationInfo, Resurrectee.PlayerReplicationInfo);		
    }
    else
    {
        Resurrectee.PlayerReplicationInfo.bOutOfLives = false;
        Resurrectee.PlayerReplicationInfo.NumLives = 1;

        Level.Game.RestartPlayer(Resurrectee);
        if(Resurrectee.Pawn == None)
        {
            Abort();
            return;
        }

		if(PlayerController(Resurrectee) != None)
			PlayerController(Resurrectee).ClientReset();

		if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).bSpawnProtectionOnRez==False && Misc_Pawn(Resurrectee.Pawn)!=None)
			Misc_Pawn(Resurrectee.Pawn).DeactivateSpawnProtection();
			
        PlaySound(Sound'Resurrection', SLOT_None, 300.0);
        BroadcastLocalizedMessage(class'NecroMessages', 0, Necromancer.PlayerReplicationInfo, Resurrectee.PlayerReplicationInfo);
    }
	
    ResurrecteeHealth = HealthOnResurrect;
    ResurrecteeShield = ShieldOnResurrect;

    if(bSacrificeHealth)
    {
        SacrificePercentage = FClamp(SacrificePercentage,0.00,1.00);

        SacrificedHealth = float(P.Health) / 100.00;
        SacrificedHealth *= SacrificePercentage * 100;
        SacrificedHealth = Clamp(SacrificedHealth,SacrificedHealth,P.Health);
        SacrificedShield = (P.ShieldStrength / 100) * (SacrificePercentage * 100);

        if(bShareHealth)
        {
            ResurrecteeHealth = SacrificedHealth;
            ResurrecteeShield = SacrificedShield;
        }

        if(P.FindInventoryType(class'NecroLeech') == None)
        {
            LeechInv = Spawn(class'NecroLeech', P,,,);
            if(LeechInv != None)
            {
                LeechInv.GiveTo(P);
                NecroLeech(LeechInv).LeechAmount = SacrificedHealth;
                NecroLeech(LeechInv).ShieldLeechAmount = SacrificedShield;
            }
        }
    }

    Resurrectee.Pawn.Health = ResurrecteeHealth;
    Resurrectee.Pawn.ShieldStrength = ResurrecteeShield;
	
	if(Misc_Player(Resurrectee)!=None)
		Misc_Player(Resurrectee).LastRezTime = Level.TimeSeconds;

    Necromancer.Adrenaline -= AdrenalineCost;

    Necromancer.PlayerReplicationInfo.Score += NecroScoreAward;
	
	if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).DarkHorse==Necromancer)
		Team_GameBase(Level.Game).DarkHorse=None;

    /*Spawn(class'NecroEffectA', Necromancer.Pawn,, Necromancer.Pawn.Location, Necromancer.Pawn.Rotation);
    Spawn(class'NecroEffectB', Necromancer.Pawn,, Necromancer.Pawn.Location, Necromancer.Pawn.Rotation);
    Spawn(class'NecroEffectA', Resurrectee.Pawn,, Resurrectee.Pawn.Location, Resurrectee.Pawn.Rotation);
    Spawn(class'NecroEffectB', Resurrectee.Pawn,, Resurrectee.Pawn.Location, Resurrectee.Pawn.Rotation);*/

    Destroy();
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("Necro Combo v3", "NecroScoreAward", default.PropsDisplayText[i++], 0, 10, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "HealthOnResurrect", default.PropsDisplayText[i++], 0, 10, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "ShieldOnResurrect", default.PropsDisplayText[i++], 0, 10, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "bSacrificeHealth", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "SacrificePercentage", default.PropsDisplayText[i++], 0, 10, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "bShareHealth", default.PropsDisplayText[i++], 0, 10, "Check");
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NecroScoreAward":	        	return default.PropsDescText[0];
		case "HealthOnResurrect":			return default.PropsDescText[1];
		case "ShieldOnResurrect":			return default.PropsDescText[2];
		case "bSacrificeHealth":	        return default.PropsDescText[3];
		case "SacrificePercentage":	        return default.PropsDescText[4];
		case "bShareHealth":		return default.PropsDescText[5];
	}

	return Super.GetDescriptionText(PropName);
}

function Tick(float DeltaTime);

defaultproperties
{
     NecroScoreAward=5.000000
     ShieldOnResurrect=100.000000
     HealthOnResurrect=100
     PropsDisplayText(0)="Necro Score Award"
     PropsDisplayText(1)="Health When Resurrected"
     PropsDisplayText(2)="Shield When Resurrected"
     PropsDisplayText(3)="bSacrificeHealth"
     PropsDisplayText(4)="SacrificePercentage"
     PropsDisplayText(5)="bShareHealth"
     PropsDescText(0)="How many points should the player receive for performing the necro combo"
     PropsDescText(1)="How much health the resurrectee should spawn with."
     PropsDescText(2)="How much shield the resurrectee should spawn with."
     PropsDescText(3)="Should the Necromancer Sacrifice their Health and Shield? (A percentage of health is taken away from the necromancer and given to the player ressed, as their starting health)."
     PropsDescText(4)="The percentage of health to be sacrificed from the necromancer and given to the player being ressed as starting health."
     PropsDescText(5)="If true, the health lost by the necromancer will be given to the ressed player instead of the health specified in HealthOnResurrect and ShieldOnResurrect (bSacrificeHalth needs to be true for this setting to work)."
     ExecMessage="Necromancy!"
     Duration=1.000000
     keys(0)=1
     keys(1)=1
     keys(2)=2
     keys(3)=2
     ActivateSound=None
     ActivationEffectClass=None
}
