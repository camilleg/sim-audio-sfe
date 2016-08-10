#!/usr/bin/env ruby
# encoding: utf-8

# Tidy text for extracting letter n-grams.

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

$f = ARGV[0] # babel-all.txt
$ngrams = ARGV[1]   # scrape-google/scraped/wikipages-evacuation/swa/ngrams.txt
$svmModel = ARGV[2] # scrape-google/scraped/wikipages-evacuation/swa/svm_model
$results = ARGV[3]  # scrape-google/scraped/wikipages-evacuation/swa/results

$a2z = "/tmp/in.a2z"
$vec = "/tmp/feature_vector"
$out = "/tmp/out"

Body0 = File.readlines($f, "utf-8")[0]
exit 0 if !Body0 # Empty input.

body = Body0.split("\n")

# Remove accents.  Downcase.
body.map! {|s| s.to_26 .downcase}

# Convert BABEL annotations like <breath> <cough> <hes> <int> <lipsmack> <no-speech> <sta> (()) ~ to spaces.
body.map! {|s| s.gsub(/<[^>]*>/, ' ') .gsub('(())', ' ') .gsub('~', ' ')}

# Convert {punctuation, digits, nonroman alphabets} to spaces,
# remove extra spaces.  So all that's left is a-z and space, ready for n-grams.
body.map! {|s| s.gsub(/[^a-z]/, ' ') .gsub(/ +/, ' ') .sub(/^ /, '') .sub(/ $/, '')}

exit 0 if !body # Empty input.  So emit no output.

fileFromString $a2z, body

`cd /r/lorelei/sfe/ngrams; make foo`
`/r/lorelei/sfe/ngrams/foo #$a2z #$ngrams > #$vec`
`rm -rf #$out`
`/r/lorelei/sfe/svm/svm_classify #$vec #$svmModel #$out`
`paste #$out #$a2z > #$results`
puts "Results are in #$results"
exit 0
