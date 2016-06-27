use inc::Module::Install;
use English qw(-no_match_vars);

name 'FusionInventory-Agent';
include 'Module::AutoInstall';
abstract 'Armadito Agent for Linux and Windows';
license 'gpl';
repository 'https://github.com/armadito/armadito-agent';
version_from 'lib/Armadito/Agent.pm';
perl_version '5.008';
authors 'Teclib';

# requires 'FusionInventory::Agent'        => '0';
# TODO : add dependencies requires

resources
    homepage    => "http://www.teclib-edition.com/en/teclib-products/armadito-antivirus/",
    bugtracker  => "https://github.com/armadito/armadito-agent/issues",
    repository  => "https://github.com/armadito/armadito-agent",
    IRC         => "http://webchat.freenode.net/#armadito";

makemaker_args(
    test => {
        TESTS => join ' ', map { glob } qw(
            t/*.t
            t/*/*.t
            t/*/*/*.t
            t/*/*/*/*.t
            t/*/*/*/*/*.t
        )
    },
    INSTALLMAN3DIR => 'none'
);

WriteAll;
