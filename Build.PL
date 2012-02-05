
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Carp" => 0,
    "Module::Build" => "0.3601",
    "Scalar::Util" => 0,
    "Test::More" => "0.94",
    "Test::Routine" => 0,
    "Test::Routine::Util" => 0,
    "perl" => "5.004"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "class-based *ML-centric templating system",
  "dist_author" => [
    "Yanick Champoux"
  ],
  "dist_name" => "Template-Caribou",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "Template::Caribou",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Exporter" => 0,
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Role" => 0,
    "Tie::Handle" => 0,
    "overload" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
