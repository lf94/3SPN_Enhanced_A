class NecroLeech extends Inventory;

var() int LeechRate;
var() int LeechAmount;

var() int ShieldLeechRate;
var() float ShieldLeechAmount;

var() int LeechCount;
var() int ShieldLeechCount;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
    if(Other == None || Other.Health <= 0)
    {
        Destroy();
        return;
    }

    Super.GiveTo(Other);

    SetTimer(1.00,true);
}

function Timer()
{
    if(Pawn(Owner) != None)
    {
		if(LeechCount < LeechAmount)
		{
       	 	Pawn(Owner).Health-=LeechRate;
        	LeechCount += LeechRate;
		}

		if(ShieldLeechCount < ShieldLeechAmount)
		{
       	 	Pawn(Owner).ShieldStrength-=ShieldLeechRate;
        	ShieldLeechCount += ShieldLeechRate;
		}

		if(Pawn(Owner).Health <= 0)
		{
			Pawn(Owner).Died(Pawn(Owner).Controller, class'DamTypeNecro', Pawn(Owner).Location);
			Destroy();
			SetTimer(0.00,false);
        	return;
		}

	    if(LeechCount >= LeechAmount && ShieldLeechCount >= ShieldLeechAmount)
        {
			Destroy();
			SetTimer(0.00,false);
        	return;
		}

        SetTimer(0.15,true);
    }
}

defaultproperties
{
     LeechRate=1
     ShieldLeechRate=1
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
