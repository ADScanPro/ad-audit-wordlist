# ad-audit-wordlist

The Active Directory audit wordlist I actually use on engagements, shared as a
recipe you rebuild yourself (one piece is behind a hashmob account, so re-hosting it
is not mine to give).

It is a **priority merge of two frequency-ordered lists**, de-duplicated keeping
the **first occurrence** so the frequency ordering survives (likely hits fall
first, which is what makes a time-capped crack land):

1. **hashmob "large"** research list — ~61.3M, frequency-ordered. A [hashmob.net](https://hashmob.net/research) account, Research downloads.
2. **kerberoast_pws** — [The-Viper-One](https://gist.github.com/The-Viper-One/a1ee60d8b3607807cc387d794e809f0b),
   ~35.6M, ~32.7M unique service-account passwords rockyou does not have.

Deduped with [`rling`](https://github.com/Cynosureprime/rling) (order-preserving),
**not** `sort -u`. Result ~94M lines. Pair with
[OneRuleToRuleThemStill](https://github.com/stealthsploit/OneRuleToRuleThemStill).

```bash
./build-ad-audit-wordlist.sh
hashcat -m 13100 kerberoast.hash combined_audit_base.txt -r OneRuleToRuleThemStill.rule
```

Credit: the hashmob community, The-Viper-One, Cynosureprime (rling), Stealthsploit.
