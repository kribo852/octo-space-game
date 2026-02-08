planets = {}

function planets.initialize_planets()

	local color_themes = require "color_themes"

	for i=1,25 do
		local colortypes = {color_themes.red_theme, color_themes.white_theme}
		local select = love.math.random(#colortypes)
		local radius = math.sqrt(love.math.random(3000*3000))
		local angle = 2.0*math.pi*love.math.random()

		local set_aura_intensity = function () 
									if colortypes[select] == color_themes.red_theme then 
										return 0.05 
									end 
									return 0.005 
								end

		planets[i] = {
					x=radius * math.cos(angle), 
					y=radius * math.sin(angle), 
					red=colortypes[select].red, 
					green=colortypes[select].green, 
					blue=colortypes[select].blue,
					radius = 35 + love.math.random(25),
					aura_intensity = set_aura_intensity(select)
				}
	end

end

return planets