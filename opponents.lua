opponents = { 
	laser_beams = {}
}


function opponents.update()
	opponents.move()

	if not timer then
		timer = 0
	end
	p_f = opponents.get_player_function
	if math.sqrt(p_f().x^2 + p_f().y^2) < 3000 then
		timer = timer + 1
	else 
		timer = timer + 100
	end
	if timer >= 1000 then
		timer = 0
		opponents.create_opponent()
	end

	for i,o in ipairs(opponents) do
		o.laser_counter = o.laser_counter + 0.015
	end

	p_f = opponents.get_player_function

	for i,laser in ipairs(opponents.laser_beams) do
		laser.x = laser.x + 4.5 * math.cos(laser.angle) + laser.initial_speedx
		laser.y = laser.y + 4.5 * math.sin(laser.angle) + laser.initial_speedy

	--	if math.sqrt((laser.x + p_f().x)^2 + (laser.y + p_f().y)^2) > 1000 then
	--		laser_beams[i] = nil
	--	end 

	end

	opponents.shoot()

end


function opponents.move()
	for i=1,#opponents do
		opponents.move_single(opponents[i])
	end
end

function opponents.move_single(opponent)
	opponents.turn(opponent)

	local dist = math.sqrt((opponent.x - player.x)^2 + (opponent.y - player.y))
	local new_dist = math.sqrt((math.cos(opponent.angle) + opponent.x - player.x)^2 + (math.sin(opponent.angle) + opponent.y - player.y))
	if new_dist < dist and new_dist > 50 then
		opponent.speed_x = opponent.speed_x + 0.005 * math.cos(opponent.angle)
		opponent.speed_y = opponent.speed_y + 0.005 * math.sin(opponent.angle)
	end

	opponent.x = opponent.x + opponent.speed_x
	opponent.y = opponent.y + opponent.speed_y

end

function opponents.turn(opponent)
	local new_dist_angle_plus = dist_for_angle_diff(opponent, 0.005)
	local new_dist_angle_minus = dist_for_angle_diff(opponent, -0.005)
	local new_dist_angle = dist_for_angle_diff(opponent, 0)

	if new_dist_angle_plus < new_dist_angle and new_dist_angle_plus < new_dist_angle_minus then
		opponent.angle = opponent.angle + 0.025
	elseif new_dist_angle_minus < new_dist_angle and new_dist_angle_minus < new_dist_angle_plus then
		opponent.angle = opponent.angle - 0.025
	end
end

function dist_for_angle_diff(opponent, angle_diff)
	return math.sqrt((opponent.x + math.cos(opponent.angle + angle_diff) - opponents.get_player_function().x)^2 + 
					(opponent.y + math.sin(opponent.angle + angle_diff) - opponents.get_player_function().y)^2)
end


function opponents.set_player_info(get_player_function)
	opponents.get_player_function = get_player_function
end

function opponents.create_opponent()
	local at_angle = 2 * math.pi * love.math.random()
	local newx = 500 * math.cos(at_angle) + opponents.get_player_function().x
	local newy = 500 * math.sin(at_angle) + opponents.get_player_function().y

	table.insert(opponents, {
		x = newx, 
		y = newy, 
		angle = at_angle + math.pi, 
		speed_x=opponents.get_player_function().speed_x, 
		speed_y=opponents.get_player_function().speed_y,
		laser_counter = 0.25 -- some preparation to fire a laser
	})
end

function opponents.clear()
	for i=1,#opponents do
		table.remove(opponents, 1)
	end
end

function opponents.shoot()

	player = opponents.get_player_function()

	for i,o in ipairs(opponents) do
		if math.sqrt((o.x-player.x)^2 + (o.y-player.y)^2) < 350 and o.laser_counter >= 1 then
			o.laser_counter = 0
			table.insert(opponents.laser_beams, {x=o.x, y=o.y, angle=o.angle + math.pi*2*0.1*(0.5 - love.math.random()), initial_speedx=o.speed_x, initial_speedy = o.speed_y})
			print("POW")
		end
	end
end

return opponents
