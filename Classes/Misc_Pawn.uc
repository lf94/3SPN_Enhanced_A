class Misc_Pawn extends xPawn;

var Misc_Player MyOwner;

/* brightskins */
var bool bBrightSkins;

var Material SavedBody;
var Material OrigBody;
var Combiner Combined;
var ConstantColor SkinColor;
var ConstantColor OverlayColor;

var Color RedColor;
var Color BlueColor;

var byte  OverlayType;
var Color OverlayColors[4];
/* brightskins */

/* camping related */
var vector LocationHistory[10];
var int	   NextLocHistSlot;
var bool   bWarmedUp;
var int	   ReWarnTime;
/* camping related */

var bool   SpawnProtectionEnabled;
var int	   SpawnProtectionTimer;

var xEmitter InvisEmitter;

replication
{
    unreliable if(Role == ROLE_Authority)
        OverlayType;

    reliable if(bNetDirty && Role == ROLE_Authority)
        SpawnProtectionEnabled;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(Misc_Player(Controller)!=None)
		Misc_Player(Controller).NextRezTime = Level.TimeSeconds+1; // 1 second delay after dying
		
	Super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
    if(InvisEmitter != None)
    {
        InvisEmitter.mRegen = false;
        InvisEmitter.Destroy();
        InvisEmitter = None;
    }

    Super.Destroyed();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if(Level.Game==None)
		return;
	
    ActivateSpawnProtection();
}

function PossessedBy(Controller C)
{
    Super.PossessedBy(C);

    if(bDeleteMe || Controller != C)
        return;

    if(Misc_PRI(PlayerReplicationInfo) != None)
        Misc_PRI(PlayerReplicationInfo).PawnReplicationInfo.SetMyPawn(self);
}

function UnPossessed()
{
    if(Misc_PRI(PlayerReplicationInfo) != None)
        Misc_PRI(PlayerReplicationInfo).PawnReplicationInfo.SetMyPawn(None);

    Super.UnPossessed();
}

function bool InCurrentCombo()
{
    if(TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
        return Super.InCurrentCombo();
    return false;
}

function DoCombo( class<Combo> ComboClass )
{
	local int i;

    if ( ComboClass != None )
    {
        if (CurrentCombo == None)
	        CurrentCombo = Spawn( ComboClass, self );

        if (CurrentCombo != None)
        {
			// Record stats for using the combo
			UnrealMPGameInfo(Level.Game).SpecialEvent(PlayerReplicationInfo,""$CurrentCombo.Class);
			if ( ComboClass.Name == 'ComboSpeed' )
				i = 0;
			else if ( ComboClass.Name == 'ComboBerserk' )
				i = 1;
			else if ( ComboClass.Name == 'ComboDefensive' )
				i = 2;
			else if ( ComboClass.Name == 'ComboInvis' )
				i = 3;
			else
				i = 4;
			TeamPlayerReplicationInfo(PlayerReplicationInfo).Combos[i] += 1;
        }
    }
}

function GiveWeaponClass(class<Weapon> WeaponClass)
{
    local Weapon NewWeapon;

    if(FindInventoryType(WeaponClass) != None)
        return;

    NewWeapon = Spawn(WeaponClass);
    if(NewWeapon != None)
        NewWeapon.GiveTo(self);
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
	local float InvisTime;

	if ( bInvis )
	{
	    if ( (OldWeapon != None) && (OldWeapon.OverlayMaterial == InvisMaterial) )
		    InvisTime = OldWeapon.ClientOverlayCounter;
	    else
		    InvisTime = 20000;
	}
    if (HasUDamage() || bInvis)
        SetWeaponOverlay(None, 0.f, true);

    Weapon = NewWeapon;

    if ( Controller != None )
		Controller.ChangedWeapon();

    PendingWeapon = None;

	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);
        OldWeapon.GotoState('Hidden');
        OldWeapon.NetUpdateFrequency = 2;
	}

	if ( Weapon != None )
	{
	    Weapon.NetUpdateFrequency = 100;
		Weapon.AttachToPawn(self);
		Weapon.BringUp(OldWeapon);
        PlayWeaponSwitch(NewWeapon);
	}

	if ( Inventory != None )
		Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)	
	
    if (bInvis)
        SetWeaponOverlay(InvisMaterial, InvisTime, true);
    else if (HasUDamage())
        SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, false);

	if ( Weapon != None )
	{
		if (bBerserk)
			Weapon.StartBerserk();
		else if ( Weapon.bBerserk )
			Weapon.StopBerserk();
	}
}

