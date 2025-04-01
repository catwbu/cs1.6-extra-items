#include <amxmodx>
#include <fakemeta>
#include <vector>
//#include <engine>
#include <hamsandwich>
#include <fakemeta_util>

new button_check[33]
new Float:vec[3]
new speed_set
new painting_check[33]
new Stayair_check[33]

public plugin_init()
{
	register_plugin("輔助", "1.0", "Zero")
	/*//全圖加亮
	register_clcmd("lights 1", "on_lights")
	register_clcmd("lights 0", "off_lights")
	*/
	register_clcmd("Stayair", "Stayair")
	register_clcmd("invincible 1", "on_invincible")  //無敵
	register_clcmd("invincible 0", "off_invincible")
	register_clcmd("painting 1", "set_painting_on")  //噴漆
	register_clcmd("painting 0", "set_painting_off")
	register_clcmd("+painting", "on_painting") 
	register_clcmd("-painting", "off_painting")
	register_clcmd("Respawn", "Respawn")             //重生
	register_clcmd("+cheatspeed", "on_button") 		 //速度開關
	register_clcmd("-cheatspeed", "off_button") 
	
	register_forward(FM_PlayerPreThink, "pThink")
	register_logevent("bind", 2 ,"1=Round_Start")
	
	speed_set = register_cvar("speed_set", "8000") //速度調節
}

public pThink(id)
{
	if(button_check[id])
		BuildMode(id)
	
	if(painting_check[id])
		painting(id)
} 
public bind(id)	
{
	button_check[id] = 0
	painting_check[id] = 0
	client_cmd(id, "bind SHIFT +cheatspeed")
	client_cmd(id, "bind f6 Respawn")
	client_cmd(id, "bind t impulse 201")
	client_cmd(id, "bind f7 Stayair")
}	
//加速
public on_button(id) 
	button_check[id] = 1
	
public off_button(id)
	button_check[id] = 0

public BuildMode(id)
{
	if (pev(id, pev_button) & IN_FORWARD)
	{
		velocity_by_aim(id, get_pcvar_num(speed_set), vec)
		set_pev(id, pev_velocity, vec)
	}
}
/*//全圖加亮
public on_lights(id)
set_lights("z")

public off_lights(id)
set_lights("n")
*/
//重生
public Respawn(id)
ExecuteHamB(Ham_CS_RoundRespawn, id)

//無限噴漆
public on_painting(id)
painting_check[id] = 1
public off_painting(id)
painting_check[id] = 0

public painting(id)
client_cmd(id, "impulse 201")

public set_painting_on(id)
{
	client_cmd(id, "bind t +painting")
	client_cmd(id, "decalfrequency 0")
}
public set_painting_off(id)
{
	client_cmd(id, "bind t impulse 201")
//	client_cmd(id, "decalfrequency 30")
}
//無敵
public on_invincible(id)
set_pev(id, pev_takedamage, 0.0)
public off_invincible(id)
set_pev(id, pev_takedamage, 1.0)
//卡空
public Stayair(id)
{
	if(!(Stayair_check[id]))
	{
		Stayair_check[id] = 1
		new ent = fm_create_entity("info_target")
		new Float:org[3]
		pev(id, pev_origin, org)
		set_pev(ent, pev_origin, org)
		set_pev(ent, pev_classname, "block_player")
		set_pev(ent, pev_solid, 2)
		set_pev(ent, pev_movetype, 5)
		set_pev(ent, pev_iuser1, id)
		engfunc(EngFunc_SetModel, ent, "models/w_usp.mdl")
		engfunc(EngFunc_SetSize, ent, {-30.0, -30.0, -20.0}, {30.0, 30.0, 20.0})
		set_pev(ent, pev_renderamt, 0.0) //透明度
		set_pev(ent, pev_rendermode, 8) //透明模式

	}
	else 
	{
		for(new i=1; i<512; i++) if(pev_valid(i))
		{
			new class[33]
			pev(i, pev_classname, class, sizeof(class)-1)
			if(!equal(class, "block_player")) continue
			if(pev(i, pev_iuser1) != id) continue
		
			fm_remove_entity(i)
		}
		Stayair_check[id] = 0
	}
}