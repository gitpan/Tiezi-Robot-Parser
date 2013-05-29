# ABSTRACT: 帖子站点解析引擎
package  Tiezi::Robot::Parser;
use Moo;
use Tiezi::Robot::Parser::HJJ;

our $VERSION =0.06;

sub init_parser {
    my ( $self, $site ) = @_; 
    my $s      = $self->detect_site($site);
    my $parser = eval qq[new Tiezi::Robot::Parser::$s()];
    return $parser;
} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_; 
    return $url unless ( $url =~ /^http/ );

    my $site =
          ( $url =~ m#^http://bbs\.jjwxc\.net/# )  ? 'HJJ'
        :                                            'Base';

    return $site;
} ## end sub detect_site


no Moo;
1;
