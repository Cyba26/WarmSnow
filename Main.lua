pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--warm snow

--poke(0x5f2e,1)

--[[

faire fonction tempete de neige

systeme de detection de lennemi
avec bruit balles + si lennemi
regarde dans la direction du
joueur

tache de sang quand touche (p
ou enemy)

avoir une fonction qui recheck
les chunks uniquement quand
le joueur a passer une centaine
de pixel

modifier les chunks pour que
les objects apparaissent en 1er
afin d'avoir une fonction plus
elegente et pouvoir mettre un
objet partout, et ensuite que
les arbres ne puisse pas se 
mettre sur cet emplacement

les objects semblent spawn tout
seul

faire en sorte que les spawns
ont plus de chance dans la 
direction ou regarde le joueur

le menu upgrade change detat de
bouton exit quand plus assez 
d'xp (clignotte et quitte a 
nimporte quel appuie)

preciser le max possible pour
chaque categorie d'amelioration

40 niv par type d'amelioration

attention a la probabilite des
different objets, qui sont les
meme

changer de palette lors de
certains combats ? lors dun
changement detat dun monstre

les attaques de monstres
peuvent se jouer sur la pal

animation p mort

]]

function _init()
	--player
	spawn_p()
	p_moving=false
	cursor_target=0
	timer_attack_mode=0
	bullets={}
	upgrade_temp={0,0,0,0}
	
	cursor_angle=0.5
	cursor_x=10
	cursor_y=10
	diff_angle=cursor_target-cursor_angle
	
	spr_p_vertical=0
	spr_p_horizontal=false
	
	--camera
	listing_icons={{23,53,5,4,3},}
	locking_cam_active=false
	locking_cam_possible=false
	locking_cam_info={x=0,y=0,l=1,h=1}
	camera_mode=0
	locking_cam_id_target=0
	center_cam={x=0,y=-250,oldx=0,oldy=0,l=1,h=1}
	--older_center_cam_x=0
	--older_center_cam_y=0
	timer_display_icons_on_top={}
	
	--world
	chunk_player_x=0
	chunk_player_y=0
	trees={}
	--campfires={}
	--create_campfire(-40,-34)
	--add_object_to_chunk(0,0,1)
	timer_clouds=0
	cloud_x=0
	cloud_y=0
	chunks={}
	objects={}
	proba_new_object=400
	add_object_to_chunk(0,0,1,true)
	--add_object_to_chunk(10,10,2,true)
	amount_campfire=0
	no_enemy_nearby=false
	random_stuff_get=0
	
	world_lvl=0

	--enemies
	enemies={}
	
	--general
	timer_gbl=0
	music()
	angle_precision=0

	--tools
	shadow_x=-2
	shadow_y=0
	particules_pix={}
	footprint={}
	spawn_random_screen_x=0
	spawn_random_screen_y=0
	palette_change=0
	tremor_intensity=0
	tremor_timing=0
	tremor_x=0
	tremor_y=0
	timer_press_button_o=0
	timer_press_button_x=0
	
	--animes
	animation_1_to_3={1,2,3}
	animation_1_to_4={1,2,3,4}
	--animation_1_to_3_loop={1,2,3,2,1}
	animation_1_to_3_loop_stop={1,1,1,2,3,2}

	
	--wip
	--create_enemy(20,20,1,20)
	center={x=0,y=0,l=1,h=1}
	print_display=0
	
	--menu
	listing_options_menu_start={
	{"⬆️ normal",-189,1},
	{"➡️ hard",-177,2},
	{"⬇️ insane",-165,3},
	}

	listing_options_menu_upgrade={
	{"fire damage",40,22,1},
	{"life max",78,38,2},
	{"roll delay",44,54,3},
	{"accuracy",18,38,4},
	
	{"⬆️",60,30,1},
	{"➡️",67,38,2},
	{"⬇️",60,46,3},
	{"⬅️",53,38,4},

	
	{"press and hold 🅾️",30,117,5}
	}
	
	--proba_by_objects={2,10,30,100}
	proba_by_objects={25,50,75,100}
	
	spr_sac_version={38,50,66}

	difficulty=0
	display_menu=true
	menu_start=true
	timer_after_menu=1001
	menu_upgrade=false

end

function _update60()
	
	--reinitialisation
	update_palette()
 amount_campfire=0
 --no_enemy_nearby=true
	--menu_upgrade_ready=false

	
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
	
	--camera
	mvmt_camera()
	curseur_ready()
	change_camera_mode()
	update_locking_cam()
	
	--enemies
	update_enemies()
	
	--general
	timer_gbl+=1
	
	--tools
	update_circ_particules()
	update_particule()
	update_tremor()
	press_button()
	
	--neige
	--particule(p.x-64,p.y-64,1,0,300,6,6,0.01,0.1,250,1)
	
	--menu
	update_menu_start()
	update_menu_timer()
	update_menu_upgrade()
	
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
 draw_footprint()
 draw_p()
 draw_bullets()
 
 --world up p
 draw_trees_up()
	
	--camera up
	draw_vignetage()
	
	--wip
	draw_cursor()
	--print(print_display,p.x,p.y-50,12)
	--print("chunks "..#chunks,p.x,p.y-30,12)
	print(amount_campfire,p.x,p.y-20,12)
	print(center_cam.x,p.x,p.y-10,12)
	--rect(e.x,e.y,e.x+13,e.y+10,2)
	--rect(p.x,p.y,p.x+p.l,p.y+p.h,2)

	--menu
	draw_menu_start()
	draw_menu_upgrade()
 draw_icon_on_top()
 draw_icon_on_top_temp()

	--interface
	interface_game()

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
	
	if (p.off>0) p.off-=1
	p.x+=add_mvmt_x
	p.y+=add_mvmt_y
	add_mvmt_x*=0.9
	add_mvmt_y*=0.9
	
	if btnp(🅾️) then	
		if (p.cooldown_roulade<=0) p.t_roulade=13
	end

	if	btnp(❎) then
		
		if player_attack_mode==true then
			shoot_p()
		end
		active_player_attack_mode(200)

		if locking_cam_possible==true then 
			locking_cam_active=true
			active_player_attack_mode(30000)
			sfx(6)
		end
		--open_menu_upgrade()
		
		for o in all(objects)	do	
			if menu_upgrade_ready==true and no_enemy_nearby==false and o.typ==1 and ceil(center_cam.x)==ceil(p.x-64) then
				open_menu_upgrade()
			end
		end	
		
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
	p={
	lvl_pv_max=1,
	lvl_cooldown_roulade_max=1,
	lvl_dmg=1,
	lvl_precision_max=1,
		
	pv_max=100,
	cooldown_roulade_max=200,
	dmg=1,
	precision_max=10,
	
	x=64,
	y=64,
	l=6,
	h=7,
	v=0.5,
	pv=100,
	xp=0,
	xp_max=0,
	off=0,
	t_roulade=0,
	cooldown_roulade=0,
	v_normal=0,
	hurt_time=0,
	precision=1,
	--lvl_accuracy=1,
	--lvl_attack_speed=1,
	}
	
	add_mvmt_x=0
	add_mvmt_y=0
end


------

--shoot

function create_bullet(x,y,dx,dy,v,dmg)
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
	})
