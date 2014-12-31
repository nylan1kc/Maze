function love.load()
	gamemode = "title"
	rng = love.math.newRandomGenerator(os.time())
	rng:random(0, 100)
	
	score = 0
	
	titleMusic = love.audio.newSource("Fire.wav")
	titleMusic:setLooping(true)
	bgm = love.audio.newSource("Getting Hotter.wav")
	bgm:setLooping(true)
	bgmEnd = love.audio.newSource("Getting Hotter - END.wav")
	goalSound = love.audio.newSource("pickup.wav")
	itemSound = love.audio.newSource("pickup2.wav")
	hourglassSound = love.audio.newSource("ticktock.wav")
	hourglassSound:setLooping(true)
	
	playerImage = love.graphics.newImage("player.png")
	flashlightImage = love.graphics.newImage("flashlight.png")
	hourglassImage = love.graphics.newImage("hourglass.png")
	stopwatchImage = love.graphics.newImage("clock.png")
	
	time_running = false
	time = 60
	
	player = {
		x = rng:random(0, 9),
		y = rng:random(0, 9),
		width = 50,
		height = 50,
		light = false,
		flashlight = true,
		hourglass = false
	}
	item = {
		exists = false,
		id = 0,
		timer = 0,
		x = 0,
		y = 0,
		width = 50,
		height = 50
	}
	
	goal = {
		x = 0,
		y = 0,
		width = 50,
		height = 50
	}
	palettes = {
		{
			--blue
			{r = 0, g = 47, b = 47},
			{r = 4, g = 99, b = 128}
		},
		{
			--red
			{r = 142, g = 40, b = 0},
			{r = 182, g = 73, b = 38}
		},
		{
			--pale greenish/gray?
			{r = 145, g = 170, b = 157},
			{r = 209, g = 219, b = 189}
		},
		{
			--yellow orangish
			{r = 219, g = 158, b = 54},
			{r = 255, g = 211, b = 78}
		},
		{
			--green
			{r = 0, g = 163, b = 136},
			{r = 121, g = 189, b = 143}
		},
		{
			--pink
			{r = 255, g = 192, b = 169},
			{r = 255, g = 133, b = 152}
		},
		{
			--orange
			{r = 255, g = 45, b = 0},
			{r = 255, g = 140, b = 0}
		},
		{
			--pastel blue
			{r = 1, g = 162, b = 166},
			{r = 41, g = 201, b = 210}
		},
		{
			--purple
			{r = 49, g = 21, b = 43},
			{r = 114, g = 49, b = 71}
		}
	}
	font64 = love.graphics.newFont("MikronX.ttf", 64)
	font32 = love.graphics.newFont("MikronX.ttf", 32)
	font16 = love.graphics.newFont("MikronX.ttf", 16)
	currentPalette = rng:random(1, table.getn(palettes))
	nextPalette = rng:random(1, table.getn(palettes))
	createGrid()
	
end

function love.update(dt)
	if gamemode == "title" then
		titleMusic:play()
	else
		titleMusic:stop()
	end
	if gamemode == "play" then
		if player.hourglass == false then
			bgm:play()
		end
		--let there be light
		if love.keyboard.isDown(" ") and player.flashlight == false then
			player.light = true
		else
			player.light = false
		end
		--timer update
		time_running = true
		if time_running == true and player.hourglass == false then
			if player.light == true then
				time = time - (3 * dt)
			else
				time = time - dt
			end			
		end
		if item.timer > 0 then
			item.timer = item.timer - dt
			if item.timer <= 0 then
				item.timer = 0
				if player.flashlight == true then
					player.flashlight = false
				end
				if player.hourglass == true then
					player.hourglass = false
					hourglassSound:stop()
				end
			end
		end
		if time < 0 then
			time_running = false
			bgm:stop()
			gamemode = "gameover"
			bgmEnd:play()
		end
	end
	--player got item
	if player.x == item.x and player.y == item.y and item.exists == true then
		itemSound:play()
		item.exists = false
		if item.id == 1 then
			player.flashlight = true
			item.timer = 5
		elseif item.id == 2 then
			time = time + 15
			item.timer = 5
		elseif item.id == 3 then
			player.hourglass = true
			bgm:pause()
			hourglassSound:play()
			item.timer = 5
		end
	end
	--player got to the goal, change the level
	if player.x == goal.x and player.y == goal.y then
		score = score + 1
		goalSound:play()
		createGrid()
	end
end

