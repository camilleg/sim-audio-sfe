#!/usr/bin/env ruby
#
# Translate English text to Swahili, about 200 KB at a time, through yandex.com.
# (The standard tool dirsplit fails, because it subtracts 400kB for ISO headers for CD-ROMs.)
#
# Called by translate-wikipages.sh.

require 'io/console'

$dir = ARGV[0]
$src = $dir + '/eng'
$dst = $dir + '/swa'
$tra = '/r/www/tmp/tr.txt'
$traURL = 'http://zx81.isl.uiuc.edu/tmp/tr.txt'
$max = 'MaximegalonDictioranny'	# Delimiter between documents in a chunk.
$chu = '/tmp/x.txt'		# A chunk of translated text.

`mkdir -p #$dst`
puts "Translating #$dir to Swahili."

files = []
`rm -f #$tra`

Dir.chdir $src
Dir.glob("*.txt") {|f|
  files << f
  `cat #{f} >> #$tra`
  `echo ' ' #$max ' ' >> #$tra`
  bytes = `wc -c #$tra`.to_i
  if bytes > 170000
    puts "#{bytes} bytes.  Please https://translate.yandex.com/translate #$traURL, copy the Swahili to #$chu in vi, save that, and hit a key."
    STDIN.getch
    lines = (fd = File.open($chu, "r")) .map(&:chomp) .map(&:strip) .join('\n') .split($max)
    files.each_with_index{|f,i| File.write($dst + "/" + f, lines[i].gsub(/\\n/, "\n"))}
    puts "Wrote files #{files}."
    files.clear
    `rm -f #$tra`
  end
}

bytes = `wc -c #$tra`.to_i
puts "#{bytes} bytes.  Please https://translate.yandex.com/translate #$traURL, copy the Swahili to #$chu in vi, save that, and hit a key."
STDIN.getch
lines = (fd = File.open($chu, "r")) .map(&:chomp) .map(&:strip) .join('\n') .split($max)
files.each_with_index{|f,i| File.write($dst + "/" + f, lines[i].gsub(/\\n/, "\n"))}
puts "Wrote files #{files}."
files.clear
`rm -f #$tra`
exit 0
