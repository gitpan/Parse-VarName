package Parse::VarName;

use 5.010;
use strict;
use warnings;

use Exporter::Lite;
our @EXPORT_OK = qw(split_varname_words);

our $VERSION = '0.01'; # VERSION

our %SPEC;

# cannot be put inside sub, warning "Variable %s will not stay shared"
my @res;

$SPEC{split_varname_words} = {
    v => 1.1,
    summary => 'Split words found in variable name',
    description => <<'_',

Try to split words found in a variable name, e.g. mTime -> [m, Time], foo1Bar ->
[foo, 1, Bar], Foo::barBaz::Qux2 -> [Foo, bar, Baz, Qux, 2].

_
    args => {
        varname => {
            schema => 'str*',
            req => 1,
            pos => 1,
        },
        include_sep => {
            summary => 'Whether to include non-alphanum separator in result',
            description => <<'_',

For example, under include_sep=true, Foo::barBaz::Qux2 -> [Foo, ::, bar, Baz,
::, Qux, 2].

_
            schema => [bool => {default=>0}],
        },
    },
    result_naked => 1,
};
sub split_varname_words {
    my %args = @_;
    my $v = $args{varname} or return [400, "Please specify varname"];

    #no warnings;
    @res = ();
    $v =~ m!\A(?:
                (
                    [A-Z][A-Z]+ |
                    [A-Z][a-z]+ |
                    [a-z]+ |
                    [0-9]+ |
                    [^A-Za-z0-9]+
                )
                (?{ push @res, $1 })
            )+\z!sxg
                or return [];
    unless ($args{include_sep}) {
        @res = grep {/[A-Za-z0-9]/} @res;
    }

    \@res;
}

1;
# ABSTRACT: Routines to parse variable name


__END__
=pod

=head1 NAME

Parse::VarName - Routines to parse variable name

=head1 VERSION

version 0.01

=head1 DESCRIPTION


This module has L<Rinci> metadata.

=head1 FUNCTIONS


None are exported by default, but they are exportable.

=head2 split_varname_words(%args) -> any

Split words found in variable name.

Try to split words found in a variable name, e.g. mTime -> [m, Time], foo1Bar ->
[foo, 1, Bar], Foo::barBaz::Qux2 -> [Foo, bar, Baz, Qux, 2].

Arguments ('*' denotes required arguments):

=over 4

=item * B<include_sep> => I<bool> (default: 0)

Whether to include non-alphanum separator in result.

For example, under include_sep=true, Foo::barBaz::Qux2 -> [Foo, ::, bar, Baz,
::, Qux, 2].

=item * B<varname>* => I<str>

=back

Return value:

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

