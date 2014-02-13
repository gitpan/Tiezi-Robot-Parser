#  ABSTRACT:  红晋江的解析模块
package Tiezi::Robot::Parser::HJJ;
use strict;
use warnings;
use utf8;

use base  'Tiezi::Robot::Parser';

use Encode;
use Web::Scraper;

our $BASE = 'http://bbs.jjwxc.net';
our $CHARSET = 'cp936';

sub parse_tiezi_topic {
    my ( $self, $html_ref ) = @_;
    my %t;
    for ($$html_ref) {
        return unless ($_);

        ( $t{title} ) =
m{<td bgcolor="#E8F3FF"><div style="float: left;">\s*主题：(.+?)<font color="#999999" size="-1">}s;
        ( $t{content} ) =
m{<td class="read"><div id="topic">(.*?)</div>\s*</td>\s*</tr>\s*</table>}s;
        $t{content} =~ s#</?font[^>]+>##sg;
        ( $t{name}, $t{time} ) =
m#№0&nbsp;</font>.*?☆☆☆</font>(.*?)</b><font color="99CC00">于</font>(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})留言#s;
        $t{name} =~ s/<\/?(font|b).*?>//gsi;
        $t{id} = 0;
    } ## end for ($$html_ref)

    return \%t;
} ## end sub parse_tiezi_topic

sub parse_tiezi_floors {
    my ( $self, $html_ref ) = @_;

    my @floor;
    while ( $$html_ref =~
m#(<tr>\s+<td colspan="2">.*?<td><font color=99CC00 size="-1">.*?</tr>)#gis
      )
    {
        my $cell = $1;
        next unless ($cell);

        my %fl;

        ( $fl{name}, $fl{time} ) =
          $cell =~
m#☆☆☆</font>(.*?)</b><font color="99CC00">于</font>(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})留言#s;
        $fl{name} =~ s/<\/?(font|b).*?>//gsi;
        $fl{name} =~ s/^-*//;
        $fl{name} ||= 'unknown';

        ( $fl{content} ) =
          $cell =~
          m{<tr>\s*<td[^>]*class="read">\s*(.*?)\s*</td>\s*</tr>\s*</table>}s;
        for ( $fl{content} ) {
s#本帖尚未审核,若发布24小时后仍未审核通过会被屏蔽##s;
            s#</?font[^>]*>##isg;
            s#</?(b|u)>##sig;
        }


        $fl{title} = '';
        ( $fl{id} ) = $cell =~ m{№(\d+)</font>}s;

        $self->calc_floor_wordnum(\%fl);

        push @floor, \%fl;
    } ## end while ( $$html_ref =~ ...)

    return \@floor;
} ## end sub parse_tiezi_floors

sub parse_tiezi_urls {
    my ( $self, $html_ref ) = @_;
    my ($page_info) =
      $$html_ref =~
      m[<div id="pager_top" align="center" style="padding:10px;">(.+?)</div>]s;
    return unless ($page_info);

    my ( $page_num, $page_url ) =
      $page_info =~ m[共(\d+)页.+?<a href=(.+?page=)\d]s;
    my @urls =
      map { "$BASE/showmsg.php$page_url$_" } ( 1 .. $page_num - 1 );
    return \@urls;
} ## end sub parse_tiezi_urls

sub parse_board_topic {
    my ( $self, $html_ref ) = @_;
    my %t;
    ( $t{title} ) =
      $$html_ref =~
m[<div style="float:left;position:relative;padding-top:3px;padding-left:4px;"><font color="red">(.+?)</font></div>]s;
    return \%t;
} ## end sub parse_board_topic

sub parse_board_subboards {
    my ( $self, $html_ref ) = @_;
    my ($jh) =
      $$html_ref =~ m{<a href="([^"]+?)" target="_blank">精华区</a>}s;
    my ($th) =
      $$html_ref =~ m{<a href="([^"]+?)" target="_blank">套红区</a>}s;
    my ($jx) =
      $$html_ref =~ m{<a href="([^"]+?)" target="_blank">加☆区</a>}s;
    my @sub_board_urls = map { "$BASE/$_" } ( $jh, $th, $jx );
    return \@sub_board_urls;
} ## end sub parse_board_subboards

