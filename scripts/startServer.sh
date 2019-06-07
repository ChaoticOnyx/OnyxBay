source /home/ubuntu/.profile
source /home/ubuntu/byond/bin/byondsetup

cd /home/ubuntu/onyxbay/tgui/
npm install
gulp --min
cd /home/ubuntu/onyxbay

nohup DreamDaemon baystation12.dmb 2507 -trusted -invisible -logself  > /dev/null 2> /dev/null < /dev/null &
echo "Started Stage server"