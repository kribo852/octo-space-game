planets = {}

function planets.initialize_planets()

	local deep_sky = require "deep_sky"

	for i=1,10 do
		local colortypes = {deep_sky.red_theme, deep_sky.white_theme}
		local select = love.math.random(#colortypes)
		planets[i] = {
					x=love.math.random(-3000, 3000), 
					y=love.math.random(-3000, 3000), 
					red=colortypes[select].red, 
					green=colortypes[select].green, 
					blue=colortypes[select].blue,
					radius = 35 + love.math.random(25)
				}
	end

end

return planets