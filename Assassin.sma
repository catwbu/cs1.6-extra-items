#include <amxmodx>
#include <fakemeta>
#include <vector>
//#include <engine>
#include <hamsandwich>
#include <fakemeta_util>

#include <xs>
#include <cstrike>
new Float:OldVec[3], Float:NewVec[3]
new g_iBloodColor, spr_blood_spray, spr_blood_drop
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
	//register_clcmd("-cheatspeed", "off_button") 

	
	register_forward(FM_PlayerPreThink, "pThink")
	register_logevent("bind", 2 ,"1=Round_Start")
	
	speed_set = register_cvar("speed_set", "8000") //速度調節
}
public plugin_precache()
{
	spr_blood_spray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")
	spr_blood_drop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")	
}
public damage_ass(id)
{
	client_print(id, print_chat, "刺殺")
	if (!is_user_alive(id))
	return
	new iEntity = get_pdata_cbase(id, 373)
	if (!pev_valid(iEntity))
	return

	Make_Damage(iEntity, id, 40.0, 120.0, 200.0)

}
public pThink(id)
{
	if(button_check[id])
	{		
		damage_ass(id)
		on_invincible(id)
	}
	else off_invincible(id)
	
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
{
	set_task(1.0, "off_button", id)
	button_check[id] = 1
	BuildMode(id)
}
public off_button(id)
{
	button_check[id] = 0

}

public BuildMode(id)
{
	if (pev(id, pev_button) & IN_FORWARD)
	{
		
		
		pev(id, pev_velocity ,OldVec)
		velocity_by_aim(id, get_pcvar_num(speed_set), NewVec)
		NewVec[2] = OldVec[2]
		set_pev(id, pev_velocity, NewVec)
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
//------------------------------------------------------------------------------------------------
stock Make_Damage(iEntity, id, Float:flRange, Float:fAngle, Float:flDamage)
{

	new Float:vecOrigin[3], Float:vecScr[3], Float:vecEnd[3], Float:V_Angle[3], Float:vecForward[3]
	pev(id, pev_origin, vecOrigin)
	pev(id, pev_v_angle, V_Angle)
	engfunc(EngFunc_MakeVectors, V_Angle)
	global_get(glb_v_forward, vecForward)
	xs_vec_mul_scalar(vecForward, flRange, vecForward)
	xs_vec_add(vecScr, vecForward, vecEnd)

	new tr = create_tr2()
	engfunc(EngFunc_TraceLine, vecScr, vecEnd, 0, id, tr)
	new Float:flFraction
	get_tr2(tr, TR_flFraction, flFraction)



	new Float:vecEndZ = vecEnd[2]
	new pEntity = -1
	
	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRange)) != 0)
	{
		if (!pev_valid(pEntity))
		continue

		if (!IsAlive(pEntity))
		continue

		if (!CheckAngle(id, pEntity, fAngle))
		continue

		Stock_Get_Origin(pEntity, vecEnd)
		vecEnd[2] = vecScr[2] + (vecEndZ - vecScr[2]) * (get_distance_f(vecScr, vecEnd) / flRange)

		engfunc(EngFunc_TraceLine, vecScr, vecEnd, 0, id, tr)
		get_tr2(tr, TR_flFraction, flFraction)

		if (flFraction >= 1.0) engfunc(EngFunc_TraceHull, vecScr, vecEnd, 0, 3, id, tr)

		get_tr2(tr, TR_flFraction, flFraction)
		
		if (pev_valid(pEntity) && id != pEntity)
		Native_ExecuteAttack(id, pEntity, iEntity, Float:flDamage, 1, DMG_BULLET)

		free_tr2(tr)
	}
	return 
}
stock CheckAngle(iAttacker, iVictim, Float:fAngle)  return(Stock_CheckAngle(iAttacker, iVictim) > floatcos(fAngle,degrees))
stock Float:Stock_CheckAngle(id,iTarget)
{
	new Float:vOricross[2],Float:fRad,Float:vId_ori[3],Float:vTar_ori[3],Float:vId_ang[3],Float:fLength,Float:vForward[3]
	Stock_Get_Origin(id, vId_ori)
	Stock_Get_Origin(iTarget, vTar_ori)
	
	pev(id,pev_angles,vId_ang)
	for(new i=0;i<2;i++) vOricross[i] = vTar_ori[i] - vId_ori[i]
	
	fLength = floatsqroot(vOricross[0]*vOricross[0] + vOricross[1]*vOricross[1])
	
	if (fLength<=0.0)
	{
		vOricross[0]=0.0
		vOricross[1]=0.0
	} else {
		vOricross[0]=vOricross[0]*(1.0/fLength)
		vOricross[1]=vOricross[1]*(1.0/fLength)
	}
	
	engfunc(EngFunc_MakeVectors,vId_ang)
	global_get(glb_v_forward,vForward)
	
	fRad = vOricross[0]*vForward[0]+vOricross[1]*vForward[1]
	
	return fRad   //->   RAD 90' = 0.5rad
}

