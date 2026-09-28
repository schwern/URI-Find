package URI::Find::Testing;
use base 'Exporter';

our @EXPORT = qw/
    simple_escape
    get_filter_tests
    get_non_escape_filter_tests
/;

my @replacements = (
    # Simple cases
    qw/xx& &&&* URL/
    , '&&* *&&'
    , '{CENSORED}'
    , '^CENSORED^'
    , '     &&* *&& '
    , ' <<!!>> CENSORED <<!!>> '

    # Special cases (Perl, PHP, PostgreSQL & others)
    , qw/$1 $0 $_ \1 \\1 \\\1 \\\\1/
    , '${$url $str $input} ${exit 0;} $${die}'

    # URL's
    , qw{www.x.com nsa.gov https://nsa.gov http://yahoo.com}
    , qw{https://www.nsa.gov http://perl.org file:///:C/users/ronald}
    , 'Broken, please report this at https://nsa.gov?report=broken-link'

    # Emojis
    , qw/😖 ⚠️ ‼️ ⚡️ 🚨 😲 🤓 ☣️ ☠️ 💀 🏴‍☠️ ⛓️‍💥 😡 🔴 😩 💻 👨🏻‍💻/
    , '⛓️‍💥 Sorry, broken link ⛓️‍💥'
    , '🚫🚫🚫🚫 CENSORED 😕⚠️⚠️⚠️⚠️'

    # HTML
    , qw/&amp; &AMP; &num;&num;&num;CENSORED/
    , '<strong style="color: red !important">CENSORED</strong>'

    # Multiline
    , qq/
        Curabitur sodales, neque non posuere rhoncus, libero
        faucibus ligula eget imperdiet aliquet. Vivamus sed.

        Curabitur lorem nisl, viverra non sollicitudin a, 
        eget, faucibus est. Quisque at ex id augue blandit.
    /
    , qq^
        <session class="censored-content-banner">
            <img class="angry-bird" src="assets/img/angry-eagle.gif"/>
            <h4 class="censorship-title">🚨🚨 Censored</h4>
            <p class="last-warning">
                😰 ###You have reached the 'limits' of insanity inside the internet.&nbsp;
                🔥 **We believe that you are under too much stress.&NonBreakingSpace;
                😎☀️ (((Please, stop programming and relax a little on the links bellow.&amp;&AMP;
            </p>

            <!-- A comment,, because why not 🤷🏻
                    -->
        </session>
    ^

    # , undef ERROR
    , 0, 1, -1
    , 1_001.00
    , 1_001, -1_001
    , 1_001.0606965
    , -1_001.2342
);

my @non_rep_tests = (
    ["Zero", 0]
    # , ["Undef", undef]
    , ["Empty string", ""]
    , ["Simple quote", "'"]
    , ["Double quote", q/'/]
    , ["Double quote", q/"/]
    , ["Not a number", "NaN"]
    
    , ["&", "&", "&amp;"]
    , ["&amp;", "&amp;", "&amp;amp;"]
    , ["&AMP;", "&AMP;", "&amp;AMP;"]
    
    , ["Emoji", "😎"]
    , ["Emoji + &", "‼️&", "‼️&amp;"]
    , ["Emoji + &amp;", "🌞&amp;", "🌞&amp;amp;"]
    
    , ["Emojis", " 🔥 ☀️ 💻 🏁 🤡 ⛓️‍💥"]
    , ["Text with Emojis", " 👨🏻‍💻 A job well done  "]
    
    , ["Perl ref", do { "" . \(my $ref) }]
    , ["Perl hash ref", do { "" . \(my %ref) }]
    , ["Perl array ref", do { "" . \(my @ref) }]
    
    , ["One", 1]
    , ["One one one", 111]
    , ["One one one, dot one", 111.1]
    , ["One one one, dot one one one", 111.111]
    , ["One underline one one one, dot one one one", 1_111.111]
    
    , ["Minus one", -1]
    , ["Minus one one one", -111]
    , ["Minus one one one, dot one", -111.1]
    , ["Minus one one one, dot one one one", -111.111]
    , ["Minus one underline one one one, dot one one one", -1_111.111]
    
    , ["Number (string)", "42"]
    , ["High Number (string)", "42343334"]
    , ["Negative Number (string)", "-42"]
    , ["High negative Number (string)", "-42"]
    
    , ["Money, no space", "\$42"]
    , ["Money, with space", "\$ 42"]
    , ["Money, cents", "\$ 42,67"]
    , ["Money, 4 cents digits", "\$ 42,6732"]
    , ["Money, high value", "\$ 42 032"]
    , ["Money, high value, cents", "\$ 426 329 404,88"]
);

my @full_rep_tests = ([
    "Simple URL filtering, 'www.' included"
    , "http://www.perl.com"
],[
    "Simple URL filtering, 'www.' included, small URL"
    , "http://www.x.com"
],[
    "Simple URL filtering, small URL"
    , "https://x.com",   
],[
    "Simple URL filtering, schema http://"
    , "http://perl.org"
],[
    "Simple URL filtering, schema ftp://"
    , "ftp://old-is-cool.net/update"
],[
    "Simple URL filtering, schema https://"
    , "https://google.com"
],[
    "Simple URL filtering, with &amp;"
    , "ftp://perl.org&amp;"
],[
    "Simple URL filtering, with params"
    , "https://www.vim.org/users/trust-me-bro"
],[
    "Simple URL filtering, with query params"
    , "https://www.kali.org?foo=bar"
],[
    "Simple URL filtering, with multiple query params"
    , "https://zed.dev?foo=bar&baz=quxxxx"
],[
    "Simple URL filtering, with param + query params"
    , "https://www.vim.org/users/george?foo=bar&baz=qux"
],[
    "Simple file path filtering (Windows .txt)"
    , "file:///C:/suggestions/movies.txt"
],[
    "Simple file path filtering (Windows .exe)"
    , "file:///C:/folder/32034499absolute-safe_executable.exe"
],[
    "Simple file path filtering (Mac .crash)"
    , "file://Users/gerald/cheese.crash"
],[
    "Simple file path filtering (Linux .pl)"
    , "file:///home/ronald/perl/absolute-perl/main.pl"
]);

my @rep_tests = ([
    "Emojis + &"
    , " 🔥 & ☀️& 💻 & 🏁 🤡 ⛓️‍💥"
    , " 🔥 &amp; ☀️&amp; 💻 &amp; 🏁 🤡 ⛓️‍💥"
],[
    "Simple URL filtering, 'www.' included, no schema"
    , "www.perl.com"
],[
    "Simple URL filtering, 'www.' included, small URL, no schema"
    , "www.x.com"
],[
    "Thing which looks like a URL but isn't"
    , "noturi:&amp; should also be escaped"
    , "noturi:&amp;amp; should also be escaped"
],[
    "Thing which looks like a URL inside brackets, but isn't"
    , "Something & <foo://bar&.com> whatever"
    , "Something &amp; <foo://bar&amp;.com> whatever"
],[
    "Non-URL nested inside brackets"
    , q{<a href="foo://example&.com">}
    , q{<a href="foo://example&amp;.com">}
]

# Issue #17 (https://github.com/schwern/URI-Find/issues/17)
,[
    "Non-URL, with one backslash after the schema, instead of two"
    , q{ http:\/example.com }
    , q{ http:\/example.com }
]);

sub get_filter_tests {
    my @tests;
    
    my $non_rep_cb = sub { $_[0] };
    add_tests($non_rep_cb, \@tests, \@non_rep_tests);

    foreach my $r (@replacements) {
        my $rep_cb = sub { $r };
        add_tests($rep_cb, \@tests, \@full_rep_tests, $r);
        add_tests($rep_cb, \@tests, \@rep_tests)
    }

    @tests
}

sub get_non_escape_filter_tests {
    my @tests = get_filter_tests();
    grep { $$_[1] !~ /&/o } @tests
}

sub simple_escape {
    my ($toencode) = @_;
    $toencode =~ s{&}{&amp;}gso;
    return $toencode;
}

sub add_tests {
    my $callback  = shift;
    my $tests_ref = shift;
    
    my $input_ref = shift;
    my @new_tests = @$input_ref;
    
    if (@_ > 0) {
        my $expected = shift;
        
        @new_tests =
            map {[ @$_, $expected ]}
            @new_tests
    }

    foreach my $t (@new_tests) {
        my ($msg, $input) = @$t;
            
        push @$tests_ref, [
            $msg, $input, $callback,
            (exists $$t[2] ? $$t[2] : $input)
        ]
    }
}

1
