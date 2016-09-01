#!/usr/bin/env python3
#
# Derived from code by Hao Tang.

import sys
import urllib.request
import urllib.parse
import json
import re
import datetime
import time

def query_page(title):
    '''
    Return a JSON string fetched from uz.wikipedia.org.
    title is the last part of the URL.
    '''
    if '%' not in title:
        title = urllib.parse.quote_plus(title)

    query = (u'https://uz.wikipedia.org/w/api.php?format=json&action=query&titles={}'
        '&prop=revisions&rvprop=content&redirects').format(title)
    res = urllib.request.urlopen(query)
    return res.read().decode('utf-8')

if __name__ == '__main__':
    t = sys.argv[1] # e.g., Fire_drill for http://uz.wikipedia.org/wiki/Fire_drill
    content = query_page(t)
    if '"-1"' not in content:
        data = json.loads(content)
        print(json.dumps({'title': t, 'datetime': datetime.datetime.now().isoformat(), 'data': data}))
        print('ok: {}'.format(t), file=sys.stderr)
    else:
        print('error: {}'.format(t), file=sys.stderr)
