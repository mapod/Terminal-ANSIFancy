Terminal::ANSIFancy
===================

Formatted strings using ANSI escape sequences.

Synopsis
--------
```perl6
use Terminal::ANSIFancy;

my $foo = fancy 'this is bold and blue', :bold, :fg<blue>;

say $foo; # [1;34mthis is bold and blue[0m

say fanciness $foo; # <bold blue>

$foo = unfancy $foo;
$foo ~~ s!" is "! is not !;

say $foo; # this is not bold and blue
```

Description
-----------
Terminal::ANSIFancy provides an interface for generating
fancy text intended for terminals.

See doc/Terminal/ANSIFancy.pod6 for more info.

License
-------
Artistic 2.0 (the same as Perl 6)
