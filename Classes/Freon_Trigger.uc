class Freon_Trigger extends Trigger;

#exec AUDIO IMPORT FILE=Sounds\touch.wav        GROUP=Sounds

var Freon_Pawn        PawnOwner;
var Array<Freon_Pawn> Toucher;
var int               Team;

var Sound ThawSound;
var Sound TouchSound;

var float ThawSpeed;
var float AutoThawTime;
var float FrozeTime;

var float FastThawModifier;

var bool  bTeamHeal;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    PawnOwner = Freon_Pawn(Owner);
    
    if(PawnOwner == None)
    {
        Destroy();
        return;
    }

    AutoThawTime = Freon_GRI(Level.GRI).AutoThawTime;
    ThawSpeed = FMax(Freon_GRI(Level.GRI).ThawSpeed, 0.5);
    bTeamHeal = Freon_GRI(Level.GRI).bTeamHeal;

    Team = PawnOwner.GetTeamNum();
    if(Team == 255)
    {
        Destroy();
        return;
    }

    SetBase(PawnOwner);

    SetTimer(0.5, true);
}

function OwnerFroze()
{ 
    FrozeTime = Level.TimeSeconds;
    GotoState('PawnFrozen');
}

function Touch(Actor Other)
{
    local Freon_Pawn touch;

    if(Other == Owner || !IsRelevant(Other) || Freon_Pawn(Other) == None)
        return;

    touch = Freon_Pawn(Other);
    if(!touch.bFrozen && touch.GetTeamNum() == Team)
    {
        Toucher.Length = Toucher.Length + 1;
        Toucher[Toucher.Length - 1] = touch;
    }    
}

function UnTouch(Actor Other)
{
    if(PawnOwner != None && Other != Owner && Freon_Pawn(Other) != None)
        RemoveToucher(Freon_Pawn(Other));

    Super.UnTouch(Other);
}

function PlayerToucherDied(Pawn P)
{
    if(Freon_Pawn(P) != None && Freon_Pawn(P).GetTeamNum() == Team)
        RemoveToucher(Freon_Pawn(P));

    Super.PlayerToucherDied(P);
}

function RemoveToucher(Freon_Pawn P)
{
    local int i;

    for(i = 0; i < Toucher.Length; i++)
    {
        if(Toucher[i] == P)
        {
            Toucher.Remove(i, 1);
            return;
        }
    }
}

function OwnerDied()
{
    Destroy();
}

function Destroyed()
{
    Toucher.Remove(0, Toucher.Length);
}

function bool TellBotToThaw(Bot B)
{
    if(B.Pawn.ReachedDestination(PawnOwner))
    {
        if(B.Enemy != None && B.EnemyVisible())
        {
            B.DoRangedAttackOn(B.Enemy);
            return true;
        }
    }

    if(B.ActorReachable(PawnOwner))
    {
        B.MoveTarget = PawnOwner;
        B.GoalString = "Trying to thaw";
        B.SetAttractionState();
        return true;
    }

    return false;
}

static function float calculateHealthGain(float Distance, float ThawSpeed, float Touchers)
{
	if(Distance <= 100.0)
		return (100.0 / Max(0.0001,ThawSpeed)) * 0.5 * Touchers;
	else
		return (100.0 / Max(0.0001,ThawSpeed)) * 0.25 * Touchers;
}

function AwardPlayerThaw(PlayerReplicationInfo PRI, float UnthawAmount)
{
	local Freon_GRI xGRI;
	local Freon_PRI xPRI;
	local float WholeThaw;
	
	xGRI = Freon_GRI(Level.GRI);
	if(xGRI == None) return;
	
	xPRI = Freon_PRI(PRI);
	if(xPRI == None) return;
	
	xPRI.PartialThaw += (UnthawAmount * xGRI.ThawPointScale);
	
	// Figure out if we've earned a whole thaw point.
	WholeThaw = xPRI.PartialThaw / 100.0f;
	if(WholeThaw >= 1.0)
	{
		xPRI.Thaws += 1;
		xPRI.Score += 1;
		
		// Put the remainder of the thaw towards our next point!
		xPRI.PartialThaw = WholeThaw - 1.0f;
	}
	
}

