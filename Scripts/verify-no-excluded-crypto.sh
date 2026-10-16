#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_search_root="${1:-$repository_root/Src}"
forbidden_manifest_pattern='<PackageReference[^>]+Include="(NSec\.Cryptography|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle|BouncyCastle\.Cryptography)"|<PackageVersion[^>]+Include="(NSec\.Cryptography|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle|BouncyCastle\.Cryptography)"'

if [[ ! -d "$package_search_root" ]]; then
  echo "Package search directory does not exist: $package_search_root"
  exit 1
fi

manifest_matches="$(find "$repository_root" \
  -path '*/bin' -prune -o \
  -path '*/obj' -prune -o \
  \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' -o -name 'packages.lock.json' \) \
  -type f -exec grep -EinH "$forbidden_manifest_pattern" {} + || true)"

if [[ -n "$manifest_matches" ]]; then
  echo "Excluded cryptography dependency found in project metadata:"
  echo "$manifest_matches"
  exit 1
fi

assets_matches="$(find "$repository_root" -path '*/obj/project.assets.json' -type f \
  -exec grep -EinH 'NSec\.Cryptography|libsodium|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle' {} + || true)"

if [[ -n "$assets_matches" ]]; then
  echo "Excluded cryptography dependency found in restored dependency assets:"
  echo "$assets_matches"
  exit 1
fi

package_count=0
while IFS= read -r package; do
  package_count=$((package_count + 1))
  if unzip -l "$package" | grep -Eiq 'NSec|libsodium|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle'; then
    echo "Excluded cryptography asset found in package: $package"
    unzip -l "$package" | grep -Ei 'NSec|libsodium|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle' || true
    exit 1
  fi

  if unzip -p "$package" '*.nuspec' | grep -Eiq '<dependency id="(NSec\.Cryptography|Sodium\.Core|BouncyCastle|Portable\.BouncyCastle|BouncyCastle\.Cryptography)"'; then
    echo "Excluded cryptography dependency found in package manifest: $package"
    exit 1
  fi
done < <(find "$package_search_root" -name '*.nupkg' -type f)

echo "Excluded-crypto audit passed (checked source metadata, restored assets, and $package_count package files)."
