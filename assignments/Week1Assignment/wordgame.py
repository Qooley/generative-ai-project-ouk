#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# === The 6.00 Word Game — Single-file version with computer player ===

import random
from functools import lru_cache

VOWELS = 'aeiou'
CONSONANTS = 'bcdfghjklmnpqrstvwxyz'
HAND_SIZE = 7

SCRABBLE_LETTER_VALUES = {
    'a': 1, 'b': 3, 'c': 3, 'd': 2, 'e': 1, 'f': 4, 'g': 2, 'h': 4, 'i': 1,
    'j': 8, 'k': 5, 'l': 1, 'm': 3, 'n': 1, 'o': 1, 'p': 3, 'q': 10, 'r': 1,
    's': 1, 't': 1, 'u': 1, 'v': 4, 'w': 4, 'x': 8, 'y': 4, 'z': 10
}

WORDLIST_FILENAME = "words.txt"
FALLBACK_WORDS = [
    "a", "an", "ant", "ants", "at", "ate", "axe", "bad", "bar", "bat", "bate",
    "be", "bee", "beer", "bet", "car", "care", "cat", "cats", "cater",
    "code", "coder", "coda", "dog", "dogs", "do", "go", "goat", "goal",
    "hat", "hate", "heat", "read", "reader", "red", "road", "seat", "tea",
    "tear", "tone", "tone", "ton", "stone", "note", "not", "ate", "ear"
]

# ----------------------------
# Helper functions (single file)
# ----------------------------

def loadWords():
    """Return list of valid words (lowercase). Falls back if words.txt missing."""
    try:
        with open(WORDLIST_FILENAME, 'r') as f:
            words = [line.strip().lower() for line in f]
        print("Loading word list from file...")
        print("  ", len(words), "words loaded.")
        return words
    except Exception:
        print("words.txt not found — using a small built-in list for demo.")
        return FALLBACK_WORDS[:]

def getFrequencyDict(sequence):
    """Return dict of element -> count from sequence (string or list)."""
    freq = {}
    for x in sequence:
        freq[x] = freq.get(x, 0) + 1
    return freq

def getWordScore(word, n):
    """
    Score = sum(letter points) * len(word), plus 50 bonus if len(word) == n.
    """
    base = sum(SCRABBLE_LETTER_VALUES.get(ch, 0) for ch in word) * len(word)
    if len(word) == n:
        base += 50
    return base

def displayHand(hand):
    """Print letters currently in the hand on one line."""
    for letter, count in hand.items():
        for _ in range(count):
            print(letter, end=" ")
    print()

def dealHand(n):
    """
    Return random hand dict with n letters; at least n//3 are vowels.
    """
    hand = {}
    numVowels = n // 3
    for _ in range(numVowels):
        x = random.choice(VOWELS)
        hand[x] = hand.get(x, 0) + 1
    for _ in range(numVowels, n):
        x = random.choice(CONSONANTS)
        hand[x] = hand.get(x, 0) + 1
    return hand

def updateHand(hand, word):
    """
    Return new hand after using letters in 'word'. Removes zero-count keys.
    """
    h = hand.copy()
    for ch in word:
        if ch in h:
            h[ch] -= 1
            if h[ch] == 0:
                del h[ch]
    return h

def isValidWord(word, hand, wordList):
    """
    True iff word is in wordList and can be made entirely from letters in hand.
    """
    if word not in wordList:
        return False
    need = getFrequencyDict(word)
    for ch, cnt in need.items():
        if hand.get(ch, 0) < cnt:
            return False
    return True

def calculateHandlen(hand):
    """Return total number of letters remaining in hand."""
    return sum(hand.values())

# ----------------------------
# Human play
# ----------------------------

def playHand(hand, wordList, n):
    """
    Human plays given hand until '.' or no letters remain.
    """
    total = 0
    while calculateHandlen(hand) > 0:
        print("Current Hand: ", end=""); displayHand(hand)
        word = input('Enter word, or a "." to indicate that you are finished: ').strip().lower()
        if word == '.':
            print(f"Goodbye! Total score: {total} points.")
            return
        if not isValidWord(word, hand, wordList):
            print("Invalid word, please try again.\n")
            continue
        gained = getWordScore(word, n)
        total += gained
        print(f'"{word}" earned {gained} points. Total: {total} points.\n')
        hand = updateHand(hand, word)
    print(f"Run out of letters. Total score: {total} points.")

# ----------------------------
# Computer player (optimal with memoization)
# ----------------------------

def getValidWords(hand, wordList):
    """Return list of all words from wordList that fit in 'hand'."""
    hand_len = calculateHandlen(hand)
    res = []
    for w in wordList:
        if len(w) > hand_len:
            continue
        freq = getFrequencyDict(w)
        if all(freq[ch] <= hand.get(ch, 0) for ch in freq):
            res.append(w)
    return res

def _hand_key(hand):
    """Canonical, hashable representation of hand for memoization."""
    return tuple(sorted((k, v) for k, v in hand.items() if v > 0))

def compPlayHand(hand, wordList, n):
    """
    Computer plays the hand optimally using DP over hand states.
    Prints the 'prompts' as if the user typed the chosen words.
    """
    @lru_cache(maxsize=None)
    def best_from(hand_tup):
        hand_dict = dict(hand_tup)
        best_score = 0
        best_seq = ()
        # Generate valid words for this hand state
        for w in getValidWords(hand_dict, wordList):
            new_hand = updateHand(hand_dict, w)
            seq, sc = best_from(_hand_key(new_hand))
            sc_total = sc + getWordScore(w, n)
            if sc_total > best_score:
                best_score = sc_total
                best_seq = (w,) + seq
        return best_seq, best_score

    sequence, total_score = best_from(_hand_key(hand))
    running = 0
    word = '.'  # ensure defined
    for word in sequence:
        print('Current hand: ', end=""); displayHand(hand)
        print('Enter a word or "." to indicate that you are finished: ', word)
        pts = getWordScore(word, n)
        hand = updateHand(hand, word)
        running += pts
        print(f'"{word}" earned {pts} points. Total: {running} points.\n')

    if calculateHandlen(hand) > 0:
        word = '.'
        print('Current hand: ', end=""); displayHand(hand)
        print('Enter a word or "." to indicate that you are finished: ', word)

    print(('Goodbye! ' if word == '.' else 'Ran out of letters. ')
          + f'Total score: {running} points.\n')

# ----------------------------
# Game loop
# ----------------------------

def playGame(wordList):
    """
    Loop:
      - 'n' = new hand, 'r' = replay last, 'e' = exit
      - then 'u' = user plays, 'c' = computer plays
    """
    n = HAND_SIZE
    last_hand = None
    while True:
        cmd = input("Enter n to deal a new hand, r to replay the last hand, or e to end game: ").strip().lower()
        if cmd == 'e':
            break
        if cmd not in ('n', 'r'):
            print("Entry is invalid")
            continue
        if cmd == 'r':
            if not last_hand:
                print("You have not played a hand yet. Please play a new hand first!")
                continue
            hand = last_hand.copy()
        else:
            hand = dealHand(n)

        while True:
            who = input("Enter u to have yourself play, c to have the computer play: ").strip().lower()
            if who not in ('u', 'c'):
                print("Entry is invalid")
                continue
            if who == 'u':
                playHand(hand.copy(), wordList, n)
            else:
                compPlayHand(hand.copy(), wordList, n)
            last_hand = hand.copy()
            break

# ----------------------------
# Main
# ----------------------------

if __name__ == '__main__':
    wordList = loadWords()
    playGame(wordList)
