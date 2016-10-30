use v6;

use Test;
plan 9; # best OS ever...

use Terminal::ANSIFancy :ALL;

is-deeply (fancy :bold),
          (fancy-escape attributes<bold>),
          'fancy() should work.';

is-deeply (unfancy fancy :reset, :!bold, :underline, :inverse, :bg<red>, :fg<magenta>, :style<yellow on blue, bold>, 'Testing...'),
          'Testing...',
          'unfancy() shold return a string with escape sequences removed.';

is-deeply (fanciness fancy :style<yellow on bright blue, bold>),
          ('yellow', 'on bright blue', 'bold'),
          'fanciness() should do what it\'s supposed to.';

is-deeply (color 'blue'),
          (fancy :fg<blue>),
          'color() should work.';

is-deeply (colored ['blue'], 'hello'),
          (fancy :fg<blue>, 'hello'),
          'colored([\'color\'], $whatever) should work.';

is-deeply (colored 'hello', 'blue'),
          (fancy :fg<blue>, 'hello'),
          'colored($whatever, \'color\') should work.';

is-deeply (uncolor fancy :style<yellow on bright blue, bold>),
          ('yellow', 'on_bright_blue', 'bold'),
          'uncolor() should do what it\'s supposed to.';

ok        (colorvalid 'bold, blue on bright red'),
          'colorvalid() should return true when given a good style.';

nok       (colorvalid 'not a valid style'),
          'colorvalid() should return false when given a bad style.';

