release_version := $(shell git describe --tags)

share/man/man1/nodenv.1: share/man/man1/nodenv.1.adoc
	asciidoctor -b manpage -a version=$(release_version:v%=%) $<
