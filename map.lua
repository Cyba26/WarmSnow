--world

--chunks

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

function check_chunks_if_exist(x,y)
	local check_chunks_exist=false
	for c in all(chunks) do
		if (c.x==x and c.y==y) check_chunks_exist=true
	end
	if check_chunks_exist==false then
		add_new_chunks(x,y)
		proba_new_object-=1
	end
end

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



--objects

function add_object_to_chunk(x,y,typ,menu)
	if menu==true then
		x=p.x-13
		y=p.y-10
	else
		x=x+100
		y=y+20+rnd(80)
	end
	local usable=false
	if (typ==2 or typ==4) usable=true
	add(objects,{
		x=x,
		y=y,
		l=21,
		h=15,
		in_chunk_x=x,
		in_chunk_y=y,
		typ=typ,
		timer_obj=0,
		usable=usable,
		version=ceil(rnd(3))
	})
end

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
	sspr(53,22,20,21,o.x,o.y-30)
end


--lakes

function update_lakes(o)

end


function draw_lakes(o)
	--rectfill(o.x,o.y,100,100,8)
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
			print_display=between_two_objets(p,o)
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





