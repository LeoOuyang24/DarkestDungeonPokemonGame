class_name Buckets extends Object

#literally just a place to store static buckets

#something to be put in a bucket
#represents how hard a particular creature is to fight at level 1
class BucketSlot:
	var difficulty:int = 1
	var creature:Creature =null
	
	func _init(d:int,c:String):
		difficulty = max(d,1)
		creature =CreatureLoader.loadJSON( c)

#creates a battle given how hard the room is
#"bucket" is an array of BucketSlots
#"difficulty" is an int, the higher it is the harder the room. 0 spawns nothing
#returns an array of enemies that can be added directly to a battlemanager
static func createBattle(bucket:Array,difficulty:int) -> Array:
	var money := difficulty #how much money we have to spend
	
	var enemies := []
	#remove all creatures that are now too hard, even at level 1
	bucket = bucket.filter(func(slot:BucketSlot):
			return slot.difficulty <= money
			)
	if bucket.size() > 0:
		#find the smallest difficulty
		var min:BucketSlot = bucket.reduce(func(slot:BucketSlot,consider:BucketSlot):
			return slot if slot.difficulty < consider.difficulty else consider
			,bucket[0])
		
		while enemies.size() < Battlefield.maxEnemies and money >= min.difficulty and bucket.size() > 0:
			var creature:Creature = null 
			var index := 0;
			var level:int = 0

			#find a valid creature
			while !creature and bucket.size() > 0:
				index = randi()%bucket.size()
				level = min(10,randi()%(max(1,money - bucket[index].difficulty)) + 1)
				if !bucket[index].creature:
					bucket.remove_at(index)
				else:
					creature = bucket[index].creature.duplicate()
					creature.levelUp(level-1)
					
					#each level after 1 is +1 difficulty
					money -= bucket[index].difficulty + level-1
					print(bucket[index].difficulty, " " ,money, " ", level)

					enemies.push_back(creature)
					
					#remove all creatures that are now too hard, even at level 1
					bucket = bucket.filter(func(slot:BucketSlot):
						return slot.difficulty <= money
						)
					break

			
				
	return enemies

var bucketBasic:Array = [
	BucketSlot.new(1,"chomper"),
	BucketSlot.new(1,"silent"),
	BucketSlot.new(3,"priest")
]

var bucketUtility:Array = [
	BucketSlot.new(1,"siren"),
	BucketSlot.new(3,"masked"),
	BucketSlot.new(2,"princess")
]

var bucketHard:Array = [
	BucketSlot.new(8,"giant")
]
