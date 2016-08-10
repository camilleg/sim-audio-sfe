#!/usr/bin/env ruby
#
# Tidy the 1100 largest wiki-swahili articles,
# for proofreading, then for extracting letter n-grams.

require 'fileutils'
require 'shellwords'
$src = '/zx/trash/wiki-swahili/sw/'
$local = true	# Don't scrape, just retidy $dst/*.content into *.txt.

$num = 1500

# Exclude meta-ish articles.
# Orodha_ya is List_of years, Canadian provinces, Byzantine emperors.
# Makala za msingi is List of vital articles.
# Mwaka and Mwezi are months and years.
# ;;;; todo: also exclude Oktoba.txt etc; 31_Oktoba.txt etc; 1913.txt etc.  Those are just short lists of short phrases.
x = `cd #$src; ls -S articles/*/*/*/*.html | egrep -v '/Wikipedia|/Image|/User|/Talk|/Template|/Category|/Orodha_ya|/Makala|/Mwaka|/Mwezi|\(mwaka\).html' | head -#$num`
#
#xsplit = x.split .map(&:chomp)
xsane = x.gsub("\n"," ") .gsub("(", "\(") .gsub(")", "\)") .split(' ')
# xsane.size == $num

$dir = Dir.pwd
$dst = "/zx/trash/wiki-swahili-fresh"
Dir.chdir $src
xsane.each {|f|
  fSafe = f.shellescape
  title = `grep '<title>' #{fSafe} | head -1` .sub(/ *<title>/, '') .sub(' - Wikipedia</title>', '') .gsub(' ', '_') .chomp
  # url = 'https://sw.wikipedia.org/wiki/' + title; puts url
  if $local
    `cat #$dst/#{title}.content | #$dir/wiki-tidy.py > #$dst/#{title}.txt`
  else
    # Something about title.shellescape is needed?
    `#$dir/onepage_wikipedia.py #{title} | tee #$dst/#{title}.content | #$dir/wiki-tidy.py > #$dst/#{title}.txt 2>> /tmp/slurp.log`
    `sleep 2` # don't stress wikipedia
  end
}

Dir.chdir $dst
`find . -name \*.txt -size -450c -delete`
exit 0
