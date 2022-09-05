function nextWave() {
	spawnCount = 0
	obGame.wave++
	obNextWave.nextWaveGuiObj.trigger = true
}


function spawnEdible() {
	var randomPosition = new vector(random_range(0, room_width), irandom_range(0, room_height))
	instance_create_layer(randomPosition.x, randomPosition.y, "frogEdibles", obFly)
}

function spawnEnemy(lower) {
	spawnersList = spawners
	if lower {
		spawnersList = lowerSpawners
	}
	var randomSpawnerIndex = irandom_range(0, array_length(spawnersList)-1)
	var spawner = spawnersList[randomSpawnerIndex]
	var randomEnemyIndex = irandom_range(0, array_length(enemyTypes)-1-lower)
	var enemy = enemyTypes[randomEnemyIndex]
	instance_create_layer(spawner.x, spawner.y, "enemies", enemy)
	spawnCount++
	
	spawnersList = undefined
}

if instance_exists(obFrog) {
	var enemiesCount = array_length(obGame.enemiesElementIds)
	var maxEnemies = round(power(obGame.wave, maxEnemiesExp) + 3)

	if spawnCount < maxEnemies {
		if spawnCooldown.val < spawnCooldown.max {
			spawnCooldown.val++
		}
		else {
			spawnEnemy(obFrog.frog.extraJumps == 0)
			spawnCooldown.val = 0
		}
	}
	else {
		if enemiesCount == 0 {
			nextWave()
		}
	}
	
	var edibleCount = array_length(layer_get_all_elements("frogEdibles"))
	if edibleCount < maxEdibleCount {
		if edibleSpawnCooldown.time < edibleSpawnCooldown.max {
			edibleSpawnCooldown.time++
		}
		else {
			spawnEdible()
			edibleSpawnCooldown.time = 0
		}
	}
}