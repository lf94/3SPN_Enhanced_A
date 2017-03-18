/* some code taken from L7's freeze tag mod */

class Freon_Pawn extends Misc_Pawn;

var bool            bFrozen;
var bool            bClientFrozen;
var bool			bGivesGit;

var Freon_Trigger   MyTrigger;

var float           DecimalHealth;    // used server-side only, to allow decimals to be added to health

var Material        FrostMaterial;
var Material        FrostMap;

var bool            bThawFast;

var array<TAM_Mutator.WeaponData> MyWD;

var Sound           ImpactSounds[6];

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        bFrozen;
}

simulated function UpdatePrecacheMaterials()
{
    Super.UpdatePrecacheMaterials();

    Level.AddPrecacheMaterial(FrostMaterial);
    Level.AddPrecacheMaterial(FrostMap);
}

simulated function Destroyed()
{
    if(MyTrigger != None)
    {
        MyTrigger.Destroy();
        MyTrigger = None;
    }

    Super.Destroyed();
}

function PossessedBy(Controller C)
{
    Super.PossessedBy(C);

    if(MyTrigger == None)
        MyTrigger = spawn(class'Freon_Trigger', self,, Location, Rotation);
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{
    local vector zeroVec;
    local int ActualDamage;
    local Controller Killer;

    zeroVec = vect(0.0,0.0,0.0);
    //if(Level.TimeSeconds-SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
	if(IsSpawnProtectionEnabled())
    {
        Super.TakeDamage(0, instigatedBy, hitlocation, zeroVec, damageType);
        return;
    }

    if ( DamageType == None )
    {
        if ( InstigatedBy != None ) 
            Warn( "No DamageType for damage by "$InstigatedBy$" with weapon "$InstigatedBy.Weapon );
        DamageType = class'DamageType';
    }

    if ( Role < ROLE_Authority ) 
    {
        Log( self$" client DamageType "$DamageType$" by "$InstigatedBy );
        return;
    }

    if ( Health <= 0 ) 
        return;

    if ( ( InstigatedBy == None || InstigatedBy.Controller == None ) &&
         ( DamageType.default.bDelayedDamage ) &&
         ( DelayedDamageInstigatorController != None ) ) 
        InstigatedBy = DelayedDamageInstigatorController.Pawn;

    if ( Physics == PHYS_None && DrivenVehicle == None )
        SetMovementPhysics();

    if ( Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ )
        Momentum.Z = FMax( Momentum.Z, 0.4 * VSize( Momentum ) );

    if ( InstigatedBy == self )
        Momentum *= 0.6;

    Momentum = Momentum / Mass;

    if ( Weapon != None )
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( DrivenVehicle != None )
        DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( ( InstigatedBy != None ) && InstigatedBy.HasUDamage() ) 
        Damage *= 2;

    ActualDamage = Level.Game.ReduceDamage( Damage, self, InstigatedBy, HitLocation, Momentum, DamageType );

    if( DamageType.default.bArmorStops && ( ActualDamage > 0 ) )
        ActualDamage = ShieldAbsorb( ActualDamage );

    Health -= ActualDamage;

    if ( HitLocation == vect(0,0,0) )
        HitLocation = Location;

/* L7 out
    PlayHit( ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum );
L7 out */

    if ( Health <= 0 ) 
    {
        // pawn froze or died -->

        if ( DamageType.default.bCausedByWorld && ( InstigatedBy == None || InstigatedBy == self ) && LastHitBy != None )
            Killer = LastHitBy;
        else if ( InstigatedBy != None )
            Killer = InstigatedBy.GetKillerController();

        if ( Killer == None && DamageType.default.bDelayedDamage )
            Killer = DelayedDamageInstigatorController;

        if(Level.Game.PreventDeath(self, Killer, DamageType, HitLocation))
        {
            Health = Max(Health, 1);

            PlayHit(ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum);
            
            if(bPhysicsAnimUpdate) 
                TearOffMomentum = Momentum;
        }
        else if(Froze(Killer, DamageType, HitLocation))
            PlayFreezingHit();
        else
        {
            PlayHit(ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum);

            if (bPhysicsAnimUpdate) 
                TearOffMomentum = Momentum;

            Died(Killer, DamageType, HitLocation);
        }
    } 
    else 
    {
        // pawn only damaged -->
// L7 -->
        PlayHit( ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum );
// L7 <--
        AddVelocity( Momentum );

        if ( Controller != None ) 
            Controller.NotifyTakeHit( InstigatedBy, HitLocation, ActualDamage, DamageType, Momentum );

        if ( InstigatedBy != None && InstigatedBy != self )
            LastHitBy = InstigatedBy.Controller;
    }
    MakeNoise( 1.0 );
}

function Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    local Freon_PRI xPRI;
    local Freon Freon;
    local Controller Gitter;  
    
    if(bGivesGit)
    {
        if(Killer!=None)
            Gitter = Killer;
        else if(LastHitBy!=None)
            Gitter = LastHitBy;
        else
            Gitter = None;
              
        if(Gitter!=None && Misc_Player(Gitter)!=None && self.Controller!=Gitter)
        {
            xPRI = Freon_PRI(Gitter.PlayerReplicationInfo);
            if(xPRI!=None)
            {
                ++xPRI.Git;
            
                Freon = Freon(Level.Game);
                if(Freon.KillGitters)
                {
                    if(xPRI.Git==Freon.MaxGitsAllowed)
                    {
                        Misc_Player(Gitter).ClientMessage("Warning:"@Class'GameInfo'.static.MakeColorCode(Freon.KillGitterMsgColour)$Freon.KillGitterMsg);
                    }
                    else if(xPRI.Git>Freon.MaxGitsAllowed)
                    {
                        Misc_Player(Gitter).BroadcastAnnouncement(class'Message_Git');
                        if(Misc_Player(Gitter).Pawn!=None)
                            Misc_Player(Gitter).Pawn.Suicide();
                    }
                }
                else
                {
                    if(xPRI.Git%4 == 0)
                    {
                        if(Misc_Player(Gitter)!=None)
                            Misc_Player(Gitter).BroadcastAnnouncement(class'Message_Git');
                        Gitter.Adrenaline = Max(0,Gitter.Adrenaline-24);
                    }
                }
            }
        }
    }

    if(MyTrigger != None)
        MyTrigger.OwnerDied();

    Super.Died(Killer, DamageType, HitLocation);
}

