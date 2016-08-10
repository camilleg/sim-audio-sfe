#!/bin/bash
#
# Translate English wikipedia text to Swahili.

for f in scrape-english/scraped/wikipages-*; do ./translate.rb "$f"; done
