Template-Caribou=/home/yanick/work/perl-modules/Template-Caribou CD=. {
lib Files=lib {
  Template/Caribou.pm
  Template/Caribou/Tags.pm
  Template/Caribou/Utils.pm
  Template/Caribou/Tags/HTML/Extended.pm
}
tests Files=t {
  tags_extended.t
  usecase_2.t
  render.t
  basic.t
  usecase_1.t
  corpus/usecase_1.bou
  corpus/usecase_2/page.bou
  corpus/usecase_2/body.bou
  corpus/usecase_2/head.bou
  lib/UseCase/Two.pm
  lib/UseCase/One.pm
}
distro Files=. {
  .gitignore
  Changes
  MANIFEST
  MANIFEST.SKIP
  dist.ini
}
}
