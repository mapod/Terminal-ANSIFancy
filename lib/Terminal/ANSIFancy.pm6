use v6;

unit module Terminal::ANSIFancy:ver<0.1>;

#
# This module may be distributed under the Artistic 2.0 license
#

#
# If you are going to read the code, read the documentation first,
#  if you haven't already.
# Make sure you understand Perl 6's type system, grammars, and
#  named function arguments. If you don't, go read the Perl 6
#  documentation on those.
# Next, read the types below.
# At this point, you might want to gloss over the Style grammar.
# After that, you should read the source from the bottom up,
#  starting with fancy()
#


#
# Internals:
#


# words corresponding to a numbers for ANSI escapes
constant attributes-basic is export(:internals) = %(
	reset         => '0',
	bold          => '1',
	dark          => '2',
	italic        => '3',
	underline     => '4',
	blink         => '5',
	inverse       => '7',
	hide          => '8',
	unbold        => '22',
	unitalic      => '23',
	ununderline   => '24',
	unblink       => '25',
	uninvert      => '27');

# different spellings of attributes-basic
constant attributes-extra is export(:internals) = %(
	bolded        => '1',
	dim           => '2',
	italicised    => '3',
	underlined    => '4',
	blinking      => '5',
	invert        => '7',
	inverse       => '7',
	hidden        => '8',
	unbolded      => '22',
	ununderlined  => '24',
	unitalicised  => '23',
	unblinking    => '25',
	uninverted    => '27');

# all of the words corresponding to a numbers for ANSI escapes
constant attributes is export(:internals) = %(attributes-basic, attributes-extra);

# the units column for the colors
constant colors is export(:internals) = %(
	black      => '0',
	red        => '1',
	green      => '2',
	yellow     => '3',
	blue       => '4',
	magenta    => '5',
	cyan       => '6',
	white      => '7',
	normal     => '9',
	default    => '9');

# [back|fore]ground colors
constant fg-colors        is export(:internals) = %( colors.map: { $_.key => 3  ~ $_.value } );
constant bg-colors        is export(:internals) = %( colors.map: { $_.key => 4  ~ $_.value } );
constant fg-bright-colors is export(:internals) = %( colors.map: { "bright $($_.key)" => 9  ~ $_.value } );
constant bg-bright-colors is export(:internals) = %( colors.map: { "bright $($_.key)" => 10 ~ $_.value } );
constant fg16-colors      is export(:internals) = %( fg-colors, fg-bright-colors );
constant bg16-colors      is export(:internals) = %( bg-colors, bg-bright-colors );


# The type check is run even when it is undefined.
# Would it be better for !.defined to be implicit, and .defined be explicit???
subset Color8    is export(:internals) of Str where ! .defined || "$_" (elem) colors;
subset Color16   is export(:internals)        where ! .defined || "$_" (elem) colors
                                                               || "$_".subst(/^ bright \s /, '') (elem) colors
                                                               || ($_[0] eq 'bright' && "$_[1]" (elem) colors);
subset Attribute is export(:internals) of Str where ! .defined || "$_" (elem) attributes;

# inverse hashes
constant fg-nums        is export(:internals) = %( fg-colors.map:        { $_.value => $_.key } );
constant bg-nums        is export(:internals) = %( bg-colors.map:        { $_.value => 'on ' ~ $_.key } );
constant fg-bright-nums is export(:internals) = %( fg-bright-colors.map: { $_.value => $_.key } );
constant bg-bright-nums is export(:internals) = %( bg-bright-colors.map: { $_.value => 'on ' ~ $_.key } );
constant attribute-nums is export(:internals) = %( attributes-basic.map: { $_.value => $_.key } );
constant nums           is export(:internals) = %( fg-nums, bg-nums, fg-bright-nums, bg-bright-nums, attribute-nums );
# apparently, we "Can't use unknown trait 'is export' in a regex declaration."
constant escape-sequence = rx{ "\e[" [ $<nums> = (<[0..9]>+) ';'? ]* "m" };

subset Escape    is export(:internals) of Str where ! .defined || $_ eq '' || $_ ~~ escape-sequence;

sub fancy-escape (*@a) returns Escape is export(:internals)
#= Generate escape sequences from a list of numbers
{
	@a.elems > 0 ?? "\e[" ~ @a.join(';') ~ "m" !! ''
}


#
# Style:
#


