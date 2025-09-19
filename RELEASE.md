# Release Checklist

This project auto-builds and publishes Docker images via GitHub Actions.

- Push to **main** → publishes `flengure/mcp-prompt-loader:latest` (multi-arch).
- Push a **tag** like `vX.Y.Z` → publishes `:X.Y.Z` **and** updates `:latest` (multi-arch).

---

## 1) Prep main

```bash
git checkout main
git pull
```

- Ensure code builds locally if needed.
- Update docs as required.

---

## 2) Finalize CHANGELOG

Edit `CHANGELOG.md` and finalize the section for the new version (e.g. `2.1.0`).

```bash
git add CHANGELOG.md
git commit -m "docs: finalize 2.1.0 changelog"
git push
```

---

## 3) Tag the release

```bash
# create annotated tag
git tag -a v2.1.0 -m "release: v2.1.0"

# push the tag
git push origin v2.1.0
```

> This triggers the GitHub Actions workflow to build and push:
> - `flengure/mcp-prompt-loader:2.1.0`
> - `flengure/mcp-prompt-loader:latest`

---

## 4) Verify CI

Open **GitHub → Actions → Build & Release Docker Image** and confirm the run is green.

Optional CLI checks:

```bash
docker buildx imagetools inspect flengure/mcp-prompt-loader:2.1.0
docker buildx imagetools inspect flengure/mcp-prompt-loader:latest
```

You should see both `linux/amd64` and `linux/arm64`.

Quick digest match check:

```bash
DIG_TAG=$(docker buildx imagetools inspect flengure/mcp-prompt-loader:2.1.0 | awk '/^Digest:/ {print $2}')
DIG_LATEST=$(docker buildx imagetools inspect flengure/mcp-prompt-loader:latest | awk '/^Digest:/ {print $2}')
printf "2.1.0 : %s\nlatest: %s\n" "$DIG_TAG" "$DIG_LATEST"
test "$DIG_TAG" = "$DIG_LATEST" && echo "✅ MATCH" || echo "❌ DIFFER"
```

---

## 5) (Optional) GitHub Release notes

Create a Release in GitHub for `v2.1.0` and paste the corresponding section from `CHANGELOG.md`.

---

## 6) (Optional) Hotfix or reissue a tag

If the tag needs to move (private repos only; avoid on public):

```bash
# delete old tag locally + remote
git tag -d v2.1.0
git push origin :refs/tags/v2.1.0

# recreate at current HEAD
git tag -a v2.1.0 -m "release: v2.1.0 (reissued)"
git push origin v2.1.0
```

---

## Notes

- `latest` is updated on **every push to main** and on **every version tag**.
- Docker Hub credentials for CI are stored as repo secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_PASSWORD`
