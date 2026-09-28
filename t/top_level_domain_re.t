#!/usr/bin/perl
use strict;
use warnings;

use URI::Find::Schemeless;
use Test::More 'no_plan';

my $callback = sub { $_[0] };
my $f = URI::Find::Schemeless->new($callback);
my $regex = $f->top_level_domain_re;

is(
    ref $regex, 'Regexp'
    , 'URI::Find::Schemeless::top_level_domain_re returns a regex'
);

my @match_tests = (
    'foo.xyz'
    , 'russia'
    , 'RUSSIA'
    , 'rOMaNIA'
    , 'main.pl'
    , 'tirol.au'
    , 'perl.org'
    , 'pERL.ORG'
    , ' php.net '
    , 'education'
    , 'government'
    , 'COMMERCIAL'
    , 'GOVERNMENT'
    , 'EDUCATION'
    , 'https://perl.com'
    , 'HTTPS://PERL.COM'
    , 'medium.  computer'
    , 'MAILTO:SOMEBODY@COMPANY.EXT'
    , "multiline\n text\nwith gov.ro \\n"

    , 'http://lk.ලංකා'
    , 'http://520.我爱你'
    , 'http://ncc.سودان'
    , 'http://cnnic.中國'
    , 'http://baidu.世界'
    , 'http://lk.இலங்கை'
    , 'http://testing.測試'
    , 'http://cst.السعودية'
    , 'http://hostmaster.укр'
    , '===><<testing.பரிட்சை > '

    , 'HTTp://go.PRO'
    , 'HTTp://niC.BIZ'
    , 'http://iana.org'
    , 'http://nic.NAme'
    , 'HTTP://NAVY.MIL'
    , 'HTTp://asIA.AsiA'
    , 'http://cooP.Coop'
    , 'http://weather.tel'
    , 'HTTp://baRCELONA.CAT'
    , 'HTTP://VODAFONE.MOBI'
    , 'HTTP://WHITEHOUSE.GOV'

    , 'http://gov.UK'
    , 'http://gov.AU'
    , 'http://govt.NZ'
    , '<http://gov.ZA>'
    , 'http://baidu.cn'
    , 'http://naver.kr'
    , 'http://ADMIN.ch'
    , 'http://google.FR'
    , 'http://google.IT'
    , 'http://google.FI'
    , 'http://google.PT'
    , 'http://nhk.or.jp'
    , 'http://go ogle.DE'
    , 'http://goog le.SE'
    , '<http://google.NO>'
    , 'http://globo.COM.BR'
    , 'http://government.se'
    , '<http://goog   le.IE>'
    , 'http://bbc.co.=>>>>uk'

    , 'http://nic.xyz'
    , 'http://nic.guru'
    , 'http://nic.wiki'
    , 'http://nic.today'
    , 'http://nic.ninja'
    , 'http://nic.space'
    , 'http://nic.tools'
    , '<http://nic.club>'
    , 'http://nic.website'
    , '<http://nic.online>'
    , 'http://mashable.com'
    , 'http://flickr.photos'
    , '<http://godaddy.com/domains'

    , 'http://nic.გе'
    , 'http://gov.мон'
    , 'http://kisa.한국'
    , 'http://163.网址'
    , 'http://163.网络'
    , 'http://ita.عمان'
    , 'http://ati.تونس'
    , 'http://thnic.ไทย'
    , 'http://twnic.台灣'
    , 'http://hkirc.香港'
    , 'http://nic.ایران'
    , 'http://nic.みんな'
    , 'http://163.中文网'
    , 'http://wanda.商城'
    , 'http://cnnic.机构'
    , 'http://wanda.集团'
    , 'http://rnids.срб'
    , 'http://ntra.سورية'
    , 'http://tra.امارات'
    , 'http://ntra.الاردن'
    , 'http://taobao.在线'
    , 'http://marnet.мкд'
    , 'http://cnnic.中国??'
    , 'http://twnic.台湾?&'
    , 'http://dotmasr.مصر'
    , 'http://mtit.فلسطين'
    , 'http://nic.الجزائر'
    , 'http://pta.پاکستان'
    , 'http://mcmc.مليسيا'
    , 'http://sgnic.新加坡'
    , 'http://alibaba.公司'
    , 'http://tencent.游戏'
    , 'http://tencent.商标'
    , 'http://президент.рф'
    , 'http://ictqatar.قطر'
    , 'http://registry.ਭਾਰਤ'
    , 'http://registry.भारत'
    , 'http://redcross.公益'
    , 'http://registry.ভারত'
    , 'http://cnnic.组织机构'
    , 'http://registry.संगठन'
    , 'http://sgnic.சிங்கப்பூர்'
    , 'http://rusnames.дети'
    , 'http://registry.భారత్'
    , 'http://hostmaster.қаз'
    , 'http://registry.بھارت'
    , 'http://registry.இந்தியா'
    , 'http://china-mobile.移动'

    , 'testing.परीक्षा'
    , "testing\n.テスト"
    , 'http://testing.测试'
    , 'http:/testing.إختبار'
    , '<ftp.testing.آزمایشی>'

    , "http://testing.\n\r\nδοκιμή\t"
    , "
    this
    is
    
    a [
    .edu]

    multiline text
    "

    # AI generated
    , '<FTP.TESTING.آزمایشی>'
    , 'Just visit http://google.ca'
    , 'रजिस्टर करें http://btcl.বাংলা पर।'
    , 'FAQ page: http://reg.ОНЛАЙН/faq'
    , 'Old reference link: <ftp.testing.آزمایشی>'
    , 'Legacy path: ftp://testing.טעסט/pub/files'
    , '更多信息请访问 http://hkirc.香港/info?ref=home'
    , 'Visit HTTP://twnic.台湾/about to learn more.'
    , '最新消息请见 http://TWNIC.台湾/news?id=2026-09'
    , 'Check pricing here: http://reg.онлайн/pricing'
    , 'Anonymous access: ftp://testing.טעסט?anon=true'
    , 'Consulta WHOIS: http://twnic.台湾/whois?q=example'
    , 'Download it from http://FREEBSD.org/releases/14.0'
    , 'Technical reference at http://icao.aero/standards'
    , 'Официальный сайт: http://президент.рф?section=news'
    , 'Source repository: http://freebsd.org/cgit/src.git'
    , 'The famous http://520.我爱你/ still exists in 2026.'
    , 'Open a ticket: http://reg.сайт/support?ticket=99213'
    , 'Duplicate on purpose: http://baidu.世界?lang=en&page=2'
    , '查看政策文件 http://cnnic.中國/policy?lang=zh&format=pdf'
    , '请查询 HTTP://cnnic.中國/whois?domain=test 获取更多信息。'
    , "Consultez http://anrt.المغرب pour plus d'informations."
    , 'Duplicate: http://duckduckgo.com/?q=test&kp=-1&kl=br-pt'
    , 'Promo code available: http://reg.сайт?promo=BLACKFRIDAY'
    , 'Search results: http://google.ca/search?q=perl+uri+find'
    , 'See details at: http://registry.భారత్?tab=faq&expand=true'
    , 'For registry data, see http://registry.ભારત?q=domain+list'
    , 'Try http://duckduckgo.com/?q=uri%3A%3Afind&ia=web instead.'
    , 'सभी विवरण http://btcl.বাংলা/register?type=personal पर उपलब्ध हैं।'
    , 'Für weitere Details siehe http://registry.ভারত?category=gov'
    , 'Voir les licences sur http://anrt.المغرب/licenses?year=2026'
    , 'Check out http://baidu.世界?lang=en&page=2 for more details.'
    , 'Check coverage at http://china-mobile.移动?plan=5g&region=sp'
    , 'Verify your token at HTTP://testing.테스트/verify?token=abc123'
    , 'Another duplicate: http://china-mobile.移动?plan=5g&region=sp'
    , 'Stats for 2026: http://hkirc.香港/stats?year=2026&format=json'
    , 'International standard described in http://icao.aero/annex-14'
    , 'Try this search: http://duckduckgo.com/?q=test&kp=-1&kl=br-pt'
    , 'Coverage map available at http://china-mobile.移动/coverage-map'
    , 'Debug mode enabled at http://testing.테스트?debug=true&verbose=1'
    , 'Consulta las políticas en http://REGISTRY.భారత్/policies ahora mismo.'
    , "HTTP://PRESIDENT.RF isn't valid, but http://президент.рф/archive/2025 is."
    , '"We are migrating to http://hkirc.香港/new-portal," the announcement said.'
    , 'Old campaign link: http://520.我爱你?utm_source=old_campaign&utm_medium=email'
    , "See services at http://mos.москва/services (not http://mos.MOSKVA, that's a typo)."
    , 'Compare http://google.ca with http://duckduckgo.com/?q=comparativo before deciding.'
    , 'News: "Russian government announces changes at http://mos.москва/budget?fiscal_year=2026"'
    , '"According to the registry at http://registry.ભારત, over 3000 domains were created this month."'
);

