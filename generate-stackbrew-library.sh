#!/usr/bin/env bash
set -Eeuo pipefail

# Keep the floating aliases on the newest maintained Redis release branches.
declare -A aliases=(
	[8]='latest'
	[7.4]='7'
	[6.2]='6'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
IFS=$'\n'; versions=( $(printf '%s\n' "${versions[@]}" | sort -rV) ); unset IFS

fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit Dockerfile $(git show HEAD:./Dockerfile | awk '
			toupper($1) == "COPY" { for (i = 2; i < NF; i++) print $i }
		')
	)
}

getArches() {
	local repo="$1" officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'
	eval "declare -A -g parentRepoToArches=( $(
		find . -name 'Dockerfile' -exec awk '
			toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ { print "'"$officialImagesUrl"'" $2 }
		' '{}' + | sort -u | xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
	) )"
}
getArches redis

cat <<-EOH
# Generated via https://github.com/buluma/redis/blob/$(fileCommit "$self")/$self

Maintainers: Michael Buluma (@buluma)
GitRepo: https://github.com/buluma/redis.git
EOH

join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version in "${versions[@]}"; do
	for variant in '' alpine; do
		dir="$version${variant:+/$variant}"
		[ -f "$dir/Dockerfile" ] || continue

		commit="$(dirCommit "$dir")"
		fullVersion="$(git show "$commit":"$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "REDIS_VERSION" { print $3; exit }')"
		versionAliases=()
		while [ "$fullVersion" != "$version" ] && [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
			versionAliases+=( "$fullVersion" )
			fullVersion="${fullVersion%[.-]*}"
		done
		versionAliases+=( "$version" ${aliases[$version]:-} )

		if [ -n "$variant" ]; then
			variantAliases=( "${versionAliases[@]/%/-$variant}" )
			variantAliases=( "${variantAliases[@]//latest-/}" )
		else
			variantAliases=( "${versionAliases[@]}" )
		fi

		parent="$(awk 'toupper($1) == "FROM" { print $2; exit }' "$dir/Dockerfile")"
		arches="${parentRepoToArches[$parent]}"
		suite="${parent#*:}"
		suite="${suite%-slim}"
		[ "$variant" != alpine ] || suite="alpine$suite"
		suiteAliases=( "${versionAliases[@]/%/-$suite}" )
		suiteAliases=( "${suiteAliases[@]//latest-/}" )
		variantAliases+=( "${suiteAliases[@]}" )

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			Architectures: $(join ', ' $arches)
			GitCommit: $commit
			Directory: $dir
		EOE
	done
done
