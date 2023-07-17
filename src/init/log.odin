package vacuostellas

import "core:fmt"
import "core:time"

LOG :: enum {
	INF,
	WRN,
	ERR,
	SVR,
}

log :: proc(log: string, value: LOG, source: string,  args: ..any) {
	fmt.printf("[%02d:%02d:%02d] ", time.clock_from_time(time.now()))
	fmt.printf("[")
	str := "";
	switch value {
		case .INF: set_style(ANSI.FG_Green);   str = "INF"; 
		case .WRN: set_style(ANSI.FG_Yellow);  str = "WRN";
		case .ERR: set_style(ANSI.FG_Red);     str = "ERR";
		case .SVR: set_style(ANSI.FG_Magenta); str = "SVR";
	}
	fmt.printf(str)
	set_style(ANSI.Reset)
	fmt.printf("] ")
	fmt.printf("[{}] ", source)
	fmt.printf(log, ..args)
	fmt.printf("\n")
	return
}

set_style :: proc(code: ANSI) {
    fmt.printf("\x1b[%dm", code)
}

ANSI :: enum {

    Reset       = 0,

    Bold        = 1,
    Dim         = 2,
    Italic      = 3,

    FG_Black    = 30,
    FG_Red      = 31,
    FG_Green    = 32,
    FG_Yellow   = 33,
    FG_Blue     = 34,
    FG_Magenta  = 35,
    FG_Cyan     = 36,
    FG_White    = 37,
    FG_Default  = 39,

    BG_Black    = 40,
    BG_Red      = 41,
    BG_Green    = 42,
    BG_Yellow   = 43,
    BG_Blue     = 44,
    BG_Magenta  = 45,
    BG_Cyan     = 46,
    BG_White    = 47,
    BG_Default  = 49,
}