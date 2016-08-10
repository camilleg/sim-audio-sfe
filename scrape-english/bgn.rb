#!/usr/bin/env ruby

# Point firefox/vimperator to search results for a phrase for an SFType.
# Example usage: bgn.rb food supply
# In a temp file, store the search phrase.

`rm -f /tmp/wiki-urls.txt`
$q = ARGV.join('+')
open("/zx/trash/wiki-query.txt", 'w') {|f| f.puts $q}

`firefox "https://www.google.com/search?q=\"#$q\"+site:en.wikipedia.org&ie=utf-8&oe=utf-8"`
puts "In firefox, please do about ten times: hit F2, hit F3, click Next."
# This uses  ~/.vimperatorrc's definition of F2 and F3 keyboard shortcuts.
# This calls: urls-from-googlepage.rb /tmp/a.html /tmp/wiki-urls.txt
# Until `wc -l /tmp/wiki-urls.txt` reaches 100.
puts "Then run ./end.rb to get the files from Wikipedia."
exit 0
