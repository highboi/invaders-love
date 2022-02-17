--this sets the filter such that it makes each loaded image sharper instead of interpolating the images
love.graphics.setDefaultFilter("nearest", "nearest")

--this are the tables for the enemy controller
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('enemy.png')










--LOVE2D LOAD FUNCTION
function love.load()
	--this loads the background image for the game
	background_image = love.graphics.newImage('background.png')

	--this loads the background music for the game
	local music = love.audio.newSource('music.mp3', 'static')
	music:setLooping(true)
	love.audio.play(music)

	--THESE ARE THE TABLES FOR THE PLAYER
	--table for the player
	player = {}
	--player's x position
	player.x = 0
	--the player's y position
	player.y = 500
	--the player's speed
	player.speed = 10
	--the table for the bullets the player will fire
	player.bullets = {}
	--this stores the cooldown for the players gun
	player.cooldown = 20
	--this loads the sound of the player's firing gun
	player.fire_sound = love.audio.newSource('laser.wav', 'static')

	--this is a function to "fire" or move the bullet on the screen
	player.fire = function()
		--the code executes if the cooldown is reached
		if player.cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.cooldown = 20
			bullet = {}
			bullet.x = player.x + 30
			bullet.y = player.y
			table.insert(player.bullets, bullet)
		end
	end

	--this loads the image that i custom made into the player table to be used later
	player.image = love.graphics.newImage('player.png')

	--this spawns the enemies
	for i=0, 8 do
		enemies_controller:spawnEnemy(i * 91, 0)
	end
end










--SERIES OF FUNCTIONS FOR THE ENEMIES
--this is a function for spawning enemies for the player and adds it to the "enemies_controller" table "enemies" 
function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 70
	enemy.height = 70
	enemy.bullets = {}
	enemy.cooldown = 20
	enemy.speed = 10
	table.insert(self.enemies, enemy)
end
--function for the enemy firing bullets, the : is shorthand for enemy.fire(self)
function enemy:fire()
	if self.cooldown <= 0 then
		self.cooldown = 20
		bullet = {}
		bullet.x = self.x + 35
		bullet.y = self.y
		table.insert(self.bullets, bullet)
	end
end
--this is a function for detecting collisions with bullets and enemies
function checkCollisions(enemies, bullets)
	for i, e in ipairs(enemies) do
		for _, b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				table.remove(enemies_controller.enemies, i)
			end
		end
	end
end










--LOVE2D UPDATE FUNCTION
function love.update(dt)
	--this deals with the cooldown of the gun on the ship (player)
	player.cooldown = player.cooldown - 1

	--keyboard input
	--the below reads input to move the player
	if love.keyboard.isDown("right") then
		player.x = player.x + player.speed
	end

	if love.keyboard.isDown("left") then
		player.x = player.x - player.speed
	end

	if love.keyboard.isDown("space") then
		player.fire()
	end

	--this checks for the players position and keeps the player within the screen
	if player.x < 0 then
		player.x = 0
	end

	if player.x > 730 then
		player.x = 730
	end

	--this moves each enemy sideways and checks if the enemies have reached the bottom of the screen
	for _, e in pairs(enemies_controller.enemies) do	
		if e.y >= love.graphics.getHeight()-100 then
			game_over = true
		end

		if e.x >= love.graphics.getWidth()-70 or e.x < 0 then
			e.y = e.y + 55
			e.speed = -e.speed
		end
		e.x = e.x + e.speed
	end

	--this checks if the enemies list is empty to show the player that they have won the game
	if #enemies_controller.enemies == 0 then
		won_game = true
	end

	--this shoots and removes the bullets from the player.bullets table once they reach the edge of the screen
	for i, b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets, i)
		end
		b.y = b.y - 5
	end

	--this checks for collisions
	checkCollisions(enemies_controller.enemies, player.bullets)
end










--LOVE2D DRAW FUNCTION
function love.draw()
	--this checks for game over
	if game_over then
		love.graphics.scale(5)
		love.graphics.print("Game Over!")
		return	
	--this checks to see if the player has won the game
	elseif won_game then
		love.graphics.scale(5)
		love.graphics.print("You Won!")
		return
	end
	
	--this draws the background image (600 by 800)
	love.graphics.draw(background_image, 0, 0, 0, 20)

	--initialize/draw the player
	love.graphics.setColor(255, 255, 255)
	--this draws the player with the image we loaded, the first number is a rotation parameter and the second one is a scaling parameter
	love.graphics.draw(player.image, player.x, player.y, 0, 7)

	--create/draw bullets and fire them
	for _, b in pairs(player.bullets) do
		love.graphics.rectangle("fill", b.x, b.y, 10, 10)
	end

	--draws each enemy in the enemies table
	for _, e in pairs(enemies_controller.enemies) do
		love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 7)
	end
end
