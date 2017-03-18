class Menu_Interaction extends Interaction;

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
	if(Action != IST_Press)
		return false;

	if(Key == class'Misc_Player'.default.Menu3SPNKey)
	{
		Misc_Player(ViewportOwner.Actor).Menu3SPN();
		return true;
	}
	
	return false;
}

event NotifyLevelChange()
{
	Master.RemoveInteraction(self);
}

defaultproperties
{
}