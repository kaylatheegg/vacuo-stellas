package vacuostellas

button :: struct {
	bb: vs_rectf32,
	name: string,

	data_type: typeid,
	data: rawptr,
	callback: proc(^button),

	button_type: button_type, //kinda ugly
	button_colours: [4]RGBA,
	txinfo: vs_recti32,
}