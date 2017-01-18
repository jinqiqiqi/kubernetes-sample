#!/bin/bash
#set -o pipefail
set -u
set -e

# See https://www.amazon.com/sendtokindle
FROM="jinqiqiqi@163.com"
TO="jinqiqiqi_11@kindle.cn"

is_mobi() {
	test "$(dd if="$1" bs=1 skip=60 count=8 status=none)" = "BOOKMOBI"
}

send_book() {
	local book="$1"

	echo "yo" | mailx -v -s "hey" -r "$FROM" -a "$book" $TO
}

to_mobi() {
	local book="$1"
	local nbook="$2"
	local out=$(basename "$nbook")

	kindlegen "$book" -c1 -o "$out"
}

get_encoding() {
	sed 's/^.*encoding="\([^"]*\)".*$/\1/' | tr 'A-Z' 'a-z'
	true
}

# This fixes FB2 encoding if it's not utf-8.
# Works with .zip files, too.
fix_encoding() {
	local book="$1"
	local cat=cat
	local zip=cat
	local enc
	local mt

	mt=$(file --brief --mime-type "$book")
	if [ "$mt" = "application/zip" ]; then
		cat="unzip -p"
		zip="zip"
	fi

	enc=$($cat "$book" | head -1 | get_encoding)

	test -z "$enc" && return 0
	test "$enc" = "utf-8" && return 0

	# Need to convert
	echo "Recoding to utf-8..."
	mv "$book" "${book}.old" && \
		$cat "${book}.old" | iconv -f "$enc" | \
		sed '1s/encoding="[^"]*"/encoding="utf-8"/' | \
		$zip > "$book"
}

process_book() {
	local book="$1"
	local mt
	local nbook

	# First, hanlde non-utf8 files
	fix_encoding "$book"

	# Now, dance around to convert to mobi
	while
		mt=$(file --brief --mime-type "$book")
		case "$mt" in
		    application/xml)
			# FB2, need to zip it to make kindlegen happy
			echo "Zipping fb2..."
			nbook="${book}.zip"
			rm -f "$nbook"
			zip "$nbook" "$book"
			;;
		    application/zip)
			# fb2.zip, need to convert to mobi
			echo "Converting to mobi..."
			nbook="${book}.mobi"
			rm -f "$nbook"
			to_mobi "$book" "$nbook"
			;;
		    application/octet-stream)
			if ! is_mobi "$book"; then
				echo "Hmm, what's $book?" 1>&2
			fi

			nbook=
			echo "Sending ..."
			send_book "$book"
			;;
		    *)
			echo "Can't figure out format of $book: $mt" 1>&2
			return 1
		esac
		book="$nbook"
		[ -n "$book" ]
	do :; done
}

for B in "$@"; do
	process_book "$B"
done