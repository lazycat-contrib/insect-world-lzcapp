# Insect World for LazyCat

LazyCat LPK v2 packaging for [xr843/insect-world](https://github.com/xr843/insect-world), an interactive 3D insect field guide.

## Source and build

The package is built from the upstream Git tag archive matching the application version. For example, package version `0.2.0` downloads `v0.2.0.tar.gz`. Every accepted archive must have a trusted entry in `upstream-checksums.txt`; unknown versions fail closed.

```sh
lzc-cli project release -o dist/application.lpk
```

The current upstream archive is `v0.2.0.tar.gz` with SHA256:

```text
c38453f854f4db7c300dffa4a0ed62d840d06f42d551f31d3c21c642d538b89e
```

The supplied 180×180 PNG logo is preserved without scaling.

## Releasing an update

1. Add the new upstream tag archive SHA256 to `upstream-checksums.txt`.
2. Update `package.yml` to the matching SemVer.
3. Commit the changes and push the matching `v<version>` tag.

The build workflow automatically downloads, verifies, tests, and builds the upstream tag on every push to `main` and on pull requests. The tag workflow creates a versioned Release asset and publishes only to the MiaoMiao private store. Upstream source builds run in GitHub Actions, not on the packaging host.

Required repository or organization Secrets:

- `APPSTORE_URL`
- `APPSTORE_TOKEN`

Optional Secrets:

- `APP_ID`
- `PRIVATE_STORE_GROUP_CODES`
