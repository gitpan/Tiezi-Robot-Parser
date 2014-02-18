
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "\x{5c0f}\x{8bf4}\x{7ad9}\x{70b9}\x{89e3}\x{6790}\x{5f15}\x{64ce}",
  "AUTHOR" => "abbypan <abbypan\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Tiezi-Robot-Parser",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Tiezi::Robot::Parser",
  "PREREQ_PM" => {
    "Web::Scraper" => 0
  },
  "TEST_REQUIRES" => {},
  "VERSION" => "0.11",
  "test" => {
    "TESTS" => ""
  }
);


my %FallbackPrereqs = (
  "Web::Scraper" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



