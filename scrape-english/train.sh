#!/bin/bash
#
# Train a classifier for each HADR topic.
# The directory wiki-swahili is available from http://zx81.isl.uiuc.edu/tmp/wiki-swahili/

(cd ../ngrams; make)
cd scraped; for f in wikipages-*/swa; do svm_learn -v 0 -m 10000 "$f"/svm_learn_input "$f"/svm_model; done
