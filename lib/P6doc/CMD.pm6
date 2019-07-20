use P6doc;
use P6doc::Utils;
use P6doc::Index;
use JSON::Fast;

package P6doc::CMD {
	my $PROGRAM-NAME = "p6doc";

    sub USAGE() {
        say q:to/END/;
            p6doc is a tool for reading perl6 documentation.

            Usage:

                p6doc <command> [argument]

            Commands:

                build       build an index for p6doc -f
                list        list the index keys
                env         show information on p6doc's environment

            Examples:

                p6doc Map
                p6doc Map.new
            END
    }

	proto MAIN(|) is export {
		{*}
	}

	multi MAIN(Bool :h(:$help)?) {
		USAGE();

		exit;
	}

	multi sub MAIN($docee, Bool :$n) {
		# On windows, if input is not surrounded by '', it will be malformed
		# Example: `p6doc X::IO` will pass `X:/:IO` to MAIN.
		# This should be checked for and corrected.

		return MAIN($docee, :f, :$n) if defined $docee.index('.');

		say get-docs(locate-module($docee).IO, :package($docee));
	}

	multi sub MAIN($docee, Bool :$f!, Bool :$n) {
		my ($package, $method) = $docee.split('.');
		if ! $method {

			if not INDEX.IO.e {
				say "building index on first run. Please wait...";
				build-index(INDEX);
			}

			my %data = from-json slurp(INDEX);

			my $final-docee = disambiguate-f-search($docee, %data);

			# NOTE: This is a temporary fix, since disambiguate-f-search
			#       does not properly handle independent routines right now.
			if $final-docee eq '' {
				$final-docee = ('independent-routines', $docee).join('.');
			}

			($package, $method) = $final-docee.split('.');

			my $m = locate-module($package);

			say get-docs($m.IO, :section($method), :$package);
		} else {
			my $m = locate-module($package);

			say get-docs($m.IO, :section($method), :$package);
		}
	}

	multi sub MAIN(Bool :$l!) {
		my @paths = search-paths() X~ <Type/ Language/>;
		my @modules;
		for @paths -> $dir {
			for dir($dir).sort -> $file {
				@modules.push: $file.basename.subst( '.'~$file.extension,'') if $file.IO.f;
			}
		}
		@modules.append: list-installed().map(*.name);
		.say for @modules.unique.sort;
	}

	multi sub MAIN(Str $file where $file.IO.e, Bool :$n) {
		say get-docs($file.IO);
	}

	# index related
	multi sub MAIN('env') {
		my Str $index-info = "Index file: {INDEX}";
		my Str $doc-info = "Doc folder: {get-doc-locations}";

		say $index-info;
		say $doc-info;
	}

	multi sub MAIN('build') {
		say "Building index file...";
		build-index(INDEX);
	}
}
