source /home/ubuntu/.profile
cd /home/ubuntu/
sudo chown -R ubuntu:ubuntu onyxbay
cd onyxbay/config/
cp -a example/. .
echo '\n' >> admins.txt
echo $ADMINS >> admins.txt