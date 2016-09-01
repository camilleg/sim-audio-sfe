#!/usr/bin/env ruby
# encoding: utf-8
#
# Tidy the largest wiki-uzbek articles,
# for proofreading, then for extracting letter n-grams.

# Gem i18n is tricky to use.  Instead, transliterate away accents manually.
class String
  def to_26
    return self.tr "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
	           "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  end
end

def fileFromString filename, s
  `rm -rf #{filename}`
  (fd = File.new(filename, "w")).puts s
  fd.close
end

$src = "/zx/trash/wiki-uzbek-fresh"
$dir = Dir.pwd
Dir.chdir $src
Dir.glob("*.txt").each {|f| 
  body = File.readlines(f, "utf-8")[0]
  next if !body # Empty file, e.g. 14_Desemba.txt

  body = body.split .map(&:chomp) .join('\n') .gsub('\n', ' ') # one line

  # Remove accents, downcase, convert {punctuation, digits, nonroman alphabets} to spaces,
  # remove extra spaces.  So all that's left is a-z and space, ready for n-grams.
  # And convert standalone words " s" to "s", due to [[perfume]]s -> perfume s.
  body = body.to_26 .downcase .gsub(/[^a-z]/, ' ') .gsub(/ +/, ' ') .sub(/^ /, '') .sub(/ $/, '') .gsub(/ s([^a-z])/, 's\\1')

  fileFromString File.basename(f,'.txt') + '.a2z', body
}

exit 0
