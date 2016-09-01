#!/usr/bin/env ruby
#
# Tidy the 2000-ish largest wiki-uzbek articles.

require 'fileutils'
require 'shellwords'
$src = '/zx/trash/wiki-uzbek/uz/'
$local = true	# Don't scrape, just retidy $dst/*.content into *.txt.

$num = 2000

# Exclude meta-ish articles.
# ;;;; todo: also exclude Oktoba.txt etc; 31_Oktoba.txt etc; 1913.txt etc.  Those are just short lists of short phrases.
# Şablon becomes .ablon.
x = `cd #$src; ls -S articles/*/*/*/*.html | egrep -v '/Vikipediya|/Vikipedia|/Wikipediya|/Template|/Yordam|/.ablon|/Discuter|/VP\~|/Narniya|/Portal|/Kategoriya|/O.z\~_|/MediaWiki|/Tasvir|/Andoza|/Foydalanuvchi|/Munozara|/Turkum|/Mil\.|/[XVI]+_|/[0-9]+.html|/[0-9]+[_\-]' | head -#$num`

xsane = x.gsub("\n"," ") .gsub("(", "\(") .gsub(")", "\)") .split(' ')

$dir = Dir.pwd
$dst = "/zx/trash/wiki-uzbek-fresh"
`mkdir -p #$dst`
Dir.chdir $src
xsane.each {|f|
  fSafe = f.shellescape
  title = `grep '<title>' #{fSafe} | head -1` \
    .sub(' - Vikipediya', '')  \
    .sub(' - Wikipedia</title>', '')  \
    .sub(/ *<title>/, '') \
    .sub('</title>', '')
    .gsub(' ', '_') .chomp
  # url = 'https://uz.wikipedia.org/wiki/' + title; puts url
  if $local
    # title.shellescape fails, because #$dst/#{title.shellescape}.content is missing.
    if File.file?("#$dst/#{title}.content")
      `cat #$dst/#{title}.content | #$dir/wiki-tidy.py | sed '/^Turkum\:/d' > #$dst/#{title}.txt`
    end
  else
    # Something about title.shellescape is needed?
    `#$dir/onepage_wikipedia.py #{title} | tee #$dst/#{title}.content | #$dir/wiki-tidy.py > #$dst/#{title}.txt 2>> /tmp/slurp.log`
    `sleep 1` # don't stress wikipedia
  end
}

`find #$dst -name \*.txt -size -450c -delete`
exit 0