function bool Froze(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
    //local Vector TossVel;
    local Trigger T;
    local NavigationPoint N;

    // DETERMINE IF PAWN FROZE -->

    if(bDeleteMe || Level.bLevelChange || Level.Game == None)
        return false;

    if(Controller == None || DrivenVehicle != None)
        return false;

    if(DamageType == class'DamageType' || DamageType.default.bCausedByWorld)
        return false;

    if(IsInPain())
        return false;

    // PAWN FROZE -->

    bFrozen = true;

    if(Freon_PawnReplicationInfo(Freon_PRI(PlayerReplicationInfo).PawnReplicationInfo) != None)
        Freon_PawnReplicationInfo(Freon_PRI(PlayerReplicationInfo).PawnReplicationInfo).PawnFroze();

    FillWeaponData();
    Health = 0;
    AmbientSound = None;
    bProjTarget = false;
    bCanPickupInventory = false;
    //bNoWeaponFiring = true;

    PlayerReplicationInfo.bOutOfLives = true;
    NetUpdateTime = Level.TimeSeconds - 1;
    Controller.WasKilledBy(Killer);
    Level.Game.Killed(Killer, Controller, self, DamageType);

    if ( Killer != None ) 
        TriggerEvent( Event, self, Killer.Pawn );
    else 
        TriggerEvent( Event, self, None );

    // make sure to untrigger any triggers requiring player touch
    if ( IsPlayerPawn() || WasPlayerPawn() ) 
    {
        PhysicsVolume.PlayerPawnDiedInVolume( self );

        ForEach TouchingActors( class'Trigger', T )
            T.PlayerToucherDied( self );
        ForEach TouchingActors( class'NavigationPoint', N )
        {
            if ( N.bReceivePlayerToucherDiedNotify ) 
                N.PlayerToucherDied( self );
        }
    }

    // remove powerup effects, etc.
    RemovePowerups();

    //Velocity.Z *= 1.3;

    if ( IsHumanControlled() ) 
        PlayerController( Controller ).ForceDeathUpdate();

    Freon(Level.Game).PawnFroze(self);
    Freeze();
    return true;
}

