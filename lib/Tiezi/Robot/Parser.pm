# ABSTRACT: 帖子站点解析引擎
use strict;
use warnings;
package  Tiezi::Robot::Parser;
use Moo;
use Tiezi::Robot::Parser::HJJ;

sub init_parser {
      my ( $self, $site ) = @_;
      my $parser = eval qq[new Tiezi::Robot::Parser::$site()];
      return $parser;
}

no Moo;
1;
