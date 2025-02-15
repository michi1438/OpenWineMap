CXXFLAGS = $(shell mapnik-config --includes --defines --cxxflags --dep-includes)
LDFLAGS = $(shell mapnik-config --libs --dep-libs --ldflags)

OBJ = poly_draw.o Region.o
OBJ2 = brd_draw.o Region.o

BIN = poly_draw 
BIN2 = brd_draw

all : $(BIN) $(BIN2)

$(BIN) : $(OBJ) $(OBJ2)
	$(CXX) $(OBJ) $(LDFLAGS) -o $(BIN)
	$(CXX) $(OBJ2) $(LDFLAGS) -o $(BIN2)

.c.o :
	$(CXX) -c $(CXXFLAGS) $<

#gyp:
#	rm -rf ./build
#	gyp rundemo.gyp --depth=. -f make --generator-output=./build/
#	make -C ./build
#	build/out/Release/rundemo `mapnik-config --prefix`

.PHONY : clean

clean: 
	rm -f $(OBJ)
	rm -f $(BIN)
	rm -f ./BUILD