function PlayFreezingHit()
{
    if(PhysicsVolume.bDestructive && ( PhysicsVolume.ExitActor != None))
        Spawn(PhysicsVolume.ExitActor);
}

function Freeze()
{
    if(MyTrigger != None)
        MyTrigger.OwnerFroze();

    bPlayedDeath = true;  
    StopAnimating(true);

    GotoState('Frozen');
}

function FillWeaponData()
{
    local Inventory inv;
    local int i;

    for(inv = Inventory; inv != None; inv = inv.Inventory)
    {
        if(Weapon(inv) == None)
            continue;

        i = MyWD.Length;
        MyWD.Length = i + 1;

        MyWD[i].WeaponName = string(inv.Class);
        MyWD[i].Ammo[0] = Weapon(inv).AmmoCharge[0];
        MyWD[i].Ammo[1] = Weapon(inv).AmmoCharge[1];
    }
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if(bFrozen && !bClientFrozen)
    {
		bPhysicsAnimUpdate = false;
		bClientFrozen = true;
		StopAnimating(true);

		if(Level.bDropDetail || Level.DetailMode == DM_Low)
			ApplyLowQualityIce();
		else
			ApplyHighQualityIce();

		bScriptPostRender = true;
    }
}

simulated function ApplyLowQualityIce()
{
    local Combiner Body;
    local Combiner Head;

    if(MyOwner != None && MyOwner.PlayerReplicationInfo == PlayerReplicationInfo)
    {
        ApplyHighQualityIce();
        return;
    }

    Body = new(none)class'Combiner';
    Head = new(none)class'Combiner';

    SetOverlayMaterial(None, 0.0, true);
    SetStandardSkin();

    Body.CombineOperation = CO_Add;
    Body.Material1 = Skins[0];
    Body.Material2 = FrostMaterial;

    Head.CombineOperation = CO_Add;
    Head.Material1 = Skins[1];
    Head.Material2 = FrostMaterial;

    Skins[0] = Body;
    Skins[1] = Head;
}

simulated function ApplyHighQualityIce()
{
    local Combiner Body;
    local Combiner Head;
    local Combiner Ice;

    Body = new(none)class'Combiner';
    Head = new(none)class'Combiner';
    Ice = new(none)class'Combiner';

    SetOverlayMaterial(None, 0.0, true);
	SetStandardSkin();

    Ice.CombineOperation = CO_Subtract;
    Ice.Material1 = FrostMap;
    Ice.Material2 = FrostMaterial;

    Body.CombineOperation = CO_Add;
    Body.Material1 = Skins[0];
    Body.Material2 = Ice;

    Head.CombineOperation = CO_Add;
    Head.Material1 = Skins[1];
    Head.Material2 = Ice;

    Skins[0] = Body;
    Skins[1] = Head;
}

simulated function SetSkin(int OverrideTeamIndex)
{
    if(bClientFrozen)
        return;

    Super.SetSkin(OverrideTeamIndex);
}

function DiedFrozen(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    if(Freon(Level.Game) != None)
        Freon(Level.Game).PlayerThawed(self, 0, 0);
    Died(Killer, DamageType, HitLocation);
}

function Thaw()
{
	bGivesGit = false;
    if(Freon(Level.Game) != None)
        Freon(Level.Game).PlayerThawed(self, 0, 0);
}

function ThawByTouch(array<Freon_Pawn> Thawers, optional float mosthealth)
{
	bGivesGit = false;
    if(Freon(Level.Game) != None)
        Freon(Level.Game).PlayerThawedByTouch(self, Thawers, mosthealth, shieldstrength);
}

