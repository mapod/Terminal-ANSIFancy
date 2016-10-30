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


Todo
----

Looking for things to do?
These are all incomplete or nonexistant:

* documentation; anyone can help with this.

* option to extend the style language,
```perl6
fancy style-grammar => StyleGrammarWithExtraBits,
      style-actions => StyleActionsWithExtraBits;
```

* 216-color: interface would be:
   - `:fg216<r g b>` (ex. :fg216<6 6 6> is white)
   - `:fg<r g b>`
   - `:style<rgb(0 6 0)>` is green.
   - maybe??? implement riddiculous `:style<some red, mostly blue, and a little green on all green, bold>`

* terminal knowledge (`%*ENV<TERM>` and terminfo?)
   - disable with `:!check`
   - don't disable coloring, just decide
     whether to use 8, 16, or 216 colors,
     unless the user explicitly enables with `:check`
   - not for anything that explicitly defines the number of colors anyway
     like `:fg8` or `:fg16`


License
-------
Artistic 2.0 (the same as Perl 6)
