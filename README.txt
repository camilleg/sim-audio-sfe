DATA COLLECTION

Directory scrape-english contains code to collect articles about each HADR topic
from English Wikipedia.  To set it up, install the Firefox plugin Vimperator,
and copy .vimperatorrc to your home directory.
To collect articles for a given topic, say "food supply", run:
  ./bgn.rb food supply
    (follow the instructions given)
  ./end.rb
These scripts call urls-from-googlepage.rb, onepage_wikipedia.py, wiki-tidy.py.
When all topics' articles have been collected, run a2z.sh.

Directory scrape-swahili contains code to collect the thousand largest articles
from Swahili Wikipedia.  To do that, run a.rb, then a2z.rb.
These scripts call onepage_wikipedia.py and wiki-tidy.py.

To extract letter n-grams from the HADR documents and the neutral Swahili text:
cd ngrams; make
cd scrape-english; ./get-ngrams.sh

http://zx81.isl.uiuc.edu/tmp/HADR-scraped/ contains
the URLs of the English Wikipedia articles,
their JSON content, extracted English text, Swahili translations,
and reduced-alphabet version for n-gram extraction.
It also contains, in each subdirectory wiki*/swa, these files:
  ngrams.txt - the n-grams that appear in this topic or in the neutral Swahili text
  svm_learn_input - data to train the classifier
  svm_model - classifier trained by svm_learn
  babel-classified - output of classifier when tested on babel-conversational-all.txt
  ngrams-top.txt - 1000 most heavily weighted n-grams 

http://zx81.isl.uiuc.edu/tmp/wiki-swahili
contains the largest articles in the Swahili Wikipedia,
as JSON, extracted Swahili text, and in reduced alphabet.

TRAINING

Install http://svmlight.joachims.org/,
in particular its executables svm_learn and svm_classify.
If you like, in svm_common.h reduce MAXFEATNUM to about two million, and re-make.

To train the topic classifiers:
cd scrape-english; ./train.sh

TESTING

First, make the test data.

  To make babel-all.txt:
    cd into a directory containing the Swahili babel transcriptions.  For example, on ifp-serv-03,
    cd /ws/ifp-serv-03_1/workspace/mickey/mickey0/openkws16/IARPA-babel202b-v1.0d-build/BABEL_OP2_202/scripted/training/transcription
    Then: sed -sn 2p *.txt > /tmp/babel-all.txt

  To make babel-conversational-all.txt:
    cd /ws/ifp-serv-03_1/workspace/mickey/mickey0/openkws16/IARPA-babel202b-v1.0d-build/BABEL_OP2_202/conversational/training/transcription
    bash
    rm /tmp/babel-conversational-all.txt
    for f in *inLine.txt; do sed '1d;n;d' "$f" | sed 's/<[^>]*>//g;/^\s*$/d' | tr -d '\n' >> /tmp/babel-conversational-all.txt; done

Then, run the test:
cd scrape-english; ./test-classifiers.sh
