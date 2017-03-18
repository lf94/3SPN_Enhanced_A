class Menu_TAMLoginMenu extends UT2K4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = "3SPNv32232.Menu_PlayerLoginControlsTAM";
	Super.AddPanels();
}
