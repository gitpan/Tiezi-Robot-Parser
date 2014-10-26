#===============================================================================
#  DESCRIPTION:  各站点的解析引擎
#       AUTHOR:  AbbyPan (USTC), <abbypan@gmail.com>
#===============================================================================
package  Tiezi::Robot::Parser::Base;
use strict;
use warnings;
use Moo;

has base => (
    #网站基地址
    is => 'rw',
);

has site => (

    #网站名称
    is => 'rw',
);

has charset => (

    is => 'rw',
);

sub detect_site_by_url {
    my ($self, $url) = @_;
    
    my $site =
          ( $url =~ m#^http://bbs\.jjwxc\.net/# )  ? 'HJJ'
        :                                            'Base';
    
    return $site;
}

sub parse_tiezi_topic {
    #主题贴内容
}

sub parse_tiezi_floors {
    #跟帖内容
    
}

sub parse_tiezi_urls {
    #帖子分页url 
}

sub parse_board_topic {
    #版块内容    
}

sub parse_board_subboards {
    #子版块 url 
}

sub parse_board_tiezis {
    #版块帖子 url
}

sub parse_board_urls {
    #版块分页 url 
}


no Moo;
1;
