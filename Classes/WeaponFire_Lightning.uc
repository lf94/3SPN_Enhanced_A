class WeaponFire_Lightning extends SniperFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Sniper.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
     DamageTypeHeadShot=Class'3SPNv32232.DamType_Headshot'
}
