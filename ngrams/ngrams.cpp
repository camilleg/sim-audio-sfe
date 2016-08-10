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
using J = int; // 1 to about a million.

// Read a file into a string.  Caller delete[]s the return value.
// Inspired by http://stackoverflow.com/q/2602013/2097284.
char* stringFromFile(const char* filename) {
  std::ifstream t(filename);
  t.seekg(0, std::ios::end);
  const int cb = t.tellg();
  char* rgb = new char[cb];
  t.seekg(0, std::ios::beg);
  t.read(rgb, cb); // Return a std::string instead, so caller needn't delete[]?
  t.close();
  if (rgb[cb-1] == '\n') rgb[cb-1] = '\0'; // .chomp
  return rgb;
}

void fileFromString(const std::string& outfilename, const std::string& indata) {
  std::ofstream t(outfilename.c_str(), std::ios_base::binary | std::ios_base::out);
  t.write(indata.c_str(), indata.size());
}

// Return a vector of filenames matching a pattern such as "/foo/bar*/*.jpg".
#include <glob.h>
std::vector<std::string> glob(const std::string& pattern) {
  std::vector<std::string> r;
  glob_t g;
  glob(pattern.c_str(), GLOB_TILDE | GLOB_BRACE, NULL, &g);
  for (auto i=0u; i<g.gl_pathc; ++i)
    r.push_back(g.gl_pathv[i]);
  globfree(&g);
  return r;
}

std::unordered_map<std::string, int> ngramsAll;
J JFromNgram(const Ngram g) {
  const auto foo = ngramsAll.find(g);
  return foo == ngramsAll.end() ? 0 : foo->second;
  // Or use http://stackoverflow.com/a/38710078/2097284.  n>7 is unlikely to be needed.
}

int main(int argc, char* argv[]) {
  if (argc != 4) {
    std::cerr << "Usage: " << argv[0] << " \"positives/*.a2z\" \"negatives/*.a2z\" ngrams.txt > input-for-svm_learn\n";
    return 1;
  }

  // First pass.  Accumulate ngrams from all files.
  for (auto arg=1; arg<=2; ++arg) {
    const auto files = glob(argv[arg]);
    for (auto a2z: files) {
      const auto src = stringFromFile(a2z.c_str());
      const int cch = strlen(src);
      char ngram[8];
      for (int n=3; n<=7; ++n) {
	for (auto i=0; i<=cch-n; ++i) {
	  // Copy from src, then null-terminate the string.
	  // (Null-terminating in place would be slightly faster, but scarier.)
	  // (Also faster: iloop, nloop, copy from 7 downto 3.)
	  strncpy(ngram, src+i, n); ngram[n] = '\0';
	  ngramsAll[ngram] = 1;
	}
      }
      delete [] src;
    }
  }

  // Build a data structure to convert an ngram to an index into ngramsAll.
  // (Another way would be a perfect hash function with a high load factor,
  // e.g. http://github.com/wahern/phf.)
  {
    auto i = 0;
    for (auto& foo: ngramsAll) foo.second = ++i;
    std::cerr << "Input files contained " << i << " distinct 3- to 7-grams.\n";
    // Write the ngrams to disk, for use by other programs such as helpers for svm_classify.
    std::string s;
    for (const auto& foo: ngramsAll) s += foo.first + "\n";
    fileFromString(argv[3], s);
#if 0
    // Such programs should read that file like this:
    {
      std::ifstream file(argv[3]);
      std::unordered_map<std::string, int> ngramsTest;
      auto i=0;
      for (std::string line; std::getline(file, line); )
	ngramsTest[line] = ++i;
      assert(ngramsTest == ngramsAll);
    }
#endif
  }

  // Second pass.  Convert the two sets of .a2z files into positive and negative input respectively for svm_learn.
  const char* prefixes[] = { "argv[0] dummy", "+1 ", "-1 " };
  const char* names[]    = { "argv[0] dummy", " positive ", " negative " };
  for (auto arg=1; arg<=2; ++arg) {
    const auto files = glob(argv[arg]);
    if (files.empty())
      std::cerr << "Warning: no" << names[arg] << "example files.  svm_learn will fail.\n";
    else
      std::cerr << "Found " << files.size() << names[arg] << "example files.\n";
    for (auto a2z: files) {
      const auto src = stringFromFile(a2z.c_str());

      // Generate the source text's n-grams.
      // Ignore markers for start and end of text, because the texts are long enough
      // to make those statistically insignificant.
      // Short or empty texts generate few or no n-grams, without any special warning.
      const int cch = strlen(src);
      std::unordered_map<std::string, int> counts;
      char ngram[8];
      for (int n=3; n<=7; ++n) {
	for (auto i=0; i<=cch-n; ++i) {
	  strncpy(ngram, src+i, n); ngram[n] = '\0';
	  ++counts[ngram];
	}
      }
      delete [] src;
      // Is it bogus to normalize over ngrams of different lengths?  7grams are naturally rarer than 3grams.
      // But how could one compensate for that?  Normalize each of the 5 sets of lengths separately to to 0.2,
      // instead of all lengths to 1.0?
      const double cNgram = counts.size();

      // Sort counts by its JFromNgram(.first).
      std::vector< std::pair<long, float> > pairs;
      pairs.reserve(cNgram);
      for (auto count: counts) pairs.push_back( {JFromNgram((char*)count.first.c_str()), count.second/cNgram} );
      std::sort(std::begin(pairs), std::end(pairs));

      std::cout << prefixes[arg];
      for (auto pair: pairs) printf("%ld:%.7f ", pair.first, pair.second);
      std::cout << "\n";
      }
    }
  return 0;
}
