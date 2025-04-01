#include <amxmodx>
#include <fakemeta>
#include <vector>

new button_check[33]
new Float:vec[3]

public plugin_init()
{
	register_clcmd("BuildMode_on", "on_button")
	register_clcmd("BuildMode_off", "off_button")
	register_forward(FM_PlayerPreThink, "pThink")
	register_logevent("bind", 2 ,"1=Round_Start")
}

public pThink(id)
{
	if(button_check[id])
	{
		BuildMode(id)
	}
}
public on_button(id) 
{
	button_check[id] = 1
	client_print(id, print_chat, "模式已開啟!")
}
public off_button(id)
{
	button_check[id] = 0
	client_cmd(id, "bind F8 BuildMode_on")
	client_print(id, print_chat, "模式關閉!")
}

public BuildMode(id)
{
	velocity_by_aim(id, 0, vec)
	set_pev(id, pev_velocity, vec)
	
	if (pev(id, pev_button) & IN_FORWARD)
	{
		velocity_by_aim(id, 600, vec)
		set_pev(id, pev_velocity, vec)
	}
	else if (pev(id, pev_button) & IN_BACK)
	{
		velocity_by_aim(id, -600, vec)
		set_pev(id, pev_velocity, vec)
	}
	client_cmd(id, "bind F8 BuildMode_off")
}

public bind(id)	
{
	button_check[id] = 0
	client_cmd(id, "bind F8 BuildMode_on")
}	