end

function update_bullets()
	for b in all(bullets) do
		b.x+=b.dx*b.v
		b.y+=b.dy*b.v
		b.time_life-=1
		if (b.time_life<=0) del(bullets,b)
	end
end

function life_dommage_bullets(someone)
	for b in all(bullets) do
		if collision(b,someone,1) then
 		for i=1,5 do
 			particule(b.x,b.y,2,2,15,8,9,rnd(1)-0.5,rnd(1)-0.5)
			end
			someone.hurt_time=4
			del(bullets,b)
			sfx(7)
			someone.pv-=b.dmg
		end
	end
end

function draw_bullets()
	for b in all(bullets) do
		pset(b.x,b.y,10)
	end
end

function shoot_p()
	local angle_shoot_precision=cursor_angle+(rnd((p.precision*0.05*(distance_between_lock_and_p*0.033))*0.2))-(p.precision*0.05*(distance_between_lock_and_p*0.033))/8
	local dx_shoot=cos(angle_shoot_precision)
	local dy_shoot=sin(angle_shoot_precision)
	create_bullet(p.x+p.l/2,p.y+p.h/2,dx_shoot,dy_shoot,2,p.dmg)
 sfx(6)
 --activate_tremor(3,70)
 for i=1,5 do
 	particule(p.x+3+dx_shoot*5,p.y+3+dy_shoot*5,2,2,15,5,6,rnd(1)-0.5,rnd(1)-0.5)
	end
end


--precision shoot

function update_precision_p()
	p.precision-=0.1
	if (p_moving==true) p.precision+=0.22
	if (p.t_roulade>0) p.precision+=1

	if (p.precision>p.precision_max) p.precision=p.precision_max
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


--direction

function buttons_direction()
	if (btn(⬆️) and p.off==0) add_mvmt_y=-p.v
	if (btn(⬇️) and p.off==0) add_mvmt_y=p.v
	if (btn(⬅️) and p.off==0) add_mvmt_x=-p.v
	if (btn(➡️) and p.off==0) add_mvmt_x=p.v
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
		--p.off=2
		if (p.t_roulade<1) p.v=0.5
		p.cooldown_roulade=p.cooldown_roulade_max
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
	if btn(⬆️) or btn(⬇️) or btn(⬅️) or btn(➡️) then
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
	else
	 p.hurt_time=0
	end
end

-- experience

function add_xp(xp)
	p.xp+=xp
	p.xp_max+=xp
end

--[[
function buy_upgrade(a)
	if (a==1) then
		p.lvl_pv+=1
	elseif (a==2) then
		p.lvl_roulade+=1
	elseif (a==3) then
		p.lvl_accuracy+=1
	elseif (a==4) then
		p.lvl_damage+=1
	end
end
]]
-->8
--world

--chunks


function generate_map()
	listing_chunks_to_create={}

	chunk_player_x=flr((p.x-64)/100+0.5)*100
	chunk_player_y=flr((p.y-64)/100+0.5)*100

	if chunk_player_x~=p.x or chunk_player_y~=p.y then
		for i=-1,1 do
		--c'est le premier qui fait bug
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
	--position_obj_local={x=0,y=0}
	trees_generate={}
	
	typ_o=0
	pos_o_x=0
	pos_o_y=0
	coor_local_chunk={x=x,y=y}
	
	object_generate()
	trees_to_generate()
	generate_chunk()
end


function object_generate()
	local rnd_proba_generate=ceil(rnd(proba_new_object))
	
	if rnd_proba_generate<=proba_by_objects[1] then
		typ_o=1
		proba_new_object+=150
	elseif rnd_proba_generate<=proba_by_objects[2] then
		typ_o=2
		proba_new_object+=100
	elseif rnd_proba_generate<=proba_by_objects[3] then
		typ_o=3
		proba_new_object+=50
	elseif rnd_proba_generate<=proba_by_objects[4] then
		typ_o=4
		proba_new_object+=10
	end
	
	if (proba_new_object>500) proba_new_object=500
	
	proba_new_object-=1
	
	if typ_o~=0 then
		pos_o_x=ceil(rnd(80)+10)+coor_local_chunk.x
		pos_o_y=ceil(rnd(80)+10)+coor_local_chunk.y
	end
	
	add_object_to_chunk(pos_o_x,pos_o_y,typ_o)
	
	--temp
	--proba_new_object=60
	--
end


function add_object_to_chunk(x,y,typ,menu)
	if menu==true then
		x=p.x-13
		y=p.y-10
	elseif typ==3 then
		x=10
		y=10
	else
		x=x
		y=y
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

	if typ_o>=1 or typ_o<=4 then
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

--[[
function generate_chunk_start()
	add(chunks,{
		active=false,
		x=0,
		y=0,
		l=100,
		h=100,
		object={45,50,1},
		--trees=trees_generate,
	})
end
]]


function chunks_active_listing()
	chunks_active={}
	for c in all(chunks) do
		if between_two_objets(p,c)<180 then
			add(chunks_active,c)
		else
			if (c.object.typ==1)	amount_campfire-=1
			del(chunks,c)
		end
	end
end


---




--[[
function generate_map()
	chunk_player_x=flr(p.x/100+0.5)*100-64
	chunk_player_y=flr(p.y/100+0.5)*100-64
	for i=-1,1 do
		for j=-1,1 do
			check_chunks_if_exist(chunk_player_x+i*100,chunk_player_y+j*100)
			chunks_active_listing()
		end
	end
end
]]