function Timer()
{
    local int i;

    local int MostHealth;
    local float HealthGain;

    local float Touchers;
	local float Distance;
	local float UnthawAmount;

    local float AverageDistance;

	if(Team_GameBase(Level.Game).bEndOfRound || Team_GameBase(Level.Game).EndOfRoundTime>0)
		return;
		
    if(bTeamHeal && Toucher.Length > 0)
    {
        for(i = 0; i < Toucher.Length; i++)
        {
            if(Toucher[i].Health > MostHealth)
                MostHealth = Toucher[i].Health;

            if(Toucher[i].bThawFast)
                Touchers += FastThawModifier;
            else
                Touchers += 1.0;

			Distance = VSize(PawnOwner.Location - Toucher[i].Location);
            AverageDistance += Distance;
			
			UnthawAmount = calculateHealthGain(Distance, ThawSpeed, 1.0f);
			//AwardPlayerThaw(Toucher[i].PlayerReplicationInfo, UnthawAmount);
        }

        if(PawnOwner.Health < MostHealth)
        {
            AverageDistance /= i;
			
			HealthGain = calculateHealthGain(AverageDistance, ThawSpeed, Touchers);
            PawnOwner.GiveHealth(HealthGain, MostHealth);
        }
    }        
}

state PawnFrozen
{
    function Touch(Actor Other)
    {
        local Freon_Pawn touch;

        if(Other == Owner || !IsRelevant(Other) || Freon_Pawn(Other) == None)
            return;

        touch = Freon_Pawn(Other);
        if(!touch.bFrozen && touch.GetTeamNum() == Team)
        {
            Toucher.Length = Toucher.Length + 1;
            Toucher[Toucher.Length - 1] = touch;

            PawnOwner.PlaySound(TouchSound);
        }
    }

    function Timer()
    {
        local int i;

        local int MostHealth;
        local float HealthGain;

        local float Touchers;
		local float Distance;
		local float UnthawAmount;
	

        local float AverageDistance;

        if(PawnOwner == None)
        {
            Destroy();
            return;
        }
		
		if(Team_GameBase(Level.Game).bEndOfRound || Team_GameBase(Level.Game).EndOfRoundTime>0)
			return;

        // touch thaw adjustment
        if(Toucher.Length > 0)
        {
            if(PlayerController(PawnOwner.Controller) != None)
                PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'Freon_ThawMessage', 2, Toucher[i].PlayerReplicationInfo);

            for(i = 0; i < Toucher.Length; i++)
            {
                if(Toucher[i].Health > MostHealth)
                    MostHealth = Toucher[i].Health;

                if(Toucher[i].bThawFast)
                    Touchers += FastThawModifier;
                else
                    Touchers += 1.0;

                Distance = VSize(PawnOwner.Location - Toucher[i].Location);
				AverageDistance += Distance;
				
				UnthawAmount = calculateHealthGain(Distance, ThawSpeed, 1.0f);
				AwardPlayerThaw(Toucher[i].PlayerReplicationInfo, UnthawAmount);
            }

            AverageDistance /= i;

            HealthGain += calculateHealthGain(AverageDistance, ThawSpeed, Touchers);
        }
        // auto thaw adjustment
        else if(AutoThawTime > 0.0)
            HealthGain += (100.0 / AutoThawTime * 0.5);

        PawnOwner.DecimalHealth += HealthGain;
        if(PawnOwner.DecimalHealth >= 1.0)
        {
            HealthGain = int(PawnOwner.DecimalHealth);
            PawnOwner.DecimalHealth -= HealthGain;
            PawnOwner.GiveHealth(HealthGain, 100);
        }

        // thaw if needed
        if(PawnOwner.Health == 100)
        {
            PawnOwner.DecimalHealth = 0.0;

            if(PlayerController(PawnOwner.Controller) != None)
                PlayerController(PawnOwner.Controller).ClientPlaySound(ThawSound);
            PawnOwner.PlaySound(ThawSound, SLOT_Interact, PawnOwner.TransientSoundVolume * 1.5,, PawnOwner.TransientSoundRadius * 1.5);

            if(Toucher.Length > 0)
                PawnOwner.ThawByTouch(Toucher, MostHealth);
            else
                PawnOwner.Thaw();

            if(PawnOwner == None)
                Destroy();
        }
    }
}

defaultproperties
{
     Team=255
     ThawSound=Sound'WeaponSounds.BaseGunTech.BGrenfloor1'
     TouchSound=Sound'3SPNv32232.Sounds.Touch'
     ThawSpeed=5.000000
     AutoThawTime=60.000000
     FastThawModifier=1.500000
     bTeamHeal=True
     TriggerType=TT_LivePlayerProximity
     bHardAttach=True
     CollisionRadius=200.000000
     CollisionHeight=100.000000
}
