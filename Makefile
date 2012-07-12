all:

## Run tests:
##     $ make test
## Update dependency list:
##     $ make local-submodules pmb-update
## Install dependent Perl modules into ./local:
##     $ make pmb-install

## ------ Environment setup ------

WGET = wget
PERL = perl
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)

PMB_PMTAR_REPO_URL =
PMB_PMPP_REPO_URL = 

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120337

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

lperl lplackup local-perl perl-version perl-exec \
local-submodules \
pmb-install pmb-update cinnamon \
generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@ \
	    PMB_PMTAR_REPO_URL=$(PMB_PMTAR_REPO_URL) \
	    PMB_PMPP_REPO_URL=$(PMB_PMPP_REPO_URL)

## ------ Tests ------

GIT = git
PROVE = prove
PERL_ENV = PATH="$(abspath ./local/perl-$(PERL_VERSION)/pm/bin):$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat config/perl/libs.txt)"

test: test-deps test-main

test-deps: git-submodules local-submodules pmb-install

git-submodules:
	$(GIT) submodule update --init

test-main:
	$(PERL_ENV) $(PROVE) t/httest/*.t

GENERATEPM = local/generatepm/bin/generate-pm-package

dist: generatepm
	$(GENERATEPM) config/dist/XXX.pi dist/
