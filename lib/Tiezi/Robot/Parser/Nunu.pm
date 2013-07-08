#ABSTRACT: 努努书坊的解析模块
package Novel::Robot::Parser::Nunu;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use Web::Scraper;

has '+base_url'  => ( default => sub {'http://book.kanunu.org'} );
has '+site'    => ( default => sub {'Nunu'} );
has '+charset' => ( default => sub {'cp936'} );

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//td[@height="30"]', 'writer' => 'TEXT';
        process_first 'h1', 'book' => 'TEXT';
        process '//tr[@bgcolor="#ffffff"]//td//a', 'chapter_info[]' => {
            'title' => 'TEXT', 'url' => '@href'
        };
        };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：(.+?)\s*发布时间.*/$1/;

    $ref->{chapter_info} = [ grep { exists $_->{url} } @{$ref->{chapter_info}} ];
    $ref->{chapter_num} = scalar(@{ $ref->{chapter_info} });
    unshift @{$ref->{chapter_info}}, undef;

    my ($url) = $$html_ref=~m#上一篇：\s*<a href='/(book[^>]+?/\d+)/index.html'>#s;
    my ($book_id) = $url=~m#/(\d+)$#;
    $book_id++;
    $url=~s#/(\d+)$#/$book_id#;

    for my $i (1 .. $ref->{chapter_num}){
        my $r = $ref->{chapter_info}[$i];
        $r->{url}="$self->{base_url}/$url/$r->{url}";
        $r->{id} = $i;
    }

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//td[@width="820"]', 'content' => sub {
            $self->get_inner_html( $_[0] );
        };
    };
    my $ref = $parse_chapter->scrape($html_ref);

    @{$ref}{qw/title book writer/}= $$html_ref=~m#<title>\s*(.+?)_(.+?)_\s*(.+?)\s*小说在线阅读#s;

    return unless ( defined $ref->{book} and defined $ref->{content});

    return $ref;
} ## end sub parse_chapter


no Moo;
1;
