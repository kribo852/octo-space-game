keyboard = require "keyboard"
deep_sky = require "deep_sky"
drawer = require "drawer"
planets = require "planets"
color_themes = require "color_themes"

function love.load()
	angle = 0
	speed_x = 0
	speed_y = 0
	angular_velocity = 0
	current_game_state = "menu"

	playerx = 0
	playery = 0

	keyboard.hello()
	keyboard.register_key_binding("run_game", "up", function ()
		speed_x = speed_x + 0.025 * math.cos(angle)
		speed_y = speed_y + 0.025 * math.sin(angle) 
	end)
	keyboard.register_key_binding("run_game", "right", function ()
		angular_velocity = angular_velocity + 0.005 * math.abs(0.25 - angular_velocity)
	end)
	keyboard.register_key_binding("run_game", "left", function ()
		angular_velocity = angular_velocity - 0.005 * math.abs(0.25 - angular_velocity)
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
	keyboard.register_key_binding("game_over", "n", function ()
		current_game_state = "run_game"
		planets.initialize_planets()
	end)
	keyboard.register_key_binding("game_over", "1", function ()
		love.event.quit()
	end)

	drawer.register_draw_action("run_game", function() deep_sky.draw() draw_player() draw_planets() end)
	drawer.register_draw_action("menu", function() love.graphics.print("Press n for a new game, \n! to quit", 100, 100) end)
	drawer.register_draw_action("game_over", game_over_draw)

	beep()
end


function love.draw()
	drawer.draw(current_game_state)
end

function draw_player()
	local middle_h = love.graphics.getHeight()/2
	local middle_w = love.graphics.getWidth()/2

	love.graphics.setColor(color_themes.prothagonist_green.red, color_themes.prothagonist_green.green, color_themes.prothagonist_green.blue)
	love.graphics.line(middle_w + 10*math.cos(angle), middle_h + 10*math.sin(angle), 
		middle_w + 10*math.cos(angle + math.pi*0.9), middle_h + 10*math.sin(angle + math.pi*0.9))

	love.graphics.line(middle_w + 10*math.cos(angle), middle_h + 10*math.sin(angle), 
		middle_w + 10*math.cos(angle - math.pi*0.9), middle_h + 10*math.sin(angle - math.pi*0.9))

	draw_minimap(700, 550)

	-- speedometer
	love.graphics.line(700, 200, 700 + 5 * speed_x, 200 + 5 * speed_y)
end


function draw_planets()
	return draw_planets_with_camera(playerx, playery)
end

function draw_planets_with_camera(camera_x, camera_y)
	local center_screen_h = love.graphics.getHeight()/2
	local center_screen_w = love.graphics.getWidth()/2
	local r, g, b = love.graphics.getColor()
	for i = 1,#planets do
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue, 0.25)
		love.graphics.circle("fill", center_screen_w + (planets[i].x-camera_x), center_screen_h + (planets[i].y-camera_y), planets[i].radius*1.25)
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue)
		love.graphics.circle("fill", center_screen_w + (planets[i].x-camera_x), center_screen_h + (planets[i].y-camera_y), planets[i].radius)
	end
	love.graphics.setColor(r, g, b)
end


function draw_minimap(screen_x, screen_y)
	local minimap_scale = 100

	love.graphics.setColor(color_themes.prothagonist_green.red, color_themes.prothagonist_green.green, color_themes.prothagonist_green.blue)
	love.graphics.circle("fill", screen_x, screen_y, 2)
	
	for i = 1,#planets do
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue)
		local minimap_diff_x = (planets[i].x - playerx)/minimap_scale
		local minimap_diff_y = (planets[i].y - playery)/minimap_scale
		love.graphics.circle("fill", screen_x + minimap_diff_x , screen_y + minimap_diff_y, 2)
	end
end

function game_over_draw()
	deep_sky.draw()
	love.graphics.print("Game over\nPress n for a new game,\n! to quit", 100, 100)
end


function love.update()
	apply_gravitation()
	keyboard.run_key_actions(current_game_state)

	angle = angle + angular_velocity
	playerx = playerx + speed_x
	playery = playery + speed_y

	angular_velocity = angular_velocity - 0.0075 * angular_velocity 
end


function apply_gravitation()
	local scale = 150.0
	local min_gravitation_radius = 50.0
	for i=1,#planets do
		distance = math.sqrt( (planets[i].x - playerx)^2 + (planets[i].y - playery)^2)
		if(distance < 2000) then
			print('distance '..distance)

			local strength = scale/(math.pow(math.max(distance, min_gravitation_radius), 2))
		
			speed_x = speed_x + strength*((planets[i].x - playerx)/distance)
			speed_y = speed_y + strength*((planets[i].y - playery)/distance)
		end
		if( distance < planets[i].radius ) then
			current_game_state = "game_over"
		end
	end
end


function beep() 
	local rate      = 44100 -- samples per second
	local length    = 10  -- 0.03125 seconds
	local tone      = 300.0 -- Hz
	local p         = math.floor(rate/tone) -- 100 (wave length in samples)
	local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
	for i=0, soundData:getSampleCount() - 1 do
		tone_number = tone*math.pow(math.sqrt(2^0.5), 1 + math.floor((2*i) / rate)%5)   
		soundData:setSample(i, math.sin(tone_number*2*math.pi*i/rate))
	end
	local source = love.audio.newSource(soundData)
	source:setVolume(0.1)
	source:play()
end

