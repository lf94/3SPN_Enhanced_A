class WeaponFire_Link extends LinkFire;

event ModeDoFire()
{
    if(!LinkGun(Weapon).Linking)
        Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Link.Primary.Fired++;
    Super.ModeDoFire();
}

defaultproperties
{
}
