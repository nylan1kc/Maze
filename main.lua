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
	rainbowItemSound = love.audio.newSource("pickup3.wav")
	badItemSound = love.audio.newSource("pickup4.wav")
	hourglassSound = love.audio.newSource("ticktock.wav")
	hourglassSound:setLooping(true)
	
	arrowKeys = love.graphics.newImage("arrows.png")
	spaceBarKey = love.graphics.newImage("spacebar.png")
	
	playerImage = love.graphics.newImage("player.png")
	flashlightImage = love.graphics.newImage("flashlight.png")
	hourglassImage = love.graphics.newImage("hourglass.png")
	stopwatchImage = love.graphics.newImage("clock.png")
	
	stopwatchRainbowImage = love.graphics.newImage("clock_rainbow.png")
	restartRainbowImage = love.graphics.newImage("restart_rainbow.png")
	magnetRainbowImage = love.graphics.newImage("magnet_rainbow.png")
	
	blindImage = love.graphics.newImage("blind.png")
	curseImage = love.graphics.newImage("curse.png")
	
	local Quad = love.graphics.newQuad
	quads = {
		Quad(0, 0, 50, 50, 300, 50),
		Quad(50, 0, 50, 50, 300, 50),
		Quad(100, 0, 50, 50, 300, 50),
		Quad(150, 0, 50, 50, 300, 50),
		Quad(200, 0, 50, 50, 300, 50),
		Quad(250, 0, 50, 50, 300, 50)
	}
	
	transition = false
	transitionLevel = 0
	transitionX = 0
	transitionY = 0
	
	time_running = false
	time = 60
	
	player = {
		x = rng:random(0, 9),
		y = rng:random(0, 9),
		width = 50,
		height = 50,
		light = false,
		flashlight = false,
		hourglass = false,
		magnet = false,
		blind = false,
		cursed = false,
		shadowX = 0,
		shadowY = 0,
		shadowTimer = 255
	}
	item = {
		exists = false,
		id = 0,
		flashlightTimer = 0,
		hourglassTimer = 0,
		magnetTimer = 0,
		blindTimer = 0,
		curseTimer = 0,
		x = 0,
		y = 0,
		width = 50,
		height = 50,
		currentFrame = 1
	}
	
	text = {
		value = "",
		x = 0,
		y = 0,
		alpha = 0,
		color = false
	}
	
	goal = {
		x = 0,
		y = 0,
		width = 50,
		height = 50,
		timer = 0
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
	previousPalette = rng:random(1, table.getn(palettes))
	currentPalette = rng:random(1, table.getn(palettes))
	nextPalette = rng:random(1, table.getn(palettes))
	createGrid()
	previousGrid = grid
end

function love.update(dt)
	if dt < 1/30 then
		love.timer.sleep(1/60 - dt)
	end
	if gamemode == "title" then
		titleMusic:play()
		if love.keyboard.isDown(" ") then
			player.light = true
		else
			player.light = false
		end
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
			bgm:setPitch(1.5)
		else
			player.light = false
			bgm:setPitch(1)
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
		--timer for flashlight
		if item.flashlightTimer > 0 then
			item.flashlightTimer = item.flashlightTimer - dt
			if item.flashlightTimer <= 0 then
				item.flashlightTimer = 0
				if player.flashlight == true then
					player.flashlight = false
				end
			end
		end
		--timer for hourglass
		if item.hourglassTimer > 0 then
			item.hourglassTimer = item.hourglassTimer - dt
			if item.hourglassTimer <= 0 then
				item.hourglassTimer = 0
				if player.hourglass == true then
					player.hourglass = false
					hourglassSound:stop()
				end
			end
		end
		--timer for magnet
		if item.magnetTimer > 0 then
			item.magnetTimer = item.magnetTimer - dt
			if item.magnetTimer <= 0 then
				item.magnetTimer = 0
				if player.magnet == true then
					player.magnet = false
				end
			end
		end
		--timer for blindness
		if item.blindTimer > 0 then
			item.blindTimer = item.blindTimer - dt
			if item.blindTimer <= 0 then
				item.blindTimer = 0
				if player.blind == true then
					player.blind = false
				end
			end
		end
		--timer for curse
		if item.curseTimer > 0 then
			item.curseTimer = item.curseTimer - dt
			if item.curseTimer <= 0 then
				item.curseTimer = 0
				if player.cursed == true then
					player.cursed = false
				end
			end
		end
		--ran out of time; end the game
		if time < 0 then
			time_running = false
			bgm:stop()
			gamemode = "gameover"
			bgmEnd:play()
		end
		--goal timer for pulsing visual
		if goal.timer < 255 then
			if player.hourglass == false then
				if player.light == true and goal.timer % 15 == 0 then
					goal.timer = goal.timer + 15
				else
					goal.timer = goal.timer + 5
				end
			end
		else
			goal.timer = 0
		end
		--player timer for shadows
		if player.shadowTimer < 255 then
			player.shadowTimer = player.shadowTimer + 15
		else
			player.shadowTimer = 255
		end
	end
	--player got item
	if player.x == item.x and player.y == item.y and item.exists == true then
		item.exists = false
		if item.id == 1 then
			itemSound:play()
			player.flashlight = true
			item.flashlightTimer = 10
		elseif item.id == 2 then
			itemSound:play()
			text.value = "+15"
			text.x = player.x * 50
			text.y = player.y * 50
			text.alpha = 255
			text.color = false
			time = time + 15
		elseif item.id == 3 then
			itemSound:play()
			player.hourglass = true
			bgm:pause()
			hourglassSound:play()
			item.hourglassTimer = 10
		elseif item.id == 4 then
			rainbowItemSound:play()
			text.value = "+30"
			text.x = player.x * 50
			text.y = player.y * 50
			text.alpha = 255
			text.color = true
			time = time + 30
		elseif item.id == 5 then
			rainbowItemSound:play()
			time = 60
			createGrid()
		elseif item.id == 6 then
			rainbowItemSound:play()
			player.magnet = true
			item.magnetTimer = 10
		elseif item.id == 7 then
			badItemSound:play()
			player.blind = true
			item.blindTimer = 5
		elseif item.id == 8 then
			badItemSound:play()
			player.cursed = true
			item.curseTimer = 10
		elseif item.id == 9 then
			badItemSound:play()
			text.value = "-5"
			text.x = player.x * 50
			text.y = player.y * 50
			text.alpha = 255
			text.color = false
			time = time - 5
		end
	end
	--player got to the goal, change the level
	if player.x == goal.x and player.y == goal.y then
		score = score + 1
		goalSound:play()
		createGrid()
	end
	--transition effect when player gets goal
	if transition == true then
		transitionLevel = transitionLevel + 1
		if transitionLevel > 10 then
			transition = false
			transitionLevel = 0
		end
	end
	item.currentFrame = item.currentFrame + 1
	if item.currentFrame > 6 then
		item.currentFrame = 1
	end
	--alpha for text
	if text.alpha > 0 then
		text.alpha = text.alpha - 5
		text.y = text.y - 2
	end
end

function love.draw()
	love.graphics.setColor(0, 0, 0)
	if transition == false then
		for i = 0, 9 do
			for j = 0, 9 do
				if player.cursed == false then
					if grid[i][j].maze == true then
						if player.light == true or player.flashlight == true then
							love.graphics.setColor(palettes[currentPalette][1].r, palettes[currentPalette][1].g, palettes[currentPalette][1].b)
						else
							love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
						end
						love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
					elseif grid[i][j].exclude == true then
						love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
						love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
					end
				else
					love.graphics.setColor(0, 0, 0)
					love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
				end
			end
		end
	else
		for i = 0, 9 do
			for j = 0, 9 do
				if player.cursed == false then
					if previousGrid[i][j].maze == true then
						if player.light == true or player.flashlight == true then
							love.graphics.setColor(palettes[previousPalette][1].r, palettes[previousPalette][1].g, palettes[previousPalette][1].b)
						else
							love.graphics.setColor(palettes[previousPalette][2].r, palettes[previousPalette][2].g, palettes[previousPalette][2].b)
						end
						love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
					elseif previousGrid[i][j].exclude == true then
						love.graphics.setColor(palettes[previousPalette][2].r, palettes[previousPalette][2].g, palettes[previousPalette][2].b)
						love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
					end
					if i >= transitionX - transitionLevel and i <= transitionX + transitionLevel and j >= transitionY - transitionLevel and j <= transitionY + transitionLevel then
						if grid[i][j].maze == true then
							if player.light == true or player.flashlight == true then
								love.graphics.setColor(palettes[currentPalette][1].r, palettes[currentPalette][1].g, palettes[currentPalette][1].b)
							else
								love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
							end
							love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
						elseif grid[i][j].exclude == true then
							love.graphics.setColor(palettes[currentPalette][2].r, palettes[currentPalette][2].g, palettes[currentPalette][2].b)
							love.graphics.rectangle("fill", i* 50, j* 50, 50, 50)
						end
					end
				else
					love.graphics.setColor(0, 0, 0)
					love.graphics.rectangle("fill", i * 50, j * 50, 50, 50)
				end
			end
		end
	end
	if gamemode == "play" then
		--draw goal
		if player.blind == false then
			love.graphics.setColor(palettes[nextPalette][2].r, palettes[nextPalette][2].g, palettes[nextPalette][2].b)
			love.graphics.rectangle("fill", goal.x * 50, goal.y * 50, goal.width, goal.height)
			love.graphics.setColor(palettes[nextPalette][2].r, palettes[nextPalette][2].g, palettes[nextPalette][2].b, 255 - goal.timer)
			love.graphics.rectangle("fill", (goal.x * 50) - (goal.timer / 5), (goal.y * 50) - (goal.timer / 5), goal.width + (goal.timer / 2.5), goal.height + (goal.timer / 2.5))		
		end
		--draw item
		if item.exists == true and player.blind == false then
			love.graphics.setColor(255, 255, 255)
			if item.id == 1 then
				love.graphics.draw(flashlightImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(flashlightImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			elseif item.id == 2 then
				love.graphics.draw(stopwatchImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(stopwatchImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			elseif item.id == 3 then
				love.graphics.draw(hourglassImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(hourglassImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			elseif item.id == 4 then
				love.graphics.draw(stopwatchRainbowImage, quads[item.currentFrame], item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(stopwatchRainbowImage, quads[item.currentFrame], (item.x * 50) - (goal.timer / 2.5), (item.y * 50) - (goal.timer / 2.5), 0, 1 + (goal.timer / 63.75), 1 + (goal.timer / 63.75))
			elseif item.id == 5 then
				love.graphics.draw(restartRainbowImage, quads[item.currentFrame], item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(restartRainbowImage, quads[item.currentFrame], (item.x * 50) - (goal.timer / 2.5), (item.y * 50) - (goal.timer / 2.5), 0, 1 + (goal.timer / 63.75), 1 + (goal.timer / 63.75))
			elseif item.id == 6 then
				love.graphics.draw(magnetRainbowImage, quads[item.currentFrame], item.x * 50, item.y * 50)
				love.graphics.setColor(255, 255, 255, 255 - goal.timer)
				love.graphics.draw(magnetRainbowImage, quads[item.currentFrame], (item.x * 50) - (goal.timer / 2.5), (item.y * 50) - (goal.timer / 2.5), 0, 1 + (goal.timer / 63.75), 1 + (goal.timer / 63.75))
			elseif item.id == 7 then
				love.graphics.setColor(0, 0, 0)
				love.graphics.draw(blindImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255 - goal.timer, 0, 0, 255 - goal.timer)
				love.graphics.draw(blindImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			elseif item.id == 8 then
				love.graphics.setColor(0, 0, 0)
				love.graphics.draw(curseImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255 - goal.timer, 0, 0, 255 - goal.timer)
				love.graphics.draw(curseImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			elseif item.id == 9 then
				love.graphics.setColor(0, 0, 0)
				love.graphics.draw(stopwatchImage, item.x * 50, item.y * 50)
				love.graphics.setColor(255 - goal.timer, 0, 0, 255 - goal.timer)
				love.graphics.draw(stopwatchImage, (item.x * 50) - (goal.timer / 5), (item.y * 50) - (goal.timer / 5), 0, 1 + (goal.timer / 127.5), 1 + (goal.timer / 127.5))
			end
		end
		--draw player
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(playerImage, player.x * 50, player.y * 50)
		love.graphics.setColor(255, 255, 255, 255 - player.shadowTimer)
		love.graphics.draw(playerImage, player.shadowX * 50, player.shadowY * 50)
		--draw black bar
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 0, 500, 500, 100)
		--draw time
		if time > 0 then
			if player.light == true then
				love.graphics.setColor(255, 0, 0)
			else
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.setFont(font32)
			love.graphics.print(math.floor(time * 10^2 + 0.5) / 100, 300, 500)
		end
		--draw score
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(font32)
		love.graphics.print("Score: " .. score, 10, 500)
		--draw text
		if text.color == true then
			if item.currentFrame == 1 then
				love.graphics.setColor(232, 76, 61, text.alpha)
			elseif item.currentFrame == 2 then
				love.graphics.setColor(231, 126, 35, text.alpha)
			elseif item.currentFrame == 3 then
				love.graphics.setColor(241, 196, 15, text.alpha)
			elseif item.currentFrame == 4 then
				love.graphics.setColor(47, 204, 113, text.alpha)
			elseif item.currentFrame == 5 then
				love.graphics.setColor(53, 152, 220, text.alpha)
			else
				love.graphics.setColor(156, 89, 184, text.alpha)
			end
		else
			love.graphics.setColor(255, 255, 255, text.alpha)
		end
		love.graphics.setFont(font32)
		love.graphics.print(text.value, text.x, text.y)
	end
	
	--draw title screen
	if gamemode == "title" then
		love.graphics.setColor(10, 10, 10, 200)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font64)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("Chroma Maze", 100, 25, 300, "center")
		love.graphics.draw(spaceBarKey, 25, 275)
		love.graphics.draw(arrowKeys, 325, 225)
		love.graphics.setFont(font32)
		love.graphics.printf("Press Enter to Start", 0, 450, 500, "center")
		love.graphics.setFont(font16)
		love.graphics.printf("Move", 400, 350, 0, "center")
		love.graphics.printf("Reveal Maze", 75, 350, 150, "center")
		love.graphics.printf("Made by: Kyle Nyland", 100, 510, 300, "center")
		love.graphics.setColor(255, 0, 0)
		love.graphics.printf("Deplete Time Faster", 25, 375, 250, "center")
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
	previousGrid = grid
	grid = {}
	potentialGrid = {}
	while nextPalette == currentPalette do
		nextPalette = rng:random(1, table.getn(palettes))
	end
	previousPalette = currentPalette
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
	goalGrid = {}
	if player.magnet == false then
		for i = 0, 9 do
			for j = 0, 9 do
				if grid[i][j].maze == true and not (i == player.x and j == player.y) and math.abs((player.x - i) + (player.y - j)) > 5 then
					table.insert(goalGrid, {x = i, y = j})
				end
			end
		end
	else
		for i = player.x - 2, player.x + 2 do
			for j = player.y - 2, player.y + 2 do
				if i >= 0 and i <= 9 and j >= 0 and j <= 9 and grid[i][j].maze == true and not (i == player.x and j == player.y) then
					table.insert(goalGrid, {x = i, y = j})
				end
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
	if itemCheck == true then
		local rand = rng:random(1, table.getn(goalGrid))
		local rand2 = rng:random(0, 100)
		item.exists = true
		if rand2 <= 50 then
			item.id = rng:random(1, 3)
		elseif rand2 > 50 and rand2 <= 90 then
			item.id = rng:random(4, 6)
		else
			item.id = rng:random(7, 9)
		end
		item.x = goalGrid[rand].x
		item.y = goalGrid[rand].y
		table.remove(goalGrid, rand)
	end
	if gamemode == "title" then
		transition = false
	else
		transition = true
	end
	transitionX = player.x
	transitionY = player.y
end

function love.keypressed(key)
	if gamemode == "play" then
		if key == "left" then
			if player.x > 0 and grid[player.x - 1][player.y].maze == true then
				player.shadowTimer = 0
				player.shadowX = player.x
				player.shadowY = player.y
				player.x = player.x - 1
			end
		elseif key == "right" then
			if player.x < 9 and grid[player.x + 1][player.y].maze == true then
				player.shadowTimer = 0
				player.shadowX = player.x
				player.shadowY = player.y
				player.x = player.x + 1
			end
		elseif key == "up" then
			if player.y > 0 and grid[player.x][player.y - 1].maze == true then
				player.shadowTimer = 0
				player.shadowX = player.x
				player.shadowY = player.y
				player.y = player.y - 1
			end
		elseif key == "down" then
			if player.y < 9 and grid[player.x][player.y + 1].maze == true then
				player.shadowTimer = 0
				player.shadowX = player.x
				player.shadowY = player.y
				player.y = player.y + 1
			end
		end
	end
	if key == "return" then
		if gamemode == "title" then
			player.light = false
			player.x = rng:random(0, 9)
			player.y = rng:random(0, 9)
			player.shadowX = player.x
			player.shadowY = player.y
			createGrid();
			gamemode = "play"
		elseif gamemode == "gameover" then
			time = 60
			score = 0
			item.exists = false
			item.flashlightTimer = 0
			item.hourglassTimer = 0
			player.x = rng:random(0, 9)
			player.y = rng:random(0, 9)
			player.shadowX = player.x
			player.shadowY = player.y
			createGrid()
			player.flashlight = false
			player.cursed = false
			player.blind = false
			player.magnet = false
			gamemode = "play"
		end
	end
end