grammar Style is export(:style) {

	token TOP                      { <expr>* }

	rule  expr                     { <term> ','? }

    proto rule term                { * }
          rule term:sym<fg-color>  { <color16> }
          rule term:sym<bg-color>  { 'on' <color16> }
          rule term:sym<attribute> { <attribute> }

	proto rule color16             { * }
	      rule color16:sym<normal> { <basecolor> }
	      rule color16:sym<bright> { 'bright' <basecolor> }

	token basecolor                { @(colors.keys) }
	token attribute                { @(attributes.keys) }
	token ws                       { [ \s | '_' | 'and' ]* }

}

class StyleToNums is export(:style) {

    method TOP                 ($/) { make $<expr>>>.made }

	method expr                ($/) { make ~$<term>.made }
	
    method term:sym<fg-color>  ($/) { make fg16-colors{ ~$<color16>.made } }
    method term:sym<bg-color>  ($/) { make bg16-colors{ ~$<color16>.made } }
    method term:sym<attribute> ($/) { make  attributes{ ~$<attribute> } }

	method color16:sym<normal> ($/) { make ~$<basecolor> }
	method color16:sym<bright> ($/) { make 'bright ' ~ $<basecolor> }

}

subset StyleStr is export(:style) where ! .defined || Style.parse: $_.join(' ');


#
# Exported:
#


#| Adds ANSI escapes to each args,
#| or just returns the escape sequence if no args are provided.
sub fancy (**@args,
           Bool :$reset,   Bool :$bold,   Bool :$underline,
		   Bool :$inverse, Bool :$italic,
           Color16 :$fg,   Color16 :$bg,
           Color16 :$fg16, Color16 :$bg16,
           Color8  :$fg8,  Color8  :$bg8,
           StyleStr :$style) returns Str is export
{

	my @rez;
	@rez.push: attributes<reset>     if $reset;
	@rez.push: attributes<bold>      if $bold;
	@rez.push: attributes<underline> if $underline;
	@rez.push: attributes<italic>    if $italic;
	@rez.push: attributes<invert>    if $inverse;
	# user explicitly un.*?s. i.e. bold=>False
	@rez.push: attributes<unbold>      if      $bold.defined and not $bold;
	@rez.push: attributes<ununderline> if $underline.defined and not $underline;
	@rez.push: attributes<unitalic>    if    $italic.defined and not $italic;
	@rez.push: attributes<uninvert>    if   $inverse.defined and not $inverse;


	@rez.push: fg16-colors{   $fg.join(' ') } if $fg.defined;
	@rez.push: bg16-colors{   $bg.join(' ') } if $bg.defined;
	@rez.push:   fg-colors{  $fg8           } if $fg8.defined;
	@rez.push:   bg-colors{  $bg8           } if $bg8.defined;
	@rez.push: fg16-colors{ $fg16.join(' ') } if $fg16.defined;
	@rez.push: bg16-colors{ $bg16.join(' ') } if $bg16.defined;

	@rez.push: | Style.parse($style.join(' '), actions => StyleToNums).made
	             if $style.defined;
	
	my $dostyle = fancy-escape @rez;

	my $unstyle = @args.elems > 0 ?? fancy-escape attributes<reset>
	                              !! '';

	return $dostyle ~
	       @args.join($dostyle) ~
	       $unstyle;

}

sub fanciness (Str $fancy, Bool :$compat) returns List is export
#= What fanciness is applied to a string (only the first escape sequence)
{
	given $fancy {
		when escape-sequence {
			$<nums>>>.Str.map({ nums{$_}.trans: ' ' => $compat ?? '_' !! ' ' }).List
		}
		default { () }
	}
}

sub unfancy (**@args) returns Str is export
#= Removes ANSI escapes from it's arguments.
{
	@args.join('').subst: escape-sequence, '', :g
}


#
# Term::ANSIColor:
#


sub color           (*@a           --> Escape) is export(:ANSIColor) { fancy     :style(@a.join: ',') }
multi sub colored   (Str $c, *@a   --> Str)    is export(:ANSIColor) { fancy $c, :style(@a.join: ',') }
multi sub colored   (Array $a, *@c --> Str)    is export(:ANSIColor) { fancy @c, :style($a.join: ',') }
sub colorstrip      (*@c           --> Str)    is export(:ANSIColor) { unfancy @c }
sub uncolor         (Str $s        --> List)   is export(:ANSIColor) { fanciness $s, :compat }
sub colorvalid      (*@c           --> Bool)   is export(:ANSIColor) { Style.parse(@c.join(',')).Bool }
