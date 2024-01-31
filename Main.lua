pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--░warm snow웃░
--by cyba

--poke(0x5f2e,1)

--[[

priorite :

6.
map generation
- prohibited zone ne fonctionne
pas
- le feu de camp bug (des invisibles
fonctionnent et les visibles
ne fonctionne pas)
- les mines spawn toujours au
meme endroit en haut a gauche,
whyyyy ??
- avoir des cailloux
- on dirait que les objets spawn
quand meme en boucle !!!

8.
tous les textes de maison a
mettre dans un seul et meme
tableau (plusieurs pieces)

8 bis.
rajouter des mines a la place
des lacs

9.
avoir pleins de palettes
differentes qui, toutes les
%10 revienne a 0 pour faire
des animations de palettes
- changer de palette lors de
certains combats, lors dun
changement detat dun monstre
- palette dans les menus lorsqu'
on le quitte ou qu'on appuye
- palette pour bouton qui
clignotte dans menu start

12.
ziiiiicmuuu ♪♪♪♪♪

15.
differencier particules en
dessous et au dessus

16.
avoir un bonus special apres
x ameliorations

17.reglage difficulte

18.dans menu selection, avoir
les symboles a un autre endroit
et la couleur change egalement

bug vitesse dattaque qui up
toute seule avec les niveaux

---

bug :

bug amelioration pv

forcer le rythme du bouton
enfonce sur myioo mini
(probleme resolu normalement
avec vitesse d'attaque)

les bullets n'activent pas
l'immunite de quelques secondes

le sprite du p continu a
tourner alors qu'il est mort

timer ⧗ avec une jauge max
pour comprendre ce qu'il reste

avoir un seuil pour ne pas te
faire one shot

difficulte :
les enemies sont plus forts,
mais pas trop la vie


---

a la fin :

spawn autour de l'ecran a 
deja provoque des bugs

attention a la probabilite des
different objets, qui sont les
meme

preciser le max possible pour
chaque categorie d'amelioration

remettre l'apparition des mobs
en fonction du world_lvl

attention, le jeu est un peu mou
il faut avoir les choses plus
concentre et le combat plus 
rapide (precision et changement
de cible accru)

pourquoi en restant sur place,
les fps chutent ?
on dirait que les objets spawn
quand meme en boucle !!!

ajuster la barre de cold


options :

10.
systeme de detection de lennemi
avec bruit balles + si lennemi
regarde dans la direction du
joueur

le menu upgrade change detat de
bouton exit quand plus assez 
d'xp (clignotte et quitte a 
nimporte quel appuie)

]]




function _init()
	--player
	keys_p=split("lvl_atk_speed,lvl_life_max,lvl_roll_delay,lvl_damages,atk_speed,pv_max,roll_delay,damages,x,y,l,h,v,pv,xp,xp_max,off,t_roulade,cooldown_roulade,v_normal,hurt_time,precision,cold,timer_death,cooldown_atk_speed")
	values_p=split("1,1,1,1,1,50,200,3,64,64,6,7,0.5,50,0,0,0,0,0,0,0,1,10000,0,0")
	spawn_p()

	p_moving=false
	cursor_target=0
	timer_attack_mode=0
	bullets={}

	cursor_angle=0.5
	cursor_x=10
	cursor_y=10
	diff_angle=cursor_target-cursor_angle
	
	spr_p_vertical=0
	spr_p_horizontal=false
	
	upgrade_temp=split("0,0,0,0")
	
	--camera
	listing_icons={split("23,53,5,4,3")}
	locking_cam_active=false
	locking_cam_possible=false
	locking_cam_info={x=0,y=0,l=1,h=1}
	camera_mode=0
	locking_cam_id_target=0
	center_cam={x=0,y=-250,oldx=0,oldy=0,l=1,h=1}
	timer_display_icons_on_top={}
	
	--world
	chunk_player_x=0
	chunk_player_y=0
	trees={}
	timer_clouds=0
	cloud_x=0
	cloud_y=0
	chunks={}
	objects={}
	add_object_to_chunk(0,0,1,true)
	amount_campfire=0
	no_enemy_nearby=false
	random_stuff_get=0

	--enemies
	enemies={}
	spr_enemies_cara_cond="0,59,14,10,0,4,-14,28,10,10,1:0,69,10,19,0,3,0,0,8,8,1:0,89,7,13,0,2,-7,-7,12,12,1:41,69,12,16,0,3,-12,0,10,10,2:41,85,16,19,0,2,-16,32,6,8,3:0,105,10,20,0,1,0,40,8,8,3"
	spr_enemies_cara=split_table(spr_enemies_cara_cond)
	keys_e=split("x,y,l,h,dx,dy,typ,pv,state,xp,timer_activity,timer_move,timer_attack,timer_spe_1,icon,id,hurt_time,p_distance,invincible,closest_p")

	
	--general
	timer_gbl=0
	music()
	angle_precision=0

	--tools
	shadow_x=-2
	shadow_y=0
	particules_pix={}
	footprint={}
	--spawn_random_screen_x=0
	--spawn_random_screen_y=0
	palette_change=0
	tremor_intensity=0
	tremor_timing=0
	tremor_x=0
	tremor_y=0
	timer_press_button_o=0
	timer_press_button_x=0
	flash_screen=false
	

	animation_empty={}
	animation_1_to_2={1,2}
	animation_1_to_3={1,2,3}
	animation_1_to_4=split("1,2,3,4")
	animation_1_to_3_loop_stop=split("1,1,1,2,3,2")

	--animation_1_to_3_stop=split("1,2,3,4,5,5,5,5,5,5,5")
	
	--wip
	--create_enemy(20,20,1,20)
	center={x=0,y=0,l=1,h=1}
	print_display=0
	
	--menu
	listing_options_menu_start=split_table("⬆️ normal,-189,1:➡️ hard,-177,2:⬇️ insane,-165,3")
	
	--keys_opt_menu_upgrade=split("animation_empty,animation_1_to_2,animation_1_to_3,animation_1_to_4,animation_1_to_3_loop_stop")
	listing_options_menu_upgrade=split_table("atk speed,43,22,1:life max,75,38,2:roll delay,41,54,3:damages,18,38,4:⬆️,57,30,1:➡️,64,38,2:⬇️,57,46,3:⬅️,50,38,4:press and hold 🅾️,30,117,5")
	
	logo_apparition=true
	animation_start=0
	
	--proba_by_objects={2,10,30,100}
	proba_new_object=400
	proba_by_objects={25,50,75,100}
	
	spr_sac_version={38,50,66}
	
	display_menu=true
	menu_start=true
	timer_after_menu=1001
	menu_upgrade=false
	
	difficulty=1
	world_lvl=1
	
	--p.pv=1000
	--p.xp=29000

end

function _update60()
	
	--reinitialisation
	update_palette()
 amount_campfire=0
 --no_enemy_nearby=true
	--menu_upgrade_ready=false
		
	--meteo
	particule(rnd(168)-94+p.x,rnd(168)-94+p.y,1,40,100,8,8,rnd(0.1)-world_lvl*0.15,0.3)

	--player
	if display_menu==false then
		update_p()
		player_moving()
		update_footprint(p,200)
		locking_cam_possible=false
	end
	
	update_bullets()
	check_no_enemy_nearby()	
	
	--world
	generate_map()
	update_trees()
	update_objects()
	update_clouds()
	map_boss()
	
	--camera
	mvmt_camera()
	curseur_ready()
	change_camera_mode()
	update_locking_cam()
	
	--enemies
	update_enemies()
	
	--general
	if (settings_boss.timer_end<=300) timer_gbl+=1
	
	--tools
	update_circ_particules()
	update_particule()
	update_tremor()
	press_button()
	
	--menu
	update_menu_start()
	update_menu_timer()
	update_menu_upgrade()
	
	--wip
	--if (timer_gbl==400) open_menu_upgrade()
	
end

function _draw()
 cls(7)
 
 --camera down
 draw_locking_cam()
 
 --shadows
 draw_shadows(p,3,3,0,0)

	--tools
	draw_circ_particules()
	draw_particule()
	
	--world under p
	draw_trees_down()
	draw_objects()
	--draw_lakes()
	
	--enemies
	draw_enemies()

	--player
 --draw_footprint()
 draw_p()
 draw_bullets()
 
 --world up p
 draw_trees_up()
	
	--camera up
	draw_vignetage()
	
	--wip
	draw_cursor()
	print(proba_new_object,p.x-30,p.y-30,3)

	--menu
	draw_menu_start()
	draw_menu_upgrade()
 draw_icon_on_top()
 draw_icon_on_top_temp()

	--interface
	interface_game()
	draw_flash_screen()
	draw_game_over()
	if (settings_boss.timer_end>300) draw_menu_end()
	
end
-->8
--player

function update_p()
	check_vitesse_change()
	buttons_direction()
	direction_p()
	direction_sprite_p()
	roulade()
	update_player_attack_mode()
	update_precision_p()
	check_immune_player()
	life_dommage_bullets(p,2)
	check_p_death()
	cursor_change_temp=0
	if (p.cooldown_atk_speed>0) p.cooldown_atk_speed-=1
	
	if (display_menu==false) update_cold_p()
	
	if (p.off>0) p.off-=1
	p.x+=add_mvmt_x
	p.y+=add_mvmt_y
	add_mvmt_x*=0.9
	add_mvmt_y*=0.9
	
	if btnp(🅾️) then	
		if (p.cooldown_roulade<=0) p.t_roulade=13
		if timer_press_button_o>20 then
			locking_cam_active=false
		end
	end

	if	btn(❎) and p.pv>0 then
	
		if player_attack_mode==true and p.cooldown_atk_speed<=0 then
			shoot_p()
		end
		active_player_attack_mode(200)
	
		if locking_cam_possible==true then 
			locking_cam_active=true
			active_player_attack_mode(30000)
			sfx(6)
		end
		
		if menu_upgrade_ready==true and no_enemy_nearby==false then
			open_menu_upgrade()
		end
		
		--for o in all(objects)	do	
			
		--end	
		
	end
	
end

function check_no_enemy_nearby()
	no_enemy_nearby=false
	for e in all(enemies) do
		if (between_two_objets(e,p)<80) then
			no_enemy_nearby=true
		end
	end
end

