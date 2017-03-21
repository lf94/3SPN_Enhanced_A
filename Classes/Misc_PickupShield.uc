class Misc_PickupShield extends ShieldPickup
    notplaceable;

auto state Pickup
{
    function Touch(actor Other)
    {
        local Pawn P;
			
		if(ValidTouch(Other)) 
		{			
			P = Pawn(Other);

            P.AddShieldStrength(ShieldAmount);
		    AnnouncePickup(P);
            SetRespawn();
		}
    }
}

defaultproperties
{
     ShieldAmount=10
     MaxDesireability=1.000000
     RespawnTime=33.000000
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="HealthPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'3SPN_Enhanced_A.Question'
     CullDistance=6500.000000
     Physics=PHYS_Rotating
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     TransientSoundVolume=0.350000
     RotationRate=(Yaw=35000)
}
