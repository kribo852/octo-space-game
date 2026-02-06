keyboard = require "keyboard"
deep_sky = require "deep_sky"
drawer = require "drawer"
planets = require "planets"
color_themes = require "color_themes"
action_runner = require "action_runner"
player = require "player"
opponents = require "opponents"

function love.load()
	love.window.setTitle( "Escape space pirates" )
	current_game_state = "menu"
	score = 0 

	keyboard.hello()
	keyboard.register_key_binding("run_game", "up", function ()
		player.accelerate()
	end)

	keyboard.register_key_binding("run_game", "right", function ()
		player.turn(1)
	end)

	keyboard.register_key_binding("run_game", "left", function ()
		player.turn(-1)
	end)

	keyboard.register_key_binding("menu", "n", function ()
		current_game_state = "run_game"
		reset_game()
		action_runner.add_action(function () apply_gravitation() player.move() opponents.update() update_score() return game_over_check() end)
	end)

	keyboard.register_key_binding("run_game", "escape", function ()
		current_game_state = "menu"
	end)

	keyboard.register_key_binding("menu", "1", function ()
		love.event.quit()
	end)

	keyboard.register_key_binding("game_over", "n", function ()
		current_game_state = "run_game"
		reset_game()
		action_runner.add_action(function () apply_gravitation() player.move() opponents.update() update_score() return game_over_check() end)
	end)

	keyboard.register_key_binding("game_over", "1", function ()
		love.event.quit()
	end)

	drawer.register_draw_action("run_game", function() deep_sky.draw() draw_player() draw_opponents() draw_planets() draw_score() end)
	drawer.register_draw_action("menu", function() deep_sky.draw() color_themes.apply_color(color_themes.white_theme, love.graphics.setColor) love.graphics.print("Press n for a new game, \n! to quit", 100, 100) end)
	drawer.register_draw_action("game_over", game_over_draw)

	beep()
end

function reset_game()
	player.init()
	planets.initialize_planets()
	opponents.clear()
	opponents.set_player_info(function() return player end)
	score = 0
end

function love.draw()
	drawer.draw(current_game_state)
end

function draw_player()
	local middle_w,middle_h = screen_center()

	color_themes.apply_color(color_themes.prothagonist_green, love.graphics.setColor, 1-player.animation)
	draw_caret(middle_w, middle_h, player.angle)

	if player.animation > 0.0001 then
		color_themes.apply_color(color_themes.prothagonist_green, love.graphics.setColor, player.animation*0.35)
		love.graphics.line(middle_w + 10*math.cos(player.angle), middle_h + 10*math.sin(player.angle), 
			middle_w + 200*math.cos(player.angle), middle_h + 200*math.sin(player.angle))
		love.graphics.circle("fill", middle_w + 12*math.cos(player.angle) + 200* player.animation *math.cos(player.angle), middle_h + 12*math.sin(player.angle) + 200 * player.animation *math.sin(player.angle), 12)
	end

	draw_minimap(700, 550)

	-- speedometer
	color_themes.apply_color(color_themes.white_theme, love.graphics.setColor)
	love.graphics.line(700, 200, 700 + 5 * player.speed_x, 200 + 5 * player.speed_y)
end


function draw_planets()
	return draw_planets_with_camera(player.x, player.y)
end

function draw_planets_with_camera(camera_x, camera_y)
	local center_screen_w,center_screen_h = screen_center()
	local r, g, b = love.graphics.getColor()
	for i = 1,#planets do
		love.graphics.setColor(planets[i].red, planets[i].green, planets[i].blue, 0.25)
		love.graphics.circle("fill", center_screen_w + (planets[i].x-camera_x), center_screen_h + (planets[i].y-camera_y), planets[i].radius*1.25)
		color_themes.apply_color(planets[i], love.graphics.setColor)
		love.graphics.circle("fill", center_screen_w + (planets[i].x-camera_x), center_screen_h + (planets[i].y-camera_y), planets[i].radius)
	end
	love.graphics.setColor(r, g, b)
end


