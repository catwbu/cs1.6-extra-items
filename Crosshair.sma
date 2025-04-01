#include <amxmodx>
#include <fakemeta>

new button_check[33]
new color_check[33]
new color_rate[33]

#define COLOR_CHANGE_RATE 0.5  //每次換色間隔

public plugin_init()
{
	register_plugin("準心自動變色", "1.0", "Zero")
	register_clcmd("coloron", "color_on")
	register_clcmd("coloroff", "color_off")
	register_forward(FM_PlayerPreThink, "pThink")
	register_logevent("bind", 2 ,"1=Round_Start")	
}

public pThink(id)
{
	if(button_check[id]) //判斷開始執行
		colorchange(id)
}
public color_on(id) //開啟
{
	color_check[id] = 1 //用於立即停止
	button_check[id] = 1 //控制執行用
	color_rate[id] = 1 //控制間隔
	client_cmd(id, "bind F4 coloroff")
	client_print(id, print_chat, "準心自動變色開啟")
}
public color_off(id) //關閉
{
	color_check[id] = 0 //用於立即停止
	button_check[id] = 0 //執行結束
	color_rate[id] = 0 //間隔控制關閉
	client_cmd(id, "bind F4 coloron")
	client_print(id, print_chat, "準心自動變色關閉")
}
public bind(id) //開局歸零
{
	color_check[id] = 0 //用於立即停止
	button_check[id] = 0 //執行結束
	color_rate[id] = 0 //間隔控制關閉
	client_cmd(id, "bind F4 coloron")
}
public colorchange(id) //主要執行內容
{
	if(color_check[id]) //立即停止閥門
	{
		if(color_rate[id]) //間隔閥門
		{
			client_cmd(id, "adjust_crosshair") //變色
			//製造間隔
			color_rate[id] = 0   
			set_task(COLOR_CHANGE_RATE, "color_rate_RETURN", id)
		}
	}
}
public color_rate_RETURN(id)
	color_rate[id] = 1








