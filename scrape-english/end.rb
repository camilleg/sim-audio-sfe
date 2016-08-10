#!/usr/bin/env ruby

# Scrape each URL in /tmp/wiki-urls.txt.
# Store those files in a dir named from the 1-line contents of /zx/trash/wiki-query.txt, e.g. "food+supply".

$query = `head -1 /zx/trash/wiki-query.txt` .chomp
$dir = Dir.pwd
$dst = "/zx/trash/wikipages-#$query" .chomp
$urls = File.readlines("/tmp/wiki-urls.txt", "utf-8")[0].split .map(&:chomp) .sort.uniq
puts "Accumulating #{$urls.size} wikipedia pages into #$dst."
`rm -rf /tmp/a.html /tmp/a_files #$dst; mkdir #$dst`
Dir.chdir $dst

`mv /tmp/wiki-urls.txt /zx/trash/wiki-urls-#{$query}.txt`
$urls.each {|u|
  title  = u.sub(/https?...en.wikipedia.org.wiki./, '')
  `#$dir/onepage_wikipedia.py #{title} | tee /zx/trash/#{title}.content | #$dir/wiki-tidy.py > #{title}.txt 2>> /tmp/slurp.log`
  # `cat /tmp/old/#{title}.content | #$dir/wiki-tidy.py > #{title}.txt 2>> /tmp/slurp.log`
  # If /tmp/slurp.log isn't empty, report what it says.
}
puts "If all is well: mv /zx/trash/*.content #$dst; mv #$dst /zx/trash/wiki-urls-#$query.txt /r/lorelei/sfe/scrape-google/scraped; rm /zx/trash/wiki-query.txt"
exit 0
