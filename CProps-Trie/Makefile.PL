use strict;
use warnings;
use Cwd;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

unless(header_found())
{
    die <<"END";
ERROR: Can't find cprops/collection.h header.

If the library is not installed, you will need to install it. If it is
installed somewhere other than /usr or /usr/local, you need to set the
following environment variables:

    LIBCPROPS_LIBDIR should contain the path to the libusb libraries
    LIBCPROPS_INCDIR should contain the path to the libusb include files

END
}

unless(lib_found())
{
    die <<"END";
ERROR: Can't find libcprops library.

If the library is not installed, you will need to install it. If it is
installed somewhere other than /usr or /usr/local, you need to set the
following environment variables:

    LIBCPROPS_LIBDIR should contain the path to the libcprops libraries
    LIBCPROPS_INCDIR should contain the path to the libcprops include files

END
}

WriteMakefile(
              NAME              => 'CProps::Trie',
              AUTHOR            => 'shabble <shabble+cpan@metavore.org>',
              VERSION_FROM      => 'lib/CProps/Trie.pm', # finds $VERSION
              ABSTRACT_FROM     => 'lib/CProps/Trie.pm',
              PL_FILES          => {},
              # LIBS              => ["-L/opt/local/lib -lcprops"],
              # INC               => "-I/opt/local/include/cprops",
              LIBS              => [ lib_loc() ],
              INC               => header_loc(),
              PREREQ_PM         => {
                                    'Test::More'        => 0,
                                    'Carp'              => 0,
                                    'MooseX::Declare'   => 0,
                                   },
              dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
              clean               => {
                                      FILES => 'CProps-Trie-* Trie.inl _Inline'
                                     },
             );


sub header_loc {
    my $dir = header_found();
    die "Still can't find headers" unless $dir;
    return "-I" . $dir . "/cprops";
}

sub lib_loc {
    my $dir = lib_found();
    die "Still can't find library" unless $dir;
    return "-L" . $dir . " -lcprops";
}

sub header_found {
    my @dirs = (
                qw(/usr/include /usr/local/include /opt/local/include),
                $ENV{LIBCPROPS_INCDIR}
               );

    foreach my $dir (@dirs) {
        return $dir if defined $dir && -e "$dir/cprops/collection.h";
    }

    return;
}

sub lib_found {
    my @dirs = (
                qw(/usr/local/lib64 /usr/lib64 /lib64 /usr/lib /usr/local/lib),
                qw(/opt/local/lib), $ENV{LIBUSB_LIBDIR}
               );

    foreach my $dir (@dirs) {
        return $dir
          if defined $dir
            && (-e "$dir/libcprops.so" || -e "$dir/libcprops.dylib");
    }

    return;
}
