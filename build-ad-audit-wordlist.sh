#!/usr/bin/env bash
# ad-audit-wordlist: the AD audit wordlist I actually use, as a recipe you can
# rebuild yourself. It is a priority merge of two frequency-ordered lists,
# de-duplicated keeping the FIRST occurrence so the frequency ordering survives:
#
#   1. hashmob "large" research list   (~61.3M, frequency-ordered, richest)
#   2. The-Viper-One kerberoast_pws    (~35.6M, ~32.7M unique service-account pwds)
#
# Result: ~94M lines, ordered so the likely hits fall first (what makes a
# time-capped crack actually land). Pair it with OneRuleToRuleThemStill for rules.
#
# Why a recipe and not a 1 GB download: the hashmob list is gated behind a
# hashmob.net account (their terms), so re-hosting it is not mine to do. You grab
# that one piece yourself; everything else is here.
set -euo pipefail

# --- 1. hashmob large (a hashmob.net account -> Research downloads) -------
#   Download "hashmob.net.large.found" and drop it next to this script.
#   Docs: https://hashmob.net/research
LARGE="hashmob.net.large.found"

# --- 2. kerberoast_pws (public, The-Viper-One) --------------------------------
curl -L -o kerberoast_pws.xz \
  'https://gist.github.com/The-Viper-One/a1ee60d8b3607807cc387d794e809f0b/raw/b7d83af6a8bbb43013e04f78328687d19d0cf9a7/kerberoast_pws.xz'
xz -dk kerberoast_pws.xz   # -> kerberoast_pws

# --- normalize (strip CR, ensure newline) then priority-concat (large FIRST) ---
awk '{ sub(/\r$/,""); print }' "$LARGE"        >  merged.txt
awk '{ sub(/\r$/,""); print }' kerberoast_pws  >> merged.txt

# --- order-preserving dedup (keep first occurrence) ---------------------------
# NOT `sort -u`: that would destroy the frequency ordering a time-capped crack
# relies on. rling is byte-exact and keeps first-seen. https://github.com/Cynosureprime/rling
rling merged.txt combined_audit_base.txt

wc -l combined_audit_base.txt   # ~94,000,000

# --- use it -------------------------------------------------------------------
#   hashcat -m 13100 kerberoast.hash combined_audit_base.txt \
#     -r OneRuleToRuleThemStill.rule
#   (OneRuleToRuleThemStill: https://github.com/stealthsploit/OneRuleToRuleThemStill)
