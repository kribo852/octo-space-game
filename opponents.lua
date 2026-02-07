opponents = { 
	laser_beams = {}
}


function opponents.update()
	opponents.move()

	opponents.timer_countup()

	for i,o in ipairs(opponents) do
		o.laser_timer = o.laser_timer + 0.015
	end

	for i,laser in ipairs(opponents.laser_beams) do
		laser.x = laser.x + 8 * math.cos(laser.angle) + laser.initial_speedx
		laser.y = laser.y + 8 * math.sin(laser.angle) + laser.initial_speedy
	end

	opponents.remove_item(opponents.laser_beams, opponents.remove_laser)
	opponents.remove_item(opponents, opponents.remove_far_away_opponents)

	opponents.shoot()
end

function opponents.timer_countup()
	if not opponents.spawn_timer then
		opponents.spawn_timer = 750
	end
	local p_f = opponents.get_player_function
	if math.sqrt(p_f().x^2 + p_f().y^2) < 3000 then
		opponents.spawn_timer = opponents.spawn_timer + 1
	else 
		opponents.spawn_timer = opponents.spawn_timer + 100
	end
	if opponents.spawn_timer >= 1000 then
		opponents.spawn_timer = 0
		opponents.create_opponent()
	end
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
		speed_x = opponents.get_player_function().speed_x, 
		speed_y = opponents.get_player_function().speed_y,
		laser_timer = 0.25 -- some preparation to fire a laser
	})
end

function opponents.clear()
	for i=1,#opponents do
		table.remove(opponents, 1)
	end
	for i=1,#opponents.laser_beams do
		table.remove(opponents.laser_beams, 1)
	end
end

function opponents.shoot()
	local player = opponents.get_player_function()

	for i,o in ipairs(opponents) do
		if math.sqrt((o.x-player.x)^2 + (o.y-player.y)^2) < 350 and o.laser_timer >= 1 then
			o.laser_timer = 0
			table.insert(opponents.laser_beams, {x=o.x, y=o.y, angle=o.angle + math.pi*2*0.05*(0.5 - love.math.random()), initial_speedx=o.speed_x, initial_speedy = o.speed_y})
			print("POW")
			opponents.laser_beep()
		end
	end
end

function opponents.remove_laser(laser)
	local player = opponents.get_player_function()
	return math.sqrt((laser.x - player.x)^2 + (laser.y - player.y)^2) > 1000
end

function opponents.remove_far_away_opponents(opponent)
	local player = opponents.get_player_function()
	return math.sqrt((opponent.x - player.x)^2 + (opponent.y - player.y)^2) > 3000
end

function opponents.laser_beep() 
	local rate      = 40000 -- samples per second
	local length    = 0.3  -- 0.03125 seconds
	local tone      = 5000.0 -- Hz
	local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
	for i=0, soundData:getSampleCount() - 1 do   
		soundData:setSample(i, math.sin(tone*2*math.pi*(i^0.8)/rate) + -0.001 + love.math.random()*0.002)
	end
	local source = love.audio.newSource(soundData)
	source:setVolume(0.1)
	source:play()
end

function opponents.remove_item(tabl, calc_removal_function)
	local number_removed = 0
	for i=1,#tabl do
		if calc_removal_function(tabl[i]) then
			number_removed = number_removed + 1 -- add to the number of removed items
		end
		if number_removed + i > #tabl then
			tabl[i] = nil -- for the tail elements, these are already moved downward
		else
			tabl[i] = tabl[i + number_removed] -- here we just shift elements downward 
		end
	end
end

return opponents
