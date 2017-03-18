class WeaponFire_BioAlt extends BioChargedFire;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Bio.Fired += 1;
    Super.ModeDoFire();
}

defaultproperties
{
}