my @non_match_tests = (
    # undef # ERROR
    0, 1, -1
    , 1_234.56
    , -1_234.56

    , 'Россия'
    , 'p|e|rl.o rg'
    , 'h t T p__S://P..E RL.C O_M'
    , 't h15 t3xt d03s n0t c0nt41n 4 t0p l3v3l d0m41n'

    # AI generated (positive samples by AI, then mannually negatified)
    , q|<FT-P.T35T1N'G.آزمایشی>|
    , q|F4Q p4g3: r3g.ОНЛАЙН/f4q|
    , q|Quot3d: "t=wn1c.台湾/quot3d"|
    , 'Ju5t v151t h+t+t+p://g00g_l3.c4'
    , q|รายละเอียดเพิ่มเติมที่ h./1c40.43r0/t"h|
    , q|रजिस्टर करें h^t&t_p://b-t'c"l.বাংলা पर।|
    , "T4b-[[p]]r3f1x3d:\tt35t1n{g}.테스트"
    , '@LL C@P$: C|NN!C.中國/WH9!$?D9M@!N=Y&$Y'
    , q|4n*d 8r4c-k3t5: [h=k1rc.香港/8r4c+k3t5]|
    , q|C9n\$ul'Y&z ://\@:n:rY.المغرب p9ur p+l+|
    , q|&m9j! @fY&r URL: h*Y(Y*p://520.我爱你 ❤️|
    , q|URL 3nd1n"g 1n 5l45h: c'h1n4-m0b1l3.移动/|
    , q|0ld r3f3r3n?c3 l1nk: <ft_p.t35t1n"g.آزمایشی>|
    , q|Y&h& f@m9u$ 520.我爱你/ $Y!ll &x!$Y$ !n 2026.|
    , q|查看政策文件 h^t&t_p://c'nn1c'h015?q=3x4m\p"l3|
    , q|L&G@C_Y P@YH: <F+YP.Y&$Y!N🇳🇪G.טעסט/PU_B/F!L&$>|
    , q|9p&n @ Y!c"k&Y: r&g.сайт/$upp9rY?Y!c'k&Y=99213|
    , q|&m9j! b&f9r& URL: 🌐 h+Y=Y_p://r&g.сайт/g'l9b@l|
    , q|最新消息请见 h^t&t_p://T=WN1C.台湾/n3w5?1d=2026-09|
    , 'LÄ$ M&R PÅ H!T&T^P://~F~R&&B$D.9RG/$&?R&F=NYH&T&R'
    , 'URL w1t*h 53m1c0l0n c&r_uft: h`t~t~p://1c40.43r0;'
    , q|C9m'm@-$&p@r@Y&d: b@!du.世界, r&g.сайт, !c@9.@&r9|
    , q|Πληροφορίες διαθέσιμες στο h+t=t_p://r3g.онлайн/3l|
    , '@N9NYM9U$ @C-C&$$: FT-P://T&$T!N_G.טעסט?@N9N=T=R=U&'
    , q|中文句子中嵌入链接 h*t(t*p://520.我爱你，请注意标点符号。|
    , '更多信息请访问 h#t#t&p://h@k_i+rc.香港/i?n"f\o?r3f=h0m3'
    , 'M!X&D C@$& $C+H&M&: H.T\T?P://R&G!$T=RY.భారత్?X=1&Y=2'
    , 'V1s1t H  T|T|P://t&wn ic.台湾/ab>out 2 lea:rn m_o_r_e.'
    , '4n0t*h3r 0n3: (h/t.t+p://d+uc+kduc_k=g0.c0m/?q=p4r3n5)'
    , q|Z0b4c_z 5zc_z3góły: h.t\t?p://rg15t&ry.ভারত?l4n"g=p>l|
    , 'D0wn_l04d 1t f^r0m h\t\t\p://F^R33B5D.0rg/r3l34535/14.0'
    , '50urc3 r3p051t0ry: h.t.t.p://f@r33b5d.0rg/c&g1t/5rc.g1t'
    , q|5t4t5 f0r 2026: h"k1rc.香港/5t4t5?y34r=2026&f0rm4t=j50n|
    , 'C✅h&c%k c9v&r@g& @t c*h!n@-m9b!l&.移动?p1@n=5g&r&g!9n=$p'
    , 'T3c-h n1c4l r3f3r3n{c}3 4t h_t-t_p://1c40.43r0/5t4nd4rd5'
    , 'Официальный сайт: H$t^T:p://президент.рф?s!e~cti0n=n3w_s'
    , q|C0n5ul]t4 WH015: h^t&t_p://t=wn1c.台湾/wh015?q=3x4m'p"l3|
    , q|C/h&c\k p'r!c!n🇳🇪g h&r&: h+Y=Y_p://r&g.онлайн/p"r!c!n🇳🇪g|
    , '请查询 H^T&T_P://c|nn!c.中國/wh9!$?d9m@!n=t&$t 获取更多信息。'
    , 'Dup1!c@t& 9n purp9$&: h^t&t_p://b@!du.世界?l@n-g=&n&p@g&=2'
    , q|Y3t 4n0t*h3r dup&l1c4t3: r3g.сайт?p^r0m0=B+L4C_KF_RI"D4Y|
    , q|URL w1t_h f+r4g-m3nt: h+t=t_p://r3g.онлайн/p4g3#53cti0n2|
    , q|l0w3rc453 3v3ry_t&hi+n"g: h+t=t_p://m05.москва/53rv'ic35|
    , q|V01r l35 l1c3n+c35 5ur ://4n&rt.المغرب/l1c3n535?y34r=2026|
    , q|URL W!Y&H P9RY N(U+MB&R: H+Y=Y_P://M9$.МОСКВА:8080/@D+M!N|
    , 'M33r 1n+f0r-m4t13 0p h.t,t.p://g00g+l3.c4/n-l?r3f=h0m3p4g3'
    , 'C=l051n-g 54[m-p]l3, p_l41n: h[t](t)p://d+uc+kduc_k=g0.c0m'
    , q|P3r ul_t3r10r1 1n__f0r+m4z10n1 v151t4 c_nn1c.中國?l4n"g=1t|
    , q|C9v&r@g& m@p @v@!l@b🇧🇬l& @Y `c`h!n@-m9b!l&.移动/c9v&r@g&-m@p|
    , 'URL F9L=L9W&D B=Y &XC|L@M@Y!9N: C=H&C|K YH!$ 9U_Y B@!DU.世界!'
    , '54m)p^l3 w1t*h t|r41l1n+g pun_ctu4t10n: h&tˆt%p://g00g_l3.c4.'
    , q{N&$Y&d qu9Y&$: 'Y&h& $!Y& "h+Y=Y_p://m9$.москва" !$ 9ff!c!@l}
    , q|0r4c1ón 3n 35p4ñ0l c0n 3n=l4c3 R3G15T+RY.భారత్, n0t3 l4 c0m4.|
    , q|Dup^l1c4t3 0f #59 w1t*h d1ff3r3nt c453: H_T_T_P://G00G_L3.C4.|
    , q|$&& D&Y@!L$ @Y: H.Y\Y?P://R&G!$Y=RY.భారత్?Y@B=F@Q&&XP@ND=Y=RÚ&|
    , '534r-c_h r35ul-t5: h*t*t*p://g00g-l3.c4/534rc_h?q=p3rl+ur1+f1nd'
    , q|URL f0ll0w3d b'y qu35t10n m4rk: D1d y0u 533 !t)t!://1c40.43r0?|
    , q|1nt3rn4t10n4l 5t4nd4rd d35c'r1b3d 1n h!!p://1c40.43r0/4nn3x-14|
    , q|URL w1t&h d0ub-l3 5l45h p4t&h: h*t(t*p://h&k1rc.香港//r3dund4nt|
    , q|FÜR W&!Y&R& D&Y@!L$ $!&H& H.Y\Y?P://R&G!$Y=RY.ভারত?C@Y&G9RY=G9V|
    , 'सभी विवरण h^t&t_p://b_t@c=l.বাংলা/r&g!$t&r?typ&=p&r$9n@l पर उपलब्ध हैं।'
    , '@n9t&h&r dup1!c@t&: h^t&t_p://c_h!n@-m9b!l&.移动?p1@n=5g&r&g!9n=$p'
    , 'URL W!YH UND&R$C9R& !N QU&RY: H-Y_Y+P://C|NN!C.中國?R&F_!D=@BC_123'
    , q|P_r9m9 c9d& @v@!l@b+l&: h+Y=Y_p://r&g.сайт?p_r9m9=B+L@C_K~F~R!D@Y|
    , 'Dup^l1c4t3: h#t@t#p://d+uc+kduc_k=g0.c0m/?q=t35t&k_p=-1&k"l=b_r-p"t'
    , q|53nt3n;c3 1n H1nd1: अधिक जानकारी के लिए h.t\t?p://r3g15t'r`y.ભારત देखें।|
    , q|URL w1t*h 3n'c0d3d 5p4c3: h??p://d+uc+kduc_k=g0.c0m/?q=ur1%20f1n'd|
    , q|T%r%y h!t!t!p://d+uc+kduc_k=g0.c0m/?q=ur1%34%34f1nd&14=w3b 1n5t34d.|
    , q|$&nY&_n_c& !n @r@b!c: يمكنكم زيارة @n'rY.المغرب لمزيد من المعلومات.|
    , 'F;or r^e^g15t_ry d_a_t_a, s,e..e r#e#g&i?s_t ry.ભારત?q=d0m4_1n+l i_s_t'
    , q|D4h4 f4zl4 b1lg1 1ç1n h+t=t_p://m05.москва/t_r 4dr351n1 z1y4r3t 3d1n.|
    , q|1Pv6-5tyl3 un'r3l4t3d t35t: h^t^t^p5://[2607:5300:60:1509::228d:4134]|
    , 'F#R@$& &M P9RTU#G(U)Ê$ C9M L!NK H!T&T^P://G99G_L&.C@, N9T& @ VÍRG_U_L@.'
    , q|$&nY&_n_c& !n J@p@n&$&: 詳細はこちらをご覧ください h*Y(Y*p://~f~r&&b$d.9rg|
    , q|URL w1t*h p^l)u5 1n qu3ry: h+t+t=p://g00g=l3.c4/534rc_h?q=c%2B%2B+p3rl|
    , '$&nY&n{[c]}& !n K9r&@n: 자세한 내용은 h-Y_Y+p://Y&$Y!n🇳🇪g.테스트 에서 확인하세요.'
    , 'URL !N$!D& P@R&N$ W!YH YR@!L!N🇳🇪G P_UN_C-Y_U@Y!9N: (H-Y_Y+P://YWN!C.台湾).'
    , 'D&b-u_g m9d& &n@b#l&d @t h^t&t_p://t&$t!n_g.테스트?d&b+u-g=t=r=u&&v&r=b9$&=1'
    , q|C0n5u%l]t4 l45 p0lít1c45 3n h.t\t?p://R3G15T-RY.భారత్/p0l1c135 4h0r4 m15m0.|
    , q|URL w1t&h f_r4g$m3nt 4nd qu3ry: h-t_t+p://t35t1n"g.테스트/p4g3?t4b=1#d3t41l5|
    , q|T%r%y t*h15 534rc_h: h%t%t_p://d+uc+kduc_k=g0.c0m/?q=t35t&k'p=-1&kl=b+r-p=t|
    , q|P🇵🇭h_r@$& ~f~r@nç@!$& @v&c l!&n h{Y}Y(p)://@)n)rY.المغرب, n9Y&z l@ v!rg=ul&.|
    , 'C_he_c+K out h)t t(P://b_a1du.世界?l4n=g=e&n&p^a*g3=2 f/or m0r%e D$e[ta]i-l.s.'
    , q|D3ut5c_h3r 54t'z m1t L1n:k h?t?t?p://f'r33b5d.0rg, b34c_h_t3n 513 d45 K0m=m4.|
    , q|V3r1f"y y"o"u"r t"o'k3n 4t H-T_T+P://t_3+5t+1n"g.테스트/v3r1f+y?t-o-k3n=4b_c123|
    , q|0ld c4m"p41g[n] l1nk: 520.我爱你?ut-m_50u_r_c3=0ld_c4m"p41g[n]&ut-m_m3d1u_m=3m41l|
    , q|P-R&\$!D&NY.R_F !\$n'Y v\@l!d, b-u-Y h+Y=Y_p://президент.рф/\@rc'h!v&/2025 \!\$.|
    , q{W& @r& m!g#r@Y!n🇳🇪g Y9 h^Y&Y_p://h&k!rc.香港/n&w-p9rY@l," Y&h& @nn9un'c&m&nY $@!d.}
    , q|V3ry l0n"g qu3ry 5t+r1n"g: h.t\t?p://r3g15t=ry.ভারত?4=1&b=2&c=3&d=4&3=5&f=6&g=7&h=8|
    , q|Русское предложение со ссылкой h+t=t_p://президент.рф, обратите внимание на запятую.|
    , q|$&& $&rv!c&$ @Y h+Y=Y_p://m9$.москва/$&rv!c&$ (n9Y h+Y=Y_p://m9$.M9$KV@, Y&h@Y'$ @ Yyp9).|
    , q|F1n4l dup"l1c4t3 b4t"c'h: h^t&t_p://b41du.世界?l4n"g=3n&p4g3=2 h^t&t_p://b41du.世界?l4n"g=3n&p4g3=2|
    , q|N&w$: "R🇷🇺u$$!@n g9v&rnm&nY @nn9u_n_c&$ c☦️h@n🇳🇪g&$ @Y h+Y=Y_p://m9$.москва/budg&Y?f!$c@l_y&@r=2026"|
    , q|C0m)p4r3 h-t_t-p://g00g(l)3.c4 w1t*h h=t=t0p://d+uc+kduc_k=g0.c0m/?q=c0m'p4r4t1v0 b3f0r3 d3c1d1n'g.|
    , '@c_c9r_d!n🇳🇪g Y9 Y&h& r&g!$Yry @Y h.Y\Y?p://r&g!$Yry.ભારત, 9v&r 3000 d9m@!n$ w&r& c🇭🇷r&@Y&d Yh!$ m9nYh.'
    , q|M'ul't1p^l3 URL5 1n 0n3 l1n3: h1,t2t-p://g00g_l_3.c4 h!t?t!p://d+uc+kduc_k=g0.c0m h:t:t:p://1c40.43r0|
);

foreach my $t (@match_tests) {
    is($t =~ /$regex/, 1, "Test with '$t'")
}

foreach my $t (@non_match_tests) {
    is($t =~ /$regex/, '', "Test with '$t'")
}
1
