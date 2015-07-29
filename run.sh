#!/bin/sh

GPG="../g10/gpg --homedir ./gnupg --no-default-keyring"

echo hello world | $GPG --clearsign --armor --debug=4 --use-agent -o sig.asc
