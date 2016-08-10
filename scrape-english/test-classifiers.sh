#!/bin/bash
#
# Test the classifiers for each HADR topic on a set of Babel Swahili transcriptions.

cd scraped; for f in wikipages-*/swa; do ../../ngrams/classify.rb babel-conversational-all.txt "$f"/ngrams.txt "$f"/svm_model "$f"/babel-classified; done
