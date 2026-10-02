# ad-audit-wordlist

![License: MIT](https://img.shields.io/badge/license-MIT-1B97A1) ![Wordlist size](https://img.shields.io/badge/wordlist-~94M_lines-0E6E78)

A kerberoastable service account doesn't wait for you to finish a 50-million-line wordlist. It waits for your engagement window to close.

**ad-audit-wordlist** is a shell-script recipe that rebuilds the ~94-million-line Active Directory audit wordlist I use on engagements, for Kerberoasting and hashcat password cracking. It priority-merges two frequency-ordered lists and dedups them in a way that keeps that order, so the likely hits land in the first few million lines where a time-capped crack can still reach them.

This is not a 1 GB download. It is the recipe, so anyone can rebuild the same list from the same two sources, in the same order.

## What's in the wordlist?

| Source | Size | Access | Role |
|---|---|---|---|
| [hashmob "large" research list](https://hashmob.net/research) | ~61.3M lines, frequency-ordered | hashmob.net account | Primary, goes first |
| [kerberoast_pws (The-Viper-One)](https://gist.github.com/The-Viper-One/a1ee60d8b3607807cc387d794e809f0b) | ~35.6M lines, ~32.7M unique on top of the first list | Public gist | Secondary, service-account passwords |

Merged and deduped with [`rling`](https://github.com/Cynosureprime/rling) (order-preserving, keeps the first occurrence). Result: ~94,000,000 lines.

## Why order beats size

Cracking against a fixed time budget is a search-order problem, not a coverage problem. Real passwords cluster around a small set of patterns (Summer2024!, company names, keyboard walks), and hashmob's frequency-ranked corpus encodes that clustering from millions of real cracks. Keep the order and hashcat finds the easy 20-30% of accounts in the first pass. Run `sort -u` on the merge and you get an alphabetized list where a weak password at line 40M costs the same GPU-hours as one at line 4M. `rling` dedups byte-exact and keeps first-seen order, so the merged list still tries the likely hits first.

## Why a recipe and not a download?

The hashmob list sits behind a hashmob.net account under their terms, so re-hosting it is not mine to give. The script pulls the public piece (`kerberoast_pws`) for you and merges it with your own hashmob download. Everything else (merge order, dedup, output) is scripted and reproducible.

## Build it

Requirements: `bash`, `curl`, `xz`, `awk`, and [`rling`](https://github.com/Cynosureprime/rling) on your `PATH`.

1. Get a [hashmob.net](https://hashmob.net/research) account, download `hashmob.net.large.found` from Research, and drop it next to the script.
2. Run:

```bash
./build-ad-audit-wordlist.sh
```

It downloads `kerberoast_pws`, normalizes line endings, merges hashmob first, and dedups with `rling` into `combined_audit_base.txt` (~94M lines).

## Use it with hashcat

Pair the wordlist with [OneRuleToRuleThemStill](https://github.com/stealthsploit/OneRuleToRuleThemStill) for rule-based mutation against a Kerberoasting hash:

```bash
hashcat -m 13100 kerberoast.hash combined_audit_base.txt -r OneRuleToRuleThemStill.rule
```

Mode `13100` is Kerberos 5, etype 23, TGS-REP: the standard hashcat mode for Kerberoasting.

## What this won't tell you

This cracks the hash. It won't tell you what that account reaches. Once you own a service account, the audit question is which paths it opens and which ones end at Domain Admin.

That's the other half: [ADscan's free CLI](https://github.com/ADScanPro/adscan) maps and executes the AD attack paths from a foothold, so you go from "I cracked a service account" to the route to the domain.

## Credit

[hashmob](https://hashmob.net/research) community, [The-Viper-One](https://gist.github.com/The-Viper-One) (kerberoast_pws), [Cynosureprime](https://github.com/Cynosureprime/rling) (rling), [Stealthsploit](https://github.com/stealthsploit/OneRuleToRuleThemStill) (OneRuleToRuleThemStill).

## License

MIT. See [LICENSE](LICENSE).

---

Built by [ADScanPro](https://github.com/ADScanPro), Active Directory security testing ([adscanpro.com](https://adscanpro.com)).
