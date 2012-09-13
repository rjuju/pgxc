#!/bin/sh
echo "Killing GTM1..."
kill -9 $(ps -ef  | grep gtm1 | grep -v grep | cut -c10-15)
echo "Waiting a little bit..."
sleep 5
echo "Promoting Standby GTM..."
~/travail/pgxc1.0.1/bin/gtm_ctl -Z gtm -D ~/travail/pgxctest/gtm2/ -p ~/travail/pgxc1.0.1/bin promote
echo "Notifying GTM_proxy"
~/travail/pgxc1.0.1/bin/gtm_ctl -Z gtm_proxy -D ~/travail/pgxctest/gtm_proxy1/ -p ~/travail/pgxc1.0.1/bin -o '-s 127.0.0.1 -t 6669' reconnect 
~/travail/pgxc1.0.1/bin/gtm_ctl -Z gtm_proxy -D ~/travail/pgxctest/gtm_proxy2/ -p ~/travail/pgxc1.0.1/bin -o '-s 127.0.0.1 -t 6669' reconnect 
