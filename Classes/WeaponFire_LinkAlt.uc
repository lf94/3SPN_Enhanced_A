class WeaponFire_LinkAlt extends LinkAltFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Link.Secondary.Fired++;
    Super.ModeDoFire();
}

/*
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Link.Secondary.Fired++;
    return Super.SpawnProjectile(Start, Dir);
}
*/
defaultproperties
{
}
