#!/bin/bash
#
# Simplify the alphabet of documents, to simplify extraction of n-grams.

cd scraped; for f in wikipages-*/swa; do ./a2z.rb "$f"; done
