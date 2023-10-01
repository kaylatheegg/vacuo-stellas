all: build

BUILD_NAME = vacuo-stellas

#ifeq ($(OS),Windows_NT)
#	BUILD_OUTPATH = comet.exe
#endif

BUILD_FLAGS = -out:$(BUILD_NAME) -no-bounds-check -debug

build:
	rm -rf build
	mkdir build 
	cp -r src/init/* 	  build
	cp -r src/render/* 	  build
	cp -r src/resources/* build
	cp -r src/object/*	  build
	cp -r src/utils/*	  build
	cp -r src/entity/*	  build
	cp -r src/entities/*  build
	cp -r src/ui/*        build
	cp -r src/world/*     build
	cp -r src/physics/*   build

	cp src/config.odin    build
	

	odin build build/ $(BUILD_FLAGS)

run: build
	./vacuo-stellas
