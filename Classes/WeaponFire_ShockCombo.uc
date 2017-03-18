class WeaponFire_ShockCombo extends ShockProjectile;

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(ComboDamage, ComboRadius, class'DamType_ShockCombo', ComboMomentumTransfer, Location );

	Spawn(class'ShockCombo');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(ComboSound, SLOT_None,1.0,,800);
    DestroyTrails();
    Destroy();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    local Misc_PRI PRI;
	
	if(EventInstigator==None)
		return;
	
	PRI = Misc_PRI(EventInstigator.PlayerReplicationInfo);

    if(DamageType == ComboDamageType)
    {
        Instigator = EventInstigator;
        SuperExplosion();
    
        if(PRI != None)
        {  
			PRI.Combo.Fired += 1;
	        PRI.Shock.Primary.Fired -= 1;
	        PRI.Shock.Secondary.Fired -= 1;
	  	}

        if(EventInstigator != None && EventInstigator.Weapon != None)
        {
			EventInstigator.Weapon.ConsumeAmmo(0, ComboAmmoCost, true);
            Instigator = EventInstigator;
        }
    }
}

defaultproperties
{
     ComboAmmoCost=2
}
