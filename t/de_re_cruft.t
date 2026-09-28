#!/usr/bin/perl
use strict;
use warnings;

# Test decruft and recruft functions
use URI::Find;
use Test::More tests => 358;

sub run_tasks {
    my $f = URI::Find
        ->new(sub {});

    my @tests =
        map {
            my $expected = shift @$_;
            map {[ $expected, $_ ]} @$_
        }
        map {[
            (ref $_ eq 'ARRAY')
            ? @$_ : ($_, $_)
        ]} @_;

    foreach my $t (@tests) {
        my ($expected, $str) = @$t;
        
        my $decruft = $f->decruft($str);
        is $decruft, $expected, "decruft '$str'";

        my $recruft = $f->recruft($decruft);
        is $recruft, $str, "recruft '$str'"
    }
}

my @tasks = (
    "", " ", 0, 1, -1
    
    , "atom.io"
    , "cpan.org%"
    , "github.com"
    , "perlmonks.org"
    , "http://perl.com"
    , "https://perl.org"
    , "www.perlmaven.com"
    , "www.perlmonks.org"
    , "ftp://myserver.net"
    , "custom://www.x.com"
    , "http://www.perl.com"
    , "ws://super-socket.io"
    , "https://www.zed.dev/"
    , "https://www.zed.dev//"
    , "https://www.zed.dev///"
    , "https://pulsar-edit.dev"
    , "https://duckduckgo.com/"
    , "https://duckduckgo.com/>"
    , "wss://ssl-super-socket.io"
    , "https://medium.com#cake?cache=cheese"
    , "https://duckduckgo.com/?q=raku%20programming"
    , "https://medium.com?cache=x&hash=iofremiovj43v453v4"
    
    , "https://raku.org\t"
    , "\t\thttps://raku.org\t"
    , "https://jobs.perl.org_"
    , "https://jobs.perl.org+"
    , "https://jobs.perl.org+_"
    , "     http://yahoo;.com "
    , "\r\nhttps://dev.perl.org"
    , "\n\nhttps://blogs.perl.org"
    , "\thttps://learn.perl.org#\t"
    , "https://strawberryperl.com\r\n"
    , "https://raku.org/install\t\r\n"
    , "\r\n\r\nhttps://dev.perl.org#?&><"
    , "https://metacpan.org/pod/List::UtilsBy\n"
    , "  ftp://myserver.net. ;https://perl.org;:::"
    , "https://www.perlmonks.org?gov=--3&&perl_v=5006!"
    , "\"\@https://www.perlmonks.org?gov=--3&&perl_v=5006;\@"

    , "ftp://myserver.net🤫"
    , " ftp://myserver.net⚡️  "
    , "⚠️ ftp://myserver.net🤫  "
    , " ⚠️ ftp://myserver.net🏴‍☠️  🔴"
    , "🚨 ftp://myserver.net🏓  🤡  "
    
    , "https://www.perlmonks.org&"
    , "https://www.perlmonks.org["
    , "https://www.perlmonks.org{"
    , "https://www.perlmonks.org("
    , "https://www.perlmonks.org[]"
    , "https://www.perlmonks.org{}"
    , "https://www.perlmonks.org()"

    , "https://www.perlmonks.org?"
    , "https://www.perlmonks.org?["
    , "https://www.perlmonks.org?{"
    , "https://www.perlmonks.org?("
    , "https://www.perlmonks.org?[]"
    , "https://www.perlmonks.org?{}"
    , "https://www.perlmonks.org?()"
    
    , "https://www.perlmonks.org/&"
    , "https://www.perlmonks.org/&["
    , "https://www.perlmonks.org/&{"
    , "https://www.perlmonks.org/&("
    , "https://www.perlmonks.org/&[]"
    , "https://www.perlmonks.org/&{}"
    , "https://www.perlmonks.org/&()"
    
    , "https://www.perlmonks.org//?&"
    , "https://www.perlmonks.org//?&["
    , "https://www.perlmonks.org//?&{"
    , "https://www.perlmonks.org//?&("
    , "https://www.perlmonks.org//?&[]"
    , "https://www.perlmonks.org//?&{}"
    , "https://www.perlmonks.org//?&()"
    
    , "https://www.perlmonks.org??"
    , "https://www.perlmonks.org&?"
    , "https://www.perlmonks.org&&"
    , "https://www.perlmonks.org[  "
    , " https://www.perlmonks.org("
    , "  https://www.perlmonks.org?   "
    , "https://www.perlmonks.org?[  \t"
    , " 🚫https://www.perlmonks.org?[]"
    , " https://www.perlmonks.org?{}  "
    , " https://www.perlmonks.org?{}  \n"
    , " https://www.perlmonks.org?{}  \r\n"
    , "\thttps://www.perlmonks.org?{}  \r\n"
    
    , "https://medium.com?cache=cheese"
    , "https://medium.com?cache=cheese["
    , "https://medium.com?cache=cheese[]"
    
    , "https://medium.com?cache=cheese{"
    , "https://medium.com?cache=cheese{}"
    
    , "https://medium.com?cache=cheese("
    , "https://medium.com?cache=cheese()"
    
    , [
        # Expected result (all tests bellow)
        "https://perl.org",
        
        "https://perl.org;",
        "https://perl.org,",
        "https://perl.org'",
        "https://perl.org]",
        "https://perl.org}",
        "https://perl.org)",
        "https://perl.org]]",
        "https://perl.org}}",
        "https://perl.org))",
        "https://perl.org\"",
        "https://perl.org;,",
        "https://perl.org\",",
        "https://perl.org\"\",",
        "https://perl.org\";,;",
        "https://perl.org';,;'",
        "https://perl.org\"',\",';",
    ]
    
    , [
        "https://www.duckduckgo.com/",
        "https://www.duckduckgo.com/)",
        "https://www.duckduckgo.com/]",
        "https://www.duckduckgo.com/}",
        "https://www.duckduckgo.com/.",
        "https://www.duckduckgo.com/;",
        "https://www.duckduckgo.com/,",
        "https://www.duckduckgo.com/''",
        "https://www.duckduckgo.com/))",
        "https://www.duckduckgo.com/}]",
        "https://www.duckduckgo.com/)]",
        "https://www.duckduckgo.com/\"\"",
    ]

    , [
        "(https://www.cpan.org)",
        "(https://www.cpan.org))",
        "(https://www.cpan.org)))",
        "(https://www.cpan.org))))",

        # Failing recruft
        # "(https://www.cpan.org,)",
        # "(https://www.cpan.org.)",
        # "(https://www.cpan.org;)",
        # "(https://www.cpan.org')",
        # "(https://www.cpan.org),)",
        # "(https://www.cpan.org];])",
        # "(https://www.cpan.org);;)",
        # "(https://www.cpan.org}};})",
        # "(https://www.cpan.org);;)])",
        # "(https://www.cpan.org);;)]}.),)",
        # "(https://www.cpan.org);;)]}.),))",
        # "(https://www.cpan.org);;)]]}.),))",
        # "(https://www.cpan.org);;)]]}.),)'\)",
        # "(https://www.cpan.org);;)]]}.),)'\")",

        # Failing recruft
        # "(https://www.cpan.org])",
        # "(https://www.cpan.org]])",
        # "(https://www.cpan.org]]])",
        # "(https://www.cpan.org]]]])",
        
        # Failing recruft
        # "(https://www.cpan.org})",
        # "(https://www.cpan.org}})",
        # "(https://www.cpan.org}}})",
        # "(https://www.cpan.org}}}})",
        
        # Failing recruft
        # "(https://www.cpan.org}])",
        # "(https://www.cpan.org)])",
        # "(https://www.cpan.org)})",
        
        # Failing recruft
        # "(https://www.cpan.org]]])",
        # "(https://www.cpan.org]}])",
        # "(https://www.cpan.org)}]})",
        # "(https://www.cpan.org))}]})",
        # "(https://www.cpan.org))))}]})",
        # "(https://www.cpan.org))))}]}))",
        # "(https://www.cpan.org))))}])}))",

        # Failing recruft
        # Failing decruft (?)
        # "(https://www.cpan.org)))",
        # "(https://www.cpan.org))}",
        # "(https://www.cpan.org))]",
        # "(https://www.cpan.org))(",
        # "(https://www.cpan.org)[}",
        # "(https://www.cpan.org)}[",
        # "(https://www.cpan.org)[)]",
        # "(https://www.cpan.org)')'",
        # "(https://www.cpan.org);;)}",
        # "(https://www.cpan.org);;)]",
        # "(https://www.cpan.org]]]])]",
        # "(https://www.cpan.org)\")\"",
        # "(https://www.cpan.org)'\")\"'",
        # "(https://www.cpan.org);;)]}.),)'",
        # "(https://www.cpan.org);;)]}.),)..",
        # "(https://www.cpan.org);;)]}.),)''",
        # "(https://www.cpan.org);;)]]}.),)'\"]",
    ]

    , [
        "https://www.perlmonks.org?gov=--3&&perl_v=5006",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006.",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006'",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006\"",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;;",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;;,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,;;,",
    ]

    , [
        " \n==>>\"https://download.torproject.org/#?&&??&",
        " \n==>>\"https://download.torproject.org/#?&&??&.\"",
        " \n==>>\"https://download.torproject.org/#?&&??&,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&;\"",
        " \n==>>\"https://download.torproject.org/#?&&??&'\"",
        " \n==>>\"https://download.torproject.org/#?&&??&\"\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..\"",
        " \n==>>\"https://download.torproject.org/#?&&??&,,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&;.\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.;\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..\"\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.;\"\"",
    ]

    , [
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org.",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org,",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org..",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org,\"",
    ]

    , [
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///.",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///,",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///;",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///\"\"",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///''",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///.............",
    ]

    , [
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar)",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar}",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]}",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]]",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]})",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]..",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar]]})",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar)..\";.]]'\",})",
        "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar)..\";.]]'\",})",

    #     # FAILED (?)
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar[",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar(",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar{",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar{.",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar['",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar[,",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar(]}",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar[\"",
    #     # "https://learnxinyminutes.com/perl?user[]=foo&user[]=bar(\"",
    ]

    , [
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&'",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\"",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&'.",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&,,",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\"\"",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\";,",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&',;'",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&',,'",
    ]

    , [
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be...",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be'...",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be\"...,",
    ]
);

run_tasks @tasks;
done_testing();
1