sub parse_board_tiezis {
    my ( $self, $html_ref ) = @_;

    my @tiezi_list =
      split( /<tr valign="middle" bgcolor="#FFE7F7">/, $$html_ref );
    shift @tiezi_list;

    for (@tiezi_list) {
        my %temp;
        @temp{qw/url title/} =
          m{href="(showmsg.php\?board=\d+[^>]*?&id=\d+)[^>]+>(.+?)</a>}s;
        @temp{qw/name/} = m{</td></tr></table></td>\s+<td>&nbsp;(.+?)</td>}s;
        @temp{qw/time/} =
          m{<td align="center"><font size="-1">(.+?)</font></td>}s;
        $temp{url} = "$BASE/$temp{url}";
        $temp{title} =~ s#</?font[^>]*>##g;
        $_ = \%temp;
    } ## end for (@tiezi_list)
    return \@tiezi_list;
} ## end sub parse_board_tiezis

sub parse_board_urls {
    my ( $self, $html_ref ) = @_;
    my ($u) = $$html_ref =~
m{href=(board.php\?[^>]+?page=)\d+\s+><img src="img/anniu1.gif" alt="下一页"}s;
    my ($n) = $$html_ref =~ m{共<font color="\#FF0000">(\d+)</font>页}s;
    my @board_urls =
      map { "$BASE/$u$_" } ( 2 .. $n );
    return \@board_urls;
} ## end sub parse_board_urls

sub make_query_request {

    my ( $self, $keyword, %opt ) = @_;
    my %qt = (
        '主题贴内容'    => 1,
        '跟贴内容'       => 2,
        '贴子主题'       => 3,
        '主题贴发贴人' => 4,
        '跟贴发贴人'    => 5,
    );
    my $q = $opt{query} || 3;
    my $type = exists $qt{ $q } ? $qt{ $q } : $q;

    my $url = $BASE . '/search.php?act=search';
    my $post = {
        'board'   => $opt{board} + 0,
        'keyword' => encode( $CHARSET, $keyword ),
        'topic'   => $type,
        'submit'  => encode( $CHARSET, '查询' ),
    };

    return ( $url, $post );

} ## end sub make_query_request

sub parse_query_result_urls {
    my ( $self, $html_ref ) = @_;
    my ($page_num) = $$html_ref =~ m[<font color="\#FF0000">(\d+)</font>]s;
    my ($url)      = $$html_ref =~
m[id="selectpage" onChange="location.href='(.+?)'\+this.value"></select>]s;
    my @urls = map { encode( $CHARSET, "$BASE$url$_" ) }
      ( 2 .. $page_num );

    return \@urls;
} ## end sub parse_query_result_urls


#sub parse_query {
    #my ( $self, $html_ref ) = @_;

    #my $parse_query = scraper {
        #process '//table[@cellpadding="2"]//tr', 'tiezis[]' => sub {
            #my $h = $_[0]->look_down( '_tag', 'a' );
            #return unless ($h);
            #my $title = $h->as_trimmed_text;
            #$title =~ s#</?font[^>]+>##ig;
            #my $url = $h->attr('href');
            #$url = "$BASE/$url";
            #return {
                #'title' => $title,
                #url     => encode( $CHARSET, $url )
            #};
        #};
        #result 'tiezis';
    #};
    #my $ref = $parse_query->scrape($html_ref);

    #return $ref;
#} ## end sub parse_query

sub parse_query {
    my ($self, $html_ref) = @_;
    my $parse_query = scraper {
        process '//table[@cellpadding="2"]//tr', 'tiezis[]' => scraper {
            process_first '//a', 'url'    => '@href';
            process '//td',      'info[]' => 'TEXT';
        };
        result 'tiezis';
    };
    my $ref  = $parse_query->scrape($html_ref);
    my @data = map {
    my $r = $_->{info};
    s/^\s+|\s+$//g for @$r;
    {
        url    => "$BASE/$_->{url}",
        title  => $r->[1],
        poster => $r->[2],
        time_s => $r->[3],
        time_e => $r->[4],
        reply  => $r->[5]+0,
        click  => $r->[6]+0,
    }
    } 
    grep { $_->{url} }  
    @$ref;
    return \@data;
}

1;
