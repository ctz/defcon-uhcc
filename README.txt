NAME OF PROJECT: RFC6979 is not optional
WAS THIS A TEAM PROJECT: no
PROJECT LICENSE: CC0

CHALLENGE (GPG KEY LEAK / PASSWORD HASHING BACKDOOR): GPG key leak

DESCRIPTION:
See submission/patch.txt for the underhandedness.  This is for GnuPG 1.4.

DSA needs a entirely secret, unique-per-key number (`k') for each signature.
If you fail at these constraints (like it being low entropy, or one bit being
biased, or reusing a k value) your private key is recoverable from signatures.

k needs to be chosen uniformly in [0,q). gnupg's choice of k starts[1] by
choosing |q| random bits, setting the top bit and seeing if the result is <q.
If it's not, it chooses the top 32 bits again.  The probability of this happening
is very low (will vary by group, a few percent seems likely).

Because k is a super-sensitive security parameter, it obviously needs to
be zeroised instead of left on the heap!  Unfortunately my patch clears the
buffer when the candidate is >=q, as well as at the end.  That means: one every
hundred or so signatures have a 32-bit entropy k.  This is enough to brute force.

To demonstrate that, submission/recover.py unpicks the resulting pgp signature
to extract everything needed to recover k from a sample signature in
submission/sigs/attack.asc.  There's also submission/recoverk.c which uses
openssl's bignum library to search faster.

recoverk can search 16-bits worth of space in 50 CPU seconds.  The search is
embarrassingly parallel, so you can hire an EC2 m4.10xlarge (40 cores)
and extract the private key from a signature for about USD50 in 22 hours.

The user will not see any difference: their signatures will always still work, and
be properly randomised with overwhelming probability.  I think it's also likely to
be overlooked in source code review.

[1]: see cipher/dsa.c gen_k(). note that GnuPG 2.0 is different and unaffected.