/*
Pawn was killed - detach any controller, and die
*/
simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation )
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}

	bTearOff = true;
	//HitDamageType = class'Gibbed'; // make sure clients gib also
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		GotoState('TimingOut');
	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.static.UseLowGore() )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,ChunkPerterbation);

	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

State Frozen
{
    ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

    event ChangeAnimation() {}
    event StopPlayFiring() {}
    function PlayFiring( float Rate, name FiringMode ) {}
    function PlayWeaponSwitch( Weapon NewWeapon ) {}
    function PlayTakeHit( Vector HitLoc, int Damage, class<DamageType> DamageType ) {}
    simulated function PlayNextAnimation() {}
    function TakeFallingDamage() {}

    event Landed( vector HitNormal )
    {
        Velocity = vect(0,0,0);
        SetPhysics(PHYS_Walking);
        LastHitBy = None;
        PlaySound(default.ImpactSounds[Rand(6)], SLOT_Pain, 1.5 * TransientSoundVolume);
    }
    
    event Tick( float DeltaTime )
    {
        if(Physics==PHYS_Walking || Physics==PHYS_Swimming || Physics==PHYS_None)
            bGivesGit = true;
        Super.Tick(DeltaTime);
    }

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
    {
        if ( DamageType == None ) 
        {
            if ( InstigatedBy != None ) 
                Warn( "No DamageType for damage by "$InstigatedBy$" with weapon "$InstigatedBy.Weapon );
            DamageType = class'DamageType';
        }

        if ( Role < ROLE_Authority ) 
        {
            Log( self$" client DamageType "$DamageType$" by "$InstigatedBy );
            return;
        }

        if ( HitLocation == vect(0,0,0) ) 
            HitLocation = Location;

        if(DamageType.default.bCausedByWorld)
        {
			if(DamageType == class'FellLava')
				Thaw();
			else
				DiedFrozen(None, DamageType, HitLocation);
			return;
        }

        if ( Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ ) 
            Momentum.Z = FMax( Momentum.Z, 0.4 * VSize( Momentum ) );

        Momentum = Momentum / (Mass * 1.5);
        SetPhysics(PHYS_Falling);
        Velocity += Momentum;

        if ( ( InstigatedBy == None || InstigatedBy.Controller == None ) &&
             ( DamageType.default.bDelayedDamage ) &&
             ( DelayedDamageInstigatorController != None ) )
            InstigatedBy = DelayedDamageInstigatorController.Pawn;

        if ( InstigatedBy != None && InstigatedBy != self )
            LastHitBy = InstigatedBy.Controller;
    }

    function BeginState()
    {
        SetPhysics(PHYS_Falling);

        LastHitBy = None;
        Acceleration = vect(0,0,0);
        TearOffMomentum = vect(0,0,0);

        if(Freon_Player(Controller) != None) 
        {
            Freon_Player(Controller).FrozenPawn = self;
            Freon_Player(Controller).Freeze();
        }
        else if(Freon_Bot(Controller) != None) 
            Freon_Bot(Controller).Freeze();
    }
}

defaultproperties
{
     FrostMaterial=Texture'AlleriaTerrain.ground.icebrg01'
     FrostMap=TexEnvMap'CubeMaps.Kretzig.Kretzig2TexENV'
     ImpactSounds(0)=Sound'PlayerSounds.BFootsteps.BFootstepSnow1'
     ImpactSounds(1)=Sound'PlayerSounds.BFootsteps.BFootstepSnow2'
     ImpactSounds(2)=Sound'PlayerSounds.BFootsteps.BFootstepSnow3'
     ImpactSounds(3)=Sound'PlayerSounds.BFootsteps.BFootstepSnow4'
     ImpactSounds(4)=Sound'PlayerSounds.BFootsteps.BFootstepSnow5'
     ImpactSounds(5)=Sound'PlayerSounds.BFootsteps.BFootstepSnow6'
}
