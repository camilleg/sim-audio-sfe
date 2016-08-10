CXXFLAGS := -O3 -Ofast -DNDEBUG -Wall -W -flto -march=native -std=c++11
#CXXFLAGS += -O0 -g -UNDEBUG

all: ngrams foo

ngrams: ngrams.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<
foo: foo.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<
