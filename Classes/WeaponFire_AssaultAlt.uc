class WeaponFire_AssaultAlt extends AssaultGrenade;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

event ModeDoFire()
{
	Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Assault.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