stock Stock_Get_Origin(id, Float:origin[3])
{
	new Float:maxs[3],Float:mins[3]
	if (pev(id, pev_solid) == SOLID_BSP)
	{
		pev(id,pev_maxs,maxs)
		pev(id,pev_mins,mins)
		origin[0] = (maxs[0] - mins[0]) / 2 + mins[0]
		origin[1] = (maxs[1] - mins[1]) / 2 + mins[1]
		origin[2] = (maxs[2] - mins[2]) / 2 + mins[2]
	} else pev(id, pev_origin, origin)
}

stock IsAlive(pEntity)
{
	if (pEntity < 1) return 0
	return (pev(pEntity, pev_deadflag) == DEAD_NO && pev(pEntity, pev_health) > 0)
}
stock IsPlayer(pEntity) return is_user_connected(pEntity)

stock IsHostage(pEntity)
{
	new classname[32]; pev(pEntity, pev_classname, classname, charsmax(classname))
	return equal(classname, "hostage_entity")
}
public Native_ExecuteAttack(iAttacker, iVictim, iEntity, Float:fDamage, iHeadShot, iDamageBit)
{
	if (pev(iVictim, pev_takedamage) <= 0.0)
	return 0

	new Float:fOrigin[3], Float:fEnd[3], iTarget, iBody, Float:fMultifDamage
	pev(iAttacker, pev_origin, fOrigin)
	get_user_aiming(iAttacker, iTarget, iBody)
	fm_get_aim_origin(iAttacker, fEnd)
	new ptr = create_tr2()
	new iHitGroup = get_tr2(ptr, TR_iHitgroup)
	if (iTarget == iVictim) iHitGroup = iBody
	else pev(iVictim, pev_origin, fEnd)
	engfunc(EngFunc_TraceLine, fOrigin, fEnd, DONT_IGNORE_MONSTERS, iAttacker, ptr)
	if (iHitGroup == HIT_HEAD && !iHeadShot) iHitGroup = HIT_CHEST
	set_pdata_int(iVictim, 75, iHitGroup, 4)
	switch(iHitGroup)
	{
		case HIT_HEAD: fMultifDamage  = 4.0
		case HIT_CHEST: fMultifDamage  = 1.0
		case 3: fMultifDamage  = 1.25
		case 4,5,6,7: fMultifDamage  = 0.75
		default: fMultifDamage  = 1.0
	}
	fDamage *= fMultifDamage

	if (get_cvar_num("mp_friendlyfire") || (!get_cvar_num("mp_friendlyfire") && get_pdata_int(iAttacker, 114) != get_pdata_int(iVictim, 114)))
	{
		if (is_user_alive(iVictim)) SpawnBlood(fEnd, g_iBloodColor, floatround(fDamage))
	}

	ExecuteHamB(Ham_TakeDamage, iVictim, iEntity, iAttacker, fDamage, iDamageBit)
	
	free_tr2(ptr)
	return 1
}
//****

stock SpawnBlood(const Float:vecOrigin[3], iColor, iAmount)
{
	if(iAmount == 0)
	return

	if (!iColor)
	return

	iAmount *= 2
	if(iAmount > 255) iAmount = 255
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(iColor)
	write_byte(min(max(5, iAmount / 6), 46))
	message_end()
}

stock hook_ent2(ent, Float:VicOrigin[3], Float:speed, Float:multi, type)
{
    static Float:fl_Velocity[3]
    static Float:EntOrigin[3]
    static Float:EntVelocity[3]
    
    pev(ent, pev_velocity, EntVelocity)
    pev(ent, pev_origin, EntOrigin)
    static Float:distance_f
    distance_f = get_distance_f(EntOrigin, VicOrigin)
    
    static Float:fl_Time; fl_Time = distance_f / speed
    static Float:fl_Time2; fl_Time2 = distance_f / (speed * multi)
    
    if(type == 1)
    {
        fl_Velocity[0] = ((VicOrigin[0] - EntOrigin[0]) / fl_Time2) * 1.5
        fl_Velocity[1] = ((VicOrigin[1] - EntOrigin[1]) / fl_Time2) * 1.5
        fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time        
    } else if(type == 2) {
        fl_Velocity[0] = ((EntOrigin[0] - VicOrigin[0]) / fl_Time2) * 1.5
        fl_Velocity[1] = ((EntOrigin[1] - VicOrigin[1]) / fl_Time2) * 1.5
        fl_Velocity[2] = (EntOrigin[2] - VicOrigin[2]) / fl_Time
    }

    xs_vec_add(EntVelocity, fl_Velocity, fl_Velocity)
    set_pev(ent, pev_velocity, fl_Velocity)
}