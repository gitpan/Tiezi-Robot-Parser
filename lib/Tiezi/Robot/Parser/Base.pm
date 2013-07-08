#ABSTRACT: 帖子解析基础模块
package  Tiezi::Robot::Parser::Base;
use Moo;

has 'base'    => ( is => 'rw' );
has 'site'    => ( is => 'rw' );
has 'charset' => ( is => 'rw' );

no Moo;
1;
