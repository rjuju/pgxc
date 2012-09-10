#/bin/sh
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/datanode1 -m immediate stop
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/datanode2 -m immediate stop
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/coord1 -m immediate stop
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/coord2 -m immediate stop
~/travail/pgxc1.0.1/bin/gtm_ctl -D ~/travail/pgxctest/gtm -m immediate stop -Z gtm
~/travail/pgxc1.0.1/bin/gtm_ctl -D ~/travail/pgxctest/gtm_proxy -m immediate stop -Z gtm_proxy

rm -rf ~/travail/pgxctest/
