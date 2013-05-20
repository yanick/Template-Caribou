
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Bar" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Moose::Util" => 0,
    "Test::More" => "0.88",
    "Test::Routine" => 0,
    "Test::Routine::Util" => 0,
    "autodie" => 0,
    "perl" => "v5.10.0"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "class-based HTML-centric templating system",
  "dist_author" => [
    "Yanick Champoux <yanick\@cpan.org>"
  ],
  "dist_name" => "Template-Caribou",
  "dist_version" => "0.2.1",
  "license" => "perl",
  "module_name" => "Template::Caribou",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "CSS::LESSp" => 0,
    "Carp" => 0,
    "List::Pairwise" => 0,
    "Method::Signatures" => 0,
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Role" => 0,
    "MooseX::ClassAttribute" => 0,
    "MooseX::Role::Parameterized" => 0,
    "MooseX::SemiAffordanceAccessor" => 0,
    "Path::Class" => 0,
    "Sub::Exporter" => 0,
    "Text::MultiMarkdown" => 0,
    "Tie::Handle" => 0,
    "XML::Twig" => 0,
    "overload" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
