maxEnemiesExp = 1.4

spawners = []
with obSpawner {
	array_push(other.spawners, id)
}

lowerSpawners = []
lowerSpawnersYCap = 2700
for (var i = 0; i < array_length(spawners); i++) {
	var spawner = spawners[i]
	if spawner.y > lowerSpawnersYCap {
		array_push(lowerSpawners, spawner)
	}
}

spawnCooldown = {
	val : 0,
	max : 20,
}

enemyTypes = [
	obWalkingEnemy,
	obFlyingEnemy,
]
spawnCount = 0

maxEdibleCount = 30
edibleSpawnCooldown = {
	time : 0,
	max : 60
}