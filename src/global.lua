pq = {}
pq.isFullscreen = false
pq.testMode = false

pq.title = "Protoquest"
pq.version = "v0.0.0.1b"

pq.scaleWidth = 1
pq.scaleHeight = 1
pq.tilemapWidth = 1
pq.tilemapHeight = 1

pq.map = nil
pq.mapPath = "maps/"
pq.filePath = ""
pq.oldFilePath = ""

pq.mapLoaded = false

pq.player = nil

pq.collidableShapes = {} -- Immovable objects shapes
pq.collidableTiles = {} -- Immovable objects tiles
pq.collidableObjects = {} -- Moveable objects

pq.collideDirection = "none"

pq.teleportShapes = {}
pq.teleportTiles = {}