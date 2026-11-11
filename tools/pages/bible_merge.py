#!/usr/bin/env python3
"""Three-way merge of the design bible, row by row.

    python3 tools/pages/bible_merge.py BASE OURS THEIRS > merged.html

BASE is the file both sides started from (the last publish this branch made, or main's copy),
OURS this branch's docs/design-bible.html, THEIRS the live page's saved source with the tool's
wrapper line and its trailing newline and </body></html> stripped. The bible is one row a line, so a line
merge of the whole file conflicts on every neighbouring row two sessions touched; this merges by
row instead: a row is keyed by its lead (a table row by its first cell, any other line by its
text), every row either side added or removed is added or removed, and a row both sides changed
is merged word by word with `git merge-file`. A section-12 list is merged item by item the same
way. A line that occurs many times (a blank line, a closing tag) is found where the change stands,
never at its first occurrence. The briefing's stamp is set, not merged: the version bumped past
the higher of the two, the date the later. A row the merge cannot settle keeps git's conflict
markers inline, is named on stderr, and the exit code is 1.
"""
import difflib
import os
from datetime import datetime
import re
import subprocess
import sys
import tempfile


def key(line: str) -> str:
    m = re.search(r'<p class="lead">(.*?)</p>', line)
    if m:
        return 'lead:' + m.group(1)[:90]
    m = re.search(r'<tr><td>(.*?)</td>', line)
    if m:
        return 'row:' + m.group(1)
    m = re.match(r'\s*<li>(.*?)(?:[.:(]|</li>)', line)
    if m:
        return 'item:' + m.group(1)[:80]
    return 'txt:' + line.strip()[:80]


def word_merge(old: str, new: str, other: str):
    """One line merged at the word level: old the base, new ours, other theirs."""
    names = []
    for text in (new, old, other):
        f = tempfile.NamedTemporaryFile('w', delete=False, suffix='.txt')
        f.write('\n'.join(text.split()) + '\n')
        f.close()
        names.append(f.name)
    p = subprocess.run(['git', 'merge-file', '-p', '-L', 'ours', '-L', 'base', '-L', 'theirs',
                        names[0], names[1], names[2]], capture_output=True, text=True)
    for n in names:
        os.unlink(n)
    indent = other[:len(other) - len(other.lstrip())]
    return indent + ' '.join(p.stdout.split()), '<<<<<<<' in p.stdout


ITEMS = re.compile(r'(<li>.*?</li>)')


def split_items(line: str):
    """A plain list on one line as its items, or None."""
    s = line.strip()
    if not (s.startswith('<ul') and s.endswith('</ul>')):
        return None
    head = s[:s.index('>') + 1]
    items = ITEMS.findall(s)
    if ''.join(items) != s[len(head):-len('</ul>')]:
        return None
    return head, items


STAMP = re.compile(r'<span class="eyebrow">(Version|Date)</span>([^<]*)<')


def stamp_date(text: str):
    try:
        return datetime.strptime(text.strip(), '%d %B %Y')
    except ValueError:
        return None


def merge_seq(base, ours, theirs, conflicts, label):
    """Theirs with every change base->ours applied to it, by identity, then by key."""
    merged = list(theirs)
    # Where each base line stands in theirs, so a line that occurs many times (a blank line, a
    # closing tag) is found where the change is, never at its first occurrence in the file.
    pos = [None] * (len(base) + 1)
    for a, b, size in difflib.SequenceMatcher(None, base, theirs, autojunk=False).get_matching_blocks():
        for k in range(size):
            pos[a + k] = b + k
    last = -1
    for i in range(len(base) + 1):
        if pos[i] is None:
            pos[i] = last + 1
        else:
            last = pos[i]
    near = 0

    def find(line, at=None):
        hits = [i for i, l in enumerate(merged) if l == line]
        if not hits:
            return -1
        want = near if at is None else at
        return min(hits, key=lambda i: abs(i - want))

    def find_key(k):
        hits = [i for i, l in enumerate(merged) if key(l) == k]
        return hits[0] if len(hits) == 1 else -1

    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, base, ours, autojunk=False).get_opcodes():
        if tag == 'equal':
            continue
        olds, news = base[i1:i2], ours[j1:j2]
        near = pos[i1] + len(merged) - len(theirs)   # the changes so far all stand above this one
        if tag == 'replace' and len(olds) == len(news):
            for n_old, (old, new) in enumerate(zip(olds, news)):
                so, sn = STAMP.search(old), STAMP.search(new)
                if so and sn and so.group(1) == sn.group(1):
                    # The briefing's stamp: both sides move it every publish, so its line never
                    # keys alike. main() sets the version past both; the date is the later one.
                    hits = [i for i, l in enumerate(merged) if (m := STAMP.search(l)) and m.group(1) == so.group(1)]
                    if len(hits) == 1 and so.group(1) == 'Date':
                        mine, theirs_at = stamp_date(sn.group(2)), stamp_date(STAMP.search(merged[hits[0]]).group(2))
                        if mine and (theirs_at is None or mine > theirs_at):
                            merged[hits[0]] = new
                    if len(hits) == 1:
                        continue
                at = find(old, near + n_old)
                if at >= 0:
                    merged[at] = new
                    continue
                at = find_key(key(old))
                if at < 0:
                    at = find_key(key(new))
                if at < 0:
                    merged.append(new)
                    conflicts.append(f'{label}: no home for the changed row, appended: {key(old)}')
                    continue
                parts = split_items(old), split_items(new), split_items(merged[at])
                if all(parts) and parts[0][0] == parts[1][0] == parts[2][0]:
                    items = merge_seq(parts[0][1], parts[1][1], parts[2][1], conflicts, key(old))
                    indent = merged[at][:len(merged[at]) - len(merged[at].lstrip())]
                    merged[at] = indent + parts[2][0] + ''.join(items) + '</ul>'
                    continue
                text, clash = word_merge(old, new, merged[at])
                merged[at] = text
                if clash:
                    conflicts.append(f'{label}: both sides changed the words of {key(old)}')
            continue
        for old in olds:
            at = find(old)
            if at < 0:
                at = find_key(key(old))
            if at >= 0:
                del merged[at]
            else:
                conflicts.append(f'{label}: a row ours removed is not in theirs: {key(old)}')
        if news:
            prev = ours[j1 - 1] if j1 > 0 else None
            at = find(prev, near - 1) if prev is not None else -1
            if at < 0 and prev is not None:
                at = find_key(key(prev))
            if at < 0:
                conflicts.append(f'{label}: no anchor for the rows ours added after {key(prev or "")}; appended')
                at = len(merged) - 1
            for n, line in enumerate(news):
                merged.insert(at + 1 + n, line)
    return merged


VERSION = re.compile(r'(<span class="eyebrow">Version</span>)(\d+\.\d+)')


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    base, ours, theirs = (open(p, encoding='utf-8').read().split('\n') for p in sys.argv[1:4])
    conflicts = []
    merged = merge_seq(base, ours, theirs, conflicts, 'bible')
    text = '\n'.join(merged)
    versions = [float(m.group(2)) for m in (VERSION.search('\n'.join(ours)), VERSION.search('\n'.join(theirs))) if m]
    if versions:
        text = VERSION.sub(lambda m: m.group(1) + f'{max(versions) + 0.001:.3f}', text, count=1)
    sys.stdout.write(text)
    for c in conflicts:
        print(c, file=sys.stderr)
    sys.exit(1 if conflicts else 0)


if __name__ == '__main__':
    main()
