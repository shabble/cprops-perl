package CProps;

use Cwd;
use Inline C
  => Config
#  => ENABLE => 'AUTOWRAP'
#  => PREFIX => 'cp_'
  => TYPEMAPS => getcwd() . "/typemap"
  => MYEXTLIB => '/opt/local/lib/libcprops.dylib'
  => INC => '/opt/local/include/cprops';

use Inline 'C' => 'src/cprops.c';

1;
