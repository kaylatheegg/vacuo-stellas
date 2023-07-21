package vacuostellas

//generate a unique id for something

uniqueIdentifier: u32 

uID :: proc() -> u32 {
	uniqueIdentifier += 1
	return uniqueIdentifier
}