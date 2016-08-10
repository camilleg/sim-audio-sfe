#!/usr/bin/env ruby

# Read a saved webpage of (about) ten results from a Google search "foo bar site:en.wikipedia.org".
# Write (append) just those search results, those URLs.

# To avoid tricky < and >> characters in keystroke macros in ~/.vimperatorrc,
# the input is not STDIN but a filename as the first argument,
# and the output is not STDOUT but a filename to append to as the second argument.

if ARGV.size != 2
  STDERR.puts "usage: urls-from-googlepage.rb infile.html outfile.txt"
  exit 1
end

open(ARGV[1], 'a') {|f|
  lines = File.readlines(ARGV[0], "utf-8") .map(&:chomp) .map {|l| l.split(' ')} .flatten
  # Expand hex codes to plain ascii.
  lines = lines.map {|l| l.gsub('\\x3d', '=') .gsub('\\x3c', '<') .gsub('\\x3e', '>') .gsub('\\x22', '"') .gsub('%3A', ':')}
  # s? matches http or https.
  # .select culls undesirable webpages.
  # Don't cull wiki/Book: because that may be a useful set of titles of articles.  Although not prose, it's strongly relevant.
  # Later, don't cull wiki/v: because Wikiversity articles are high quality, despite having slightly different format (it's misparsed, entirely empty at the moment).
  # Also cull wiki/Wiki.*/ because the last slash breaks end.rb: no such directory.
  # But chapters like https://en.wikibooks.org/wiki/First_Aid/External_Bleeding are high quality!  Map / to _?
  #
  # todo: keep only the main class="r" links, not the tinier less-related links underneath,
  # e.g. <h3 class="r"><a href="https://en.wikipedia.org/wiki/Homeless_shelter"
  urls = lines.grep(/https?:\/\/en.wikipedia.org\/wiki\//) .map {|l| l.sub('href="','').sub(/"$/,'')} \
    .select {|l| !( %w(# webcache.google google.com/search google.com/imgres </cite> <b> </b> upload.wikimedia wiktionary wiki/wikinews: wiki/Wikiquote: wiki/Wiktionary: wiki/wikt: wiki/Wikt: wiki/v: wiki/Wikipedia: wiki/Category: wiki/Category_talk: wiki/Wikipedia_talk: wiki/Talk: wiki/Template: wiki/File: wiki/Portal: wiki/List_of_ title="http disambiguation album%29 film%29 wiki/Area_code_ ).any? {|w| l.include? w})}
  if urls.empty?
    # When called from vimperator, STDERR and STDOUT aren't visible, although they might go to a logfile.
    # At least this warning appears in /tmp/wiki-urls.txt.
    STDERR.puts "File #{ARGV[0]} contained no search results into wikipedia."
    f.puts      "File #{ARGV[0]} contained no search results into wikipedia."
  else
    # Todo: More cleverly than removing *all* URLs containing #, remove duplicates due to "Jump to", e.g.
    # https://en.wikipedia.org/wiki/Food_security
    # https://en.wikipedia.org/wiki/Food_security#Homogeneity_in_the_global_food_supply
    f.puts urls.sort.uniq
  end
}
exit 0

# todo: cull lines like these:
# class="rg_meta">{"id":"I5TyHMVq9nnjmM:","ml":{"0":{"bh":160,"bw":184,"o":0}},"oh":2000,"ou":"https://upload.wikimedia.org/wikipedia/commons/1/13/Rita_evacuees_from_Houston_Texas_September_21_2005.jpg","ow":3000,"pt":"https://upload.wikimedia.org/wikipedia/commons/1/1...","rh":"en.wikipedia.org","ru":"https://en.wikipedia.org/wiki/Emergency_evacuation","th":160,"tu":"https://encrypted-tbn2.gstatic.com/images?q\u003dtbn:ANd9GcQzf5jyk9rL0I1V2y__pWL2EKoNf2_kps0a2k2ttMUyKVuUddNB8Lyn80Wg","tw":240}</div></div><!--n--></div></div></div></div></div></div></div></image-viewer-group></div></div></div></div><div
# https://www.google.com/imgres?imgurl=https://upload.wikimedia.org/wikipedia/commons/1/13/Rita_evacuees_from_Houston_Texas_September_21_2005.jpg&amp;imgrefurl=https://en.wikipedia.org/wiki/Emergency_evacuation&amp;h=2000&amp;w=3000&amp;tbnid=I5TyHMVq9nnjmM:&amp;tbnh=160&amp;tbnw=240&amp;docid=5bO9L3rAemdZOM&amp;usg=__qTWUzG5VU3P6owwYkRTf_ve18yI=&amp;sa=X&amp;ved=0ahUKEwiM5fGW_YLOAhVB6oMKHZMuDjcQ9QEIIjAA
# title="https://en.wikipedia.org/wiki/Emergency_evacuation
# class="_Rm">https://en.wikipedia.org/wiki/<b>Medical</b>_emergency</cite><span
