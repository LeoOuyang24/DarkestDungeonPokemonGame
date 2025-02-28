class_name MoveSlot extends Object

#represents a move slot.
#move slots have a cooldown, that is not removed if a move is changed

#current cooldown, number of turns left to wait
var cooldown:int = 0

var move:Move = null:
	set(val):
		move = val
		if move:
			move.slot = self


func getMove() -> Move:
	return move if move else PassTurn.new()

#returns whether this move is usable
func isUsable() -> bool:
	return cooldown <= 1 and move
	
#get amount of cooldown left to wait
func getRemainingCD() -> int: 
	return cooldown
	
func setCooldown(amount:int) -> void:
	var old = cooldown
	cooldown = max(0,amount)
	#cooldown_changed.emit(amount - old,cooldown)

#decrement the cooldown
func decRemainingCD(amount:int = 1) -> void:
	setCooldown(cooldown - amount)
	
#do a move
#anything that needs to be done that is universal to all moves (ie, setting the cooldown) is done here
func doMove(user:Creature, targets:Array, battlefield):
	if move:
		var cooldown = move.move(user,targets,battlefield)
		
		#extremely scuffed way of allowing multiple return values for move.
		#originally "move" always returned void, there was nothing for it to return
		#later in development, I found that some moves needed to have modified cooldowns. Execute, for example
		#has a cooldown of 1 if it gets a kill. The easiest and most flexible way to do this was to have "move"
		#return the cooldown desired, defaulting to baseCooldown. However, I didn't want to go through every 
		#move I had made and add a return statement, plus it should be "implied" that the cooldown is the basecooldown
		#since for 90% of moves that is the case. So this "if" here checks if the returned value is Nil/0 and defaults
		#to the basecooldown if so
		setCooldown(cooldown if cooldown && cooldown > 0 else move.baseCooldown)
