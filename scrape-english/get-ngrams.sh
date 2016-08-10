#!/bin/bash
#
# Extract letter n-grams from the documents.
# The directory wiki-swahili is available from http://zx81.isl.uiuc.edu/tmp/wiki-swahili/

(cd ../ngrams; make)
cd scraped; for f in wikipages-*/swa; do ../../ngrams/ngrams "$f"/\*.a2z "wiki-swahili/*.a2z" "$f"/ngrams.txt > "$f"/svm_learn_input; done
