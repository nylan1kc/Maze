function love.load()
	rng = love.math.newRandomGenerator(os.time())
	rng:random(0, 100)
	
	player = {
		x = rng:random(0, 9),
		y = rng:random(0, 9),
		width = 50,
		height = 50
	}
	goal = {
		x = 0,
		y = 0,
		width = 50,
		height = 50
	}
	createGrid()
	
end

function love.update()
	if player.x == goal.x and player.y == goal.y then
		createGrid()
	end
end

function love.draw()
	love.graphics.setColor(0, 0, 0)
	for i = 0, 9 do
		for j = 0, 9 do
			if grid[i][j].maze == true then
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
			end
			if grid[i][j].exclude == true then
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
			end
		end
	end
	--draw goal
	love.graphics.setColor(255, 0, 255)
	love.graphics.rectangle("fill", goal.x * 50, goal.y * 50, goal.width, goal.height)
	--draw player
	love.graphics.setColor(0, 255, 255)
	love.graphics.rectangle("fill", player.x * 50, player.y * 50, player.width, player.height)
end

function createGrid()
	grid = {}
	potentialGrid = {}
	for i = 0, 9 do
		grid[i] = {}
		for j = 0, 9 do 
			grid[i][j] = {
				maze = false,
				exclude = false
			}
		end
	end
	
	--step 1
	randi = player.x
	randj = player.y
	grid[randi][randj].maze = true
	
	
	--step 2
	if randi + 1 <= 9 then
		table.insert(potentialGrid, {i = randi + 1, j = randj})
	end
	if randi - 1 >= 0 then
		table.insert(potentialGrid, {i = randi - 1, j = randj})
	end
	if randj + 1 <= 9 then
		table.insert(potentialGrid, {i = randi, j = randj + 1})
	end
	if randj - 1 >= 0 then
		table.insert(potentialGrid, {i = randi, j = randj - 1})
	end
	
	--steps 3-5
	while table.getn(potentialGrid) > 0 do
		for i = 0, 9 do
			for j = 0, 9 do
				if i - 1 >= 0 and j - 1 >= 0 and grid[i - 1][j].maze == true and grid[i][j - 1].maze == true and grid[i][j].maze == false and grid[i][j].exclude == false then
					grid[i][j].exclude = true
				end
				if i + 1 <= 9 and j - 1 >= 0 and grid[i + 1][j].maze == true and grid[i][j - 1].maze == true and grid[i][j].maze == false and grid[i][j].exclude == false then
					grid[i][j].exclude = true
				end
				if i - 1 >= 0 and j + 1 <= 9 and grid[i - 1][j].maze == true and grid[i][j + 1].maze == true and grid[i][j].maze == false and grid[i][j].exclude == false then
					grid[i][j].exclude = true
				end
				
				if i + 1 <= 9 and j + 1 <= 9 and grid[i + 1][j].maze == true and grid[i][j + 1].maze == true and grid[i][j].maze == false and grid[i][j].exclude == false then
					grid[i][j].exclude = true
				end
				for k, value in ipairs(potentialGrid) do
					if grid[i][j].exclude == true and i == value.i and j == value.j then
						table.remove(potentialGrid, k)
					end
				end
			end
		end
		if table.getn(potentialGrid) > 0 then
			local rand = rng:random(1, table.getn(potentialGrid))
			grid[potentialGrid[rand].i][potentialGrid[rand].j].maze = true
			if potentialGrid[rand].i - 1 >= 0 and grid[potentialGrid[rand].i - 1][potentialGrid[rand].j].maze == false and grid[potentialGrid[rand].i - 1][potentialGrid[rand].j].exclude == false then
				table.insert(potentialGrid, {i = potentialGrid[rand].i - 1, j = potentialGrid[rand].j})
			end
			if potentialGrid[rand].i + 1 <= 9 and grid[potentialGrid[rand].i + 1][potentialGrid[rand].j].maze == false and grid[potentialGrid[rand].i + 1][potentialGrid[rand].j].exclude == false then
				table.insert(potentialGrid, {i = potentialGrid[rand].i + 1, j = potentialGrid[rand].j})
			end
			if potentialGrid[rand].j - 1 >= 0 and grid[potentialGrid[rand].i][potentialGrid[rand].j - 1].maze == false and grid[potentialGrid[rand].i][potentialGrid[rand].j - 1].exclude == false then
				table.insert(potentialGrid, {i = potentialGrid[rand].i, j = potentialGrid[rand].j - 1})
			end
			if potentialGrid[rand].j + 1 <= 9 and grid[potentialGrid[rand].i][potentialGrid[rand].j + 1].maze == false and grid[potentialGrid[rand].i][potentialGrid[rand].j + 1].exclude == false then
				table.insert(potentialGrid, {i = potentialGrid[rand].i, j = potentialGrid[rand].j + 1})
			end
			table.remove(potentialGrid, rand)
		end
	end
	local goalGrid = {}
	for i = 0, 9 do
		for j = 0, 9 do
			if grid[i][j].maze == true and i ~= player.x and j ~= player.y and math.abs((player.x - i) + (player.y - j)) > 5 then
				table.insert(goalGrid, {x = i, y = j})
			end
		end
	end
	local rand = rng:random(1, table.getn(goalGrid))
	goal.x = goalGrid[rand].x
	goal.y = goalGrid[rand].y
end

function love.keypressed(key)
	if key == "left" then
		if player.x > 0 and grid[player.x - 1][player.y].maze == true then
			player.x = player.x - 1
		end
	elseif key == "right" then
		if player.x < 9 and grid[player.x + 1][player.y].maze == true then
			player.x = player.x + 1
		end
	elseif key == "up" then
		if player.y > 0 and grid[player.x][player.y - 1].maze == true then
			player.y = player.y - 1
		end
	elseif key == "down" then
		if player.y < 9 and grid[player.x][player.y + 1].maze == true then
			player.y = player.y + 1
		end
	end
end