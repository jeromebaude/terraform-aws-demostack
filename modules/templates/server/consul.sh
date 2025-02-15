#!/usr/bin/env bash
set -e

echo "==> Consul (server)"
if [ ${enterprise} == 0 ]
then
echo "--> Fetching OSS binaries"
install_from_url "consul" "${consul_url}"
else
echo "--> Fetching enterprise binaries"
install_from_url "consul" "${consul_ent_url}"
fi


echo "--> Writing configuration"
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${region}",
  "acl_master_token": "${consul_master_token}",
  "acl_token": "${consul_master_token}",
  "acl_default_policy": "allow",
  "advertise_addr": "$(private_ip)",
  "advertise_addr_wan": "$(public_ip)",
  "bootstrap_expect": ${consul_servers},
  "bind_addr": "0.0.0.0",
  "data_dir": "/mnt/consul",
  "disable_update_check": true,
  "encrypt": "${consul_gossip_key}",
  "leave_on_terminate": true,
  "node_name": "${node_name}",
  "raft_protocol": 3,
  "retry_join": ["provider=aws tag_key=${consul_join_tag_key} tag_value=${consul_join_tag_value}"],
  "server": true,
 
  "addresses": {
    "http": "0.0.0.0",
    "https": "0.0.0.0",
    "gRPC": "0.0.0.0"
  },
  "ports": {
    "http": 8500,
    "https": 8501,
    "gRPC": 8502
  },
  "key_file": "/etc/ssl/certs/me.key",
  "cert_file": "/etc/ssl/certs/me.crt",
  "ca_file": "/usr/local/share/ca-certificates/01-me.crt",
  "verify_incoming": true,
  "verify_outgoing": false,
  "verify_server_hostname": false,
   "auto_encrypt": {
    "allow_tls": true
  },
  "ui": true,
  "autopilot": {
    "cleanup_dead_servers": true,
    "last_contact_threshold": "200ms",
    "max_trailing_logs": 250,
    "server_stabilization_time": "10s",
    "redundancy_zone_tag": "",
    "disable_upgrade_migration": false,
    "upgrade_version_tag": "build"
},
"node_meta": {
    "build": "1.0.0",
    "type" : "server"
  },
 "connect":{
  "enabled": true,
  "ca_provider" : "consul"
      }
}
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/consul.sh > /dev/null <<"EOF"
alias conslu="consul"
alias ocnsul="consul"
EOF
source /etc/profile.d/consul.sh

echo "--> Generating systemd configuration"
sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul
Documentation=https://www.consul.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable consul
sudo systemctl restart consul

echo "--> Installing dnsmasq"
ssh-apt install dnsmasq
sudo tee /etc/dnsmasq.d/10-consul > /dev/null <<"EOF"
server=/consul/127.0.0.1#8600
no-poll
server=8.8.8.8
server=8.8.4.4
cache-size=0
EOF
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

echo "--> Waiting for all Consul servers"
while [ "$(consul members 2>&1 | grep "server" | grep "alive" | wc -l)" -lt "${consul_servers}" ]; do
  sleep 3
done

echo "--> Waiting for Consul leader"
while [ -z "$(curl -s http://127.0.0.1:8500/v1/status/leader)" ]; do
  sleep 3
done

if [ ${enterprise} == 1 ]
then
echo "--> apply Consul License"
sudo consul license put "${consullicense}" > /tmp/consullicense.out


fi


echo "--> Denying anonymous access to vault/ and tmp/"
curl -so /dev/null -X PUT http://127.0.0.1:8500/v1/acl/update \
  -H "X-Consul-Token: ${consul_master_token}" \
  -d @- <<BODY
{
  "ID": "anonymous",
  "Rules": "key \"vault\" { policy = \"deny\" }\n\nkey \"tmp\" { policy = \"deny\" }"
}
BODY



echo "==> Consul is done!"
