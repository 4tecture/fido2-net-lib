# 4tecture fork modifications

This repository is a public fork of
[passwordless-lib/fido2-net-lib](https://github.com/passwordless-lib/fido2-net-lib). The current fork baseline is
upstream release `4.3.1`, commit `ce2736d`.

## Purpose

The fork removes managed and native third-party cryptography implementations from the runtime dependency graph.
Cryptographic verification that remains supported is performed through .NET `System.Security.Cryptography`, which
delegates to the cryptographic implementation available to the operating system/runtime platform.

This is an engineering statement about the dependency graph, not legal advice or a determination of export-control
classification. Consumers remain responsible for validating their own distribution requirements.

## Changes from upstream

- Removed the `NSec.Cryptography` NuGet dependency and therefore its native `libsodium` runtime assets.
- Confirmed the package dependency graph contains no Bouncy Castle package or asset.
- Removed EdDSA/Ed25519 signing and verification code.
- Removed EdDSA from the default and public convenience algorithm lists used for credential registration.
- Explicitly reject caller-supplied EdDSA registration parameters and incoming OKP credential public keys.
- Retained the numeric COSE EdDSA/OKP identifiers only so unsupported input can be recognized and diagnosed.
- Renamed every packable artifact to a 4tecture-owned package identity:
  - `4tecture.Fido2.SystemCrypto`
  - `4tecture.Fido2.Models`
  - `4tecture.Fido2.AspNet.SystemCrypto`

## Supported credential signature algorithms

The fork retains the upstream System.Security-based support for:

- ECDSA: ES256, ES384, ES512, and ES256K where the operating system supports its curve.
- RSA PKCS#1: RS256, RS384, RS512, and legacy RS1.
- RSA-PSS: PS256, PS384, and PS512.

EdDSA/Ed25519 and OKP credential public keys are not supported. A credential registered with EdDSA by an earlier
build cannot be authenticated by this distribution and must be re-registered using a supported algorithm.

## Versioning and maintenance

Fork releases use a stable, explicitly reviewed version under the distinct `4tecture.*` package identities,
beginning with `4.0.1`. The current release is `4.3.1`. `Directory.Build.props` is the single source of truth for the package version. Because NuGet
packages are immutable, every published content change must increment that version before it reaches a `release/*`
branch. Future upstream integrations must be reviewed manually; upstream crypto and package dependency changes must
not be merged without re-running the excluded-crypto audit and the full test suite.

Azure Pipelines publishes automatic `release/*` builds with that stable version to the `Products` feed. A manually
queued build from any other branch appends the pipeline run number as a prerelease suffix, for example
`4.3.1-20261016.1`, and publishes it to `Products-PreRelease`. Pull requests are validated by GitHub Actions and do
not trigger Azure Pipelines.

## License and attribution

The upstream source is licensed under the MIT License. The original `LICENSE.txt`, copyright notices, repository
history, and upstream attribution are retained. Modified files and packages identify 4tecture as the maintainer of
this fork. See `LICENSE.txt` for the license text.
