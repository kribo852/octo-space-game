keyboard = require "keyboard"
deep_sky = require "deep_sky"
drawer = require "drawer"
planets = require "planets"

function love.load()
	angle = 0
	speed_x = 0
	speed_y = 0
	angular_velocity = 0
	current_game_state = "menu"

	playerx = 270;
	playery = 250;

	keyboard.hello()
	keyboard.register_key_binding("run_game", "up", function ()
		speed_x = speed_x + 0.025 * math.cos(angle)
		speed_y = speed_y + 0.025 * math.sin(angle) 
	end)
	keyboard.register_key_binding("run_game", "right", function ()
		angular_velocity = angular_velocity + 0.001
	end)
	keyboard.register_key_binding("run_game", "left", function ()
		angular_velocity = angular_velocity - 0.001
	end)
	keyboard.register_key_binding("menu", "n", function ()
		current_game_state = "run_game"
		planets.initialize_planets()
	end)
	keyboard.register_key_binding("run_game", "escape", function ()
		current_game_state = "menu"
	end)
	keyboard.register_key_binding("menu", "1", function ()
		love.event.quit()
	end)

	drawer.register_draw_action("run_game", game_draw)
	drawer.register_draw_action("menu", function() love.graphics.print("Press n for a new game, \n! to quit", 100, 100) end)

end


function love.draw()
	drawer.draw(current_game_state)
end

function game_draw()
	deep_sky.draw()

	local middle_h = love.graphics.getHeight()/2
	local middle_w = love.graphics.getWidth()/2

	love.graphics.line(middle_w + 10*math.cos(angle), middle_h + 10*math.sin(angle), 
		middle_w + 10*math.cos(angle + math.pi*0.9), middle_h + 10*math.sin(angle + math.pi*0.9))

	love.graphics.line(middle_w + 10*math.cos(angle), middle_h + 10*math.sin(angle), 
		middle_w + 10*math.cos(angle - math.pi*0.9), middle_h + 10*math.sin(angle - math.pi*0.9))

	draw_planets(middle_w, middle_h)
	draw_minimap(700, 550)

	love.graphics.line(700, 200, 700 + 5 * speed_x, 200 + 5 * speed_y)
end


function draw_planets(middle_w, middle_h)
	local r, g, b = love.graphics.getColor()
	for i = 1,#planets do
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue, 0.25)
		love.graphics.circle("fill", middle_w + (planets[i].x-playerx), middle_h + (planets[i].y-playery), 55)
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue)
		love.graphics.circle("fill", middle_w + (planets[i].x-playerx), middle_h + (planets[i].y-playery), 45)
	end
	love.graphics.setColor(r, g, b)
end


function draw_minimap(screen_x, screen_y)
	love.graphics.circle("fill", screen_x, screen_y, 2)
	
	for i = 1,#planets do
		local minimap_diff_x = (planets[i].x - playerx)/200
		local minimap_diff_y = (planets[i].y - playery)/200 
		love.graphics.circle("fill", screen_x + minimap_diff_x , screen_y + minimap_diff_y, 4)
	end
end


function love.update()
	apply_gravitation()
	keyboard.run_key_actions(current_game_state)

	angle = angle + angular_velocity
	playerx = playerx + speed_x
	playery = playery + speed_y

	angular_velocity = angular_velocity - 0.003 * angular_velocity 
end


function apply_gravitation()
	local scale = 100.0
	local min_gravitation_radius = 75.0
	for i=1,#planets do
		distance = math.sqrt( (planets[i].x - playerx)^2 + (planets[i].y - playery)^2)
		if(distance < 2000) then
			print('distance '..distance)

			local strength = scale/(math.pow(math.max(distance, min_gravitation_radius), 2))
		
			speed_x = speed_x + strength*((planets[i].x - playerx)/distance)
			speed_y = speed_y + strength*((planets[i].y - playery)/distance)
		end
	end
end
