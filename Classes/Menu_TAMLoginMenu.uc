class Menu_TAMLoginMenu extends UT2K4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = "3SPN_Enhanced_A.Menu_PlayerLoginControlsTAM";
	Super.AddPanels();
}
