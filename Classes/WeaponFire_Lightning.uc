class WeaponFire_Lightning extends SniperFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Sniper.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
     DamageTypeHeadShot=Class'3SPN_Enhanced_A.DamType_Headshot'
}
