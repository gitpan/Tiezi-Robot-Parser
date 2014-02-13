# ABSTRACT: 小说站点解析引擎
package  Tiezi::Robot::Parser;
our $VERSION = 0.10;

sub new {
    my ( $self, %opt) = @_;

    $opt{site}      = $self->detect_site($opt{site}) || 'HJJ';
    my $module = "Tiezi::Robot::Parser::$opt{site}";

    eval "require $module;";
    bless { %opt }, $module;

} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my $site =
          ( $url =~ m#^http://bbs\.jjwxc\.net/# )  ? 'HJJ'
        :                                            'Base';
    return $site;
} ## end sub detect_site

sub calc_floor_wordnum {
    my ($self, $f) = @_;
    return if(exists $f->{word_num});
    my $wd = $f->{content};
    $wd =~ s/<[^>]+>//gs;
    $f->{word_num} = $wd =~ s/\S//gs;
    return $f;
}

1;
