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

bug : des fois on clique dans
le vide et ca ouvre le menu
upgrade

idem, des fois ca donne des
objets gratos

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
	proba_new_object=0
	add_object_to_chunk(0,0,1,true)
	--add_object_to_chunk(10,10,2,true)
	amount_campfire=0
	no_enemy_nearby=false
	random_stuff_get=0

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
	
	proba_by_objects={2,10,30,100}
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
	print(print_display,p.x,p.y-50,12)
	--print(amount_campfire,p.x,p.y-30,12)
	--print(cursor_angle,p.x,p.y-20,12)
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
