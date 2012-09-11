#!/bin/sh
echo "Shutting down datanode1..."
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/datanode1 -m immediate stop
echo "Shutting down datanode2..."
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/datanode2 -m immediate stop
echo "Shutting down coordinator1..."
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/coord1 -m immediate stop
echo "Shutting down coordinator2..."
~/travail/pgxc1.0.1/bin/pg_ctl -D ~/travail/pgxctest/coord2 -m immediate stop
echo "Shutting down GTM_proxy..."
~/travail/pgxc1.0.1/bin/gtm_ctl -D ~/travail/pgxctest/gtm_proxy -m immediate stop -Z gtm_proxy
echo "Shutting down GTM1..."
~/travail/pgxc1.0.1/bin/gtm_ctl -D ~/travail/pgxctest/gtm1 -m immediate stop -Z gtm
echo "Shutting down GTM2..."
~/travail/pgxc1.0.1/bin/gtm_ctl -D ~/travail/pgxctest/gtm2 -m immediate stop -Z gtm

rm -rf ~/travail/pgxctest/
