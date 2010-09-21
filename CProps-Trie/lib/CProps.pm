package CProps;

use Cwd;
use Inline C
 => Config
 => TYPEMAPS    => getcwd() . "/typemap"
 => LIBS        => '-L/opt/local/lib -lcprops'
 => INC         => '/opt/local/include/cprops'
 => FORCE_BUILD => 1;

use Inline 'C' => 'src/cprops.c';

1;
