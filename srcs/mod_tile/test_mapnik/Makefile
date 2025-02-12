CXXFLAGS = $(shell mapnik-config --includes --defines --cxxflags --dep-includes)
LDFLAGS = $(shell mapnik-config --libs --dep-libs --ldflags)

OBJ = sud_ouest.o
OBJ2 = sud_ouest_brd.o

BIN = sud_ouest
BIN2 = sud_ouest_brd

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