// changed to save adren
function RemovePowerups()
{
    local float Adren;

    if(TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
    {
        Super.RemovePowerups();
        return;
    }

    if(Controller != None && Misc_DynCombo(CurrentCombo) != None)
    {
        Adren = Controller.Adrenaline;
        Super.RemovePowerups();
        Controller.Adrenaline = Adren; 

        return;
    }

    Super.RemovePowerups();
}

// 75% armor absorbtion rate
function int ShieldAbsorb(int dam)
{
    local float Shield;

    if(ShieldStrength == 0)
        return dam;

    SetOverlayMaterial(ShieldHitMat, ShieldHitMatTime, false);
    PlaySound(Sound'WeaponSounds.ArmorHit', SLOT_Pain, 2 * TransientSoundVolume,, 400);

    Shield = ShieldStrength - (dam * 0.75 + 0.5);
    dam *= 0.25;
    if(Shield < 0)
    {
        dam += -(Shield);
        Shield = 0;
    }

    ShieldStrength = Shield;
    return dam;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    local vector zeroVec;
    zeroVec = vect(0.0,0.0,0.0);
	if(IsSpawnProtectionEnabled())
        Super.TakeDamage(0, instigatedBy, hitlocation, zeroVec, damageType);
    else
        Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

simulated function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
    if(mat == None)
        OverlayType = 0;
    else if(mat == ShieldHitMat)
    {
        OverlayType = 1;
        SetTimer(ShieldHitMatTime, false);
    }
    else if(OverlayType != 1)
    {
        if(mat == Shader'XGameShaders.PlayerShaders.LightningHit')
            OverlayType = 2;
        else if(mat == Shader'UT2004Weapons.Shaders.ShockHitShader')
            OverlayType = 3;
        else if(mat == Shader'XGameShaders.PlayerShaders.LinkHit')
            OverlayType = 4;   

        SetTimer(ShieldHitMatTime, false);
    }

    Super.SetOverlayMaterial(mat, time, bOverride);
}

/* brightskins related */
/* copied from a recent xpawn patch version.
   needed to stop GPFs in older versions. */
simulated function bool CheckValidFemaleDefault()
{
	return ( (PlacedFemaleCharacterName ~= "Tamika")
			|| (PlacedFemaleCharacterName ~= "Sapphire")
			|| (PlacedFemaleCharacterName ~= "Enigma")
			|| (PlacedFemaleCharacterName ~= "Cathode")
			|| (PlacedFemaleCharacterName ~= "Rylisa")
			|| (PlacedFemaleCharacterName ~= "Ophelia")
			|| (PlacedFemaleCharacterName ~= "Zarina") 
            || (PlacedFemaleCharacterName ~= "Nebri")
            || (PlacedFemaleCharacterName ~= "Subversa")
            || (PlacedFemaleCharacterName ~= "Diva") );
}

simulated function bool CheckValidMaleDefault()
{
	return ( (PlacedCharacterName ~= "Jakob")
			|| (PlacedCharacterName ~= "Gorge")
			|| (PlacedCharacterName ~= "Malcolm")
			|| (PlacedCharacterName ~= "Xan")
			|| (PlacedCharacterName ~= "Brock")
			|| (PlacedCharacterName ~= "Gaargod")
			|| (PlacedCharacterName ~= "Axon")
            || (PlacedCharacterName ~= "Barktooth")
            || (PlacedCharacterName ~= "Torch")
            || (PlacedCharacterName ~= "WidowMaker") );
}
/*
*/

simulated function string CheckAndGetCharacter()
{
    if(!CheckValidFemaleDefault() && !CheckValidMaleDefault())
    {
        if(!CheckValidFemaleDefault())
            PlacedFemaleCharacterName = "Tamika";
        if(!CheckValidMaleDefault())
            PlacedCharacterName = "Jakob";
    }

    if(PlayerReplicationInfo != None && PlayerReplicationInfo.bIsFemale)
        return PlacedFemaleCharacterName;
    else
        return PlacedCharacterName;
}

simulated function string GetDefaultCharacter()
{
    local PlayerController P;
    local int MyTeam;
    local int OwnerTeam;
	
    if(!class'Misc_Player'.default.bForceRedEnemyModel && !class'Misc_Player'.default.bForceBlueAllyModel)
        return Super.GetDefaultCharacter();

    MyTeam = GetTeamNum();
    if(MyTeam == 255)
        return CheckAndGetCharacter();

    P = Level.GetLocalPlayerController();
    if(P != None && P.PlayerReplicationInfo != None)
    {
        OwnerTeam = P.GetTeamNum();

        if(class'Misc_Player'.default.bUseTeamModels || OwnerTeam == 255)
        {
            if(MyTeam == 1)
            {
                if(class'Misc_Player'.default.bForceBlueAllyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.BlueAllyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.BlueAllyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
            else
            {
                if(class'Misc_Player'.default.bForceRedEnemyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.RedEnemyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.RedEnemyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
        }
        else if(!class'Misc_Player'.default.bUseTeamModels)
        {
            if(MyTeam == OwnerTeam)
            {
                if(class'Misc_Player'.default.bForceBlueAllyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.BlueAllyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.BlueAllyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
            else
            {
                if(class'Misc_Player'.default.bForceRedEnemyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.RedEnemyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.RedEnemyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
        }
    }

    return CheckAndGetCharacter();
}

simulated function bool ForceDefaultCharacter()
{
	local PlayerController P;
    local int MyTeam;
    local int OwnerTeam;
	
    if(!class'Misc_Player'.default.bForceRedEnemyModel && !class'Misc_Player'.default.bForceBlueAllyModel)
        return Super.ForceDefaultCharacter();

    MyTeam = GetTeamNum();
    if(MyTeam == 255)
        return Super.ForceDefaultCharacter();

    P = Level.GetLocalPlayerController();
    if(P != None && P.PlayerReplicationInfo != None)
    {
        OwnerTeam = P.GetTeamNum();

        if(class'Misc_Player'.default.bUseTeamModels || OwnerTeam == 255)
        {
            if(MyTeam == 1)
                return class'Misc_Player'.default.bForceBlueAllyModel;
            else
                return class'Misc_Player'.default.bForceRedEnemyModel;
        }
        else if(!class'Misc_Player'.default.bUseTeamModels)
        {
            if(MyTeam == OwnerTeam)
                return class'Misc_Player'.default.bForceBlueAllyModel;
            else
                return class'Misc_Player'.default.bForceRedEnemyModel;
        }
    }

    return true;
}

simulated function bool CheckValid(string name)
{
    return ((name ~= "Abaddon")
        ||  (name ~= "Ambrosia") || (name ~= "Annika") || (name ~= "Arclite")
        ||  (name ~= "Aryss") || (name ~= "Asp") || (name ~= "Axon")
        ||  (name ~= "Azure") || (name ~= "Baird") || (name ~= "BlackJack")
        ||  (name ~= "Barktooth") || (name ~= "Brock") || (name ~= "Brutalis")
        ||  (name ~= "Cannonball") || (name ~= "Cathode") || (name ~= "ClanLord")
        ||  (name ~= "Cleopatra") || (name ~= "Cobalt") || (name ~= "Corrosion")
        ||  (name ~= "Cyclops") || (name ~= "Damarus") || (name ~= "Diva")
        ||  (name ~= "Divisor") || (name ~= "Domina") || (name ~= "Dominator")
        ||  (name ~= "Drekorig") || (name ~= "Enigma") || (name ~= "Faraleth")
        ||  (name ~= "Fate") || (name ~= "Frostbite") || (name ~= "Gaargod")
        ||  (name ~= "Garrett") || (name ~= "Gkublok") || (name ~= "Gorge")
        ||  (name ~= "Greith") || (name ~= "Guardian") || (name ~= "Harlequin")
        ||  (name ~= "Horus") || (name ~= "Hyena") || (name ~= "Jakob")
        ||  (name ~= "Kaela") || (name ~= "Kane") || (name ~= "Kareg")
        ||  (name ~= "Komek") || (name ~= "Kraagesh") || (name ~= "Kragoth")
        ||  (name ~= "Lauren") || (name ~= "Lilith") || (name ~= "Makreth")
        ||  (name ~= "Malcolm") || (name ~= "Mandible") || (name ~= "Matrix")
        ||  (name ~= "Mekkor") || (name ~= "Memphis") || (name ~= "Mokara")
        ||  (name ~= "Motig") || (name ~= "Mr.Crow") || (name ~= "Nebri")
        ||  (name ~= "Nebri") || (name ~= "Ophelia") || (name ~= "Othello")
        ||  (name ~= "Outlaw") || (name ~= "Prism") || (name ~= "Rae")
        ||  (name ~= "Rapier") || (name ~= "Ravage") || (name ~= "Reinha")
        ||  (name ~= "Remus") || (name ~= "Renegade") || (name ~= "Riker")
        ||  (name ~= "Roc") || (name ~= "Romulus") || (name ~= "Rylisa")
        ||  (name ~= "Sapphire") || (name ~= "Satin") || (name ~= "Scarab")
        ||  (name ~= "Selig") || (name ~= "Siren") || (name ~= "Skakruk")
        ||  (name ~= "Skrilax") || (name ~= "Subversa") || (name ~= "Syzygy")
        ||  (name ~= "Tamika") || (name ~= "Thannis") || (name ~= "Torch")
        ||  (name ~= "Thorax") || (name ~= "Virus") || (name ~= "Widowmaker")
        ||  (name ~= "Wraith") || (name ~= "Xan") || (name ~= "Zarina"));
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	local string DefaultSkin;
    local PlayerController p;

    DefaultSkin = GetDefaultCharacter();

	if(PlayerReplicationInfo!=None && (	PlayerReplicationInfo.CharacterName ~= "Virus"		|| 
										PlayerReplicationInfo.CharacterName ~= "Enigma"		|| 
										PlayerReplicationInfo.CharacterName ~= "Xan" 		||
										PlayerReplicationInfo.CharacterName ~= "Cyclops"	||
										PlayerReplicationInfo.CharacterName ~= "Axon"		||
										PlayerReplicationInfo.CharacterName ~= "Matrix"		||
										!CheckValid(PlayerReplicationInfo.CharacterName)))
	{
		if(Controller == None || Controller.IsA('Bot'))
         		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);
	}

	if ((rec.Species == None) || ForceDefaultCharacter())
		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);

	Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if(!Species.static.Setup(self, rec))
	{
		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);
		if(!Species.static.Setup(self, rec))
			return;
	}

	ResetPhysicsBasedAnim();

    if(Level.NetMode == NM_DedicatedServer)
        return;

    p = Level.GetLocalPlayerController();
    if(p == None)
        return;

    bNoCoronas = true;

    if(MyOwner == None)
    {
		MyOwner = Misc_Player(p);

	    if(MyOwner == None)
		    return;
    }   

    bBrightSkins = class'Misc_Player'.default.bUseBrightSkins;
    if(bBrightSkins)
    {
        if(OrigBody == None)
		    OrigBody = Skins[0];

	    if(SkinColor == None)
		    SkinColor = New(none)class'ConstantColor';

        if(OverlayColor == None)
            OverlayColor = New(none)class'ConstantColor';

	    if(Combined == None)
		    Combined = New(none)class'Combiner';
    }
}

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for(i = 0; i < Attached.length; i++)
    {
        if(Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet') 
            && !Attached[i].IsA('Emitter_SeeInvis') && !Attached[i].IsA('SpeedTrail')
            && !Attached[i].IsA('RegenCrosses') && !Attached[i].IsA('OffensiveEffect'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }
    }
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if(MyOwner == None)
        MyOwner = Misc_Player(Level.GetLocalPlayerController());

    if(MyOwner != None)
    {
        if(bInvis)
        {
            if(MyOwner.bSeeInvis)
            {
                if(InvisEmitter == None)
                    InvisEmitter = Spawn(class'Emitter_SeeInvis', self,, Location, Rotation);
                AttachToBone(InvisEmitter, 'spine');
            }
            else if(InvisEmitter != None)
            {
                DetachFromBone(InvisEmitter);
                InvisEmitter.mRegen = false;
                InvisEmitter.Destroy();
                InvisEmitter = None;
            }

            return;
        }
        else if(InvisEmitter != None)
        {
            DetachFromBone(InvisEmitter);
            InvisEmitter.mRegen = false;
            InvisEmitter.Destroy();
            InvisEmitter = None;
        }
    }
    else if(bInvis)
        return;

    if(bPlayedDeath)
		return;

    bBrightSkins = class'Misc_Player'.default.bUseBrightSkins;	
	SetSkin(-1);
}

simulated function SetSkin(int OverrideTeamIndex)
{
    if(bBrightSkins)
    {
        if(OverlayType != 0)
            SetOverlaySkin();
        else
            SetBrightSkin(-1);
    }
    else
        SetStandardSkin();
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	SetStandardSkin();
	bUnlit = false;
	Super.PlayDying(DamageType, HitLoc);
}

simulated function SetStandardSkin()
{
	if(OrigBody != None)
		Skins[0] = OrigBody;

	bUnlit = true;
}

simulated static function ClampColor(out Color color)
{
    color.R = Min(color.r, 100) / 100.0 * 128.0;
    color.G = Min(color.g, 100) / 100.0 * 128.0;
    color.B = Min(color.b, 100) / 100.0 * 128.0;
    color.A = 128;
}

simulated function SetBrightSkin(int OverrideTeamIndex)
{
	local int TeamIndex;
	local int OwnerTeam;
    local bool ShowYellow;
    local bool IsEnemy;
	local bool GameEnded;

	if(MyOwner!=None && MyOwner.IsInState('GameEnded'))
		GameEnded = true;
		
	if(OverrideTeamIndex==-1 && GameEnded)
		return;

	if(OrigBody == None)
		OrigBody = Skins[0];

	if(SkinColor == None)
		SkinColor = New(none)class'ConstantColor';

    if(OverlayColor == None)
        OverlayColor = New(none)class'ConstantColor';

	if(Combined == None)
		Combined = New(none)class'Combiner';

	if(OverrideTeamIndex != -1)
		TeamIndex = OverrideTeamIndex;
	else
		TeamIndex = GetTeamNum();
    
    IsEnemy = (MyOwner!=None && MyOwner.GetTeamNum()!=TeamIndex) || TeamIndex==255;
    ShowYellow = IsEnemy && IsSpawnProtectionEnabled() && !GameEnded;

		if(MyOwner!=None && MyOwner.PlayerReplicationInfo!=None && MyOwner.PlayerReplicationInfo.bOnlySpectator)
		{
			if(Pawn(MyOwner.ViewTarget) != None && Pawn(MyOwner.ViewTarget).PlayerReplicationInfo != None && Pawn(MyOwner.ViewTarget).PlayerReplicationInfo.Team != None)
				OwnerTeam = Pawn(MyOwner.ViewTarget).PlayerReplicationInfo.Team.TeamIndex;
            else
        OwnerTeam = 255;
		}
		else
    {
        OwnerTeam = MyOwner.GetTeamNum();
    }
    
	if(OverrideTeamIndex==-1 && MyOwner!=None && OwnerTeam!=255 && !class'Misc_Player'.default.bUseTeamColors)
	{
        if(ShowYellow)
            SkinColor.Color = class'Misc_Player'.default.Yellow;
		else if(MyOwner.PlayerReplicationInfo != PlayerReplicationInfo && (OwnerTeam == 255 || TeamIndex != OwnerTeam))
			SkinColor.Color = class'Misc_Player'.default.RedOrEnemy;
		else/* if(TeamIndex == OwnerTeam || MyOwner.PlayerReplicationInfo == PlayerReplicationInfo)*/
			SkinColor.Color = class'Misc_Player'.default.BlueOrAlly;
	}
	else
	{
        if(MyOwner == None)
        {
            if(TeamIndex == 0 || TeamIndex == 255)
			    SkinColor.Color = RedColor;
		    else
			    SkinColor.Color = BlueColor;
        }
        else
        {
            if(ShowYellow)
                SkinColor.Color = class'Misc_Player'.default.Yellow;
		    else if(TeamIndex == 0 || TeamIndex == 255)
			    SkinColor.Color = class'Misc_Player'.default.RedOrEnemy;
		    else
			    SkinColor.Color = class'Misc_Player'.default.BlueOrAlly;
        }
	}

    ClampColor(SkinColor.Color);
	
    Combined.CombineOperation = CO_Add;
    Combined.Material1 = GetSkin();
	Combined.Material2 = SkinColor;
	Skins[0] = Combined;

	bUnlit = true;
}

simulated function Material GetSkin()
{
    local Material TempSkin;
   	local string Skin;

	if(SavedBody != None)
		return SavedBody;

    Skin = String(Skins[0]);

    if(Right(Skin, 2) == "_0" || Right(Skin, 2) == "_1")
    {
        Skin = Left(Skin, Len(Skin) - 2);
    }
    else if(Right(Skin, 3) == "_0B" || Right(Skin, 3) == "_1B")
    {
        Skin = Right(Skin, Len(Skin) - 6);
        Skin = Left(Skin, Len(Skin) - 3);
    }

   	TempSkin = Material(DynamicLoadObject(Skin, class'Material', true));

    if(TempSkin == None)
        TempSkin = Skins[0];

	SavedBody = TempSkin;
	return SavedBody;
}

simulated function SetOverlaySkin()
{
	if(OverlayColor==None || Combined==None)
		return;
		
    OverlayColor.Color = OverlayColors[OverlayType - 1];

    Combined.Material1 = GetSkin();
    Combined.Material2 = OverlayColor;
    Skins[0] = Combined;
}

function Timer()
{
    OverlayType = 0;
}
/* brightskins related */

simulated function bool IsSpawnProtectionEnabled()
{
	return SpawnProtectionEnabled;
}

function ActivateSpawnProtection()
{
    SpawnProtectionEnabled = true;
	SpawnProtectionTimer = default.SpawnProtectionTimer;
}

function DeactivateSpawnProtection()
{
	if(SpawnProtectionEnabled && SpawnProtectionTimer!=default.SpawnProtectionTimer)
	{
		if(PlayerController(Controller) != None)
			PlayerController(Controller).ReceiveLocalizedMessage(class'Message_SpawnProtection', 0);
	}
	
    SpawnProtectionEnabled = false;
	SpawnProtectionTimer = 0;
}

function UpdateSpawnProtection()
{
	if(SpawnProtectionTimer==0)
		return;
		
	--SpawnProtectionTimer;
	
	if(PlayerController(Controller) != None)
		PlayerController(Controller).ReceiveLocalizedMessage(class'Message_SpawnProtection', SpawnProtectionTimer);
	
	if(SpawnProtectionTimer>0)
		return;
		
	DeactivateSpawnProtection();
}

defaultproperties
{
     RedColor=(R=100)
     BlueColor=(B=100,G=25)
     OverlayColors(0)=(G=80,R=128,A=128)
     OverlayColors(1)=(B=128,G=96,R=64,A=128)
     OverlayColors(2)=(B=110,R=80,A=128)
     OverlayColors(3)=(B=64,G=128,R=64,A=128)
     ShieldHitMatTime=0.350000
     bPlayOwnFootsteps=False
     RequiredEquipment(0)="XWeapons.ShieldGun"
     RequiredEquipment(1)="XWeapons.AssaultRifle"
     //bNoWeaponFiring=True
	 SpawnProtectionTimer=4
}
