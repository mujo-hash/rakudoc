unit module P6doc::Utils;

our @sys-doc-locations = ($*REPO.repo-chain()>>.Str X~ "{$*SPEC.dir-sep}doc{$*SPEC.dir-sep}").grep: *.IO.d;
our @test-doc-locations is export = $*CWD.add("{$*SPEC.dir-sep}t{$*SPEC.dir-sep}testdata{$*SPEC.dir-sep}mini-doc{$*SPEC.dir-sep}test-doc").grep: *.IO;

sub get-doc-locations(Bool $test = True) is export {
	if $test {
		return @test-doc-locations
	} else {
		return @sys-doc-locations
	}
}

sub search-paths() is export {
	#return (('.', |$*REPO.repo-chain())>>.Str X~ </doc/>).grep: *.IO.d;
	return (('.', |$*CWD)>>.Str X~ </t/testdata/mini-doc/test-doc/>).grep: *.IO.d;
}

sub findbin() returns IO::Path is export {
	$*PROGRAM.parent;
}