function love.draw()
	love.graphics.setColor(0, 0, 0)
	for i = 0, 9 do
		for j = 0, 9 do
			if grid[i][j].maze == true then
				if player.light == true or player.flashlight == true then
					love.graphics.setColor(palettes[currentPalette][1].r, palettes[currentPalette][1].g, palettes[currentPalette][1].b)
				else
					love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
				end
				love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
			end
			if grid[i][j].exclude == true then
				love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
				love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
			end
		end
	end
	if gamemode == "play" then
		--draw goal
		love.graphics.setColor(palettes[nextPalette][2].r, palettes[nextPalette][2].g, palettes[nextPalette][2].b)
		love.graphics.rectangle("fill", goal.x * 50, goal.y * 50, goal.width, goal.height)
		--draw item
		if item.exists == true then
			love.graphics.setColor(255, 255, 255)
			if item.id == 1 then
				love.graphics.draw(flashlightImage, item.x * 50, item.y * 50)
			elseif item.id == 2 then
				love.graphics.draw(stopwatchImage, item.x * 50, item.y * 50)
			elseif item.id == 3 then
				love.graphics.draw(hourglassImage, item.x * 50, item.y * 50)
			end
		end
		--draw player
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(playerImage, player.x * 50, player.y * 50)
		--draw time
		if time > 0 then
			love.graphics.setColor(255, 255, 255)
			love.graphics.setFont(font32)
			love.graphics.print(math.floor(time * 10^2 + 0.5) / 100, 300, 500)
		end
		--draw score
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(font32)
		love.graphics.print("Score: " .. score, 10, 500)
	end
	
	if gamemode == "title" then
		love.graphics.setColor(10, 10, 10, 200)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font64)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("Chroma Maze", 100, 50, 300, "center")
		love.graphics.setFont(font16)
		love.graphics.printf("Arrow Keys to Move\nSpace to Show Maze\n\nTry to Get to the Goal\nShowing the Maze Decreases Your Time!\n\nPress Enter to Start\n\n\n\n\nMade by: Kyle Nyland", 100, 250, 300, "center")
	end
	
	if gamemode == "gameover" then
		love.graphics.setColor(10, 10, 10, 200)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font32)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("Time's Up!", 100, 150, 300, "center")
		love.graphics.setFont(font64)
		love.graphics.printf("Final Score: " .. score, 0, 200, 500, "center")
		love.graphics.setFont(font16)
		love.graphics.printf("Press Enter to Play Again", 100, 400, 300, "center")
	end
end

function createGrid()
	grid = {}
	potentialGrid = {}
	while nextPalette == currentPalette do
		nextPalette = rng:random(1, table.getn(palettes))
	end
	currentPalette = nextPalette
	while nextPalette == currentPalette do
		nextPalette = rng:random(1, table.getn(palettes))
	end
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
			grid[potentialGrid[rand].i][potentialGrid[rand].j].exclude = false
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
	
	--outside excludes
	for i = 0, 9 do
		for j = 0, 9 do
			if (i + 1 > 9 or grid[i + 1][j].maze == false) and (i - 1 < 0 or grid[i - 1][j].maze == false) and (j + 1 > 9 or grid[i][j + 1].maze == false) and (j - 1 < 0 or grid[i][j - 1].maze == false) then
				grid[i][j].exclude = true
				grid[i][j].maze = false
			end
		end
	end
	--get goal
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
	table.remove(goalGrid, rand)
	
	--create an item
	item.exists = false
	local itemRand = rng:random(0, 100)
	local itemCheck = false
	if time >= 45 then
		--5% chance
		if itemRand <= 5 then
			itemCheck = true
		end
	elseif time < 45 and time >= 30 then
		--25% chance
		if itemRand <= 25 then
			itemCheck = true
		end
	elseif time < 30 and time >= 20 then
		--40% chance
		if itemRand <= 40 then
			itemCheck = true
		end
	elseif time < 20 and time >= 10 then
		--50% chance
		if itemRand <= 50 then
			itemCheck = true
		end
	elseif time < 10 and time >= 5 then
		--75% chance
		if itemRand <= 75 then
			itemCheck = true
		end
	else
		if itemRand <= 90 then
			itemCheck = true
		end
	end
	if itemCheck == true and item.timer <= 0 then
		local rand = rng:random(1, table.getn(goalGrid))
		item.exists = true
		item.id = rng:random(1, 3)
		item.x = goalGrid[rand].x
		item.y = goalGrid[rand].y
		table.remove(goalGrid, rand)
	end
end

function love.keypressed(key)
	if gamemode == "play" then
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
		elseif key == "r" then
			createGrid();
		end
	end
	if key == "return" then
		if gamemode == "title" then
			gamemode = "play"
		elseif gamemode == "gameover" then
			time = 60
			score = 0
			item.exists = false
			item.timer = 0
			createGrid()
			gamemode = "play"
		end
	end
end