function draw_p()
	animate(animation_1_to_3,10)
	if (p_moving==true) create_circ_particules(p.x+p.l/2,p.y+p.h,5,0.25,0.1,0.1,0.2,20,4,1,5,0.1,8,8,8)

	if timer_gbl%20>=10 and p.hurt_time>0 then
	elseif p.timer_death>0 then
		sspr(12+ceil(p.timer_death/80)*6,8,6,7,p.x,p.y,6,7,spr_p_horizontal)
	else
		if timer_after_menu>0 and display_menu==true then
			anime=animation_1_to_4[flr((timer_after_menu%(#animation_1_to_4*52))/(52))+1]
			sspr(anime*6-6+18,14,6,7,p.x,p.y,6,7,spr_p_horizontal)
		else
			if (p_moving==false) anime=1
			if p.t_roulade>0 and p_moving==true then
				animate(animation_1_to_3,10)
				sspr(anime*6-6,14,6,7,p.x,p.y,6,7,spr_p_horizontal)
			else
				sspr(anime*6-6,spr_p_vertical,6,7,p.x,p.y,6,7,spr_p_horizontal)
				if (player_attack_mode==true) sspr(18,spr_p_vertical*0.3,8,2,p.x-1,p.y+3,8,2,spr_p_horizontal)
			end
		end
	end
end

function spawn_p()
	p=combine_keys_values(keys_p,values_p)
	add_mvmt_x=0
	add_mvmt_y=0
end


------

--shoot

function create_bullet(x,y,dx,dy,v,dmg,typ)
	add(bullets,{
		x=x,
		y=y,
		l=1,
		h=1,
		dx=dx,
		dy=dy,
		v=v,
		dmg=dmg,
		time_life=80/v,
		time_life_max=80/v,
		typ=typ
	})
end

function update_bullets()
	for b in all(bullets) do
		b.x+=b.dx*b.v
		b.y+=b.dy*b.v
		b.time_life-=1
		if (b.time_life<=0) del(bullets,b)
		particule(b.x,b.y,rnd(2),5,15,8,5,0,0,0,0)
	end
end

function life_dommage_bullets(someone,typ_hurt)
	for b in all(bullets) do
		if collision(b,someone,1) and b.typ==typ_hurt and someone.invincible~=true then
 		if (someone.typ~=nil) someone.state=3
 		particule(b.x,b.y,5,7,15,8,9,rnd(1)-0.5,rnd(1)-0.5)
			someone.hurt_time=4
			particule(someone.x+someone.l/2,someone.y+someone.h/2,rnd(12),18,200,3,8,0,0)
			someone.pv-=b.dmg
			del(bullets,b)
			sfx(7)
		end
	end
end

function draw_bullets()
	for b in all(bullets) do
		if b.typ==1 then
			pset(b.x,b.y,10)
		elseif b.typ==2 then
			circfill(b.x,b.y,2+timer_gbl%10/5,10)
			circ(b.x,b.y,4+timer_gbl%10/5,5+timer_gbl%20/5)
		end
	end
end

function shoot_p()
	local angle_shoot_precision=cursor_angle+(rnd((p.precision*0.05*(distance_between_lock_and_p*0.033))*0.2))-(p.precision*0.05*(distance_between_lock_and_p*0.033))/8
	local dx_shoot=cos(angle_shoot_precision)
	local dy_shoot=sin(angle_shoot_precision)

	p.cooldown_atk_speed=p.atk_speed*30
	create_bullet(p.x+p.l/2,p.y+p.h/2,dx_shoot,dy_shoot,2,p.damages,1)
 sfx(6)
 for i=1,5 do
		create_circ_particules(p.x+3+dx_shoot*5,p.y+3+dy_shoot*5,3,0.75,0.1,0.5,0.3,rnd(17),3,1,0,0.3,5,9,8)
	end
end


--precision shoot

function update_precision_p()
	p.precision-=0.1
	if (p_moving==true) p.precision+=0.22
	if (p.t_roulade>0) p.precision+=1

	--if (p.precision>p.precision_max) p.precision=p.precision_max
	if (p.precision>10) p.precision=10
	if (p.precision<1) p.precision=1
end



--attack mode

function active_player_attack_mode(x)
	player_attack_mode=true
	timer_attack_mode=x
end

function desactive_player_attack_mode()
	player_attack_mode=false
	timer_attack_mode=0
end

function update_player_attack_mode()
	if player_attack_mode==true then
		timer_attack_mode-=1
		if (timer_attack_mode<=0) player_attack_mode=false
	end
end

--[[
button_press_dir={0,0}

function direction_button()
	button_press_dir={0,0}
	if (btn(⬅️)) button_press_dir[1]+=1
	if (btn(➡️)) button_press_dir[1]-=1
	if (btn(⬆️)) button_press_dir[2]+=1
	if (btn(⬇️)) button_press_dir[2]-=1
	if button_press_dir[1]~=0 and button_press_dir[2]~=0 then
		button_press_dir[1]*=0.6 
		button_press_dir[2]*=0.6
	end
end
]]

--direction

function buttons_direction()
	if p.off==0 then
		if (btn(⬆️)) add_mvmt_y=-p.v
		if (btn(⬇️)) add_mvmt_y=p.v
		if (btn(⬅️)) add_mvmt_x=-p.v
		if (btn(➡️)) add_mvmt_x=p.v
	end
end

function direction_sprite_p()
	if 0.4>cursor_angle and cursor_angle>0.1 then 
		spr_p_vertical=7
	else
		spr_p_vertical=0
	end
	if 0.25<cursor_angle and cursor_angle<0.75 then 
		spr_p_horizontal=false
	else
		spr_p_horizontal=true
	end
end

function direction_p()

		cursor_target=atan2(add_mvmt_x,add_mvmt_y)

	if p_moving==true then
		diff_angle=cursor_target-cursor_angle
	
		if (diff_angle>0.55) cursor_angle+=1
		if (diff_angle<-0.55) cursor_angle-=1

	end
	
		if locking_cam_active==true then
			cursor_angle=atan2(locking_cam_info.x-(p.x+p.l/2),locking_cam_info.y-(p.y+p.h/2))
		elseif p_moving==true then
			cursor_angle+=(diff_angle)*0.2
		end
	
		cursor_x=cos(cursor_angle)*10
		cursor_y=sin(cursor_angle)*10

end

function draw_cursor()
	pset(p.x+p.l/2+cursor_x,p.y+p.h/2+cursor_y,11)
end


--roulade and move

function roulade()
	if p.t_roulade>0 then
		p.t_roulade-=1
		p.v=2
		p.v_normal+=1
		if (p.t_roulade<1) p.v=0.5
		p.cooldown_roulade=p.roll_delay
	end
	if p.cooldown_roulade>=0 then
		p.cooldown_roulade-=1
	end
end

function check_vitesse_change()
	if p.v_normal<=0 then
		p.v=0.5
	else
		p.v_normal-=1
	end
end


function player_moving()
	if abs(add_mvmt_x)>0.3 or abs(add_mvmt_y)>0.3 then
		p_moving=true
		if (timer_gbl%10==1) sfx(ceil(rnd(3)))
	else
		p_moving=false
	end
end


--hurt

function hurt_player(dmg)
	if p.hurt_time==0 then
		p.pv-=dmg
		p.hurt_time=200
	end
end

function check_immune_player()
	if p.hurt_time>0 then
		p.hurt_time-=1
	--else
	 --p.hurt_time=0
	end
end

-- experience

function add_xp(xp)
	p.xp+=xp
	p.xp_max+=xp
end

--cold bar

function update_cold_p()
	p.cold-=1
end


--death

function check_p_death()
	if p.pv<=0 then
		activate_death()
	end
end

function activate_death()
	locking_cam_active=false
	display_menu=true
	p.timer_death+=1
	p.off=2
	palette_change=1
	p.hurt_time=0
	if p.timer_death>400 then
		_init()
	end
end
-->8
--world

--chunks

settings_boss={
timer=0,
active=0,
boss_alive=false,
timer_end=0
}

function map_boss()
	if world_lvl==6 then
		settings_boss.active=1
		if (p.timer_death==0) palette_change=3
		if display_menu==false then
		
			settings_boss.timer+=1
			if settings_boss.timer==1 then
				create_enemy(p.x-8,p.y-80,6,10,0)
				--for e in all(enemies) do
				-- e.id=1234	
				--end
			elseif settings_boss.timer<=220 then
				center_cam.x-=1
				center_cam.y-=17
				activate_tremor(0.1,99)
			end
		end
		
		if settings_boss.timer>300 and settings_boss.boss_alive==false then
			settings_boss.timer_end+=1
			activate_tremor(0.16,97)

		end
	end
end

function generate_map()
	listing_chunks_to_create={}

	chunk_player_x=flr((p.x-64)/100+0.5)*100
	chunk_player_y=flr((p.y-64)/100+0.5)*100

	if chunk_player_x~=p.x or chunk_player_y~=p.y then
		for i=-1,1 do
			for j=-1,1 do
				check_chunks_if_exist(chunk_player_x+i*100,chunk_player_y+j*100)
			end
		end
		
		print_display=#listing_chunks_to_create
	
		for c in all(listing_chunks_to_create) do
		 add_new_chunks(c.x,c.y)	
		end

		chunks_active_listing()

	end
end

---

function check_chunks_if_exist(x,y)
	local chunks_exist=false
	for c in all(chunks) do
		if c.x==x and c.y==y then
			chunks_exist=true
		end
	end
	
	if chunks_exist==false then
		add(listing_chunks_to_create,{
			x=x,
			y=y,
		})
	end
	
end


---

function add_new_chunks(x,y)
	trees_generate={}
	
	typ_o=0
	pos_o_x=0
	pos_o_y=0
	coor_local_chunk={x=x,y=y}
	
	object_generate()
	trees_to_generate()
	generate_chunk()
	if (world_lvl~=6) create_spawn_enemies(coor_local_chunk.x+rnd(100),coor_local_chunk.y+rnd(100))
end

function check_campfire()
	amount_campfire=0
	for o in all(objects) do
		if o.typ==1 then
			amount_campfire+=1
		end
	end
end

function object_generate()
	local rnd_proba_generate=rnd(proba_new_object)
	typ_o=0
	for i=1,4 do
		if rnd_proba_generate<=proba_by_objects[i] and typ_o==0 then
			if amount_campfire>1 and i==1 then
				typ_o=4
			else
				typ_o=i
			end
			--proba_new_object+=1/i*150
		end
	end
	
	if (proba_new_object>500) proba_new_object=500
	
	proba_new_object-=1
	
	if typ_o~=0 then
		pos_o_x=ceil(rnd(80)+10)+coor_local_chunk.x
		pos_o_y=ceil(rnd(80)+10)+coor_local_chunk.y
	end
	
	if (settings_boss.active==0) add_object_to_chunk(pos_o_x,pos_o_y,typ_o)
	
end


function add_object_to_chunk(x,y,typ,menu)
		x=x
		y=y
	if menu==true then
		x=p.x-13
		y=p.y-10
	elseif typ==3 then
		x=10
		y=10
	end
	local usable=false
	if (typ==2 or typ==4) usable=true

	add(objects,{
		x=x,
		y=y,
		l=21,
		h=15,
		typ=typ,
		timer_obj=0,
		usable=usable,
		version=ceil(rnd(3))
	})
end


function trees_to_generate()

	amount_trees_generate=(ceil(rnd(10))+6)
	--*settings_boss.active

	if typ_o~=0 then
		prohibited_zone={x=pos_o_x,y=pos_o_y,l=24,h=24}
	else
		prohibited_zone={x=0,y=0,l=0,h=0}
	end
	
	for i=1,amount_trees_generate do
		local coor_for_tree={x=ceil(rnd(100)),y=ceil(rnd(100)),l=14,h=10}
		if between_two_objets(coor_for_tree,prohibited_zone)>60 then
			add(trees_generate,{
				x=coor_for_tree.x+coor_local_chunk.x,
				y=coor_for_tree.y+coor_local_chunk.y,
				l=13,
				h=3,
				typ_side=ceil(rnd(3)),
				typ_bot=ceil(rnd(3)),
				typ_floor=ceil(rnd(10)),
			})
		end
	end
end


function generate_chunk() 
	add(chunks,{
		active=false,
		x=coor_local_chunk.x,
		y=coor_local_chunk.y,
		l=100,
		h=100,
		object={x=pos_o_x+coor_local_chunk.x,y=pos_o_y+coor_local_chunk.y,typ=typ_o},
		trees=trees_generate,
	})
end

function chunks_active_listing()
	chunks_active={}
	for c in all(chunks) do
		if between_two_objets(p,c)<180 then
			add(chunks_active,c)
		else
			del(chunks,c)
		end
	end
end


---


--objects


function update_objects()
	for o in all(objects) do
		if (between_two_objets(o,p)>180) del(objects,o)
		if o.typ==1 then
	 	update_campfires(o)
	 elseif o.typ==2 then
	 	update_buildings(o)
	 elseif o.typ==3 then
	 	update_mines(o)
	 elseif o.typ==4 then
	 	update_bags(o)
	 else
			del(objects.o)
	 end
	end
end

function draw_objects()
	animate(animation_1_to_4,10)
 for o in all(objects) do
 	if o.typ==1 or o.typ==11 then
 		draw_campfires(o)
 	elseif o.typ==10 then
 		draw_campfires(o)
			o.timer_obj-=1
			if (o.timer_obj<=0) o.typ=11
		elseif o.typ==2 then
			draw_buildings(o)
		elseif o.typ==3 then
			draw_mines(o)
		elseif o.typ==4 then
			draw_bags(o)
 	end
 end
end

--buildings


function update_buildings(o)
	
end


function draw_buildings(o)
	sspr(52+o.version*19,104,19,21,o.x,o.y-30)
end


--mine

function update_mines(o)
	if collision(o,p,-8) then
		explosion_of_zone_and_dmg(o,40)
		del(objects,o)
	end
end

function draw_mines(o)
	pset(o.x+10,o.y+10,2+(timer_gbl%50)/25)
	circ(o.x+10,o.y+10,3,8)
end


--bag


function update_bags(o)
	if btnp(❎) and between_two_objets(o,p)<10 and o.usable==true and no_enemy_nearby==false and (o.typ==4 or o.typ==2) then
		gain_stuff(1,4,o)
		o.usable=false
	end
end

function draw_bags(o)
	local state_object=0
	if (o.usable~=true) state_object=6+o.version*2-2
 sspr(spr_sac_version[o.version]+state_object,53,4+o.version*2,6,o.x+o.l/2,o.y+o.h/2)
end

function gain_stuff(a_min,a_max,o)
	random_stuff_get=ceil(rnd(a_max-a_min))+a_min
	if random_stuff_get<=2 then
		create_icon_on_top_temp(o.x+6,o.y,"+10♥",300)
		p.pv+=10
		if (p.pv>p.pv_max) p.pv=p.pv_max
	elseif random_stuff_get<=4 then
		create_icon_on_top_temp(o.x,o.y,"+200◆",300)
		add_xp(200)
	elseif random_stuff_get<=6 then
		create_icon_on_top_temp(o.x,o.y,"+400◆",300)
		add_xp(400)
	elseif random_stuff_get<=7 then
		create_icon_on_top_temp(o.x,o.y,"+1♥max",300)
		upgrade_temp[1]+=1
	elseif random_stuff_get<=8 then
		create_icon_on_top_temp(o.x-4,o.y,"+1⧗roll",300)
		upgrade_temp[2]+=1
	elseif random_stuff_get<=9 then
		create_icon_on_top_temp(o.x,o.y,"+1✽dmg",300)
	 upgrade_temp[3]+=1
	elseif random_stuff_get<=10 then
		create_icon_on_top_temp(o.x-8,o.y,"+1…atk spd",300)
	 upgrade_temp[4]+=1
	end
	if (random_stuff_get>=7 and random_stuff_get<=10) apply_upgrade_temp()
end


--campfires

function update_campfires(o)
	if o.typ==1 then
	 if	menu_upgrade==false then
			create_circ_particules(o.x+3,o.y+7,5,0.25,0.1,1,rnd(0.1),rnd(40)+30,10,flr(rnd(1)+0.2),10,0.2,8,8,8)
		end
		if between_two_objets(p,o)<20 then
			menu_upgrade_ready=true
		else
			menu_upgrade_ready=false
		end
	end
end

function draw_campfires(o)
	sspr(0,43,21,15,o.x-7,o.y+7)
 if o.typ==1 then
 	sspr(22+anime*7-7,43,7,10,o.x,o.y+6)
		if timer_after_menu>0 and timer_gbl%40>20 then
			draw_find_campfire(o)
		end
	elseif o.typ==10 then
		anime=animation_1_to_4[flr(((o.timer_obj*-1)%(#animation_1_to_4*25))/25)+1]
 	sspr(50+anime*7-14,43,7,10,o.x,o.y+6)
		draw_find_campfire(o)
	end	
end

function draw_find_campfire(o)
	if world_lvl~=6 then
		print(
			[[
	    -> ⧗! <-
	  find the next
	    campfire!  ]],o.x-29,o.y-17+o.timer_obj*0.03,12)
	end
end




--trees

function update_trees()
	for c in all(chunks_active) do
		for t in all(c.trees) do
			if collision(p,t,-3) then
				p.v=0.1
				p.v_normal+=1
			end
		end
	end
end


function draw_trees_up()
	if settings_boss.active==0 then
		for c in all(chunks_active) do
			for t in all(c.trees) do
	   sspr(14+(t.typ_side*13-13),21,13,22,t.x-4,t.y-23)
	 	end
	 end
	end
end

function draw_trees_down()
	for c in all(chunks_active) do
		for t in all(c.trees) do
		 draw_shadows(t,0,0,0,0,true)
		 sspr(5*t.typ_bot-5,21,5,4,t.x,t.y-1)
		 sspr(0,t.typ_floor+25,13,4,t.x-2,t.y+1)
 	end
 end
end



--clouds

--[[requis
cloud_x=0
cloud_y=0
]]

function update_clouds()

	timer_clouds+=2
	if timer_clouds>=500 then	
		spawn_around_screen()
		cloud_x=spawn_random_screen[1]
		cloud_y=spawn_random_screen[2]
		timer_clouds=ceil(rnd(400)+200)
		create_circ_particules(cloud_x,cloud_y,16,0.23,0,rnd(3)+8,0,1500,1500,rnd(4)+4,30,0.1,8,8,8)
	end

end



--footprint

function update_footprint(a,life_time)
	if timer_gbl%10==1 then
		particule(a.x+a.l/2,a.y+2,1,10,life_time,8,8,0,0)
	end
end
-->8
--camera and effects

--vignetage

function draw_vignetage()
	for i=1,40 do
		fillp(0b1110111101011111.1)
		--if (i<10) fillp()
		if (i<29) fillp(█)
		circ(center_cam.x+64,center_cam.y+64,92-i,7)
		--circ(center_cam.x+64,center_cam.y+64,76-i*(2^(i*0.02)),7)
		fillp()
	end
	
	--[[
	sspr(97,0,31,26,center_cam.x+97,center_cam.y)
	sspr(97,0,31,26,center_cam.x,center_cam.y,32,32,true)
	sspr(97,0,31,26,center_cam.x,center_cam.y+96,32,32,true,true)
	sspr(97,0,31,26,center_cam.x+97,center_cam.y+96,32,32,false,true)
]]
end

function print_ex(a)
	print(a,x,y,col)
end


function mvmt_camera()
	
	local older_cam_x=0
	local older_cam_y=0
	to_number_one=0
	
	if camera_mode==0 then
		older_cam_x=p.x-64
		older_cam_y=p.y-64
	elseif camera_mode==1 then
		if (timer_press_button_o>8) to_number_one=-1*(1/(timer_press_button_o*0.1+1))+1
		older_cam_x=(p.x+locking_cam_info.x+(p.x-locking_cam_info.x)*to_number_one)/2-64+center_cam.oldx*0.8
		older_cam_y=(p.y+locking_cam_info.y+(p.y-locking_cam_info.y)*to_number_one)/2-64+center_cam.oldy*0.8
	end
	
	diff_old_new_cam_x=older_cam_x-center_cam.x
	diff_old_new_cam_y=older_cam_y-center_cam.y

	center_cam.x=older_cam_x-diff_old_new_cam_x*0.8
	center_cam.y=older_cam_y-diff_old_new_cam_y*0.8

	camera(center_cam.x+tremor_x,center_cam.y+tremor_y)
end


--ciblage

function curseur_ready()
	for e in all(enemies) do
	
		checking_angle(e,0.35)
		if (collision(p,e,40)) and angle_comparaison==true and locking_cam_active==false and p.timer_death<1 then
			if (timer_gbl%100==1) sfx(5)			
		 e.icon=1
		 locking_cam(e)	
	  
		else
			e.icon=0
		end
		
	end
end

function change_camera_mode()
	camera_mode=0
	if (locking_cam_active==true) camera_mode=1
end

function locking_cam(x)
	locking_cam_id_target=x.id
	locking_cam_possible=true
end

function update_locking_cam()
	distance_between_lock_and_p=between_two_objets(p,locking_cam_info)
	for e in all(enemies) do
		if e.id==locking_cam_id_target then
			locking_cam_info.x=(e.x+e.l/2)
			locking_cam_info.y=(e.y+e.h/2)
			between_two_objets(p,e)
			if (not collision(e,p,90)) locking_cam_active=false
		end
	end
end

function draw_locking_cam()
	if locking_cam_active==true then	
		animate(animation_1_to_3,100)
		local precision_circ_dyn=(p.precision-1)*3*(distance_between_lock_and_p*0.023)
		local col_local=9
		if (precision_circ_dyn>18) fillp(▒)
		
		if timer_press_button_o>10 then 
			fillp(░)
			col_local=8
		end
		if timer_press_button_o>15 then
		 fillp(ˇ)
		 col_local=6+timer_gbl%10/5
		end
		circ(locking_cam_info.x,locking_cam_info.y,precision_circ_dyn,col_local)
		fillp()
	end
end


--icons

function draw_icon_on_top()
	for e in all(enemies) do
		if e.icon==1 then
			animate(animation_1_to_3_loop_stop,10)
			sspr(23+anime*5-5,53,5,4,e.x+e.l/2-2,e.y+e.h/2-10)
		end
	end
	for o in all(objects) do
	 if display_menu==false and o.usable==true and between_two_objets(p,o)<20 then
			if o.typ==1 and menu_upgrade_ready==true then
					display_button_action(o)
			elseif o.typ~=1 and o.usable==true then
				display_button_action(o)
			end
		end
	end
end

function display_button_action(o)
	animate(animation_1_to_3_loop_stop,10)
	if (no_enemy_nearby==true) anime=0
	print("❎",o.x+o.l/2,o.y+o.h/2-10,8+anime)
end

--icons on top

function create_icon_on_top_temp(x,y,score,time_anime)
	add(timer_display_icons_on_top,{
		x=x,
		y=y,
		score=score,
		time_anime=time_anime,
		time_anime_max=time_anime,
	})
end

function draw_icon_on_top_temp()
	for i in all(timer_display_icons_on_top) do
		i.time_anime-=1
		print(i.score,i.x,i.y-14-(i.time_anime/i.time_anime_max)*-4,8+(i.time_anime/i.time_anime_max)*3)
		if (i.time_anime<=0) del(timer_display_icons_on_top,i)
	end
end
-->8
--enemies

function update_enemies()
	if (display_menu==false and (world_lvl~=6 or settings_boss.timer>200)) then
		spawn_around_screen()
		spawn_auto_enemies(spawn_random_screen[1],spawn_random_screen[2])	
		distance_e_closest_p=1000
		settings_boss.boss_alive=false
		
		for e in all(enemies) do
			check_distance_p(e)
		end
		
		for e in all(enemies) do
		
			--with p
			update_touch_e_to_p(e)
			apply_distance_p_label(e)
			if (settings_boss.timer_end>1) e.pv-=100
			
			--states
	 	life_dommage_bullets(e,1)
	 	check_hurt_enemy(e)
	 	check_life_enemies(e)
	 	update_footprint(e,300)
			check_distance_player(enemies,e)
			
			--move
			neutral_move_enemies(e)
			check_change_move_to_attack(e)
			
			--attack
			if (world_lvl==6) e.state=3
			
			if e.state==3 then
				e.timer_attack+=1
				attack_enemy_gbl(e)
			end
			
		end
	end
end


function check_distance_p(e)
	e.cloest_p=between_two_objets(e,p)
	if e.cloest_p<distance_e_closest_p then
		distance_e_closest_p=e.cloest_p
	end
end

function apply_distance_p_label(e)
	if e.cloest_p==distance_e_closest_p then
		e.cloest_p=1
	else
		e.cloest_p=0
	end
end

function draw_enemies()
	if p.timer_death<=0 then
		for e in all(enemies) do
			draw_shadows(e,0,e.h*0.8,0,0,true)
			if e.hurt_time==0 then
				check_spr_direction(e)
				draw_enemies_spr(e)
			end
		end
	end
end



--attacks

function attack_enemy_gbl(e)

	if e.typ==1 then
		
		if e.timer_attack<rnd(100)+100 then
			typ_mvmt_enemy_around_p(e,10)
		elseif p.hurt_time>0 and between_two_objets(p,e)<90 then
			typ_mvmt_enemy_dir_p(e,false,1.2)
		elseif e.timer_attack<301 then
			typ_mvmt_enemy_dir_p(e,true,1)
		elseif e.timer_attack>300 then
			e.timer_attack=0
		end

	elseif e.typ==2 then
		
		typ_mvmt_enemy_dir_p(e,true,0.5)
		if e.timer_attack>rnd(300)+200 then
			typ_mvmt_enemy_teleport(e,20,50)
			e.timer_attack=0
		end

	elseif e.typ==3 then
		
		typ_mvmt_enemy_dir_p(e,true,0.4)
		--if between_two_objets(e,p)<12 then 
		if collision(e,p,5) then
			explosion_of_zone_and_dmg(e,20)
			locking_cam_active=false
			del(enemies,e)
		end
		
	elseif e.typ==4 then

		local attack_speed_e_up=80
		if (collision(e,p,20)) attack_speed_e_up=10
		if e.timer_attack>attack_speed_e_up then
			local angle_e_to_p=angle_to(e,p)
			create_bullet(e.x+e.l/2,e.y+e.h/2,cos(angle_e_to_p),-sin(angle_e_to_p),attack_speed_e_up/130+0.4,15,2)
			e.timer_attack=0
		end
		
	elseif e.typ==5 then

		if e.timer_attack<rnd(100)+100 then
			typ_mvmt_enemy_around_p(e,10)
		elseif	e.timer_attack<220 then
			e.timer_spe_1+=1
			if (timer_gbl%5==1) create_bullet_fast(e)
			typ_mvmt_enemy_dir_p(e,true,1+(e.timer_spe_1*0.1),true)
		elseif e.timer_attack>220 then
			e.timer_attack=0
			e.timer_spe_1=0
		end

	elseif e.typ==6 then

		settings_boss.boss_alive=true

		if e.timer_attack<200 then
			e.invincible=true
			typ_mvmt_enemy_dir_p(e,true,0.3)
		
		elseif e.timer_attack==201 then
			local attack_typ_e=ceil(rnd(3))
			if (attack_typ_e==1 and #enemies>3) attack_typ_e=ceil(rnd(2))+1
			e.invincible=false
			
			if attack_typ_e==1 then
				for i=1,3 do
					create_enemy(rnd(100)+e.x-50,rnd(100)+e.y-50,1,20,100)
				end
			elseif attack_typ_e==2 then
				e.timer_spe_1=100
			elseif attack_typ_e==3 then
				e.timer_spe_1=200
			end
			
		elseif e.timer_attack<400 then

			if e.timer_spe_1>0 and e.timer_spe_1<=100 and timer_gbl%10==1 then
				create_bullet_fast(e)
				e.timer_spe_1-=10
				if (timer_gbl%50==1) typ_mvmt_enemy_teleport(e,20,50)
			elseif e.timer_spe_1>102 and e.timer_spe_1<=200 then
				typ_mvmt_enemy_dir_p(e,true,1.1)
				if (timer_gbl%30==1) typ_mvmt_enemy_teleport(e,40,45)
				palette_change=1
				e.timer_spe_1-=1
			end
			
		elseif e.timer_attack>400+rnd(100) then
			e.timer_attack=0
			e.timer_spe_1=0
			
		end
	end
end


function explosion_of_zone_and_dmg(e,zone)
	if (between_two_objets(e,p)<zone) p.pv-=20
	for other in all(enemies) do
		if (between_two_objets(e,other)<zone) other.pv-=50
	end
	flash_screen=true
	create_circ_particules(e.x+e.l/2,e.y+e.h/2,16,0.25,0.1,9,-1*rnd(0.1),rnd(40)+70,60,13,2,0.1,3,10,8)
	activate_tremor(0.5,94)
end

function create_bullet_fast(e)
	local angle_e_to_p=angle_to(e,p)
	create_bullet(e.x+e.l/2,e.y+e.h/2,cos(angle_e_to_p),-sin(angle_e_to_p),1.5,15,2)
end

function check_spr_direction(e)
	local spr_direction=false
	if (e.dx<0) spr_direction=true
end

function invincible_circ(e)
	circ(e.x+4,e.y+4,15,3)
	for b in all(bullets) do
		if between_two_objets(b,e)<20 then
			del(bullets,b)
			sfx(9)
		end
	end 
end

-------

function neutral_move_enemies(e)
	if e.state==1 then
		e.timer_activity+=1
		if (e.timer_activity>rnd(300)+300) then
			e.state=2	
			e.timer_activity=0
		end
	elseif e.state==2 then
		enemy_move_rnd(e)
	end
end


function check_change_move_to_attack(e)
	if between_two_objets(p,e)<45 then
		e.state=3
	end
	if between_two_objets(p,e)>120 then 
		e.state=2
	end
end

------

--enemies move

function enemy_move_rnd(enemy)
	enemy.timer_move+=1
	if enemy.timer_move==1 then
		enemy.dx=(rnd(0.2)-0.1)*2
		enemy.dy=(rnd(0.2)-0.1)*2
	end
	if enemy.timer_move<rnd(300)+200 then
		enemy.x+=enemy.dx
		enemy.y+=enemy.dy
	else
		enemy.state=1
		enemy.timer_move=0
	end
end


--mvmt of enemies

function update_touch_e_to_p(e)
	if collision(e,p,-5) then
		hurt_player(10)
	end
end

function typ_mvmt_enemy_around_p(e,s)
	local multiply_cos_sin_local=1
	if (between_two_objets(p,e)<40 or between_two_objets(p,e)>50) multiply_cos_sin_local=0.6
	e.x+=sin(angle_to(p,e))*multiply_cos_sin_local
	e.y+=cos(angle_to(p,e))*multiply_cos_sin_local
end

function typ_mvmt_enemy_dir_p(e,towards_p,s,charge_bool)
	local typ_of_direction_towards_p=1
	local towards_p_angle=angle_to(e,p)
	if (towards_p~=true) typ_of_direction_towards_p=-1
	if (charge_bool==true and e.timer_spe_1<8) or charge_bool~=true then
		e.dx=cos(towards_p_angle)*s*typ_of_direction_towards_p
		e.dy=-sin(towards_p_angle)*s*typ_of_direction_towards_p
	end
	e.x+=e.dx
	e.y+=e.dy
end

function typ_mvmt_enemy_teleport(e,min_near_p,max_near_p)
	create_circ_particules(e.x+e.l/2,e.y+e.h/2,5,0.25,0.1,5,-1*rnd(0.1),rnd(40)+70,60,10,4,0.1,3,10,8)
	flash_screen=true	
	e.x=150+p.x
	e.y=150+p.y
	while between_two_objets(e,p)<min_near_p do
		e.x=rnd(max_near_p*2)+p.x-max_near_p
		e.y=rnd(max_near_p*2)+p.y-max_near_p
	end
	create_circ_particules(e.x+e.l/2,e.y+e.h/2,5,0.25,0.1,5,-1*rnd(0.1),rnd(40)+70,60,10,4,0.1,3,10,8)
end

--life

function check_life_enemies(e)
	if (e.pv<=0) then
		if (e.id==locking_cam_id_target) locking_cam_active=false
		particule(e.x,e.y,40,0,60,10,9,0,rnd(0.1)-0.2,e.l*2,e.h*3)
  create_circ_particules(e.x+e.l/2,e.y+e.h/2,8,0.25,0.1,4,0.07,70,20,6,1,0.05,9,8,8)
		activate_tremor(20,90)
		add_xp(e.xp)
		create_icon_on_top_temp(e.x,e.y,"+100◆",200)
		del(enemies,e)
	end
end


--check distance gbl

function check_distance_player(parent,enfant)
	enfant.p_distance=between_two_objets(p,enfant)	
	if not collision(p,enfant,200) then
		if (world_lvl~=6) del(parent,enfant)
	end
end

--enemy hurt_time

function check_hurt_enemy(e)
	if e.hurt_time>0 then
		e.hurt_time-=1
	end
end


--creation

function spawn_auto_enemies(x,y)
	if timer_gbl%2000==1 then
		create_spawn_enemies(x,y)
	end
end

function create_spawn_enemies(x,y)
	--setting 3 = typ
	if #enemies<5 then
		--typ_e=ceil(rnd(5))
		typ_e=ceil(rnd(world_lvl))
		create_enemy(x,y,typ_e,10*typ_e,100+typ_e*50)
	end
end 

function create_enemy(x,y,typ,pv,xp)
	local values_e={x,y,spr_enemies_cara[typ][3],spr_enemies_cara[typ][4],0,0,typ,pv,1,xp,0,0,0,0,0,rnd(300),0,0,false,0}
	add(enemies,combine_keys_values(keys_e,values_e))
end


typ_of_animation={animation_empty,animation_1_to_2,animation_1_to_3,animation_1_to_4}

function draw_enemies_spr(e)

	local typ_of_animation_local=typ_of_animation[spr_enemies_cara[e.typ][6]]

	local animation_by_state=animation_empty
	local animation_start_by_state=0
	local animation_delay_by_state=0
	local display_during_atk_action=false
	
	print_display=spr_enemies_cara[5][1]

	--uniquement pendant l'action
	if spr_enemies_cara[e.typ][11]==3 then
		display_during_atk_action=true
		if e.state==3 and	e.timer_attack>=0 then
			display_during_atk_action=false
		end
	end
	
	if e.state==1 then 
		animation_by_state=animation_empty
		animation_start_by_state=0
		animation_delay_by_state=0
	elseif e.state==3 and display_during_atk_action==false then
	 animation_by_state=typ_of_animation_local
		animation_start_by_state=spr_enemies_cara[e.typ][8]
		animation_delay_by_state=spr_enemies_cara[e.typ][10]
	elseif e.state>=2 then
	 animation_by_state=animation_1_to_3
		animation_start_by_state=spr_enemies_cara[e.typ][7]
		animation_delay_by_state=spr_enemies_cara[e.typ][9]
	end
	
	anime=0
	animate(animation_1_to_3,8)

	--sprite immobile lors attack
	if spr_enemies_cara[e.typ][11]==2 then
		if e.state==3 then
		 anime=4
		 if (e.timer_attack<6) anime=3
		end
	end
	
	if e.state==1 then
		anime=0
	end
	
		--exceptions
	local y_change_spr=0
	
	if e.typ==2 and between_two_objets(e,p)<12 and timer_gbl%20>10 then
		y_change_spr=17
		anime=3
	elseif e.typ==3 and between_two_objets(e,p)<23 and timer_gbl%16>8 then
		anime=4
	elseif e.typ==5 and e.state==3 then
		anime-=1
	elseif e.typ==6 and e.state==3 then 
		if e.timer_attack<200 then
			invincible_circ(e)
			anime-=4
		else
			anime=0
		end
	end

	sspr(spr_enemies_cara[e.typ][1]+animation_start_by_state+anime*spr_enemies_cara[e.typ][3],spr_enemies_cara[e.typ][2]+y_change_spr,spr_enemies_cara[e.typ][3],spr_enemies_cara[e.typ][4],e.x-spr_enemies_cara[e.typ][3]*0.1,e.y,spr_enemies_cara[e.typ][3],spr_enemies_cara[e.typ][4],spr_direction)

end

-->8
--menu and interface


--menu building

--[[
listing_storie_building={"kitchen,the kitchen is a total mess and the back door is blocked containing strange noises,search the room,3,2,30,open the back door,1,2,80,leave,2,2,100:leaving room,the room is well decorated and clean with nothing out of the ordinary to report,search quickly,3,7,80,search deeper,4,2,60,leave,2,7,90:barn,a large abandoned space dotted with large crates deep the dark,search,3,8,60,shoot everywhere,4,7,60,leave,2,8,50:ancient chapel,a stench covers this dilapidated strange place,search,6,9,30,explore,20,8,50,leave,2,7,80:stock,a large quantity of trifles covers the furniture,search quickly,5,2,80,search deeper,21,2,60,leave,2,2,100:aaltar,an altar adorns the entire room with strange photos with candles still lit,smash everything,3,8,70,pray,21,2,50,leave,3,2,40"}
story_choose=0
story_choose_timer=0

function update_menu_building()
	if menu_building==true then
		story_choose_timer+=1
		palette_change=2
		if story_choose_timer==1 then
			story_choose=rnd(2)
		end
		if story_choose_timer>20 then
			if (btn(⬆️))
		end
	end
end


function draw_menu_building()
	if menu_building==true then
		
	end
end
]]


--

function update_menu_timer()
	if (timer_after_menu>=1 and timer_after_menu<=1000) timer_after_menu-=1
	if timer_after_menu==2 then
		turn_off_fire()
		proba_new_object=100
		if (menu_start==false) world_lvl+=1
	end
	if timer_after_menu==0 then
		display_menu=false
		menu_start=false
		menu_upgrade=false
	end
end

function turn_off_fire()
	for o in all(objects) do
		if o.typ==1 then
			o.typ=10
			o.timer_obj=100
		end
	end
end

--menu start

function update_menu_start()
	if menu_start==true then
		if (btn(⬆️))	difficulty_choice(1)
		if (btn(➡️))	difficulty_choice(2)
		if (btn(⬇️))	difficulty_choice(3)
		if (btn(❎)) and difficulty>0 and timer_after_menu>=200 and timer_gbl>170 then
			timer_after_menu=200
			enemies={}
		end
		fire_effects(45,-208,difficulty)
	end

end

function fire_effects(x,y,difficulty)
	if difficulty==3 then
	create_circ_particules(x,y-difficulty*3,6*(difficulty*0.8-1),0.25,0.1,6,-0.08,rnd(30)+50,20,1,10,0.4,3,2,2)	
	end
	create_circ_particules(x,y-difficulty*2,4*(difficulty*1.2-1),0.25,0.1,3+(difficulty*1.2),-0.08+(difficulty*0.01),rnd(30)+50-difficulty*5,30,1,10,0.4,3,3,8)
	create_circ_particules(x,y-4-difficulty*2,2*(difficulty*1.2-1),0.25,0.05,2+(difficulty*1.2),-0.08+(difficulty*0.01),100-difficulty*10,40,flr(rnd(1)+0.5),10,0.4,4,4,8)
end

function character_and_fire(x,y)
	if timer_gbl%100>50 then
		character_and_fire_var=1
	else
		character_and_fire_var=0
	end
 sspr(102,27,26,35,x+35,y-25-character_and_fire_var,26,34+character_and_fire_var)
	sspr(102,62,26,12,x,y)
end

function draw_menu_start()
	if menu_start==true then
	
		character_and_fire(33,-208)
		--logo
		sspr(48,0,36,21,36,-280-animation_start-timer_gbl/20,54,31)
			
		--options
		for e in all(listing_options_menu_start) do
			local color_menu=9
			if (e[3]==difficulty) color_menu=11
			print (e[1],44,e[2]-animation_start*1.2+24,color_menu)
		end

	 sspr(72,37,30,11,47,-153-animation_start*1.2+24+timer_gbl%60/30)

		draw_circ_particules()
	 
	 if timer_after_menu>=200 and timer_gbl<120 then
			center_cam.x=0
			center_cam.y-=76
		elseif timer_after_menu>=200 then
			center_cam.y-=64
			if (animation_start<20) animation_start+=1
		end
				
	end
end

function difficulty_choice(a)
	difficulty=a
end





--menu upgrade

function open_menu_upgrade()
	menu_upgrade=true
	display_menu=true
	timer_after_menu=1001
	choice_option=0
end

function update_menu_upgrade()
 if	menu_upgrade==true and timer_after_menu>=200 then
		
 	--palette_change=1
 	if (btn(⬆️) and upgrade_temp[1]+p.lvl_atk_speed<=40) choice_option=1
 	if (btn(➡️) and upgrade_temp[2]+p.lvl_life_max<=40) choice_option=2
 	if (btn(⬇️) and upgrade_temp[3]+p.lvl_roll_delay<=40) choice_option=3
 	if (btn(⬅️) and upgrade_temp[4]+p.lvl_damages<=40) choice_option=4
 	if (btn(🅾️)) choice_option=5
 	if (btnp(❎)) and choice_option>0 and choice_option<5 then
 	 if upgrade_temp[choice_option]*30<p.xp then
 	 	upgrade_temp[choice_option]+=1
 			p.xp-=upgrade_temp[choice_option]*30
 			if (upgrade_temp[choice_option]>=40) choice_option=0
 		end
 	end
 	if timer_press_button_o>60 then
 		timer_after_menu=200
 		apply_upgrade_temp()
 	end
 	if timer_after_menu>=200 then
	 	create_circ_particules(center_cam.x+47,center_cam.y+98-difficulty*2,4*(difficulty*1.2-1),0.25,0.1,3+(difficulty*1.2),-0.08+(difficulty*0.01),rnd(30)+50-difficulty*5,30,1,10,0.4,3,3,8)
			create_circ_particules(center_cam.x+47,center_cam.y+98-difficulty*2,2*(difficulty*1.2-1),0.25,0.05,2+(difficulty*1.2),-0.08+(difficulty*0.01),100-difficulty*10,40,flr(rnd(1)+0.5),10,0.4,4,4,8)
 	end
 end 
end

function apply_upgrade_temp()

	p.atk_speed=0.5-upgrade_temp[1]/100
	p.pv=50+upgrade_temp[2]*14
	p.pv_max=50+upgrade_temp[2]*14
	p.roll_delay=200-4*upgrade_temp[3]
	p.damages=5+upgrade_temp[4]*0.08

	p.lvl_atk_speed=upgrade_temp[1]
	p.lvl_life_max=upgrade_temp[2]
	p.lvl_roll_delay=upgrade_temp[3]
	p.lvl_damages=upgrade_temp[4]
		
	upgrade_temp={
	p.lvl_atk_speed,
	p.lvl_life_max,
	p.lvl_roll_delay,
	p.lvl_damages,
	}
end


function draw_menu_upgrade()
 if	menu_upgrade==true and timer_after_menu>=200 then
 	
 	rectfill(center_cam.x,center_cam.y,center_cam.x+128,center_cam.y+128,7)
 
	 for e in all(listing_options_menu_upgrade) do
			local color_menu=9
			if (e[4]==choice_option) color_menu=11
			print(e[1],center_cam.x+e[2],center_cam.y+e[3],color_menu)
		end
	
		local x_pos={center_cam.x+59,center_cam.x+113,center_cam.x+59,center_cam.x+7}
		local y_pos={center_cam.y+15,center_cam.y+38,center_cam.y+61,center_cam.y+38}
		local attributes={p.lvl_atk_speed, p.lvl_life_max, p.lvl_roll_delay,p.lvl_damages}		
		for i=1,4 do
		  local col_pos_up=8+flr((upgrade_temp[i]+attributes[i])*0.1)
		  print(upgrade_temp[i],x_pos[i], y_pos[i],col_pos_up)
		end	
	
		if timer_press_button_o>1 then
			rectfill(center_cam.x+30,center_cam.y+112,center_cam.x+98,center_cam.y+113,9)
			rectfill(center_cam.x+30,center_cam.y+112,center_cam.x+30+timer_press_button_o,center_cam.y+113,11)
			rectfill(center_cam.x+97,center_cam.y+112,center_cam.x+132,center_cam.y+113,7)
		end
		
		character_and_fire(center_cam.x+35,center_cam.y+96)
 	draw_circ_particules()

	end
end


--menu end

function draw_menu_end()
	cls(7)
	elements_to_print_end={"bravo !","good game","score",p.xp_max,"time",flr(timer_gbl/3600).." min "..flr(timer_gbl/60)%60}
	camera(0,0)
	palette_change=0
	for i=1,6 do
		if i*50+300<settings_boss.timer_end then 
			print(elements_to_print_end[i],46,32+i*12+i%2*3,10-i%2)
		end
	end
	sspr(77,22,16,15,56,18)
end




--interface

function interface_game()
	
	local animation_interface_haut=0
	if (menu_start==true) animation_interface_haut=timer_after_menu
	print("♥",center_cam.x+6,center_cam.y+6-animation_interface_haut,3)	
	rectfill(center_cam.x+13,center_cam.y+6-animation_interface_haut,center_cam.x+15+ceil(p.pv_max/8),center_cam.y+10-animation_interface_haut,10)
	if (p.pv>0) rectfill(center_cam.x+14,center_cam.y+7-animation_interface_haut,center_cam.x+14+ceil(p.pv/8),center_cam.y+9-animation_interface_haut,3)

	print("◆",center_cam.x+6,center_cam.y+14-animation_interface_haut,12)	
	print(p.xp,center_cam.x+14,center_cam.y+14-animation_interface_haut,12)	

	local indicator_c=12
	if (p.cold<4000 and timer_gbl%20>10) indicator_c=3

	print("⧗",center_cam.x+6,center_cam.y+22-animation_interface_haut,indicator_c)	
	rectfill(center_cam.x+13,center_cam.y+24-animation_interface_haut,center_cam.x+13+ceil(p.cold/1000),center_cam.y+24-animation_interface_haut,indicator_c)
	
	text_to_print_local="…"..ceil(p.atk_speed*100).."  ♥"..ceil(p.pv_max).."  ✽"..ceil(p.roll_delay).."  🐱"..ceil(p.damages)
	print(text_to_print_local,center_cam.x+73-#text_to_print_local*3,center_cam.y+120+animation_interface_haut,8)
	
end


--game over

function draw_game_over()
	if p.timer_death>250 then
		sspr(53,21,23,15,center_cam.x+40,center_cam.y+38+animation_start-p.timer_death/30,46,30)
	end
end

-->8
--tools

--optimisation de table

function split_table(a)
	local t_one=split(a,":",false)
	for k, v in pairs(t_one) do
		t_one[k]=split(v)
	end
	return t_one
end

--inclure key+value dans table

function combine_keys_values(keys, values)
 local combined={}
 for i=1,#keys do
  combined[keys[i]] = values[i]
 end
 return combined
end

--distance entre deux objets

function between_two_objets(a,b)
 return (((b.x+b.l/2)-(a.x+a.l/2))^2+((b.y+b.h/2)-(a.y+a.h/2))^2)^0.5
end

--change palette

listing_palette_settings=split_table("14,3,129,136,137,143,15,7,6,13,1,129,12,140,133,5:14,3,13,136,137,9,15,6,6,13,1,129,12,140,133,5:7,7,7,7,7,7,129,7,129,7,7,7,7,7,7,7:14,3,129,136,137,143,15,6,13,13,1,129,12,140,133,5")

function update_palette()
	if palette_change<=0 then
		palette_change=0
	end
	for i=1,16 do
		pal(i-1,listing_palette_settings[palette_change+1][i],1)
	end
	palette_change-=10
end

--check player ciblage

function checking_angle(a,tolerance)
	angle_precision=atan2((p.y+p.h/2)-(a.y+a.h/2),(p.x+p.l/2)-(a.x+a.l/2))+0.25
	if (angle_precision>1) angle_precision-=1
	
	angle_precision=abs(abs(cursor_angle-1)-angle_precision)
	angle_comparaison=false
	if angle_precision>0.5-tolerance and angle_precision<0.5+tolerance then
		angle_comparaison=true
	end
end

--spawn around screen

spawn_random_screen={0,0}

function spawn_around_screen()
	local direction_side_screen=ceil(rnd(4))
	local side_listing=split("-94,0,0,-94,94,0,0,94")
	for s in all(side_listing) do
		if (s==0) s=rnd(128)
	end
	spawn_random_screen[1]=side_listing[direction_side_screen*2-1]+p.x
	spawn_random_screen[2]=side_listing[direction_side_screen*2]+p.y
end

--circle particules

circ_particules={}
keys_circ_par=split("x,y,l,h,angle,size,size_grow,time_life,time_fade,time_between,speed,col1,col2,col3,col,timer")

function create_circ_particules(x,y,range,angle,angle_range,size,size_grow,time_life,time_fade,number,time_between,speed,col1,col2,col3)
	for i=1,number do
		local values_circ_par={
		x+(rnd(range)-rnd(range)),
		y+(rnd(range)-rnd(range)),
		1,
		1,
		angle+(rnd(angle_range)-rnd(angle_range)),
		size,
		size_grow,
		time_life,
		time_fade,
		time_between*i,
		speed,
		col1,
		col2,
		col3,
		0,
		0,
		}
		add(circ_particules,combine_keys_values(keys_circ_par,values_circ_par))
	end
end


function update_circ_particules()
	for c in all(circ_particules) do
		--
		if (between_two_objets(p,c)>180) del(circ_particules,c)
		--
		c.timer+=1
		if c.timer+c.time_between<c.time_life*0.5 then
			c.col=c.col1
		elseif c.timer+c.time_between<c.time_life*0.75 then
			c.col=c.col2
		else
			c.col=c.col3
		end
		if c.timer>=c.time_between then
			c.size+=c.size_grow
			c.x+=cos(c.angle)*c.speed
			c.y+=sin(c.angle)*c.speed
			if (c.timer>=c.time_life) del(circ_particules,c)
		end
	end
end

function draw_circ_particules()
	for c in all(circ_particules) do
		if (c.timer+c.time_between>c.time_life-c.time_fade) fillp(░)
		if (c.timer>=c.time_between) circfill(c.x,c.y,c.size,c.col)
		fillp()
	end
end

--angle

function angle_to(a,b)
 return atan2((b.y+b.h/2)-(a.y+a.h/2),(b.x+b.l/2)-(a.x+a.l/2))+0.25
end

--collision with distance

function collision(a,b,distance)
	return not (a.x-distance>b.x+b.l 
	or a.y-distance>b.y+b.h 
	or a.x+a.l<b.x-distance
	or a.y+a.h<b.y-distance)
end	

--shadows

function draw_shadows(a,x,y,l,h,bool_rect)
	fillp(▒)
	if bool_rect==nil then
		circfill(a.x+a.l/2+shadow_x+x,a.y+a.h/2+shadow_y+y,a.l*0.5+l,8)
	else
		rectfill(a.x+shadow_x+x,a.y+shadow_y+y,a.x+a.l+shadow_x+l,a.y+a.h+shadow_y+h,8)
	end	
	fillp()
end

--tremor

function activate_tremor(pwr,timing)
	tremor_intensity+=pwr
	tremor_timing=timing*0.01 --de 1 a 100
end

function update_tremor()
	tremor_x=rnd(tremor_intensity)-(tremor_intensity/2)
	tremor_y=rnd(tremor_intensity)-(tremor_intensity/2)
	tremor_intensity*=tremor_timing
	if (tremor_intensity<.2) tremor_intensity=0
end

--flash

function draw_flash_screen()
	if flash_screen==true then
		rectfill(center_cam.x-10,center_cam.y-10,center_cam.x+140,center_cam.y+140,8)
		if (timer_gbl%5==1) flash_screen=false
	end
end

--particule effect

keys_particules_pix=split("x,y,life,col1,col2,dir_x,dir_y")

function particule(x,y,number,range,life,col1,col2,dir_x,dir_y,limit_x,limit_y)
	if (limit_x==nil) limit_x=range
	if (limit_y==nil) limit_y=range
	for i=1,number do
		local values_particules_pix={
			x+rnd(limit_x)/2,
			y+rnd(limit_y)/2,
			life,
			col1,
			col2,
			dir_x,
			dir_y,
			}
		add(particules_pix,combine_keys_values(keys_particules_pix,values_particules_pix))
	end
end

function update_particule()
	for par in all(particules_pix) do
		par.x+=par.dir_x
		par.y+=par.dir_y
		par.life-=1
		if (par.life<10) par.col1=par.col2
		if (par.life<1) del(particules_pix,par)
	end
end

function draw_particule()
	for par in all(particules_pix) do
		pset(par.x,par.y,par.col1)
	end
end


--animate

function animate(animation_name,s)
	anime=animation_name[flr((timer_gbl%(#animation_name*s))/(s))+1]
end

--press button

function press_button()
	if btn(🅾️) then 
		timer_press_button_o+=1
	else
		timer_press_button_o=0
	end
	if btn(❎) then 
		timer_press_button_x+=1
	else
		timer_press_button_x=0
	end
end

__gfx__
0cdd000cdd000cdd00fffe0000000008800800000000900088000088008888888088888880088888800080000000800087077077777777777777777777777777
c66dd0c66dd0c66dd0099900008980809099809990000000880000880888aaa89088aaa988088888888080000000880000000777077770777777777777777777
c65dd0c56dd0c65dd0ff000000889099088899090000000098088089088a00099089000a99089a89988080000000800000700000077707777777777777777777
099ada099ada09adda09900000990000090900900090000099089099089000899099000999099099a89080000000808080007007000777777777777777777777
999a9a999a9a099aaa00000000880008000800000000000089099089099888998098999980098099099080000000880000000000000070707777077777777777
0aaaa00aaaa09aaa90000000089880980089099009009000990990990999999990999999900990aa099080000000800800000000000070777777777777777777
0b0b0000bb0000b0b000000009809089008009990009000099998999098aaaa99099aaa990099000089080000000800000000000070000077077777777777777
0cdd000cdd000cdd0000000000900090009900009000000099999999099000099099000899099000099080000000800000070000000070000777777777777777
cdddd0cdddd0cdddd00cdd00000000000000000000000000aa999999099000099099000a99099000099080000000800000000000000000000007777777777777
cdddd0cdddd0cdddd0ccddd00cd00000000000000000000000aaaaaa0aa0000aa0aa0000aa0aa0000aa080000000800000000000000000007077707777777777
0dddaa0dddda0adddac55dd0ccdd000cda000cda000cda0000000000000000000000000000000000000080000000800000000000000007000000070770777777
9adaaa9adaaa0addaa0aaadaccdddaccddd0ccddd0ccddd088888888088000088008888880088000088080000000800000000000007000007000007707777777
0aaaa00aaaa09aaaa0939a3ac5c9adccddaaccddaaccddaa98999988088800089088888888088000088080000000800000000000000000000000000777777777
0b0b0000bb0000b0b0b9a39039a390cd3ba3c33ba3333b3399989aaa0998800990888aaa89089088089080000000800000000000000000000007000700770777
000d0000b000000c00000000000000000000000000000000a9999900099990099089a00099099089099080000000800000000000000000000000700000777777
0dddd00daab0009dc00cdd000cdd000cdd000ccd000000000aa99990099998098099000098098099099080000000800000000000000000000000000700777777
dddddddddaaaa9966dccddd0ccddd0c66dd0c65dd0000000000aa999099a99999099000099099099098080000000800000000000000000000700000000070777
ccaddbddaa9a9aa6ddc55dd0c56dd0c65dd0c65aaa000000000098990890a9999098000999099989999080000000800000000000000000000000000000007007
c6aaaaddaa99baaddd0aaada0aaada099adaa99aaa00000099999999099009999099999999099999999080000000800000000000000000000000070000007707
099ab00d66c00addd0aaaaaaa9aa9a999a9a99aa900000009999999909900a9990a999999a0aa999999080000000800000000000000000000000000007000777
00aa0000cc0000ba00b9ab90baaba0baaaa090abb0000000aaaaaaaa0aa000aaa00aaaaaa0000aaaaaa088888888800000000000000000000000000000000077
02220222220222000000200000000000020000000000020000000999990999990999900999990000000000000000000000000000000000000000000000070070
022200222000200000022000000000008200000000000720000009aaaa09aaa909993909aaaa0000006655440000000000000000000000000000000000000077
072200222002220000822000000000077220000000008220000009000009000909a9a90900000000054544454000000000000000000000000007000000000000
0222022222022200007722000000000228200000000027770000090999090009090a090993000666554444444665400000000000000000000000000000000007
0020000002000000002772000000008887720000000028820000090aa909999309000309aa000600064465443000400000000000000000000000000000070007
000000000000200000888220000000722227000000007727200009999909aaa90900030939330500064545543000500000000000000000000000000000000007
20000000000000000082227000000087777200000008882720000aaaaa0a000a0a000a0aaaaa0500054455443000400000000000000ccccccdd0000000000000
000000002000000000277720000000222272000000082722700000000000000000000000000000544545445430330000000000000cccccdccddd000000000000
00000000000000000777727000000072872700000002222770000099990900090999990999990000354444443300000000000000cccccccddccdd0000f000000
0000200000002000022282200000088822222000000288772000099aa909000909aaaa03aaa30000054444335000000000000000ccdcdddddddddd000f000000
000000000000000008877272000002227727700000022722700009a009090009090000090093000000543335000000000000000ccccddcccdddadd00ff000000
020000000020000008222227000007772272200000087777220009000909309909930009933a000000055350000000000000000ccdddddddddddad00ff000000
00000000000000000222777700000822888227000082722227000900990a993a09aa0003aa3000000000430000000000000000dcccd5ddddddddaad0ffe00000
000000000000000088882222000088887222720000272887720009999a00a3a00333390900a300000000540000000000000000ddcd556dddcddddad0efe00000
20000000000020007722222770007777822772700028822777000aaaa0000a000aaaaa0a000a00000006543000000000000000cdd55666dd55ddddd0ef000000
020000000000000022777722200022227772272000822272220000000000000000000000000000000065433300000000000000cdd556666dd5ddaaddee000000
000020000000000027222777200022882277722000878777272000000000000000000000022222222222222222222222222220cdd566666dd2dddaddee000000
000000000000000888882222700888772222277008882722772000000000000000000000222222222222222222222222222222ccd5566665d22addadee200000
000000002200000827772222270222227777722708222227227200000000000000000000222222222222222222222222222222ccdd566522dd2222ddee220000
000000000000000222222772220777222277222202727877777200000000000000000000222222777772222777277722722222dcd225522add222fedee220000
000000000000002227722227722222772222777788888222777720000000000000000000222227727277222722272722722222ddd2222daaad222ee2ee220000
000000000000000022222722220002222272222022277772222270000000000000000000222227772777222727272722722222dd2222daaa2ee652e22e220000
0000088000000088000000030000000003000030000000300000030000000000000000002222277272772227272727222222220d222daaaaae5555222e220000
0000080000000008000000000300000033030003030000000000000000000000000000002222227777722222772777227222220de22faaa2a2655522ae220000
00088000000000000800000033000030330030333003003030300030000000000000000022222222222222222222222222222265fe2eeaaa26665522ae220000
00000000000000000880000033300003333003333000003300000300000000000000000022222222222222222222222222222255ee2efea22666522aae220000
08800000000000000088003033330303333033333300033330003300000300000000000002222222222222222222222222222055555999996665522a2a220000
0080000000000000800000033333033334330333430033333303033300003000003000000000000000000000000000000000005555999999d66522aaaa220000
008000bb0bbb0bb0000800033433333343330334330033343000333000003400000030000000000000000000000000000000000999666d9d9d02a222a2220000
8880008bb8bbbb800000800334430334343333443333343430033430000333000003000000000000000000000000000000000099999666d9dd22aa2222220000
08008088bbb8b8000000880044430034443003343300334430034433003334300303000000000000000000000000000000000099ddd6622dd2aaa22e22220000
0800000bbbbbbb00800080003430000343000044300003440000344000034300003430000000000000000000000000000000009d22222aa222aa2a2ee2220000
000000bb88800bb000000003333303330003000e0e00000000fefeeeee000000be0999f9f9fb0bbb0bbff000000000000000000dd222aaaa22aaa22fef220000
08000000000000000088000433340434000300fffb000bbf00f899fe9ebbb0bb9efffaafffbbbbbbbbbbbf0800000000000000000222aaaa2aaaaaaeee200000
08800000000000000800000043400434000300eeeeb0bbbe00e9fffefbe9bbfbfbfeeffeeebbfebbbeebeb00000000000000000002a22aaa22aaa2afe2200000
00880000000000088800000004000040000400efeb0bebefb0efff9efbeffb9efbfeeeeefebafeeeeefeba0800000000000000000d52aa55a2a2aaaae2200000
00000888880008080000000000000000000000eeeb0beeeb0beff79bfbeff79bfbb7fefefebab7fefefeba0000000000000000000552566522aaa2a2e2888800
00000000080888000000000000000000000000eb7bbbeb7bbbee7bb7ebee7bb7ebbb7bfb7baabb7bfb7baa08080808080808000aada2aaae2aaaaa2a22888880
0000b0000b0000000000000000000000b0000b00000000b0000b0000000000000000000000b0000b0000000000000000000000aaae2eeee22ad2222222888888
00b00bbb00bb000000bbbb0b000000b00bbb00bb0000b00bbb00bb000000bbbb0b000000b00bbb00bb000000bbbb0b00000000aaae2aaaee222da22228888880
000bbbbbbbb3b000bbbbbbb0bb00000bbbbbbbb3b0000bbbbbbbb3b000bbbbbbb0bb00000bbbbbbbb3b000bbbbbbb0bb000000a2222aaaaae8a2222888888800
00bbbbbbbbbbbb000bbbbbbbb3b000bbbbbbbbbbbbb0bbbbbbbbbbbb000bbbbbbbb3b000bbbbbbbbbbbb000bbbbbbbb3b0000000000bbbbbbbbbb00000000000
0bbbbbbbbb00b000bbbbbbbb0bbb0bbbbbbbbb00b00bbbbbbbbb00b000bbbbbbbb0bbb0bbbbbbbbb00b000bbbbbbbb0bbb00000bbbbbbbbaaaaaaaaa0b000000
b0bbbbbbbbb0000bbbbbbbbbb0b0b0bbbbbbbbb00000bbbb0bbbb0000bbbbbbbbbb0b0b00bbb0b0bb0000bb0bbbbbbb0b00000bbbbbbaaaaaaaaaaaaabbbbbb0
00b0bbbb0bb000b0bb0b0bbb000000bb0b0bbbb0000bbbbb0bb0bbb000bbbb0bbb000000b0bb00bb0bb00000bb0bb000000000b00bbaaaeaabaaaaaabbbbbbbb
00b0b00b0b0000000bb000bb0000000b0b00b0b000bb0bb000b000b0000bb00bb00000bbbb000000bb0000000bbb000000000000baaaaeebbbbbbeeaaab88bbb
00b0b00b0b00000000b00bb0000000b00b00b00b00b000bb000b000000000bbb0000000b0000000000000000000b00000000000aaaaeeebbbbbbbbbeeaaaa880
00bb0b0bb0b000000bbb0bbb000000bb0b00bb0b00b00000000b00000000000000000000000000000000000000000000000000beeebbbb88bbbbbbbbbeeaaba0
00b00000b000b00000b000b000000000b0000b0000000bb0000000000bb0000000000bb00bb000000000000000000000000000bbbbb88bbb88e888bbbbbebbb8
00b00000b000b00000b000b00000b000b0000b00000bbbbbb0000000bbbbb00000b0bbbbbb0b00000000000000000000000000bbb8bbbb888888b8888bbbbb88
000b000b00000b000b0000bb000bb000bb0bb000000b3bbb0bb000bbb3bbb0000b00b3bbbb0b00000000000000000000000000b00bb08888b88888ee888b8880
000bb0bb00000bb0bb00000b000b00000bbb0000000bbbbbb00b0b00bbbbbb000b00bbbbb00b0000bbb000000000000000000000000000008888888888888000
0000bbb0000000bbb0000000bb0b00000bbb00000000bbbbb000bb00bbbb00b000bb0bbbb000000bbbbb00000000000000000000000000000000000000000000
00003bb00000003bb00000003bb0000003bb0000000bbb00bb0000b0bb0b00b00000bb0bbb0000bb3bbbb0000000000000000000bbbbbbbbbbbbbbbbbbbbbbb0
0000b3b0000000b3b0000000b3b000000b3b000000b00b00b000000bb00b0b000000bb0b0b0000bbbbbb0b00000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb
0000bbb0000000bbb000000bbbb00000bbbbb0000b000b00b000000bb00b0b0000000b0b000000b0bbb00b0000000bbb0bb0000bbb777b777b777b777b7b7bbb
000bbbbb00000bbbbb0000bbbbbb000bbbbbbb000b000b00b000000b000b0000000000b0000000b00bb00b00000bbbbbbbb0000bbb7b7b7bbbb7bb7b7b7b7bbb
00bbbbbb0000bbbbbb000bbbbbbb000bbbbbbb0000b00b00b000000b000b000000000bb000000b000bb00b0000bbbbbbbbb0000bbb77bb77bbb7bb77bb777bbb
00bbbbbbb000bbbbbbb0bbbbbbbbb00bbbbbbbb000000b00b000000b000b000000000b0b00000b000bb00b000bbb3bbbb0b0000bbb7b7b7bbbb7bb7b7bbb7bbb
00bb3bbbb00bbb3bbbb03bbb33bbb000bb3bbbb00000b000b0000000b00b000000000b0b00000b00b0b00b000b0bbbbbb00b000bbb7b7b777bb7bb7b7b777bbb
0bb0b0b3bb0b30b03bb033bb0b3bb000bbb0b3bb0000b0000b000000b0b0000000000b0b00000b00b0b00b0000b0b0bb000b000bbbbbbbbbbbbbbbbbbbbbbbbb
0b3bb0b0bb030b00b3000bb000bb00000bbbb0bb0000b0000b000000b0b000000000b000b0000000b0000b0000b0b0b0000b0000bbbbbbbbbbbbbbbbbbbbbbb0
0033b0bb30000b00bb0000b000bb000000bbbb300000b0000b000000b0b000000000b000b0000000b0000b0000b00bb0000b0000000000000000000000000000
0000b0b0000000b0b00000b0000b000000bb0000000b0000b00000000b0b0000000b000b000000000b0000b000b000bbb000b000000000000000000000000000
0000b0b0000000b00b0000b0000b000000b0b000000000b00000b0000000000b0000b0000000000b0000b0000000000000000000000000000000000000000000
0000b0b00000000b0b00000b0000b00000b00b000000bb00bbbbb000000000b0000bb000000000b000bbb000000000b000000000000000000000000000000000
0000b0b0000000000b0000000000b0000b000000000b3bbbb00000000000bb00bbb000000000bb00bb00000000000b000bbb0000000000000000000000000000
0000000000000000000000000000000b0000b00000bbbbbb00000000000b3bbbb0000000000b3bbbb00000000000bb0bb00000000000b00000b0000000000000
00bbb0000bbb0000bbb000033300000b000b003000b000b000000000b0bbbbbb00000000b0bbbbbb00000000000bbbb000000000b00b000bbb00000000000000
0bb3bb00bb3bb00bb3bb00333b300000b0bb000000000bb0000000bb00b000b0000000bb00b000b000000000b0b3bb00000000bb00bbbbb00000000000000000
bbbbbb0bbbbbb0bbbbbb03b3b3300000bbb0033000000bb0000bbbbb00000bb0000bbbbb00000bb0000000bb00bb00b0000bbbbb00bbb0000000000bb0000000
3bbb3bb3bbb3bbbbbb3bb33bb3b300003bb000bb0000bb000bbbbbb00000bb000bbbbbb000000bb0000bbbbb00b0bbb00bbbbbb00b3bbb00000bbbb000000000
bbbbb3bbbbbb3bbbbbb3b33b3b330000b3b3bbb3000bb00bbbbbbbb0000bb00bbbbbbbb00000bb000bbbbbb0000bbb0bbbbbbbb00b0bbb00bbbbbb0000000000
0bbbbb00bbbbb00bbbbb003333300000bb33bb3000bbbbbbbbbbbb0000bbbbbbbbbbbbb0000bb00bbbbbbbb000bbbbbbbbbbbb0000bbb00bbbbbbb0000000000
0b0b0b00b0b0b00b0b0b00333030000b0bbb330300bbbbbb00bbbb0000bbbbbb00bbbb0000bbbbbbbbbbbb00000bbbbb0000b0000bbbbbbbbbbbb00000000000
0b0b0b00b0b0b00b0b0b003030300000bbb3bb0300bbbbb0000b0b0000bbbbb0000b0b0000bbbbbb00b0bb000000b0b0000b000000bbbbbb0bbb000000000000
0b0b0b00b0b0b00b0b0b00b03033000bbb3b3b0000b00b00000b0b0000b00b000000bb0000bbbbb000b00b0000000bb0000bb0000b0bbbbbbbbb000000000000
0b0b0b00b0b0b00b0b0b00b3b0b0000b0bbbbbb000b00b00000b00b000b00b000000b000000bb00000b0b000000000bb0bbb00000b0bbb00b00bb0b000000000
0b0b0b00b0b0b0b00bbb030033300000bbb0bbb000b00b00000b00b0000b00b00000b000000b000000b0b000000000bb000000000bbb0000bb00bb0000000000
0b0bb000bb0b0bb0b0b0b30b0b0b00000b00bb0000b00b00000b00b0000b00b0000b0b0000bb00000b000b0000000000b000000000bb0b000bb00b0000000000
b0b0bb000b00bbb0b000b303330300000bb00b000b000b000000b0b0000b00b0000b0b000b00b0000b000b00000000000bb00000000bb000000bb00000000000
0000000000000000000000000000000000bb0b000b0000b00000b0b00000b0b0000b00b00b00b0000b0000b00000000000000000000000000000000000000000
000000000000000000000000000000000bb0bb000b0000b0000b0b000000bb0000b00b000b000b00b0000b000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffff00000000000eeeee0000000000
0033300cb0003330cb000033300cb00033300cb00cb33300000000000000000000000000000000000000000000000000fbbfe8f000000000ebabebe000000000
0333330bcb033333bcb00333330bcb0333330bcb0bcb333000000000000000000000000000000000000000000000000feebbfe9f00000000eabaebe000000000
03bb330bdb03bb33bdb003bb330bdb03bb330bdb0bdbbb300000000000000000000000000000000000000000000000faaaeebfe9f0000000eabaebe000000000
03bb330bb003bb33bb0003bb330bb003bb330bb00bbbb330000000000000000000000000000fefaabebabe0000000feb98beebbaab000000ebabebe0000ee000
033b333b00033b33b000033b333b00033b333b000b33b33300000000000000000000000000fbbbebbbebbbe00000fbee99beeabfeef00000ebbbebe0000ee000
0bbbbb3b000bbbbbb00003bbbb3b0003bbbb3b000bbbb3bb0000000000000000000000000fbaaabebbbebbbe000fbeeb99bbeaebfeef0000fffffeeffeeee000
bbbbbbbb00bbbbbbbb000bbbbbbb000bbbb3bb00bbbbbbb30000000003330000000000000fa999aeabbebbbb00feebeffffbebebbfeef0feeeeeeeeeeeeeeee0
0bbbb3bbb00bbbb3bb00bbbbb3bb000bbbb3bb00bbbbbb33000000003333000b00000000fe99899eebbbebbbe0aaaaaaaabbbaabbbffffeebbbbbeeeebbbbbee
b0bbb33bb0b0bbb33b000bbbb33b00b0bbb3bb00b0bb3333000000003bb330cd00000000ee98999eeabbebbbe0abbbbbbbbbbbbbbbbbbfebbbbbbfebbbbbbbee
b0bb3330b0b0bb333bb0b0bb333b00b0bb33bb000bbb3330000000000bb330bd0000000eafaaaaaeaebbbebbbefbebebebebbebebebeffeb9989beebb9989bfe
b0033330b0b003333bb0b003333b000003333b000b0333300000000000b330b00000000eaeafeeaebaebbebbbe0aebfeebeeaeebbbeb0eeb9899beebb9899bfe
b0b03b30b000b03b30b0b0b03b3b0000b0bb3b000b0b3b30000000000bbb30b00000000eafeeeeeeeeeeeeeeee0aeeeeeeeeaeb989ee0eeb9999bfebb8998bee
00b03bb0b000b03bb0b000b0bbb0b000b0bb0b000b0b3bb000000000bbbb3bb000000000feababbfeba9999be00bfeeffefebeb899eb0efb99aaaeeab9989aef
0bb00bb0b00bb00bb0b00bb0bb00b0000bbb0b000b0bbbb000000000b0bb30bb04330000eeaabbbbeea9989be00afeaabbeebeb998ee0feb9aaaaeebaa99abef
0bb00bb0b00bb00bb0b000bbbb00b000bbb00b000b0bbbb0000000000b0bb00b466330b0aeabbbbbfea9899ae00bfa9899bfaeb989be0eeaabbaaeabbbaabbee
0bb00bb0b00bbb0bb0b000bbb000b000bbb000b00b0b0bb000000000bb0bb0b036533bc0afaabbbbfba8999be00bfb899bbfbee999be9eeabbbbaeebbbbbbbef
0bb00b00b000bb0b00b000bb0000b0000b0b00b00b0b0b0000000000bb0bb0b00bbf3bc0afababbbeaa9999ae00bebaababeaee99fbb9feebbbbeeeeeeeeeeee
00b00b0b00000b0b0b00000bb000b0000b0bb0b00b0b0b00000000000b0b00b0fffbfb00eeabbbbbfeefefefb00bfbaafbbebeef7ffbffeabbbbbeebbebbebee
00b00b0b00000bb00b00000b0b00b000b000b0b00b0b0b00000000000b0b00b00bbbbb0b7eaaabbbe7beeeeeffbb7baaaab7bbeeee7beebeb7bbebeeee7eeebe
00b00b0b00000bb00b0000b00b00b000b000b0b00b0b0b0000000000030300b00b0b0b0be7a7babbee7be7b7efb7bbff7bbbb7be7b7bee7bbff7bbb7ebe7be7e
00900009000000090000999000099099000900009990090000900090090000000090000000000009000990900000000009000000909000090090000000909000
00000999999999900999999999000000000099999999000009000009999900009009999990999990090000000999990090099000000099999900000999000909
00999999999999999999999999999999999999999999999900009999999990090999999999999999000999999999999999999990099999999999999999999000
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777766677777766677766666666666766666666666777666666666777777777777777777777777777777777777777777
777777777777777777777777777777777777666777777666776666111116dd766611111d66677666666666666777777777777777777777777777777777777777
777777777777777777777777777777777777666777777666776666111116dd766611111d66677666666666666777777777777777777777777777777777777777
777777777777777777777777777777777777dd677666766d77666177777ddd766d777771ddd776dd166ddd666777777777777777777777777777777777777777
777777777777777777777777777777777777ddd776dd7ddd776dd777766ddd7ddd77777dddd77ddd7ddd116dd777777777777777777777777777777777777777
777777777777777777777777777777777777ddd776dd7ddd776dd777766ddd7ddd77777dddd77ddd7ddd116dd777777777777777777777777777777777777777
77777777777777777777777777777777777766d77ddd766d77ddd6666ddd667dd6dddddd66777d667ddd77ddd777777777777777777777777777777777777777
777777777777777777777777777777777777ddd77ddd7ddd77dddddddddddd7ddddddddddd777ddd711177ddd777777777777777777777777777777777777777
777777777777777777777777777777777777ddd77ddd7ddd77dddddddddddd7ddddddddddd777ddd711177ddd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddd66dddd77d66111111ddd7ddd11111ddd777ddd7777776dd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddddddddd77ddd777777ddd7ddd777776ddd77ddd777777ddd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddddddddd77ddd777777ddd7ddd777776ddd77ddd777777ddd777777777777777777777777777777777777777
777777777777777777777777777777777777111ddddddddd77ddd777777ddd7ddd777771ddd77ddd777777ddd777777777777777777777777777777777777777
77777777777777777777777777777777777777711111111177111777777111711177777711177111777777111777777777777777777777777777777777777777
77777777777777777777777777777777777777711111111177111777777111711177777711177111777777111777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777766666666666677666777777666777666666666777666777777666777777777777777777777777777777777777777
77777777777777777777777777777777777766666666666677666777777666777666666666777666777777666777777777777777777777777777777777777777
777777777777777777777777777777777777dd6dddddd666776666777776dd766666666666677666777777666777777777777777777777777777777777777777
777777777777777777777777777777777777ddddd6dd111177ddd666777ddd766666111166d776dd7666776dd777777777777777777777777777777777777777
777777777777777777777777777777777777ddddd6dd111177ddd666777ddd766666111166d776dd7666776dd777777777777777777777777777777777777777
77777777777777777777777777777777777711ddddddd77777dddddd777ddd766d117777ddd77ddd766d77ddd777777777777777777777777777777777777777
77777777777777777777777777777777777777111dddddd777dddddd677d667ddd777777dd677d667ddd77ddd777777777777777777777777777777777777777
77777777777777777777777777777777777777111dddddd777dddddd677d667ddd777777dd677d667ddd77ddd777777777777777777777777777777777777777
77777777777777777777777777777777777777777111dddd77ddd1dddddddd7ddd777777ddd77ddd7ddd77d66777777777777777777777777777777777777777
777777777777777777777777777777777777777777dd6ddd776dd711dddddd7dd677777dddd77dddd66dddddd777777777777777777777777777777777777777
777777777777777777777777777777777777777777dd6ddd776dd711dddddd7dd677777dddd77dddd66dddddd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddddddddd77ddd777dddddd7dddddddddddd77dddddddddddd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddddddddd77ddd7771ddddd711ddddddddd177111ddddddddd777777777777777777777777777777777777777
777777777777777777777777777777777777dddddddddddd77ddd7771ddddd711ddddddddd177111ddddddddd777777777777777777777777777777777777777
77777777777777777777777777777777777711111111111177111777711111777111111111777777111111111777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777767777777777777777777777777777ccccccss77777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777p7777777777777777777777777777cccccsccsss7777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777776777p777777777777777777777cccccccssccss777757777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777777777777777777777777ccscssssssssss77757777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777p77777777777777777777ccccsscccsss1ss77557777777777777777777777777777777777777777
777777777777777777777777777777777777777777p77767777777777777777777777ccsssssssssss1s77557777777777777777777777777777777777777777
77777777777777777777777777777777777777777777p77777777777777777777777scccsvssssssss11s755l777777777777777777777777777777777777777
77777777777777777777777777777777777777777777776777777777777777777777sscsvvfssscssss1s7l5l777777777777777777777777777777777777777
777777777777777777777777777777777777777777pp677777777777777777777777cssvvfffssvvsssss7l57777777777777777777777777777777777777777
77777777777777777777777777777777777777677pppp76777777777777777777777cssvvffffssvss11ssll7777777777777777777777777777777777777777
777777777777777777777777777777777777777767ppp77767776777777777777777cssvfffffsshsss1ssll7777777777777777777777777777777777777777
777777777777777777777777777777777777777777ppppo777677777777777777777ccsvvffffvshh1ss1sllh777777777777777777777777777777777777777
777777777777777777777777777777777777777767ppppp7o7777777777777777777ccssvffvhhsshhhhssllhh77777777777777777777777777777777777777
777777777777777777777777777777777777777777ppppp777o77777777777777777scshhvvhh1sshhh5lsllhh77777777777777777777777777777777777777
77777777777777777777777777777777777777776opppppoo7777777777777777777ssshhhhs111shhhllhllhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777oopppppoo7777777777777777777sshhhhs111hllfvhlhhlhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777oopppppooo7777777777777777777shhhs11111lvvvvhhhlhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777oopppppoooo777777777777777777slhh5111h1hfvvvhh1lhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777opppppppoo777777777777777777fv5lhll111hfffvvhh1lhh77777777777777777777777777777777777777
77777777777777777777777777777777777777777ppoooppo7o77777777777777777vvllhl5l1hhfffvhh11lhh77777777777777777777777777777777777777
77777777777777777777777777777777777777777oooooooo7777777777777777777vvvvvdddddfffvvhh1h1hh77777777777777777777777777777777777777
77777777777777777777777777777777777777777oooooooo7777777777777777777vvvvddddddsffvhh1111hh77777777777777777777777777777777777777
7777777777777777777777777777777777777777ooooooooo77777777777777777777dddfffsdsds7h1hhh1hhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777ooooooooo7777777777777777777dddddfffsdsshh11hhhhhh77777777777777777777777777777777777777
7777777777777777777777777777777777777777ooooooooo7777777777777777777ddsssffhhssh111hhlhhhh77777777777777777777777777777777777777
77777777777777777777777777777777777777777ooooooo77777777777777777777dshhhhh11hhh11h1hllhhh77777777777777777777777777777777777777
77777777777777777777777777777777777777hhhooooooo777777777777777777777sshhh1111hh111hh5l5hh77777777777777777777777777777777777777
7777777777777777777777777777777777hhhhhhhh1ooo111117h777777777777777777hhh1111h111111lllh777777777777777777777777777777777777777
777777777777777777777777777777777hhhhhh1111111111111hhhhhh7777777777777h1hh111hh111h15lhh777777777777777777777777777777777777777
777777777777777777777777777777777h77hh111l11h111111hhhhhhhh777777777777svh11vv1h1h1111lhh777777777777777777777777777777777777777
77777777777777777777777777777777777h1111llhhhhhhll111h66hhh777777777777vvhvffvhh111h1hlh6666777777777777777777777777777777777777
77777777777777777777777777777777771111lllhhhhhhhhhll1111667777777777711s1h111lh11111h1hh6666677777777777777777777777777777777777
777777777777777777777777777777777hlllhhhh66hhhhhhhhhll11h17777777777111lhllllhh1shhhhhhh6666667777777777777777777777777777777777
777777777777777777777777777777777hhhhh66hhh66l666hhhhhlhhh6777777777111lh111llhhhs1hhhh66666677777777777777777777777777777777777
777777777777777777777777777777777hhh6hhhh666666h6666hhhhh667777777771hhhh11111l61hhhh6666666777777777777777777777777777777777777
777777777777777777777777777777777h77hh76666h66666ll666h6667777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777776666666666666777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777767777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__sfx__
00020000276101c61014620106201362011620126201262013620146201761018610196101a6101961000600076002a6002960000600006000060000600006000060000600006000060000600006000060000600
000200001b610226101e620136200b620096200d620116201061012610136101461016610176101b6101d6101f610206102061000600006000060000600006000060000600006000060000600006000060000600
000200001e6101a610146200f6200b6200a6200a6200a6200b6200b6200c6100d6101061010610116101161012610126101361014610146101561000600006000060000600006000060000600006000060000600
d03600000461107611086110761106611046110361102611016110161103611066110661105611046110361104611066110861108611086110761105611036110161100611006110061100611026110461106611
a61200000061002620066300b64011650106300b62006620046200361002610016100061000610006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
071e00000352004530065400554004530045300654005540035300352004520055300550004500045000350003500055000650008500065000050000500065000550004500025000250003500055000850004500
07010000171501c1502215018140131201c14024150331502b15027150201501a1301713013130101200d1200c1200a1200912008110061100510003100011000010000100031000010000100001000010000100
4f0100002a6503265028650226501c65017650136500e650096500665003650026500065000650006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
870100002a2503225028250222501c25017250132500e250092500625003250022500025000250002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
920200000f7501c7502d750257501e75017750127500f7500c7500b75009750077500675005750047500375002750017500175000750017500075000750007500070000700007000070000700007000070000700
000100000000031000370003a000390003800036000330002e0002a000270001f0001000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 03424344