function draw_minimap(screen_x, screen_y)
	local minimap_scale = 100

	color_themes.apply_color(color_themes.prothagonist_green, love.graphics.setColor)
	love.graphics.circle("fill", screen_x, screen_y, 2)
	
	for i = 1,#planets do
		color_themes.apply_color(planets[i], love.graphics.setColor)
		local minimap_diff_x = (planets[i].x - player.x)/minimap_scale
		local minimap_diff_y = (planets[i].y - player.y)/minimap_scale
		love.graphics.circle("fill", screen_x + minimap_diff_x , screen_y + minimap_diff_y, 2)
	end
end

function game_over_draw()
	deep_sky.draw()
	draw_score()
	color_themes.apply_color(color_themes.white_theme, love.graphics.setColor)
	love.graphics.print("Game over\nPress n for a new game,\n! to quit", 100, 100)
end

function draw_opponents()
	local middle_w,middle_h = screen_center()
	for i=1,#opponents do
		color_themes.apply_color(color_themes.red_theme, love.graphics.setColor)
		draw_caret(middle_w + opponents[i].x - player.x, middle_h + opponents[i].y - player.y, opponents[i].angle)		
	end

	color_themes.apply_color(color_themes.red_theme, love.graphics.setColor, 0.85)
	for i,laser in ipairs(opponents.laser_beams) do
		love.graphics.circle("fill", middle_w + laser.x - player.x, middle_h + laser.y - player.y, 4)
	end

end

function draw_caret(xpos, ypos, angle)
	love.graphics.line(xpos + 10*math.cos(angle), ypos + 10*math.sin(angle), 
		xpos + 10*math.cos(angle + math.pi*0.9), ypos + 10*math.sin(angle + math.pi*0.9))
	love.graphics.line(xpos + 10*math.cos(angle), ypos + 10*math.sin(angle), 
		xpos + 10*math.cos(angle - math.pi*0.9), ypos + 10*math.sin(angle - math.pi*0.9))
end

function draw_score()
	color_themes.apply_color(color_themes.prothagonist_green, love.graphics.setColor)
	love.graphics.print("Score "..score)
end

function love.update()
	action_runner.run_actions()
	keyboard.run_key_actions(current_game_state)
end

function love.keypressed(key, scancode, isrepeat)
   if key == "space" then
      action_runner.add_action(wormhole())
   end
end

function apply_gravitation()
	local scale = 150.0
	local min_gravitation_radius = 50.0
	for i=1,#planets do
		distance = math.sqrt( (planets[i].x - player.x)^2 + (planets[i].y - player.y)^2)
		if(distance < 2000) then
			--print('distance '..distance)

			local strength = scale/(math.pow(math.max(distance, min_gravitation_radius), 2))
		
			player.speed_x = player.speed_x + strength*((planets[i].x - player.x)/distance)
			player.speed_y = player.speed_y + strength*((planets[i].y - player.y)/distance)
		end
	end
end

function game_over_check()
	for i=1,#planets do
		distance = math.sqrt( (planets[i].x - player.x)^2 + (planets[i].y - player.y)^2)
		if( distance < planets[i].radius ) then
			current_game_state = "game_over"
			break
		end
	end

	for index,laser in ipairs(opponents.laser_beams) do
		if(math.sqrt((player.x - laser.x)^2 + (player.y - laser.y)^2 ) < 5) then
			current_game_state = "game_over"
		end
	end


	return not (current_game_state == "game_over")
end

function update_score()
	score = score + 1
end


function wormhole()
	if player.animation < 0.001 then --only start if there is no current wormhole
		local timer = 0
		print("worm hole")
		return function()
			timer = timer + 1
			player.animation = timer/45

			if player.animation >= 1 then
				player.animation = 0
				player.jump_wormhole()
				return false
			end
			return true
		end
	end
	return function() return false end -- empty function
end

function screen_center()
	return love.graphics.getWidth()/2,love.graphics.getHeight()/2
end

function beep() 
	local rate      = 10000 -- samples per second
	local length    = 10  -- 0.03125 seconds
	local tone      = 300.0 -- Hz
	local p         = math.floor(rate/tone) -- 100 (wave length in samples)
	local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
	for i=0, soundData:getSampleCount() - 1 do
		tone_number = tone*math.pow(math.sqrt(2^0.5), 1 + math.floor((2*i) / rate)%10)   
		soundData:setSample(i, math.sin(tone_number*2*math.pi*i/rate))
	end
	local source = love.audio.newSource(soundData)
	source:setVolume(0.1)
	source:play()
end

