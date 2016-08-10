// The feature vector is a sequence of n-grams, 3 <= n <= 7,
// over a 27-letter alphabet (space, then a through z).
// J indexes into a feature vector.

#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <unordered_map>
#include <vector>

using Ngram = char*;
using J = int; // 1 to about two million.

std::unordered_map<std::string, int> ngramsAll;
J JFromNgram(const Ngram g) {
  const auto foo = ngramsAll.find(g);
  //for (auto it=ngramsAll.begin(); it!=ngramsAll.end(); ++it) std::cerr << "1st " << it->first << " 2nd " << it->second << "\n";
  return foo == ngramsAll.end() ? 0 : foo->second;
}

int main(int argc, char* argv[]) {
  if (argc != 3) {
    std::cerr << "Usage: " << argv[0] << " in.txt ngrams.txt > input-for-svm_classify\n";
    return 1;
  }

  // Read the data structure that converts an ngram to an index into ngramsAll.
  {
    std::ifstream file(argv[2]);
    auto i=0;
    for (std::string line; std::getline(file, line); ) {
      ngramsAll[line] = ++i;
    }
  }
  std::cerr << "Looking for ngrams in a list of " << ngramsAll.size() << ".\n";

  // Convert each line of argv[1] to a feature vector to pass to svm_classify.
  std::ifstream a2z(argv[1]);
  for (std::string line; std::getline(a2z, line); ) {
    // Generate the source text's n-grams.
    const auto src = line.c_str();
    const int cch = strlen(src);
    std::unordered_map<std::string, int> counts;
    char ngram[8];
    for (int n=3; n<=7; ++n) {
      for (auto i=0; i<=cch-n; ++i) {
	strncpy(ngram, src+i, n); ngram[n] = '\0';
	++counts[ngram];
      }
    }
    const double cNgram = counts.size();

    // Sort counts by its JFromNgram(.first).
    std::vector< std::pair<long, float> > pairs;
    pairs.reserve(cNgram);
    for (auto count: counts) {
      const J j = JFromNgram((char*)count.first.c_str());
      if (j > 0)
	pairs.push_back( {j, count.second/cNgram} );
    }
    std::sort(std::begin(pairs), std::end(pairs));

    std::cout << "0 "; // class label
    for (auto pair: pairs) printf("%ld:%.7f ", pair.first, pair.second);
    std::cout << "\n";
  }
  return 0;
}
