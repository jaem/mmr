#!/opt/local/bin/perl

=head
Test case put together to work out how to access nested data structures using
the dor notation inside a foreach loop.

I accidently came across answer after using Dumper to display the variable content.
It seems there are key and value tags that can be used to access this data.

See the example below.

=cut

#http://template-toolkit.org/docs/manual/Variables.html
#http://mail.template-toolkit.org/pipermail/templates/2005-June/007501.html
#http://template-toolkit.org/docs/tutorial/Datafile.html
#http://search.cpan.org/~abw/Template-Toolkit-2.26/lib/Template/Iterator.pm

use Template;
use Data::Dumper;

my %data = (
  header => 'This could be a header',
  footer => 'This could be a footer',
  teams  => {
    0 => { name => goat0, wins => 33, deeper => {canwe => 0}},
    1 => { name => goat1, wins => 1 , deeper => {canwe => 11} },
    2 => { name => goat2, wins => 0 , deeper => {canwe => 22}}
  },
  trysort => {
    xx => {status => 11},
    aa => {status => 21},
    mm => {status => 31},
    dd => {status => 41},
  },
  trysort2 => {
    6 => {status => 11},
    3 => {status => 21},
    5 => {status => 31},
    0 => {status => 41},
  }
);

print Dumper(\%data);

my $tt = Template->new( { EVAL_PERL => 1, INTERPOLATE => 1} ) || die $Template::ERROR, "\n";

# file handle (GLOB)
$tt->process( \*DATA, \%data ) || die $tt->error(), "\n";

__END__
Direct Access = [% teams.m0.name %]
Direct Access = [% teams.m1.name %]
Direct Access = [% teams.m2.name %]
[% FOREACH team IN teams -%]
# I tried all these,
InLoop = [% team %] [% loop.size -%] == [% team.name %]
InLoop = [% team -%] == [% ${team}.name %]
InLoop = [% team -%] == [% teams.${team}.name %]
InLoop = [% team -%] == [% \$team.name %]
InLoop = [% team -%] == [% get(teams.team).name %]
# But only this one works....note .value must be used.
InLoop = [% team -%] == [% team.value.name %] [% team.value.deeper.canwe %] and Key = [% team.key %]
Dump data using regular PERL
   [% PERL %]
   use Data::Dumper;
   # So I can access team using stash and operate on using regular PERL
   print Dumper $stash->get('team');
   [% END -%] 
[% END -%]
# Check that we can sort the keys to foreach
[% FOREACH team IN trysort2.keys.nsort -%]
InLoop = [% team %] 
[% END -%]
[% FOREACH team IN trysort.keys.sort -%]
InLoop = [% team %] 
[% END -%]
[% header %]
This is a template defined in the __END__ section which is accessible via the DATA "file handle".
[% footer %]
