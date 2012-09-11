#!/bin/sh
echo "Promoting Standby GTM..."
~/travail/pgxc1.0.1/bin/gtm_ctl -Z gtm -D ~/travail/pgxctest/gtm2/ promote
echo "Notifying GTM_proxy"
~/travail/pgxc1.0.1/bin/gtm_ctl -Z gtm_proxy -D ~/travail/pgxctest/gtm_proxy/ -o "-s localhost -t 6669" reconnect 

