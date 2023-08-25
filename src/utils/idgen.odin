package vacuostellas

//generate a unique id for something
//TODO: make the variable private to this TU


uniqueIdentifier: u32 

uID :: proc() -> u32 {
	uniqueIdentifier += 1
	return uniqueIdentifier
}