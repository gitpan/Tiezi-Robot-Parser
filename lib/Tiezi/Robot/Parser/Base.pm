#  ABSTRACT:  各BBS站点的解析引擎
package  Tiezi::Robot::Parser::Base;
use strict;
use warnings;
use Moo;

#网站基地址
has base => ( is => 'rw' );

#网站名称
has site => ( is => 'rw' );

has charset => ( is => 'rw' );

#主题贴内容
sub parse_tiezi_topic { }

#跟帖内容
sub parse_tiezi_floors { }

#帖子分页url
sub parse_tiezi_urls { }

#版块内容
sub parse_board_topic { }

#子版块 url
sub parse_board_subboards { }

#版块帖子 url
sub parse_board_tiezis { }

#版块分页 url
sub parse_board_urls { }

no Moo;
1;
