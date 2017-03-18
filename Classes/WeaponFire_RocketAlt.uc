class WeaponFire_RocketAlt extends RocketMultiFire;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Rockets.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
