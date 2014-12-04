function love.load()
	createGrid()
		
end

function love.update()
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	for i = 0, 9 do
		for j = 0, 9 do
			if grid[i][j].exclude == true then
				love.graphics.setColor(0, 0, 255)
				love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
			end
			if grid[i][j].potential == true then
				love.graphics.setColor(255, 0, 0)
				love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
			end
			if grid[i][j].maze == true then
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
			end
		end
	end
end

function createGrid()
	rng = love.math.newRandomGenerator(os.time())
	rng:random(0, 100)
	grid = {}
	for i = 0, 9 do
		grid[i] = {}
		for j = 0, 9 do 
			grid[i][j] = {
				maze = false,
				potential = false,
				exclude = false
			}
		end
	end
	
	--step 1
	local randi = rng:random(0, 9)
	local randj = rng:random(0, 9)
	grid[randi][randj].maze = true
	
	--step 2
	if randi + 1 <= 9 then
		grid[randi + 1][randj].potential = true
	end
	if randi - 1 >= 0 then
		grid[randi - 1][randj].potential = true
	end
	if randj + 1 <= 9 then
		grid[randi][randj + 1].potential = true
	end
	if randj - 1 >= 0 then
		grid[randi][randj - 1].potential = true
	end
	
	--steps 3-5
	local mazecheck = false
	for i = 0, 25 do
		mazecheck = true
		for i = 0, 9 do
			for j = 0, 9 do
				if i - 1 >= 0 and j - 1 >= 0 and grid[i - 1][j].maze == true and grid[i][j - 1] == true then
					grid[i][j].exclude = true
				end
				if i + 1 <=9  and j - 1 >= 0 and grid[i + 1][j].maze == true and grid[i][j - 1] == true then
					grid[i][j].exclude = true
				end
				if i - 1 >= 0 and j + 1 <= 9 and grid[i - 1][j].maze == true and grid[i][j + 1] == true then
					grid[i][j].exclude = true
				end
				if i + 1 <= 9 and j + 1 <= 9 and grid[i + 1][j].maze == true and grid[i][j + 1] == true then
					grid[i][j].exclude = true
				end
				if grid[i][j].exclude == true then
					grid[i][j].potential = false
				end
				if grid[i][j].maze == false or grid[i][j].exclude == false then
					mazecheck = false
				end
			end
		end
		local check = false
		while check == false do
			local randi = rng:random(0, 9)
			local randj = rng:random(0, 9)
			if grid[randi][randj].potential == true and grid[randi][randj].exclude == false then
				grid[randi][randj].potential = false
				grid[randi][randj].maze = true
				--step 4
				if randi + 1 <= 9 then
					grid[randi + 1][randj].potential = true
				end
				if randi - 1 >= 0 then
					grid[randi - 1][randj].potential = true
				end
				if randj + 1 <= 9 then
					grid[randi][randj + 1].potential = true
				end
				if randj - 1 >= 0 then
					grid[randi][randj - 1].potential = true
				end
				check = true
			end
		end
	end
	
end