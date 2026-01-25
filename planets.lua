planets = {}

function planets.initialize_planets()

	local color_themes = require "color_themes"

	for i=1,10 do
		local colortypes = {color_themes.red_theme, color_themes.white_theme}
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