local deep_sky = {
	red_theme = {red=0.75, green=0.1, blue=0.125},
	white_theme = {red=0.88, green=0.88, blue=0.93},
	background = {red=0.01, green=0.03, blue=0.06}
}

function deep_sky.init_stars()
	local star_array = {}
	for i=1,100 do
		star_array[i] = {x=love.math.random(love.graphics.getWidth()), y=love.math.random(love.graphics.getHeight())}
	end
	return star_array
end

function deep_sky.draw() 
	love.graphics.setBackgroundColor(deep_sky.background.red, deep_sky.background.green, deep_sky.background.blue)
	local r, g, b = love.graphics.getColor()
	for i=1,#deep_sky.star_array do
		love.graphics.setColor(deep_sky.white_theme.red, deep_sky.white_theme.green, deep_sky.white_theme.blue, 0.25)
		love.graphics.rectangle("fill", deep_sky.star_array[i].x, deep_sky.star_array[i].y, 3, 3)
	end
	love.graphics.setColor(r, g, b)
end

deep_sky.star_array = deep_sky.init_stars()

return deep_sky