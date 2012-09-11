#/bin/sh

dir=0;
bin=0;

while getopts ":d:b:" opt; do
  case $opt in
    d) dir=$OPTARG
      ;;
    b) bin=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG">&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument">&2
      exit 1
      ;;
  esac
done

if [ $dir -eq 0 ] 2>/dev/null
then
  dir='.'
fi

if [ $bin -eq 0 ] 2>/dev/null
then
  bin='./bin'
fi

echo "dir: $dir bin: $bin"

#1. Make dirs
#mkdir $dir/gtm
#mkdir $dir/gtm_proxy
#mkdir $dir/coord1
#mkdir $dir/coord2
#mkdir $dir/datanode1
#mkdir $dir/ datanode2

#2. Setup GTM & proxy
echo " ==> Generating GTM1..."
$bin/initgtm -Z gtm -D $dir/gtm1/
sed -i "s/^nodename.*/nodename = 'GTM1'				# Specifies the node name./"		$dir/gtm1/gtm.conf
sed -i "s/^port.*/port = 6668					# Port number of this GTM./"		$dir/gtm1/gtm.conf
echo " ==> Done."
echo " ==> Launching GTM1..."
$bin/gtm_ctl -Z gtm -D $dir/gtm1/ -p $bin/ -l $dir/gtm1/gtm.log start
echo " ==> Done."
echo " ==> Generating GTM2..."
$bin/initgtm -Z gtm -D $dir/gtm2/
sed -i "s/^nodename.*/nodename = 'GTM2'				# Specifies the node name./"		$dir/gtm2/gtm.conf
sed -i "s/^port.*/port = 6669					# Port number of this GTM./"		$dir/gtm2/gtm.conf
sed -i "s/^#startup.*/startup = STANDBY				# Start mode. ACT\/STANDBY./" 		$dir/gtm2/gtm.conf
sed -i "s/^#active_host.*/active_host = 'localhost'		# Listen address of active GTM./"	$dir/gtm2/gtm.conf
sed -i "s/^#active_port.*/active_port = 6668			# Port number of active GTM./"		$dir/gtm2/gtm.conf
echo " ==> Done."
echo " ==> Launching GTM2..."
$bin/gtm_ctl -Z gtm -D $dir/gtm2/ -p $bin/ -l $dir/gtm2/gtm.log start
echo " ==> Done."
echo ""

echo " ==> Generating GTM Proxy..."
$bin/initgtm -Z gtm_proxy -D $dir/gtm_proxy/
sed -i "s/^nodename.*/nodename = 'GTMPROXY'			# Specifies the node name./" $dir/gtm_proxy/gtm_proxy.conf
echo " ==> Done."
echo " ==> Launching GTM Proxy..."
$bin/gtm_ctl -Z gtm_proxy -D $dir/gtm_proxy/ -p $bin/ -l $dir/gtm_proxy/gtm_proxy.log start
echo "$bin/gtm_ctl -Z gtm_proxy -D $dir/gtm_proxy/ -p $bin/ -l $dir/gtm_proxy/logfile.txt start"
echo " ==> Done."
echo ""


#3. Setup Datanodes 1 & 2
echo " ==> Generating Datanode1..."
$bin/initdb -U postgres -D $dir/datanode1 --nodename datanode1
sed -i 's/^#port.*/port = 15532				# (change requires restart)/' $dir/datanode1/postgresql.conf
sed -i "s/^#log_line_prefix.*/log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '                   # special values:/" $dir/datanode1/postgresql.conf
sed -i 's/^#logging_collector.*/logging_collector = on		# Enable capturing of stderr and csvlog/' $dir/datanode1/postgresql.conf
echo " ==> Done"
echo "Launching Datanode1..."
$bin/pg_ctl -U postgres -D $dir/datanode1 -Z datanode -l $dir/datanode1/logfile.txt start
echo " ==> Done"
echo ""

echo " ==> Generating Datanode2..."
$bin/initdb -U postgres -D $dir/datanode2 --nodename datanode2
sed -i 's/^#port.*/port = 15533				# (change requires restart)/' $dir/datanode2/postgresql.conf
sed -i "s/^#log_line_prefix.*/log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '                   # special values:/" $dir/datanode2/postgresql.conf
sed -i 's/^#logging_collector.*/logging_collector = on		# Enable capturing of stderr and csvlog/' $dir/datanode2/postgresql.conf
echo " ==> Done"
echo " ==> Launching Datanode2..."
$bin/pg_ctl -U postgres -D $dir/datanode2 -Z datanode -l $dir/datanode2/logfile.txt start
echo " ==>Done"
echo ""

#4. Setup Coordinators 1 & 2
echo " ==> Generating Coordinator1..."
$bin/initdb -U postgres -D $dir/coord1 --nodename coord1
sed -i 's/^#port.*/port = 5532				# (change requires restart)/' $dir/coord1/postgresql.conf
sed -i 's/#pooler_port.*/pooler_port = 6660                     # Pool Manager TCP portf/' $dir/coord1/postgresql.conf
sed -i "s/#log_line_prefix.*/log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '                   # special values:/" $dir/coord1/postgresql.conf
sed -i 's/#logging_collector.*/logging_collector = on		# Enable capturing of stderr and csvlog/' $dir/coord1/postgresql.conf
echo " ==> Done"
echo " ==> Launching Coordinator1..."
$bin/pg_ctl -U postgres -D $dir/coord1 -Z coordinator -l $dir/coord1/logfile.txt start
echo " ==> Done"
echo ""

echo " ==> Generating Coordinator2..."
$bin/initdb -U postgres -D $dir/coord2 --nodename coord2
sed -i 's/^#port.*/port = 5533				# (change requires restart)/' $dir/coord2/postgresql.conf
sed -i 's/#pooler_port.*/pooler_port = 6661                     # Pool Manager TCP portf/' $dir/coord2/postgresql.conf
sed -i "s/#log_line_prefix.*/log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '                   # special values:/" $dir/coord2/postgresql.conf
sed -i 's/#logging_collector.*/logging_collector = on		# Enable capturing of stderr and csvlog/' $dir/coord2/postgresql.conf
echo "Done"
echo " ==> Launching Coordinator2..."
$bin/pg_ctl -U postgres -D $dir/coord2 -Z coordinator -l $dir/coord2/logfile.txt start
echo " ==> Done"
echo ""
sleep 2

#5. Declare nodes in cluster
echo " ==> Declaring 2 nodes in Coordinator1..."
$bin/psql -p 5532 -h localhost -c "CREATE NODE dn1 WITH (TYPE='datanode', PORT=15532);CREATE NODE dn2 WITH (TYPE='datanode', PORT=15533);CREATE NODE coord2 WITH (TYPE='coordinator', PORT=5533);select pgxc_pool_reload();"
echo " ==>Done."
echo " ==> Declaring 2 nodes in Coordinator2..."
$bin/psql -p 5533 -h localhost -c "CREATE NODE dn1 WITH (TYPE='datanode', PORT=15532);CREATE NODE dn2 WITH (TYPE='datanode', PORT=15533);CREATE NODE coord1 WITH (TYPE='coordinator', PORT=5532);select pgxc_pool_reload();"
echo " ==>Done."