--[[
function add_new_chunks(chunk_x,chunk_y)
	
	local object_already_here=false
	local object_coor_local={x=0,y=0,h=20,l=20}
	for o in all(objects) do
		if o.in_chunk_x==chunk_x and o.in_chunk_y==chunk_y then
			object_already_here=true
			object_coor_local.x=o.x
			object_coor_local.y=o.y
		end
	end
	
	if object_already_here==false then
		--proba_new_object-=1
	local typ_of_chunks=ceil(rnd(proba_new_object))
		
		if typ_of_chunks<=proba_by_objects[1] then
			typ_of_object_that_spawn=1
			proba_new_object+=150
			object_already_here=true
		elseif typ_of_chunks<=proba_by_objects[2] then
			typ_of_object_that_spawn=2
			proba_new_object+=100
		elseif typ_of_chunks<=proba_by_objects[3] then
			typ_of_object_that_spawn=3
			proba_new_object+=50
		elseif typ_of_chunks<=proba_by_objects[4] then
			typ_of_object_that_spawn=4
			proba_new_object+=10
		end
			if (typ_of_chunks<=proba_by_objects[4]) add_object_to_chunk(chunk_x,chunk_y,typ_of_object_that_spawn)
			if (proba_new_object>500) proba_new_object=500
			print_display=proba_new_object
	end

	local zone_x_spawn_tree=100
	if (object_already_here==true) zone_x_spawn_tree=80
	local nbr_of_trees=(ceil(rnd(10))+6)
	
	trees_generate={}
	for i=1,nbr_of_trees do
		local coor_for_tree={x=ceil(rnd(zone_x_spawn_tree)),y=ceil(rnd(100)),l=1,h=1}
		local check_collision_tree_objects=false
		
		if between_two_objets(coor_for_tree,object_coor_local)>50 then
			if check_collision_tree_objects==false then
				add(trees_generate,{
					x=coor_for_tree.x+chunk_x,
					y=coor_for_tree.y+chunk_y,
					l=13,
					h=3,
					typ_side=ceil(rnd(3)),
					typ_bot=ceil(rnd(3)),
					typ_floor=ceil(rnd(10)),
				})
			end
		end
	end
	
	add(chunks,{
		active=false,
		x=chunk_x,
		y=chunk_y,
		l=100,
		h=100,
		typ=typ_of_chunks,
		object=object_to_spawn,
		trees=trees_generate,
	})
	
end
]]










--objects


function update_objects()
	--print_display=#objects
	for o in all(objects) do
		if (between_two_objets(o,p)>180) del(objects,o)
		if o.typ==1 then
	 	update_campfires(o)
	 	amount_campfire+=1
	 	if (amount_campfire>1) del(objects,o)
	 elseif o.typ==2 then
	 	update_buildings(o)
	 elseif o.typ==3 then
	 	update_lakes(o)
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
			draw_lakes(o)
		elseif o.typ==4 then
			draw_bags(o)
 	end
 end
end

--buildings

function update_buildings(o)
	
end


function draw_buildings(o)
	sspr(48,104,20,21,o.x,o.y-30)
end


--lakes

function update_lakes(o)

end


function draw_lakes(o)
	rectfill(o.x,o.y,80,80,8)
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
		create_icon_on_top_temp(o.x-2,o.y,"+1…acc",300)
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
			--print_display=between_two_objets(p,o)
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
	elseif o.typ==10 then
