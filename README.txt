NAME OF PROJECT: 
WAS THIS A TEAM PROJECT: no
PROJECT LICENSE: wtfpl/cc0

CHALLENGE (GPG KEY LEAK / PASSWORD HASHING BACKDOOR): GPG key leak

NOTE: The project description should explain your entry
      clearly; including the techniques used, why it works,
      why you think it would go undetected. It may be a
      summary of a longer document included in the /submission/
      folder. This description will eventually be published on
      the Underhanded Crypto Contest web site, along with the
      contents of the /submission/ folder. This must clearly
      describe the entry to the judges; to respect the time of
      our judges, they will not take the time to hunt for the
      techniques used. The description should be 500 to 2000
      words.

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
buffer when the candidate >=q, as well as at the end.  That means: one every hundred
or so signatures have a 32-bit entropy k.  This is enough to brute force.

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

