#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
The 6.00 Word Game — single-file edition with:
- Safer I/O loops and clearer messages
- Sorted hand display for readability
- Deterministic hands via optional seed
- Faster optimal computer player using DP over 26-letter count tuples
- Precomputed word counters and scores
- Small quality-of-life tweaks

Run: python word_game.py
"""
from __future__ import annotations

import random
import string
import sys
from dataclasses import dataclass
from functools import lru_cache
from typing import Dict, Iterable, List, Sequence, Tuple

VOWELS: str = "aeiou"
CONSONANTS: str = "bcdfghjklmnpqrstvwxyz"
HAND_SIZE: int = 7

SCRABBLE_LETTER_VALUES: Dict[str, int] = {
    'a': 1, 'b': 3, 'c': 3, 'd': 2, 'e': 1, 'f': 4, 'g': 2, 'h': 4, 'i': 1,
    'j': 8, 'k': 5, 'l': 1, 'm': 3, 'n': 1, 'o': 1, 'p': 3, 'q': 10, 'r': 1,
    's': 1, 't': 1, 'u': 1, 'v': 4, 'w': 4, 'x': 8, 'y': 4, 'z': 10
}

WORDLIST_FILENAME = "words.txt"
FALLBACK_WORDS = [
    # de-duped, lowercased minimal list for demo
    "a", "an", "ant", "ants", "at", "ate", "axe", "bad", "bar", "bat", "bate",
    "be", "bee", "beer", "bet", "car", "care", "cat", "cats", "cater",
    "code", "coder", "coda", "dog", "dogs", "do", "go", "goat", "goal",
    "hat", "hate", "heat", "read", "reader", "red", "road", "seat", "tea",
    "tear", "tone", "ton", "stone", "note", "not", "ear"
]

ALPHABET = string.ascii_lowercase
ALPHA_IDX = {ch: i for i, ch in enumerate(ALPHABET)}

# ----------------------------
# Helper functions
# ----------------------------

def load_words() -> List[str]:
    """Return list of valid words (lowercase). Falls back if words.txt missing."""
    try:
        with open(WORDLIST_FILENAME, 'r', encoding='utf-8') as f:
            words = [line.strip().lower() for line in f if line.strip()]
        print("Loading word list from file...")
        print("  ", len(words), "words loaded.")
        return words
    except Exception:
        print("words.txt not found — using a small built-in list for demo.")
        return FALLBACK_WORDS[:]


def get_frequency_dict(sequence: Sequence[str] | str) -> Dict[str, int]:
    freq: Dict[str, int] = {}
    for x in sequence:
        freq[x] = freq.get(x, 0) + 1
    return freq


def get_word_score(word: str, n: int) -> int:
    """Score = sum(letter points) * len(word), +50 bonus if len(word) == n."""
    base = sum(SCRABBLE_LETTER_VALUES.get(ch, 0) for ch in word) * len(word)
    if len(word) == n:
        base += 50
    return base


def display_hand(hand: Dict[str, int]) -> None:
    """Print letters in the hand on one line (sorted for readability)."""
    out = []
    for letter in sorted(hand):
        out.extend([letter] * hand[letter])
    print(" ".join(out))


def deal_hand(n: int, *, seed: int | None = None) -> Dict[str, int]:
    """Return random hand dict with n letters; at least n//3 are vowels.
    Optional deterministic seed for testing.
    """
    rng = random.Random(seed)
    hand: Dict[str, int] = {}
    num_vowels = n // 3
    for _ in range(num_vowels):
        x = rng.choice(VOWELS)
        hand[x] = hand.get(x, 0) + 1
    for _ in range(num_vowels, n):
        x = rng.choice(CONSONANTS)
        hand[x] = hand.get(x, 0) + 1
    return hand


def update_hand(hand: Dict[str, int], word: str) -> Dict[str, int]:
    """Return new hand after using letters in 'word'. Removes zero-count keys."""
    h = hand.copy()
    for ch in word:
        if ch in h:
            h[ch] -= 1
            if h[ch] <= 0:
                del h[ch]
    return h


def is_valid_word(word: str, hand: Dict[str, int], word_list: Sequence[str]) -> bool:
    """True iff word is in word_list and can be made entirely from letters in hand."""
    if not word.isalpha():
        return False
    if word not in word_list:
        return False
    need = get_frequency_dict(word)
    for ch, cnt in need.items():
        if hand.get(ch, 0) < cnt:
            return False
    return True


def hand_len(hand: Dict[str, int]) -> int:
    return sum(hand.values())

# ----------------------------
# Human play
# ----------------------------

def play_hand(hand: Dict[str, int], word_list: Sequence[str], n: int) -> None:
    """Human plays given hand until '.' or no letters remain."""
    total = 0
    while hand_len(hand) > 0:
        print("Current Hand: ", end=""); display_hand(hand)
        word = input("Enter word, or a '.' to indicate that you are finished: ").strip().lower()
        if word == '.':
            print(f"Goodbye! Total score: {total} points.")
            return
        if not is_valid_word(word, hand, word_list):
            print("Invalid word, please try again.\n")
            continue
        gained = get_word_score(word, n)
        total += gained
        print(f'"{word}" earned {gained} points. Total: {total} points.\n')
        hand = update_hand(hand, word)
    print(f"Run out of letters. Total score: {total} points.")

# ----------------------------
# Computer player (optimal with memoized DP over count-tuples)
# ----------------------------

@dataclass(frozen=True)
class WordInfo:
    word: str
    counts: Tuple[int, ...]  # length 26
    score: int


def counts_tuple_from_hand(hand: Dict[str, int]) -> Tuple[int, ...]:
    arr = [0] * 26
    for ch, v in hand.items():
        idx = ALPHA_IDX.get(ch)
        if idx is not None:
            arr[idx] = v
    return tuple(arr)


def can_form(counts_hand: Tuple[int, ...], counts_word: Tuple[int, ...]) -> bool:
    # elementwise counts_word <= counts_hand
    for h, w in zip(counts_hand, counts_word):
        if w > h:
            return False
    return True


def subtract_counts(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(x - y for x, y in zip(a, b))


def prep_words(word_list: Sequence[str], n: int) -> List[WordInfo]:
    out: List[WordInfo] = []
    for w in word_list:
        if not w.isalpha():
            continue
        counts = [0] * 26
        for ch in w:
            idx = ALPHA_IDX.get(ch)
            if idx is None:
                counts = None  # type: ignore
                break
            counts[idx] += 1
        if counts is None:  # contains non a-z
            continue
        out.append(WordInfo(w, tuple(counts), get_word_score(w, n)))
    # Optional: sort by (length desc, score desc) to reach good branches early
    out.sort(key=lambda wi: (len(wi.word), wi.score), reverse=True)
    return out


def comp_play_hand(hand: Dict[str, int], word_list: Sequence[str], n: int) -> None:
    """Computer plays the hand optimally using DP over hand states.
    Prints the prompts as if the user typed the chosen words.
    """
    word_infos = prep_words(word_list, n)

    @lru_cache(maxsize=None)
    def best_from(hand_counts: Tuple[int, ...]) -> Tuple[Tuple[str, ...], int]:
        best_score = 0
        best_seq: Tuple[str, ...] = tuple()
        total_letters = sum(hand_counts)
        if total_letters == 0:
            return best_seq, 0
        # Iterate all dictionary words, prune by length and feasibility
        for wi in word_infos:
            if len(wi.word) > total_letters:
                continue
            if not can_form(hand_counts, wi.counts):
                continue
            next_hand = subtract_counts(hand_counts, wi.counts)
            seq, sc = best_from(next_hand)
            sc_total = sc + wi.score
            if sc_total > best_score:
                best_score = sc_total
                best_seq = (wi.word,) + seq
        return best_seq, best_score

    sequence, total_score = best_from(counts_tuple_from_hand(hand))
    running = 0
    last_word = '.' if sequence else '.'

    for w in sequence:
        print('Current hand: ', end=""); display_hand(hand)
        print('Enter a word or "." to indicate that you are finished: ', w)
        pts = get_word_score(w, n)
        hand = update_hand(hand, w)
        running += pts
        last_word = w
        print(f'"{w}" earned {pts} points. Total: {running} points.\n')

    if hand_len(hand) > 0:
        print('Current hand: ', end=""); display_hand(hand)
        print('Enter a word or "." to indicate that you are finished: ', '.')
        last_word = '.'

    print(("Goodbye! " if last_word == '.' else 'Ran out of letters. ') + f'Total score: {running} points.\n')

# ----------------------------
# Game loop
# ----------------------------

def ask(prompt: str, valid: Iterable[str]) -> str:
    valid_set = {v.lower() for v in valid}
    while True:
        resp = input(prompt).strip().lower()
        if resp in valid_set:
            return resp
        print("Entry is invalid")


def play_game(word_list: Sequence[str]) -> None:
    """Loop:
      - 'n' = new hand, 'r' = replay last, 'e' = exit
      - then 'u' = user plays, 'c' = computer plays
    """
    n = HAND_SIZE
    last_hand: Dict[str, int] | None = None
    while True:
        cmd = ask("Enter n to deal a new hand, r to replay the last hand, or e to end game: ", ("n", "r", "e"))
        if cmd == 'e':
            break
        hand: Dict[str, int]
        if cmd == 'r':
            if not last_hand:
                print("You have not played a hand yet. Please play a new hand first!")
                continue
            hand = last_hand.copy()
        else:
            hand = deal_hand(n)
        who = ask("Enter u to have yourself play, c to have the computer play: ", ("u", "c"))
        if who == 'u':
            play_hand(hand.copy(), word_list, n)
        else:
            comp_play_hand(hand.copy(), word_list, n)
        last_hand = hand.copy()

# ----------------------------
# Main
# ----------------------------

if __name__ == '__main__':
    words = load_words()
    try:
        play_game(words)
    except KeyboardInterrupt:
        print("\nExiting. Bye!")
        sys.exit(0)