--animate(animation_1_to_4,50)
		anime=animation_1_to_4[flr(((o.timer_obj*-1)%(#animation_1_to_4*25))/(25))+1]
 	sspr(50+anime*7-7,43,7,10,o.x,o.y+6)
	end	
--pset(o.x,o.y,1)
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
	for c in all(chunks_active) do
		for t in all(c.trees) do
   sspr(14+(t.typ_side*13-13),21,13,22,t.x-4,t.y-23)
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
		cloud_x=spawn_random_screen_x
		cloud_y=spawn_random_screen_y
		timer_clouds=ceil(rnd(400)+200)
		create_circ_particules(cloud_x,cloud_y,16,0.23,0,rnd(3)+8,0,1500,1500,rnd(4)+4,30,0.1,8,8,8)
	end

end



--footprint

--[[requis
init
footprint={}

update
update_footprint(a,life_time)

draw
draw_footprint()

sprites
3 types de traces en 93,0 ici

]]

function update_footprint(a,life_time)
	if timer_gbl%10==1 then
		add(footprint,{
			x=a.x+a.l/2,
			y=a.y+a.h,
			life_time=life_time,
			typ=ceil(rnd(3)),
			timer=0,
		})
	end
end

function draw_footprint()
	for f in all(footprint) do
		f.timer+=1
		sspr(93,f.typ*2-2,2,4,f.x,f.y)
		if (f.timer>f.life_time) del(footprint,f)
	end
end






-->8
--camera and effects

--vignetage

function draw_vignetage()
	fillp(😐)
	for i=1,10 do
		circ(center_cam.x+64,center_cam.y+64,76-i*(2^(i*0.12)),7)
	end
	sspr(97,0,31,26,center_cam.x+97,center_cam.y)
	sspr(97,0,31,26,center_cam.x,center_cam.y,32,32,true)
	sspr(97,0,31,26,center_cam.x,center_cam.y+96,32,32,true,true)
	sspr(97,0,31,26,center_cam.x+97,center_cam.y+96,32,32,false,true)
	fillp()
end


function mvmt_camera()
	
	local older_cam_x=0
	local older_cam_y=0
	
	if camera_mode==0 then
		older_cam_x=p.x-64
		older_cam_y=p.y-64
	elseif camera_mode==1 then
		older_cam_x=(p.x+locking_cam_info.x)/2-64+center_cam.oldx*0.8
		older_cam_y=(p.y+locking_cam_info.y)/2-64+center_cam.oldy*0.8
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
		checking_angle(e,0.15)
		if (collision(p,e,40)) and angle_comparaison==true and locking_cam_active==false then
			if (timer_gbl%100==1) sfx(5)			
		 e.icon=1
		 locking_cam(e)			
		else
			e.icon=0
		end
	end
end

function change_camera_mode()
	if locking_cam_active==true then
		camera_mode=1
		--palette_change=1
	else
		camera_mode=0
	end
end

function locking_cam(x)
	locking_cam_id_target=x.id
	locking_cam_possible=true
end

function update_locking_cam()
	distance_between_lock_and_p=between_two_objets(p,locking_cam_info)
	for e in all(enemies) do
		if e.id==locking_cam_id_target then
			locking_cam_info.x=e.x+e.l/2
			locking_cam_info.y=e.y+e.h/2
			between_two_objets(p,e)
			if (not collision(e,p,90)) locking_cam_active=false
		end
	end
end

function draw_locking_cam()
	if locking_cam_active==true then	
		animate(animation_1_to_3,100)
		local precision_circ_dyn=(p.precision-1)*3*(distance_between_lock_and_p*0.023)
		if (precision_circ_dyn>18) fillp(░)
		--fillp(0b1111110111111111.1)
		--circ(locking_cam_info.x,locking_cam_info.y,7+anime,8)
		circ(locking_cam_info.x,locking_cam_info.y,precision_circ_dyn,8)
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
	if (display_menu==false) then
		spawn_around_screen()
		spawn_auto_enemies(spawn_random_screen_x,spawn_random_screen_y)	
		for e in all(enemies) do
	 	life_dommage_bullets(e)
	 	check_hurt_enemy(e)
	 	check_life_enemies(e)
	 	update_touch_enemies(e)
	 	update_footprint(e,300)
			check_distance_player(enemies,e)
			if (e.typ==1) change_state_enemies(e)
		end
	end
end

function draw_enemies()
	for e in all(enemies) do
		draw_shadows(e,3,7,3,5,true)
		if e.typ==1 and e.hurt_time==0 then
			local spr_direction=false
			if (e.dx<0) spr_direction=true
			if e.state==1 then
				sspr(0,59,13,10,e.x,e.y,13,10,spr_direction)
			elseif e.state==2 then
				animate(animation_1_to_3,10)
				sspr(0+anime*14-14,59,13,10,e.x,e.y,13,10,spr_direction)
			elseif e.state==3 then
				animate(animation_1_to_4,10)
				sspr(42+anime*14-14,59,13,10,e.x,e.y)
			end
		end
	end
end


-----------

--creation

function spawn_auto_enemies(x,y)
	if timer_gbl%400==1 then
		create_enemy(x,y,1,20,100)
	end
end

function check_hurt_enemy(e)
	if e.hurt_time>0 then
		e.hurt_time-=1
	end
end

function create_enemy(x,y,typ,pv,xp)
	add(enemies,{
		x=x,
		y=y,
		l=13,
		h=6,
		dx=0,
		dy=0,
		typ=typ,
		pv=pv,
		state=1,
		xp=xp,
		timer_activity=0,
		timer_move=0,
		icon=0,
		id=rnd(300),
		hurt_time=0,
		p_distance=0,
	})
end


--states

function change_state_enemies(e)
	
	--e.timer_activity+=1
	
	if e.state==1 then
		if (e.timer_activity>rnd(300)+300) then
			e.state=2	
			e.timer_activity=0
		end
	elseif e.state==2 then
		enemy_move_rnd(e)
	elseif e.state==3 then
		attack_e1(e)
	end
	
	if between_two_objets(p,e)<70 then
		e.state=3
	end
	if between_two_objets(p,e)>120 then 
		e.state=2
	end
end

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


--attack by enemy

function update_touch_enemies(e)
	if collision(e,p,-5) then
		hurt_player(10)
	end
end

function attack_e1(e)
	e.timer_activity+=1
	if e.timer_activity<rnd(100)+100 then
		typ_mvmt_enemy_around_p(e,10)
	elseif p.hurt_time>0 and between_two_objets(p,e)<90 then
		typ_mvmt_enemy_dir_p(e,false,1.2)
	elseif e.timer_activity<301 then
		typ_mvmt_enemy_dir_p(e,true,1)
	elseif e.timer_activity>300 then
		e.timer_activity=0
	end
end

function typ_mvmt_enemy_around_p(e,s)
	if between_two_objets(p,e)>30 then
		e.x+=sin(angle_to(p,e))
		e.y+=cos(angle_to(p,e))
	end
	if between_two_objets(p,e)<40 then
		e.x+=cos(angle_to(p,e))*0.6
		e.y+=sin(angle_to(p,e))*0.6
	end
	if between_two_objets(p,e)>50 then
	 e.x-=cos(angle_to(p,e))*0.5
		e.y+=sin(angle_to(p,e))*0.5
	end
end

function typ_mvmt_enemy_dir_p(e,towards_p,s)
	local typ_of_direction_towards_p=1
	local towards_p_angle=angle_to(e,p)
	if (towards_p~=true) typ_of_direction_towards_p=-1
	e.dx=cos(towards_p_angle)*s*typ_of_direction_towards_p
	e.dy=-sin(towards_p_angle)*s*typ_of_direction_towards_p	
	e.x+=e.dx
	e.y+=e.dy
end

function charge_enemy()
	e.x+=e.dx
	e.y+=e.dy
end


--life

function check_life_enemies(e)
	if (e.pv<=0) then
		if (e.id==locking_cam_id_target) locking_cam_active=false
		particule(e.x,e.y,40,0,60,10,9,0,rnd(0.1)-0.2,e.l*2,e.h*3)
  create_circ_particules(e.x+e.l/2,e.y+e.h/2,8,0.25,0.1,4,0.07,70,20,6,1,0.05,9,8,8)
		activate_tremor(20,90)
		add_xp(100)
		create_icon_on_top_temp(e.x,e.y,"+100◆",200)
		del(enemies,e)
	end
end



--check distance gbl

function check_distance_player(parent,enfant)
	enfant.p_distance=between_two_objets(p,enfant)	
	if not collision(p,enfant,200) then
		del(parent,enfant)
	end
end
-->8
--menu and interface


--

function update_menu_timer()
	if (timer_after_menu>=1 and timer_after_menu<=1000) timer_after_menu-=1
	if timer_after_menu==2 then
		turn_off_fire()
		proba_new_object=100
		world_lvl+=1
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
		if (btn(❎)) and difficulty>0 and timer_after_menu>=200 then
			timer_after_menu=200
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
	 sspr(102,27,26,35,x+35,y-26)
	else
	 sspr(102,27,26,35,x+35,y-25,26,34)
	end
	sspr(102,62,26,12,x,y)
end

function draw_menu_start()
	if menu_start==true then
		character_and_fire(33,-208)
		
		--options
		for e in all(listing_options_menu_start) do
			local color_menu=9
			if (e[3]==difficulty) color_menu=11
			print (e[1],44,e[2],color_menu)
		end

	 if difficulty>0 then
	 rectfill(44,-153,82,-143,11)
	 rectfill(43,-152,83,-144,11)
	 else
	 rectfill(44,-153,82,-143,9)
	 rectfill(43,-152,83,-144,9)
	 end
	 print ("❎ start",48,-150,7)
	 
		draw_circ_particules()
	 
	 if timer_after_menu>=200 then
			center_cam.x=0
			center_cam.y-=64
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
	--add_xp(100)
end

function update_menu_upgrade()
 if	menu_upgrade==true and timer_after_menu>=200 then
		
		--upgrade_temp={p.lvl_pv_max,p.lvl_cooldown_roulade_max,p.lvl_dmg,p.precision_max}

 	--palette_change=1
 	if (btn(⬆️) and upgrade_temp[1]+p.lvl_pv_max<=40) choice_option=1
 	if (btn(➡️) and upgrade_temp[2]+p.lvl_cooldown_roulade_max<=40) choice_option=2
 	if (btn(⬇️) and upgrade_temp[3]+p.lvl_dmg<=40) choice_option=3
 	if (btn(⬅️) and upgrade_temp[4]+p.lvl_precision_max<=40) choice_option=4
 	if (btn(🅾️)) choice_option=5
 	if (btnp(❎)) and choice_option>0 and choice_option<5 then
 	 if upgrade_temp[choice_option]*50<p.xp then
 	 	upgrade_temp[choice_option]+=1
 			p.xp-=upgrade_temp[choice_option]*50
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

	p.pv+=(upgrade_temp[1]-p.lvl_pv_max)*5
	p.pv_max+=(upgrade_temp[1]-p.lvl_pv_max)*5
	p.cooldown_roulade_max-=(upgrade_temp[2]-p.lvl_cooldown_roulade_max)*5
	p.dmg+=(upgrade_temp[3]-p.lvl_dmg)*0.1
	p.precision_max-=(upgrade_temp[4]-p.lvl_precision_max)*0.25

	p.lvl_pv_max+=upgrade_temp[1]
	p.lvl_cooldown_roulade_max+=upgrade_temp[2]
	p.lvl_dmg+=upgrade_temp[3]
	p.lvl_precision_max+=upgrade_temp[4]
		
	if (p.precision_max<=1) p.precision_max=1
	upgrade_temp={p.lvl_pv_max,p.lvl_cooldown_roulade_max,p.lvl_dmg,p.precision_max}
end


function draw_menu_upgrade()
 if	menu_upgrade==true and timer_after_menu>=200 then
 	
 	rectfill(center_cam.x,center_cam.y,center_cam.x+128,center_cam.y+128,7)
 
	 for e in all(listing_options_menu_upgrade) do
			local color_menu=9
			if (e[4]==choice_option) color_menu=11
			print(e[1],center_cam.x+e[2],center_cam.y+e[3],color_menu)
		end
		
		print(upgrade_temp[1],center_cam.x+61,center_cam.y+15,8+flr((upgrade_temp[1]+p.lvl_pv_max)*0.1))
		print(upgrade_temp[2],center_cam.x+113,center_cam.y+38,8+flr((upgrade_temp[2]+p.lvl_cooldown_roulade_max)*0.1))
		print(upgrade_temp[3],center_cam.x+61,center_cam.y+61,8+flr((upgrade_temp[3]+p.lvl_dmg)*0.1))
		print(upgrade_temp[4],center_cam.x+7,center_cam.y+38,8+flr((upgrade_temp[4]+p.lvl_precision_max)*0.1))
	
		if timer_press_button_o>1 then
			rectfill(center_cam.x+30,center_cam.y+112,center_cam.x+98,center_cam.y+113,9)
			rectfill(center_cam.x+30,center_cam.y+112,center_cam.x+30+timer_press_button_o,center_cam.y+113,11)
			rectfill(center_cam.x+97,center_cam.y+112,center_cam.x+132,center_cam.y+113,7)
		end
		
		character_and_fire(center_cam.x+35,center_cam.y+96)
 	draw_circ_particules()

	end
end


--interface

function interface_game()
	local animation_interface_haut=0
	if (menu_start==true) animation_interface_haut=timer_after_menu
	print("♥",center_cam.x+6,center_cam.y+6-animation_interface_haut,3)	
	rectfill(center_cam.x+13,center_cam.y+6-animation_interface_haut,center_cam.x+7+ceil(p.pv_max/4),center_cam.y+10-animation_interface_haut,10)
	rectfill(center_cam.x+14,center_cam.y+7-animation_interface_haut,center_cam.x+6+ceil(p.pv/4),center_cam.y+9-animation_interface_haut,3)

	print("◆",center_cam.x+6,center_cam.y+14-animation_interface_haut,12)	
	print(p.xp,center_cam.x+14,center_cam.y+14-animation_interface_haut,12)	
end

-->8
--tools

--optimisation visuel
--if t.x-70<p.x and p.x<t.x+70 and t.y-70<p.y and p.y<t.y+70 then


--distance entre deux objets

--[[requis
function
donner une valeur a une variable
en lui appliquant la fonction

]]


function between_two_objets(a,b)
 return (((b.x+b.l/2)-(a.x+a.l/2))^2+((b.y+b.h/2)-(a.y+a.h/2))^2)^0.5
end


--change palette

--[[requis
init
palette_change=0

update
update_palette()

function
palette_change+=1

]]

function update_palette()
	if palette_change<=0 then
		palette_change=0
		pal({[0]=14,3,129,136,137,143,15,7,6,13,1,129,12,140,133,5},1)
	elseif palette_change==1 then
		pal({[0]=14,3,13,136,137,9,15,6,6,13,1,129,12,140,133,5},1)
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
function spawn_around_screen()
	local direction_side_screen=ceil(rnd(4))
	if	direction_side_screen==1 then
		spawn_random_screen_x=-94+p.x
		spawn_random_screen_y=rnd(128)+p.y
	elseif direction_side_screen==2 then
		spawn_random_screen_x=rnd(128)+p.x
		spawn_random_screen_y=-94+p.y
	elseif direction_side_screen==3 then
		spawn_random_screen_x=94+p.x
		spawn_random_screen_y=rnd(128)+p.y
	else
		spawn_random_screen_x=rnd(128)+p.x
		spawn_random_screen_y=94+p.y
	end	
end


--circle particules

circ_particules={}

function create_circ_particules(x,y,range,angle,angle_range,size,size_grow,time_life,time_fade,number,time_between,speed,col1,col2,col3)

	for i=1,number do
		add(circ_particules,{
			x=x+(rnd(range)-rnd(range)),
			y=y+(rnd(range)-rnd(range)),
			l=1,
			h=1,
			angle=angle+(rnd(angle_range)-rnd(angle_range)),
			size=size,
			size_grow=size_grow,
			time_life=time_life,
			time_fade=time_fade,
			time_between=time_between*i,
			speed=speed,
			col1=col1,
			col2=col2,
			col3=col3,
			col=0,
			timer=0,
		})
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

--[[requis
shadow_x=1
shadow_y=4
draw
draw_shadows()
]]

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

--[[requis
init
tremor_intensity=0
tremor_timing=0

update
update_tremor()

in function
activate_tremor
]]

function activate_tremor(pwr,timing)
	tremor_intensity+=pwr
	tremor_timing=timing*0.01 --de 1 a 100
end

function update_tremor()
	tremor_x=rnd(tremor_intensity)-(tremor_intensity/2)
	tremor_y=rnd(tremor_intensity)-(tremor_intensity/2)
	--camera(center_cam_x,center_cam_y)
	--camera(tremor_x,tremor_y)
	tremor_intensity*=tremor_timing
	if (tremor_intensity<.2) tremor_intensity=0
end



--particule effect

--[[requis
init
particules_pix={}

update
update_particule()

draw
draw_particule()

in function
particule(x,y,number,range,life,col1,col2,dir_x,dir_y,limit_x,limit_y)
]]

function particule(x,y,number,range,life,col1,col2,dir_x,dir_y,limit_x,limit_y)
	if (limit_x==nil) limit_x=range
	if (limit_y==nil) limit_y=range
	for i=1,number do
		add (particules_pix,{
			x=x+rnd(limit_x)/2,
			y=y+rnd(limit_y)/2,
			life=life,
			col1=col1,
			col2=col2,
			dir_x=dir_x,
			dir_y=dir_y,
		})
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

--[[requis
1.creer des tables avec les 
numeros de sprites voulu lors
du lancement

2.mettre "anime" en multiplicateur
de la position x ou y dans la
fiche sprite

init
timer_gbl={}
toutes les "animations" dispo
ex: anime_a={1,2,3}

]]


function animate(animation_name,s)
	anime=animation_name[flr((timer_gbl%(#animation_name*s))/(s))+1]
end


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
0cdd000cdd000cdd00fffe0000000000000000000000000000000000000000000000000000000000000000000000000087077077777777777777777777777777
c66dd0c66dd0c66dd009990000000000000000000000000000000000000000000000000000000000000000000000080000000777077770777777777777777777
c65dd0c56dd0c65dd0ff000000000000000000000000000000000000000000000000000000000000000000000000000000700000077707777777777777777777
099ada099ada09adda09900000000000000000000000000000000000000000000000000000000000000000000000008080007007000777777777777777777777
999a9a999a9a099aaa00000000000000000000000000000000000000000000000000000000000000000000000000080000000000000070707777077777777777
0aaaa00aaaa09aaa9000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000070777777777777777777
0b0b0000bb0000b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000077077777777777777
0cdd000cdd000cdd0000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000070000777777777777777
cdddd0cdddd0cdddd00cdd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777777777
cdddd0cdddd0cdddd0ccddd00cd00000000000000000000000000000000000000000000000000000000000000000000000000000000000007077707777777777
0dddaa0dddda0adddac55dd0ccdd000cda0000000000000000000000000000000000000000000000000000000000000000000000000007000000070770777777
9adaaa9adaaa0addaa0aa7daccdddaccddd000000000000000000000000000000000000000000000000000000000000000000000007000007000007707777777
0aaaa00aaaa09aaaa0373a3ac5c7adccddaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777
0b0b0000bb0000b0b0b9a39039a390c73b7300000000000000000000000000000000000000000000000000000000000000000000000000000007000700770777
000d0000b000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000777777
0dddd00daab0009dc00cdd000cdd000cdd000ccd0000000000000000000000000000000000000000000000000000000000000000000000000000000700777777
dddddddddaaaa9966dccddd0ccddd0c66dd0c65dd000000000000000000000000000000000000000000000000000000000000000000000000700000000070777
ccaddbddaa9a9aa6ddc55dd0c56dd0c65dd0c65aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000007007
c6aaaaddaa99baaddd0aaada0aaada099adaa99aaa00000000000000000000000000000000000000000000000000000000000000000000000000070000007707
099ab00d66c00addd0aaaaaaa9aa9a999a9a99aa9000000000000000000000000000000000000000000000000000000000000000000000000000000007000777
00aa0000cc0000ba00b9ab90baaba0baaaa090abb000000000000000000000000000000000000000000000000000000000000000000000000000000000000077
02220222220222000000200000000000020000000000020000000000000000000000000000000000000000000000000000000000000000000000000000070070
02220022200020000002200000000000820000000000072000000000000000000000000000000000000000000000000000000000000000000000000000000077
07220022200222000082200000000007722000000000822000000000000000000000000000000000000000000000000000000000000000000007000000000000
02220222220222000077220000000002282000000000277700000000000000000000000000000000000000000000000000000000000000000000000000000007
0020000002000000002772000000008887720000000028820000000000bbbb000000000000000000000000000000000000000000000000000000000000070007
000000000000200000888220000000722227000000007727200000000bbbb3b00000000000000000000000000000000000000000000000000000000000000007
2000000000000000008222700000008777720000000888272000000000b0bbbb0000000000000000000000000000000000000000000ccccccdd0000000000000
0000000020000000002777200000002222720000000827227000000000000bbbb0000000000000000000000000000000000000000cccccdccddd000000000000
000000000000000007777270000000728727000000022227700000000bb0b0bb0000000000000000000000000000000000000000cccccccddccdd0000f000000
0000200000002000022282200000088822222000000288772000000000bbbbbbbb00000000000000000000000000000000000000ccdcdddddddddd000f000000
00000000000000000887727200000222772770000002272270000000000000bbb00000000000000000000000000000000000000ccccddcccdddadd00ff000000
0200000000200000082222270000077722722000000877772200000000000bbbbb0000000000000000000000000000000000000ccdddddddddddad00ff000000
0000000000000000022277770000082288822700008272222700000000000bbb00b00000000000000000000000000000000000dcccd5ddddddddaad0ffe00000
0000000000000000888822220000888872227200002728877200000000000bbbb0bb0000000000000000000000000000000000ddcd556dddcddddad0efe00000
20000000000020007722222770007777822772700028822777000000000bbbbbb0bb0000000000000000000000000000000000cdd55666dd55ddddd0ef000000
02000000000000002277772220002222777227200082227222000000000b00bbbb0bb000000000000000000000000000000000cdd556666dd5ddaaddee000000
0000200000000000272227772000228822777220008787772720000000b0bbbbb0b0b000000000000000000000000000000000cdd566666dd2dddaddee000000
000000000000000888882222700888772222277008882722772000000b0bbbbbb00bb000000000000000000000000000000000ccd5566665d22addadee200000
000000002200000827772222270222227777722708222227227200000bbbbbbb0bb0b000000000000000000000000000000000ccdd566522dd2222ddee220000
000000000000000222222772220777222277222202727877777200000b0bbb0bbbb00b00000000000000000000000000000000dcd225522add222fedee220000
000000000000002227722227722222772222777788888222777720000b0b0000bb0b0b00000000000000000000000000000000ddd2222daaad222ee2ee220000
000000000000000022222722220002222272222022277772222270000000000000000000000000000000000000000000000000dd2222daaa2ee652e22e220000
0000088000000088000000030000000003000030000000300000030000000000000000000000000000000000808080808080800d222daaaaae5555222e220000
0000080000000008000000000300000033030003030000000000000000000000000000000000000000000008000000000000000de22faaa2a2655522ae220000
00088000000000000800000033000030330030333003003030300030000000000000000000000000000000000000000000000065fe2eeaaa26665522ae220000
00000000000000000880000033300003333003333000003300000300000000000000000000000000000000080000000000000055ee2efea22666522aae220000
08800000000000000088003033330303333033333300033330003300000300000000000000000000000000000000000000000055555999996665522a2a220000
0080000000000000800000033333033334330333430033333303033300003000003000000000000000000008000000000000005555999999d66522aaaa220000
008000bb0bbb0bb0000800033433333343330334330033343000333000003400000030000000000000000000000000000000000999666d9d9d02a222a2220000
8880008bb8bbbb800000800334430334343333443333343430033430000333000003000000000000000000080000000000000099999666d9dd22aa2222220000
08008088bbb8b8000000880044430034443003343300334430034433003334300303000000000000000000000000000000000099ddd6622dd2aaa22e22220000
0800000bbbbbbb00800080003430000343000044300003440000344000034300003430000000000000000008000000000000009d22222aa222aa2a2ee2220000
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
00b0b00b0b00000000b00bb0000000b00b00b00b00b000bb000bb00000000bbb0000000b0000000000000000000b00000000000aaaaeeebbbbbbbbbeeaaaa880
00bb0b0bb0b000000bbb0bbb000000bb0b00bb0b00000bb0000000000bb0000000000bb00bb000000000000000000000000000beeebbbb88bbbbbbbbbeeaaba0
00b00000b000b00000b000b000000000b0000b00800bbbbbb0000000bbbbb00000b0bbbbbb0b00000000000000000000000000bbbbb88bbb88e888bbbbbebbb8
00b00000b000b00000b000b00000b000b0000b00000b3bbb0bb000bbb3bbb0000b00b3bbbb0b00000000000000000000000000bbb8bbbb888888b8888bbbbb88
000b000b00000b000b0000bb000bb000bb0bb000800bbbbbb00b0b00bbbbbb000b00bbbbb00b0000bbb0000000000000000000b00bb08888b88888ee888b8880
000bb0bb00000bb0bb00000b000b00000bbb00000000bbbbb000bb00bbbb00b000bb0bbbb000000bbbbb00000000000000000000000000008888888888888000
0000bbb0000000bbb0000000bb0b00000bbb0000800bbb00bb0000b0bb0b00b00000bb0bbb0000bb3bbbb0000000000000000080000000000000000000000000
00003bb00000003bb00000003bb0000003bb000000b00b00b000000bb00b0b000000bb0b0b0000bbbbbb0b000000000000000000000000000000000000000000
0000b3b0000000b3b0000000b3b000000b3b00008b000b00b000000bb00b0b0000000b0b000000b0bbb00b0000000bbb0bb00080000000000000000000000000
0000bbb0000000bbb000000bbbb00000bbbbb0000b000b00b000000b000b0000000000b0000000b00bb00b00000bbbbbbbb00000000000000000000000000000
000bbbbb00000bbbbb0000bbbbbb000bbbbbbb0080b00b00b000000b000b000000000bb000000b000bb00b0000bbbbbbbbb00080000000000000000000000000
00bbbbbb0000bbbbbb000bbbbbbb000bbbbbbb0000000b00b000000b000b000000000b0b00000b000bb00b000bbb3bbbb0b00000000000000000000000000000
00bbbbbbb000bbbbbbb0bbbbbbbbb00bbbbbbbb08000b000b0000000b00b000000000b0b00000b00b0b00b000b0bbbbbb00b0080000000000000000000000000
00bb3bbbb00bbb3bbbb03bbb33bbb000bb3bbbb00000b0000b000000b0b0000000000b0b00000b00b0b00b0000b0b0bb000b0000000000000000000000000000
0bb0b0b3bb0b30b03bb033bb0b3bb000bbb0b3bb8000b0000b000000b0b000000000b000b0000000b0000b0000b0b0b0000b0080000000000000000000000000
0b3bb0b0bb030b00b3000bb000bb00000bbbb0bb0000b0000b000000b0b000000000b000b0000000b0000b0000b00bb0000b0000000000000000000000000000
0033b0bb30000b00bb0000b000bb000000bbbb30800b0000b00000000b0b0000000b000b000000000b0000b000b000bbb000b080808080808080808080808080
0000b0b0000000b0b00000b0000b000000bb00000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b0b0000000b00b0000b0000b000000b0b000800000b00000b0000000000b0000b0000000000b0000b0000000000000000000000000000000000000000000
0000b0b00000000b0b00000b0000b00000b00b000000bb00bbbbb000000000b0000bb000000000b000bbb000000000b000000000000000000000000000000000
0000b0b0000000000b0000000000b0000b000000800b3bbbb00000000000bb00bbb000000000bb00bb00000000000b000bbb0000000000000000000000000000
0000000000000000000000000000000b0000b00000bbbbbb00000000000b3bbbb0000000000b3bbbb00000000000bb0bb00000000000b00000b0000000000000
00bbb0000bbb00003bb000033300000b000b003080b000b000000000b0bbbbbb00000000b0bbbbbb00000000000bbbb000000000b00b000bbb00000000000000
0bb3bb00bb3bb003b3b300333b300000b0bb000000000bb0000000bb00b000b0000000bb00b000b000000000b0b3bb00000000bb00bbbbb00000000000000000
bbbbbb0bbbbbb033bbbb03b3b3300000bbb0033080000bb0000bbbbb00000bb0000bbbbb00000bb0000000bb00bb00b0000bbbbb00bbb0000000000bb0000000
3bbb3bb3bbb3bb3bbb3bb33bb3b300003bb000bb0000bb000bbbbbb00000bb000bbbbbb000000bb0000bbbbb00b0bbb00bbbbbb00b3bbb00000bbbb000000000
bbbbb3bbbbbb3b33bbb3b33b3b330000b3b3bbb3800bb00bbbbbbbb0000bb00bbbbbbbb00000bb000bbbbbb0000bbb0bbbbbbbb00b0bbb00bbbbbb0000000000
0bbbbb00bbbbb0033bbb003333300000bb33bb3000bbbbbbbbbbbb0000bbbbbbbbbbbbb0000bb00bbbbbbbb000bbbbbbbbbbbb0000bbb00bbbbbbb0000000000
0b0b0b00b0b0b0030b0300333030000b0bbb330380bbbbbb00bbbb0000bbbbbb00bbbb0000bbbbbbbbbbbb00000bbbbb00bbb0000bbbbbbbbbbbb00000000000
0b0b0b00b0b0b0030b03003030300000bbb3bb0300bbbbb0000b0b0000bbbbb0000b0b0000bbbbbb00b0bb000000b0b00bbb000000bbbbbb0bbb000000000000
0b0b0b00b0b0b00b0b0300b03033000bbb3b3b0080b00b00000b0b0000b00b000000bb0000bbbbb000b00b0000000bbbb00bb0000b0bbbbbbbbb000000000000
0b0b0b00b0b0b00b0b0b00b3b0b0000b0bbbbbb000b00b00000b00b000b00b000000b000000bb00000b0b000000000b0bbbb00000b0bbb00b00bb0b000000000
0b0b0b00b0b0b0b003b3030033300000bbb0bbb080b00b00000b00b0000b00b00000b000000b000000b0b00000000bbb0b0000000bbb0000bb00bb0000000000
0b0bb000bb0b0b30b0b0b30b0b0b00000b00bb0000b00b00000b00b0000b00b0000b0b0000bb00000b000b000000b000b0b0000000bb0b000bb00b0000000000
b0b0bb000b00bbb0b000b303330300000bb00b008b000b000000b0b0000b00b0000b0b000b00b0000b000b0000000000000b0000000bb000000bb00000000000
0000000000000000000000000000000000bb0b000b0000b00000b0b00000b0b0000b00b00b00b0000b0000b00000000000000000000000000000000000000000
000000000000000000000000000000000bb0bb008b0000b0000b0b000000bb0000b00b000b000b00b0000b000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000000000000000000000000000000000000000
0033300cb0003330cb000033300cb00033300cb00cb333000000000000000000000000000fbebff0000000000000000000000000000000000000000000000000
0333330bcb033333bcb00333330bcb0333330bcb0bcb3330000000000000000000000000feebebff000000000000000000000000000000000000000000000000
03bb330bdb03bb33bdb003bb330bdb03bb330bdb0bdbbb3000000000000000000000000faaaeeebff00000000000000000000000000000000000000000000000
03bb330bb003bb33bb0003bb330bb003bb330bb00bbbb3300000fefaabebae00000000feb98beeabaab000000000000000000000000000000000000000000000
033b333b00033b33b000033b333b00033b333b000b33b333000faaaebbbebbe000000fbee99beeaebfff00000000000000000000000000000000000003330000
0bbbbb3b000bbbbbb00003bbbb3b0003bbbb3b000bbbb3bb00faaaaaebbbebbe0000fbeeb99bbeaebe98f000000000000000000000000000000000003333000b
bbbbbbbb00bbbbbbbb000bbbbbbb000bbbb3bb00bbbbbbb300fa999aeabbebbb000feebeffffbebebbe99f00000000000000000000000000000000003bb330cd
0bbbb3bbb00bbbb3bb00bbbbb3bb000bbbb3bb00bbbbbb330fe99899eebbbebbe00faaaaaaabbbaabbbeff00000000000000000000000000000000000bb330bd
b0bbb33bb0b0bbb33b000bbbb33b00b0bbb3bb00b0bb33330ee98999eeabbebbe00fbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000b330b0
b0bb3330b0b0bb333bb0b0bb333b00b0bb33bb000bbb3330eafaaaaaeaebbbebbe0fbebebebebbebebebef00000000000000000000000000000000000bbb30b0
b0033330b0b003333bb0b003333b000003333b000b033330eaeafeeaebaebbebbe00aebfeebeeaeebbbeb00000000000000000000000000000000000bbbb3bb0
b0b03b30b000b03b30b0b0b03b3b0000b0bb3b000b0b3b30eafeeeeeeeeeeeeeee00aeeeeeeeeaeb989ee00000000000000000000000000004330000b0bb30bb
00b03bb0b000b03bb0b000b0bbb0b000b0bb0b000b0b3bb00feababbfeba9999b000bfeeffefebeb899eb000000000000000000000000000466330b00b0bb00b
0bb00bb0b00bb00bb0b00bb0bb00b0000bbb0b000b0bbbb00eeabbbbbeea9989e000afeaabbeebeb998ee00000000000000000000000000036533bc0bb0bb0b0
0bb00bb0b00bb00bb0b000bbbb00b000bbb00b000b0bbbb00aeabbabbfea9899e000bfa9899bfaeb989be0000000000000000000000000000bbf3bc0bb0bb0b0
0bb00bb0b00bbb0bb0b000bbb000b000bbb000b00b0b0bb00afbabbbbfba8999e000bfb899bbfbee999be900000000000000000000000000fffbfb000b0b00b0
0bb00b00b000bb0b00b000bb0000b0000b0b00b00b0b0b000afbbabbbeaa9999b000bebaababeaee99fbb9000000000000000000000000000bbbbb000b0b00b0
00b00b0b00000b0b0b00000bb000b0000b0bb0b00b0b0b000eeabbbabfeefefef000bfbaafbbebeef7ffbf000000000000000000000000000b0b0b00030300b0
00b00b0b00000bb00b00000b0b00b000b000b0b00b0b0b00bbebaababe7beeeeef0bb7baaaabe7beeee7be1b7baaaabe7beeee7be00000000000000000000000
00b00b0b00000bb00b0000b00b00b000b000b0b00b0b0b00befbbbbbbee7be7b7f0b7bbff7bbb77be7b7be17bbff7bbb77be7b7be00000000000000000000000
00900009000000090000999000099099000900009990090000900090090000000090000000000009000990900000000009000000909000090090000000909000
00000999999999900999999999000000000099999999000009000009999900009009999990999990090000000999990090099000000099999900000999000909
00999999999999999999999999999999999999999999999900009999999990090999999999999999000999999999999999999990099999999999999999999000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000031000370003a000390003800036000330002e0002a000270001f0001000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 03424344

